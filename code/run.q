\d .aml


/* tb   = input table
/* tgt  = target vector 
/* typ  = type of feature extraction being completed
/* mdls = table of models (.aml.models`class/.aml.models`reg)
/* p    = parameters (::) ~ default other changes user dependent
runexample:{[tb;tgt;typ;mdls;p]
 dict:i.updparam[tb;p;typ]; 
 system "S ",string s:dict`seed;
 tb:preproc[tb;tgt;typ;dict];
 tb:freshcreate[tb;dict];
 runmodels[dict`xv;flip value flip tb;tgt;mdls;dict`prf;dict`scf;s]
 }


/ Utils
i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
  {d:`aggcols`cols2use`params`xv`prf`scf`seed!
     (first cols x;1_cols x;
      .ml.fresh.params;.ml.xval.kfshuff[5;1];
      .ml.fitpredict;`class`regr!(.ml.accuracy;.ml.mse);42);
   $[y~(::);d;
     99h=type y;
     $[min key[y]in key[d];
       d[key y]:value y;
       '`$"You can only pass appropriate keys to fresh"];
     '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
   d}[x;p];
  typ=`normal;
   '`$"This will need to be added once the normal recipe is in place";
  typ=`tseries;
   '`$"This will need to be added once the time-series recipe is in place";
  '`$"Incorrect input type"]}
