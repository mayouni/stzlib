# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #194.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

o1 = new stzList( 1:299_000 + "str1" + "str2" + [ "+", "-" ] )
? len( o1.OnlyNumbers() )
#--> 299000

pf()
# Executed in 1.01 second(s)
