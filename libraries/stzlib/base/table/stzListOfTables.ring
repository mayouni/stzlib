

func IsListOfTables(paList)

	if NOT (isList(paList) and IsListOfHashLists(paList))
		return FALSE
	ok

	_nRows_ = len(paList[1][2])
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if len(paList[i][2]) != _nRows_
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

		_nLen_ = len(paList)
		for i = 1 to _nLen_
			@aContent + new stzTable(paList[i])
		next

	def NumberOfTables()
		return len(@aContent)

		def HowManyTables()
			return len(@aContent)

		def CountTables()
			return len(@aContent)

	def Show()
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			@aContent[i].Show()
		next
