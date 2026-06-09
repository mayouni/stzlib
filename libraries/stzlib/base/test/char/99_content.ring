# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #99.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("۩")
o1 {
	? Content()			#--> ۩
	? Unicode()			#--> 1769

	? IsArabic()			#--> TRUE
	? IsArabicLetter()		#--> FALSE

	? IsQuranicSign()		#--> TRUE
}

pf()
# Executed in 0.02 second(s) in Ring 1.23
