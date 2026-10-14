

func IsListOfTables(paList)

	if NOT (isList(paList) and IsListOfHashLists(paList))
		return 0
	ok

	_nRows_ = len(paList[1][2])
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if len(paList[i][2]) != _nRows_
			return 0
		ok
	next

	return 1

	func @IsListOfTables(paList)
		return IsListOfTables(paList)


# Holds several tables built from a list of hash lists, to count them and show them one after the other.
#
# Each hash list of the list becomes one stzTable, whose columns are the hash list's keys. The class
# counts its tables, under three names, and Show prints them in turn. It inherits from the list of
# hash lists. Tables of different row counts are accepted today, although the build check says it
# demands the same count.
#
#   receiver   o1 = new stzListOfTables([ [ :NAME = [ "Ann", "Bob" ], :AGE = [ 31, 28 ] ], [ :ID = [
#              1, 2 ], :CITY = [ "Niamey", "Dosso" ] ] ])
#   example    ? o1.NumberOfTables()
#              #--> 2
#              ? o1.CountTables()
#              #--> 2
#   see        stzTable, stzListOfHashLists, IsListOfTables
class stzListOfTables from stzListOfHashLists
	@aContent = []

	# Builds a list of tables from a list of hash lists, each hash list becoming one stzTable.
	#
	#   paList     a list of hash lists, each one [ :COLUMN = values, ... ]
	#   returns    nothing; the object is built
	#   warning    raises Can't create the stzListOfTables object for anything that is not a list of
	#              hash lists, but an empty list raises R2 Array Access instead of that message; the
	#              rule that every table has the same number of rows is not enforced, since the test
	#              compares the length of a column pair, always 2, and tables of 2 and 3 rows are
	#              accepted
	#   see        NumberOfTables, Show
	def init(paList)
		if NOT @IsListOfTables(paList)
			StzRaise("Can't create the stzListOfTables object! You must provide a well formed list of hashlists.")
		ok

		_nLen_ = len(paList)
		for i = 1 to _nLen_
			@aContent + new stzTable(paList[i])
		next

	# Returns how many tables the list holds.
	#
	#   returns    a number
	#   see        HowManyTables, CountTables, Show
	def NumberOfTables()
		return len(@aContent)

		# Returns how many tables the list holds, as NumberOfTables does.
		#
		#   returns    a number
		#   see        NumberOfTables, CountTables
		def HowManyTables()
			return len(@aContent)

		# Returns how many tables the list holds, as NumberOfTables does.
		#
		#   returns    a number
		#   see        NumberOfTables, HowManyTables
		def CountTables()
			return len(@aContent)

	# Prints each table in turn as a boxed grid with capitalized column names.
	#
	#   returns    nothing; it prints
	#   see        NumberOfTables, stzTable
	def Show()
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			@aContent[i].Show()
		next
