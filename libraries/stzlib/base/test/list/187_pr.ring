# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #187.

load "../../stzBase.ring"


o1 = new stzList(1:299_000 + 120000)

? o1.Contains(120000)
#--> TRUE
# Executed in 0.84 second(s)

? o1.NumberOfOccurrence(120000)
#--> 2
# Executed in 1.37 second(s)

pf()
# Executed in 2.44 second(s)
