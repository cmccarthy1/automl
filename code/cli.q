\d .aml

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

dict:.Q.opt .z.x

cli_format:{[d]
  if[not[d[`type]in("fresh";"normal")]0;'"User has not provided information on the problem type"];
  $["fresh"~d[`type]0;
    [opts:`funcs`seed`saveopt`hld`sz`tts`sigfeats;
      vals:(`.ml.fresh.params;42;2;0.2;0.2;`.ml.ttsnonshuff;`.aml.prep.freshsignificance)];
    "normal"~d[`type]0;
    [opts:`funcs`seed`saveopt`hld`sz`tts`sigfeats;
      vals:(`.aml.prep.i.default;42;2;0.2;0.2;`.ml.traintestsplit;`.aml.prep.freshsignificance)]
    ;'"nah"];
  (.Q.def[opts!vals]d)_`type
 }
