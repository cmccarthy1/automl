\d .aml

// For the following code the parameter naming convention holds
// defined here is applied to avoid repetition throughout the file
/* t   = input table
/* p   = parameter dictionary passed as default or modified by user
/* tgt = target data

// Create features using the FRESH algorithm
/. r > table of fresh created features and the time taken to complete extraction as a mixed list
prep.freshcreate:{[t;p]
  agg:p`aggcols;prm:get p`funcs;
  // Feature extraction should be performed on all columns that are non aggregate
  cols2use:k where not (k:cols[t])in agg;
  fe_start:.z.T;
  t:"f"$prep.i.nullencode[value .ml.fresh.createfeatures[t;agg;cols2use;prm];med];
  fe_end:.z.T-fe_start;
  t:.ml.infreplace t;
  (0^.ml.dropconstant t;fe_end)}


// In all cases feature significance currently returns the top 25% of important features
// if no features are deemed important it currently continues with all available features
// this is temporary approptiate action needs to be decided on.
/. r > table with only the significant features available or all features as above
prep.freshsignificance:{[t;tgt]
  $[0<>count k:.ml.fresh.significantfeatures[t;tgt;.ml.fresh.percentile 0.25];
    k;[-1 prep.i.freshsigerr;cols t]]}


// Create features for 'normal problems' -> one target for each row no time dependency
// or fresh like structure
/. r > table with features created in accordance with the normal feature creation procedure 
prep.normalcreate:{[t;p]
  fe_start:.z.T;
  // Time columns are extracted such that constituent parts can be used 
  // but are not transformed according to remaining procedures
  tcols:.ml.i.fndcols[t;"dmntvupz"];
  tb:(cols[t]except tcols)#t;
  tb:prep.i.applyfn/[tb;p`funcs];
  tb:.ml.dropconstant prep.i.nullencode[.ml.infreplace tb;med];
  // Apply the transform of time specific columns as appropriate
  if[0<count tcols;tb^:.ml.timesplit[tcols#t;::]];
  fe_end:.z.T-fe_start;
  (tb;fe_end)}

// Apply word2vec on string data for nlp problems
/. r > table with features created in accordance with the nlp feature creation procedure
prep.nlpcreate:{[t;p]
  fe_start:.z.T;
  // Find string columns to apply spacy word2vec
  // If there is multiple string columns, join them together to be passed to the models later
  strcol:.ml.i.fndcols[t;"C"];
  sents:$[1<count strcol;raze each flip t[strcol];raze t[strcol]];
  // Load in spacy and word2vec modules
  system["export PYTHONHASHSEED=0"];
  word2vec:.p.import[`gensim.models]`:word2vec;
  sp:.p.import[`spacy];
  dr:.p.import[`builtins][`:dir];
  pos:dr[sp[`:parts_of_speech]]`;
  nlpmdl:sp[`:load]["en_core_web_sm"];
  // Add NER tagging
  ents:nlpmdl each sents;
  ners:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW`LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  tner:prep.i.percdict[;ners]each{group`${(.p.wrap x)[`:label_]`}each x[`:ents]`}each ents;
  // Apply parsing using spacy module
  corpus:.nlp.newParser[`en;`isStop`tokens`uniPOS]sents;
  // Add uniPOS tagging
  unipos:`$pos[til(first where 0<count each pos ss\:"__")];
  tpos:prep.i.percdict[;unipos]each group each corpus`uniPOS;
  // Apply sentiment analysis
  sentt:.nlp.sentiment each sents;
  // Apply vectorisation using word2vec
  tokens:string corpus[`tokens];
  size:300&count raze distinct tokens;window:$[30<tk:avg count each tokens;10;10<tk;5;2];
  model:word2vec[`:Word2Vec][tokens;`size pykw size;`window pykw window;`seed pykw p[`seed];`workers pykw 1];
  sentvec:{x[y;z]}[tokens]'[til count w2vind;w2vind:where each tokens in model[`:wv.index2word]`];
  w2vtb:flip(`$"col",/:string til size)!flip avg each{x[`:wv.__getitem__][y]`}[model]each sentvec;
  // Join all tables
  tb:tpos,'sentt,'w2vtb,'tner;
  tb[`isStop]:{sum[x]%count x}each corpus`isStop;
  tb:.ml.dropconstant prep.i.nullencode[.ml.infreplace tb;med];
  if[0<count cols[t] except strcol;tb:tb,'(prep.normalcreate[(strcol)_t;p])[0]];
  if[2~p`saveopt;model[`:save][i.ssrwin[path,"/",p[`spath],"/models/w2v.model"]]];
  fe_end:.z.T-fe_start;
  (tb;fe_end)}
