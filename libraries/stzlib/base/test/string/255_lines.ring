# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #255.
#ERR Error (R14) : Calling Method without definition: ismadeofnumbers

load "../../stzBase.ring"

pr()

o1 = new stzString("ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

? o1.Lines()[3]
#--> "123346"

? Q( o1.Lines()[3] ).IsMadeOfNumbers()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.18
