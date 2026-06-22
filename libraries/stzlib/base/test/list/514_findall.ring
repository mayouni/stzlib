# Narrative
# --------
# Shows that Softanza finds and sorts every Ring value type inside a
# list -- numbers, strings, and nested lists alike.
#
# Ring's native find()/sort() only handle numbers and strings. Softanza
# lifts that limit: FindAll() locates a nested sub-list by value (here
# [ "L1", "L1" ] sits at position 6), and SortedInAscending() orders a
# heterogeneous list with a stable type-tier rule -- numbers first
# (sorted), then strings (sorted), then lists (sorted). Objects are the
# only type not yet sortable (a documented #TODO); for now they would be
# appended in appearance order. This makes Softanza's sort effectively
# total over all Ring types.
#
# Extracted from stzlisttest.ring, block #514.

load "../../stzBase.ring"


pr()

# Ring can find (and sort) items inside a list (respectively
# using find() and sort() functions), but only if these items
# are of type "NUMBER" or "STRING".

# Softanza makes it posible to find (and sort) all the three
# types: numbers, strings, lists (--> TODO: not yet for objects).

o1 = new stzList([ "twelve", 12, [ "L2", "L2" ], "ten", 10, [ "L1", "L1" ] ])

? @@( o1.FindAll([ "L1", "L1" ]) ) + NL
#--> [ 6 ]

# Not only list are findable, they are also sortable and comparable.

? @@( o1.SortedInAscending() )
#--> [ 10, 12, "ten", "twelve", [ "L1", "L1" ], [ "L2", "L2" ] ]

# As you can see, the logic of sorting applied by Softanza is:
#	--> Putting numbers first and sorting them
#	--> Adding strings after that and sorting them
#	--> Adding lists after that and sorting them

# Same thing should be possible for objects but not yet implemented (#TODO)
# ~> For the mean time, objects are added at the end in the order of
# their appearance. But we could sort them also, based on their attributes
# values. Which makes Softanza sort totally pervasive for all Ring types!

pf()
#--> Executed in 0.02 second(s).
