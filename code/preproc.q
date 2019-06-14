// The purpose of this code is to act as a first pass manipulation of incoming data
// to the automated machine learning platform such that the user does not need to
// deal with the preprocessing side only input the appropriate table.

\d .aml

\l ml/ml.q
.ml.loadfile`:util/init.q

preproc:{[tb]
 t:i.symencode[tb;10];
 t:"f"$i.null_encode[t;med];
 .ml.infreplace[t]}

i.symencode:{
 sc:.ml.i.fndcols[x;"s"];				/ sc = symbol columns
 if[0<count sc;
  fc:where y<count each distinct each sc!flip[x]sc;	/ fc = cols to freq encode
  ohe:sc where not sc in fc;				/ ohe = one hot encoded columns
  r:.ml.onehot[.ml.freqencode[x;fc];ohe]];r}

i.null_encode:{[x;y]
        vals:l k:where 0<sum each l:null each flip x;
        nms:`$string[k],\:"_null";
        $[0=count k;x;flip y[x]^flip[x],nms!vals]}

