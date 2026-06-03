# Narrative
# --------
# ? Q(1:10).ShowShort()
#
# Extracted from stzGlobalTest.ring, block #25.

load "../../stzBase.ring"

pr()

#--> [ 1, 2, 3, "...", 8, 9, 10 ]

? Q(1:10).ShowShortN(3)

? Q(1:10).ShowShortXT([2, 3])
#--> [ 1, 2, "...", 8, 9, 10 ]

pf()
