# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #27.

load "../../../stzBase.ring"


? ARandomItemIn("A":"E")
#--> B

? NRandomItemsIn(3, "A":"E")
#--> [ "B", "B", "E" ]

? NRandomItemsInU(3, "A":"E")
#--> [ "B", "E", "A" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20
