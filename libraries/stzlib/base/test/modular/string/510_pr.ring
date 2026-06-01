# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #510.

load "../../../stzBase.ring"


o1 = new stzString("ab_cd_ef_gh")
? o1.FindAll("_")
#--> [3, 6, 9]

pf()
