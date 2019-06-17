\l p.q
\l ml/ml.q
.ml.loadfile`:xval/init.q

/examples data
n:10000
x:flip(n?100f;asc n?100f)
yr:asc n?100f / regression
yc:n?0 1      / classification
xval_func:.ml.xval.kfshuff[5;1]
score_func:.ml.xval.fitscore

/set default seed
seed:42

/table of models
/* x = symbol, either `class or `reg

files:`class`reg!("classmodels.txt";"regmodels.txt")

.ml.models:{
 if[not x in key files;'`$"text file not found"];
 vd:value d:{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$files x;  / add path?
 m:update lib:vd[;0],seed:vd[;1],valid:count[d]#1b from([]model:key d);
 m,'([]minit:{.p.import[` sv`sklearn,x`lib]hsym x`model}each m)}

/run multiple models
/* run with .ml.runmodels[xval_func;x;y;m;score_func]
.ml.runmodels:{[xv;x;y;m;f]
 s:{if[`seed~x;:get x]}each m`seed;
 m[`model]!.ml.runmodel[xv;x;y;;f;]'[m`minit;s]}

/run single model
.ml.runmodel:{[xv;x;y;a;f;s] 
 s:$[not type[s]in(101h;-7h);@[{"i"$x};s;'`$"type not convertable"];s];
 if[-7h~type s;s:enlist[`random_state]!enlist s];
 raze .ml.gsseed[xv;x;y;a;f;s]}

/seeded gridsearch
.ml.gsseed:{[xv;x;y;a;f;pd]$[not pd~(::);value .ml.xval.gridsearch[xv;x;y;a;f;pd];xv[x;y;a;f[::]]]}
