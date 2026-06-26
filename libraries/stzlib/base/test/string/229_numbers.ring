# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #229.
#
# SEMANTICS TO CONFIRM (deferred -- see _AUDIT_DEFECTS.md): NumbersComingAfter("@i")
# on " @i + 10, @i- 125, e11" returns [ "+10", "-125" ] (the numbers right after
# each "@i"); the archive expected [ "+10", "-125", "11" ], but "11" (from "e11")
# does not follow an "@i". Confirm whether NumbersComingAfter should also pick up
# trailing numbers with no preceding anchor. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString(" @i + 10, @i- 125, e11")
? @@( o1.Numbers() ) + NL

? @@( o1.NumbersComingAfter("@i") )
#--> archive [ "+10", "-125", "11" ]; currently [ "+10", "-125" ]

pf()
