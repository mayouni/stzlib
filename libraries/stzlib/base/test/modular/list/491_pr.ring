# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #491.

load "../../../stzBase.ring"


o1 = new stzList([ "mio", "mia", "mio", "mix", "miz", "mix" ])

? o1.FindNthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

# Other alternatives are:
? o1.FindNextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

? o1.NthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

? o1.NextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

pf()
# Executed in almost 0 second(s).
