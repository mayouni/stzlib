# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #7.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzList([ "me", "you", "all", "the", "others" ])
? o1.ContainsEither("me", :or = "you")
#--> FALSE

o1 = new stzlist([ "me", "and", "all", "the", "others" ])
? o1.ContainsEither("me", :or = "you")
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
