\d .aml

FPDF:.p.import[`fpdf][`:FPDF]

// inputs
/* x = dictionary with needed values for the pdf see following
/* `metric -> defined scoring metric for making decisions (symbol)
/* `dict   -> scores for each of the models (dictionary)
/* `feats  -> the number of features produced (IJHE)
/* `xvtime -> amount of time to run all models in cross validation
/* `bmtime -> amount of time to fit and predict on the best model
/* `mdl    -> best model (symbol)
/* `impact -> path to impact graph (path as string)
/* `xv     -> mixed list with type of cross validation and number of folds or percentage of data
/* `gs     -> mixed list with type of grid search and number of folds/percentage of data

// !!! make sure to put in semi colons after calls to pdf !!!

report:{
  pdf:FPDF[];
  pdf[`:add_page][];

  font[pdf;15;`BIU];
  title[pdf;"kdb+/q AutoML model generated report"];
  line[pdf;7];

  font[pdf;11;`];
  fline:"This report outlines the results achieved through the running of kdb+/q autoML, this run started at ",string[y`stdate]," at ",string[y`sttime];
  cell[pdf;fline];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Breakdown of Pre-Processing"];
  line[pdf;7];

  font[pdf;11;`];
  feats:"Following the extraction of features a total of ",string[x`feats]," were produced.";
  cell[pdf;feats];
  line[pdf;7];

  feats:"Feature extraction took ",string[x`feat_time]," time in total.";
  cell[pdf;feats];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Initial Scores"];
  line[pdf;7];

  font[pdf;11;`];
  grid_search:$[(x[`xv]0)in `mcsplit`pcsplit;
                "A percentage based cross validation .ml.",string[x[`xv]0]," was performed with a holdout set of ",string[x[`xv]1],"% of training data used for validation.";
               string[x[`xv]0],"-fold cross validation was performed on the training set to find the best model using, .ml.",string[x[`xv]0],"."];
  cell[pdf;grid_search];
  line[pdf;5];

  image[pdf;path,"/code/postproc/Images/train_test_validate.png"];
  font[pdf;8;`];
  fig_1:"Figure 1: This is representative image of the form of train-validate-test split performed here.";
  cell[pdf;fig_1];
  line[pdf;7];

  font[pdf;11;`];
  xvtime:"The total time to complete the running of cross validation for each of the models on the training set was: ",string[x`xvtime],".";
  cell[pdf;xvtime];
  line[pdf;7];

  metric:"The metric that is being used for the scoring of the models was: ",string[x`metric],".";
  cell[pdf;metric];
  line[pdf;7];
 
  {cell[x;y]}[pdf]each {(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}x`dict;
  line[pdf;7];
 
  image[pdf;x`impact];
  font[pdf;8;`];
  fig_2:"Figure 2: This is the feature impact for a number of the most significant features as determined on the training set";
  cell[pdf;fig_2];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Initial model selection summary"];
  line[pdf;7];
 
  font[pdf;11;`];
  cell[pdf;"Best scoring model = ",string first key[x`dict]];
  line[pdf;5];

  holdout:"The score on the validation set for this model was = ",string[x`holdout],".";
  cell[pdf;holdout]; 
  line[pdf;5];
 
  bmtime:"The total time to complete the running of this model on the validation set was: ",string[x`bmtime],".";
  cell[pdf;bmtime];
  line[pdf;7];

  if[not (first key[x`dict])in `LinearRegression`GaussianNB;
    font[pdf;13;`B];
    gstitle:"Grid search for a ",(string first key[x`dict])," model.";
    cell[pdf;gstitle];
    line[pdf;5];

    font[pdf;11;`];
    gsp:"The following are the hyperparameters which have been deemed optimal for the model";
    cell[pdf;gsp];
    line[pdf;5];

    {cell[x;y]}[pdf]each {(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}x`gs;
    line[pdf;7];
    ]

    fin:"The score for the best model fit on the entire training set and scored on the test set was = ",string[x`score];
    cell[pdf;fin];
    line[pdf;7];
  
  system"mkdir -p ",folder_name:path,"/Outputs/",string[y`stdate],"/Run_",string[y`sttime],"/Reports";
  pdf[`:output][folder_name,"/q_automl_report_",sv["_";string(x`mdl;y`sttime)];`F];
  -1"Saving to pdf has been completed";}

font    :{x[`:set_font][`Arial;`size pykw y;`style pykw z]}
title   :{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"C")]}
cell    :{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"L")]}
image   :{x[`:image][y;`w pykw 120]}
line    :{x[`:ln]y}

