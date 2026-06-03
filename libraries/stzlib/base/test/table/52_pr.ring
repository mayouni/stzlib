# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #52.

load "../../stzBase.ring"


o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show() + NL
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllCols(:With = [ "A", "B", "C" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.02 second(s) in Ring 1.1è
