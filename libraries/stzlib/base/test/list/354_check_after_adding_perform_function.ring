# Narrative
# --------
# #TODO check after adding Perform() function
#
# Extracted from stzlisttest.ring, block #354.

load "../../stzBase.ring"


pr()

# Transforming the list structure so it becomes
# a list of pairs of numbers. To do so, the numbers
# are duplicated inside a list of two items.

o1 = new stzList([ 0, 2, 0, 3, [1,2] ])
o1.PerformWF(
	func x { return Q(x).IsANumber() },
	func x { return Q(x).RepeatedInAPair() }
)

? @@(o1.Content())
#--> [ [ 0, 0 ], [ 2, 2 ], [ 0, 0 ], [ 3, 3 ], [ 1, 2 ] ]

pf()
