# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #445.
#ERR Error (R14) : Calling Method without definition: splitafterpositions

load "../../stzBase.ring"

pr()

o1 = new stzString("---4---8---")

? @@( o1.SplitAfterPositions([ 4, 8 ]) ) + NL
#--> [ "---4", "---8", "---" ]

? @@( o1.SplitWXT(:AfterPositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---4", "---8", "---" ]

pf()
# Executed in 0.13 second(s) in Ring 1.21
