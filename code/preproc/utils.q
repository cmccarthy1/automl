\d .aml

// Utilities for preproc.q

/  Automatic type checking
prep.i.autotype:{[x;typ;p]
  $[typ in `tseries`normal;
    [cls:.ml.i.fndcols[x;"sfihjbepmdznuvt"];
      tb:flip cls!x cls;
      prep.u.err_col[cols x;cls;typ]];
    typ=`fresh;
    [aprcls:flip (l:p[`aggcols]) _ flip x;
      cls:.ml.i.fndcols[aprcls;"sfiehjb"];
      tb:flip (l!x l,:()),cls!x cls;
      prep.u.err_col[cols x;cols tb;typ]];
    tb:(::)];
  tb}

/  Description of input table
/* x = table
prep.i.describe:{
  columns :`count`unique`mean`std`min`max`type;
  numcols :.ml.i.fndcols[x;"hijef"];
  timecols:.ml.i.fndcols[x;"pmdznuvt"];
  boolcols:.ml.i.fndcols[x;"b"];
  catcols :.ml.i.fndcols[x;"s"];
  textcols:.ml.i.fndcols[x;"c"];
  num  :prep.u.metafn[x;numcols ;(count;{count distinct x};avg;sdev;min;max;{`numeric})];
  symb :prep.u.metafn[x;catcols ;prep.u.non_numeric[{`categorical}]];
  times:prep.u.metafn[x;timecols;prep.u.non_numeric[{`time}]];
  bool :prep.u.metafn[x;boolcols;prep.u.non_numeric[{`boolean}]];
  flip columns!flip num,symb,times,bool
  }

/  Length checking
prep.i.lencheck:{[x;tgt;typ;p]
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

/  Null encoding
prep.i.nullencode:{[x;y]
  vals:l k:where 0<sum each l:null each flip x;
  nms:`$string[k],\:"_null";
  // 0 filling needed if median value also null (encoding maintained through added columns)
  // could use med where med <> 0n but this will skew distribution also (although less drastic)
  $[0=count k;x;flip 0^(y each flip x)^flip[x],nms!vals]}


/  Symbol encoding
/* tab   = input table
/* n   = number of distinct values in a column after which we symbol encode
/* b   = boolean flag indicating if table is to be returned (0) or encoding type returned (1)
/* d   = the parameter dictionary outlining the run setup
/* typ = how the encoding should work, if it's a dictionary which could be returned from b=1 then encode according to problem
/        type for that dictionary, otherwise use function to encode the full table or return the dictionary for later use
/. returns the table with appropriate encoding applied
prep.i.symencode:{[tab;n;b;d;typ]
  $[99h=type typ;
    r:$[`fresh~d`typ;
        $[all {not ` in x}each value typ;.ml.onehot[raze .ml.freqencode[;typ`freq]each flip each 0!d[`aggcols]xgroup tab;typ`ohe];
          ` in typ`freq;.ml.onehot[tab;typ`ohe];
          ` in typ`ohe;raze .ml.freqencode[;typ`freq]each flip each 0!d[`aggcols]xgroup tab;
          tab];
        `normal~d`typ;
        $[all {not ` in x}each value typ;.ml.onehot[.ml.freqencode[tab;typ`freq];typ`ohe];
          ` in typ`freq;.ml.onehot[tab;typ`ohe];
          ` in typ`ohe;raze .ml.freqencode[tab;typ`fc];
          tab];
        '`$"This form of encoding has yet to be implemented for specified column encodings"];
    [sc:.ml.i.fndcols[tab;"s"]except $[tp:`fresh~d`typ;acol:d`aggcols;`];
      if[0=count sc;r:$[b=1;`freq`ohe!``;tab]];
      if[0<count sc;
        fc:where n<count each distinct each sc!flip[tab]sc;
        ohe:sc where not sc in fc;
        r:$[b=1;`freq`ohe!(fc;ohe);tp;.ml.onehot[raze .ml.freqencode[;fc]each
          flip each 0!acol xgroup tab;ohe];
          .ml.onehot[.ml.freqencode[tab;fc];ohe]]];
      if[b=0;r:flip sc _ flip r]]];
  r}


// Utilities for feat_extract.q

/  Credibility score
prep.i.credibility:{[x;c;tgt]
  if[(::)~c;c:.ml.i.fndcols[x;"s"]];
  avgtot:avg tgt;
  counts:{(count each group x)x}each x c,:();
  avggroup:{(key[k]!avg each y@value k:group x)x}[;tgt]each x c,:();
  scores:{z*(x-y)}[avgtot]'[avggroup;counts];
  names:(`$string[c],\:"_credibility_estimate");
  x^flip names!scores}

/  perform +/-/*/% transformations of hij columns for unique linear combinations of such columns
prep.i.bulktransform:{[x;c]
  if[(::)~c;c:.ml.i.fndcols[x;"hij"]];
  n:raze(,'/)`$(raze each string c@:.ml.combs[count c;2]),\:/:("_multi";"_sum";"_div";"_sub");
  flip flip[x],n!(,/)(prd;sum;{first(%)x};{last deltas x})@/:\:x c}

/  perform a truncated single value decomposition on unique linear combinations of float columns
prep.i.truncsvd:{[x;c;d]
  if[(::)~c;c:.ml.i.fndcols[x;"f"]];
  c@:.ml.combs[count c,:();d];
  svd:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
  flip flip[x],(`$(raze each string c),\:"_trsvd")!{raze x[`:fit_transform][flip y]`}[svd]each x c}



// utils.q utilities
/* x = entire column list
/* y = sublist of columns we use
/* z = type of feature creation we are doing
prep.u.err_col:{[x;y;z]if[count[x]<>count y;
 -1 "\n Removed the following columns due to type restrictions for ",string z;
 0N!x where not x in y]}

prep.u.err_tgt:{
 -1 "\n Test set does not contain examples of each class. Removed MultiKeras from models";
 delete from x where model=`MultiKeras}

prep.u.metafn:{$[0<count y;z@\:/:flip(y)#x;()]}

prep.u.non_numeric:{(count;{count distinct x};{};{};{};{};x)}
