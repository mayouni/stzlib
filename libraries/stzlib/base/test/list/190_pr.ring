# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #190.

load "../../stzBase.ring"


o1 = new stzList( 1:7 + "str1" + "str2" + [ "+", "-" ] )
? @@( o1.OnlyNumbers() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

pf()
# Executed in 0.03 second(s)
