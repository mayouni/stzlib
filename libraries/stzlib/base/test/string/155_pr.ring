# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #155.

load "../../stzBase.ring"


o1 = new stzString("---|ABC|---|ABC|---")

? @@( o1.FindBetweenAsSections("ABC", "|", "|") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindBoundedByAsSections([ "ABC", '|' ]) )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindXT("ABC", :Between = [ "|", "|" ]) )
#--> [ 5, 13 ]

? @@( o1.FindAsSectionsXT("ABC", :Between = [ "|", "|" ]) )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindXT("ABC", :BoundedBy = "|") )
#--> [ 5, 13 ]

? @@( o1.FindAsSectionsXT("ABC", :BoundedBy = "|") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.20
