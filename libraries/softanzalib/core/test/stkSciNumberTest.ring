
load "../number/stzSciNumber.ring"


? Number2Sci(324_987_182_091_876_345)
#--> '3.25e17'

? Sci2Number('3.25e17')
#--> 325_000_000_000_000_000.00

# Note how Ring rounded that big number, because the underling
# C DOUBLE type used can't represent it.
