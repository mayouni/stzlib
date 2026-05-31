# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #99.

load "../../../stzBase.ring"


o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.TrimLeft()
o1.TrimRight()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
