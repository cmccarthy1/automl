/ This is an example of a pipeline that could be implemented to complete the initial choice of algorithm

\d .aml

/* tb  = input table
/* tgt = target vector 
/* rc  = symbol(`class/reg)
/* typ = type of feature extraction being completed
/* p   = parameters (::) ~ default other changes user dependent
/* xv  = xval function (".ml.xval.kfshuff[5;1]")
/* scf = scoring function (".ml.xval.fitscore")
runexample:{[tb;tgt;typ;mdls;p]
 dict:i.updparam[tb;p;typ]; 
 tb:preproc[tb;tgt;typ;dict];
 tb:freshcreate[tb;dict];
 runmodels[dict`xv;flip value flip tb;tgt;mdls;dict`scf]
 }


/ Utils

i.updparam:{[x;p;typ]
 dict:$[typ=`fresh;
        {d:`aggcols`cols2use`params`xv`scf!(first cols x;1_cols x;.ml.fresh.params;.ml.xval.kfshuff[5;1];.ml.xval.fitscore);
         $[y~(::);d;99h=type y;$[min key[y]in key[d];d[key y]:value y;'`$"You can only pass appropriate keys to fresh"];
           '`$"You must pass identity `(::)` or dictionary with appropriate key/value pairs to function"];
         d}[x;p];
        typ=`normal;
	'`$"This will need to be added once the normal recipe is in place";
        typ=`tseries;
        '`$"This will need to be added once the time-series recipe is in place";
        '`$"Incorrect input type"]}

