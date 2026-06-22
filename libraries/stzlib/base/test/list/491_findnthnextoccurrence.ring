# Narrative
# --------
# Locating the Nth *next* occurrence of a value, counting forward from a start position.
#
# The list [ "mio", "mia", "mio", "mix", "miz", "mix" ] has "mix" at positions 4 and 6.
# FindNthNextOccurrence(2, :Of="mix", :StartingAt=3) walks forward from index 3 and
# returns the position of the 2nd "mix" found, which is 6. The named-parameter form
# (:Of, :StartingAt) reads like prose and makes the search intent explicit. Softanza
# exposes the same operation under four interchangeable names -- FindNthNextOccurrence,
# FindNextNthOccurrence, NthNextOccurrence, and NextNthOccurrence -- so the call site
# can pick whichever word order reads best; all four return the same position, 6.
#
# Extracted from stzlisttest.ring, block #491.

load "../../stzBase.ring"

pr()

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
