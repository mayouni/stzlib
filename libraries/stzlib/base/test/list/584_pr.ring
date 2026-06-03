# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #584.

load "../../stzBase.ring"


o1 = new stzNumber(12500)

? o1 - 500	# You can even say o1 - "500" because stzNumber accepts
#--> 12000	# values of numbers that are hosted in strings!

pf()
# Executed in 0.07 second(s).
