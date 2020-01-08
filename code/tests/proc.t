\l automl.q
.aml.loadfile`:init.q

\d .aml

// Input Matrix
mattrn:flip (til 5;01010b;asc til 5;7.6 1.2 9.5 8.3 2.4;11001b)
mattst:flip (3 2 1 9 0;10101b;9 8 2 3 4;8.4 3.2 7.9 0.1 2.2;10110b)
data:(mattrn;10101b;mattst;11001b)

mdldict:flip`model`lib`fnc`seed`typ!flip key[d],'value d:proc.i.txtparse[`class;"/code/mdldef/"]

scf:.ml.accuracy
p:i.normaldefault[]

// Compile sklearn and keras mdls

minitsk:proc.i.mdlfunc[`sklearn;`ensemble;`RandomForestClassifier]
minitk:proc.i.mdlfunc[`keras;`binary;`BinaryKeras]

raze[first value get[`.ml.gs.kfsplit][5;1;data 0;data 1;p[`prf]minitsk;enlist[`random_state]!enlist 123;enlist[`val]!enlist 0]]~enlist each 0110011001b
raze[get[`.ml.xv.kfsplit][5;1;data 0;data 1;p[`prf][minitk;(123,`binary)]]]~enlist each 1110110011b

// Map scoring function to appropriate ordering metric
proc.i.ord[`.ml.accuracy]~desc
proc.i.ord[`.ml.rmse]~asc
proc.i.ord[`.ml.r2score]~desc
