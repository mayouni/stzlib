# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #320.

load "../../../stzBase.ring"


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
