# Narrative
# --------
# Builds a stzList from a character range and grows it with ExtendWith().
#
# The colon form stzList("A" : "C") asks Softanza to materialize the
# inclusive character range A through C, yielding [ "A", "B", "C" ].
# ExtendWith() then appends the items of another list ("D", "E") onto
# the tail in place, so the list becomes [ "A", "B", "C", "D", "E" ].
# This contrasts with AddItem (one element) -- ExtendWith splices a
# whole list, keeping the result a flat sequence rather than nesting.
# pr()/pf() wrap the block in the profiler; the "STOPPED!" banner is
# the success marker, not an error.
#
# Extracted from stzlisttest.ring, block #151.

load "../../stzBase.ring"

pr()

o1 = new stzList("A" : "C")
o1.ExtendWith(["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.04 second(s)
# Including 0.02 seconds consumed by the Show() function
