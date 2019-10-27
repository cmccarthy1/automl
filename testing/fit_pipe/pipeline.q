// The purpose of this file is to provide an initial pass at a function for fitting on new data and returning the predictions from the model.
// The function should take the following as parameters
/* x = data to be fit
/* y = the path to the folder which the /Config and /Models folders are
/* z = how the data is to be returned

// Required changes to automl to accommodate this
/. Add in a parameter to the output for 'getmetadata' that returns (`fresh/`normal)

\d .aml

fitnew:{
  metadata:getmeta[.aml.path,y,"Config/metadata"];
  // the loads function and model decision functions will be wrapped into a 'bigger' routine once this has been expanded (if keras different)
  loads:.p.import[`sklearn.externals][`:joblib][`:load];
  model:loads[.aml.path,y,"/Models/",string metadata[`best_model]];
  typ:metadata`type;
  data:$[`normal=typ;
    i.normalproc[x;metadata];
    `fresh=typ;
    '`$"This is next to be implemented";
    '`$"This form of operation is not currently supported"
    ];
  model[`:predict;<]data
  }

/* x = data
/* y = metadata
i.normalproc:{
  x:i.symbencode[x;y`symencode];
  x:.ml.dropconstant x;
  x:i.null_encode[x;med];
  x:.ml.infreplace[x];
  x:first normalcreate[x;::];
  flip value flip y[`features]#x
  }

/* x = data
/* y = dictionary with frequency/ohe encode instructions
i.symbencode:{
  // if there is only one input for each key and they're non named columns return the table unchanged
  $[all {not ` in x}each value y;.ml.onehot[.ml.freqencode[x;y`freq];y`ohe];
    not ` in y`freq;.ml.onehot[x;y`freq];
    not ` in y`ohe;.ml.freqencode[x;y`ohe];
    x]}
