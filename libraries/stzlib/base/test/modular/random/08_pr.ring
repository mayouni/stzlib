# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #8.

load "../../../stzBase.ring"


aNumbers = [ 12, 9, 10, 7, 25, 12, 9, 8 ]
? Some(aNumbers)
#--> [ 12, 10, 7 ]

? DefaultSome()
0.3

SetSome(0.5)
? Some(aNumbers)
#--> [ 10, 25, 7, 9 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
