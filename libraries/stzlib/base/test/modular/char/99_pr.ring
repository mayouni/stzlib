# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #99.

load "../../../stzBase.ring"


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
