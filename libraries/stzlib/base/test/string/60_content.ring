# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #60.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")

o1.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> "♥ qt ♥♥ pyhton ♥♥♥ csharp ♥"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.17
