load "../stzbase.ring"

/*=== English

pr()

SetOrdinalLanguage("en")

? Ordinal(1)	#--> 1st
? Ordinal(2)	#--> 2nd
? Ordinal(3)	#--> 3rd
? Ordinal(11)	#--> 11th
? Ordinal(21)	#--> 21st

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*=== French

pr()

SetOrdinalLanguage("fr")

? Ordinal(1)	#--> 1er
? Ordinal(2)	#--> 2e
? Ordinal(10)	#--> 10ème

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*=== Arabic
*/
pr()

SetOrdinalLanguage("ar")

? Ordinal(1)	#--> الأوّل
? Ordinal(3)	#--> الثّالث
? Ordinal(5)	#--> الخامس

pf()
# # Executed in almost 0 second(s) in Ring 1.23
