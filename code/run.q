\d .aml

// This is a prototype of the pipeline for the automated machine learning pipeline

/* tb   = input table
/* tgt  = target vector
/* feat_typ = type of feature extraction being completed
/* prob_typ = type of problem regression/class (`reg/`class)
/* mdls = table of models (.aml.models[`class;tgt]/.aml.models[`reg;tgt])
/* p    = parameters (::) ~ default other changes user dependent

runexample:{[tb;tgt;feat_typ;prob_typ;p]
  mdls:models[prob_typ;tgt];
  dtdict:`stdate`sttime!(.z.D;.z.T);
  dict:i.updparam[tb;p;feat_typ];
  system "S ",string s:dict`seed;
  tb:i.autotype[tb;feat_typ;dict];

  -1"\nThe following is a breakdown of information for each of the relevant columns in the dataset\n";

  tb:preproc[tb;tgt;feat_typ;dict];

  -1"\nData preprocessing completed, starting feature creation\n";

  tb:$[feat_typ=`fresh;freshcreate[tb;dict];feat_typ=`normal;normalcreate[tb;dict];'`err];
  feats:freshsignificance[tb 0;tgt];
  tts:dict[`tts][;tgt;dict`sz]tab:feats#tb 0;
  mdls:i.kerascheck[mdls;tts;tgt];
 
  -1"\nFeature creation and significance testing completed.";
  -1"Starting initial model selection - allow ample time for large datasets\n";
  -1"Total features being passed to the models = ",string[ctb:count 1_cols tab];

  bm:runmodels[tts`xtrain;tts`ytrain;mdls;dict;dtdict];

  -1"\nThe best model has been selected as ",string[bm[1]],", continuing to grid-search and final model fitting on holdout set\n";

// The following is commented out for now due to the changes imposed by inclusion of gridsearch
  if[2=dict`saveopt;
    -1"Now saving down a report on this run to Outputs/Reports\n";
    report[i.report_dict[ctb;bm;tb;dtdict;path];dtdict];];

  fn:i.scfn[dict;mdls];
  exclude_list:`GaussianNB`LinearRegression;
  if[a:bm[1]in exclude_list;
    score:i.scorepred[flip value flip tts`xtest;tts`ytest;last bm;fn];
    exp_mdl:last bm];
  if[b:not bm[1]in exclude_list;
    prms:gs.psearch[flip value flip tts`xtrain;tts`ytrain;tts`xtest;tts`ytest;bm 1;dict;prob_typ;mdls];
    score  :first prms;
    exp_mdl:last prms];
  -1"Grid search/final model fitting now completed the final score on the holdout set was: ",string score;

/* x = date-time of model start (dict)
/* y = best model name (`symbol)
/* z = best model object (embedPy)
/* r = all applied models (table)

  if[dict[`saveopt]in 1 2;i.savemdl[dtdict;bm[1];exp_mdl;mdls]];
  }
