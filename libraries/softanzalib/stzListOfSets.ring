
class stzListOfSets from stzListOfLists
	@aContent

	def init(paListOfSets)
		oTempList = new stzList(paListOfSets)

		if oTempList.AllItemsAreSets()
			@aContent = paListOfSets
		else
			stzRaise(stzListOfSetsError(:CanNotCreateListOfSets))
			//aSets = oTempList.Transform( :AllItems, :ThatAreLists, :ToSets )
		ok

	def Content()
		return @aContent

	def Sets()
		return Content()

	def Intersection()
		oStzList = new stzList(This.Merge())
		return oStzList.UniqueItems()

	def CommonItems()
		return This.Intersection()
