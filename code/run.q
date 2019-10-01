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
  tab:feats#tb 0;
  tts:dict[`tts][tab;tgt;dict`sz];
  if[(`MultiKeras in mdls`model)&(count distinct tgt)>min {count distinct x}each tts`ytrain`ytest;mdls:i.err_tgt[mdl]]

  -1"\nFeature creation and significance testing completed.\nStarting initial model selection - allow ample time for large datasets\n";
  -1"Total features being passed to the models = ",string[ctb:count 1_cols tab];

  bm:runmodels[tts`xtrain;tts`ytrain;mdls;dict;dtdict];

  -1"\nModel selection has been completed, continuing to the next step\n";

  if[2=dict`saveopt;
    -1"Now saving down a report on this run to Outputs/Reports\n";
    report[i.report_dict[ctb;bm;tb;dtdict;path];dtdict];];

  fn:dict[`scf]$[`reg in distinct mdls`typ;`reg;`class];
  $[bm[1]in `GaussianNB`LinearRegression;
   fn[;tts`ytest](last bm)[`:predict][flip value flip tts`xtest]`;
   first gs.psearch[flip value flip tab;tgt;bm 1;dict;prob_typ;mdls]]
 }
