# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #127.

load "../../stzBase.ring"


# REMINDER: Duplication is performed in a reasonable performance
# when the size of the list does not exceed 30K items!

aBigList = 1 : 30_000 +
	   "A" + "B" + "." + "A" + "A" + "B" + 2 + 2

o1 = new stzList(aBigList)

? o1.ContainsDuplicates()
#--> TRUE

pf()
# Executed in 3.15 second(s) in Ring 1.21
# Executed in 4.27 second(s) in Ring 1.19
