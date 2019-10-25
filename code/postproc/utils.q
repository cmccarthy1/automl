\d .aml

// Utilities for plotting functions

/  Python functionality
plt:.p.import`matplotlib.pyplot;

/  shuffle columns of matrix/table based on col name or idx
i.shuffle:{idx:neg[n]?n:count x;$[98h~type x;x:@[x;y;@;idx];x[;y]:x[;y]idx];:x}

/  calculate impact of each feature and save plot of top 20
i.featureimpact:{[b;m;x;y;c;f;o;dt]
  r:i.predshuff[m;x;y;f]each til count c;
  im:i.impact[r;c;o];
  i.impactplot[im;b;dt];
  -1"\nFeature impact calculated for features associated with ",string[b]," model - \nsee img folder in current directory for results";}

/  rerun model after shuffle and output score
i.predshuff:{[m;x;y;f;c]
  x:i.shuffle[x;c];
  p:m[`:predict][x]`;
  f[p;y]}

/  impact score
i.impact:{asc y!s%max s:$[z~desc;1-;]$[any 0>x;.ml.minmaxscaler;]x}

/  Data points for plotting curve
/* y = true target vector
/* p = predicted probability vector
i.cumulative_gain_curve:{[y;p]
  if[2<>count distinct y;'`$"y must be binary"];
  i.gaincurve[y]'[flip p;c:asc distinct y]}

/  cumulative gains curve
/* pc = positive class
i.gaincurve:{[y;p;pc]
  gain:sums y:(pc=y)idesc p;
  gain:0.,gain%sum y;
  pcnt:0.,(1+til n)%n:count y;
  `pc`gain`pcnt!(pc;gain;pcnt)}


// Utilities for report generation

/  dictionary used report population
i.report_dict:{[x;y;z;r;k;l]
  dd:(0#`)!();
  select
    feats    :x,
    dict     :y 0,
    impact   :(k,"/Outputs/",string[r`stdate],"/Run_",string[r`sttime],"/Images/Impact_Plot_",string[y 1],".png"),
    holdout  :y 2,
    xvtime   :y 3,
    bmtime   :y 4,
    metric   :y 5,
    feat_time:z 1,
    gs       :l 0,
    score    :l 1,
    xv       :l 2,
    gscfg    :l 3
  from dd}

