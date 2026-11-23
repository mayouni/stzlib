# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #22.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering several.
# One seed governs both generators since 2026-08-07 -- see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine Xoshiro.
SeedRandom(31)

? ARandomNumberBetweenAnd( :Between = 5, :And = 10 )
#--> 5

pf()
