# Narrative
# --------
# #narration
#
# Extracted from stzlisttest.ring, block #509.

load "../../stzBase.ring"


pr()

# Softanza can sort a list, whatever data types it contains (not only
# numbers and strings), in ascending and descending orders (see
# comments in corresponding methods in stzList class).

# Also, it can retrieve the sorting of a list using SortingOrder()
# method (returns :Ascending, :Descending, or :Unsorted).

# And it can compare the sorting orders of two lists using
# HasSameSortingOrderAs() method.

? Q(3:1).SortInAscendingQ().Content() 	# Or SortUp()
#--> [ 1, 2, 3 ]

? Q(1:3).SortInDescendingQ().Content()	# Or SortDown()
#--> [ 3, 2, 1 ]

? Q(1:3).SortingOrder()
#--> :Ascending

? Q(1:3).HasSameSortingOrderAs(3:1)
#--> FALSE

? Q(1:3).HasSameSortingOrderAs(1:3)
#--> TRUE

? Q(1:3).HasSameSortingOrderAs(1:5) + NL
#--> TRUE

# For conciseness, you can call these functions directly,
# without objects instanciation:

? HaveSameSortingOrder(1:3, 1:7)
#--> TRUE

? SortingOrders([ 1:3, 1:7 ])
#--> [ "ascending", "ascending" ]

pf()
# Executed in 0.01 second(s).
