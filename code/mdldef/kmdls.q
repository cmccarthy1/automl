\d .aml

// The following is a naming convention used in this file
/* d = data as a mixed list containing training and testing data ((xtrn;ytrn);(xtst;ytst))
/* s = seed used for initialising the same model
/* o = one-hot encoding for multi-classification example
/* m = model object being passed through the system

binfitscore:{[d;s]
  m:binmdl[d;s];
  m:binfit[d;m];
  binpredict[d;m]}

multifitscore:{[d;s]
  o:`ytrn`ytst!flip@'./:[;((::;0);(::;1))](0,count d[0]1)_/:value .ml.i.onehot1(,/)d[;1];
  m:multimdl[d;s];
  m:multifit[d;m;o];
  multipredict[d;m]}

regfitscore:{[d;s]
  m:regmdl[d;s];
  m:regfit[d;m];
  regpredict[d;m]}

binmdl:{[d;s]
 m:seq[];
 nps[s];
 m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
 m[`:add]dns[1;`activation pykw"sigmoid"];
 m[`:compile][`loss pykw"binary_crossentropy";`optimizer pykw"rmsprop"];m}

multimdl:{[d;s]
  m:seq[];
  nps[s];
  m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
  m[`:add]dns[count distinct d[0]1;`activation pykw"softmax"];
  m[`:compile][`loss pykw"categorical_crossentropy";`optimizer pykw"rmsprop"];m}

regmdl:{[d;s]
  m:seq[];
  nps[s];
  m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
  m[`:add]dns[1;`activation pykw"relu"];
  m[`:compile][`optimizer pykw"rmsprop";`loss pykw"mse"];m}

binfit  :{[d;m]  m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}
multifit:{[d;m;o]m[`:fit][npa d[0]0;npa o`ytrn;`batch_size pykw 32;`verbose pykw 0];m}
regfit  :{[d;m]  m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}


// Prediction functions for each of the keras models
/* d = Data from which prediction is to be made
/* m = Fitted Keras model
/. r > predicted value
binpredict  :{[d;m].5<raze m[`:predict][npa d[1]0]`}
multipredict:{[d;m]m[`:predict_classes][npa d[1]0]`}
regpredict  :{[d;m]raze m[`:predict][npa d[1]0]`}

npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random][`:seed];

