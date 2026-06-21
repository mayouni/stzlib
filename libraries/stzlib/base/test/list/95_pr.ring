# Narrative
# --------
# Stringify + lowercase + replace on a mixed-type list in one pass.
#
# StringifyLowercaseAndReplace() walks a list of mixed numbers and
# strings, coerces every item to its string form, lowercases each, then
# performs a codepoint-safe SUBSTRING replace. Here it lowercases
# "r_INg"->"r_ing", "R_ng"->"r_ng", "R_ING"->"r_ing" (numbers become
# "1","2","3"), then swaps each "_" for the heart glyph (:With = AHeart()),
# yielding "r♥ing" / "r♥ng". One chained call does stringify + case + replace.
#
# Extracted from stzlisttest.ring, block #95.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplace("_", :With = AHeart())
o1.Show()
#--> [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ]

pf()
# Executed in 0.03 second(s)
