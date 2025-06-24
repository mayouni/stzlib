
load "../stzmax.ring"


? Number2Sci(324_987_182_091_876_345)
#--> '3.25e17'

? Sci2Number('3.25e17') + NL
#--> 325_000_000_000_000_000.00

# Note how Ring rounded that big number, because the underling
# C DOUBLE type used can't represent it.

? "---" + NL

# The minimum number Ring can represent is "2.2250738585072014e-308"

decimals(15)

? Sci2Number("2.2250738585072014e-308") + NL

# And the maximum number is "1.7976931348623157e+308"

?  Sci2Number("1.7976931348623157e+308")
