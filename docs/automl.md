---
title: Automated Machine Learning - code.kx.com
keywords: Python, Jupyter, auto ml, machine learning, ml, kdb+/q, Anaconda, Docker
---

# <i class="fas fa-share-alt"></i> Automated Machine Learning

In recent years, there has been an increased demand within the data science community for more user-friendly machine learning software, designed specifically for those who are not machine learning experts.

Automated machine learning (AML) has been created to meet this demand by automatically performing machine learning tasks without the user having to write the code associated with the process. AML performs tasks such as data preprocessing, feature selection and extraction and candidate model training and selection.

Typically, AML platforms provide users with a small set of simple wrapper functions which can be used to perform large portions of machine learning tasks, with the option to change default parameters where required.

Within the kdb+/q AML library, the function `.aml.runexample` is provided to perform the aforementioned machine learning tasks in a single wrapper function, where users must provide the following parameters:

-   `tb` is the table of input features
-   `tgt` is the target vector, which can be binary, multi-class or continuous
-   `typ` is the type of feature extraction to be performed (current implementation only supports FRESH)
-   `mdls` is the table of models resulting from `.aml.models[m;tgt]` where m is either ```class`` or ```reg``
-   `p` is a dictionary of update parameters where `(::)` indicates that defaults should be used

The wrapper function carries out the following machine learning tasks and returns a performance metric for each candidate model.

!!! note
	The kdb+/q ML-Toolkit is required for the AML implementation.

## Preprocessing

To preprocess data into a suitable format for machine learning, the following steps are taken:

-   Symbol encode: symbol columns with less than 10 distinct symbols are one hot encoded, while columns with more than 10 are frequency encoded
-   Drop constant: any constant columns are removed from the feature table
-   Null encode: any nulls are replaced with the median value of the column, with an additional column provided stating the previous locations of the null values
-   Infinity replace: any values equal to positive/negative infinity are replaced by the max/min column values respectively 

## Feature Extraction

The current AML implementation only supports [FRESH](https://code.kx.com/v2/ml/toolkit/fresh/) feature extraction which carries out the following:

-   Create features: a set of aggregation functions are applied to the original columns to derive new features
-   Null encode: any nulls are replaced with the median value of the column, with an additional column provided stating the previous locations of the null values
-   Infinity replace: any values equal to positive/negative infinity are replaced by the max/min column values respectively
-   Drops constant: any constant columns are removed from the feature table

## Distributed Cross-Validation

Cross validation is performed on a variety of models for both classification and regression problems.

Classification Models        | Regression Models
-----------------------------|-----------------------------
AdaBoost Classifier          | AdaBoost Regressor
Random Forest Classifier     | RandomForestRegressor
Gradient Boosting Classifier | GradientBoostingRegressor
Logistic Regression          | LinearRegression
Gaussian                     | Lasso
K-Neighbors Classifier       | KNeighborsRegressor
MLP Classifier               | MLPRegressor
SVC                          | Keras Regression Model
Linear SVC                   |
Keras Binary Model           |
Keras Multi-Class Model      |

In the AML pipeline the above models are initialized depending on which type of target is provided. Models parameters are set to the default values and a random seed is set so that results are reproducible. Cross validation is then run on each of the models, with 5-fold cross validation used as the default.

Multiple processes are opened and work is distributed across them, where each process performs model fitting and cross validation.

## Genetic Algorithms



