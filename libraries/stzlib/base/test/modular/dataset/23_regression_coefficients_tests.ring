# Narrative
# --------
# Regression Coefficients Tests
#
# Extracted from stzdatasettest.ring, block #23.

load "../../../stzBase.ring"

# Fits a linear model and returns slope, intercept, and R-squared.

pr()

oX = new stzDataSet([ 1, 2, 3, 4, 5 ])
oY = new stzDataSet([ 2, 4, 6, 8, 10 ])

aRegression = oX.RegressionCoefficients(oY)
? @@NL(aRegression)
#--> [[ " slope", 2], [ " intercept", 0], [ " r_squared", 1]]

oY2 = new stzDataSet([ 1, 3, 5, 7, 11 ])
aRegression2 = oX.RegressionCoefficients(oY2)
? @@NL(aRegression2)
 #--> [[ " slope", 2.4], [ " intercept", -1.8], [ " r_squared", 0.9730]]

pf()
# Executed in 0.0020 second(s) in Ring 1.24
# Executed in 0.0050 second(s) in Ring 1.22
