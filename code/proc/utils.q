\d .aml

// In default dictionary the following parameters are set but can be changed through modification of p
/ x   = data as table
/ p   = dictionary of parameters (type of feature extract dependant)
/ typ = type of feature extraction (FRESH/normal/tseries ...)
i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
  {d:`aggcols`params`xv`prf`scf`k`seed`saveopt!
     (first cols x;
      .ml.fresh.params;`kfshuff;
      xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);5;42;2);
   $[y~(::);d;
     99h=type y;
     $[min key[y]in key[d];
       d[key y]:value y;
       '`$"You can only pass appropriate keys to fresh"];
     '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
   d}[x;p];
  typ=`normal;
   {d:`xv`prf`scf`k`seed`saveopt!
      (`kfshuff;xv.fitpredict;
       `class`reg!(`.ml.accuracy;`.ml.mse);
       5;42;2);
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

// Update models available based on amount of available data
i.updmodels:{[mdls;tgt]
 $[100000<count tgt;
   [-1"\nLimiting the models being applied due to number targets>100,000";
    -1"No longer running neural nets or svms\n";
    select from mdls where(lib<>`keras),not fnc in`neural_network`svm];mdls]}

// dict of text files for parsing
i.files:`class`reg`score!("classmodels.txt";"regmodels.txt";"scoring.txt")

// extraction of models from text
i.mdlfunc:{$[`keras~x;get` sv``aml,y;{[x;y;z].p.import[x]y}[` sv x,y;hsym z]]}

// extraction of infromation from text
i.txtparse:{{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,y,i.files x}

// table -> matrix
i.mattab :{flip value flip x}

// shuffle columns of matrix/table based on col name or idx
i.shuffle:{idx:neg[n]?n:count x;$[98h~type x;x:@[x;y;@;idx];x[;y]:x[;y]idx];:x}

// save down the best model
/* x = date-time of model start (dict)
/* y = best model name (`symbol)
/* z = best model object (embedPy)
/* r = all applied models (table)
i.savemdl:{[x;y;z;r]
 folder_name:path,"/Outputs/",string[x`stdate],"/Models/Run_",string[x`sttime];
 save_path: system"mkdir -p ",folder_name;
 pickle:.p.get[`pickle_save];
 $[(`sklearn=?[r;enlist(=;`model;y,());();`lib])0;
    (pickle[folder_name,"/",string[y];z];0N!string[y]," model saved to ",folder_name);
   (`keras=?[r;enlist(=;`model;y,());();`lib])0;
    (bm[`:save][folder_name,"/",string[y],".h5"];0N!string[y]," model saved to ",folder_name);
   0N!"Saving of non keras/sklearn models types is not currently supported"];
 }

