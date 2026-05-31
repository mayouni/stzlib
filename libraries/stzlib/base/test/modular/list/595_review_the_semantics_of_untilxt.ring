# Narrative
# --------
# #todo review the semantics of UntilXT()
#
# Extracted from stzlisttest.ring, block #595.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ :Water, :Milk, :Cofee, :Tea, :Sugar, " ",:Honey ])
? o1.WalkUntil('@Item = :Milk')
#--> [ 1, 2 ]

? o1.WalkUntil('@Item = " "')
#--> [ 1, 2, 3, 4, 5, 6 ]

pf()
# Executed in 0.12 second(s).
