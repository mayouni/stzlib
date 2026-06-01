# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #796.

load "../../../stzBase.ring"


o1 = new stzString("LandRingoriaLand")
o1.RemoveFirstOccurrence( :Of = "Land")
? o1.Content()
#--> RingoriaLand

pf()
# Executed in 0.01 second(s).
