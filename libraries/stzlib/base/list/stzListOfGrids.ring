// TODO

func StzListOfGridsQ(paGrids)
	return new stzListOfGrids(paGrids)

class stzGrids from stzListOfGrids

# Holds a list of grids, each a list of lists, once it can be built; it cannot be built today.
#
# The class is marked TODO in its file. Its init checks the argument with a method named
# IsListOfGrids that stzList does not have (only the global function of that name exists), so new
# stzListOfGrids(aList) and StzListOfGridsQ(aList) raise error R14 for every list, an empty one
# included; a value that is not a list raises the intended message. Content has no return statement,
# so it would answer an empty text even for an object that could be built. For a single grid use
# stzList2D; for a list of lists, stzListOfLists.
#
#   receiver   o1 = new stzList2D([ [ 1, 2 ], [ 3, 4 ] ])
#   example    ? @@( o1.Content() )
#              #--> [ [ 1, 2 ], [ 3, 4 ] ]
#   see        stzList2D, stzListOfLists
class stzListOfGrids from stzListOfLists

	# Builds a list of grids from a list whose items are grids, checking each one.
	#
	#   paGrids    a list of grids, each a list of lists
	#   returns    nothing today: it raises error R14 and no object is built
	#   note       the file is marked TODO
	#   warning    Raises error R14 "Calling Method without definition: islistofgrids" today, for
	#              every list including [ ], instead of building the object: the check is written as
	#              a method of stzList, which only exists as the global function IsListOfGrids; a
	#              value that is not a list raises "Incorrect param type! paGrids must be a list of
	#              grids."
	#   see        Content
	def init(paGrids)
		if isList(paGrids) and Q(paGrids).IsListOfGrids()
			@aContent = paGrids

		else
			StzRaise("Incorrect param type! paGrids must be a list of grids.")
		ok

	# Returns the grids the object holds.
	#
	#   returns    nothing today, and it could not be reached: init never succeeds
	#   warning    Not run, because no object can be built; read from the code, the body is the bare
	#              name @aContent with no return, so it would answer an empty text
	#   see        Copy
	def Content()
		@aContent

	# Returns a new stzListOfGrids built from the content of this one.
	#
	#   returns    nothing today, and it could not be reached: init never succeeds
	#   warning    Not run, because no object can be built; it passes Content to a new object, and
	#              Content has no return
	#   see        Content
	def Copy() # We must define it here to be sepecific to get
		   # a copy from the object and not from its parent
		return new stzListOfGrids( This.Content() )
