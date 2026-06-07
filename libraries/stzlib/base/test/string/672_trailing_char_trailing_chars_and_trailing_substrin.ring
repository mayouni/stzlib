# Narrative
# --------
# #narration TRAILING CHAR, TRAILING CHARS, AND TRAILiNG SUBSTRING
#
# Extracted from stzStringTest.ring, block #672.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

# You have a number in string an you want to get some info about its trailing part?

# A trailing part is a substring at the end of the string composed of repeated chars.

o1 = new stzString("12.4560000")

# You can check if the string contains a trailing part:

? o1.HasTrailingSubString() # Or HasTrailingChars()
#--> TRUE

# And even get their number:

? o1.HowManyTrailingChar()
#--> 4

# You can get theim as a string:

? o1.TrailingSubString() # Or TrailingCharsXT()
#--> "0000"

# or get them as a list of chars:

? @@( o1.TrailingChars() )
#--> [ "0", "0", "0", "0" ]

# Usually, in practice, you need to remove them:

o1.RemoveTrailingChars() # Or RemoveTrailingSubString()
? o1.Content()
#--> "12.456"

pf()
# Executed in 0.01 second(s).
