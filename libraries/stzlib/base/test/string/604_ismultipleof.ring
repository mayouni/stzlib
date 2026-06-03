# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #604.
#ERR Error (R14) : Calling Method without definition: ismultipleof

load "../../stzBase.ring"

pr()

? Q("ArabicArabicArabic").IsMultipleOf("Arabic")
#--> TRUE

? Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic")
#--> TRUE

? Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic")
#--> FALSE

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", TRUE)
#--> FALSE

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
