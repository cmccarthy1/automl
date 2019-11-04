\d .aml

savemeta:{
  `:metadata set x;
  system"mkdir",$[.z.o like "w*";" ";" -p "],folder_name:path,"/",po:"Outputs/",string[y`stdate],"/Run_",string[y`sttime],"/Config/";
  $[first[string .z.o]in "lm";
    system"mv metadata ",folder_name;
    system"move metadata ",folder_name]
  -1"Saving down model parameters to ",po;}

getmeta:{
  file_path:`$":",x;
  $[()~key file_path;'`$"metadata file doesn't exist";get file_path]
  }
