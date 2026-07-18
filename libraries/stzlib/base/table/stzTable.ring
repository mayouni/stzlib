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
		return FALSE
	ok

	try
		new stzTable(paTable)
		return TRUE
	catch
		return FALSE
	done

	func @IsTable(paTable)
		return IsTable(paTable)


  /////////////////
 ///   CLASS   ///
/////////////////

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
	@pEngine = NULL
	@bEngineStale = TRUE

	# Define border characters (initialized in init())
	@aBorder = []

	# Attributes used by the Transpose() method

	@bTransposedWithHeaders = FALSE # tracks when headers were preserved during transpose
	@aOriginalColNames = [] # stores the original column names internally

	# Build the table from rows (the first row may carry the column
	# names).
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

		_oParam_ = Q(paTable)

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

		but _oParam_.ItemsAreListsOfSameSize() and
		    @IsListOfStrings(paTable[1])

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

		but _oParam_.ItemsAreListsOfSameSize() and
		    _oParam_.IsNotHashList()

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


			insert(paTable, 0, _acColNames_)
			This.Init(paTable)
			return

		but _oParam_.IsHashList()
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

	# The lowercase class name: "stztable".
	def ClassName()
		return "stztable"

		# Same as ClassName.
		def KlassName()
			return "stztable"

	# The raw table rows.
	def Content()
		_aContent_ = @aContent # A deep copy to avoid reference propagation
		return _aContent_

		# Same as Content.
		def Table()
			return This.Content()

			# The table content, chainable form.
			def TableQ()
				return new stzList( This.Table() )

		# The raw table rows (same as Content).
		def Value()
			return Content()


	# A new stzTable with the same rows.
	def Copy()

		_aCopy_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			_aCopy_ + @aContent[_i_]
		next

		_oCopy_ = new stzTable(_aCopy_)
		return _oCopy_

	# TRUE if the table has no data.
	def IsEmpty()
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 1
		ok
		for _i_ = 1 to _nLen_
			_aCol_ = @aContent[_i_][2]
			_nColLen_ = len(_aCol_)
			for j = 1 to _nColLen_
				if _aCol_[j] != NULL
					return 0
				ok
			next
		next
		return 1

	  #================================================#
	 #   CHECHKING IF THE TABLE HAS GIVEN COLUMN(S)   #
	#================================================#

	def HasColumName(pcName)

		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		# Column names are stored as given (often upper-cased). The old
		# code lowercased the query then did a case-SENSITIVE Contains,
		# so it never matched -- HasCol always returned FALSE. Compare
		# case-insensitively against the stored names instead.
		_bResult_ = This.ColNamesQ().ContainsCS(pcName, FALSE)

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

		# --- Aggregation layer, exposed on the base -----------------------
		# stzTable is the class users instantiate; the aggregation methods are
		# defined on the stzTableAggregator SUBCLASS, so a bare stzTable would
		# miss them. We expose them here (same forwarder pattern as Show ->
		# stzTableDisplay). The heavy compute -- calc columns, column aggregates
		# -- delegates to a throwaway aggregator built from this table's content,
		# while the calc-col STATE (@anCalculatedCols) lives on, and is read from,
		# THIS object so it persists across calls. The query methods read that
		# state directly via Col/ColName, which also sidesteps two latent bugs in
		# the aggregator's own versions: a `new X().Method()` R13 in its
		# FindCalculatedCols, and a CalculatedCols that calls TheseCols (defined
		# on the sibling stzTableSubset, unreachable from the aggregator). The
		# real fix is the table-hierarchy refactor noted near the forwarders
		# below; this keeps the public surface working meanwhile.

		def FindCalculatedCols()
			_oCc_ = new stzList(@anCalculatedCols)
			return _oCc_.Sorted()

			def FindCalculatedColumns()
				return This.FindCalculatedCols()

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

		def FindCalculatedRows()
			_oCr_ = new stzList(@anCalculatedRows)
			return _oCr_.Sorted()

			def FindCalculatedRowsPositions()
				return This.FindCalculatedRows()

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

	def IsColName(pcName)

		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		if This.FindCol(pcName) > 0
			return TRUE
		else
			return FALSE
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

	def AreColNamesOrNumbers(paCols)
		_oTemp_ = Q(paCols)

		if NOT ( isList(paCols) and
			( _oTemp_.IsListOfNumbers() or
			  _oTemp_.IsListOfStrings() or
			  _oTemp_.IsListOfNumbersAndStrings() ) )

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

	def ColToColNumber(pCol)
		if isNumber(pCol)
			return pCol
		ok
		return This.FindCol(pCol)

	def NumberOfRows()
		if len(@aContent) = 0
			return 0
		ok
		return len(@aContent[1][2])

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

	def Row(pnRow)
		_aResult_ = []
		_nCols_ = len(@aContent)
		for _i_ = 1 to _nCols_
			_aResult_ + @aContent[_i_][2][pnRow]
		next
		return _aResult_

	def Cell(pCol, pnRow)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		return @aContent[_n_][2][pnRow]

	def NumberOfCells()
		return This.NumberOfColumns() * This.NumberOfRows()

	def NthColName(_n_)
		return @aContent[_n_][1]

	def FirstColName()
		return This.NthColName(1)

	def LastColName()
		return This.NthColName(This.NumberOfColumns())

	def LastRow()
		return This.Row(This.NumberOfRows())

	def Rows()
		_aResult_ = []
		_nRows_ = This.NumberOfRows()
		for _i_ = 1 to _nRows_
			_aResult_ + This.Row(_i_)
		next
		return _aResult_

	def ReplaceRow(pnRow, paNewRow)
		_nCols_ = len(@aContent)
		for _i_ = 1 to _nCols_
			@aContent[_i_][2][pnRow] = paNewRow[_i_]
		next
		This._InvalidateEngine()

	def ReplaceCell(pCol, pnRow, pValue)
		_n_ = This.FindCol(pCol)
		if _n_ = 0
			StzRaise("Column not found!")
		ok
		@aContent[_n_][2][pnRow] = pValue
		This._InvalidateEngine()

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
		if @pEngine = NULL or @bEngineStale
			if @pEngine != NULL
				StzEngineTableFree(@pEngine)
			ok

			@pEngine = StzEngineTableNew()

			# ONE bulk call. This used to add each column, then each row, then
			# SET EVERY CELL individually -- O(rows x cols) FFI calls (300k for
			# a 50k x 6 table). The engine now reads the whole content list in
			# a single call.
			StzEngineTableFill(@pEngine, @aContent)

			@bEngineStale = FALSE
		ok

	def _InvalidateEngine()
		@bEngineStale = TRUE

	def _SyncFromEngine()
		# ONE bulk call. This used to read EVERY CELL with GetCellType +
		# GetCell* -- 2 FFI calls per cell (600k for a 50k x 6 table). The
		# engine now builds the whole Ring content list in a single call.
		@aContent = StzEngineTableContent(@pEngine)
		@bEngineStale = FALSE

	def _FreeEngine()
		if @pEngine != NULL
			StzEngineTableFree(@pEngine)
			@pEngine = NULL
		ok

	# The engine handle of the table's backing store.
	def EngineHandle()
		This._EnsureEngine()
		return @pEngine

	  #=========================================#
	 #  STRUCTURAL OPERATIONS (from submodule) #
	#=========================================#

	def RemoveNthCol(_n_)
		if This.NumberOfCols() = 1
			@aContent = [ [ :COL1, [ "" ] ] ]
			return
		ok
		ring_remove(@aContent, _n_)

		def RemoveColAt(_n_)
			This.RemoveNthCol(_n_)

	def RemoveColumn(pColNameOrNumber)
		_nRcCol_ = This.ColToColNumber(pColNameOrNumber)
		if _nRcCol_ = 0
			StzRaise("Column not found!")
		ok
		This.RemoveNthCol(_nRcCol_)

		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	  #================================================#
	 #  CASTING TO PIVOT TABLE (from submodule)       #
	#================================================#

	#NOTE // stzPivotTable belongs to the MAX layer of StzLib
	# For the following method to work, you must load "stzMax.ring"

	def ToStzPivotTable()
		return new stzPivotTable(This)

	  #=========================================#
	 #  DISPLAY OPERATIONS (from submodule)    #
	#=========================================#

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

		def AddCol(pacColNameAndData)
			This.AddColumn(pacColNameAndData)

	# Word-order alias used by narrative tests.
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
		_aRowsLocal_ = This.Rows()
		_nLenRowsLocal_ = len(_aRowsLocal_)
		_aResultLocal_ = []
		for _iFrLocal_ = 1 to _nLenRowsLocal_
			if _aRowsLocal_[_iFrLocal_] = paRow
				_aResultLocal_ + _iFrLocal_
			ok
		next
		return _aResultLocal_

		def FindRow(paRow)
			return This.FindRowCS(paRow, 1)

	# FindInCol(pCol, pValueOrSubvalue) -- look up positions in a
	# single column where the cell equals pValue or contains pSubValue.
	# Accepts bare value or :Value = / :SubValue = named-param forms.
	def FindInCol(pCol, pValueOrNamed)
		return This.FindInColCS(pCol, pValueOrNamed, 1)

	def FindInColCS(pCol, pValueOrNamed, pCaseSensitive)
		# Strip a trailing :CS=... if the caller bundled three args.
		_pValue_ = pValueOrNamed
		_bSub_ = FALSE
		if isList(_pValue_) and len(_pValue_) = 2 and isString(_pValue_[1])
			_cKey_ = lower(_pValue_[1])
			if _cKey_ = "value"
				_pValue_ = _pValue_[2]
			but _cKey_ = "subvalue"
				_pValue_ = _pValue_[2]
				_bSub_ = TRUE
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
			_bMatch_ = FALSE
			if _bSub_
				if isString(_cell_) and isString(_pValue_)
					if pCaseSensitive
						if StzFindFirst(_cell_, _pValue_) > 0 _bMatch_ = TRUE ok
					else
						# StzCaseFold is codepoint-aware; upper() is byte-oriented
						# and missed multibyte case (accented cells).
						if StzFindFirst(StzCaseFold(_cell_), StzCaseFold(_pValue_)) > 0 _bMatch_ = TRUE ok
					ok
				ok
			else
				if pCaseSensitive
					if _cell_ = _pValue_ _bMatch_ = TRUE ok
				else
					if isString(_cell_) and isString(_pValue_)
						if StzCaseFold(_cell_) = StzCaseFold(_pValue_) _bMatch_ = TRUE ok
					else
						if _cell_ = _pValue_ _bMatch_ = TRUE ok
					ok
				ok
			ok
			if _bMatch_ _aRes_ + _iFcLocal_ ok
		next
		return _aRes_

	# ContainsCell(pCol, pValue) -- TRUE if any cell in column pCol
	# equals pValue.
	def ContainsCell(pCol, pValue)
		return len(This.FindInCol(pCol, pValue)) > 0

		def ContainsCellInCol(pCol, pValue)
			return This.ContainsCell(pCol, pValue)

	# NumberOfOccurrenceInCol -- count cells in column pCol matching
	# pValueOrNamed. Accepts bare value / :Value / :OfValue / :OfSubValue.
	def NumberOfOccurrenceInCol(pCol, pValueOrNamed)
		return len(This.FindInCol(pCol, _NormalizeColLookupKey(pValueOrNamed)))

		def NumberOfOccurrencesInCol(pCol, pValueOrNamed)
			return This.NumberOfOccurrenceInCol(pCol, pValueOrNamed)

		def NumberOfOccurrenceInColumn(pCol, pValueOrNamed)
			return This.NumberOfOccurrenceInCol(pCol, pValueOrNamed)

	# NumberOfOccurrenceInRow(nRow, pValue) -- count cells in row nRow
	# matching pValue. Walks each column at row index nRow.
	def NumberOfOccurrenceInRow(nRow, pValue)
		_pVal_ = _NormalizeColLookupKey(pValue)
		_bSub_ = FALSE
		if isList(pValue) and len(pValue) = 2 and isString(pValue[1]) and
		   lower(pValue[1]) = "ofsubvalue"
			_bSub_ = TRUE
		ok
		_nCount_ = 0
		_nCols_ = This.NumberOfCols()
		for _i_ = 1 to _nCols_
			_cell_ = @aContent[_i_][2][nRow]
			if _bSub_
				if isString(_cell_) and isString(_pVal_)
					if StzFindFirst(_cell_, _pVal_) > 0 _nCount_++ ok
				ok
			else
				if _cell_ = _pVal_ _nCount_++ ok
			ok
		next
		return _nCount_

		def NumberOfOccurrencesInRow(nRow, pValue)
			return This.NumberOfOccurrenceInRow(nRow, pValue)

	# NumberOfOccurrenceInCell(nCol, nRow, pValue) -- check just the
	# single cell at [nCol, nRow]. Returns 0 or 1 (1 if it matches).
	def NumberOfOccurrenceInCell(nCol, nRow, pValue)
		_pVal_ = _NormalizeColLookupKey(pValue)
		_bSub_ = FALSE
		if isList(pValue) and len(pValue) = 2 and isString(pValue[1]) and
		   lower(pValue[1]) = "ofsubvalue"
			_bSub_ = TRUE
		ok
		_cell_ = @aContent[nCol][2][nRow]
		if _bSub_
			if isString(_cell_) and isString(_pVal_) and StzFindFirst(_cell_, _pVal_) > 0
				return 1
			ok
			return 0
		ok
		if _cell_ = _pVal_ return 1 ok
		return 0

	# NumberOfOccurrenceInCols(acCols, pValue) -- sum across the
	# listed columns.
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

	# Fill(pValue) -- replace every cell in the table with pValue.
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

	# FillSections(aSections, :With = value) -- replace cells in the
	# given [colIdx, rowIdx] section pairs. Accepts the :With named
	# param or a bare value as 2nd arg.
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

	# RemoveCols(acColsOrNumbers) -- remove every column whose name
	# or 1-based number is listed.
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

		def CellAndPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

		def CellAndItsPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

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

	def Cells()

		_aResult_ = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
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

	def PositionsAndTheseCells(paCells)
		_aResult_ = []
		_nCells_ = len(paCells)

		for i = 1 to _nCells_
			_aCell_ = paCells[i]
			_aResult_ + [ _aCell_, This.Cell(paCells[1], paCells[2]) ]
		next

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS BY TRANSFORMING IT TO A HASHLIST  #
	#------------------------------------------------------------------#

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

		# Doing the job

		_nCol1_ = panCellPos1[1]
		_nRow1_ = panCellPos1[2]

		_nCol2_ = panCellPos2[1]
		_nRow2_ = panCellPos2[2]

		_aResult_ = []

		# If only one column is concerned

		if _nCol1_ = _nCol2_
			for j = _nRow1_ to _nRow2_
				_aResult_ + [ _nCol1_, j ]
			next

			return _aResult_
		ok

		# If the sections span mote then one column

		_nRows_ = This.NumberOfRows()

		# Adding the first column

		for j = _nRow1_ to _nRows_
			_aResult_ + [ _nCol1_, j ]
		next

		_nCols_ = len( @aContent )
		if _nCols_ = 1
			return
		ok

		# Adding all the cells except the first and last columns

		if _nCols_ > 2

			for i = (_nCol1_ + 1) to (_nCol2_ - 1)
				for j = _nRow1_ to _nRows_
					_aResult_ + [ i, j ]
				next
			next

		ok

		# Adding the remaining cells in the last column

		for j = 1 to _nRow2_
			_aResult_ + [ _nCol2_, j ]
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

	def ColSection(pCol, _n1_, _n2_)

		_aCellsPos_ =  This.ColSectionAsPositions(pCol, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		def ColumnSection(pCol, _n1_, _n2_)
			return This.ColSection(pCol, _n1_, _n2_)

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

	def CellsInColSectionZ(_nCol_, _n1_, _n2_)
		_anCellsPos_ = This.FindCellsInColSection(_nCol_, _n1_, _n2_)
		_aCells_ = This.CellsAtPositions(_anCellsPos_)
		_aResult_ = Association([ _aCells_, _anCellsPos_ ])

		return _aResult_

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#====================================================#

	def RowSection(_nRow_, _n1_, _n2_)
		_aCellsPos_ =  This.RowSectionAsPositions(_nRow_, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInRowSection(_nRow_, _n1_, _n2_)
			return This.RowSection(_nRow_, _n1_, _n2_)

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

	def SectionToRange(_n1_, _n2_) // TODO
		StzRaise("Feature not implemented yet!")

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

	def CellsInCols(paCols)

		if NOT ( isList(paCols) and
			Q(paCols).IsListOfNumbersOrStrings() and
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

	def CellsInRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers.")
		ok

		_aResult_ = This.TheseCells(RowsAsPositions(panRows))
		return _aResult_

	  #-----------------------#
	 #   GETTING FIRST ROW   #
	#-----------------------#

	def FirstRow()
		return This.NthRow(1)

	def FirstRowXT()
		return This.NthRowXT(1)

	  #----------------------#
	 #   GETTING LAST ROW   #
	#----------------------#

	def LastRowXT()
		return This.NthRowXT(This.NumberOfRows())

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

		def CellsInRowNAndTheirPositions(_n_)
			return This.RowZ(p)

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

		def CellsAndPositionsInNthRow(_n_)
			return This.RowZ(p)

			def CellsAndPositionsInNthRowQ(_n_)
				return This.CellsAndPositionsInNthRowQRT(_n_, :stzList)

			def CellsAndPositionsInNthRowQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsInNthRowAndTheirPositions(_n_)
			return This.RowZ(p)

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

			def NtRowZQ(_n_)
				return This.NthRowZQRT(_n_, :stzList)

			def NthRowZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		#>

	  #-------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN ROW   #
	#-------------------------------------------------------#

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

		#>

	def AddColumns(pacColNamesAndData)
		_nLen_ = len(pacColNamesAndData)

		for i = 1 to _nLen_
			This.AddColumn(pacColNamesAndData[i])
		next

		def AddCols(pacColNamesAndData)
			This.AddColumns(pacColNamesAndData)

	  #===============#
	 #  ADDING ROWS  #
	#===============#

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

	def Extend(_nCol_, _nRow_)

		/* ... */
		StzRaise("Unsupported feature in this release!")

		def ExtendTo(_nCol_, _nRow_)

	  #======================#
	 #  UPDATING THE TABLE  #
	#======================#

	def Update(paNewTable)
		if CheckingParams() = 1
			if isList(paNewTable) and StzIsWithOrByOrUsingNamedParamList(paNewTable)
				paNewTable = paNewTable[2]
			ok

			# Validate DIRECTLY on paNewTable. This used to read
			#     Q(paNewTable).IsHashList() and
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
						_bValidUp_ = FALSE
						exit
					ok

					_nKeysUp_ = len(_acKeysUp_)
					for _jUp_ = 1 to _nKeysUp_
						if _acKeysUp_[_jUp_] = _pUp_[1]
							_bValidUp_ = FALSE
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
						_bValidUp_ = FALSE
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

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(paNewTable)
			This.Update(paNewTable)

			def UpdateWithQ(paNewTable)
				return This.UpdateQ(paNewTable)

		def UpdateBy(paNewTable)
			This.Update(paNewTable)

			def UpdateByQ(paNewTable)
				return This.UpdateQ(paNewTable)

		def UpdateUsing(paNewTable)
			This.Update(paNewTable)

			def UpdateUsingQ(paNewTable)
				return This.UpdateQ(paNewTable)

		#>

	def Updated(paNewTable)
		return paNewTable

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

	def RenanmeCol(pCol, pcNewName)

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(pCol)

			if StzFindFirst(pCol, [ :First, :FirstCol, :FirstColumn ]) > 0
				pCol = 1

			but StzFindFirst(pCol, [ :First, :FirstCol, :FirstColumn ]) > 0
				pCol = This.NumberOfCols()

			but This.HasColName(pCol)
				pCol = This.ColToColNumber(pCol)

			else
				StzRaise("Incorrect value! Allowed values :FirstCol, :LastCol, or use a number instead.")
			ok
		ok

		This.RenameColN(pCol, pcNewName)

	def RenameCols(paColsAndTheirNewNames)

		if NOT (isList(paColsAndTheirNewNames) and Q(paColsAndTheirNewNames).IsHashList())
			StzRaise("Incorrect param type! paColsAndTheirNewNames must be a hashlist.")
		ok

		_nLen_ = len(paColsAndTheirNewNames)

		for i = 1 to _nLen_
			This.RenameCol(paColsAndTheirNewNames[i][1], paColsAndTheirNewNames[i][2])
		next

	def RenameNthCol(_n_, pcNewName)
		if isList(pcNewName) and Q(pcNewName).IsWithOrByNamedParam()
			pcNewName = pcNewName[2]
		ok

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		@aContent[_n_][1] = pcNewName

		def RenameColN(_n_, pcNewName)
			This.RenameNthCol(_n_, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		_nLen_ = len(panColsNumbers)

		for i = 1 to _nLen_
			This.RenameColN(panColsNumbers[i])
		next

	def RenameFirstCol(pcNewName)
		This.RenameNthCol(1, pcNewName)

	def RenameLastCol(pcNewName)
		This.RenameNthCol(:Last, pcNewName)

	  #=====================#
	 #  REMOVING A COLUMN  #
	#=====================#

		def RemoveNthColumn(_n_)
			This.RemoveNthCol(_n_)

		def RemoveColumnAt(_n_)
			This.RemoveNthCol(_n_)

	def RemoveColumnsAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		_anColNumbers_ = new stzList( U(TpacColNamesOrNumbers) ).Sorted()
		_nLen_ = len(_anColNumbers_)

		_aContent_ = @aContent

		for i = _nLen_ to 1 step -1
			ring_remove(_aContent_, _anColNumbers_[i])
		next

		This.UpdateWith(_aContent_)



		def RemoveColsAt(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthCols(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthColumns(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

	def RemoveAllColsExceptAt(panColNumbers)
		This.RemoveAllColsExcept(paColNumbers)

		#< @FunctionAlternativeForms

		def RemoveColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#--

		def RemoveColsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#--

		def RemoveAllColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#>

	def RemoveAllColsExcept(paCols)
		if CheckingParams()
			if NOT ( isList(paCols) and Q(paCols).IsListOfNumbersOrStrings() )
				StzRaise("Incorrect param type! panRows must be a list of numbers or strings.")
			ok
		ok

		_anPos_ = This.FindColsExcept(paCols)
		This.RemoveCols(_anPos_)

		#< @FunctionAlternativeForms

		def RemoveColsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveAllColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#--

		def RemoveAllColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveAllColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#>

	  #---------------------------------------------#
	 #  REMOVING ALL THE COLUMNS AND ALL THE ROWS  #
	#=============================================#

	def RemoveAll()
		This.UpdateWith([ :COL1 = [ "" ] ])

		def RemoveAllCols()
			This.RemoveAll()

		def RemoveAllColumns()
			This.RemoveAll()

	  #------------------------#
	 #  REMOVING A GIVEN ROW  #
	#========================#

	def RemoveRow(pRowOrRowNumber)
		if CheckingParams()
			if NOT ( isNumber(pRowOrRowNumber) or isList(pRowOrRowNumber) )
				StzRaise("Incorrect param type! pRowOrRowNumber must be a number or list.")
			ok
		ok

		if isNumber(pRowOrRowNumber)
			This.RemoveNthRow(pRowOrRowNumber)

		else
			_n_ = This.FindRow(pRowOrRowNumber)[1]
			This.RemoveNthRow(_n_)
		ok

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


		def RemoveRowAt(_n_)
			This.RemoveNthRow(_n_)

		def RemoveRowNumber(_n_)
			This.RemoveNthRow(_n_)

		def RemoveRowN(_n_)
			This.RemoveNthRow(_n_)

	  #---------------------------#
	 #  REMOVING THE GIVEN ROWS  #
	#---------------------------#

	def RemoveNthRows(panRows)

		if CheckingParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_aContent_ = @aContent
		_nLen_ = len(_aContent_)
		_anPos_ = new stzList( U(panRows) ).Sorted()
		_nLenPos_ = len(_anPos_)

		for i = _nLen_ to 1 step -1
			for j = 1 to _nLen_
				ring_remove(_aContent_[j][2], _anPos_[i])
			next
		next

		This.UpdateWith(_aContent_)


		def RemoveRowsAt(panRows)
			This.RemoveNthRows(panRows)

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

	def RemoveAllRowsExceptAt(panRows)
		if CheckingParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_anPos_ = This.FindRowsExceptAt(panRows)
		This.RemoveRows(_anPos_)

		#< @FunctionAlternativeForms

		def RemoveRowsExceptAt(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		def RemoveAllRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		def RemoveRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

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
			This.RemoveRowsAt(pRowsOrRowsNumbers)

		else // @IsListOfLists(pRowsOrRowsNumbers)

			_anPos_ = This.FindRowsExceptThese(pRowsOrRowsNumbers)
			This.RemoveRowsAt(_anPos_)
		ok


		#< @FunctionAlternativeForms

		def RemoveRowsExcept(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		def RemoveAllRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		def RemoveRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		#>

	  #=====================#
	 #  ERASING THE TABLE  #
	#=====================#

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


		def EraseTable()
			This.Erase()

	  #-------------------#
	 #  ERASING COLUMNS  #
	#-------------------#

	def EraseColumn(pColNameOrNumber)
		_aCellsPos_ = This.ColAsPositions(pColNameOrNumber)
		This.EraseCells(_aCellsPos_)

		def EraseCol(pColNameOrNumber)
			This.EraseColumn(pColNameOrNumber)

	def EraseColumns(pcColNamesOrNumbers)
		_nCols_ = This.TheseColsToColsNumbers(pcColNamesOrNumbers)

		_nCols1Len_ = len(_nCols_)
		for _iLoopCols1_ = 1 to _nCols1Len_
			_n_ = _nCols_[_iLoopCols1_]
			This.EraseCol(_n_)
		next

		def EraseCols(pcColNamesOrNumbers)
			This.EraseColumns(pcColNamesOrNumbers)

	  #----------------#
	 #  ERASING ROWS  #
	#----------------#

	def EraseRow(_n_)
		_aCellsPos_ = This.RowAsPositions(_n_)
		This.EraseCells(_aCellsPos_)

	def EraseRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
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


		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

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


		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	  #------------------------------#
	 #  ERASING A SECTION OF CELLS  #
	#------------------------------#

	def EraseSection(paCellPos1, paCellPos2)
		_aCellsPso_ = This.SectionAsPositions()
		This.EraseCells(_aCellsPos_)

	  #======================#
	 #  INSERTING A COLUMN  #
	#======================#

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
			This.InsertColAtPositions(_n_, paRowData)
			return
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

		# Adding the column

		_aContent_ = @aContent
		@aContent + [ _cColName_, _aColData_ ]
		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForms

		def InsertColBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#--

		def insertColAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#==

		def InsertColumn(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#--

		def insertColumnAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#>

	def InsertColAfter(_n_, paRowData)
		This.InsertColAt(_n_+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertColAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		#--

		def InsertColumnAfter(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		def InsertColumnAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		#>

	  #===================#
	 #  INSERTING A ROW  #
	#===================#

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



		#< @FunctionAlternativeForms

		def InsertRowBefore(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		def InsertRowBeforePosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		#--

		def insertRowAt(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		def InsertRowAtPosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		#>

	def InsertRowAfter(_n_, paRowData)
		This.InsertRowAt(_n_+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertRowAfterPosition(_n_, paRowData)
			This.InsertRowAfter(_n_, paRowData)

		#>

	  #-------------------------------------#
	 #  INSERTING A ROW IN MANY POSITIONS  #
	#-------------------------------------#

	def InsertRowAtPositions(panPos, paRow)
		if CheckingParams()
			if NOT ( isList(panPos) and @isListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_anPos_ = new stzList( U(panPos) ).Sorted()
		_nLen_ = len(_anPos_)

		for i = _nLen_ to 1 step -1
			This.InsertRowAtPosition(panPos[i], paRow)
		next

		def InsertRows(panPos, paRow)
			This.InsertRowAtPositions(panPos, paRow)

		def InsertRowsAt(panPos, paRow)
			InsertRowAtPositions(panPos, paRow)

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

	def TheseColumns(pacColNamesOrNumbers)
		if NOT 	( isList(pacColNamesOrNumbers) and
			  ( Q(pacColNamesOrNumbers).IsListOfNumbers() or
			  Q(pacColNamesOrNumbers).IsListOfStrings() ) )

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

	def TheseColNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsListOfNumbers() )
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

		panColNumbers  = new stzList(panColNumbers).Sorted()
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

	def cColNamesToNumbers(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
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

	def SubTable(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
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

	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers() )

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
		if NOT (isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers())
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


		#< @FunctionAlternativeForm

		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

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


		#< @FunctionAlternativeForm

		def SwapColumnNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

		def SwapColumnsNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

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

		def SwapColums(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		#< @FunctionAlternativeForm

		def SwapColum(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		def SwapCols(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		def SwapColumns(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		#>

	  #=============================#
	 #   REPLACING A COLUMN NAME   #
	#=============================#

	def ReplaceNthColName(_n_, pcNewColName)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.ReplaceColName(_n_, pcNewColName)

	def ReplaceColName(pCol, pcNewColName)
		if isList(pcNewColName) and Q(pcNewColName).IsWithOrByNamedParam()
			pcNewColName = pcNewColName[2]
		ok

		if NOT isString(pcNewColName)
			StzRaise("Incorrect param type! pcNewColName must be a string.")
		ok

		if This.IsColName(pcNewColName)
			StzRaise("Can't replace the column with this name (" + pcNewColName + ")! Name you provided already exists.")
		ok

		_aContent_ = @aContent
		_n_ = This.ColNumber(pCol)
		@aContent[_n_][1] = pcNewColName
		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForm

		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

		#>

	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
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

		#< @FunctionAlternativeForm

		def AreColumnNames(pacColNames)
			This.AreColNames(pacColNames)

		def AreColumnsNames(pacColNames)
			This.AreColNames(pacColNames)

		#>

	def FindColsByName(pacColNames)

		if CheckingParams()

			if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
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

	#-- WITHOUT CASESENSITIVITY

	def FindColByValue(paColData)
		return This.FindColByValueCS(paColData, 1)

		def FindColumnByValue(paColData)
			return This.FindColByValue(paColData)

	  #----------------------------------#
	 #  FINDING MANY COLUMNS BY VALUES  #
	#----------------------------------#

	def FindColsByValueCS(paManyColData, pCaseSensitive)

		if CheckingParams()

			if NOT ( isList(paManyColData) and Q(paManyColData).IsListOfLists() )
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

		_anResult_ = new stzList(_anResult_).Sorted()
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

		#>

	#-- WTIHOUT CASESENSITIVITY

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

	def FindColsExceptAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfLists(panColNumbers) )
				StzRaise("Incorrect param type! apnColNumbers must be a list of numbers.")
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

			if NOT ( @IsListOfNumbers(paColNumbersOrColNames) or
				 @IsListOfStrings(paColNumbersOrColNames) )
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list of numbers or a list of strings.")
			ok
		ok

		_anResult_ = Q(1:This.NumberOfCols()) - These( This.FindCols(paColNumbersOrColNames) )
		// #TODO Make a more performant solution!

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

	def FindNthRowCS(paRow, pCaseSensitive)
		_nPos_ = Q(This.Rows()).FindNthCS(parow, pCaseSensitive)
		return _nPos_

		def FindNthOccurrenceOfRowCS(paRow, pCaseSensitive)
			return This.FindNthRowCS(paRow, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthRow(paRow)
		return This.FindNthRowCS(paRow, 1)

		def FindNthOccurrenceOfRow(paRow)
			return This.FindNthRow(paRow)

	  #----------------------------------------#
	 #  FINDINING MANYS ROWS BY THEIR VALUES  #
	#----------------------------------------#

	def FindRowsCS(paRows, pCaseSensitive)
		_anResult_ = Q(This.Rows()).FindManyCS(paRows, pCaseSensitive)
		return _anResult_

		def FindManyRowsCS(paRows, pCaseSensitive)
			return This.FindRowsCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindRows(paRows)
		return This.FindRowsCS(paRows, 1)

		def FindManyRows(paRows)
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

	#-- WITHOUT CASESENSITIVITY

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


	#-- WITHOUT CASESENSITIVITY

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
		#>

	#-- WITHOUT CASESENSITIVITY

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

		_aResult_ = StzListOfListsQ( This.Cols() ).FindInListsCS(pCellValue, pCaseSensitive)
		return _aResult_

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

	#-- WITHOUT CASESENSITIVITY

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
			_nLen_ = len(_aTemp_)

			for j = 1 to _nLen_
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

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubValue(pSubValue)
		return This.FindSubValueCS(pSubValue, 1)

		#< @FuntionAlternativeForm

		def PositionsOfSubValue(pSubValue)
			return This.FindSubValue(pSubValue)

		#>

	  #-------------------------------------------#
	 #  FINFING MANY SUBVALUES INSIDE THE TABLE  #
	#-------------------------------------------#

	def FindSubValuesCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

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

			if _oParam_.IsOfOfTheseNamedParams([
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValue(_n_, pSubValue)
		return This.FindNthSubValueCS(_n_, pSubValue, 1)

		def FindNthOccurrenceOfSubValue(_n_, pSubValueValue)
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

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirst(pCellValueOrSubValue)
		return This.FindFirstCS(pCellValueOrSubValue, 1)
	
		def FindFirstOccurrence(pCellValueOrSubValue)
			return This.FindFirst(pCellValueOrSubValue)	

	  #----------------------------------------#
	 #   FIRST CELL AND LAST CELL POSITIONS   #
	#----------------------------------------#

	def FirstCellPosition()
		return [1, 1]

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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValue(pSubValue)
		return This.FindFirstSubValueCS(pSubValue, 1)

		def FindFirstOccurrenceOfSubValue(pSubValueValue)
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValue(pSubValue)
			return This.FindLastSubValueCS(pSubValue, 1)

			def FindLastOccurrenceOfSubValue(pSubValueValue)
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY
	
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

		if isList(paRow) and len(paRow) = This.NumberOfRows()

			_bResult_ = This.RowsQ().ContainsCS(paRow, pCaseSensitive)
		ok

		return _bResult_

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def ContainsCols(paCols)
		return This.ContainsColsCS(paCols, 1)

		def containsTheseCols(paCols)
			return This.ContainsCols(paCols)

		def ContainsColumns(paCols)
			return This.ContainsCols(paCol)

		def ContainsTheseColumns(paCols)
			return This.ContainsCols(paCol)

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS CELLS THAT INCLUDE A GIVEN SUBVALUE  #
	#----------------------------------------------------------------------#

	def ContainsSubValueCS(pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

	  #---------------------------------------------#
	 #  FINDING A GIVEN VALUE INSIDE A GIVEN CELL  #
	#---------------------------------------------#

	def FindValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :Value = pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCell(pCellCol, pCellRow, pValue)
		return This.FindValueInCellCS(pCellCol, pCellRow, pValue, 1)

	  #------------------------------------------------#
	 #  FINDING A GIVEN SUBVALUE INSIDE A GIVEN CELL  #
	#------------------------------------------------#

	def FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :SubValue = pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN A GIVEN NUMBER OF CELLS  #
	#================================================================================================#

	def FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPairs() )
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

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllInCells(paCells, pCellValueOrSubValue)

		return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def FindAllOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def FindOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def OccurrencesInCells(pCellValueOrSubValue)
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
			return This.FindValueInCellsCS(ppaCells, _cellValue_, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCells(pValue)
		return This.FindValueInCellsCS(pValue, 1)
			
		def OccurrencesOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(paCells, pCellValue)

		def PositionsOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(ppaCells, _cellValue_)
	
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCells(_n_, paCells, pValue)
		return This.FindNthCellCS(_n_, pValue, 1)

		def FindNthOccurrenceOfValueInCells(_n_, paCells, pCellValue)
			return This.FindNthValueInCells(_n_, paCells, pValue)
	
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

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCells(_n_, paCells, pSubValue)
		return This.FindNthSubValueInCellsCS(_n_, paCells, pSubValue, 1)

		def FindNthOccurrenceOfSubValueInCells(_n_, paCells, pSubValueValue)
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
			return This.FFindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCells(paCells, pValue)
		return This.FindFirstValueInCellCS(paCells, pValue, 1)

		def FindFirstOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindFirstValueInCells(paCells, pValue)

	  #------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN THE PROVIDED LIST OF CELLS  #
	#------------------------------------------------------------------------------#

	def FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(1, paCells, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCells(paCells, pSubValue)
		return This.FindFirstSubValueInCellsCS(paCells, pSubValue, 1)

		def FindFirstOccurrenceOfSubValueInCells(paCells, pSubValueValue)
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
			return This.FFindLastnCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCells(paCells, pValue)
		return This.FindLastValueInCellCS(paCells, pValue, 1)

		def FindLastOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindLastValueInCells(paCells, pValue)

	  #-------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN SUBVALUE IN SOME GIVEN CELLS  #
	#-------------------------------------------------------------------#
	
	def FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCells(paCells, pSubValue)
		return This.FindLastSubValueInCellsCS(paCells, pSubValue, 1)

		def FindLasttOccurrenceOfSubValueInCells(paCells, pSubValueValue)
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

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, 1)
	
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pSubValue, 1)

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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def CellsContainSubValue(paCells, pSubValue)
		return This.CellsContainSubValueCS(paCells, pSubValue, 1)

		def ContainsSubValueInCells(paCells, pSubValue)
			return This.CellsContainSubValue(paCells, pSubValue)

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN A GIVEN CELL  #
	#========================================================#

	def FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_anResult_ = _anPos_[_n_]

		#TODO // Implement a more performant alortithm by adding FindNext...()

		return _anResult_

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindNthSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindNthOccurrenceOfSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)
	
		#< @FunctionAlternativeForms

		def CountInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF CELL  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
		_nResult_ = len( This.FindValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive) )
		return _nResult_

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

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

		def ContainsInCellCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.CellContainsCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContains(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

		def ContainsInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.CellContains( pCellCol, pCellRow, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellContainsValueCS( pCellCol, pCellRow, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive) ) > 0
			return 1
		else
			return 0
		ok

		def ContainsValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return This.CellContainValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def CellContainsSubValue(pCellCol, pCellRow, pSubValue)
		return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, 1)

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


		#-- WITHOUT CASESENSITIVITY

		def FindInRow(pRow, pCellValueOrSubValue)
			return This.FindInRowCS(pRow, pCellValueOrSubValue, 1)

	def FindValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInRow(pRow, pCellValue)
			return This.FindValueInRowCS(pRow, pSubValue, 1)

	def FindSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInRow(pRow, pSubValue)
			return This.FindValueInRowCS(pRow, pSubValue, 1)

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

		#-- WITHOUT CASESENSITIVITY

		def FindNthInRow(_n_, pRow, pCellValueOrSubValue)
			return This.FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInRow(_n_, pRow, pCellValueOrSubValue)
				return This.FindNthInRow(_n_, pRow, pCellValueOrSubValue)

	def FindNthValueInRowCS(_n_, pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.RowAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInRow(_n_, pRow, pCellValue)
			return This.FindNthValueInRowCS(_n_, pRow, pCellValue, 1)

			def FindNthOccurrenceOfValueInRow(_n_, pRow, pCellValue)
				return This.FindNthValueInRow(_n_, pRow, pCellValue)

	def FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.RowAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInRow(pRow, pCellValueOrSubValue)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindFirstInRow(pRow, pCellValueOrSubValue)

	def FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInRow(pRow, pCellValue)
			return This.FindFirstValueInRowCS(pRow, pCellValue, 1)

			def FindFirstOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindFirstValueInRow(pRow, pCellValue)

	def FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def FindLastInRow(pRow, pCellValueOrSubValue)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindLastInRow(pRow, pCellValueOrSubValue)

	def FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInRow(pRow, pCellValue)
			return This.FindLastValueInRowCS(pRow, pCellValue, 1)

			def FindLastOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindLastValueInRow(pRow, pCellValue)

	def FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowCS(pRow, pSubValue, 1)

		def FindLastOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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
		return len( This.FindCellInRowCS(pRow, pCellValue, pCaseSensitive) )

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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#--

		def NumberOfOccurrenceOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfValueInRowInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRowInRow(pRow, pRow, pValue)

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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#>

		#-- WITHOUT CASESENSITIVITY
	
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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInRow(pRow, pSubValue)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, 1)

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

	#-- WITHOUT CASESENSITIVITY

	def FindInRows(panRows, pCellValueOrSubValue)
		return This.FindInRowsCS(panRows, pCellValueOrSubValue, 1)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN ROWS  #
	#------------------------------------------------------------#

	def FindValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInRows(panRows, pCellValue)
		return This.FindValueInRowsCS(panRows, pSubValue, 1)

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.RowsAsPositions(panRows), pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInRows(panRows, pSubValue)
		return This.FindValueInRowsCS(panRows, pSubValue, 1)

	  #==========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#==========================================================================================#

	def FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		panRows = This.RowsToNames(panRows)

		return This.FindNthInCellsCS(_n_, This.RowsAsPositions(panRows), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>


	#-- WITHOUT CASESENSITIVITY

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
		_anPos_ = This.FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForm

		def FindNthOccurrenceOfSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRowsCs(panRows, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindNthInRowsCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return len( This.FindCellInRowsCS(panRows, pCellValue, pCaseSensitive) )

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY
	
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInRows(panRows, pSubValue)
		return This.ContainsSubValueInRowsCS(panRows, pSubValue, 1)

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

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCol(pCol, pCellValue)
		return This.FindValueInColCS(pCol, pSubValue, 1)

		def FindValueInColumn(pCol, pCellValue)
			return This.FindValueInCol(pCol, pCellValue)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		def FindSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCol(pCol, pSubValue)
		return This.FindValueInColCS(pCol, pSubValue, 1)

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>


	#-- WITHOUT CASESENSITIVITY

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
		_anPos_ = This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return len( This.FindCellInColCS(pCol, pCellValue, pCaseSensitive) )

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY
	
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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCol(pCol, pSubValue)
		return This.ContainsSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumn(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
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

	#-- WITHOUT CASESENSITIVITY

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

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCols(paCols, pCellValue)
		return This.FindValueInColsCS(paCols, pSubValue, 1)

		def FindValueInColumns(paCols, pCellValue)
			return This.FindValueInCols(paCols, pCellValue)

	  #-------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMNS  #
	#-------------------------------------------------------------#

	def FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.ColsAsPositions(paCols), pSubValue, pCaseSensitive)

		def FindSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCols(paCols, pSubValue)
		return This.FindValueInColsCS(paCols, pSubValue, 1)

		def FindSubValueInColumns(paCols, pSubValue)
			return This.FindSubValueInCols(paCols, pSubValue)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#=============================================================================================#

	def FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		paCols = This.ColsToNames(paCols)

		return This.FindNthInCellsCS(_n_, This.ColsAsPositions(paCols), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>


	#-- WITHOUT CASESENSITIVITY

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
		_anPos_ = This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindNthInColsCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return This.FindLastSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

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
		return len( This.FindCellInColsCS(paCols, pCellValue, pCaseSensitive) )

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY
	
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

		#>

	#-- WITHOUT CASESENSITIVITY

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCols(paCols, pSubValue)
		return This.ContainsSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumns(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
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

		#-- WITHOUT CASESENSITIVITY

		def FindInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)

	def FindValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInSection(paSection1, paSection2, pCellValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, 1)

	def FindSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, 1)

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

		#-- WITHOUT CASESENSITIVITY

		def FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
			return This.FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
				return This.FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)

	def FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.SectionAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)
			return This.FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, 1)

			def FindNthOccurrenceOfValueInSection(_n_, paSection1, paSection2, pCellValue)
				return This.FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)

	def FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.SectionAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInSection(paSection1, paSection2, pCellValue)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindFirstOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindFirstValueInSection(paSection1, paSection2, pCellValue)

	def FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		def FindFirstOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInSection(paSection1, paSection2, pCellValue)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindLastOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindLastValueInSection(paSection1, paSection2, pCellValue)

	def FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		def FindLastOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

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

		#>

		#-- WITHOUT CASESENSITIVITY

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
		return len( This.FindCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive) )

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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#--

		def NumberOfOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfValueInSectionInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)

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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#>

		#-- WITHOUT CASESENSITIVITY
	
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

		#>

		#-- WITHOUT CASESENSITIVITY

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

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInSection(paSection1, paSection2, pSubValue)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def SectionContainsSubValue(paSection1, paSection2, pSubValue)
				return This.ContainsSubValueInSection(paSection1, paSection2, pSubValue)


	def Sort()
		This.SortOn(1)

		#< @FunctionFluentForm

		def SortQ()
			This.Sort()
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

		#>

	  #-----------------------------------#
	 #  SORTING THE TABLE IN DESCENDING  #
	#-----------------------------------#

	def SortDown()
		This.SortDownOn(1)

		#< @FunctionFluentForm

		def SortDownQ()
			This.SortDown()
			return This

		#>

		#< @FunctionAlternativeForm

		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

		#>

	def SortedDown()
		_aResult_ = This.Copy().SortDownQ().Content()
		return _aResult_

		def SortedInDescending()
			return This.SortedDown()

	  #----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN ASCENDiNG  #
	#====================================================#

	#TODO
	# Check performance on large tables

	def SortOn(pCol)
		_nCol_ = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, _nCol_-1, 1)
		This._SyncFromEngine()

		#< @FunctionFluentForm

		def SortOnQ(pCol)
			This.SortOn(pCol)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUpOn(pCol)
			This.SortOn(pCol)

			def SortUpOnQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnInAscending(pCol)
			This.SortOn(pCol)

			def SortOnInAscendingQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnCol(pCol)
			This.SortOn(pCol)

			def SortOnColQ(pCol)
				return This.SortOnQ(pCol)

		def SortColUpOn(pCol)
			This.SortOn(pCol)

			def SortColUpOnQ(pCol)
				return This.SortOnQ(pCol)

		def SortInAscendingOnCol(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnColumn(pCol)
			This.SortOn(pCol)

			def SortOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		def SortUpOnColumn(pCol)
			This.SortOn(pCol)

			def SortUpOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		def SortInAscendingOnColumn(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColumnQ(pCol)
				return This.SortOnQ(pCol)

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

	def SortDownOn(pCol)
		_nCol_ = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, _nCol_-1, 0)
		This._SyncFromEngine()

		#< @FunctionFluentForm


		def SortDownOnQ(pCol)
			This.SortDownOn(pCol)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOn(pCol)
			This.SortOnDown(pCol)

			def SortInDescendingOnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortColDownOn(pCol)
			This.SortDownOn(pCol)

			def SortColDownOnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortInDescendingOnCol(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortDownOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortDownOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortInDescendingOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

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

	def SortBy(pcExpr)

		This.SortOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUpBy(pcExpr)
			This.SortBy(pcExpr)

			def SortUpByQ(pcExpr)
				return This.SortByQ(pcExpr)

		def SortInAscendingBy(pcExpr)
			This.SortBy(pcExpr)

			def SortInAscendingByQ(pcExpr)
				return This.SortByQ(pcExpr)

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

	def SortDownBy(pcExpr)
		This.SortDownOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortDownByQ(pcExpr)
			This.SortDownBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForm

		def SortInDescendingBy(pcExpr)
			This.SortDownBy(pcExpr)

			def SortInDescendingByQ(pcExpr)
				return This.SortDownByQ(pcExpr)

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

		#>

		#< @FunctionAlternativeForms

		def SortOnByUp(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnByUpQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortUpOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

		def SortOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortUpOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColumnByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

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

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOnBy(pCol, pcExpr)
			This.SortDownOnBy(_nCol_, pcExpr)

			def SortInDescendingOnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortDownOnColBy(_nCol_, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortDownOnColByQ(_nCol_, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortInDescendingOnColBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortDownOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortedDownOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortInDescendingOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		#>

	def SortedDownOnBy(pCol, pcExpr)
		_aResult_ = This.Copy().SortDownOnByQ(pCol, pcExpr).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedInDescendingOnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

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

	def IsSorted()
		return This.IsSortedOn(1)

	def IsSortedUp()
		return This.IsSortedUpOn(1)

		def IsSortedInAscending()
			return This.IsSortedUpOn(1)

	def IsSortedDown()
		return This.IsSortedDownOn(1)

		def IsSortedInDescending()
			return This.IsSortedDownOn(1)

	def IsSortedOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortOn(pCol)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedOnCol(pCol)
			return This.IsSortedOn(pCol)

		def IsSortedOnColumn(pCol)
			return This.IsSortedOn(pCol)

	def IsSortedUpOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOn(pCol)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
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

	def IsSortedDownOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOn(pCol)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
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

	#--

	def IsSortedBy(pcExpr)
		return This.IsSotedOnBy(1, pcExpr)

	def IsSortedUpBy(pcExpr)
		return This.IsSortedUpOn(1, pcExpr)

		def IsSortedInAscendingBy(pcExpr)
			return This.IsSortedUpBy(1, pcExpr)

	def IsSortedDownBy(pcExpr)
		return This.IsSortedDownOnBy(1, pcExpr)

		def IsSortedInDescendingBy(pcExpr)
			return This.IsSortedDownOnBy(1, pcExpr)

	def IsSortedOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedOnColBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedOnColumnBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		#--

		def IsSortedByOn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedByOnCol(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedByOnColumn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

	def IsSortedUpOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedUpOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#--

		def IsSorteUpByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#==

		def IsSortedInAscendingOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#--

		def IsSorteInAscendingByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

	def IsSortedDownOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		_nLen_ = This.NumberOfCols()

		for i = 1 to _nLen_
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_


		def IsSortedDownOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#--

		def IsSortedDownByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#==

		def IsSortedInDescendingOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#--

		def IsSortedInDescendingByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def ReplaceCellByPosition(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		def ReplaceByPositionCell(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		#>

	  #---------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY THE PROVIDED VALUE  #
	#---------------------------------------------------------------------------#

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

		#< @FunctionAlternatives

		def ReplaceTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		#TODO // Add the fellowing semantics to all simular functions in the library

		def ReplaceEachOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceEveryOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEachOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEveryOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceByPositionCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES  #
	#-----------------------------------------------------------------------------#

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

		#< @FunctionAlternativeForms

		def ReplaceTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceEachOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceEveryOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceByPositionEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceByPositionEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

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

		def ReplacePositionsTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

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

		#>

	#-- WITHOUT CASESENSITIIVTY

	def ReplaceCellByValue(pCellValue, pNewCellValue)
		This.ReplaceCellByValueCS(pCellValue, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValue(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#--

		def ReplaceByValueCell(pCellValue, pNewCellValue)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValue(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValue(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#--

		def ReplaceByValueManyCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

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

		def ReplaceColumn(pCol, paCol)
			This.ReplaceCol(pCol, paCol)

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

		#< @FunctionAlternativeForms

		def ReplaceNthColumn(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		def ReplaceColN(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		def ReplaceColumnN(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		#--

		def ReplaceColAt(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		def ReplaceColAtPosition(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

		def ReplaceColumnAt(_n_, paCol)
			This.ReplaceNthCol(_n_, paCol)

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

	def ReplaceColsAt(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceColAt(_anPosU_[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplacesNthCols(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAt(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

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

	def ReplaceTheseCols(paCols, paNewCol)
		if IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		_anPos_ = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositions(_anPos_, paNewCol)

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

	def ReplaceColNameAndData(pCol, pcColName, paColData)
		_nCol_ = This.ColToColNumber(pCol)
		This.ReplaceNthColName(_nCol_, pcColName)
		This.ReplaceNthCol(_nCol_, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndData(pCol, pcColName, paColData)
			This.ReplaceColNameAndData(pCol, pcColName, paColData)

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


		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndData(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndData(_n_, pcColName, paColData)

		def ReplaceColNNamedAndData(_n_, pcColName, paColData)
			This.ReplaceNthColNamedAndData(_n_, pcColName, paColData)

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


		def ReplaceCellsInColumn(pCol, pCell)
			This.ReplaceCellsInCol(pCol, pCell)

	  #------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#------------------------------------------------------------------------------------------------#
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

		#< @FunctionAlternativeForms

		def ReplaceAllColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		def ReplaceCols(paNewCols)
			This.ReplaceAllCols(paNewCols)

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

	def ReplaceAllColsByMany(paCols, paNewCols)
		/* ... */

		StzRaise("Unsupported feature in this release!")

		def ReplaceAllColumsByMany(paCols, paNewCols)
			This.ReplaceAllColsByMany(paCols, paNewCols)

	#TODO : Add ReplaceAllColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #-----------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#-----------------------------------------------------------------------------------#

	def ReplaceTheseColsByMany(paCols, paNewCols)
		if IsOneOfTheseNamedParamsList(paNewCols,[ :With, :By, :Using ])
			paNewCols = paNewCols[2]
		ok

		/* ... */

		StzRaise("Unsupported feature in this release!")

		#< @FunctionAlternativeForms

		def ReplaceTheseColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		#>

	#TODO // Add ReplaceTheseColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #===================================================================#
	 #  REPLACING THE CELLS OF THE GIVEN ROW BY THE PRIVIDED CELL VALUE  #
	#===================================================================#

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

		def ReplaceNthRow(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowN(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowAt(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

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

		#< @FunctionAlternativeForms

		def ReplaceRows(paNewRow)
			This.ReplaceAllRows(paNewRow)

		def ReplaceRowsWith(paNewRow)
			This.ReplaceAllRows(paNewRow)

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

	def ReplaceRowsAt(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		_anPosU_ = U(panPos)
		_nLen_ = len(_anPosU_)

		for i = 1 to _nLen_
			This.ReplaceRowAt(_anPosU_[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplacesNthRows(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAt(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

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

	def ReplaceTheseRows(panRowsNumbers, paNewRow)
		if IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositions(panRowsNumbers, paNewRow)

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

	def ReplaceCellsInTheseRows(paRows, pCell)
		if IsOneOfTheseNamedParamsList(paNewrows,[ :With, :By, :Using ])
			paNewrows = paNewrows[2]
		ok

		_aCells_ = This.CellsInTheseRowsAsPositions(paRows)
		This.ReplaceCells(_aCells_, pCell)


		def ReplaceTheseRowsWith(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAll(pCellValue, pNewCellValue)
		This.ReplaceAllCS(pCellValue, pNewCellValue, 1)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#--

		def ReplaceAllOccurrences(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#>

	  #---------------------------------------------------#
	 #  REPLACING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#---------------------------------------------------#

	def ReplaceNthCS(_n_, pValue, pNewCellValue, pCaseSensitive)
		_aCellPos_ = This.FindNthCS(_n_, pValue, pCaseSensitive)
		This.ReplaceCell(_aCellPos_, pNewCellValue)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNth(_n_, pValue, pNewCellValue)
		This.ReplaceNthCS(_n_, pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceFirstCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(1, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirst(pValue, pNewCellValue)
		This.ReplaceFirstCS(pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceLastCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(:Last, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLast(pValue, pNewCellValue)
		This.ReplaceLastCS(pValue, pNewCellValue, 1)

	  #====================================#
	 #  REPLACING SUBVALUES INSIDE CELLS  #
	#====================================#

	def ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCell(pnCol, pnRow, pSubValue, pNewSubValue)
		This.ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCells(paCellsPos, pSubValue, pNewSubValue)
		This.ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCellsByMany(paCellsPos, pSubValues, pNewSubValue)
		This.ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, 1)

	# Add ReplaceInCellsByManyXT() : if all repalaced restart at the 1st one

	#--

	def ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInSection(paCellPos1, paCellPos2,  pSubValue, pNewSubValue)
		This.ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInSectionByMany(paCellPos1, paCellPos2,  pSubValues, pNewSubValue)
		This.ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, ;CaseSensitive = 1)

	# Add ReplaceInSectionByManyXT() : if all replaced restart at the 1st one

	#--

	def ReplaceInSectionsCS(aSections, pSubValue, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSections(aSections, pSubValue)
		This.ReplaceInSectionsCS(aSections, pSubValue, 1)

	#--

	def ReplaceInSectionsByManyCS(aSections, paSubValues, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSectionsByMany(aSections, paSubValues)
		This.ReplaceInSectionsByManyCS(aSections, paSubValues, 1)

	#-- Add ReplaceInSectionsByManyXT() : if all replaced restrat at 1st one

		def FillCQ(pValue) #TODO // Add this to all functions
			return This.Copy().FillQ(pValue)

	def Filled(pValue)
		_aResult_ = This.Copy().FillQ(pValue).Content()
		return _aResult_

	  #=================================#
	 #  MISC. : SOME USEFUL UTILITIES  #
	#=================================#

	def ToStzHashList()
		return new stzHashList( This.Table() )

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

	def TheseColsToColNames(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

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

		#>

	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

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

	def TheseRowsToRowsNumbers(paRows)
		if NOT ( isList(paRows) and Q(paRows).IsListOfLists() )
			StzRaise("Incorrect param type! paRows must be a list of lists.")
		ok

		_nLen_ = len(paRows)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.RowToNumber(paRows[i])
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

		if Q(pacColNames).IsListOfStrings()
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
			if StzFindFirstCS( '@(:' + This.ColName(i) + ')', pcFormula, FALSE ) > 0
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
		_bNumericRefs_ = TRUE
		for j = 1 to _nRefLen_
			_aColVals_ = This.Col(_aRefCols_[j])
			_nCVLen_ = len(_aColVals_)
			for c = 1 to _nCVLen_
				if NOT isNumber(_aColVals_[c])
					_bNumericRefs_ = FALSE
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

		#< @FunctionAlternativeForms

		def InsertCalculatedColAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		def InsertCalculatedColumn(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		def InsertCalculatedColumnAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		#>

	def AddCalculatedCol(pcColName, pcFormula)
		This.InsertCalculatedCol(This.NumberOfCols()+1, pcColName, pcFormula)

		#< @FunctionAlternativeForm

		def AddCalculatedColumn(pcColName, pcFormula)
			This.AddCalculatedCol(pcColName, pcFormula)

		#>

	  #-----------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED COLUMNS  #
	#-----------------------------------------------#

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

	def AddCalculatedRow(pacFormulas)
		This.InsertCalculatedRow( This.NumberOfRows() + 1, pacFormulas)

	  #--------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED ROWS  #
	#--------------------------------------------#

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

		def MEAN(paCell1, paCell2)
			return AVERAGE(paCell1, paCell2)

	def KOUNT(paCell1, paCell2)
		_nResult_ = len( This.CellsInSection(paCell1, paCell2) )
		return _nResult_

	def MAX(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nResult_ = @Max(_aCells_)

		return _nResult_

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

	def SumCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableSumCol(@pEngine, _nCol_-1)

		def SumColumn(pCol)
			return This.SumCol(pCol)

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

	def MinCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMinCol(@pEngine, _nCol_-1)

		def MinColumn(pCol)
			return This.MinCol(pCol)

	def MaxCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMaxCol(@pEngine, _nCol_-1)

		def MaxColumn(pCol)
			return This.MaxCol(pCol)

	def ProductCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableProductCol(@pEngine, _nCol_-1)

		def ProductColumn(pCol)
			return This.ProductCol(pCol)

	def CountNonNullInCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableCountNonNull(@pEngine, _nCol_-1)

		def CountNonNullInColumn(pCol)
			return This.CountNonNullInCol(pCol)

	  #============================================#
	 #  CASTING THE TABLE INTO A STZTABLE OBJECT  #
	#============================================#

	#NOTE // stzPivotTable belongs to the MAX layer of StzLib
	# For the fellowing method to work, you must load "stzmax.ring"

    def Filter(paColValues)

        # Validate input is a hash list

        if NOT (isList(paColValues) and Q(paColValues).IsHashList())
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

	def FilterCQ(paColValues)
			_oCopy_ = This.Copy()
			_oCopy_.Filter(paColValues)
			return _oCopy_
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

	def Aggregate(paAggregations)
		# Validate input is a hash list
		if NOT (isList(paAggregations) and Q(paAggregations).IsHashList())
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

				if NOT StzFindFirst(paCols, _acColNames_[i]) > 0
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

			_nResult_ = NULL
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
	                _bFound_ = FALSE
	                _nHobbyMapnHobbyIndex2Len_ = len(_aHobbyMap_[_nHobbyIndex_][2])
	                for r = 1 to _nHobbyMapnHobbyIndex2Len_
	                    if _aHobbyMap_[_nHobbyIndex_][2][r] = nRow
	                        _bFound_ = TRUE
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

	def Show()
		? This._displayFullTable()

	def ShowFilter(paFilterCriteria)
		? _displayFilteredTable(paFilterCriteria)

    # New display method to show table contents

    def Display(paFilterCriteria)

        # If no filter criteria provided, display full table

        if paFilterCriteria = NULL
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

        _cOutput_ += _cLine_ + NL

        # Header row

        _cLine_ = @aBorder[:Vertical]

        for i = 1 to _nCols_
            _cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
        next

        _cOutput_ += _cLine_ + NL

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

        _cOutput_ += _cLine_ + NL

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

            _cOutput_ += _cLine_ + NL

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

        return _oFilteredTable_.Display(NULL)

	  #----------------------------------------#
	 #  DISPLAYING THE TABLE - EXTENDED FORM  #
	#----------------------------------------#

	# Master method orchestrating the submethods
	def processParameters(pParams, _bRowNumber_, _bSubTotal_, _bGrandTotal_, bCleanDesign)
		if pParams = NULL
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
								_bRowNumber_ = TRUE
							but @StzMid(_cParam_, 1, 8) = "subtotal"
								_bSubTotal_ = TRUE
							but @StzMid(_cParam_, 1, 10) = "grandtotal"
								_bGrandTotal_ = TRUE
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
		_bRowNumber_ = @if(IsBoolean(_bRowNumber_), _bRowNumber_, FALSE)
		_bSubTotal_ = @if(IsBoolean(_bSubTotal_), _bSubTotal_, FALSE)
		_bGrandTotal_ = @if(IsBoolean(_bGrandTotal_), _bGrandTotal_, FALSE)

	# Submethod to calculate column widths
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

	# Submethod to adjust column widths and names for row numbers
	def adjustForRowNumbers(_bRowNumber_, _aColWidths_, _acColNames_)

		if _bRowNumber_
			_nRowNumWidth_ = len("" + This.NumberOfRows()) + 2
			_aColWidths_ = ring_insert(_aColWidths_, 1, _nRowNumWidth_)
			_acColNames_ = ring_insert(_acColNames_, 1, "#")
		ok

	# Submethod to build the output string
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
		_cOutput_ += _cLine_ + NL

		# Header row
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

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
		_cOutput_ += _cLine_ + NL

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

	# Submethod to build data rows with subtotals
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
			_cOutput_ += _cLine_ + NL

			if _bSubTotal_ and r = _nRows_
				_cOutput_ += buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
			ok
		next

		return _cOutput_

	# Submethod to build subtotal row
	def buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
		_cOutput_ = ""
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar("-", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

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
		_cOutput_ += _cLine_ + NL

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar(" ", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

		return _cOutput_

	# Submethod to build grand total
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
		_cOutput_ += _cLine_ + NL

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
		_cOutput_ += _cLine_ + NL

		return _cOutput_

	#---------------------------------#
	#  TRANSPOSINT THE TABLE CONTENT  #
	#---------------------------------#


	def Transpose()

	    # Get dimensions directly from @aContent
	    _nCols_ = len(@aContent)
	    if _nCols_ = 0
	        return
	    ok
	    _nRows_ = len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = FALSE
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


		def Turn()
			This.Transpose()

		def SwapColsAndRows()
			This.Transpose()

		def SwapRowsAndCols()
			This.Transpose()

		def SwitchColsAndRows()
			This.Transpose()

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
	    @bTransposedWithHeaders = True
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

		def TransposeWithColNames()
			This.TansposeXT()

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
	    @bTransposedWithHeaders = False
	    @aOriginalColNames = []

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

	def CanTransposeBack()
	    return (@bTransposedWithHeaders and @aOriginalColNames != [])


	  #---------------------#
	 #  UTILITY FUNCTIONS  #
	#---------------------#

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

	def ToCSV()
		return ListToCSV(This.Content())

	def ToCSVXT(pcSep)
		return ListToCSVXT(This.Content(), pcSep)

	#---

	def FromCSV(pcCSV)
		This.UpdateWith(CSVToList(pcCSV))

		def FromCSVString(pcCSV)
			This.FromCSV(pcCSV)

	def FromCSVXT(pcCSV, pcSep)
		This.UpdateWith(CSVToListXT(pcCSV, pcSep))

		def FromCSVStringXT(pcCSV, pcSep)
			This.FromCSVXT(pcCSV, pcSep)

	#--

	def ToJSON() # Compact Json (without NL and TAB indendtaion)
		return ListToJson(This.Content())

	def ToJsonXT() # Json with NL and TAB-indentation
		return ListToJsonXT(This.Content())

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


	def FromHtml(pcHtmlTable)

		if NOT isString(pcHtmlTable)
			StzRaise("Incorrect param type! pcHtmlTable must be a string.")
		ok

		This.UpdateWith(StzStringQ(pcHtmlTable).HtmlToTable())
