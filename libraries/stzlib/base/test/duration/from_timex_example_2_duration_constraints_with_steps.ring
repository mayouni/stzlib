# Narrative
# --------
# Example 2: Duration Constraints with Steps
#
# Extracted from stztimextest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDur1 = new stzDuration("1 hour 30 minutes")  # 90 minutes
oDur2 = new stzDuration("1 hour 20 minutes")  # 80 minutes

Tmx = new stzTimex("{@Duration(1h..2h:15min)}")

? Tmx.Match(oDur1)
#--> TRUE (90min is in range and on 15min boundary)

? Tmx.Match(oDur2)
#--> FALSE (80min not on 15min step: 60, 75, 90, 105, 120)

pf()
