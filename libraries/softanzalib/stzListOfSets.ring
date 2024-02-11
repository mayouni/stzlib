
func StzListOfSetsQ(paList)
	return new stzListOfSets(paList)

func IsListOfSets(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsSet(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfSets(paList)
		return IsListOfSets(paList)

	func ListIsListOfSets(paList)
		return IsListOfSets(paList)

	#--

	func IsAListOfSets(paList)
		return IsListOfSets(paList)

	func @IsAListOfSets(paList)
		return IsListOfSets(paList)

	func ListIsAListOfSets(paList)
		return IsListOfSets(paList)

	#>

class stzSets from stzListOfSets

class stzListOfSets from stzListOfLists
	@aContent

	def init(paList)

		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfSets() )

			@aContent = paListOfSets

		else
			StzRaise(stzListOfSetsError(:CanNotCreateListOfSets))
		ok

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfSets( This.Content() )

	def Sets()
		return Content()

	def Intersection()
		oStzList = new stzList(This.Merge())
		return oStzList.UniqueItems()

	def CommonItems()
		return This.Intersection()
