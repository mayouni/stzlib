# Narrative
# --------
# Example 4: From epoch duration hash
#
# Extracted from stzdatetimetest.ring, block #65.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([
    :FromEpochDuration = [
        :Years = 54,
        :Months = 9,
        :Days = 3,
        :Hours = 14,
        :Minutes = 30
    ]
])
? oDateTime.ToISO()
#--> 2024-09-21 9:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
