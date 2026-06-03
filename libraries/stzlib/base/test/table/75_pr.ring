# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #75.

load "../../stzBase.ring"


o1 = new stzTable([
	[  "COL1",   "COL2" ],
	#-------------------#
	[     "a",    "R1"  ],
	[ "abcde",    "R5"  ],
	[   "abc",    "R3"  ],
	[    "ab",    "R2"  ],
	[     "b",    "R1"  ],
	[   "abcd",   "R4"  ]
])

? @@( o1.CellsInCols([:COL1, :COL2]) ) + NL
#--> [
#	"a", "abcde", "abc", "ab", "b", "abcd",
#	"R1", "R5", "R3", "R2", "R1", "R4"
# ]

? @@( o1.CellsInRows([1, 3, 5]) )
#--> [ "a", "R1", "abc", "R3", "b", "R1" ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.21 second(s) in Ring 1.17
