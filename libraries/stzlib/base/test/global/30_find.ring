# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #30.

load "../../stzBase.ring"

pr()

o1 = new stzString("...|---|....|--|..--")

? @@( o1.Find("--") )
#--> [ 5, 6, 14, 19 ]

? @@( o1.FindAsSections("--") )
#--> [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.FindAsSection("--") ) # Section without "s"! --> same as FindFirstAsSection()
#--> [ 5, 6 ]

# You can use the ..Z() and ..ZZ() extensions:

? @@( o1.FindZ("--") )
#--> [ 5, 6, 14, 19 ]

? @@( o1.FindZZ("--") )
#--> [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.FindAsSections([ "---", "--" ]) ) + NL
#--> [ [ 5, 6 ], [ 5, 7 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.BoundedBy("|") )
#--> [ "---", "....", "--" ]

? @@( o1.FindSubStringsBoundedByZZ("|") )# Idem
#--> [ [ 5, 7 ], [ 9, 12 ], [ 14, 15 ] ]

pf()
# Executed in 0.10 second(s)
