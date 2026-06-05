# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #53.

load "../../stzBase.ring"

pr()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithRow = [ "A", "B" ] )
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      B      .
#       A      B      .
#       A      B      .

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17
