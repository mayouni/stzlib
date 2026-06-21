# Narrative
# --------
# Counting and locating a repeated value inside a stzList.
#
# Given the list [ 1, 2, 3, "*", 5, 6, "*", 8 ], HowMany("*")
# tallies how many times the value occurs (2). FindFirst("*")
# returns the position of the leftmost match (4) and FindLast("*")
# returns the position of the rightmost match (7). Together these
# form the Softanza idiom for asking "how often, and where" about a
# single value without writing a manual scan loop.
#
# Extracted from stzlisttest.ring, block #211.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8 ])

? o1.HowMany("*")
#--> 2

? o1.FindFirst("*")
#--> 4

? o1.FindLast("*")
#--> 7

pf()
# Executed in 0.03 second(s)
