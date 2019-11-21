\d .aml
separ:{"_" vs string x}

featlst:exec f from feattab:.ml.fresh.params

colextract:{
 fncparams:cname except coln:y where y in cname:`$separ[x];
 fnc:first fncparams;
 $[0<feattab[fnc]`pnum;
  (paramv[pvloc]:enlist each"F"$ssr[;"o";"."]each pv[pvloc];
  paramv:enlist each"J"$pv;
  pvloc:where sum("o";"w")in/:\:pv:string params ploc+1;
  ploc:where params in feattab[fnc]`pnames;
  params:1_fncparams);(paramn:();paramv:())];
  `coln`f`pnum`pnames`pvals`valid!(coln;fnc;count[ploc];params ploc;paramv;1b)
 }


