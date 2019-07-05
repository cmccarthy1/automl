n:10000
x:([]n?100f;asc n?100f)
yr:asc n?100f / regression
yc:n?0b       / binary classification
ym:n?5        / multi classification
k:3           / number of folds
p:.2          / percentage of holdout
n:1           / number of repetitions
score_func:.ml.xv.fitpredict
