# Narrative
# --------
# Correlation Analysis Tests
#
# Extracted from stzdatasettest.ring, block #20.

load "../../../stzBase.ring"

# Measures strength and direction of linear relationships.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5 ])
o2 = new stzDataSet([ 2, 4, 6, 8, 10 ])

? o1.CorelWith(o2)       #--> 1 (perfect positive correlation)
? o1.CoVarwith(o2)       #--> 5 (covariance)
? o1.RankCorelWith(o2)   #--> 1 (Spearman rank correlation)

pf()
# Executed in 0.0140 second(s) in Ring 1.24
# Executed in 0.0240 second(s) in Ring 1.22
