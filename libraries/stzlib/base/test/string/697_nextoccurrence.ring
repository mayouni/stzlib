# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #697.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")

? o1.NextOccurrence("Mio", :StartingAt = 1)
#--> 4

? o1.NthPreviousOccurrence(2, "Mio", :StartingAt = 15)
#--> 4

? o1.NthPreviousOccurrence(4, "Mio", :StartingAt = 25)
#--> 4

pf()
# Executed in 0.02 second(s).
