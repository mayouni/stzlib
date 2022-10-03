
func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable
	@aTable = [] # Table content is stored as a hashlist

	def init(paTable)

		# A table can be created in 4 different ways

		if NOT isList(paTable)
			stzRaise("Incorrect param format! paTable must be a list.")
		ok

		# Way 1: new stzTable([])
		#--> Creates an empty table with just a column and a row

		# Way 2: new stzTable([3, 4])
		# --> Creates a tale of 3 columns and 4 rows, all cells are empty

		# Both ways (1 and 3) are made bu the following code:
		if len(paTable) = 0 or Q(paTable).IsPairOfNumbers()
			
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
		ok

		# WAY 3: The table is created using a hashlist
		#--> [
		# 	:COL1 = [ ..., ..., ... ] ],
		# 	:COL2 = [ ..., ..., ... ] ],
		# 	:COL3 = [ ..., ..., ... ] ]
		#    ]

		if Q(paTable).IsHashList() and
			 StzHashListQ(paTable).ValuesAreListsOfSameSize()
				@aTable = paTable
				return
		ok

		# Way 4 (the more natural way) The table is described in a
		# a l ist of lists that mimics the realworld presentation
		# of a table (first line represents colums, and the other
		# lines represents rows):

		# o1 = new stzTable([
		# 	[ :ID,	 :EMPLOYEE,    	:SALARY	],
		# 	#-------------------------------#
		# 	[ 10,	 "Ali",		35000	],
		# 	[ 20,	 "Dania",	28900	],
		# 	[ 30,	 "Han",		25982	],
		# 	[ 40,	 "Ali",		12870	]
		# ])

		if Q(paTable).IsNotHashList() and
		   Q(paTable).ItemsAreListsOfSameSize() and
		   Q(paTable[1]).IsListOfStrings()

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
		ok
			
		stzRaise("Incorrect param format!")

	def Content()
		return @aTable

		def Table()
			return This.Content()

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
		bResult = TRUE
		for cName in pacNames
			if NOT This.HasColName(cName)
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
				stzRaise("Unsupported return type!")
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
			stzRaise("Incorrect param type! pcColName must be a string.")
		ok

		if Q(pcColName).IsOneOfThese([:First, :FirstCol, :FirstColumn])
			pcColName = This.FirstColName()

		but Q(pcColName).IsOneOfThese([:Last, :LastCol, :LastColumn])
			pcColName = This.LastColName()
		ok

		pcColName = Q(pcColName).Lowercased()
		n = find( This.Header(), pcColName)
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
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
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
				return new stzListOfNumbers( This.Col(p) )

			on :stzListOfLists
				return new stzListOfLists( This.Col(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Col(p) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Col(p) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Col(p) )

			other
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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
				stzRaise("syntax error in (" + n + ")! Allowed values are :First or :Last ( or :FirstCol or :LastCol).")

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
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n must be a number.")
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
				stzRaise("Unsupported return type!")
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
		aResult = []

		for i = 1 to This.NumberOfRows()
			aResult + [ nCol, i]
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInColPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColCellsAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsAsPositionsInCol(pCol)
			return This.CellsInColAsPositions(pCol)

		#--

		def CellsInColumnAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsInColumnPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def ColumnCellsAsPositions(pCol)
			return This.CellsInColAsPositions(pCol)

		def CellsAsPositionsInColumn(pCol)
			return This.CellsInColAsPositions(pCol)

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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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
		aResult = []
		for i = 1 to This.NumberOfRows()
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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
					stzRaise("Unsupported return type!")
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
			stzRaise("Incorrect param type! pnRow must be a number.")
		ok

		aResult = []

		for i = 1 to This.NumberOfCols()
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

	def Cell(pCol, pRow)

		if isString(pCol)
			if Q(pCol).IsOneOfThese([:First, :FirstCol, :FirstColumn])
				pCol = 1

			but Q(pCol).IsOneOfThese([:Last, :LastCol, :LastColumn])
				pCol = This.NumberOfColumns()

			else
				if NOT This.HasColName(pCol)
					stzRaise("Syntax error in (" + pCol + ")! Allowed values are :First or :Last (or :FirstCol or :LastCol).")
				ok
			ok
		ok

		if isString(pRow)
			if pRow = :First or pRow = :FirstRow
				pRow = 1

			but pRow = :Last or pRow = :LastRow
				pRow = This.NumberOfRows()

			else
				stzRaise("Syntax error in (" + pRow + ")! Allowed values are :First or :Last (or :FirstRow or :LastRow).")
			ok

		ok

		cColName = ""

		if isNumber(pCol)
			cColName = This.ColName(pCol)

		but isString(pCol)
			cColName = pCol

		else
			stzRaise("Incorrect param type! pCol must be a number or string.")
		ok

		if NOT isNumber(pRow)
			stzRaise("Incorrect param type! pRow must be a number.")
		ok

		Result = This.Table()[cColName][pRow]
		return Result

		#< @FunctionFluentForm

		def CellQ(pCol, pRow)
			return Q( This.Cell(pCol, pRow) )

		#>

		#< @FunctionAlternativeForms

		def CellAtPosition(pCol, pRow)
			return This.Cell(pCol, pRow)

			def CellAtPositionQ(pCol, pRow)
				return This.CellAtPosition(pCol, pRow)

		def CellAt(pCol, pRow)
			return This.Cell(pCol, pRow)

			def CellAtQ(pCol, pRow)
				return This.CellAtPosition(pCol, pRow)

		#>

	def CellXT(pCol, pRow)
		nCol = This.ColToNumber(pCol)
		nRow = This.RowToNumber(pRow)

		aResult = [ This.Cell(pCol, pRow), [ nCol, nRow ] ]

		return aResult

		def CellAndPosition(pCol, pRow)

		def CellAndItsPosition(pCol, pRow)

	  #----------------------------------------------------------------------------#
	 #  GETIING GIVEN CELLS VALUES BY THEIR POSITIONS (COLUMN, ROW) IN THE TABLE  #
	#----------------------------------------------------------------------------#

	def TheseCells(paCellsPos)
		aResult = []

		for cellPos in paCellsPos
			aResult + This.Cell(cellPos[1], cellPos[2])
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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

		for v = 1 to This.NumberOfRows()
			for u = 1 to This.NumberOfCol()
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

		for v = 1 to This.NumberOfRows()
			for u = 1 to This.NumberOfCol()
				aResult + [ [u, v ], This.Cell(u, v) ]
			next
		next

		return aResult

	def CellsAsPositions()
		aResult = []

		for v = 1 to This.NumberOfRows()
			for u = 1 to This.NumberOfCol()
				aResult + [u, v ]
			next
		next

		return aResult

	  #-----------------------------------------------------------#
	 #  GETIING THE LIST OF THE GIVEN CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------------#

	def TheseCellsAndTheirPositions(paCells)
		aResult = []

		for aCell in paCells
			aResult + [ This.Cell(aCell[1], aCell[2]), aCell ]
		next

		return aResult

		def TheseCellsAndPositions(paCells)
			return This.TheseCellsAndTheirPositions(paCells)

		def TheseCellsXT(paCells)
			return This.TheseCellsAndTheirPositions(paCells)

	def PositionsAndTheseCells(paCells)
		aResult = []

		for aCell in paCells
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
				StzRaise("Insupported return type!")
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

		for cellPos in paCellsPos
			aResult + [ @@S(cellPos), This.Cell(cellPos[1], cellPos[2]) ]
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
				stzRaise("Unsupported return type!")
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

		aResult = []

		for aCell in aCells
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Syntax error in (" + panCellPos1 + ")! Allowed values are :First or :FirstCell.")
			ok
		ok

		if isString(panCellPos2)
			if panCellPos2 = :First or panCellPos2 = :LastCell
				panCellPos2 = This.LastCellPosition()

			else
				stzRaise("Syntax error in (" + panCellPos2 + ")! Allowed values are :Last or :LastCell.")
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

			stzRaise("Incorrect params types! panCellPos1 and panCellPos2 must be pairs of numbers.")
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
				stzRaise("Unsupported return type!")
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
			stzRaise("Incorrect param type! pCol must be a number.")
		ok

		if isString(n1)
			if n1 = :First or n1 = :FirstRow
				n1 = 1
			ok
		ok

		if NOT isNumber(n1)
			stzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if n2 = :Last or n2 = :LastRow
				n2 = This.NumberOfRows()
			ok
		ok

		if NOT isNumber(n2)
			stzRaise("Incorrect param type! n2 must be a number.")
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
			stzRaise("Incorrect param type! nRow must be a number.")
		ok

		if isString(n1)
			if Q(n1).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n1 = 1
			ok
		ok

		if NOT isNumber(n1)
			stzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if Q(n2).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n2 = This.NumberOfCols()
			ok
		ok

		if NOT isNumber(n2)
			stzRaise("Incorrect param type! n2 must be a number.")
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
				stzRaise("Unsupported return type!")
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

///// 1 >> WORKING ON THE TABLE //////////////////////////////////////////////////////////////

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
			stzRaise("Incorrect param type! n must be a number.")
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
			stzRaise("Incorrect param type! n must be a number.")
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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
				stzRaise("Incorrect param format! pValue must take the form :Cell = ... or :SubValue = ...")
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
			return This.NumberOfOccurrenceOfCell(pValue, pCaseSensitive)

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
	
	def ContainsSubValueCS(pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValue(pSubValue)
			return This.ContainsSubValueCS(pSubValue, :CaseSensitive = TRUE)

///// 2 >> WORKING ON SOME CELLS ///////////////////////////////////////////////////////////////////////////

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
			if Q(n).IsOneOf([ :First, :FirstOccurrence, :FirstValue ])
				n = 1

			but Q(n).IsOneOf([ :Last, :LastOccurrence, :LastValue ])
				n = This.NumberOfOccurrenceInCellsCS(paCells, pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindAllInCellsCS( paCells, pCellValue, pCaseSensitive)

		aResult = []

		if len(anPos) > 0 and n <= len(anPos)
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
			if Q(n).IsOneOf([ :First, :FirstOccurrence, :FirstSubValue ])
				n = 1

			but Q(n).IsOneOf([ :Last, :LastOccurrence, :LastSubValue ])
				n = This.CountSubValuesCS(pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param type! n must be a number.")
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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
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
		return len( This.FindInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive) )

		def NumberOfOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

		def CountInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

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

///// 3 >> WORKING ON ROWS /////////////////////////////////////////////////////////////////

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
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

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
		return This.FindFirstSubValueInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

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

///// 4 >> WORKING ON COLS ///////////////////////////////////////////////////////////////////////////

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

		#-- WITHOUT CASESENSITIVITY

		def FindInCol(pCol, pCellValueOrSubValue)
			return This.FindInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)

	def FindValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInCol(pCol, pCellValue)
			return This.FindValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInCol(pCol, pSubValue)
			return This.FindValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

	  #============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#============================================================================================#

	def FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :Nth, :N, :Occurrence ])
			n = n[2]
		ok

		pCol = This.ColToName(pCol)

		return This.FindNthInCellsCS(n, This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInCol(n, pCol, pCellValueOrSubValue)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindNthOccurrenceInCol(n, pCol, pCellValueOrSubValue)
				return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

	def FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)
		anPos = This.FindInColCS(pCol, pCellValue, pCaseSensitive)

		aResult = []
		for line in anPos
			aCellPos = line[1]
			i = 0
			for nPos in line[2]
				i++
				if i = n
					aResult + [ aCellPos, line[2][i] ]
					exit 2
				ok
			next
		next

		return aResult


		def FindNthOccurrenceOfValueInColCs(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInCol(n, pCol, pCellValue)
			return This.FindNthValueInColCS(n, pCol, pCellValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfValueInCol(n, pCol, pCellValue)
				return This.FindNthValueInCol(n, pCol, pCellValue)

	def FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		aResult = []
		if n > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		def FindNthOccurrenceOfSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInCol(n, pCol, pSubValue)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, :CaseSensitive = TRUE)

			def FindNthOccurrenceOfSubValueInCol(n, pCol, pSubValue)
				return This.FindNthSubValueInCol(n, pCol, pSubValue)

	  #----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(1, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInCol(pCol, pCellValueOrSubValue)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindFirstOccurrenceInCol( pCol, pCellValueOrSubValue)
				return This.FindFirstInCol(pCol, pCellValueOrSubValue)

	def FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInCol(pCol, pCellValue)
			return This.FindFirstValueInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfValueInCol(pCol, pCellValue)
				return This.FindFirstValueInCol(pCol, pCellValue)

	def FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInCol(pCol, pSubValue)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			def FindFirstOccurrenceOfSubValueInCol(pCol, pSubValue)
				return This.FindFirstSubValueInCol(pCol, pSubValue)

	  #----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInCol(pCol, pCellValueOrSubValue)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)
		
			def FindLastOccurrenceInCol( pCol, pCellValueOrSubValue)
				return This.FindLastInCol(pCol, pCellValueOrSubValue)

	def FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInCol(pCol, pCellValue)
			return This.FindLastValueInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfValueInCol(pCol, pCellValue)
				return This.FindLastValueInCol(pCol, pCellValue)

	def FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		def FindLastOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInCol(pCol, pSubValue)
			return This.FindLastSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			def FindLastOccurrenceOfSubValueInCol(pCol, pSubValue)
				return This.FindLastSubValueInCol(pCol, pSubValue)

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

		def NumberOfOccurrencesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		def CountInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInCol(pCol, pValue)
			return This.NumberOfOccurrenceInColCS(pCol, pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInCol(pCol, pValue)
			return This.NumberOfOccurrenceInCol(pCol, pValue)

		def CountInCol(pCol, pValue)
			return This.NumberOfOccurrenceInCol(pCol, pValue)

		#>

	def NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, pCaseSensitive)
		return len( This.FindCellInColCS(pCol, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def NumberOfOccurrencesOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#--

		def NumberOfOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def NumberOfOccurrencesOfValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountOfValueInColInCol(pCol, pCol, pValue)
			return This.NumberOfOccurrenceOfCellInColInCol(pCol, pCol, pValue)

		def CountOfValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def CountValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountSubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def NumberOfOccurrencesOfSubValuesInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def CountOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def CountOfSubValuesInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def CountSubValuesInCol(pCol, pSubValue)
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

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :Value, :Cells, :Values ])
				return This.ContainsCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :SubValues ])
				return This.ContainsSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				stzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.ContainsCellCS(pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ColContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInCol(pCol, pCellValueOrSubValue)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, :CaseSensitive = TRUE)

			def ColContains(pCol, pCellValueOrSubValue)
				return This.ContainsInCol(pCol, pCellValueOrSubValue)

	def ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ColContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ContainsValueInColCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def ContainsCellInCol(pCol, pCellValue)
			return This.ContainsCellInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

			def ColContainsCell(pCol, pCellValue)
				return This.ContainsCellInCol(pCol, pCellValue)

			def ContainsValueInCol(pCol, pCellValue)
				return This.ContainsCellInCol(pCol, pCellValue)
	
	def ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def ColContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInCol(pCol, pSubValue)
			return This.ContainsSubValueInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

			def ColContainsSubValue(pCol, pSubValue)
				return This.ContainsSubValueInCol(pCol, pSubValue)


///// 5 >> WORKING ON SECTIONS //////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////

	  #===================#
	 #  REPLACING CELLS  #
	#===================#

	def ReplaceCell(pCol, pnRow, pNewValue)
		This.Table(pCol)[pnRow] = pNewValue

	def ReplaceCells(paCellsPos, pNewValue)
		for cellPos in paCellsPos
			This.ReplaceCell(cellPos[1], cellPos[2], pNewValue)
		next

	def ReplaceCellsByMany(paCellsPos, paNewValues)
		nLenCells = len(paCellsPos)
		nLenValues = len(paNewValues)
		
		if nLenValues >= nLenCells
			aValues = Q(paNewValues).Section(1, nLenCells)

		else
			aValues = Q(paNewValues).ExtendedTo( nLenCells, :Using = NULL )
		ok
		
		i = 0
		for cellPos in paCellsPos
			i++
			This.ReplaceCell(cellPos[1], cellPos[2], aValues[i])
		next

		def Paste(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

	def ReplaceAllCS(pValue, pNewValue, pCaseSensitive)
		aCellsPos = This.FindAllCs(pValue, pCaseSensitive)
		This.ReplaceCells(aCellsPos, pNewValue)

	def ReplaceAll(pValue, pNewValue, pCaseSensitive)
		This.ReplaceAllCS(pValue, pNewValue, :CaseSensitive = TRUE)

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
			
			stzRaise("Incorrect column format! paColNameAndData must take the form :ColName = [ cell1, cell2, ... ].")
		ok

		if NOT len(paColNameAndData[2]) = This.NumberOfRows()
			stzRaise("Incorrect number of cells! paColNameAndData must contain extactly " + This.NumberOfRows() + " cells.")
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
			stzRaise("Incorrect param type! paRow must be a list.")
		ok

		if NOT len(paRow) = This.NumberOfCols()
			stzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
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

			stzRaise("Incorrect param type! paNewTable must be a hashlist where values are lists of the same size.")
		ok

		@aTable = paNewTable

	  #====================#
	 #  RENAMING COLUMNS  #
	#====================#

	def RenanmeCol(pCol, pcNewName)

		if NOT isString(pcNewName)
			stzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = This.NumberOfCols()

			but This.HasColName(pCol)
				pCol = This.ColToColNumber(pCol)

			else
				stzRaise("Incorrect value! Allowed values :FirstCol, :LastCol, or use a number instead.")
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
			stzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		This.Table()[n][1] = pcNewName

		def RenameColN(n, pcNewName)
			This.RenameNthCol(n, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			stzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
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

	def Erase() // Only data is erased, columns remain as they are
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
			stzRaise("Incorrect param type! panRows must be a list of numbers!")
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
			stzRaise("Incorrect column name!")
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
			stzRaise("Incorrect param type! pacColNames must be a list of string.")
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
				stzRaise("Unsupported return type!")
			off

	def ColNumbersToNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsLIstOfNumbers() )
			stzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
		ok

		aResult = []

		for n in panColNumbers
			aResult + This.NthColName(n)
		next

		return aResult
	
	def TheseColumns(paColNamesOrNumbers)
		if NOT 	( isList(paColNamesOrNumbers) and
			  ( Q(paColNamesOrNumbers).IsListOfNumbers() or
			  Q(paColNamesOrNumbers).IsListOfStrings() )
			)

			stzRaise("Incorrect param type! paColNamesOrNumbers must be a list of numbers or a list of strings.")
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
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
			stzRaise("Incorrect param type! pacColNumbers muts be a list of numbers.")
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

	  #======================#
	 #  SUBSET OF THE TABLE #
	#======================#

	def SubSet(panRowsNumbers)
		return This.TheseRows(panRowsNumbers)

		def SubSetQ(panRowsNumbers)
			return This.SubSetQR(panRowsNumbers, :stzList)

		def SubSetQR(panRowsNumbers, pcReturnType)
			return This.TheseRowsQR(panRowsNumbers, pcReturnType)

	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers() )

			stzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
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
				stzRaise("Unsupported return type!")
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
				stzRaise("Unsupported return type!")
			off

	  #=====================#
	 #  SORTING THE TABLE  #
	#=====================#

	/* ... */

	  #=====================#
	 #  SHOWING THE TABLE  #
	#=====================#

	def Show()
		? This.ToString()

	def ToString()
		cTable = This.HeaderToString() + NL + This.RowsToString()
		return cTable

	def MaxWidthInCol(pCol)
		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])

			but This.HasColName(pCol)
				pCol = This.FindCol(pCol)

			else
				stzRaise("Syntax error in column name! Allowed values are :First, :FirstCol, or privide a number instead.")
			ok
		ok

		anSizes = [ This.ColNameQ(pCol).NumberOfChars() ]

		aColData = This.Col(pCol)
		for cell in aColData
			anSizes + @@SQ(cell).RemoveBoundsQ('"').NumberOfChars()
		next

		nResult = StzListOfNumbersQ(anSizes).Max()
		return nResult

		def WidthOfLargestCellInCol(pCol)
			return This.MaxWidthInCol(pCol)

	def MaxWidthInEachCol()
		anResult = []

		for cColName in This.ColNames()
			anResult + This.MaxWidthInCol(cColName)
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
				stzRaise("Unsupported return type!")
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
		cRows = ""

		for y = 1 to NumberOfRows()
			cRows += ""+ y + "   " + RowToString(y) + NL
		next

		return cRows


	def RowToString(n)
		cRow = ""
		aRow = This.Row(n)

		anMax = []
		for colName in This.ColNames()
			anMax + This.WidthOfLargestCellInCol(colName)
		next

		i = 0
		for cell in aRow
			i++
			cRow += @@SQ(cell).RemoveBoundsQ('"').
						AlignedToRightXT( anMax[i], " " )

			if i < len(aRow)
				cRow += "   "
			ok
		next

		return cRow

		def RowToStringQ(n)
			return new stzString( This.RowToString(n) )

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

		if NOT IsNumberOrString(p)
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				stzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		cResult = This.ColName(p)
		return cResult

		def ColumnToColumnName(p)
			return This.ColToColName(p)

		def ColToName(p)
			return This.ColToColName(p)

	def TheseColsToColNames(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() )
			)

			stzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
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

	def ColToColNumber(p)
		if isList(p) and Q(p).IsOneOfTheseNamedParams([ :Row, :InRow, :Rows, :InRows ])
			p = p[2]
		ok

		if NOT IsNumberOrString(p)
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				stzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		if NOT Q(p).IsBetween(1, This.NumberOfCols())
			stzRaise("Incorrect value! n must be a number between 1 and " + This.NumberOfCols() + ".")
		ok

		nResult = p
		return nResult

		def ColumnToColumnNumber(p)
			return This.ColToColNumber(p)

		def ColToNumber(p)
			return This.ColToColNumber(p)

	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() )
			)

			stzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
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
			stzRaise("Incorrect param type! pRow must be a number.")
		ok

		return  pRow

		def RowToNumber(pRow)
			return This.RowToRowNumber(pRow)

	def TheseRowsToRowsNumbers(paRows)
		aResult = []

		for aRow in paRows
			aResult + This.RowToNumber(aRow)
		next

		return aResult

		def TheseRowsToNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

