# Narrative
# --------
# APPLICATION: LOTTERY NUMBER VALIDATION
#
# Extracted from stznumbrextest.ring, block #32.

load "../../../stzBase.ring"


pr()

oLottery = Nx("{@Digit(1-9)6:unique}")
? oLottery.Match(123456)  #--> TRUE
? oLottery.Match(123455)  #--> FALSE (not unique)
? oLottery.Match(123450)  #--> FALSE (contains 0)

pf()
