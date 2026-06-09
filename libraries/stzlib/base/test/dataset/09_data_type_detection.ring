# Narrative
# --------
# Data Type Detection
#
# Extracted from stzdatasettest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Identifies the type of data (numeric, categorical, mixed). #TODO Add temporal

pr()

o1 = new stzDataSet([ "Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow" ])
? o1.DataType()  #--> "categorical" (all values are strings)

pf()
# Executed in 0.0010 second(s) in Ring 1.22
