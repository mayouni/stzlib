# Narrative
# --------
# SOFTANZA FALSINESS #TODO
#
# Extracted from stzfunctest.ring, block #4.

load "../../../stzBase.ring"


# The strict inverse of TRUTH

? IsFalse("") #--> TRUE
? IsFalse(0) #--> TRUE
? IsFalse(NullObject()) #--> TRUE
? IsFalse(FalseObject()) #--> TRUE

? IsFalse(123) #--> FALSE
? IsFalse(-23) #--> FALSE

? IsFalse("text") #--> FALSE
? IsFalse([1, 2, 3]) #--> FALSE
? IsFalse([]) #--> False
