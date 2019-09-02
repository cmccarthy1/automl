/
.ml.ts.createfeatures{[t;prm]
 t:.ml.timesplit[t;(::)];  / freq/lexi/ohe?
 / calc lags
 / transform
 ts.feat.scale[t;f]  / have minmax as default - change in dict
 }
\

\l ml/ml.q
.ml.loadfile`:init.q

\d .ml


/ scaling fnc - choose between `.ml.minmaxscaler`.ml.stdscaler and log
autolog:{[x;c;t]
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 zc:c where{$[9=type x;0f in;0 in]x}each d:x c,:();
 skew:fresh.feat.skewness each d:x p:c except zc;
 c:p pos:where(t<skew)|skew<neg t;
 flip flip[x],c!(),log d pos}


/ need? --in toolkit already
ts.feat.freqencode:freqencode
ts.feat.lexiencode:lexiencode
ts.feat.onehot    :onehot


/ feature functions
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
ts.loadparams:{
 pp:{(raze value@)each(!).("S=;")0:x}each(!).("S*";"|")0:x;
 ts.params[([]f:key pp);`pvals]:value each value pp:inter[key pp;exec f from ts.params]#pp;
 ts.params[([]f:key pp);`pnames]:key each value pp;
 ts.params:update valid:pnum=count each pnames from ts.params where f in key pp;}

/ utils
i.combinedlag:{[x;c;l1;l2;f]
 if[count[l1]<>count l2;'`$"lists of lags to compare must have same length"];
 if[(::)~c;c:i.fndcols[x;"fijh"]];
 n:raze`$string[c,:()],\:/:"_",'"_"sv'("lag";string f),/:string flip(l1,:();l2,:());
 v:{[d;f;l1;l2]i.lagdict[f]. xprev'[;d]each(l1;l2)}[x c;f]'[l1;l2];
 max[l1,l2]_flip flip[x],n!raze v}
i.lagdict:`sum`sub`prod`ratio!(+;-;*;%)


\d .
.ml.ts.loadparams hsym`$.aml.path,"/code/timeseries/hyperparam.txt"
