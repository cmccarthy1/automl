\d .aml

// This is a prototype of the pipeline for the automated machine learning pipeline

/* tb   = input table
/* tgt  = target vector 
/* typ  = type of feature extraction being completed
/* mdls = table of models (.aml.models`class/.aml.models`reg)
/* p    = parameters (::) ~ default other changes user dependent

runexample:{[tb;tgt;typ;mdls;p]
 dict:i.updparam[tb;p;typ];
 system "S ",string s:dict`seed;
 tb:preproc[tb;tgt;typ;dict];
 -1"\nPreprocessing of data completed, starting feature creation\n";
 tb:freshcreate[tb;dict];
 -1"Feature creation completed, starting initial model selection allow time on large datasets\n";
 -1"Total feature created = ",string[count 1_cols tb],"\n";
 rmdls:runmodels[flip value flip tb;tgt;mdls;dict];
 -1"\nA ranking of the best models has now been completed continuing to the next step\n";
 rmdls
 }
