# Narrative
# --------
# ReplaceThisItemAtPositions: value-GUARDED counterpart of block #47.
#
# Same positions [1,5] and same replacement "♥♥♥", but now a guard value
# "ring" is supplied: a position is only rewritten if it actually holds
# "ring". Positions 1 and 5 qualify, so the result matches the unguarded
# form -- the guard would only matter if a listed position held something
# else. (The commented CheckParamOff() is a speed knob, not behaviour.)
#
# Extracted from stzlisttest.ring, block #48.

load "../../stzBase.ring"

pr()

//CheckParamOff()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceThisItemAtPositions([ 1, 5 ], "ring", :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

pf()
# Executed in 0.16 second(s)
#NOTE : turn CheckParamsOff() to get 0.03
