# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #38.

load "../../stzBase.ring"


? HowMany( ArabicLetters() ) # Or HowManyArabicLetters() or NumberOfArabicLetters()
#--> 28

? 10PercentOf( ArabicLetters() ) # Or NPercentOf(10, ArabicLetters())
#o--> [ "ص", "ة", "د", "ص" ]

#NOTE : there is an eXTended list of arabic leters

? HowMany( ArabicLettersXT() )
#--> 34

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19
