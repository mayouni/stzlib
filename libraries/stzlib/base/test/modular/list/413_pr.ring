# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #413.

load "../../../stzBase.ring"


o1 = new stzNumber(12500)

? o1 / 500
#--> 25

# Note that the / operator does not change the o1 content:

? o1.Content()
#--> 12500

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.21
