# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #151.

load "../../stzBase.ring"

pr()

o1 = new stzList("A" : "C")
o1.ExtendWith(["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.04 second(s)
# Including 0.02 seconds consumed by the Show() function
