# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #410.

load "../../stzBase.ring"


o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

//? o1.EndsWithNumber("+132.45")
#--> ERROR: Calling function with extra number of parameters

? o1.EndsWithNumberN("+132.45") #NOTE
				# the N a the end of function name
				# Or you can say EndsWithThisNumber(...)
#--> TRUE

? o1.TrailingNumber()
#--> "+132.45"

pf()
#--> Executed in 0.04 second(s) in Ring 1.21
