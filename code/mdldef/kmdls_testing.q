\d .aml

binfitscore:{
  m:binmdl[x;y];
  m:binfit[x;m];
  binpredict[x[1]0;m];}

multifitscore:{
  l:`ytrn`ytst!flip@'./:[;((::;0);(::;1))](0,count x[0]1)_/:value .ml.i.onehot1(,/)x[;1];
  m:multimdl[x;y];
  m:multifit[x;m;l];
  multipredict[x[1]0;m]}

regfitscore:{
  m:regmdl[x;y];
  m:regfit[x;m];
  regpredict[x[1]0;m]}

binmdl:{
 m:seq[];
 nps[y];
 m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first x[0]0];
 m[`:add]dns[1;`activation pykw"sigmoid"];
 m[`:compile][`loss pykw"binary_crossentropy";`optimizer pykw"rmsprop"];m}

multimdl:{
  m:seq[];
  nps[y];
  m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first x[0]0];
  m[`:add]dns[count distinct x[0]1;`activation pykw"softmax"];
  m[`:compile][`loss pykw"categorical_crossentropy";`optimizer pykw"rmsprop"];m}

regmdl:{
  m:seq[];
  nps[y];
  m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first x[0]0];
  m[`:add]dns[1;`activation pykw"relu"];
  m[`:compile][`optimizer pykw"rmsprop";`loss pykw"mse"];m}

binfit  :{[d;m]  m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}
multifit:{[d;m;p]m[`:fit][npa d[0]0;npa p`ytrn;`batch_size pykw 32;`verbose pykw 0];m}
regfit  :{[d;m]  m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}


// Prediction functions for each of the keras models
/* d = Data from which prediction is to be made
/* m = Fitted Keras model
/. r > predicted value
binpredict  :{[d;m]`e+1;.5<raze m[`:predict][npa d]`}
multipredict:{[d;m]m[`:predict_classes][npa d]`}
regpredict  :{[d;m]raze m[`:predict][npa d]`}

npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random][`:seed];

