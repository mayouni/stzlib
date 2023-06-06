#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZTABLE			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing tables in SoftanzaLib      #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*
Get insipration of realworld use cases and features from this article
describing the difference between NumPy and Pandas (Pyhthon ecosystem):
https://betterprogramming.pub/pandas-illustrated-the-definitive-visual-guide-to-pandas-c31fa921a43

#TODO (Future): use Apache Arrow as a C++ backend for stzTable
# https://arrow.apache.org/

	Apache Arrow is a software development platform for
	building high performance applications that process
	and transport large data sets. It is designed to both
	improve the performance of analytical algorithms and
	the efficiency of moving data from one system or
	programming language to another.

	A critical component of Apache Arrow is its in-memory
	columnar format, a standardized, language-agnostic
	specification for representing structured, table-like
	datasets in-memory. This data format has a rich data
	type system (included nested and user-defined data types)
	designed to support the needs of analytic database
	systems, data frame libraries, and more.

*/

func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable
	@aTable = []

	# Table content is stored as a hashlist where keys are col names
	# EXAMPLE:
	# 	[
	# 		[ "COL1", [ "A", "B", "C" ] ],
	# 		[ "COL2", [ "a", "b", "c" ] ],
	# 		[ "COL3", [ "1", "2", "3" ] ]
	# 	]

	# This choice is made firstly, because columns have names and
	# rows have'nt. But maily, to enable (future) data analytics and
	# data science operations on tables of data, where variables are
	# always represented as columns.

	def init(paTable)

		# A table can be created in 4 different ways

		if NOT isList(paTable)
			StzRaise("Incorrect param format! paTable must be a list.")
		ok

		if len(paTable) = 0 or Q(paTable).IsPairOfNumbers()
	
		# Way 1: new stzTable([])
		#--> Creates an empty table with just a column and a row

		# Way 2: new stzTable([3, 4])
		# --> Creates a tale of 3 columns and 4 rows, all cells are empty

		# Both ways (1 and 2) are made by the following code:
		
			nCols = 1
			nRows = 1

			if  Q(paTable).IsPairOfNumbers()
				nCols = paTable[1]
				nRows = paTable[2]
			ok

			aRow = []
			for i = 1 to nRows
				aRow + NULL
			next

			for i = 1 to nCols
				@aTable + [ "COL"+i, aRow ]
			next

			return

		but Q(paTable).ItemsAreListsOfSameSize() and
		    Q(paTable[1]).IsListOfStrings()

		# Way 3 (the more natural way) The table is described in a
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

			for cCol in paTable[1]
				@aTable + [ cCol, [] ]
			next
			#--> [
			# 	:ID       = [],
			# 	:EMPLOYEE = [],
			# 	:SALARY   = []
			#    ]

			for r = 2 to len(paTable)
				i = 0

				for cell in paTable[r]
					i++
					@aTable[i][2] + cell
				next
			next

			return

		but Q(paTable).ItemsAreListsOfSameSize() and
		    Q(paTable).IsNotHashList()

		# WAY 4: Similar to way 3 but the line of column names is
		# not provided. Means that you privided only the rows of
		# your table!
		# --> Softanza accepts the rows and adds automatically the
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
		
		but Q(paTable).IsHashList()
		# Way 5: The table is provided in the same format of how
		# it is implemented in this class: a hashlist.

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

			@aTable = paTable

		else
			# If the param provided don't fit in any of the ways above
			StzRaise("Incorrect param format! There are 5 possible ways in creating a table. " +
				 "None fits with the param you provided. Check the code/comments under " +
				 "stzTable.Init() method.")
		ok

	def Content()
		return @aTable

		def Table()
			return This.Content()

		def TableQ()
			return new stzList( This.Table() )

	def Copy()
		oCopy = new stzTable(This.Content())
		return oCopy

	def IsEmpty()
		if This.CellsQ().AllItemsAreNull()
			return TRUE

		else
			return FALSE
		ok
	
	  #================================================#
	 #   CHECHKING IF THE TABLE HAS GIVEN COLUMN(S)   #
	#================================================#

	def HasColumName(pcName)
		cName = StzStringQ(pcName).Lowercased()
		bResult = This.ColNamesQ().Contains(cName)

		return bResult

		def HasColName(pcName)
			return This.HasColumName(pcName)

		def HasCol(pcName)
			return This.HasColumName(pcName)

		def HasColumn(pcName)
			return This.HasColumName(pcName)

	def HasColumnsNames(pacNames)
		nLen = len(pacNames)
		bResult = TRUE
		for i = 1 to nLen
			if NOT This.HasColName(pacNames[i])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def HasColNames(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasColumns(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasCols(pacNames)
			return This.HasColumnsNames(pacNames)

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

		def Size()
			return This.NumberOfColumns()

	  #---------------------------------#
	 #   GETTING THE LIST OF COULMNS   #
	#---------------------------------#

	def Columns()
		return This.ToStzHashList().Keys()

		#< @FunctionFluentForm

		def ColumnsQ()
			return This.ColumnsQR( :stzList )

		def ColumnsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Columns() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Columns() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Columns() )

			on :stzListOfLists
				return new stzListOfLists( This.Columns() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Columns() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def ColumnsNames()
			return This.Columns()

			def ColumnsNamesQ()
				return This.ColumnsNamesQ()

			def ColumnsNamesQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def AllColumnsNames()
			return This.Columns()

			def AllColumnsNamesQ()
				return This.AllColumnsQ()

			def AllColumnsNamesQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def ColumnNames()
			return This.Columns()

			def ColumnNamesQ()
				return This.ColumnsQ()

			def ColumnNamesQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def AllColumnNames()
			return This.Columns()

			def AllColumnNamesQ()
				return This.ColumnsQ()

			def AllColumnNamesQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def Cols()
			return This.Columns()

			def ColsQ()
				return This.ColumnsQ()

			def ColsQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def AllCols() # Useful by contrast to TheseCols(paCols)
			return This.Columns()

			def AllCollsQ()
				return This.ColsQR(:stzList)

			def AllCollsQR(pcReturnType)
				return This.ColsQR(pcReturnType)

		def ColsNames()
			return This.Columns()

			def ColsNamesQ()
				return This.ColumnsQ()

			def ColsNamesQR(pcReturnType)
				return This.ColunmsQR(pcReturnType)

		def AllColsNames()
			return This.Columns()

			def AllColsNamesQ()
				return This.ColumnsQ()

			def AllColsNamesQR(pcReturnType)
				return This.ColumnsQR(pcReturnType)

		def ColNames()
			return This.Columns()

			def ColNamesQ()
				return This.AllColsNamesQR(:stzList)

			def ColNamesQR(pcReturnType)
				return This.ColsNamesQR(pcReturnType)

		def AllColNames()
			return This.Columns()

			def AllColNamesQ()
				return This.AllColsNamesQR(:stzList)

			def AllColNamesQR(pcReturnType)
				return This.ColsNamesQR(pcReturnType)

		def Header()
			return This.Columns()

			def HeaderQ()
				return This.HeaderQ()

			def HeaderQR(pcReturnType)
				return This.HeaderQR(pcReturnType)

		#>

  	  #================================#
	 #  FINDING A COLUMN BY ITS NAME  #
	#================================#

	def FindCol(pcColName)
		if NOT isString(pcColName)
			StzRaise("Incorrect param type! pcColName must be a string.")
		ok

		if Q(pcColName).IsOneOfThese([:First, :FirstCol, :FirstColumn])
			pcColName = This.FirstColName()

		but Q(pcColName).IsOneOfThese([:Last, :LastCol, :LastColumn])
			pcColName = This.LastColName()
		ok

		pcColName = Q(pcColName).Lowercased()
		n = ring_find( This.Header(), pcColName)
		return n

		def FindColumn(pcColName)
			return This.FindCol(pcColName)

	  #------------------------------#
	 #  FINDING A ROW BY ITS VALUE  #
	#------------------------------#

	def FindRow(paRow)
		n = Q(This.Rows()).FindAll(paRow)

		if len(n) = 0
			n = 0

		but len(n) = 1
			n = n[1]
		ok

		return n

	  #======================#
	 #   READING A COLUMN   #
	#======================#

	def Col(p)
		if isString(p)
			oTemp = Q(p)
			if oTemp.IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but oTemp.IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfColumns()

			but This.HasColName(p)
				p = This.FindCol(p)
			ok
		ok

		aResult = This.VerticalSection( p, 1, This.NumberOfRows() )
		return aResult

		#< @FunctionFluentForm

		def ColQ(p)
			return This.ColQR(p, :stzList)

		def ColQR(p, pcReturnType)
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

		def Column(p)
			return This.Col(p)

			def ColumnQ(p)
				return This.ColumnQR(p, :stzList)

			def ColumnQR(p, pcReturnType)
				return This.ColQR(p, pcReturnType)

		def CellsInCol(p)
			return This.Col(p)

			def CellsInColQ(p)
				return This.CellsInColQR(p, :stzList)

			def CellsInColQR(p, pcReturnType)
				return This.CellsInColQR(p, pcReturnType)

		def CellsInColumn(p)
			return This.Col(p)

			def CellsInColumnQ(p)
				return This.CellsInColumnQR(p, :stzList)

			def CellsInColumnQR(p, pcReturnType)
				return This.CellsInColumnQR(p, pcReturnType)

		#>

	def CellsInCols(paCols)
		if NOT (isList(paCols) and
			Q(paCols).IsListOfNumbersOrStrings() and
			This.AreColumnsIdentifiers(paCols))

			StzRaise("Incorrect param type! paCols must be a list of string containing existing columns names.")
		ok

		nLen = len(paCols)

		aResult = []
		for i = 1 to nLen
			aResult + This.CellsInCol(paCols[i])
		next

		aResult = Q(aResult).Flattened()
		return aResult

	def IsColNameOrNumber(pCol)

		if ( isString(pCol) and This.IsColName(pCol) ) or
		   ( isNumber(pCol) and This.ColNumber(pCol) )
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

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

		#>

	def AreColNamesOrNumbers(paCols)
		oTemp = Q(paCols)

		if NOT ( isList(paCols) and
			( oTemp.IsListOfNumbers() or
			  oTemp.IsListOfStrings() or
			  oTemp.IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be of list of numbers or strings.")
		ok

		bResult = TRUE
		nLen = len(paCols)

		for i = 1 to nLen
			if NOT This.IsColNameOrNumber(paCols[i])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def AreColNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColIdentifiers(paCols)
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

	def ColXT(p)
		aResult = This.CellsInColAsPositionsQ(p).
				AssociatedWith( This.Col(p) )

		return aResult

		#< @FunctionFluentForm

		def ColXTQ(p)
			return This.ColXTQR(p, :stzList)

		def ColXTQR(p, pcReturnType)
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
				return This.ColumnXTQR(p, :stzList)

			def ColumnXTQR(p, pcReturnType)
				return This.ColXTQR(p, pcReturnType)

		def CellsInColXT(p)
			return This.ColXT(p)

			def CellsInColXTQ(p)
				return This.CellsInColXTQR(p, :stzList)

			def CellsInColXTQR(p, pcReturnType)
				return This.CellsInColXTQR(p, pcReturnType)

		def CellsInColumnXT(p)
			return This.ColXT(p)

			def CellsInColumnXTQ(p)
				return This.CellsInColumnXTQR(p, :stzList)

			def CellsInColumnXTQR(p, pcReturnType)
				return This.CellsInColumnXTQR(p, pcReturnType)

		#>

	  #========================#
	 #   GETTING NTH COLUMN   #
	#========================#

	def NthColName(n)
		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				n = This.NumberOfColumns()

			else
				StzRaise("syntax error in (" + n + ")! Allowed values are :First or :Last ( or :FirstCol or :LastCol).")

			ok
		ok

		cResult = This.ColNames()[n]

		return cResult

		def NthColumnName(n)
			return This.NthColName(n)

	def NthCol(n)
		return This.Col(n)

		def NthColumn(n)
			return This.NthCol(n)

		def CellsInNthCol(n)
			return This.NthCol(n)

		def CellsInNthColumn(n)
			return This.NthCol(n)

	def NthColXT(n)
		return This.ColXT(n)

		def NthColumnXT(n)
			return This.ColXT(n)

		def CellsInNthColXT(n)
			return This.ColXT(n)

		def CellsInNthColumnXT(n)
			return This.ColXT(n)

		def CellsInNthColAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInColNAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInNthColumnAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInColumnNAndTheirPositions(n)
			return This.ColXT(n)
		
	  #--------------------------#
	 #   GETTING FIRST COLUMN   #
	#--------------------------#

	def FirstColXT()
		return This.NthCOlXT(1)

		def FirstColumnXT()
			return This.FirstColXT()

	def FirstColName()
		return This.NthColName(1)

		def FirstColumnName()
			return This.FirstColName()

	def FirstCol()
		return This.NthCol(1)

		def FirstColumn()
			return This.FirstCol()

	  #-------------------------#
	 #   GETTING LAST COLUMN   #
	#-------------------------#

	def LastColXT()
		return This.NthCOlXT(:Last)

		def LastColumnXT()
			return This.LastColXT()

	def LastColName()
		return This.NthColName(:Last)

		def LastColumnName()
			return This.LastColName()

	def LastCol()
		return This.NthCol(:Last)

		def LastColumn()
			return This.LastCol()

	  #------------------------#
	 #  GETTING COLUMN NAME   #
	#------------------------#

	def ColName(n)
		if isString(n)
			if This.HasColName(n)
				return n
			else
				StzRaise("Incorrect column name! The name you provided does not exist.")
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if n = 0
			return "#"

		but n <= This.NumberOfColumns()
			return This.ColNames()[n]
		ok

		def ColNameQ(n)
			return new stzString( This.ColName(n) )

		def ColumnName(n)
			return This.ColName(n)

			def ColumnNameQ(n)
				return new stzString( This.ColumnName(n) )

	  #--------------------------------------------------------#
	 #  GETTING CELLS AND THEIR POSITIONS IN A GIVEN COLUMN   #
	#--------------------------------------------------------#

	def CellsAndPositionsInCol(p)
		aResult = This.ColQ(p).AssociatedWith( This.CellsInColAsPositions(p) )

		return aResult

		#< @FunctionFluentForm

		def CellsAndPositionsInColQ(p)
			return This.CellsAndPositionsInColQR(p, :stzList)

		def CellsAndPositionsInColQR(p, pcReturnType)
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
				return This.CellsAndPositionsInColumnQR(p, :stzList)

			def CellsAndPositionsInColumnQR(p, pcReturnType)
				return This.CellsAndPositionsInColQR(p, pcReturnType)

		#>

	  #----------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN COLUMN   #
	#----------------------------------------------------------#

	def CellsInColAsPositions(pCol)
		nCol = This.ColToColNumber(pCol)
		nNumberOfRows = This.NumberOfRows()

		aResult = []

		for i = 1 to nNumberOfRows
			aResult + [ nCol, i]
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInColPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColCellsAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsAsPositionsInCol(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		#--

		def CellsInColumnAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsInColumnPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnCellsAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsAsPositionsInColumn(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		#==

		def PositionsOfCellsInCol(pCol)
			return This.CellsInColAsPositions(pCol)

		def PositionsOfCellsInColumn(pCol)
			return This.CellsInColAsPositions(pCol)

		#==

		def CellsToColAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsToColPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColCellsToPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsToPositionsInCol(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColToPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		#--

		def CellsInColumnToPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnCellsToPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsToPositionsInColumn(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnToPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		#>

	  #--------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY COLUMNS   #
	#--------------------------------------------------------#

	def CellsInColsAsPositions(paCols)
		nLen = len(paCols)
		anColNumbers = This.TheseColsAsNumbers(paCols)
		aResult = []

		for i = 1 to nLen
			for aPosition in This.CellsInColAsPositions(anColNumbers[i])
				aResult + aPosition
			next
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInColsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def ColsCellsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsAsPositionsInCols(paCols)
			return This.CellsInColsAsPositions(paCols)

		#--

		def CellsInColumnsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsInColumnsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def ColumnsCellsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsAsPositionsInColumns(paCols)
			return This.CellsInColsAsPositions(paCols)

		#==

		def CellsToColsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToColsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def ColsCellsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToPositionsInCols(paCols)
			return This.CellsInColsAsPositions(paCols)

		#--

		def CellsInColumnsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def ColumnsCellsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToPositionsInColumns(paCols)
			return This.CellsInColsAsPositions(paCols)

		#==

		def CellsInTheseColsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def TheseColsCellsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsAsPositionsInTheseCols(paCols)
			return This.CellsInColsAsPositions(paCols)

		#--

		def CellsInTheseColumnsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsInTheseColumnsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def TheseColumnsCellsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsAsPositionsInTheseColumns(paCols)
			return This.CellsInColsAsPositions(paCols)

		#==

		def CellsInTheseColsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToTheseColsAsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToTheseColsPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def TheseColsCellsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToPositionsInTheseCols(paCols)
			return This.CellsInColsAsPositions(paCols)

		#--

		def CellsInTheseColumnsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def TheseColumnsCellsToPositions(paCols)
			return This.CellsInColsAsPositions(paCols)

		def CellsToPositionsInTheseColumns(paCols)
			return This.CellsInColsAsPositions(paCols)

		#>

	  #===================#
	 #   READING A ROW   #
	#===================#

	def Row(n)

		if isString(n)
			if Q(pRow).IsOneOfThese([ :First, :FirstRow ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastRow ])
				n = This.NumberOfRows()

			ok
		ok

		aResult = This.HorizontalSection( n, 1, This.NumberOfCols() )
		return aResult

		#< @FunctionFluentForm

		def RowQ(n)
			return This.RowQR(n, :stzList)

		def RowQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(n) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(n) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def RowN(n)
			return This.Row(n)

			def RowNQ(n)
				return This.RownQR(n, :stzList)

			def RowNQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def NthRow(n)
			return This.Row(n)

			def NthRowQ(n)
				return This.NthRowQR(n, :stzList)

			def NthRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInRow(n)
			return This.Row(n)

			def CellsInRowQ(n)
				return This.CellsInRowQR(n, :stzList)

			def CellsInRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInRowN(n)
			return This.Row(n)

			def CellsInRowNQ(n)
				return This.CellsInRowNQR(n, :stzList)

			def CellsInRowNQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInNthRow(n)
			return This.Row(n)

			def CellsInNthRowQ(n)
				return This.CellsInNthRowQR(n, :stzList)

			def CellsInNthRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)
		#>

	def CellsInRows(pnRows)
		if NOT ( isList(pnRows) and Q(pnRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! pnRows must be a list of numbers.")
		ok

		nLen = len(pnRows)
		aResult = []

		for n = 1 to nLen
			aResult + This.CellsInRow(n)
		next

		aResult = Q(aResult).Flattened()
		return aResult

	def RowXT(n)
		aResult = This.CellsInRowAsPositionsQ(n).AssociatedWith( This.Row(n) )
		return aResult

		#< @FunctionFluentForm

		def RowXTQ(n)
			return This.RowXTQR(n, :stzList)

		def RowXTQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowXT(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowXT(n) )

			on :stzListOfLists
				return new stzListOfLists( This.RowXT(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInRowXT(n)
			return This.RowXT(n)

			def CellsInRowXTQ(n)
				return This.CellsInRowXTQR(n, :stzList)

			def CellsInRowXTQR(n, pcReturnType)
				return This.CellsInRowXTQR(n, pcReturnType)

		def RowNXT(n)
			return This.RowXT(n)

			def RowNXTQ(n)
				return This.RowNXTQR(n, :stzList)

			def RowNXTQR(n, pcReturnType)
				return This.CellsInRowXTQR(n, pcReturnType)

		def NthRowXT(n)
			return This.RowXT(n)

			def NtRowXTQ(n)
				return This.NthRowXTQR(n, :stzList)

			def NthRowXTQR(n, pcReturnType)
				return This.CellsInRowXTQR(n, pcReturnType)

		#>

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
		return This.NthRowXT(:Last)

	def LastRow()
		return This.NthRow(:Last)

	  #--------------------------------#
	 #   GETTING THE NUMBER OF ROWS   #
	#--------------------------------#

	def NumberOfRows()
		nResult = len(This.Table()[1][2])
		return nResult

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

	def Rows()
		nRows   = This.NumberOfRows()
		aResult = []

		for i = 1 to nRows
			aResult + This.RowN(i)
		next

		return aResult

		def RowsQ()
			return This.RowsQR(:stzList)

		def RowsQR(pcReturnType)
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
				return This.AllRowsQR(:stzList)

			def AllRowsQR(pcReturnType)
				return This.RowsQR(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #   GETTING CELLS AND THEIR POSITIONS IN A GIVN ROW   #
	#-----------------------------------------------------#

	def CellsAndPositionsInRow(n)
		aResult = RowQ(n).AssociatedWith( This.CellsInRowAsPositions(p) )
		return aResult		

		#< @FunctionFluentForm

		def CellsAndPositionsInRowQ(n)
			return This.CellsAndPositionsInRowQR(p, :stzList)

		def CellsAndPositionsInRowQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.CellsAndPositionsInRow(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.CellsAndPositionsInRow(n) )

			on :stzListOfLists
				return new stzListOfLists( This.CellsAndPositionsInRow(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInRowNAndTheirPositions(n)
			return This.CellsAndPositionsInRow(p)

			def CellsInRowNAndTheirsPositionsQ(n)
				return This.CellsInRowNAndTheirsPositionsQR(n, :stzList)

			def CellsInRowNAndTheirsPositionsQR(n, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.CellsInRowNAndTheirsPositions(n) )
	
				on :stzListOfPairs
					return new stzListOfPairs( This.CellsInRowNAndTheirsPositions(n) )
	
				on :stzListOfLists
					return new stzListOfLists( This.CellsInRowNAndTheirsPositions(n) )
	
				other
					StzRaise("Unsupported return type!")
				off
		
		def CellsAndPositionsInRowN(n)
			return This.CellsAndPositionsInRow(p)

			def CellsAndPositionsInRowNQ(n)
				return This.CellsAndPositionsInRowNQR(n, :stzList)

			def CellsAndPositionsInRowNQR(n, pcReturnType)
				return This.CellsInRowNAndTheirsPositionsQR(n, pcReturnType)

		def CellsAndPositionsInNthRow(n)
			return This.CellsAndPositionsInRow(p)

			def CellsAndPositionsInNthRowQ(n)
				return This.CellsAndPositionsInNthRowQR(n, :stzList)

			def CellsAndPositionsInNthRowQR(n, pcReturnType)
				return This.CellsInRowNAndTheirsPositionsQR(n, pcReturnType)

		def CellsInNthRowAndTheirPositions(n)
			return This.CellsAndPositionsInRow(p)

			def CellsInNthRowAndTheirPositionsQ(n)
				return This.CellsInNthRowAndTheirPositionsQR(n, :stzList)

			def CellsInNthRowAndTheirPositionsQR(n, pcReturnType)
				return This.CellsInRowNAndTheirsPositionsQR(n, pcReturnType)
		#>

	  #-------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN ROW   #
	#-------------------------------------------------------#

	def CellsInRowAsPositions(pnRow)
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

		nNumberOfCols = This.NumberOfCols()
		aResult = []

		for i = 1 to nNumberOfCols
			aResult + [ i, pnRow ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInRowPositions(pnRow)
			return This.CellsInRowAsPositions(pnRow)

		def RowAsPositions(pnRow)
			return This.CellsInRowAsPositions(pnRow)

		def RowCellsAsPositions(pnRow)
			return This.CellsInRowAsPositions(pnRow)

		def CellsAsPositionsInRow(pnRow)
			return This.CellsInRowAsPositions(pnRow)

		#--

		def PositionsOfCellsInRow(pCol)
			return This.CellsInRowAsPositions(pCol)

		#>

	  #----------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY ROWS  #
	#----------------------------------------------------#

	def CellsInRowsAsPositions(panRows)
		nRows = len(panRows)
		aResult = []

		for i = 1 to nRows

			aPositions = This.CellsInRowAsPositions(i)
			nLenPos    = len(aPositions)

			for q = 1 to nLenPos
				aResult + aPositions[q]
			next

		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInRowsPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def RowsCellsAsPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def CellsAsPositionsInRows(panRows)
			return This.CellsInRowsAsPositions(panRows)

		#--

		def CellsInRowsToPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def RowsCellsToPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def CellsToPositionsInRows(panRows)
			return This.CellsInRowsAsPositions(panRows)

		#==

		def CellsInTheseRowsAsPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def CellsInTheseRowsPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def TheseRowsCellsAsPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def CellsAsPositionsInTheseRows(panRows)
			return This.CellsInRowsAsPositions(panRows)

		#--

		def CellsInTheseRowsToPositions(panRows)
			return This.CellsInTheseRowsAsPositions(panRows)

		def TheseRowsCellsToPositions(panRows)
			return This.CellsInRowsAsPositions(panRows)

		def CellsToPositionsInTheseRows(panRows)
			return This.CellsInRowsAsPositions(panRows)

		#>

	  #===============================#
	 #  GETIING THE NUMBER OF CELLS  #
	#===============================#

	def NumberOfCells()
		nResult = This.NumberOfCol() * This.NumberOfRows()
		return nResult

	  #-------------------------------------------------------------------#
	 #  GETIING A CELL VALUE BY ITS POSITION (COLUMN, ROW) IN THE TABLE  #
	#-------------------------------------------------------------------#

	def Cell(pCol, pnRow)

		if isString(pCol)
			if Q(pCol).IsOneOfThese([:First, :FirstCol, :FirstColumn])
				pCol = 1

			but Q(pCol).IsOneOfThese([:Last, :LastCol, :LastColumn])
				pCol = This.NumberOfColumns()

			else
				if NOT This.HasColName(pCol)
					StzRaise("Syntax error in (" + pCol + ")! This column name is inexistant.")
				ok
			ok
		ok

		if isString(pnRow)
			if pnRow = :First or pnRow = :FirstRow
				pnRow = 1

			but pnRow = :Last or pnRow = :LastRow
				pnRow = This.NumberOfRows()

			else
				StzRaise("Syntax error in (" + pnRow + ")! Allowed values are :First or :Last (or :FirstRow or :LastRow).")
			ok

		ok

		cCol   = This.ColToName(pCol)
		Result = This.Table()[cCol][pnRow]
		return Result

		#< @FunctionFluentForm

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

	def CellXT(pCol, pnRow)
		nCol = This.ColToNumber(pCol)
		nRow = This.RowToNumber(pnRow)

		aResult = [ This.Cell(pCol, pRow), [ nCol, nRow ] ]

		return aResult

		def CellAndPosition(pCol, pRow)
			return This.CellXT(pCol, pnRow)

		def CellAndItsPosition(pCol, pRow)
			return This.CellXT(pCol, pnRow)

	  #----------------------------------------------------------------------------#
	 #  GETIING GIVEN CELLS VALUES BY THEIR POSITIONS (COLUMN, ROW) IN THE TABLE  #
	#----------------------------------------------------------------------------#

	def TheseCells(paCellsPos)
		/*
		o1 = new stzTable([
			[ :NATION,	:LANGUAGE ],
			[ "___",	"Arabic"  ],
			[ "France",	"___"  ],
			[ "USA",	"___" ]
		])
		
		aSomeCells = [ [1, 1], [2, 2], [2, 3] ]
		
		? o1.TheseCells(aSomeCells)
		#--> [ "___", "___", "___" ]
		*/

		aResult = []
		nLen    =  len(paCellsPos)

		for i = 1 to nLen
			aResult + This.Cell( paCellsPos[i][1], paCellsPos[i][2] )
		next

		return aResult
		
		#< @FunctionFluentForm

		def TheseCellsQ(paCellsPos)
			return TheseCellsQR(paCellsPos, :stzList)

		def TheseCellsQR(paCellsPos, pcReturnType)
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

			def CellsAtPositionsQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def CellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def CellsAtQ(paCellsPos)
				return This.CellsAtPositions(paCellsPos, :stzList)

			def CellsAtQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def TheseCellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtQ(paCellsPos)
				return This.TheseCellsAt(paCellsPos, :stzList)

			def TheseCellsAtQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def TheseCellsAtPositions(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtPositionsQ(paCellsPos)
				return This.TheseCellsAtPositions(paCellsPos, :stzList)

			def TheseCellsAtPositionsQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		#>

	  #---------------------------------#
	 #  GETIING THE LIST OF ALL CELLS  #
	#---------------------------------#

	def Cells()

		aResult = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return aResult

		#< @FunctionFluentForm

		def CellsQ()
			return This.CellsQR(:stzList)

		def CellsQR(pcReturnType)
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
				return This.CellsQR(:stzList)

			def AllCellsQR(pcReturnType)
				return This.CellsQR(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------#

	def CellsAndTheirPositions()

		aResult = []
		nRows   = This.NumberOfRows()
		nCols   = This.NumberOfCol()

		for v = 1 to nRows

			for u = 1 to nCols
				aResult + [ This.Cell(u, v), [u, v ] ]
			next u

		next

		return aResult

		def CellsAndPositions()
			return This.CellsAndTheirPositions()

		def AllCellsAndTheirPositions()
			return This.CellsAndTheirPositions()

		def AllCellsAndPositions()
			return This.return This.CellsAndTheirPositions()

		def CellsXT()
			return This.CellsAndTheirPositions()

		def AllCellsXT()
			return This.return This.CellsAndTheirPositions()

	def PositionsAndCells()

		aResult = []
		nRows   = This.NumberOfRows()
		nCols   = This.NumberOfCol()

		for v = 1 to nRows
			for u = 1 to nCols
				aResult + [ [u, v ], This.Cell(u, v) ]
			next
		next

		return aResult

	def CellsAsPositions()

		aResult = []
		nRows   = This.NumberOfRows()
		nCols   = This.NumberOfCol()

		for v = 1 to nRows
			for u = 1 to nCols
				aResult + [u, v ]
			next
		next

		return aResult

		def AllCellsAsPositions()
			return This.CellsAsPositions()

	  #-----------------------------------------------------------#
	 #  GETIING THE LIST OF THE GIVEN CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------------#

	def TheseCellsAndTheirPositions(paCells)
		aResult = []
		nCells = len(paCells)

		for i = 1 to nCells
			aCell = paCells[i]
			aResult + [ This.Cell(aCell[1], aCell[2]), aCell ]
		next

		return aResult

		def TheseCellsAndPositions(paCells)
			return This.TheseCellsAndTheirPositions(paCells)

		def TheseCellsXT(paCells)
			return This.TheseCellsAndTheirPositions(paCells)

	def PositionsAndTheseCells(paCells)
		aResult = []
		nCells = len(paCells)

		for i = 1 to nCells
			aCell = paCells[i]
			aResult + [ aCell, This.Cell(paCells[1], paCells[2]) ]
		next

		return aResult
	
	  #------------------------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS BY TRANSFORMING IT TO A HASHLIST  #
	#------------------------------------------------------------------#

	def CellsToHashList()
		aResult = This.TheseCellsToHashList( This.CellsAsPositions() )
		return aResult

		#< @FunctionFluentForm

		def CellsToHashListQ()
			return This.CellsToHashListQR( :stzList )

		def CellsToHashListQR(pcReturnType)
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
				return This.CellsAsHashListQR(:stzList)

			def CellsAsHashListQR(pcReturnType)
				return This.CellsToHashListQR(pcReturnType)

		#>

	def TheseCellsToHashList(paCellsPos)
		# TODO: check if paCells are really cells and belong to the table!

		aResult = []
		nLen = len(paCellsPos)

		for i = 1 to nLen
			cellPos = paCellsPos[i]
			aResult + [ @@(cellPos), This.Cell(cellPos[1], cellPos[2]) ]
		next

		return aResult

		#< @FunctionFluentForm

		def TheseCellsToHashListQ(paCellsPos)
			return This.TheseCellsToHashListQR(paCellsPos, pcReturnType)

		def TheseCellsToHashListQR(paCellsPos, pcReturnType)
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
				return This.TheseCellsAsHashListQR(paCellsPos, pcReturnType)

			def TheseCellsAsHashListQR(paCellsPos, pcReturnType)
				return This.TheseCellsToHashListQR(paCellsPos, pcReturnType)

		#>

	  #==============================#
	 #  GETTING A SECTION OF CELLS  #
	#==============================#

	def Section( panCellPos1, panCellPos2 )
		aCells = This.SectionAsPositions( panCellPos1, panCellPos2 )
		nCells = len(aCells)
		aResult = []

		for i = 1 to nCells
			aCell = aCells[i]
			aResult + This.Cell(aCell[1], aCell[2])
		next

		return aResult
		
		#< @FunctionFluentForm
		
		def SectionQ( panCellPos1, panCellPos2 )
			return This.SectionQR( panCellPos1, panCellPos2, :stzList )

		def SectionQR( panCellPos1, panCellPos2, pcReturnType )
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
		
	def SectionXT( panCellPos1, panCellPos2 )
		
		aResult = This.SectionAsPositionsQ(panCellPos1, panCellPos2).
			       AssociatedWith( This.Section(panCellPos1, panCellPos2) )

		return aResult


		def SectionXTQ( panCellPos1, panCellPos2 )
			return This.SectionXTQR( panCellPos1, panCellPos2, :stzList )

		def SectionXTQR( panCellPos1, panCellPos2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionXT( panCellPos1, panCellPos2 ) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionXT( panCellPos1, panCellPos2 ) )

			other
				StzRaise("Unsupported return type!")
			off

	def SectionAsPositions( panCellPos1, panCellPos2 )
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
				panCellPos1 = Q(panCellPos1).FirstItemReplaced( :With = 1)
			ok

			if isString(panCellPos1[2]) and panCellPos1[2] = :FirstRow
				panCellPos1 = Q(panCellPos1).NthItemReplaced( 2, :With = 1)
			ok

			if isString(panCellPos2[1]) and panCellPos2[1] = :LastCol
				panCellPos2 = Q(panCellPos2).FirstItemReplaced( :With = This.NumberOfCol() )
			ok

			if isString(panCellPos2[2]) and panCellPos2[2] = :LastRow
				panCellPos2 = Q(panCellPos2).NthItemReplaced( 2, :With = This.NumberOfRows() )
			ok
		ok

		if isList(panCellPos2)
			if isString(panCellPos2[1]) and panCellPos2[1] = :LastCol
				panCellPos2[1] = This.NumberOfCol()
			ok

			if isString(panCellPos2[2]) and panCellPos2[2] = :LastRow
				panCellPos2[2] = This.NumberOfRows()
			ok

		ok

		if NOT ( isList(panCellPos1) and Q(panCellPos1).IsPairOfNumbers() and
			 isList(panCellPos2) and Q(panCellPos2).IsPairOfNumbers() )

			StzRaise("Incorrect params types! panCellPos1 and panCellPos2 must be pairs of numbers.")
		ok

		anPairs = Q([ panCellPos1, panCellPos2 ]).SortedInAscending()
		nCol1   = anPairs[1][1]
		nRow1   = anPairs[1][2]
		nCol2   = anPairs[2][1]
		nRow2   = anPairs[2][2]

		aResult = []
		for u = nRow1 to nRow2
			for v = nCol1 to nCol2
				aResult + [ v, u ]
			next v
		next u
	
		return aResult

		#< @FunctionFluentForm

		def SectionAsPositionsQ( panCellPos1, panCellPos2 )
			return This.SectionAsPositionsQR( panCellPos1, panCellPos2, :stzList )

		def SectionAsPositionsQR( panCellPos1, panCellPos2, pcReturnType )
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

	  #-----------------------------------------------------#
	 #   VERTICAL SECTIONS (SOME CELLS OF A GIVEN COLUMN)  #
	#-----------------------------------------------------#

	def VerticalSection(pCol, n1, n2)
		aCellsPos =  This.VerticalSectionAsPositions(pCol, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

	def VerticalSectionAsPositions(pCol, n1, n2)
		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				pCol = This.NumberOfColumns()

			but This.HasColName(pCol)
				pCol = This.FindCol(pCol)
			ok
		ok

		if NOT isNumber(pCol)
			StzRaise("Incorrect param type! pCol must be a number.")
		ok

		if isString(n1)
			if n1 = :First or n1 = :FirstRow
				n1 = 1
			ok
		ok

		if NOT isNumber(n1)
			StzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if n2 = :Last or n2 = :LastRow
				n2 = This.NumberOfRows()
			ok
		ok

		if NOT isNumber(n2)
			StzRaise("Incorrect param type! n2 must be a number.")
		ok

		aResult = []
		for i = n1 to n2
			aResult + [pCol, i]
		next

		return aResult

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#----------------------------------------------------#

	def HorizontalSection(nRow, n1, n2)
		aCellsPos =  This.HorizontalSectionAsPositions(nRow, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

	def HorizontalSectionAsPositions(nRow, n1, n2)
		if isString(nRow)
			if Q(nRow).IsOneOfThese([ :First, :FirstRow ])
				pRow = 1

			but Q(nRow).IsOneOfThese([ :Last, :LastRow ])
				nRow = This.NumberOfRows()

			ok
		ok

		if NOT isNumber(nRow)
			StzRaise("Incorrect param type! nRow must be a number.")
		ok

		if isString(n1)
			if Q(n1).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n1 = 1
			ok
		ok

		if NOT isNumber(n1)
			StzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if Q(n2).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n2 = This.NumberOfCols()
			ok
		ok

		if NOT isNumber(n2)
			StzRaise("Incorrect param type! n2 must be a number.")
		ok

		aResult = []
		for i = n1 to n2
			aResult + [i, nRow]
		next

		return aResult

	  #----------------------------------------#
	 #   FIRST CELL AND LAST CELL POSITIONS   #
	#----------------------------------------#

	def FirstCellPosition()
		return [1, 1]

	def LastCellPosition()
		return [ This.NumberOfCol(), This.NumberOfRows() ]

	  #-------------------------------------------------#
	 #   CONVERTING A SECTION OF CELLS TO A HASHLIST   #
	#-------------------------------------------------#

	def SectionToHashList(panCellPos1, panCell2)
		aResult = TheseCellsToHashList( This.SectionAsPositions(panCellPos1, panCell2) )
		return aResult

		def SectionToHashListQ(panCellPos1, panCellPos2)
			return This.SectionsToHashListQR(panCellPos1, panCellPos2, :stzList)

		def SectionToHashListQR(panCellPos1, panCellPos2, pcReturnType)
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

	def SectionToRange(paSection) // TODO
		aResult = []
		/* ... */

		return aResult

	def Range(paPair, paRange) // TODO
		/* ... */

	/// WORKING ON TABLE /////////////////////////////////////////////////////////////////

	  #==================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==================================================================================#

	def FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.FindAll("Ali") // or o1.FindAll( :Cells = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? o1.FindAll( :SubValue = "A" )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1] ]
		     ]
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Cells, :Value, :OfValue, :Values ])
				return This.FindCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :SubValues ])
				return This.FindSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		else
			return This.FindCellCS(pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForms

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
			return This.FindAllCS(pCellValueOrSubValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
			def FindAllOccurrences(pCellValueOrSubValue)
				return This.FindAll(pCellValueOrSubValue)		
	
			def FindOccurrences(pCellValueOrSubValue)
				return This.FindAll(pCellValueOrSubValue)
	
			def Occurrences(pCellValueOrSubValue)
				return This.FindAll(pCellValueOrSubValue)
		
			def Positions(pCellValueOrSubValue)
				return This.FindAll(pCellValueOrSubValue)
			#>

	def FindCellCS(pCellValue, pCaseSensitive)

		bCheckCase = FALSE
		if isString(pCellValue)
			bCheck = TRUE
		ok

		aCellsXT = This.CellsAndTheirPositions()

		aResult = []
		for i = 1 to len(aCellsXT)
			CellValue = aCellsXT[i][1]
			aCellPos  = aCellsXT[i][2]

			if isString(CellValue) and bCheckCase
				if Q(CellValue).IsEqualToCS(pCellValue, pCaseSensitive)
					aResult + aCellPos
				ok
			else
				if Q(cellValue).IsEqualTo(pCellValue)
					aResult + aCellPos
				ok
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindCellsCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def FindAllCellsCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)
			
		def OccurrencesOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def PositionsOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		#--

		def FindValueCS(pCellValue, pCaseSensitive)
			return This. FindCellCS(pCellValue, pCaseSensitive)

		def FindValuesCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def FindAllValuesCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)
			
		def OccurrencesOfValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def PositionsOfValuesCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindCell(pValue)
			return This.FindCellCS(pValue, :CaseSensitive = TRUE)

			def FindCells(pValue)
				return This.FindCell(pValue)

			def FindAllCells(pValue)
				return This.FindCell(pValue)

			def OccurrencesOfCell(pValue)
				return This.FindCell(pValue)

			def PositionsOfCell(pValue)
				return This.FindCell(pValue)

			#--
	
			def FindValue(pCellValue)
				return This. FindCell(pCellValue)
	
			def FindValues(pCellValue)
				return This.FindCell(pCellValue)
	
			def FindAllValues(pCellValue)
				return This.FindCell(pCellValue)
				
			def OccurrencesOfValue(pCellValue)
				return This.FindCell(pCellValue)
	
			def PositionsOfValues(pCellValue)
				return This.FindCell(pCellValue)

			#>
	
	def FindSubValueCS(pSubValue, pCaseSensitive)
		bCheckCase = FALSE
		if isString(pSubValue)
			bCheckCase = TRUE
		ok

		aCellsXT = This.CellsAndTheirPositions()

		aResult = []
		for i = 1 to len(aCellsXT)
			cellValue = aCellsXT[i][1]
			oCellValue = Q(cellValue)

			aCellPos  = aCellsXT[i][2]

			bCellIsString = isString(cellValue)
			bCellIsListOfStrings = isList(cellValue) and oCellValue.IsListOfStrings()


			if bCheckCase
				if bCellIsString = TRUE or bCellIsListOfStrings = TRUE

					if oCellValue.ContainsCS(pSubValue, pCaseSensitive)
						aResult + [ aCellPos, oCellValue.FindAllCS(pSubValue, pCaseSensitive) ]
					ok
				ok
			else

				if isList(cellValue) and oCellValue.Contains(pSubValue)
					aResult + [ aCellPos, oCellValue.FindAll(pSubValue) ]
				ok
			ok
		next

		return aResult

		def FindSubValuesCs(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

		def FindAllSubValuesCs(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

		def PositionsOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValue(pSubValue)
			return This.FindSubValueCS(pSubValue, :CaseSensitive = TRUE)

			def FindSubValues(pSuvValue)
				return This.FindSubValue(pSubValue)

			def FindAllSubValues(pSubValue)
				return This.FindSubValue(pSubValue)

			def PositionsOfSubValue(pSubValue)
				return This.FindSubValue(pSubValue)

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#---------------------------------------------------------------------------------------#

	def FindNthCS(n, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindNthCellCS(n, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
				return This.FindNthSubValueCS(n, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok

		else
			return This.FindNthCellCS(n, pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(n, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthCS(n, pCellValueOrSubValue, pCaseSensitive)		

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindNth(n, pCellValueOrSubValue)
			return This.FindNthCS(n, pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			def FindNthOccurrence(n, pCellValueOrSubValue)
				return This.FindNth(n, pCellValueOrSubValue)	

	def FindNthCellCS(n, pCellValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence ])
				n = This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = []

		aFoundCells = This.FindAllCS( :Cells = pCellValue, pCaseSensitive)
		if n > 0 and n <= len(aCells)
			aResult = aFoundCells[n]
		ok	

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfCellCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		def FindNthValueCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindNthCell(n, pValue)
			return This.FindNthCellCS(n, pValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
			def FindNthOccurrenceOfCell(n, pCellValue)
				return This.FindNthCell(n, pCellValue)
	
			def FindNthValue(n, pCellValue)
				return This.FindNthCell(n, pCellValue)
	
			def FindNthOccurrenceOfValue(n, pCellValue)
				return This.FindNthCell(n, pCellValue)
	
			#>
	
	def FindNthSubValueCS(n, pSubValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence ])
				n = This.CountSubValuesCS(pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindSubValuesCS(pSubValue, pCaseSensitive)

		aResult = []
		m = 0
		for line in anPos
			for i = 1 to len(line[2])
				m += 1
				if m = n
					aResult = [ line[1], line[2][i] ]
					exit 2
				ok
			next
		next

		return aResult
			
		def FindNthOccurrenceOfSubValueCS(n, pSubValue, pCaseSensitive)
			return This.FindNthSubValueCS(n, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValue(n, pSubValue)
			return This.FindNthSubValueCS(n, pSubValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfSubValue(n, pSubValueValue)
				return This.FindNthSubValue(n, pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindFirstCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindFirstCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return This.FindFirstCS(pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			def FindFirstOccurrence(pCellValueOrSubValue)
				return This.FindFirst(pCellValueOrSubValue)	

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
			return This.FindFirstCellCS(pValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfCell(pCellValue)
				return This.FindFirstCell(pCellValue)
	
			def FindFirstValue(pCellValue)
				return This.FindFirstCell(pCellValue)
	
			def FindFirstOccurrenceOfValue(pCellValue)
				return This.FindFirstCell(pCellValue)
	
	def FindFirstSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(1, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindFirstSubValueCS(pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValue(pSubValue)
			return This.FindFirstSubValueCS(pSubValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfSubValue(pSubValueValue)
				return This.FindFirstSubValue(pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindLastCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindLastCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return This.FindLastCS(pCellValue, :CaseSensitive = TRUE)
	
			def FindLastOccurrence(pCellValue)
				return This.FindLast(pCellValue)	

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
			return This.FindLastCellCS(pValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfCell(pCellValue)
				return This.FindLastCell(pCellValue)
	
			def FindLastValue(pCellValue)
				return This.FindLastCell(pCellValue)
	
			def FindLastOccurrenceOfValue(pCellValue)
				return This.FindLastCell(pCellValue)
		
	def FindLastSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(:Last, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindLastSubValueCS(pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValue(pSubValue)
			return This.FindLastSubValueCS(pSubValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfSubValue(pSubValueValue)
				return This.FindLastSubValue(pSubValue)

	  #==================================================================================#
	 #  NUMBER OF OCCURRENCE A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==================================================================================#

	def NumberOfOccurrenceCS(pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrence( :OfCell = "Ali" ) #--> 2
		? o1.NumberOfOccurrence( :OfSubValue = "A" ) #--> 3
		*/

		if isList(pValue)
			if Q(pValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Cells, :Value, :OfValue, :Values ])
				return This.NumberOfOccurrenceOfCellCS(pValue[2], pCaseSensitive)

			but Q(pValue).IsOneOfTheseNamedParams([ :SubValue, :SubValues, :OfSubValue, :OfSubValues ])
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

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrence(pValue)
			return This.NumberOfOccurrenceCS(pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		def Count(pValue)
			return This.NumberOfOccurrence(pValue)

		#>

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

		def NumberOfOccurrencesOfValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCell(pCellValue)
			return This.NumberOfOccurrenceOfCellCS(pCellValue, :CaseSensitive = TRUE)

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

		def NumberOfOccurrencesOfValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#>

	def NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		aTemp = This.FindSubValueCS(pSubValue, pCaseSensitive)
		nResult = 0

		for line in aTemp
			nResult += len(line[2])
		next

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountSubValuesCS(psubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def NumberOfOccurrencesOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountSubValues(psubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#>

	  #=============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A CELL  #
	#=============================================================================#

	def ContainsCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Dan", "Ali", "Sam" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.Contains( :Cell = "Ali" ) #--> TRUE
		? o1.Contains( :SubValue = "a" ) #--> TRUE
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :Value, :Cells, :Values ])
				return This.ContainsCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :SubValues ])
				return This.ContainsSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.ContainsCellCS(pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY
	
		def Contains(pCellValueOrSubValue)
			return This.ContainsCS(pCellValueOrSubValue, :CaseSensitive = TRUE)

	def ContainsCellCS(pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def ContainsValueCS(pCellValue, pCaseSensitive)
			return This.ContainsCellCS(pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsCell(pCellValue)
			return This.ContainsCellCS(pCellValue, :CaseSensitive = TRUE)

			def ContainsValue(pCellValue)
				return This.ContainsCell(pCellValue)

	  #-----------------------------------------------#
	 #  CHECKING IF THE TABBLE CONTAINS A GIVEN ROW  #
	#-----------------------------------------------#

	def ContainsRowCS(paRow, pCaseSensitive)
		bResult = FALSE

		if isList(paRow) and len(paRow) = This.NumberOfRows()

			bResult = This.RowsQ().ContainsCS(paRow, pCaseSensitive)
		ok

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsRow(paRow)
		return This.ContainsRowCS(paRow, :CaseSensitive = TRUE)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN ROWS  #
	#-------------------------------------------------#

	def ContainsRowsCS(paRows, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCols([
			[ 10, "Imed", 52  ],
			[ 30, "Karim", 48 ]
		])

		#--> TRUE
		*/

		bResult = TRUE

		for aRow in paRows
			if NOT This.ContainsRowCS(aRow, pCaseSensitive)
				bResult = FALSE
				exit
			ok

		next

		return bResult

		def ContainsTheseRowsCS(paRows, pCaseSensitive)
			return This.ContainsRowsCS(paRows, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsRows(paRows)
			return This.ContainsRowsCS(paRows, :CaseSensitive = TRUE)

			def ContainsTheseRows(paRows)
				return This.ContainsRows(paRows)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN COLUMN  #
	#-------------------------------------------------#

	def ContainsColCS(paCol, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
		#--> TRUE
		*/

		bResult = FALSE

		if isList(paCol) and len(paCol) = 2 and
		   isString(paCol[1]) and This.HasColName(paCol[1]) and
		   isList(paCol[2]) and len(paCol[2]) = This.NumberOfRows()

			cCol = paCol[1]
			bResult = This.ColQ(cCol).IsEqualToCS(paCol[2], pCaseSensitive)
		ok

		return bResult

		def ContainsColumnCS(paCol, pCaseSensitive)
			return This.ContainsColCS(paCol, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsCol(paCol)
			return This.ContainsColCS(paCol, :CaseSensitive = TRUE)

			def ContainsColumn(paCol)
				return This.ContainsCol(paCol)

	  #----------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN COLUMNS  #
	#----------------------------------------------------#

	def ContainsColsCS(paCols, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCols([
			:NAME = [ "Imed", "Hatem", "Karim" ],
			:AGE  = [ 52, 46, 48 ]
		])

		#--> TRUE
		*/

		bResult = TRUE

		for aCol in paCols
			if NOT This.ContainsColCS(aCol, pCaseSensitive)
				bResult = FALSE
				exit
			ok

		next

		return bResult

		def ContainsTheseColsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsTheseColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsCols(paCols)
			return This.ContainsColsCS(paCols, :CaseSensitive = TRUE)

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
			return TRUE

		else
			return FALSE
		ok

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValue(pSubValue)
			return This.ContainsSubValueCS(pSubValue, :CaseSensitive = TRUE)


	/// WORKING ON SOME CELLS //////////////////////////////////////////////////////////////////////////

	  #================================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN A GIVEN NUMBER OF CELLS  #
	#================================================================================================#

	def FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.FindInCells( [ [1,2], [2,2], [1,3] ], :Value = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? o1.FindInCellsCS( [ [1,2], [2,2], [1,3] ], :SubValue = "A", :CS = FALSE )
		#--> [
				[ [1, 2], [1] ],
				[ [1, 3], [1] ]
		     ]
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Cells, :Value, :OfValue, :Values ])
				return This.FindValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :SubValues ])
				return This.FindSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.FindValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		
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

			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)

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

	def FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		bCheckCase = FALSE
		if isString(pCellValue)
			bCheckCase = TRUE
		ok

		aCellsXT = This.TheseCellsAndTheirPositions(paCells)

		aResult = []
		for i = 1 to len(aCellsXT)
			CellValue = aCellsXT[i][1]
			aCellPos  = aCellsXT[i][2]

			if isString(CellValue) and bCheckCase
				if Q(CellValue).IsEqualToCS(pCellValue, pCaseSensitive)
					aResult + aCellPos
				ok
			else
				if Q(cellValue).IsEqualTo(pCellValue)
					aResult + aCellPos
				ok
			ok
		next

		return aResult

		#< @FunctionAlternativeForms
			
		def OccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def PositionsOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(ppaCells, CellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInCells(pValue)
			return This.FindValueInCellsCS(pValue, :CaseSensitive = TRUE)
			
			def OccurrencesOfValueInCells(paCells, pCellValue)
				return This.FindValueInCells(paCells, pCellValue)

			def PositionsOfValueInCells(paCells, pCellValue)
				return This.FindValueInCells(ppaCells, CellValue)
	
	def FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		bCheckCase = FALSE
		if isString(pSubValue)
			bCheckCase = TRUE
		ok

		aCellsXT = This.TheseCellsAndTheirPositions(paCells)

		aResult = []
		for i = 1 to len(aCellsXT)
			cellValue = aCellsXT[i][1]
			oCellValue = Q(cellValue)

			aCellPos  = aCellsXT[i][2]

			bCellIsString = isString(cellValue)
			bCellIsListOfStrings = isList(cellValue) and oCellValue.IsListOfStrings()


			if bCheckCase
				if bCellIsString = TRUE or bCellIsListOfStrings = TRUE

					if oCellValue.ContainsCS(pSubValue, pCaseSensitive)
						aResult + [ aCellPos, oCellValue.FindAllCS(pSubValue, pCaseSensitive) ]
					ok
				ok
			else

				if isList(cellValue) and oCellValue.Contains(pSubValue)
					aResult + [ aCellPos, oCellValue.FindAll(pSubValue) ]
				ok
			ok
		next

		return aResult

		def FindSubValuesInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def FindAllSubValuesInCellsCs(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def OccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def PositionsOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

			def FindSubValuesInCells(paCells, pSuvValue)
				return This.FindSubValueInCells(paCells, pSubValue)

			def FindAllSubValuesInCells(paCells, pSubValue)
				return This.FindSubValueInCells(paCells, pSubValue)

			def OccurrencesOfSubValueInCells(paCells, pSubValue)
				return This.FindSubValueInCells(paCells, pSubValue)

			def PositionsOfSubValueInCells(paCells, pSubValue)
				return This.FindSubValueInCells(paCells, pSubValue)

	  #---------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#---------------------------------------------------------------------------------------------#

	def FindNthInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindNthValueInCellsCS(n, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
				return This.FindNthSubValueInCellsCS(n, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindNthValueInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)		

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindNthInCells(n, paCells, pCellValueOrSubValue)
			return This.FindNthInCellsCS(n, paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			def FindNthOccurrenceInCells(n, paCells, pCellValueOrSubValue)
				return This.FindNthInCells(n, paCells, pCellValueOrSubValue)	

	def FindNthValueInCellsCS(n, paCells, pCellValue, pCaseSensitive)
		# Returns the cell position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence, :FirstValue ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence, :LastValue ])
				n = This.NumberOfOccurrenceInCellsCS(paCells, pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindAllInCellsCS( paCells, pCellValue, pCaseSensitive)

		aResult = []

		if len(anPos) > 0 and n <= eing_len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		def FindNthOccurrenceOfValueInCellCS(n, paCells, pCellValue, pCaseSensitive)
			return This.FindNthValueInCellCS(n, paCells, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInCells(n, paCells, pValue)
			return This.FindNthCellCS(n, pValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfValueInCells(n, paCells, pCellValue)
				return This.FindNthValueInCells(n, paCells, pValue)
	
	def FindNthSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)
		# Returns the subvalue position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence, :FirstSubValue ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence, :LastSubValue ])
				n = This.CountSubValuesInCellsCS(paCells, pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindSubValuesInCellsCS(paCells, pSubValue, pCaseSensitive)

		aResult = []
		m = 0
		for line in anPos
			for i = 1 to len(line[2])
				m += 1
				if m = n
					aResult = [ line[1], line[2][i] ]
					exit 2
				ok
			next
		next

		return aResult
			
		def FindNthOccurrenceOfSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInCells(n, paCells, pSubValue)
			return This.FindNthSubValueInCellsCS(n, paCells, pSubValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfSubValueInCells(n, paCells, pSubValueValue)
				return This.FindNthSubValueInCells(n, paCells, pSubValue)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#------------------------------------------------------------------------------------------------#

	def FindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return This.FindFirstInCellsCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			def FindFirstOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.FindFirstInCells(paCells, pCellValueOrSubValue)	

	def FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(1, paCells, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInCells(paCells, pValue)
			return This.FindFirstValueInCellCS(paCells, pValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfValueInCells(paCells, pCellValue)
				return This.FindFirstValueInCells(paCells, pValue)
	
	def FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(1, paCells, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInCells(paCells, pSubValue)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfSubValueInCells(paCells, pSubValueValue)
				return This.FindFirstSubValueInCells(paCells, pSubValue)

	  #-----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------------------------------------#

	def FindLastInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return This.FindLastInCellsCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			def FindLastOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.FindLastInCells(paCells, pCellValueOrSubValue)	

	def FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(:Last, paCells, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInCells(paCells, pValue)
			return This.FindLastValueInCellCS(paCells, pValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfValueInCells(paCells, pCellValue)
				return This.FindLastValueInCells(paCells, pValue)
	
	def FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInCells(paCells, pSubValue)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

			def FindLasttOccurrenceOfSubValueInCells(paCells, pSubValueValue)
				return This.FindLastSubValueInCells(paCells, pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF  CELLS  #
	#----------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)
	
			#< @FunctionAlternativeForms

			def NumberOfOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
	
			def CountInCells(paCells, pCellValueOrSubValue)
				return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

			#>

	def NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		nResult = len( This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def CountValuesInCellsCS(paCells, pCellValue, pCaseSensitive)
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
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, :CaseSensitive = TRUE)

		#--

		def NumberOfOccurrenceOfValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def CountValuesInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def CountValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		#--

		def NumberOfOccurrencesInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def NumberOfOccurrenceInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		#>

	def NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		nResult = 0

		for line in anPos
			nResult += len(line[2])
		next

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def CountSubValuesInCellsCS(paCells, pSubValue, pCaseSensitive)
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
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

		#--

		def NumberOfOccurrenceOfSubValueInCells(paCells, pSubValue)
			return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

		def CountSubValuesInCells(paCells, pSubValue)
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
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue ])
				return This.CellsContainValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue ])
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
			return This.CellsContainCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)

			def ContainsInCells(paCells, pCellValueOrSubValue)
				return This.CellsContain(paCells, pCellValueOrSubValue)

	def CellsContainValueCS(paCells, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellsCS(paCells, pValue, pCaseSensitive) ) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsValueInCellsCS(paCells, pValue, pCaseSensitive)
			return This.CellsContainValueCS(paCells, pValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def CellsContainValue(paCells, pValue)
			return This.CellsContainValueCS(paCells, pValue, :CaseSensitive = TRUE)

			def ContainsValueInCells(paCells, pValue)
				return This.CellsContainValue(paCells, pValue)

	def CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)
		aTemp = This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		if isList(aTemp) and len(aTemp) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def CellsContainSubValue(paCells, pSubValue)
			return This.CellsContainSubValueCS(paCells, pSubValue, :CaseSensitive = TRUE)

			def ContainsSubValueInCells(paCells, pSubValue)
				return This.CellsContainSubValue(paCells, pSubValue)

	/// WORKING ON ROWS //////////////////////////////////////////////////////////////////////

	  #======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#======================================================================================#

	def FindInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? o1.FindInRow(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? o1.FindInRow(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? o1.FindInRow( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :Cells, :Value, :Values ])
				return This.FindValueInRowCS(pRow, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :SubValue ])
				return This.FindSubValueInRowCS(pRow, pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.FindValueInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindInRow(pRow, pCellValueOrSubValue)
			return This.FindInRowCS(pRow, pCellValueOrSubValue, :CaseSensitive = TRUE)

	def FindValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInRow(pRow, pCellValue)
			return This.FindValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

	def FindSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInRow(pRow, pSubValue)
			return This.FindValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

	  #=========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#=========================================================================================#

	def FindNthInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :N, :Nth, :Occurrence ])
			n = n[2]
		ok

		if isList(pRow) and Q(pRow).IsOneOfTheseNamedParams([ :Row, :InRow ])
			pRow = pRow[2]
		ok

		return This.FindNthInCellsCS(n, This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInRow(n, pRow, pCellValueOrSubValue)
			return This.FindNthInRowCS(n, pRow, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindNthOccurrenceInRow(n, pRow, pCellValueOrSubValue)
				return This.FindNthInRow(n, pRow, pCellValueOrSubValue)

	def FindNthValueInRowCS(n, pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(n, This.RowAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInRow(n, pRow, pCellValue)
			return This.FindNthValueInRowCS(n, pRow, pCellValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfValueInRow(n, pRow, pCellValue)
				return This.FindNthValueInRow(n, pRow, pCellValue)

	def FindNthSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(n, This.RowAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInRow(n, pRow, pSubValue)
			return This.FindNthSubValueInRowCS(n, pRow, pSubValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfSubValueInRow(n, pRow, pSubValue)
				return This.FindNthSubValueInRow(n, pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(1, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInRow(pRow, pCellValueOrSubValue)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindFirstOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindFirstInRow(pRow, pCellValueOrSubValue)

	def FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInRow(pRow, pCellValue)
			return This.FindFirstValueInRowCS(pRow, pCellValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindFirstValueInRow(pRow, pCellValue)

	def FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInRow(pRow, pSubValue)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

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
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindLastOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindLastInRow(pRow, pCellValueOrSubValue)

	def FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInRow(pRow, pCellValue)
			return This.FindLastValueInRowCS(pRow, pCellValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindLastValueInRow(pRow, pCellValue)

	def FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

		def FindLastOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInRow(pRow, pSubValue)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindLastSubValueInRow(pRow, pSubValue)

	  #---------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A ROW  #
	#---------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInRow( :OfCell = "Ali" ) #--> 2
		? o1.CountInRow( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.RowAsPositions(pRow), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		def CountInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

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

		def NumberOfOccurrencesOfValuesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfValuesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountValuesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInRow(pRow, pCellValue)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, :CaseSensitive = TRUE)

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

		def NumberOfOccurrencesOfValuesInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfValueInRowInRow(pRow, pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRowInRow(pRow, pRow, pValue)

		def CountOfValuesInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountValuesInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValuesInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountOfSubValuesInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountSubValuesInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def NumberOfOccurrencesOfSubValuesInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountOfSubValuesInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountSubValuesInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		#>

	  #============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A ROW  #
	#============================================================================#

	def ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInRow(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInRow(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInRowCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowContainsCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInRow(pRow, pCellValueOrSubValue)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, :CaseSensitive = TRUE)

			def RowContains(pRow, pCellValueOrSubValue)
				return This.ContainsInRow(pRow, pCellValueOrSubValue)

	def ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
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
			return This.ContainsCellInRowCS(pRow, pCellValue, :CaseSensitive = TRUE)

			def RowContainsCell(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)

			def ContainsValueInRow(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)
	
	def ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def RowContainsSubValueCS(pRow, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInRow(pRow, pSubValue)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

			def RowContainsSubValue(pRow, pSubValue)
				return This.ContainsSubValueInRow(pRow, pSubValue)

	/// WORKING ON COLUMNS //////////////////////////////////////////////////////////////////////

	  #=========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#=========================================================================================#

	def FindInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])

		? o1.FindInCol( :FIRSTNAME, :Value = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? o1.FindInCol( :FIRSTNAME, :SubValue = "a" ) #--> [ ]

		? o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE )
		#--> [
			[ [2, 1], [2]    ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		pCol = This.ColToName(pCol)

		return This.FindInCellsCS( This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		def FindInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindInCol(pCol, pCellValueOrSubValue)
			return This.FindInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)

			def FindInColumn(pCol, pCellValueOrSubValue)
				return This.FindInCol(pCol, pCellValueOrSubValue)

	def FindValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		def FindValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindValueInColCS(pCol, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInCol(pCol, pCellValue)
			return This.FindValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			def FindValueInColumn(pCol, pCellValue)
				return This.FindValueInCol(pCol, pCellValue)

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		def FindSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInCol(pCol, pSubValue)
			return This.FindValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			def FindSubValueInColumn(pCol, pSubValue)
				return This.FindSubValueInCol(pCol, pSubValue)

	  #============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#============================================================================================#

	def FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :Nth, :N, :Occurrence ])
			n = n[2]
		ok

		pCol = This.ColToName(pCol)

		return This.FindNthInCellsCS(n, This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindNthInCol(n, pCol, pCellValueOrSubValue)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			#< @FunctionAlternativeForms

			def FindNthInColumn(n, pCol, pCellValueOrSubValue)
				return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

			def FindNthOccurrenceInCol(n, pCol, pCellValueOrSubValue)
				return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

			def FindNthOccurrenceInColumn(n, pCol, pCellValueOrSubValue)
				return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

			#>

	def FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		if isList(pCol) and Q(pCol).IsOneOfTheseNamedParams([
					:Col, :InCol, :OfCol,
					:Column, :InColumn, :OfColumns,
					:Cols, :InCols, :OfCols,
					:Columns, :InColumns, :OfColumnss
				    ])

			pCol = pCol[2]
		ok

		return This.FndNthInCellsCS(n, This.ColAsPositions(pcol), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumCS(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColCs(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnCS(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		#>


		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInCol(n, pCol, pCellValue)
			return This.FindNthValueInColCS(n, pCol, pCellValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms

			def FindNthValueInColumn(n, pCol, pCellValue)
				return This.FindNthValueInCol(n, pCol, pCellValue)

			def FindNthOccurrenceOfValueInCol(n, pCol, pCellValue)
				return This.FindNthValueInCol(n, pCol, pCellValue)

			def FindNthOccurrenceOfValueInColumn(n, pCol, pCellValue)
				return This.FindNthValueInCol(n, pCol, pCellValue)

			#>

	def FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		aResult = []
		if n > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInCol(n, pCol, pSubValue)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, :CaseSensitive = TRUE)

			#< @FuntionAlternativeForms

			def FindNthSubValueInColum(n, pCol, pSubValue)
				return This.FindNthSubValueInCol(n, pCol, pSubValue)

			def FindNthOccurrenceOfSubValueInCol(n, pCol, pSubValue)
				return This.FindNthSubValueInCol(n, pCol, pSubValue)

			def FindNthOccurrenceOfSubValueInColumn(n, pCol, pSubValue)
				return This.FindNthSubValueInCol(n, pCol, pSubValue)

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
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			#< @FunctionAlternativeForms

			def FindFirstInColumn( pCol, pCellValueOrSubValue)
				return This.FindFirstInCol(pCol, pCellValueOrSubValue)

			def FindFirstOccurrenceInCol( pCol, pCellValueOrSubValue)
				return This.FindFirstInCol(pCol, pCellValueOrSubValue)

			def FindFirstOccurrenceInColumn( pCol, pCellValueOrSubValue)
				return This.FindFirstInCol(pCol, pCellValueOrSubValue)

			#>

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
			return This.FindFirstValueInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms

			def FindFirstValueInColumn(pCol, pCellValue)
				return This.FindFirstValueInCol(pCol, pCellValue)

			def FindFirstOccurrenceOfValueInCol(pCol, pCellValue)
				return This.FindFirstValueInCol(pCol, pCellValue)

			def FindFirstOccurrenceOfValueInColumn(pCol, pCellValue)
				return This.FindFirstValueInCol(pCol, pCellValue)

			#>

	def FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInCol(pCol, pSubValue)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

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
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			#< @FunctionAlternativeForms

			def FindLastInColumn( pCol, pCellValueOrSubValue)
				return This.FindLastInCol(pCol, pCellValueOrSubValue)

			def FindLastOccurrenceInCol( pCol, pCellValueOrSubValue)
				return This.FindLastInCol(pCol, pCellValueOrSubValue)

			def FindLastOccurrenceInColumn( pCol, pCellValueOrSubValue)
				return This.FindLastInCol(pCol, pCellValueOrSubValue)

			#>

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
			return This.FindLastValueInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms

			def FindLastValueInColumn(pCol, pCellValue)
				return This.FindLastValueInCol(pCol, pCellValue)

			def FindLastOccurrenceOfValueInCol(pCol, pCellValue)
				return This.FindLastValueInCol(pCol, pCellValue)

			def FindLastOccurrenceOfValueInColumn(pCol, pCellValue)
				return This.FindLastValueInCol(pCol, pCellValue)

			#>

	def FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

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
			return This.FindLastSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

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

	def NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInCol( :OfCell = "Ali" ) #--> 2
		? o1.CountInCol( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.ColAsPositions(pCol), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		def CountInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		def CountInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInCol(pCol, pValue)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
			def NumberOfOccurrenceInColumn(pCol, pValue)
				return This.NumberOfOccurrenceInCol(pCol, pValue)
	
			def NumberOfOccurrencesInCol(pCol, pValue)
				return This.NumberOfOccurrenceInCol(pCol, pValue)

			def NumberOfOccurrencesInColumn(pCol, pValue)
				return This.NumberOfOccurrenceInCol(pCol, pValue)
	
			def CountInCol(pCol, pValue)
				return This.NumberOfOccurrenceInCol(pCol, pValue)

			def CountInColumn(pCol, pValue)
				return This.NumberOfOccurrenceInCol(pCol, pValue)
	
			#>

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

		def NumberOfOccurrencesOfValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValuesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValuesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValueInColumCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValuesInColumCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

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
	
			def NumberOfOccurrencesOfValuesInCol(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			def NumberOfOccurrencesOfValuesInColumn(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			#--
	
			def CountOfValueInCol(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			def CountOfValueInColumn(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			#--
	
			def CountOfValuesInCol(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			def CountOfValuesInColumn(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			#--
	
			def CountValueInCol(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			def CountValueInColum(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			#--
	
			def CountValuesInCol(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			def CountValuesInColum(pCol, pValue)
				return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
			#>

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

		def NumberOfOccurrencesOfSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountSubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
			def NumberOfOccurrenceOfSubValueInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			#--
	
			def NumberOfOccurrencesOfSubValueInCol(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			def NumberOfOccurrencesOfSubValueInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			#--
	
			def NumberOfOccurrencesOfSubValuesInCol(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			def NumberOfOccurrencesOfSubValuesInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			#--
	
			def CountOfSubValueInCol(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			def CountOfSubValueInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			#--
	
			def CountOfSubValuesInCol(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			def CountOfSubValuesInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			#--
	
			def CountSubValuesInCol(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
			def CountSubValuesInColumn(pCol, pSubValue)
				return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#>

	  #===============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A COLUMN  #
	#===============================================================================#

	def ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInCol(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInCol(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInColCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		if isList(pCol) and Q(pCol).IsOneOfTheseNamedParams([
					:Col, :Column, :InCol, :InColumn, :OfCol, :OfColumn,
					:Cols, :Columns, :InCols, :InColumns, :OfCols, :OfColumns
				    ])

			pCol = pCol[2]
		ok

		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				pCol = This.NumberOfCols()
		
			else
				StzRaise("Incorrect param type! pCol must be a number.")
			ok
		ok

		return This.ContainsInCellsCS(This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColumContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInCol(pCol, pCellValueOrSubValue)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms

			def ContainsInColumn(pCol, pCellValueOrSubValue)
				return This.ContainsInCol(pCol, pCellValueOrSubValue)

			def ColContains(pCol, pCellValueOrSubValue)
				return This.ContainsInCol(pCol, pCellValueOrSubValue)

			def ColumnContains(pCol, pCellValueOrSubValue)
				return This.ContainsInCol(pCol, pCellValueOrSubValue)

			#>

	def ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
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

		def ContainsCellInCol(pCol, pCellValue)
			return This.ContainsCellInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
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
	
	def ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
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
			return This.ContainsSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			#< @FunctionAlternativeForms
	
			def ContainsSubValueInColumn(pCol, pSubValue)
				return This.ContainsSubValueInCol(pCol, pSubValue)
	
			def ColContainsSubValue(pCol, pSubValue)
				return This.ContainsSubValueInCol(pCol, pSubValue)
	
			def ColumnContainsSubValue(pCol, pSubValue)
				return This.ContainsSubValueInCol(pCol, pSubValue)
	
			#>

	/// WORKING ON SECTIONS //////////////////////////////////////////////////////////////////////

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#==========================================================================================#

	def FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? o1.FindInSection(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? o1.FindInSection(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? o1.FindInSection( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :Cells, :Value, :Values ])
				return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :SubValue ])
				return This.FindSubValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, :CaseSensitive = TRUE)

	def FindValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInSection(paSection1, paSection2, pCellValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

	def FindSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#=============================================================================================#

	def FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :N, :Nth, :Occurrence ])
			n = n[2]
		ok

		return This.FindNthInCellsCS(n, This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInSection(n, paSection1, paSection2, pCellValueOrSubValue)
			return This.FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindNthOccurrenceInSection(n, paSection1, paSection2, pCellValueOrSubValue)
				return This.FindNthInSection(n, paSection1, paSection2, pCellValueOrSubValue)

	def FindNthValueInSectionCS(n, paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(n, This.SectionAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInSection(n, paSection1, paSection2, pCellValue)
			return This.FindNthValueInSectionCS(n, paSection1, paSection2, pCellValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfValueInSection(n, paSection1, paSection2, pCellValue)
				return This.FindNthValueInSection(n, paSection1, paSection2, pCellValue)

	def FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(n, This.SectionAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInSection(n, paSection1, paSection2, pSubValue)
			return This.FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfSubValueInSection(n, paSection1, paSection2, pSubValue)
				return This.FindNthSubValueInSection(n, paSection1, paSection2, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-------------------------------------------------------------------------#

	def FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(1, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindFirstOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInSection(paSection1, paSection2, pCellValue)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindFirstValueInSection(paSection1, paSection2, pCellValue)

	def FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

		def FindFirstOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindFirstSubValueInSection(paSection1, paSection2, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-------------------------------------------------------------------------#

	def FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(:Last, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindLastOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInSection(paSection1, paSection2, pCellValue)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindLastValueInSection(paSection1, paSection2, pCellValue)

	def FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

		def FindLastOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindLastSubValueInSection(paSection1, paSection2, pSubValue)

	  #---------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A SECTION  #
	#---------------------------------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInSection( :OfCell = "Ali" ) #--> 2
		? o1.CountInSection( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.SectionAsPositions(paSection1, paSection2), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def CountInSection(paSection1, paSection2, pValue)
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

		def NumberOfOccurrencesOfValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pCellValue)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, :CaseSensitive = TRUE)

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

		def NumberOfOccurrencesOfValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfValueInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)

		def CountOfValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValuesInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountOfSubValuesInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountSubValuesInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def NumberOfOccurrencesOfSubValuesInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountOfSubValuesInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountSubValuesInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		#>

	  #================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A SECTION  #
	#================================================================================#

	def ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInSection(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInSection(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInSectionCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def SectionContainsCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, :CaseSensitive = TRUE)

			def SectionContains(paSection1, paSection2, pCellValueOrSubValue)
				return This.ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)

	def ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
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
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, :CaseSensitive = TRUE)

			def SectionContainsCell(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)

			def ContainsValueInSection(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)
	
	def ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def SectionContainsSubValueCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInSection(paSection1, paSection2, pSubValue)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, :CaseSensitive = TRUE)

			def SectionContainsSubValue(paSection1, paSection2, pSubValue)
				return This.ContainsSubValueInSection(paSection1, paSection2, pSubValue)

	///////////////////////////////////////////////////////////////////

	  #=================================================#
	 #  REPLACING CELLS (PASTING NEW VALUES IN CELLS)  #
	#=================================================#

	def ReplaceCell(pCol, pnRow, pNewCellValue)
		cCol = This.ColToName(pCol)
		This.Table()[cCol][pnRow] = pNewCellValue

	def ReplaceCells(paCellsPos, paNewCellsValues)
		if isList(paNewCellsValues) and Q(paNewCellsValues).IsByOrWithNamedParam()
			paNewCellsValues = paNewCellsValues[2]
		ok
	
		for i = 1 to len(paCellsPos)
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewCellsValues[i])
		next

		def ReplaceTheseCells(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

	def ReplaceCellsByMany(paCellsPos, paNewValues)

		if isList(paNewValues) and
		   Q(paNewValues).IsByOrWithNamedParam()
			paNewValues = paNewValues[2]
		ok

		if NOT BothAreLists(paCellsPos, paNewValues)
			StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
		ok

		nLenCells  = len(paCellsPos)
		nLenValues = len(paNewValues)
		
		if nLenValues >= nLenCells

			aValues = Q(paNewValues).Section(1, nLenCells)
		else
	
			aValues = Q(paNewValues).Section(1, nLenValues)
			for i = nLenValues + 1 to nLenCells
				aValues + This.Cell(paCellsPos[i][1], paCellsPos[i][2])
			next
		ok

		i = 0
		for i = 1 to len(paCellsPos)
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], aValues[i])
		next

	  #==============================#
	 #  REPLACING CELLS IN COLUMNS  #
	#==============================#

	def ReplaceCol(pCol, paNewCol)
		if isList(paNewCol) and
		   Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		if isString(paNewCol)
			This.ReplaceColName(pCol, paNewCol)
			return
		ok

		if NOT isList(paNewCol)
			StzRaise("Incorrect param type! paNewCol must be a list.")
		ok

		aColCells = This.ColAsPositions(pCol)
		This.ReplaceCellsByMany(aColCells, paNewCol)

		def ReplaceColumn(pCol, paNewCol)
			This.ReplaceCol(pCol, pNewCol)

	def ReplaceAllCols(paNewCol)
		if isList(paNewCol) and
		   Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		if NOT isList(paNewCol) 
			StzRaise("Incorrect param type! paNewCol must be a list.")
		ok

		for i = 1 to This.NumberOfCols()
			This.ReplaceCol(i, paNewCol)
		next

		def ReplaceAllColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		def ReplaceCols(paNewCols)
			This.ReplaceAllCols(paNewCols)

		def ReplaceColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

	def ReplaceTheseCols(paCols, paNewCols)
		if Q(paNewCols).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCols = paNewCols[2]
		ok

		aCells = This.CellsInTheseColsAsPositions(paCols)
		This.ReplaceCells(aCells, paNewCols)

		def ReplaceTheseColumns(paCols, paNewCols)
			This.ReplaceTheseCols(paCols, paNewCols)

	  #===========================#
	 #  REPLACING CELLS IN ROWS  #
	#===========================#

	def ReplaceRow(pnRow, paNewRow)
		if isList(pnRow) and
		   ( Q(pnRow).IsAtNamedParam() or
		     Q(pnRow).IsAtPositionNamedParam() )
			pnRow = pnRow[2]
		ok

		if isList(paNewRow) and
		   ( Q(paNewRow).IsByOrWithNamedParam() or
		     Q(paNewRow).IsByRowNamedParam() or
		     Q(paNewRow).IsWithRowNamedParam() )

			paNewRow = paNewRow[2]
		ok

		aRowCells = This.RowAsPositions(pnRow)
		This.ReplaceCellsByMany(aRowCells, paNewRow)

	# Replacing all the rows with the provided row
	def ReplaceAllRows(paNewRow)
		if isList(paNewRow) and
		   Q(paNewRow).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		if NOT isList(paNewRow) 
			StzRaise("Incorrect param type! paNewRow must be a list.")
		ok

		for i = 1 to This.NumberOfRows()
			This.ReplaceRow(i, paNewRow)
		next

		def ReplaceRows(paNewRows)
			This.ReplaceAllRows(paNewRows)

	def ReplaceTheseRows(paRows, paNewRows)
		if Q(paNewrows).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewrows = paNewrows[2]
		ok

		aCells = This.CellsInTheseRowsAsPositions(paRows)
		This.ReplaceCells(aCells, paNewrows)

	  #===================================================#
	 #  REPLACING ALL OCCURRENCE OF A CELL IN THE TABLE  #
	#===================================================#

	def ReplaceAllCS(pCellValue, pNewCellValue, pCaseSensitive)
		aCellsPos = This.FindAllCS(pCellValue, pCaseSensitive)
		This.ReplaceCells(aCellsPos, pNewCellValue)

		# TODO: Add alternative forms: ReplaceAllOccurrences...

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAll(pCellValue, pNewCellValue, pCaseSensitive)
		This.ReplaceAllCS(pCellValue, pNewCellValue, :CaseSensitive = TRUE)

	  #---------------------------------------------------#
	 #  REPLACING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#---------------------------------------------------#

	def ReplaceNthCS(n, pValue, pNewCellValue, pCaseSensitive)
		aCellPos = This.FindNthCS(n, pValue, pCaseSensitive)
		This.ReplaceCell(aCellPos, pNewCellValue)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNth(n, pValue, pNewCellValue)
		This.ReplaceNthCS(n, pValue, pNewCellValue, :CS = TRUE)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceFirstCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(1, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirst(pValue, pNewCellValue)
		This.ReplaceFirstCS(pValue, pNewCellValue, :CS = TRUE)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceLastCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(:Last, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLast(pValue, pNewCellValue)
		This.ReplaceLastCS(pValue, pNewCellValue, :CS = TRUE)

	  #====================================#
	 #  REPLACING SUBVALUES INSIDE CELLS  #
	#====================================#

	def ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	  #==================#
	 #  ADDING COLUMNS  #
	#==================#

	def AddColumn(paColNameAndData)
		/* EXAMPLE

		o1.AddCol( :AGE = [ 12, 28, 32 ] )

		*/

		if NOT ( isList(paColNameAndData) and 
			 len(paColNameAndData) = 2 and
			 isString(paColNameAndData[1]) and
			 isList(paColNameAndData[2]) )
			
			StzRaise("Incorrect column format! paColNameAndData must take the form :ColName = [ cell1, cell2, ... ].")
		ok

		if This.IsColName(paColNameAndData[1])
			StzRaise("Can't add the column! The name your provided already exists.")
		ok

		if NOT len(paColNameAndData[2]) = This.NumberOfRows()
			StzRaise("Incorrect number of cells! paColNameAndData must contain extactly " + This.NumberOfRows() + " cells.")
		ok

		This.Content() + paColNameAndData

		def AddCol(paColNameAndData)
			This.AddColumn(paColNameAndData)

	def AddColumns(paColNamesAndData)
		for paColNameAndData in paColNamesAndData
			This.AddColumn(paColNameAndData)
		next

		def AddCols(paColNamesAndData)
			This.AddColumns(paColNamesAndData)

	  #===============#
	 #  ADDING RAWS  #
	#===============#

	def AddRow(paRow)
		/*
		o1 = new stzTable([
			:ID 	  = [ 10,	20,		30	],
			:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
			:SALARY	  = [ 14500,	17630,		20345	]
		])

		o1.AddRow([ 40, "Peter", 12500 ])
		? o1.Row(4) #--> [ 40, "Peter", 12500 ]

		*/

		if NOT isList(paRow)
			StzRaise("Incorrect param type! paRow must be a list.")
		ok

		if NOT len(paRow) = This.NumberOfCols()
			StzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
		ok

		i = 0
		for col in This.Table()
			i++
			col[2] + paRow[i]
		next

	def AddRows(paRows)
		for row in paRows
			This.AddRow(row)
		next

	  #=======================#
	 #  EXTANDING THE TABLE  # // TODO
	#=======================#

	/* ... */

	  #======================#
	 #  UPDATING THE TABLE  #
	#======================#

	def Update( paNewTable )
		if isList(paNewTable) and Q(paNewTable).IsWithNamedParam()
			paNewTable = paNewTable[2]
		ok

		if NOT( isList(paNewTable) and Q(paNewTable).IsHashList() and
			StzHashListQ(paNewTable).ValuesAreListsOfSameSize()  )

			StzRaise("Incorrect param type! paNewTable must be a hashlist where values are lists of the same size.")
		ok

		@aTable = paNewTable

	  #====================#
	 #  RENAMING COLUMNS  #
	#====================#

	def RenanmeCol(pCol, pcNewName)

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = This.NumberOfCols()

			but This.HasColName(pCol)
				pCol = This.ColToColNumber(pCol)

			else
				StzRaise("Incorrect value! Allowed values :FirstCol, :LastCol, or use a number instead.")
			ok
		ok

		This.RenameColN(pCol, pcNewName)

	def RenameCols(paColsAndTheirNewNames)
		# WARNING: Assumes param is well formed!
		#--> TODO: Check param correctness.

		for aPair in paColsNumbersAndTheirNames
			This.RenameCol(aPair[1], aPair[2])
		next

	def RenameNthCol(n, pcNewName)
		if isList(pcNewName) and Q(pcNewName).IsWithOrByNamedParam()
			pcNewName = pcNewName[2]
		ok

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		This.Table()[n][1] = pcNewName

		def RenameColN(n, pcNewName)
			This.RenameNthCol(n, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		for n in panColsNumbers
			This.RenameColN(n)
		next

	def RenameFirstCol(pcNewName)
		This.RenameNthCol(1, pcNewName)

	def RenameLastCol(pcNewName)
		This.RenameNthCol(:Last, pcNewName)

	  #====================#
	 #  REMOVING COLUMNS  #
	#====================#

	def RemoveColumn(pColNameOrNumber)
		if This.NumberOfCols() = 1
			This.RenameFirstCol(:With = :COL1)
			This.EraseCol(1)
			return
		ok

		if isList(pColNameOrNumber)
			This.RemoveColumns(pColNameOrNumber)
			return
		ok

		if isString(pColNameOrNumber)
			cColName = pColNameOrNumber

		but isNumber(pColNameOrNumber)
			cColName = This.ColName(pColNameOrNumber)
		ok

		aResult = This.ToStzHashList().RemoveByKeyQ(cColName).Content()
		This.Update( :With = aResult )

		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	def RemoveColumns(paColNamesOrNumbers)
		paColNamesOrNumbers = StzListQ(paColNamesOrNumbers).DuplicatesRemoved()

		aColNames = This.TheseColsToColNames(paColNamesOrNumbers)

		for cCol in aColNames
			This.RemoveCol(cCol)
		next

		def RemoveCols(pColNamesOrNumbers)
			This.RemoveColumns(pColNamesOrNumbers)

	  #-----------------#
	 #  REMOVING RAWS  #
	#-----------------#

	def RemoveRow(pnRow) // TODO
		/* ... */

		def RemoveNthRow(pnRow)
			This.EraseRow(pnRow)

		def RemoveRowN(pnRow)
			This.EraseRow(pnRow)

	def RemoveRows(panRows) // TODO
		/* ... */

	  #=====================#
	 #  ERASING THE TABLE  #
	#=====================#

	def Erase()
		# NOTE: Only data in cells is erased, columns and
		# rows remain as they are!
		for line in This.Table()
			for cell in line[2]
				cell = NULL
			next
		next

		def EraseTable()
			This.Erase()

	  #-------------------#
	 #  ERASING COLUMNS  #
	#-------------------#

	def EraseColumn(pColNameOrNumber)
		aCellsPos = This.ColAsPositions(pColNameOrNumber)
		This.EraseCells(aCellsPos)

		def EraseCol(pColNameOrNumber)
			This.EraseColumn(pColNameOrNumber)

	def EraseColumns(pColNamesOrNumbers)
		nCols = This.TheseColsToColsNumbers(pColNamesOrNumbers)

		for n in nCols
			This.EraseCol(n)
		next

		def EraseCols(pColNamesOrNumbers)
			This.EraseColumns(pColNamesOrNumbers)

	  #----------------#
	 #  ERASING RAWS  #
	#----------------#

	def EraseRow(n)
		aCellsPos = This.RowAsPositions(n)
		This.EraseCells(aCellsPos)

	def EraseRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers!")
		ok

		for n in panRows
			This.EraseRow(n)
		next

	  #-----------------#
	 #  ERASING CELLS  #
	#-----------------#

	def EraseCell(pCol, pnRow)
		if isNumber(pCol)
			pCol = This.ColName(pCol)
		ok

		if NOT isString(pCol) and This.HasColName(pCol)
			StzRaise("Incorrect column name!")
		ok

		This.Table()[pCol][pnRow] = NULL

		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

	def EraseCells(paCellsPos)
		for cell in paCellsPos
			This.EraseCell(cell[1], cell[2])
		next

		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	def EraseSection(paCellPos1, paCellPos2)
		aCellsPso = This.SectionAsPositions()
		This.EraseCells(aCellsPos)

	  #======================#
	 #  INSERTING A COLUMN  # // TODO
	#======================#

	def InsertColumn(n, paColData) // TODO
		/* ... */

		def InsertCol(n, paColData)
			return This.InsertColumn(n, paColData)

		def InsertColumnBefore(n, paColData)
			return This.InsertColumn(n, paColData)

		def InsertColBefore(n, paColData)
			return This.InsertColumn(n, paColData)

	def InsertColumnAfter(n, paColData) // TODO
		/* ... */

		def InsertColAfter(n, paColData)
			This.InsertColumnAfter(n, paColData)

	def InsertColumnAt(n, paColData) // TODO
		/* ... */

		def InsertColAt(n, paColData)
			This.InsertColumnAt(n, paColData)

	  #-----------------------------------------------#
	 #  INSERTING MANY COLUMNS IN THE SAME POSITION  # // TODO
	#-----------------------------------------------#

	def InsertColumns(n, paColsData) // TODO
		if isList(n) and Q(n).IsListOfNumbers()
			This.InsertColumnsInThesePositions(n, paColsData)
		ok

		/* ... */

		def InsertCols(n, paColsData)
			return This.InsertColumns(n, paColsData)

		def InsertColumnsBefore(n, paColsData)
			return This.InsertColumns(n, paColsData)

		def InsertColsBefore(n, paColsData)
			return This.InsertsColumn(n, paColsData)

	def InsertColumnsAfter(n, paColsData) // TODO
		/* ... */

		def InsertColsAfter(n, paColsData)
			This.InsertColumnsAfter(n, paColsData)

	def InsertColumnsAt(n, paColsData) // TODO
		/* ... */

		def InsertColsAt(n, paColsData)
			This.InsertColumnsAt(n, paColsData)

	  #-------------------------------------------------#
	 #  INSERTING MANY COLUMNS IN DIFFERENT POSITIONS  # // TODO
	#-------------------------------------------------#

	def InsertColumnsInThesePositions(panPositions, paColsData) // TODO
		/* ... */

		def InsertColsInThesePositions(panPositions, paColsData)
			return This.InsertColumnsInThesePositions(panPositions, paColsData)

		def InsertColumnsBeforeThesePositions(panPositions, paColsData)
			return This.InsertColumnsInThesePositions(panPositions, paColsData)

	def InsertColumnsAfterThesePositions(panPositions, paColsData) // TODO
		/* ... */

		def InsertColsAfterThesePositions(panPositions, paColsData)
			This.InsertColumnsAfterThesePositions(panPositions, paColsData)

	def InsertColumnsAtThesePositions(panPositions, paColsData) // TODO
		/* ... */

		def InsertColsAtThesePositions(panPositions, paColsData)
			This.InsertColumnsAtThesePositions(panPositions, paColsData)

	  #==================#
	 #  INSERTING RAWS  # // TODO
	#==================#

	def InsertRow(n, paRowData) // TODO
		/* ... */

		def InsertRowBefore(n, paRowData)
			return This.InsertRow(n, paRowData)

	def InsertRowAfter(n, paRowData) // TODO
		/* ... */

	def InsertRowAt(n, paRowData) // TODO
		/* ... */

	  #--------------------------------------------#
	 #  INSERTING MANY RAWS IN THE SAME POSITION  # // TODO
	#--------------------------------------------#

	def InsertRows(n, paRowsData) // TODO
		if isList(n) and Q(n).IsListOfNumbers()
			This.InsertRowsInThesePositions(n, paRowsData)
		ok

		/* ... */

		def InsertRowsBefore(n, paRowsData)
			return This.InsertRows(n, paRowsData)

	def InsertRowsAfter(n, paRowsData) // TODO
		/* ... */

	def InsertRowsAt(n, paRowsData) // TODO
		/* ... */

	  #-----------------------------------------#
	 #  INSERTING MANY RAWS IN MANY POSITIONS  # // TODO
	#-----------------------------------------#

	def InsertRowsAtThesePositions(panPositions, paRowsData) // TODO
		/* ... */

		def InsertRowsBeforeThesePositions(panPositions, paRowsData)
			return This.InsertRowsInThesePositions(panPositions, paRowsData)

	def InsertRowsAfterThesePositions(panPositions, paRowsData) // TODO
		/* ... */

	  #=============#
	 #  SUBTABLES  #
	#=============#

	def SubTable(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok

		pacColNames = Q(pacColNames).Lowercased()

		if This.HasColNames(pacColNames)
			aResult = []
			for cColName in pacColNames
	
				aResult + [ cColName, This.Col(cColName) ]
			next
	
			return aResult	
		ok

		def SubTableQ(pacColNames)
			return This.SubTableQR(pacColNames, :stzList)

		def SubTableQR(pacColNames, pcReturnType)
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

	def ColNumbersToNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsLIstOfNumbers() )
			StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
		ok

		aResult = []

		for n in panColNumbers
			aResult + This.NthColName(n)
		next

		return aResult
	
	def TheseColumns(paColNamesOrNumbers)
		if NOT 	( isList(paColNamesOrNumbers) and
			  ( Q(paColNamesOrNumbers).IsListOfNumbers() or
			  Q(paColNamesOrNumbers).IsListOfStrings() ) )

			StzRaise("Incorrect param type! paColNamesOrNumbers must be a list of numbers or a list of strings.")
		ok

		aResult = []

		if Q(paColNamesOrNumbers).IsListOfNumbers()
			anColNumbers = paColNamesOrNumbers
			aResult = This.SubTable( This.ColNumbersToNames(anColNumbers) )

		but Q(paColNamesOrNumbers).IsListOfStrings()
			acColNames = paColNamesOrNumbers
			aResult = This.SubTable( acColNames )

		ok

		return aResult

		#< @FunctionFluentForm

		def TheseColumnsQ(paColNamesOrNumbers)
			return TheseColumnsQR(paColNamesOrNumbers, :stzList)

		def TheseColumnsQR(paColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumns(paColNamesOrNumbers) )

			on :stzHashList
				return new stzHashList( This.TheseColumns(paColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumns(paColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumns(paColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def TheseCols(paColNamesOrNumbers)
			return This.TheseColumns(paColNamesOrNumbers)

			def TheseColsQ(paColNamesOrNumbers)
				return This.TheseColsQR(paColNamesOrNumbers, :stzList)

			def TheseColsQR(paColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsQR(paColNamesOrNumbers, pcReturnType)

		def ColumnsAtPositions(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColumnsAtPositionsQ(panColNumbers)
				return This.ColumnsAtPositionsQR(panColNumbers, :stzList)

			def ColumnsAtPositionsQR(panColNumbers, pcReturnType)
				return This.TheseColumnsQR(panColNumbers, pcReturnType)


		def ColumnsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColumnsAtQ(panColNumbers)
				return This.ColumnsAtQR(panColNumbers, :stzList)

			def ColumnsAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsQR(panColNumbers, pcReturnType)

		def ColsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColsAtQ(panColNumbers)
				return This.ColumnsAtQR(panColNumbers, :stzList)

			def ColsAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsQR(panColNumbers, pcReturnType)

		def ColAtPositions(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtPositionsQ(panColNumbers)
				return This.ColAtPositionsQR(panColNumbers, :stzList)

			def ColAtPositionsQR(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQR(panColNumbers, pcReturnType)

		def ColAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtQ(panColNumbers)
				return This.ColAtQR(panColNumbers, :stzList)

			def ColAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQR(panColNumbers, pcReturnType)

		#>

	def TheseColumnsXT(panColNamesOrNumbers)
		for col in This.TheseColumns(panColNamesOrNumbers)
			col = Q(col).AssociatedWith( This.ColPositions(col) )
		next

		#< @FunctionFluentForm

		def TheseColumnsXTQ(panColNamesOrNumbers)
			return This.TheseColumnsXTQR(panColNamesOrNumbers, :stzList)

		def TheseColumnsXTQR(panColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumnsXT(panColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumnsXT(panColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumnsXT(panColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def TheseColsXT(panColNamesOrNumbers)
			return This.TheseColumnsXT(panColNamesOrNumbers)

			def TheseColsXTQ(panColNamesOrNumbers)
				return This.TheseColsXTQR(panColNamesOrNumbers, :stzList)

			def TheseColsXTQR(panColNamesOrNumbers, pcReturnType)
				return This.TheseColsXT(panColNamesOrNumbers, pcReturnType)

		def TheseColXT(panColNamesOrNumbers)
			return This.TheseColumnsXT(panColNamesOrNumbers)

			def TheseColXTQ(panColNamesOrNumbers)
				return This.TheseColXTQR(panColNamesOrNumbers, :stzList)

			def TheseColXTQR(panColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsXT(panColNamesOrNumbers, pcReturnType)

		#>

	def TheseColNames(panColNumbers)
		if NOT (isList(panColNumbers) and Q(panColNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! pacColNumbers muts be a list of numbers.")
		ok

		panColNumbers  = Q(panColNumbers).SortedInAscending()
		pacColNames    = This.ColNames()
		nNumCols       = len(pacColNames)
		
		if len(panColNumbers) > nNumCols
			panColNumbers = Q(panColNumbers).Section( 1, nNumCols)
		ok

		aResult = []
		for n in panColNumbers
			aResult + pacColNames[n]
		next n

		return aResult

		def TheseColumsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

		def TheseColsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

	  #=======================#
	 #  SUBSET OF THE TABLE  #
	#=======================#

	def SubSet(panRowsNumbers)
		return This.TheseRows(panRowsNumbers)

		def SubSetQ(panRowsNumbers)
			return This.SubSetQR(panRowsNumbers, :stzList)

		def SubSetQR(panRowsNumbers, pcReturnType)
			return This.TheseRowsQR(panRowsNumbers, pcReturnType)

	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers() )

			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		aResult = []

		for n in panRowsNumbers
			aResult + This.Row(n)
		next

		return aResult

		#< @FunctionFluentForm

		def TheseRowsQ(panRowsNumbers)
			return TheseRowsQR(panRowsNumbers, :stzList)

		def TheseRowsQR(panRowsNumbers, pcReturnType)
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
				return This.RowsAtPositionsQR(panRowsNumbers, :stzList)

			def RowsAtPositionsQR(panRowsNumbers, pcReturnType)
				return This.TheseRowsQR(panRowsNumbers, pcReturnType)

		def RowsAt(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtQ(panRowsNumbers)
				return This.RowsAtPositionsQR(panRowsNumbers, :stzList)

			def RowsAtQR(panRowsNumbers, pcReturnType)
				return This.TheseRowsQR(panRowsNumbers, pcReturnType)

		#>

	def TheseRowsXT(panRowsNumbers)
		for n in This.TheseRows(panRowsNumbers)
			col = RowQ(n).AssociatedWith( This.RowPositions(n) )
		next

		def TheserowsXTQ(panRowsNumbers)
			return This.TheseRowsXTQR(panRowsNumbers, :stzList)

		def TheseRowsXTQR(panRowsNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseRowsXT(panRowsNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseRowsXT(panRowsNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseRowsXT(panRowsNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

	  #=====================#
	 #  SORTING THE TABLE  #
	#=====================#

	def Sort(pCol)
		This.SortInAscending(pCol)

		def SortBy(pCol)
			This.Sort(pCol)

	def SortXT(pCol, pcDirection)
		/*
		o1 = new stzTable([
			[  "COL1",   "COL2" ],
			[     "a",    "R1"  ],
			[ "abcde",    "R5"  ],
			[   "abc",    "R3"  ],
			[    "ab",    "R2 " ],
			[     "b",    "R1"  ],
			[   abcd",    "R4"  ]
		])

		o1.Sort( :By = :COL2 )
		o1.Show()
		#-->
		#    COL1   COL2
		1       a   "R1"
		2       b   "R1"
		3      ab   "R2"
		4     abc   "R3"
		5    abcd   "R4"
		6   abcde   "R5"

		*/

		# Checking params

		if isList(pCol) and
			( Q(pCol).IsByNamedParam() or
			  Q(pCol).IsByColNamedParam() or
			  Q(pCol).IsByColumnNamedParam() )

			pCol = pCol[2]
		ok

		if NOT ( isNumber(pCol) or isString(pCol) )
			StzRaise("Incorrect param type! pCol must be a number or string.")
		ok

		if isNumber(pCol) and NOT ( Q(pCol).IsBetween(1, This.NumberOfCol()) )
			StzRaise("Incorrect param value! pCol must be a number between 1 and " + This.NumberOfCol() + ".")

		but isString(pCol) and NOT This.HasColName(pCol)
			StzRaise("Incorrect param value! pCol must be a valid column name.")
		ok

		if isList(pcDirection) and Q(pcdirection).IsInNamedParam()
			pcDirection = pcDirection[2]
		ok

		if NOT ( isString(pcDirection) and
			 Q(pcDirection).IsOneOfThese([ :Ascending, :Descending, :InAscending, :InDescending ]) )

			StzRaise("Incorrect param! pcDirection must be :In = :Ascending or :In = :Descending.")
		ok

		# STEP 1: Moving the column used in the sort at the first position
		# while memorising its position (because we will move it back later)

		nInitialColPos = This.ColToNumber(pCol)
		This.MoveCol(pCol, :To = :FirstPosition)
	
		# STEP 2: Turn the rows into a list of strings and sort them using
		# the stzListOfStrings sorting service

		acRows = []

		for aRow in This.Rows()

			cRow = "[ "
			i = 0
			for cell in aRow
				i++
				if isString(cell)
					cRow += '"' + cell + '"'
				else
					cRow += @@(cell)
				ok
				if i < len(aRow)
					cRow += ", "
				ok
			next
			cRow += " ]"

			acRows + cRow
		next
	
		ocRows = new stzListOfStrings(acRows)
		if pcDirection = :Ascending or pcDirection = :InAscending
			ocRows.SortInAscending()

		but pcDirection = :Descending or pcDirection = :InDescending
			ocRows.SortInDescending()
		ok

		acRows = ocRows.Content()
		#--> [
		# 	[ "R1", "a" ],
		# 	[ "R1", "b" ],
		# 	[ "R2", "ab" ],
		# 	[ "R3", "abc" ],
		# 	[ "R4", "abcd" ],
		# 	[ "R5", "abcde" ]
		#   ]

		# STEP 3: Turning the list of strings into rows by evaluation

		aRows = []
		for cRow in acRows
			cCode = 'aRow = ' + cRow
			eval(cCode)
			aRows + aRow
		next

		# STEP 4: Updating the table with these rows

		This.ReplaceRows(:With = aRows)

		# STEP 5: Moving back the column used in sorting to its
		# initial position in the table

		This.MoveCol(1, :ToPosition = nInitialColPos)


	def SortInAscending(pCol)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Karim",	52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Abraham",	48	]
		])
		
		? o1.Sort(:By = :NAME)
		
		#-->
		# #	ID	NAME		AGE
		# 1	30	Abraham		48
		# 2	20	Hatem		46
		# 3	10	Karim		52 
		*/

		This.SortXT(pCol, :InAscending)

	def SortInDescending(pCol)
		This.SortXT(pCol, :InDescending)

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

		aRowCopy = This.Row(pnTo)
		This.ReplaceRow(pnTo, This.Row(pnFrom))
		This.ReplaceRow(pnFrom, aRowCopy)

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
			aCopyOfRow1 = This.Row(pnRow1)
			This.ReplaceRow(pnRow1, This.Row(pnRow2))
			This.ReplaceRow(pnRow2, aCopyOfRow1)
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
			if Q(pnFrom).IsOneOfThese([
				:First, :FirstCol, :FirstColumn, :FirstPosition ])

				pnFrom = 1

			but Q(pnFrom).IsOneOfThese([
				:Last, :LastCol, :LastColumn, :LastPosition ])

				pnFrom = This.NumberOfCols()
			ok
		ok

		if isString(pnTo)
			if Q(pnTo).IsOneOfThese([
				:First, :FirstCol, :FirstColumn, :FirstPosition ])

				pnTo = 1

			but Q(pnTo).IsOneOfThese([
				:Last, :LastCol, :LastColumn, :LastPosition ])

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

		if pnFrom != pnTo
			aCopy = @aTable[pnTo]
			@aTable[pnTo] = @aTable[pnFrom]
			@aTable[pnFrom] = aCopy
		ok

		#< @FunctionAlternativeForm

		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

	def IsColName(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		cName = Q(pcName).Lowercased()

		bResult = FALSE
		if This.ColumnsQ().Contains(pcName)
			bResult = TRUE
		ok

		return bResult

		#< @FunctionAlternativeForm

		def IsColumnName(pcName)
			return This.IsColName(pcName)

		#>
		
	def SwapColNames(pCol1, pCol2)
		bCol1IsValid = ( isNumber(pCol1) and Q(pCol1).IsBetween(1, This.NumberOfCol()) )
		bCol2IsValie = ( isString(pCol2) and This.HasColName(pCol2) )

		if NOT ( bCol1IsValid or bCol2IsValie )
			StzRaise("Incorrect params! pCol1 and pCol2 must be valid columns names or strings.")
		ok

		cName1 = This.ColName(pCol1)
		cName2 = This.ColName(pCol2)

		nCol1 = This.ColNumber(pCol1)
		nCol2 = This.ColNumber(pCol2)

		@aTable[nCol1][1] = cName2
		@aTable[nCol2][1] = cName1

		#< @FunctionAlternativeForm

		def SwapColumnNames(pcCol1, pcCol2)
			This.SwapColNames(pcCol1, pcCol2)

		def SwapColumnsNames(pcCol1, pcCol2)
			This.SwapColNames(pcCol1, pcCol2)

		#>

	def SwapCol(pCol1, pCol2)
		if isList(pCol1) and
			( Q(pCol1).IsAndNamedParam() or
			  Q(pCol1).IsAndPositionNamedParam() or

			  Q(pCol1).IsAndColNamedParam() or
			  Q(pCol1).IsAndColumnNamedParam() or

			  Q(pCol1).IsAndColAtNamedParam() or
			  Q(pCol1).IsAndColumnAtNamedParam() or

			  Q(pCol1).IsAndColAtPositionNamedParam() or
			  Q(pCol1).IsAndColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenNamedParam() or

			  Q(pCol1).IsBetweenColNamedParam() or
			  Q(pCol1).IsBetweenColumnNamedParam() or

			  Q(pCol1).IsBetweenColAtNamedParam() or
			  Q(pCol1).IsBetweenColumnAtNamedParam() or

			  Q(pCol1).IsBetweenColAtPositionNamedParam() or
			  Q(pCol1).IsBetweenColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenPositionNamedParam() or
			  Q(pCol1).IsBetweenPositionsNamedParam()
			)
			  # NOTE: I don't use IsOneOfTheseNamedParams() here
			  # to gain some performance by discarding eval()

			pCol1 = pCol1[2]
		ok

		if isList(pCol2) and
			( Q(pCol2).IsAndNamedParam() or
			  Q(pCol2).IsAndColNamedParam() or
			  Q(pCol2).IsAndColumnNamedParam() or
			  Q(pCol2).IsAndColAtNamedParam() or
			  Q(pCol2).IsAndColumnAtNamedParam() or
			  Q(pCol2).IsAndColAtPositionNamedParam() or
			  Q(pCol2).IsAndColumnAtPositionNamedParam() or
			  Q(pCol2).IsAndColNamedNamedParam() or
			  Q(pCol2).IsAndColumnNamedNamedParam()
			)

			pCol2 = pCol2[2]
		ok

		if This.ColNumber(pCol1) != This.ColNumber(pCol2)
			aCopyOfCol1 = This.Col(pCol1)
			This.ReplaceCol(pCol1, This.Col(pCol2) )
			This.ReplaceCol(pCol2, aCopyOfCol1)
	
			This.SwapColNames(pCol1, pCol2)
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

		n = This.ColNumber(pCol)
		@aTable[n][1] = pcNewColName

		#< @FunctionAlternativeForm

		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

		#>

	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		bResult = TRUE

		for cName in pacColNames
			if NOT This.IsColName(cName)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForm

		def AreColumnNames(pacColNames)
			This.AreColNames(pacColNames)

		def AreColumnsNames(pacColNames)
			This.AreColNames(pacColNames)

		#>

	  #=====================#
	 #  SHOWING THE TABLE  #
	#=====================#

	def Show()
		? This.ToString()

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	def ToStringXT(paOptions)
		cTable = This.HeaderToString() + NL + This.RowsToStringXT(paOptions)
		return cTable

	def ToString()
		return This.ToStringXT([ :ReplaceEmptyCellsWith = "" ])

	def MaxWidthInCol(pCol)
		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				pCol = This.NumberOfCols()

			else
				pCol = This.FindCol(pCol)
				if pCol = 0
					StzRaise("Inexistant column name!")
				ok
			ok
		ok
? ElapsedTime()
		aColContent = This.Col(pCol)
		nNumberOfCols = len(aColContent)
		nMax = 0

		for i = 1 to nNumberOfCols
			cell = aColContent[i]

			if isList(cell)
				nLen = len(cell)
			but isString(cell)
				nLen = Q(cell).NumberOfChars()
			but isNumber(cell)
				nLen = len(""+cell)
			else // case of object
				# TODO: manage this in the future
			ok

			if nLen > nMax
				nMax = nLen
			ok
		next

		return nMax


		def WidthOfLargestCellInCol(pCol)
			return This.MaxWidthInCol(pCol)

	def MaxWidthInEachCol()
		anResult = []
		nNumberOfCols = This.NumberOfCol()

		for i = 1 to nNumberOfCols
			anResult + This.MaxWidthInCol(i)
		next

		return anResult

		def MaxWidthInEachColQ()
			return This.MaxWidthInEachColQR(:stzList)

		def MaxWidthInEachColQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.MaxWidthInEachCol() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.MaxWidthInEachCol() )

			other
				StzRaise("Unsupported return type!")
			off

	def MaxWidthInEachColXT()
		anResult = This.MaxWidthInEachColQ().
				InsertBeforeQ(1, len( "" + This.NumberOfRows() ) ).
				Content()

		return anResult

	def MaxWidthInRow(p)
		anSizes = []

		aRow = This.Row(p)
		for cell in aRow
			anSizes + @@SQ(cell).RemoveBoundsQ('"').NumberOfChars()
		next

		nResult = StzListOfNumbersQ(anSizes).Max()
		return nResult

		def WidthOfLargestCellInRow(pRow)
			return This.WidthOfLargestCellInRow(pRow)

	def MaxWidthInEachRow()
		anResult = []

		for i = 1 to This.NumberOfRows()
			anSizes = []
			for cell in This.NthRow(i)
				anSizes + @@SQ(cell).RemoveBoundsQ('"').NumberOfChars()
			next

			anResult + StzListOfNumbersQ(anSizes).Max()
		next

		return anResult

	def HeaderToString()
		anMax = This.MaxWidthInEachColXT()

		acStr = This.ColNamesQ().
				UppercaseQ().
				InsertBeforeQ(1, "#").
				Content()

		cResult = ""
		i = 0
		for str in acStr
			i++
			cResult += Q(str).AlignedtoRightXT(anMax[i], " ")
			if i < len(anMax)
				cResult += "   "
			ok
		next

		return cResult

	def RowsToString()
		return This.RowsToStringXT([ :ReplaceEmptyCellsWith = "" ])

	def RowsToStringXT(paOptions)

		cRows = ""
		//nNumberOfRows = 
		for y = 1 to This.NumberOfRows()
			cRows += ""+ y + "   " + This.RowToStringXT(y, paOptions) + NL
		next

		return cRows

	def RowToString(n)
		return This.RowToStringXT(n, [ :ReplaceEmptyCellsWith = "" ])

	def RowToStringXT(n, paOptions)
		if NOT ( isList(paOptions) and Q(paOptions).IsHashList() )
			StzRaise("Incorrect param format! paOtions must be a hashlist.")
		ok

		cEmptyCell = paOptions[ :ReplaceEmptyCellsWith ]

		anMax = []
		acColNames   = This.ColNames()
		nLenColNames = len(acColNames)

		anMax = This.MaxWidthInEachCol()

		cRow = ""
		aRow = This.Row(n)
		nLenRow = len(aRow)

		for i = 1 to nLenRow
			cell = aRow[i]

			if isString(cell) and cell = NULL
				cell = cEmptyCell

			but isList(cell)
				cell = "'" + @@(cell) + "'"
			ok
			
			cRow += @@SQ(cell).
				RemoveBoundsQ('"').
				RemoveBoundsQ("'").
				AlignedToRightXT( anMax[i], " " )

			if i < nLenRow
				cRow += "   "
			ok
		next

		return cRow

		def RowToStringQ(n)
			return new stzString( This.RowToString(n) )

	  #-----------------------------------------------------------#
	 #  FILLING ALL THE TABLE WITH A GIVEN CELL, COLUMN, OR ROW  #
	#-----------------------------------------------------------#

	def Fill(pValue)
		/*

		EXAMPLE 1:

		o1 = new stzTable([3, 3])
		o1.Fill( :With = "A" )	# or ( :WithCell = "A" )
		o1.Show()
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "A"	  "A"	  "A"
		# 3	  "A"	  "A"	  "A"

		EXAMPLE 2:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithCol = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "B"	  "B"	  "B"
		# 3	  "C"	  "C"	  "C"

		EXAMPLE 3:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithRow = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "B"	  "C"
		# 2	  "A"	  "B"	  "C"
		# 3	  "A"	  "B"	  "C"

		*/

		cFill = :WithCell

		if isList(pValue) and
		   Q(pValue).IsOneOfTheseNamedParams([
			:With, :WithCell, :WithCol, :WithColumn, :WithRow,
			:Using, :UsingCell, :UsingCol, :UsingColumn, :UsingRow ])

			cFill  = pValue[1]
			pValue = pValue[2]
		ok

		if cFill = :With or cFill = :WithCell
			for i = 1 to This.NumberOfCols()
				for v = 1 to This.NumberOfRows()
					This.ReplaceCell(i, v, pValue)
				next v
			next i

		but Q(cFill).IsOneOfThese([
			:WithCol, :WithColumn, :UsingCol, :UsingColumn ])
		    
			This.ReplaceCols(:With = pValue)

		but cFill = :WithRow or cFill = :UsingRow

			This.ReplaceRows(:By = pValue)

		else
			StzRaise("Unsupported syntax! Allowed named params are: " +
				 ":WithCell, :WithColumn, and :WithRow.")
		ok
		
		#< @FunctionFuentForm

		def FillQ(pValue)
			This.Fill(pValue)
			return This

		def FillCQ(pValue) # TODO: Add this to all functions
			return This.Copy().FillQ(pValue)

	def Filled(pValue)
		aResult = This.Copy().FillQ(pValue).Content()
		return aResult

	  #=================================#
	 #  MISC. : SOME USEFUL UTILITIES  #
	#=================================#

	def ToStzHashList()
		return new stzHashList( This.Table() )

	def ColToColName(p)
		if isList(p) and
		   Q(p).IsOneOfTheseNamedParams([
			:Col, :InCol, :Cols, :InCols,
			:Column, :InColumn, :Columns, :InColumns	
		   ])

			p = p[2]
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		cResult = This.ColName(p)
		return cResult

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

		acResult = []
		for col in paCols
			acResult + This.ColToColName(col)
		next

		return acResult

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

	def ColToColNumber(p)
		if isNumber(p) and p <= This.NumberOfCol()
			return p
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.ColNamesQ().FindFirst(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		if NOT Q(p).IsBetween(1, This.NumberOfCols())
			StzRaise("Incorrect value! n must be a number between 1 and " + This.NumberOfCols() + ".")
		ok

		nResult = p
		return nResult

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


	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		anResult = []
		for col in paCols
			anResult + This.ColToColNumber(col)
		next

		return anResult

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

	def RowToRowNumber(pRow)
		if isList(pRow) and Q(pRow).IsOneOfTheseNamedParams([ :Row, :Rows, :InRow, :InRows, :OfRow, :OfRows ])
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

		return  pRow

		def RowToNumber(pRow)
			return This.RowToRowNumber(pRow)

		def RowAsNumber(pRow)
			return This.RowToRowNumber(pRow)

	def TheseRowsToRowsNumbers(paRows)
		aResult = []

		for aRow in paRows
			aResult + This.RowToNumber(aRow)
		next

		return aResult

		def TheseRowsToNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def TheseRowsAsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)
