# Narrative
# --------
# SOFTANZA EMpTINESS
#
# Extracted from stzfunctest.ring, block #2.

load "../../stzBase.ring"


# Emptiness applies to "" for strings, [] for lists, and NullObject() for objects

? IsEmpty("") #--> TRUE
? IsEmpty([]) #--> TRUE
? IsEmpty(0) #--> FALSE
? IsEmpty(NullObject()) #--> TRUE
? IsEmpty(FalseObject()) #--> FALSE
