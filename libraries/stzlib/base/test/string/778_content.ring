# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #778.
#ERR Error (R14) : Calling Method without definition: replacefirstnchars

load "../../stzBase.ring"

pr()

o1 = new stzString("---Ring!")
o1.ReplaceFirstNChars(3, :With = "Hi ")
? o1.Content()
#--> Hi Ring!

o1 = new stzString("Hi Ring---")
o1.ReplaceLastNChars(3, :With= "!")
? o1.Content()
#--> Hi Ring!

pf()
# Executed in 0.01 second(s).
