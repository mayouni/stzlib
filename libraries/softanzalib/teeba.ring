load "stzlib.ring"

pron()

n1 = 6405
n2 = 10

? GCD(n1, n2) # GreatestCommonDivisor()
#--> 4

? @@( Factors(n1) ) + NL
#--> [ 1, 2, 3, 4, 6, 9, 12, 18, 27, 36, 54, 81, 108, 162, 324 ]

? @@( Factors(n2) )
#--> [ 1, 2, 4, 8, 16, 32, 64 ]

? Max( CommonNumbers([ Factors(n1), Factors(n2) ]) )
#--> [ 1, 2, 4 ]

proff()
