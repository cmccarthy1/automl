// The purpose of this code is to act as the first pass manipulation of incoming data
// to the automated machine learning platform such that the user does not need to
// deal with the preprocessing side only input the appropriate table and target.


\d .aml


/* tb  = tabular data
/* tgt = target data
/* typ = type of feature extraction being performed
/* p   = is a set of parameters as a dictionary or :: ('default set')
preproc:{[tb;tgt;typ;p]
 if[`fresh=typ;p[`cols2drop]_flip tb]; / t: ?
 i.lencheck[tb;tgt;typ;p];
 t:i.symencode[tb;10];
 t:.ml.dropconstant[t];
 t:"f"$i.null_encode[t;med];
 $[`fresh=typ;
   (flip p[`cols2drop]#flip tb),'.ml.infreplace[t];
   .ml.infreplace[t]]}
