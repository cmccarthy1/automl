\d .aml

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

cli_dict:.Q.opt .z.x

cli_format:{[d]
  // The following options can be defined without a problem type being defined at present
  gen_opts:`seed`saveopt`hdl`sz`sigfeats;
  gen_vals:(`rand_val;2;0.2;0.2;`.aml.prep.freshsignificance);
  // The following option definitions are problem dependant
  custm:`tts`funcs;
  // check that some approptiate flags have been provided
  if[not any (custm,gen_opts)in key[d];:(::)];
  if[any custm in key[d];
    if[not[d[`type]in("fresh";"normal")]0;
      '"User has not provided appropriate information defining the problem type"];
    $["fresh"~d[`type]0;
        vals:(`.ml.fresh.params;`.ml.ttsnonshuff);
      "normal"~d[`type]0;
        vals:(`.aml.prep.i.default;`.ml.traintestsplit)
    ;'"type must be specified"]];
  (.Q.def[(gen_opts!gen_vals),cstm!vals]d)_`type;
 }
