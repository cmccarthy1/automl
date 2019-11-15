\d .aml

// This script contains all of the functions used currently within the pipeline for the
// plotting and saving of visualisations related to the the pipeline

/  calculate impact of each feature and save plot of top 20
post.featureimpact:{[b;m;x;c;f;o;dt;fpath]
  r:post.i.predshuff[m;x 0;x 1;f]each til count c;
  im:post.i.impact[r;c;o];
  post.i.impactplot[im;b;dt;fpath];
  -1"\nFeature impact calculated for features associated with ",string[b]," model";
  -1 "Plots saved in ",fpath[1][`images],"\n";}
