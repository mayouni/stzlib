# Narrative
# --------
# APPLICATION: CRYPTO KEY VALIDATION
#
# Extracted from stznumbrextest.ring, block #29.

load "../../../stzBase.ring"


pr()

oKeyValidator = Nx("{@Property(Prime) & @Digit3+}")
? oKeyValidator.Match(101)  #--> TRUE (prime, 3 digits)
? oKeyValidator.Match(103)  #--> TRUE (prime, 3 digits)
? oKeyValidator.Match(100)  #--> FALSE (not prime)
? oKeyValidator.Match(97)   #--> FALSE (only 2 digits)

pf()
