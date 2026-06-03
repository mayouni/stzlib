# Narrative
# --------
# AddInDiagonal Example
#
# Extracted from stzmatrixtest.ring, block #20.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Main diagonal elements increased by 10

o1.AddInDiagonal(10)

o1.Show() # Note this is misspelled form of Show() but Softanza understands it!
#-->
# ┌          ┐
# │ 11  2  3 │
# │  4 15  6 │
# │  7  8 19 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
