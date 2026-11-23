# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #37.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering several.
# One seed governs both generators since 2026-08-07 -- see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine Xoshiro.
SeedRandom(31)

? QQ(1:7).AnyNumberAfterPosition(5)
#--> 6


pf()
# Executed in 0.01 second(s)
