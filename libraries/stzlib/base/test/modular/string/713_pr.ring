# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #713.

load "../../../stzBase.ring"


? Q("~~H/U/S/S/E/I/N~~").CharsWXT('{ Q(@char).isLetter() }')
#--> [ "H","U","S","S","E","I","N" ]

? Q("~~H/U/S/S/E/I/N~~").NumberOfCharsWXT('{ Q(@char).isLetter() }')
#--> 7

pf()
# Executed in 0.36 second(s).
