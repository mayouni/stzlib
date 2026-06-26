# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #241.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, Z/ZZ grouping family): the plain
# FirstHalf/SecondHalf/Halves(+XT) forms work (block 240), but every Z/ZZ form
# loses the [substring, position] grouping -- FirstHalfZ returns [1,4] instead of
# [ "1234", 1 ], HalvesZZ returns [ [1,4], [5,9] ] instead of
# [ [ "1234",[1,4] ], [ "56789",[5,9] ] ], etc. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")

? @@( o1.FirstHalfZ() )   #--> expected [ "1234", 1 ] (currently [ 1, 4 ])
? @@( o1.FirstHalfZZ() )  #--> expected [ "1234", [ 1, 4 ] ]
? @@( o1.SecondHalfZZ() ) #--> expected [ "56789", [ 5, 9 ] ]
? @@( o1.HalvesZ() )      #--> expected [ [ "1234", 1 ], [ "56789", 5 ] ]
? @@( o1.HalvesZZ() )     #--> expected [ [ "1234", [1,4] ], [ "56789", [5,9] ] ]

pf()
