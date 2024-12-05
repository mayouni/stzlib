// TODO

func StzListOfGridsQ(paGrids)
	return new stzListOfGrids(paGrids)

func IsListOfGrids(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsGrid(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfGrids(paList)
		return IsListOfGrids(paList)

	#--

	func IsAListOfGrids(paList)
		return IsListOfGrids(paList)

	func @IsAListOfGrids(paList)
		return IsListOfGrids(paList)

	#>

class stzGrids from stzListOfGrids

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
