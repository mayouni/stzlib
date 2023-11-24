
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

	def Sets()
		return Content()

	def Intersection()
		oStzList = new stzList(This.Merge())
		return oStzList.UniqueItems()

	def CommonItems()
		return This.Intersection()
