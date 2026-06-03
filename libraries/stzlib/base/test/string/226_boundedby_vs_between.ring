# Narrative
# --------
# #TODO #narration BOUNDEDBY() VS BETWEEN()
#
# Extracted from stzStringTest.ring, block #226.

load "../../stzBase.ring"


pr()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")


? o1.BoundedBy([ "<<<", ">>>" ])
#--> ["ring", "softanza"]

? o1.Between("<<<", ">>>")
#--> "ring>>>___<<<softanza"

pf()
# Executed in 0.02 second(s) in Ring 1.21
