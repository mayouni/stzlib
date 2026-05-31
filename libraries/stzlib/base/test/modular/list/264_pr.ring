# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #264.

load "../../../stzBase.ring"


o1 = new stzList([ "a", "ab", "abnA", "abAb" ])

? o1.Contains("n")
#--> FALSE

? o1.FindFirst("n")
#--> FALSE

pf()
# Executed in 0.02 second(s)
