# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #915.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
o1.ReplaceOccurrences([ 2, :and = 3 ], :of = "[...]", :by = [ "ONE", :and = "TWO"])
? o1.Content()
#--> --[...]---ONE---TWO---[~~~]--[~~~]--

pf()
# Executed in 0.02 second(s).
