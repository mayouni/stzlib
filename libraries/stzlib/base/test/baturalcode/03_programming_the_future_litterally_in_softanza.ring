# Narrative
# --------
# #todo #narration PROGRAMMING THE FUTURE, LITTERALLY, IN SOFTANZA
#
# Extracted from stzbaturalcodetest.ring, block #3.
#ERR Error (R14) : Calling Method without definition: isuppercasedfq

load "../../stzBase.ring"


pr()

? BeforeQ("ringo").IsUppercasedFQ().
	RemoveFFQ("o").
	AndThenQ().ReturnIt()
#--> RING

? BeforeQ("ringo").IsUppercasedFQ().AndThenQ().SpacifiedFQ().
	RemoveFFQ(" o").
	BoundItWithQ([ "<< ", :and = " >>" ]).
	AndFinallyQ().ReturnIt()
#--> << R I N G O >>

? BeforeQ('').UppercasingFQ("ringo").
	RemoveFFQ("o").FromItQ().
	SpacifyItQ().
	AndThenQ().ReturnIt()
#--> R I N G

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.06 second(s) in Ring 1.20
