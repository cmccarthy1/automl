\l ml/ml.q
.ml.loadfile`:init.q

\d .aml

/  table of models
/* x = symbol, either `class or `reg
/* y = target
/* z = dictionary of parameters 
models:{
 if[not x in key i.files;'`$"text file not found"];
 d:i.txtparse[x;"/code/mdl_def/"];
 if[1~z`tf;d:l!d l:key[d]where not `keras=first each value d];
 m:flip`model`lib`fnc`seed`typ!flip key[d],'value d;
 if[x=`class;
    m:$[2<count distinct y;
        delete from m where typ=`binary;
        delete from m where model=`MultiKeras]];
 m:update minit:.aml.i.mdlfunc .'flip(lib;fnc;model)from m;
 i.updmodels[m;y]}

/  run multiple models
/* x = table of features
/* y = target
/* m = models from `.aml.models`
/* d = dictionary of populated parameters (defined earlier in the workflow)
/* dt = date and time that the entire 
runmodels:{[x;y;m;d;dt]
  system"S ",string s:d`seed;
  c:cols x;x:flip value flip x;
  / keep holdout for feature impact
  tt:d[`tts][x;y;d`hld];
  m :i.kerascheck[m;tt;y];
  / seeded cross validation returning predictions
  xv_tstart:.z.T;
  p1:xv.seed[tt`xtrain;tt`ytrain;d]'[m];
  / scoring functions for results and order asc/desc
  fn:i.scfn[d;m];o:i.ord fn;
  -1"\nScores for all models, using ",string fn;
  show s1:o m[`model]!{first avg x}each fn .''p1;
  xv_tend:.z.T-xv_tstart;
  / score best model on holdout and save down model if appropriate
  -1"\nBest scoring model = ",string bs:first key s1;
  bm:(first exec minit from m where model=bs)[][];
  bm_tstart:.z.T;
  bm[`:fit][tt`xtrain;tt`ytrain];
  s2:fn[;ytst:tt`ytest]bm[`:predict][xtst:tt`xtest]`;
  -1"Score for validation predictions using best model = ",string[s2],"\n";
  bm_tend:.z.T-bm_tstart;
  / feature impact graph produced on holdout data if setting appropriate
  if[2=d[`saveopt];i.featureimpact[bs;bm;xtst;ytst;c;fn;o;dt]];
  / outputs from run models, used in report generation
  (s1;bs;s2;xv_tend;bm_tend;fn;bm)}

if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]
