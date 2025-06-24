func StzListOfHashListsQ(paList)
	return new stzListOfHashLists(paList)

func StzHashListsQ(paList)
	return new stzListOfHashLists(paList)


class stzHashLists from stzListOfHashLists
class stzListOfAssociativeLists from stzListOfHashLists
class stzAssociativeLists from stzListOfHashLists

class stzListOfHashLists from stzList
	
	@aContent

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )

			@aContent = paList

		else
			StzRaise("Can't create stzListOfHashLists object!")
		ok

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfHashLists(This.Content())

	def ListOfHashLists()
		return This.Content()

	def ToListOfStzHashLists()
		aResult = []
		nLen = len(@aContent)

		for i = 1 to nLen
			aResult + new stzHashList(@aContent[i])
		next

		return aResult

	def Show()

		cResult = ""
		nLen = len(@aContent)

		for i = 1 to nLen

			aHashList = @aContent[i]
			nLenHash = len(aHashList)

			for j = 1 to nLenHash
				cLine = aHashList[j][1] + " : " + aHashList[j][2]
				cResult += cLine + NL
			next

			cResult += NL
		next

		? trim(cResult)

		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>
