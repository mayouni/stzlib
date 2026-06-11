# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzString("Ring")
? @@(InvisibleChars())

pf()

? StzCharQ("⚝").Name()
#--> OUTLINED WHITE STAR

? StzCharQ("OUTLINED WHITE STAR").Content()
#--> ⚝

? StzCharQ("⚝").Unicode()
#--> 9885

? StzCharQ(9885).Content()
#--> ⚝

pf()
# Executed in 0.02 second(s) in Ring 1.27 (Backed by StzEngine)
# Executed in 0.13 second(s) in Ring 1.22
# Executed in 0.17 second(s) in Ring 1.21
