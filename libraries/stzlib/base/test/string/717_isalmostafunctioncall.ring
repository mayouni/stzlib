# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #717.
#ERR Error (R14) : Calling Method without definition: isalmostafunctioncall

load "../../stzBase.ring"

pr()

# Used internally by the library in evaluating conditional code:

? StzStringQ('myfunc()').IsAlmostAFunctionCall()
#--> TRUE

? StzStringQ('my_func("name")').IsAlmostAFunctionCall()
#--> TRUE

pf()
# Executed in 0.01 second(s).
