# Narrative
# --------
# TURNABLE NUMBERS
#
# Extracted from stzchartest.ring, block #8.

load "../../stzBase.ring"


#TODO // Add TurnUp, TurnDown, Turn, IsTurnedUp, IsTurnedDown
# here in stzChar then in stzString

pr()

? @@(TurnableNumbers())
#--> [ 2, 3 ]

? @@(TurnableNumbersUnicodes())
#--> [ 2, 3 ]

? @@(TurnableNumbersXT()) #NOTE// Font in Notepad may not show the turned numbers
#--> [ [ 2, "↊" ], [ 3, "↋" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.11 second(s) in Ring 1.20
