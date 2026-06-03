# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #696.

load "../../stzBase.ring"

pr()

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")

? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 1)
#--> 4

? o1.FindNextNthOccurrence(2, "Mio", :StartingAt = 7)
#--> 16

? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 20)
#--> 22

pf()
# Executed in 0.01 second(s).
