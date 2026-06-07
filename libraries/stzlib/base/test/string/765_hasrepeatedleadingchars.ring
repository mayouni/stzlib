# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #765.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

str = "   سلام"
o1 = new stzString(str)

? o1.HasRepeatedLeadingChars()
#--> TRUE

? @@( o1.RepeatedLeadingChar() )
#--> " "

o1.TrimRight() ? o1.Content()
#o--> سلام

pf()
# Executed in 0.02 second(s).
