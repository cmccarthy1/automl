// This contains the utility functions used within the other scripts.
// This is mainly for code expansion in the future.


\d .aml


/ preproc.q utilities

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
 sc:.ml.i.fndcols[x;"s"];                               / sc = symbol columns
 if[0=count sc;r:x];
 if[0<count sc;
  fc:where y<count each distinct each sc!flip[x]sc;     / fc = cols to freq encode
  ohe:sc where not sc in fc;                            / ohe = one hot encoded columns
  r:.ml.onehot[.ml.freqencode[x;fc];ohe]];r}


/ run.q utilities

i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
  {d:`aggcols`cols2use`params`xv`prf`scf`seed!
     (first cols x;1_cols x;
      .ml.fresh.params;`kfsplit;
      .ml.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);42);
   $[y~(::);d;
     99h=type y;
     $[min key[y]in key[d];
       d[key y]:value y;
       '`$"You can only pass appropriate keys to fresh"];
     '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
   d}[x;p];
  typ=`normal;
   '`$"This will need to be added once the normal recipe is in place";
  typ=`tseries;
   '`$"This will need to be added once the time-series recipe is in place";
  '`$"Incorrect input type"]}


/ distrib.q utilities
i.files:`class`reg`score!("classmodels.txt";"regmodels.txt";"scoring.txt")
i.mdlfunc:{$[`keras~x;get` sv``aml,y;{[x;y;z].p.import[x]y}[` sv x,y;hsym z]]}
i.txtparse:{{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,y,i.files x}
