# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #459.
#ERR Error (R14) : Calling Method without definition: removecharswxt

load "../../stzBase.ring"

pr()

o1 = new stzString("(9, 7, 8)")

o1.RemoveCharsWXT('Q(@Char).IsNumberInString()')
? o1.Content()
#--> (, , )

pf()
# Executed in 0.15 second(s) in Ring 1.22
