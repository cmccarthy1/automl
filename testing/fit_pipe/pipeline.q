// The purpose of this file is to provide an initial pass at a function for fitting on new data and returning the predictions from the model.
// This currently works reliably for 'normal creation' but symbol encoding in fresh is still to be supported
// The function should take the following as parameters
/* x = data to be fit
/* y = the path to the folder which the /Config and /Models folders are
/* z = how the data is to be returned

// Required changes to automl to accommodate this
/. need to modify symencode/symbencode here to accommodate the new FRESH version

\d .aml

skload:.p.import[`joblib][`:load]
krload:.p.import[`keras.models][`:load_model]

fitnew:{
  metadata:getmeta[.aml.path,"/Outputs/",y,"/Config/metadata"];
  typ:metadata`typ;
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
  x:i.symencode[x;10;0;y;y`symencode];
  x:i.null_encode[x;med];
  x:.ml.infreplace[x];
  x:first normalcreate[x;::];
  flip value flip y[`features]#x
  }

i.freshproc:{
  agg:y`aggcols;
  // only apply relevant functions based on the extracted features 
  app_fns:1!select from 0!.ml.fresh.params where f in raze `$distinct{("_" vs string x)1}each y`features;
  x:i.symencode[x;10;0;y;y`symencode];
  cols2use:k where not (k:cols[x])in agg;
  x:i.null_encode[value .ml.fresh.createfeatures[x;agg;cols2use;app_fns];med];
  x:.ml.infreplace x;
  // This is necessary as it is not guaranteed that new feature creation will produce the requisite features 
  //  -> need to add dummy data
  if[not all ftc:y[`features]in cols x;
    new_cols:y[`features]where not ftc;
    x:y[`features] xcols flip flip[x],new_cols!((count new_cols;count x)#0f),()];
  flip value flip y[`features]#"f"$0^x
  }
