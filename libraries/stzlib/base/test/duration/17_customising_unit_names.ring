# Narrative
# --------
# Customising unit names
#
# Extracted from stzdurationtest.ring, block #17.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Global unit container
? @@NL($aUnitNames)
#--> [
#    [:Days, "day", "days"],
#   [:Hours, "hour", "hours"],
#   [:Minutes, "minute", "minutes"],
#   [:Seconds, "second", "seconds"]
# ]

# Change to abbreviated forms
$aUnitNames = [
    [:Days, "d", "d"],
    [:Hours, "h", "h"],
    [:Minutes, "m", "m"],
    [:Seconds, "s", "s"]
]

oDur = DurationQ("2 days 5 hours")
? oDur.ToHuman()
#--> 2 d and 5 h

pf()
# Executed in 0.04 second(s) in Ring 1.24
