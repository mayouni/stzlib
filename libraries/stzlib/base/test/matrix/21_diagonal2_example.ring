# Narrative
# --------
# Diagonal2 Example
#
# Extracted from stzmatrixtest.ring, block #21.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

? @@( o1.Diagonal2() )
#--> [ 3, 5, 7 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
