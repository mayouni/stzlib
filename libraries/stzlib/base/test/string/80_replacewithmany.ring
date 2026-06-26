# Narrative
# --------
# #todo
#
# Extracted from stzStringTest.ring, block #80.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Replace-by-many family"):
# ReplaceWithMany(sub, list) is the one-substring -> many-replacements form and
# has the same bug as ReplaceByMany -- on "--Ring--Softanza--" with ["1","2","3"]
# it returns "Ring1Softanza" (1st and 3rd occurrences dropped) instead of
# "1Ring2Softanza3". The many-to-many ReplaceManyWithMany (block #81) works.
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--Softanza--")
o1.ReplaceWithMany("--", ["1", "2", "3"])
? o1.Content() #--> expected "1Ring2Softanza3" (currently "Ring1Softanza")

pf()
