\d .aml

// This script contains all of the functions used currently within the pipeline for the
// plotting and saving of visualisations related to the the pipeline

/  calculate impact of each feature and save plot of top 20
post.featureimpact:{[b;m;x;y;c;f;o;dt]
  r:post.i.predshuff[m;x;y;f]each til count c;
  im:post.i.impact[r;c;o];
  post.i.impactplot[im;b;dt];
  -1"\nFeature impact calculated for features associated with ",string[b]," model";
  -1 ssr["Plots saved in Outputs/",string[dt`stdate],"/Run_",string[dt`sttime],"/Images/\n";":";"."];}
