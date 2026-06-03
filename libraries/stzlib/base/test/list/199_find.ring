# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #199.

load "../../stzBase.ring"

pr()

o1 = new stzList( 1:299_000 + "str1" + "str2" + 12 + [ "+", "-" ] + "str1" + o1 )

? o1.Find("str1")
#--> [299001, 299005]

pf()
# Executed in 0.84 second(s)
