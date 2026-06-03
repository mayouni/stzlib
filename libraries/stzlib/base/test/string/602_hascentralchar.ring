# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #602.
#ERR Error (R14) : Calling Method without definition: hascentralchar

load "../../stzBase.ring"

pr()

? Q("RINGO").HasCentralChar()
#--> TRUE

? Q("RINGO").CentralChar()
#--> N

? Q("RINGO").PositionOfCentralChar()
#--> 3

? Q("RINGO").HasThisCentralChar("N")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
