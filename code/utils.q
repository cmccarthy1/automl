\d .aml

// Utilities for run.q

//  Function takes in a string which is the name of a parameter flatfile
/* nm = name of the file from which the dictionary is being extracted
/. r  > the dictionary as defined in a float file in mdl_def
i.getdict:{[nm]
  d:proc.i.paramparse[nm;"/code/mdl_def/"];
  idx:(k except`scf;
    k except`xv`gs`scf;
    $[`xv in k;`xv;()],$[`gs in k;`gs;()];
    $[`scf in k:key d;`scf;()]);
  fnc:(key;{get string first x};{(x 0;get string x 1)};{key[x]!`$value x});
  // addition of empty dictionary entry needed as parsing 
  // of file behaves oddly with only a single entry
  if[sgl:1=count d;d:(enlist[`]!enlist""),d];
  d:{$[0<count y;@[x;y;z];x]}/[d;idx;fnc];
  if[sgl;d:1_d];
  d}
 
i.freshdefault:{`aggcols`params`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
  ({first cols x};`.ml.fresh.params;(`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.aml.xv.fitpredict;
   `class`reg!(`.ml.accuracy;`.ml.mse);42;2;0.2;`.ml.traintestsplit;0.2)}
i.normaldefault:{`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
  ((`.ml.xv.kfshuff;5);(`.ml.xv.kfshuff;5);`.aml.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);
   42;2;0.2;`.ml.traintestsplit;0.2)}

/  This function sets or updates the default parameter dictionary as appropriate
/* t   = data as table
/* p   = dictionary of parameters (type of feature extract dependant)
/* typ = type of feature extraction (FRESH/normal/tseries ...)
i.updparam:{[t;p;typ]
  dict:
    $[typ=`fresh;
      {[t;p]d:i.freshdefault[];	   
       d:$[(ty:type p)in 10 -11 99h;
	   [if[10h~ty;p:.aml.i.getdict p];
	    if[-11h~ty;p:.aml.i.getdict$[":"~first p;1_;]p:string p];
	    $[min key[p]in key d;d,p;'`$"You can only pass appropriate keys to fresh"]];
           p~(::);d;
             '`$"p must be passed the identity `(::)`, a filepath to a parameter flatfile",
                " or a dictionary with appropriate key/value pairs"];
	   d[`aggcols]:$[100h~typagg:type d`aggcols;
                         d[`aggcols]t;
                         11h~abs typagg;d`aggcols;
                         '`$"aggcols must be passed function or list of columns"];
	   d,enlist[`tf]!enlist 0~checkimport[]}[t;p];
      typ=`normal;
      {[t;p]d:i.normaldefault[];
       d:$[(ty:type p)in 10 -11 99h;
	   [if[10h~ty;p:.aml.i.getdict p];
            if[-11h~ty;p:.aml.i.getdict$[":"~first p;1_;]p:string p];
            $[min key[p]in key d;d,p;
	      '`$"You can only pass appropriate keys to normal"]];
           p~(::);d;
	   '`$"p must be passed the identity `(::)`, a filepath to a parameter flatfile",
              " or a dictionary with appropriate key/value pairs"];
	   d,enlist[`tf]!enlist 0~checkimport[]}[t;p];
      typ=`tseries;
      '`$"This will need to be added once the time-series recipe is in place";
    '`$"Incorrect input type"]}

// Apply an appropriate scoring function to predictions from a model
/* xtst = test data
/* ytst = test target
/* mdl  = fitted embedPy model object
/* scf  = scoring function which determines best model
/. r    > score for the model based on the predictions on test data
i.scorepred:{[xtst;ytst;mdl;scf]scf[;ytst]mdl[`:predict][xtst]`}

/  save down the best model
/* x = date-time of model start (dict)
/* y = best model name (`symbol)
/* z = best model object (embedPy)
/* r = all applied models (table)
i.savemdl:{[x;y;z;r]
  fname:path,"/",mo:ssr["Outputs/",string[x`stdate],"/Run_",string[x`sttime],"/Models/";":";"."];
  system"mkdir -p ",fname;
  joblib:.p.import[`joblib];
  $[(`sklearn=?[r;enlist(=;`model;y,());();`lib])0;
      (joblib[`:dump][z;fname,"/",string[y]];-1"Saving down ",string[y]," model to ",mo);
    (`keras=?[r;enlist(=;`model;y,());();`lib])0;
      (bm[`:save][fname,"/",string[y],".h5"];-1"Saving down ",string[y]," model to ",mo);
   -1"Saving of non keras/sklearn models types is not currently supported"];
 }

// Table of models appropriate for the problem type being solved
/* typ = symbol, either `class or `reg
/. r   > table with all information needed for appropriate models to be applied to data
i.models:{[typ;tgt;p]
  if[not typ in key proc.i.files;'`$"text file not found"];
  d:proc.i.txtparse[typ;"/code/mdl_def/"];
  if[0b~p`tf;
    d:l!d l:key[d]where not `keras=first each value d];
  m:flip`model`lib`fnc`seed`typ!flip key[d],'value d;
  if[typ=`class;
    // For classification tasks remove inappropriate classification models
    m:$[2<count distinct tgt;
        delete from m where typ=`binary;
        delete from m where model=`MultiKeras]];
  // Add a column with appropriate initialized models for each row
  m:update minit:.aml.proc.i.mdlfunc .'flip(lib;fnc;model)from m;
  // Threshold models used based on unique target values
  i.updmodels[m;tgt]}

// Update models available for use based on the number of rows in the data set
/* mdls = table defining models which are to be applied to the dataset
/* tgt  = target vector
/. r    > model table with appropriate models removed if needed and model removal highlighted
i.updmodels:{[mdls;tgt]
 $[100000<count tgt;
   [-1"\nLimiting the models being applied due to number targets>100,000";
    -1"No longer running neural nets or svms\n";
    select from mdls where(lib<>`keras),not fnc in`neural_network`svm];mdls]}

// These are a list of models which are deterministic and thus which do not need to be grid-searched 
// at present this should include the Keras models as a sufficient tuning method
// has yet to be implemented
i.excludelist:`GaussianNB`LinearRegression`RegKeras`MultiKeras`BinKeras;

// Save down the metadata dictionary as a binary file which can be retrieved by a user or
// is to be used in running of the models on new data
/* d  = dictionary of parameters to be saved
/* dt = dictionary with the date and time that a run was started, required for naming of save path 
/. r  > the location that the metadata was saved to
i.savemeta:{[d;dt]
  `:metadata set d;
  system "mkdir",$[.z.o like "w*";" ";" -p "],fname:path,"/",
    // Save path, ssr required as mac does not support ':' as input in file paths.
    spath:ssr["Outputs/",string[dt`stdate],"/Run_",string[dt`sttime],"/Config/";":";"."];
  // move the metadata information to the appropriate location based on OS
  $[first[string .z.o]in "lm";
    system"mv metadata ",fname;
    system"move metadata ",fname];
  -1"Saving down model parameters to ",spath;}

// Retrieve the metadata information from a specified path
/* fp = full file path denoting the location of the metadata to be retrieved
/. r  > returns the parameter dictionary
i.getmeta:{[fp]
  fp:`$":",fp;
  $[()~key fp;'`$"metadata file doesn't exist";get fp]
  }


// Apply feature creation and encoding procedures for 'normal' on new data
/* t = New tabular data to apply creation and encoding on
/* d = metadata from a previous run of automl as a dictionary
/. r > table with feature creation and encodings applied appropriately
i.normalproc:{[t;d]
  prep.i.autotype[t;d`typ;d];
  // symbol encoding completed based on encoding applied in a previous 'run'
  t:prep.i.symencode[t;10;0;d;d`symencode];
  t:prep.i.nullencode[t;med];
  t:.ml.infreplace[t];
  t:first prep.normalcreate[t;::];
  flip value flip d[`features]#t}

// Apply feature creation and encoding procedures for FRESH on new data
/* t = New tabular data to apply creation and encoding on
/* d = metadata from a previous run of automl as a dictionary
/. r > table with feature creation and encodings applied appropriately
i.freshproc:{[t;d]
  t:prep.i.autotype[t;d`typ;d];
  agg:d`aggcols;
  // extract relevant functions based on the significant features determined by the model
  funcs:raze `$distinct{("_" vs string x)1}each d`features;
  // ensures that many calculations that are irrelevant are not run
  appfns:1!select from 0!.ml.fresh.params where f in funcs;
  // apply symbol encoding based on a previous run of automl
  t:prep.i.symencode[t;10;0;d;d`symencode];
  cols2use:k where not (k:cols t)in agg;
  t:prep.i.nullencode[value .ml.fresh.createfeatures[t;agg;cols2use;appfns];med];
  t:.ml.infreplace t;
  // It is not guaranteed that new feature creation will produce the all requisite features 
  // if this is not the case dummy features are added to the data
  if[not all ftc:d[`features]in cols t;
    newcols:d[`features]where not ftc;
    t:d[`features] xcols flip flip[t],newcols!((count newcols;count t)#0f),()];
  flip value flip d[`features]#"f"$0^t}


// Util functions used in multiple util files

// Error flag if test set is not appropriate for multiKeras model
/* mdls = table denoting all the models with associated information used in this repository
/. r    > the models table with the MultiKeras model removed
i.errtgt:{[mdls]
  -1 "\n Test set does not contain examples of each class. Removed MultiKeras from models";
  delete from mdls where model=`MultiKeras}

// Extract the scoring function to be applied for model selection
/* p    = parameter dictionary
/* mdls = table with all appropriate models
/. r    > the scoring function appropriate to the problem being solved
i.scfn:{[p;mdls]p[`scf]$[`reg in distinct mdls`typ;`reg;`class]}

// Check if MultiKeras model is to be applied and each target exists in both training and testing sets
/* mdls = models table
/* tts  = train-test split dataset
/* tgt  = target data
/. r    > table with multi-class keras model removed if it is not to be applied
i.kerascheck:{[mdls;tts;tgt]
  mkcheck :(`MultiKeras in mdls`model);
  tgtcheck:(count distinct tgt)>min{count distinct x}each tts`ytrain`ytest;
  $[mkcheck&tgtcheck;i.errtgt;]mdls}

