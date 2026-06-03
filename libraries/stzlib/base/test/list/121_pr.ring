# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #121.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

o1 = new stzList(1:1_500_000)

o1.ShowShort()
#--> [ 1, 2, 3, " ... ", 1499998, 1499999, 1500000 ]

pf()
# Executed in 1.71 second(s)
