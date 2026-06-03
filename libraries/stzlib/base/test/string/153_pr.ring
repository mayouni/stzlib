# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #153.

load "../../stzBase.ring"


o1 = new stzList([ "s", "o", "f", "t", "a", "n", "z", "a" ])
? @@( o1.Section(4, 6) )
#--> [ "t", "a", "n" ]

? @@( o1.Section(6, 4) )
#--> [ "t", "a", "n" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
