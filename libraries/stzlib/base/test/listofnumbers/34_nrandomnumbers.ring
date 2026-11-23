# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #34.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering several.
# One seed governs both generators since 2026-08-07 -- see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine Xoshiro.
SeedRandom(31)

? QQ(1:100_000).NRandomNumbers(3)
#--> [8719, 96748, 82101]

pf()
# Executed in 0.62 second(s)
