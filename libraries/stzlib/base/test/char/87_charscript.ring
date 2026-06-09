# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #87.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? CharScript(",") 	#--> common
? CharScript("⅀") 	#--> common
? CharScript("ظ") 	#--> arabic
? CharScript("ܞ")  	#--> syriac

? CharScript("డ") 	#--> telugu
? CharScript("ল") 	#--> bengali
? CharScript("Ϡ") 	#--> greek
? CharScript("Ж") 	#--> cyrillic
? CharScript("经") 	#--> han

pf()
# Executed in 0.02 second(s) in Ring 1.23
