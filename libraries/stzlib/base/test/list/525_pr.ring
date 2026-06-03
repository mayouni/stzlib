# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #525.

load "../../stzBase.ring"


? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT(' isNumber(@item) ')
#--> [1, 2, 3]

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT('
	isString(@item) and Q(@item).IsLetter()
') #--> [ "A", "B", "C" ]

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWXT('Q(@item).IsDividableBy(2)')
#--> [2, 4, 6]

pf()
# Executed in 0.22 second(s).
