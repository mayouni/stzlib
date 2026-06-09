# Narrative
# --------
# SOFTANZA EMpTINESS
#
# Extracted from stzfunctest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Emptiness applies to "" for strings, [] for lists, and NullObject() for objects

? IsEmpty("") #--> TRUE
? IsEmpty([]) #--> TRUE
? IsEmpty(0) #--> FALSE
? IsEmpty(NullObject()) #--> TRUE
? IsEmpty(FalseObject()) #--> FALSE

pf()
