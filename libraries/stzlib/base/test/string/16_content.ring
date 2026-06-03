# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #16.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring qt softanza pyhton kandaji csharp zai")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥♥

pf()
# Executed in 0.01 second(s)
