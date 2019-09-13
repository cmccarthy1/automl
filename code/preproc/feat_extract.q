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


// This function currently defaults to use take the top 25%
// of significant feature this could be augmented easily
// in the future to add more diverse functionality or more options.
// For each current type of feature extraction this is used in place of more complex methods
// The function is a copy of that in the toolkit but here to allow expanded functionality in
// the future 
/* x = table with extracted_features
/* y = target data
freshsignificance:{.ml.fresh.significantfeatures[x;y;.ml.fresh.percentile 0.25]}
