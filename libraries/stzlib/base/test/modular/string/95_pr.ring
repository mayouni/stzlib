# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #95.

load "../../../stzBase.ring"


? @@( Digits() )
#--> [0, 1, 2, 3, 4, 5, 6, 7, 8 , 9 ]

? Q(5).IsADigit() # In this case, Q() transforms 5 to a stzNumber object
#--> TRUE

? Q("3").IsADigitInString() # In this case, Q() transforms 5 to a stzString object
#--> TRUE

? Q("").IsADigitInString() # Idem
#--> FALSE

? Q("125").IsADigitInString() # Idem
#--> FALSE

? QQ("3").IsADigit() #  In this case, QQ() transforms "3" to a stzChar object
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.22
