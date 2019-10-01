\d .aml
// for test implementation ["ffile.txt";"/testing/gridsearch/"] are the arguments to txtparse2
i.txtparse2   :{key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.aml.path,y,x}
i.extract_dict:{key[k]!value each value k:i.txtparse2[x;y]z}


// The following is a modification of the function .ml.gs.kfsplit to accommodate 
//  the needs of the automated machine learning platform, this should not be seen as a final version but gives
//  an idea of the methodology being used
/* typ_gs = form of grid search being applied   // defaults to kfsplit for regression & kfstrat for classification
/* xt  = x-training data
/* yt  = y-training data
/* mdl = symbol denoting the model to be used   // from the return of best model search 
/* hld = percentage of data in holdout set      // default to 20 %
/* d   = parameter dictionary used throughout the functions (must include holdout `hld`typ_gs)
/* typ = is the task `class/`reg
// The function should output both the score on the held out set and the best parameter set.
//   both these can be used to 
//     a. output the values to output
//     b. train a model on entire training set and test on the true holdout set


// paths and names will need to change on merge into main system
e_dict:{.aml.i.extract_dict["ffile.txt";"/testing/gridsearch/"]x}

gs.psearch:{[xt;yt;mdl;d;typ;mdls]
  // extract the required hyperparameters for given model from flat file 
  dict:e_dict[mdl];

  // create the appropriate module for the model being applied
  module:` sv 2#i.txtparse[typ;"/code/mdl_def/"]mdl;
  fn:d[`scf]$[`reg in distinct mdls`typ;`reg;`class];
  // produce the required fitting and scoring projection based on best model
  // at present this returns the scores based on the models provided by the user/algo
  fit_score:xv.fitpredict2[get fn]{y;x}[.p.import[module][hsym mdl];];
  // run the grid-search over the parameter set 
  get[` sv `.ml.gs,d`typ_gs][d`k;1;xt;yt;fit_score;dict;d`hld]
  }
