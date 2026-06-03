# Narrative
# --------
# Mutual Information Tests
#
# Extracted from stzdatasettest.ring, block #25.

load "../../stzBase.ring"

# Measures shared information between variables (linear and non-linear).

pr()

oA = new stzDataSet([ "Low", "Low", "High", "High", "Low", "High" ])
oB = new stzDataSet([ "No", "No", "Yes", "Yes", "No", "Yes" ])

? oA.MutualInformationWith(oB)
#--> 1 (perfect dependence)

oC = new stzDataSet([ "X", "Y", "X", "Y", "X", "Y" ])
? oA.MutualInfoWith(oC)
#--> 0.0817 (near independence)

pf()
# Executed in 0.0080 second(s) in Ring 1.24
# Executed in 0.0150 second(s) in Ring 1.22

#======================================================================#
#  Data Preprocessing                                                  #
#======================================================================#

# Prepares data for analysis through transformations.
