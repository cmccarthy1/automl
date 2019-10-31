// The purpose of this code is to act as the first pass manipulation of incoming data
// to the automated machine learning platform such that the user does not need to
// deal with the preprocessing side only input the appropriate table and target.

\d .aml


/* tb  = tabular data
/* tgt = target data
/* typ = type of feature extraction being performed
/* p   = is a set of parameters as a dictionary or :: ('default set')
preproc:{[tb;tgt;typ;p]
 i.lencheck[tb;tgt;typ;p];
 tb:i.symencode[tb;10;0;p];
 $[`fresh=typ;[sep_data:(p[`aggcols],())#flip tb;t:flip (cols[tb]except p[`aggcols])#flip tb];t:tb];
 show i.describe t;
 t:.ml.dropconstant t;
 t:i.null_encode[t;med];
 $[`fresh=typ;flip sep_data,;flip]flip .ml.infreplace t
 }
