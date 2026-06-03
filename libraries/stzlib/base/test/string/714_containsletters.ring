# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #714.
#ERR Error (R14) : Calling Method without definition: containsletters

load "../../stzBase.ring"

pr()

? Q("--A--B--").ContainsLetters()
#--> TRUE

? Q("--A--B--").ContainsLetter("A")
#--> TRUE

? Q("--A--B--").ContainsLetter("a")
#--> TRUE

? Q("--A--B--").ContainsLetter("M")
#--> FALSE

? Q("H").IsALetterOf("HUSSEIN")
#--> TRUE

? Q("h").IsALetterOf("HUSSEIN")
#--> TRUE

pf()
# Executed in 0.04 second(s).
