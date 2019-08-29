plt:.p.import`matplotlib.pyplot

\d .aml

/* x = output of cumulative_gains_curve
/* y = `lift or `gain
i.gainliftplt:{
 c1:x 0;c2:x 1;
 pcnt:$[b:`lift~y;1_;]c2`pcnt;
 gain:`g1`g2!{$[x;(1_z`gain)%'y;z`gain]}[b;pcnt]each(c1;c2);
 sub:plt[`:subplots][];
 fig:sub[@;0];ax:sub[@;1];
 ax[`:set_title]string[y]," chart";
 ax[`:plot][pcnt;gain`g1;`lw pykw 3;`label pykw"class ",string c1`pc];
 ax[`:plot][pcnt;gain`g2;`lw pykw 3;`label pykw"class ",string c2`pc];
 ax[`:plot][0 1;1 1;"k--";`lw pykw 2;`label pykw"baseline"];
 ax[`:set_xlabel]"% of sample";
 ax[`:set_ylabel]string y;
 ax[`:grid]"on";
 ax[`:legend][`loc pykw"lower right"];
 plt[`:show][];}

i.impactplot:{[r;m]
 plt[`:figure][`figsize pykw 20 20];
 sub:plt[`:subplots][];
 fig:sub[@;0];ax:sub[@;1];
 ax[`:barh][n:til 20;20#value r;`align pykw`center];
 ax[`:set_yticks][n];
 ax[`:set_yticklabels]20#key r;
 ax[`:set_title]"Feature Impact: ",string m;
 ax[`:set_ylabel]"Columns";
 ax[`:set_xlabel]"Relative feature impact";
 plt[`:savefig][sv["_";string(m;.z.Z)],".png";`bbox_inches pykw"tight"];}