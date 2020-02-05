\d .aml

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

cli_dict:.Q.opt .z.x

cli_format:{[d]
  // The following options can be defined without a problem type being defined at present
  gen_single_opts:`seed`saveopt`hdl`sz`sigfeats;
  gen_multi_opts:`xv`gs;
  gen_single_vals:(`rand_val;2;0.2;0.2;`.aml.prep.freshsignificance);
  gen_multi_vals:((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5));
  gen_nms:gen_single_opts,gen_multi_opts;
  gen_vals:gen_single_vals,gen_multi_vals;
  // The following option definitions are problem dependant
  multi_opts:`funcs;
  custm:`tts,multi_opts;
  // check that some approptiate flags have been provided
  if[not any (custm,gen_nms)in key[d];:(::)];
  custm_dict:$[any custm in key[d];
    [if[not[d[`type]in("fresh";"normal")]0;
      '"User has not provided appropriate information defining the problem type"];
    $["fresh"~d[`type]0;
        custm!(`.ml.fresh.params;`.ml.ttsnonshuff);
      "normal"~d[`type]0;
        custm!(`.aml.prep.i.default;`.ml.traintestsplit)
    ;'"type must be specified"]];()!()];
  (.Q.def[(gen_nms!gen_vals),custm_dict]d)_`type
 }

single_check:{if["," in x;'"attempting to pass a list instead to single input option"]}
xvgs_check:{if[2<>count sp:mul_split[x];'"input must have have 2 elements"]}
mul_split:{vs[",";x]}
