# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #604.

load "../../../stzBase.ring"


# A Softanza NullObject is a named object

? NullObject().IsNamedObject()
#--> TRUE

? NullObject().VarName()
#--> @nullobject

# It can't equal anything, even itself!

? NullObject().IsEqualTo(NullObject())
#--> FALSE

pf()
# Executed in almost 0 second(s).
