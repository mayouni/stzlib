# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #18.
#ERR Error (R3) : Calling Function without definition: arandomposition

load "../../stzBase.ring"

pr()

Q("SOFTANZA") {

	? ARandomPosition()
	#--> 8

	? ARandomChar()
	#--> T

	? ARandomPositionGreaterThan(4)
	#--> 8

	? ARandomCharAfterPosition(4)
	#--> A

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomCharExcept("A")
	#--> S

	? ARandomPositionLessThan(4)
	#--> 2

	? ARandomCharBefore(4)
	#--> S

	? ARandomCharAfter("T")
	#--> N

	? ARandomCharBefore("T")
	#--> S

}

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
