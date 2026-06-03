# Narrative
# --------
# Utility & Standalone Functions
#
# Extracted from stzdatasettest.ring, block #35.

load "../../stzBase.ring"

# Provides additional tools like dataset comparison.

pr()

? @@NL(CompareDatasets([ 1, 2, 3, 4, 5], [2, 4, 6, 8, 10 ]))
#--> [
#	"Mean difference: -50%",
#	"Dataset 2 shows higher variability",
#	"Strong positive correlation (1)"
# ]

pf()
# Executed in 0.0020 second(s) in Ring 1.24
# Executed in 0.0030 second(s) in Ring 1.22

#======================================================================#
#  Summary and Export                                                  #
#======================================================================#

# Summarizes and exports dataset statistics.
