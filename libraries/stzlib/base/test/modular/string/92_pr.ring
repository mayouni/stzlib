# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #92.

load "../../../stzBase.ring"


o1 = new stzString("123♥♥678**123♥♥678")

? o1.SubStringComesBefore("♥♥", :Position = 6)
#--> TRUE

? o1.SubStringComesBeforePosition("♥♥", 6)
#--> TRUE

? o1.SubStringComesBefore("♥♥", :SubString = "**")
#--> TRUE

? o1.SubStringComesBeforeSubString("♥♥", "**")
#--> TRUE

#--

? o1.SubStringComesAfter("♥♥", :Position = 3)
#--> TRUE

? o1.SubStringComesAfterPosition("♥♥", 3)
#--> TRUE

? o1.SubStringComesAfter("**", :SubString = "♥♥")
#--> TRUE

? o1.SubStringComesAfterSubString("**", "♥♥")
#--> TRUE

#--

? o1.SubStringComesBetween("♥♥", :Positions = 3, :And = 6)
#--> TRUE

? o1.SubStringComesBetweenPositions("♥♥", 3, 6)
#--> TRUE

? o1.SubStringComesBetween("678", :SubStrings = "♥♥", :And = "**")
#--> TRUE

? o1.SubStringComesBetweenSubStrings("678", "**", "♥♥")
#--> TRUE

#--

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> TRUE

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> TRUE

pf()
# Executed in 0.03 second(s)
