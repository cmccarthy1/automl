\d .automl

post.save_report:{[report_param;spaths;ptype;dtdict]
  -1 i.runout[`save],i.ssrsv[spaths[1]`report];
  // Attempt to default to latex generation, if not installed or if generation fails use reportlab
  $[0~checkimport[2];
    // error trap generation of latex models
    @[{latexgen . x};
      (report_param;dtdict;spaths[0]`report;ptype);
      // Highlight failure and run default report generation
      {[params;err] -1"The following error occurred when attempting to run latex report generation";-1 err,"\n";
        post.report . params;}[(report_param;dtdict;spaths[0]`report;ptype)]];
    post.report[report_param;dtdict;spaths[0]`report;ptype]]
  }

post.save_info:{[mdls;dict;mdl_name;best_mdl;spaths;dtdict]
  pylib:?[mdls;enlist(=;`model;enlist mdl_name);();`lib]0;
  mtyp :?[mdls;enlist(=;`model;enlist mdl_name);();`typ]0;
  exmeta:`pylib`mtyp!(pylib;mtyp);
  i.savemdl[mdl_name;best_mdl;mdls;spaths];
  i.savemeta[dict,exmeta;dtdict;spaths];
  }
