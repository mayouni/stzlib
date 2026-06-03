# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #22.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

? ACharOtherThan("y")
#--> 

? ACharOtherThan("䛂")
#--> "≜"
#--> "㎍"
#--> "⟶"
#--> "ਭ"

pf()
# Executed in 1.37 second(s) in Ring 1.23
