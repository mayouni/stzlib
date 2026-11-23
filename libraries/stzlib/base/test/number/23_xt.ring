# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #23.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering several.
# One seed governs both generators since 2026-08-07 -- see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine Xoshiro.
SeedRandom(31)

# The comment that stood here said "To include bounds (1 and 5) use ...XT()", and
# it was wrong twice. ARandomNumberBetweenAnd ALREADY includes both bounds
# (stzRandom.ring:1223 passes 0 for the strict flag); the exclusive form is
# ARandomNumberStrictlyBetweenAnd. And ARandomNumberXT is the SEEDED variant,
# not the bound-inclusive one -- stzRandom.ring:1219 warns about exactly this
# reading of the XT suffix. The file is still named 23_xt.ring after the belief.
? ARandomNumberBetweenAnd( :Between = 1, :And = 5 )
#--> 1

pf()
