# Narrative
# --------
# Coefficient of Variation
#
# Extracted from stzdatasettest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# CoVar measures relative variability (standard deviation / mean * 100),
# useful for comparing variability across datasets.

pr()

o1 = new stzDataSet([ 10, 15, 20, 25, 30, 35, 40 ])
? o1.CoVar() #--> 43.2049 (percent variability relative to mean)

pf()
# Executed in 0.0020 second(s) in Ring 1.24
