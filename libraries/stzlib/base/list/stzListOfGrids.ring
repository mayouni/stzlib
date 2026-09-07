// TODO

func StzListOfGridsQ(paGrids)
	return new stzListOfGrids(paGrids)

class stzGrids from stzListOfGrids

class stzListOfGrids from stzListOfLists

	def init(paGrids)
		# IsListOfGrids is a global FUNCTION in stzListFunc taking the
		# list. Q(paGrids) gives a stzList, which has no method of that
		# name, so this raised R14 and the class could not be constructed
		# at all.
		if isList(paGrids) and IsListOfGrids(paGrids)
			@aContent = paGrids

		else
			StzRaise("Incorrect param type! paGrids must be a list of grids.")
		ok

	# Measured on 1.27: a method whose body is a bare expression returns
	# "", not the value and not an error. Without the return, Copy() below
	# handed an empty string to the constructor.
	def Content()
		return @aContent

	def Copy() # We must define it here to be sepecific to get
		   # a copy from the object and not from its parent
		return new stzListOfGrids( This.Content() )
