# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #641.

load "../../stzBase.ring"


o1 = new stzString("IloveRingprogramminglanguage!")
o1.SpacifySubStringsUsing( [ "love", "Ring", "programming" ], " " )
? o1.Content()
#--> I love Ring programming language!

pf()
# Executed in 0.05 second(s) in Ring 1.22
