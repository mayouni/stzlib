# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #303.

load "../../stzBase.ring"

#                      4      11      19   24
#                      v      v       v    v
o1 = new stzString("   r  in  g  is a rin  g  ")

? @@( o1.FindAnyBoundedByIBZZ([ "r", "g" ]) )
#--> [ [ 4, 11 ], [ 19, 24 ] ]

? QRT( o1.SubStringsBoundedByIB([ "r","g" ]), :stzListOfStrings).WithoutSapces()
#NOTE: WithoutSapces() is misspelled and the correct form is WithoutSpaces!
# Despite that, softanza accepts it ;)

#--> [ "ring", "ring" ]

pf()
# Executed in 0.04 second(s) in Ring 1.21.
# Executed in 0.07 second(s) in Ring 1.18
