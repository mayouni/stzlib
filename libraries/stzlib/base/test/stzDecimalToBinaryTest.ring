load "../stzbase.ring"

pr()

o1 = new stzDecimalToBinary("-12.05")
? o1.ToBinaryForm()
#--> 0b-1100.0000110011001100110

pf()
# Executed in 0.05 second(s) in Ring 1.21
