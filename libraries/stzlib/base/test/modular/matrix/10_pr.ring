# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #10.

load "../../../stzBase.ring"


aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

updateColumn(aMatrix, :mul, 1, 2, :mul, 3, 2)

? @@NL(aMatrix)
#--> [
#	[ 2, 2, 6 ],
#	[ 8, 5, 12 ],
#	[ 14, 8, 18 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
