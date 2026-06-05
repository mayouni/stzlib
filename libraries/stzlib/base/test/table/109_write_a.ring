# Narrative
# --------
# #todo write a #narration
#
# Extracted from stztabletest.ring, block #109.

load "../../stzBase.ring"


pr()

o1 = new stzTable([
	[ :ID,	   :EMPLOYEE, 	:SALARY   ],
	#---------------------------------#
	[ "001",   "Salima", 	12499.20  ],
	[ "002",   "Sonia", 	10000.10  ],
	[ "003",   "So",	12780.45  ],
	[ "004",   "GonSonSo", 	12740.30  ],
	[ "005",   "Mansour", 	10000.10  ],
	[ "006",   "so", 	14800.10  ]
])

? @@( o1.FindInCol(:EMPLOYEE, "---") ) + NL
#--> [ ]

? @@( o1.FindInCol(:EMPLOYEE, "So") ) + NL
#--> [ [ 2, 3 ] ]

? @@( o1.FindInColCS(:EMPLOYEE, "So", :CS = FALSE) ) + NL
#--> [ [ 2, 3 ], [ 2, 6 ] ]

? @@NL( o1.FindInCol(:EMPLOYEE, :SubValue = "So") ) + NL
#--> [
#	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	]
# ]

? @@NL( o1.FindInColCS(:EMPLOYEE, :SubValue = "So", :CS = FALSE) )
#--> [
# 	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	],
#	[ [ 2, 5 ], [ 4 ] 	],
#	[ [ 2, 6 ], [ 1 ] 	]
# ]

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.55 second(s) in Ring 1.17
