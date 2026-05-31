# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #32.

load "../../../stzBase.ring"


o1 = new stzString('   str = "  ...  "     and   str !=    "  *** " ')

? @@NL( o1.BoundedBy('"') ) + NL
#--> [
#	"  ...  ",
#	"     and   str !=    ",
#	"  *** "
# ]


? @@( o1.FindAsSections( o1.BoundedBy('"') ) )
#--> [ [ 11, 17 ], [ 19, 39 ], [ 41, 46 ] ]

pf()
# Executed in 0.07 second(s)
