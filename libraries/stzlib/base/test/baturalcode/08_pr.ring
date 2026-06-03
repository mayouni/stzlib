# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #8.

load "../../stzBase.ring"


? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegative()
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).WhichQ().CanBeDividedBy(10)
#--> TRUE

? Q([ -1200, -10200, -820, -10 ]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.23
