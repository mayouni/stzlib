# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #445.

load "../../stzBase.ring"


o1 = new stzString("---4---8---")

? @@( o1.SplitAfterPositions([ 4, 8 ]) ) + NL
#--> [ "---4", "---8", "---" ]

? @@( o1.SplitWXT(:AfterPositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---4", "---8", "---" ]

pf()
# Executed in 0.13 second(s) in Ring 1.21
