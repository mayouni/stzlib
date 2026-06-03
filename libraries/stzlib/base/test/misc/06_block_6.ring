# Narrative
# --------
# #ring #perf
#
# Extracted from stzmisctest.ring, block #6.

load "../../stzBase.ring"


pr()

? @@NL( sort([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]
], 2) )

pf()
#-->
'
[
	[ "Bob", 89 ],
	[ "Roy", 100 ],
	[ "Dan", 120 ]
]

'
# Executed in almost 0 second(s) in Ring 1.21
#--> Executed in 0.03 second(s) in Ring 1.20
