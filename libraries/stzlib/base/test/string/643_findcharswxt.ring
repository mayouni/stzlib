# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #643.
#ERR Error (R14) : Calling Method without definition: findcharswxt

load "../../stzBase.ring"

pr()

o1 = new stzString("KALIDIA")

? o1.FindCharsWXT('@char = "I"')
#--> [ 4, 6 ]

pf()
# Executed in 0.08 second(s) in Ring 1.22
# Executed in 0.42 second(s) in Ring 1.18
# Executed in 0.52 second(s) in Ring 1.17
