
func StzListOfSetsQ(paList)
	return new stzListOfSets(paList)

class stzSets from stzListOfSets

class stzListOfSets from stzListOfLists
	@aContent

	def init(paList)

		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfSets() )

			@aContent = paList

		else
			StzRaise(stzListOfSetsError(:CanNotCreateListOfSets))
		ok

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfSets( This.Content() )

	def Sets()
		return Content()
