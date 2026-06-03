# Narrative
# --------
# pr()
#
# Extracted from stzdatasettest.ring, block #42.

load "../../stzBase.ring"


aStep = [ [ "function", "ValidateData" ], [ "required", 1 ], [ "description", "Check data quality" ] ]
? HasKey(aStep, "condition")
#--> FALSE

? @@(aStep[:condition])
#--> ""

? HasKey(aStep, "required") #--> TRUE

? @@(aStep[:required])
#--> 1

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0020 second(s) in Ring 1.22
