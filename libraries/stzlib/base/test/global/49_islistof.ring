# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #49.

load "../../stzBase.ring"

pr()

? Q([ 1, 2, 3 ]).IsListOf(:Numbers)		#--> TRUE

? Q([ "A", "B", "C" ]).IsListOf(:Strings)	#--> TRUE

o1 = new stzNumber(10)

? Q([ o1, o1, o1 ]).IsListOf(:StzNumbers)	#--> TRUE

o1 = new stzString("A")
? Q([ o1, o1, o1 ]).IsListOf(:StzStrings)	#--> TRUE

? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:ListsOfNumbers)	#--> TRUE
? Q([ [1,2], [3,4], [5,6] ]).IsListOf(:PairsOfNumbers)	#--> TRUE

pf()
#--> Executed in 0.09 second(s).
