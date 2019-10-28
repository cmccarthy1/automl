// The purpose of this file is to provide an initial pass at a function for fitting on new data and returning the predictions from the model.
// The function should take the following as parameters
/* x = data to be fit
/* y = the path to the folder which the /Config and /Models folders are
/* z = how the data is to be returned

// Required changes to automl to accommodate this
/. Add in a parameter to the output for 'getmetadata' that returns (`fresh/`normal)

\d .aml

skload:.p.import[`sklearn.externals][`:joblib][`:load]
krload:.p.import[`keras.models][`:load_model]

fitnew:{
  metadata:getmeta[.aml.path,"/Outputs/",y,"/Config/metadata"];
  typ:metadata`type;
  data:$[`normal=typ;
    i.normalproc[x;metadata];
    `fresh=typ;
    i.freshproc[x;metadata];
    '`$"This form of operation is not currently supported"
    ];
  $[(mp:metadata[`pylib])in `sklearn`keras;
    [model:$[mp~`sklearn;skload;krload].aml.path,"/Outputs/",y,"/Models/",string metadata[`best_model];
     model[`:predict;<]data];
    '`$"The current model type you are attempting to apply is not currently supported"]  
  }

/* x = data
/* y = metadata
i.normalproc:{
  x:i.symbencode[x;y`symencode];
  x:i.null_encode[x;med];
  x:.ml.infreplace[x];
  x:first normalcreate[x;::];
  flip value flip y[`features]#x
  }
i.freshproc:{
  agg:y`aggcols;prm:y`params;
  cols2use:k where not (k:cols[x])in agg;
  x:"f"$i.null_encode[value .ml.fresh.createfeatures[x;agg;cols2use;prm];med];
  x:.ml.infreplace x;
  // This is necessary as it is not guaranteed that new feature creation will produce the requisite features -> need to add dummy data
  if[not all ftc:y[`features]in cols x;
    new_cols:y[`features]where not ftc;
    x:y[`features] xcols flip flip[x],new_cols!(2;count x)#0f];
  flip value flip y[`features]#"f"$0^x
  }

/* x = data
/* y = dictionary with frequency/ohe encode instructions
i.symbencode:{
  // if there is only one input for each key and they're non named columns return the table unchanged
  $[all {not ` in x}each value y;.ml.onehot[.ml.freqencode[x;y`freq];y`ohe];
    ` in y`freq;.ml.onehot[x;y`ohe];
    ` in y`ohe;.ml.freqencode[x;y`freq];
    x]}
