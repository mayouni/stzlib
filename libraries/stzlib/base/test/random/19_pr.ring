# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #19.

load "../../stzBase.ring"


Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? ARandomPosition()
	#--> 3

	? ARandomItem()
	#--> S

	? ARandomPositionGreaterThan(4)
	#--> 5

	? ARandomItemAfterPosition(4)
	#--> N

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomItemExcept("A")
	#--> Z

	? ARandomPositionLessThan(4)
	#--> 3

	? ARandomItemBeforePosition(4)
	#--> O

	? ARandomItemAfter("T")
	#--> A

	? ARandomItemBefore("T")
	#--> O

}

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
