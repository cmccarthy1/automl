\d .aml

// The functions contained in this file are all those that are expected to be executable
// by a user, this includes the function to run the full pipeline and one for running on new data

// This is a prototype of the workflow for the automated machine learning pipeline
/* tb    = input table
/* tgt   = target vector
/* ftype = type of feature extraction being completed (`fresh/`normal)
/* ptype = type of problem regression/class (`reg/`class)
/* p     = parameters (::) produces default other changes are user dependent

run:{[tb;tgt;ftype;ptype;p]
  dtdict:`stdate`sttime!(.z.D;.z.T);
  // Extract & update the dictionary used to define the workflow
  dict:i.updparam[tb;p;ftype],enlist[`typ]!enlist ftype;
  // Check that the functions to overwrite default behaviour exist in process
  i.checkfuncs[dict];
  // update the seed randomly if user does not specify the seed in p
  if[`rand_val~dict[`seed];dict[`seed]:"j"$.z.t];
  // if required to save data construct the appropriate folders
  if[dict[`saveopt]in 1 2;spaths:i.pathconstruct[dtdict;dict`saveopt]];
  mdls:i.models[ptype;tgt;dict];
  system"S ",string dict`seed;
  tb:prep.i.autotype[tb;ftype;dict];
  -1 i.runout`col;
  // This provides an encoding map which can be used in reruns of automl even
  // if the data is no longer in the appropriate format for symbol encoding
  encoding:prep.i.symencode[tb;10;1;dict;::];
  tb:preproc[tb;tgt;ftype;dict];-1 i.runout`pre;
  tb:$[ftype=`fresh;prep.freshcreate[tb;dict];
       ftype=`normal;prep.normalcreate[tb;dict];
       '`$"Feature extraction type is not currently supported"];
  feats:get[dict[`sigfeats]][tb 0;tgt];
  // Encode target data if target is a symbol vector
  if[11h~type tgt;tgt:.ml.labelencode tgt];
  // Apply the appropriate train/test split to the data
  // the following currently runs differently if the parameters are defined
  // in a file or through the more traditional dictionary/(::) format
  tts:($[-11h=type dict`tts;get;]dict[`tts])[;tgt;dict`sz]tab:feats#tb 0;
  // Centralizing the table to matrix conversion makes it easier to avoid
  // repetition of this task which can be computationally expensive
  xtrn:flip value flip tts`xtrain;xtst:flip value flip tts`xtest;
  ytrn:tts`ytrain;ytst:tts`ytest;
  mdls:i.kerascheck[mdls;tts;tgt];
  // Check if Tensorflow/Keras not available for use, NN models removed
  if[1~checkimport[];mdls:?[mdls;enlist(<>;`lib;enlist `keras);0b;()]];
  -1 i.runout`sig;-1 i.runout`slct;-1 i.runout[`tot],string[ctb:count cols tab];
  // Run all appropriate models on the training set
  // Set numpy random seed if multiple prcoesses
  if[0<abs[system "s"];.p.import[`numpy][`:random.seed][dict`seed]];
  bm:proc.runmodels[xtrn;ytrn;mdls;cols tts`xtrain;dict;dtdict;spaths];
  fn:i.scfn[dict;mdls];
  // Do not run grid search on deterministic models returning score on the test set and model
  if[a:bm[1]in i.excludelist;
    data:(xtrn;ytrn;xtst;ytst);
    funcnm:string first exec fnc from mdls where model=bm[1];
    -1 i.runout`ex;score:i.scorepred[data;bm[1];expmdl:last bm;fn;funcnm]];
  // Run grid search on the best model for the parameter sets defined in hyperparams.txt
  if[b:not a;
    -1 i.runout`gs;
    prms:proc.gs.psearch[xtrn;ytrn;xtst;ytst;bm 1;dict;ptype;mdls];
    score:first prms;expmdl:last prms];
  -1 i.runout[`sco],string[score],"\n";
  // Save down a pdf report summarizing the running of the pipeline
  if[2=dict`saveopt;
    -1 i.runout[`save],i.ssrsv[spaths[1]`report];
    report_param:post.i.reportdict[ctb;bm;tb;dtdict;path;(prms 1;score;dict`xv;dict`gs);spaths];
    post.report[report_param;dtdict;spaths[0]`report]];
  if[dict[`saveopt]in 1 2;
    // Extract the Python library from which the best model was derived, used for model rerun
    pylib:?[mdls;enlist(=;`model;enlist bm 1);();`lib];
    // additional metadata information to be saved to disk
    hp:$[b;enlist[`hyper_parameters]!enlist prms 1;()!()];
    exmeta:`features`test_score`best_model`symencode`pylib!(feats;score;bm 1;encoding;pylib 0);
    metadict:dict,hp,exmeta;
    i.savemdl[bm 1;expmdl;mdls;spaths];
    i.savemeta[metadict;dtdict;spaths]];
  }


// Function for the processing of new data based on a previous run and return of predicted target 
/* t = table of new data to be predicted
/* fp = the path to the folder which the /Config and /Models folders are

new:{[t;fp]
  // Relevant python functionality for loading of models
  skload:.p.import[`joblib][`:load];
  if[0~checkimport[];krload:.p.import[`keras.models][`:load_model]];
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
    [fp_upd:i.ssrwin[path,"/outputs/",fp,"/models/",string metadata[`best_model]];
     if[bool:(mdl:metadata[`best_model])in i.keraslist;fp_upd,:".h5"];
     model:$[mp~`sklearn;skload;krload]fp_upd;
     $[bool;
       [fnm:neg[5]_string lower mdl;get[".aml.",fnm,"predict"][(0n;(data;0n));model]];
       model[`:predict;<]data]];
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
  h:hopen hsym`$i.ssrwin[raze[path],"/code/models/",fn];
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

