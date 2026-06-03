# Narrative
# --------
# #NOTE This is an update of the next narration of the solution
#
# Extracted from stzhexnumbertTest.ring, block #8.

load "../../stzBase.ring"

# or the SPDS problem statement form RosettaCode. Here we
# rpovide a cleaner and more efficient solution:

pr()

? NFirstPrimesW(25, :Where = '{ 
	Q(@prime).DigitsQRT(:stzListOfNumbers).ArePrimes()
}')
#--> [
#	2, 3, 5, 7, 23, 37, 53,
#	73, 223, 227, 233, 257,
#	277, 337, 353, 373, 523,
#	557, 577, 727, 733, 757,
#	773, 2237, 2273
# ]

pf()
# Executed in 1.19 second(s) in Ring 1.21
