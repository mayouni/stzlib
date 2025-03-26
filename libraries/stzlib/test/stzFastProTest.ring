load "../max/stzmax.ring"

/*===

pr()

# Create a 1D list and set all items to 1000

aSimpleList = 1:1_000_000

FastProUpdateList(aSimpleList, :set, :items, 1000)
? ShowShort(aSimpleList)
#--> [ 1000, 1000, 1000, "...", 1000, 1000, 1000 ]

pf()
# Executed in 0.15 second(s) in Ring 1.22

/*---
*/
pr()

# Create a 2D list and set first column to 100

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

FastProUpdateList(aMatrix, :set, :col, [ 1, 100 ])

? @@NL(aMatrix)

pf()
