# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #812.

load "../../../stzBase.ring"


? StringAlignXT("SOFTANZA", 30, ".", :Left)
? StringAlignXT("SOFTANZA", 30, ".", :Right)
? StringAlignXT("SOFTANZA", 30, ".", :Center)
? StringAlignXT("SOFTANZA", 30, ".", :Justified) + NL

#-->
# SOFTANZA......................
# ......................SOFTANZA
# ...........SOFTANZA...........
# S....O...F...T...A...N...Z...A

pf()
# Executed in 0.05 second(s).
