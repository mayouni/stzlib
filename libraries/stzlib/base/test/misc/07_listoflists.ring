# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #7.

load "../../stzBase.ring"

pr()

? @@NL( StzListOfListsQ([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]

]).SortedOnDown(2) )
#--> [
#	[ "Dan",      120 ],
#	[ "Roy",      100 ],
#	[ "Bob",       89 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
