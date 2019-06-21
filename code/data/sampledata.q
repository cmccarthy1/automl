n:10000
x:flip(n?100f;asc n?100f)
yr:asc n?100f / regression
yc:n?0 1      / binary classification
ym:n?5        / multi classification
xval_func:.ml.xval.kfshuff[5;1]
score_func:.ml.fitpredict
