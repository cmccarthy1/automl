# Automated machine learning in kdb+

## Introduction

The automated machine learning library described here is built largely on the tools available within the machine learning toolkit. The purpose of this framework is to provide users with the ability to automate the process of applying machine learning techniques to real-world problems. In the absence of expert machine learning engineers this handles the following processes within a traditional workflow.

- Data preprocessing
- Feature engineering and feature selection
- Model selection
- Hyperparameter Tuning
- Report generation and model persistence

Each of these steps is outlined in depth within the documentation for this platform [here](https://code.kx.com/q/ml/automl/). This allows users to understand the processes by which decisions are being made and the transformations which their data undergo during the production of the output models.

At present the machine learning frameworks supported for this are based on:

1. One-to-one feature to target non time-series
2. FRESH based feature extraction and model production

The problems which can be solved by this framework will be expanded over time as will the available functionality.

## Requirements

The following requirements cover all those needed to run the libraries in the current build of the toolkit.

- embedPy
- ML-Toolkit

A number of Python dependencies also exist for the running of embedPy functions within both the the machine-learning utilities and FRESH libraries. Install of the requirements can be completed as follows

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

**Note**:

The following may be required for windows users within a conda environment:

- Users may incur the below error as a result of running matplotlib within a conda environment:
	```
	This application failed to start because it could not find or load the Qt platform plugin "windows" in "". Reinstalling the application may fix this problem.
	```
	To avoid this error occurring, windows users should add the following to their environment variables:
	```
	'QT_QPA_PLATFORM_PLUGIN_PATH' = '/path/to/Anaconda3/Library/plugins/platforms'
	```

The following are optional additional packages which users can install to allow for a larger range of functionality, but which are not necessarily required:

- Tensorflow and Keras are required for the application of the some default deep learning models within this platform. Given the large memory requirements of Tensorflow the platform will operate without Tensorflow by not running the deep learning models. Installing Tensorflow and Keras will allow these models, along with custom Keras models, to be run.


## Installation

Place the library file in `$QHOME` and load into a q instance using `automl/automl.q`

This will load all the functions contained within the `.ml` namespace  
```q
$q automl/automl.q
q).automl.loadfile`:init.q
```

## Documentation

Documentation for all sections of the automated machine learning library are available [here](https://code.kx.com/q/ml/automl/).

## Status

Automated machine learning in kdb+ is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

Any issues with the framework should be raised in the issues section of this repository. Functionality suggestions or more general questions should be submitted via email to ai@kx.com

