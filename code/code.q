
\l ml/ml.q
\l components.q

.ml.loadfile`:init.q

\d .aml

/* x = data table, rather than matrix to make most use out of the toolkit
/* y = target data array (should have the same number of values as data 
/*     table/unique values the case of FRESH
/* m = `classification/`regression (m)odel as a symbol
/* typ = dictionary denoting what is to be done 
/       1. single dict if `tseries`normal `type!`tseries/`normal dict 
/       2. multi-input dict if `type=`fresh;`type`aggcol`cols2drop`params!...
/* n = number of children to be produced initially

init:{[x;y;m;typ;n;p;seed]
 system"S ",string seed;
 comp.lencheck[x;y;typ];		/ check that #targets is data appropriate
 feats:comp.featurecreate[x;typ];	/ create feature appropriate for typ	
 feats:.ml.infreplace "f"$value feats;	/ remove infinities this needs float input for checks 
 ind:pop[feats;n];			/ indices for the initial feature population
 tts:.ml.traintestsplit[feats;y;p]; 	/ train-test-split the dataset
 comp.genloop[tts;n;m;ind;seed]		/ "Genetic loop"
 }


