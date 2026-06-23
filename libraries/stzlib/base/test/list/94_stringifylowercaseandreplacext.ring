# Narrative
# --------
# StringifyLowercaseAndReplaceXT(): stringify + lowercase every item, then
# SUBSTRING-replace across them all.
#
# The list mixes numbers and mixed-case strings. The call first coerces each
# item to a lowercased string ("R_ING" -> "r_ing", 1 -> "1"), then replaces
# the substring "_" with AHeart() ("♥") inside every item, so "r_ing"
# becomes "r♥ing". Show() prints the resulting flat list. The XT form behaves
# the same as the plain form here (block #95); both do a codepoint-safe
# substring replace, not a whole-item match.
#
# Extracted from stzlisttest.ring, block #94.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplaceXT("_", :With = AHeart())
o1.Show()
#--> [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19
