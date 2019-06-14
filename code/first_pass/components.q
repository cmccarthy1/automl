// The purpose of the code contained within this script is to act as the container
//  for subsections of an initial pass at an automl programme we are attempting to build
//  this is primarily focused on making sure that the code-base which is likely to be
//  expansive is "easy" to debug. A large number of comments and descriptions are included here
//  to make it easier to understand... Don't worry Andrew they'll be removed eventually.

\l utils.q

\d .aml

// The following function defines the models which are to be applied to the
//  dataset within the genetic algorithm it's important in this that for repeated runsI improve our capabilities to forecast and respond to natural disasters using orbital imagery, coupled with ground observations and social data? 
//  of the models the seed is continually reset to ensure that the same model is being
//  used over and over again.
/* x = m
/* y = seed
comp.mdls:{
 $[x=`classification;
    .p.import[`sklearn.tree;`:DecisionTreeClassifier][`random_state pykw y];
   x=`regression;
    .p.import[`sklearn.ensemble;`:AdaBoostRegressor][`learning_rate pykw 0.5;`random_state pykw y];
   '`$"incorrect model type"]}

/* x = tabular data for feature creation
/* y = target data
/* z = 'typ' dictionary defined at input in init
comp.lencheck:{
  $[`fresh=z`type;
   if[count[y]<>count distinct x z`aggcol;
      '`$"Can't use fresh count targets must equal count of unique aggregate values"];
   z[`type]in`tseries`normal;
   if[count[y]<>count x;
      '`$"Must have the same number of targets as values in table"];
   '`$"This is not a supported try 'normal,tseries or fresh'"]}

/* x = tabular data
/* y = 'typ' dictionary to be defined by the user
comp.featurecreate:{
 $[`fresh=y`type;
    0^.ml.fresh.createfeatures[x;y`aggcol;y`cols2drop;y`params];
   `tseries=y`type;
    0N!"t-series needs to be added";
   `normal=y`type;
    0N!"normal needs to be added";
   '`"Type of feature creation not recognised"]}

/* tts = train-test-split dataset
/* n = number of loops
/* m = model
/* col = columns within feature
/* ind = initial indices
/* seed = seed value being applied, this ensures that all runs are 'fair'
comp.genloop:{[tts;n;m;ind;seed]
 col:cols tts`xtrain;
 ascore:();mscore:();
 do[n;
    cvals:col where each ind;
    score:scoring[tts;;m;seed]each cvals;
    bst:ind where rank[score]in (hlf:"i"$cs%2) _ til cs:count score;
    ind:();
    do[hlf;ind,:crossing . 2?bst];
    ind:mutations[ind];
    ascore,:avg score;mscore,:max score
   ];
 0N!(ascore;mscore)}
