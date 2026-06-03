# Narrative
# --------
# ReplaceTheseElementsInSectionByManyXT() - Replace multiple values in section with cycling replacements
#
# Extracted from stzmatrixtest.ring, block #52.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 2, 5, 1 ],
    [ 7, 1, 2 ]
])

# Replace all occurrences of 1 and 2 in entire matrix with cycling values [100, 200]
o1.ReplaceTheseElementsInSection(
	[1, 2],
	:From = [1,1], :To = [3,3],
	:ByManyXT = [-1, -2]
)

o1.Show()
#-->
# ┌          ┐
# │ -1 -2  3 │
# │ -1  5 -2 │
# │  7 -1 -2 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

o1 = new stzMatrix([
    [ 1, 5, 3 ],
    [ 4, 5, 6 ],
    [ 7, 5, 9 ]
])

? @@NL( o1.ElementsInSectionZ([ 2, 2 ], [ 3, 3 ]) )
#--> [
#	[ 5, [ 2, 2 ] ],
#	[ 5, [ 3, 2 ] ],
#	[ 6, [ 2, 3 ] ],
#	[ 9, [ 3, 3 ] ]
# ]

# NOTE 1 : By convention, positions in matrices are read vertically
# from top tp down and then from left to right

# NOTE 2 : Element and Number are semantic alternatives in stzMatrix

pf()
# Executed in 0.01 second(s) in Ring 1.22
