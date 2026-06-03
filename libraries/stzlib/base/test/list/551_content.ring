# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #551.
#ERR Error (R14) : Calling Method without definition: insertafterwxt

load "../../stzBase.ring"

pr()

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
o1.InsertAfterWXT( :Where = '{ Q(@item).IsLowercase() }' , "*")
? o1.Content()
#--> ["c", "*", "c++", "*", "C#", "RING", "Python", "RUBY"]

pf()
# Executed in 0.16 second(s).
