# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #58.

load "../../../stzBase.ring"


o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithCol = [ "A", "B" ] )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       .      .      .

o1.Fill( :WithCol = [ "A", "B", "C" ] )

o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

pf()
# Executed in 0.29 second(s) in Ring 1.20
# Executed in 1.58 second(s) in Ring 1.19
