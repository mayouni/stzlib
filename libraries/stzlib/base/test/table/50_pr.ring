# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #50.

load "../../stzBase.ring"


o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllRows(:With = [ "+", "+", "+" ])

o1.Show()
#--> COL1   COL2   COL3
#   ----- ------ -----
#      +      +      +
#      +      +      +
#      +      +      +

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.98 second(s) in Ring 1.17
