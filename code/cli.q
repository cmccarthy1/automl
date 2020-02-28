\d .automl

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

// Dictionary of user input, users can pass in arguments for:
// s (slaves), p (port), seed, hld, sigfeats, sz, xv, gs, type, tts, funcs
cli.dict:first each .Q.opt .z.x

// Convert user input dictionary to correct format for p parameter to .automl.run
/* d = cli_dict output
/. r > returns default param dict updated with cmd line inputs
cli.format:{[d]
  // check correct keys have been passed in
  if[not all(kd:key d)in`type,key i.freshdefault[];
    '"incorrect options chosen"];
  // parameter types
  opts:(`prf`seed`hld`tts`sz`sigfeats;`xv`gs;enlist`scf;`aggcols`funcs);
  opts:`sgl`mlt`dct`cst!{x where x in y}[kd]each opts;
  // check parameters have correct types
  {[d;opt;k;f]
    f each d opt k
	}[d;opts]'[`sgl`mlt`dct;(cli.i.single_check;cli.i.multi_check;cli.i.dict_check)];
  // if type not specified, user cannot use aggcols (fresh) or funcs (problem specific)
  dict_list:$[not`type in kd;
      [-1"must specify type to pass in aggcols or funcs, removing from dictionary";
       {$[0<count x;![y;();0b;x];y]}[opts`cst]each(i.normaldefault[];d)];
    "normal"~typ:d`type;
      (i.normaldefault[];d);
    "fresh"~typ;
      (i.freshdefault[];d);
    '"incorrect input for type"];
  // correct input types
  d:.Q.def . dict_list;
  // convert dict and multi parameters to correct format 
  @[;opts`mlt;cli.i.multi_prep]@[;opts`dct;cli.i.dict_prep]d _`type
 }

cli.i.single_check:{if[0=count x;:(::)];if[","in x;'"attempting to pass a list to a single input option"]}
cli.i.multi_check:{if[0=count x;:(::)];if[2<>count","vs x;'"input must have have 2 elements"]}
cli.i.dict_check:{
  // if class/reg not in keys or if given format other than (k,v)/(k,v,k,v) error
  if[(not all(x[0 2]except enlist"")in("class";"reg"))|not(count x:","vs x)in 2 4;
    '"scf must contain functions for class and/or reg"]}
cli.i.dict_prep:{
  if[0=count x;:x];
  $[2=n:count x:","vs string x;
      (i.normaldefault[]`scf),(!).`$(0;1)_x;
    4=n;
      (!). flip`$(0;2)_x;
    '"scf in wrong format"]} 
cli.i.multi_prep:{@[;0;{`$x}]@[;1;get]","vs string x}