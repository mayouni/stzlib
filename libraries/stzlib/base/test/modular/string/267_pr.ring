# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #267.

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

? @@( o1.DeepFindBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 17, 29 ], [ 77, 84 ], [ 103, 109 ], [ 66, 119 ], [ 51, 128 ], [ 42, 132 ], [ 2, 135 ] ]

pf()
# Executed in 0.03 second(s)
