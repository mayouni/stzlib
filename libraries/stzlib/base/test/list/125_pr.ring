# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #125.

load "../../stzBase.ring"


o1 = new stzList(1:180_000)

o1.ShortenN(2)
? @@( o1.Content() )
#--> [ 1, 2, "...", 179999, 180000 ]

pf()
# Executed in 0.13 second(s)
