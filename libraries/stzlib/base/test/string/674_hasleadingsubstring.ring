# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #674.

load "../../stzBase.ring"

pr()

o1 = new stzString("000012.456")

? o1.HasLeadingSubString() # Or HasLeadingChars()
#--> TRUE

? o1.HowManyLeadingChar()
#--> 4

# You can get theim as a string:

? o1.LeadingSubString() # Or LeadingCharsXT()
#--> "0000"

# or get them as a list of chars:

? @@( o1.LeadingChars() )
#--> [ "0", "0", "0", "0" ]

# Usually, in practice, you need to remove them:

o1.RemoveLeadingChars() # Or RemoveLeadingSubString
? o1.Content()
#--> 12.456

pf()
# Executed in 0.02 second(s).
