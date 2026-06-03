# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #524.

load "../../stzBase.ring"


? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsWXT('isNumber(@item)')
#--> 3

? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsWXT('
	isString(@item) and Q(@item).isLetter()
')
#--> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsWXT('Q(@item).IsDividableBy(2)')
#--> 3

pf()
# Executed in 0.21s second(s).
