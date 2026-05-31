# Narrative
# --------
# Partial Correlation Tests
#
# Extracted from stzdatasettest.ring, block #24.

load "../../../stzBase.ring"

# Measures correlation between two variables, controlling for a third.

pr()

oX = new stzDataSet([ 1, 2, 3, 4, 5 ])
oY = new stzDataSet([ 2, 3, 4, 5, 6 ])
oZ = new stzDataSet([ 1, 1, 2, 2, 3 ])

? oX.CorrelationWith(oY)        #--> 1
? oX.PartialCorrelation(oY, oZ) #--> 1

pf()
# Executed in 0.0020 second(s) in Ring 1.24
# Executed in 0.0020 second(s) in Ring 1.22
