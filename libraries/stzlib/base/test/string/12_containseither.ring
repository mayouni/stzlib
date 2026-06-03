# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #12.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("me you all the others")
? o1.ContainsEither("me", :or = "you")
#--> FALSE

o1 = new stzString("me and all the others")
? o1.ContainsEither("me", :or = "you")
#--> TRUE

pf()
# Executed in 0.01 second(s)
