# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #468.

load "../../stzBase.ring"


? Q(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	Value()

	#--> 45

? @@( Qh(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	History() )

	#--> [ 13000, 11500, 23, 46 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
