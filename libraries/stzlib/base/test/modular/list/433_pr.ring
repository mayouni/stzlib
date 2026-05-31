# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #433.

load "../../../stzBase.ring"


o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
? @@( o1 - These([ "bo", "wo" ]) )
#--> [ "fa", "wy" ]

pf()
# Executed in almost 0 second(s).
