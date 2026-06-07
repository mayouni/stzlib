# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #438.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

? Q("ONE-TWO-THREE").Split("-")
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE").SplitAtCharsWXT('{ Q(@char).IsNotLetter() }')
#--> [ "ONE", "TWO", "THREE" ]

pf()
# Executed in 0.18 second(s) in Ring 1.21
