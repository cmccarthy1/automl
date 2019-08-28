\l ml/ml.q

/ new ml funcs used below
.ml.loadfile`:init.q
.ml.mattab :{flip value flip x}
.ml.shuffle:{idx:neg[n]?n:count x;$[98h~type x;x:@[x;y;@;idx];x[;y]:x[;y]idx];:x}

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
/* x = table of features
/* y = target
/* m = models from `.aml.models`
/* d = dictionary of populated parameters (defined earlier in the workflow)
runmodels:{[x;y;m;d]
 system"S ",string s:d`seed;c:cols x;x:.ml.mattab x;             
 if[11h~type y;y:![dy;til count dy:distinct y]y];
 tt:.ml.traintestsplit[x;y;.3];                             / keep holdout for feature impact
 p1:.ml.gs.seed[tt`xtrain;tt`ytrain;d]'[m];                      
 f:get fn:d[`scf]$[`reg in distinct m`typ;`reg;`class];     / scoring function
 o:get string first i.txtparse[`score;"/code/mdl_def/"]fn;  / order function, e.g. asc/desc
 -1"\nScores for all models, using ",string[fn],"\n";
 show s1:o m[`model]!{first avg x}each f .''p1;
 -1"\nScore for holdout predictions using best model - ",string[bs:first key s1],"\n";
 bm:(first exec minit from m where model=bs)[][];    
 bm[`:fit][tt`xtrain;tt`ytrain];
 show s2:fn[;ytst:tt`ytest]bm[`:predict][xtst:tt`xtest]`;
 featureimpact[bs;bm;xtst;ytst;c;f;o];}

// calculate impact of each feature and save plot of top 20
featureimpact:{[b;m;x;y;c;f;o]
 r:i.predshuff[m;x;y;f]each til count c;
 im:i.impact[r;c;o];
 i.impactplot[im;b];
 -1"\nFeature impact calculated - see current directory for results\n";}

if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]
