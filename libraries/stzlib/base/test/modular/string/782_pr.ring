# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #782.

load "../../../stzBase.ring"


o1 = new stzString("Oooo Tunisia---")

? o1.HasLeadingChars()
#--> FALSE

? @@( o1.LeadingChar() )
#--> ""

? o1.HasLeadingCharsCS(FALSE)
#--> TRUE

? o1.LeadingCharCS(:CS = FALSE)
#--> "O"

? @@( o1.LeadingChars()	)
#--> []

? o1.LeadingCharsCS(:CS=FALSE)
#--> [ "O", "o", "o", "o" ]

? o1.LeadingSubStringCS(FALSE)
#--> "Oooo"

pf()
# Executed in 0.02 second(s).
