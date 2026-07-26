# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #57.

load "../../stzBase.ring"

pr()

? MaxNumberInRing()
#--> 9007199254740992.00

# This used to read 999999999999999, a pre-engine bound that was wrong for both
# readings of the name: Softanza is not bounded at all (a 20-digit integer is held
# and added exactly -- see numeric_calculable_narrated.ring), and Ring's own exact
# limit is 2^53 = 9007199254740992, nine times larger. It reports the truth now.
# The ".00" is Ring's global decimals() display mode, not part of the value.

? MaxRoundInRing()
#--> 14

pf()
# Executed in 0.03 second(s)
