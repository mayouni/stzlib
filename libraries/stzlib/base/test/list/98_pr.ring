# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #98.

load "../../stzBase.ring"


o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.Trim()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
