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
	? DozensInHundreds()	#--> 28
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
