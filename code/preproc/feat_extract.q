\d .aml

// Create features using the FRESH algorithm
/* x = tabular data
/* p = parameter upgrade as relevant dictionary or ::
freshcreate:{[x;p]
 agg:p`aggcols;prm:p`params;
 cols2use:k where not (k:cols[x])in agg;
 fe_start:.z.T;
 x:"f"$i.null_encode[value .ml.fresh.createfeatures[x;agg;cols2use;prm];med];
 fe_end:.z.T-fe_start;
 x:.ml.infreplace x;
 ("f"$0^.ml.dropconstant x;fe_end)}
