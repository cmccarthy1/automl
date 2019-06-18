\d .aml

/ x = tabular data 
// p = parameter upgrade as relevant dictionary or ::
freshcreate:{[x;p]
 dict:`aggcols`cols2use`params!(first cols x;1_cols x;.ml.fresh.params);
 $[p~(::);
   dict;
   99h=type p;
   $[min key[p]in key[dict];
     dict[key p]:value p;
     '`$"You can only pass appropriate keys to fresh"];
   '`$"You must pass identity or dictionary with appropriate key/value pairs to function"];
 x:"f"$i.null_encode[value .ml.fresh.createfeatures[x]. value dict;med];
 x:.ml.infreplace x;
 x:"f"$0^.ml.dropconstant x}
 


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
