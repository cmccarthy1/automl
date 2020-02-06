\d .automl

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

// Dictionary of user input, users can pass in arguments for:
// s (slaves), p (port), seed, hld, sigfeats, sz, xv, gs, type, tts, funcs
cli_dict:first each .Q.opt .z.x

// Original -- will create dict regardless of type
/* d = cli_dict output
/. r > returns default param dict updated with cmd line inputs
cli_format:{[d]
  // The following options can be defined without a problem type being defined at present
  single_opts:`seed`saveopt`hld`sz`sigfeats;
  multi_opts :`xv`gs;
  single_vals:(`rand_val;2;0.2;0.2;`.automl.prep.freshsignificance);
  multi_vals :((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5));
  nms :single_opts,multi_opts;
  vals:single_vals,multi_vals;
  // The following option definitions are problem dependant
  multi_opts:`funcs;
  custm:`tts,multi_opts;
  // check that some approptiate flags have been provided
  if[not any(custm,nms)in key d;:(::)];
  custm_dict:$[any custm in key d;
    [if[not(typ:first d`type)in("fresh";"normal");
       '"User has not provided appropriate information defining the problem type"];
     $["fresh"~typ;
         custm!(`.ml.fresh.params;`.ml.ttsnonshuff);
       "normal"~typ;
         custm!(`.automl.prep.i.default;`.ml.traintestsplit);
       '"type must be specified"]];
    ()!()];
  (.Q.def[(nms!vals),custm_dict]d)_`type
 }

single_check:{if[","in x;'"attempting to pass a list to a single input option"]}
multi_check :{if[2<>count","vs x;'"input must have have 2 elements"]}
dict_check:{
  // if class/reg not in keys or if given format other than (k,v)/(k,v,k,v) error
  if[(not all(x[0 2]except enlist"")in("class";"reg"))|not(count x:","vs x)in 2 4;
    '"scf must contain functions for class and/or reg"]}
dict_prep:{
  $[2=n:count x:","vs x;
      enlist[first x]!enlist last x;
    4=n;
      {x!y}. flip`$(0;2)_x;
    '"scf in wrong format"]} 

// New version using default functions

// Convert user input dictionary to correct format for p parameter to .automl.run
/* d = cli_dict output
/. r > returns default param dict updated with cmd line inputs
cli_format_2:{[d]
  // check correct keys have been passed in
  if[not all(kd:key d)in`type,key i.freshdefault[];
    '"incorrect options chosen"];
  // parameter types
  sgl_opts:`prf`seed`hld`tts`sz`sigfeats;
  mlt_opts:`xv`gs;
  dct_opts:enlist`scf;
  cst_opts:`aggcols`funcs;
  // check parameters have correct types
  single_check each d sgl_opts;
  multi_check each d mlt_opts;
  dict_check each d dct_opts;
  // update parameters with dictionary inputs
  d:@[d;dct_opts;dict_prep];
  // if type not specified, user cannot use aggcols (fresh) or funcs (problem specific)
  dict_list:$[not`type in kd;
      [-1"must specify type to pass in aggcols or funcs, removing from dictionary";
       {![y;();0b;x]}[cst_opts]each(i.normaldefault[];d)];
    "normal"~typ:d`type;
      (i.normaldefault[];d);
    "fresh"~typ;
      (i.freshdefault[];d);
    '"incorrect input for type"];
  // convert to correct format
  @[;mlt_opts;{@[;0;{`$x}]@[;1;get]","vs string x}](.Q.def . dict_list)_`type
 }



