\d .aml

canvas:.p.import[`reportlab.pdfgen.canvas]
pdfimage:.p.import[`reportlab.platypus]`:Image

// Generate a report using FPDF outlining the results from a run of the automl pipeline
/* dict  = dictionary with needed with values for the pdf
/* dt    = dictionary denoting the start and end time of an automl run
/* fname = This is a file path which denotes a save location for the generated report.
/. r     > a pdf report saved to disk
post.report:{[dict;dt;fname]
 pdf:canvas[`:Canvas][ssr[fname,"/q_automl_report_",sv["_";string(dict`mdl;dt`sttime)],".pdf";":";"."]];
 font[pdf;"Helvetica-BoldOblique";15];  
 title[pdf;f:800;"kdb+/q AutoML model generated report"];

 font[pdf;"Helvetica";11];
 fline1:"This report outlines the results achieved through the running of kdb+/q autoML, ",
        "this run started at ";
 fline2:string[dt`stdate]," at ",string[dt`sttime];
 cell[pdf;f-:30;fline1];
 cell[pdf;f-:15;fline2];

 font[pdf;"Helvetica-Bold";13];
 cell[pdf;f-:30;"Breakdown of Pre-Processing"];

 font[pdf;"Helvetica";11];
 feats:"Following the extraction of features a total of ",string[dict`feats]," were produced.";
 cell[pdf;f-:30;feats];

 feats:"Feature extraction took ",string[dict`feat_time]," time in total.";
 cell[pdf;f-:30;feats];

 font[pdf;"Helvetica-Bold";13];
 cell[pdf;f-:30;"Initial Scores"];
 
 font[pdf;"Helvetica";11];
 xval:$[(dict[`xv]0)in `mcsplit`pcsplit;
         "A percentage based cross validation .ml.",string[dict[`xv]0],
           " was performed with a holdout set of ",string[dict[`xv]1],
           "% of training data used for validation.";
         string[dict[`xv]1],"-fold cross validation was performed on the training",
           "set to find the best model using, ",string[dict[`xv]0],"."];
 cell[pdf;f-:30;xval];
 
 image[pdf;path,"/code/postproc/images/train_test_validate.png";f-:90;500;70];
 font[pdf;"Helvetica";8];
 fig_1:"Figure 1: This is representative image showing the data split into training,",
        "validation and testing sets.";
 cell[pdf;f-:10;fig_1];

 font[pdf;"Helvetica";11];
 xvtime1:"The total time to complete the running of cross validation",
         " for each of the models on the training set was: ";
 xvtime2:string[dict`xvtime],".";

 cell[pdf;f-:30;xvtime1];
 cell[pdf;f-:20;xvtime2];

 metric:"The metric that is being used for scoring and optimizing the models was: ",
         string[dict`metric],".";
 cell[pdf;f-:30;metric];

  // Take in a kdb dictionary for printing line by line to the pdf file.
  {[m;h;s]cell[m;h;s]}[pdf]'[cntf:(f-20)-15*1_til[1+count dd];dd:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`dict];
  f:last cntf;

 pdf[`:showPage][]; 

 
 image[pdf;dict`impact;f:500;400;300];
 font[pdf;"Helvetica";8];
 fig_2:"Figure 2: This is the feature impact for a number of the most significant",
        " features as determined on the training set";
 cell[pdf;f-:30;fig_2];

 font[pdf;"Helvetica-Bold";13];
 cell[pdf;f-:30;"Model selection summary"];

 font[pdf;"Helvetica";11];
 cell[pdf;f-:30;"Best scoring model = ",string first key[dict`dict]];

 holdout:"The score on the validation set for this model was = ",string[dict`holdout],".";
 cell[pdf;f-:30;holdout];

 bmtime:"The total time to complete the running of this model on the validation set was: ",
         string[dict`bmtime],".";
 cell[pdf;f-:30;bmtime];

 if[not (first key[dict`dict])in i.excludelist;
   font[pdf;"Helvetica";13];
   gstitle:"Grid search for a ",(string first key[dict`dict])," model.";
   cell[pdf;f-:30;gstitle];
   
   font[pdf;"Helvetica";11];
   gscfg:$[(dict[`gscfg]0)in `mcsplit`pcsplit;
           "The grid search was completed using .ml.gs.",string[dict[`gscfg]0],
             " with a percentage of ",string[dict[`gscfg]1],"% of training data used for validation";
           "A ",string[dict[`gscfg]1],"-fold grid-search was performed on the training set",
             " to find the best model using, ",string[dict[`gscfg]0],"."];
   cell[pdf;f-:30;gscfg];
   
   font[pdf;"Helvetica";11];
   gsp:"The following are the hyperparameters which have been deemed optimal for the model";
   cell[pdf;f-:30;gsp];
   
   {[m;i;h;s]cell[m;i;h;s]}[pdf]'[cntf:f-10*1_til[1+count dgs];dgs:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`gs];
   f:last cntf;
   ]
  
  fin:"The score for the best model fit on the entire training set and scored ",
      "on the test set was = ",string[dict`score];
  cell[pdf;f-30;fin];
  pdf[`:save][];
 }


// Utilities for the report generation functionality
/* m =   pdf gen module used
/* i =   how far indented is the text
/* h =   the placement height from the bottom of the page 
/* f =   font size
/* s =   font size
/* txt = text to include
/* fp =  filepath
/* wi =  image width
/* hi =  image height
font:{[m;f;s]m[`:setFont][f;s]}
cell:{[m;h;txt]m[`:drawString][30;h;txt]}
title:{[m;h;txt]m[`:drawString][150;h;txt]}
image:{[m;fp;h;wi;hi]m[`:drawImage][fp;40;h;wi;hi]}
