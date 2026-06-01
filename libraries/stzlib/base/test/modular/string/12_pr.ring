# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #12.

load "../../../stzBase.ring"


o1 = new stzString("me you all the others")
? o1.ContainsEither("me", :or = "you")
#--> FALSE

o1 = new stzString("me and all the others")
? o1.ContainsEither("me", :or = "you")
#--> TRUE

pf()
# Executed in 0.01 second(s)
