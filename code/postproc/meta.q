\d .aml

savemeta:{
  `:metadata set x;
  system"mkdir -p ",folder_name:path,"/Outputs/",string[y`stdate],"/Run_",string[y`sttime],"/Config";
  $[first[string .z.o]in "lm";
    system"mv metadata ",folder_name;
    system"move metadata ",folder_name]}

getmeta:{
  file_path:`$":",path,"/Outputs/",x;
  $[()~key file_path;'`$"metadata file doesn't exist";get file_path]
  }
