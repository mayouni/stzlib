# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #803.
#ERR Error (R41) : Invalid numeric string

load "../../stzBase.ring"

pr()

o1 = new stzString("Softanza loves simplicity")
? o1.ReplaceFirstQ( o1.Section(10, :LastChar), "arrives!").Content()
#--> "Softanza arrives!"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17
