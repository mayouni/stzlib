# Narrative
# --------
# Coefficient of Variation
#
# Extracted from stzdatasettest.ring, block #3.

load "../../stzBase.ring"

# CoVar measures relative variability (standard deviation / mean * 100),
# useful for comparing variability across datasets.

pr()

# Four decimals, because that is the precision these expectations are
# written to. Ring renders a float through the PROCESS-GLOBAL decimals
# setting, which defaults to 2 -- so a standard deviation of 10.8012
# printed as 10.80 and the promise beside it read as a divergence. The
# value was always right; only the rendering was short.
StzDecimals(4)

o1 = new stzDataSet([ 10, 15, 20, 25, 30, 35, 40 ])
? o1.CoVar() #--> 43.2049 (percent variability relative to mean)

pf()
# Executed in 0.0020 second(s) in Ring 1.24
