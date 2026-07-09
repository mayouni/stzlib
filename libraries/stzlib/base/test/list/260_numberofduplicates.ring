# Narrative
# --------
# Counts and lists the values that appear more than once in a stzList.
#
# Given [ "*", "4", "*", "3", "4" ], two values recur: "*" and "4".
# NumberOfDuplicates() reports how many distinct values are duplicated
# (2 here, not the number of extra copies), while Duplicates() returns
# the set of those repeated values in first-seen order, [ "*", "4" ].
# Each duplicated value is reported once regardless of how many times
# it appears.
#
# Extracted from stzlisttest.ring, block #260.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "*", "4", "*", "3", "4" ])

? o1.NumberOfDuplicates() + NL
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.08 second(s) before
