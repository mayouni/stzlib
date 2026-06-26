# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #56.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Replace-by-many family"):
# ReplaceByMany(sub, list) should replace each successive occurrence of `sub`
# with list[1], list[2], ... ("1♥34♥♥" -> "123456"), but it is broken (returns
# "1342"). The :By / :ByMany named-param forms of Replace() are worse -- they are
# a no-op (return the string unchanged). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("1♥34♥♥")
o1.ReplaceByMany("♥", [ "2", "5", "6" ])
? o1.Content() #--> expected "123456" (currently broken)

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :By = [ "2", "5", "6" ])
? o1.Content() #--> expected "123456" (currently a no-op)

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :ByMany = [ "2", "5", "6" ])
? o1.Content() #--> expected "123456" (currently a no-op)

pf()
