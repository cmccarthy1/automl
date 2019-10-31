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
  x:i.symbencode[x;y`symencode];
  x:i.null_encode[x;med];
  x:.ml.infreplace[x];
  x:first normalcreate[x;::];
  flip value flip y[`features]#x
  }

i.freshproc:{
  agg:y`aggcols;
  cols2use:k where not (k:cols[x])in agg;

  // only apply relevant functions based on the extracted features 
  app_fns:1!select from 0!.ml.fresh.params where f in `$distinct{("_" vs string x)1}each y`features;

  x:i.null_encode[value .ml.fresh.createfeatures[x;agg;cols2use;app_fns];med];
  x:.ml.infreplace x;
  // This is necessary as it is not guaranteed that new feature creation will produce the requisite features 
  //  -> need to add dummy data
  if[not all ftc:y[`features]in cols x;
    new_cols:y[`features]where not ftc;
    x:y[`features] xcols flip flip[x],new_cols!((count new_cols;count x)#0f),()];
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


/  Symbol encoding
/* tab = input table
/* n   = number of distinct values in a column after which we symbol encode
/* b   = boolean flag indicating if table is to be returned (0) or encoding type returned (1)
/* d   = the parameter dictionary outlining the run setup
/* typ = how the encoding should work, if it's a dictionary which could be returned from b=1 then only encode on those cols else (::) don't care
/. returns the table with appropriate encoding applied
i.symencode_base:{[tab;n;b;d;typ]
  sc:.ml.i.fndcols[tab;"s"]except $[tp:`fresh~d`typ;acol:d`aggcols;`];
  if[0=count sc;r:$[b=1;`freq`ohe!``;tab]];
  if[0<count sc;
    fc:where n<count each distinct each sc!flip[tab]sc;
    ohe:sc where not sc in fc;
    r:$[b=1;`freq`ohe!(fc;ohe);tp;.ml.onehot[raze .ml.freqencode[;fc]each
      flip each 0!acol xgroup tab;ohe];
      .ml.onehot[.ml.freqencode[tab;fc];ohe]]];
  if[b=0;r:flip sc _ flip r];
  r
  }

i.test_encode:{[tab;n;b;d;typ]
  $[99h<>type typ;
     i.symencode_base[tab;n;b;d;(::)]
  }
  
