\d .aml

// For the following code the parameter naming convention holds
// defined here is applied to avoid repetition throughout the file
/* tgt = target data
/* p   = parameter dictionary passed as default or modified by user

// Run cross validated machine learning models on training data and choose the best model.
/* t = table of features as output from preprocessing pipeline/feature extraction
/* mdls = appropriate models from `.aml.proc.models` above
/* dt = date and time that the run was initialized (this is used in the feature impact function) 
proc.runmodels:{[t;tgt;mdls;p;dt]
  system"S ",string s:p`seed;
  c:cols t;t:flip value flip t;
  // Apply train test split to keep holdout for feature impact plot and testing of vanilla best model
  tt:p[`tts][t;tgt;p`hld];
  mdls:i.kerascheck[mdls;tt;tgt];
  xv_tstart:.z.T;
  // Complete a seeded cross validation on training sets producing the predictions with associated 
  // real values. This allows the best models to be chosen based on relevant user defined metric 
  p1:proc.xv.seed[tt`xtrain;tt`ytrain;p]'[mdls];
  scf:i.scfn[p;mdls];
  ord:proc.i.ord scf;
  -1"\nScores for all models, using ",string scf;
  // Score the models based on user denoted scf and ordered appropriately to find best model
  show s1:ord mdls[`model]!{first avg x}each scf .''p1;
  xv_tend:.z.T-xv_tstart;
  -1"\nBest scoring model = ",string bs:first key s1;
  // Extract the best model, fit on entire training set and predict/score on test set
  // for the appropriate scoring function
  bm:(first exec minit from mdls where model=bs)[][];
  bm_tstart:.z.T;
  bm[`:fit][tt`xtrain;tt`ytrain];
  s2:scf[;ytst:tt`ytest]bm[`:predict][xtst:tt`xtest]`;
  -1"Score for validation predictions using best model = ",string[s2],"\n";
  bm_tend:.z.T-bm_tstart;
  // Feature impact graph produced on holdout data if setting is appropriate
  if[2=p[`saveopt];post.featureimpact[bs;bm;xtst;ytst;c;scf;ord;dt]];
  // Outputs from run models. These are used in the generation of a pdf report
  // or are used within later sections of the pipeline.
  (s1;bs;s2;xv_tend;bm_tend;scf;bm)}

if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]
