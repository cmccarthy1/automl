\d .aml

/ x = tabular data 
// p = parameter upgrade as relevant dictionary or ::
freshcreate:{[x;p]
 x:"f"$i.null_encode[value .ml.fresh.createfeatures[x]. value 3#p;med];
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
