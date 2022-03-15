func StzListOfHashListsQ(paList)
	return new stzListOfHashLists(paList)
	
class stzListOfHashLists from stzObject
	@aListOfHashLists

	def init(paList)
		if StzListQ(paList).IsListOfHashLists()
			@aListOfHashLists = paList

		else
			raise("Can't create stzListOfHashLists object!")
		ok

	def Content()
		return @aListOfHashLists

	def ListOfHashLists()
		return This.Content()

	def Show()
		for aHashList in This.ListOfHashLists()
			StzHashListQ(aHashList).Show() ? ""
		next
