\d .aml


// Create features using the FRESH algorithm
/* x = tabular data 
/* p = parameter upgrade as relevant dictionary or ::
freshcreate:{[x;p]
 x:"f"$i.null_encode[value .ml.fresh.createfeatures[x]. value 3#p;med];
 x:.ml.infreplace x;
 x:"f"$0^.ml.dropconstant x}
