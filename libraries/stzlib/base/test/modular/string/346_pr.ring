# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #346.

load "../../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindSubStringsBoundedBy([ "67", :And = "12" ]) ) # Same as o1.FindSubStringsBetween("67", "12")
#--> [ 8 ]

? @@( o1.FindSubStringBoundedBy("♥♥♥", [ "67", :And = "12" ]) ) # Same  as o1.FindSubStringsBetween( "♥♥♥", "67", "12")
#--> [ 8 ]

? @@( o1.FindXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]) )
#--> [ 8 ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]) )
#--> [ [ 8, 10 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "67", :And = "12" ]) )
#--> [ [ 6, 12 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "12", "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

#-----

? @@( o1.FindXT( "♥♥♥", :BoundedBy = ["12", :And = "67" ]) )
#--> [3, 13]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = ["12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]) )
#--> [1, 11]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

pf()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 0.30 second(s) in Ring 1.18
