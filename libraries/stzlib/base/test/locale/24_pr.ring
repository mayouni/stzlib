# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #24.

load "../../stzBase.ring"


StzLocaleQ([ :Script = :Arabic ]) {
	? Abbreviation()			 				#--> ar_EG
	? NthDayOfWeek(1)			 				#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> السبت

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> الاثنين

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> ن
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
