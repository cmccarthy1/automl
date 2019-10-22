\d .aml

/  Create features using the FRESH algorithm
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


/  This function currently defaults to use take the top 25%
/  of significant feature this could be augmented easily
/  in the future to add more diverse functionality or more options.
/  For each current type of feature extraction this is used in place of more complex methods
/  The function is a copy of that in the toolkit but here to allow expanded functionality in
/  the future 
/* x = table with extracted_features
/* y = target data
freshsignificance:{
  $[0<>count k:.ml.fresh.significantfeatures[x;y;.ml.fresh.percentile 0.25];
    k;
    {-1"The feature significance extraction process deemed none of the features to be important continuing anyway";cols x}[x]]}

/  Create features for 'normal problems' -> one target for each row no time dependency
/  or fresh like structure
/* x = table on which to perform the feature creation
/* p = parameters to be passed to the model in line with i.updparams
normalcreate:{[x;p]
/ cols2use:k where not (k:cols[x])in p`ignore_cols;
  fe_start:.z.T;
  tcols:.ml.i.fndcols[x;"dmntvupz"];
  t:(cols[x]except tcols)#x;
  t:i.truncsvd[t;::;2];
  t:i.bulktransform[t;::];
  t:.ml.dropconstant i.null_encode[.ml.infreplace t;med];
  tcols:$[0<count tcols;.ml.timesplit[tcols#x;::];()];
  t:t^tcols;
  fe_end:.z.T-fe_start;
  (t;fe_end)}

