\d .aml

// Utilities for run.q

/  Function takes in a string which is the name of a parameter flatfile
/  Returns the parameter dictionary
i.getdict:{
 d:i.paramparse[x;"/code/mdl_def/"];
 idx:(k except`scf;k except`xv`gs`scf;$[`xv in k;`xv;()],$[`gs in k;`gs;()];$[`scf in k:key d;`scf;()]);
 fnc:(key;{get string first x};{(x 0;get string x 1)};{key[x]!`$value x});
 if[sgl:1=count d;d:(enlist[`]!enlist""),d];
 d:{$[0<count y;@[x;y;z];x]}/[d;idx;fnc];
 if[sgl;d:1_d];
 d}
 
i.freshdefault:`aggcols`params`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
  ({first cols x};`.ml.fresh.params;(`.ml.xv.kfshuff;5);(`.ml.xv.kfshuff;5);`.aml.xv.fitpredict;
   `class`reg!(`.ml.accuracy;`.ml.mse);42;2;0.2;`.ml.traintestsplit;0.2)
i.normaldefault:`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
  ((`.ml.xv.kfshuff;5);(`.ml.xv.kfshuff;5);`.aml.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);
   42;2;0.2;`.ml.traintestsplit;0.2)

// Saves down flatfile of default dict
/* f = filename as string, symbol or hsym
/* feat_typ = type of feature extraction, e.g. `fresh or `normal
/. Returns flatfile of dictionary parameters

savedefault:{[f;feat_typ]
  // Check type of filename and convert to string
  f:$[10h~typf:type f;f;
      -11h~typf;$[":"~first strf;1_;]strf:string typf;
      '`$"filename must be string, symbol or hsym"];
  // Open handle to file f
  h:hopen hsym`$raze[.aml.path],"/automl/code/mdl_def/",f;
  // Set d to default dictionary for feat_typ
  d:$[`fresh~feat_typ;.aml.i.freshdefault;
      `normal~feat_typ;.aml.i.normaldefault;
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
  // Write to file
  {x y}[h]each strd;
  hclose h;}
  
/  This function sets or updates the default parameter dictionary as appropriate
/* x   = data as table
/* p   = dictionary of parameters (type of feature extract dependant)
/* typ = type of feature extraction (FRESH/normal/tseries ...)
i.updparam:{[x;p;typ]
 dict:
  / FRESH
  $[typ=`fresh;
      {d:`aggcols`params`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
         ({first cols x};.ml.fresh.params;(`kfshuff;5);(`kfshuff;5);
         xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);
         42;2;0.2;.ml.traintestsplit;0.2);	   
       d:$[(ty:type y)in 10 -11 99h;
	      [if[10h~ty;y:.aml.i.getdict y];
		   if[-11h~ty;y:.aml.i.getdict$[":"~first y;1_;]y:string y];
		   $[min key[y]in key d;d,y;
			 '`$"You can only pass appropriate keys to fresh"]];
		  y~(::);d;
		  '`$"p must be passed the identity `(::)`, a filepath to a parameter flatfile or a dictionary with appropriate key/value pairs"];
	   d[`aggcols]:$[100h~typagg:type d`aggcols;d[`aggcols]x;11h~abs typagg;d`aggcols;'`$"aggcols must be passed function or list of columns"];
	   d,enlist[`tf]!enlist 0~checkimport[]}[x;p];
  / NORMAL
    typ=`normal;
      {d:`xv`gs`prf`scf`seed`saveopt`hld`tts`sz!
         ((`kfshuff;5);(`kfshuff;5);xv.fitpredict;
         `class`reg!(`.ml.accuracy;`.ml.mse);
         42;2;0.2;.ml.traintestsplit;0.2);
       d:$[(ty:type y)in 10 -11 99h;
	      [if[10h~ty;y:.aml.i.getdict y];
		   if[-11h~ty;y:.aml.i.getdict$[":"~first y;1_;]y:string y];
		   $[min key[y]in key d;d,y;
			 '`$"You can only pass appropriate keys to normal"]];
		  y~(::);d;
		  '`$"p must be passed the identity `(::)`, a filepath to a parameter flatfile or a dictionary with appropriate key/value pairs"];
	   d,enlist[`tf]!enlist 0~checkimport[]}[x;p];
  / TIMESERIES
    typ=`tseries;
      '`$"This will need to be added once the time-series recipe is in place";
  / ERROR
    '`$"Incorrect input type"]}

/  apply scoring function to precitions from model
/* x = x-test; y = y-test; z = model; r = scoring function
i.scorepred:{[x;y;z;r] r[;y]z[`:predict][x]`}

/  save down the best model
/* x = date-time of model start (dict)
/* y = best model name (`symbol)
/* z = best model object (embedPy)
/* r = all applied models (table)
i.savemdl:{[x;y;z;r]
 folder_name:path,"/",mo:ssr["Outputs/",string[x`stdate],"/Run_",string[x`sttime],"/Models/";":";"."];
 save_path: system"mkdir -p ",folder_name;
 joblib:.p.import[`joblib];
 $[(`sklearn=?[r;enlist(=;`model;y,());();`lib])0;
    (joblib[`:dump][z;folder_name,"/",string[y]];-1"Saving down ",string[y]," model to ",mo);
   (`keras=?[r;enlist(=;`model;y,());();`lib])0;
    (bm[`:save][folder_name,"/",string[y],".h5"];-1"Saving down ",string[y]," model to ",mo);
   -1"Saving of non keras/sklearn models types is not currently supported"];
 }

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
/. 
i.kerascheck:{$[(`MultiKeras in x`model)&(count distinct z)>min{count distinct x}each y`ytrain`ytest;i.errtgt;]x}


\d .
\d .ml

i.infrep:{
 t:i.inftyp first string y;
 {[n;x;y;z]@[x;i;:;z@[x;i:where x=y;:;n]]}[t 0]/[x;t 1 2;(min;max)]}
i.inftyp:("5";"8";"9";"6";"7";"12";"16";"17";"18")!
 (0N -32767 32767;0N -0w 0w;0n -0w 0w),6#enlist 0N -0W 0W

infreplace:{
 $[98=t:type x;
   [m:type each dt:k!x k:.ml.i.fndcols[x;"hijefpnuv"];flip flip[x]^i.infrep'[dt;m]];
   0=t;
   [m:type each dt:x r:where all each string[type each x]in key i.inftyp;(x til[count x]except r),i.infrep'[dt;m]];
   98=type kx:key x;
   [m:type each dt:k!x k:.ml.i.fndcols[x:value x;"hijefpnuv"];cols[kx]xkey flip flip[kx],flip[x]^i.infrep'[dt;m]];
   [m:type each dt:k!x k:.ml.i.fndcols[x:flip x;"hijefpnuv"];flip[x]^i.infrep'[dt;m]]]}

