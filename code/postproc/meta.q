\d .aml

// Note to use the below function on windows 'mkdir' will need to available at command line.

// Save down the metadata dictionary as a binary file which can be retrieved by a user or
// is to be used in running of the models on new data
/* d  = dictionary of parameters to be saved
/* dt = dictionary with the date and time that a run was started, required for naming of save path 
/. r  > the location that the metadata was saved to
savemeta:{[d;dt]
  `:metadata set d;
  system "mkdir",$[.z.o like "w*";" ";" -p "],fname:path,"/",
    // Save path, ssr required as mac does not support ':' as input in file paths.
    spath:ssr["Outputs/",string[dt`stdate],"/Run_",string[dt`sttime],"/Config/";":";"."];
  // move the metadata information to the appropriate location based on OS
  $[first[string .z.o]in "lm";
    system"mv metadata ",fname;
    system"move metadata ",fname];
  -1"Saving down model parameters to ",spath;}

// Retrieve the metadata information from a specified path
/* fp = full file path denoting the location of the metadata to be retrieved
/. r  > returns the parameter dictionary
getmeta:{[fp]
  fp:`$":",fp;
  $[()~key fp;'`$"metadata file doesn't exist";get fp]
  }
