# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #582.

load "../../../stzBase.ring"


o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
o1.RemoveLast(" من") # Or o1.RemoveNthOccurrence(:Last, " من")
? o1.Content()
#--> Gives من كان في زمنه من أصحابه فهو أكبر المحظوظين

pf()
# Executed in 0.01 second(s) in Ring 1.22
