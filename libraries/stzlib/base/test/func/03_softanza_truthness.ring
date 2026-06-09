# Narrative
# --------
# SOFTANZA TRUTHNESS #TODO
#
# Extracted from stzfunctest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Everything is true except 0, "", FalseObject(), and NullObject()
# Make a simular article to this:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/base/doc/narrations/stzstring-emptiness-narration.md

? ""

? IsTrue("") #--> FALSE
? IsTrue(0) #--> FALSE
? IsTrue(NullObject()) #--> FALSE
? IsTrue(FalseObject()) #--> FALSE

? IsTrue(123) #--> TRUE
? IsTrue(-23) #--> TRUE

? IsTrue("text") #--> TRUE
? IsTrue([1, 2, 3]) #--> TRUE
? IsTrue([]) #--> TRUE

pf()
