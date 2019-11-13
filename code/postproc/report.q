\d .aml

FPDF:.p.import[`fpdf][`:FPDF]

// Generate a report using FPDF outlining the results from a run of the automl pipeline
/* dict = dictionary with needed with values for the pdf
/. dt   = dictionary denoting the start and end time of an automl run
/. r    > a pdf report saved to disk
post.report:{[dict;dt]
  pdf:FPDF[];
  pdf[`:add_page][];

  font[pdf;15;`BIU];
  title[pdf;"kdb+/q AutoML model generated report"];
  line[pdf;7];

  font[pdf;11;`];
  fline:"This report outlines the results achieved through the running of kdb+/q autoML, ",
        "this run started at ",string[dt`stdate]," at ",string[dt`sttime];
  cell[pdf;fline];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Breakdown of Pre-Processing"];
  line[pdf;7];

  font[pdf;11;`];
  feats:"Following the extraction of features a total of ",string[dict`feats]," were produced.";
  cell[pdf;feats];
  line[pdf;7];

  feats:"Feature extraction took ",string[dict`feat_time]," time in total.";
  cell[pdf;feats];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Initial Scores"];
  line[pdf;7];

  font[pdf;11;`];
  xval:$[(dict[`xv]0)in `mcsplit`pcsplit;
         "A percentage based cross validation .ml.",string[dict[`xv]0],
           " was performed with a holdout set of ",string[dict[`xv]1],
           "% of training data used for validation.";
         string[dict[`xv]1],"-fold cross validation was performed on the training",
           "set to find the best model using, .ml.",string[dict[`xv]0],"."];
  cell[pdf;xval];
  line[pdf;5];

  image[pdf;path,"/code/postproc/Images/train_test_validate.png"];
  font[pdf;8;`];
  fig_1:"Figure 1: This is representative image showing the data split into training,",
        "validation and testing sets.";
  cell[pdf;fig_1];
  line[pdf;7];

  font[pdf;11;`];
  xvtime:"The total time to complete the running of cross validation",
         " for each of the models on the training set was: ",string[dict`xvtime],".";
  cell[pdf;xvtime];
  line[pdf;7];

  metric:"The metric that is being used for scoring and optimizing the models was: ",
         string[dict`metric],".";
  cell[pdf;metric];
  line[pdf;10];
  
  // Take in a kdb dictionary for printing line by line to the pdf file.
  {cell[x;y]}[pdf]each {(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`dict;
  line[pdf;7];
 
  image[pdf;dict`impact];
  font[pdf;8;`];
  fig_2:"Figure 2: This is the feature impact for a number of the most significant",
        " features as determined on the training set";
  cell[pdf;fig_2];
  line[pdf;7];

  font[pdf;13;`B];
  cell[pdf;"Model selection summary"];
  line[pdf;7];
 
  font[pdf;11;`];
  cell[pdf;"Best scoring model = ",string first key[dict`dict]];
  line[pdf;5];

  holdout:"The score on the validation set for this model was = ",string[dict`holdout],".";
  cell[pdf;holdout]; 
  line[pdf;5];
 
  bmtime:"The total time to complete the running of this model on the validation set was: ",
         string[dict`bmtime],".";
  cell[pdf;bmtime];
  line[pdf;7];

  if[not (first key[dict`dict])in `LinearRegression`GaussianNB;
    font[pdf;13;`B];
    gstitle:"Grid search for a ",(string first key[dict`dict])," model.";
    cell[pdf;gstitle];
    line[pdf;5];

    font[pdf;11;`];
    gscfg:$[(dict[`gscfg]0)in `mcsplit`pcsplit;
            "The grid search was completed using .ml.gs.",string[dict[`gscfg]0],
              " with a percentage of ",string[dict[`gscfg]1],"% of training data used for validation";
            ". A ",string[dict[`gscfg]1],"-fold grid-search was performed on the training set",
              " to find the best model using, .ml.gs.",string[dict[`gscfg]0],"."];
    cell[pdf;gscfg];
    line[pdf;7];

    font[pdf;11;`];
    gsp:"The following are the hyperparameters which have been deemed optimal for the model";
    cell[pdf;gsp];
    line[pdf;5];

    {cell[x;y]}[pdf]each {(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`gs;
    line[pdf;7];
    ]

  fin:"The score for the best model fit on the entire training set and scored ",
      "on the test set was = ",string[dict`score];
  cell[pdf;fin];
  line[pdf;7];
  
  system"mkdir",$[.z.o like "w*";" ";" -p "],
        fname:ssr[path,"/Outputs/",string[dt`stdate],"/Run_",string[dt`sttime],"/Reports";":";"."];
  pdf[`:output][ssr[fname,"/q_automl_report_",sv["_";string(dict`mdl;dt`sttime)],".pdf";":";"."];`F];}

// Utilities for the report generation functionality
font :{x[`:set_font][`Arial;`size pykw y;`style pykw z]}
title:{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"C")]}
cell :{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"L")]}
image:{x[`:image][y;`w pykw 120]}
line :{x[`:ln]y}
