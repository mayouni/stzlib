# Narrative
# --------
# o1 = new stzString("_♥_★_♥_")
#
# Extracted from stzStringTest.ring, block #396.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? @@( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzString("_♥_★_♥_")
? @@( o1.TheseCharsZ([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@( o1.TheseCharsZ([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

pf()
