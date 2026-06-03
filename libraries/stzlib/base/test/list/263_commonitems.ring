# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #263.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ring", "Ruby", "Python" ])

? o1.CommonItems(:With = [ "Julia", "Ring", "Go", "Python" ])
#--> [ "Ring", "Python" ]

pf()
#--> Executed in 0.03 second(s)
