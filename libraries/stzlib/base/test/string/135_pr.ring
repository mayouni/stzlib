# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #135.
#ERR Error (R14) : Calling Method without definition: show

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendWith("DE")
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
