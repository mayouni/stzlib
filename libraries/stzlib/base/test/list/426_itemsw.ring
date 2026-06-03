# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #426.
#ERR Error (R14) : Calling Method without definition: itemsw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1 - These( o1.ItemsW('NOT isNumber(This[@i])') )
#             \_______________ ________________/
#                             V
#                   [ "A", "B", "C", "D" ]

#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in 0.05 second(s).
