load "stzlib.ring"

/*-------------

pron()

o1 = new stzString("---♥♥...**---")

? o1.SubStringComesBetween("...", "♥♥", "**")
#--> TRUE

? o1.SubStringComesBetween("...", "**", "♥♥")
#--> TRUE

proff()

/*-------------
*/
pron()

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

proff()

/*-----

pron()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----


pron()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

proff()
# Executed in 0.05 second(s)
