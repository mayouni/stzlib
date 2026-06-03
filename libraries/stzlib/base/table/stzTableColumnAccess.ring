#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLECOLUMNACCESS        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table column access subclass -- getting     #
#                  column data, positions, and names.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableColumnAccess from stzTable

	  #===============================================#
	 #   GETTING A COLUMN DATA (IN A LIST OF CELLS)  #
	#===============================================#

	def Col(p)

		if isString(p)

			if StzFind([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFind([ :Last, :LastCol, :LastColumn ], p) > 0
				p = This.NumberOfColumns()

			but This.HasColName(p)
				p = This.FindCol(p)
			ok
		ok

		aResult = This.ColSection( p, 1, This.NumberOfRows() )

		return aResult

		#< @FunctionFluentForm

		def ColQ(p)
			return This.ColQRT(p, :stzList)

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

		def Column(p)
			return This.Col(p)

			def ColumnQ(p)
				return This.ColumnQRT(p, :stzList)

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

		nLen = ring_len(paCols)

		aResult = []
		for i = 1 to nLen
			aResult + This.CellsInCol(paCols[i])
		next

		aResult = Q(aResult).Flattened()
		return aResult

	  #------------------------------------------------#
	 #  GETTING THE COLUMN NAME AND THE COLUMN CELLS  #
	#------------------------------------------------#

	def ColXT(p)
		aResult = [ This.ColName(p) ]

		aCells = This.Col(p)
		nLen = ring_len(aCells)

		for i = 1 to nLen
			aResult + aCells[i]
		next

		return aResult

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

	def NthColName(n)
		if isString(n)

			if StzFind([ :First, :FirstCol, :FirstColumn ], n) > 0
				n = 1

			but StzFind([ :Last, :LastCol, :LastColumn ], n) > 0
				n = This.NumberOfColumns()

			else
				StzRaise("syntax error in (" + n + ")! Allowed values are :First or :Last ( or :FirstCol or :LastCol).")

			ok
		ok

		cResult = This.ColNames()[n]

		return cResult

		def NthColumnName(n)
			return This.NthColName(n)

	  #------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE NTH COLUMN   #
	#------------------------------------------------#

	def NthCol(n)
		return This.Col(n)

		def NthColumn(n)
			return This.NthCol(n)

		def CellsInNthCol(n)
			return This.NthCol(n)

		def CellsInNthColumn(n)
			return This.NthCol(n)

		def NthColData(n)
			return This.NthCol(n)

		def NthColumnData(n)
			return This.NthCol(n)

	  #-------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF NTH COLUMN ALONG WITH ITS CELLS  #
	#-------------------------------------------------------------------------#

	def NthColXT(n)
		if isString(n)
			if n = :first or n = :FirstCol or n = :FirstColumn
				n = 1

			but n = :Last or n = :LastCol or n = :LastColumn
				n = This.NumberOfCol()
			ok
		ok

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

	  #----------------------------------------#
	 #  GETTING THE NAME OF THE FIRST COLUMN  #
	#========================================#

	def FirstColName()
		return This.NthColName(1)

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

	def LastColName()
		return This.NthColName(This.NumberOfCols())

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

		nLenCols = ring_len(@aContent)

		if n < 1 or n > nLenCols
			StzRaise("Index out of range! n must is not a valid number of column.")
		ok

		cResult = @aContent[n][1]
		return cResult

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

		nCol = This.ColToColNumber(pCol)

		nNumberOfRows = This.NumberOfRows()

		aResult = []

		for i = 1 to nNumberOfRows
			aResult + [ nCol, i]
		next

		return aResult

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
		nLen = ring_len(paCols)
		anColNumbers = This.TheseColsAsNumbers(paCols)
		aResult = []

		for i = 1 to nLen
			aCellsPos = This.CellsInColAsPositions(anColNumbers[i])
			nLenCells = ring_len(aCellsPos)

			for j = 1 to nLenCells
				aResult + aCellsPos[j]
			next
		next

		return aResult

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
