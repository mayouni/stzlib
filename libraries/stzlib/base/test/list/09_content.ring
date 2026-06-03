# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #9.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "zai" ])
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "qt", "♥♥", "pyhton", "♥", "csharp", "♥♥" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
