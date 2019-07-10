\d .ml
np:.p.import`numpy

/ grid search w/ random seed where applicable
gs.seed:{[x;y;d;m]
 b:m[`lib]~`sklearn;
 s:$[a:m[`seed]~`seed;$[b;enlist[`random_state]!enlist d`seed;d`seed];::];
 $[a&b;first value get[` sv`.ml.gs,d`xv][d`k;1;np[`:array][x]`:T;y;d[`prf]m`minit;s;0];
   get[` sv`.ml.xv,d`xv][d`k;1;x;y;d[`prf][m`minit;s]]]}

 
/ returns (ypred;ytrue) for each k
xv.fitpredict:{[f;p;d]($[-7h~type p;f[d;p];@[.[f[][p]`:fit;d 0]`:predict;d[1]0]`];d[1]1)}


// This should be removed before any release
.aml.loadfile`:code/data/sampledata.q
