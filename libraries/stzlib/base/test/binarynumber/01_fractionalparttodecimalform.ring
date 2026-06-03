# Narrative
# --------
# pr()
#
# Extracted from stzbinarynumbertest.ring, block #1.

load "../../stzBase.ring"

pr()

decimals(10)

	# Creating a binary number from a binary form

	o1 = new stzBinaryNumber("0b01110111100111010.11101111")

	? o1.FractionalPartToDecimalForm()
	#--> 0.93359375
	
	? o1.ToDecimalForm()
	#--> 61242.93359375		#TODO check correctness!

decimals(2)

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.17
