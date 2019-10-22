\d .aml

/* mdl = symbol denoting the model to be used   // from the return of best model search
/* d   = parameter dictionary used throughout the functions (must include holdout `hld`typ_gs)
/* typ = is the task `class/`reg
/* mdls= table of the models which could be applied
gs.psearch:{[xtrn;ytrn;xtst;ytst;mdl;d;typ;mdls]
  dict:i.extract_dict[mdl];					// dictionary hyperparameters
  module:` sv 2#i.txtparse[typ;"/code/mdl_def/"]mdl;            // required module names
  fn:i.scfn[d;mdls];						// relevant scoring function
  o:i.ord fn;     						// required ordering to data
  epymdl:.p.import[module][hsym mdl];				// embedPy model definition for relevant model
  / fitting and scoring projection
  fitscore:gs.fitpredict[get fn]{y;x}[epymdl;];
  / apply grid search
  gsprms:get[` sv `.ml.gs,d`typ_gs][d`k;1;xtrn;ytrn;fitscore;dict;d`hld];
  hyp:first key o avg each first gsprms;
  / 'best' model
  bmdl:epymdl[pykwargs hyp][`:fit][xtrn;ytrn];
  score:fn[;ytst]bmdl[`:predict][flip value flip xtst]`;
  (score;hyp;bmdl)
  }

/ cross validation search w/ random seed where applicable
xv.seed:{[x;y;d;m]
 b:m[`lib]~`sklearn;
 system"S 43";
 s:$[a:m[`seed]~`seed;$[b;enlist[`random_state]!enlist d`seed;d`seed];::];
 $[a&b;first value get[` sv`.ml.gs,d`xv][d`k;1;x;y;d[`prf]m`minit;s;0];
   get[` sv`.ml.xv,d`xv][d`k;1;x;y;d[`prf][m`minit;s]]]}

/ returns (ypred;ytrue) for each k
xv.fitpredict:{[f;p;d]($[-7h~type p;f[d;p];@[.[f[][p]`:fit;d 0]`:predict;d[1]0]`];d[1]1)}

/ returns the score based on user/algo provided scoring function
gs.fitpredict:{[fn;f;p;d]fn . xv.fitpredict[f;p;d]}
