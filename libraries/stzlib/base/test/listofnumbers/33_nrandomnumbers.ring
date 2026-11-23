# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #33.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering several.
# One seed governs both generators since 2026-08-07 -- see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine Xoshiro.
SeedRandom(31)

? QQ(1:10).NRandomNumbers(3)
#--> [1, 10, 9]

pf()
# Executed in 0.04 second(s)
