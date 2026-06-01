# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #831.

load "../../../stzBase.ring"


o1 = new stzString("0o20723.034")
o1 {
	? RepresentsNumber()			#--> TRUE
	? RepresentsSignedNumber()		#--> FALSE
	? RepresentsUnsignedNumber()		#--> TRUE
	? RepresentsCalculableNumber() + NL	#--> TRUE
	
	? RepresentsInteger()			#--> FALSE
	? RepresentsSignedInteger()		#--> FALSE
	? RepresentsUnsignedInteger()		#--> FALSE
	? RepresentsCalculableInteger()	 + NL	#--> FALSE
	
	? RepresentsRealNumber()		#--> TRUE
	? RepresentsSignedRealNumber()		#--> FALSE
	? RepresentsUnsignedRealNumber()	#--> TRUE
	? RepresentsCalculableRealNumber() + NL	#--> TRUE
	
	? RepresentsNumberInDecimalForm()	#--> FALSE
	? RepresentsNumberInBinaryForm()	#--> FALSE
	? RepresentsNumberInHexForm()		#--> FALSE
	? RepresentsNumberInOctalForm()		#--> TRUE
}

pf()
# Executed in 0.16 second(s) in Ring 1.22
