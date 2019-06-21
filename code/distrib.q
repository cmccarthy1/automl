\l ml/ml.q
.ml.loadfile`:init.q


\d .aml


// table of models
/* x = symbol, either `class or `reg
/* y = target
models:{
 if[not x in key i.files;'`$"text file not found"];
 d:{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,"/code/mdl_def/",i.files x; 
 m:flip`model`lib`fnc`seed`typ!flip key[d],'value d;
 if[x=`class;
  m:$[2<count distinct y;delete from m where typ=`binary;delete from m where model=`MultiKeras]];
 update minit:{$[`keras~x;get` sv``aml,y;.p.import[` sv x,y]hsym z]}.'flip(lib;fnc;model)from m}


// run multiple models
/* x = features
/* y = target
/* m = models from `.aml.models`
/* d = dictionary of populated parameters (defined earlier in the workflow)
// test fn
runmodels:{[x;y;m;d]
 system"S ",string s:d`seed;
 s:{if[`seed~x;:y]}[;s]each m`seed;
 r:i.runmodel[d`xv;x;y;;d`prf;]'[m`minit;s];
 desc m[`model]!avg each
  {{x[y 0;y 1]}[x]each y}[$[min m[`typ]in key[d`scf];d[`scf]`class;d[`scf]`regr]]each r}


if[0>system"s";.ml.mproc.init[abs system"s"]enlist".ml.loadfile`:init.q"]


/ Utils
i.files:`class`reg!("classmodels.txt";"regmodels.txt")
i.runmodel:{[xv;x;y;a;f;s]
 s:$[type[s]in(101h;-7h);s;@[{"i"$x};s;'`$"type not convertable"]];
 if[(-7h~type s)&105h~type a;s:enlist[`random_state]!enlist s];
 raze .ml.gsseed[xv;x;y;a;f;s]}
