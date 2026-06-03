# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #51.
#ERR Error (R14) : Calling Method without definition: fill

load "../../stzBase.ring"

pr()

o1 = new stzTable([2, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2
#    ----- -----
#      .      .
#      .      .
#      .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+" ]) + NL
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

pf()
# Executed in 0.18 second(s) in Ring 1.20
# Executed in 1.31 second(s) in Ring 1.17
