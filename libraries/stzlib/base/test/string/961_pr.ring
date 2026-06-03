# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #961.

load "../../stzBase.ring"


o1 = new stzString("---456----123--67---")

o1.ReplaceSectionsByMany(
	[ [4, 6], [11, 13], [16, 17] ],
	[ "^^^", "^^^", "^^" ]
)

? o1.Content()
#--> ---^^^----^^^--^^---

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.19
