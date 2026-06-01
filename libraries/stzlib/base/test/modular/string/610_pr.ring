# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #610.

load "../../../stzBase.ring"


StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NthMarquer(2)
	#--> #2

	? FindNthMarquer(2)
	#--> 26
		# You can also say:
		# ? NthMarquerOccurrence(2)
		# ? NthMarquerPosition(2)
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.63 second(s) in Ring 1.19
