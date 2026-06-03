# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #495.

load "../../stzBase.ring"


o1 = new stzString("RIxxNxG")

? o1.SubString("x")
#--> "x"

? o1.SubStringQ("x").StzType() + NL
#--> stzstring

#--

? @@( o1.SubString("y") )
#--> NULL

? o1.SubStringQ("y").StzType()
# stznullobject

pf()
# Executed in 0.01 second(s) in Ring 1.22

#== @FunctionPartialForm #TODO #NARRATION

pr()

o1 = new stzString("__Ri__ng__")

? o1.@("__").@Removed()
#--> Ring

? o1.@("__").UppercasedQ().AndThenQ().@Removed()
#--> RING

pf()
# Executed in 0.06 second(s) in Ring 1.22

#---

pr()

o1 = new stzString("RIxxNxG")
? o1.@("x").@Removed()
#--> RING

pf()
# Executed in 0.05 second(s) in Ring 1.22
