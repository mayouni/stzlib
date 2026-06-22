# Narrative
# --------
# Stringifying the items of a list
#
# Extracted from stzlisttest.ring, block #11.

load "../../stzBase.ring"


pr()

o1 = new stzList([ 120, "abc", 1:3 ])
o1.Stringify()
? @@( o1.Content() )
#--> [ "120", "abc", "[ 1, 2, 3 ]" ]

pf()
