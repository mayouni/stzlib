# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #267.

load "../../../stzBase.ring"


o1 = new stzList([ "a", "ab", "b" ])
? @@( o1.Intersection(:with = [ "a", "ab", "abc", "b", "bc", "c" ]) ) # Or CommonItems()
#--> [ "a", "ab", "b" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19 (64 bits)
# Executed in 0.03 second(s) in Ring 1.17
