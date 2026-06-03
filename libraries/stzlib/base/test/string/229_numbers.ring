# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #229.

load "../../stzBase.ring"

pr()

o1 = new stzString(" @i + 10, @i- 125, e11")
? @@( o1.Numbers() ) + NL

? @@( o1.NumbersComingAfter("@i") )
#--> [ "+10", "-125", "11" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.18
