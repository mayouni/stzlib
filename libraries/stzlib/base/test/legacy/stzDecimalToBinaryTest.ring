load "../stzbase.ring"

/*---

pr()

o1 = new stzDecimalToBinary("-12.05")
? o1.ToBinaryForm()
#--> 0b-1100.0000110011001100110

pf()
# Executed in 0.09 second(s) in Ring 1.23

/*--- Positive integer

pr()

o1 = new stzDecimalToBinary("42")
? o1.ToBinaryForm()
#--> 0b101010

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Positive decimal number

pr()

o1 = new stzDecimalToBinary("10.75")
? o1.ToBinaryForm()
#--> 0b1010.11

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Negative integer

pr()

o1 = new stzDecimalToBinary("-7")
? o1.ToBinaryForm()
#--> 0b-111

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- Zero

pr()

o4 = new stzDecimalToBinary("0")
? o4.ToBinaryForm()
#--> 0b0

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Test 5: Negative decimal number
*/
pr()

o5 = new stzDecimalToBinary("-0.625")
? o5.ToBinaryForm()
#--> 0b-0.101

pf()
# Executed in 0.06 second(s) in Ring 1.23
