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

	# Define border characters
	@aBorder = [
		:TopLeft = “â•­”,
		:TopRight = “â•®”,
		:BottomLeft = “â•°”,
		:BottomRight = “â•¯”,
		:Horizontal = “â”€”,
		:Vertical = “â”‚”,
		:TeeRight = “â”œ”,
		:TeeLeft = “â”¤”,
		:TeeDown = “â”¬”,
		:TeeUp = “â”´”,
		:Cross = “â”¼”
	]

	# Attributes used by the Transpose() method

	@bTransposedWithHeaders = FALSE # tracks when headers were preserved during transpose
	@aOriginalColNames = [] # stores the original column names internally

	def init(paTable)

		# A table can be created in many different ways
		# Case where a string is provided

		if NOT isList(paTable)
			StzRaise("Incorrect param format! paTable must be a list.")
		ok

		oParam = Q(paTable)

		if len(paTable) = 0 or oParam.IsPairOfNumbers()

		# Example : new stzTable([])
		#--> Creates an empty table with just a column and a row

		# Example: new stzTable([3, 4])
		#--> Creates a table of 3 columns and 4 rows, all cells are empty

		# Both ways (1 and 2) are made by the following code:

			nCols = 1
			nRows = 1

			if  @IsPairOfNumbers(paTable)
				nCols = paTable[1]
				nRows = paTable[2]
			ok

			aRow = []
			for i = 1 to nRows
				aRow + ""
			next

			for i = 1 to nCols
				@aContent + [ "COL"+i, aRow ]
			next

			return

		but oParam.ItemsAreListsOfSameSize() and
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
			nLen = len(paTable[1])

			for i = 1 to nLen
				cCol = paTable[1][i]
				@aContent + [ cCol, [] ]
			next
			#--> [
			# 	:ID       = [],
			# 	:EMPLOYEE = [],
			# 	:SALARY   = []
			#    ]

			for r = 2 to len(paTable)
				i = 0
				nLen = len(paTable[r])

				for i = 1 to nLen
					@aContent[i][2] + paTable[r][i]
				next
			next

			return

		but oParam.ItemsAreListsOfSameSize() and
		    oParam.IsNotHashList()

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

			aTempTable = []

			acColNames = []
			for i = 1 to len(paTable[1])
				acColNames + ("col" + i)
			next


			insert(paTable, 0, acColNames)
			This.Init(paTable)
			return

		but oParam.IsHashList()
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

			nLen = len(paTable)
			@aContent = []

			for i = 1 to nLen
				if isList(paTable[i][2])
					@aContent + [ paTable[i][1], paTable[i][2] ]
				else
					aTemp = []
					aTemp + paTable[i][2]
					@aContent + [ paTable[i][1], aTemp ]
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

	def ClassName()
		return "stztable"

		def KlassName()
			return "stztable"

	def Content()
		_aContent_ = @aContent # A deep copy to avoid reference propagation
		return _aContent_

		def Table()
			return This.Content()

			def TableQ()
				return new stzList( This.Table() )

		def Value()
			return Content()


	def Copy()

		_aCopy_ = []
		nLen = len(@aContent)
		for i = 1 to nLen
			_aCopy_ + @aContent[i]
		next

		_oCopy_ = new stzTable(_aCopy_)
		return _oCopy_

	def IsEmpty()
		nLen = len(@aContent)
		if nLen = 0
			return 1
		ok
		for i = 1 to nLen
			aCol = @aContent[i][2]
			for j = 1 to len(aCol)
				if aCol[j] != NULL
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

		cName = StzLower(pcName)
		bResult = This.ColNamesQ().Contains(cName)

		return bResult

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
		nLen = len(pacNames)
		bResult = 1
		for i = 1 to nLen
			if NOT This.HasColName(pacNames[i])
				bResult = 0
				exit
			ok
		next

		return bResult

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
		nResult = len( This.Table() )
		return nResult

		def NumberOfCols()
			return This.NumberOfColumns()

		def NumberOfCol()
			return This.NumberOfColumns()

	  #---------------------------------#
	 #   GETTING THE LIST OF COULMNS   #
	#---------------------------------#

	def ColumnsNames()
		aResult = []
		nLen = len(@aContent)
		for i = 1 to nLen
			aResult + @aContent[i][1]
		next
		return aResult

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

			def ColNamesQ()
				return This.ColumnsNamesQ()

			def ColNamesQRT(pcReturnType)
				return This.ColumnsNamesQRT(pcReturnType)

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
		cName = StzLower(pcName)

		bResult = 0
		if This.ColNamesQ().Contains(pcName)
			bResult = 1
		ok
*/
		return bResult

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

	def IsColNumber(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if n < 1 or n > This.NumberOfCols()
			return 0
		else
			return 1
		ok

		def IsColumnNumber(n)
			return This.IsColNumber(n)

		def IsAColNumber(n)
			return This.IsColNumber(n)

		def IsAColumnNumber(n)
			return This.IsColNumber(n)

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
		oTemp = Q(paCols)

		if NOT ( isList(paCols) and
			( oTemp.IsListOfNumbers() or
			  oTemp.IsListOfStrings() or
			  oTemp.IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be of list of numbers or strings.")
		ok

		bResult = 1
		nLen = len(paCols)

		for i = 1 to nLen
			if NOT This.IsColNameOrNumber(paCols[i])
				bResult = 0
				exit
			ok
		next

		return bResult

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
		nLen = len(@aContent)
		for i = 1 to nLen
			if StzLower(@aContent[i][1]) = pcColName
				return i
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
		n = This.FindCol(pCol)
		if n = 0
			StzRaise("Column not found!")
		ok
		return @aContent[n][2]

		def Column(pCol)
			return This.Col(pCol)

	def Row(pnRow)
		aResult = []
		nCols = len(@aContent)
		for i = 1 to nCols
			aResult + @aContent[i][2][pnRow]
		next
		return aResult

	def Cell(pCol, pnRow)
		n = This.FindCol(pCol)
		if n = 0
			StzRaise("Column not found!")
		ok
		return @aContent[n][2][pnRow]

	def NumberOfCells()
		return This.NumberOfColumns() * This.NumberOfRows()

	def NthColName(n)
		return @aContent[n][1]

	def FirstColName()
		return This.NthColName(1)

	def LastColName()
		return This.NthColName(This.NumberOfColumns())

	def LastRow()
		return This.Row(This.NumberOfRows())

	def Rows()
		aResult = []
		nRows = This.NumberOfRows()
		for i = 1 to nRows
			aResult + This.Row(i)
		next
		return aResult

	def ReplaceRow(pnRow, paNewRow)
		nCols = len(@aContent)
		for i = 1 to nCols
			@aContent[i][2][pnRow] = paNewRow[i]
		next
		This._InvalidateEngine()

	def ReplaceCell(pCol, pnRow, pValue)
		n = This.FindCol(pCol)
		if n = 0
			StzRaise("Column not found!")
		ok
		@aContent[n][2][pnRow] = pValue
		This._InvalidateEngine()

	def ReplaceCol(pCol, paNewData)
		n = This.FindCol(pCol)
		if n = 0
			StzRaise("Column not found!")
		ok
		@aContent[n][2] = paNewData
		This._InvalidateEngine()

	  #============================================================#
	 #  ENGINE ACCELERATION INFRASTRUCTURE                         #
	#============================================================#

	def _EnsureEngine()
		if @pEngine = NULL or @bEngineStale
			if @pEngine != NULL
				StzEngineTableFree(@pEngine)
			ok

			@pEngine = StzEngineTableNew()

			nCols = len(@aContent)
			for i = 1 to nCols
				StzEngineTableAddCol(@pEngine, @aContent[i][1])
			next

			if nCols > 0
				nRows = len(@aContent[1][2])
				for r = 1 to nRows
					StzEngineTableAddRow(@pEngine)
					for c = 1 to nCols
						v = @aContent[c][2][r]
						if isNumber(v)
							if floor(v) = v
								StzEngineTableSetCellInt(@pEngine, c-1, r-1, v)
							else
								StzEngineTableSetCellFloat(@pEngine, c-1, r-1, v)
							ok
						but isString(v)
							StzEngineTableSetCellString(@pEngine, c-1, r-1, v)
						ok
					next
				next
			ok

			@bEngineStale = FALSE
		ok

	def _InvalidateEngine()
		@bEngineStale = TRUE

	def _SyncFromEngine()
		nCols = StzEngineTableNumCols(@pEngine)
		nRows = StzEngineTableNumRows(@pEngine)

		@aContent = []
		for c = 1 to nCols
			cName = StzEngineTableColName(@pEngine, c-1)
			aData = []
			for r = 1 to nRows
				nType = StzEngineTableGetCellType(@pEngine, c-1, r-1)
				if nType = 2
					aData + StzEngineTableGetCellInt(@pEngine, c-1, r-1)
				but nType = 3
					aData + StzEngineTableGetCellFloat(@pEngine, c-1, r-1)
				but nType = 4
					aData + StzEngineTableGetCellString(@pEngine, c-1, r-1)
				else
					aData + ""
				ok
			next
			@aContent + [cName, aData]
		next
		@bEngineStale = FALSE

	def _FreeEngine()
		if @pEngine != NULL
			StzEngineTableFree(@pEngine)
			@pEngine = NULL
		ok

	def EngineHandle()
		This._EnsureEngine()
		return @pEngine
