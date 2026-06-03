# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #198.

load "../../stzBase.ring"

pr()

o1 = new stzList( 1:299_000 + "str1" + "str2" + 12 + [ "+", "-" ]  + o1 )

? o1.Find(12)
#--> [12, 299003]

pf()
# Executed in 2.67 second(s)
