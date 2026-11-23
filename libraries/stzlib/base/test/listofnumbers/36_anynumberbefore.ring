# Narrative
# --------
# */
#
# Extracted from stzlistofnumberstest.ring, block #36.

load "../../stzBase.ring"

pr()

# SEEDED, so this file asserts one value instead of remembering five.
#
# It used to carry five #--> lines -- 102, 4, 4, 12 and 192 -- each a draw
# somebody saw on some run. Four of the five diverge on every run by
# construction, whatever the library does, and WHICH four changes run to run:
# the corpus sweep read this file as 5 divergences on 2026-11-17 and 4 on
# 2026-11-23 without the library changing at all.
#
# 192 IS NOT IN THE LIST. The numbers before 22 are 12, 4, 35 and 102, so that
# promise recorded a defect, not a draw. Measured again 2026-11-23 over 3 runs:
# 12, 102, 102 -- every value legal. The defect behind 192 is gone, and the
# promise outlived it as a permanent false accusation against working code.
#
# One seed governs both generators since 2026-08-07 (see StzSRandom in
# base/number/stzRandom.ring: all library draws route to the engine's Xoshiro,
# and the builtin is seeded alongside it), so a seeded draw is reproducible.
SeedRandom(31)

# Measured, not predicted: seed 31 draws 12 in three separate processes, and
# seed 77 draws 4 in three more -- so the seed is genuinely in play and the
# value below is reproducible rather than remembered.
? QQ([ 12, 4, 35, 102, 22, 98, 5 ]).AnyNumberBefore(22)
#--> 12


pf()
# Executed in 0.01 second(s)
