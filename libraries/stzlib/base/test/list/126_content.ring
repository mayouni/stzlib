# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #126.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:180_000)

o1.ShortenNUsing(2, "{}")
? @@( o1.Content() )
#--> [ 1, 2, "{}", 179999, 180000 ]

pf()
# Executed in 0.09 second(s)
