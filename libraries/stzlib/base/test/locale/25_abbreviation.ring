# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #25.

load "../../stzBase.ring"

pr()

StzLocaleQ([ :Language = :russian, :Country = :Russia ]) {
	? Abbreviation()			 				#--> ru_RU
	? NthDayOfWeek(1)							#--> monday
	? NativeNthDayOfWeek(1) + NL		 		#--> понедельник

	? NthDayOfWeekAbbreviation(1)		 		#--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> пн

	? NthDayOfWeekSymbol(1)			 			#--> M
	? NativeNthDayOfWeekSymbol(1)		 		#--> пн
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
