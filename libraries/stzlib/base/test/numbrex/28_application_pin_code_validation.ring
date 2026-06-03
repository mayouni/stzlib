# Narrative
# --------
# APPLICATION: PIN CODE VALIDATION
#
# Extracted from stznumbrextest.ring, block #28.

load "../../stzBase.ring"


pr()

oPinValidator = Nx("{@Digit4:unique}")
? oPinValidator.Match(1234)  #--> TRUE
? oPinValidator.Match(1123)  #--> FALSE (not unique)
? oPinValidator.Match(9876)  #--> TRUE

pf()
