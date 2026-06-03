# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #509.

load "../../stzBase.ring"


o1 = new stzString("ab_cd_ef_gh")

? o1.FindFirstNOccurrences(2, "_")
#--> [3, 6]
? o1.FindLastNOccurrences(2, "_")
#--> [6, 9]

pf()
# Executed in 0.03 second(s).
