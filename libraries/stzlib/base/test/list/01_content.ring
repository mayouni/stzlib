# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #1.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ali", "Hedi" ])

o2 = o1.Copy()
o2.AddItem("Said")
? @@(o2.Content())
#--> [ "Ali", "Hedi", "Said" ]

? @@( o1.Content() ) # The original list is unchanged
#--> [ "Ali", "Hedi" ]

pf()
# Executed in almost 0 second(s) in Ring 1.24
