# Narrative
# --------
# NumberOfOccurrence(value) counts how many times a value appears in a list.
#
# The list is built as 1:14 + 12, which expands the range 1..14 and then
# appends a second 12, giving [1,2,...,14,12]. Because 12 now appears both
# inside the original range and as the appended tail item, asking the list
# how many times 12 occurs returns 2. This is the Softanza idiom for a
# straightforward value tally over a flat list, distinct from position-
# finding: it answers "how many", not "where".
#
# Extracted from stzlisttest.ring, block #186.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:14 + 12)
? o1.NumberOfOccurrence(12)
#--> 2

pf()
# Executed in 0.03 second(s)
