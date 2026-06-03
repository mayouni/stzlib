# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #428.

load "../../stzBase.ring"


o1 = new stzString("-132114.45 euros and 246 cents")

? @@( o1.FindNumbers() ) + NL
#--> [ 1, 22 ]

? @@( o1.FindNumbersZZ() )  + NL
#--> [ [ 1, 10 ], [ 22, 24 ] ]

? @@( o1.Numbers() ) + NL
#--> [ "-132114.45", "246" ]

? @@( o1.NumbersZZ() ) + NL
#--> [ [ "-132114.45", [ 1, 10 ] ], [ "246", [ 22, 24 ] ] ]

? o1.StartsWithANumber()
#--> TRUE

? o1.StartsWithThisNumber("-132")
#--> TRUE

? o1.StartsWithThisNumber("-132114.45") + NL
#--> TRUE

? o1.LeadingNumber()
#--> "-132114.45"

pf()
# Executed in 0.08 second(s) in Ring 1.22
