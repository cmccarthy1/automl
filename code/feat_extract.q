\d .aml

\l ml/ml.q
.ml.loadfile`:init.q

// x = tabular data 
// p = parameter upgrade as relevant dictionary or ::
fresh_create:{[x;p]
 dict:`aggcols`cols2use`params!(first cols x;1_cols x;.ml.fresh.params);
 $[p~(::);
   dict;
   99h=type p;
   $[min key[p]in key[dict];
     dict[key p]:value p;
     '`$"You can only pass appropriate keys to fresh"];
   '`$"You must pass identity or dictionary with appropriate key/value pairs to function"];
 .ml.fresh.createfeatures[x]. value dict}
 


lencheck:{[x;tgt;typ;p]
 if[typ~(::);typ:`normal];
 $[-11h=type typ;
  $[`fresh=typ;
    if[count[tgt]<>count distinct $[1=count p`aggcols;x[p`aggcols]0;(,/)x p`aggcols];
       '`$"Target count must equal count of unique agg values for fresh"];
   typ in`tseries`normal;
    if[count[y]<>count x;'`$"Must have the same number of targets as values in table"];
   '`$"Value for typ must be a supported symbol or ::"];
   '`$"Value for typ must be a supported symbol or ::"]}

/
// x = table of data
// typ = type of feature extraction being performed
// p = parameter changes being applied to the feature creation procedure
featcreate:{[x;typ;p]
 if[typ~(::)
 $[`fresh=type;
    fresh_create[x;y`aggcol;y`cols2drop;y`params];
   `tseries=y`type;
    0N!"t-series needs to be added";
   `normal=y`type;
    0N!"normal needs to be added";
   '`"Type of feature creation not recognised"]}
\
