# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #211.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8 ])

? o1.HowMany("*")
#--> 2

? o1.FindFirst("*")
#--> 4
# Executed in 0.02 second(s)

? o1.FindLast("*")
#--> Executed in 0.02 second(s)

pf()
# Executed in 0.03 second(s)
