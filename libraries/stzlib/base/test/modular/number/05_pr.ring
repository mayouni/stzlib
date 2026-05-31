# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #5.

load "../../../stzBase.ring"


? Q(169).IsPrime()
#--> FALSE

? Q(17).IsPrime()
#--> TRUE

? @@( Q(54).Divirdos() ) + NL	# Misspelled, but works!
#--> [ 1, 2, 3, 6, 9, 18, 27, 54 ]

? @@( Q(54).Factors() ) + NL
#--> [ 1, 2, 3, 6, 9, 18, 27, 54 ]

? @@( Q(54).PrimeFactors() ) + NL
#--> [ 2, 3 ]

? @@( Q(54).PrimeDividors() )
#--> [ 2, 3 ]

pf()
# Executed in 0.04 second(s)
