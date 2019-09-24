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
 -1"\nThe following is a breakdown of information for each of the relevant columns in the dataset\n";
 tb:preproc[tb;tgt;typ;dict];
 -1"\nData preprocessing completed, starting feature creation\n";
 tb:$[typ=`fresh;freshcreate[tb;dict];typ=`normal;normalcreate[tb;dict];'`err];
 feats:freshsignificance[tb 0;tgt];
 tab:feats#tb 0;
 -1"\nFeature creation and significance testing completed.\nStarting initial model selection - allow ample time for large datasets\n";
 -1"Total features being passed to the models = ",string[ctb:count 1_cols tab];
 bm:runmodels[tab;tgt;mdls;dict;dtdict];
 -1"\nModel selection has been completed, continuing to the next step\n";
 if[2=dict`saveopt;
 -1"Now saving down a report on this run to Outputs/Reports\n";
 report[i.report_dict[ctb;bm;tb;dtdict;path];dtdict];]
 }
