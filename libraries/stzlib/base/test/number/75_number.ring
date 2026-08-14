# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #75.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("259715288")
o1 {
	? Number()

	? UnitsInHundreds() 	#--> 8
	# 8, the dozens DIGIT -- the class's own doc says so, and its two
	# siblings here already read digit-wise (units 8, hundreds 2). The
	# old promise of 28 was the cumulative count-of-tens reading, which
	# neither sibling uses; a mixed convention satisfies no one.
	? DozensInHundreds()	#--> 8
	? HundredsInHundreds()	#--> 2
}

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*

o1 = new stzNumber(12_531_078_512_456)
? o1.Structure()
? o1.AllUnits()

o1 {
	? Billions()
	? BillionsXT()
	
	? UnitsInBillions()
	? DozensInBillions()
	? HundredsInBillions()
	
	? HasBillions()
}

/*
o1 = new stzNumber("2345")
? o1.Sign()
? o1.IsPositive()

*/
