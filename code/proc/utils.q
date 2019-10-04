\d .aml

// Utilities for proc.q

/  Check if multikeras model is to be applied and each target exists in both training and testing sets
i.kerascheck:{$[(`MultiKeras in x`model)&(count distinct z)>min{count distinct x}each y`ytrain`ytest;i.err_tgt;]x}

/  Dict of text files for parsing
i.files:`class`reg`score!("classmodels.txt";"regmodels.txt";"scoring.txt")

/  Extraction of models from text
i.mdlfunc:{$[`keras~x;get` sv``aml,y;{[x;y;z].p.import[x]y}[` sv x,y;hsym z]]}

/  Update models available based on amount of available data
i.updmodels:{[mdls;tgt]
 $[100000<count tgt;
   [-1"\nLimiting the models being applied due to number targets>100,000";
    -1"No longer running neural nets or svms\n";
    select from mdls where(lib<>`keras),not fnc in`neural_network`svm];mdls]}


// Utilities for xvgs.q

/ parse the hyperparameter flatfile
i.paramparse:{key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.aml.path,y,x}

/ extract a dictionary from the parsed flatfile
i.e_dict:{key[k]!value each value k:i.paramparse[x;y]z}
i.extract_dict:{.aml.i.e_dict["hyperparams.txt";"/code/mdl_def/"]x}


// Utilities for both scripts

/  extract the scoring function to be applied for model selection
/* x = dictionary of params, y = mdl table
i.scfn:{x[`scf]$[`reg in distinct y`typ;`reg;`class]}

/  extract appropriate ordering for scoring function chosen
/* x = scoring function
i.ord:{get string first i.txtparse[`score;"/code/mdl_def/"]x}

/  extraction of infromation from text
i.txtparse:{{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,y,i.files x}

