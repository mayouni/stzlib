// TODO

func StzListOfGridsQ(paGrids)
	return new stzListOfGrids(paGrids)

class stzListOfGrids from stzListOfLists

	def init(paGrids)
		if isList(paGrids) and Q(paGrids).IsListOfGrids()
			@aContent = paGrids

		else
			StzRaise("Incorrect param type! paGrids must be a list of grids.")
		ok

	def Content()
		@aContent

	def Copy() # We must define it here to be sepecific to get
		   # a copy from the object and not from its parent
		return new stzListOfGrids( This.Content() )
