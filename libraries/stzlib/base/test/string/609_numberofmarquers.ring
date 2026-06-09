# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #609.

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NumberOfMarquers()
	#--> 4

	? FirstMarquer()
	#--> #1

	? FindFirstMarquer()
	#--> 12
		# You can also say:
		# ? FirstMarquerOccurrence()
		# ? FirstMarquerPosition()

	? LastMarquer()
	#--> #1
	
	? FindLastMarquer()
	#--> 66
		# You can also say:
		# ? LastMarquerOccurrence()
		# ? LastMarquerPosition()

}

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 1.64 second(s) in Ring 1.21
# Executed in 1.64 second(s) in Ring 1.19
