# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #123.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:180_000)

o1.ShowShortUsing("***")
#--> [ 1, 2, 3, "***", 179998, 179999, 180000 ]

o1.ShowShortN(2)
#--> [ 1, 2, "...", 179999, 180000 ]

o1.ShowShortNUsing(2, "***")
#--> [ 1, 2, "***", 179999, 180000 ]

? @@( o1.Shortened() )
#--> [ 1, 2, 3, "...", 179998, 179999, 180000 ]

? @@( o1.ShortenedN(2) )
#--> [ 1, 2, "...", 179999, 180000 ]

? @@( o1.ShortenedXT(0, 2, "{...}") )
#--> [ 1, 2, "{...}", 179999, 180000 ]

pf()
# Executed in 0.46 second(s) in Ring 1.19 (64 bits)
# Executed in 0.76 second(s) in Ring 1.17
