# Narrative
# --------
# Data Quality Tests
#
# Extracted from stzdatasettest.ring, block #32.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Handles missing values by excluding them from analysis.

pr()

# Listing the missing values supported by Softanza
# (recognized and cleaned automatically in stzDataSet)

? @@(MissingValues())
#--> ['', "NA", "NULL", "n/a", "#N/A " ]

o1 = new stzDataSet([ 1, "NA", 3, "NULL", 5, "#N/A" ])

? @@(o1.Data())
#--> [ 1, 3, 5 ] (excludes missing values)

? o1.Count()
#--> 3 (count of valid values)

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0020 second(s) in Ring 1.22
