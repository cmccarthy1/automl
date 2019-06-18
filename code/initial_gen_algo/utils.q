\d .aml

/  x = 1st individual
/  y = 2nd individual
/* a == return an array of 4 offspring

// The do loop here which runs twice to 'regenerate the community'
// this step is needed after the selection process which reduces the
// population by 1/2. 
crossing:{l:where x<>y;a:();do[2;a,:enlist@[x;l;(count l)?0b]];a}

// Mutations:
//  ensure that offspring from parents every now and
//  get randomly 'shuffled'. This is needed because offspring
//  could be very similar to parents after a number of generations. Changing
//  the value 0.01 below would change how many these mutations take place.
mutations:{
 {p:("i"$0.01*cfi)?cfi:count x;@[x;p;not x@p]}each x}


// Initial population production:
/* x = feature table created produced in the previous step
/* y = #individuals to be in the population
pop:{i:();do[y;i,:enlist count[1_cols x]?0b];i}

scoring:{[tts;col;mdl;seed]
 comp.mdls[mdl;seed][`:fit][flip tts[`xtrain]col;tts`ytrain][`:score][flip tts[`xtest]col;tts`ytest]`}
