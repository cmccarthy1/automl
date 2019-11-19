\d .aml

// The functions contained in this file are all those that are expected to be executable
// by a user, this includes the function to run the full pipeline and one for running on new data

// This is a prototype of the workflow for the automated machine learning pipeline
/* tb    = input table
/* tgt   = target vector
/* ftype = type of feature extraction being completed (`fresh/`normal)
/* ptype = type of problem regression/class (`reg/`class)
/* p     = parameters (::) produces default other changes are user dependent

runexample:{[tb;tgt;ftype;ptype;p]
  dtdict:`stdate`sttime!(.z.D;.z.T);
  // Extract & update the dictionary used to define the workflow
  dict:i.updparam[tb;p;ftype],enlist[`typ]!enlist ftype;
  // update the seed randomly if user does not specify the seed in p
  if[`rand~dict[`seed];dict[`seed]:"j"$.z.t];
  // if required to save data construct the appropriate folders
  if[dict[`saveopt]in 1 2;spaths:i.pathconstruct[dtdict;dict`saveopt]];
  mdls:i.models[ptype;tgt;dict];
  system"S ",string dict`seed;
  tb:prep.i.autotype[tb;ftype;dict];
  -1 runout`col;
  encoding:prep.i.symencode[tb;10;1;dict;::];
  tb:preproc[tb;tgt;ftype;dict];-1 runout`pre;
  tb:$[ftype=`fresh;prep.freshcreate[tb;dict];
       ftype=`normal;prep.normalcreate[tb;dict];
       '`$"Feature extraction type is not currently supported"];
  feats:prep.freshsignificance[tb 0;tgt];
  // Encode target data if target is a symbol vector
  if[11h~type tgt;tgt:.ml.labelencode tgt];
  // Apply the appropriate train/test split to the data
  // the following currently runs differently if the parameters are defined
  // in a file or through the more traditional dictionary/(::) format
  tts:($[-11h=type dict`tts;get;]dict[`tts])[;tgt;dict`sz]tab:feats#tb 0;
  mdls:i.kerascheck[mdls;tts;tgt];
  // Check if Tensorflow/Keras available for use, NN models removed if not
  if[1~checkimport[];mdls:?[mdls;enlist(<>;`lib;enlist `keras);0b;()]];
  -1 runout`sig;-1 runout`slct;-1 runout[`tot],string[ctb:count cols tab];
  // Run all appropriate models on the training set
  bm:proc.runmodels[tts`xtrain;tts`ytrain;mdls;dict;dtdict;spaths];
  fn:i.scfn[dict;mdls];
  // Do not run grid search on deterministic models returning score on the test set and model
  if[a:bm[1]in i.excludelist;
    -1 runout`ex;score:i.scorepred[flip value flip tts`xtest;tts`ytest;last bm;fn];expmdl:last bm];
  // Run grid search on the best model for the parameter sets defined in hyperparams.txt
  if[b:not a;
    -1 runout`gs;
    prms:proc.gs.psearch[flip value flip tts`xtrain;tts`ytrain;
      tts`xtest;tts`ytest;
      bm 1;dict;ptype;mdls];
    score:first prms;expmdl:last prms];
  -1 runout[`sco],string[score],"\n";
  // Save down a pdf report summarizing the running of the pipeline
  if[2=dict`saveopt;
    -1 runout[`save],spaths[1]`report;
    report_param:post.i.reportdict[ctb;bm;tb;dtdict;path;(prms 1;score;dict`xv;dict`gs);spaths];
    post.report[report_param;dtdict;spaths[0]`report]];
  if[dict[`saveopt]in 1 2;
    // Extract the Python library from which the best model was derived, used for model rerun
    pylib:?[mdls;enlist(=;`model;enlist bm 1);();`lib];
    // additional metadata information to be saved to disk
    hp:$[b;enlist[`hyper_parameters]!enlist prms 1;()!()];
    exmeta:`features`test_score`best_model`symencode`pylib!(feats;score;bm 1;encoding;pylib 0);
    metadict:dict,hp,exmeta;
    i.savemdl[dtdict;bm 1;expmdl;mdls;spaths];
    i.savemeta[metadict;dtdict;spaths]];
  }
  
// Function for the processing of new data based on a previous run and return of predicted target 
/* t = table of new data to be predicted
/* fp = the path to the folder which the /Config and /Models folders are

newproc:{[t;fp]
  // Relevant python functionality for loading of models
  skload:.p.import[`joblib][`:load];
  krload:.p.import[`keras.models][`:load_model];
  // Retrieve the metadata from a file path based on the run date/time
  metadata:i.getmeta[i.ssrwin[path,"/outputs/",fp,"/config/metadata"]];
  typ:metadata`typ;
  data:$[`normal=typ;
    i.normalproc[t;metadata];
    `fresh=typ;
    i.freshproc[t;metadata];
    '`$"This form of operation is not currently supported"
    ];
  $[(mp:metadata[`pylib])in `sklearn`keras;
    // Apply the relevant saved down model to new data
    [model:$[mp~`sklearn;skload;krload]i.ssrwin[path,"/outputs/",fp,"/models/",string metadata[`best_model]];
     model[`:predict;<]data];
    '`$"The current model type you are attempting to apply is not currently supported"]
  }

// Saves down flatfile of default dict
/* fn    = filename as string, symbol or hsym
/* ftype = type of feature extraction, e.g. `fresh or `normal
/. r     > flatfile of dictionary parameters
savedefault:{[fn;ftype]
  // Check type of filename and convert to string
  fn:$[10h~typf:type fn;fn;
      -11h~typf;$[":"~first strf;1_;]strf:string typf;
      '`$"filename must be string, symbol or hsym"];
  // Open handle to file fn
  h:hopen hsym`$i.ssrwin[raze[path],"/code/mdl_def/",fn];
  // Set d to default dictionary for feat_typ
  d:$[`fresh ~ftype;.aml.i.freshdefault[];
      `normal~ftype;.aml.i.normaldefault[];
      '`$"feature extraction type not supported"];
  // String values for file
  vals:{$[1=count x;
            string x;
          11h~abs typx:type x;
            ";"sv{raze$[1=count x;y;"`"sv y]}'[x;string x];
          99h~typx;
            ";"sv{string[x],"=",string y}'[key x;value x];
          0h~typx;
            ";"sv string x;x]}each value d;
  // Add key, pipe and newline indicator
  strd:{(" |" sv x),"\n"}each flip(7#'string[key d],\:5#" ";vals);
  // Write dictionary entries to file
  {x y}[h]each strd;
  hclose h;}

runout:`col`pre`sig`slct`tot`ex`gs`sco`save!
 ("\nThe following is a breakdown of information for each of the relevant columns in the dataset\n";
  "\nData preprocessing complete, starting feature creation";
  "\nFeature creation and significance testing complete";
  "Starting initial model selection - allow ample time for large datasets";
  "\nTotal features being passed to the models = ";
  "Continuing to final model fitting on holdout set";
  "Continuing to grid-search and final model fitting on holdout set";
  "\nBest model fitting now complete - final score on test set = ";
  "Saving down procedure report to ")
