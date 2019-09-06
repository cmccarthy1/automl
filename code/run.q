\d .aml

// This is a prototype of the pipeline for the automated machine learning pipeline

/* tb   = input table
/* tgt  = target vector
/* typ  = type of feature extraction being completed
/* mdls = table of models (.aml.models[`class;tgt]/.aml.models[`reg;tgt])
/* p    = parameters (::) ~ default other changes user dependent

runexample:{[tb;tgt;typ;mdls;p]
 dtdict:`stdate`sttime!(.z.D;.z.T);
 dict:i.updparam[tb;p;typ];
 system "S ",string s:dict`seed;
 tb:i.autotype[tb;typ;dict];
 tb:preproc[tb;tgt;typ;dict];
 -1"\nData preprocessing completed, starting feature creation\n";
 tb:freshcreate[tb;dict];
 -1"Feature creation completed, starting initial model selection - allow time for large datasets\n";
 -1"Total features created = ",string[ctb:count 1_cols tb 0],"\n";
 bm:runmodels[tb 0;tgt;mdls;dict;dtdict];
 -1"\nModel selection has been completed, continuing to the next step\n";
 if[2=dict`saveopt;
 -1"Now saving down a report on this run to Outputs/Reports\n";
 report[i.report_dict[ctb;bm;tb;dtdict;path];dtdict];]
 }
