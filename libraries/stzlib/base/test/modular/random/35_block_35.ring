# Narrative
# --------
# *
#
# Extracted from stzrandomtest.ring, block #35.

load "../../../stzBase.ring"

pr()

# Softanza can generate random real numbers in the range 0 to 1

? random01() # Or StzRandom01()
#--> 0.31

? ARandomNumberLessThan01(0.7)
#--> 0.52

? RandomRound()
#--> 3

	decimals(3)
	
	? random01() # Or StzRandom01()
	#--> 0.949
	
	? ARandomNumberLessThan01(0.7)
	#--> 0.557

SetRandomRound(5)
? RandomRound()
#--> 5

	decimals(5)
	
	? random01() # Or StzRandom01()
	#--> 0.91723
	
	? ARandomNumberLessThan01(0.5)
	#--> 0.26434

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.15 second(s) in Ring 1.20
