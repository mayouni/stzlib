# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? Q("AnnIE").NumberOfVowels() # same as ? Q("AnnIE").VowelN()
#--> 3

? Q("AnnIE").Vowels()
#--> [ "A", "I", "E" ]

? Q("AnnIE").Vowel() # A random vowel from the string
#--> E

? Q("AnnIE").VowelN() # N ~> Number of...
#--> 3

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.04 second(s) on Ring 1.21
# Executed in 0.07 second(s) on Ring 1.20
