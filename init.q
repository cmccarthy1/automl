\d .aml
\l p.q
loadfile`:code/checkimport.p
loadfile`:code/proc/utils.q
loadfile`:code/proc/proc.q
$[0~checkimport[];
   loadfile`:code/mdl_def/kmdls.q;
   [-1"Requirements for deep learning models not available, these will not be run";]]
loadfile`:code/preproc/utils.q
loadfile`:code/preproc/preproc.q
loadfile`:code/preproc/featextract.q
loadfile`:code/postproc/utils.q
loadfile`:code/postproc/plots.q
loadfile`:code/postproc/report_gen.q
loadfile`:code/postproc/meta.q
loadfile`:code/utils.q
loadfile`:code/run.q
loadfile`:code/proc/xvgs.q
