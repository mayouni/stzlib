# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #10.

load "../../stzBase.ring"


o1 = new stzList([
	"ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "ring", "kandaji" ])

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "qt", "♥♥", "pyhton", "♥♥♥", "csharp", "♥", "♥♥♥" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

#====

pr()

? SectionToRange(3, 7)
#--> [ 3, 5 ]

? RangeToSection(3, 5)
#--> [ 3, 7 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
