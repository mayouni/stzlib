# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #611.

load "../../../stzBase.ring"


pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NextNthMarquerST(2, :StartingAt = 14) # You can omit the ..ST()
	#--> #3
		# Or you can say:
		# ? NthNextMarquer(2, :StartingAt = 14)
	
	? FindNextNthMarquerST(2, :StartingAt = 14)
	#--> 44
		# Or you can say:
		# ? NextNthMarquerOccurrence(2, :StartingAt = 14)
		# ? NthNextMarquerOccurrence(2, :StartingAt = 14)
		# ? NextNthMarquerPosition(2, :StartingAt = 14)
		# ? NthNextMarquerPosition(2, :StartingAt = 14)

}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.70 second(s) in Ring 1.17
