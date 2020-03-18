\l automl/automl.q
.automl.loadfile`:init.q

\l latex.p
// For simplicity of implementation this code is written largely in python
// calls are made to appropriate functions to handle item generation

td:.p.get[`test_doc]
key_vals:`date`time`num_feat`feat_time`xv_folds`xv_func`xvtime`metric`best_model`best_val_score`val_score`gs_folds`gs_func`score
values:string each(.z.d;.z.t;1;"t"$0;5;`.ml.xv.shuff;"t"$100;`.ml.mse;`binarykeras;0.001;"t"$20;5;`.ml.gs.kfshuff;0.001);

d:`rand`model`name!(0.002;0.003;0.005)
scr:flip `model`score!flip key[d],'value[d]
vals:`nn`C`epsilon!(5;0.1;`test)
gs:flip `param`val!flip key[vals],'value[vals]

tb:(flip enlist[`column]!enlist key[k]),'value k:.automl.prep.i.describe([]5?0b;5?1f;5?5)

tab_test:.ml.tab2df[tb][`:round][3]
score:.ml.tab2df[scr][`:round][3]
grid:.ml.tab2df[gs][`:round][3]
ptype:`reg
td[key_vals!values;tab_test;score;ptype;.automl.i.excludelist;grid];
