\d .aml

// The following is a naming convention used in this file
/* d = data as a mixed list containing training and testing data ((xtrn;ytrn);(xtst;ytst))
/* s = seed used for initialising the same model
/* o = one-hot encoding for multi-classification example
/* m = model object being passed through the system

fitscore:{[d;s;mtype]
  if[mtype~`multi;d[;1]:npa@'flip@'./:[;((::;0);(::;1))](0,count d[0]1)_/:value .ml.i.onehot1(,/)d[;1]];
  m:mdl[d;s;mtype];
  m:fit[d;m];
  get[".aml.",string[mtype],"predict"][d;m]}


actdict:`binary`reg`multi!("sigmoid";"relu";"softmax")
lossdict:`binary`reg`multi!("binary_crossentropy";"mse";"categorical_crossentropy")

mdl:{[d;s;mtype]
 m:seq[];
 nps[s];
 m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
 m[`:add]dns[$[mtype~`multi;count distinct (d[0]1)`;1];`activation pykw actdict[mtype]];
 m[`:compile][`loss pykw lossdict[mtype];`optimizer pykw "rmsprop"];m}

fit:{[d;m]m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}

// Prediction functions for each of the keras models
/* d = Data from which prediction is to be made
/* m = Fitted Keras model
/. r > predicted value
binarypredict  :{[d;m].5<raze m[`:predict][npa d[1]0]`}
multipredict:{[d;m]m[`:predict_classes][npa d[1]0]`}
regpredict  :{[d;m]raze m[`:predict][npa d[1]0]`}

npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random][`:seed];

