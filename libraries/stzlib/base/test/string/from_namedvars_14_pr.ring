# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #14.
#ERR exit 1: stzstring

load "../../stzBase.ring"

pr()

o1 = new stzString(:nation = "Niger")

? ClassName(o1)
#--> stzstring

? IsNamedObject(o1)
#--> TRUE

? ObjectName(o1)
#--> nation

#----

o1 = new stzString("Niger")

? ISNamedObject(o1)
#--> FALSE

? ObjectName(o1)
#--> @noname

#TODO // Reflect...
# Does any normal object (not necessarilty a stzObject) containing an
# @cVarName attribute and an ObjectVarName() method should be
# considered as potentially named ?

# In fact, the actual implementation ignores those objects completely
# and assign a @noname to them --> they are considered UnnamedObject!

pf()
# Executed in 0.01 second(s).
