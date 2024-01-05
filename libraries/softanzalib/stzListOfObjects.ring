
// TODO

func StzListOfObjectsQ()
	return new stzListOfObjects

func IsListOfObjects(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isObject(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	func @IsListOfObjects(paList)
		return IsListOfObjects(paList)

	func ListIsListOfObjects(paList)
		return IsListOfObjects(paList)

class stzListOfObjects from stzList
	@aContent = []

	def init(paObjects)
		if isList(paObjects) and Q(paObjects).IsListOfObjects()
			@aContent = paObjects

		else
			StzRaise("Incorrect param type! paObjects must be a list of objects.")
		ok

	def Content()
		@aContent

	def Copy()
		return new stzListOfObjects( This.Content() )
