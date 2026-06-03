# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #297.

load "../../stzBase.ring"


o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")
? @@( o1.SplitAtSections([ [ 1, 8 ], [ 29, 34 ] ]) )
#--> [ "r  in  g", "r  ing" ]

pf()
# Executed in 0.08 second(s).
