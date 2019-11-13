\d .aml

// This is a prototype of the workflow for the automated machine learning pipeline

/* tb   = input table
/* tgt  = target vector
/* feat_typ = type of feature extraction being completed (`fresh/`normal)
/* prob_typ = type of problem regression/class (`reg/`class)
/* p    = parameters (::) ~ default other changes user dependent

runexample:{[tb;tgt;feat_typ;prob_typ;p]
  dtdict:`stdate`sttime!(.z.D;.z.T);
  dict:i.updparam[tb;p;feat_typ],enlist[`typ]!enlist feat_typ;
  mdls:proc.models[prob_typ;tgt;dict]; // needs to be moved from proc 
  system"S ",string s:dict`seed;
  tb:prep.i.autotype[tb;feat_typ;dict] ;-1 runout`col;
  encoding:prep.i.symencode[tb;10;1;dict;::];
  tb:preproc[tb;tgt;feat_typ;dict];-1 runout`pre;
  tb:$[feat_typ=`fresh;prep.freshcreate[tb;dict];feat_typ=`normal;prep.normalcreate[tb;dict];'`err];
  feats:prep.freshsignificance[tb 0;tgt];
  if[11h~type tgt;tgt:.ml.labelencode tgt];
  tts:dict[`tts][;tgt;dict`sz]tab:feats#tb 0;
  mdls:i.kerascheck[mdls;tts;tgt];
  if[0~checkimport[];mdls:?[mdls;enlist(<>;`lib;enlist `keras);0b;()]];
  -1 runout`sig;-1 runout`slct;
  -1 runout[`tot],string[ctb:count cols tab];
  bm:proc.runmodels[tts`xtrain;tts`ytrain;mdls;dict;dtdict];
  fn:i.scfn[dict;mdls];
  exclude_list:`GaussianNB`LinearRegression`RegKeras;
  if[a:bm[1]in exclude_list;-1 runout`ex;
    score:i.scorepred[flip value flip tts`xtest;tts`ytest;last bm;fn];exp_mdl:last bm];
  if[b:not bm[1]in exclude_list;-1 runout`gs;
    prms:proc.gs.psearch[flip value flip tts`xtrain;
                         tts`ytrain;tts`xtest;tts`ytest;
                         bm 1;dict;prob_typ;mdls];
    score:first prms;exp_mdl:last prms];
  -1 runout[`sco],string[score],"\n";
  if[2=dict`saveopt;
    -1 runout[`save],string[dtdict`stdate],"/Run_",string[dtdict`sttime],"/Reports/";
    report_param:post.i.reportdict[ctb;bm;tb;dtdict;path;(prms 1;score;dict`xv;dict`gs)];
    post.report[report_param;dtdict]];
  hp:$[b;enlist[`hyper_parameters]!enlist prms 1;()!()];
  pylib:?[mdls;enlist(=;`model;enlist bm 1);();`lib];
  meta_dict:dict,hp,`features`test_score`best_model`symencode`pylib!(feats;score;bm 1;encoding;pylib 0);
  if[dict[`saveopt]in 1 2;i.savemdl[dtdict;bm 1;exp_mdl;mdls];savemeta[meta_dict;dtdict]];}
  

.ml.labelencode:{(asc distinct x)?x}

runout:`col`pre`sig`slct`tot`ex`gs`sco`save!
 ("\nThe following is a breakdown of information for each of the relevant columns in the dataset\n";
  "\nData preprocessing complete, starting feature creation";
  "\nFeature creation and significance testing complete";
  "Starting initial model selection - allow ample time for large datasets";
  "\nTotal features being passed to the models = ";
  "Continuing to final model fitting on holdout set";
  "Continuing to grid-search and final model fitting on holdout set";
  "\nBest model fitting now complete - final score on test set = ";
  "Saving down procedure report to Outputs/")
