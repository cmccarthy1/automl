\d .aml

// Length checking
i.lencheck:{[x;tgt;typ;p]
  if[typ~(::);typ:`normal];
  $[-11h=type typ;
    $[`fresh=typ;
      if[count[tgt]<>count distinct $[1=count p`aggcols;x[p`aggcols];(,'/)x p`aggcols];
         '`$"Target count must equal count of unique agg values for fresh"];
      typ in`tseries`normal;
      if[count[tgt]<>count x;
         '`$"Must have the same number of targets as values in table"];
    '`$"Input for typ must be a supported symbol or ::"];
    '`$"Input for typ must be a supported symbol or ::"]}

// Null encoding
i.null_encode:{[x;y]
  vals:l k:where 0<sum each l:null each flip x;
  nms:`$string[k],\:"_null";
  $[0=count k;x;flip y[x]^flip[x],nms!vals]}

// Symbol encoding
i.symencode:{
  sc:.ml.i.fndcols[x;"s"];                               / sc = symbol columns
  if[0=count sc;r:x];
  if[0<count sc;
   fc:where y<count each distinct each sc!flip[x]sc;     / fc = cols to freq encode
   ohe:sc where not sc in fc;                            / ohe = one hot encoded columns
   r:.ml.onehot[.ml.freqencode[x;fc];ohe]];
  r}

// Automatic type checking
i.autotype:{[x;typ;p]
  $[typ in `tseries`normal;
    [cls:.ml.i.fndcols[x;"sfihjbepmdznuvt"];
      tb:flip cls!x cls;
      i.err_col[cols x;cls;typ]];
    typ=`fresh;
    [aprcls:flip (l:p[`aggcols]) _ flip x;
      cls:.ml.i.fndcols[aprcls;"sfiehjb"];
      tb:flip (l!x l,:()),cls!x cls;
      i.err_col[cols x;cols tb;typ]];
    tb:(::)];
  tb}

// Credibility score
i.credibility:{[x;c;tgt]
  if[(::)~c;c:.ml.i.fndcols[x;"s"]];
  avgtot:avg tgt;
  counts:{(count each group x)x}each x c,:();
  avggroup:{(key[k]!avg each y@value k:group x)x}[;tgt]each x c,:();
  scores:{z*(x-y)}[avgtot]'[avggroup;counts];
  names:(`$string[c],\:"_credibility_estimate");
  x^flip names!scores}


// utils.q utilities
/* x = entire column list
/* y = sublist of columns we use
/* z = type of feature creation we are doing
i.err_col:{[x;y;z]if[count[x]<>count y;
 -1 "\n Removed the following columns due to type restrictions for ",string z;
 0N!x where not x in y]}

i.err_tgt:{
 -1 "\n Test set does not contain examples of each class. Removed MultiKeras from models";
 delete from x where model=`MultiKeras}
 
// Automl version of the describe function from the toolkit
/* x =
describe:{
 columns :`count`unique`mean`std`min`max`type;
 numcols :.ml.i.fndcols[x;"hijef"];
 timecols:.ml.i.fndcols[x;"pmdznuvt"];
 boolcols:.ml.i.fndcols[x;"b"];
 catcols :.ml.i.fndcols[x;"s"];
 textcols:.ml.i.fndcols[x;"c"];
 num  :i.metafn[x;numcols ;(count;{count distinct x};avg;sdev;min;max;{`numeric})];
 symb :i.metafn[x;catcols ;i.non_numeric[{`categorical}]];
 times:i.metafn[x;timecols;i.non_numeric[{`time}]];
 bool :i.metafn[x;boolcols;i.non_numeric[{`boolean}]];
 flip columns!flip num,symb,times,bool
 }
i.metafn:{$[0<count y;z@\:/:flip(y)#x;()]}
i.non_numeric:{(count;{count distinct x};{};{};{};{};x)}
