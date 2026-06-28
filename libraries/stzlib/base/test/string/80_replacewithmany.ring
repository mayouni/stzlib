# Narrative
# --------
# ReplaceWithMany(sub, list) is the one-substring -> many-replacements form: each
# "--" maps to the next item, so the three separators become 1, 2, 3.
#
# Extracted from stzStringTest.ring, block #80.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--Softanza--")
o1.ReplaceWithMany("--", ["1", "2", "3"])
? o1.Content()
#--> 1Ring2Softanza3

pf()
