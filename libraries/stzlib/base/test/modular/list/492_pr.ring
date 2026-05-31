# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #492.

load "../../../stzBase.ring"


o1 = new stzList([ "mio", "mix", "mia", "mio", "mix", "miz", "mix" ])

? o1.FindPreviousNthOccurrence( 2, :Of = "mix", :StartingAt = 6)
#--> 2

pf()
# Executed in 0.05 second(s).
