# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #260.

load "../../../stzBase.ring"


o1 = new stzList([ "*", "4", "*", "3", "4" ])

? o1.NumberOfDuplicates() + NL
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

pf()
# Executed in 0.08 second(s)
