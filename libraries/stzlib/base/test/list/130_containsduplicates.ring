# Narrative
# --------
# ContainsDuplicates() reports whether any value occurs more than once.
#
# The list here holds the string "2" and the number 2. Softanza
# treats these as distinct values -- a string and an integer are
# never equal -- so the list has no duplicates and the method
# returns FALSE. Note the boolean prints as 0 on the console, which
# is Ring's rendering of FALSE.
#
# Extracted from stzlisttest.ring, block #130.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "2", 2 ])
? o1.ContainsDuplicates()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19
