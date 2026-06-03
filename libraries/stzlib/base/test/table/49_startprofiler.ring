# Narrative
# --------
# StartProfiler()
#
# Extracted from stztabletest.ring, block #49.

load "../../stzBase.ring"


o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+", "+", "+" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

StopProfiler()
# Executed in 0.22 second(s) in Ring 1.20
# Executed in 1.89 second(s) in Ring 1.17
