# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #1.
#ERR Error (R3) : Calling Function without definition: substringq

load "../../stzBase.ring"

pr()

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> TRUE

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> TRUE

#--

? SubStringQ([ "**", :In = "--♥♥--**--" ]).ComesAfterSubString("♥♥")
#--> TRUE

? SubStringQ("**").InQ("--♥♥--**--").ComesAfterSubString("♥♥")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("**").ComesAfterSubString("♥♥")
#--> TRUE

#--

? SubStringQ("--").InQ("--♥♥--**--").ComesBetween("♥♥", :And = "**")
#--> TRUE

? SubStringQ("--").InQ("--♥♥--**--").ComesBetween("**", :And = "♥♥")
#--> TRUE

? SubStringQ([ "--", :In = "--♥♥--**--" ]).ComesBetweenSubStrings("♥♥", :And = "**")
#--> TRUE

? SubStringQ([ "--", :In = "--♥♥--**--" ]).ComesBetweenSubStrings("**", :And = "♥♥")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("--").ComesbetweenSubStrings("♥♥", :And = "**")
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.22

#---
