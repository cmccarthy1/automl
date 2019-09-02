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
 if[x=`class;
    m:$[2<count distinct y;
        delete from m where typ=`binary;
        delete from m where model=`MultiKeras]];
 m:update minit:.aml.i.mdlfunc .'flip(lib;fnc;model)from m;
 i.updmodels[m;y]}

// run multiple models
/* x = table of features
/* y = target
/* m = models from `.aml.models`
/* d = dictionary of populated parameters (defined earlier in the workflow)
runmodels:{[x;y;m;d]
 system"S ",string s:d`seed;
 c:cols x;
 x:i.mattab x;
 / encode categorical as numerical
 if[11h~type y;y:![dy;til count dy:distinct y]y];
 / keep holdout for feature impact
 tt:.ml.traintestsplit[x;y;.3];
 / seeded cross validation returning predictions
 p1:gs.seed[tt`xtrain;tt`ytrain;d]'[m];
 / scoring functions for results and order asc/desc
 f:get fn:d[`scf]$[`reg in distinct m`typ;`reg;`class];
 o:get string first i.txtparse[`score;"/code/mdl_def/"]fn;
 / 'leaderboard' of scores from run models
 -1"\nScores for all models, using ",string[fn];
 show s1:o m[`model]!{first avg x}each f .''p1;
 -1"\nScore for holdout predictions using best model - ",string[bs:first key s1],"\n";
 bm:(first exec minit from m where model=bs)[][];
 bm[`:fit][tt`xtrain;tt`ytrain];
 show s2:fn[;ytst:tt`ytest]bm[`:predict][xtst:tt`xtest]`;
 / feature impact graph produced on holdout data
 i.featureimpact[bs;bm;xtst;ytst;c;f;o];}

/ grid search w/ random seed where applicable
gs.seed:{[x;y;d;m]
 b:m[`lib]~`sklearn;
 s:$[a:m[`seed]~`seed;$[b;enlist[`random_state]!enlist d`seed;d`seed];::];
 $[a&b;first value get[` sv`.ml.gs,d`xv][d`k;1;x;y;d[`prf]m`minit;s;0];
   get[` sv`.ml.xv,d`xv][d`k;1;x;y;d[`prf][m`minit;s]]]}


/ returns (ypred;ytrue) for each k
xv.fitpredict:{[f;p;d]($[-7h~type p;f[d;p];@[.[f[][p]`:fit;d 0]`:predict;d[1]0]`];d[1]1)}

if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]

