# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #73.

load "../../stzBase.ring"

pr()

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

o1.SortOn(:COL2)

? o1.Show() + NL
#--> COL1   COL2
#   ------ -----
#       a     R1
#       b     R1
#      ab     R2
#     abc     R3
#    abcd     R4
#   abcde     R5

o1.SortDownOn(:COL2)

o1.Show()
#--> COL1   COL2
#   ------ -----
#   abcde     R5
#    abcd     R4
#     abc     R3
#      ab     R2
#       b     R1
#       a     R1

pf()
# Executed in 0.29 second(s)
