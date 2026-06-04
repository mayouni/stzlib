# Narrative
# --------
# # Be careful: there is a difference between finding a string
#
# Extracted from stzlistofstringstest.ring, block #62.
#ERR Error (R14) : Calling Method without definition: findstringcs

load "../../stzBase.ring"

pr()

# and finding a substring inside the string items of the list of string

# Let's explain this by example

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

# The following finds the hole string "name" (whatever case it has)
# and sees if it exists AS AN ITEM of the list of strings

? @@( o1.FindStringCS("name", TRUE) ) #--> [ ]

# While the following analyses the strings themselves and finds
# where they may include the SUBSTRING "name"

? @@( o1.FindSubstringCS("name", :CS = FALSE) )
#--> [
#	[ 1, [ 13    ] ],
#	[ 3, [ 6, 21 ] ]
# ]

# This means that "name" exists :
#	- in the 1st string at  position 13, and
#	- in the 3rd string at positions 6 and 21

# Now guess the following:
? @@( o1.FindStringCS("mabrooka", :CaseSensitive = FALSE) )
#--> [ 2, 6 ]
#--> "mabourka" exists (whatever case is) as an entire string item in positions 2 and 6

# And this one:
? @@( o1.FindSubstringCS("mabrooka", :CaseSensitive = FALSE) )
#--> [
# 	[ 2, [ 1 ] ],
# 	[ 6, [ 1 ] ]
# ]
#--> "mabourka" exists (whatever case is) AS A SUBSTRING:
# 	- of the 2nd string, at position 1, and
# 	- of the 6th string at position 1

pf()
