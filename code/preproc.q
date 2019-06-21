// The purpose of this code is to act as the first pass manipulation of incoming data
// to the automated machine learning platform such that the user does not need to
// deal with the preprocessing side only input the appropriate table and target.


\d .aml


/* tb  = tabular data
/* tgt = target data
/* typ = type of feature extraction being performed
/* p   = is a set of parameters as a dictionary or :: ('default set')
preproc:{[tb;tgt;typ;p]
 if[`fresh=typ;p[`cols2drop]_flip tb];
 i.lencheck[tb;tgt;typ;p];
 t:i.symencode[tb;10];
 t:.ml.dropconstant[t];
 t:"f"$i.null_encode[t;med];
 $[`fresh=typ;
   (flip p[`cols2drop]#flip tb),'.ml.infreplace[t];
   .ml.infreplace[t]]}


/ Utils
i.lencheck:{[x;tgt;typ;p]
 if[typ~(::);typ:`normal];
 $[-11h=type typ;
  $[`fresh=typ;
    if[count[tgt]<>count distinct $[1=count p`aggcols;x[p`aggcols];(,'/)x p`aggcols];
       '`$"Target count must equal count of unique agg values for fresh"];
   typ in`tseries`normal;
    if[count[y]<>count x;
       '`$"Must have the same number of targets as values in table"];
   '`$"Input for typ must be a supported symbol or ::"];
   '`$"Input for typ must be a supported symbol or ::"]}
i.null_encode:{[x;y]
        vals:l k:where 0<sum each l:null each flip x;
        nms:`$string[k],\:"_null";
        $[0=count k;x;flip y[x]^flip[x],nms!vals]}
i.symencode:{
 sc:.ml.i.fndcols[x;"s"];				/ sc = symbol columns
 if[0=count sc;r:x];
 if[0<count sc;
  fc:where y<count each distinct each sc!flip[x]sc;	/ fc = cols to freq encode
  ohe:sc where not sc in fc;				/ ohe = one hot encoded columns
  r:.ml.onehot[.ml.freqencode[x;fc];ohe]];r}
