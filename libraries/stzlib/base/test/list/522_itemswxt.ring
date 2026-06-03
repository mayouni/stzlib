# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #522.

load "../../stzBase.ring"

pr()

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWXTQ('{

	isNumber(@item) and
	Q(@item).IsDividableBy(2)

}').NumberOfItems()
#--> 3

pf()
# Executed in 0.14 second(s).
