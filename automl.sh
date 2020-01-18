./" Manpage for kdb+ automl
.TH man 1 "17 January 2019" "0.1" "q-automl man page"
.SH NAME
q-automl - An automated machine learning framework for kdb+
.SH SYNOPSIS
q automl.q
[\fB\-s\fR \fIslaves\fR]
[\fB\-p\fR \fIport\fR]
[\fB\-seed\fR \fIseed\fR]
[\fB\-hld\fR \fIholdout-set\fR]
[\fB\-sigfeats\fR \fIsignificant-features\fR]
[\fB\-sz\fR \fIvalidation-set\fR]
[\fB\-xv\fR \fIcross-validation\fR]
[\fB\-gs\fR \fIgrid-search\fR]
[\fB\-type\fR \fIproblem-type\fR]
[\fB\-tts\fR \fItrain-test-split\fR]
[\fB\-funcs\fR \fIapplied-functions\fR]

.SH DESCRIPTION
This framework provides users with the ability to automate machine learning tasks using a framework built and designed using kdb+/q technology. An emphasis has been placed on the flexibility and extensibility of the framework. 
.SH OPTIONS

.TP
.BR \-s = slave-processes
Number of slave processes/threads available to the process.

Default - There is no default required for this, the q process will be initialized with no slave processes/threads.

.TP
.BR \-p = port
Port number of the centralised q process.

Default - There is no default required for this, the q process will be initialized with no specified port.

.TP
.BR \-seed = seed
Seed which will be used for initializing the machine learning workflow.

Default - value determined based on the current time.

.TP
.BR \-hld = holdout 
Size of the holdout set used for testing the final model once cross validation and grid search procedures have determined the best model.

Default - 20% of the entire dataset.

.TP
.BR \-sz = validation-size
Size of the training set to be set aside for the validation score for the best model achieved through via a cross validated search over appropriate models.

Default - 20% of the training set following holdout separation.

.TP
.BR \-tts = train-test-split
Name of the function to be used to split the dataset into its training and testing(holdout) sets.

Default - 

    FRESH  -> .ml.ttsnonshuff (non shuffled sequential train-test split)

    normal -> .ml.traintestsplit (randomly shuffled train-test split)

.TP
.BR \-type = problem-type
Form of problem being solved (FRESH/Normal)

Note - This input is required if a user wishes to modify \-funcs or \-tts as the default behaviour for solving these problems is different in each case as outlined in their relevant descriptions.

.SH ISSUES
There are currently no known issues within the repository, an up to date log of any issues is made available at https://github.com/KxSystems/automl

.SH AUTHORS
Contributers to this project: This project has been designed and implemented in its entirety by the Kx Systems Machine Learning team

.SH REPORTING ISSUES
Issues should be reported to https://github.com/KxSystems/automl

.SH LICENCE
This project as with all those released by the Kx Machine Learning team is available for free under an Apache 2.0 licence and is supported on a best effort basis.
