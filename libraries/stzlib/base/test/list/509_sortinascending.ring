# Narrative
# --------
# Sorting a list and reasoning about its order, regardless of element type.
#
# Softanza sorts any list (not only numbers/strings) in ascending order via
# SortInAscending() / SortUp() and in descending order via SortInDescending()
# / SortDown(). It can also report a list's current order with SortingOrder()
# (yielding the lowercase string "ascending", "descending", or "unsorted")
# and compare two lists' orders with HasSameSortingOrderAs(). For conciseness
# the same checks are available as bare functions HaveSameSortingOrder() and
# SortingOrders(). The comparison predicates print 1/0 on the console for
# the logical values TRUE/FALSE recorded below.
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
#--> ascending

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
