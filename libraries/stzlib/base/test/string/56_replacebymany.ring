# Narrative
# --------
# ReplaceByMany maps each occurrence of the substring to the next replacement.
# Replace() recognizes the same intent via its :By / :ByMany named params (a LIST
# value routes to ReplaceByMany), so all three spellings give "123456".
#
# Extracted from stzStringTest.ring, block #56.

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
