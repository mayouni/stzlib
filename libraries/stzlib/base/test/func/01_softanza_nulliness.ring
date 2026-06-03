# Narrative
# --------
# SOFTANZA NULLINESS
#
# Extracted from stzfunctest.ring, block #1.

load "../../stzBase.ring"


# Only empty strings and the NullObject() are considered null,
# everything else is not null

pr()

? IsNull("") #--> TRUE
? IsNull([]) #--> FALSE
? IsNull(0) #--> FALSE
? IsNull(NullObject()) #--> TRUE
? IsNull(TrueObject()) #--> FALSE
? IsNull(FalseObject()) #--> FALSE

pf()
