# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #516.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.IsBoundedBy([ "{", "}" ]) + NL
#--> TRUE

o1.RemoveTheseBounds("{", "}")
? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.01 second(s).
