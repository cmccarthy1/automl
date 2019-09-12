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
/* `lgain  -> path to lift gain curve (path as string)

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
 cell[pdf;"The 5-fold cross validation scores for all the run models are as follows:"];
 line[pdf;5];

 font[pdf;11;`];
 xvtime:"The total time to complete the running of cross validation is: ",string[x`xvtime],".";
 cell[pdf;xvtime];
 line[pdf;7];

 metric:"The metric that is being used for the scoring of the models was: ",string[x`metric],".";
 cell[pdf;metric];
 line[pdf;7];

 {cell[x;y]}[pdf]each {(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}x`dict;
 line[pdf;7];

 image[pdf;x`impact];
 font[pdf;8;`];
 fig_1:"Figure 1: This is the feature impact for each of the 20 most significant features";
 cell[pdf;fig_1];
 line[pdf;7];

 pdf[`:add_page][];
 font[pdf;13;`B];
 cell[pdf;"Results Summary"];
 line[pdf;7];
 
 font[pdf;11;`];
 cell[pdf;"Best scoring model = ",string first key[x`dict]];
 line[pdf;5];

 holdout:"The score on the holdout set for this model was = ",string[x`holdout],".";
 cell[pdf;holdout]; 
 line[pdf;5];
 
 bmtime:"The total time to complete the running of the best model was: ",string[x`bmtime],".";
 cell[pdf;bmtime];
 line[pdf;7];


 system"mkdir -p ",folder_name:path,"/Outputs/",string[y`stdate],"/Reports";
 pdf[`:output][folder_name,"/q_automl_report_",sv["_";string(x`mdl;y`sttime)];`F];
 -1"Saving to pdf has been completed";}

font    :{x[`:set_font][`Arial;`size pykw y;`style pykw z]}
title   :{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"C")]}
cell    :{x[`:multi_cell][175;5;pykwargs `txt`align!(y;"L")]}
image   :{x[`:image][y;`w pykw 120]}
line    :{x[`:ln]y}

