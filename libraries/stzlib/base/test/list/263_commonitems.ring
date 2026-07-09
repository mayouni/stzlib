# Narrative
# --------
# CommonItems(:With=) returns the set intersection of two lists.
#
# The host stzList keeps only the items that also appear in the
# argument list, and the result is emitted in the host's own order
# (Ring then Python here), not the argument's order. This is the
# Softanza idiom for "what do these two collections share" -- a
# named-argument call (:With=) that reads like prose and leaves the
# host list untouched while returning a fresh intersection list.
#
# Extracted from stzlisttest.ring, block #263.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ring", "Ruby", "Python" ])

? o1.CommonItems(:With = [ "Julia", "Ring", "Go", "Python" ])
#--> [ "Ring", "Python" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
