# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #323.
#ERR Error (R14) : Calling Method without definition: replaceanyboundedby

load "../../stzBase.ring"

pr()

o1 = new stzString('[[[
	"1", "1",
		[[["2", "♥", "2"]]],
	"1",
		[[["2",
			[[["3", "♥",
				[[["4",
					[[["5", "♥"]]],
				"4",
					[[["5","♥"]]],
				"♥"]]],
			"3"]]]
		]]]

]]]')

o1.ReplaceAnyBoundedBy([ "[", "]" ], "***")
? o1.Content()
#-->
# [***]]],
#	"1",
#		[***]]],
#				"4",
#					[***]]],
#				"♥"]]],
#			"3"]]]
#		]]]
#
# ]]]

StopProfiler()

pf()
# Executed in 0.04 second(s)
