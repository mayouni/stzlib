# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #249.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")
? o1.FindNext("1", :startingAt = 10)

pf()
