# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #23.

load "../../stzBase.ring"

pr()

StzLocaleQ([ :Language = :Persian ]) {
	? Abbreviation()			 				#--> fa_IR
	? NthDayOfWeek(1)						 	#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> شنبه

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> شنب

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> ش
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
