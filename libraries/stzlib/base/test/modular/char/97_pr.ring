# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #97.

load "../../../stzBase.ring"


o1 = new stzChar("ﮘ")
o1 {
	? Content()			#--> ﮘ
	? Unicode()			#--> 64408

	? IsArabic()			#--> TRUE
	? IsArabicLetter()		#--> TRUE

	? IsArabicPresentationForm()	#--> TRUE
	? IsArabicPresentationFormA()	#--> TRUE
	? IsArabicPresentationFormB()	#--> FALSE
}

pf()
# Executed in 0.03 second(s) in Ring 1.23
