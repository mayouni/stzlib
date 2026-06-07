# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #61.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzString("ring ruby ring php ring")

o1.ReplaceSubstringAtPositions([ 1, 20 ], "ring", :By = "♥♥♥")
? o1.Content()
#--> "♥♥♥ ruby ring php ♥♥♥"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.17
