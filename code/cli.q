\d .aml

// The purpose of this script is to provide the initial stages of a command line interface
// for the automated machine learning platform

dict:.Q.opt .z.x

cli_format:{[d]
  if[not[d[`type]in("fresh";"normal")]0;'"User has not provided information on the problem type"];
  $["fresh"~d[`type]0;
    [opts:`seed`saveopt;vals:(`rand_val;2);
      .Q.def[opts!vals]d]_`type;
    '"nah"]
 }
