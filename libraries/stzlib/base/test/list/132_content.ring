# Narrative
# --------
# Removing duplicate items from a list in place with RemoveDuplicates().
#
# RemoveDuplicates() keeps the FIRST occurrence of each distinct value and
# drops every later repeat, so the original ordering of survivors is preserved.
# Distinctness is type-aware: the string "2" and the number 2 are different
# values and both survive, just as Softanza never silently coerces a quoted
# digit into an integer. Here the nine-item list collapses to its five
# distinct values: "A", "B", the string "2", the number 2, and ".".
#
# Extracted from stzlisttest.ring, block #132.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "2", 2, "." ]

pf()
# Executed in almost 0 second(s).
