# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #2.

load "../../stzBase.ring"


? IsTrue("") #--> FLASE

? IsTrue("Hello") #--> FALSE

? IsTrueXT("Hello") #--> TRUE

? IsTrueXT("") #--> FALSE
# Because:
? EmptyStringIsConsideredFalse() #--> TRUE

# Change the default and try again:
SetEmptyStringIsConsideredFalse(0)
? IsTrueXT("") #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.24
