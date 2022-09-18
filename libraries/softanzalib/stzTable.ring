
func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable
	@aTable = [] # TODO: Change it to a list of hashlists!

	def init(paTable)
		// TODO: also check that the second values are all lists and
		// that they have same size...

		if NOT ( isList(paTable) and Q(paTable).IsHashList() and
			 StzHashListQ(paTable).ValuesAreListsOfSameSize() )
			stzRaise("Incorrect param format! paTable must be a hashlist with values that are lists of same size.")
		ok

		@aTable = paTable

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
				return This.ColumnsQ()

			def ColumnsNamesQR(pcReturnType)
				return This.ColmunsQR(pcReturnType)

		def Cols()
			return This.Columns()

			def ColsQ()
				return This.This.ColumnsQ()

			def ColsQR(pcReturnType)
				return This.ColmunsQR(pcReturnType)

		def ColsNames()
			return This.Columns()

			def ColsNamesQ()
				return This.ColumnsQ()

			def ColsNamesQR(pcReturnType)
				return This.ColmunsQR(pcReturnType)

		def ColNames()
			return This.Columns()

			def ColNamesQ()
				return This.ColumnsQ()

			def ColNamesQR(pcReturnType)
				return This.ColmunsQR(pcReturnType)

		def Header()
			return This.Columns()

			def HeaderQ()
				return This.HeaderQ()

			def HeaderQR(pcReturnType)
				return This.HeaderQR(pcReturnType)

		#>

	  #======================#
	 #   READING A COLUMN   #
	#======================#

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
		aResult = ColQ(p).AssociatedWith( This.CellsInColAsPositions(p) )
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

		def CellsAndPositionsInCol(p)
			return This.ColXT(p)

			def CellsAndPositionsInColQ(p)
				return This.CellsAndPositionsInColQR(p, :stzList)

			def CellsAndPositionsInColQR(p, pcReturnType)
				return This.ColXTQR(p, pcReturnType)

		def CellsAndPositionsInColumn(p)
			return This.ColXT(p)

			def CellsAndPositionsInColumnQ(p)
				return This.CellsAndPositionsInColumnQR(p, :stzList)

			def CellsAndPositionsInColumnQR(p, pcReturnType)
				return This.ColXTQR(p, pcReturnType)
		#>

	  #----------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN COLUMN   #
	#----------------------------------------------------------#

	def CellsInColAsPositions(pCol)
		nCol = This.FindCol(pCol)
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

	def HorizontalSection(pRow, n1, n2)
		aCellsPos =  This.HorizontalSectionAsPositions(pRow, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

	def HorizontalSectionAsPositions(pRow, n1, n2)
		if isString(pRow)
			if Q(pRow).IsOneOfThese([ :First, :FirstRow ])
				pRow = 1

			but Q(pRow).IsOneOfThese([ :Last, :LastRow ])
				prow = This.NumberOfRows()

			ok
		ok

		if NOT isNumber(pRow)
			stzRaise("Incorrect param type! pRow must be a number.")
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
			aResult + [i, pRow]
		next

		return aResult

	def Row(p)

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstRow ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastRow ])
				p = This.NumberOfRows()

			ok
		ok

		aResult = This.HorizontalSection( p, 1, This.NumberOfCols() )
		return aResult

		#< @FunctionFluentForm

		def RowQ(p)
			return This.RowQR(p, :stzList)

		def RowQR(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(p) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(p) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(p) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(p) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(p) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(p) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInRow(p)
			return This.Row(p)

			def CellsInRowQ(p)
				return This.CellsInRowQR(p, :stzList)

			def CellsInRowQR(p, pcReturnType)
				return This.CellsInRowQR(p, pcReturnType)

		#>

	def RowXT(p)
		aResult = RowQ(p).AssociatedWith( This.CellsInRowAsPositions(p) )
		return aResult

		#< @FunctionFluentForm

		def RowXTQ(p)
			return This.RowXTQR(p, :stzList)

		def RowXTQR(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowXT(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowXT(p) )

			on :stzListOfLists
				return new stzListOfLists( This.RowXT(p) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsInRowXT(p)
			return This.RowXT(p)

			def CellsInRowXTQ(p)
				return This.CellsInRowXTQR(p, :stzList)

			def CellsInRowXTQR(p, pcReturnType)
				return This.CellsInRowXTQR(p, pcReturnType)

		def CellsAndPositionsInRow(p)
			return This.RowXT(p)

			def CellsAndPositionsInRowQ(p)
				return This.CellsAndPositionsInRowQR(p, :stzList)

			def CellsAndPositionsInRowQR(p, pcReturnType)
				return This.RowXTQR(p, pcReturnType)

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

		def CellsAsPositionsInrow(pnRow)
			return This.CellsInRowAsPositions(pnRow)

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

		def ColumnName(n)
			return This.ColName(n)

	  #=====================#
	 #   GETTING NTH ROW   #
	#=====================#

	def NthRow(n)
		return This.Row(n)

	def NthRowXT(n)
		return This.RowXT(n)

	  #--------------------------#
	 #   GETTING FIRST ROW   #
	#--------------------------#

	def FirstRowXT()
		return This.NthRowXT(1)

	def FirstRow()
		return This.NthRow(1)

	  #----------------------#
	 #   GETTING LAST ROW   #
	#----------------------#

	def LastRowXT()
		return This.NthRowXT(:Last)

	def LastRow()
		return This.NthRow(:Last)

	  #================================#
	 #   GETTING THE NUMBER OF ROWS   #
	#================================#

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

	  #-------------------------------#
	 #  GETIING THE NUMBER OF CELLS  #
	#-------------------------------#

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

		#>

	  #---------------------------------#
	 #  GETIING THE LIST OF ALL CELLS  #
	#---------------------------------#

	def Cells()
		aResult = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return aResult

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

		def CellsXT()
			return This.CellsAndTheirPositions()

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

	  #------------------------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS BY TRANSFORMING IT TO A HASHLIST  #
	#------------------------------------------------------------------#

	def CellsToHashList()
		aResult = This.TheseCellsToHashList( This.CellsAsPositions() )
		return aResult

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

	def TheseCellsToHashList(paCellsPos)
		# TODO: check if paCells are really cells and belong to the table!

		aResult = []

		for cellPos in paCellsPos
			aResult + [ @@S(cellPos), This.Cell(cellPos[1], cellPos[2]) ]
		next

		return aResult

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
			       AssociatedWith( This.SectionQ(panCellPos1, panCellPos2) )

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
	
	def FirstCellPosition()
		return [1, 1]

	def LastCellPosition()
		return [ This.NumberOfCol(), This.NumberOfRows() ]

	def SectionAsPositions( panCellPos1, panCellPos2 )
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

	  #--------------------------------#
	 #  CASE OF RECTANGULAR SECTIONS  #
	#--------------------------------#

	// TODO

	  #--------------------------------------------------------#
	 #  CASE OF VERTICAL SECTIONS (SOME CELLS FROM A COLUMN)  #
	#--------------------------------------------------------#

	// TODO

	  #-------------------------------------------------------#
	 #  CASE OF HORIZONTAL SECTIONS (SOME CELLS FROM A ROW)  #
	#-------------------------------------------------------#

	// TODO

	  #============================#
	 #  GETTING A RANGE OF CELLS  #
	#============================#

	// TODO

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

	  #===============================================#
	 #  NUMBER OF OCCURRENCE OF A CELL IN THE TABLE  #
	#===============================================#

	def NumberOfOccurrenceCS(pCellValue, pCaseSensitive)
		if isList(pCellValue) and Q(pCellValue).IsOfNamedParam()
			pCellValue = pCellValue[2]
		ok

		nResult = len( This.FindCellsCS(pCellValue, pCaseSensitive) )
		return nResult

		def NumberOfOccurrencesCS(pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellCS(pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrence(pCellValue)
		return This.NumberOfOccurrenceCS(pCellValue, :CaseSensitive = TRUE)

		def NumberOfOccurrences(pCellValue)
			return This.NumberOfOccurrence(pCellValue)

		def NumberOfOccurrenceOfCell(pCellValue)
			return This.NumberOfOccurrence(pCellValue)

		def NumberOfOccurrencesOfCell(pCellValue)
			return This.NumberOfOccurrence(pCellValue)

	  #----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A GIVEN COLUMN  #
	#----------------------------------------------------#

	def NumberOfOccurrenceInColCS(pCol, pCellValue, pCaseSensitive)
		if isList(pCellValue) and Q(pCellValue).IsOfNamedParam()
			pCellValue = pCellValue[2]
		ok

		nResult = len( This.FindCellsInColCS(pCol, pCellValue, pCaseSensitive) )
		return nResult

		def NumberOfOccurrencesInColCS(pCol, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColCS(pCol, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCol(pCol, pCellValue)
		return This.NumberOfOccurrenceInColCS(pCol, pCellValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCol(pCol, pCellValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValue)

		def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValue)

		def NumberOfOccurrencesOfCellInCol(pCol, pCellValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValue)

	  #-------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A GIVEN ROW  #
	#-------------------------------------------------#

	def NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)
		if isList(pCellValue) and Q(pCellValue).IsOfNamedParam()
			pCellValue = pCellValue[2]
		ok

		nResult = len( This.FindCellsInRowCS(n, pCellValue, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceInRowNCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesInRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesInRowNCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfCellInRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfCellInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfCellInRowNCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInRowNCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(n, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInRow(n, pCellValue)
		return This.NumberOfOccurrenceInRowCS(n, pCellValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInNthRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrenceInRowN(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		#--

		def NumberOfOccurrencesInRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrencesInNthRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrencesInRowN(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		#--

		def NumberOfOccurrenceOfCellInRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrenceOfCellInNthRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrenceOfCellInRowN(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		#--

		def NumberOfOccurrencesOfCellInRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrencesOfCellInNthRow(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		def NumberOfOccurrencesOfCellInRowN(n, pCellValue)
			return This.NumberOfOccurrenceInRow(n, pCellValue)

		#>

	  #-----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A GIVEN SECTION  #
	#-----------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		nResult = len( This.FindInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive) )
		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInSection(paCellPos1, paCellPos2, pSubValue)
		return This.NumberOfOccurrenceInSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

	  #-----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE SOME CELLS  #
	#-----------------------------------------------------#

	def NumberOfOccurrenceInCellsInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		aCellsPos = This.SectionAsPositions(paCellPos1, paCellPos2)
		bResult = This.NumberOfOccurrenceInCellsCS(aCellPos, pSubValue, pCaseSensitive)
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCellsInSection(paCellPos1, paCellPos2, pSubValue)
		return This.NumberOfOccurrenceInSideSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

	  #--------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE A CELL   #
	#--------------------------------------------------#

	def NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCell(pnCol, pnRow, pSubValue)
		return This.NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCell(pnCol, pnRow, pSubValue)
			return This.NumberOfOccurrenceInCell(pnCol, pnRow, pSubValue)

	  #------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE MANY CELLS   #
	#------------------------------------------------------#

	def NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCells(paCellsPos, pSubValue)
		return This.NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCells(paCellsPos, pSubValue)
			return This.NumberOfOccurrenceInCells(paCellsPos, pSubValue)

	  #===================================================#
	 #  CHECKING IF A CELL CONTAIN A GIVEN VALUE INSIDE  #
	#===================================================#

	def CellContainsCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		cell = This.Cell(pnCol, pnRow)

		bResult = FALSE

		if isString(cell) or (isList(cell) and Q(cell).IsListOfStrings())
			bResult = Q(cell).ContainsCS(pSubValue, pCaseSensitive)

		else
			bResult = Q(cell).Contains(pSubValue)
		ok

		return bResult

	#-- WITHOUT CASESNESITIVITY

	def CellContains(pnCol, pnRow, pSubValue)
		return This.CellContainsCS(pnCol, pnRow, pSubValue, :CS = TRUE)

	  #-------------------------------------------------------#
	 #  CHECKING IF SOME CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#-------------------------------------------------------#

	def CellsContainCS(paCellsPos, pSubValue, pCaseSensitive)
		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		
		for cellPos in paCellsPos
			if This.CellContainsCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def CellsContain(paCellsPos, pSubValue)
		return This.CellsContainCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #------------------------------------------------------#
	 #  CHECKING IF ALL CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#------------------------------------------------------#

	def AllCellsContainCS(paCellsPos, pSubValue, pCaseSensitive)
		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = TRUE
		
		for cellPos in paCellsPos
			if NOT This.CellContainsCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def EachCellContainsCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.AllCellsContainCS(paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def AllCellsContain(paCellsPos, pSubValue)
		return This.AllCellsContainsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def EachCellContains(paCellsPos, pSubValue)
			return This.AllCellsContain(paCellsPos, pSubValue)

	  #-----------------------------------------------------#
	 #  CHECKING IF NO CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#-----------------------------------------------------#

	def NoCellsContainCS(paCellsPos, pSubValue, pCaseSensitive)
		return NOT This.AllCellsContainCS(paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NoCellsContain(paCellsPos, pSubValue)
		return This.NoCellsContainCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #-------------------------------------------------------#
	 #  CHECKING IF SOME CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#-------------------------------------------------------#

	def SomeCellsContainCS(paCellsPos, pSubValue, pCaseSensitive)
		return This.NCellsContainCS(paCellsPos, pSubValue, pCaseSensitive) = 1

	#-- WITHOUT CASESENSITIVITY

	def SomeCellsContain(paCellsPos, pSubValue)
		return This.NoCellsContainCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------#
	 #  CHECKING IF N OF THE GIVEN CELLS CONTAIN A GIVEN VALUE INSIDE THEM  #
	#----------------------------------------------------------------------#

	def NCellsContainCS(n, paCellsPos, pSubValue, pCaseSensitive)
		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		i = 0

		for cellPos in paCellsPos
			if This.CellContainsCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
				i++
				if i = n
					bResult = TRUE
					exit
				ok
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def NCellsContain(paCellsPos, pSubValue)
		return This.NCellsContainCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  CHECKING IF CELLS CONTAIN N OCCURRENCES OF GIVEN VALUE INSIDE IT  #
	#--------------------------------------------------------------------#

	def CellsContainNOccurrenceCS(n, paCellsPos, pSubValue, pCaseSensitive)
		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		i = 0

		for cellPos in paCellsPos
			i += This.NumberOfOccurrenceCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
			if i = n
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def CellsContainNOccurrencesCS(n, paCellsPos, pSubValue, pCaseSensitive)
			return This.CellsContainNOccurrenceCS(n, paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContainNOccurrence(n, paCellsPos, pSubValue)
		return This.CellsContainNOccurrenceCS(n, paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def CellsContainNOccurrences(n, paCellsPos, pSubValue)
			return This.CellsContainNOccurrence(n, paCellsPos, pSubValue)

	  #---------------------------------------------#
	 #  CHECKING IF A CELL CONTAINS A GIVEN VALUE  #
	#---------------------------------------------#

	def ContainsInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		cellValue = This.Cell(pnCol, pnRow)

		bResult = FALSE

		if isString(cell) or (isList(cellValue) and Q(cellValue).IsListOfStrings())
			bResult = Q(cellValue).ContainsCS(pSubValue, pCaseSensitive)

		else
			bResult = Q(cellValue).Contains(pSubValue)
		ok

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsInCell(pnCol, pnRow, pSubValue)
		return This.ContainsInCellCS(pnCol, pnRow, pSubValue, :CS = TRUE)

	  #-----------------------------------------------#
	 #  CHECKING IF SOME CELLS CONTAIN A GIVEN CELL  #
	#-----------------------------------------------#

	def ContainsInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		bResult = FALSE

		for cellPos in paCellsPos
			if This.ContainsInCellCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsInCells(paCellsPos, pSubValue)
		return This.ContainsInCellsCS(paCellsPos, pSubValue, :CS = TRUE)

	  #-----------------------------------------------#
	 #  CHECKING IF A SECTION CONTAINS A GIVEN CELL  #
	#-----------------------------------------------#

	def ContainsInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		aCellsPos = This.SectionAsPositions(paCellPos1, paCellPos2)
		bResult = This.ContainsInCellsCS(aCellsPos, pSubValue, pCaseSensitive)

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsInSection(paCellPos1, paCellPos2, pSubValue)
		return This.ContainsInSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

	  #------------------------------------------------------------#
	 #  CHECKING IF SOME CELLS CONTAIN A GIVEN VALUE INSIDE THEM  #
	#------------------------------------------------------------#

	def ContainsInCellsInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		aCellsPos = This.SectionAsPositions(paCellPos1, paCellPos2)
		bResult = This.ContainsInCellsCS(aCellPos, pSubValue, pCaseSensitive)
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsInCellsInSection(paCellPos1, paCellPos2, pSubValue)
		return This.ContainsInSideSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

	  #=============================================#
	 #  FINDING ALL CELLS FORMED OF A GIVEN VALUE  #
	#=============================================#

	def FindCellsCS(pCellValue, pCaseSensitive)
		aResult = []

		oHashList = new stzHashList( This.CellsToHashList() )
		acCellPos = oHashList.FindKeysByValue(pCellValue)

		cCode = 'aResult = ' + @@S(acCellPos)
		eval(cCode)

		return aResult

		def FindAllCS(pCellValue, pCaseSensitive)
			return This.FindCellsCS(pCellValue, pCaseSensitive)

	def FindCells(pValue)
		return This.FindCellsCS(pValue, :CaseSensitive = TRUE)

		def FindAll(pCellValue, pCaseSensitive)
			return This.FindCells(pValue)

	  #---------------------------------------------------------#
	 #  FINDING THE NTH OCCURRENCE OF A CELL INSIDE THE TABLE  #
	#---------------------------------------------------------#

	def FindNthCellCS(n, pCellValue, pCaseSensitive)
		if isList(pCellValue) and Q(pCellValue).IsOfNamedParam()
			pCellValue = pCellValue[2]
		ok

		if isString(n)
			if n = :First or :FirstCell
				n = 1
			but n = :Last or :LastCell

				n = This.NumberOfOccurrence(pCellValue)
			ok
		ok

		aPositions = This.FindCellsCS(pCellValue, pCaseSensitive)

		nResult = 0

		if n > 0 and n <= len(aPositions)
			nResult = aPositions[n]
		ok

		return nResult

		def FindNthOccurrenceCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

	def FindNthCell(n, pCellValue)
		return This.FindNthCellCS(n, pCellValue, :CaseSensitive = TRUE)

		def FindNthOccurrence(n, pCellValue)
			return This.FindNthCell(n, pCellValue)

	#---

	def FindFirstCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(1, pCellValue, pCaseSensitive)

		def FindCellCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstOccurrenceCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

	def FindFirstCell(pCellValue)
		return This.FindFirstCellCS(pCellValue, :CaseSensitive = TRUE)

		def FindCell(pCellValue)
			return This.FindFirstCell(pCellValue)

		def FindFirstOccurrence(pCellValue)
			return This.FindFirstCell(pCellValue)

	#---

	def FindLastCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(:Last, pCellValue, pCaseSensitive)

		def FindLastOccurrenceCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)


	def FindLastCell(pCellValue)
		return This.FindLastCellCS(pCellValue, :CaseSensitive = TRUE)

		def FindLastOccurrence(pCellValue)
			return This.FindLastCell(pCellValue)

	  #--------------------------------#
	 #  FINDING CELLS IN A GIVEN RAW  #
	#--------------------------------#

	def FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		if isString(n)
			n = This.FindRow(n)
		ok

		aResult = []

		i = 0
		for cell in This.Row(n)
			i++

			if isString(cell) or
			   (isList(cell) and Q(cell).IsListOfStrings())

				if isString(pCellValue)
					if Q(cell).IsEqualToCS(pCellValue, pCaseSensitive)
						aResult + [n, i]
					ok
				ok

			else
				if Q(cell).IsEqualTo(pCellValue)
					aResult + [n, i]
				ok
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindCellsInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		def FindCellsInRowNCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		def FindInRowCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		def FindInNthRowCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		def FindInRowNCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInRowCS(n, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindCellsInRow(n, pCellValue)
		return This.FindInRowCS(n, pCellValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindCellsInNthRow(n, pCellValue)
			return This.FindCellsInRow(n, pCellValue)

		def FindCellsInRowN(n, pCellValue)
			return This.FindCellsInRow(n, pCellValue)

		def FindInRow(n, pCellValue)
			return This.FindCellsInRow(n, pCellValue)

		def FindInNthRow(n, pCellValue)
			return This.FindCellsInRow(n, pCellValue)

		def FindInRowN(n, pCellValue)
			return This.FindCellsInRow(n, pCellValue)

		#>

	  #-----------------------------------#
	 #  FINDING CELLS IN A GIVEN COLUMN  #
	#-----------------------------------#

	def FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		if isString(pnCol)
			if This.HasColName(pnCol)
				pnCol = This.FindCol(pnCol)
			else
				# TODO + WARNING: generalise this check in all
				# similar situations, otherwise a silent bug would
				# happen and be difficult to be aware of!
				stzRaise("Column name (" + pnCol + ") not found!")
			
			ok
		ok

		if isList(pCellValue) and Q(pCellValue).IsMadeOfParamList()
			pCellValue = pCellValue[2]
		ok

		aResult = []

		i = 0
		for cell in This.Col(pnCol)
			i++

			if isString(cell) or
			   (isList(cell) and Q(cell).IsListOfStrings())

				if isString(pCellValue)
					if Q(cell).IsEqualToCS(pCellValue, pCaseSensitive)
						aResult + [pnCol, i]
					ok
				ok

			else
				if Q(cell).IsEqualTo(pCellValue)
					aResult + [pnCol, i]
				ok
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindCellsInNthColCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindCellsInColNCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInColCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInNthColCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInColNCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		#--

		def FindCellsInColumnCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindCellsInNthColumnCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindCellsInColumnNCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInColumnCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInNthColumnCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		def FindInColumnNCS(pnCol, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(pnCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindCellsInCol(pnCol, pCellValue)
		return This.FindCellsInColCS(pnCol, pCellValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindCellsInNthCol(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindCellsInColNC(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInCol(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInNthCol(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInColN(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		#--

		def FindCellsInColumn(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindCellsInNthColumn(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindCellsInColumnN(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInColumn(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInNthColumn(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		def FindInColumnN(pnCol, pCellValue)
			return This.FindCellsInCol(pnCol, pCellValue)

		#>

	  #----------------------------------------#
	 #  FINDING A CELL IN A SECTION OF CELLS  #
	#----------------------------------------#

	def FindCellsInSectionCS(panPair1, panPair2, pCellValue, pCaseSensitive)

		aCellsXT = This.SectionXT(panPair1, panPair2)

		bCaseSensitive = pCaseSensitive[2]

		if isString(pCellValue) and bCaseSensitive = TRUE
			pCellValue = Q(pCellValue).Lowercased()
		ok

		aResult = []

		for cellxt in aCellsXT
			aCellPosition = cellxt[1]
			cellValue = cellxt[2]

			if bCaseSensitive and isString(cellValue)
				cellValue = Q(cellValue).Lowercased()
			ok
				
			if Q(cellValue).IsEqualTo(pCellValue)
				aResult + aCellPosition
			ok
		next

		return aResult
		

		def FindInSectionCS(panPair1, panPair2, pCellValue, pCaseSensitive)
			return This.FindCellsInSectionCS(panPair1, panPair2, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCellsInSection(panPair1, panPair2, pCellValue)
		return This.FindCellsInSectionCS(panPair1, panPair2, pCellValue, :CaseSensitive = TRUE)

		def FindInSection(panPair1, panPair2, pCellValue)
			return This.FindCellsInSection(panPair1, panPair2, pCellValue)

	  #----------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE A CELL  #
	#----------------------------------------------------#

	def FindInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		if isList(pSubValue) and Q(pSubValue).IsOfNamedParam()
			pSubValue = pSubValue[2]
		ok

		cellValue = This.Cell(pnCol, pnRow)

		aResult = []

		if isString(cellValue) or ( isList(cellValue) and Q(cellValue).IsListOfStrings() )
			if isString(pSubValue)
				aResult = Q(cellValue).FindAllCS(pSubValue, pCaseSensitive)
			ok

		but isList(cellValue)
			aResult = Q(cellValue).FindAll(pSubValue)

		ok

		return aResult

		def FindAllOccurrencesInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
			return This.FindInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
	
	#-- WITHOUT CASESENSITIVITY

	def FindInCell(pnCol, pnRow, pSubValue)
		return This.FindInCellCS(pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

		def FindAllOccurrencesInCell(pnCol, pnRow, pSubValue)
			return This.FindInCell(pnCol, pnRow, pSubValue)

	  #---------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE A CELL  #
	#---------------------------------------------------#

	def FindNthOccurrenceInCellCS(n, pnCol, pnRow, pSubValue, pCaseSensitive)
		if isString(n)
			if n = :First
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
			ok
		ok

		nResult = This.FindAllOccurrencesInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)[n]

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCell(n, pnCol, pnRow, pSubValue)
		return This.FindNthOccurrenceInCellCS(n, pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE A CELL  #
	#-----------------------------------------------------#

	def FindFirstOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellCS(:First, pnCol, pnRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCell(pnCol, pnRow, pSubValue)
		return This.FindFirstOccurrenceInCellCS(pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

	  #----------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE A CELL  #
	#----------------------------------------------------#

	def FindLastOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellCS(:Last, pnCol, pnRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCell(pnCol, pnRow, pSubValue)
		return This.FindLastOccurrenceInCellCS(pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

	  #=========================================================#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS  #
	#=========================================================#

	def FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		aResult = []

		for cellPos in paCellsPos
			aOccurr = This.FindInCellCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
			if len(aOccurr) > 0
				aResult + [ cellPos, aOccurr ]
			ok
		next

		return aResult

		def FindAllInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
	
	#-- WITHOUT CASESENSITIVITY

	def FindInCells(paCellsPos, pSubValue)
		return This.FindInCellsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def FindAllInCells(paCellsPos, pSubValue)
			return This.FindInCell(paCellsPos, pSubValue)

		def FindOccurrencesInCells(paCellsPos, pSubValue)
			return This.FindInCell(paCellsPos, pSubValue)

	  #---------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS -- EXTENDED  #
	#---------------------------------------------------------------------#

	def FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)
		
		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		aResult = []

		aPairs  = This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		i = 0
		for cellPos in paCellsPos
			i++
			aPair = aPairs[i]
			if len(aPair) != 0
				aResult + [ cellPos, aPair ]
			ok
		next

		return aResult

		def FindInCellsCSXT(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		def FindAllInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		def FindAllInCellsCSXT(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCSXT(paCellsPos, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsXT(paCellsPos, pSubValue)
		return This.FindInCellsXTCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def FindAllInCellsXT(paCellsPos, pSubValue)
			return This.FindInCellsXT(paCellsPos, pSubValue)

		def FindOccurrencesInCellsXT(paCellsPos, pSubValue)
			return This.FindInCellsXT(paCellsPos, pSubValue)

	  #--------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#--------------------------------------------------------#

	def FindNthOccurrenceInCellsCS(n, paCellsPos, pSubValue, pCaseSensitive)
		if isString(n)
			if n = :First
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
			ok
		ok

		nResult = This.FindAllOccurrencesInCellsCS(paCellsPos, pSubValue, pCaseSensitive)[n]

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCells(n, paCellsPos, pSubValue)
		return This.FindNthOccurrenceInCellsCS(n, paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #----------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#----------------------------------------------------------#

	def FindFirstOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsCS(1, paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCells(paCellsPos, pSubValue)
		return This.FindFirstOccurrenceInCellsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #---------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#---------------------------------------------------------#

	def FindLastOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsCS(:Last, paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCells(paCellsPos, pSubValue)
		return This.FindLastOccurrenceInCellsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

	  #=========================================================================#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE THE CELLS OF A GIVEN COLUMN  #
	#=========================================================================#

	def FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)
		aResult = This.FindInCellsCS( This.ColCellsAsPositions(pCol), pSubValue, pCaseSensitive )
		return aResult

		#< @FunctionAlternativeForms

		def FindAllInCellsInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def FindInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		def FindAllInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColCS(pCol, pSubValue, pCaseSensitive)
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInCol(pCol, pSubValue)
		return This.FindInCellsInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllInCellsInCol(pCol, pSubValue)
			return This.FindInCellsInCol(pCol, pSubValue)

		def FindOccurrencesInCellsInCol(pCol, pSubValue)
			return This.FindInCellsInCol(pCol, pSubValue)

		#--

		def FindInCellsInColumn(pCol, pSubValue)
			return This.FindInCellsInCol(pCol, pSubValue)

		def FindAllInCellsInColumn(pCol, pSubValue)
			return This.FindInCellsInCol(pCol, pSubValue)

		def FindOccurrencesInCellsInColumn(pCol, pSubValue)
			return This.FindInCellsInCol(pCol, pSubValue)

		#>

	  #=======================================================================#
	 #  NUMBER OF OCCURRENCES OF A VALUE INSIDE THE CELLS OF A GIVEN COLUMN  #
	#=======================================================================#

	def NumberOfOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)
		aCellsPos = This.ColCellsAsPositions(pCol)
		nResult = len( This.FindInCellsCS(aCellsPos, pSubValue, pCaseSensitive) )

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInCellsInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCellsInCol(pCol, pSubValue)
		return This.NumberOfOccurrenceInCellsInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInCellsInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceInCellsInCol(pCol, pSubValue)

		def NumberOfOccurrenceInCellsInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceInCellsInCol(pCol, pSubValue)

		def NumberOfOccurrencesInCellsInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceInCellsInCol(pCol, pSubValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS -- EXTENDED  #
	#---------------------------------------------------------------------#

	def FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)
		paCellsPos = This.CellsInColAsPositions(pCol)

		aResult = This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindInCellsInColCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllInCellsInColCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllOccurrencesInCellsInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		#--

		def FindInCellsInColumnCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindInCellsInColumnXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllInCellsInColumnXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllInCellsInColumnCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColumnXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColumnXTCS(pCol, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInColumnCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllOccurrencesInCellsInColumnCSXT(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		def FindAllOccurrencesInCellsInColumnXTCS(pCol, pSubValue, pCaseSensitive)
			return This.FindInCellsInColXTCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInColXT(pCol, pSubValue)
		return This.FindInCellsInColXTCS(pCol, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllInCellsInColXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		def FindOccurrencesInCellsInColXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		def FindAllOccurrencesInCellsInColXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		#--

		def FindInCellsInColumnXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		def FindOccurrencesInCellsInColumnXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		def FindAllInCellsInColumnXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		def FindAllOccurrencesInCellsInColumnXT(pCol, pSubValue)
			return This.FindInCellsInColXT(pCol, pSubValue)

		#>

	  #------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN COLUMN  #
	#------------------------------------------------------------------------#

	def FindNthOccurrenceInCellsInColCS(n, pCol, pSubValue, pCaseSensitive)
		nResult = This.FindAllOccurrencesInCellsInColCS(paCellsPos, pSubValue, pCaseSensitive)[n]
		return nResult

		def FindNthOccurrenceInCellsInColumnCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthOccurrenceInCellsInColCS(n, pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCellsInCol(n, pCol, pSubValue)
		return This.FindNthOccurrenceInCellsInColCS(n, pCol, pSubValue, :CaseSensitive = TRUE)

		def FindNthOccurrenceInCellsInColumn(n, pCol, pSubValue)
			return This.FindNthOccurrenceInCellsInCol(n, pCol, pSubValue)

	  #--------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN COLUMN  #
	#--------------------------------------------------------------------------#

	def FindFirstOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsInColCS(1, pCol, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCellsInCol(pCol, pSubValue)
		return This.FindFirstOccurrenceInCellsInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		def FindFirstOccurrenceInCellsInColumn(pCol, pSubValue)
			return This.FindFirstOccurrenceInCellsInCol(pCol, pSubValue)

	  #--------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN COLUMN   #
	#--------------------------------------------------------------------------#

	def FindLastOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsInColCS(:Last, pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceInCellsInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastOccurrenceInCellsInColCS(pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCellsInCol(pCol, pSubValue)
		return This.FindLastOccurrenceInCellsInColCS(pCol, pSubValue, :CaseSensitive = TRUE)

		def FindLastOccurrenceInCellsInColumn(pCol, pSubValue)
			return This.FindLastOccurrenceInCellsInCol(pCol, pSubValue)

	  #======================================================================#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE THE CELLS OF A GIVEN ROW  #
	#======================================================================#

	
	def FindInCellsInRowCS(pRow, pSubValue, pCaseSensitive)
		paCellsPos = This.CellsInRowAsPositions(pRow)
		aResult = This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindAllInCellsInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowCS(pRow, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowCS(pRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInRow(pRow, pSubValue)
		return This.FindInCellsInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllInCellsInRow(pRow, pSubValue)
			return This.FindInCellsInRow(pRow, pSubValue)

		def FindOccurrencesInCellsInRow(pRow, pSubValue)
			return This.FindInCellsInRow(pRow, pSubValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS -- EXTENDED  #
	#---------------------------------------------------------------------#

	def FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)
		paCellsPos = This.CellsInRowAsPositions(pRow)

		aResult = This.FindInCellsXTCS(paCellsPos, pSubValue, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindInCellsInRowCSXT(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)

		def FindAllInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)

		def FindAllInCellsInRowCSXT(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsInRowCSXT(pRow, pSubValue, pCaseSensitive)
			return This.FindInCellsInRowXTCS(pRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInRowXT(pRow, pSubValue)
		return This.FindInCellsInRowXTCS(pRow, pSubValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllInCellsInRowXT(pRow, pSubValue)
			return This.FindInCellsInRowXT(pRow, pSubValue)

		def FindOccurrencesInCellsInRowXT(pRow, pSubValue)
			return This.FindInCellsInRowXT(pRow, pSubValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN ROW  #
	#---------------------------------------------------------------------#

	def FindNthOccurrenceInCellsInRowCS(n, pRow, pSubValue, pCaseSensitive)
		nResult = This.FindAllOccurrencesInCellsInRowCS(paCellsPos, pSubValue, pCaseSensitive)[n]
		return nResult

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCellsInRow(n, pRow, pSubValue)
		return This.FindNthOccurrenceInCellsInRowCS(n, pRow, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN ROW  #
	#-----------------------------------------------------------------------#

	def FindFirstOccurrenceInCellsInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsInRowCS(1, pRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCellsInRow(pRow, pSubValue)
		return This.FindFirstOccurrenceInCellsInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE THE CELLS OF A GIVEN ROW   #
	#-----------------------------------------------------------------------#

	def FindLastOccurrenceInCellsInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsInRowCS(:Last, pRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCellsInRow(pRow, pSubValue)
		return This.FindLastOccurrenceInCellsInRowCS(pRow, pSubValue, :CaseSensitive = TRUE)

	  #=============================================#
	 #  FINDING A VALUE INSIDE A SECTION OF CELLS  #
	#=============================================#

	def FindInCellsInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		aCellsPos = This.SectionAsPositions(paCellPos1, paCellPos2)

		aResult = This.FindInCellsCSXT(aCellsPos, pSubValue, pCaseSensitive)
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInSection(paCellPos1, paCellPos2, pSubValue)
		return This.FindInSideSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

	  #---------------------------------------------------------#
	 #  FINDING A VALUE INSIDE A SECTION OF CELLS -- EXTENDED  #
	#---------------------------------------------------------#

	// Rendering the result in a hash list
	def FindInCellsInSectionCSXT(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		aResult = This.FindInSideSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		
		for aRow in aResult
			aRow[1] = @@S( aRow[1] )
		next

		return aResult

		def FindInCellsInSectionXTCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
			return This.FindInCellsInSectionCSXT(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)

		def FindInCellsInSectionToHashListCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
			return This.FindInCellsInSectionCSXT(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsInSectionXT(paCellPos1, paCellPos2, pSubValue)
		return This.FindInCellsInSectionCSXT(paCellPos1, paCellPosr2, pSubValue, :CaseSensitive = TRUE)

		def FindInCellsInSectionToHashList(paCellPos1, paCellPos2, pSubValue)
			return This.FindInCellsInSectionXT(paCellPos1, paCellPos2, pSubValue)

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
			 isList(paColNameAndData[2]) and
			 len(paColNameAndData[2]) = This.NumberOfRows() )

			stzRaise("Incorrect column format! paColNameAndData must take the form :ColName = [ cell1, cell2, ... ]")
		ok

		This.Content() + paColNameAndData

		def AddCol(paColNameAndData)
			This.AddColumn(paColNameAndData)

	def AddColumns(paColNamesAndData) // TODO
		for paColNameAndData in paColNamesAndData
			This.AddColumn(paColNameAndData)
		next

		def AddCols(paColNamesAndData)
			This.AddColumns(paColNamesAndData)

	  #===============#
	 #  ADDING RAWS  #
	#===============#

	def AddRow(paRowContent) // TODO
		/* ... */

	def AddEmptyRow() // TODO
		/* ... */

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
	 #  REMOVING COLUMNS  #
	#====================#

	def RemoveColumn(pColNameOrNumber)
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

		for pCol in paColNamesOrNumbers
			This.RemoveCol(pCol)
		next

		def RemoveCols(pColNamesOrNumbers)
			This.RemoveColumns(pacColNames)

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

	def EraseColumn(pColNameOrNumber) // TODO
		/* ... */

		def EraseCol(pColNameOrNumber)
			This.EraseColumn(pColNameOrNumber)

	def EraseColumns(pColNamesOrNumbers) // TODO
		/* ... */

		def EraseCols(pColNamesOrNumbers)
			This.EraseColumns(pacColNames)

	  #----------------#
	 #  ERASING RAWS  #
	#----------------#

	def EraseRow(pnRow) // TODO
		/* ... */

		def EraseNthRow(pnRow)
			This.EraseRow(pnRow)

		def EraseRowN(pnRow)
			This.EraseRow(pnRow)

	def EraseRows(panRows) // TODO
		/* ... */

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

	def EraseCells(paCellsPos)
		for cell in paCellsPos
			This.EraseCell(cell[1], cell[2])
		next

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

	  #----------------------------------------------#
	 #  INSERTING MANY RAWS IN DIFFERENT POSITIONS  # // TODO
	#----------------------------------------------#

	def InsertRowsInThesePositions(panPositions, paRowsData) // TODO
		/* ... */

		def InsertRowsBeforeThesePositions(panPositions, paRowsData)
			return This.InsertRowsInThesePositions(panPositions, paRowsData)

	def InsertRowsAfterThesePositions(panPositions, paRowsData) // TODO
		/* ... */

	def InsertRowsAtThesePositions(panPositions, paRowsData) // TODO
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
	
				aResult + [ cColName, This.ColData(cColName) ]
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

	def MaxSizeInCol(pCol)
		anSizes = []

		aColData = This.ColData(pCol)
		for cell in aColData
			anSizes + @@SQ(cell).RemoveBoundsQ('"').NumberOfChars()
		next

		nResult = StzListOfNumbersQ(anSizes).Max()
		return nResult

		def SizeOfLargestCellInCol(pCol)
			return This.MaxSizeInCol(pCol)

	def MaxSizeInEachCol()
		anResult = []

		for cColName in This.ColNames()
			anResult + This.MaxSizeInCol(cColName)
		next

		return anResult

		def MaxSizeInEachColQ()
			return This.MaxSizeInEachColQR(:stzList)

		def MaxSizeInEachColQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.MaxSizeInEachCol() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.MaxSizeInEachCol() )

			other
				stzRaise("Unsupported return type!")
			off

	def MaxSizeInEachColXT()
		anResult = This.MaxSizeInEachColQ().
				InsertBeforeQ(1, len( "" + This.NumberOfRows() ) ).
				Content()

		return anResult

	def MaxSizeInRow(p)
		anSizes = []

		aRow = This.Row(p)
		for cell in aRow
			anSizes + @@SQ(cell).RemoveBoundsQ('"').NumberOfChars()
		next

		nResult = StzListOfNumbersQ(anSizes).Max()
		return nResult

		def SizeOfLargestCellInRow(pRow)
			return This.SizeOfLargestCellInRow(pRow)

	def MaxSizeInEachRow()
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
		anMax = This.MaxSizeInEachColXT()
		acStr = This.ColNamesQ().InsertBeforeQ(1, "#").Content()

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
			anMax + This.SizeOfLargestCellInCol(colName)
		next

		i = 0
		for cell in aRow
			i++
			cRow += @@SQ(cell).RemoveBoundsQ('"').AlignedToRightXT( anMax[i], " " )
			if i < len(aRow)
				cRow += "   "
			ok
		next

		return cRow

		def RowToStringQ(n)
			return new stzString( This.RowToString(n) )

	  #=======================#
	 # CONVERTING THE TABLE  #
	#=======================#

	def ToStzHashList()
		return new stzHashList( This.Table() )

