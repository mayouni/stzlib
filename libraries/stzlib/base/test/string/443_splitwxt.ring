# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #443.
#ERR Error (R14) : Calling Method without definition: splitwxt

load "../../stzBase.ring"

pr()

o1 = new stzString("JuliaRingRuby")

? o1.SplitWXT(:AroundSubString = ' @substring = "Ring" ')
#--> [ "Julia", "Runby" ]

? o1.SplitWXT(:BeforeSubString = ' @substring = "Ring" ')
#--> [ "Julia", "Ruby" ]

? o1.SplitWXT(:AfterSubString = ' @substring = "Ring" ')
#--> [ "JuliaRing", "Ruby" ]

pf()
# Executed in 0.97 second(s) in Ring 1.21
