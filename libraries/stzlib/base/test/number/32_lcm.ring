# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #32.

load "../../stzBase.ring"

pr()

# Least common multiplier between 25 and 42
? Q(25).LCM(42)
#--> 1050

? @@( Q(1050).PrimeFactorsXT() ) + NL
#--> [ [ 2, 525 ], [ 3, 350 ], [ 5, 210 ], [ 7, 150 ] ]

? @@( Q(1050).FactorsXT() )
#--> [
#	[ 1, 1050 ], [ 2, 525 ], [ 3, 350 ],
#	[ 5, 210 ], [ 6, 175 ], [ 7, 150 ],
#	[ 10, 105 ], [ 14, 75 ], [ 15, 70 ],
#	[ 21, 50 ], [ 25, 42 ], [ 30, 35 ],
#	[ 35, 30 ], [ 42, 25 ], [ 50, 21 ],
#	[ 70, 15 ], [ 75, 14 ], [ 105, 10 ],
#	[ 150, 7 ], [ 175, 6 ], [ 210, 5 ],
#	[ 350, 3 ], [ 525, 2 ], [ 1050, 1 ]
# ]

pf()
# Executed in 0.51 second(s) in Ring 1.19
# Executed in 0.68 second(s) in Ring 1.17
