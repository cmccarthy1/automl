\d .aml

/* x = output of cumulative_gains_curve
/* y = `lift or `gain
i.gainliftplt:{
 c1:x 0;c2:x 1;
 pcnt_lift:1_c2`pcnt;
 pcnt_gain:c2`pcnt;
 gain_lift:`gl1`gl2!{(1_y`gain)%'x}[pcnt_lift]each(c1;c2);
 gain_gain:`gg1`gg2!{x`gain}each(c1;c2);
 plt[`:figure][1;`figsize pykw 10 10];
 plt[`:subplot][211];
 plt[`:plot][pcnt_lift;gain_lift`gl1;`lw pykw 3;`label pykw"class ",string c1`pc];
 plt[`:plot][pcnt_lift;gain_lift`gl2;`lw pykw 3;`label pykw"class ",string c2`pc];
 plt[`:plot][0 1;1 1;"k--";`lw pykw 2;`label pykw"baseline"];
 plt[`:legend][`loc pykw "upper right"];
 plt[`:title]["Lift-Gain charts";`fontsize pykw 20];
 plt[`:ylabel]["Lift";`fontsize pykw 18];
 plt[`:subplot][212];
 plt[`:plot][pcnt_gain;gain_gain`gg1;`lw pykw 3;`label pykw"class ",string c1`pc];
 plt[`:plot][pcnt_gain;gain_gain`gg2;`lw pykw 3;`label pykw"class ",string c2`pc];
 plt[`:plot][0 1;1 1;"k--";`lw pykw 2;`label pykw"baseline"];
 plt[`:legend][`loc pykw "lower right"];
 plt[`:xlabel]["% of sample";`fontsize pykw 18];
 plt[`:ylabel]["Gain";`fontsize pykw 18];
 system"mkdir -p ",folder_name:path,"/images/img_",string[.z.D];
 plt[`:savefig][folder_name,"/",sv["_";string(`Lift_Gain;.z.T)],".png"];
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
 system"mkdir -p ",folder_name:path,"/images/img_",string[.z.D];
 plt[`:savefig][folder_name,"/",sv["_";string(m;.z.T)],".png";`bbox_inches pykw"tight"];}
