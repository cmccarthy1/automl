\l p.q
\l ml/ml.q
.ml.loadfile`:init.q

// examples data
n:10000
x:flip(n?100f;asc n?100f)
yr:asc n?100f / regression
yc:n?0 1      / classification
xval_func:.ml.xval.kfshuff[5;1]
score_func:.ml.xval.fitscore


\d .aml

// default seed 
seed:42

// table of models
/* x = symbol, either `class or `reg
models:{
 if[not x in key i.files;'`$"text file not found"];
 vd:value d:{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,"/code/mdl_def/",i.files x; 
 m:update lib:vd[;0],seed:vd[;1],valid:count[d]#1b from([]model:key d);
 m,'([]minit:{.p.import[` sv`sklearn,x`lib]hsym x`model}each m)}

// run multiple models
/* run with .ml.runmodels[xval_func;x;y;m;score_func]
runmodels:{[xv;x;y;m;f]
 system"S ",string seed;						/ ensure multiple run returns same model (kfshuff)
 s:{if[`seed~x;:seed]}each m`seed;
 1#key desc m[`model]!avg each i.runmodel[xv;x;y;;f;]'[m`minit;s]}	/ return the best model name from the selection


i.files:`class`reg!("classmodels.txt";"regmodels.txt")

i.gsseed:{[xv;x;y;a;f;pd]
 $[not pd~(::);
   value .ml.xval.gridsearch[xv;x;y;a;f;pd];
   xv[x;y;a;f[::]]]}

i.runmodel:{[xv;x;y;a;f;s]
 s:$[not type[s]in(101h;-7h);@[{"i"$x};s;'`$"type not convertable"];s];
 if[-7h~type s;s:enlist[`random_state]!enlist s];
 raze i.gsseed[xv;x;y;a;f;s]}
