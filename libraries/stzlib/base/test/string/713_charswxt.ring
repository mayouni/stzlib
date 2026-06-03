# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #713.
#ERR Error (R14) : Calling Method without definition: charswxt

load "../../stzBase.ring"

pr()

? Q("~~H/U/S/S/E/I/N~~").CharsWXT('{ Q(@char).isLetter() }')
#--> [ "H","U","S","S","E","I","N" ]

? Q("~~H/U/S/S/E/I/N~~").NumberOfCharsWXT('{ Q(@char).isLetter() }')
#--> 7

pf()
# Executed in 0.36 second(s).
