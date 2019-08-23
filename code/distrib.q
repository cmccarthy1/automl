\l ml/ml.q
.ml.loadfile`:init.q


\d .aml


// table of models
/* x = symbol, either `class or `reg
/* y = target
models:{
 if[not x in key i.files;'`$"text file not found"];
 d:i.txtparse[x;"/code/mdl_def/"];
 m:flip`model`lib`fnc`seed`typ!flip key[d],'value d;
 if[x=`class;m:$[2<count distinct y;delete from m where typ=`binary;delete from m where model=`MultiKeras]];
 m:update minit:.aml.i.mdlfunc .'flip(lib;fnc;model)from m;
 i.updmodels[m;y]}


// run multiple models
/* x = matrix of features
/* y = target
/* m = models from `.aml.models`
/* d = dictionary of populated parameters (defined earlier in the workflow)
runmodels:{[x;y;m;d]
 system"S ",string s:d`seed;
 if[11h~type y;y:![dy;til count dy:distinct y]y];
 r:.ml.gs.seed[x;y;d]'[m];
 fn:$[`reg in distinct m`typ;d[`scf]`reg;d[`scf]`class];  / scoring function to apply to results
 sco:i.txtparse[`score;"/code/mdl_def/"];	          / sco = score ordering tab
 get[string first sco fn]m[`model]!{first avg x}each get[fn].''r}


if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]
