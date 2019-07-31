// This contains the utility functions used within the other scripts.
// This is mainly for code expansion in the future.


\d .aml


/ preproc.q utilities

i.lencheck:{[x;tgt;typ;p]
 if[typ~(::);typ:`normal];
 $[-11h=type typ;
  $[`fresh=typ;
    if[count[tgt]<>count distinct $[1=count p`aggcols;x[p`aggcols];(,'/)x p`aggcols];
       '`$"Target count must equal count of unique agg values for fresh"];
   typ in`tseries`normal;
    if[count[tgt]<>count x;
       '`$"Must have the same number of targets as values in table"];
   '`$"Input for typ must be a supported symbol or ::"];
   '`$"Input for typ must be a supported symbol or ::"]}
i.null_encode:{[x;y]
 vals:l k:where 0<sum each l:null each flip x;
 nms:`$string[k],\:"_null";
 $[0=count k;x;flip y[x]^flip[x],nms!vals]}
i.symencode:{
 sc:.ml.i.fndcols[x;"s"];                               / sc = symbol columns
 if[0=count sc;r:x];
 if[0<count sc;
  fc:where y<count each distinct each sc!flip[x]sc;     / fc = cols to freq encode
  ohe:sc where not sc in fc;                            / ohe = one hot encoded columns
  r:.ml.onehot[.ml.freqencode[x;fc];ohe]];r}
i.autotype:{[x;typ;p]
 $[typ in `tseries`normal;
   [cls:.ml.i.fndcols[x;"sfihjbepmdznuvt"];
    tb:flip cls!x cls;
    i.err_col[cols x;cls;typ]];
   typ=`fresh;
   [aprcls:flip (l:p[`aggcols]) _ flip x;
    cls:.ml.i.fndcols[aprcls;"sfiehjb"];
    tb:flip (l!x l,:()),cls!x cls;
    i.err_col[cols x;cols tb;typ]];
   tb:(::)];
  tb}

/ run.q utilities

// in default dictionary the following parameters are set but can be changed through modification of p
// FRESH:
/* aggcols  (FRESH columns to base aggregations on -> first column)
/* cols2use (Columns that we apply functions to    -> 1_cols table)
/* params   (functions to apply to data            -> all functions)
/* xv       (type of cross validation              -> kfsplit)
/* prf      (prediction function                   -> fitpredict)
/* scf      (scoring functions for class/regress   -> accuracy/mean square error)
/* k        (number of folds for cross validation  -> 5)
/* seed     (seed to be used to fix all runs fair  -> 42)
i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
  {d:`aggcols`params`xv`prf`scf`k`seed!
     (first cols x;
      .ml.fresh.params;`kfsplit;
      .ml.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);5;42);
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
i.updmodels:{[mdls;tgt]
 if[100000<count tgt;
    -1"\nLimiting the models being applied due to number targets>100,000";
    -1"No longer running neural nets or svms\n";
    r:select from mdls where (lib<>`keras),not fnc in `neural_network`svm];
 r}


/ distrib.q utilities
i.files:`class`reg`score!("classmodels.txt";"regmodels.txt";"scoring.txt")
i.mdlfunc:{$[`keras~x;get` sv``aml,y;{[x;y;z].p.import[x]y}[` sv x,y;hsym z]]}
i.txtparse:{{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,y,i.files x}

/ utils.q utilities
/ x = entire column list
/ y = sublist of columns we use
/ z = type of feature creation we are doing
i.err_col:{[x;y;z]if[count[x]<>count y;-1 "\n Removed the following columns due to type restrictions for ",string z;0N!x where not x in y]}
