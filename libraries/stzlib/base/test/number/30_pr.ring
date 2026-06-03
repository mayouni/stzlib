# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #30.

load "../../stzBase.ring"


? Q(25).MultiplesUntilQRT(1080, :stzListOfNumbers).
	LeastCommonNumber(:With = Q(42).MultiplesUntil(1080) )

#--> 1050

	# Executed in 1.48 second(s) in Ring 1.19
	# Executed in 2.51 second(s) in Ring 1.18
	# Executed in 4.45 second(s) in Ring 1.17

# Ok, but how this is found in practice, like if we make it by hand?
# First, let's see the multiples of 25 under 1080

aList1 = Q(25).Multiples(:Under = 1080) # Use ? @@( aList1 ) to show the list

#--> [
#	25, 50, 75, 100, 125,
#	150, 175, 200, 225, 250,
#	275, 300, 325, 350, 375,
#	400, 425, 450, 475, 500,
#	525, 550, 575, 600, 625,
#	650, 675, 700, 725, 750,
#	775, 800, 825, 850, 875,
#	900, 925, 950, 975,
#	1000, 1025, 1050, 1075
# ]

	# Executed in 1.00 second(s) in Ring 1.19 (64 Bits)
	# Executed in 1.62 second(s) in Ring 1.18
	# Executed in 2.84 second(s) in Ring 1.17

# Then we look to the multiples of 42 under 1080

aList2 = Q(42).Multiples(:Under = 1080) # Use ? @@( aList2 ) to show the list

#--> [
#	42, 84, 126, 168, 210,
#	252, 294, 336, 378, 420,
#	462, 504, 546, 588, 630,
#	672, 714, 756, 798, 840,
#	882, 924, 966, 1008, 1050
# ]

	# Executed in 0.65 second(s) in Ring 1.19
	# Executed in 1.64 second(s) in Ring 1.18
	# Executed in 1.70 second(s) in Ring 1.17

# We can visually recognize 1050 as the Least Common Multiplier between
# the two numbers (25 and 42) before we exceed 1080.

# We can get this instantly by saying:

? StzListOfNumbersQ(aList1).LeastCommonNumber(aList2)
#--> 1050

pf()
# Executed in 0.85 second(s) in Ring 1.19 (64 Bits)
# Executed in 1.41 second(s) in Ring 1.18
# Executed in 2.35 second(s) in Ring 1.17
