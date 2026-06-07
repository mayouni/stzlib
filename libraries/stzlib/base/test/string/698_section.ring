# Narrative
# --------
# *
#
# Extracted from stzStringTest.ring, block #698.
#ERR panic: integer part of floating point value out of bounds

load "../../stzBase.ring"

pr()

o1 = new stzString("216;TUNISIA;227;NIGER")

? o1.Section(5, o1.NextOccurrence( :Of = ";", :StartingAt = 5 ) - 1 )
#--> TUNISIA

pf()
# Executed in 0.01 second(s).
