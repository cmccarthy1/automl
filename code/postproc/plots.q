\d .aml

//  calculate impact of each feature and save plot of top 20
/* bm   = best model name as a symbol
/* mdl  = best model as a fitted embedPy object
/* data = list containing test features and values
/* cnm  = column names for all columns being shuffled    
/* scf  = scoring function used to determine the best model
/* ord  = ordering needed to determine the best model
/* dt   = dictionary denoting the start time and date of a run
/* fp   = file path dictionaries with the full save path and subsection for printing
post.featureimpact:{[bm;mdl;data;cnm;scf;ord;dt;fp]
  r:post.i.predshuff[mdl;data 0;data 1;scf]each til count cnm;
  im:post.i.impact[r;cnm;ord];
  post.i.impactplot[im;bm;dt;fp];
  -1"\nFeature impact calculated for features associated with ",string[bm]," model";
  -1 "Plots saved in ",fp[1][`images],"\n";}
