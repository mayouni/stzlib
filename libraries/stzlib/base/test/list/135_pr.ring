# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #135.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveNonDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "A", "A", "B", 2, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

# Enhancing Your Mental Model with Softanza: A Case Study of List Sorting
# Let's explore how Softanza improves the programming experience by examining
# the sort() function implementation
