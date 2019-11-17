// The purpose of this file is to act as a placer for functions which may be moved into the
// machine learning toolkit or which overwrite the present behaviour of functions in the
// toolkit

\d .ml

infreplace:{
 $[98=t:type x;
   [m:type each dt:k!x k:.ml.i.fndcols[x;"hijefpnuv"];flip flip[x]^i.infrep'[dt;m]];
   0=t;
   [m:type each dt:x r:where all each string[type each x]in key i.inftyp;(x til[count x]except r),i.infrep'[dt;m]];
   98=type kx:key x;
   [m:type each dt:k!x k:.ml.i.fndcols[x:value x;"hijefpnuv"];cols[kx]xkey flip flip[kx],flip[x]^i.infrep'[dt;m]];
   [m:type each dt:k!x k:.ml.i.fndcols[x:flip x;"hijefpnuv"];flip[x]^i.infrep'[dt;m]]]}

// Encode the target data to be from
labelencode:{(asc distinct x)?x}


// Utilities for functions to be added to the toolkit
i.infrep:{
 t:i.inftyp[]first string y;
 {[n;x;y;z]@[x;i;:;z@[x;i:where x=y;:;n]]}[t 0]/[x;t 1 2;(min;max)]}
i.inftyp:{
  typ:("5";"8";"9";"6";"7";"12";"16";"17";"18");
  rep:(0N -32767 32767;0N -0w 0w;0n -0w 0w),6#enlist 0N -0W 0W;
  typ!rep}
