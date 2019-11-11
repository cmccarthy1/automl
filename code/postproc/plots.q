\d .aml

/* x = output of cumulative_gains_curve
/* y = `lift or `gain
/* z = dictionary containing date and time of run start `sttime`stdate! ...
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
 system"mkdir -p ",folder_name:path,"/Outputs/",string[z`stdate],"/Images/Run_",string[z`sttime];
 plt[`:savefig][folder_name,"/Lift_Gain_Curve.png"];
 plt[`:show][];}

i.impactplot:{[r;m;z]
 plt[`:figure][`figsize pykw 20 20];
 sub:plt[`:subplots][];
 fig:sub[@;0];ax:sub[@;1];
 b:20<cr:count value r;
 n:$[b;til 20;til cr];
 v:$[b;20#;cr#]value r;
 k:$[b;20#;cr#]key r;
 ax[`:barh][n;v;`align pykw`center];
 ax[`:set_yticks]n;
 ax[`:set_yticklabels]k;
 ax[`:set_title]"Feature Impact: ",string m;
 ax[`:set_ylabel]"Columns";
 ax[`:set_xlabel]"Relative feature impact";
 system"mkdir -p ",folder_name:path,"/Outputs/",string[z`stdate],"/Run_",string[z`sttime],"/Images";
 plt[`:savefig][folder_name,"/",sv["_";string(`Impact_Plot;m)],".png";`bbox_inches pykw"tight"];}

// should work but needs implementation decisions prior to integration
//  note: need to output prediction probabilities for this
i.roccurve:{
 rocdict:`frp`tpr!.ml.roc[y;x];
 rocAuc:.ml.rocaucscore[rocdict`frp; rocdict`tpr];lw:2;
 plt[`:plot][rocdict`frp;rocdict`tpr;`color pykw "darkorange";`lw pykw lw;`label pykw "ROC curve (Area = ",string[rocAuc]," )"];
 plt[`:plot][0 1;0 1;`color pykw "navy";`lw pykw lw;`linestyle pykw "--"];
 plt[`:xlim][0 1];
 plt[`:ylim][0 1.05];
 plt[`:xlabel]["False Positive Rate"];
 plt[`:ylabel]["True Positive Rate"];
 plt[`:title]["Reciever operating characteristic example"];
 plt[`:legend][`loc pykw "upper left"];
 system"mkdir -p ",folder_name:path,"/Outputs/",string[z`stdate],"/Images/Run_",string[z`sttime];
 plt[`:savefig][folder_name,"/ROC_Curve.png"];
 plt[`:show][];}
