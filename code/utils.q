\d .aml

// Utilities for run.q

/  This function sets or updates the default parameter dictionary as appropriate
/* x   = data as table
/* p   = dictionary of parameters (type of feature extract dependant)
/* typ = type of feature extraction (FRESH/normal/tseries ...)
i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
  {d:`aggcols`params`xv`prf`scf`k`seed`saveopt`hld`typ_gs`tts`sz!
     (first cols x;
      .ml.fresh.params;`kfshuff;
      xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);
      5;42;2;0.2;`kfsplit;.ml.traintestsplit;0.2);
   $[y~(::);d;
     99h=type y;
     $[min key[y]in key[d];
       d[key y]:value y;
       '`$"You can only pass appropriate keys to fresh"];
     '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
   d}[x;p];
  typ=`normal;
   {d:`xv`prf`scf`k`seed`saveopt`hld`typ_gs`tts`sz!
      (`kfshuff;xv.fitpredict;
       `class`reg!(`.ml.accuracy;`.ml.mse);
       5;42;2;0.2;`kfsplit;.ml.traintestsplit;0.2);
    $[y~(::);d;
     99h=type y;
     $[min key[y]in key[d];
       d[key y]:value y;
       '`$"You can only pass appropriate keys to fresh"];
     '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
   d}[x;p];
  typ=`tseries;
   '`$"This will need to be added once the time-series recipe is in place";
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
 folder_name:path,"/Outputs/",string[x`stdate],"/Run_",string[x`sttime],"/Models";
 save_path: system"mkdir -p ",folder_name;
 joblib:.p.import[`sklearn.externals][`:joblib];
 $[(`sklearn=?[r;enlist(=;`model;y,());();`lib])0;
    (joblib[`:dump][z;folder_name,"/",string[y]];0N!string[y]," model saved to ",folder_name);
   (`keras=?[r;enlist(=;`model;y,());();`lib])0;
    (bm[`:save][folder_name,"/",string[y],".h5"];0N!string[y]," model saved to ",folder_name);
   0N!"Saving of non keras/sklearn models types is not currently supported"];
 }

