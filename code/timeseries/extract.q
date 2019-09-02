/
.ml.ts.createfeatures{[t;prm]
 t:.ml.timesplit[t;(::)];  / freq/lexi/ohe?
 / calc lags
 / transform
 }
\

\l ml/ml.q
.ml.loadfile`:init.q

\d .ml

/ need? --in toolkit already
ts.feat.freqencode:{[x;c]freqencode[x;c]}
ts.feat.lexiencode:{[x;c]lexiencode[x;c]}
ts.feat.onehot:{[x;c]onehot[x;c]}

/ feature functions
/ To drop OG columns below change `flip[x]` to `(c _ flip x)`
ts.feat.autolog:{[x;c;t]
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 zc:c where{$[9=type x;0f in;0 in]x}each d:x c,:();
 skew:fresh.feat.skewness each d:x p:c except zc;
 c:p pos:where(t<skew)|skew<neg t;
 flip flip[x],(`$string[c,()],\:"_log")!(),log d pos}
ts.feat.bulktransform:{[x;c]
 if[(::)~c;c:i.fndcols[x;"hij"]];
 n:raze(,'/)`$(raze each string c@:combs[count c;2]),\:/:("_multi";"_sum";"_div";"_sub");
 flip flip[x],n!(,/)(prd;sum;{first(%)x};{last deltas x})@/:\:x c}
ts.feat.countencode:{[x;c]
 if[(::)~c;c:i.fndcols[x;"s"]];
 flip flip[x],(`$string[c],\:"_count")!{(count each group x)x}each x c,:()}
ts.feat.featurelag:{[x;c;l]
 if[(::)~c;c:i.fndcols[x;"f"]];
 v:raze{y xprev'x}[x c,:()]each l,:();
 max[l]_flip flip[x],(raze`$string[c],\:/:"_lag_",/:string l)!v}
ts.feat.fnscaling:{[x;c;b]
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 flip flip[x],$[b;minmaxscaler;stdscaler]c!x c,:()}
ts.feat.movingavg:{[x;c;l]
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 v:raze{y mavg'x}[x c,:()]each l,:();
 (max[l]-1)_flip flip[x],(raze`$string[c],\:/:"_mavg_",/:string l)!v}
ts.feat.prodlag :{[x;c;l1;l2]i.combinedlag[x;c;l1;l2;`prod ]}
ts.feat.ratiolag:{[x;c;l1;l2]i.combinedlag[x;c;l1;l2;`ratio]}
ts.feat.sublag  :{[x;c;l1;l2]i.combinedlag[x;c;l1;l2;`sub  ]}
ts.feat.sumlag  :{[x;c;l1;l2]i.combinedlag[x;c;l1;l2;`sum  ]}
ts.feat.truncsvd:{[x;c;d]
 if[(::)~c;c:i.fndcols[x;"f"]];
 c@:.ml.combs[count c,:();d];
 svd:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
 flip flip[x],(`$(raze each string c),\:"_trsvd")!{x[`:fit_transform][flip y]`}[svd]each x c}

ts.params:update pnum:{count 1_get[ts.feat x]1}each f,pnames:count[i]#(),pvals:count[i]#()from([]f:1_key ts.feat)
ts.params:1!`pnum xasc update valid:pnum=count each pnames from ts.params

/ utils
i.combinedlag:{[x;c;l1;l2;f]
 if[count[l1]<>count l2;'`$"lists of lags to compare must have same length"];
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 n:raze`$string[c,:()],\:/:"_",'"_"sv'("lag";string f),/:string flip(l1,:();l2,:());
 v:{[d;f;l1;l2]i.lagdict[f]. xprev'[;d]each(l1;l2)}[x c;f]'[l1;l2];
 max[l1,l2]_flip flip[x],n!raze v}
i.lagdict:`sum`sub`prod`ratio!(+;-;*;%)
