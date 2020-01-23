\l automl.q
.aml.loadfile`:init.q

\d .aml

tab:([]100?1f;100?0b;asc 100?`1;100?100)
tgt_f:asc 100?1f
tgt_b:100?0b
tgt_mul:100?3

$[(::)~@[{.aml.run[x;tgt_f;`normal;`reg;::]};tab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_b;`normal;`class;::]};tab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_mul;`normal;`class;::]};tab;{[err]err;0b}];1b;0b]

$[(::)~@[{.aml.run[x;tgt_b;`normal;`class;`saveopt`seed!(0;12345)]};tab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_f;`normal;`reg;`xv`gs`saveopt!((`.ml.xv.kfsplit;2);(`.ml.gs.kfsplit;2);1)]};tab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_mul;`normal;`class;`scf`saveopt`sz!((`class`reg!(`.ml.mae;`.ml.rmsle));2;.6)]};tab;{[err]err;0b}];1b;0b]

freshtab:([]5000?100?0p;asc 5000?100?1f;5000?1f;desc 5000?10f;5000?0b)
$[(::)~@[{.aml.run[x;tgt_f;`fresh;`reg;::]};freshtab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_b;`fresh;`class;::]};freshtab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_mul;`fresh;`class;::]};freshtab;{[err]err;0b}];1b;0b]

$[(::)~@[{.aml.run[x;tgt_f;`fresh;`reg;`saveopt`aggcols!(0;`x1)]};freshtab;{[err]err;0b}];1b;0b]
$[(::)~@[{.aml.run[x;tgt_b;`fresh;`class;`hld`tts!(0.3;`.ml.traintestsplit)]};freshtab;{[err]err;0b}];1b;0b]

0b~$[(::)~@[{.aml.run[x;tgt_f;`normal;`reg;enlist[`tst]!enlist 1]};tab;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.aml.run[x;tgt_b;`fresh;`class;`saveopt`tts!(2;`.ml.tst)]};freshtab;{[err]err;0b}];1b;0b]
