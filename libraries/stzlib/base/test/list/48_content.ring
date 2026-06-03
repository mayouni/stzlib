# Narrative
# --------
# pr()
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
