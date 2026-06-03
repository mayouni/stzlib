# Narrative
# --------
# // TODO: ERROR
#
# Extracted from stznumbertest.ring, block #76.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("27 898 116.56")
? o1.Structure(:AsListOfLists)
/*
	Returns:
	atrillions
		units: 0
		dozens: 0
		Thousands: 0
	abillions
		units:0
		dozens: 0
		Thousands: 0
	amillions
		units: 7
		dozens: 2
		Thousands: 0
	athousands
		units: 8
		dozens: 9
		Thousands: 8
	aHundreds
		units: 6
		dozens: 1
		Thousands: 1
*/
/*
? sin(13) # Gives 0.42
o1 = new stzNumber(13)
? o1.Sine() # Gives 0.4201670368266
/*
? IntegerPart(12.567)
? IsBit(3)

SetActiveRound(3)
? getActiveRound()

n = StringToNumber("12")
? n

? IsInteger(56.145)

? GetUnitsDozensAndThousands(125)
? GetMicroStructure(113)
/*
// Coverting a number from any form to any form

? NumberConvert("1031", :FromDecimal, :ToDecimal)
? NumberConvert("1031", :FromDecimal, :ToBinary)
? NumberConvert("1031", :FromDecimal, :ToOctal)
? NumberConvert("1031", :FromDecimal, :ToHex)
? ""
? NumberConvert("b10000000111", :FromBinary, :ToDecimal)
? NumberConvert("b10000000111", :FromBinary, :ToBinary)
? NumberConvert("b10000000111", :FromBinary, :ToOctal)
? NumberConvert("b10000000111", :FromBinary, :ToHex)
? ""
? NumberConvert("o2007", :FromOctal, :ToDecimal)
? NumberConvert("o2007", :FromOctal, :ToBinary)
? NumberConvert("o2007", :FromOctal, :ToOctal)
? NumberConvert("o2007", :FromOctal, :ToHex)
? ""
? NumberConvert("x407", :FromHex, :ToDecimal)
? NumberConvert("x407", :FromHex, :ToBinary)
? NumberConvert("x407", :FromHex, :ToOctal)
? NumberConvert("x407", :FromHex, :ToHex)



/*
? NumberIsInDecimalForm("1031")
? NumberIsInOctalForm("o2700")
? NumberIsInBinaryForm("b111010000010")
? StringContainsNumberInHexform("x407")
? ""

// Converting a decimal number to binary, octal and hex
o1 = new stzNumber("1031")
? o1.Number()
? o1.ToBinary()
? o1.ToOctal()
? o1.ToHex()
? ""

// Converting binary, octal and hex numbers to decimal
o1 = new stzNumber("")
o1.FromBinary("b10000000111")
? o1.Content()

o1.FromHex("x407")
? o1.Content()

o1.FromOctal("o2007")
? o1.Content()

pf()
