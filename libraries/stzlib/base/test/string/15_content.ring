# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #15.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring kandaji")

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥♥♥ csharp ♥ ♥♥♥

pf()
#--> Executed in 0.01 second(s)
