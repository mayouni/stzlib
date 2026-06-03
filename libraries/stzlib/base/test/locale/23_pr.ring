# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #23.

load "../../stzBase.ring"


StzLocaleQ([ :Language = :Persian ]) {
	? Abbreviation()			 				#--> fa_IR
	? NthDayOfWeek(1)						 	#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> شنبه

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> دوشنبه

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> د
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
