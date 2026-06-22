# Narrative
# --------
# Locating every position of a repeated value in a list, then counting it.
#
# FindAll scans the list and returns the 1-based positions of all cells
# whose value equals the search term. Here the value 120 sits at
# positions 3 and 6, so FindAll(120) yields [ 3, 6 ]. NumberOfOccurrence
# answers the companion question -- how many times the value appears --
# which is simply the length of that position list, giving 2. The pair
# is the canonical Softanza idiom: FindAll for "where", NumberOfOccurrence
# for "how many", both driven by the same value-equality scan.
#
# Extracted from stzlisttest.ring, block #489.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindAll(120)
#--> [ 3, 6 ]

? o1.NumberOfOccurrence(120)
#--> 2

pf()
# Executed in 0.01 second(s).
