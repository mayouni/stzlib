# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #794.
#ERR Error (R14) : Calling Method without definition: findnthoccurrence

load "../../stzBase.ring"

pr()

o1 = new stzString("this text is my text not your text, right?!")
? o1.FindAllCS("text", :CaseSensitive = FALSE)
#--> [6, 17, 31]

? o1.FindNthOccurrence(2, "Text")
#--> 0

? o1.FindNthOccurrenceCS(2, "Text", :CaseSensitive = FALSE)
#--> 17

pf()
# Executed in 0.01 second(s).
