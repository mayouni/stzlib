

func IsListOfTables(paList)

	if NOT (isList(paList) and IsListOfHashLists(paList))
		return FALSE
	ok

	nRows = len(paList[1][2])
	nLen = len(paList)

	for i = 1 to nLen
		if len(paList[i][2]) != nRows
			return FALSE
		ok
	next

	return TRUE

	func @IsListOfTables(paList)
		return IsListOfTables(paList)


class stzListOfTables from stzListOfHashLists
	@aContent = []

	def init(paList)
		if NOT @IsListOfTables(paList)
			StzRaise("Can't create the stzListOfTables object! You must provide a well formed list of hashlists.")
		ok

		nLen = len(paList)
		for i = 1 to nLen
			@aContent + new stzTable(paList[i])
		next

	def NumberOfTables()
		return len(@aContent)

		def HowManyTables()
			return len(@aContent)

		def CountTables()
			return len(@aContent)

	def Show()
		nLen = len(@aContent)
		for i = 1 to nLen
			@aContent[i].Show()
		next
