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

		def InsertCalculatedCol(_n_, pcColName, pcFormula)
			_oAgg_ = new stzTableAggregator(@aContent)
			_oAgg_.InsertCalculatedCol(_n_, pcColName, pcFormula)
			This.UpdateWith(_oAgg_.Content())
			@anCalculatedCols + _n_

			def InsertCalculatedColAt(_n_, pcColName, pcFormula)
				This.InsertCalculatedCol(_n_, pcColName, pcFormula)

			def InsertCalculatedColumn(_n_, pcColName, pcFormula)
				This.InsertCalculatedCol(_n_, pcColName, pcFormula)

			def InsertCalculatedColumnAt(_n_, pcColName, pcFormula)
				This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		def AddCalculatedCol(pcColName, pcFormula)
			This.InsertCalculatedCol(This.NumberOfCols() + 1, pcColName, pcFormula)

			def AddCalculatedColumn(pcColName, pcFormula)
				This.AddCalculatedCol(pcColName, pcFormula)

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

		def SumCol(pCol)
			_oAgg_ = new stzTableAggregator(@aContent)
			return _oAgg_.SumCol(pCol)

		def AvgCol(pCol)
			_oAgg_ = new stzTableAggregator(@aContent)
			return _oAgg_.AvgCol(pCol)

			def MeanCol(pCol)
				return This.AvgCol(pCol)

		def MinCol(pCol)
			_oAgg_ = new stzTableAggregator(@aContent)
			return _oAgg_.MinCol(pCol)

		def MaxCol(pCol)
			_oAgg_ = new stzTableAggregator(@aContent)
			return _oAgg_.MaxCol(pCol)

		def ProductCol(pCol)
			_oAgg_ = new stzTableAggregator(@aContent)
			return _oAgg_.ProductCol(pCol)

		# Calculated ROWS build on InsertRow, which lives on the sibling
		# stzTableStructure -- so they are unreachable from a bare stzTable AND
		# broken on the aggregator itself (its InsertCalculatedRow calls
		# This.InsertRow -> R14). Exposing InsertRow here, delegated to a
		# throwaway structure, makes it callable on stzTable and -- because the
		# aggregator inherits from stzTable -- repairs the aggregator's own
		# calculated-row methods by inheritance.

		def InsertRow(_n_, paRowData)
			_oStruct_ = new stzTableStructure(@aContent)
			_oStruct_.InsertRow(_n_, paRowData)
			This.UpdateWith(_oStruct_.Content())

		def InsertCalculatedRow(_n_, pacFormulas)
			_oAgg_ = new stzTableAggregator(@aContent)
			_oAgg_.InsertCalculatedRow(_n_, pacFormulas)
			This.UpdateWith(_oAgg_.Content())
			@anCalculatedRows + _n_

		def AddCalculatedRow(pacFormulas)
			This.InsertCalculatedRow(This.NumberOfRows() + 1, pacFormulas)

			def AddCalculatedRows(pacFormulas)
				This.AddCalculatedRow(pacFormulas)

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

			_nCols_ = len(@aContent)
			for _i_ = 1 to _nCols_
				StzEngineTableAddCol(@pEngine, @aContent[_i_][1])
			next

			if _nCols_ > 0
				_nRows_ = len(@aContent[1][2])
				for r = 1 to _nRows_
					StzEngineTableAddRow(@pEngine)
					for c = 1 to _nCols_
						_v_ = @aContent[c][2][r]
						if isNumber(_v_)
							if floor(_v_) = _v_
								StzEngineTableSetCellInt(@pEngine, c-1, r-1, _v_)
							else
								StzEngineTableSetCellFloat(@pEngine, c-1, r-1, _v_)
							ok
						but isString(_v_)
							StzEngineTableSetCellString(@pEngine, c-1, r-1, _v_)
						ok
					next
				next
			ok

			@bEngineStale = FALSE
		ok

	def _InvalidateEngine()
		@bEngineStale = TRUE

	def _SyncFromEngine()
		_nCols_ = StzEngineTableNumCols(@pEngine)
		_nRows_ = StzEngineTableNumRows(@pEngine)

		@aContent = []
		for c = 1 to _nCols_
			_cName_ = StzEngineTableColName(@pEngine, c-1)
			_aData_ = []
			for r = 1 to _nRows_
				_nType_ = StzEngineTableGetCellType(@pEngine, c-1, r-1)
				if _nType_ = 2
					_aData_ + StzEngineTableGetCellInt(@pEngine, c-1, r-1)
				but _nType_ = 3
					_aData_ + StzEngineTableGetCellFloat(@pEngine, c-1, r-1)
				but _nType_ = 4
					_aData_ + StzEngineTableGetCellString(@pEngine, c-1, r-1)
				else
					_aData_ + ""
				ok
			next
			@aContent + [_cName_, _aData_]
		next
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

	def Show()
		_oTdDisp_ = new stzTableDisplay(@aContent)
		_oTdDisp_.Show()

	def ToString()
		_oTdToStr_ = new stzTableDisplay(@aContent)
		return _oTdToStr_.ToString()

	# ----------------------------------------------------------------
	# Inlined forwarders for methods that live on stzTableStructure /
	# stzTableFinder / stzTableColumnAccess. Those classes inherit
	# FROM stzTable, so calling them on a bare stzTable instance would
	# otherwise miss. We copy the operative logic here -- thin enough
	# that maintenance cost is low; deduplicate if/when we refactor
	# the table hierarchy.

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
						if StzFindFirst(_pValue_, _cell_) > 0 _bMatch_ = TRUE ok
					else
						# StzCaseFold is codepoint-aware; upper() is byte-oriented
						# and missed multibyte case (accented cells).
						if StzFindFirst(StzCaseFold(_pValue_), StzCaseFold(_cell_)) > 0 _bMatch_ = TRUE ok
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
					if StzFindFirst(_pVal_, _cell_) > 0 _nCount_++ ok
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
			if isString(_cell_) and isString(_pVal_) and StzFindFirst(_pVal_, _cell_) > 0
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
