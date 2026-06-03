# Narrative
# --------
# #narration: eXTended form of RemoveFirstChar()
#
# Extracted from stzStringTest.ring, block #29.

load "../../stzBase.ring"


pr()

# Remove the 7 dashes in front of the word ring

o1 = new stzString("-------Ring")

o1.RemoveFirstChar()
? o1.Content()
#--> ------Ring

# Remove an other one
o1.RemoveFirstChar()
? o1.Content()
#--> -----Ring

# And an other one
o1.RemoveFirstChar()
? o1.Content()
#--> ----Ring

# Tired? Remove them all in one shot using the eXTend form
o1.RemoveFirstCharXT()
? o1.Content()
#--> Ring

#NOTE: we can get the same result by using RemoveLeadingChars()

o1 = new stzString("-------Ring")
o1.RemoveLeadingChars()
? o1.Content()
#--> Ring

pf()
# Executed in 0.02 second(s)
