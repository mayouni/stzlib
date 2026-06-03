# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #124.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:180_000)

o1.Shorten()
? @@( o1.Content() )
#--> [ 1, 2, 3, "...", 179998, 179999, 180000 ]

pf()
# Executed in 0.13 second(s)
