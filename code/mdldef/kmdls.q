\d .aml

// The following is a naming convention used in this file
/* d = data as a mixed list containing training and testing data ((xtrn;ytrn);(xtst;ytst))
/* s = seed used for initialising the same model
/* o = one-hot encoding for multi-classification example
/* m = model object being passed through the system (compiled/fitted)
/* mtype = model type

/. r > the predicted values for a given model as applied to input data
fitscore:{[d;s;mtype]
  if[mtype~`multi;d[;1]:npa@'flip@'./:[;((::;0);(::;1))](0,count d[0]1)_/:value .ml.i.onehot1(,/)d[;1]];
  m:mdl[d;s;mtype];
  m:fit[d;m];
  get[".aml.",string[mtype],"predict"][d;m]}

// Dictionaries mapping the problem type to the loss function and activation function
actdict:`binary`reg`multi!("sigmoid";"relu";"softmax")
lossdict:`binary`reg`multi!("binary_crossentropy";"mse";"categorical_crossentropy")

/. r > the compiled keras model
mdl:{[d;s;mtype]
 nps[s];
 if[not 1~checkimport[];tfs[s]];
 m:seq[];
 m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
 m[`:add]dns[$[mtype~`multi;count distinct (d[0]1)`;1];`activation pykw actdict[mtype]];
 m[`:compile][`loss pykw lossdict[mtype];`optimizer pykw "rmsprop"];m}

/. r > the fit keras model
fit:{[d;m]m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}

// Prediction functions for each of the keras models
/* d = Data from which prediction is to be made 
/*     formatting based on master workflow ((0n;0n);(xtst;0n))
/. r > predicted values
binarypredict  :{[d;m].5<raze m[`:predict][npa d[1]0]`}
multipredict:{[d;m]m[`:predict_classes][npa d[1]0]`}
regpredict  :{[d;m]raze m[`:predict][npa d[1]0]`}

npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random][`:seed];
if[not 1~checkimport[];tfs:.p.import[`tensorflow][`:random.set_seed]];
