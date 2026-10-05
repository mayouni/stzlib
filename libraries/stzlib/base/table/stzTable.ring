#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLE (CORE)            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table core class -- init, content access,   #
#                  column/row metadata, identity checks.       #
#                  Domain methods in stzTable*.ring submodules. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  ////////////////////////
 ///   GLOBAL FUNCS   ///
////////////////////////

func StzTableQ(paTable)
	return new stzTable( paTable )

func IsTable(paTable)
	if NOT isList(paTable)
		return 0
	ok

	try
		new stzTable(paTable)
		return 1
	catch
		return 0
	done

	func @IsTable(paTable)
		return IsTable(paTable)


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds a table of named columns and numbered rows, and answers questions about its cells, rows and columns.
#
# Reach for it when data has columns that deserve a name and rows that deserve a position. The
# content is stored column by column, as [ name, list of cells ] pairs, so a column is reached by
# its name (case does not matter) or by its position, and a row only by its position. A table is
# built from rows whose first line holds the column names, from rows alone (the columns are then
# called col1, col2 ...), from a hash list of name = cells pairs, or from a [ columns, rows ] size
# pair. Mutators change the table in place and return nothing; the CQ forms and the Sorted and
# Filled families give a result without touching it. The class inherits stzList, so a method not
# defined here falls through to the list. Many names are alternative spellings of one method, and a
# good share of the class is unfinished: about 200 methods raise an error or do nothing today, and
# each of them says so in its brief and its warning.
#
#   receiver   o1 = new stzTable([ [ :ID, :EMPLOYEE, :SALARY ], [ "001", "Salem", 12499.20 ], [
#              "002", "Henri", 10890.10 ], [ "003", "Sonia", 12740.30 ] ])
#   example    ? @@( o1.ColumnsNames() )
#              #--> [ "id", "employee", "salary" ]
#              ? o1.NumberOfRows()
#              #--> 3
#              ? @@( o1.Row(2) )
#              #--> [ "002", "Henri", 10890.10 ]
#   see        stzList, stzHashList
Class stzTable from stzList
	@aContent = []

	# Table content is stored as a hashlist where keys are col names
	# EXAMPLE:
	# 	[
	# 		[ “COL1”, [ “A”, “B”, “C” ] ],
	# 		[ “COL2”, [ “a”, “b”, “c” ] ],
	# 		[ “COL3”, [ “1”, “2”, “3” ] ]
	# 	]

	# This choice is made firstly, because columns have names and
	# rows have'nt. But mainly, to enable (future) data analytics and
	# data science operations on tables of data, where variables are
	# always represented as columns.

	@anCalculatedCols = []
	@anCalculatedRows = []

	# Engine handle for Zig-backed acceleration
	@pEngine = ""
	@bEngineStale = 1

	# Define border characters (initialized in init())
	@aBorder = []

	# Attributes used by the Transpose() method

	@bTransposedWithHeaders = 0 # tracks when headers were preserved during transpose
	@aOriginalColNames = [] # stores the original column names internally

	# Builds the table from rows with a header row, rows alone, a hash list of columns, or a [ columns, rows ] size pair.
	#
	#   paTable    the content, in one of the four shapes
	#   returns    nothing; the table is built
	#   note       Rows alone get the column names col1, col2 ...; a size pair gives empty cells
	#              named COL1, COL2 ...
	#   warning    Rows of unequal sizes with no header, or any other shape, raise an error
	#@ aka  Build the table from rows (the first row may carry the column names).
	def init(paTable)

		# Initialize Softanza visual identity border characters
		@aBorder = []
		@aBorder + [ :TopLeft, "╭" ]
		@aBorder + [ :TopRight, "╮" ]
		@aBorder + [ :BottomLeft, "╰" ]
		@aBorder + [ :BottomRight, "╯" ]
		@aBorder + [ :Horizontal, "─" ]
		@aBorder + [ :Vertical, "│" ]
		@aBorder + [ :TeeRight, "├" ]
		@aBorder + [ :TeeLeft, "┤" ]
		@aBorder + [ :TeeDown, "┬" ]
		@aBorder + [ :TeeUp, "┴" ]
		@aBorder + [ :Cross, "┼" ]

		# A table can be created in many different ways
		# Case where a string is provided

		if NOT isList(paTable)
			StzRaise("Incorrect param format! paTable must be a list.")
		ok

		# Structural probes computed DIRECTLY on paTable, in ONE pass.
		# This used to be `_oParam_ = Q(paTable)` followed by
		# _oParam_.ItemsAreListsOfSameSize() / IsHashList() / IsNotHashList().
		# Q() copies every cell, and ItemsAreListsOfSameSize() is engine-backed
		# (_EngineListFromContent MARSHALS the whole content to the engine) --
		# and it was called TWICE. So every `new stzTable(...)` paid
		# O(rows x cols) copying + up to two full marshals to answer questions
		# that are O(items): 0.75s of a 0.84s Copy() on a 50k-row table, on the
		# path of EVERY table construction.
		#   _bSameSize_ -- every item is a list, all of the same size
		#   _bHashList_ -- every item is [ stringKey, value ], keys unique
		_nItemsIn_ = len(paTable)
		_bSameSize_ = 1
		_bHashList_ = 1
		_nFirstSizeIn_ = -1
		_acKeysIn_ = []

		for _iIn_ = 1 to _nItemsIn_
			_pIn_ = paTable[_iIn_]

			if isList(_pIn_)
				if _nFirstSizeIn_ = -1
					_nFirstSizeIn_ = len(_pIn_)
				but len(_pIn_) != _nFirstSizeIn_
					_bSameSize_ = 0
				ok
			else
				_bSameSize_ = 0
			ok

			if _bHashList_
				if NOT ( isList(_pIn_) and len(_pIn_) = 2 and isString(_pIn_[1]) )
					_bHashList_ = 0
				else
					_nKeysIn_ = len(_acKeysIn_)
					for _jIn_ = 1 to _nKeysIn_
						if _acKeysIn_[_jIn_] = _pIn_[1]
							_bHashList_ = 0
							exit
						ok
					next
					if _bHashList_
						_acKeysIn_ + _pIn_[1]
					ok
				ok
			ok
		next

		if len(paTable) = 0 or @IsPairOfNumbers(paTable)

		# Example : new stzTable([])
		#--> Creates an empty table with just a column and a row

		# Example: new stzTable([3, 4])
		#--> Creates a table of 3 columns and 4 rows, all cells are empty

		# Both ways (1 and 2) are made by the following code:

			_nCols_ = 1
			_nRows_ = 1

			if  @IsPairOfNumbers(paTable)
				_nCols_ = paTable[1]
				_nRows_ = paTable[2]
			ok

			_aRow_ = []
			for _i_ = 1 to _nRows_
				_aRow_ + ""
			next

			for _i_ = 1 to _nCols_
				@aContent + [ "COL"+_i_, _aRow_ ]
			next

			return

		but _bSameSize_ and @IsListOfStrings(paTable[1])

		# ~> (the more natural way) The table is described in a
		# a list of lists that mimics the realworld presentation
		# of a table (first line represents colums, and the other
		# lines represent rows):

		# o1 = new stzTable([
		# 	[ :ID,	 :EMPLOYEE,    	:SALARY	],
		# 	#-------------------------------#
		# 	[ 10,	 "Ali",		35000	],
		# 	[ 20,	 "Dania",	28900	],
		# 	[ 30,	 "Han",		25982	],
		# 	[ 40,	 "Ali",		12870	]
		# ])
			_nLen_ = len(paTable[1])

			for _i_ = 1 to _nLen_
				_cCol_ = paTable[1][_i_]
				@aContent + [ _cCol_, [] ]
			next
			#--> [
			# 	:ID       = [],
			# 	:EMPLOYEE = [],
			# 	:SALARY   = []
			#    ]

			_nTableLen_ = len(paTable)
			for r = 2 to _nTableLen_
				_i_ = 0
				_nLen_ = len(paTable[r])

				for _i_ = 1 to _nLen_
					@aContent[_i_][2] + paTable[r][_i_]
				next
			next

			return

		but _bSameSize_ and NOT _bHashList_

		# ~> Similar to way 3 but the line of column names is
		# not provided. Means that you privided only the rows of
		# your table!
		#--> Softanza accepts the rows and adds automatically the
		# column names as :COL1, :COL2, :COL3...

		# EXAMPLE:
		# o1 = new stzTable([
		# 	[ 10,	 "Ali",		35000	],
		# 	[ 20,	 "Dania",	28900	],
		# 	[ 30,	 "Han",		25982	],
		# 	[ 40,	 "Ali",		12870	]
		# ])

			_aTempTable_ = []

			_acColNames_ = []
			_nTable1Len_ = len(paTable[1])
			for _i_ = 1 to _nTable1Len_
				_acColNames_ + ("col" + _i_)
			next


			# Prepend the generated header by CONSTRUCTION. The original used
			# bare `insert(paTable, 0, ...)`, but inside a class `insert`
			# resolves to the inherited Insert METHOD and dies with R20 ("extra
			# number of parameters") -- which broke the whole rows-without-header
			# form, `new stzTable([ [1,"Ali"], [2,"Han"] ])`. (ring_insert is no
			# use here either: it rejects position 0.)
			_aWithHeader_ = [ _acColNames_ ]
			_nRowsIn_ = len(paTable)
			for _iRowIn_ = 1 to _nRowsIn_
				_aWithHeader_ + paTable[_iRowIn_]
			next

			This.Init(_aWithHeader_)
			return

		but _bHashList_
		# ~> The table is provided in the same format of how
		# it is implemented in this class: a hashlist.
		# ~> the most performant way!

		# EXAMPLE:

		# o1 = new stzTable([
		#  	:NAME   = [ "Ali", 	  "Dania", 	"Han" 	 ],
		#  	:JOB    = [ "Programmer", "Manager", 	"Doctor" ],
		# 	:SALARY = [ 35000, 	  50000, 	62500    ]
		# ])

		# o1.Show()
		#--> 	#    NAME          JOB   SALARY
		# 	1     Ali   Programmer    35000
		# 	2   Dania      Manager    50000
		# 	3     Han       Doctor    62500

			# We need a supplemenatary check here of the case
			# where the values of the hashlist are not list
			# So for example, if the use provides:

			# o1 = new stzTable([ [ "i", 1 ], [ "ring", 4 ], [ "language", 8 ] ])
			# where 1, 4 and 8 are not lists...

			# It should be transformed to:

			# o1 = new stzTable([ [ "i", [1] ], [ "ring", [4] ], [ "language", [8] ] ])

			_nLen_ = len(paTable)
			@aContent = []

			for _i_ = 1 to _nLen_
				if isList(paTable[_i_][2])
					@aContent + [ paTable[_i_][1], paTable[_i_][2] ]
				else
					_aTemp_ = []
					_aTemp_ + paTable[_i_][2]
					@aContent + [ paTable[_i_][1], _aTemp_ ]
				ok
			next

		else
			# If the param provided don't fit in any of the ways above
			StzRaise("Incorrect param format! There are 5 possible ways in creating a table. " +
				 "None fits with the param you provided. Check the code/comments under " +
				 "stzTable.Init() method.")
		ok

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the class name, in lowercase.
	#
	#   returns    the text "stztable"
	#@ aka  The lowercase class name: "stztable".
	def ClassName()
		return "stztable"

		# Returns the class name, in lowercase.
		#
		#   returns    the text "stztable"
		#   see        ClassName
		#@ aka  Same as ClassName.
		def KlassName()
			return "stztable"

	# Returns the table as a list of [ column name, cells ] pairs, one pair per column.
	#
	#   returns    a list of [ name, list of cells ] pairs
	#   see        Rows, Cols
	#@ aka  The raw table rows.
	def Content()
		_aContent_ = @aContent # A deep copy to avoid reference propagation
		return _aContent_

		# Same as Content.
		def Table()
			return This.Content()

			# The table content, chainable form.
			def TableQ()
				return new stzList( This.Table() )

		# Returns the table as a list of [ column name, cells ] pairs, one pair per column.
		#
		#   returns    a list of [ name, list of cells ] pairs
		#   see        Content
		#@ aka  The raw table rows (same as Content).
		def Value()
			return Content()


	# Returns a new table holding the same columns and cells; the original is unchanged.
	#
	#   returns    a new stzTable
	#@ aka  A new stzTable with the same rows.
	def Copy()

		_aCopy_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			_aCopy_ + @aContent[_i_]
		next

		_oCopy_ = new stzTable(_aCopy_)
		return _oCopy_

	# TRUE if the table has no column, or if every cell is an empty string.
	#
	#   returns    TRUE or FALSE
	#   note       A table of one column and one empty cell counts as empty.
	#@ aka  TRUE if the table has no data.
	def IsEmpty()
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 1
		ok
		for _i_ = 1 to _nLen_
			_aCol_ = @aContent[_i_][2]
			_nColLen_ = len(_aCol_)
			for j = 1 to _nColLen_
				if _aCol_[j] != ""
					return 0
				ok
			next
		next
		return 1

	  #================================================#
	 #   CHECHKING IF THE TABLE HAS GIVEN COLUMN(S)   #
	#================================================#

	# TRUE if a column has that name, ignoring case.
	#
	#   returns    TRUE or FALSE
	#   warning    Raises an error when pcName is not text
	#   see        HasColumnsNames
	def HasColumName(pcName)

		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		# Column names are stored as given (often upper-cased). The old
		# code lowercased the query then did a case-SENSITIVE Contains,
		# so it never matched -- HasCol always returned FALSE. Compare
		# case-insensitively against the stored names instead.
		_bResult_ = This.ColNamesQ().ContainsCS(pcName, 0)

		return _bResult_

		#< @FunctionAlternativeForms

		def HasColName(pcName)
			return This.HasColumName(pcName)

		def HasCol(pcName)
			return This.HasColumName(pcName)

		def HasColumn(pcName)
			return This.HasColumName(pcName)

		#--

		def ContainsColumName(pcName)
			return This.HasColumName(pcName)

		def ContainsColName(pcName)
			return This.HasColumName(pcName)

	# TRUE if every given name is the name of a column, ignoring case.
	#
	#   pacNames   the list of column names to look for
	#   returns    TRUE or FALSE
	#   see        HasColumName
		#>
	def HasColumnsNames(pacNames)
		_nLen_ = len(pacNames)
		_bResult_ = 1
		for _i_ = 1 to _nLen_
			if NOT This.HasColName(pacNames[_i_])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionAlternativeForms

		def HasColNames(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasColumns(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasCols(pacNames)
			return This.HasColumnsNames(pacNames)

		#--

		def ContainsColumnsNames(pacNames)
			return This.HasColumnsNames(pacNames)

		def ContainsColNames(pacNames)
			return This.HasColumnsNames(pacNames)

		#>

	  #-------------------------------#
	 #   GETTING NUMBER OF COULMNS   #
	#-------------------------------#

	# Returns how many columns the table has.
	#
	#   returns    a number
	#   see        NumberOfRows
	def NumberOfColumns()
		_nResult_ = len( This.Table() )
		return _nResult_

		def NumberOfCols()
			return This.NumberOfColumns()

		def NumberOfCol()
			return This.NumberOfColumns()

	  #---------------------------------#
	 #   GETTING THE LIST OF COULMNS   #
	#---------------------------------#

	# Returns the column names, in column order.
	#
	#   returns    a list of text
	#   see        NumberOfColumns
	def ColumnsNames()
		_aResult_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			_aResult_ + @aContent[_i_][1]
		next
		return _aResult_

		#< @FunctionFluentForm

		def ColumnsNamesQ()
			return This.ColumnsNamesQRT( :stzList )

		def ColumnsNamesQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ColumnsNames() )

			on :stzListOfStrings
				return new stzListOfStrings( This.ColumnsNames() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.ColumnsNames() )

			on :stzListOfLists
				return new stzListOfLists( This.ColumnsNames() )

			on :stzListOfPairs
				return new stzListOfPairs( This.ColumnsNames() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def AllColumnsNames()
			return This.ColumnsNames()

			def AllColumnsNamesQ()
				return This.AllColumnsNamesQ()

			def AllColumnsNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

		def ColumnNames()
			return This.ColumnsNames()

			def ColumnNamesQ()
				return This.ColumnsNamesQ()

			def ColumnNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

		def AllColumnNames()
			return This.ColumnsNames()

			def AllColumnNamesQ()
				return This.ColumnsNamesQ()

			def AllColumnNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

		def ColsNames()
			return This.ColumnsNames()

			def ColsNamesQ()
				return This.ColumnsNamesQ()

			def ColsNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

		def ColNames()
				return This.ColumnsNames()

			def Columns()
				return This.ColumnsNames()

			def ColNamesQ()
				return This.ColumnsNamesQ()

			def ColNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

		# Returns the sorted positions of the columns that were added as calculated columns.
		#
		#   returns    a list of numbers; [ ] when there are none
		#   see        CalculatedCols
		# --- Aggregation layer, exposed on the base -----------------------
		#@ aka  stzTable is the class users instantiate; the aggregation methods are defined on the stzTableAggregator SUBCLASS, so a bare stzTable would miss them. We expose them here (same forwarder pattern as Show -> stzTableDisplay). The heavy compute -- calc columns, column aggregates -- delegates to a throwaway aggregator built from this table's content, while the calc-col STATE (@anCalculatedCols) lives on
		def FindCalculatedCols()
			_oCc_ = new stzList(@anCalculatedCols)
			return _oCc_.Sorted()

			def FindCalculatedColumns()
				return This.FindCalculatedCols()

		# Returns the cells of every calculated column, one list per column.
		#
		#   returns    a list of lists of cells; [ ] when there are none
		#   see        FindCalculatedCols
		def CalculatedCols()
			_anPos_ = This.FindCalculatedCols()
			_aResult_ = []
			_nLen_ = len(_anPos_)
			for _i_ = 1 to _nLen_
				_aResult_ + This.Col(_anPos_[_i_])
			next
			return _aResult_

			def CalculatedColumns()
				return This.CalculatedCols()

		# Returns the names of the calculated columns, in column order.
		#
		#   returns    a list of text; [ ] when there are none
		#   see        CalculatedCols
		def CalculatedColNames()
			_anPos_ = This.FindCalculatedCols()
			_acResult_ = []
			_nLen_ = len(_anPos_)
			for _i_ = 1 to _nLen_
				_acResult_ + This.ColName(_anPos_[_i_])
			next
			return _acResult_

			def CalculatedColsNams()
				return This.CalculatedColNames()

			def CalculatedColumnNams()
				return This.CalculatedColNames()

			def CalculatedColumnsNams()
				return This.CalculatedColNames()

		# Returns the sorted positions of the rows that were added as calculated rows.
		#
		#   returns    a list of numbers; [ ] when there are none
		#   see        CalculatedRows
		def FindCalculatedRows()
			_oCr_ = new stzList(@anCalculatedRows)
			return _oCr_.Sorted()

			def FindCalculatedRowsPositions()
				return This.FindCalculatedRows()

		# Returns the cells of every calculated row, one list per row.
		#
		#   returns    a list of lists of cells; [ ] when there are none
		#   see        FindCalculatedRows
		def CalculatedRows()
			_anPos_ = This.FindCalculatedRows()
			_aResult_ = []
			_nLen_ = len(_anPos_)
			for _i_ = 1 to _nLen_
				_aResult_ + This.Row(_anPos_[_i_])
			next
			return _aResult_

		def AllColsNames() # Useful by contrast to TheseCols(paCols)
			return This.ColumnsNames()

			def AllColsNamesQ()
				return This.ColsNamesQRT(:stzList)

			def AllColsNamesQRT(pcReturnType)
				return This.ColsNamesQRT(pcReturnType)

		def AllColNames() # Useful by contrast to TheseCols(paCols)
			return This.ColumnsNames()

			def AllColNamesQ()
				return This.ColsNamesQRT(:stzList)

			def AllColNamesQRT(pcReturnType)
				return This.ColsNamesQRT(pcReturnType)

		def Header()
			return This.ColumnsNames()

			def HeaderQ()
				return This.HeaderQ()

			def HeaderQRT(pcReturnType)
				return This.HeaderQRT(pcReturnType)

		#>

	  #====================================================#
	 #  CHECKING IF THE PROVIDED STRING IS A COLUMN NAME  #
	#====================================================#

	# TRUE if a column bears this name, ignoring case.
	#
	#   returns    TRUE or FALSE
	#   warning    Raises an error when pcName is not text
	#   see        IsColNumber
	def IsColName(pcName)

		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		if This.FindCol(pcName) > 0
			return 1
		else
			return 0
		ok
/*
		_cName_ = StzLower(pcName)

		_bResult_ = 0
		if This.ColNamesQ().Contains(pcName)
			_bResult_ = 1
		ok
*/
		return _bResult_

		#< @FunctionAlternativeForm

		def IsColumnName(pcName)
			return This.IsColName(pcName)

		def IsAColName(pcName)
			return This.IsColName(pcName)

		def IsAColumnName(pcName)
			return This.IsColName(pcName)

		#>

	  #------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED NUMBER IS A COLUMN NUMBER  #
	#------------------------------------------------------#

	# TRUE if the number lies between 1 and the number of columns.
	#
	#   _n_        the position to test
	#   returns    TRUE or FALSE
	#   warning    Raises an error when the argument is not a number
	#   see        IsColName
	def IsColNumber(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if _n_ < 1 or _n_ > This.NumberOfCols()
			return 0
		else
			return 1
		ok

		def IsColumnNumber(_n_)
			return This.IsColNumber(_n_)

		def IsAColNumber(_n_)
			return This.IsColNumber(_n_)

		def IsAColumnNumber(_n_)
			return This.IsColNumber(_n_)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED VALUE IS A COLUMN NUMBER OR NAME  #
	#-------------------------------------------------------------#

	# TRUE if the argument is the name of a column or a valid column position.
	#
	#   returns    TRUE or FALSE
	#   see        IsColName, IsColNumber
	def IsColNameOrNumber(pCol)

		if ( isString(pCol) and This.IsColName(pCol) ) or
		   ( isNumber(pCol) and This.IsColNumber(pCol) )
			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsCol(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColmun(pcol)
			return This.IsColNameOrNumber(pCol)

		def IsColNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#--

		def IsColumnNameOrNumber(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColumnNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColumnIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#==

		# TRUE if the given value names a column or is a column number.
		def IsAColNameOrNumber(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsACol(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsAColmun(pcol)
			return This.IsColNameOrNumber(pCol)

		def IsAColNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsAColIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#--

		def IsAColumnNameOrNumber(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsAColumnNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsAColumnIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#>

	  #---------------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED VALUES ARE COLUMN NUMBERS OR NAMES  #
	#---------------------------------------------------------------#

	# TRUE if every item of the list is the name or the position of a column.
	#
	#   returns    TRUE or FALSE
	#   see        IsColNameOrNumber
	def AreColNamesOrNumbers(paCols)
		_oTemp_ = Q(paCols)

		if NOT ( isList(paCols) and
			( _oTemp_.IsListOfNumbers() or
			  _oTemp_.IsListOfStrings() or
			  IsListOfNumbersAndStrings(paCols) ) )

			StzRaise("Incorrect param type! paCols must be of list of numbers or strings.")
		ok

		_bResult_ = 1
		_nLen_ = len(paCols)

		for _i_ = 1 to _nLen_
			if NOT This.IsColNameOrNumber(paCols[_i_])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionAlternativeForms

		def AreColNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColID(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#--

		def AreColumnNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#==

		# TRUE if every given value is a column name or number.
		def AreColsNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColsNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColsIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#--

		def AreColumnsNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnsNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnsIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#>

	  #============================================================#
	 #  INFRASTRUCTURE METHODS (needed by all submodules)          #
	#============================================================#

	# Returns the position of a column given by name or by number; 0 when there is no such column.
	#
	#   returns    a number
	#   see        FindColByName
	def FindCol(pCol)
		if isNumber(pCol)
			if pCol >= 1 and pCol <= len(@aContent)
				return pCol
			else
				return 0
			ok
		ok
		if isString(pCol)
			return This.FindColByName(pCol)
		ok
		return 0

		def FindColumn(pCol)
			return This.FindCol(pCol)

	# Returns the position of the column with this name, ignoring case; 0 when there is none.
	#
	#   pcColName   the column name to look for
	#   returns     a number
	#   see         FindCol
	def FindColByName(pcColName)
		pcColName = StzLower(pcColName)
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if StzLower(@aContent[_i_][1]) = pcColName
				return _i_
			ok
		next
		return 0

		def FindColumnByName(pcColName)
			return This.FindColByName(pcColName)

	# Returns the position of a column: a number passes through unchecked, a name is looked up and gives 0 when absent.
	#
	#   returns    a number
	#   see        FindCol
	def ColToColNumber(pCol)
		if isNumber(pCol)
			return pCol
		ok
		return This.FindCol(pCol)

	# Returns how many rows the table has, read from its first column; 0 when there is no column.
	#
	#   returns    a number
	#   see        NumberOfColumns
	def NumberOfRows()
		if len(@aContent) = 0
			return 0
		ok
		return len(@aContent[1][2])

	# Returns the cells of one column, top to bottom.
	#
	#   returns    a list of cells
	#   warning    Raises the error Column not found! for an unknown column
	#   see        Row, Cell
	def Col(pCol)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		return @aContent[_n_][2]

		def Column(pCol)
			return This.Col(pCol)

		def ColQ(pCol)
			return new stzList(This.Col(pCol))

			def ColumnQ(pCol)
				return This.ColQ(pCol)

	# Returns the cells of one row, left to right, one per column.
	#
	#   pnRow      the row position, 1 for the first
	#   returns    a list of cells
	#   warning    Raises R2 when the row is past the last one
	#   see        Col, Rows
	def Row(pnRow)
		_aResult_ = []
		_nCols_ = len(@aContent)
		for _i_ = 1 to _nCols_
			_aResult_ + @aContent[_i_][2][pnRow]
		next
		return _aResult_

	# Returns the content of one cell, given its column and its row.
	#
	#   pnRow      the row position, 1 for the first
	#   returns    the cell value
	#   warning    Raises Column not found! for an unknown column and R2 for a row past the last one
	#   see        Col, Row
	def Cell(pCol, pnRow)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		return @aContent[_n_][2][pnRow]

	# Returns the number of columns times the number of rows.
	#
	#   returns    a number
	#   see        NumberOfColumns, NumberOfRows
	def NumberOfCells()
		return This.NumberOfColumns() * This.NumberOfRows()

	# Returns the name of the nth column.
	#
	#   _n_        the position of the column
	#   returns    the column name, as text
	#   warning    Raises R2 when n is 0 or past the last column
	#   see        FirstColName, LastColName
	def NthColName(_n_)
		return @aContent[_n_][1]

	# Returns the name of the first column.
	#
	#   returns    the column name, as text
	#   see        NthColName, LastColName
	def FirstColName()
		return This.NthColName(1)

	# Returns the name of the last column.
	#
	#   returns    the column name, as text
	#   see        NthColName, FirstColName
	def LastColName()
		return This.NthColName(This.NumberOfColumns())

	# Returns the cells of the last row, one per column.
	#
	#   returns    a list of cells
	#   see        Row
	def LastRow()
		return This.Row(This.NumberOfRows())

	# Returns every row, top to bottom, each as a list of cells.
	#
	#   returns    a list of rows
	#   see        Row, Content
	def Rows()
		_aResult_ = []
		_nRows_ = This.NumberOfRows()
		for _i_ = 1 to _nRows_
			_aResult_ + This.Row(_i_)
		next
		return _aResult_

	# Puts the given values in a row, one per column, in place.
	#
	#   pnRow      the row position
	#   paNewRow   the new cells, one per column
	#   returns    nothing; the table changes
	#   warning    A list shorter than the number of columns raises R5 and a row past the last one
	#              raises R2
	#   see        ReplaceCell
	def ReplaceRow(pnRow, paNewRow)
		_nCols_ = len(@aContent)
		for _i_ = 1 to _nCols_
			@aContent[_i_][2][pnRow] = paNewRow[_i_]
		next
		This._InvalidateEngine()

	# Puts a value in one cell, in place.
	#
	#   pnRow      the row position, 1 for the first
	#   returns    nothing; the table changes
	#   warning    Raises Column not found! for an unknown column
	#   see        ReplaceCol
	def ReplaceCell(pCol, pnRow, pValue)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		@aContent[_n_][2][pnRow] = pValue
		This._InvalidateEngine()

	# Puts a whole new list of cells in a column, in place.
	#
	#   paNewData   the new cells of the column
	#   returns     nothing; the table changes
	#   warning     The length is not checked: a list of another length leaves the columns of
	#               unequal size
	#   see         ReplaceCell
	def ReplaceCol(pCol, paNewData)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		@aContent[_n_][2] = paNewData
		This._InvalidateEngine()

	  #============================================================#
	 #  TABLE SECTION (overrides stzList.Section for [col,row])   #
	#============================================================#

	# Returns columns n1 to n2 as [ name, cells ] pairs, or the cells of the block between two [ column, row ] corners, row by row.
	#
	#   p1         the first position, :First, or a [ column, row ] corner
	#   p2         the last position, :Last, or the opposite corner
	#   returns    a list
	#   warning    Swapped numbers are put in order; a number out of range raises Indexes out of
	#              range!
	#   see        Cell, Col
	def Section(p1, p2)
		if isList(p1) and isList(p2)
			# Rectangular section [col1,row1] to [col2,row2].
			# Row-major: (row1,col1), (row1,col2)..(row1,colN),
			#            (row2,col1)..(row2,colN), ..., (rowN,colN).
			# Earlier implementation did a page-reading sweep (first
			# column to end-of-table, middle columns full, last column
			# from top) which contradicted both the submodule
			# (stzTableCellAccess.Section) and intuitive cell-block
			# semantics.
			_nSCol1 = p1[1]
			_nSRow1 = p1[2]
			_nSCol2 = p2[1]
			_nSRow2 = p2[2]

			_aSResult = []
			for _iS = _nSRow1 to _nSRow2
				for _jS = _nSCol1 to _nSCol2
					_aSResult + @aContent[_jS][2][_iS]
				next
			next
			return _aSResult
		ok

		_nSLen = This.NumberOfItems()
		if isString(p1)
			if p1 = :First or p1 = :FirstItem
				p1 = 1
			but p1 = :Last or p1 = :LastItem
				p1 = _nSLen
			ok
		ok
		if isString(p2)
			if p2 = :Last or p2 = :LastItem or p2 = :End or p2 = :EndOfList
				p2 = _nSLen
			but p2 = :First or p2 = :FirstItem
				p2 = 1
			ok
		ok
		if NOT @BothAreNumbers(p1, p2)
			StzRaise("Incorrect params! n1 and n2 must be numbers.")
		ok
		if p1 < 1 or p1 > _nSLen or p2 < 1 or p2 > _nSLen
			StzRaise("Indexes out of range!")
		ok
		if p2 < p1
			_nSTemp = p1
			p1 = p2
			p2 = _nSTemp
		ok
		_aSContent = This.Content()
		_aSResult2 = []
		for _iS2 = p1 to p2
			_aSResult2 + _aSContent[_iS2]
		next
		return _aSResult2

	  #============================================================#
	 #  ENGINE ACCELERATION INFRASTRUCTURE                         #
	#============================================================#

	def _EnsureEngine()
		if @pEngine = "" or @bEngineStale
			if @pEngine != ""
				StzEngineTableFree(@pEngine)
			ok

			@pEngine = StzEngineTableNew()

			# ONE bulk call. This used to add each column, then each row, then
			# SET EVERY CELL individually -- O(rows x cols) FFI calls (300k for
			# a 50k x 6 table). The engine now reads the whole content list in
			# a single call.
			StzEngineTableFill(@pEngine, @aContent)

			@bEngineStale = 0
		ok

	def _InvalidateEngine()
		@bEngineStale = 1

	def _SyncFromEngine()
		# ONE bulk call. This used to read EVERY CELL with GetCellType +
		# GetCell* -- 2 FFI calls per cell (600k for a 50k x 6 table). The
		# engine now builds the whole Ring content list in a single call.
		@aContent = StzEngineTableContent(@pEngine)
		@bEngineStale = 0

	def _FreeEngine()
		if @pEngine != ""
			StzEngineTableFree(@pEngine)
			@pEngine = ""
		ok

	# Returns the handle of the engine-side copy of the table, rebuilding it first when it is stale.
	#
	#   returns    a number
	#@ aka  The engine handle of the table's backing store.
	def EngineHandle()
		This._EnsureEngine()
		return @pEngine

	  #=========================================#
	 #  STRUCTURAL OPERATIONS (from submodule) #
	#=========================================#

	# Removes the nth column, in place; removing the only column leaves one empty column.
	#
	#   _n_        the position of the column to remove
	#   returns    nothing; the table changes
	#   warning    Raises Bad parameters value, error in range! when n is past the last column
	#   see        RemoveColumn
	def RemoveNthCol(_n_)
		if This.NumberOfCols() = 1
			@aContent = [ [ :COL1, [ "" ] ] ]
			This._InvalidateEngine()
			return
		ok
		ring_remove(@aContent, _n_)
		This._InvalidateEngine()

		# Removes the nth column, in place; removing the only column leaves one empty column.
		#
		#   _n_        the position of the column to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthCol
		def RemoveColAt(_n_)
			This.RemoveNthCol(_n_)

	# Removes one column, given by name or position, in place; removing the only column leaves one empty column.
	#
	#   pColNameOrNumber   the column to remove, by name or position
	#   returns            nothing; the table changes
	#   warning            Raises Column not found! for an unknown name, and a bad-range error for a
	#                      position past the last column
	#   see                RemoveNthCol
	def RemoveColumn(pColNameOrNumber)
		_nRcCol_ = This.ColToColNumber(pColNameOrNumber)
		if _nRcCol_ = 0
			StzRaise("Column not found!")
		ok
		This.RemoveNthCol(_nRcCol_)

		# Removes one column, given by name or position, in place; removing the only column leaves one empty column.
		#
		#   pColNameOrNumber   the column to remove, by name or position
		#   returns            nothing; the table changes
		#   see                RemoveColumn
		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	  #================================================#
	 #  CASTING TO PIVOT TABLE (from submodule)       #
	#================================================#

	# Returns a stzPivotTable built on this table, for pivot-style summaries.
	#
	#   returns    a stzPivotTable
	#   note       Needs the max layer of the library to be loaded
	#@ aka  NOTE // stzPivotTable belongs to the MAX layer of StzLib For the following method to work, you must load "stzMax.ring"
	def ToStzPivotTable()
		return new stzPivotTable(This)

	  #=========================================#
	 #  DISPLAY OPERATIONS (from submodule)    #
	#=========================================#

	# Appends a column at the right end, in place; the cells are padded with empty text or cut to the number of rows.
	#
	#   pacColNameAndData   the new column as [ name, list of cells ]
	#   returns             nothing; the table changes
	#   warning             Raises an error when the name already exists or the pair is not [ text,
	#                       list ]; a pair written with :name = list is refused too
	#   see                 AddColumns
	def AddColumn(pacColNameAndData)
		if NOT ( isList(pacColNameAndData) and
			 len(pacColNameAndData) = 2 and
			 isString(pacColNameAndData[1]) and
			 isList(pacColNameAndData[2]) )
			StzRaise("Incorrect column format! pacColNameAndData must be [:cColName = [...]].")
		ok
		if This.IsColName(pacColNameAndData[1])
			StzRaise("Can't add the column! The name you provided already exists.")
		ok
		_nLen_ = len(pacColNameAndData[2])
		_nRows_ = This.NumberOfRows()
		if _nLen_ < _nRows_
			for _i_ = _nLen_+1 to _nRows_
				pacColNameAndData[2] + ""
			next
		but _nLen_ > _nRows_
			for _i_ = _nLen_ to _nRows_+1 step - 1
				ring_remove(pacColNameAndData[2], _i_)
			next
		ok
		@aContent + pacColNameAndData
		This._InvalidateEngine()

		# Appends a column at the right end, in place; the cells are padded with empty text or cut to the number of rows.
		#
		#   pacColNameAndData   the new column as [ name, list of cells ]
		#   returns             nothing; the table changes
		#   see                 AddColumn
		def AddCol(pacColNameAndData)
			This.AddColumn(pacColNameAndData)

	# Returns the name of the nth column.
	#
	#   _n_        the position of the column
	#   returns    the column name, as text
	#   warning    Raises Column index out of range. for 0 or a position past the last column
	#   see        NthColName
	#@ aka  Word-order alias used by narrative tests.
	def ColName(_n_)
		if _n_ < 1 or _n_ > len(@aContent)
			StzRaise("Column index out of range.")
		ok
		return @aContent[_n_][1]

		def ColumnName(_n_)
			return This.ColName(_n_)

	# FindRow / FindRowCS -- look up a row's position by its value
	# array. Forwarded version of stzTableFinder.FindRow.
	def FindRowCS(paRow, pCaseSensitive)
		# Two lists are never equal under =, so the rows are compared cell by cell
		_aResultLocal_ = []
		if NOT isList(paRow)
			return _aResultLocal_
		ok

		_aRowsLocal_ = This.Rows()
		_nLenRowsLocal_ = len(_aRowsLocal_)
		for _iFrLocal_ = 1 to _nLenRowsLocal_
			if This._SameRowCS(_aRowsLocal_[_iFrLocal_], paRow, pCaseSensitive)
				_aResultLocal_ + _iFrLocal_
			ok
		next
		return _aResultLocal_

	# TRUE if the two rows have the same cells in the same order; text compares without case when the flag is 0.
	def _SameRowCS(paRowA, paRowB, pCaseSensitive)
		_nLenSr_ = len(paRowA)
		if _nLenSr_ != len(paRowB)
			return 0
		ok

		for _iSr_ = 1 to _nLenSr_
			_xA_ = paRowA[_iSr_]
			_xB_ = paRowB[_iSr_]

			if isString(_xA_) and isString(_xB_)
				if pCaseSensitive
					if _xA_ != _xB_
						return 0
					ok
				else
					if StzLower(_xA_) != StzLower(_xB_)
						return 0
					ok
				ok

			but isNumber(_xA_) and isNumber(_xB_)
				if _xA_ != _xB_
					return 0
				ok

			but isList(_xA_) and isList(_xB_)
				if @@(_xA_) != @@(_xB_)
					return 0
				ok

			else
				return 0
			ok
		next

		return 1

		# Looks for a row equal to the given cells and answers its positions.
		#
		#   paRow      the cells of the row to look for
		#   returns    a list of positions; [ ] when no row matches
		def FindRow(paRow)
			return This.FindRowCS(paRow, 1)

	# Returns the row positions where the column holds the given value, case-sensitively; [ ] when the column does not exist.
	#
	#   pValueOrNamed   the value to look for, or [ :Value, v ]
	#   returns         a list of row positions
	#   see             ContainsCell, NumberOfOccurrenceInCol
	#@ aka  FindInCol(pCol, pValueOrSubvalue) -- look up positions in a single column where the cell equals pValue or contains pSubValue. Accepts bare value or :Value = / :SubValue = named-param forms.
	def FindInCol(pCol, pValueOrNamed)
		return This.FindInColCS(pCol, pValueOrNamed, 1)

	def FindInColCS(pCol, pValueOrNamed, pCaseSensitive)
		# Strip a trailing :CS=... if the caller bundled three args.
		_pValue_ = pValueOrNamed
		_bSub_ = 0
		if isList(_pValue_) and len(_pValue_) = 2 and isString(_pValue_[1])
			_cKey_ = lower(_pValue_[1])
			if _cKey_ = "value" or _cKey_ = "ofvalue"
				_pValue_ = _pValue_[2]
			but _cKey_ = "subvalue" or _cKey_ = "ofsubvalue"
				_pValue_ = _pValue_[2]
				_bSub_ = 1
			ok
		ok
		if isList(pCaseSensitive) and len(pCaseSensitive) = 2 and
		   isString(pCaseSensitive[1]) and lower(pCaseSensitive[1]) = "cs"
			pCaseSensitive = pCaseSensitive[2]
		ok

		_nColIdx_ = This.FindCol(pCol)
		if _nColIdx_ = 0 return [] ok
		_aColData_ = @aContent[_nColIdx_][2]
		_nLenCol_ = len(_aColData_)
		_aRes_ = []
		for _iFcLocal_ = 1 to _nLenCol_
			_cell_ = _aColData_[_iFcLocal_]
			_bMatch_ = 0
			if _bSub_
				if isString(_cell_) and isString(_pValue_)
					if pCaseSensitive
						if StzFindFirst(_pValue_, _cell_) > 0 _bMatch_ = 1 ok
					else
						# StzCaseFold is codepoint-aware; upper() is byte-oriented
						# and missed multibyte case (accented cells).
						if StzFindFirst(StzCaseFold(_pValue_), StzCaseFold(_cell_)) > 0 _bMatch_ = 1 ok
					ok
				ok
			else
				if pCaseSensitive
					if _cell_ = _pValue_ _bMatch_ = 1 ok
				else
					if isString(_cell_) and isString(_pValue_)
						if StzCaseFold(_cell_) = StzCaseFold(_pValue_) _bMatch_ = 1 ok
					else
						if _cell_ = _pValue_ _bMatch_ = 1 ok
					ok
				ok
			ok
			if _bMatch_ _aRes_ + _iFcLocal_ ok
		next
		return _aRes_

	# TRUE if the column holds a cell equal to the value, case-sensitively.
	#
	#   returns    TRUE or FALSE
	#   warning    Answers FALSE, not an error, for a column that does not exist
	#   see        FindInCol
	#@ aka  ContainsCell(pCol, pValue) -- TRUE if any cell in column pCol equals pValue.
	def ContainsCell(pCol, pValue)
		return len(This.FindInCol(pCol, pValue)) > 0

		def ContainsCellInCol(pCol, pValue)
			return This.ContainsCell(pCol, pValue)

	# Returns how many cells of the column equal the value, case-sensitively.
	#
	#   pValueOrNamed   the value to count, or [ :Value, v ]
	#   returns         a number
	#   see             FindInCol
	#@ aka  NumberOfOccurrenceInCol -- count cells in column pCol matching pValueOrNamed. Accepts bare value / :Value / :OfValue / :OfSubValue.
	def NumberOfOccurrenceInCol(pCol, pValueOrNamed)
		_bSubNc_ = 0
		if isList(pValueOrNamed) and len(pValueOrNamed) = 2 and isString(pValueOrNamed[1]) and
		   ( lower(pValueOrNamed[1]) = "ofsubvalue" or lower(pValueOrNamed[1]) = "subvalue" )
			_bSubNc_ = 1
		ok

		if _bSubNc_
			return len(This.FindInCol(pCol, [ :SubValue, pValueOrNamed[2] ]))
		ok

		return len(This.FindInCol(pCol, _NormalizeColLookupKey(pValueOrNamed)))

		def NumberOfOccurrencesInCol(pCol, pValueOrNamed)
			return This.NumberOfOccurrenceInCol(pCol, pValueOrNamed)

		def NumberOfOccurrenceInColumn(pCol, pValueOrNamed)
			return This.NumberOfOccurrenceInCol(pCol, pValueOrNamed)

	# Returns how many cells of the row equal the value.
	#
	#   nRow       the row position
	#   pValue     the value to count, or [ :Value, v ]
	#   returns    a number
	#   see        NumberOfOccurrenceInCol
	#@ aka  NumberOfOccurrenceInRow(nRow, pValue) -- count cells in row nRow matching pValue. Walks each column at row index nRow.
	def NumberOfOccurrenceInRow(nRow, pValue)
		_pVal_ = _NormalizeColLookupKey(pValue)
		_bSub_ = 0
		if isList(pValue) and len(pValue) = 2 and isString(pValue[1]) and
		   lower(pValue[1]) = "ofsubvalue"
			_bSub_ = 1
		ok
		_nCount_ = 0
		_nCols_ = This.NumberOfCols()
		for _i_ = 1 to _nCols_
			_cell_ = @aContent[_i_][2][nRow]
			if _bSub_
				if isString(_cell_) and isString(_pVal_)
					if StzFindFirst(_pVal_, _cell_) > 0 _nCount_++ ok
				ok
			else
				if _cell_ = _pVal_ _nCount_++ ok
			ok
		next
		return _nCount_

		def NumberOfOccurrencesInRow(nRow, pValue)
			return This.NumberOfOccurrenceInRow(nRow, pValue)

	# Returns 1 when the cell at the given column and row equals the value, otherwise 0.
	#
	#   nCol       the column position, as a number
	#   nRow       the row position
	#   pValue     the value to compare with
	#   returns    0 or 1
	#   see        NumberOfOccurrenceInRow
	#@ aka  NumberOfOccurrenceInCell(nCol, nRow, pValue) -- check just the single cell at [nCol, nRow]. Returns 0 or 1 (1 if it matches).
	def NumberOfOccurrenceInCell(nCol, nRow, pValue)
		_pVal_ = _NormalizeColLookupKey(pValue)
		_bSub_ = 0
		if isList(pValue) and len(pValue) = 2 and isString(pValue[1]) and
		   lower(pValue[1]) = "ofsubvalue"
			_bSub_ = 1
		ok
		_cell_ = @aContent[nCol][2][nRow]
		if _bSub_
			if isString(_cell_) and isString(_pVal_) and StzFindFirst(_pVal_, _cell_) > 0
				return 1
			ok
			return 0
		ok
		if _cell_ = _pVal_ return 1 ok
		return 0

	# Returns the sum, over the given columns, of the cells equal to the value.
	#
	#   acCols     the columns to look in, by name or position
	#   returns    a number
	#   see        NumberOfOccurrenceInCol
	#@ aka  NumberOfOccurrenceInCols(acCols, pValue) -- sum across the listed columns.
	def NumberOfOccurrenceInCols(acCols, pValue)
		_nTot_ = 0
		_nLen_ = len(acCols)
		for _i_ = 1 to _nLen_
			_nTot_ += This.NumberOfOccurrenceInCol(acCols[_i_], pValue)
		next
		return _nTot_

		def NumberOfOccurrencesInCols(acCols, pValue)
			return This.NumberOfOccurrenceInCols(acCols, pValue)

	# NumberOfOccurrenceXT(:InCol/:InRow/:InCell/:InCols + :OfValue/:OfSubValue)
	def NumberOfOccurrenceXT(p1, p2)
		if NOT (isList(p1) and len(p1) = 2 and isString(p1[1]) and
		        isList(p2) and len(p2) = 2 and isString(p2[1]))
			StzRaise("NumberOfOccurrenceXT: expects two named-param lists.")
		ok
		_cWhere_ = lower(p1[1])
		_xTgt_   = p1[2]
		if _cWhere_ = "incol" or _cWhere_ = "incolumn"
			return This.NumberOfOccurrenceInCol(_xTgt_, p2)
		but _cWhere_ = "inrow"
			return This.NumberOfOccurrenceInRow(_xTgt_, p2)
		but _cWhere_ = "incell"
			if NOT (isList(_xTgt_) and len(_xTgt_) = 2)
				StzRaise(":InCell expects [nCol, nRow].")
			ok
			return This.NumberOfOccurrenceInCell(_xTgt_[1], _xTgt_[2], p2)
		but _cWhere_ = "incols" or _cWhere_ = "incolumns"
			return This.NumberOfOccurrenceInCols(_xTgt_, p2)
		ok
		return 0

	# ShowXT(opts) -- forwarder to Show(). The option list controls
	# row numbers, intersection chars, totals etc; until those are
	# fully ported, fall back to plain Show so callers don't R14.
	def ShowXT(pOpts)
		This.Show()

	# Sets every cell of the table to the same value, in place.
	#
	#   returns    nothing; the table changes
	#   see        FillSections
	#@ aka  Fill(pValue) -- replace every cell in the table with pValue.
	def Fill(pValue)
		_nCols_ = This.NumberOfCols()
		for _i_ = 1 to _nCols_
			_nRows_ = len(@aContent[_i_][2])
			for _j_ = 1 to _nRows_
				@aContent[_i_][2][_j_] = pValue
			next
		next
		This._InvalidateEngine()

		def FillQ(pValue)
			This.Fill(pValue)
			return This

	# Sets the listed cells to a value, in place; positions outside the table are skipped without an error.
	#
	#   aSections   the cells to fill, each as [ column position, row position ]
	#   pWith       the value to put, or [ :With, value ]
	#   returns     nothing; the table changes
	#   warning     Despite its name it takes single cells, not rectangular sections
	#   see         Fill
	#@ aka  FillSections(aSections, :With = value) -- replace cells in the given [colIdx, rowIdx] section pairs. Accepts the :With named param or a bare value as 2nd arg.
	def FillSections(aSections, pWith)
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1]) and
		   lower(pWith[1]) = "with"
			pWith = pWith[2]
		ok
		_nLen_ = len(aSections)
		for _i_ = 1 to _nLen_
			_sec_ = aSections[_i_]
			if isList(_sec_) and len(_sec_) = 2
				_c_ = _sec_[1]; _r_ = _sec_[2]
				if _c_ >= 1 and _c_ <= len(@aContent) and
				   _r_ >= 1 and _r_ <= len(@aContent[_c_][2])
					@aContent[_c_][2][_r_] = pWith
				ok
			ok
		next
		This._InvalidateEngine()

	# Removes every listed column, given by name or position, in place; unknown columns are ignored.
	#
	#   acCols     the columns to remove, by name or position
	#   returns    nothing; the table changes
	#   see        RemoveColumn
	#@ aka  RemoveCols(acColsOrNumbers) -- remove every column whose name or 1-based number is listed.
	def RemoveCols(acCols)
		_nLen_ = len(acCols)
		# Remove in two passes: resolve to indices first (since removal
		# shifts subsequent indices), then sort descending so we delete
		# from the right.
		_anIdx_ = []
		for _i_ = 1 to _nLen_
			_n_ = This.FindCol(acCols[_i_])
			if _n_ > 0 _anIdx_ + _n_ ok
		next
		# Sort descending
		_aSorted_ = _anIdx_
		_nSL_ = len(_aSorted_)
		for _i_ = 2 to _nSL_
			_v_ = _aSorted_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] < _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]
				_j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nSL_
			ring_remove(@aContent, _aSorted_[_i_])
		next
		This._InvalidateEngine()

		# Removes every listed column, given by name or position, in place; unknown columns are ignored.
		#
		#   acCols     the columns to remove, by name or position
		#   returns    nothing; the table changes
		#   see        RemoveCols
		def RemoveColumns(acCols)
			This.RemoveCols(acCols)

# Helper: normalise a column lookup key. Accepts bare value, :Value=...,
# :OfValue=..., :OfSubValue=...
func _NormalizeColLookupKey(pVal)
	if isList(pVal) and len(pVal) = 2 and isString(pVal[1])
		_k_ = lower(pVal[1])
		if _k_ = "value" or _k_ = "ofvalue" or _k_ = "subvalue" or _k_ = "ofsubvalue"
			return pVal[2]
		ok
	ok
	return pVal

		def CellQ(pCol, pnRow)
			return Q( This.Cell(pCol, pnRow) )

		#>

		#< @FunctionAlternativeForms

		def CellAtPosition(pCol, pnRow)
			return This.Cell(pCol, pnRow)

			def CellAtPositionQ(pCol, pnRow)
				return This.CellAtPosition(pCol, pnRow)

		def CellAt(pCol, pnRow)
			return This.Cell(pCol, pnRow)

			def CellAtQ(pCol, pnRow)
				return This.CellAtPosition(pCol, pnRow)

		#>

	  #------------------------------------------#
	 #  GETTING A CELL ALONG WITH ITS POSITION  #
	#------------------------------------------#

	def CellZ(pCol, pnRow)
		_nCol_ = This.ColToNumber(pCol)
		_nRow_ = This.RowToNumber(pnRow)

		_aResult_ = [ This.Cell(pCol, _nRow_), [ _nCol_, _nRow_ ] ]

		return _aResult_

		# Returns a cell together with its [ column, row ] position.
		#
		#   pRow       the row position
		#   returns    a list [ cell, [ column, row ] ]
		#   see        CellZ
		def CellAndPosition(pCol, pRow)
			return This.CellZ(pCol, pRow)

		# Returns a cell together with its [ column, row ] position.
		#
		#   pRow       the row position
		#   returns    a list [ cell, [ column, row ] ]
		#   see        CellZ
		def CellAndItsPosition(pCol, pRow)
			return This.CellZ(pCol, pRow)

	  #-----------------------------#
	 #  CELL FUNTCTION - EXTENDED  #
	#-----------------------------#

	def CellCSXT(pCellCol, pCellRow, pExpr, pValueORSubValue, pCaseSensitive)
		/*
		_o1_ = new stzTable([
			[ :NAME,	:AGE ],
			[ "Ali",	24   ],
			[ "Lio",	25   ],
			[ "Dan",	42   ]
		])

		This.CellXT( :NNAME, 2, :ContainsSubValue,  "io")
		#--> TRUE

		*/

		if isString(pExpr)
			if pExpr = :Contains or pExpr = :ContainsValue or
			   pExpr = :ContainsCellValue

				return This.CellContainsValueCS(pCellCol, pCellRow, pValueORSubValue, pCaseSensitive)

			but pExpr = :ContainsSubValue or pExpr = :ContainsCellPart or
			    pExpr = :ContainsSubPart

				return This.CellContainsSubValueCS(pCellCol, pCellRow, pValueOrSubValue, pCaseSensitive)

			ok
		ok

		StzRaise("Insuppported syntax!")

	#-- WITHOUT CASESENSITIVITY

	def CellXT(pCellCol, pCellRow, pExpr, pValueORSubValue)
		return This.CellCSXT(pCellCol, pCellRow, pExpr, pValueORSubValue, 1)

	  #----------------------------------------------------------------------------#
	 #  GETIING GIVEN CELLS VALUES BY THEIR POSITIONS (COLUMN, ROW) IN THE TABLE  #
	#----------------------------------------------------------------------------#

	# Returns the cells at the given [ column, row ] positions, in the order given.
	#
	#   paCellsPos   the positions, each as [ column, row ]
	#   returns      a list of cells
	#   warning      Raises R2 for a row past the last one
	#   see          Cell, CellsAsPositions
	def TheseCells(paCellsPos)
		/*
		_o1_ = new stzTable([
			[ :NATION,	:LANGUAGE ],
			[ "___",	"Arabic"  ],
			[ "France",	"___"  ],
			[ "USA",	"___" ]
		])

		_aSomeCells_ = [ [1, 1], [2, 2], [2, 3] ]

		? _o1_.TheseCells(_aSomeCells_)
		#--> [ "___", "___", "___" ]
		*/

		_aResult_ = []
		_nLen_ =  len(paCellsPos)

		for i = 1 to _nLen_

			_aResult_ + This.Cell( paCellsPos[i][1], paCellsPos[i][2] )
		next

		return _aResult_

		#< @FunctionFluentForm

		def TheseCellsQ(paCellsPos)
			return TheseCellsQRT(paCellsPos, :stzList)

		def TheseCellsQRT(paCellsPos, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseCells(paCellsPos) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseCells(paCellsPos) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseCells(paCellsPos) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAtPositions(paCellsPos)
			return This.TheseCells(paCellsPos)

			def CellsAtPositionsQ(paCellsPos)
				return This.CellsAtPositions(paCellsPos, :stzList)

			def CellsAtPositionsQRT(paCellsPos, pcReturnType)
				return This.TheseCellsQRT(paCellsPos, pcReturnType)

		def CellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def CellsAtQ(paCellsPos)
				return This.CellsAtPositions(paCellsPos, :stzList)

			def CellsAtQRT(paCellsPos, pcReturnType)
				return This.TheseCellsQRT(paCellsPos, pcReturnType)

		def TheseCellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtQ(paCellsPos)
				return This.TheseCellsAt(paCellsPos, :stzList)

			def TheseCellsAtQRT(paCellsPos, pcReturnType)
				return This.TheseCellsQRT(paCellsPos, pcReturnType)

		def TheseCellsAtPositions(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtPositionsQ(paCellsPos)
				return This.TheseCellsAtPositions(paCellsPos, :stzList)

			def TheseCellsAtPositionsQRT(paCellsPos, pcReturnType)
				return This.TheseCellsQRT(paCellsPos, pcReturnType)

		#>

	  #---------------------------------#
	 #  GETIING THE LIST OF ALL CELLS  #
	#---------------------------------#

	# Returns every cell of the table as one flat list, row by row.
	#
	#   returns    a list of cells
	#   see        CellsAsPositions, Rows
	def Cells()

		_aResult_ = This.Section( [ 1, 1 ], [ This.NumberOfCols(), This.NumberOfRows() ] )
		return _aResult_

		#< @FunctionFluentForm

		def CellsQ()
			return This.CellsQRT(:stzList)

		def CellsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Cells() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Cells() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Cells() )

			on :stzListOfLists
				return new stzListOfLists( This.Cells() )

			on :stzListOfHashLists
				return new stzListOfHashLists( This.Cells() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Cells() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def AllCells() # Useful by contrast to TheseCells(paCells)
			return This.Cells()

			def AllCellsQ()
				return This.CellsQRT(:stzList)

			def AllCellsQRT(pcReturnType)
				return This.CellsQRT(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------#

	# Returns every cell with its [ column, row ] position, row by row.
	#
	#   returns    a list of [ cell, [ column, row ] ] pairs
	#   see        PositionsAndCells
	def CellsAndTheirPositions()

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_

			for u = 1 to _nCols_
				_aResult_ + [ This.Cell(u, v), [u, v ] ]
			next u

		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsAndPositions()
			return This.CellsAndTheirPositions()

		def AllCellsAndTheirPositions()
			return This.CellsAndTheirPositions()

		def AllCellsAndPositions()
			return This.CellsAndTheirPositions()

		#--

		def CellsZ()
			return This.CellsAndTheirPositions()

		def AllCellsZ()
			return This.CellsAndTheirPositions()

	# Returns every [ column, row ] position with its cell, row by row.
	#
	#   returns    a list of [ [ column, row ], cell ] pairs
	#   see        CellsAndTheirPositions
		#>
	def PositionsAndCells()

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_
			for u = 1 to _nCols_
				_aResult_ + [ [u, v ], This.Cell(u, v) ]
			next
		next

		return _aResult_

	# Returns the [ column, row ] position of every cell, row by row.
	#
	#   returns    a list of [ column, row ] pairs
	#   see        CellsAndTheirPositions
	def CellsAsPositions()

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_
			for u = 1 to _nCols_
				_aResult_ + [u, v ]
			next
		next

		return _aResult_

		def AllCellsAsPositions()
			return This.CellsAsPositions()

	  #-----------------------------------------------------------#
	 #  GETIING THE LIST OF THE GIVEN CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------------#

	def TheseCellsZ(paCells)
		_aResult_ = []
		_nCells_ = len(paCells)

		for i = 1 to _nCells_
			_aCell_ = paCells[i]
			_aResult_ + [ This.Cell(_aCell_[1], _aCell_[2]), _aCell_ ]
		next

		return _aResult_

		def TheseCellsAndTheirPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsAndPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsXT(paCells)
			return This.TheseCellsZ(paCells)

	# Pairs each given [ column, row ] position with the cell found there.
	#
	#   paCells    the positions, each as [ column, row ]
	#   returns    a list of [ position, cell ] pairs
	#   see        TheseCells
	def PositionsAndTheseCells(paCells)
		_aResult_ = []
		_nCells_ = len(paCells)

		for i = 1 to _nCells_
			_aCell_ = paCells[i]
			_aResult_ + [ _aCell_, This.Cell(_aCell_[1], _aCell_[2]) ]
		next

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS BY TRANSFORMING IT TO A HASHLIST  #
	#------------------------------------------------------------------#

	# Returns every cell keyed by the text of its [ column, row ] position, row by row.
	#
	#   returns    a list of [ "[ 1, 1 ]", cell ] pairs
	#   see        CellsAndTheirPositions
	def CellsToHashList()
		_aResult_ = This.TheseCellsToHashList( This.CellsAsPositions() )
		return _aResult_

		#< @FunctionFluentForm

		def CellsToHashListQ()
			return This.CellsToHashListQRT( :stzList )

		def CellsToHashListQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.CellsToHashList() )

			on :stzHashList
				return new stzHashList( This.CellsToHashList() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAsHashList()
			return This.CellsToHashList()

			def CellsAsHashListQ()
				return This.CellsAsHashListQRT(:stzList)

			def CellsAsHashListQRT(pcReturnType)
				return This.CellsToHashListQRT(pcReturnType)

	# Returns the cells at the given positions, each keyed by the text of its [ column, row ] position.
	#
	#   paCellsPos   the positions, each as [ column, row ]
	#   returns      a list of [ "[ 1, 1 ]", cell ] pairs
	#   see          TheseCells
		#>
	def TheseCellsToHashList(paCellsPos)
		#TODO // check if paCells are really cells and belong to the table!

		_aResult_ = []
		_nLen_ = len(paCellsPos)

		for i = 1 to _nLen_
			_cellPos_ = paCellsPos[i]
			_aResult_ + [ @@(_cellPos_), This.Cell(_cellPos_[1], _cellPos_[2]) ]
		next

		return _aResult_

		#< @FunctionFluentForm

		def TheseCellsToHashListQ(paCellsPos)
			return This.TheseCellsToHashListQRT(paCellsPos, pcReturnType)

		def TheseCellsToHashListQRT(paCellsPos, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseCellsToHashList(paCellsPos) )

			on :stzHashList
				return new stzList( This.TheseCellsToHashList(paCellsPos) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeFrom

		def TheseCellsAsHashList(paCellsPos)
			return This.TheseCellsToHashList(paCellsPos)

			def TheseCellsAsHashListQ(paCellsPos)
				return This.TheseCellsAsHashListQRT(paCellsPos, pcReturnType)

			def TheseCellsAsHashListQRT(paCellsPos, pcReturnType)
				return This.TheseCellsToHashListQRT(paCellsPos, pcReturnType)

		#>

	  #==============================#
	 #  GETTING A SECTION OF CELLS  #
	#==============================#

		def SectionQ( panCellPos1, panCellPos2 )
			return This.SectionQRT( panCellPos1, panCellPos2, :stzList )

		def SectionQRT( panCellPos1, panCellPos2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.Section( panCellPos1, panCellPos2 ) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Section( panCellPos1, panCellPos2 ) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Section( panCellPos1, panCellPos2 ) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Section( panCellPos1, panCellPos2 ) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInSection(panCellPos1, panCellPos2)
			return This.Section( panCellPos1, panCellPos2 )

			def CellsInSectionQ(panCellPos1, panCellPos2)
				return This.SectionQ( panCellPos1, panCellPos2 )

			def CellsInSectionQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionQRT( panCellPos1, panCellPos2, pcReturnType )

		#>

	def SectionZ( panCellPos1, panCellPos2 )

		_aResult_ = This.SectionAsPositionsQ(panCellPos1, panCellPos2).
			       AssociatedWith( This.Section(panCellPos1, panCellPos2) )

		return _aResult_

		#< @FunctionFluentForms

		def SectionZQ( panCellPos1, panCellPos2 )
			return This.SectionZQRT( panCellPos1, panCellPos2, :stzList )

		def SectionZQRT( panCellPos1, panCellPos2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionZ( panCellPos1, panCellPos2 ) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionZ( panCellPos1, panCellPos2 ) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SectionAndPosition( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def SectionAndPositionQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def SectionAndPositionQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQRT( panCellPos1, panCellPos2, pcReturnType )

		def SectionAndItsPosition( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def SectionAndItsPositionQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def SectionAndItsPositionQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQRT( panCellPos1, panCellPos2, pcReturnType )

		#--

		def CellsInSectionZ( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def CellsInSectionZQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def CellsInSectionZQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQRT( panCellPos1, panCellPos2, pcReturnType )

		def CellsInSectionAndPosition( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def CellsInSectionAndPositionQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def CellsInSectionAndPositionQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQRT( panCellPos1, panCellPos2, pcReturnType )

		def CellsInSectionAndItsPosition( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def CellsInSectionAndItsPositionQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def CellsInSectionAndItsPositionQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQRT( panCellPos1, panCellPos2, pcReturnType )

	# Returns the positions of the block between two [ column, row ] corners, row by row, like Section.
	#
	#   panCellPos1   the first corner, [ column, row ] or :FirstCell
	#   panCellPos2   the last corner, [ column, row ] or :LastCell
	#   returns       a list of [ column, row ] pairs
	#   see           Section
		#>
	def SectionAsPositions( panCellPos1, panCellPos2 )
		if CheckingParams()
			if isList(panCellPos1) and Q(panCellPos1).IsFromNamedParam()
				panCellPos1 = panCellPos1[2]
			ok

			if isList(panCellPos2) and Q(panCellPos2).IsToNamedParam()
				panCellPos2 = panCellPos2[2]
			ok

			if isString(panCellPos1)
				if panCellPos1 = :First or panCellPos1 = :FirstCell
					panCellPos1 = This.FirstCellPosition()

				else
					StzRaise("Syntax error in (" + panCellPos1 + ")! Allowed values are :First or :FirstCell.")
				ok
			ok

			if isString(panCellPos2)
				if panCellPos2 = :First or panCellPos2 = :LastCell
					panCellPos2 = This.LastCellPosition()

				else
					StzRaise("Syntax error in (" + panCellPos2 + ")! Allowed values are :Last or :LastCell.")
				ok
			ok

			if isList(panCellPos1)
				if isString(panCellPos1[1]) and panCellPos1[1] = :FirstCol
					panCellPos1 = Q(panCellPos1).ReplaceAtQ(1, 1).Content()
				ok

				if isString(panCellPos1[2]) and panCellPos1[2] = :FirstRow
					panCellPos1 = Q(panCellPos1).ReplaceAtQ(2, 1).Content()
				ok

				if isString(panCellPos2[1]) and panCellPos2[1] = :LastCol
					panCellPos2 = Q(panCellPos2).ReplaceAtQ(1, This.NumberOfCol() ).Content()
				ok

				if isString(panCellPos2[2]) and panCellPos2[2] = :LastRow
					panCellPos2 = Q(panCellPos2).ReplaceAtQ( 2, This.NumberOfRows() ).Content()
				ok
			ok

			if isList(panCellPos2)
				if isString(panCellPos2[1]) and panCellPos2[1] = :LastCol
					panCellPos2[1] = This.NumberOfCol()
				ok

				if isString(panCellPos2[2]) and panCellPos2[2] = :LastRow
					panCellPos2[2] = This.NumberOfRows()
				ok

				if isString(panCellPos1[1]) and This.IsAColName((panCellPos1[1]))
					panCellPos1[1] = This.ColToColNumber(panCellPos1[1])
				ok

				if isString(panCellPos2[1]) and This.IsAColName((panCellPos2[1]))
					panCellPos2[1] = This.ColToColNumber(panCellPos2[1])
				ok

			ok
		ok
		# end of CheckParams()

		if NOT ( isList(panCellPos1) and Q(panCellPos1).IsPairOfNumbers() and
			 isList(panCellPos2) and Q(panCellPos2).IsPairOfNumbers() )

			StzRaise("Incorrect params types! panCellPos1 and panCellPos2 must be pairs of numbers.")
		ok

		# Doing the job: the block between the two corners, row by row, exactly the cells Section gives

		_nCol1_ = panCellPos1[1]
		_nRow1_ = panCellPos1[2]

		_nCol2_ = panCellPos2[1]
		_nRow2_ = panCellPos2[2]

		_aResult_ = []

		for j = _nRow1_ to _nRow2_
			for i = _nCol1_ to _nCol2_
				_aResult_ + [ i, j ]
			next
		next

		return _aResult_

		#< @FunctionFluentForm

		def SectionAsPositionsQ( panCellPos1, panCellPos2 )
			return This.SectionAsPositionsQRT( panCellPos1, panCellPos2, :stzList )

		def SectionAsPositionsQRT( panCellPos1, panCellPos2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionAsPositions(panCellPos1, panCellPos2))

			on :stzListOfLists
				return new stzListOfLists( This.SectionAsPositions(panCellPos1, panCellPos2))

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionAsPositions(panCellPos1, panCellPos2))

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInSectionAsPositions( panCellPos1, panCellPos2 )
			return This.SectionAsPositions( panCellPos1, panCellPos2 )

			def CellsInSectionAsPositionsQ( panCellPos1, panCellPos2 )
				return This.SectionAsPositionsQ( panCellPos1, panCellPos2 )

			def CellsInSectionAsPositionsQRT( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionAsPositionsQRT( panCellPos1, panCellPos2, pcReturnType )

		#--

		def FindSection(panCellPos1, panCellPos2)
			return This.SectionAsPositions( panCellPos1, panCellPos2 )

		def FindCellsInSection(panCellPos1, panCellPos2)
			return This.SectionAsPositions( panCellPos1, panCellPos2 )

		#>

	  #---------------------------------------------------#
	 #   COLUMN SECTIONS (SOME CELLS OF A GIVEN COLUMN)  #
	#===================================================#

	# Returns the cells of one column between two row positions.
	#
	#   _n1_       the first row of the section
	#   _n2_       the last row of the section
	#   returns    a list of cells
	#   see        ColSectionAsPositions, RowSection
	def ColSection(pCol, _n1_, _n2_)

		_aCellsPos_ =  This.ColSectionAsPositions(pCol, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		def ColumnSection(pCol, _n1_, _n2_)
			return This.ColSection(pCol, _n1_, _n2_)

	# Returns the [ column, row ] positions of one column between two row positions.
	#
	#   _n1_       the first row of the section
	#   _n2_       the last row of the section
	#   returns    a list of [ column, row ] pairs
	#   see        ColSection
	def ColSectionAsPositions(pCol, _n1_, _n2_)
		if CheckingParams()
			if isList(_n1_)

				if StzListIsOneOfTheseNamedParamsList(_n1_,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)
				if StzListIsOneOfTheseNamedParamsList(_n2_,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					_n2_ = _n2_[2]
				ok
			ok

			if isString(pCol)
				if StzFindFirst(pCol, [ :First, :FirstCol, :FirstColumn ]) > 0
					pCol = 1

				but StzFindFirst(pCol, [ :Last, :LastCol, :LastColumn ]) > 0
					pCol = This.NumberOfColumns()

				but This.HasColName(pCol)
					pCol = This.FindCol(pCol)
				ok
			ok

			if NOT isNumber(pCol)
				StzRaise("Incorrect param type! pCol must be a number.")
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstRow
					_n1_ = 1
				ok
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok

			if isString(_n2_)
				if _n2_ = :Last or _n2_ = :LastRow
					_n2_ = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(_n2_)
				StzRaise("Incorrect param type! n2 must be a number.")
			ok
		ok

		_aResult_ = []
		for i = _n1_ to _n2_
			_aResult_ + [pCol, i]
		next

		return _aResult_

		#< @FunctionAlternativeForm

		def ColumnSectionAsPositions(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindColSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindColumnSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindCellsInColSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindCellsColumnSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A COL SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	# Returns the cells of one column between two row positions, each with its [ column, row ] position.
	#
	#   _nCol_     the column position
	#   _n1_       the first row of the section
	#   _n2_       the last row of the section
	#   returns    a list of [ cell, [ column, row ] ] pairs
	#   see        ColSection
	def CellsInColSectionZ(_nCol_, _n1_, _n2_)
		_anCellsPos_ = This.FindCellsInColSection(_nCol_, _n1_, _n2_)
		_aCells_ = This.CellsAtPositions(_anCellsPos_)
		_aResult_ = Association([ _aCells_, _anCellsPos_ ])

		return _aResult_

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#====================================================#

	# Returns the cells of one row between two column positions.
	#
	#   _nRow_     the row position
	#   _n1_       the first column of the section
	#   _n2_       the last column of the section
	#   returns    a list of cells
	#   see        RowSectionAsPositions, ColSection
	def RowSection(_nRow_, _n1_, _n2_)
		_aCellsPos_ =  This.RowSectionAsPositions(_nRow_, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInRowSection(_nRow_, _n1_, _n2_)
			return This.RowSection(_nRow_, _n1_, _n2_)

	# Returns the [ column, row ] positions of one row between two column positions.
	#
	#   _nRow_     the row position
	#   _n1_       the first column of the section
	#   _n2_       the last column of the section
	#   returns    a list of [ column, row ] pairs
	#   see        RowSection
		#>
	def RowSectionAsPositions(_nRow_, _n1_, _n2_)
		if CheckingParams()

			if isList(_n1_)
				if StzListIsOneOfTheseNamedParamsList(_n1_,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)

				if StzListIsOneOfTheseNamedParamsList(_n2_,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					_n2_ = _n2_[2]
				ok
			ok

			if isString(_nRow_)

				if StzFindFirst(_nRow_, [ :First, :FirstRow]) > 0
					_nRow_ = 1

				but StzFindFirst(_nRow_, [ :Last, :LastRow ]) > 0
					_nRow_ = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(_nRow_)
				StzRaise("Incorrect param type! nRow must be a number.")
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstCol
					_n1_ = 1
				ok
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok

			if isString(_n2_)
				if _n2_ = :Last or _n2_ = :LastCol
					_n2_ = This.NumberOfCols()
				ok
			ok

			if NOT isNumber(_n2_)
				StzRaise("Incorrect param type! n2 must be a number.")
			ok
		ok

		_aResult_ = []
		for i = _n1_ to _n2_
			_aResult_ + [i, _nRow_]
		next

		return _aResult_

		#< @FunctionAlternativeForm

		def FindRowSection(_nRow_, _n1_, _n2_)
			return This.RowSectionAsPositions(_nRow_, _n1_, _n2_)

		def FindCellsInRowSection(_nRow_, _n1_, _n2_)
			return This.RowSectionAsPositions(_nRow_, _n1_, _n2_)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A ROW SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	def CellsInRowSectionZ(_nRow_, _n1_, _n2_)
		_anCellsPos_ = This.FindCellsInRowSection(_nRow_, _n1_, _n2_)
		_aCells_ = This.CellsAtPositions(_anCellsPos_)
		_aResult_ = Association([ _aCells_, _anCellsPos_ ])

		return _aResult_

	  #-------------------------------------------------#
	 #   CONVERTING A SECTION OF CELLS TO A HASHLIST   #
	#=================================================#

	# Returns the cells between two corners, each keyed by the text of its [ column, row ] position.
	#
	#   panCellPos1   the first corner, [ column, row ]
	#   panCell2      the last corner, [ column, row ]
	#   returns       a list of [ "[ 1, 1 ]", cell ] pairs
	#   warning       Follows the column-by-column order of SectionAsPositions
	#   see           SectionAsPositions
	def SectionToHashList(panCellPos1, panCell2)
		_aResult_ = TheseCellsToHashList( This.SectionAsPositions(panCellPos1, panCell2) )
		return _aResult_

		def SectionToHashListQ(panCellPos1, panCellPos2)
			return This.SectionsToHashListQRT(panCellPos1, panCellPos2, :stzList)

		def SectionToHashListQRT(panCellPos1, panCellPos2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionToHashList(panCellPos1, panCellPos2) )

			on :stzHashList
				return new stzHashList( This.SectionToHashList(panCellPos1, panCellPos2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SectionToHashList(panCellPos1, panCellPos2) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SectionToHashList(panCellPos1, panCellPos2) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionToHashList(panCellPos1, panCellPos2) )

			other
				StzRaise("Unsupported return type!")
			off

	  #============================#
	 #  GETTING A RANGE OF CELLS  #
	#============================#

	// TODO

	# Raises error today instead of returning a range of the table.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    nothing; it raises
	#   warning    Always raises Feature not implemented yet!
	#   see        Section
	def SectionToRange(_n1_, _n2_) // TODO
		StzRaise("Feature not implemented yet!")

	# Raises error today instead of returning a block of the table between two bounds.
	#
	#   paPair     a pair of positions
	#   paRange    the range to read
	#   returns    nothing; it raises
	#   warning    Always raises Feature not implemented yet!
	#   see        Section
	def Range(paPair, paRange) // TODO
		StzRaise("Feature not implemented yet!")

		def ColQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Col(p) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Col(p) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Col(p) )

			on :stzListOfLists
				return new stzListOfLists( This.Col(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Col(p) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Col(p) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Col(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

			def ColumnQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def ColumnData(p)
			return This.Col(p)

			def ColumnDataQ(p)
				return This.ColumnQRT(p, :stzList)

			def ColumnDataQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def ColData(p)
			return This.Col(p)

			def ColDataQ(p)
				return This.ColumnQRT(p, :stzList)

			def ColDataQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def CellsInCol(p)
			return This.Col(p)

			def CellsInColQ(p)
				return This.CellsInColQRT(p, :stzList)

			def CellsInColQRT(p, pcReturnType)
				return This.CellsInColQRT(p, pcReturnType)

		def CellsInColumn(p)
			return This.Col(p)

			def CellsInColumnQ(p)
				return This.CellsInColumnQRT(p, :stzList)

			def CellsInColumnQRT(p, pcReturnType)
				return This.CellsInColumnQRT(p, pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE PROVIDED COLUMNS  #
	#-----------------------------------------------------#

	# Returns the cells of the given columns, column after column.
	#
	#   returns    a list of cells
	#   see        ColsAsPositions
	def CellsInCols(paCols)

		if NOT ( isList(paCols) and
			IsListOfNumbersOrStrings(paCols) and
			This.AreColumnsIdentifiers(paCols))

			StzRaise("Incorrect param type! paCols must be a list of string containing existing columns names.")
		ok

		_nLen_ = len(paCols)

		_aResult_ = []
		for i = 1 to _nLen_
			_aResult_ + This.CellsInCol(paCols[i])
		next

		_aResult_ = Q(_aResult_).Flattened()
		return _aResult_

	  #------------------------------------------------#
	 #  GETTING THE COLUMN NAME AND THE COLUMN CELLS  #
	#------------------------------------------------#

	def ColXT(p)
		_aResult_ = [ This.ColName(p) ]

		_aCells_ = This.Col(p)
		_nLen_ = len(_aCells_)

		for i = 1 to _nLen_
			_aResult_ + _aCells_[i]
		next

		return _aResult_

		#< @FunctionFluentForm

		def ColXTQ(p)
			return This.ColXTQRT(p, :stzList)

		def ColXTQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ColXT(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.COlXT(p) )

			on :stzListOfLists
				return new stzListOfLists( This.ColXT(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ColumnXT(p)
			return This.ColXT(p)

			def ColumnXTQ(p)
				return This.ColumnXTQRT(p, :stzList)

			def ColumnXTQRT(p, pcReturnType)
				return This.ColXTQRT(p, pcReturnType)

		def CellsInColXT(p)
			return This.ColXT(p)

			def CellsInColXTQ(p)
				return This.CellsInColXTQRT(p, :stzList)

			def CellsInColXTQRT(p, pcReturnType)
				return This.CellsInColXTQRT(p, pcReturnType)

		def CellsInColumnXT(p)
			return This.ColXT(p)

			def CellsInColumnXTQ(p)
				return This.CellsInColumnXTQRT(p, :stzList)

			def CellsInColumnXTQRT(p, pcReturnType)
				return This.CellsInColumnXTQRT(p, pcReturnType)

		#>

	  #=======================#
	 #  GETTING COLUMN NAME  #
	#=======================#

		def NthColumnName(_n_)
			return This.NthColName(_n_)

	  #------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE NTH COLUMN   #
	#------------------------------------------------#

	def NthCol(_n_)
		return This.Col(_n_)

		def NthColumn(_n_)
			return This.NthCol(_n_)

		def CellsInNthCol(_n_)
			return This.NthCol(_n_)

		def CellsInNthColumn(_n_)
			return This.NthCol(_n_)

		def NthColData(_n_)
			return This.NthCol(_n_)

		def NthColumnData(_n_)
			return This.NthCol(_n_)

	  #-------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF NTH COLUMN ALONG WITH ITS CELLS  #
	#-------------------------------------------------------------------------#

	def NthColXT(_n_)
		if isString(_n_)
			if _n_ = :first or _n_ = :FirstCol or _n_ = :FirstColumn
				_n_ = 1

			but _n_ = :Last or _n_ = :LastCol or _n_ = :LastColumn
				_n_ = This.NumberOfCol()
			ok
		ok

		return This.ColXT(_n_)

		def NthColumnXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColumnXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInColNAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInNthColumnAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInColumnNAndTheirPositions(_n_)
			return This.ColXT(_n_)

	  #----------------------------------------#
	 #  GETTING THE NAME OF THE FIRST COLUMN  #
	#========================================#

		def FirstColumnName()
			return This.FirstColName()

	  #------------------------------------------------------#
	 #   GETTING FIRST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#------------------------------------------------------#

	# Returns the cells of the first column, top to bottom.
	#
	#   returns    a list of cells
	#   see        LastCol, Col
	def FirstCol()
		return This.NthCol(1)

		def FirstColumn()
			return This.FirstCol()

		def FirstColData()
			return This.FirstCol()

		def FirstColumnData()
			return This.FirstCol()

	  #---------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF FIRST COLUMN ALONG WITH IST CELLS  #
	#---------------------------------------------------------------------------#

	def FirstColXT()
		return This.NthCOlXT(1)

		def FirstColumnXT()
			return This.FirstColXT()


	  #---------------------------------------#
	 #  GETTING THE NAME OF THE LAST COLUMN  #
	#=======================================#

		def LastColumnName()
			return This.LastColName()

	  #-----------------------------------------------------#
	 #   GETTING LAST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#-----------------------------------------------------#

	# Returns the cells of the last column, top to bottom.
	#
	#   returns    a list of cells
	#   see        FirstCol, Col
	def LastCol()
		return This.NthCol(This.NumberOfCols())

		def LastColumn()
			return This.LastCol()

		def LastColData()
			return This.LastCol()

		def LastColumnData()
			return This.LastCol()

	  #--------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF LAST COLUMN ALONG WITH IST CELLS  #
	#--------------------------------------------------------------------------#

	def LastColXT()
		return This.NthCOlXT(This.NumberOfCols())

		def LastColumnXT()
			return This.LastColXT()

	  #=======================#
	 #  GETTING COLUMN NAME  #
	#=======================#

		def ColNameQ(_n_)
			return new stzString( This.ColName(_n_) )

			def ColumnNameQ(_n_)
				return new stzString( This.ColumnName(_n_) )

	  #--------------------------------------------------------#
	 #  GETTING CELLS AND THEIR POSITIONS IN A GIVEN COLUMN   #
	#--------------------------------------------------------#

	# Returns the cells of one column, each with its [ column, row ] position.
	#
	#   p          the column, by name or position
	#   returns    a list of [ cell, [ column, row ] ] pairs
	#   see        ColAsPositions
	def CellsAndPositionsInCol(p)
		_aResult_ = This.ColQ(p).AssociatedWith( This.CellsInColAsPositions(p) )

		return _aResult_

		#< @FunctionFluentForm

		def CellsAndPositionsInColQ(p)
			return This.CellsAndPositionsInColQRT(p, :stzList)

		def CellsAndPositionsInColQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.CellsAndPositionsInCol(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.CellsAndPositionsInCol(p) )

			on :stzListOfLists
				return new stzListOfLists( This.CellsAndPositionsInCol(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInColumn(p)
			return This.CellsAndPositionsInCol(p)

			def CellsAndPositionsInColumnQ(p)
				return This.CellsAndPositionsInColumnQRT(p, :stzList)

			def CellsAndPositionsInColumnQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		def ColZ(p)
			return This.CellsAndPositionsInCol(p)

			def ColZQ(p)
				return This.ColZQRT(p, :stzList)

			def ColZQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		def CellsInColZ(p)
			return This.CellsAndPositionsInCol(p)

			def CellsInColZQ(p)
				return This.ColZQRT(p, :stzList)

			def CellsInColZQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		#>

	  #----------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN COLUMN   #
	#----------------------------------------------------------#

	# Returns the [ column, row ] position of every cell of one column.
	#
	#   returns    a list of [ column, row ] pairs
	#   warning    Raises an error for a column that does not exist
	#   see        RowAsPositions
	def ColAsPositions(pCol)
		if NOT This.IsCol(pCol)
			StzRaise("Incorrect param value! " + @@(pCol) + " is not a valid column identifier.")
		ok

		_nCol_ = This.ColToColNumber(pCol)

		_nNumberOfRows_ = This.NumberOfRows()

		_aResult_ = []

		for i = 1 to _nNumberOfRows_
			_aResult_ + [ _nCol_, i]
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def ColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#==

		def PositionsOfCellsInCol(pCol)
			return This.ColAsPositions(pCol)

		def PositionsOfCellsInColumn(pCol)
			return This.ColAsPositions(pCol)

		#==

		def CellsToColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def ColToPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		#>

	  #--------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY COLUMNS   #
	#--------------------------------------------------------#

	# Returns the [ column, row ] positions of every cell of the given columns, column by column.
	#
	#   returns    a list of [ column, row ] pairs
	#   see        ColAsPositions
	def ColsAsPositions(paCols)
		_nLen_ = len(paCols)
		_anColNumbers_ = This.TheseColsAsNumbers(paCols)
		_aResult_ = []

		for i = 1 to _nLen_
			_aCellsPos_ = This.CellsInColAsPositions(_anColNumbers_[i])
			_nLenCells_ = len(_aCellsPos_)

			for j = 1 to _nLenCells_
				_aResult_ + _aCellsPos_[j]
			next
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColumnsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def PositionsOfCellsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def PositionsOfCellsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def CellsToColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInCols(pCol)
			return This.ColsAsPositions(pCol)

		def ColsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#>

		def RowQ(_n_)
			return This.RowQRT(_n_, :stzList)

		def RowQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(_n_) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(_n_) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(_n_) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(_n_) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(_n_) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def RowN(_n_)
			return This.Row(_n_)

			def RowNQ(_n_)
				return This.RownQRT(_n_, :stzList)

			def RowNQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def NthRow(_n_)
			return This.Row(_n_)

			def NthRowQ(_n_)
				return This.NthRowQRT(_n_, :stzList)

			def NthRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInRow(_n_)
			return This.Row(_n_)

			def CellsInRowQ(_n_)
				return This.CellsInRowQRT(_n_, :stzList)

			def CellsInRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInRowN(_n_)
			return This.Row(_n_)

			def CellsInRowNQ(_n_)
				return This.CellsInRowNQRT(_n_, :stzList)

			def CellsInRowNQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInNthRow(_n_)
			return This.Row(_n_)

			def CellsInNthRowQ(_n_)
				return This.CellsInNthRowQRT(_n_, :stzList)

			def CellsInNthRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)
		#>

	  #----------------------------------#
	 #  GETTING THE CELLS OF MANY ROWS  #
	#----------------------------------#

	# Returns the cells of the given rows, row by row, as one flat list.
	#
	#   panRows    the row positions
	#   returns    a list of cells
	#   see        RowsAsPositions
	def CellsInRows(panRows)
		if NOT ( isList(panRows) and @IsListOfNumbers(panRows) )
			StzRaise("Incorrect param type! panRows must be a list of numbers.")
		ok

		_aResult_ = This.TheseCells(RowsAsPositions(panRows))
		return _aResult_

	  #-----------------------#
	 #   GETTING FIRST ROW   #
	#-----------------------#

	# Returns the cells of the first row, left to right.
	#
	#   returns    a list of cells
	#   see        LastRow, Row
	def FirstRow()
		return This.NthRow(1)

	def FirstRowXT()
		return This.NthRowXT(1)

	  #----------------------#
	 #   GETTING LAST ROW   #
	#----------------------#

	def LastRowXT()
		return This.NthRowXT(This.NumberOfRows())

		# Returns how many rows the table has.
		#
		#   returns    a number
		#   see        NumberOfRows
		def Size()
			return NumberOfRows()

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

		def RowsQ()
			return This.RowsQRT(:stzList)

		def RowsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Rows() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Rows() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Rows() )

			on :stzListOfChars
				return new stzListOfChars( This.Rows() )

			on :stzListOfLists
				return new stzListOfLists( This.Rows() )

			on :stzListOfHashLists
				return new stzListOfHashLists( This.Rows() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Rows() )

			on :stzListOfSets
				return new stzListOfSets( This.Rows() )

			on :stzListOfObjects
				return new stzListOfNumbers( This.Rows() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def AllRows() # In contrast with TheseRows(panRows)
			return This.Rows()

			def AllRowsQ()
				return This.AllRowsQRT(:stzList)

			def AllRowsQRT(pcReturnType)
				return This.RowsQRT(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #   GETTING CELLS AND THEIR POSITIONS IN A GIVN ROW   #
	#-----------------------------------------------------#

	def RowZ(_n_)
		_aResult_ = RowQ(_n_).AssociatedWith( This.CellsInRowAsPositions(_n_) )
		return _aResult_

		#< @FunctionFluentForm

		def RowZQ(_n_)
			return This.RowZQRT(p, :stzList)

		def RowZQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowZ(_n_) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowZ(_n_) )

			on :stzListOfLists
				return new stzListOfLists( This.RowZ(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInRow(_n_)
			return This.RowZ(_n_)

			def CellsAndPositionsInRowQ(_n_)
				return This.CellsAndPositionsInRowNQRT(_n_, :stzList)

			def CellsAndPositionsInRowQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsInRowZ(_n_)
			return This.RowZ(_n_)

			def CellsInRowZQ(_n_)
				return This.CellsInRowZQRT(_n_, :stzList)

			def CellsInRowZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		# Returns the cells of one row, each paired with its [ column, row ] position.
		#
		#   _n_        the row position
		#   returns    a list of [ cell, [ column, row ] ] pairs
		#   see        RowZ
		def CellsInRowNAndTheirPositions(_n_)
			return This.RowZ(_n_)

			# Returns the cells of row n, each with its [ column, row ] position, wrapped in a stzList.
			#
			#   _n_        the row position
			#   returns    a stzList of [ cell, [ column, row ] ] pairs
			#   see        RowZ
			def CellsInRowNAndTheirsPositionsQ(_n_)
				return This.CellsInRowNAndTheirsPositionsQRT(_n_, :stzList)

			def CellsInRowNAndTheirsPositionsQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsAndPositionsInRowN(_n_)
			return This.RowZ(_n_)

			def CellsAndPositionsInRowNQ(_n_)
				return This.CellsAndPositionsInRowNQRT(_n_, :stzList)

			def CellsAndPositionsInRowNQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		# Returns the cells of one row, each paired with its [ column, row ] position.
		#
		#   _n_        the row position
		#   returns    a list of [ cell, [ column, row ] ] pairs
		#   see        RowZ
		def CellsAndPositionsInNthRow(_n_)
			return This.RowZ(_n_)

			def CellsAndPositionsInNthRowQ(_n_)
				return This.CellsAndPositionsInNthRowQRT(_n_, :stzList)

			def CellsAndPositionsInNthRowQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		# Returns the cells of one row, each paired with its [ column, row ] position.
		#
		#   _n_        the row position
		#   returns    a list of [ cell, [ column, row ] ] pairs
		#   see        RowZ
		def CellsInNthRowAndTheirPositions(_n_)
			return This.RowZ(_n_)

			def CellsInNthRowAndTheirPositionsQ(_n_)
				return This.CellsInNthRowAndTheirPositionsQRT(_n_, :stzList)

			def CellsInNthRowAndTheirPositionsQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def RowNZ(_n_)
			return This.RowZ(_n_)

			def RowNZQ(_n_)
				return This.RowNZQRT(_n_, :stzList)

			def RowNZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def NthRowZ(_n_)
			return This.RowZ(_n_)

			# Returns the cells of row n, each with its [ column, row ] position, wrapped in a stzList.
			#
			#   _n_        the row position
			#   returns    a stzList of [ cell, [ column, row ] ] pairs
			#   warning    The name misspells NthRowZQ
			#   see        RowZ
			def NtRowZQ(_n_)
				return This.NthRowZQRT(_n_, :stzList)

			def NthRowZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		#>

	  #-------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN ROW   #
	#-------------------------------------------------------#

	# Returns the [ column, row ] position of every cell of one row.
	#
	#   pnRow      the row position, :First or :Last
	#   returns    a list of [ column, row ] pairs
	#   warning    The row is not checked against the table: a row past the last one still answers
	#              positions
	#   see        ColAsPositions
	def RowAsPositions(pnRow)
		if CheckingParams()

			if isString(pnRow)
				if pnRow = :First or pnRow = :FirstRow
					pnRow = 1

				but pnRow = :Last or pnRow = :LastRow
					pnRow = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(pnRow)
				StzRaise("Incorrect param type! pnRow must be a number.")
			ok

		ok

		_nNumberOfCols_ = This.NumberOfCols()
		_aResult_ = []

		for i = 1 to _nNumberOfCols_
			_aResult_ + [ i, pnRow ]
		next

		return _aResult_

		#< @Alternativefunctions

		def CellsInRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		#==

		def CellsInThisRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInThisRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInThisRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def RowToCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#>
	  #----------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY ROWS  #
	#----------------------------------------------------#

	# Returns the [ column, row ] positions of every cell of the given rows, row by row.
	#
	#   panRows    the row positions
	#   returns    a list of [ column, row ] pairs
	#   see        RowAsPositions
	def RowsAsPositions(panRows)
		_nNumberOfCols_ = This.NumberOfCols()
		_nLenRows_ = len(panRows)

		_aResult_ = []

		for i = 1 to _nLenRows_

			for j = 1 to _nNumberOfCols_
				_aResult_ + [ j, panRows[i] ]
			next

		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		#==

		def CellsInTheseRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInTheseRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInTheseRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def RowsToCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

	# Appends several columns at the right end, in place; the cells are padded or cut like AddColumn.
	#
	#   pacColNamesAndData   the columns, each as [ name, list of cells ]
	#   returns              nothing; the table changes
	#   warning              A name that already exists raises an error after the earlier columns
	#                        were added
	#   see                  AddColumn
		#>
	def AddColumns(pacColNamesAndData)
		_nLen_ = len(pacColNamesAndData)

		for i = 1 to _nLen_
			This.AddColumn(pacColNamesAndData[i])
		next

		# Appends several columns at the right end, in place; the cells are padded or cut like AddColumn.
		#
		#   pacColNamesAndData   the columns, each as [ name, list of cells ]
		#   returns              nothing; the table changes
		#   see                  AddColumns
		def AddCols(pacColNamesAndData)
			This.AddColumns(pacColNamesAndData)

	  #===============#
	 #  ADDING ROWS  #
	#===============#

	# Appends one row at the bottom, in place.
	#
	#   paRow      the cells of the new row, one per column
	#   returns    nothing; the table changes
	#   warning    Raises an error when the number of cells differs from the number of columns
	#   see        AddRows
	def AddRow(paRow)
		/*
		_o1_ = new stzTable([
			:ID 	  = [ 10,	20,		30	],
			:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
			:SALARY	  = [ 14500,	17630,		20345	]
		])

		_o1_.AddRow([ 40, "Peter", 12500 ])
		? _o1_.Row(4) #--> [ 40, "Peter", 12500 ]

		*/

		if NOT isList(paRow)
			StzRaise("Incorrect param type! paRow must be a list.")
		ok

		_nLen_ = This.NumberOfCols()

		if NOT len(paRow) = This.NumberOfCols()
			StzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
		ok

		_aContent_ = @aContent

		for i = 1 to _nLen_
			_aContent_[i][2] + paRow[i]
		next

		This.UpdateWith(_aContent_)

	# Appends several rows at the bottom, in place.
	#
	#   paRows     the new rows, each a list with one cell per column
	#   returns    nothing; the table changes
	#   warning    Stops at the first row of the wrong size, leaving the earlier rows added
	#   see        AddRow
	def AddRows(paRows)
		if NOT isList(paRows)
			StzRaise("Incorrect param type! paRows must be a list.")
		ok

		_nLen_ = len(paRows)
		for i = 1 to _nLen_
			This.AddRow(paRows[i])
		next

	  #=======================#
	 #  EXTANDING THE TABLE  # // TODO
	#=======================#

	# Grows the table to at least the given number of columns and rows, in place; the new cells are empty text.
	#
	#   _nCol_     the number of columns to reach
	#   _nRow_     the number of rows to reach
	#   returns    nothing; the table changes
	def Extend(_nCol_, _nRow_)
		if NOT ( isNumber(_nCol_) and isNumber(_nRow_) )
			StzRaise("Incorrect param type! _nCol_ and _nRow_ must be numbers.")
		ok

		_nColsEx_ = This.NumberOfCols()
		_nRowsEx_ = This.NumberOfRows()

		# The table only grows: a size smaller than the present one changes nothing
		if _nRow_ < _nRowsEx_
			_nRow_ = _nRowsEx_
		ok

		_aContentEx_ = @aContent

		if _nRow_ > _nRowsEx_
			for i = 1 to _nColsEx_
				for j = _nRowsEx_ + 1 to _nRow_
					_aContentEx_[i][2] + ""
				next
			next
		ok

		for i = _nColsEx_ + 1 to _nCol_
			_cNameEx_ = "col" + i
			while This._ColNameTakenIn(_aContentEx_, _cNameEx_)
				_cNameEx_ += "_"
			end

			_aCellsEx_ = []
			for j = 1 to _nRow_
				_aCellsEx_ + ""
			next
			_aContentEx_ + [ _cNameEx_, _aCellsEx_ ]
		next

		This.UpdateWith(_aContentEx_)

	def _ColNameTakenIn(paContent, pcName)
		_nLenCn_ = len(paContent)
		for _iCn_ = 1 to _nLenCn_
			if StzLower(paContent[_iCn_][1]) = StzLower(pcName)
				return 1
			ok
		next
		return 0

		# Grows the table to at least the given number of columns and rows, in place; the new cells are empty text.
		#
		#   _nCol_     the number of columns to reach
		#   _nRow_     the number of rows to reach
		#   returns    nothing; the table changes
		#   see        Extend
		def ExtendTo(_nCol_, _nRow_)
			This.Extend(_nCol_, _nRow_)

	  #======================#
	 #  UPDATING THE TABLE  #
	#======================#

	# Replaces the whole content by a hash list of equally long columns, in place.
	#
	#   paNewTable   the new content as name = cells pairs, optionally behind :With, :By or :Using
	#   returns      nothing; the table changes
	#   warning      Raises an error when the columns are not [ text, list ] pairs of one size with
	#                distinct names
	#   see          UpdateWith
	def Update(paNewTable)
		if CheckingParams() = 1
			if isList(paNewTable) and StzIsWithOrByOrUsingNamedParamList(paNewTable)
				paNewTable = paNewTable[2]
			ok

			# Validate DIRECTLY on paNewTable. This used to read
			#     @IsHashList(paNewTable) and
			#     StzHashListQ(paNewTable).ValuesAreListsOfSameSize()
			# -- and each Q()/StzHashListQ() wrap COPIES every cell just to run
			# an O(cols) check, so validation cost O(rows x cols) on EVERY
			# update. Measured: 2.10s of a 2.42s calculated column on a 50k-row
			# table with two text columns (87% of the whole operation), and
			# Update is on the path of nearly every mutating table method.
			# The rules below are unchanged: a hashlist -- each item is
			# [ stringKey, value ] with UNIQUE keys -- whose values all have the
			# same size.
			_bValidUp_ = isList(paNewTable)

			if _bValidUp_
				_nColsUp_ = len(paNewTable)
				_acKeysUp_ = []
				_nSizeUp_ = -1

				for _iUp_ = 1 to _nColsUp_
					_pUp_ = paNewTable[_iUp_]

					if NOT ( isList(_pUp_) and len(_pUp_) = 2 and isString(_pUp_[1]) )
						_bValidUp_ = 0
						exit
					ok

					_nKeysUp_ = len(_acKeysUp_)
					for _jUp_ = 1 to _nKeysUp_
						if _acKeysUp_[_jUp_] = _pUp_[1]
							_bValidUp_ = 0
							exit
						ok
					next
					if NOT _bValidUp_
						exit
					ok
					_acKeysUp_ + _pUp_[1]

					if _nSizeUp_ = -1
						_nSizeUp_ = len(_pUp_[2])
					but len(_pUp_[2]) != _nSizeUp_
						_bValidUp_ = 0
						exit
					ok
				next
			ok

			if NOT _bValidUp_
				StzRaise("Incorrect param type! paNewTable must be a hashlist where values are lists of the same size.")
			ok
		ok

		@aContent = paNewTable
		This._InvalidateEngine()

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(paNewTable)
			This.Update(paNewTable)
			return This

		# Replaces the whole content by a hash list of equally long columns, in place.
		#
		#   paNewTable   the new content as name = cells pairs, optionally behind :With, :By or
		#                :Using
		#   returns      nothing; the table changes
		#   see          Update
		#>
		#< @FunctionAlternativeForms
		def UpdateWith(paNewTable)
			This.Update(paNewTable)

			def UpdateWithQ(paNewTable)
				return This.UpdateQ(paNewTable)

		# Replaces the whole content by a hash list of equally long columns, in place.
		#
		#   paNewTable   the new content as name = cells pairs, optionally behind :With, :By or
		#                :Using
		#   returns      nothing; the table changes
		#   see          Update
		def UpdateBy(paNewTable)
			This.Update(paNewTable)

			def UpdateByQ(paNewTable)
				return This.UpdateQ(paNewTable)

		# Replaces the whole content by a hash list of equally long columns, in place.
		#
		#   paNewTable   the new content as name = cells pairs, optionally behind :With, :By or
		#                :Using
		#   returns      nothing; the table changes
		#   see          Update
		def UpdateUsing(paNewTable)
			This.Update(paNewTable)

			def UpdateUsingQ(paNewTable)
				return This.UpdateQ(paNewTable)

	# Returns a copy of the table whose whole content is replaced, leaving the original untouched.
	#
	#   paNewTable   the value handed back
	#   returns      a new stzTable
	#   see          Update
		#>
	def Updated(paNewTable)
		_oUpdated_ = This.Copy()
		_oUpdated_.Update(paNewTable)
		return _oUpdated_

		#< @FunctionAlternativeForms

		def UpdatedWith(paNewTable)
			return This.Updated(paNewTable)

		def UpdatedBy(paNewTable)
			return This.Updated(paNewTable)

		def UpdatedUsing(paNewTable)
			return This.Updated(paNewTable)

		#>

	  #====================#
	 #  RENAMING COLUMNS  #
	#====================#

	# Gives a column a new name, in place; the column is given by name or position, or as :First or :Last.
	#
	#   pcNewName   the new name of the column, as text
	#   returns     nothing; the table changes
	#   see         RenameNthCol
	def RenameCol(pCol, pcNewName)

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(pCol)

			# A real column name wins over the keywords
			if This.HasColName(pCol)
				pCol = This.ColToColNumber(pCol)

			but StzFindFirst(lower(pCol), [ :first, :firstcol, :firstcolumn ]) > 0
				pCol = 1

			but StzFindFirst(lower(pCol), [ :last, :lastcol, :lastcolumn ]) > 0
				pCol = This.NumberOfCols()

			else
				StzRaise("Incorrect value! Allowed values :FirstCol, :LastCol, or use a number instead.")
			ok
		ok

		This.RenameColN(pCol, pcNewName)

		# Gives a column a new name, in place; the column is given by name or position.
		#
		#   pcNewName   the new name of the column, as text
		#   returns     nothing; the table changes
		#   see         RenameCol
		def RenanmeCol(pCol, pcNewName)
			This.RenameCol(pCol, pcNewName)

	# Renames several columns from old name = new name pairs, in place.
	#
	#   paColsAndTheirNewNames   the columns to rename, as old name = new name pairs
	#   returns                  nothing; the table changes
	#   see                      RenanmeCol
	def RenameCols(paColsAndTheirNewNames)

		if NOT (isList(paColsAndTheirNewNames) and @IsHashList(paColsAndTheirNewNames))
			StzRaise("Incorrect param type! paColsAndTheirNewNames must be a hashlist.")
		ok

		_nLen_ = len(paColsAndTheirNewNames)

		for i = 1 to _nLen_
			This.RenameCol(paColsAndTheirNewNames[i][1], paColsAndTheirNewNames[i][2])
		next

	# Gives the nth column a new name, in place; :First and :Last are accepted.
	#
	#   _n_         the position of the column
	#   pcNewName   the new name as text, or [ :With, name ]
	#   returns     nothing; the table changes
	#   see         RenameFirstCol
	def RenameNthCol(_n_, pcNewName)
		if isList(pcNewName) and Q(pcNewName).IsWithOrByNamedParam()
			pcNewName = pcNewName[2]
		ok

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(_n_)
			if lower(_n_) = "last" or lower(_n_) = "lastcol"
				_n_ = This.NumberOfCols()
			but lower(_n_) = "first" or lower(_n_) = "firstcol"
				_n_ = 1
			ok
		ok

		if NOT ( isNumber(_n_) and _n_ >= 1 and _n_ <= This.NumberOfCols() )
			StzRaise("Column index out of range.")
		ok

		@aContent[_n_][1] = pcNewName
		This._InvalidateEngine()

		# Gives the nth column a new name, in place.
		#
		#   _n_         the position of the column
		#   pcNewName   the new name as text, or [ :With, name ]
		#   returns     nothing; the table changes
		#   see         RenameNthCol
		def RenameColN(_n_, pcNewName)
			This.RenameNthCol(_n_, pcNewName)

	# Gives several columns a new name each, in place, from their positions and the names in the same order.
	#
	#   panColsNumbers   the positions of the columns to rename
	#   pacNewNames      the new names, in the same order as the positions
	#   returns          nothing; the table changes
	#   see              RenameNthCol
	def RenameNthCols(panColsNumbers, pacNewNames)
		if NOT (isList(panColsNumbers) and @IsListOfNumbers(panColsNumbers) )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		if NOT (isList(pacNewNames) and @IsListOfStrings(pacNewNames) and len(pacNewNames) = len(panColsNumbers))
			StzRaise("Incorrect param type! pacNewNames must be a list of strings, one per position.")
		ok

		_nLen_ = len(panColsNumbers)

		for i = 1 to _nLen_
			This.RenameColN(panColsNumbers[i], pacNewNames[i])
		next

		# Renames several columns by position; the older spelling of RenameNthCols.
		#
		#   panColsNumbers   the positions of the columns to rename
		#   pacNewNames      the new names, in the same order as the positions
		#   returns          nothing; the table changes
		#   see              RenameNthCols
		def RemnameNthCols(panColsNumbers, pacNewNames)
			This.RenameNthCols(panColsNumbers, pacNewNames)

	# Gives the first column a new name, in place.
	#
	#   pcNewName   the new name, as text
	#   returns     nothing; the table changes
	#   see         RenameNthCol
	def RenameFirstCol(pcNewName)
		This.RenameNthCol(1, pcNewName)

	# Gives the last column a new name, in place.
	#
	#   pcNewName   the new name, as text
	#   returns     nothing; the table changes
	#   see         RenameNthCol
	def RenameLastCol(pcNewName)
		This.RenameNthCol(This.NumberOfCols(), pcNewName)

	  #=====================#
	 #  REMOVING A COLUMN  #
	#=====================#

		# Removes the nth column, in place; removing the only column leaves one empty column.
		#
		#   _n_        the position of the column to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthCol
		def RemoveNthColumn(_n_)
			This.RemoveNthCol(_n_)

		# Removes the nth column, in place; removing the only column leaves one empty column.
		#
		#   _n_        the position of the column to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthCol
		def RemoveColumnAt(_n_)
			This.RemoveNthCol(_n_)

	# Removes the columns at the given positions, in place; a position past the last column is ignored.
	#
	#   panColNumbers   the positions of the columns to remove
	#   returns         nothing; the table changes
	#   see             RemoveCols
	def RemoveColumnsAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		_anColNumbers_ = ring_sort( U(panColNumbers) )
		_nLen_ = len(_anColNumbers_)
		_nCols_ = This.NumberOfCols()

		# From the last position down, so that a removal never shifts a position still to come;
		# a position past the last column is ignored, like an unknown name in RemoveCols.
		for i = _nLen_ to 1 step -1
			if _anColNumbers_[i] >= 1 and _anColNumbers_[i] <= _nCols_
				This.RemoveNthCol(_anColNumbers_[i])
			ok
		next



		# Removes the columns at the given positions, in place; a position past the last column is ignored.
		#
		#   panColNumbers   the positions of the columns to remove
		#   returns         nothing; the table changes
		#   see             RemoveCols
		def RemoveColsAt(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		# Removes the columns at the given positions, in place; a position past the last column is ignored.
		#
		#   panColNumbers   the positions of the columns to remove
		#   returns         nothing; the table changes
		#   see             RemoveCols
		def RemoveNthCols(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		# Removes the columns at the given positions, in place; a position past the last column is ignored.
		#
		#   panColNumbers   the positions of the columns to remove
		#   returns         nothing; the table changes
		#   see             RemoveCols
		def RemoveNthColumns(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

	# Keeps only the columns at the given positions, in place.
	#
	#   panColNumbers   the positions of the columns to keep
	#   returns         nothing; the table changes
	#   see             FindColsExcept
	def RemoveAllColsExceptAt(panColNumbers)
		This.RemoveAllColsExcept(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		#< @FunctionAlternativeForms
		def RemoveColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveAllColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveAllColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		#@ aka  --
		def RemoveColsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveAllColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		#@ aka  --
		def RemoveAllColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveAllColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		# Keeps only the columns at the given positions, in place.
		#
		#   panColNumbers   the positions of the columns to keep
		#   returns         nothing; the table changes
		#   see             RemoveAllColsExceptAt
		def RemoveColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#>

	def RemoveAllColsExcept(paCols)
		if CheckingParams()
			if NOT ( isList(paCols) and IsListOfNumbersOrStrings(paCols) )
				StzRaise("Incorrect param type! panRows must be a list of numbers or strings.")
			ok
		ok

		_anPos_ = This.FindColsExcept(paCols)
		This.RemoveCols(_anPos_)

		#< @FunctionAlternativeForms

		def RemoveColsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		# Keeps only the given columns, written as names or positions, in place.
		#
		#   panRow     the columns to keep, by name or position
		#   returns    nothing; the table changes
		#   see        FindColsExcept
		def RemoveAllColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		# Keeps only the given columns, written as names or positions, in place.
		#
		#   panRow     the columns to keep, by name or position
		#   returns    nothing; the table changes
		#   see        FindColsExcept
		def RemoveColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#--

		def RemoveAllColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		# Keeps only the given columns, written as names or positions, in place.
		#
		#   panRow     the columns to keep, by name or position
		#   returns    nothing; the table changes
		#   see        FindColsExcept
		def RemoveAllColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		# Keeps only the given columns, written as names or positions, in place.
		#
		#   panRow     the columns to keep, by name or position
		#   returns    nothing; the table changes
		#   see        FindColsExcept
		def RemoveColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#>

	  #---------------------------------------------#
	 #  REMOVING ALL THE COLUMNS AND ALL THE ROWS  #
	#=============================================#

	# Empties the table, in place, leaving one column named col1 with one empty cell.
	#
	#   returns    nothing; the table changes
	#   see        Erase
	def RemoveAll()
		This.UpdateWith([ :COL1 = [ "" ] ])

		# Empties the table, in place, leaving one column named col1 with one empty cell.
		#
		#   returns    nothing; the table changes
		#   see        RemoveAll
		def RemoveAllCols()
			This.RemoveAll()

		# Empties the table, in place, leaving one column named col1 with one empty cell.
		#
		#   returns    nothing; the table changes
		#   see        RemoveAll
		def RemoveAllColumns()
			This.RemoveAll()

	  #------------------------#
	 #  REMOVING A GIVEN ROW  #
	#========================#

	# Removes one row, given by position, in place; a row given as its cells needs FindRow, which finds nothing.
	#
	#   pRowOrRowNumber   the row to remove, as its position
	#   returns           nothing; the table changes
	#   see               RemoveNthRow
	def RemoveRow(pRowOrRowNumber)
		if CheckingParams()
			if NOT ( isNumber(pRowOrRowNumber) or isList(pRowOrRowNumber) )
				StzRaise("Incorrect param type! pRowOrRowNumber must be a number or list.")
			ok
		ok

		if isNumber(pRowOrRowNumber)
			This.RemoveNthRow(pRowOrRowNumber)

		else
			_anPos_ = This.FindRow(pRowOrRowNumber)
			if len(_anPos_) = 0
				StzRaise("Row not found!")
			ok
			This.RemoveNthRow(_anPos_[1])
		ok

	# Removes the nth row from every column, in place.
	#
	#   _n_        the position of the row to remove
	#   returns    nothing; the table changes
	#   warning    Raises a bad-range error for 0 or a position past the last row
	#   see        RemoveRows
	def RemoveNthRow(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_aContent_ = @aContent
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			ring_remove(_aContent_[i][2], _n_)
		next

		This.UpdateWith(_aContent_)


		# Removes the nth row from every column, in place.
		#
		#   _n_        the position of the row to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthRow
		def RemoveRowAt(_n_)
			This.RemoveNthRow(_n_)

		# Removes the nth row from every column, in place.
		#
		#   _n_        the position of the row to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthRow
		def RemoveRowNumber(_n_)
			This.RemoveNthRow(_n_)

		# Removes the nth row from every column, in place.
		#
		#   _n_        the position of the row to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthRow
		def RemoveRowN(_n_)
			This.RemoveNthRow(_n_)

	  #---------------------------#
	 #  REMOVING THE GIVEN ROWS  #
	#---------------------------#

	# Removes the rows at the given positions, in place; a position outside the table is ignored.
	#
	#   panRows    the positions of the rows to remove
	#   returns    nothing; the table changes
	#   see        RemoveNthRow
	def RemoveNthRows(panRows)

		if CheckingParams()
			if NOT ( isList(panRows) and @IsListOfNumbers(panRows) )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_aContent_ = @aContent
		_nLen_ = len(_aContent_)
		_nRows_ = This.NumberOfRows()
		_anPos_ = ring_sort( U(panRows) )
		_nLenPos_ = len(_anPos_)

		# From the last position down, so that a removal never shifts a position still to come;
		# a position outside the table is ignored.
		for i = _nLenPos_ to 1 step -1
			if _anPos_[i] >= 1 and _anPos_[i] <= _nRows_
				for j = 1 to _nLen_
					ring_remove(_aContent_[j][2], _anPos_[i])
				next
			ok
		next

		This.UpdateWith(_aContent_)


		# Removes the rows at the given positions, in place; a position outside the table is ignored.
		#
		#   panRows    the positions of the rows to remove
		#   returns    nothing; the table changes
		#   see        RemoveNthRow
		def RemoveRowsAt(panRows)
			This.RemoveNthRows(panRows)

	# Removes the given rows, written as positions or as lists of cells, in place.
	#
	#   pRowsOrRowsNumbers   the positions of the rows to remove, or the rows themselves
	#   returns              nothing; the table changes
	#   see                  RemoveNthRow
	def RemoveRows(pRowsOrRowsNumbers)
		if CheckingParams()
			if NOT isList(pRowsOrRowsNumbers)
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers.")
			ok

			if NOT ( @IsListOfNumbers(pRowsOrRowsNumbers) or @IsListOfLists(pRowsOrRowsNumbers) )
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(pRowsOrRowsNumbers)
			This.RemoveRowsAt(pRowsOrRowsNumbers)

		else // @IsListOfLists(pRowsOrRowsNumbers)
			_anPos_ = This.FindTheseRows(pRowsOrRowsNumbers)
			This.RemoveRowsAt(_anPos_)
		ok

	  #-----------------------------------------------#
	 #  REMOVING ALL THE ROWS EXCEPT THOSE PROVIDED  #
	#-----------------------------------------------#

	# Keeps only the rows at the given positions, in place.
	#
	#   panRows    the positions of the rows to keep
	#   returns    nothing; the table changes
	#   see        FindRowsExceptAt
	def RemoveAllRowsExceptAt(panRows)
		if CheckingParams()
			if NOT ( isList(panRows) and @IsListOfNumbers(panRows) )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_anPos_ = This.FindRowsExceptAt(panRows)
		This.RemoveRowsAt(_anPos_)

		# Keeps only the rows at the given positions, in place.
		#
		#   panRow     the positions of the rows to keep
		#   returns    nothing; the table changes
		#   see        FindRowsExceptAt
		#< @FunctionAlternativeForms
		def RemoveRowsExceptAt(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		# Keeps only the rows at the given positions, in place.
		#
		#   panRow     the positions of the rows to keep
		#   returns    nothing; the table changes
		#   see        FindRowsExceptAt
		def RemoveAllRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		# Keeps only the rows at the given positions, in place.
		#
		#   panRow     the positions of the rows to keep
		#   returns    nothing; the table changes
		#   see        FindRowsExceptAt
		def RemoveRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

	# Keeps only the given rows, written as positions or as lists of cells, in place.
	#
	#   pRowsOrRowsNumbers   the rows to keep, as positions or as lists of cells
	#   returns              nothing; the table changes
	#   see                  FindRowsExceptAt
		#>
	def RemoveAllRowsExcept(pRowsOrRowsNumbers)

		if CheckingParams()
			if NOT isList(pRowsOrRowsNumbers)
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers.")
			ok

			if NOT ( @IsListOfNumbers(pRowsOrRowsNumbers) or @IsListOfLists(pRowsOrRowsNumbers) )
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(pRowsOrRowsNumbers)
			This.RemoveAllRowsExceptAt(pRowsOrRowsNumbers)

		else // @IsListOfLists(pRowsOrRowsNumbers)

			_anPos_ = This.FindRowsExceptThese(pRowsOrRowsNumbers)
			This.RemoveRowsAt(_anPos_)
		ok


		#< @FunctionAlternativeForms

		def RemoveRowsExcept(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		# Keeps only the given rows, written as positions or as lists of cells, in place.
		#
		#   pRowsOrRowsNumbers   the rows to keep, as positions or as lists of cells
		#   returns              nothing; the table changes
		#   see                  FindRowsExceptAt
		def RemoveAllRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		# Keeps only the given rows, written as positions or as lists of cells, in place.
		#
		#   pRowsOrRowsNumbers   the rows to keep, as positions or as lists of cells
		#   returns              nothing; the table changes
		#   see                  FindRowsExceptAt
		def RemoveRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		#>

	  #=====================#
	 #  ERASING THE TABLE  #
	#=====================#

	# Sets every cell to an empty string, in place; the columns and rows stay.
	#
	#   returns    nothing; the table changes
	#   see        RemoveAll
	def Erase()
		#NOTE
		# Only data in cells is erased, columns and
		# rows remain as they are!

		_aContent_ = @aContent

		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			_nLenLine_ = len(_aContent_[i][2])
			for j = 1 to _nLenLine_
				_aContent_[i][2][j] = ""
			next
		next

		This.UpdateWith(_aContent_)


		# Sets every cell to an empty string, in place; the columns and rows stay.
		#
		#   returns    nothing; the table changes
		#   see        RemoveAll
		def EraseTable()
			This.Erase()

	  #-------------------#
	 #  ERASING COLUMNS  #
	#-------------------#

	# Sets every cell of one column to an empty string, in place.
	#
	#   pColNameOrNumber   the column to empty, by name or position
	#   returns            nothing; the table changes
	#   see                EraseColumns
	def EraseColumn(pColNameOrNumber)
		_aCellsPos_ = This.ColAsPositions(pColNameOrNumber)
		This.EraseCells(_aCellsPos_)

		# Sets every cell of one column to an empty string, in place.
		#
		#   pColNameOrNumber   the column to empty, by name or position
		#   returns            nothing; the table changes
		#   see                EraseColumns
		def EraseCol(pColNameOrNumber)
			This.EraseColumn(pColNameOrNumber)

	# Sets every cell of the given columns to an empty string, in place.
	#
	#   pcColNamesOrNumbers   the columns to empty, by name or position
	#   returns               nothing; the table changes
	#   see                   EraseColumn
	def EraseColumns(pcColNamesOrNumbers)
		_nCols_ = This.TheseColsToColsNumbers(pcColNamesOrNumbers)

		_nCols1Len_ = len(_nCols_)
		for _iLoopCols1_ = 1 to _nCols1Len_
			_n_ = _nCols_[_iLoopCols1_]
			This.EraseCol(_n_)
		next

		# Sets every cell of the given columns to an empty string, in place.
		#
		#   pcColNamesOrNumbers   the columns to empty, by name or position
		#   returns               nothing; the table changes
		#   see                   EraseColumn
		def EraseCols(pcColNamesOrNumbers)
			This.EraseColumns(pcColNamesOrNumbers)

	  #----------------#
	 #  ERASING ROWS  #
	#----------------#

	# Sets every cell of one row to an empty string, in place.
	#
	#   _n_        the position of the row to empty
	#   returns    nothing; the table changes
	#   see        EraseRows
	def EraseRow(_n_)
		_aCellsPos_ = This.RowAsPositions(_n_)
		This.EraseCells(_aCellsPos_)

	# Sets every cell of the given rows to an empty string, in place.
	#
	#   panRows    the positions of the rows to empty
	#   returns    nothing; the table changes
	#   see        EraseRow
	def EraseRows(panRows)
		if NOT ( isList(panRows) and @IsListOfNumbers(panRows) )
			StzRaise("Incorrect param type! panRows must be a list of numbers!")
		ok

		_nPanRows1Len_ = len(panRows)
		for _iLoopPanRows1_ = 1 to _nPanRows1Len_
			_n_ = panRows[_iLoopPanRows1_]
			This.EraseRow(_n_)
		next

	  #-----------------#
	 #  ERASING CELLS  #
	#-----------------#

	# Sets one cell to an empty string, in place.
	#
	#   pnRow      the row position, 1 for the first
	#   returns    nothing; the table changes
	#   see        EraseCells
	def EraseCell(pCol, pnRow)
		if isNumber(pCol)
			pCol = This.ColName(pCol)
		ok

		if NOT ( isString(pCol) and This.HasColName(pCol) )
			StzRaise("Incorrect column name!")
		ok

		_aContent_ = @aContent

		_nCol_ = This.ColToColNumber(pCol)
		_aContent_[_nCol_][2][pnRow] = ""

		This.UpdateWith(_aContent_)


		# Sets one cell to an empty string, in place.
		#
		#   pnRow      the row position, 1 for the first
		#   returns    nothing; the table changes
		#   see        EraseCells
		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

	# Sets the cells at the given [ column, row ] positions to an empty string, in place.
	#
	#   paCellsPos   the positions, each as [ column number, row number ]
	#   returns      nothing; the table changes
	#   warning      Raises an error unless every item is a pair of numbers; the column must be
	#                given by number
	#   see          EraseCell
	def EraseCells(paCellsPos)
		if NOT ( isList(paCellsPos) and @IsListOfPairsOfNumbers(paCellsPos) )
			StzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		_aContent_ = @aContent
		_nLen_ = len(paCellsPos)

		for i = 1 to _nLen_
			_nCol_ = paCellsPos[i][1]
			_nRow_ = paCellsPos[i][2]
			_aContent_[_nCol_][2][_nRow_] = ""
		next

		This.UpdateWith(_aContent_)


		# Sets the cells at the given [ column, row ] positions to an empty string, in place.
		#
		#   paCellsPos   the positions, each as [ column number, row number ]
		#   returns      nothing; the table changes
		#   warning      Raises an error unless every item is a pair of numbers; the column must be
		#                given by number
		#   see          EraseCell
		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	  #------------------------------#
	 #  ERASING A SECTION OF CELLS  #
	#------------------------------#

	# Empties every cell of the block between two [ column, row ] corners, in place.
	#
	#   paCellPos1   the first corner, [ column, row ]
	#   paCellPos2   the last corner, [ column, row ]
	#   returns      nothing; the table changes
	#   see          EraseCells
	def EraseSection(paCellPos1, paCellPos2)
		_aCellsPos_ = This.SectionAsPositions(paCellPos1, paCellPos2)
		This.EraseCells(_aCellsPos_)

	  #======================#
	 #  INSERTING A COLUMN  #
	#======================#

	# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
	#
	#   _n_         the position of the column
	#   paColData   the new column as [ name, list of cells ]
	#   returns     nothing; the table changes
	#   see         AddColumn
	def InsertCol(_n_, paColData)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				_n_ = _n_[2]
			ok

			if NOT ( isNumber(_n_) or ( isList(_n_) and @IsListOfNumbers(_n_) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT ( isList(paColData) and len(paColData) > 1 and isString(paColData[1]) )
				StzRaise("Incorrect param type! paColData must be a list with the first item beeing a string.")
			ok
		ok

		if isList(_n_)
			StzRaise("Incorrect param type! A column is inserted at one position: n must be a number.")
		ok

		_cColNameIc_ = paColData[1]
		if This.IsColName(_cColNameIc_)
			StzRaise("Can't insert the column! The name you provided already exists.")
		ok

		if _n_ < 1 or _n_ > This.NumberOfCols() + 1
			StzRaise("Incorrect param value! n must be between 1 and the number of columns plus one.")
		ok

		# Preparing the column name and data

		_cColName_ = paColData[1]
		paColData = paColData[2]

		_nLenColData_ = len(paColData)
		_nRows_ = This.NumberOfRows()
		_nMin_ = @Min([ _nLenColData_, _nRows_ ])

		_aColData_ = []

		for i = 1 to _nMin_
			_aColData_ + paColData[i]
		next

		if _nLenColData_ < _nRows_
			for i = _nLenColData_ + 1 to _nRows_
				_aColData_ + ""
			next
		ok

		# Inserting the column, so that it becomes column n

		ring_insert(@aContent, _n_, [ _cColName_, _aColData_ ])
		This._InvalidateEngine()


		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#< @FunctionAlternativeForms
		def InsertColBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#@ aka  --
		def insertColAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#@ aka  ==
		def InsertColumn(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColumnBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColumnBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#@ aka  --
		def insertColumnAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		# Inserts a new column so that it becomes column n, in place; its cells are padded or cut to the number of rows.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColumnAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

	# Inserts a new column just after column n, in place, so that it becomes column n+1.
	#
	#   _n_         the position of the column
	#   paRowData   the new column as [ name, list of cells ]
	#   returns     nothing; the table changes
	#   see         AddColumn
		#>
	def InsertColAfter(_n_, paRowData)
		This.InsertColAt(_n_+1, paRowData)

		# Inserts a new column just after column n, in place, so that it becomes column n+1.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#< @FunctionAlternativeForm
		def InsertColAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		# Inserts a new column just after column n, in place, so that it becomes column n+1.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		#@ aka  --
		def InsertColumnAfter(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		# Inserts a new column just after column n, in place, so that it becomes column n+1.
		#
		#   _n_         the position of the column
		#   paRowData   the new column as [ name, list of cells ]
		#   returns     nothing; the table changes
		#   see         AddColumn
		def InsertColumnAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		#>

	  #===================#
	 #  INSERTING A ROW  #
	#===================#

	# Inserts a row so that it becomes row n, in place; a short row is padded with empty strings.
	#
	#   _n_         the position the new row takes, 1 for the top, up to the number of rows plus one
	#   paRowData   the cells of the new row, one per column
	#   returns     nothing; the table changes
	#   warning     Raises R2 past the number of rows plus one, and an error for 0; extra cells are
	#               ignored; n can also be [ :At, n ]
	#   see         AddRow
	def InsertRow(_n_, paRowData)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				_n_ = _n_[2]
			ok

			if NOT ( isNumber(_n_) or ( isList(_n_) and @IsListOfNumbers(_n_) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT isList(paRowData)
				StzRaise("Incorrect param type! paRowData must be a list.")
			ok
		ok

		if isList(_n_)
			This.InsertRowAtPositions(_n_, paRowData)
			return
		ok

		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()
		_nRowData_ = len(parowData)
		_nMin_ = @Min([_nRowData_ , _nCols_ ])

		# Filling the missing cells by ""

		if _nRowData_ < _nCols_
			for i = _nRowData_+1 to _nCols_
				paRowData + ""
			next
		ok

		# Doing the job

		_aContent_ = @aContent

		for i = 1 to _nCols_
			ring_insert(_aContent_[i][2], _n_, paRowData[i])
		next

		This.UpdateWith(_aContent_)



		# Inserts a row so that it becomes row n, in place; a short row is padded with empty strings.
		#
		#   _n_         the position the new row takes, 1 for the top, up to the number of rows plus
		#               one
		#   paRowData   the cells of the new row, one per column
		#   returns     nothing; the table changes
		#   see         InsertRow
		#< @FunctionAlternativeForms
		def InsertRowBefore(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		# Inserts a row so that it becomes row n, in place; a short row is padded with empty strings.
		#
		#   _n_         the position the new row takes, 1 for the top, up to the number of rows plus
		#               one
		#   paRowData   the cells of the new row, one per column
		#   returns     nothing; the table changes
		#   see         InsertRow
		def InsertRowBeforePosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		# Inserts a row so that it becomes row n, in place; a short row is padded with empty strings.
		#
		#   _n_         the position the new row takes, 1 for the top, up to the number of rows plus
		#               one
		#   paRowData   the cells of the new row, one per column
		#   returns     nothing; the table changes
		#   see         InsertRow
		#@ aka  --
		def insertRowAt(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		# Inserts a row so that it becomes row n, in place; a short row is padded with empty strings.
		#
		#   _n_         the position the new row takes, 1 for the top, up to the number of rows plus
		#               one
		#   paRowData   the cells of the new row, one per column
		#   returns     nothing; the table changes
		#   see         InsertRow
		def InsertRowAtPosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

	# Inserts a row just after row n, in place, so that it becomes row n+1.
	#
	#   _n_         the position of the row to insert after
	#   paRowData   the cells of the new row, one per column
	#   returns     nothing; the table changes
	#   see         InsertRow
		#>
	def InsertRowAfter(_n_, paRowData)
		This.InsertRowAt(_n_+1, paRowData)

		# Inserts a row just after row n, in place, so that it becomes row n+1.
		#
		#   _n_         the position of the row to insert after
		#   paRowData   the cells of the new row, one per column
		#   returns     nothing; the table changes
		#   see         InsertRow
		#< @FunctionAlternativeForm
		def InsertRowAfterPosition(_n_, paRowData)
			This.InsertRowAfter(_n_, paRowData)

		#>

	  #-------------------------------------#
	 #  INSERTING A ROW IN MANY POSITIONS  #
	#-------------------------------------#

	# Inserts the same row at each of the given positions, in place.
	#
	#   panPos     the positions where the row is inserted
	#   paRow      the cells of the new row, one per column
	#   returns    nothing; the table changes
	#   see        InsertRow
	def InsertRowAtPositions(panPos, paRow)
		if CheckingParams()
			if NOT ( isList(panPos) and @isListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_anPos_ = ring_sort( U(panPos) )
		_nLen_ = len(_anPos_)

		# From the last position down, so that each position means a place in the table as it was given
		for i = _nLen_ to 1 step -1
			This.InsertRowAtPosition(_anPos_[i], paRow)
		next

		# Inserts the same row at each of the given positions, in place.
		#
		#   panPos     the positions where the row is inserted
		#   paRow      the cells of the new row, one per column
		#   returns    nothing; the table changes
		#   see        InsertRow
		def InsertRows(panPos, paRow)
			This.InsertRowAtPositions(panPos, paRow)

		# Inserts the same row at each of the given positions, in place.
		#
		#   panPos     the positions where the row is inserted
		#   paRow      the cells of the new row, one per column
		#   returns    nothing; the table changes
		#   see        InsertRow
		def InsertRowsAt(panPos, paRow)
			This.InsertRowAtPositions(panPos, paRow)

	# Returns the cells of every column, one list per column, in column order.
	#
	#   returns    a list of lists of cells
	#   see        Rows, TheseColumns
	def Cols()
		return This.TheseCols( 1 : This.NumberOfCols() )

		#< @FunctionFluentForm

		def ColsQ()
			return new stzList( This.Cols() )

		#>

		#< @FunctionAlternativeForms

			def ColumnsQ()
				return This.ColsQ()

		def AllCols()
			return This.Cols()

			def AllColsQ()
				return This.ColsQ()

		def AllColumns()
			return This.Cols()

			def AllColumnsQ()
				return This.ColsQ()

		#--

		def ColsData()
			return This.Cols()

			def ColsDataQ()
				return This.ColsQ()

		def ColumnsData()
			return This.Cols()

			def ColumnsDataQ()
				return This.ColsQ()

		def AllColsData()
			return This.Cols()

			def AllColsDataQ()
				return This.ColsQ()

		def AllColumnsData()
			return This.Cols()

			def AllColumnsDataQ()
				return This.ColsQ()

		#>

	  #--------------------------------------------------------------------#
	 #  GETTING THE LIST OF COLUMNS AS DEFINED BY THEIR NAMES OR NUMBERS  #
	#--------------------------------------------------------------------#

	# Returns the cells of the given columns, in the order given, one list per column.
	#
	#   pacColNamesOrNumbers   the columns to read, all names or all positions
	#   returns                a list of lists of cells
	#   warning                Raises an error when names and positions are mixed, or when a column
	#                          does not exist
	#   see                    Cols, Col
	def TheseColumns(pacColNamesOrNumbers)
		if NOT 	( isList(pacColNamesOrNumbers) and
			  ( @IsListOfNumbers(pacColNamesOrNumbers) or
			  @IsListOfStrings(pacColNamesOrNumbers) ) )

			StzRaise("Incorrect param type! pacColNamesOrNumbers must be a list of numbers or a list of strings.")
		ok

		_nLen_ = len(pacColNamesOrNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.Column(pacColNamesOrNumbers[i])
		next

		return _aResult_

		#< @FunctionFluentForm

		def TheseColumnsQ(pacColNamesOrNumbers)
			return TheseColumnsQRT(pacColNamesOrNumbers, :stzList)

		def TheseColumnsQRT(pacColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzHashList
				return new stzHashList( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumns(pacColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def TheseCols(pacColNamesOrNumbers)
			return This.TheseColumns(pacColNamesOrNumbers)

			def TheseColsQ(pacColNamesOrNumbers)
				return This.TheseColsQRT(pacColNamesOrNumbers, :stzList)

			def TheseColsQRT(pacColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsQRT(pacColNamesOrNumbers, pcReturnType)

		#>

	  #-----------------------------------------------------------------#
	 #  GETTING THE LIST OF COLUMNS (AS COLUMN NAMES AND THEIR CELLS)  #
	#-----------------------------------------------------------------#

	def ColsXT()
		return This.TheseColsXT( 1 : This.NumberOfCols() )

		def ColsXTQ()
			return new stzList( This.ColsXT() )

	  #-----------------------------------------------------#
	 #  GETTING THE LIST COLUMNS DEFINED BY THEIR NUMBERS  #
	#-----------------------------------------------------#

	def ColumnsAtPositions(panColNumbers)
		return This.TheseColumns(panColNumbers)

		#< @FunctionFluentForms

		def ColumnsAtPositionsQ(panColNumbers)
			return This.ColumnsAtPositionsQRT(panColNumbers, :stzList)

		def ColumnsAtPositionsQRT(panColNumbers, pcReturnType)
			return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		#>

		#< @FunctionAlternativeForms

		def ColumnsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColumnsAtQ(panColNumbers)
				return This.ColumnsAtQRT(panColNumbers, :stzList)

			def ColumnsAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		def ColsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColsAtQ(panColNumbers)
				return This.ColumnsAtQRT(panColNumbers, :stzList)

			def ColsAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		def ColAtPositions(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtPositionsQ(panColNumbers)
				return This.ColAtPositionsQRT(panColNumbers, :stzList)

			def ColAtPositionsQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQRT(panColNumbers, pcReturnType)

		def ColAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtQ(panColNumbers)
				return This.ColAtQRT(panColNumbers, :stzList)

			def ColAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQRT(panColNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------#
	 #  GETTING THE LIST OF PROVIDED COLUMNS (THEIR NAMES AND THEIR CELLS)  #
	#----------------------------------------------------------------------#

	def TheseColumnsXT(paColNamesOrNumbers)

		if NOT ( isList(paColNamesOrNumbers) and
			 Q(paColNamesOrNumbers).IsListOfStringsOrNumbers() )

			StzRaise("Incorrect param type! paColNamesOrNumbers must be a list of strings or numbers.")
		ok

		_nLen_ = len(paColNamesOrNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			p = paColNamesOrNumbers[i]
			_aResult_ + [ This.ColName(p), This.ColData(p) ]
		next

		return _aResult_

		#< @FunctionFluentForm

		def TheseColumnsXTQ(paColNamesOrNumbers)
			return This.TheseColumnsXTQRT(paColNamesOrNumbers, :stzList)

		def TheseColumnsXTQRT(paColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumnsXT(paColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumnsXT(paColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumnsXT(paColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def TheseColsXT(paColNamesOrNumbers)
			return This.TheseColumnsXT(paColNamesOrNumbers)

			def TheseColsXTQ(paColNamesOrNumbers)
				return This.TheseColsXTQRT(paColNamesOrNumbers, :stzList)

			def TheseColsXTQRT(paColNamesOrNumbers, pcReturnType)
				return This.TheseColsXT(paColNamesOrNumbers, pcReturnType)

		def TheseColXT(paColNamesOrNumbers)
			return This.TheseColumnsXT(paColNamesOrNumbers)

			def TheseColXTQ(paColNamesOrNumbers)
				return This.TheseColXTQRT(paColNamesOrNumbers, :stzList)

			def TheseColXTQRT(paColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsXT(paColNamesOrNumbers, pcReturnType)

		#>

	  #-------------------------------------------------------------------------#
	 #  GETTING THE NAMES OF THE PROVIDED COLUMNS AS DEFINED BY THEIR NUMBERS  #
	#-------------------------------------------------------------------------#

	# Returns the names of the columns at the given positions, in ascending order of position.
	#
	#   panColNumbers   the positions of the columns
	#   returns         a list of column names
	#   see             ColNumbersToNames
	def TheseColNames(panColNumbers)
		if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
			StzRaise("Incorrect param type! pacColNumbers muts be a list of numbers.")
		ok

		_nCols_ = This.NumberOfCols()

		_bAllValid_ = 1
		_nPanColNumbersLen_ = len(panColNumbers)
		for _i = 1 to _nPanColNumbersLen_
			if panColNumbers[_i] < 1 or panColNumbers[_i] > _nCols_
				_bAllValid_ = 0
				exit
			ok
		next
		if NOT _bAllValid_
			StzRaise("Incorrect param type! numbers in panColNumbers must all be between 1 and " + _nCols_ + ".")
		ok

		panColNumbers  = ring_sort(panColNumbers)
		_nLenColNumbers_ = len(panColNumbers)

		pacColNames    = This.ColNames()

		_nNumCols_       = len(pacColNames)

		if len(panColNumbers) > _nNumCols_
			panColNumbers = Q(panColNumbers).Section( 1, _nNumCols_)
		ok

		_aResult_ = []

		for i = 1 to _nLenColNumbers_
			_aResult_ + pacColNames[panColNumbers[i]]
		next

		return _aResult_

		def TheseColumsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

		def TheseColsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

	  #------------------------------------------------------------------#
	 #  GETTING THE NAMES OF COLUMNS AS DEFINED BY THEIR GIVEN NUMBERS  #
	#------------------------------------------------------------------#

	# Returns the names of the columns at the given positions, in the order given.
	#
	#   panColNumbers   the positions of the columns
	#   returns         a list of column names
	#   warning         Raises R2 for a position outside the table
	#   see             ColumnsNames
	def ColNumbersToNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsLIstOfNumbers() )
			StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
		ok

		_nLen_ = len(panColNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.NthColName(panColNumbers[i])
		next

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETTING THE NUMBERS OF COLUMNS AS DEFINED BY THEIR GIVEN NAMES  #
	#------------------------------------------------------------------#

	# Returns the position of each given column name, in the order given; 0 for an unknown name.
	#
	#   pacColNames   the column names to look up
	#   returns       a list of numbers
	#   see           FindColsByName
	def ColNamesToNumbers(pacColNames)
		if NOT ( isList(pacColNames) and @IsListOfStrings(pacColNames) )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		_nLen_ = len(pacColNames)
		_anResult_ = []

		for i = 1 to _nLen_
			_n_ = This.FindColByName(pacColNames[i])
			_anResult_ + _n_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def cColNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		def ColsNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		def ColumnNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		def ColumnsNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		#>

	  #=============================================================#
	 #  RETURNING THE SUBTABLE DEFINED BY THE GIVEN COLUMNS NAMES  #
	#=============================================================#

	# Returns the named columns as [ name, cells ] pairs, in the order given, with lowercase names.
	#
	#   pacColNames   the column names to keep
	#   returns       a list of [ name, cells ] pairs
	#   warning       Answers nothing (an empty string) when one of the names is not a column
	#   see           TheseColumns
	def SubTable(pacColNames)
		if NOT ( isList(pacColNames) and @IsListOfStrings(pacColNames) )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok

		pacColNames = Q(pacColNames).Lowercased()

		if This.HasColNames(pacColNames)
			_aResult_ = []
			_nPacColNames1Len_ = len(pacColNames)
			for _iLoopPacColNames1_ = 1 to _nPacColNames1Len_
				_cColName_ = pacColNames[_iLoopPacColNames1_]
				_aResult_ + [ _cColName_, This.Col(_cColName_) ]
			next

			return _aResult_
		ok

		def SubTableQ(pacColNames)
			return This.SubTableQRT(pacColNames, :stzList)

		def SubTableQRT(pacColNames, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SubTable(pacColNames) )

			on :stzHashList
				return new stzHashList( This.SubTable(pacColNames) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SubTable(pacColNames) )

			on :stzListOfLists
				return new stzListOfLists( This.SubTable(pacColNames) )

			on :stzTable
				return new stzTable( This.SubTable(pacColNames) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-----------------------------------------------------------------------#
	 #  RETURNING A SUBSET OF THE TABLE DEFININED BY THE GIVEN ROWS NUMBERS  #
	#-----------------------------------------------------------------------#

	def SubSet(panRowsNumbers)
		return This.TheseRows(panRowsNumbers)

		def SubSetQ(panRowsNumbers)
			return This.SubSetQRT(panRowsNumbers, :stzList)

		def SubSetQRT(panRowsNumbers, pcReturnType)
			return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

	  #========================================================#
	 #  GETTING THE LIST OF ROWS AS DEFINED BY THEIR NUMBERS  #
	#========================================================#

	# Returns the rows at the given positions, in the order given, each as a list of cells.
	#
	#   panRowsNumbers   the row positions to read
	#   returns          a list of rows
	#   warning          Raises R2 for a position past the last row
	#   see              Rows, Row
	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and @IsListOfNumbers(panRowsNumbers) )

			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		_aResult_ = []
		_nLen_ = len(panRowsNumbers)

		for i = 1 to _nLen_
			_aResult_ + This.Row(panRowsNumbers[i])
		next

		return _aResult_

		#< @FunctionFluentForm

		def TheseRowsQ(panRowsNumbers)
			return TheseRowsQRT(panRowsNumbers, :stzList)

		def TheseRowsQRT(panRowsNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Theserows(panRowsNumbers) )

			on :stzHashList
				return new stzHashList( This.TheseRows(panRowsNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseRows(panRowsNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseRows(panRowsNumbers) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def RowsAtPositions(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtPositionsQ(panRowsNumbers)
				return This.RowsAtPositionsQRT(panRowsNumbers, :stzList)

			def RowsAtPositionsQRT(panRowsNumbers, pcReturnType)
				return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

		def RowsAt(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtQ(panRowsNumbers)
				return This.RowsAtPositionsQRT(panRowsNumbers, :stzList)

			def RowsAtQRT(panRowsNumbers, pcReturnType)
				return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------------#
	 #  GETTING THE CELLS CONTAINED IN THE GIVEN ROWS ALONG WITH THEIR POSITIONS  #
	#----------------------------------------------------------------------------#

	def TheseRowsZ(panRowsNumbers)
		if NOT (isList(panRowsNumbers) and @IsListOfNumbers(panRowsNumbers))
			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		_nLen_ = len(apnRowsNumbers)

		_aResult_ = []
		_nLen1Len_ = len(_nLen_)
		for _iLoopLen1_ = 1 to _nLen1Len_
			_n_ = _nLen_[_iLoopLen1_]
			_aResult_ + This.RowZ(panRowsNumbers[i])
		next

		return _aResult_

		def TheseRowsZQ(panRowsNumbers)
			return This.TheseRowsZQRT(panRowsNumbers, :stzList)

		def TheseRowsZQRT(panRowsNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseRowsZ(panRowsNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseRowsZ(panRowsNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseRowsZ(panRowsNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

	  #==============================================#
	 #   MOVING A ROW FROM A POSITION TO AN OTHER   #
	#==============================================#

	# Exchanges the rows at the two positions, in place; the rows between them do not shift.
	#
	#   pnFrom     the position of the first row, :First or :Last
	#   pnTo       the position of the second row, :First or :Last
	#   returns    nothing; the table changes
	#   warning    Despite its name it swaps two rows rather than moving one: moving row 1 to 4
	#              leaves row 4 in first place
	#   see        SwapRows
	def MoveRow(pnFrom, pnTo)

		# Checking the params correctness

		if isList(pnFrom) and
			( Q(pnFrom).IsFromNamedParam()  or
			  Q(pnFrom).IsFromPositionNamedParam() or
			  Q(pnFrom).IsAtPositionNamedParam() )

			pnFrom = pnFrom[2]
		ok

		if isList(pnTo) and
			( Q(pnTo).IsToNamedParam()  or
			  Q(pnTo).IsToPositionNamedParam() )

			pnTo = pnTo[2]
		ok

		if isString(pnFrom)
			if pnFrom = :First or
			   pnFrom = :FirstRow or
			   pnFrom = :FirstPosition

				pnFrom = 1

			but pnFrom = :Last or
			    pnFrom = :LastRow or
			    pnFrom = :LastPosition

				pnFrom = This.NumberOfRows()
			ok
		ok

		if isString(pnTo)
			if pnTo = :Last or pnTo = :LastRow
				pnTo = This.NumberOfRows()

			but pnTo = :First or pnTo = :FirstRow
				pnTo = 1
			ok
		ok

		if NOT Q([pnFrom, pnTo]).BothAreNumbers()
			StzRaise("Incorrect param types! Both pnFrom and pnTo must be numbers.")
		ok

		# Doing the job

		_aRowCopy_ = This.Row(pnTo)
		This.ReplaceRow(pnTo, This.Row(pnFrom))
		This.ReplaceRow(pnFrom, _aRowCopy_)

	  #-----------------------#
	 #   SWAPPING TWO ROWS   #
	#-----------------------#

	# Exchanges the rows at the two positions, in place.
	#
	#   pnRow1     the position of the first row
	#   pnRow2     the position of the second row
	#   returns    nothing; the table changes
	#   warning    Raises R2 for a position past the last row
	#   see        MoveRow
	def SwapRows(pnRow1, pnRow2)

		if isList(pnRow1) and
			( Q(pnRow1).IsAndNamedParam() or
			  Q(pnRow1).IsAndPositionNamedParam() or
			  Q(pnRow1).IsAndRowNamedParam() or
			  Q(pnRow1).IsAndRowAtNamedParam() or
			  Q(pnRow1).IsAndRowAtPositionNamedParam() or
			  Q(pnRow1).IsBetweenNamedParam() or
			  Q(pnRow1).IsBetweenRowNamedParam() or
			  Q(pnRow1).IsBetweenRowAtNamedParam() or
			  Q(pnRow1).IsBetweenRowAtPositionNamedParam() or
			  Q(pnRow1).IsBetweenPositionNamedParam() or
			  Q(pnRow1).IsBetweenPositionsNamedParam()
			)

			pnRow1 = pnRow1[2]
		ok

		if isList(pnRow2) and
			( Q(pnRow2).IsAndNamedParam() or
			  Q(pnRow2).IsAndRowNamedParam() or
			  Q(pnRow2).IsAndRowAtNamedParam() or
			  Q(pnRow2).IsAndRowAtPositionNamedParam()
			)

			pnRow2 = pnRow2[2]
		ok

		if AreBothNumbers(pnRow1, pnRow2)
			_aCopyOfRow1_ = This.Row(pnRow1)
			This.ReplaceRow(pnRow1, This.Row(pnRow2))
			This.ReplaceRow(pnRow2, _aCopyOfRow1_)
		ok

	  #-------------------------------------------------#
	 #   MOVING A COLUMN FROM A POSITION TO AN OTHER   #
	#-------------------------------------------------#

	# Exchanges the columns at the two positions, in place; the columns between them do not shift.
	#
	#   pnFrom     the position of the first column
	#   pnTo       the position of the second column
	#   returns    nothing; the table changes
	#   warning    Despite its name it swaps two columns rather than moving one; a column given by
	#              name raises R24 because the body misspells pnFrom
	#   see        SwapCol
	def MoveCol(pnFrom, pnTo)

		# Checking the params correctness

		if isList(pnFrom) and
			 ( Q(pnFrom).IsFromNamedParam()  or
			   Q(pnFrom).IsFromPositionNamedParam() )

			pnFrom = pnFrom[2]
		ok

		if isList(pnTo) and
			( Q(pnTo).IsToNamedParam()  or
			  Q(pnTo).IsToPositionNamedParam() )

			pnTo = pnTo[2]
		ok

		if isString(pnFrom)

			if StzFindFirst(pnForm, [
				:First, :FirstCol, :FirstColumn, :FirstPosition ]) > 0

				pnFrom = 1

			but StzFindFirst(pnFrom, [
				:Last, :LastCol, :LastColumn, :LastPosition ]) > 0

				pnFrom = This.NumberOfCols()
			ok
		ok

		if isString(pnTo)

			if StzFindFirst(pnTo, [
				:First, :FirstCol, :FirstColumn, :FirstPosition ]) > 0

				pnTo = 1

			but StzFindFirst(pnTo, [
				:Last, :LastCol, :LastColumn, :LastPosition ]) > 0

				pnTo = This.NumberOfCols()
			ok
		ok

		if isString(pnFrom) and NOT This.HasColName(pnFrom)
			StzRaise("Incorrect column name!")
		ok

		if isString(pnTo) and NOT This.HasColName(pnTo)
			StzRaise("Incorrect column name!")
		ok

		pnFrom = This.ColToNumber(pnFrom)
		pnTo = This.ColToNumber(pnTo)

		# Doing the job

		_aContent_ = @aContent

		if pnFrom != pnTo
			_aCopy_ = @aContent[pnTo]
			_aContent_[pnTo] = @aContent[pnFrom]
			_aContent_[pnFrom] = _aCopy_
		ok

		This.UpdateWith(_aContent_)


		# Exchanges the columns at the two positions, in place; the columns between them do not shift.
		#
		#   pnFrom     the position of the first column
		#   pnTo       the position of the second column
		#   returns    nothing; the table changes
		#   warning    Swaps two columns rather than moving one
		#   see        MoveCol
		#< @FunctionAlternativeForm
		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

	# Exchanges the names of two columns, in place; the cells stay where they are.
	#
	#   pCol1      the position of the first column
	#   pCol2      the position of the second column
	#   returns    nothing; the table changes
	#   warning    Works with positions only; column names raise R41
	#   see        SwapCol
	def SwapcColNames(pCol1, pCol2)

		_bCol1IsValid_ = ( isNumber(pCol1) and
				 pCol1 >= 1 and pCol1 <= This.NumberOfCol() )

		_bCol2IsValid_ = ( isString(pCol2) and This.HasColName(pCol2) )

		if NOT ( _bCol1IsValid_ or _bCol2IsValid_ )
			StzRaise("Incorrect params! pCol1 and pCol2 must be valid columns names or strings.")
		ok

		_cName1_ = This.ColName(pCol1)
		_cName2_ = This.ColName(pCol2)

		_nCol1_ = This.ColNumber(pCol1)
		_nCol2_ = This.ColNumber(pCol2)

		_aContent_ = @aContent
		_aContent_[_nCol1_][1] = _cName2_
		_aContent_[_nCol2_][1] = _cName1_

		This.UpdateWith(_aContent_)


		# Exchanges the names of two columns, in place; the cells stay where they are.
		#
		#   pcCol1     the position of the first column
		#   pcCol2     the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41
		#   see        SwapCol
		#< @FunctionAlternativeForm
		def SwapColumnNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

		# Exchanges the names of two columns, in place; the cells stay where they are.
		#
		#   pcCol1     the position of the first column
		#   pcCol2     the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41
		#   see        SwapCol
		def SwapColumnsNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

	# Exchanges two columns, names and cells, in place.
	#
	#   pCol1      the position of the first column
	#   pCol2      the position of the second column
	#   returns    nothing; the table changes
	#   warning    Works with positions only; column names raise R41, and a name mixed with a
	#              position raises an error
	#   see        MoveCol
		#>
	def SwapCol(pCol1, pCol2)
		if isList(pCol1) and
			( Q(pCol1).IsAndNamedParam() or
			  Q(pCol1).IsAndPositionNamedParam() or

			  Q(pCol1).IsAndcColNamedParam() or
			  Q(pCol1).IsAndColumnNamedParam() or

			  Q(pCol1).IsAndColAtNamedParam() or
			  Q(pCol1).IsAndColumnAtNamedParam() or

			  Q(pCol1).IsAndColAtPositionNamedParam() or
			  Q(pCol1).IsAndColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenNamedParam() or

			  Q(pCol1).IsBetweencColNamedParam() or
			  Q(pCol1).IsBetweenColumnNamedParam() or

			  Q(pCol1).IsBetweenColAtNamedParam() or
			  Q(pCol1).IsBetweenColumnAtNamedParam() or

			  Q(pCol1).IsBetweenColAtPositionNamedParam() or
			  Q(pCol1).IsBetweenColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenPositionNamedParam() or
			  Q(pCol1).IsBetweenPositionsNamedParam()
			)
			  #NOTE: I don't use IsOneOfTheseNamedParams() here
			  # to gain some performance by discarding eval()

			pCol1 = pCol1[2]
		ok

		if isList(pCol2) and
			( Q(pCol2).IsAndNamedParam() or
			  Q(pCol2).IsAndcColNamedParam() or
			  Q(pCol2).IsAndColumnNamedParam() or
			  Q(pCol2).IsAndColAtNamedParam() or
			  Q(pCol2).IsAndColumnAtNamedParam() or
			  Q(pCol2).IsAndColAtPositionNamedParam() or
			  Q(pCol2).IsAndColumnAtPositionNamedParam() or
			  Q(pCol2).IsAndcColNamedNamedParam() or
			  Q(pCol2).IsAndColumnNamedNamedParam()
			)

			pCol2 = pCol2[2]
		ok

		if This.ColNumber(pCol1) != This.ColNumber(pCol2)
			_aCopyOfCol1_ = This.Col(pCol1)
			This.ReplaceCol(pCol1, This.Col(pCol2) )
			This.ReplaceCol(pCol2, _aCopyOfCol1_)

			This.SwapcColNames(pCol1, pCol2)
		ok

		# Exchanges two columns, names and cells, in place.
		#
		#   pCol1      the position of the first column
		#   pCol2      the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41, and a name mixed with a
		#              position raises an error
		#   see        MoveCol
		def SwapColums(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		# Exchanges two columns, names and cells, in place.
		#
		#   pCol1      the position of the first column
		#   pCol2      the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41, and a name mixed with a
		#              position raises an error
		#   see        MoveCol
		#< @FunctionAlternativeForm
		def SwapColum(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		# Exchanges two columns, names and cells, in place.
		#
		#   pcCol1     the position of the first column
		#   pcCol2     the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41, and a name mixed with a
		#              position raises an error
		#   see        MoveCol
		def SwapCols(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		# Exchanges two columns, names and cells, in place.
		#
		#   pcCol1     the position of the first column
		#   pcCol2     the position of the second column
		#   returns    nothing; the table changes
		#   warning    Works with positions only; column names raise R41, and a name mixed with a
		#              position raises an error
		#   see        MoveCol
		def SwapColumns(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		#>

	  #=============================#
	 #   REPLACING A COLUMN NAME   #
	#=============================#

	# Gives a column a new name, in place; a name already used by another column raises an error.
	#
	#   _n_            the position of the column
	#   pcNewColName   the new name, as text, or [ :With, name ]
	#   returns        nothing; the table changes
	#   see            RenameNthCol
	def ReplaceNthColName(_n_, pcNewColName)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.ReplaceColName(_n_, pcNewColName)

	# Gives a column a new name, in place; a name already used by another column raises an error.
	#
	#   pcNewColName   the new name, as text, or [ :With, name ]
	#   returns        nothing; the table changes
	#   see            RenameNthCol
	def ReplaceColName(pCol, pcNewColName)
		if isList(pcNewColName) and Q(pcNewColName).IsWithOrByNamedParam()
			pcNewColName = pcNewColName[2]
		ok

		if NOT isString(pcNewColName)
			StzRaise("Incorrect param type! pcNewColName must be a string.")
		ok

		_nSame_ = This.FindColByName(pcNewColName)
		if _nSame_ != 0 and _nSame_ != This.FindCol(pCol)
			StzRaise("Can't replace the column with this name (" + pcNewColName + ")! Name you provided already exists.")
		ok

		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok

		This.RenameNthCol(_n_, pcNewColName)


		# Gives a column a new name, in place; a name already used by another column raises an error.
		#
		#   pcNewColName   the new name, as text, or [ :With, name ]
		#   returns        nothing; the table changes
		#   see            RenameNthCol
		#< @FunctionAlternativeForm
		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

	# TRUE if every name in the list is the name of a column, ignoring case.
	#
	#   pacColNames   the column names to test
	#   returns       TRUE or FALSE
	#   warning       Raises an error when an item is not text
	#   see           HasColumnsNames
		#>
	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and @IsListOfStrings(pacColNames) )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		_nLen_ = len(pacColNames)
		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT This.IsColName(pacColNames[i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		# TRUE if every name in the list is the name of a column, ignoring case.
		#
		#   pacColNames   the column names to test
		#   returns       TRUE or FALSE
		#   warning       Raises an error when an item is not text
		#   see           HasColumnsNames
		#< @FunctionAlternativeForm
		def AreColumnNames(pacColNames)
			This.AreColNames(pacColNames)

		# TRUE if every name in the list is the name of a column, ignoring case.
		#
		#   pacColNames   the column names to test
		#   returns       TRUE or FALSE
		#   warning       Raises an error when an item is not text
		#   see           HasColumnsNames
		def AreColumnsNames(pacColNames)
			This.AreColNames(pacColNames)

	# Returns the positions of the named columns, in the order given; unknown names are skipped.
	#
	#   pacColNames   the column names to look for
	#   returns       a list of column positions
	#   see           FindCol
		#>
	def FindColsByName(pacColNames)

		if CheckingParams()

			if NOT ( isList(pacColNames) and @IsListOfStrings(pacColNames) )
				StzRaise("Incorrect param type! pacColNames must be a list of strings.")
			ok

			_nLen_ = len(pacColNames)
			for i = 1 to _nLen_
				if pacColNames[i] = :First 	 or
				   pacColNames[i] = :FirstCol	 or
				   pacColNames[i] = :FirstColumn

					pacColNames[i] = This.FirstColName()

				but pacColNames[i] = :Last 	 or
				    pacColNames[i] = :LastCol	 or
				    pacColNames[i] = :LastColumn

					pacColNames[i] = This.LastColName()
				ok
			next

		ok

		_anResult_ = Q( This.ColNames() ).FindMany(pacColNames)
		return _anResult_

		#< @FunctionAlternativeForm

		def FindColsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumnsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumnsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		#--

		def FindManyColsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumnsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumnsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		#==

		def FindCols(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumns(pacColNames)
			return This.FindColsByName(pacColNames)

		#--

		def FindManyCols(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumns(pacColNames)
			return This.FindColsByName(pacColNames)

		#>

	  #-----------------------------#
	 #  FINDING A COLUMN BY VALUE  #
	#-----------------------------#

	def FindColByValueCS(paColData, pCaseSensitive)
		if CheckingParams()
			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok
		ok

		_anResult_ = This.ToStzHashList().FindValueCS(paColData, pCaseSensitive)
		return _anResult_

		def FindColumnByValueCS(paColData, pCaseSensitive)
			return This.FindColByValueCS(paColData, pCaseSensitive)

	# Returns the positions of the columns whose cells equal the given list, case-sensitively.
	#
	#   paColData   the cells to look for, top to bottom
	#   returns     a list of column positions; [ ] when none matches
	#   see         FindColsByValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindColByValue(paColData)
		return This.FindColByValueCS(paColData, 1)

		def FindColumnByValue(paColData)
			return This.FindColByValue(paColData)

	  #----------------------------------#
	 #  FINDING MANY COLUMNS BY VALUES  #
	#----------------------------------#

	def FindColsByValueCS(paManyColData, pCaseSensitive)

		if CheckingParams()

			if NOT ( isList(paManyColData) and @IsListOfLists(paManyColData) )
				StzRaise("Incorrect param type! paManyColData must be a list of lists.")
			ok

		ok

		paManyColData = U( paManyColData ) # Duplicates are removed

		_nLen_ = len(paManyColData)
		_anResult_ = []

		for i = 1 to _nLen_
			_anPos_ = This.FindColByValueCS(paManyColData[i], pCaseSensitive)
			_nLenPos_ = len(_anPos_)
			for j = 1 to _nLenPos_
				_anResult_ + _anPos_[j]
			next
		next

		_anResult_ = ring_sort(_anResult_)
		return _anResult_

		#< @FunctionAlternativeForms

		def FindColsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindColumnsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindColumnsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		#==

		def FindMAnyColsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColumnsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColumnsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

	# Raises an error today instead of returning the positions of the columns equal to any of the given cell lists.
	#
	#   paManyColData   the cell lists to look for, each a list of cells
	#   returns         nothing; it raises
	#   warning         Raises Can't create the stzList object! for a valid list of cell lists;
	#                   FindColByValue works one list at a time
	#   see             FindColByValue
		#>
	# Returns the positions of the columns equal to any of the given cell lists.
	def FindColsByValue(paManyColData)
		return This.FindColsByValueCS(paManyColData, 1)

		#< @FunctionAlternativeForms

		def FindColsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindColumnsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindColumnsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		#==

		def FindMAnyColsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColumnsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColumnsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		#>

	  #-----------------------------------------------#
	 #  FINING COLUMNS BY NAME EXPET THOSE PROVIDED  #
	#===============================================#

	# Returns the positions of the columns that are not at the given positions.
	#
	#   panColNumbers   the positions to leave out, wrapped in a list of lists
	#   returns         a list of column positions
	#   see             FindColsExcept
	def FindColsExceptAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		_anColNumbers_ = U(panColNumbers)
		_nLen_ = len(@aContent)

		_anResult_ = []

		for i = 1 to _nLen_
			if StzFindFirst(i, _anColNumbers_) = 0
				_anResult_ + i
			ok
		next

		return _anResult_

		def FindColumnsExceptAt(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)

		def FindColsExceptPositions(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)

		def FindColumnsExceptPositions(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)


	def FindColsExcept(paColNumbersOrColNames)
		if CheckingParams()
			if NOT isList(paColNumbersOrColNames)
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list.")
			ok

			if NOT IsListOfNumbersOrStrings(paColNumbersOrColNames)
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list of numbers or names.")
			ok
		ok

		# Each item is a position or a name; FindCol answers the position either way (0 when absent).
		_anLeftOut_ = []
		_nLeft_ = len(paColNumbersOrColNames)
		for i = 1 to _nLeft_
			_anLeftOut_ + This.FindCol(paColNumbersOrColNames[i])
		next

		_anResult_ = []
		_nCols_ = This.NumberOfCols()
		for i = 1 to _nCols_
			if StzFindFirst(i, _anLeftOut_) = 0
				_anResult_ + i
			ok
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def FindAllColsExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindColsOtherThan(paCols)
			return This.FindColsExcept(paCols)

		def FindColumnsExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColumnsExcept(paCols)
			return This.FindColumnsExcept(paCols)

		def FindColumnsOtherThan(paCols)
			return This.FindColumnsExcept(paCols)

		#--

		def FindColsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindColsByNameOtherThan(paCols)
			return This.FindColsExcept(paCols)

		def FindColumnsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColumnsByNameExcept(paCols)
			return This.FindColumnsExcept(paCols)

		def FindColumnsByNameOtherThan(paCols)
			return This.FindColumnsExcept(paCols)

		#>

	  #------------------------------------------------#
	 #  FINING COLUMNS BY VALUE EXPET THOSE PROVIDED  #
	#------------------------------------------------#

	def FindColsByValueExceptCS(paCols, pCaseSensitive)

		_anResult_ = Q(1:This.NumberOfCols()) -
			   These( This.FindColsByValueCS(paCols, pCaseSensitive) )

		return _anResult_

		#< @FunctionAlternativeForms

		def FindAllColsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindColsByValueOtherThanCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindColumnsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindAllColumnsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColumnsByValueExceptCS(paCols, pCaseSensitive)

		def FindColumnsByValueOtherThanCS(paCols, pCaseSensitive)
			return This.FindColumnsByValueExceptCS(paCols, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindColsByValueExcept(paCols)
		return This.FindColsByValueExceptCS(paCols, 1)

		#< @FunctionAlternativeForms

		def FindAllColsByValueExcept(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindColsByValueOtherThan(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindColumnsByValueExcept(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindAllColumnsByValueExcept(paCols)
			return This.FindColumnsByValueExcept(paCols)

		def FindColumnsByValueOtherThan(paCols)
			return This.FindColumnsByValueExcept(paCols)

		#>

	  #==============================#
	 #  FINDING A ROW BY ITS VALUE  #
	#==============================#

	def FindNthRowCS(_n_, paRow, pCaseSensitive)
		_anPos_ = This.FindRowCS(paRow, pCaseSensitive)
		if isNumber(_n_) and _n_ >= 1 and _n_ <= len(_anPos_)
			return _anPos_[_n_]
		ok
		return 0

		def FindNthOccurrenceOfRowCS(_n_, paRow, pCaseSensitive)
			return This.FindNthRowCS(_n_, paRow, pCaseSensitive)

	# Returns the position of the nth row equal to the given cells; 0 when there is none.
	#
	#   _n_        which occurrence to return, 1 for the first
	#   paRow      the cells of the row to look for
	#   returns    a number
	#   see        FindRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthRow(_n_, paRow)
		return This.FindNthRowCS(_n_, paRow, 1)

		def FindNthOccurrenceOfRow(_n_, paRow)
			return This.FindNthRow(_n_, paRow)

	  #----------------------------------------#
	 #  FINDINING MANYS ROWS BY THEIR VALUES  #
	#----------------------------------------#

	def FindRowsCS(paRows, pCaseSensitive)
		_anResult_ = []
		if NOT isList(paRows)
			return _anResult_
		ok

		_nLenRows_ = len(paRows)
		for i = 1 to _nLenRows_
			_anPos_ = This.FindRowCS(paRows[i], pCaseSensitive)
			_nLenPos_ = len(_anPos_)
			for j = 1 to _nLenPos_
				if StzFindFirst(_anPos_[j], _anResult_) = 0
					_anResult_ + _anPos_[j]
				ok
			next
		next

		_anResult_ = ring_sort(_anResult_)
		return _anResult_

		def FindManyRowsCS(paRows, pCaseSensitive)
			return This.FindRowsCS(paRows, pCaseSensitive)

	# Returns the positions of the rows equal to any of the given rows, case-sensitively.
	#
	#   paRows     the rows to look for, each a list of cells
	#   returns    a list of row positions
	#   see        FindRowsExceptThese
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindRows(paRows)
		return This.FindRowsCS(paRows, 1)

		def FindManyRows(paRows)
			return This.FindRows(paRows)

		def FindTheseRows(paRows)
			return This.FindRows(paRows)

	  #------------------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED - AS ROWS OR POSITIONS #
	#------------------------------------------------------------------#

	def FindRowsExceptCS(paRows, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(paRows) and ( @IsListOfNumbers(paRows) or @IsListOfLists(paRows) )  )
				StzRaise("Incorrect param type! paRows must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(paRows)
			return This.FindRowsExceptAtCS(paRows, pCaseSensitive)

		else // @IsListOfLists
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)
		ok


		def FindAllRowsExceptCS(paRows, pCaseSensitive)
			return This.FindRowsExceptCS(paRows, pCaseSensitive)

		def FindRowsOtherThanCS(paRows, pCaseSensitive)
			return This.FindRowsExceptCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindRowsExcept(paRows)
		return This.FindRowsExceptCS(paRows, 1)

		def FindAllRowsExcept(paRows)
			return This.FindRowsExcept(paRows)

		def FindRowsOtherThan(paRows)
			return This.FindRowsExcept(paRows)

	  #------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (AS ROWS)  #
	#------------------------------------------------------#

	def FindRowsExceptTheseCS(paRows, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(paRows) and @IsListOfLists(paRows) )
				StzRaise("Incorrect param type! paRows must be a list of lists.")
			ok
		ok

		_anPos_ = This.FindRowsCS(paRows, pCaseSensitive)
		_nRows_ = This.NumberOfRows()

		_anResult_ = []

		for i = 1 to _nRows_
			if StzFindFirst(i, _anPos_) = 0 and StzFindFirst(i, _anResult_) = 0
				_anResult_ +i
			ok
		next

		return _anResult_

		def FindAllRowsExceptTheseCS(paRows, pCaseSensitive)
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)

		def FindRowsOtherThanTheseCS(paRows, pCaseSensitive)
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)

	# Returns the positions of the rows that equal none of the given rows.
	#
	#   paRows     the rows to leave out, each a list of cells
	#   returns    a list of row positions
	#   see        FindRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindRowsExceptThese(paRows)
		return This.FindRowsExceptTheseCS(paRows, 1)

		def FindAllRowsExceptThese(paRows)
			return This.FindRowsExceptThese(paRows)

		def FindRowsOtherThanThese(paRows)
			return This.FindRowsExceptThese(paRows)

	  #-----------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (ÙŽAS POSITIONS)  #
	#-----------------------------------------------------------#

	def FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(panRowNumbers) and @IsListOfNumbers(panRowNumbers) )
				StzRaise("Incorrect param type! panRowNumbers must be a list of numbers.")
			ok
		ok

		_nRows_ = This.NumberOfRows()

		_anResult_ = []

		for i = 1 to _nRows_
			if StzFindFirst(i, panRowNumbers) = 0 and StzFindFirst(i, _anResult_) = 0
				_anResult_ + i
			ok
		next

		return _anResult_

		def FindAllRowsExceptAtCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)

		def FindRowsOtherThanPositionsCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)

		def FindAllRowsExceptAtPositionsCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)


	# Returns the positions of the rows whose position is not in the given list.
	#
	#   panRowNumbers   the row positions to leave out
	#   returns         a list of row positions
	#   warning         Positions past the last row are ignored
	#   see             FindRowsExceptThese
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindRowsExceptAt(panRowNumbers)
		return This.FindRowsExceptAtCS(panRowNumbers, 1)

		def FindAllRowsExceptAt(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindRowsOtherThanPositions(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindAllRowsExceptAtPosiitons(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

	def FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.FindAll("Ali") // or o1.FindAll( :Cells = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? _o1_.FindAll( :SubValue = "A" )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1] ]
		     ]
		*/

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue,
				:CellValue, :OfCellValue, :Of ])


				return This.FindCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue,
				:Part, :OfPart, :CellPart, :OfCellPart,
				:SubPart, :OfSubPart ])

				return This.FindSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		else
			return This.FindCellCS(pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForms

		def FindCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindAllOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def PositionsCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)
	# Returns the positions of the cells equal to a text, case-sensitively; [ :SubValue, text ] finds the cells that contain it.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a list of [ column, row ] positions; with :SubValue, [ [ column, row
	#                          ], [ places in the cell ] ] items
	#   warning                Raises an error for a number, because the list-of-lists helper it
	#                          uses passes StzFindAll its arguments in the wrong order; text values
	#                          work
	#   see                    FindCell, FindSubValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindAll(pCellValueOrSubValue)
		return This.FindAllCS(pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def Find(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)

		def FindAllOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)		
	
		def FindOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
	
		def Occurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		
		def Positions(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		#>

	  #--------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL IN THE TABLE  #
	#--------------------------------------------------#

	def FindCellCS(pCellValue, pCaseSensitive)
		if isString(pCellValue)
			This._EnsureEngine()
			# Engine returns a ready list of [col, row] pairs (built Zig-side).
			return StzEngineTableFindCellStringCS(@pEngine, pCellValue, pCaseSensitive)
		ok

		# Numbers and lists: read the columns one after the other, as [ column, row ] positions
		_aResult_ = []
		_nColsFc_ = len(@aContent)
		for _iFc_ = 1 to _nColsFc_
			_aColFc_ = @aContent[_iFc_][2]
			_nRowsFc_ = len(_aColFc_)
			for _jFc_ = 1 to _nRowsFc_
				if This._SameCellCS(_aColFc_[_jFc_], pCellValue, pCaseSensitive)
					_aResult_ + [ _iFc_, _jFc_ ]
				ok
			next
		next
		return _aResult_

	# TRUE if the two cells are the same value; text compares without case when the flag is 0.
	def _SameCellCS(pCellA, pCellB, pCaseSensitive)
		if isString(pCellA) and isString(pCellB)
			if pCaseSensitive
				return ( pCellA = pCellB )
			ok
			return ( StzLower(pCellA) = StzLower(pCellB) )
		ok

		if isNumber(pCellA) and isNumber(pCellB)
			return ( pCellA = pCellB )
		ok

		if isList(pCellA) and isList(pCellB)
			return ( @@(pCellA) = @@(pCellB) )
		ok

		return 0

		#< @FunctionAlternativeForms
			
		def OccurrencesOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def PositionsOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		#--

		def FindValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)
			
		def OccurrencesOfValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

	# Returns the positions of the cells equal to a text, case-sensitively.
	#
	#   returns    a list of [ column, row ] positions; [ ] when none
	#   see        FindAll
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindCell(pValue)
		return This.FindCellCS(pValue, 1)

		#< @FunctionAlternativeForms

		def OccurrencesOfCell(pValue)
			return This.FindCell(pValue)

		def PositionsOfCell(pValue)
			return This.FindCell(pValue)

		#--
	
		def FindValue(pCellValue)
			return This.FindCell(pCellValue)
					
		def OccurrencesOfValue(pCellValue)
			return This.FindCell(pCellValue)
	
		#>
	
	  #-----------------------------------#
	 #  FINDING MANY CELLS IN THE TABLE  #
	#-----------------------------------#

	def FindCellsCS(paValues, pCaseSensitive)
		if CheckingParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		paValues = UCS(paValues, pCaseSensitive)
		_nLen_ = len(paValues)

		_aResult_ = []

		for i = 1 to _nLen_
			_aTemp_ = This.FindCellCS(paValues[i], pCaseSensitive)
			_nLenTemp_ = len(_aTemp_)

			for j = 1 to _nLenTemp_
				_aResult_ + _aTemp_[j]
			next
		next

		return _aResult_

		def FindValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCellsCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

	# Returns the positions of the cells equal to any of the given values, case-sensitively.
	#
	#   paValues   the values to look for
	#   returns    a list of [ column, row ] positions
	#   see        FindCell
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindCells(paValues)
		return This.FindCellsCS(paValues, 1)

		def FindValues(paValues)
			return This.FindCells(paValues)

		def FindMany(paValues)
			return This.FindCells(paValues)

		def FindManyCells(paValues)
			return This.FindCells(paValues)

		def FindManyValues(paValues)
			return This.FindCells(paValues)

	  #-------------------------------------------#
	 #  FINDING ALL CELLS EXCEPT THOSE PROVIDED  #
	#-------------------------------------------#

	def FindCellsExceptCS(paValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindCellsExcept(paValues)
		return This.FindCellsExceptCS(paValues, 1)

	  #------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN SUBVALUE IN THE TABLE  #
	#------------------------------------------------------#

	def FindSubValueCS(pSubValue, pCaseSensitive)
		_bCheckCase_ = 0
		if @IsStringOrList(pSubValue)
			_bCheckCase_ = 1
		ok

		_aCellsXT_ = This.CellsAndTheirPositions()

		_aResult_ = []
		_nCellsXTLen_3 = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_3
			_cellValue_ = _aCellsXT_[i][1]
			_oCellValue_ = Q(_cellValue_)

			_aCellPos_  = _aCellsXT_[i][2]

			_bCellIsString_ = isString(_cellValue_)
			_bCellIsListOfStrings_ = isList(_cellValue_) and _oCellValue_.IsListOfStrings()


			if _bCheckCase_
				if _bCellIsString_ = 1 or _bCellIsListOfStrings_ = 1

					if _oCellValue_.ContainsCS(pSubValue, pCaseSensitive)
						_aResult_ + [ _aCellPos_, _oCellValue_.FindAllCS(pSubValue, pCaseSensitive) ]
					ok
				ok
			else

				if isList(_cellValue_) and _oCellValue_.Contains(pSubValue)
					_aResult_ + [ _aCellPos_, _oCellValue_.FindAll(pSubValue) ]
				ok
			ok
		next

		return _aResult_

		#< @FuntionAlternativeForm

		def PositionsOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

	# Returns the cells that contain a text, each as [ [ column, row ], [ places of the text in the cell ] ].
	#
	#   returns    a list of [ [ column, row ], list of places ] items
	#   see        FindAll, FindFirstSubValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValue(pSubValue)
		return This.FindSubValueCS(pSubValue, 1)

		#< @FuntionAlternativeForm

		def PositionsOfSubValue(pSubValue)
			return This.FindSubValue(pSubValue)

		#>

	  #-------------------------------------------#
	 #  FINFING MANY SUBVALUES INSIDE THE TABLE  #
	#-------------------------------------------#

	def FindSubValuesCS(paSubValues, pCaseSensitive)
		if NOT ( isList(paSubValues) and @IsListOfStrings(paSubValues) )
			StzRaise("Incorrect param type! paSubValues must be a list of strings.")
		ok

		# One item per cell that holds at least one of the texts: [ [ column, row ], places ],
		# the places of every text being gathered, in ascending order
		_aResultSv_ = []
		_nSv_ = len(paSubValues)
		for _iSv_ = 1 to _nSv_
			_aOne_ = This.FindSubValueCS(paSubValues[_iSv_], pCaseSensitive)
			_nOne_ = len(_aOne_)
			for _jSv_ = 1 to _nOne_
				_nAt_ = 0
				_nRes_ = len(_aResultSv_)
				for _kSv_ = 1 to _nRes_
					if @@(_aResultSv_[_kSv_][1]) = @@(_aOne_[_jSv_][1])
						_nAt_ = _kSv_
						exit
					ok
				next

				if _nAt_ = 0
					_aResultSv_ + _aOne_[_jSv_]
				else
					_nPl_ = len(_aOne_[_jSv_][2])
					for _lSv_ = 1 to _nPl_
						_aResultSv_[_nAt_][2] + _aOne_[_jSv_][2][_lSv_]
					next
					_aResultSv_[_nAt_][2] = ring_sort(_aResultSv_[_nAt_][2])
				ok
			next
		next

		return _aResultSv_

	# Returns the cells that contain any of several texts, with the places of the texts inside each.
	#
	#   paSubValues   the texts to look for
	#   returns       a list of [ [ column, row ], places ] items
	#   see           FindSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValues(paSubValues)
		return This.FindSubValuesCS(paSubValues, 1)

	  #-----------------------------------------------#
	 #  FINFING ALL SUBVALUES EXCEPT THOSE PROVIDED  #
	#-----------------------------------------------#

	def FindSubValuesExceptCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindSubValuesExcept(paSubValues)
		return This.FindSubValuesExceptCS(paSubValues, 1)

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#---------------------------------------------------------------------------------------#

	def FindNthCS(_n_, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindNthValueCS(_n_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindNthSubValueCS(_n_, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok

		else
			return This.FindNthValueCS(_n_, pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(_n_, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthCS(_n_, pCellValueOrSubValue, pCaseSensitive)		

	# Returns the [ column, row ] position of the nth cell equal to a text; [ ] when there are fewer.
	#
	#   _n_                    the position, or how many, as a number
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   warning                The [ :SubValue, text ] form raises R14, because
	#                          IsOfOfTheseNamedParams is defined nowhere; a number raises like
	#                          FindCell
	#   see                    FindFirst, FindLast
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNth(_n_, pCellValueOrSubValue)
		return This.FindNthCS(_n_, pCellValueOrSubValue, 1)
	
		def FindNthOccurrence(_n_, pCellValueOrSubValue)
			return This.FindNth(_n_, pCellValueOrSubValue)	

	  #-------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------#

	def FindNthCellCS(_n_, pCellValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(_n_)

			if StzFindFirst(_n_, [ :First, :FirstOccurrence ]) > 0
				_n_ = 1

			but StzFindFirst(_n_, [ :Last, :LastOccurrence ]) > 0
				_n_ = This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_aResult_ = []

		_aFoundCells_ = This.FindCellCS(pCellValue, pCaseSensitive)

		if _n_ > 0 and _n_ <= len(_aFoundCells_)
			_aResult_ = _aFoundCells_[_n_]
		ok	

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfCellCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

		def FindNthValueCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

	# Returns the [ column, row ] position of the nth cell equal to a value; [ ] when there are fewer, and :Last stands for the last one.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ column, row ] pair, or [ ]
	#   warning    Raises an error for a number, because the list-of-lists helper it uses passes
	#              StzFindAll its arguments in the wrong order; text values work
	#   see        FindNth
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthCell(_n_, pValue)
		return This.FindNthCellCS(_n_, pValue, 1)

		#< @FunctionAlternativeForms
	
		def FindNthOccurrenceOfCell(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		def FindNthValue(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		def FindNthOccurrenceOfValue(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		#>

	  #-----------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------#
	
	def FindNthSubValueCS(_n_, pSubValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(_n_)
			if StzFindFirst(_n_, [ :First, :FirstOccurrence ]) > 0
				_n_ = 1

			but StzFindFirst(_n_, [ :Last, :LastOccurrence ]) > 0
				_n_ = This.CountSubValueCS(pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindSubValueCS(pSubValue, pCaseSensitive)

		_nLen_ = len(_anPos_)

		_aResult_ = []
		_m_ = 0
		for i = 1 to _nLen_
			_line_ = _anPos_[i]
			_nLine2Len_ = len(_line_[2])
			for j = 1 to _nLine2Len_
				_m_ += 1
				if _m_ = _n_
					_aResult_ = [ _line_[1], _line_[2][j] ]
					exit 2
				ok
			next
		next

		return _aResult_
			
		def FindNthOccurrenceOfSubValueCS(_n_, pSubValue, pCaseSensitive)
			return This.FindNthSubValueCS(_n_, pSubValue, pCaseSensitive)

	# Returns the nth cell that contains a text, as [ [ column, row ], place of the text in the cell ]; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ [ column, row ], place ] pair, or [ ]
	#   see        FindSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthSubValue(_n_, pSubValue)
		return This.FindNthSubValueCS(_n_, pSubValue, 1)

		# Returns the nth occurrence of a text inside the cells, as [ [ column, row ], place ]; [ ] when there are fewer.
		#
		#   _n_              the position, or how many, as a number
		#   pSubValueValue   the text to look for inside the cells
		#   returns          a [ [ column, row ], place ] pair, or [ ]
		#   see              FindNthSubValue
		def FindNthOccurrenceOfSubValue(_n_, pSubValue)
			return This.FindNthSubValue(_n_, pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindFirstCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindFirstCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindFirstSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstCellCS(pCellValueOrSubValue, pCaseSensitive)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstCS(pCellValueOrSubValue, pCaseSensitive)		

	# Returns the [ column, row ] position of the first cell equal to a text, or of the first cell containing it with [ :SubValue, text ].
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   warning                Raises an error for a number, because the list-of-lists helper it
	#                          uses passes StzFindAll its arguments in the wrong order; text values
	#                          work
	#   see                    FindLast, FindNth
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirst(pCellValueOrSubValue)
		return This.FindFirstCS(pCellValueOrSubValue, 1)
	
		def FindFirstOccurrence(pCellValueOrSubValue)
			return This.FindFirst(pCellValueOrSubValue)	

	  #----------------------------------------#
	 #   FIRST CELL AND LAST CELL POSITIONS   #
	#----------------------------------------#

	# Returns the position of the first cell, always [ 1, 1 ].
	#
	#   returns    the pair [ 1, 1 ]
	#   see        LastCellPosition
	def FirstCellPosition()
		return [1, 1]

	# Returns the position of the last cell, as [ number of columns, number of rows ].
	#
	#   returns    a [ column, row ] pair
	#   see        FirstCellPosition
	def LastCellPosition()
		return [ This.NumberOfCol(), This.NumberOfRows() ]

	  #---------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL VALUE IN THE TABLE  #
	#---------------------------------------------------------#

	def FindFirstCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(1, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

	# Returns the [ column, row ] position of the first cell equal to a value; [ ] when there is none.
	#
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindFirst
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstCell(pValue)
		return This.FindFirstCellCS(pValue, 1)

		def FindFirstOccurrenceOfCell(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstOccurrenceOfValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
	  #-------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-------------------------------------------------------#

	def FindFirstSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(1, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindFirstSubValueCS(pSubValue, pCaseSensitive)

	# Returns the first cell that contains a text, as [ [ column, row ], place of the text in the cell ].
	#
	#   returns    a [ [ column, row ], place ] pair, or [ ]
	#   see        FindSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstSubValue(pSubValue)
		return This.FindFirstSubValueCS(pSubValue, 1)

		# Returns the first occurrence of a text inside the cells, as [ [ column, row ], place ]; [ ] when there is none.
		#
		#   pSubValueValue   the text to look for inside the cells
		#   returns          a [ [ column, row ], place ] pair, or [ ]
		#   see              FindFirstSubValue
		def FindFirstOccurrenceOfSubValue(pSubValue)
			return This.FindFirstSubValue(pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#----------------------------------------------------------------------------------------#

	def FindLastCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindLastCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindLastSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastCellCS(pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastCS(pCellValueOrSubValue, pCaseSensitive)		

	# Returns the [ column, row ] position of the last cell equal to a text, or of the last cell containing it with [ :SubValue, text ].
	#
	#   returns    a [ column, row ] pair, or [ ]
	#   warning    Raises an error for a number, because the list-of-lists helper it uses passes
	#              StzFindAll its arguments in the wrong order; text values work
	#   see        FindFirst
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLast(pCellValue)
		return This.FindLastCS(pCellValue, 1)
	
		def FindLastOccurrence(pCellValue)
			return This.FindLast(pCellValue)	

	  #-------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE  #
	#-------------------------------------------#

	def FindLastCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(:Last, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

	# Returns the [ column, row ] position of the last cell equal to a value; [ ] when there is none.
	#
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindLast
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLastCell(pValue)
		return This.FindLastCellCS(pValue, 1)

		def FindLastOccurrenceOfCell(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastOccurrenceOfValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
	  #-----------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE  #
	#-----------------------------------------#

	def FindLastSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(:Last, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindLastSubValueCS(pSubValue, pCaseSensitive)

		# Returns the last cell that contains a text, as [ [ column, row ], place of the text in the cell ].
		#
		#   returns    a [ [ column, row ], place ] pair, or [ ]
		#   see        FindSubValue
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastSubValue(pSubValue)
			return This.FindLastSubValueCS(pSubValue, 1)

			# Returns the last occurrence of a text inside the cells, as [ [ column, row ], place ]; [ ] when there is none.
			#
			#   pSubValueValue   the text to look for inside the cells
			#   returns          a [ [ column, row ], place ] pair, or [ ]
			#   see              FindLastSubValue
			def FindLastOccurrenceOfSubValue(pSubValue)
				return This.FindLastSubValue(pSubValue)

	  #==========================================================================================#
	 #  GETTING NUMBER OF OCCURRENCE A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==========================================================================================#

	def NumberOfOccurrenceCS(pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrence( :OfCell = "Ali" ) #--> 2
		? _o1_.NumberOfOccurrence( :OfSubValue = "A" ) #--> 3
		*/

		if isList(pValue)
			if IsOneOfTheseNamedParamsList(pValue, [ :Cell, :OfCell, :Cells, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrenceOfCellCS(pValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pValue, [ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrenceOfSubValueCS(pValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def CountCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrenceCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

	# Returns how many cells equal a text, case-sensitively; [ :OfCell, v ] and [ :OfSubValue, text ] choose what is counted.
	#
	#   pValue     the text to count, or [ :OfCell, v ] or [ :OfSubValue, text ]
	#   returns    a number
	#   warning    Raises an error for a number, because the list-of-lists helper it uses passes
	#              StzFindAll its arguments in the wrong order; text values work
	#   see        NumberOfOccurrenceOfCell, NumberOfOccurrenceOfSubValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrence(pValue)
		return This.NumberOfOccurrenceCS(pValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		def Count(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowMany(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrence(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		#>

	  #-------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellCS(pCellValue, pCaseSensitive)
		return len( This.FindCellCS(pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#==

		def HowManyCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

	# Returns how many cells equal a value, case-sensitively.
	#
	#   returns    a number
	#   warning    Raises an error for a number, because the list-of-lists helper it uses passes
	#              StzFindAll its arguments in the wrong order; text values work
	#   see        NumberOfOccurrence
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceOfCell(pCellValue)
		return This.NumberOfOccurrenceOfCellCS(pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def NumberOfOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def HowManyCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#>

	  #-----------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		_aPos_ = This.FindSubValueCS(pSubValue, pCaseSensitive)
		_nLen_ = len(_aPos_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += len(_aPos_[i][2])
		next

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

	# Returns how many cells contain a text, case-sensitively.
	#
	#   returns    a number
	#   see        NumberOfOccurrence
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceOfSubValue(pSubValue)
		return This.NumberOfOccurrenceOfSubValueCS(pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#--

		def HowManyOccurrenceOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrenceOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#>

	   #------------------------------------------------------------------#
	  #  GETTING NUMBER OF OCCURRENCE OF A GIVEN CELL VALUE OR SUBVALUE  #
	 #  IN THE GIVEN CELL(S) OR COL(S) OR ROW(S)                        #
	#------------------------------------------------------------------#

	def NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([

		])

		? _o1_.NumberOfOccurrenceXT( :InCol = :NAME, :OfSubValue = "Ali" )
		*/

		if NOT isList(pInCellsOrColOrRow)
			StzRaise("Incorrect param type! pInCellsOrColOrRow must be a list.")
		ok

		_nResult_ = 0

		_oTempList_ = new stzList(pInCellsOrColOrRow)
		if _oTempList_.IsInCellNamedParam()
			_coll_ = pInCellsOrColOrRow[2][1]
			_nRow_ = pInCellsOrColOrRow[2][2]
			_nResult_ = This.NumberOfOccurrenceInCellCS(_coll_, _nRow_, pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInCellsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInCellsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInColNamedParam()
			_nResult_ = This.NumberOfOccurrenceInColCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInColsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInColsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInRowNamedParam()
			_nResult_ = This.NumberOfOccurrenceInRowCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInRowsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInRowsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		else
			StzRaise("Syntax error! pInCellsOrColOrRow must be one of these lists ( :InCells = ..., :InCol = ..., or :InRow = ...).")

		ok

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def CountCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def CountXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		#>

	  #=============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A CELL  #
	#=============================================================================#

	def ContainsCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Dan", "Ali", "Sam" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.Contains( :Cell = "Ali" ) #--> TRUE
		? _o1_.Contains( :SubValue = "a" ) #--> TRUE
		*/

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzlist(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :Value ])
				return This.ContainsCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :Part, :CellPart ])
				return This.ContainsSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.ContainsCellCS(pCellValueOrSubValue, pCaseSensitive)

		# TRUE if some cell equals the text; a text found only inside a longer cell does not count.
		#
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                TRUE or FALSE
		#   warning                Raises an error for a number, because the list-of-lists helper it
		#                          uses passes StzFindAll its arguments in the wrong order; text
		#                          values work
		#   see                    ContainsSubValue
		#@ aka  -- WITHOUT CASESENSITIVITY
		def Contains(pCellValueOrSubValue)
			return This.ContainsCS(pCellValueOrSubValue, 1)

	def ContainsCellCS(pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def ContainsValueCS(pCellValue, pCaseSensitive)
			return This.ContainsCellCS(pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

			def ContainsValue(pCellValue)
				return This.ContainsCell(pCellValue)

	  #-----------------------------------------------#
	 #  CHECKING IF THE TABBLE CONTAINS A GIVEN ROW  #
	#-----------------------------------------------#

	def ContainsRowCS(paRow, pCaseSensitive)
		_bResult_ = 0

		if isList(paRow) and len(paRow) = This.NumberOfCols()

			_bResult_ = ( len(This.FindRowCS(paRow, pCaseSensitive)) > 0 )
		ok

		return _bResult_

	# TRUE if the table has a row equal to the given cells, case-sensitively.
	#
	#   paRow      the cells of a row, one per column
	#   returns    TRUE or FALSE
	#   see        ContainsRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsRow(paRow)
		return This.ContainsRowCS(paRow, 1)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN ROWS  #
	#-------------------------------------------------#

	def ContainsRowsCS(paRows, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCols([
			[ 10, "Imed", 52  ],
			[ 30, "Karim", 48 ]
		])

		#--> TRUE
		*/

		_bResult_ = 1
		_nLen_ = len(paRows)

		for i = 1 to _nLen_
			if NOT This.ContainsRowCS(paRows[i], pCaseSensitive)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

		def ContainsTheseRowsCS(paRows, pCaseSensitive)
			return This.ContainsRowsCS(paRows, pCaseSensitive)

	# TRUE if the table has every one of the given rows, case-sensitively.
	#
	#   paRows     the rows to look for, each a list of cells
	#   returns    TRUE or FALSE
	#   see        ContainsRow
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsRows(paRows)
		return This.ContainsRowsCS(paRows, 1)

		def ContainsTheseRows(paRows)
			return This.ContainsRows(paRows)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN COLUMN  #
	#-------------------------------------------------#

	def ContainsColCS(paCol, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
		#--> TRUE
		*/

		_bResult_ = 0

		if isList(paCol) and len(paCol) = 2 and
		   isString(paCol[1]) and This.HasColName(paCol[1]) and
		   isList(paCol[2]) and len(paCol[2]) = This.NumberOfRows()

			_cCol_ = paCol[1]
			_bResult_ = This.ColQ(_cCol_).IsEqualToCS(paCol[2], pCaseSensitive)
		ok

		return _bResult_

		def ContainsColumnCS(paCol, pCaseSensitive)
			return This.ContainsColCS(paCol, pCaseSensitive)

	# TRUE if the table has a column of that name holding exactly those cells, case-sensitively.
	#
	#   paCol      the column, as [ name, list of cells ]
	#   returns    TRUE or FALSE
	#   warning    Answers FALSE for a list of cells given without the column name
	#   see        ContainsCols
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsCol(paCol)
		return This.ContainsColCS(paCol, 1)

		def ContainsColumn(paCol)
			return This.ContainsCol(paCol)

	  #----------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN COLUMNS  #
	#----------------------------------------------------#

	def ContainsColsCS(paCols, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCols([
			:NAME = [ "Imed", "Hatem", "Karim" ],
			:AGE  = [ 52, 46, 48 ]
		])

		#--> TRUE
		*/

		_bResult_ = 1
		_nLen_ = len(paCols)

		for i = 1 to _nLen_
			if NOT This.ContainsColCS(paCols[i], pCaseSensitive)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

		def ContainsTheseColsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsTheseColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

	# TRUE if the table has every one of the given columns, each as [ name, cells ].
	#
	#   paCols     the columns to look for, each as [ name, list of cells ]
	#   returns    TRUE or FALSE
	#   see        ContainsCol
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsCols(paCols)
		return This.ContainsColsCS(paCols, 1)

		def containsTheseCols(paCols)
			return This.ContainsCols(paCols)

		# TRUE if the table has every one of the given columns, each as [ name, cells ].
		#
		#   paCols     the columns to look for, each as [ name, list of cells ]
		#   returns    TRUE or FALSE
		#   see        ContainsCols
		def ContainsColumns(paCols)
			return This.ContainsCols(paCols)

		# TRUE if the table has every one of the given columns, each as [ name, cells ].
		#
		#   paCols     the columns to look for, each as [ name, list of cells ]
		#   returns    TRUE or FALSE
		#   see        ContainsCols
		def ContainsTheseColumns(paCols)
			return This.ContainsCols(paCols)

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS CELLS THAT INCLUDE A GIVEN SUBVALUE  #
	#----------------------------------------------------------------------#

	def ContainsSubValueCS(pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

	# TRUE if some cell contains the text, case-sensitively.
	#
	#   returns    TRUE or FALSE
	#   see        Contains
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsSubValue(pSubValue)
		return This.ContainsSubValueCS(pSubValue, 1)


	/// WORKING ON SOME CELLS //////////////////////////////////////////////////

	  #=====================================================#
	 #  FINDING A GIVEN VALUE OR SUBVALUE IN A GIVEN CELL  #
	#=====================================================#

	def FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 1
				_bSubValue_ = 0

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 0
				_bSubValue_ = 1
			ok
		
		ok

		if _bValue_
			_bResult_ = This.CellQ(pCellCol, pCellRow).IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
			return _bResult_

		else // bSubValue

			_anResult_ = []

			_oCell_ = This.CellQ(pCellCol, pCellRow)

			if @IsStzFindable(_oCell_)
				_anResult_ = _oCell_.FindCS(pCellValueOrSubValue, pCaseSensitive)

			ok

			return _anResult_
		ok

	# Returns the places where a text occurs inside one cell, as character positions; [ ] when it does not.
	#
	#   pCellCol               the column of the cell, by name or position
	#   pCellRow               the row position of the cell
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a list of numbers
	#   warning                The [ :Value, v ] form answers the number 1 when the cell equals v,
	#                          not a list
	#   see                    FindSubValueInCell
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

	  #---------------------------------------------#
	 #  FINDING A GIVEN VALUE INSIDE A GIVEN CELL  #
	#---------------------------------------------#

	def FindValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :Value = pValue, pCaseSensitive)

	# Returns 1 when the cell equals the value, otherwise 0.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    1 or 0
	#   see        FindInCell
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValueInCell(pCellCol, pCellRow, pValue)
		return This.FindValueInCellCS(pCellCol, pCellRow, pValue, 1)

	  #------------------------------------------------#
	 #  FINDING A GIVEN SUBVALUE INSIDE A GIVEN CELL  #
	#------------------------------------------------#

	def FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :SubValue = pSubValue, pCaseSensitive)

	# Returns the places where a text occurs inside one cell, as character positions.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    a list of numbers; [ ] when absent
	#   see        FindInCell
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN A GIVEN NUMBER OF CELLS  #
	#================================================================================================#

	def FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and @IsListOfPairs(paCells) )
			StzRaise("Incorrect param type! paCells must be a list of pairs.")
		ok

		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])

				_bValue_ = 1
				_bSubValue_ = 0
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])

				_bValue_ = 0
				_bSubValue_ = 1
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			ok

		ok

		_nLen_ = len(paCells)
		_aResult_ = []

		if _bValue_

			for i = 1 to _nLen_
				_cellValue_ = This.Cell(paCells[i][1], paCells[i][2])
				_oCell_ = Q(_cellValue_)

				if @BothAreNumbers(_cellValue_, pCellValueOrSubValue)

					if _cellValue_ = pCellValueOrSubValue
						_aResult_ + paCells[i]
					ok

				but @BothAreStrings(_cellValue_, pCellValueOrSubValue) or
				    @BothAreLists(_cellValue_, pCellValueOrSubValue)
				
					if _oCell_.IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
						_aResult_ + paCells[i]
					ok

				but @BothAreStzObjects( _cellValue_, pCellValueOrSubValue)

					if _oCell_.IsEqualTo(pCellValueOrSubValue)
						_aResult_ + paCells[i]
					ok

				ok
			next

		else // bSubValue

			for i = 1 to _nLen_
				_aPos_ = This.FindSubValueInCellCS(paCells[i][1], paCells[i][2], pCellValueOrSubValue, pCaseSensitive)
				if len(_aPos_) > 0
					_aResult_ + [ paCells[i], _aPos_ ]
				ok
			next
		ok

		return _aResult_
				
		#< @FunctionAlternativeForms

		def FindAllOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def PositionsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	# Returns, for the given cells, the cells that contain a text with the places inside each, or the cells equal to a value with [ :Value, v ].
	#
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a list of [ [ column, row ], places ] items, or of [ column, row ]
	#                          positions
	#   warning                Raises an error unless paCells is a list of pairs
	#   see                    FindSubValueInCells
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindAllInCells(paCells, pCellValueOrSubValue)

		return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def FindAllOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def FindOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		# Returns, among the given cells, those that contain a text, with the places of the text inside each.
		#
		#   pCellValueOrSubValue   the text to look for
		#   returns                a list of [ [ column, row ], places ] items
		#   see                    FindAllInCells
		def OccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
		
		def PositionsInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		def FindInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		#>

	  #--------------------------------------------#
	 #  FINDING A VALUE IN A GIVEN LIST OF CELLS  #
	#--------------------------------------------#

	def FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		_aCellsXT_ = This.TheseCellsAndTheirPositions(paCells)

		_aResult_ = []

		_nCellsXTLen_2 = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_2

			_cellValue_ = _aCellsXT_[i][1]
			_aCellPos_  = _aCellsXT_[i][2]

			if @BothAreNumbers(_cellValue_, pCellValue)
				if _cellValue_ = pCellValue
					_aResult_ + _aCellPos_
				ok

			but @BothAreStrings(_cellValue_, pCellValue) or
			    @BothAreLists(_cellValue_, pCellValue)

				if Q(_cellValue_).IsEqualToCS(pCellValue, pCaseSensitive)
					_aResult_ + _aCellPos_
				ok

			but @BothAreStzObjects(_cellValue_, pCellValue)

				if Q(_cellValue_).IsEqualTo(pCellValue)
					_aResult_ + _aCellPos_
				ok
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms
			
		def OccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def PositionsOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	# Returns the given cells that equal a value, as [ column, row ] positions.
	#
	#   returns    a list of [ column, row ] positions
	#   see        FindNthValueInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValueInCells(paCells, pValue)
		return This.FindValueInCellsCS(paCells, pValue, 1)
			
		def OccurrencesOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(paCells, pCellValue)

		# Returns the given cells that equal a value, as [ column, row ] positions.
		#
		#   paCells    the cells to look in, each as a [ column, row ] position
		#   returns    a list of [ column, row ] positions
		#   see        FindFirstInCells
		def PositionsOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(paCells, pCellValue)
	
	  #-----------------------------------------------#
	 #  FINDING A SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-----------------------------------------------#

	def FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		_aCellsXT_ = This.TheseCellsAndTheirPositions(paCells)

		_aResult_ = []

		_nCellsXTLen_ = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_

			_cellValue_ = _aCellsXT_[i][1]
			_oCellValue_ = Q(_cellValue_)

			_aCellPos_  = _aCellsXT_[i][2]

			if @BothAreStrings(_cellValue_, pSubValue) or
			   @BothAreLists(_cellValue_, pSubValue)

				if _oCellValue_.ContainsCS(pSubValue, pCaseSensitive)
					_aResult_ + [ _aCellPos_, _oCellValue_.FindAllCS(pSubValue, pCaseSensitive) ]
				ok

			but @BothAreNumbers(_cellValue_, pSubValue) or
				( (isString(_cellValue_) and isNumber(pSubValue)) or
			     	  (isNumber(_cellValue_) and @IsNumberInString(pSubValue))
				)

				_oStzStrCellValue_ = new stzString(""+ _cellValue_)

				if _oStzStrCellValue_.Contains(''+ pSubValue)
					_aResult_ + [ _aCellPos_, _oStzStrCellValue_.FindAll(""+ pSubValue) ]
				ok
			ok

		next

		return _aResult_

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def PositionsOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	# Returns the given cells that contain a text, each as [ [ column, row ], [ places in the cell ] ].
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a list of [ [ column, row ], places ] items
	#   see        FindSubValueInCell
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValueInCells(paCells, pSubValue)
		return This.FindSubValueInCellsCS(paCells, pSubValue, 1)

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		def PositionsOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#---------------------------------------------------------------------------------------------#

	def FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindNthValueInCellsCS(_n_, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindNthSubValueInCellsCS(_n_, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindNthValueInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)		

	# Returns the nth, among the given cells, whose value equals a text; with [ :SubValue, text ] the nth that contains it.
	#
	#   _n_                    the position, or how many, as a number
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindFirstInCells, FindLastInCells
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthInCells(_n_, paCells, pCellValueOrSubValue)
		return This.FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, 1)
	
		def FindNthOccurrenceInCells(_n_, paCells, pCellValueOrSubValue)
			return This.FindNthInCells(_n_, paCells, pCellValueOrSubValue)	

	  #----------------------------------------------#
	 #  FINDING NTH VALUE IN A GIVEN LIST OF CELLS  #
	#----------------------------------------------#

	def FindNthValueInCellsCS(_n_, paCells, pCellValue, pCaseSensitive)
		# Returns the cell position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(_n_)
			if StzFindFirst(_n_, [ :First, :FirstOccurrence, :FirstValue ]) > 0
				_n_ = 1

			but StzFindFirst(_n_, [ :Last, :LastOccurrence, :LastValue ]) > 0
				_n_ = This.NumberOfOccurrenceInCellsCS(paCells, pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindValueInCellsCS( paCells, pCellValue, pCaseSensitive)

		_aResult_ = []

		if len(_anPos_) > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		def FindNthOccurrenceOfValueInCellCS(_n_, paCells, pCellValue, pCaseSensitive)
			return This.FindNthValueInCellCS(_n_, paCells, pCellValue, pCaseSensitive)

	# Returns the [ column, row ] position of the nth cell of the whole table equal to a value, ignoring the given cells.
	#
	#   _n_        the position, or how many, as a number
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ column, row ] pair, or [ ]
	#   warning    Looks in the whole table, not in paCells: the body forwards to FindNthCellCS
	#              without the cells
	#   see        FindNthInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthValueInCells(_n_, paCells, pValue)
		return This.FindNthValueInCellsCS(_n_, paCells, pValue, 1)

		# Returns the nth of the given cells that equals a value; [ ] when there are fewer.
		#
		#   _n_          the position, or how many, as a number
		#   paCells      the cells to look in, each as a [ column, row ] position
		#   pCellValue   the value to look for
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindNthInCells
		def FindNthOccurrenceOfValueInCells(_n_, paCells, pCellValue)
			return This.FindNthValueInCells(_n_, paCells, pCellValue)
	
	  #-------------------------------------------------#
	 #  FINDING NTH SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-------------------------------------------------#

	def FindNthSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)
		# Returns the subvalue position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(_n_)
			if StzFindFirst(_n_, [ :First, :FirstOccurrence, :FirstSubValue ]) > 0
				_n_ = 1

			but StzFindFirst(_n_, [ :Last, :LastOccurrence, :LastSubValue ]) > 0
				_n_ = This.CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_nLen_ = len(_anPos_)

		_aResult_ = []
		_m_ = 0

		for i = 1 to _nLen_
			_line_ = _anPos_[i]
			_nLen2_ = len(_line_[2])

			for j = 1 to _nLen2_
				_m_ += 1
				if _m_ = _n_
					_aResult_ = [ _line_[1], _line_[2][j] ]
					exit 2
				ok
			next
		next

		return _aResult_
			
		def FindNthOccurrenceOfSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)

	# Returns the nth given cell that contains a text, as [ [ column, row ], place of the text ].
	#
	#   _n_        the position, or how many, as a number
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ [ column, row ], place ] pair, or [ ]
	#   see        FindSubValueInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthSubValueInCells(_n_, paCells, pSubValue)
		return This.FindNthSubValueInCellsCS(_n_, paCells, pSubValue, 1)

		# Returns the nth occurrence of a text inside the given cells, as [ [ column, row ], place ].
		#
		#   _n_              the position, or how many, as a number
		#   paCells          the cells to look in, each as a [ column, row ] position
		#   pSubValueValue   the text to look for inside the cells
		#   returns          a [ [ column, row ], place ] pair, or [ ]
		#   see              FindNthSubValueInCells
		def FindNthOccurrenceOfSubValueInCells(_n_, paCells, pSubValue)
			return This.FindNthSubValueInCells(_n_, paCells, pSubValue)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#------------------------------------------------------------------------------------------------#

	def FindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindFirstSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

	# Returns the first, among the given cells, whose value equals a text; with [ :SubValue, text ] the first that contains it.
	#
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindLastInCells
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstInCells(paCells, pCellValueOrSubValue)
		return This.FindFirstInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		def FindFirstOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.FindFirstInCells(paCells, pCellValueOrSubValue)	

	  #--------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL IN THE PROVIDED LIST OF CELLS  #
	#--------------------------------------------------------------------------#

	def FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(1, paCells, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	# Returns the first of the given cells that equals a value; [ ] when there is none.
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindFirstInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstValueInCells(paCells, pValue)
		return This.FindFirstValueInCellsCS(paCells, pValue, 1)

		# Returns the first of the given cells that equals a value; [ ] when there is none.
		#
		#   paCells      the cells to look in, each as a [ column, row ] position
		#   pCellValue   the value to look for
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindFirstInCells
		def FindFirstOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindFirstValueInCells(paCells, pCellValue)

	  #------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN THE PROVIDED LIST OF CELLS  #
	#------------------------------------------------------------------------------#

	def FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(1, paCells, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	# Returns the first given cell that contains a text, as [ [ column, row ], place of the text ].
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ [ column, row ], place ] pair, or [ ]
	#   see        FindSubValueInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstSubValueInCells(paCells, pSubValue)
		return This.FindFirstSubValueInCellsCS(paCells, pSubValue, 1)

		# Returns the first occurrence of a text inside the given cells, as [ [ column, row ], place ].
		#
		#   paCells          the cells to look in, each as a [ column, row ] position
		#   pSubValueValue   the text to look for inside the cells
		#   returns          a [ [ column, row ], place ] pair, or [ ]
		#   see              FindFirstSubValueInCells
		def FindFirstOccurrenceOfSubValueInCells(paCells, pSubValue)
			return This.FindFirstSubValueInCells(paCells, pSubValue)

	  #-----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------------------------------------#

	def FindLastInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfPart ])
				return This.FindLastSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

	# Returns the last, among the given cells, whose value equals a text; with [ :SubValue, text ] the last that contains it.
	#
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindFirstInCells
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLastInCells(paCells, pCellValueOrSubValue)
		return This.FindLastInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		def FindLastOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.FindLastInCells(paCells, pCellValueOrSubValue)	

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN VAULUE IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------#

	def FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(:Last, paCells, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	# Returns the last of the given cells that equals a value; [ ] when there is none.
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindLastInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLastValueInCells(paCells, pValue)
		return This.FindLastValueInCellsCS(paCells, pValue, 1)

		# Returns the last of the given cells that equals a value; [ ] when there is none.
		#
		#   paCells      the cells to look in, each as a [ column, row ] position
		#   pCellValue   the value to look for
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindLastInCells
		def FindLastOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindLastValueInCells(paCells, pCellValue)

	  #-------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN SUBVALUE IN SOME GIVEN CELLS  #
	#-------------------------------------------------------------------#
	
	def FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	# Returns the last given cell that contains a text, as [ [ column, row ], place of the text ].
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a [ [ column, row ], place ] pair, or [ ]
	#   see        FindSubValueInCells
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLastSubValueInCells(paCells, pSubValue)
		return This.FindLastSubValueInCellsCS(paCells, pSubValue, 1)

		# Returns the last occurrence of a text inside the given cells, as [ [ column, row ], place ].
		#
		#   paCells          the cells to look in, each as a [ column, row ] position
		#   pSubValueValue   the text to look for inside the cells
		#   returns          a [ [ column, row ], place ] pair, or [ ]
		#   see              FindLastSubValueInCells
		def FindLasttOccurrenceOfSubValueInCells(paCells, pSubValue)
			return This.FindLastSubValueInCells(paCells, pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF  CELLS  #
	#----------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	# Returns how many of the given cells equal a value.
	#
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a number
	#   see                    CellsContain
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
		return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
	
		def CountInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF  CELLS  #
	#-------------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		_nResult_ = len( This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive) )
		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def CountValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	# Returns how many of the given cells equal a value.
	#
	#   paCells      the cells to look in, each as a [ column, row ] position
	#   pCellValue   the value to count
	#   returns      a number
	#   see          NumberOfOccurrencesInCells
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, 1)

		#--

		def NumberOfOccurrenceOfValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def CountValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		#--

		def NumberOfOccurrencesInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def NumberOfOccurrenceInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF  CELLS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_anPos_ = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_nLen_ = len(_anPos_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += len(_anPos_[i][2])
		next

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	# Returns 0 today instead of the number of given cells that contain a text.
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    a number, 0 today
	#   warning    Counts cells equal to the text, not cells containing it, so a text found inside a
	#              longer cell is missed
	#   see        NumberOfOccurrencesInCells
		#>
	# Returns how many times a text occurs inside the given cells.
	def NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, 1)

	#--

	def NumberOfOccurrenceOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def CountSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#--

	def NumberOfOccurrencesInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def NumberOfOccurrenceInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.CellsContainValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.CellsContainSubValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.CellsContainValueCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def ContainsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	# TRUE if at least one of the given cells equals the value; with [ :SubValue, text ] if one contains it.
	#
	#   paCells                the cells to look in, each as a [ column, row ] position
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                TRUE or FALSE
	#   see                    CellsContainValue, CellsContainSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellsContain(paCells, pCellValueOrSubValue)
		return This.CellsContainCS(paCells, pCellValueOrSubValue, 1)

		def ContainsInCells(paCells, pCellValueOrSubValue)
			return This.CellsContain(paCells, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellsContainValueCS(paCells, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellsCS(paCells, pValue, pCaseSensitive) ) > 0
			return 1
		else
			return 0
		ok

		def ContainsValueInCellsCS(paCells, pValue, pCaseSensitive)
			return This.CellsContainValueCS(paCells, pValue, pCaseSensitive)

	# TRUE if at least one of the given cells equals the value.
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    TRUE or FALSE
	#   see        CellsContain
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellsContainValue(paCells, pValue)
		return This.CellsContainValueCS(paCells, pValue, 1)

		def ContainsValueInCells(paCells, pValue)
			return This.CellsContainValue(paCells, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)
		_aTemp_ = This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		if isList(_aTemp_) and len(_aTemp_) > 0
			return 1
		else
			return 0
		ok

		def ContainsSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)

	# TRUE if at least one of the given cells contains the text.
	#
	#   paCells    the cells to look in, each as a [ column, row ] position
	#   returns    TRUE or FALSE
	#   see        CellsContain
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellsContainSubValue(paCells, pSubValue)
		return This.CellsContainSubValueCS(paCells, pSubValue, 1)

		def ContainsSubValueInCells(paCells, pSubValue)
			return This.CellsContainSubValue(paCells, pSubValue)

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN A GIVEN CELL  #
	#========================================================#

	def FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
		if isString(_n_)
			if lower(_n_) = "first" or lower(_n_) = "firstoccurrence"
				_n_ = 1

			but lower(_n_) = "last" or lower(_n_) = "lastoccurrence"
				_n_ = This.NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#TODO // Implement a more performant alortithm by adding FindNext...()
		if _n_ >= 1 and _n_ <= len(_anPos_)
			return _anPos_[_n_]
		ok

		return 0

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindNthSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindNthOccurrenceOfSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

	# Returns the place of the nth occurrence of a text inside one cell, as a character position.
	#
	#   _n_        the position, or how many, as a number
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    a number
	#   warning    Raises R2 when the cell holds fewer than n occurrences
	#   see        FindFirstInCell, FindInCell
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)
		return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)

		def FindNthSubValueInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)
			
		def FindNthOccurrenceOfSubValueInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN A CELL)  #
	#-----------------------------------------------------------#

	def FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(1, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	# Returns the place of the first occurrence of a text inside one cell, as a character position.
	#
	#   pCellCol    the column of the cell, by name or position
	#   pCellRow    the row position of the cell
	#   pSubValue   the text to look for inside the cell
	#   returns     a number
	#   warning     Raises R2 when the text is absent from the cell
	#   see         FindInCell
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstInCell(pCellCol, pCellRow, pSubValue)
		return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		def FindFirstSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)
			
		def FindFirstOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELL  #
	#----------------------------------------------------------------------------------------------#

	def FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(:Last, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindLastSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	# Raises error today instead of returning the place of the last occurrence of a text inside one cell.
	#
	#   pCellCol    the column of the cell, by name or position
	#   pCellRow    the row position of the cell
	#   pSubValue   the text to look for inside the cell
	#   returns     nothing; it raises
	#   warning     Raises Incorrect param type! n must be a number. because it passes :Last, which
	#               the nth-occurrence finder does not read
	#   see         FindNthInCell
		#>
	# Returns the place of the last occurrence of a text inside one cell; 0 when it is absent.
	def FindLastInCell(pCellCol, pCellRow, pSubValue)
		return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		def FindLastSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)
			
		def FindLastOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #--------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF CELL  #
	#--------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

	# Raises an error today instead of counting how many times a text occurs inside one cell.
	#
	#   pCellCol               the column of the cell, by name or position
	#   pCellRow               the row position of the cell
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises Bad parameter type! for every argument tried
	#   see                    NumberOfOccurrenceInCell
		#>
	# Returns how many times a text occurs inside one cell, or 1 when the cell equals a value.
	def NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)
	
		#< @FunctionAlternativeForms

		def CountInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF CELL  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
		# A value is a whole cell: it occurs once in the cell that equals it, never in another
		if This.FindValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return 1
		ok
		return 0

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def CountValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

	# Raises an error today instead of counting how many times a value occurs inside one cell.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    nothing; it raises
	#   warning    Raises Bad parameter type! for every argument tried
	#   see        NumberOfOccurrenceInCell
		#>
	# Returns 1 when one cell equals the value, otherwise 0.
	def NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def CountValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		#--

		def NumberOfOccurrencesInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def NumberOfOccurrenceInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		#>

	  #---------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF CELL  #
	#---------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_nResult_ = len( This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive) )
		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def CountSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfSubValueCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	# Raises an error today instead of counting how many times a text occurs inside one cell.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    nothing; it raises
	#   warning    Raises Bad parameter type! for every argument tried
	#   see        NumberOfOccurrenceInCell
		#>
	# Returns how many times a text occurs inside one cell.
	def NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

	#--

	def NumberOfOccurrenceOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def CountSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#--

	def NumberOfOccurrencesInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def NumberOfOccurrenceInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 1
				_bSubValue_ = 0
				
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		_bResult_ = 0

		if _bValue_
			_bResult_ = This.CellContainsValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		else // bSubValue
			_bResult_ = This.CellContainsSubValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		ok

		return _bResult_

		def ContainsInCellCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.CellContainsCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

	# Returns an empty string for a text present in the cell and raises R2 for an absent one, instead of TRUE or FALSE.
	#
	#   pCellCol               the column of the cell, by name or position
	#   pCellRow               the row position of the cell
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; an empty string
	#   see                    CellContainsSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellContains(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

		def ContainsInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.CellContains( pCellCol, pCellRow, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	# TRUE if one cell equals the value, with a case flag.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    TRUE or FALSE
	#   see        CellContainsSubValue
	def CellContainsValueCS( pCellCol, pCellRow, pValue, pCaseSensitive)
		if This.FindValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return 1
		else
			return 0
		ok

		def CellContainValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return This.CellContainsValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)

		def ContainsValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return This.CellContainValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)

	# TRUE if one cell equals the value.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    TRUE or FALSE
	#   see        CellContainsSubValue
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellContainValue(pCellCol, pCellRow, pValue)
		return This.CellContainValueCS(pCellCol, pCellRow, pValue, 1)

		def ContainsValueInCell(pCellCol, pCellRow, pValue)
			return This.CellContainValue( pCellCol, pCellRow, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_nPos_ = This.FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		if _nPos_ > 0
			return 1
		else
			return 0
		ok

		def ContainsSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	# TRUE if one cell contains the text; raises R2 instead of answering FALSE when it does not.
	#
	#   pCellCol   the column of the cell, by name or position
	#   pCellRow   the row position of the cell
	#   returns    TRUE, or an R2 error
	#   see        ContainsSubValueInCell
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CellContainsSubValue(pCellCol, pCellRow, pSubValue)
		return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, 1)

		# TRUE if one cell contains the text; raises R2 instead of answering FALSE when it does not.
		#
		#   pCellCol   the column of the cell, by name or position
		#   pCellRow   the row position of the cell
		#   returns    TRUE, or an R2 error
		#   see        CellContainsSubValue
		def ContainsSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.CellContainsSubValue(pCellCol, pCellRow, pSubValue)

	/// WORKING ON ROWS //////////////////////////////////////////////////////////////////////

	  #======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#======================================================================================#

	def FindInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? _o1_.FindInRow(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? _o1_.FindInRow(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? _o1_.FindInRow( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		_aCellsPos_ = This.RowCellsAsPositions(pRow)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.FindValueInCellsCS(_aCellsPos_, pCellValueOrSubValue, pCaseSensitive)


		# Returns the positions of the cells in one row that equal a value, or that contain a text with [ :SubValue, text ].
		#
		#   pRow                   the row position, 1 for the first
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a list of [ column, row ] positions; with :SubValue, [ [ column,
		#                          row ], places ] items
		#   warning                Raises R2 for a row past the last one; a text found only inside a
		#                          longer cell is missed without :SubValue
		#   see                    FindFirstInRow, FindNthInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindInRow(pRow, pCellValueOrSubValue)
			return This.FindInRowCS(pRow, pCellValueOrSubValue, 1)

	def FindValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		# Returns the cells of one row that equal a value, as [ column, row ] positions.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a list of [ column, row ] positions
		#   see        FindInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindValueInRow(pRow, pCellValue)
			return This.FindValueInRowCS(pRow, pCellValue, 1)

	def FindSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		# Returns the positions of the cells in one row that equal the text, not the cells that contain it.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a list of [ column, row ] positions
		#   warning    Forwards to the whole-value finder, so a text found only inside a longer cell
		#              answers [ ]
		#   see        FindInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindSubValueInRow(pRow, pSubValue)
			return This.FindSubValueInRowCS(pRow, pSubValue, 1)

	  #=========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#=========================================================================================#

	def FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :N, :Nth, :Occurrence ])
			_n_ = _n_[2]
		ok

		if isList(pRow) and IsOneOfTheseNamedParamsList(pRow,[ :Row, :InRow ])
			pRow = pRow[2]
		ok

		return This.FindNthInCellsCS(_n_, This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the nth cell in one row that equals a value; [ ] when there are fewer.
		#
		#   _n_                    the position, or how many, as a number
		#   pRow                   the row position, 1 for the first
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindFirstInRow, FindLastInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthInRow(_n_, pRow, pCellValueOrSubValue)
			return This.FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInRow(_n_, pRow, pCellValueOrSubValue)
				return This.FindNthInRow(_n_, pRow, pCellValueOrSubValue)

	def FindNthValueInRowCS(_n_, pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		# Returns the nth cell of one row that equals a value; [ ] when there are fewer.
		#
		#   _n_        the position, or how many, as a number
		#   pRow       the row position, 1 for the first
		#   returns    a [ column, row ] pair, or [ ]
		#   see        FindNthInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthValueInRow(_n_, pRow, pCellValue)
			return This.FindNthValueInRowCS(_n_, pRow, pCellValue, 1)

			def FindNthOccurrenceOfValueInRow(_n_, pRow, pCellValue)
				return This.FindNthValueInRow(_n_, pRow, pCellValue)

	def FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)

		# Returns the nth occurrence of a text inside the cells of one row, as [ [ column, row ], place ].
		#
		#   _n_        the position, or how many, as a number
		#   pRow       the row position, 1 for the first
		#   returns    a [ [ column, row ], place ] pair, or [ ]
		#   see        FindNthInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthSubValueInRow(_n_, pRow, pSubValue)
			return This.FindNthSubValueInRowCS(_n_, pRow, pSubValue, 1)

			def FindNthOccurrenceOfSubValueInRow(_n_, pRow, pSubValue)
				return This.FindNthSubValueInRow(_n_, pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(1, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the first cell in one row that equals a value; [ ] when there is none.
		#
		#   pRow                   the row position, 1 for the first
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindLastInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstInRow(pRow, pCellValueOrSubValue)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindFirstInRow(pRow, pCellValueOrSubValue)

	def FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInRowCS(1, pRow, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		# Returns the first cell of one row that equals a value; [ ] when there is none.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a [ column, row ] pair, or [ ]
		#   see        FindFirstInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstValueInRow(pRow, pCellValue)
			return This.FindFirstValueInRowCS(pRow, pCellValue, 1)

			def FindFirstOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindFirstValueInRow(pRow, pCellValue)

	def FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInRowCS(1, pRow, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		# Returns the first occurrence of a text inside the cells of one row, as [ [ column, row ], place ].
		#
		#   pRow       the row position, 1 for the first
		#   returns    a [ [ column, row ], place ] pair, or [ ]
		#   see        FindFirstInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstSubValueInRow(pRow, pSubValue)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, 1)

			def FindFirstOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindFirstSubValueInRow(pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the last cell in one row that equals a value; [ ] when there is none.
		#
		#   pRow                   the row position, 1 for the first
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindFirstInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastInRow(pRow, pCellValueOrSubValue)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindLastInRow(pRow, pCellValueOrSubValue)

	def FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInRowCS(:Last, pRow, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		# Returns the last cell of one row that equals a value; [ ] when there is none.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a [ column, row ] pair, or [ ]
		#   see        FindLastInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastValueInRow(pRow, pCellValue)
			return This.FindLastValueInRowCS(pRow, pCellValue, 1)

			def FindLastOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindLastValueInRow(pRow, pCellValue)

	def FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInRowCS(:Last, pRow, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		# Returns the last occurrence of a text inside the cells of one row, as [ [ column, row ], place ].
		#
		#   pRow       the row position, 1 for the first
		#   returns    a [ [ column, row ], place ] pair, or [ ]
		#   see        FindLastInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastSubValueInRow(pRow, pSubValue)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, 1)

			def FindLastOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindLastSubValueInRow(pRow, pSubValue)

	  #---------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A ROW  #
	#---------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInRow( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInRow( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.RowAsPositions(pRow), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		def CountInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def CountInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.NumberOfOccurrencesOfValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		# Raises error R14 today instead of counting the cells in one row that equal a value.
		#
		#   pRow       the row position, 1 for the first
		#   returns    nothing; it raises
		#   warning    Raises R14 because the CS helper it calls is defined nowhere
		#   see        NumberOfOccurrenceInRow
		#>
		# Returns how many cells of one row equal a value.
		def NumberOfOccurrenceOfCellInRow(pRow, pCellValue)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def NumberOfOccurrencesOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		# Returns how many cells of one row equal a value.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a number
		#   see        NumberOfOccurrenceInRow
		#@ aka  --
		def NumberOfOccurrenceOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def NumberOfOccurrencesOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		# Returns how many cells of one row equal a value.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a number
		#   see        NumberOfOccurrenceInRow
		def CountOfValueInRowInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		# Returns how many cells in one row contain a text.
		#
		#   pRow       the row position, 1 for the first
		#   returns    a number
		#   see        NumberOfOccurrenceInRow
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		#>

	  #============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A ROW  #
	#============================================================================#

	def ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInRow(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInRow(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInRowCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowContainsCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		# TRUE if some cell in one row equals the value.
		#
		#   pRow                   the row position, 1 for the first
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                TRUE or FALSE
		#   see                    ContainsSubValueInRow
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsInRow(pRow, pCellValueOrSubValue)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, 1)

			def RowContains(pRow, pCellValueOrSubValue)
				return This.ContainsInRow(pRow, pCellValueOrSubValue)

	def ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def RowContainsCellCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def ContainsValueInRowCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def RowContainsValueCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		# TRUE if some cell in one row equals the value.
		#
		#   pRow       the row position, 1 for the first
		#   returns    TRUE or FALSE
		#   see        ContainsInRow
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsCellInRow(pRow, pCellValue)
			return This.ContainsCellInRowCS(pRow, pCellValue, 1)

			def RowContainsCell(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)

			def ContainsValueInRow(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)
	
	def ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def RowContainsSubValueCS(pRow, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		# TRUE if some cell in one row contains the text.
		#
		#   pRow       the row position, 1 for the first
		#   returns    TRUE or FALSE
		#   see        ContainsInRow
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsSubValueInRow(pRow, pSubValue)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, 1)

			# TRUE if some cell of the row contains the text.
			#
			#   pRow       the row position, 1 for the first
			#   returns    TRUE or FALSE
			#   see        ContainsSubValueInRow
			def RowContainsSubValue(pRow, pSubValue)
				return This.ContainsSubValueInRow(pRow, pSubValue)

	/// WORKING ON A LIST OF ROWS /////////////////////////////////////////////////////////////

	  #=======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#=======================================================================================#

	def FindInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? _o1_.FindInRows( [ 2, 3 ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? _o1_.FindInRowsCS(  [ 1, 3 ], :SubValue = "a", 0 )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [3, 1], [6] ],
			[ [3, 3], [2] ]
		     ]
		*/

		_aCellsPositions_ = This.RowsToCellsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
				
			ok
		ok

		return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue, pCaseSensitive)

	# Returns the positions of the cells in the given rows that equal a value, or that contain a text with [ :SubValue, text ].
	#
	#   panRows                the row positions
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a list of [ column, row ] positions; with :SubValue, [ [ column, row
	#                          ], places ] items
	#   warning                A text found only inside a longer cell is missed without :SubValue
	#   see                    FindFirstInRows, FindNthInRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindInRows(panRows, pCellValueOrSubValue)
		return This.FindInRowsCS(panRows, pCellValueOrSubValue, 1)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN ROWS  #
	#------------------------------------------------------------#

	def FindValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

	# Returns the cells of the given rows that equal a value, as [ column, row ] positions.
	#
	#   panRows    the row positions
	#   returns    a list of [ column, row ] positions
	#   see        FindInRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValueInRows(panRows, pCellValue)
		return This.FindValueInRowsCS(panRows, pCellValue, 1)

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.RowsAsPositions(panRows), pSubValue, pCaseSensitive)

	# Returns the positions of the cells in the given rows that equal the text, not the cells that contain it.
	#
	#   panRows    the row positions
	#   returns    a list of [ column, row ] positions
	#   warning    Forwards to the whole-value finder, so a text found only inside a longer cell
	#              answers [ ]
	#   see        FindInRows
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValueInRows(panRows, pSubValue)
		return This.FindSubValueInRowsCS(panRows, pSubValue, 1)

	  #==========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#==========================================================================================#

	def FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok


		return This.FindNthInCellsCS(_n_, This.RowsAsPositions(panRows), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R14 today instead of finding the nth cell in the given rows that equals a value.
	#
	#   _n_                    the position, or how many, as a number
	#   panRows                the row positions
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R14 because RowsToNames is defined nowhere; FindNthValueInRows
	#                          works
	#   see                    FindNthValueInRows
		#>
	# Returns the nth cell of the given rows equal to a value, or the nth occurrence of a text with [ :SubValue, text ].
	def FindNthInRows(_n_, panRows, pCellValueOrSubValue)
		return This.FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRows(_n_, panRows, pCellValueOrSubValue)
			return This.FindNthInRows(_n_, panRows, pCellValueOrSubValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN ROWS  #
	#------------------------------------------------------#

	def FindNthValueInRowsCS(_n_, panRows, pCellValue, pCaseSensitive)

		if isList(panRows) and
		   IsOneOfTheseNamedParamsList(panRows,[ :Rows, :InRows, :OfRows ])

			panRows = panRows[2]
		ok

		return This.FindNthInCellsCS(_n_, This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRowsCs(_n_, panRows, pCellValue, pCaseSensitive)
			return This.FindNthValueInRowsCS(_n_, panRows, pCellValue, pCaseSensitive)

	# Returns the nth cell in the given rows that equals a value, as a position; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   panRows    the row positions
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindNthInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthValueInRows(_n_, panRows, pCellValue)
		return This.FindNthValueInRowsCS(_n_, panRows, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRows(_n_, panRows, pCellValue)
			return This.FindNthValueInRows(_n_, panRows, pCellValue)

		#>

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindNthSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.RowsAsPositions(panRows), pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceOfSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)

	# Returns the nth cell in the given rows that contains a text, as a position with the place of the text; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   panRows    the row positions
	#   returns    a [ [ column, row ], place of the text ] pair, or [ ]
	#   see        FindNthInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthSubValueInRows(_n_, panRows, pSubValue)
		return This.FindNthSubValueInRowsCS(_n_, panRows, pSubValue, 1)

		#< @FuntionAlternativeForm

		def FindNthOccurrenceOfSubValueInRows(_n_, panRows, pSubValue)
			return This.FindNthSubValueInRows(_n_, panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(1, panRows, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R14 today instead of finding the first cell in the given rows that equals a value.
	#
	#   panRows                the row positions
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R14 because RowsToNames is defined nowhere
	#   see                    FindFirstValueInRows
		#>
	# Returns the first cell of the given rows equal to a value, or the first occurrence of a text with [ :SubValue, text ].
	def FindFirstInRows(panRows, pCellValueOrSubValue)
		return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindFirstInRows(panRows, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindNthValueInRowsCS(1, panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRowsCs(panRows, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in the given rows that equals a value.
	#
	#   panRows    the row positions
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInRows
		#>
	# Returns the first cell of the given rows that equals a value; [ ] when there is none.
	def FindFirstValueInRows(panRows, pCellValue)
		return This.FindFirstValueInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindFirstValueInRows(panRows, pCellValue)

		#>

	  #------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------#

	def FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInRowsCS(1, panRows, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in the given rows that contains a text.
	#
	#   panRows    the row positions
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInRows
		#>
	# Returns the first occurrence of a text inside the cells of the given rows, as [ [ column, row ], place ].
	def FindFirstSubValueInRows(panRows, pSubValue)
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindFirstSubValueInRows(panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(:Last, panRows, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R24 today instead of finding the last cell in the given rows that equals a value.
	#
	#   panRows                the row positions
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R24 (uninitialized variable prow) because the body passes a
	#                          name that is not its parameter
	#   see                    FindFirstInRows
		#>
	# Returns the last cell of the given rows equal to a value, or the last occurrence of a text with [ :SubValue, text ].
	def FindLastInRows(panRows, pCellValueOrSubValue)
		return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindLastInRows(panRows, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF ROWS  #
	#-------------------------------------------------------------#

	def FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindNthValueInRowsCS(:Last, panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in the given rows that equals a value.
	#
	#   panRows    the row positions
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInRows
		#>
	# Returns the last cell of the given rows that equals a value; [ ] when there is none.
	def FindLastValueInRows(panRows, pCellValue)
		return This.FindLastValueInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindLastValueInRows(panRows, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#-----------------------------------------------------------------#

	def FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInRowsCS(:Last, panRows, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in the given rows that contains a text.
	#
	#   panRows    the row positions
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInRows
		#>
	# Returns the last occurrence of a text inside the cells of the given rows, as [ [ column, row ], place ].
	def FindLastSubValueInRows(panRows, pSubValue)
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindLastSubValueInRows(panRows, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.RowsAsPositions(panRows), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

		def CountInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

	# Returns how many cells in the given rows equal a value, case-sensitively.
	#
	#   panRows            the row positions
	#   pValueOrSubValue   the value to look for, or [ :OfSubValue, text ]
	#   returns            a number
	#   see                NumberOfOccurrenceOfSubValueInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
		return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrencesInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		def CountInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		#>

	  #----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF ROWS  #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.NumberOfOccurrencesOfValueInCellsCS( This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		def CountOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

	# Raises error R14 today instead of counting the cells in the given rows that equal a value.
	#
	#   panRows    the row positions
	#   returns    nothing; it raises
	#   warning    Raises R14 because the CS helper it calls is defined nowhere
	#   see        NumberOfOccurrenceInRows
		#>
	# Returns how many cells of the given rows equal a value.
	def NumberOfOccurrenceOfCellInRows(panRows, pCellValue)
		return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def NumberOfOccurrenceOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		#>

	  #--------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowsAsPositions(panRows), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

	# Returns how many cells in the given rows contain a text.
	#
	#   panRows    the row positions
	#   returns    a number
	#   see        NumberOfOccurrenceInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		def CountOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		#>

	  #===========================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF ROWS  #
	#===========================================================================================#

	def ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		if isList(panRows) and
		   IsOneOfTheseNamedParamsList(panRows,[ :Rows, :InRows, :OfRows ])
			pRow = pRow[2]
		ok

		_aRowPos_ = This.RowsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aRowPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aRowPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(_aRowPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowsContainCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

	# TRUE if some cell in the given rows equals the value.
	#
	#   panRows                the row positions
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                TRUE or FALSE
	#   see                    ContainsSubValueInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsInRows(panRows, pCellValueOrSubValue)
		return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForm

		def RowsContain(panRows, pCellValueOrSubValue)
			return This.ContainsInRows(panRows, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF ROWS CONTAIN THE GIVEN CELL  #
	#-----------------------------------------------------------#

	def ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def RowsContainCellCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def ContainsValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def RowsContainValueCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

	# TRUE if some cell in the given rows equals the value.
	#
	#   panRows    the row positions
	#   returns    TRUE or FALSE
	#   see        ContainsInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsCellInRows(panRows, pCellValue)
		return This.ContainsCellInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def RowsContainCell(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def ContainsValueInRows(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def RowsContainValue(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)
	
		#>

	  #-------------------------------------------------------#
	 #  CHECKING IF A LIST OF ROWS CONTAIN A GIVEN SUBVALUE  #
	#-------------------------------------------------------#
	
	def ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForm

		def RowsContainSubValueCS(panRows, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

	# TRUE if some cell in the given rows contains the text.
	#
	#   panRows    the row positions
	#   returns    TRUE or FALSE
	#   see        ContainsInRows
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsSubValueInRows(panRows, pSubValue)
		return This.ContainsSubValueInRowsCS(panRows, pSubValue, 1)

		# TRUE if some cell of the given rows contains the text.
		#
		#   panRows    the row positions
		#   returns    TRUE or FALSE
		#   see        ContainsSubValueInRows
		#< @FunctionAlternativeForm
		def RowsContainSubValue(panRows, pSubValue)
			return This.ContainsSubValueInRows(panRows, pSubValue)
		
		#>

	/// WORKING ON COLUMNS //////////////////////////////////////////////////////////////////////

	  #=========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#=========================================================================================#

		def FindInColumn(pCol, pCellValueOrSubValue)
			return This.FindInCol(pCol, pCellValueOrSubValue)

	  #--------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMN  #
	#--------------------------------------------------------------#

	def FindValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		def FindValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindValueInColCS(pCol, pCellValue, pCaseSensitive)

	# Returns the cells of one column that equal a value, as [ column, row ] positions.
	#
	#   returns    a list of [ column, row ] positions
	#   see        FindInCol
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValueInCol(pCol, pCellValue)
		return This.FindValueInColCS(pCol, pCellValue, 1)

		def FindValueInColumn(pCol, pCellValue)
			return This.FindValueInCol(pCol, pCellValue)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		def FindSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	# Returns the positions of the cells in one column that equal the text, not the cells that contain it.
	#
	#   returns    a list of [ column, row ] positions
	#   warning    Forwards to the whole-value finder, so a text found only inside a longer cell
	#              answers [ ]
	#   see        FindInCol
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValueInCol(pCol, pSubValue)
		return This.FindSubValueInColCS(pCol, pSubValue, 1)

		def FindSubValueInColumn(pCol, pSubValue)
			return This.FindSubValueInCol(pCol, pSubValue)

	  #============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#============================================================================================#

	def FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		pCol = This.ColToName(pCol)

		return This.FindNthInCellsCS(_n_, This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

	# Returns the [ column, row ] position of the nth cell in one column that equals a value; [ ] when there are fewer.
	#
	#   _n_                    the position, or how many, as a number
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindFirstInCol, FindLastInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthInCol(_n_, pCol, pCellValueOrSubValue)
		return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindNthInColumn(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInCol(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInColumn(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMN  #
	#--------------------------------------------------------#

	def FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		if isList(pCol) and IsOneOfTheseNamedParamsList(pCol,[
					:Col, :InCol, :OfCol,
					:Column, :InColumn, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		return This.FindNthInCellsCS(_n_, This.ColAsPositions(pcol), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumCS(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColCs(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnCS(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

	# Returns the nth cell in one column that equals a value, as a position; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindNthInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthValueInCol(_n_, pCol, pCellValue)
		return This.FindNthValueInColCS(_n_, pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValueInColumn(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		def FindNthOccurrenceOfValueInCol(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		def FindNthOccurrenceOfValueInColumn(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

	# Returns the nth cell in one column that contains a text, as a position with the place of the text; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ [ column, row ], place of the text ] pair, or [ ]
	#   see        FindNthInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthSubValueInCol(_n_, pCol, pSubValue)
		return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, 1)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColum(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInCol(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInColumn(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(1, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

	# Returns the [ column, row ] position of the first cell in one column that equals a value; [ ] when there is none.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindLastInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindFirstInCol(pCol, pCellValueOrSubValue)
		return This.FindFirstInColCS(pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A COLUMN  #
	#--------------------------------------------------#

	def FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindNthValueInColCS(1, pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in one column that equals a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInCol
		#>
	# Returns the first cell of one column that equals a value; [ ] when there is none.
	def FindFirstValueInCol(pCol, pCellValue)
		return This.FindFirstValueInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A COLUMN  #
	#------------------------------------------------------#

	def FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInColCS(1, pCol, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in one column that contains a text.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInCol
		#>
	# Returns the first occurrence of a text inside the cells of one column, as [ [ column, row ], place ].
	def FindFirstSubValueInCol(pCol, pSubValue)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

	# Returns the [ column, row ] position of the last cell in one column that equals a value; [ ] when there is none.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a [ column, row ] pair, or [ ]
	#   see                    FindFirstInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindLastInCol(pCol, pCellValueOrSubValue)
		return This.FindLastInColCS(pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindLastInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		#>

	  #---------------------------------#
	 #  FINDING LAST CELL IN A COLUMN  #
	#---------------------------------#

	def FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindNthValueInColCS(:Last, pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in one column that equals a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInCol
		#>
	# Returns the last cell of one column that equals a value; [ ] when there is none.
	def FindLastValueInCol(pCol, pCellValue)
		return This.FindLastValueInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindLastValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		#>

	  #-------------------------------------#
	 #  FINDING LAST SUBVALUE IN A COLUMN  #
	#-------------------------------------#

	def FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInColCS(:Last, pCol, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in one column that contains a text.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInCol
		#>
	# Returns the last occurrence of a text inside the cells of one column, as [ [ column, row ], place ].
	def FindLastSubValueInCol(pCol, pSubValue)
		return This.FindLastSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		#>

	  #------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A COLUMN  #
	#------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInCol( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInCol( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		def CountInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def CountInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		#--

		def HowManyOccurrenceInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrenceInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A COLUMN  #
	#----------------------------------------------#

	def NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, pCaseSensitive)
		return This.NumberOfOccurrencesOfValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValueInColumCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#==

		def HowManyValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

	# Raises error R14 today instead of counting the cells in one column that equal a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R14 because the CS helper it calls is defined nowhere
	#   see        NumberOfOccurrenceInCol
		#>
	# Returns how many cells of one column equal a value.
	def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
		return This.NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountValueInColum(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#==

		def HowManyValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#--

		def HowManyOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#>

	  #--------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN COLUMN  #
	#--------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	# Returns how many cells in one column contain a text.
	#
	#   returns    a number
	#   see        NumberOfOccurrenceInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def CountOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def CountOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#==

		def HowManySubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#--

		def HowManyOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#>

	  #===============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A COLUMN  #
	#===============================================================================#

	def ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInCol(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInCol(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInColCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		if isList(pCol) and IsOneOfTheseNamedParamsList(pCol,[
					:Col, :Column, :InCol, :InColumn, :OfCol, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		if isString(pCol)

			if StzFindFirst(pCol, [ :First, :FirstCol, :FirstColumn ]) > 0
				pCol = 1

			but StzFindFirst(pCol, [ :Last, :LastCol, :LastColumn ]) > 0
				pCol = This.NumberOfCols()
		
			else
				StzRaise("Incorrect param type! pCol must be a number.")
			ok
		ok

		_aCellsPos_ = This.ColAsPositions(pCol)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok

		ok

		return This.ContainsValueInCellsCS(_aCellsPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColumnContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

	# TRUE if some cell in one column equals the value.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                TRUE or FALSE
	#   warning                Takes the column as a number: a column name raises an error
	#   see                    ContainsSubValueInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsInCol(pCol, pCellValueOrSubValue)
		return This.ContainsInColCS(pCol, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def ContainsInColumn(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColumnContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------#
	 #  CHECKING IF A GIVEN COLUMN CONTAINS A GIVEN CELL  #
	#----------------------------------------------------#

	def ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ContainsValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

		def ContainsCellInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ContainsValueInCol(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ContainsValueInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#>

	  #--------------------------------------------------#
	 #  CHECKING IF A COLUMN CONTAINS A GIVEN SUBVALUE  #
	#--------------------------------------------------#
	
	def ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColumnContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	# TRUE if some cell in one column contains the text.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsInCol
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsSubValueInCol(pCol, pSubValue)
		return This.ContainsSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumn(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		# TRUE if some cell of the column contains the text.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsSubValueInCol
		def ColumnContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		#>

	/// WORKING ON A LIST OF COLUMNS /////////////////////////////////////////////////////////////

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#==========================================================================================#

	def FindInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? _o1_.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? _o1_.FindInColsCS(  [ :FIRSTNAME, :LASTNAME ], :SubValue = "a", 0 )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		_bValue_ = 1
		_bSubValue_ = 0

		_aCellsPositions_ = This.ColsToCellsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			ok
		ok

		return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue, pCaseSensitive)

	# Returns the positions of the cells in the given columns that equal a value, or that contain a text with [ :SubValue, text ].
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                a list of [ column, row ] positions; with :SubValue, [ [ column, row
	#                          ], places ] items
	#   warning                A text found only inside a longer cell is missed without :SubValue
	#   see                    FindFirstInCols, FindNthInCols
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindInCols(paCols, pCellValueOrSubValue)
		return This.FindInColsCS(paCols, pCellValueOrSubValue, 1)

		def FindInColumns(paCols, pCellValueOrSubValue)
			return This.FindInCols(paCols, pCellValueOrSubValue)

	  #---------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------------#

	def FindValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		def FindValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindValueInColsCS(paCols, pCellValue, pCaseSensitive)

	# Returns the cells of the given columns that equal a value, as [ column, row ] positions.
	#
	#   returns    a list of [ column, row ] positions
	#   see        FindInCols
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValueInCols(paCols, pCellValue)
		return This.FindValueInColsCS(paCols, pCellValue, 1)

		def FindValueInColumns(paCols, pCellValue)
			return This.FindValueInCols(paCols, pCellValue)

	  #-------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMNS  #
	#-------------------------------------------------------------#

	def FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.ColsAsPositions(paCols), pSubValue, pCaseSensitive)

		def FindSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	# Returns the positions of the cells in the given columns that equal the text, not the cells that contain it.
	#
	#   returns    a list of [ column, row ] positions
	#   warning    Forwards to the whole-value finder, so a text found only inside a longer cell
	#              answers [ ]
	#   see        FindInCols
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubValueInCols(paCols, pSubValue)
		return This.FindSubValueInColsCS(paCols, pSubValue, 1)

		def FindSubValueInColumns(paCols, pSubValue)
			return This.FindSubValueInCols(paCols, pSubValue)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#=============================================================================================#

	def FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok


		return This.FindNthInCellsCS(_n_, This.ColsAsPositions(paCols), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R14 today instead of finding the nth cell in the given columns that equals a value.
	#
	#   _n_                    the position, or how many, as a number
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R14 because ColsToNames is defined nowhere; FindNthValueInCols
	#                          works
	#   see                    FindNthValueInCols
		#>
	# Returns the nth cell of the given columns equal to a value, or the nth occurrence of a text with [ :SubValue, text ].
	def FindNthInCols(_n_, paCols, pCellValueOrSubValue)
		return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindNthInColumns(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInCols(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInColumns(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		#>

	  #---------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------#

	def FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		if isList(paCols) and IsOneOfTheseNamedParamsList(paCols,[
					:Cols, :InCols, :OfCols,
					:Columns, :InColumns, :OfColumns
				    ])

			paCols = paCols[2]
		ok

		return This.FindNthInCellsCS(_n_, This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumsCS(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColsCs(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnsCS(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

	# Returns the nth cell in the given columns that equals a value, as a position; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ column, row ] pair, or [ ]
	#   see        FindNthInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthValueInCols(_n_, paCols, pCellValue)
		return This.FindNthValueInColsCS(_n_, paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValueInColumns(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		def FindNthOccurrenceOfValueInCols(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		def FindNthOccurrenceOfValueInColumns(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.ColsAsPositions(paCols), pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

	# Returns the nth cell in the given columns that contains a text, as a position with the place of the text; [ ] when there are fewer.
	#
	#   _n_        the position, or how many, as a number
	#   returns    a [ [ column, row ], place of the text ] pair, or [ ]
	#   see        FindNthInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthSubValueInCols(_n_, paCols, pSubValue)
		return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, 1)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColums(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInCols(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInColumns(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMN  #
	#------------------------------------------------------------------------------------------#

	def FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(1, paCols, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R14 today instead of finding the first cell in the given columns that equals a value.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R14 because ColsToNames is defined nowhere
	#   see                    FindFirstValueInCols
		#>
	# Returns the first cell of the given columns equal to a value, or the first occurrence of a text with [ :SubValue, text ].
	def FindFirstInCols(paCols, pCellValueOrSubValue)
		return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindNthValueInColsCS(1, paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in the given columns that equals a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInCols
		#>
	# Returns the first cell of the given columns that equals a value; [ ] when there is none.
	def FindFirstValueInCols(paCols, pCellValue)
		return This.FindFirstValueInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------#

	def FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInColsCS(1, paCols, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the first cell in the given columns that contains a text.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindFirstInCols
		#>
	# Returns the first occurrence of a text inside the cells of the given columns, as [ [ column, row ], place ].
	def FindFirstSubValueInCols(paCols, pSubValue)
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMNS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(:Last, paCols, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

	# Raises error R24 today instead of finding the last cell in the given columns that equals a value.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                nothing; it raises
	#   warning                Raises R24 (uninitialized variable pcol) because the body passes a
	#                          name that is not its parameter
	#   see                    FindFirstInCols
		#>
	# Returns the last cell of the given columns equal to a value, or the last occurrence of a text with [ :SubValue, text ].
	def FindLastInCols(paCols, pCellValueOrSubValue)
		return This.FindLastInColsCS(paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindLastInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF COLUMNS  #
	#----------------------------------------------------------------#

	def FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindNthValueInColsCS(:Last, paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in the given columns that equals a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInCols
		#>
	# Returns the last cell of the given columns that equals a value; [ ] when there is none.
	def FindLastValueInCols(paCols, pCellValue)
		return This.FindLastValueInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindLastValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#--------------------------------------------------------------------#

	def FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInColsCS(:Last, paCols, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	# Raises error R4 today instead of finding the last cell in the given columns that contains a text.
	#
	#   returns    nothing; it raises
	#   warning    Raises R4 (stack overflow) because the CS form calls itself without end
	#   see        FindLastInCols
		#>
	# Returns the last occurrence of a text inside the cells of the given columns, as [ [ column, row ], place ].
	def FindLastSubValueInCols(paCols, pSubValue)
		return This.FindLastSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.ColsAsPositions(paCols), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCoslCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def NumberOfOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def CountInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def CountInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#--

		def HowManyOccurrenceInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#>

	  #-------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF COLUMNS  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.NumberOfOccurrencesOfValueInCellsCS( This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountValueInColumsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#==

		def HowManyValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

	# Raises error R14 today instead of counting the cells in the given columns that equal a value.
	#
	#   returns    nothing; it raises
	#   warning    Raises R14 because the CS helper it calls is defined nowhere
	#   see        NumberOfOccurrenceInCols
		#>
	# Returns how many cells of the given columns equal a value.
	def NumberOfOccurrenceOfCellInCols(paCols, pCellValue)
		return This.NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountValueInColums(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#==

		def HowManyValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#--

		def HowManyOccurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColsAsPositions(paCols), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	# Returns how many cells in the given columns contain a text.
	#
	#   returns    a number
	#   see        NumberOfOccurrenceInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		
		#--
	
		def CountOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def CountOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#==

		def HowManySubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#--

		def HowManyOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#>

	  #==============================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#==============================================================================================#

	def ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		if isList(paCols) and IsOneOfTheseNamedParamsList(paCols,[
					:Cols, :Columns, :InCols, :InColumns, :OfCols, :OfColumns
				    ])

			pCol = pCol[2]
		ok

		_aColPos_ = This.ColsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aColPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aColPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(_aColPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColumnsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

	# TRUE if some cell in the given columns equals the value.
	#
	#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside the
	#                          cells
	#   returns                TRUE or FALSE
	#   see                    ContainsSubValueInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsInCols(paCols, pCellValueOrSubValue)
		return This.ContainsInColsCS(paCols, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def ContainsInColumns(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColumnsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF COLUMNS CONTAIN THE GIVEN CELL  #
	#--------------------------------------------------------------#

	def ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ContainsValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainsValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

	# TRUE if some cell in the given columns equals the value.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsCellInCols(paCols, pCellValue)
		return This.ContainsCellInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsCellInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ContainsValueInCols(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ContainsValueInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#>

	  #----------------------------------------------------------#
	 #  CHECKING IF A LIST OF COLUMNS CONTAIN A GIVEN SUBVALUE  #
	#----------------------------------------------------------#
	
	def ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColumnsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	# TRUE if some cell in the given columns contains the text.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsInCols
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ContainsSubValueInCols(paCols, pSubValue)
		return This.ContainsSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumns(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		# TRUE if some cell of the given columns contains the text.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsSubValueInCols
		def ColumnsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		#>

	/// WORKING ON SECTIONS //////////////////////////////////////////////////////////////////////
	#TODO // Working on SELECTIONS

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#==========================================================================================#

	def FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? _o1_.FindInSection(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? _o1_.FindInSection(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? _o1_.FindInSection( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)
			ok
		ok

		return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		# Returns the positions of the cells between two [ column, row ] corners that equal a value, or that contain a text with [ :SubValue, text ].
		#
		#   paSection1             the first corner of the section, as [ column, row ]
		#   paSection2             the opposite corner of the section, as [ column, row ]
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a list of [ column, row ] positions; with :SubValue, [ [ column,
		#                          row ], places ] items
		#   warning                A text found only inside a longer cell is missed without
		#                          :SubValue; a section is read column by column, so reversed
		#                          corners give [ ]
		#   see                    FindFirstInSection, FindNthInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)

	def FindValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		# Returns the cells of the block between two [ column, row ] corners that equal a value, as [ column, row ] positions.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a list of [ column, row ] positions
		#   see          FindInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindValueInSection(paSection1, paSection2, pCellValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pCellValue, 1)

	def FindSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		# Returns the positions of the cells between two [ column, row ] corners that equal the text, not the cells that contain it.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a list of [ column, row ] positions
		#   warning      Forwards to the whole-value finder, so a text found only inside a longer
		#                cell answers [ ]
		#   see          FindInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#=============================================================================================#

	def FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :N, :Nth, :Occurrence ])
			_n_ = _n_[2]
		ok

		return This.FindNthInCellsCS(_n_, This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the nth cell between two [ column, row ] corners that equals a value; [ ] when there are fewer.
		#
		#   _n_                    the position, or how many, as a number
		#   paSection1             the first corner of the section, as [ column, row ]
		#   paSection2             the opposite corner of the section, as [ column, row ]
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindFirstInSection, FindLastInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
			return This.FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
				return This.FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)

	def FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		# Returns the nth cell of the block between two [ column, row ] corners that equals a value; [ ] when there are fewer.
		#
		#   _n_          the position, or how many, as a number
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindNthInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)
			return This.FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, 1)

			def FindNthOccurrenceOfValueInSection(_n_, paSection1, paSection2, pCellValue)
				return This.FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)

	def FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)

		# Returns the nth occurrence of a text inside the cells of the block between two [ column, row ] corners, as [ [ column, row ], place ].
		#
		#   _n_          the position, or how many, as a number
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ [ column, row ], place ] pair, or [ ]
		#   see          FindNthInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindNthSubValueInSection(_n_, paSection1, paSection2, pSubValue)
			return This.FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, 1)

			def FindNthOccurrenceOfSubValueInSection(_n_, paSection1, paSection2, pSubValue)
				return This.FindNthSubValueInSection(_n_, paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(1, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the first cell between two [ column, row ] corners that equals a value; [ ] when there is none.
		#
		#   paSection1             the first corner of the section, as [ column, row ]
		#   paSection2             the opposite corner of the section, as [ column, row ]
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindLastInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInSectionCS(1, paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		# Returns the first cell of the block between two [ column, row ] corners that equals a value; [ ] when there is none.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindFirstInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstValueInSection(paSection1, paSection2, pCellValue)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindFirstOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindFirstValueInSection(paSection1, paSection2, pCellValue)

	def FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInSectionCS(1, paSection1, paSection2, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		# Returns the first occurrence of a text inside the cells of the block between two [ column, row ] corners, as [ [ column, row ], place ].
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ [ column, row ], place ] pair, or [ ]
		#   see          FindFirstInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindFirstSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def FindFirstOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindFirstSubValueInSection(paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(:Last, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		# Returns the [ column, row ] position of the last cell between two [ column, row ] corners that equals a value; [ ] when there is none.
		#
		#   paSection1             the first corner of the section, as [ column, row ]
		#   paSection2             the opposite corner of the section, as [ column, row ]
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                a [ column, row ] pair, or [ ]
		#   see                    FindFirstInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInSectionCS(:Last, paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		# Returns the last cell of the block between two [ column, row ] corners that equals a value; [ ] when there is none.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ column, row ] pair, or [ ]
		#   see          FindLastInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastValueInSection(paSection1, paSection2, pCellValue)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindLastOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindLastValueInSection(paSection1, paSection2, pCellValue)

	def FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInSectionCS(:Last, paSection1, paSection2, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		# Returns the last occurrence of a text inside the cells of the block between two [ column, row ] corners, as [ [ column, row ], place ].
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a [ [ column, row ], place ] pair, or [ ]
		#   see          FindLastInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def FindLastSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def FindLastOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindLastSubValueInSection(paSection1, paSection2, pSubValue)

	  #-------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A SECTION  #
	#-------------------------------------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInSection( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInSection( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.SectionAsPositions(paSection1, paSection2), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		# Returns how many cells between two [ column, row ] corners equal a value, case-sensitively.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a number
		#   see          NumberOfOccurrenceOfSubValueInSection
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def NumberOfOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def CountInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.NumberOfOccurrencesOfValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#==

		def HowManyCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		# Raises error R14 today instead of counting the cells between two [ column, row ] corners that equal a value.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      nothing; it raises
		#   warning      Raises R14 because the CS helper it calls is defined nowhere
		#   see          NumberOfOccurrenceInSection
		#>
		# Returns how many cells of the block between two [ column, row ] corners equal a value.
		def NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pCellValue)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def NumberOfOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		# Returns how many cells of the block between two [ column, row ] corners equal a value.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a number
		#   see          NumberOfOccurrenceInSection
		#@ aka  --
		def NumberOfOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def NumberOfOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		# Returns how many cells of the block between two [ column, row ] corners equal a value.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a number
		#   see          NumberOfOccurrenceInSection
		def CountOfValueInSectionInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#==

		def HowManyCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		# Returns how many cells between two [ column, row ] corners contain a text.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      a number
		#   see          NumberOfOccurrenceInSection
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		#>

	  #================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A SECTION  #
	#================================================================================#

	def ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInSection(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInSection(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInSectionCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def SectionContainsCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		# TRUE if some cell between two [ column, row ] corners equals the value.
		#
		#   paSection1             the first corner of the section, as [ column, row ]
		#   paSection2             the opposite corner of the section, as [ column, row ]
		#   pCellValueOrSubValue   the cell value to look for, or [ :SubValue, text ] to look inside
		#                          the cells
		#   returns                TRUE or FALSE
		#   see                    ContainsSubValueInSection
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)

			def SectionContains(paSection1, paSection2, pCellValueOrSubValue)
				return This.ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)

	def ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def SectionContainsCellCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def ContainsValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def SectionContainsValueCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		# TRUE if some cell between two [ column, row ] corners equals the value.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      TRUE or FALSE
		#   see          ContainsInSection
		#>
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsCellInSection(paSection1, paSection2, pCellValue)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, 1)

			def SectionContainsCell(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)

			def ContainsValueInSection(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)
	
	def ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def SectionContainsSubValueCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		# TRUE if some cell between two [ column, row ] corners contains the text.
		#
		#   paSection1   the first corner of the section, as [ column, row ]
		#   paSection2   the opposite corner of the section, as [ column, row ]
		#   returns      TRUE or FALSE
		#   see          ContainsInSection
		#@ aka  -- WITHOUT CASESENSITIVITY
		def ContainsSubValueInSection(paSection1, paSection2, pSubValue)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def SectionContainsSubValue(paSection1, paSection2, pSubValue)
				return This.ContainsSubValueInSection(paSection1, paSection2, pSubValue)


	# Sorts the rows in place, in ascending order of the first column.
	#
	#   returns    nothing; the table changes
	#   see        SortOn, SortDown
	def Sort()
		This.SortOn(1)

		#< @FunctionFluentForm

		def SortQ()
			This.Sort()
			return This

		# Sorts the rows in place, in ascending order of the first column.
		#
		#   returns    nothing; the table changes
		#   see        SortOn, SortDown
		#>
		#< @FunctionAlternativeForms
		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		# Sorts the rows in place, in ascending order of the first column.
		#
		#   returns    nothing; the table changes
		#   see        SortOn, SortDown
		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

		#>

	  #-----------------------------------#
	 #  SORTING THE TABLE IN DESCENDING  #
	#-----------------------------------#

	# Sorts the rows in place, in descending order of the first column.
	#
	#   returns    nothing; the table changes
	#   see        SortDownOn, Sort
	def SortDown()
		This.SortDownOn(1)

		#< @FunctionFluentForm

		def SortDownQ()
			This.SortDown()
			return This

		# Sorts the rows in place, in descending order of the first column.
		#
		#   returns    nothing; the table changes
		#   see        SortDownOn, Sort
		#>
		#< @FunctionAlternativeForm
		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

	# Returns the table content sorted in descending order of the first column; the table itself is unchanged.
	#
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortDown, SortedOn
		#>
	def SortedDown()
		_aResult_ = This.Copy().SortDownQ().Content()
		return _aResult_

		def SortedInDescending()
			return This.SortedDown()

	  #----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN ASCENDiNG  #
	#====================================================#

	# Sorts the rows in place, in ascending order of one column.
	#
	#   pCol       the column to sort on, by name or position
	#   returns    nothing; the table changes
	#   see        SortDownOn, SortedOn
	#TODO
	#@ aka  Check performance on large tables
	def SortOn(pCol)
		_nCol_ = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, _nCol_-1, 1)
		This._SyncFromEngine()

		#< @FunctionFluentForm

		def SortOnQ(pCol)
			This.SortOn(pCol)
			return This

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		#>
		#< @FunctionAlternativeForms
		def SortUpOn(pCol)
			This.SortOn(pCol)

			def SortUpOnQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortOnInAscending(pCol)
			This.SortOn(pCol)

			def SortOnInAscendingQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortOnCol(pCol)
			This.SortOn(pCol)

			def SortOnColQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortColUpOn(pCol)
			This.SortOn(pCol)

			def SortColUpOnQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortInAscendingOnCol(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortOnColumn(pCol)
			This.SortOn(pCol)

			def SortOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortUpOnColumn(pCol)
			This.SortOn(pCol)

			def SortUpOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		# Sorts the rows in place, in ascending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortDownOn, SortedOn
		def SortInAscendingOnColumn(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColumnQ(pCol)
				return This.SortOnQ(pCol)

	# Returns the table content sorted in ascending order of one column; the table itself is unchanged.
	#
	#   pCol       the column to sort on, by name or position
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortOn
		#>
	def SortedOn(pCol)
		_aResult_ = This.Copy().SortOnQ(pCol).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedUpOn(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOn(pCol)
			return This.SortedOn(pCol)

		def SortedOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedUpOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedOnColumn(pCol)
			return This.SortedOn(pCol)

		def SortedUpOnColumn(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOnColumn(pCol)
			return This.SortedOn(pCol)

		#>

	  #-----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN DESCENDiNG  #
	#=====================================================#

	# Sorts the rows in place, in descending order of one column.
	#
	#   pCol       the column to sort on, by name or position
	#   returns    nothing; the table changes
	#   see        SortOn
	def SortDownOn(pCol)
		_nCol_ = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, _nCol_-1, 0)
		This._SyncFromEngine()

		#< @FunctionFluentForm


		def SortDownOnQ(pCol)
			This.SortDownOn(pCol)
			return This

		# Reorders the columns instead of sorting the rows today, by handing the call to the inherited list sort.
		#
		#   pCol       the column to sort on
		#   returns    nothing; the columns are reordered
		#   warning    Hands the call to SortOnDown, which is not a table method: the inherited list
		#              method sorts the [ name, cells ] column pairs on their nth item and leaves
		#              the rows alone, and a column name raises an error; SortDownOn works
		#   see        SortDownOn
		#>
		#< @FunctionAlternativeForms
		def SortInDescendingOn(pCol)
			This.SortOnDown(pCol)

			def SortInDescendingOnQ(pCol)
				return This.SortDownOnQ(pCol)

		# Sorts the rows in place, in descending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortOn
		def SortColDownOn(pCol)
			This.SortDownOn(pCol)

			def SortColDownOnQ(pCol)
				return This.SortDownOnQ(pCol)

		# Sorts the rows in place, in descending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortOn
		def SortInDescendingOnCol(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColQ(pCol)
				return This.SortDownOnQ(pCol)

		# Sorts the rows in place, in descending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortOn
		def SortDownOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortDownOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

		# Sorts the rows in place, in descending order of one column.
		#
		#   pCol       the column to sort on, by name or position
		#   returns    nothing; the table changes
		#   see        SortOn
		def SortInDescendingOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

	# Raises error R19 today instead of returning the content sorted in descending order of one column.
	#
	#   pCol       the column to sort on
	#   returns    nothing; it raises
	#   warning    Raises R19 because the body calls SortDownOnQ without the column; SortedOn works
	#              for ascending order
	#   see        SortDownOn
		#>
	def SortedDownOn(pCol)
		_aResult_ = This.Copy().SortDownOnQ().Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedInDescendingOn(pCol)
			return This.SortedDown(pcol)

		def SortedColDownOn(pCol)
			return This.SortedDown(pcol)

		def SortedInDescendingOnCol(pCol)
			return This.SortedDown(pcol)

		def SortedDownOnColumn(pCol)
			return This.SortedDown(pcol)

		def SortedInDescendingOnColumn(pCol)
			return This.SortedDown(pcol)

		#>

	  #========================================================#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN ASCENDING  #
	#========================================================#

	# Sorts the rows in place, in ascending order of an expression applied to the first column.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; the table changes
	#   see        SortOnBy, SortDownBy
	def SortBy(pcExpr)

		This.SortOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		# Sorts the rows in place, in ascending order of an expression applied to the first column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortOnBy, SortDownBy
		#>
		#< @FunctionAlternativeForms
		def SortUpBy(pcExpr)
			This.SortBy(pcExpr)

			def SortUpByQ(pcExpr)
				return This.SortByQ(pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to the first column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortOnBy, SortDownBy
		def SortInAscendingBy(pcExpr)
			This.SortBy(pcExpr)

			def SortInAscendingByQ(pcExpr)
				return This.SortByQ(pcExpr)

	# Returns the table content sorted in ascending order of an expression on the first column; the table is unchanged.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortBy
		#>
	def SortedBy(pcExpr)
		_aResult_ = This.Copy().SortByQ(pcExpr).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedUpBy(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedInAscendingBy(pcExpr)
			return This.SortedBy(pcExpr)

		#>

	  #---------------------------------------------------------#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN DESCENDING  #
	#---------------------------------------------------------#

	# Sorts the rows in place, in descending order of an expression applied to the first column.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; the table changes
	#   see        SortDownOnBy, SortBy
	def SortDownBy(pcExpr)
		This.SortDownOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortDownByQ(pcExpr)
			This.SortDownBy(pcExpr)
			return This

		# Sorts the rows in place, in descending order of an expression applied to the first column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortBy
		#>
		#< @FunctionAlternativeForm
		def SortInDescendingBy(pcExpr)
			This.SortDownBy(pcExpr)

			def SortInDescendingByQ(pcExpr)
				return This.SortDownByQ(pcExpr)

	# Returns the table content sorted in descending order of an expression on the first column; the table is unchanged.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortDownBy
		#>
	def SortedDownBy(pcExpr)
		_aResult_ = This.Copy().SortDownByQ(pcExpr).Content()
		return _aResult_

		#< @FunctionAlternativeForm

		def SortedBInDescendingy(pcExpr)
			return This.SortedDownBy(pcExpr)

		#>

	  #--------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN ASCENDiNG  #
	#==========================================================================#

	# Sorts the rows in place, in ascending order of an expression applied to one column.
	#
	#   pCol       the column to sort on, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; the table changes
	#   note       The expression may also write @cell for @item
	#   see        SortDownOnBy, SortedOnBy
	def SortOnBy(pCol, pcExpr)

		_nCol_ = This.ColToColNumber(pCol)
		_oLoL_ = new stzListOfLists( This.Rows() )
		pcExpr = StzReplace(StzReplace(pcExpr, "@cell", "@item"), "@CELL", "@item")

		_oLoL_.SortOnBy(_nCol_, pcExpr)

		_aRowsSorted_ = _oLoL_.Content()
		_nLenRows_ = len(_aRowsSorted_)

		for i = 1 to _nLenRows_
			This.ReplaceRow(i, _aRowsSorted_[i])
		next

		#< @FunctionFluentForm

		def SortOnByQ(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)
			return This

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		#>
		#< @FunctionAlternativeForms
		def SortOnByUp(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnByUpQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortInAscendingOnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortUpOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortInAscendingOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortUpOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in ascending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortDownOnBy, SortedOnBy
		def SortInAscendingOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColumnByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

	# Returns the table content sorted in ascending order of an expression on one column; the table is unchanged.
	#
	#   pCol       the column to sort on, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortOnBy
		#>
	def SortedOnBy(pCol, pcExpr)
		_aResult_ = This.Copy().SortOnByQ(pCol, pcExpr).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedUpOnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedUpOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedUpOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		#>

	  #---------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN DESCENDiNG  #
	#===========================================================================#

	# Sorts the rows in place, in descending order of an expression applied to one column.
	#
	#   pCol       the column to sort on, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; the table changes
	#   see        SortOnBy
	def SortDownOnBy(pCol, pcExpr)

		_nCol_ = This.ColToColNumber(pCol)

		_oLoL_ = new stzListOfLists( This.Rows() )
		pcExpr = StzReplace(StzReplace(pcExpr, "@cell", "@item"), "@CELL", "@item")
		_oLoL_.SortDownOnBy(_nCol_, pcExpr)

		_aRowsSorted_ = _oLoL_.Content()
		_nLenRows_ = len(_aRowsSorted_)

		for i = 1 to _nLenRows_
			This.ReplaceRow(i, _aRowsSorted_[i])
		next

		#< @FunctionFluentForm

		def SortDownOnByQ(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)
			return This

		# Raises error R24 today instead of sorting the rows in descending order of an expression on a column.
		#
		#   pCol       the column to sort on
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; it raises
		#   warning    Raises R24 (uninitialized variable _ncol_) because the body passes a name
		#              that is not its parameter; SortDownOnBy works
		#   see        SortDownOnBy
		#>
		#< @FunctionAlternativeForms
		def SortInDescendingOnBy(pCol, pcExpr)
			This.SortDownOnBy(_nCol_, pcExpr)

			def SortInDescendingOnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		# Raises error R24 today instead of sorting the rows in descending order of an expression on a column.
		#
		#   _nCol_     the column to sort on
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; it raises
		#   warning    Raises R24 (uninitialized variable pcol) because the parameter is named
		#              _nCol_ while the body passes pCol; SortDownOnBy works
		#   see        SortDownOnBy
		def SortDownOnColBy(_nCol_, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortDownOnColByQ(_nCol_, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in descending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortOnBy
		def SortInDescendingOnColBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in descending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortOnBy
		def SortDownOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortedDownOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		# Sorts the rows in place, in descending order of an expression applied to one column.
		#
		#   pCol       the column to sort on, by name or position
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; the table changes
		#   see        SortOnBy
		def SortInDescendingOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

	# Returns the table content sorted in descending order of an expression on one column; the table is unchanged.
	#
	#   pCol       the column to sort on, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    a list of [ name, cells ] pairs, the sorted table
	#   see        SortDownOnBy
		#>
	def SortedDownOnBy(pCol, pcExpr)
		_aResult_ = This.Copy().SortDownOnByQ(pCol, pcExpr).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedInDescendingOnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		# Raises error R24 today instead of returning the content sorted in descending order of an expression on a column.
		#
		#   _nCol_     the column to sort on
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; it raises
		#   warning    Raises R24 (uninitialized variable pcol) because the parameter is named
		#              _nCol_ while the body passes pCol; SortedDownOnBy works
		#   see        SortedDownOnBy
		def SortedDownOnColBy(_nCol_, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedInDescendingInColBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedDownOnColumnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedInDescendingOnColumnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		#>

	#-----------------------------------#
	#  CHECKING IF THE TABLE IS SORTED  #
	#-----------------------------------#

	# TRUE if the rows are already in ascending order of the first column.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedOn
	def IsSorted()
		return This.IsSortedOn(1)

	# TRUE if the rows are already in ascending order of the first column.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedUpOn
	def IsSortedUp()
		return This.IsSortedUpOn(1)

		# TRUE if the rows are already in ascending order of the first column.
		#
		#   returns    TRUE or FALSE
		#   see        IsSortedUpOn
		def IsSortedInAscending()
			return This.IsSortedUpOn(1)

	# TRUE if the rows are already in descending order of the first column.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedDownOn
	def IsSortedDown()
		return This.IsSortedDownOn(1)

		# TRUE if the rows are already in descending order of the first column.
		#
		#   returns    TRUE or FALSE
		#   see        IsSortedDownOn
		def IsSortedInDescending()
			return This.IsSortedDownOn(1)

	# TRUE if the rows are already in ascending order of one column, comparing the table with its sorted copy.
	#
	#   pCol       the column to test, by name or position
	#   returns    TRUE or FALSE
	#   see        IsSortedDownOn
	def IsSortedOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortOn(pCol)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def IsSortedOnCol(pCol)
			return This.IsSortedOn(pCol)

		def IsSortedOnColumn(pCol)
			return This.IsSortedOn(pCol)

	# TRUE if the rows are already in ascending order of one column, comparing the table with its sorted copy.
	#
	#   pCol       the column to test, by name or position
	#   returns    TRUE or FALSE
	#   see        IsSortedOn
	def IsSortedUpOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOn(pCol)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_


		def IsSortedOnUp(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedUpOnCol(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedUpOnColumn(pCol)
			return THis.IsSortedUpOn(pCol)

		#--

		def IsSortedInAscendingOn(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingUp(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingCol(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingColumn(pCol)
			return THis.IsSortedUpOn(pCol)

	# TRUE if the rows are already in descending order of one column, comparing the table with its sorted copy.
	#
	#   pCol       the column to test, by name or position
	#   returns    TRUE or FALSE
	#   see        IsSortedOn
	def IsSortedDownOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOn(pCol)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_


		def IsSortedDownOnCol(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedDownOnColumn(pCol)
			return THis.IsSortedDownOn(pCol)

		#--

		def IsSortedInDescendingOn(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedUpInDescending(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedInDescendingCol(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedInDescendingOnColumn(pCol)
			return THis.IsSortedDownOn(pCol)

	# Raises error R14 today instead of testing the order given by an expression on the first column.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; it raises
	#   warning    Raises R14 because the body calls IsSotedOnBy, a misspelling; IsSortedOnBy works
	#   see        IsSortedOnBy
	#@ aka  --
	def IsSortedBy(pcExpr)
		return This.IsSotedOnBy(1, pcExpr)

	# Raises error R20 today instead of testing the ascending order given by an expression on the first column.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; it raises
	#   warning    Raises R20 because it passes the expression as an extra argument to IsSortedUpOn
	#   see        IsSortedOnBy
	def IsSortedUpBy(pcExpr)
		return This.IsSortedUpOn(1, pcExpr)

		# Raises error R20 today instead of testing the ascending order given by an expression on the first column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    nothing; it raises
		#   warning    Raises R20 because it passes an extra argument to IsSortedUpBy
		#   see        IsSortedOnBy
		def IsSortedInAscendingBy(pcExpr)
			return This.IsSortedUpBy(1, pcExpr)

	# TRUE if the rows are already in descending order of an expression on the first column.
	#
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    TRUE or FALSE
	#   see        IsSortedDownOnBy
	def IsSortedDownBy(pcExpr)
		return This.IsSortedDownOnBy(1, pcExpr)

		# TRUE if the rows are already in descending order of an expression on the first column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   returns    TRUE or FALSE
		#   see        IsSortedDownOnBy
		def IsSortedInDescendingBy(pcExpr)
			return This.IsSortedDownOnBy(1, pcExpr)

	# TRUE if the rows are already in ascending order of an expression on one column.
	#
	#   pCol       the column to test, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    TRUE or FALSE
	#   see        IsSortedDownOnBy
	def IsSortedOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortOnBy(pCol, pcExpr)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def IsSortedOnColBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedOnColumnBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		# TRUE if the rows are already in ascending order of an expression on one column, the expression coming first.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		#@ aka  --
		def IsSortedByOn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		# TRUE if the rows are already in ascending order of an expression on one column, the expression coming first.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedByOnCol(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		# TRUE if the rows are already in ascending order of an expression on one column, the expression coming first.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedByOnColumn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

	# Raises error R14 today instead of testing the ascending order given by an expression on one column.
	#
	#   pCol       the column to test
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    nothing; it raises
	#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
	#              IsSortedOnBy works
	#   see        IsSortedOnBy
	def IsSortedUpOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOnBy(pCol, pcExpr)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def IsSortedUpOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		#@ aka  --
		def IsSorteUpByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		def IsSortedUpByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		def IsSortedUpByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#==

		def IsSortedInAscendingOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		#@ aka  --
		def IsSorteInAscendingByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		def IsSortedInAscendingByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		# Raises error R14 today instead of testing the ascending order given by an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body relies on SortUpOnBy, which is defined nowhere;
		#              IsSortedOnBy works
		#   see        IsSortedOnBy
		def IsSortedInAscendingByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

	# TRUE if the rows are already in descending order of an expression on one column.
	#
	#   pCol       the column to test, by name or position
	#   pcExpr     the expression to sort by, as text, with @item standing for a cell
	#   returns    TRUE or FALSE
	#   see        IsSortedOnBy
	def IsSortedDownOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOnBy(pCol, pcExpr)

		_bResult_ = 1
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_


		def IsSortedDownOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		#@ aka  --
		def IsSortedDownByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedDownByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedDownByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#==

		def IsSortedInDescendingOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		#@ aka  --
		def IsSortedInDescendingByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedInDescendingByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# TRUE if the rows are already in descending order of an expression on one column.
		#
		#   pcExpr     the expression to sort by, as text, with @item standing for a cell
		#   pCol       the column to test, by name or position
		#   returns    TRUE or FALSE
		#   see        IsSortedOnBy
		def IsSortedInDescendingByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		# Puts a value in one cell, given by its column and row, in place.
		#
		#   pCol            the column of the cell, by name or position
		#   pnRow           the row position, 1 for the first
		#   pNewCellValue   the new value of the cell
		#   returns         nothing; the table changes
		#   warning         Raises R2 for a row past the last one and Column not found! for an
		#                   unknown column
		#   see             ReplaceCell, ReplaceCells
		def ReplaceCellByPosition(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		# Puts a value in one cell, given by its column and row, in place.
		#
		#   pCol            the column of the cell, by name or position
		#   pnRow           the row position, 1 for the first
		#   pNewCellValue   the new value of the cell
		#   returns         nothing; the table changes
		#   warning         Raises R2 for a row past the last one and Column not found! for an
		#                   unknown column
		#   see             ReplaceCell, ReplaceCells
		def ReplaceByPositionCell(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		#>

	  #---------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY THE PROVIDED VALUE  #
	#---------------------------------------------------------------------------#

	# Puts the same value in every listed cell, in place.
	#
	#   paCellsPos       the cells to change, each as [ column, row ]
	#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
	#   returns          nothing; the table changes
	#   warning          Raises Column not found! for a position whose column does not exist and R2
	#                    for a row past the last one
	#   see              ReplaceCellsByMany, ReplaceCell
	def ReplaceCells(paCellsPos, paNewCellValue)

		if ChekParams() #NOTE this is a misspelled form (c in Check is lacking)
			        # But Softanza forgives it (PERMISSIVENESS prinicle of the FLEXIBILITY goal)

			if isList(paNewCellValue) and IsOneOfTheseNamedParamsList(paNewCellValue,[ :By, :With, :Using ])
				paNewCellValue = paNewCellValue[2]
			ok

		ok

		_nCellsPosLen_ = len(paCellsPos)
		for i = 1 to _nCellsPosLen_
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewCellValue)
		next

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		#< @FunctionAlternatives
		def ReplaceTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		#TODO // Add the fellowing semantics to all simular functions in the library
		#@ aka  --
		def ReplaceEachOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		#@ aka  --
		def ReplaceEveryOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		#@ aka  == Adding ...ByPosition(s) to all alternatives
		def ReplaceCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceManyByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceManyByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEachCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryOneOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryOneOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceEveryCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		#@ aka  --
		def ReplaceByPositionCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		# Puts the same value in every listed cell, in place.
		#
		#   paCellsPos       the cells to change, each as [ column, row ]
		#   paNewCellValue   the value put in every listed cell, or [ :With, value ]
		#   returns          nothing; the table changes
		#   see              ReplaceCells, ReplaceCellsByMany
		def ReplaceByPositionsEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES  #
	#-----------------------------------------------------------------------------#

	# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
	#
	#   paCellsPos    the cells to change, each as [ column, row ]
	#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
	#   returns       nothing; the table changes
	#   see           ReplaceCellsByMany, ReplaceCells
	def ReplaceCellsByMany(paCellsPos, paNewValues)

		if CheckingParams()

			if isList(paNewValues) and
			   IsOneOfTheseNamedParamsList(paNewValues,[ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok

			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		_nLenCells_  = len(paCellsPos)
		_nLenValues_ = len(paNewValues)
		_nMin_ = @Min([ _nLenCells_, _nLenValues_ ])

		for i = 1 to _nMin_
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewValues[i])
		next

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		#< @FunctionAlternativeForms
		def ReplaceTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		#@ aka  --
		def ReplaceEachOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		#@ aka  --
		def ReplaceEveryOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		#@ aka  == Adding ...ByPosition(s) to all alternatives
		def ReplaceCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceManyByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceManyByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEachCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the whole list of values in each listed cell, in place, instead of one value per cell.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   warning       Forwards to ReplaceCells, which treats the list of values as one value:
		#                 every listed cell receives the whole list; ReplaceCellsByMany pairs them
		#                 one by one
		#   see           ReplaceCellsByMany
		def ReplaceEachCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryOneOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryOneOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceEveryCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		#@ aka  --
		def ReplaceByPositionCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the whole list of values in each listed cell, in place, instead of one value per cell.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   warning       Forwards to ReplaceCells, which treats the list of values as one value:
		#                 every listed cell receives the whole list; ReplaceCellsByMany pairs them
		#                 one by one
		#   see           ReplaceCellsByMany
		def ReplaceByPositionsEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES, EXTENDED  #
	#---------------------------------------------------------------------------------------#

	def ReplaceCellsByManyXT(paCellsPos, paNewValues)

		if CheckingParams()

			if isList(paNewValues) and
			   IsOneOfTheseNamedParamsList(paNewValues,[ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok

			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		_nLenPos_ = len(paCellsPos)
		_nLenNew_ = len(paNewValues)

		if _nLenNew_ < _nLenPos_
			paNewValues = Q(paNewValues).ExtendXTQ(:To = _nLenPos_, :ByRepeatingItems).Content()

		but _nLenNew_ > _nLenPos_
			This.ExtendTo( QRT(paCellsPos, :stzListOfPairs).Max() )
		ok

		This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#< @FunctionAlternatives

		def ReplaceTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplacePositionsTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplacePositionsManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplacePositionsEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		# Puts the values in the listed cells one by one, in place; surplus positions or values are ignored.
		#
		#   paCellsPos    the cells to change, each as [ column, row ]
		#   paNewValues   the values to put, one per listed cell, or [ :With, list ]
		#   returns       nothing; the table changes
		#   see           ReplaceCellsByMany, ReplaceCells
		def ReplaceByPositionsEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#>

	  #-----------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF A CELL (VALUE) BY THE PROVIDED VALUE  #
	#=================================================================#

	def ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)
		_aPos_ = This.FindCellCS(pCellValue, pCaseSensitive)
		This.ReplaceCellsByPositions(_aPos_, pNewCellValue)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValueCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceByValueOccurrencesOfCellByCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

	# Replaces every cell equal to a value by another value, in place, case-sensitively.
	#
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; the table changes
	#   warning         Raises an error for a number as the value to find, because FindCell does
	#   see             ReplaceCell, FindCell
		#>
	#@ aka  -- WITHOUT CASESENSITIIVTY
	def ReplaceCellByValue(pCellValue, pNewCellValue)
		This.ReplaceCellByValueCS(pCellValue, pNewCellValue, 1)

		# Raises error R24 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCell   the value that takes the place
		#   returns    nothing; it raises
		#   warning    Raises R24 (uninitialized variable pnewcellvalue) because the body passes a
		#              name that is not its parameter; ReplaceCellByValue works
		#   see        ReplaceCellByValue
		#< @FunctionAlternativeForms
		def ReplaceOccurrencesOfCellByValue(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		# Replaces every cell equal to a value by another value, in place, case-sensitively.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; the table changes
		#   warning         Raises an error for a number as the value to find, because FindCell does
		#   see             ReplaceCell, FindCell
		#@ aka  --
		def ReplaceByValueCell(pCellValue, pNewCellValue)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		# Raises error R24 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCell   the value that takes the place
		#   returns    nothing; it raises
		#   warning    Raises R24 (uninitialized variable pnewcellvalue) because the body passes a
		#              name that is not its parameter; ReplaceCellByValue works
		#   see        ReplaceCellByValue
		def ReplaceByValueOccurrencesOfCellBy(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY THE PROVIDED VALUE  #
	#--------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

	# Raises error today instead of replacing the cells equal to any of several values by one value.
	#
	#   paCellsValues   the cell values to replace
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; it raises
	#   warning         Always raises Function not yet implemented!
	#   see             ReplaceCellByValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceManyCellsByValue(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, 1)

		# Raises error today instead of replacing the cells equal to any of several values by one value.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		#< @FunctionAlternativeForms
		def ReplaceCellsByValue(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		# Raises error today instead of replacing the cells equal to any of several values by one value.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		#@ aka  --
		def ReplaceByValueManyCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		# Raises error today instead of replacing the cells equal to any of several values by one value.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		def ReplaceByValueCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES  #
	#--------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

	# Raises error today instead of replacing several cell values by several new values.
	#
	#   paCellsValues   the cell values to replace
	#   pNewCellValue   the new values
	#   returns         nothing; it raises
	#   warning         Always raises Function not yet implemented!
	#   see             ReplaceCellByValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, 1)

		# Raises error today instead of replacing several cell values by several new values.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the new values
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		#< @FunctionAlternativeForms
		def ReplaceCellsByValueByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		# Raises error today instead of replacing several cell values by several new values.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the new values
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		def ReplaceByValueManyCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		# Raises error today instead of replacing several cell values by several new values.
		#
		#   paCellsValues   the cell values to replace
		#   pNewCellValue   the new values
		#   returns         nothing; it raises
		#   warning         Always raises Function not yet implemented!
		#   see             ReplaceCellByValue
		def ReplaceByValueCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES -- XT FORM  #
	#-------------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		#>

	  #=============================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS  #
	#=============================================================#

		# Puts a whole new list of cells in a column, in place.
		#
		#   paCol      the new cells of the column
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked: another length leaves the columns of
		#              unequal size
		#   see        ReplaceCol
		def ReplaceColumn(pCol, paCol)
			This.ReplaceCol(pCol, paCol)

	# Puts a whole new list of cells in the nth column, in place.
	#
	#   _n_        the position, or how many, as a number
	#   paCol      the new cells of the column, or [ :With, cells ]
	#   returns    nothing; the table changes
	#   warning    The length of the list is not checked; a pair [ name, cells ] is read as plain
	#              cells and does not rename the column
	#   see        ReplaceCol
	def ReplaceNthCol(_n_, paCol)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if isList(paCol) and Q(paCol).IsByColOrByColNumberNamedParam()
				paCol = paCol[2]
			ok

			if NOT ( isList(paCol) or isString(paCol) or isNumber(paCol) )
				StzRaise("Incorrect param type! paCol must be a list or a string or number.")
			ok
		ok

		if isString(paCol)
			This.ReplaceColName(_n_, paCol)
			return
		ok

		if isNumber(paCol)
			paCol = This.Col(paCol)
		ok

		_nRows_ = This.NumberOfRows()
		_nLen_ = len(paCol)

		if _nLen_ > _nRows_
			_nLen_ = _nRows_
		ok

		_aCol_ = []
		_aContent_ = @aContent

		for i = 1 to _nRows_
			if i <= _nLen_
				_aCol_ + paCol[i]
			else
				_aCol_ + _aContent_[_n_][2][i]
			ok
		next

		_aContent_[_n_][2] = _aCol_
		This.UpdateWith(_aContent_)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		#< @FunctionAlternativeForms
		def ReplaceNthColumn(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		def ReplaceColN(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		def ReplaceColumnN(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		#@ aka  --
		def ReplaceColAt(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		def ReplaceColAtPosition(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		def ReplaceColumnAt(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		# Puts a whole new list of cells in the nth column, in place.
		#
		#   _n_        the position, or how many, as a number
		#   paCol      the new cells of the column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The length of the list is not checked; a pair [ name, cells ] is read as
		#              plain cells and does not rename the column
		#   see        ReplaceCol
		def ReplaceColumnAtPosition(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		#>

	  #-------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------#
	# ~> XT : If paCol has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColXT(pCol, paCol)
		_nCol_ = This.ColToColNumber(pCol)
		This.ReplaceNthColXT(_nCol_, paCol)

		def ReplaceColumnXT(pCol, paCol)
			This.ReplaceColXT(pCol, paCol)

	def ReplaceNthColXT(_n_, paCol)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if NOT isList(paCol)
				StzRaise("Incorrect param type! paCol must be a list.")
			ok
		ok

		_nRows_ = This.NumberOfRows()
		_nLen_ = len(paCol)

		if _nLen_ > _nRows_
			_nLen_ = _nRows_
		ok

		_aCol_ = []
		_j_ = 0

		for i = 1 to _nRows_
			if i <= _nLen_
				_aCol_ + paCol[i]
			else
				_j_++
				if _j_ > _nLen_
					_j_ = 1
				ok
				_aCol_ + paCol[_j_]
			ok
		next

		_aContent_ = @aContent
		_aContent_[_n_][2] = _aCol_
		This.UpdateWith(_aContent_)

		#< @FunctionAlternativeForms

		def ReplaceNthColumnXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		def ReplaceColNXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		def ReplaceColumnNXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		#--

		def ReplaceColAtXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		def ReplaceColAtPositionXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		def ReplaceColumnAtXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		def ReplaceColumnAtPositionXT(_n_, paCol)
			This.ReplaceNthColXT(_n_, paCol)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------------#

	# Puts the same list of cells in each of the columns at the given positions, in place.
	#
	#   panPos     the positions of the columns to change
	#   paCol      the new cells put in every listed column
	#   returns    nothing; the table changes
	#   see        ReplaceNthCol
	def ReplaceColsAt(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceColAt(_anPosU_[i], paCol)
		next

		# Puts the same list of cells in each of the columns at the given positions, in place.
		#
		#   panPos     the positions of the columns to change
		#   paCol      the new cells put in every listed column
		#   returns    nothing; the table changes
		#   see        ReplaceNthCol
		#< @FunctionAlternativeForms
		def ReplaceColsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		# Puts the same list of cells in each of the columns at the given positions, in place.
		#
		#   panPos     the positions of the columns to change
		#   paCol      the new cells put in every listed column
		#   returns    nothing; the table changes
		#   see        ReplaceNthCol
		def ReplacesNthCols(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		# Puts the same list of cells in each of the columns at the given positions, in place.
		#
		#   panPos     the positions of the columns to change
		#   paCol      the new cells put in every listed column
		#   returns    nothing; the table changes
		#   see        ReplaceNthCol
		def ReplaceColumnsAt(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		# Puts the same list of cells in each of the columns at the given positions, in place.
		#
		#   panPos     the positions of the columns to change
		#   paCol      the new cells put in every listed column
		#   returns    nothing; the table changes
		#   see        ReplaceNthCol
		def ReplaceColumnsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		# Puts the same list of cells in each of the columns at the given positions, in place.
		#
		#   panPos     the positions of the columns to change
		#   paCol      the new cells put in every listed column
		#   returns    nothing; the table changes
		#   see        ReplaceNthCol
		def ReplacesNthColumns(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		#>

	  #----------------------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------------#

	def ReplaceColsAtXT(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceColAtXT(_anPosU_[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColumnsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------------#

	# Puts the same list of cells in each of the given columns, in place.
	#
	#   paNewCol   the new cells put in every listed column, or [ :With, cells ]
	#   returns    nothing; the table changes
	#   see        ReplaceColsAt
	def ReplaceTheseCols(paCols, paNewCol)
		if IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		_anPos_ = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositions(_anPos_, paNewCol)

		# Puts the same list of cells in each of the given columns, in place.
		#
		#   paNewCol   the new cells put in every listed column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   see        ReplaceColsAt
		def ReplaceTheseColumns(paCols, paNewCol)
			This.ReplaceTheseCols(paCols, paNewCol)


	  #-------------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------------#

	def ReplaceTheseColsXT(paCols, paNewCol)
		if IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		_anPos_ = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositionsXT(_anPos_, paNewCol)

		def ReplaceTheseColumnsXT(paCols, paNewCol)
			This.ReplaceTheseColsXT(paCols, paNewCol)

	  #===============================================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS  #
	#===============================================================================#

	# Gives a column a new name and new cells, in place.
	#
	#   pcColName   the new column name, as text
	#   paColData   the new cells of the column
	#   returns     nothing; the table changes
	#   see         ReplaceNthColNamedAndData
	def ReplaceColNameAndData(pCol, pcColName, paColData)
		_nCol_ = This.ColToColNumber(pCol)
		This.ReplaceNthColName(_nCol_, pcColName)
		This.ReplaceNthCol(_nCol_, paColData)

		# Gives a column a new name and new cells, in place.
		#
		#   pcColName   the new column name, as text
		#   paColData   the new cells of the column
		#   returns     nothing; the table changes
		#   see         ReplaceNthColNamedAndData
		#< @FunctionAlternativeForm
		def ReplaceColumnNamedAndData(pCol, pcColName, paColData)
			This.ReplaceColNameAndData(pCol, pcColName, paColData)

	# Gives the nth column a new name and new cells, in place.
	#
	#   _n_         the position, or how many, as a number
	#   pcColName   the new column name, as text, or [ :With, name ]
	#   paColData   the new cells of the column
	#   returns     nothing; the table changes
	#   see         ReplaceNthCol
		#>
	def ReplaceNthColNamedAndData(_n_, pcColName, paColData)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if isList(pcColName) and Q(pcColName).IsWithOrByOrUsingNamedParam()
				pcColName = pcColName[2]
			ok

			if isList(paColData) and Q(paColData).IsAndNamedParam()
				pacolData = paColData[2]
			ok

			if NOT isString(pcColName)
				StzRaise("Incorrect param type! pcColName must be a string.")
			ok

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok
		ok

		_nMin_ = @Min([ len(paColData), This.NumberOfRows() ])
		_aTemp_ = []
		for i = 1 to _nMin_
			_aTemp_ + paColData[i]
		next

		_aContent_ = @aContent
		_aContent_[_n_][1] = pcColName
		_aContent_[_n_][2] = _aTemp_

		This.UpdateWith(_aContent_)


		# Gives the nth column a new name and new cells, in place.
		#
		#   _n_         the position, or how many, as a number
		#   pcColName   the new column name, as text, or [ :With, name ]
		#   paColData   the new cells of the column
		#   returns     nothing; the table changes
		#   see         ReplaceNthCol
		#< @FunctionAlternativeForms
		def ReplaceNthColumnNamedAndData(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndData(_n_, pcColName, paColData)

		# Gives the nth column a new name and new cells, in place.
		#
		#   _n_         the position, or how many, as a number
		#   pcColName   the new column name, as text, or [ :With, name ]
		#   paColData   the new cells of the column
		#   returns     nothing; the table changes
		#   see         ReplaceNthCol
		def ReplaceColNNamedAndData(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndData(_n_, pcColName, paColData)

		# Gives the nth column a new name and new cells, in place.
		#
		#   _n_         the position, or how many, as a number
		#   pcColName   the new column name, as text, or [ :With, name ]
		#   paColData   the new cells of the column
		#   returns     nothing; the table changes
		#   see         ReplaceNthCol
		def ReplaceColumnNNamedAndData(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndData(_n_, pcColName, paColData)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#
	# ~> XT : If paColData has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColNameAndDataXT(pCol, pcColName, paColData)
		_nCol_ = This.ColToColNumber(pCol)
		This.ReplaceNthColName(_nCol_, pcColName)
		This.ReplaceNthColXT(_nCol_, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndDataXT(pCol, pcColName, paColData)
			This.ReplaceColNameAndDataXT(pCol, pcColName, paColData)

		#>

	def ReplaceNthColNamedAndDataXT(_n_, pcColName, paColData)
		This.ReplaceNthColName(_n_, pcColName)
		This.ReplaceNthColXT(_n_, paColData)

		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndDataXT(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(_n_, pcColName, paColData)

		def ReplaceColNNamedAndDataXT(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(_n_, pcColName, paColData)

		def ReplaceColumnNNamedAndDataXT(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(_n_, pcColName, paColData)

		#>

	  #==================================================================#
	 #  REPLACING ALL THE CELLS OF A COLUMN BY THE SAME PROVIDED VALUE  #
	#==================================================================#

	# Sets every cell of one column to the same value, in place.
	#
	#   pCell      the value put in every cell, or [ :With, value ]
	#   returns    nothing; the table changes
	#   see        ReplaceCellsInRow, ReplaceCol
	def ReplaceCellsInCol(pCol, pCell)
		if CheckingParams()
			if isList(pCell) and Q(pCell).IsWithOrByOrUsingNamedParam()
				pCell = pCell[2]
			ok
		ok

		_nCol_ = This.ColToColNumber(pCol)
		_nRows_ = This.NumberOfRows()
		_aContent_ = @aContent

		for i = 1 to _nRows_
			_aContent_[_nCol_][2][i] = pCell
		next

		This.UpdateWith(_aContent_)


		# Sets every cell of one column to the same value, in place.
		#
		#   pCell      the value put in every cell, or [ :With, value ]
		#   returns    nothing; the table changes
		#   see        ReplaceCellsInRow, ReplaceCol
		def ReplaceCellsInColumn(pCol, pCell)
			This.ReplaceCellsInCol(pCol, pCell)

	  #------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#------------------------------------------------------------------------------------------------#
	# Puts the same list of cells in every column, in place.
	#
	#   paNewCol   the new cells put in every column, or [ :With, cells ]
	#   returns    nothing; the table changes
	#   warning    Every column becomes a copy of the list, so the data is lost; a list of [ name,
	#              cells ] pairs is put in each cell as it stands
	#   see        ReplaceTheseCols
	#TODO // check for performance
	def ReplaceAllCols(paNewCol)
		if CheckingParams()

			if isList(paNewCol) and
			   IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok

			if NOT isList(paNewCol)
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			This.ReplaceCol(i, paNewCol)
		next

		# Puts the same list of cells in every column, in place.
		#
		#   paNewCol   the new cells put in every column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    Every column becomes a copy of the list, so the data is lost; a list of [
		#              name, cells ] pairs is put in each cell as it stands
		#   see        ReplaceTheseCols
		#< @FunctionAlternativeForms
		def ReplaceAllColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		# Puts the same list of cells in every column, in place.
		#
		#   paNewCols   the new cells put in every column, or [ :With, cells ]
		#   returns     nothing; the table changes
		#   warning     Every column becomes a copy of the list, so the data is lost; a list of [
		#               name, cells ] pairs is put in each cell as it stands
		#   see         ReplaceTheseCols
		def ReplaceCols(paNewCols)
			This.ReplaceAllCols(paNewCols)

		# Puts the same list of cells in every column, in place.
		#
		#   paNewCol   the new cells put in every column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    Every column becomes a copy of the list, so the data is lost; a list of [
		#              name, cells ] pairs is put in each cell as it stands
		#   see        ReplaceTheseCols
		def ReplaceColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		#>

	  #------------------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#------------------------------------------------------------------------------------------------------------#
	#TODO // check for performance

	def ReplaceAllColsXT(paNewCol)
		if CheckingParams()

			if isList(paNewCol) and
			   IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok

			if NOT isList(paNewCol)
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			This.ReplaceColXT(i, paNewCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceAllColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		def ReplaceColsXT(paNewCols)
			This.ReplaceAllColsXT(paNewCols)

		def ReplaceColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#----------------------------------------------------------------------------------------------#

	# Raises error today instead of replacing several columns by several new column lists.
	#
	#   paNewCols   the new cell lists, one per column
	#   returns     nothing; it raises
	#   warning     Always raises Unsupported feature in this release!
	#   see         ReplaceTheseCols
	def ReplaceAllColsByMany(paCols, paNewCols)
		/* ... */

		StzRaise("Unsupported feature in this release!")

		# Raises error today instead of replacing several columns by several new column lists.
		#
		#   paNewCols   the new cell lists, one per column
		#   returns     nothing; it raises
		#   warning     Always raises Unsupported feature in this release!
		#   see         ReplaceTheseCols
		def ReplaceAllColumsByMany(paCols, paNewCols)
			This.ReplaceAllColsByMany(paCols, paNewCols)

	#TODO : Add ReplaceAllColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #-----------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#-----------------------------------------------------------------------------------#

	# Raises error today instead of replacing several columns by several new column lists.
	#
	#   paNewCols   the new cell lists, one per column
	#   returns     nothing; it raises
	#   warning     Always raises Unsupported feature in this release!
	#   see         ReplaceTheseCols
	def ReplaceTheseColsByMany(paCols, paNewCols)
		if IsOneOfTheseNamedParamsList(paNewCols,[ :With, :By, :Using ])
			paNewCols = paNewCols[2]
		ok

		/* ... */

		StzRaise("Unsupported feature in this release!")

		# Raises error today instead of replacing several columns by several new column lists.
		#
		#   paNewCols   the new cell lists, one per column
		#   returns     nothing; it raises
		#   warning     Always raises Unsupported feature in this release!
		#   see         ReplaceTheseCols
		#< @FunctionAlternativeForms
		def ReplaceTheseColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		# Raises error today instead of replacing several columns by several new column lists.
		#
		#   paNewCols   the new cell lists, one per column
		#   returns     nothing; it raises
		#   warning     Always raises Unsupported feature in this release!
		#   see         ReplaceTheseCols
		def ReplaceColsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		# Raises error today instead of replacing several columns by several new column lists.
		#
		#   paNewCols   the new cell lists, one per column
		#   returns     nothing; it raises
		#   warning     Always raises Unsupported feature in this release!
		#   see         ReplaceTheseCols
		def ReplaceColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		#>

	#TODO // Add ReplaceTheseColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #===================================================================#
	 #  REPLACING THE CELLS OF THE GIVEN ROW BY THE PRIVIDED CELL VALUE  #
	#===================================================================#

	# Sets every cell of one row to the same value, in place.
	#
	#   pnRow      the row position, 1 for the first
	#   pCell      the value put in every cell of the row
	#   returns    nothing; the table changes
	#   see        ReplaceCellsInCol, ReplaceRow
	def ReplaceCellsInRow(pnRow, pCell)
		_aNewRow_ = []
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			_aNewRow_ + pCell
		next

		This.ReplaceRow(pnRow, _aNewRow_)

	  #-----------------------------------------------------------------------------------------#
	 #  REPLACING A ROW (DEFINED BY ITS NUMBER) BY AN OTHER ONE (PROVIDED AS A LIST OF CELLS)  #
	#-----------------------------------------------------------------------------------------#

		# Puts the given cells in the nth row, one per column, in place.
		#
		#   pnRow      the row position, 1 for the first
		#   paNewRow   the new cells of the row, one per column
		#   returns    nothing; the table changes
		#   warning    A list shorter than the number of columns raises R2, and a row past the last
		#              one raises R2
		#   see        ReplaceRow
		def ReplaceNthRow(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		# Puts the given cells in the nth row, one per column, in place.
		#
		#   pnRow      the row position, 1 for the first
		#   paNewRow   the new cells of the row, one per column
		#   returns    nothing; the table changes
		#   warning    A list shorter than the number of columns raises R2, and a row past the last
		#              one raises R2
		#   see        ReplaceRow
		def ReplaceRowN(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		# Puts the given cells in the nth row, one per column, in place.
		#
		#   pnRow      the row position, 1 for the first
		#   paNewRow   the new cells of the row, one per column
		#   returns    nothing; the table changes
		#   warning    A list shorter than the number of columns raises R2, and a row past the last
		#              one raises R2
		#   see        ReplaceRow
		def ReplaceRowAt(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		# Puts the given cells in the nth row, one per column, in place.
		#
		#   pnRow      the row position, 1 for the first
		#   paNewRow   the new cells of the row, one per column
		#   returns    nothing; the table changes
		#   warning    A list shorter than the number of columns raises R2, and a row past the last
		#              one raises R2
		#   see        ReplaceRow
		def ReplaceRowAtPosition(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		#>

	#-- EXTENDED FORM

	def ReplaceRowXT(pnRow, paNewRow)
		_nNew_  = len(paNewRow)
		_nRows_ = This.NumberOfRows()

		_n_ = 0

		if _nNew_ < _nRows_
			for i = _nNew_ + 1 to _nRows_
				_n_++
				if _n_ > _nNew_
					_n_ = 1
				ok

				paNewRow + paNewRow[_n_]
			next

		but _nNew_ > _nRows_
			for i = _nNew_ to _nRows_ + 1 step -1
				ring_remove(paNewRow, i)
			next
		ok

		This.ReplaceRow(pnRow, paNewRow)

		#< @FunctionAlternativeForm

		def ReplaceNthRowXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowNXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtPositionXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#--------------------------------------------------------------------------------#

	# Makes every row a copy of the given cells, in place.
	#
	#   paNewRow   the cells every row receives, one per column, or [ :With, cells ]
	#   returns    nothing; the table changes
	#   warning    The data of all rows is lost
	#   see        ReplaceTheseRows
	def ReplaceAllRows(paNewRow)
		if CheckingParams()
			if isList(paNewRow) and
			   IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
				paNewRow = paNewRow[2]
			ok

			if NOT isList(paNewRow)
				StzRaise("Incorrect param type! paNewRow must be a list.")
			ok
		ok

		_nLenCols_ = @Min([ len(paNewRow), len(@aContent) ])
		_nLenRows_ = This.NumberOfRows()
		_aContent_ = @aContent

		for i = 1 to _nLenCols_
			for _j_ = 1 to _nLenRows_
				_aContent_[i][2][_j_] = paNewRow[i]
			next
		next

		This.UpdateWith(_aContent_)

		# Makes every row a copy of the given cells, in place.
		#
		#   paNewRow   the cells every row receives, one per column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The data of all rows is lost
		#   see        ReplaceTheseRows
		#< @FunctionAlternativeForms
		def ReplaceRows(paNewRow)
			This.ReplaceAllRows(paNewRow)

		# Makes every row a copy of the given cells, in place.
		#
		#   paNewRow   the cells every row receives, one per column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The data of all rows is lost
		#   see        ReplaceTheseRows
		def ReplaceRowsWith(paNewRow)
			This.ReplaceAllRows(paNewRow)

		# Makes every row a copy of the given cells, in place.
		#
		#   paNewRow   the cells every row receives, one per column, or [ :With, cells ]
		#   returns    nothing; the table changes
		#   warning    The data of all rows is lost
		#   see        ReplaceTheseRows
		def ReplaceRowsBy(paNewRow)
			This.ReplaceAllRows(paNewRow)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#--------------------------------------------------------------------------------------------#

	def ReplaceAllRowsXT(paNewRow)
		_nRows_ = This.NumberOfRows()

		for i = 1 to _nRows_
			This.ReplaceRowXT(i, paNewRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		def ReplaceRowsWithXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		def ReplaceRowsByXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		#>

	  #----------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------#

	# Puts the same cells in each of the rows at the given positions, in place.
	#
	#   panPos     the positions of the rows to change
	#   paRow      the cells every listed row receives, one per column
	#   returns    nothing; the table changes
	#   see        ReplaceNthRow
	def ReplaceRowsAt(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceRowAt(_anPosU_[i], paRow)
		next

		# Puts the same cells in each of the rows at the given positions, in place.
		#
		#   panPos     the positions of the rows to change
		#   paRow      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   see        ReplaceNthRow
		#< @FunctionAlternativeForms
		def ReplaceRowsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		# Puts the same cells in each of the rows at the given positions, in place.
		#
		#   panPos     the positions of the rows to change
		#   paRow      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   see        ReplaceNthRow
		def ReplacesNthRows(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		# Puts the same cells in each of the rows at the given positions, in place.
		#
		#   panPos     the positions of the rows to change
		#   paRow      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   see        ReplaceNthRow
		def ReplaceRowumnsAt(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		# Puts the same cells in each of the rows at the given positions, in place.
		#
		#   panPos     the positions of the rows to change
		#   paRow      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   see        ReplaceNthRow
		def ReplaceRowumnsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		# Puts the same cells in each of the rows at the given positions, in place.
		#
		#   panPos     the positions of the rows to change
		#   paRow      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   see        ReplaceNthRow
		def ReplacesNthRowumns(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------#

	def ReplaceRowsAtXT(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceRowAtXT(_anPosU_[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowumnsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		#>

	  #-------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------#

	# Puts the same cells in each of the given rows, in place.
	#
	#   panRowsNumbers   the positions of the rows to change
	#   paNewRow         the cells every listed row receives, one per column, or [ :With, cells ]
	#   returns          nothing; the table changes
	#   see              ReplaceRowsAt
	def ReplaceTheseRows(panRowsNumbers, paNewRow)
		if IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositions(panRowsNumbers, paNewRow)

		# Puts the same cells in each of the given rows, in place.
		#
		#   panRowsNumbers   the positions of the rows to change
		#   paNewRow         the cells every listed row receives, one per column, or [ :With, cells
		#                    ]
		#   returns          nothing; the table changes
		#   see              ReplaceRowsAt
		def ReplaceTheseRowumns(panRowsNumbers, paNewRow)
			This.ReplaceTheseRows(panRowsNumbers, paNewRow)

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#

	def ReplaceTheseRowsXT(panRowsNumbers, paNewRow)
		if IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositionsXT(panRowsNumbers, paNewRow)

		def ReplaceTheseRowumnsXT(panRowsNumbers, paNewRow)
			This.ReplaceTheseRowsXT(panRowsNumbers, paNewRow)

	  #===============================================================#
	 #  REPLACING THE CELLS IN THE GIVEN ROWS BY THE PTOVIDED VALUE  #
	#===============================================================#

	# Raises error R24 today instead of setting every cell of the given rows to one value.
	#
	#   paRows     the positions of the rows to change
	#   pCell      the value put in every cell
	#   returns    nothing; it raises
	#   warning    Raises R24 (uninitialized variable panewrows) because the body checks a name that
	#              is not its parameter
	#   see        ReplaceCellsInRow
	def ReplaceCellsInTheseRows(paRows, pCell)
		if IsOneOfTheseNamedParamsList(paNewrows,[ :With, :By, :Using ])
			paNewrows = paNewrows[2]
		ok

		_aCells_ = This.CellsInTheseRowsAsPositions(paRows)
		This.ReplaceCells(_aCells_, pCell)


		# Puts the same cells in each of the given rows, in place; the second argument must be a list of cells, not one value.
		#
		#   paRows     the positions of the rows to change
		#   pCell      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   warning    Despite the name pCell, a single value raises R5; only a list of cells works
		#   see        ReplaceTheseRows
		def ReplaceTheseRowsWith(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)

		# Puts the same cells in each of the given rows, in place; the second argument must be a list of cells, not one value.
		#
		#   paRows     the positions of the rows to change
		#   pCell      the cells every listed row receives, one per column
		#   returns    nothing; the table changes
		#   warning    Despite the name pCell, a single value raises R5; only a list of cells works
		#   see        ReplaceTheseRows
		def ReplaceTheseRowsBy(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)


	  #===================================================#
	 #  REPLACING ALL OCCURRENCE OF A CELL IN THE TABLE  #
	#===================================================#

	def ReplaceAllCS(pCellValue, pNewCellValue, pCaseSensitive)
		_aCellsPos_ = This.FindAllCS(pCellValue, pCaseSensitive)
		This.ReplaceCells(_aCellsPos_, pNewCellValue)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceAllOccurrencesCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

	# Replaces every cell equal to a value by another value, in place, case-sensitively.
	#
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; the table changes
	#   warning         Raises an error for a number as the value to find, because FindCell does
	#   see             ReplaceCell, FindCell
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceAll(pCellValue, pNewCellValue)
		This.ReplaceAllCS(pCellValue, pNewCellValue, 1)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		#< @FunctionAlternatives
		def ReplaceAllOccurrencesOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		def ReplaceEachOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		def ReplaceEveryOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		#@ aka  --
		def ReplaceAllOccurrences(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		def ReplaceEachOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		# Raises error R19 today instead of replacing every cell equal to a value by another value.
		#
		#   pNewCellValue   the value that takes the place
		#   returns         nothing; it raises
		#   warning         Raises R19 because it forwards to ReplaceCell with two arguments where
		#                   ReplaceCell needs a column, a row and a value; ReplaceAll works
		#   see             ReplaceAll
		def ReplaceEveryOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#>

	  #---------------------------------------------------#
	 #  REPLACING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#---------------------------------------------------#

	def ReplaceNthCS(_n_, pValue, pNewCellValue, pCaseSensitive)
		_aCellPos_ = This.FindNthCS(_n_, pValue, pCaseSensitive)
		This.ReplaceCell(_aCellPos_, pNewCellValue)

	# Raises error R19 today instead of replacing the nth, first or last cell equal to a value.
	#
	#   _n_             the position, or how many, as a number
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; it raises
	#   warning         Raises R19 because the CS form calls ReplaceCell with a position pair where
	#                   ReplaceCell needs a column, a row and a value
	#   see             ReplaceAll
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceNth(_n_, pValue, pNewCellValue)
		This.ReplaceNthCS(_n_, pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceFirstCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(1, pValue, pNewCellValue, pCaseSensitive)

	# Raises error R19 today instead of replacing the nth, first or last cell equal to a value.
	#
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; it raises
	#   warning         Raises R19 because the CS form calls ReplaceCell with a position pair where
	#                   ReplaceCell needs a column, a row and a value
	#   see             ReplaceAll
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceFirst(pValue, pNewCellValue)
		This.ReplaceFirstCS(pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceLastCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(:Last, pValue, pNewCellValue, pCaseSensitive)

	# Raises error R19 today instead of replacing the nth, first or last cell equal to a value.
	#
	#   pNewCellValue   the value that takes the place
	#   returns         nothing; it raises
	#   warning         Raises R19 because the CS form calls ReplaceCell with a position pair where
	#                   ReplaceCell needs a column, a row and a value
	#   see             ReplaceAll
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceLast(pValue, pNewCellValue)
		This.ReplaceLastCS(pValue, pNewCellValue, 1)

	  #====================================#
	 #  REPLACING SUBVALUES INSIDE CELLS  #
	#====================================#

	def ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	# Raises error today instead of replacing a text found inside cells.
	#
	#   pnCol          the column position
	#   pnRow          the row position, 1 for the first
	#   pSubValue      the text to replace
	#   pNewSubValue   the text that takes the place
	#   returns        nothing; it raises
	#   warning        Always raises Function not yet implemented!
	#   see            ReplaceAll
	def ReplaceInCell(pnCol, pnRow, pSubValue, pNewSubValue)
		This.ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	# Raises error today instead of replacing a text found inside cells.
	#
	#   paCellsPos     the cell positions, each as [ column, row ]
	#   pSubValue      the text to replace
	#   pNewSubValue   the text that takes the place
	#   returns        nothing; it raises
	#   warning        Always raises Function not yet implemented!
	#   see            ReplaceAll
	def ReplaceInCells(paCellsPos, pSubValue, pNewSubValue)
		This.ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	# Raises error today instead of replacing a text found inside cells.
	#
	#   paCellsPos     the cell positions, each as [ column, row ]
	#   pSubValues     the texts to replace
	#   pNewSubValue   the text that takes the place
	#   returns        nothing; it raises
	#   warning        Always raises Function not yet implemented!
	#   see            ReplaceAll
	def ReplaceInCellsByMany(paCellsPos, pSubValues, pNewSubValue)
		This.ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, 1)

	# Add ReplaceInCellsByManyXT() : if all repalaced restart at the 1st one

	#--

	def ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	# Raises error today instead of replacing a text found inside cells.
	#
	#   paCellPos1     the first corner, as [ column, row ]
	#   paCellPos2     the opposite corner, as [ column, row ]
	#   pSubValue      the text to replace
	#   pNewSubValue   the text that takes the place
	#   returns        nothing; it raises
	#   warning        Always raises Function not yet implemented!
	#   see            ReplaceAll
	def ReplaceInSection(paCellPos1, paCellPos2,  pSubValue, pNewSubValue)
		This.ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	# Raises error R24 today instead of replacing several texts found inside a section.
	#
	#   paCellPos1     the first corner, as [ column, row ]
	#   paCellPos2     the opposite corner, as [ column, row ]
	#   pSubValues     the texts to replace
	#   pNewSubValue   the text that takes the place
	#   returns        nothing; it raises
	#   warning        Raises R24 (uninitialized variable casesensitive) because the body passes a
	#                  flag it does not have
	#   see            ReplaceInSection
	def ReplaceInSectionByMany(paCellPos1, paCellPos2,  pSubValues, pNewSubValue)
		This.ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, ;CaseSensitive = 1)

	# Raises error today instead of replacing a text found inside cells.
	#
	#   aSections   the sections to work on
	#   pSubValue   the text to replace
	#   returns     nothing; it raises
	#   warning     Always raises Function not yet implemented!
	#   see         ReplaceAll
	#@ aka  Add ReplaceInSectionByManyXT() : if all replaced restart at the 1st one
	def ReplaceInSectionsCS(aSections, pSubValue, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSections(aSections, pSubValue)
		This.ReplaceInSectionsCS(aSections, pSubValue, 1)

	# Raises error today instead of replacing a text found inside cells.
	#
	#   aSections     the sections to work on
	#   paSubValues   the texts to replace
	#   returns       nothing; it raises
	#   warning       Always raises Function not yet implemented!
	#   see           ReplaceAll
	#@ aka  --
	def ReplaceInSectionsByManyCS(aSections, paSubValues, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSectionsByMany(aSections, paSubValues)
		This.ReplaceInSectionsByManyCS(aSections, paSubValues, 1)

		# Crashes the Ring process today instead of returning a filled copy of the table.
		#
		#   returns    nothing; the process stops
		#   warning    Copy().FillQ(...) stops the whole Ring process without an error message in
		#              the check run; Filled works
		#   see        Filled
		#@ aka  -- Add ReplaceInSectionsByManyXT() : if all replaced restrat at 1st one
		def FillCQ(pValue) #TODO // Add this to all functions
			return This.Copy().FillQ(pValue)

	# Returns the table content with every cell set to one value; the table itself is unchanged.
	#
	#   returns    a list of [ name, cells ] pairs
	#   see        Fill
	def Filled(pValue)
		_aResult_ = This.Copy().FillQ(pValue).Content()
		return _aResult_

	  #=================================#
	 #  MISC. : SOME USEFUL UTILITIES  #
	#=================================#

	# Returns the table content as a stzHashList of column name and cells.
	#
	#   returns    a stzHashList
	#   see        Content
	def ToStzHashList()
		return new stzHashList( This.Table() )

	# Returns the name of a column given by position or name; accepts [ :Col, x ] and similar named forms.
	#
	#   p          the column, by name or position
	#   returns    the column name, as text
	#   warning    Raises Column index out of range. for a position past the last column
	#   see        ColToColNumber
	def ColToColName(p)
		if isList(p) and
		   IsOneOfTheseNamedParamsList(p,[
			:Col, :InCol, :Cols, :InCols,
			:Column, :InColumn, :Columns, :InColumns
		   ])

			p = p[2]
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)

			if StzFindFirst(p, [ :First, :FirstCol, :FirstColumn ]) > 0
				p = 1

			but StzFindFirst(p, [ :Last, :LastCol, :LastColumn ]) > 0
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		_cResult_ = This.ColName(p)
		return _cResult_

		def ColumnToColumnName(p)
			return This.ColToColName(p)

		def ColToName(p)
			return This.ColToColName(p)

		def ColAsName(p)
			return This.ColToColName(p)

		def ColumnAsName(p)
			return This.ColToColName(p)

	# Returns the names of the given columns, written as positions or as names.
	#
	#   returns    a list of column names
	#   see        TheseColsToColNumbers
	def TheseColsToColNames(paCols)
		if NOT ( isList(paCols) and ( @IsListOfNumbers(paCols) or
				@IsListOfStrings(paCols) or
				IsListOfNumbersAndStrings(paCols) ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		_nLen_ = len(paCols)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + This.ColToColName(paCols[i])
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def TheseColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#--

		def ColsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#>

		def ColumnToColumnNumber(p)
			return This.ColToColNumber(p)

		def ColToNumber(p)
			return This.ColToColNumber(p)

		def ColNumber(p)
			return This.ColToColNumber(p)

		def ColumnToNumber(p)
			return This.ColToColNumber(p)

		def ColumnNumber(p)
			return This.ColToColNumber(p)

		def ColAsNumber(p)
			return This.ColToColNumber(p)

		def ColumnAsNumber(p)
			return This.ColToColNumber(p)

	# Returns the positions of the given columns, written as positions or as names.
	#
	#   returns    a list of numbers
	#   see        TheseColsToColNames
		#>
	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( @IsListOfNumbers(paCols) or
				@IsListOfStrings(paCols) or
				IsListOfNumbersAndStrings(paCols) ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		_nLen_ = len(paCols)
		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + This.ColToColNumber(paCols[i])
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def TheseColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		#--

		def ColsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

	# Returns a row position as a number: a number passes through unchecked, :First gives 1 and :Last the last row.
	#
	#   pRow       the row position, :First or :Last
	#   returns    a number
	#   warning    A row given as its cells raises an error, so no row is ever looked up by its
	#              content
	#   see        Row
		#>
	def RowToRowNumber(pRow)
		if isList(pRow) and IsOneOfTheseNamedParamsList(pRow,[ :Row, :Rows, :InRow, :InRows, :OfRow, :OfRows ])
			pRow = pRow[2]
		ok

		if isString(pRow)
			if pRow = :First or pRow = :FirstRow
				pRow = 1
			but pRow = :Last or pRow = :LastRow
				pRow = This.NumberOfRows()
			ok
		ok

		if NOT isNumber(pRow)
			StzRaise("Incorrect param type! pRow must be a number.")
		ok

		return pRow

		def RowToNumber(pRow)
			return This.RowToRowNumber(pRow)

		def RowAsNumber(pRow)
			return This.RowToRowNumber(pRow)

	# Returns the position of each given row, 0 for a row the table does not hold.
	#
	#   paRows     the rows to look up, each a list of cells
	#   returns    a list of numbers
	#   see        FindRows
	def TheseRowsToRowsNumbers(paRows)
		if NOT ( isList(paRows) and @IsListOfLists(paRows) )
			StzRaise("Incorrect param type! paRows must be a list of lists.")
		ok

		_nLen_ = len(paRows)
		_aResult_ = []

		for i = 1 to _nLen_
			_anPos_ = This.FindRow(paRows[i])
			if len(_anPos_) > 0
				_aResult_ + _anPos_[1]
			else
				_aResult_ + 0
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def TheseRowsToNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def TheseRowsAsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		#>

	  #=============================#
	 #  USED BY SQL EXTERNAL CODE  #
	#=============================#

	# Returns the cell-reading code of a column in a formula, or the text itself when it names no column; a list raises today.
	#
	#   pacColNames   a column name as text, for a formula
	#   returns       text
	#   warning       A column name gives the code text ( This.Cell(n, j) ); a list raises R14
	#                 because IsHasHListOrListOfStrings is defined nowhere
	#   see           AddCalculatedCol
	def @(pacColNames)
		/*
		@([

		:id    = SMALLINT,
		:name  = VARCHAR(30),
		:score = SMALLINT

		])
		*/

		if CheckingParams()
			if NOT ( isString(pacColNames) or
				 (isList(pacColNames) and Q(pacColNames).IsHasHListOrListOfStrings()) )

				StzRaise("Incorrect param type! pacColNames must be a hashlist or a string containing a column name.")
			ok
		ok

		if isString(pacColNames)
			if This.IsAColName(pacColNames)
				_n_ = This.ColToColNumber(pacColNames)
				return '( This.Cell(' + _n_ + ', j) )'
			else
				return pacColNames
			ok
		ok

		_nLen_ = len(pacColNames)
		_acColNames_ = []

		if @IsListOfStrings(pacColNames)
			for i = 1 to _nLen_
				_acColNames_ + [ pacColNames[i], [ "" ] ]
			next

		else // IsHashList()
			for i = 1 to _nLen_
				_acColNames_ + [ pacColNames[i][1], [ "" ] ]
			next
		ok

		This.AddCols(_acColNames_)
		This.RemoveCol(1)

		_aRow_ = []
		for i = 1 to _nLen_
			_aRow_ + ""
		next

		This.AddRow(_aRow_)

	  #==============================#
	 #  ADDING A CALCULATED COLUMN  #
	#==============================#

	# Inserts a column, in place, whose cells are the formula evaluated on each row; the column takes the given position.
	#
	#   _n_         the position the new column takes
	#   pcColName   the name of the new column, as text
	#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column in
	#               the row
	#   returns     nothing; the table changes
	#   warning     Raises an error when the name already exists or the formula is empty
	#   see         AddCalculatedCol
	def InsertCalculatedCol(_n_, pcColName, pcFormula)
		if CheckingParams()
			if NOT @BothAreStrings(pcColName, pcFormula)
				StzRaise("Incorrect param types! pcColName and pcFormula must be both strings.")
			ok

			if ring_trim(pcColName) = ""
				StzRaise("Can't proceed! You must provide a name for the calculated column.")
			ok

			if This.IsAColName(pcColName)
				StzRaise("Can't proceed! The column name you provided already exists.")
			ok

			if ring_trim(pcFormula) = ""
				StzRaise("Cant' proceed! You must provide a formula.")
			ok
		ok

		_aColData_ = []
		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()

		@NumberOfRows = _nRows_
		@NumberOfCols = _nCols_
		@NumberOfColumns = _nCols_

		# Engine-first calculated column, DENSE path. Lower @(:ColName) to This[j]
		# where j is the column's position among the REFERENCED columns, so we
		# pass ONLY those -- read by the engine as a dense f64 matrix with NO
		# per-cell boxing (the boxing in the nested-list path was the marshalling
		# floor). The formula compiles ONCE and evaluates natively per row. (The
		# classic path below re-ran the Ring compiler with eval() on EACH row --
		# ~11us/row, seconds of pure compile overhead at scale.)
		# First find WHICH columns the formula references, then lower each to
		# This[j] where j is its rank among those referenced. Matching is
		# case-INsensitive: column names are stored lower-cased while a formula
		# may write @(:A). The @(:name) delimiters make the token exact, so a
		# column whose name is a prefix of another cannot match by accident.
		_oEngFormula_ = new stzString(pcFormula)
		_aRefCols_ = []
		for i = 1 to _nCols_
			if StzFindFirstCS( '@(:' + This.ColName(i) + ')', pcFormula, 0 ) > 0
				_aRefCols_ + i
			ok
		next
		_nRefLen_ = len(_aRefCols_)

		for j = 1 to _nRefLen_
			_oEngFormula_.ReplaceCS( '@(:' + This.ColName(_aRefCols_[j]) + ')',
						 'This[' + j + ']', 0 )
		next

		# One pass: gather the referenced columns' data (the dense input) and
		# confirm each is numeric. The engine evaluates arithmetically, so a
		# formula over a string column (e.g. a concatenation) must take the Ring
		# fallback below to preserve its semantics.
		_aRefData_ = []
		_bNumericRefs_ = 1
		for j = 1 to _nRefLen_
			_aColVals_ = This.Col(_aRefCols_[j])
			_nCVLen_ = len(_aColVals_)
			for c = 1 to _nCVLen_
				if NOT isNumber(_aColVals_[c])
					_bNumericRefs_ = 0
					exit
				ok
			next
			_aRefData_ + _aColVals_
			if NOT _bNumericRefs_
				exit
			ok
		next

		if _bNumericRefs_ and _nRefLen_ > 0
			_aColData_ = StzEngineListEvalColumnsDense(_aRefData_, _nRows_, _oEngFormula_.Content())
		ok

		# Fallback: a non-numeric reference, or a formula the engine DSL cannot
		# compile (which returns an empty column), is evaluated the classic way
		# so no existing formula regresses.
		if len(_aColData_) != _nRows_
			_aColData_ = []
			_oForumla_ = new stzString(pcFormula)
			for i = 1 to _nCols_
				_oForumla_.ReplaceCS( ('@(:'+ This.ColName(i)+')'), 'This.Cell(' + i + ', i)', 0)
			next
			_cCode_ = "_value_ = " + _oForumla_.Content()
			for i = 1 to _nRows_
				eval(_cCode_)
				_aColData_ + _value_
			next
		ok

		_aContent_ = @aContent
		_aContent_ = ring_insert(_aContent_, _n_, [ pcColName, _aColData_ ])
		This.UpdateWith(_aContent_)
		@anCalculatedCols + _n_

		# Inserts a column, in place, whose cells are the formula evaluated on each row; the column takes the given position.
		#
		#   _n_         the position the new column takes
		#   pcColName   the name of the new column, as text
		#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column
		#               in the row
		#   returns     nothing; the table changes
		#   warning     Raises an error when the name already exists or the formula is empty
		#   see         AddCalculatedCol
		#< @FunctionAlternativeForms
		def InsertCalculatedColAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		# Inserts a column, in place, whose cells are the formula evaluated on each row; the column takes the given position.
		#
		#   _n_         the position the new column takes
		#   pcColName   the name of the new column, as text
		#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column
		#               in the row
		#   returns     nothing; the table changes
		#   warning     Raises an error when the name already exists or the formula is empty
		#   see         AddCalculatedCol
		def InsertCalculatedColumn(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		# Inserts a column, in place, whose cells are the formula evaluated on each row; the column takes the given position.
		#
		#   _n_         the position the new column takes
		#   pcColName   the name of the new column, as text
		#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column
		#               in the row
		#   returns     nothing; the table changes
		#   warning     Raises an error when the name already exists or the formula is empty
		#   see         AddCalculatedCol
		def InsertCalculatedColumnAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

	# Appends a column, in place, whose cells are the formula evaluated on each row.
	#
	#   pcColName   the name of the new column, as text
	#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column in
	#               the row
	#   returns     nothing; the table changes
	#   warning     Raises an error when the name already exists or the formula is empty
	#   see         InsertCalculatedCol
		#>
	def AddCalculatedCol(pcColName, pcFormula)
		This.InsertCalculatedCol(This.NumberOfCols()+1, pcColName, pcFormula)

		# Appends a column, in place, whose cells are the formula evaluated on each row.
		#
		#   pcColName   the name of the new column, as text
		#   pcFormula   the formula, as text, where @(:COLNAME) stands for the cell of that column
		#               in the row
		#   returns     nothing; the table changes
		#   warning     Raises an error when the name already exists or the formula is empty
		#   see         InsertCalculatedCol
		#< @FunctionAlternativeForm
		def AddCalculatedColumn(pcColName, pcFormula)
			This.AddCalculatedCol(pcColName, pcFormula)

		#>

	  #-----------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED COLUMNS  #
	#-----------------------------------------------#

	# Inserts a row, in place, whose cells are the formulas evaluated one per column; the row takes the given position.
	#
	#   _n_           the position the new row takes
	#   pacFormulas   the formulas as text, one per column
	#   returns       nothing; the table changes
	#   see           AddCalculatedRow
	def InsertCalculatedRow(_n_, pacFormulas)
		if CheckingParams()
			if NOT ( isList(pacFormulas) and @IsListOfStrings(pacFormulas) )
				StzRaise("Incorrect param type! pacFormulas must be a list of strings.")
			ok
		ok

		_aRowData_ = []
		_nLen_ = len(pacFormulas)
		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()
		_nMin_ = @Min([ _nRows_, _nLen_ ])

		# Preparing the list of formulas

		_aoForumlas_ = StzListQ(pacFormulas).ToListOfStzStrings()
		_acCodes_ = []
		for i = 1 to _nMin_
			_cColName_ = This.ColName(i)
			_aoForumlas_[i].ReplaceCS( ('@(:'+ _cColName_ +')'), 'This.Col(:' + _cColName_ + ')', 0)
			_cCode_ =  _aoForumlas_[i].Content()
			if _cCode_ != ""
				_cCode_ = '_value_ = ' + _cCode_
			ok
			_acCodes_ + _cCode_
		next

		@NumberOfRows = _nRows_
		@NumberOfCols = _nCols_
		@NumberOfColumns = _nCols_

		for i = 1 to _nMin_
			if _acCodes_[i] != ""
				eval(_acCodes_[i])
				_aRowData_ + _value_
			else
				_aRowData_ + " "
			ok
		next

		if _nMin_ < _nCols_
			for i = _nMin_+1 to _nCols_
				_aRowData_ + ""
			next
		ok

		This.InsertRow(_n_, _aRowData_)
		@anCalculatedRows + _n_

	# Appends a row, in place, whose cells are the formulas evaluated one per column.
	#
	#   pacFormulas   the formulas as text, one per column
	#   returns       nothing; the table changes
	#   see           InsertCalculatedRow
	def AddCalculatedRow(pacFormulas)
		This.InsertCalculatedRow( This.NumberOfRows() + 1, pacFormulas)

	  #--------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED ROWS  #
	#--------------------------------------------#

	# Returns the result when it adds the cells of a block between two corners; 0 when a cell is not a number.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   warning    Answers 0 for a block holding any text cell, and for plain column numbers instead
	#              of [ column, row ] corners
	#   see        SumCol
	def SUM(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += _aCells_[i]
		next

		return _nResult_

	# Returns the result when it multiplies the cells of a block between two corners; 0 when a cell is not a number.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   warning    Answers 0 for a block holding any text cell, and for plain column numbers instead
	#              of [ column, row ] corners
	#   see        SumCol
	def PRODUCT(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nResult_ = 1

		for i = 1 to _nLen_
			_nResult_ *= _aCells_[i]
		next

		return _nResult_

	# Returns the result when it averages the cells of a block between two corners; 0 when a cell is not a number.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   warning    Answers 0 for a block holding any text cell, and for plain column numbers instead
	#              of [ column, row ] corners
	#   see        SumCol
	def AVERAGE(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nSum_ = 0

		for i = 1 to _nLen_
			_nSum_ += _aCells_[i]
		next

		_nResult_ = _nSum_ / _nLen_
		return _nResult_

		# Returns the average of the cells of a block between two corners; 0 when a cell is not a number.
		#
		#   paCell1    the first corner of the block, as [ column, row ]
		#   paCell2    the opposite corner of the block, as [ column, row ]
		#   returns    a number
		#   warning    Answers 0 for a block holding any text cell
		#   see        AVERAGE
		def MEAN(paCell1, paCell2)
			return AVERAGE(paCell1, paCell2)

	# Returns how many cells lie in a block between two corners.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   see        SUM
	def KOUNT(paCell1, paCell2)
		_nResult_ = len( This.CellsInSection(paCell1, paCell2) )
		return _nResult_

	# Returns the result when it takes the largest of the cells of a block between two corners; 0 when a cell is not a number.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   warning    Answers 0 for a block holding any text cell, and for plain column numbers instead
	#              of [ column, row ] corners
	#   see        SumCol
	def MAX(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nResult_ = @Max(_aCells_)

		return _nResult_

	# Returns the result when it takes the smallest of the cells of a block between two corners; 0 when a cell is not a number.
	#
	#   paCell1    the first corner of the block, as [ column, row ]
	#   paCell2    the opposite corner of the block, as [ column, row ]
	#   returns    a number
	#   warning    Answers 0 for a block holding any text cell, and for plain column numbers instead
	#              of [ column, row ] corners
	#   see        SumCol
	def MIN(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nResult_ = @Min(_aCells_)

		return _nResult_

	  #==========================================================#
	 #  ENGINE-BACKED COLUMN AGGREGATION (whole-column, fast)    #
	#==========================================================#

	# Returns the sum of the numeric cells of a column, computed by the engine.
	#
	#   returns    a number
	#   warning    A column of text, even numeric text such as 001, sums to 0
	#   see        AvgCol, SUM
	def SumCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableSumCol(@pEngine, _nCol_-1)

		def SumColumn(pCol)
			return This.SumCol(pCol)

	# Returns the average of the cells of a column, computed by the engine.
	#
	#   returns    a number
	#   see        SumCol, MedianCol
	def AvgCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableAvgCol(@pEngine, _nCol_-1)

		def AvgColumn(pCol)
			return This.AvgCol(pCol)

		def AverageCol(pCol)
			return This.AvgCol(pCol)

		def AverageColumn(pCol)
			return This.AvgCol(pCol)

		def MeanCol(pCol)
			return This.AvgCol(pCol)

		def MeanColumn(pCol)
			return This.AvgCol(pCol)

	# Returns the smallest cell of a column, computed by the engine.
	#
	#   returns    a number
	#   see        MaxCol
	def MinCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMinCol(@pEngine, _nCol_-1)

		def MinColumn(pCol)
			return This.MinCol(pCol)

	# Returns the largest cell of a column, computed by the engine.
	#
	#   returns    a number
	#   see        MinCol
	def MaxCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMaxCol(@pEngine, _nCol_-1)

		def MaxColumn(pCol)
			return This.MaxCol(pCol)

	# Returns the product of the cells of a column, computed by the engine.
	#
	#   returns    a number
	#   see        SumCol
	def ProductCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableProductCol(@pEngine, _nCol_-1)

		def ProductColumn(pCol)
			return This.ProductCol(pCol)

	# Returns how many cells of a column are not empty.
	#
	#   returns    a number
	#   see        NumberOfRows
	def CountNonNullInCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableCountNonNull(@pEngine, _nCol_-1)

		def CountNonNullInColumn(pCol)
			return This.CountNonNullInCol(pCol)

	#=====================================================================#
	#  COLUMN STATISTICS -- backed by stzDataSet (the stats engine).      #
	#                                                                     #
	#  The table engine gives us Sum/Avg/Min/Max/Product. Everything      #
	#  richer -- median, spread, quartiles, correlation, regression --    #
	#  is NOT reimplemented here: the table extracts a column once and    #
	#  hands it to stzDataSet, which owns the stats authority (and is     #
	#  itself engine-backed). stzTable becomes a CUSTOMER of the numeric  #
	#  foundation rather than stopping at sum-and-average.                #
	#=====================================================================#

	# A column's numeric cells, coerced (numeric strings included) and
	# cleaned of everything non-numeric, as a plain list of numbers.
	def _NumericColOf(pCol)
		_aRaw_ = This.Col(pCol)
		_aOut_ = []
		_nLen_ = len(_aRaw_)
		for _i_ = 1 to _nLen_
			_c_ = _aRaw_[_i_]
			# Keep only real numerics. The null/empty guard comes FIRST because
			# IsNumberInStringOrNumber("") is TRUE -- without it an empty cell
			# coerces to a spurious 0 and poisons the mean and median.
			if (NOT isNull(_c_)) and (("" + _c_) != "") and IsNumberInStringOrNumber(_c_)
				_aOut_ + number("" + _c_)
			ok
		next
		return _aOut_

	# THE STATISTICS AUTHORITY IS THE ENGINE, not another Ring class.
	#
	# This used to hand each column to stzDataSet -- which is engine-backed, so the
	# arithmetic was right, but the ADAPTER lived in Ring: the eight accessors per
	# column, the pairwise double loop, the diagonal. That means a Python or C face
	# over the same engine got a table type with no statistics at all, which is the
	# opposite of the point of having an engine.
	#
	# frame.zig now owns the tabular operations, so a column description is ONE
	# crossing and a correlation matrix is ONE crossing, for every language.
	def _DescribeFlat(pCol)
		_aD_ = StzEngineFrameDescribe(This._NumericColOf(pCol))
		if NOT isList(_aD_) or len(_aD_) != 8
			StzRaise("DescribeCol: the engine refused this column.")
		ok
		return _aD_

	# TRUE if the column holds at least one value and every non-empty value is a number or numeric text.
	#
	#   returns    TRUE or FALSE
	#   warning    Raises Column not found! for an unknown column
	#   see        NumericColumnNames
	#@ aka  A column counts as numeric when it has at least one value and every non-null value is a number (or a numeric string).
	def IsNumericCol(pCol)
		_aRaw_ = This.Col(pCol)
		_nNum_ = 0
		_nNonNull_ = 0
		_nLen_ = len(_aRaw_)
		for _i_ = 1 to _nLen_
			_c_ = _aRaw_[_i_]
			if NOT isNull(_c_)
				_nNonNull_++
				if IsNumberInStringOrNumber(_c_)
					_nNum_++
				ok
			ok
		next
		return _nNonNull_ > 0 and _nNum_ = _nNonNull_

		def IsNumericColumn(pCol)
			return This.IsNumericCol(pCol)

	# Returns the median of the numeric cells of a column.
	#
	#   returns    a number
	#   see        DescribeCol
	def MedianCol(pCol)
		return This._DescribeFlat(pCol)[3]

		def MedianColumn(pCol)
			return This.MedianCol(pCol)

	# Returns the sample standard deviation of the numeric cells of a column.
	#
	#   returns    a number
	#   see        VarianceCol, DescribeCol
	def StdDevCol(pCol)
		return This._DescribeFlat(pCol)[4]

		def StdDevColumn(pCol)
			return This.StdDevCol(pCol)

	# Returns the variance of the numeric cells of a column, the square of its standard deviation.
	#
	#   returns    a number
	#   see        StdDevCol
	def VarianceCol(pCol)
		_nS_ = This._DescribeFlat(pCol)[4]
		return _nS_ * _nS_

		def VarianceColumn(pCol)
			return This.VarianceCol(pCol)

	# Returns the first quartile of the numeric cells of a column.
	#
	#   returns    a number
	#   see        Q3Col, DescribeCol
	def Q1Col(pCol)
		return This._DescribeFlat(pCol)[7]

		def Q1Column(pCol)
			return This.Q1Col(pCol)

	# Returns the third quartile of the numeric cells of a column.
	#
	#   returns    a number
	#   see        Q1Col, DescribeCol
	def Q3Col(pCol)
		return This._DescribeFlat(pCol)[8]

		def Q3Column(pCol)
			return This.Q3Col(pCol)

	# Returns the given percentile of the numeric cells of a column, interpolating between cells.
	#
	#   pnP        the percentile, from 0 to 100
	#   returns    a number
	#   see        MedianCol
	#@ aka  A percentile other than the quartiles still goes through stzDataSet, which is the sample authority and already engine-backed -- a table-shaped operation is not needed for a single number from a single column.
	def PercentileCol(pCol, pnP)
		_oDS_ = new stzDataSet(This._NumericColOf(pCol))
		return _oDS_.Percentile(pnP)

		def PercentileColumn(pCol, pnP)
			return This.PercentileCol(pCol, pnP)

	# Returns eight statistics of a column: count, mean, median, stddev, min, max, q1 and q3.
	#
	#   returns    a list of eight [ name, value ] pairs
	#   warning    Raises an error for a column with no numeric cell
	#   see        Describe
	#@ aka  A full per-column summary as DATA -- the eight numbers, in the engine's order.
	def DescribeCol(pCol)
		_aD_ = This._DescribeFlat(pCol)
		return [
			[ :count,  _aD_[1] ],
			[ :mean,   _aD_[2] ],
			[ :median, _aD_[3] ],
			[ :stddev, _aD_[4] ],
			[ :min,    _aD_[5] ],
			[ :max,    _aD_[6] ],
			[ :q1,     _aD_[7] ],
			[ :q3,     _aD_[8] ]
		]

		def DescribeColumn(pCol)
			return This.DescribeCol(pCol)

	# Returns the names of the numeric columns, in column order.
	#
	#   returns    a list of column names
	#   see        IsNumericCol
	#@ aka  The names of the numeric columns, in table order.
	def NumericColumnNames()
		_aOut_ = []
		_aNames_ = This.ColumnNames()
		_nLen_ = len(_aNames_)
		for _i_ = 1 to _nLen_
			if This.IsNumericCol(_aNames_[_i_])
				_aOut_ + _aNames_[_i_]
			ok
		next
		return _aOut_

	# Returns the eight statistics of every numeric column, as [ column name, [ [ name, value ], ... ] ] items.
	#
	#   returns    a list of [ name, statistics ] pairs; [ ] when no column is numeric
	#   see        DescribeCol
	#@ aka  Describe every NUMERIC column, as [ [colName, DescribeCol(colName)], ... ].
	def Describe()
		_aNames_ = This.NumericColumnNames()
		_nC_ = len(_aNames_)
		if _nC_ = 0
			return []
		ok
		_aCols_ = []
		_nR_ = 0
		for _j_ = 1 to _nC_
			_aV_ = This._NumericColOf(_aNames_[_j_])
			_aCols_ + _aV_
			if len(_aV_) > _nR_
				_nR_ = len(_aV_)
			ok
		next
		# row-major, ragged columns padded with their own last value so a short
		# column cannot shift the ones beside it
		_aFlat_ = []
		for _i_ = 1 to _nR_
			for _j_ = 1 to _nC_
				_aV_ = _aCols_[_j_]
				if _i_ <= len(_aV_)
					_aFlat_ + _aV_[_i_]
				else
					_aFlat_ + _aV_[len(_aV_)]
				ok
			next
		next
		_aD_ = StzEngineFrameDescribeAll(_aFlat_, _nR_, _nC_)
		if NOT isList(_aD_) or len(_aD_) != _nC_ * 8
			StzRaise("Describe: the engine refused this table.")
		ok
		_aOut_ = []
		for _j_ = 1 to _nC_
			_b_ = (_j_ - 1) * 8
			_aOut_ + [ _aNames_[_j_], [
				[ :count,  _aD_[_b_ + 1] ],
				[ :mean,   _aD_[_b_ + 2] ],
				[ :median, _aD_[_b_ + 3] ],
				[ :stddev, _aD_[_b_ + 4] ],
				[ :min,    _aD_[_b_ + 5] ],
				[ :max,    _aD_[_b_ + 6] ],
				[ :q1,     _aD_[_b_ + 7] ],
				[ :q3,     _aD_[_b_ + 8] ]
			] ]
		next
		return _aOut_

	# The same summary as a TABLE object (statistic-per-row), for display or
	# further chaining -- hence the Q, per the naming law.
	def DescribeQ()
		_aStatNames_ = [ :count, :mean, :median, :stddev, :min, :max, :q1, :q3 ]
		_aCols_ = [ [ :statistic, _aStatNames_ ] ]
		_aDesc_ = This.Describe()
		_nL_ = len(_aDesc_)
		for _j_ = 1 to _nL_
			_aVals_ = []
			for _s_ = 1 to 8
				_aVals_ + _aDesc_[_j_][2][_s_][2]
			next
			_aCols_ + [ _aDesc_[_j_][1], _aVals_ ]
		next
		return new stzTable(_aCols_)

	# Returns the Pearson correlation between two columns, from the engine; 0 when fewer than two rows.
	#
	#   pColA      the first column, by name or position
	#   pColB      the second column, by name or position
	#   returns    a number between -1 and 1
	#   warning    A column with no numeric cell answers 0
	#   see        CorrelationMatrix
	#@ aka  Pearson correlation between two columns -- read off the engine's matrix, so a pair and a whole matrix cannot disagree.
	def CorrelationBetween(pColA, pColB)
		_aA_ = This._NumericColOf(pColA)
		_aB_ = This._NumericColOf(pColB)
		_nR_ = len(_aA_)
		if len(_aB_) < _nR_
			_nR_ = len(_aB_)
		ok
		if _nR_ < 2
			return 0
		ok
		_aFlat_ = []
		for _i_ = 1 to _nR_
			_aFlat_ + _aA_[_i_]
			_aFlat_ + _aB_[_i_]
		next
		_aM_ = StzEngineFrameCorrMatrix(_aFlat_, _nR_, 2)
		if NOT isList(_aM_) or len(_aM_) != 4
			StzRaise("CorrelationBetween: the engine refused these columns.")
		ok
		return _aM_[2]

		def CorrBetween(pColA, pColB)
			return This.CorrelationBetween(pColA, pColB)

	# Returns the correlation matrix of the numeric columns as [ [ :columns, names ], [ :matrix, rows ] ].
	#
	#   returns    a list of two pairs
	#   see        CorrelationBetween
	#@ aka  The pairwise correlation matrix over the numeric columns, as DATA: [ [:columns, aNames], [:matrix, aMatrix] ].
	def CorrelationMatrix()
		_aNames_ = This.NumericColumnNames()
		_nC_ = len(_aNames_)
		if _nC_ = 0
			return [ [ :columns, [] ], [ :matrix, [] ] ]
		ok
		_aCols_ = []
		_nR_ = 0
		for _j_ = 1 to _nC_
			_aV_ = This._NumericColOf(_aNames_[_j_])
			_aCols_ + _aV_
			if _nR_ = 0 or len(_aV_) < _nR_
				_nR_ = len(_aV_)
			ok
		next
		_aFlat_ = []
		for _i_ = 1 to _nR_
			for _j_ = 1 to _nC_
				_aFlat_ + _aCols_[_j_][_i_]
			next
		next
		_aM_ = StzEngineFrameCorrMatrix(_aFlat_, _nR_, _nC_)
		if NOT isList(_aM_) or len(_aM_) != _nC_ * _nC_
			StzRaise("CorrelationMatrix: the engine refused this table.")
		ok
		_aOut_ = []
		for _i_ = 1 to _nC_
			_aRow_ = []
			for _j_ = 1 to _nC_
				_aRow_ + _aM_[(_i_ - 1) * _nC_ + _j_]
			next
			_aOut_ + _aRow_
		next
		return [ [ :columns, _aNames_ ], [ :matrix, _aOut_ ] ]

		def CorrMatrix()
			return This.CorrelationMatrix()

	# Returns the least-squares line of one column on another as slope, intercept and r_squared pairs.
	#
	#   pColY      the column to explain, by name or position
	#   pOn        the word :On, which makes the call read as RegressionOf(y, :On, x)
	#   pColX      the column that explains, by name or position
	#   returns    a list of three [ name, value ] pairs
	#   warning    Raises an error when pOn is not :On, or when fewer than two points or no spread
	#              in x leave no line
	#   see        CorrelationBetween
	#@ aka  Least-squares regression of one column ON another, read at the call site: RegressionOf(:pay, :On, :age). Returns [ [:slope,..], [:intercept,..], [:r_squared,..] ].
	def RegressionOf(pColY, pOn, pColX)
		if pOn != :On and pOn != :on
			StzRaise("RegressionOf: read it as RegressionOf(yCol, :On, xCol).")
		ok
		_aY_ = This._NumericColOf(pColY)
		_aX_ = This._NumericColOf(pColX)
		_aR_ = StzEngineFrameRegression(_aX_, _aY_)
		if NOT isList(_aR_) or len(_aR_) != 3
			StzRaise("RegressionOf: no line fits these columns -- fewer than two " +
				"points, or an x with no spread at all.")
		ok
		return [ [ :slope, _aR_[1] ], [ :intercept, _aR_[2] ], [ :r_squared, _aR_[3] ] ]

	  #============================================#
	 #  CASTING THE TABLE INTO A STZTABLE OBJECT  #
	#============================================#

    # Keeps only the rows whose cells match every column = value pair, in place; a list of values matches any of them.
    #
    #   paColValues   the filter, as column name = value or column name = list of values pairs
    #   returns       nothing; the table changes
    #   warning       Raises an error for an unknown column; a filter matching nothing leaves empty
    #                 columns
    #   see           FilterW
    #@ aka  NOTE // stzPivotTable belongs to the MAX layer of StzLib For the fellowing method to work, you must load "stzmax.ring"
    def Filter(paColValues)

        # Validate input is a hash list

        if NOT (isList(paColValues) and @IsHashList(paColValues))
            StzRaise("Filter requires a hash list of filtering [ColName, ColValue] pairs.")
        ok

        # Validate column existence and prepare filtering

		_nLen_ = len(paColValues)

		for i = 1 to _nLen_
            _cColName_ = paColValues[i][1]

            # Check if column exists (case-insensitive)

            _nColIndex_ = This.FindCol(_cColName_)
            if _nColIndex_ = 0
                StzRaise("Column '" + _cColName_ + "' not found in the table")
            ok
        next

        # Perform filtering

        _nRows_ = This.NumberOfRows()
        _aRowsToKeep_ = []

        for nRow = 1 to _nRows_
            _bKeepRow_ = 1
			_nLenValues_ = len(paColValues)

			for v = 1 to _nLenValues_
                _cColName_ = paColValues[v][1]
                _aFilterValues_ = paColValues[v][2]

                # Get column index
                _nColIndex_ = This.FindCol(_cColName_)

                # Get cell value
                _cellValue_ = This.Cell(_nColIndex_, nRow)

                # Check if cell value matches filter conditions
                # Support both single value and list of values

                if isList(_aFilterValues_)

                    _bValueMatches_ = 0
					_nLenFilterValues_ = len(_aFilterValues_)

					for j = 1 to _nLenFilterValues_

                        if _cellValue_ = _aFilterValues_[j]
                            _bValueMatches_ = 1
                            exit
                        ok

					next

                else
                    _bValueMatches_ = (_cellValue_ = _aFilterValues_)
                ok

                # If any condition fails, exclude the row
                if NOT _bValueMatches_
                    _bKeepRow_ = 0
                    exit
                ok
            next

            if _bKeepRow_
                _aRowsToKeep_ + This.Row(nRow)
            ok
        next

        # Rebuild the table with filtered rows

        _aResult_ = []

        # Recreate columns with filtered data

        _nCols_ = This.NumberOfCols()

        for _nCol_ = 1 to _nCols_
            _cColName_ = This.ColName(_nCol_)
            _colData_ = []

			_nLenRowsToKeep_ = len(_aRowsToKeep_)
            for nRow = 1 to _nLenRowsToKeep_
                _colData_ + _aRowsToKeep_[nRow][_nCol_]
            next

            _aResult_ + [_cColName_, _colData_]
        next

        @aContent = _aResult_

    #< @FunctionFluentForm

    def FilterQ(paColValues)
        This.Filter(paColValues)
        return This

	# Returns a filtered copy of the table, keeping the rows that match every column = value pair; the table is unchanged.
	#
	#   paColValues   the filter, as column name = value or column name = list of values pairs
	#   returns       a new stzTable
	#   see           Filter
	def FilterCQ(paColValues)
			_oCopy_ = This.Copy()
			_oCopy_.Filter(paColValues)
			return _oCopy_
	# Keeps only the rows whose cells match every column = value pair, in place; a list of values matches any of them.
	#
	#   paColValues   the filter, as column name = value or column name = list of values pairs
	#   returns       nothing; the table changes
	#   see           Filter
	#>
	#< @FunctionAlternativeForm
	def FilterBy(paColValues)
		This.Filter(paColValues)

		def FilterByQ(paColValues)
			return This.FilterQ(paColValues)

		def FilterByCQ(paColValues)
			return This.FilterCQ(paColValues)

	#>

	  #--------------------------------------------#
	 #  FILTERING THE TABLE BY A GIVEN CONDITION  #
	#--------------------------------------------#

	def FilterW(pcCondition)

		# Validate input is a string

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if ring_trim(pcCondition) = ""
			StzRaise("Can't proceed! You must provide a condition.")
		ok


		# Early check for complex condition

		_oCondition_ = new stzString(pcCondition)
		if _oCondition_.NumberOfOccurrence('@(') > 1
			This.FilterWXT(pcCondition)
			return
		ok

		# Prepare the condition expression

		_nCols_ = This.NumberOfCols()

		for i = 1 to _nCols_
			_cColName_ = This.ColName(i)
			_oCondition_.ReplaceCS('@(:' + _cColName_ + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		_cCondition_ = _oCondition_.Content()

		# Prepare evaluation code
		_cCode_ = "_bResult_ = " + _cCondition_

		# Perform filtering
		_nRows_ = This.NumberOfRows()
		_aRowsToKeep_ = []

		for nRow = 1 to _nRows_
			# Evaluate the condition for the current row
			eval(_cCode_)
			if _bResult_
				_aRowsToKeep_ + This.Row(nRow)
			ok
		next
		_nLenRowsToKeep_ = len(_aRowsToKeep_)

		# Rebuild the table with filtered rows
		_aResult_ = []
		_nCols_ = This.NumberOfCols()

		for _nCol_ = 1 to _nCols_

			_cColName_ = This.ColName(_nCol_)
			_colData_ = []


			for nRow = 1 to _nLenRowsToKeep_
				_colData_ + _aRowsToKeep_[nRow][_nCol_]
			next

			_aResult_ + [_cColName_, _colData_]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def FilterWQ(pcCondition)
			This.FilterW(pcCondition)
			return This

		# Returns a filtered copy keeping the rows that satisfy a condition written with @(:COLNAME); the table is unchanged.
		#
		#   returns    a new stzTable
		#   see        FilterWXTCQ
		def FilterWCQ(pcCondition)
			_oCopy_ = This.Copy()
			_oCopy_.FilterW(pcCondition)
			return _oCopy_

		#>

		#< @FunctionAlternativeForm

		def FilterByW(pcCondition)
			This.FilterW(pcCondition)

		def FilterByWQ(pcCondition)
			return This.FilterWQ(pcCondition)

		def FilterByWCQ(pcCondition)
			return This.FilterWCQ(pcCondition)

		#>

	  #----------------------------------------------#
	 #  FILTERING THE TABLE BY A COMPLEX CONDITION  #
	#----------------------------------------------#

	def FilterWXT(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if ring_trim(pcCondition) = ""
			StzRaise("Can't proceed! You must provide a condition.")
		ok

		# Validate that all referenced column names exist

		_oConditionTemp_ = new stzString(pcCondition)
		_acColNames_ = This.ColNames()
		_nLenCols_ = len(_acColNames_)

		for i = 1 to _nLenCols_

			if _oConditionTemp_.ContainsCS('@(:' + _acColNames_[i] + ')', 0)
				if NOT This.IsColName(_acColNames_[i])
					StzRaise("Invalid column name! The column '@(:" + _acColNames_[i] + ")' does not exist in the table.")
				ok
			ok

		next

		# Prepare the condition expression

		_oCondition_ = new stzString(pcCondition)
		_nCols_ = This.NumberOfCols()

		for i = 1 to _nCols_
			_cColName_ = This.ColName(i)
			_oCondition_.ReplaceCS('@(:' + _cColName_ + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		_cCondition_ = _oCondition_.Content()

		# Verify that no '@(:...)' patterns remain

		if Q(_cCondition_).Contains('@(:')
			StzRaise("Invalid condition! Unresolved column reference found in: " + _cCondition_)
		ok

		# Prepare evaluation code

		_cCode_ = "_bOk_ = " + _cCondition_

		# Perform filtering

		_nRows_ = This.NumberOfRows()
		_aRowsToKeep_ = []

		for nRow = 1 to _nRows_
			try
				eval(_cCode_)
				if _bOk_
					_aRowsToKeep_ + This.Row(nRow)
				ok
			catch
				StzRaise("Error evaluating condition: " + _cCondition_ + " at row " + nRow)
			done
		next

		# Rebuild the table with filtered rows

		_aResult_ = []
		_nCols_ = This.NumberOfCols()

		for _nCol_ = 1 to _nCols_

			_cColName_ = This.ColName(_nCol_)
			_colData_ = []
			_nLenRowsToKeep_ = len(_aRowsToKeep_)

			for nRow = 1 to _nLenRowsToKeep_
				_colData_ + _aRowsToKeep_[nRow][_nCol_]
			next

			_aResult_ + [_cColName_, _colData_]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def FilterWXTQ(pcCondition)
			This.FilterWXT(pcCondition)
			return This

		# Returns a filtered copy keeping the rows that satisfy a condition that names several columns; the table is unchanged.
		#
		#   returns    a new stzTable
		#   see        FilterWCQ
		def FilterWXTCQ(pcCondition)
			_oCopy_ = This.Copy()
			_oCopy_.FilterWXT(pcCondition)
			return _oCopy_

		#>

		#< @FunctionAlternativeForm

		def FilterByWXT(pcCondition)
			This.FilterWXT(pcCondition)

			def FilterByWXTQ(pcCondition)
				return This.FilterWXTQ(pcCondition)

			def FilterByWXTCQ(pcCondition)
				return This.FilterWXTCQ(pcCondition)

		#>

	  #============================================================================#
	 #  Aggregating (Grouping) table data based on specified columns and methods  #
	#============================================================================#

	# Replaces the table, in place, by one row of aggregates named function(column), such as sum(age).
	#
	#   paAggregations   the aggregations as column name = function pairs
	#   returns          nothing; the table changes
	#   warning          Raises an error for an unknown column or for a function outside the list,
	#                    such as Median
	#   see              GroupByAndAggregate
	def Aggregate(paAggregations)
		# Validate input is a hash list
		if NOT (isList(paAggregations) and @IsHashList(paAggregations))
			StzRaise("Aggregate requires a hash list of aggregation specifications")
		ok

		# Predefined aggregation methods
		_aValidMethods_ = [
			:Sum,
			:Average,
			:Count,
			:Max,
			:Min,
			:First,
			:Last
		]

		# Validate and process aggregations
		_aProcessedAggs_ = []
		_nLen_ = len(paAggregations)

		for i = 1 to _nLen_
			_cColName_ = paAggregations[i][1]
			_cAggMethod_ = StzLower(paAggregations[i][2])

			# Validate column existence
			_nColIndex_ = This.FindCol(_cColName_)
			if _nColIndex_ = 0
				StzRaise("Column '" + _cColName_ + "' not found in the table")
			ok

			# Validate aggregation method
			if StzFindFirst(_cAggMethod_, _aValidMethods_) = 0
				StzRaise("Invalid aggregation method: " + _cAggMethod_)
			ok

			_aProcessedAggs_ + [_cColName_, _cAggMethod_]
		next

		# Perform aggregation
		_aResult_ = []

		# Add columns for aggregation results
		_nLen_ = len(_aProcessedAggs_)

		for i = 1 to _nLen_
			_cColName_ = _aProcessedAggs_[i][1]
			_cAggMethod_ = _aProcessedAggs_[i][2]

			# Create aggregated column name
			_cAggColName_ = _cAggMethod_ + "(" + _cColName_ + ")"

			# Perform aggregation
			_nColIndex_ = This.FindCol(_cColName_)
			_aColData_ = This.Col(_nColIndex_)
			_nLenData_ = len(_aColData_)

			_nResult_ = 0

			switch _cAggMethod_

			on :Sum

				for v = 1 to _nLenData_
					_nResult_ += _aColData_[v]
				next

			on :Average

				_nSum_ = 0

				for v = 1 to _nLenData_
					_nSum_ += _aColData_[v]
				next

				_nResult_ = _nSum_ / _nLenData_

			on :Count
				_nResult_ = _nLenData_

			on :Max

				_nResult_ = _aColData_[1]

				for v = 2 to _nLenData_
					if _aColData_[v] > _nResult_
						_nResult_ = _aColData_[v]
					ok
				next

			on :Min

				_nResult_ = _aColData_[1]

				for v = 2 to _nLenData_
					if _aColData_[v] < _nResult_
						_nResult_ = _aColData_[v]
					ok
				next

			on :First
				_nResult_ = _aColData_[1]

			on :Last
				_nResult_ = _aColData_[_nLenData_]
			off

			# Add aggregated column
			_aResult_ + [ _cAggColName_, [_nResult_] ]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def AggregateQ(paAggregations)
			This.Aggregate(paAggregations)
			return This
		# Replaces the table, in place, by one row of aggregates named function(column), such as sum(age).
		#
		#   paAggregations   the aggregations as column name = function pairs
		#   returns          nothing; the table changes
		#   see              Aggregate
		#>
		#< @FunctionAlternativeForm
		def AggregateBy(paAggregations)
			This.Aggregate(paAggregations)

			def AggregateByQ(paAggregations)
				return This.AggregateQ(paAggregation)

		#>

	  #===============================================#
	 #  GROUPING DATA (ROWS) BY A GIVEN VALUE (COL)  #
	#===============================================#

	# Reorders the rows in place so that rows with the same values in the given columns sit together, in order of first appearance.
	#
	#   returns    nothing; the table changes
	#   warning    A single column name given as text is read as a list-valued column and empties
	#              the table when its cells are not lists
	#   see        GroupByAndAggregate
	def GroupBy(paCols)

		if NOT isList(paCols)
			if isString(paCols) This.IsCol(paCols) and @IsListOfLists(This.Col(paCols))
				This.GroupByListItems(paCols)
				return
			ok

			_aTemp_ = [] + paCols
			paCols = _aTemp_
		ok

		# Validate input is a list of column names
		if NOT (isList(paCols) and len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence
		_nLen_ = len(paCols)
		for i = 1 to _nLen_
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Prepare to group rows
		_nRows_ = This.NumberOfRows()
		_aGroupedRows_ = []
		_aGroupKeys_ = []
		_aUniqueGroups_ = []

		# Iterate through rows to create groups
		_nLenCols_ = len(paCols)
		for nRow = 1 to _nRows_
			# Create group key from specified columns
			_aGroupKey_ = []
			for i = 1 to _nLenCols_
				_nColIndex_ = This.FindCol(paCols[i])
				_aGroupKey_ + This.Cell(_nColIndex_, nRow)
			next

			# Convert group key to string for easy comparison
			_cGroupKey_ = ""
			_nGroupKeyLen_ = len(_aGroupKey_)
			for i = 1 to _nGroupKeyLen_
				_cGroupKey_ += ""+ _aGroupKey_[i] + '|'
			next

			# Check if this group key exists
			_nGroupIndex_ = StzFindFirst(_cGroupKey_, _aGroupKeys_)
			if _nGroupIndex_ = 0
				# New group, add to groups
				_aGroupKeys_ + _cGroupKey_
				_aUniqueGroups_ + _aGroupKey_
				_aGroupedRows_ + [ This.Row(nRow) ]
			else
				# Existing group, append row
				_aGroupedRows_[_nGroupIndex_] + This.Row(nRow)
			ok
		next

		# Build result table structure
		_aResult_ = []
		_acColNames_ = This.ColNames()

		# Add all columns to result
		_nColNamesLen_3 = len(_acColNames_)
		for i = 1 to _nColNamesLen_3
			_aResult_ + [ _acColNames_[i], [] ]
		next

		# Add rows from each group to result
		_nLenGroups_ = len(_aUniqueGroups_)
		for i = 1 to _nLenGroups_
			_aRows_ = _aGroupedRows_[i]
			_nRowsLen_ = len(_aRows_)
			for j = 1 to _nRowsLen_
				_aRow_ = _aRows_[j]
				# Add each value to its column
				_nRowLen_ = len(_aRow_)
				for k = 1 to _nRowLen_
					_aResult_[k][2] + _aRow_[k]
				next
			next
		next

		@aContent = _aResult_


		#< @FunctionFluentForm

		def GroupByQ(paCols)
			This.GroupBy(paCols)
			return This

		# Returns a copy of the table with its rows grouped by the given columns; the table is unchanged.
		#
		#   returns    a new stzTable
		#   see        GroupBy
		def GroupByCQ(paCols)
				_oCopy_ = This.Copy()
				_oCopy_.GroupBy(paCols)
				return _oCopy_
		#>

	  #-------------------------------------------#
	 #  GROUPING BY AND AGRREGATING -- EXTENDED  #
	#-------------------------------------------#

	def GroupByXT(paCols, paAggregations)

		# Validate input is a list of column names

		if NOT (isList(paCols) and len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence

		_nLen_ = len(paCols)

		for i = 1 to _nLen_
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Validate aggregation input

		if NOT (isList(paAggregations) and @IsListOfPairsOfStrings(paAggregations))
				StzRaise("Aggregations must be a hash list of [column, method] pairs")
		ok

		# Default aggregation if none provided: First value for non-grouped columns

		_nLenAgg_ = len(paAggregations)

		if _nLenAgg_ = 0

			_acColNames_ = This.ColNames()

			for i = 1 to _nLenAgg_

				if NOT StzFindFirst(_acColNames_[i], paCols) > 0
					paAggregations + [_cColName_, :First]
				ok

			next
		else

		# Lowercase all the aggregation functions

		for i = 1 to _nLenAgg_
			paAggregations[i][2] = StzLower(paAggregations[i][2])
		next

		# Valid aggregation methods

		_aValidMethods_ = [ :Sum, :Average, :Count, :Max, :Min, :First, :Last ]

		for i = 1 to _nLenAgg_

			_cColName_ = paAggregations[i][1]
			_cAggMethod_ = paAggregations[i][2]

			# Validate column exists

			if This.FindCol(_cColName_) = 0
				StzRaise("Column '" + _cColName_ + "' not found in the table")
			ok

			# Validate method is supported

			if NOT StzFindFirst(_cAggMethod_, _aValidMethods_)
				StzRaise("Invalid aggregation method: " + _cAggMethod_)
			ok

			# Validate column is not in grouping columns

			if StzFindFirst(_cColName_, paCols) > 0
				StzRaise("Cannot aggregate grouping column: " + _cColName_)
			ok

		next
	ok

	# Prepare to group rows

	_nRows_ = This.NumberOfRows()
	_aGroupedRows_ = []
	_aGroupKeys_ = []
	_aUniqueGroups_ = []

	# Iterate through rows to create groups

	_nLenCols_ = len(paCols)

	for nRow = 1 to _nRows_

		# Create group key from specified columns

		_aGroupKey_ = []

		for i = 1 to _nLenCols_
			_nColIndex_ = This.FindCol(paCols[i])
			_aGroupKey_ + This.Cell(_nColIndex_, nRow)
		next
		_nLenKeys_ = len(_aGroupKey_)

		# Convert group key to string for easy comparison

		_cGroupKey_ = ""

		for i = 1 to _nLenKeys_
			_cGroupKey_ += ""+ _aGroupKey_[i] + '|'
		next

		# Check if this group key exists

		_nGroupIndex_ = StzFindFirst(_cGroupKey_, _aGroupKeys_)

		if _nGroupIndex_ = 0

			# New group, add to groups

			_aGroupKeys_ + _cGroupKey_
			_aUniqueGroups_ + _aGroupKey_
			_aGroupRows_ = [ This.Row(nRow) ]
			_aGroupedRows_ + _aGroupRows_

		else
			# Existing group, append row
			_aGroupedRows_[_nGroupIndex_] + This.Row(nRow)
		ok
	next

	# Build result table structure

	_aResult_ = []

	# Add grouping columns first

	for i = 1 to _nLenCols_
		_aResult_ + [ paCols[i], [] ]
	next

	# Process aggregations and add aggregated columns

	for i = 1 to _nLenAgg_
		_cColName_ = paAggregations[i][1]
		_cAggMethod_ = paAggregations[i][2]
		_cAggColName_ = _cAggMethod_ + "(" + _cColName_ + ")"
		_aResult_ + [ _cAggColName_, [] ]
	next

	# Perform aggregations for each group

	_nLenGroups_ = len(_aUniqueGroups_)

	for i = 1 to _nLenGroups_

		_aGroupKey_ = _aUniqueGroups_[i]
		_aRows_ = _aGroupedRows_[i]
		_nLenRows_ = len(_aRows_)

		# Add group key values to result

		for j = 1 to _nLenCols_
			_aResult_[j][2] + _aGroupKey_[j]
		next

		# Calculate aggregations for this group

		_nColOffset_ = _nLenCols_ + 1

		for j = 1 to _nLenAgg_

			_cColName_ = paAggregations[j][1]
			_cAggMethod_ = paAggregations[j][2]
			_nColIndex_ = This.FindCol(_cColName_)

			# Extract values for this column from group rows

			_aValues_ = []

			for r = 1 to _nLenRows_
				_aValues_ + _aRows_[r][_nColIndex_]
			next

			# Apply aggregation method

			_nResult_ = ""
			_nLenVal_ = len(_aValues_)

			switch _cAggMethod_

				on :Sum

					_nResult_ = 0

					for v = 1 to _nLenVal_
						_nResult_ += _aValues_[v]
					next

				on :Average

						_nSum_ = 0

						for v = 1 to _nLenVal_
							_nSum_ += _aValues_[v]
						next

						_nResult_ = _nSum_ / _nLenVal_

				on :Count
					_nResult_ = _nLenVal_

				on :Max
					_nResult_ = _aValues_[1]

					for v = 2 to _nLenVal_
						if _aValues_[v] > _nResult_
							_nResult_ = _aValues_[v]
						ok
					next

				on :Min
					_nResult_ = _aValues_[1]

					for v = 2 to _nLenVal_
						if _aValues_[v] < _nResult_
							_nResult_ = _aValues_[v]
						ok
					next

				on :First
					_nResult_ = _aValues_[1]

				on :Last
					_nResult_ = _aValues_[_nLenVal_]
				off

				# Add result to output

				_aResult_[_nColOffset_][2] + _nResult_
				_nColOffset_++

			next

		next

		@aContent = _aResult_


		#< @FunctionFluentForm

		def GroupByXTQ(paCols, paAggregations)
			This.GroupByXT(paCols, paAggregations)
			return This

		# Replaces the table, in place, by one row per group of the given columns, with the aggregates of the other columns.
		#
		#   paAggregations   the aggregations as [ column name, function ] pairs
		#   returns          nothing; the table changes
		#   warning          Raises an error for an unknown column or function
		#   see              Aggregate, GroupBy
		#>
		#< @FunctionAlternativeForm
		def GroupByAndAggregate(paCols, paAggregations)
			This.GroupByXT(paCols, paAggregations)

			def GroupByAndAggregateQ(paCols, paAggregations)
				return This.GroupByXTQ(paCols, paAggregations)

		#>

	  #---------------------------------------------#
	 #  GROUPING DATA BY A COLUMN CONTAINING LIST  #
	#---------------------------------------------#

	# Reshapes the table, in place, to one row per item of a list-valued column, the item coming first in each row.
	#
	#   paCols     the list-valued column, by name
	#   returns    nothing; the table changes
	#   warning    A row whose cell is not a list is dropped; an unknown column raises an error
	#   see        GroupBy
	def GroupByListItems(paCols) #TODO // check why there is a dependance with "HOBBY"!
		if NOT isList(paCols)
			_aTemp_ = [] + paCols
			paCols = _aTemp_
		ok
	    # Validate input is a list of column names
	    if NOT (isList(paCols) and len(paCols) > 0)
	        StzRaise("GroupByListItems requires a non-empty list of column names")
	    ok

	    # Validate column existence
	    _nLen_ = len(paCols)
	    for i = 1 to _nLen_
	        if This.FindCol(paCols[i]) = 0
	            StzRaise("Column '" + paCols[i] + "' not found in the table")
	        ok
	    next

	    # Get the lists column we're grouping by
	    _cListColumn_ = paCols[1]  # Use the first column as the list column
	    _nListColIndex_ = This.FindCol(_cListColumn_)

	    # Prepare to collect unique hobby values and associated rows
	    _nRows_ = This.NumberOfRows()
	    _aHobbyMap_ = []  # Will be a list of [hobby, [row1, row2, ...]] pairs

	    # Process each row and collect unique hobby values
	    for nRow = 1 to _nRows_
	        _vCellValue_ = This.Cell(_nListColIndex_, nRow)

	        # Skip if not a list
	        if NOT isList(_vCellValue_)
	            loop
	        ok

	        # Process each hobby in the list
	        _nVCellValueLen_ = len(_vCellValue_)
	        for j = 1 to _nVCellValueLen_
	            _cHobby_ = _vCellValue_[j]

	            # Find this hobby in our map
	            _nHobbyIndex_ = 0
	            _nHobbyMapLen_2 = len(_aHobbyMap_)
	            for k = 1 to _nHobbyMapLen_2
	                if _aHobbyMap_[k][1] = _cHobby_
	                    _nHobbyIndex_ = k
	                    exit
	                ok
	            next

	            if _nHobbyIndex_ = 0
	                # New hobby, add it with this row
	                _aHobbyMap_ + [_cHobby_, [nRow]]
	            else
	                # Existing hobby, check if row already exists
	                _bFound_ = 0
	                _nHobbyMapnHobbyIndex2Len_ = len(_aHobbyMap_[_nHobbyIndex_][2])
	                for r = 1 to _nHobbyMapnHobbyIndex2Len_
	                    if _aHobbyMap_[_nHobbyIndex_][2][r] = nRow
	                        _bFound_ = 1
	                        exit
	                    ok
	                next

	                # Add row if not found
	                if NOT _bFound_
	                    _aHobbyMap_[_nHobbyIndex_][2] + nRow
	                ok
	            ok
	        next
	    next

	    # Build the new table structure with hobbies as the first column
	    _aNewColumns_ = [_cListColumn_]
	    _acColNames_ = This.ColNames()

	    # Add all other columns except the list column
	    _nColNamesLen_2 = len(_acColNames_)
	    for i = 1 to _nColNamesLen_2
	        if _acColNames_[i] != _cListColumn_
	            _aNewColumns_ + _acColNames_[i]
	        ok
	    next

	    # Create the result table structure
	    _aResult_ = []
	    _nNewColumnsLen_ = len(_aNewColumns_)
	    for i = 1 to _nNewColumnsLen_
	        _aResult_ + [_aNewColumns_[i], []]
	    next

	    # Fill in the data for each hobby group
	    _nHobbyMapLen_ = len(_aHobbyMap_)
	    for i = 1 to _nHobbyMapLen_
	        _cHobby_ = _aHobbyMap_[i][1]
	        _aRowIndices_ = _aHobbyMap_[i][2]

	        # For each row that has this hobby
	        _nRowIndicesLen_ = len(_aRowIndices_)
	        for j = 1 to _nRowIndicesLen_
	            _nRowIndex_ = _aRowIndices_[j]

	            # Add the hobby as the first column value
	            _aResult_[1][2] + _cHobby_

	            # Add all other columns from the original row
	            _nColOffset_ = 2  # Start from second column
	            _nColNamesLen_ = len(_acColNames_)
	            for k = 1 to _nColNamesLen_
	                if _acColNames_[k] != _cListColumn_
	                    _nColIndex_ = This.FindCol(_acColNames_[k])
	                    _aResult_[_nColOffset_][2] + This.Cell(_nColIndex_, _nRowIndex_)
	                    _nColOffset_++
	                ok
	            next
	        next
	    next

	    @aContent = _aResult_

	def ToString()
		return This._displayFullTable()

	# Prints the table as a boxed grid on the console.
	#
	#   returns    nothing; the grid is printed
	#   see        Display
	def Show()
		? This._displayFullTable()

	# Prints the rows that match the criteria as a boxed grid, and leaves only those rows in the table.
	#
	#   paFilterCriteria   the filter, as column name = value pairs
	#   returns            nothing; the grid is printed
	#   warning            Also filters the table in place, so the other rows are gone afterwards
	#   see                Display
	def ShowFilter(paFilterCriteria)
		? _displayFilteredTable(paFilterCriteria)

    # Returns the table as a boxed grid text; with criteria it returns only the matching rows and filters the table in place.
    #
    #   paFilterCriteria   the filter as column name = value pairs, or an empty text for the whole
    #                      table
    #   returns            text, the grid
    #   warning            With criteria the table itself is filtered, so the other rows are gone
    #                      afterwards
    #   see                Show
    #@ aka  New display method to show table contents
    def Display(paFilterCriteria)

        # If no filter criteria provided, display full table

        if paFilterCriteria = ""
            return This._displayFullTable()

        else
            return This._displayFilteredTable(paFilterCriteria)
        ok

    # Internal method to display full table

    def _displayFullTable()
        # Get column names and content
        _acColNames_ = This.ColNames()
        _aContent_ = @aContent

        # Calculate column widths
        _aColWidths_ = []
        _nCols_ = len(_acColNames_)

        # First pass: calculate max width for each column header
        for i = 1 to _nCols_
            _nMaxWidth_ = len(_acColNames_[i])

            # Check column values

            _aColData_ = _aContent_[i][2]
			_nLenCol_ = len(_aColData_)

            for j = 1 to _nLenCol_

				if isNumber(_aColData_[j]) or isString(_aColData_[j])
                	_cellValue_ = "" + _aColData_[j]
				else
					_cellValue_ = @@(_aColData_[j])
				ok

                if stzlen(_cellValue_) > _nMaxWidth_
                    _nMaxWidth_ = stzlen(_cellValue_)
                ok

            next

            _aColWidths_ + (_nMaxWidth_ + 2)  # Add padding

        next

        # Build output string
        _cOutput_ = ""

        # Top border

        _cLine_ = @aBorder[:TopLeft]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:TeeDown]
			else
				_cLine_ += @aBorder[:TopRight]
			ok

        next

        _cOutput_ += _cLine_ + char(10)

        # Header row

        _cLine_ = @aBorder[:Vertical]

        for i = 1 to _nCols_
            _cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
        next

        _cOutput_ += _cLine_ + char(10)

        # Separator

        _cLine_ = @aBorder[:TeeRight]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok

        next

        _cOutput_ += _cLine_ + char(10)

        # Data rows

        _nRows_ = This.NumberOfRows()

        for r = 1 to _nRows_

            _cLine_ = @aBorder[:Vertical]

            for i = 1 to _nCols_

				_cellValue_ = ""
                _val_ = This.Content()[i][2][r]
				if isNumber(_val_) or isString(_val_)
                	_cellValue_ = "" + _val_
				else
					_cellValue_ = @@(_val_)
				ok

                # Right-align numbers, left-align strings

                if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
                    _cLine_ += " " + PadLeft(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
                else
                    _cLine_ += " " + PadRight(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
                ok

            next

            _cOutput_ += _cLine_ + char(10)

        next

        # Bottom border

        _cLine_ = @aBorder[:BottomLeft]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:TeeUp]
			else
				_cLine_ += @aBorder[:BottomRight]
			ok

        next

        _cOutput_ += _cLine_

        return _cOutput_

    # Internal method to display filtered table

    def _displayFilteredTable(paFilterCriteria)

        # Create a filtered copy of the table

        _oFilteredTable_ = This.FilterQ(paFilterCriteria)

        # Use the full table display method on the filtered table

        return _oFilteredTable_.Display("")

	  #----------------------------------------#
	 #  DISPLAYING THE TABLE - EXTENDED FORM  #
	#----------------------------------------#

	# Reads display options such as RowNumber, SubTotal and GrandTotal but returns nothing, so it has no effect.
	#
	#   pParams         the options, as a hash list, a list of pairs or a list of words
	#   _bRowNumber_    the row-number flag, 1 or 0
	#   _bSubTotal_     the sub-total flag, 1 or 0
	#   _bGrandTotal_   the grand-total flag, 1 or 0
	#   bCleanDesign    the clean-design flag, 1 or 0
	#   returns         nothing
	#   warning         Works on local copies of the flags and returns nothing, so the caller never
	#                   sees the result
	#   see             Display
	#@ aka  Master method orchestrating the submethods
	def processParameters(pParams, _bRowNumber_, _bSubTotal_, _bGrandTotal_, bCleanDesign)
		if pParams = ""
			# Use defaults
		else
			if isList(pParams)
				if len(pParams) = 0
					# Use defaults
				else
					_nLenP_ = len(pParams)
					for i = 1 to _nLenP_
						if isList(pParams[i])
							_cParamName_ = StzLower(string(pParams[i][1]))
							if len(pParams[i]) >= 2
								if StzLower(_cParamName_) = "rownumber"
									_bRowNumber_ = pParams[i][2]
								but StzLower(_cParamName_) = "subtotal"
									_bSubTotal_ = pParams[i][2]
								but StzLower(_cParamName_) = "grandtotal"
									_bGrandTotal_ = pParams[i][2]

								ok
							ok
						but isString(pParams[i])
							_cParam_ = pParams[i]
							if @StzMid(_cParam_, 1, 9) = "rownumber"
								_bRowNumber_ = 1
							but @StzMid(_cParam_, 1, 8) = "subtotal"
								_bSubTotal_ = 1
							but @StzMid(_cParam_, 1, 10) = "grandtotal"
								_bGrandTotal_ = 1
							ok
						ok
					next
				ok

			but IsHashList(pParams)
				if HasKey(pParams, :RowNumber)
					_bRowNumber_ = pParams[:RowNumber]
				ok

				if HasKey(pParams, :SubTotal)
					_bSubTotal_ = pParams[:SubTotal]
				ok

				if HasKey(pParams, :GrandTotal)
					_bGrandTotal_ = pParams[:GrandTotal]
				ok
			ok
		ok

		# Ensure boolean values
		_bRowNumber_ = @if(IsBoolean(_bRowNumber_), _bRowNumber_, 0)
		_bSubTotal_ = @if(IsBoolean(_bSubTotal_), _bSubTotal_, 0)
		_bGrandTotal_ = @if(IsBoolean(_bGrandTotal_), _bGrandTotal_, 0)

	# Returns the display width of each column, from its name and its widest cell, plus 2 for padding.
	#
	#   _acColNames_    the column names
	#   _aContent_      the table content, as [ name, cells ] pairs
	#   _bRowNumber_    the row-number flag, 1 or 0
	#   _bGrandTotal_   the grand-total flag, 1 or 0
	#   returns         a list of numbers
	#   warning         The first column is at least 17 wide, because of the longest sample label of
	#                   the grid
	#   see             Display
	#@ aka  Submethod to calculate column widths
	def calculateColumnWidths(_acColNames_, _aContent_, _bRowNumber_, _bGrandTotal_)
		_aColWidths_ = []
		_nCols_ = len(_acColNames_)

		for i = 1 to _nCols_
			_nMaxWidth_ = len(_acColNames_[i])
			_aColData_ = _aContent_[i][2]
			_nLenCol_ = len(_aColData_)

			for j = 1 to _nLenCol_
				if isString(_aColData_[j]) or isNumber(_aColData_[j])
					_cellValue_ = "" + _aColData_[j]
				else
					_cellValue_ = @@(_aColData_[j])
				ok
				_nLenCell_ = stzlen(_cellValue_)
				if _nLenCell_ > _nMaxWidth_
					_nMaxWidth_ = _nLenCell_
				ok
			next

			_nLenTemp_ = len("Product X Total")
			if i = 1
				if _nMaxWidth_ < _nLenTemp_
					_nMaxWidth_ = _nLenTemp_
				ok
			ok

			_nLenTemp_ = len("GRAND-TOTAL")
			if i = 1 and _bGrandTotal_
				if _nMaxWidth_ < _nLenTemp_
					_nMaxWidth_ = _nLenTemp_
				ok
			ok

			_aColWidths_ + (_nMaxWidth_ + 2)
		next

		return _aColWidths_

	# Adds a row-number column to the widths and names it receives, but returns nothing, so it has no effect.
	#
	#   _bRowNumber_   the row-number flag, 1 or 0
	#   _aColWidths_   the column widths
	#   _acColNames_   the column names
	#   returns        nothing
	#   warning        Changes local copies only and returns nothing, so the caller never sees the
	#                  result
	#   see            calculateColumnWidths
	#@ aka  Submethod to adjust column widths and names for row numbers
	def adjustForRowNumbers(_bRowNumber_, _aColWidths_, _acColNames_)

		if _bRowNumber_
			_nRowNumWidth_ = len("" + This.NumberOfRows()) + 2
			_aColWidths_ = ring_insert(_aColWidths_, 1, _nRowNumWidth_)
			_acColNames_ = ring_insert(_acColNames_, 1, "#")
		ok

	# Returns the boxed grid text for the given names, content and widths, with an optional grand total.
	#
	#   _acColNames_    the column names
	#   _aContent_      the table content, as [ name, cells ] pairs
	#   _aColWidths_    the column widths
	#   _bRowNumber_    the row-number flag, 1 or 0
	#   _bSubTotal_     the sub-total flag, 1 or 0
	#   _bGrandTotal_   the grand-total flag, 1 or 0
	#   returns         text, the grid
	#   see             Display
	#@ aka  Submethod to build the output string
	def buildOutput(_acColNames_, _aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_)
		_cOutput_ = ""
		_nCols_ = len(_acColNames_)

		# Top border
		_cLine_ = @aBorder[:TopLeft]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:TeeDown]
			else
				_cLine_ += @aBorder[:TopRight]
			ok
		next
		_cOutput_ += _cLine_ + char(10)

		# Header row
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + char(10)

		# Separator
		_cLine_ = @aBorder[:TeeRight]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok
		next
		_cOutput_ += _cLine_ + char(10)

		# Data rows with aggregation
		_cOutput_ += buildDataRows(_aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_, _nCols_)

		# Grand total
		if _bGrandTotal_
			_cOutput_ += buildGrandTotal(_aColWidths_, _bRowNumber_, _nCols_)
		ok

		# Bottom border
		_cLine_ = @aBorder[:BottomLeft]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:TeeUp]
			else
				_cLine_ += @aBorder[:BottomRight]
			ok
		next
		_cOutput_ += _cLine_

		return _cOutput_

	# Returns the text of the data rows of the grid, with optional sub-total rows.
	#
	#   _aContent_      the table content, as [ name, cells ] pairs
	#   _aColWidths_    the column widths
	#   _bRowNumber_    the row-number flag, 1 or 0
	#   _bSubTotal_     the sub-total flag, 1 or 0
	#   _bGrandTotal_   the grand-total flag, 1 or 0
	#   _nCols_         the number of columns shown
	#   returns         text, the grid rows
	#   see             buildOutput
	#@ aka  Submethod to build data rows with subtotals
	def buildDataRows(_aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_, _nCols_)
		_cOutput_ = ""
		_nRows_ = This.NumberOfRows()
		_nGroupCol_ = @if(_bRowNumber_, 2, 1)
		_cCurrentGroup_ = ""
		_aGroups_ = []
		_aGroupTotals_ = []
		_aGrandTotals_ = []

		for i = 1 to _nCols_
			_aGrandTotals_ + 0
		next

		# First pass: gather groups and calculate totals
		for r = 1 to _nRows_

			_cGroup_ = "" + _aContent_[_nGroupCol_][2][r]

			if NOT StzFindFirst(_cGroup_, _aGroups_) > 0
				_aGroups_ + _cGroup_
				_aGroupTotals_[_cGroup_] = []
				for i = 1 to _nCols_
					_aGroupTotals_[_cGroup_] + 0
				next
			ok

			for i = 1 to _nCols_
				if _bRowNumber_ and i = 1
					loop
				ok
				_nDataCol_ = @if(_bRowNumber_, i - 1, i)
				if _nDataCol_ > 0 and _nDataCol_ <= len(_aContent_)
					_cellValue_ = _aContent_[_nDataCol_][2][r]
					if not (isNumber(_cellValue_) or isString(_cellValue_))
						_cellValue_ = @@(_cellValue_)
					ok
					if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
						_aGroupTotals_[_cGroup_][i] += (0 + _cellValue_)
						_aGrandTotals_[i] += (0 + _cellValue_)
					ok
				ok
			next
		next

		# Second pass: display data with totals
		_cCurrentGroup_ = ""
		for r = 1 to _nRows_
			_cGroup_ = "" + _aContent_[_nGroupCol_][2][r]

			if _bSubTotal_ and _cCurrentGroup_ != "" and _cGroup_ != _cCurrentGroup_
				_cOutput_ += buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
			ok

			_cCurrentGroup_ = _cGroup_
			_cLine_ = @aBorder[:Vertical]
			for i = 1 to _nCols_
				if _bRowNumber_ and i = 1
					_cLine_ += " " + PadLeft("" + r, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_nDataCol_ = @if(_bRowNumber_, i - 1, i)
					if _nDataCol_ > 0 and _nDataCol_ <= len(_aContent_)
						_cellValue_ = _aContent_[_nDataCol_][2][r]
						if NOT (isNumber(_cellValue_) or isString(_cellValue_))
							_cellValue_ = @@(_cellValue_)
						ok
						if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
							_cLine_ += " " + PadLeft(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
						else
							_cLine_ += " " + PadRight(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
						ok
					else
						_cLine_ += " " + PadRight("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
					ok
				ok
			next
			_cOutput_ += _cLine_ + char(10)

			if _bSubTotal_ and r = _nRows_
				_cOutput_ += buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
			ok
		next

		return _cOutput_

	# Returns the text of a sub-total line of the grid for one group.
	#
	#   _aColWidths_      the column widths
	#   _nCols_           the number of columns shown
	#   _bRowNumber_      the row-number flag, 1 or 0
	#   _nGroupCol_       the position of the grouping column
	#   _cCurrentGroup_   the name of the group
	#   _aGroupTotals_    the totals of each group, keyed by group name
	#   returns           text, the sub-total lines
	#   see               buildDataRows
	#@ aka  Submethod to build subtotal row
	def buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
		_cOutput_ = ""
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar("-", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + char(10)

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			if _bRowNumber_ and i = 1
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but i = _nGroupCol_
				_cLine_ += " " + PadLeft(" Sub-total", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but (i = _nGroupCol_ + 1 and not _bRowNumber_) or (i = _nGroupCol_ + 1 and _bRowNumber_)
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(_aGroupTotals_[_cCurrentGroup_][i]) and _aGroupTotals_[_cCurrentGroup_][i] != 0
					_cLine_ += " " + PadLeft("" + _aGroupTotals_[_cCurrentGroup_][i], _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		_cOutput_ += _cLine_ + char(10)

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar(" ", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + char(10)

		return _cOutput_

	# Raises error R24 today instead of returning the grand-total line of the grid.
	#
	#   _aColWidths_   the column widths
	#   _bRowNumber_   the row-number flag, 1 or 0
	#   _nCols_        the number of columns shown
	#   returns        nothing; it raises
	#   warning        Raises R24 because the body reads the grand totals, which are local to
	#                  buildDataRows
	#   see            buildOutput
	#@ aka  Submethod to build grand total
	def buildGrandTotal(_aColWidths_, _bRowNumber_, _nCols_)
		_cOutput_ = ""
		_cLine_ = @aBorder[:TeeRight]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok
		next
		_cOutput_ += _cLine_ + char(10)

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			if _bRowNumber_ and i = 1
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but i = @if(_bRowNumber_, 2, 1)
				_cLine_ += PadLeft("GRAND-TOTAL ", _aColWidths_[i]) + @aBorder[:Vertical]
			but i = @if(_bRowNumber_, 3, 2)
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(_aGrandTotals_[i]) and _aGrandTotals_[i] != 0
					_cLine_ += " " + PadLeft("" + _aGrandTotals_[i], _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		_cOutput_ += _cLine_ + char(10)

		return _cOutput_

	#---------------------------------#
	#  TRANSPOSINT THE TABLE CONTENT  #
	#---------------------------------#


	# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
	#
	#   returns    nothing; the table changes
	#   warning    TransposeBack cannot restore the names after this form
	#   see        TransposeXT, TransposeBack
	def Transpose()

	    # Get dimensions directly from @aContent
	    _nCols_ = len(@aContent)
	    if _nCols_ = 0
	        return
	    ok
	    _nRows_ = len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = 0
	    @aOriginalColNames = []
	    for i = 1 to _nCols_
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names
	    _acNewColNames_ = []
	    for i = 1 to _nRows_
	        _acNewColNames_ + ("COL" + i)
	    next

	    # Build new content directly in target format
	    _aNewContent_ = []
	    for i = 1 to _nRows_
	        _aNewRow_ = []
	        for j = 1 to _nCols_
	            _aNewRow_ + @aContent[j][2][i]
	        next
	        _aNewContent_ + [_acNewColNames_[i], _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []


		def TransposeQ()
			This.Transpose()
			return This


		# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
		#
		#   returns    nothing; the table changes
		#   warning    TransposeBack cannot restore the names after this form
		#   see        TransposeXT, TransposeBack
		def Turn()
			This.Transpose()

		# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
		#
		#   returns    nothing; the table changes
		#   warning    TransposeBack cannot restore the names after this form
		#   see        TransposeXT, TransposeBack
		def SwapColsAndRows()
			This.Transpose()

		# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
		#
		#   returns    nothing; the table changes
		#   warning    TransposeBack cannot restore the names after this form
		#   see        TransposeXT, TransposeBack
		def SwapRowsAndCols()
			This.Transpose()

		# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
		#
		#   returns    nothing; the table changes
		#   warning    TransposeBack cannot restore the names after this form
		#   see        TransposeXT, TransposeBack
		def SwitchColsAndRows()
			This.Transpose()

		# Turns rows into columns, in place: each old row becomes a column named COL1, COL2 and so on; the old column names are dropped.
		#
		#   returns    nothing; the table changes
		#   warning    TransposeBack cannot restore the names after this form
		#   see        TransposeXT, TransposeBack
		def SwithRowsAndCols()
			This.Transpose()


	def TransposeXT() # Keeps original colnames

	    # Get dimensions and column names directly from @aContent
	    _nCols_ = len(@aContent)
	    if _nCols_ = 0
	        return
	    ok
	    _nRows_ = len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = 1
	    @aOriginalColNames = []
	    for i = 1 to _nCols_
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names (all follow COL pattern)
	    _acNewColNames_ = []
	    for i = 1 to _nRows_
	        _acNewColNames_ + ("COL" + i)
	    next

	    # Build new content
	    _aNewContent_ = []

	    # First column contains original headers
	    _aFirstColumn_ = []
	    for i = 1 to _nCols_
	        _aFirstColumn_ + @aContent[i][1]
	    next
	    _aNewContent_ + [_acNewColNames_[1], _aFirstColumn_]

	    # Remaining columns contain transposed data
	    for i = 1 to _nRows_
	        _aNewRow_ = []
	        for j = 1 to _nCols_
	            _aNewRow_ + @aContent[j][2][i]
	        next
	        _aNewContent_ + [("COL" + (i+1)), _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

		# Raises error R14 today instead of transposing the table while keeping the column names as a first column.
		#
		#   returns    nothing; it raises
		#   warning    Raises R14 because the body calls TansposeXT, a misspelling; TransposeXT
		#              works
		#   see        TransposeXT
		def TransposeWithColNames()
			This.TansposeXT()

	# Restores the table turned by TransposeXT, with its column names and rows.
	#
	#   returns    nothing; the table changes
	#   warning    Raises an error when nothing was transposed, and after a plain Transpose it
	#              leaves columns with no cells
	#   see        TransposeXT, CanTransposeBack
	def TransposeBack()
	    # Only works if table was transposed with headers
	    if len(@aOriginalColNames) = 0
	        raise("Cannot transpose back: no header information found")
	    ok

	    # Get data columns (skip first column which contains headers)
	    _aDataColumns_ = []
	    _nContentLen_ = len(@aContent)
	    for i = 2 to _nContentLen_
	        _aDataColumns_ + @aContent[i][2]
	    next

	    # Transpose back
	    _nOriginalCols_ = len(@aOriginalColNames)
	    _nOriginalRows_ = len(_aDataColumns_)

	    _aNewContent_ = []
	    for i = 1 to _nOriginalCols_
	        _aNewRow_ = []
	        for j = 1 to _nOriginalRows_
	            _aNewRow_ + _aDataColumns_[j][i]
	        next
	        _aNewContent_ + [@aOriginalColNames[i], _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

	    # Clear transpose flags
	    @bTransposedWithHeaders = 0
	    @aOriginalColNames = []

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

	# TRUE if the table was turned with TransposeXT and can be restored.
	#
	#   returns    TRUE or FALSE
	#   see        TransposeBack
	def CanTransposeBack()
	    return (@bTransposedWithHeaders and @aOriginalColNames != [])


	  #---------------------#
	 #  UTILITY FUNCTIONS  #
	#---------------------#

	# Returns the text padded with spaces on the right up to a width; a longer text is returned as it is.
	#
	#   _cText_    the text or value to pad
	#   nWidth     the width to reach, in characters
	#   returns    text
	#   see        PadLeft, CenterText
	def PadRight(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_cText_ = @@(_cText_)
		ok

		# Pad text to the right
		_cStr_ = "" + _cText_
		_nPad_ = nWidth - stzlen(_cStr_)
		if _nPad_ > 0
			return _cStr_ + RepeatChar(" ", _nPad_)
		else
			return _cStr_
		ok

	# Returns the text padded with spaces on the left up to a width; a longer text is returned as it is.
	#
	#   _cText_    the text or value to pad
	#   nWidth     the width to reach, in characters
	#   returns    text
	#   warning    A list as the text raises R21, because the body stores its written form in the
	#              wrong variable
	#   see        PadRight, CenterText
	def PadLeft(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_text_ = @@(_cText_)
		ok

		# Pad text to the left
		_cStr_ = "" + _cText_
		_nPad_ = nWidth - stzlen(_cStr_)
		if _nPad_ > 0
			return RepeatChar(" ", _nPad_) + _cStr_
		else
			return _cStr_
		ok

	# Returns the text centred in a width with spaces, the extra space going to the right.
	#
	#   _cText_    the text or value to centre
	#   nWidth     the width to reach, in characters
	#   returns    text
	#   see        PadRight, PadLeft
	def CenterText(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_cText_ = Q(_cText_).Stringified()
		ok

		# Center text within width
		_cStr_ = "" + _cText_
		_nPadTotal_ = nWidth - stzlen(_cStr_)
		if _nPadTotal_ <= 0
			return _cStr_
		ok

		_nPadLeft_ = floor(_nPadTotal_ / 2)
		_nPadRight_ = _nPadTotal_ - _nPadLeft_

		return RepeatChar(" ", _nPadLeft_) + _cStr_ + RepeatChar(" ", _nPadRight_)

	# Returns a text made of a character repeated a number of times.
	#
	#   nCount     how many times to repeat the character
	#   cChar      the character to repeat
	#   returns    text
	#   see        PadRight
	def StrFill(nCount, cChar)

		# Create string of repeated character
		_cResult_ = ""
		for i = 1 to nCount
			_cResult_ += cChar
		next
		return _cResult_

	  #======================================================================#
	 #  IMPORTING TABLE CONTENT FROM AN EXTERNAL STRING (CSV, JSON OR HTML)  #
	#========================================================================#

	# Returns the table as CSV text, a header line of column names then one line per row, separated by semicolons.
	#
	#   returns    text, the CSV
	#   see        FromCSV
	def ToCSV()
		return ListToCSV(This.Content())

	def ToCSVXT(pcSep)
		return ListToCSVXT(This.Content(), pcSep)

	# Replaces the table, in place, by the content of CSV text whose first line holds the column names and fields are separated by semicolons.
	#
	#   pcCSV      the CSV text
	#   returns    nothing; the table changes
	#   warning    Raises an error when the text is not CSV; commas do not split fields, so the
	#              whole line becomes one column
	#   see        ToCSV
	#---
	def FromCSV(pcCSV)
		This.UpdateWith(CSVToList(pcCSV))

		# Replaces the table, in place, by the content of CSV text whose first line holds the column names and fields are separated by semicolons.
		#
		#   pcCSV      the CSV text
		#   returns    nothing; the table changes
		#   see        FromCSV
		def FromCSVString(pcCSV)
			This.FromCSV(pcCSV)

	def FromCSVXT(pcCSV, pcSep)
		This.UpdateWith(CSVToListXT(pcCSV, pcSep))

		def FromCSVStringXT(pcCSV, pcSep)
			This.FromCSVXT(pcCSV, pcSep)

	# Returns the table as compact JSON, an object of column names with their lists of cells.
	#
	#   returns    text, the JSON
	#   see        FromJson
	#@ aka  --
	def ToJSON() # Compact Json (without NL and TAB indendtaion)
		return ListToJson(This.Content())

	def ToJsonXT() # Json with NL and TAB-indentation
		return ListToJsonXT(This.Content())

	# Replaces the table, in place, by JSON text that is an object of column names with lists of cells.
	#
	#   pcJsonStr   the JSON text
	#   returns     nothing; the table changes
	#   warning     Raises an error when the text is not JSON or is not an object of columns
	#   see         ToJSON
	def FromJson(pcJsonStr) #TODO Test it
		if NOT isString(pcJsonStr)
			StzRaise("Incorrect param type! pcJsonStr must be a string.")
		ok

		if NOT @IsJson(pcJsonStr)
			StzRaise("Can't proceed! This string you provided is not in JSON.")
		ok

		_aData_ = JsonToList(pcJsonStr)
		if Not ( @IsHashList(_aData_) and @IsTable(_aData_) )
			StzRaise("Can't proceed! The Json structure does not correspond to a stzTable structure.")
		ok

		This.UpdateWith(_aData_)

	# Raises error R24 today instead of returning the table as an HTML table.
	#
	#   returns    nothing; it raises
	#   warning    Raises R24 because ToHtmlXT reads a variable named data that is never set
	#   see        ToCSV
	#---
	def ToHtml()
		return @Simplify(This.ToHtmlXT())

		def ToHtmlTable()
			return This.ToHtml()

	def ToHtmlXT()
	    _aContent_ = @aContent
	    if len(_aContent_) = 0
	        return '<table class="data"><thead><tr></tr></thead><tbody></tbody></table>'
	    ok

	    # Ensure all columns have exactly the same number of values
	    # This is critical for the buggy parser
	    _nLen_ = len(_aContent_)
	    _nRows_ = 0
	    for i = 1 to _nLen_
	        if len(_aContent_[i][2]) > _nRows_
	            _nRows_ = len(_aContent_[i][2])
	        ok
	    next

	    # Pad shorter columns with empty strings to match longest column
	    for i = 1 to _nLen_
	        while len(_aContent_[i][2]) < _nRows_
	            _aContent_[i][2] + ""
	        end
	    next

	    _cHtml_ = '<table class="data" id="products">' + nl
	    _cHtml_ += '<thead>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '<tr>' + nl

	    # Generate header row - ensure format matches parser expectations
	    for i = 1 to _nLen_
	        _cHtml_ += '            ' + '<th scope="col">' + data[i][1] + '</th>' + nl
	    next

	    _cHtml_ += '</tr>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '</thead>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '<tbody>' + nl
	    _cHtml_ += nl

	    # Generate body rows - use exact format the parser expects
	    for nRowIndex = 1 to _nRows_
	        _cHtml_ += '<tr class="row">' + nl

	        # For each column, get the value at this row index
	        for nColIndex = 1 to _nLen_
	            _cValue_ = _aContent_[nColIndex][2][nRowIndex]
	            _cHtml_ += '        ' + '<td>' + _cValue_ + '</td>' + nl
	        next

	        _cHtml_ += nl
	        _cHtml_ += '</tr>' + nl
	        _cHtml_ += nl
	    next

	    _cHtml_ += '</tbody>' + nl
	    _cHtml_ += '</table>' + nl
			return _cHtml_

		def ToHtmlTableXT()
			return This.ToHtmlXT()


	# Raises error R14 today instead of replacing the table by the content of an HTML table.
	#
	#   pcHtmlTable   the HTML text of a table
	#   returns       nothing; it raises
	#   warning       Raises R14 because HtmlToTable is defined nowhere
	#   see           FromCSV
	def FromHtml(pcHtmlTable)

		if NOT isString(pcHtmlTable)
			StzRaise("Incorrect param type! pcHtmlTable must be a string.")
		ok

		This.UpdateWith(StzStringQ(pcHtmlTable).HtmlToTable())
