# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #11.

load "../../stzBase.ring"

pr()

n1 = 6405
n2 = 10

? GCD(n1, n2) # GreatestCommonDivisor()
#--> 5

? @@( Factors(n1) ) + NL
#--> [ 1, 3, 5, 7, 15, 21, 35, 61, 105, 183, 305, 427, 915, 1281, 2135, 6405 ]

? @@( Factors(n2) )
#--> [ 1, 2, 5, 10 ]

? Max( CommonNumbers([ Factors(n1), Factors(n2) ]) )
#--> 5

pf()
# Executed in 0.04 second(s)
