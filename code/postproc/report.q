\d .aml

canvas:.p.import[`reportlab.pdfgen.canvas]

// Generate a report using FPDF outlining the results from a run of the automl pipeline
/* dict  = dictionary with needed with values for the pdf
/* dt    = dictionary denoting the start and end time of an automl run
/* fname = This is a file path which denotes a save location for the generated report.
/. r     > a pdf report saved to disk
post.report:{[dict;dt;fname]
 0N!fname;
 pdf:canvas[`:Canvas]["tst.pdf"];
 font[pdf;"Helvetica-BoldOblique";15];  
 cell[pdf;150;800;"kdb+/q AutoML model generated report"];

 font[pdf;"Helvetica";11];
 fline:"This report outlines the results achieved through the running of kdb+/q autoML, ",
        "this run started at ",string[dt`stdate]," at ",string[dt`sttime];
 cell[pdf;50;770;fline];

 font[pdf;"Helvetica-Bold";13];
 cell[pdf;50;740;"Breakdown of Pre-Processing"];

 font[pdf;"Helvetica";11];
 feats:"Following the extraction of features a total of ",string[dict`feats]," were produced.";
 cell[pdf;50;710;feats];

 feats:"Feature extraction took ",string[dict`feat_time]," time in total.";
 cell[pdf;50;680;feats];

 pdf[`:save][];
 }


/* m = pdf gen module used
/* i = how far indented is the text
/* h = the placement height from the bottom of the page 
/* f = font size
/* s = font size
/* txt = text to include
font:{[m;f;s]m[`:setFont][f;s]}
cell:{[m;i;h;txt]m[`:drawString][i;h;txt]}

