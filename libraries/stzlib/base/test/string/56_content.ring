# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #56.
#ERR Error (R14) : Calling Method without definition: replacebymany

load "../../stzBase.ring"

pr()

o1 = new stzString("1♥34♥♥")
o1.ReplaceByMany("♥", [ "2", "5", "6" ])
? o1.Content()
#--> 123456

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :By = [ "2", "5", "6" ])
? o1.Content()
#--> 123456

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :ByMany = [ "2", "5", "6" ])
? o1.Content()
#--> 123456

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.16 second(s) in Ring 1.17
