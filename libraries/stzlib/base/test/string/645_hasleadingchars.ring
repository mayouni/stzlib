# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #645.
#ERR Error (R3) : Calling Function without definition: hasleadingitems

load "../../stzBase.ring"


pr()

# One of the design goals of Softanza is to be as consitent as possible
# in managing Strings and Lists. In other terms, what works for one,
# should work for the other, preserving the same semantics.

# To show this, the following code that plays with leading and trailing
# chars in a string...

StzStringQ( "***Ring++" ) {

	? HasLeadingChars()
	#--> TRUE

	? NumberOfLeadingChars()
	#--> 3

	? @@( LeadingChars() ) # Or LeadingCharsXT() #--> "***"
	#--> [ "*", "*", "*" ]
	
	? HasTrailingChars()
	#--> TRUE

	? NumberOfTrailingChars()
	#--> 2

	? @@( TrailingCharsXT() )
	#--> "++"

	ReplaceEachLeadingChar(:With = "+")
	? Content()
	#--> "+++Ring++"
	
	//ReplaceLeadingAndTrailingChars(:With = "*")
	ReplaceEachLeadingAndTrailingChar(:With = "*")
	? Content() + NL + NL + "---" + NL
	#--> "***Ring**"
}

# works quiet the same with leading and trailing items items of this list:

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems()
	#--> TRUE

	? NumberOfLeadingItems()
	#--> 3

	? @@( LeadingItems() )
	#--> [ "*", "*", "*" ]
	
	? HasTrailingItems()
	#--> TRUE

	? NumberOfTrailingItems()
	#--> 2
	? @@( TrailingItems() )
	#--> [ "+", "+" ]

	ReplaceLeadingItems(:With = "+")
	? @@( Content() )
	#--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItems(:With = "*") + NL+NL + "---" + NL
	? @@( Content() )
	#--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

#NOTE that, as far as strings are concerned, both if the main objec we
# are working on is a string or a list containing string itmes as leading
# or trailing chars, this feature is sensitive to case:
# so we can say:

StzStringQ("eeEEeeTUNISeeEE") {

	? NumberOfLeadingCharsCS(:CaseSensitive = FALSE)
	#--> 6

	? LeadingCharsCS(:CaseSensitive = FALSE)
	#--> eeEEee

	? NumberOfLeadingCharsCS(TRUE)
	#--> 2

	? LeadingCharsCS(TRUE)
	#--> ee

	? LeadingCharIsCS("E", :CaseSensitive = FALSE)	+ NL
	#--> TRUE

	#--

	? NumberOfTrailingCharsCS(:CaseSensitive = FALSE) + NL
	#--> 4

	? TrailingCharsCS(:CaseSensitive = FALSE)
	#--> EEee

	? NumberOfTrailingCharsCS(TRUE) + NL
	#--> 2

	? TrailingCharsCS(TRUE)
	#--> EE

	? LeadingCharIsCS("e", :CaseSensitive = FALSE)
	#--> TRUE

}

pf()
# Executed in 0.08 second(s) in Ring 1.22
# Executed in 0.35 second(s) in Ring 1.18
# Executed in 0.61 second(s) in Ring 1.17

#NOTE: Case sensitivity is also supported in Lists with most functions.
# In the future, all functions wil be covered.
