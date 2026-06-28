# Narrative
# --------
# NestedSubStringsIB: split the (simplified) string at every bound marker and keep
# each fragment from one marker to the next INCLUSIVE -- so neighbours share a "["
# or "]". The trailing "] ]" pieces are the closing markers winding back out.
#
# Extracted from stzlisttest.ring, block #320.

load "../../stzBase.ring"

pr()

o1 = new stzString('[
	"1", "1",
		["2", "♥", "2"],
	"1",
		["2",
			["3", "♥",
				["4",
					["5", "♥"],
				"4",
					["5","♥"],
				"♥"],
			"3"]
		]

]')


? @@NL( o1.SimplifyQ().NestedSubStringsIB(:BoundedBy = [ "[", "]" ]) )
#--> [
#	'[ "1", "1", [',
#	'["2", "♥", "2"]',
#	'], "1", [',
#	'["2", [',
#	'["3", "♥", [',
#	'["4", [',
#	'["5", "♥"]',
#	'], "4", [',
#	'["5","♥"]',
#	'], "♥"]',
#	'], "3"]',
#	"] ]",
#	"] ]"
# ]

StopProfiler()
#--> Executed in 0.06 second(s)

pf()
