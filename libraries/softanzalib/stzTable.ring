

func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable
	@aTable = []

	def init(paTable)
		if len(paTable) = 2 and
		isNumber(paTable[1]) and
		isNumber(paTable[2])
			// TODO: Creating an empty table()

		but isString(paTable)
			// TODO: Extracting a table from the string

		else
			// The table is provided as a parameter
			// --> TODO: Verify of it is well formatted
			// Implement isTable() in stzList and use it here

			@aTable = paTable

			if len(@aTable) > 0
				# Transforming column names to uppercase
				for str in @aTable[1]
					str = Q(str).Uppercased()
				next
			ok
		ok

	def Content()
		return @aTable

		def Table()
			return This.Content()

	def IsEmpty()
		if len( This.Content() ) = 0
			return TRUE

		else
			return FALSE
		ok

	  #----------#
	 #  HEADER  #
	#----------#

	def Header()
		if NOT This.IsEmpty()
			return @aTable[1]
		ok
	
	  #================================================#
	 #   CHECHKING IF THE TABLE HAS GIVEN COLUMN(S)   #
	#================================================#

	def HasColumName(pcName)
		if This.IsEmpty()
			return FALSE
		ok

		cName = StzStringQ(pcName).Uppercased()
		bResult = This.ColNamesQ().Contains(cName)

		return bResult

		def HasColName(pcName)
			return This.HasColumName(pcName)

	def HasColumnsNames(pacNames)
		if This.IsEmpty()
			return FALSE
		ok

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

	  #-------------------------------#
	 #   GETTING NUMBER OF COULMNS   #
	#-------------------------------#

	def NumberOfColumns()
		nResult = 0

		if NOT This.IsEmpty()
			nResult = len(Header())
		ok

		def NumberOfCols()
			return This.NumberOfColumns()

		def NumberOfCol()
			return This.NumberOfColumns()

	  #---------------------------------#
	 #   GETTING THE LIST OF COULMNS   #
	#---------------------------------#

	def Columns()
		aResult = []

		if NOT This.IsEmpty()
			bResult =  This.Header()
		ok

		return bResult

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

		#>

	  #----------------------#
	 #   READING A COLUMN   #
	#----------------------#

	def Col(p)
		if isNumber(p)
			return This.NthCol(p)

		but isString(p)
			n = This.FindCol(p)
			return This.NthColData(n)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

		def Column(p)
			return This.Col(p)

	def NthCol(n)
		aResult = []

		for aRow in This.Table()
			aResult + aRow[n]
		next

		return aResult

	def NthColName(n)
		cResult = This.ColNames()[n]
		return cResult

	def NthColData(n)
		if This.IsEmpty()
			return []
		ok

		aResult = StzListQ( This.NthCol(n) ).Section(2, :LastItem)
		return aResult

	def ColData(p)
		if isNumber(p)
			return This.NthColData(p)

		but isString(p)
			n = This.FindCol(p)
			return This.NthColData(n)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

	def ColName(n)
		if n = 0
			return "#"

		else
			return This.ColNames()[n]
		ok

		def ColumnName(n)
			return This.ColName(n)

	  #================================#
	 #   GETTING THE NUMBER OF ROWS   #
	#================================#

	def NumberOfRows()
		return len(@aTable) - 1

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

	def Rows()
		return Q( This.Content() ).Section(2, :LastItem)

	  #-------------------------#
	 #   GETTING THE NTH ROW   #
	#-------------------------#

	def RowN(n)
		if n = 0
			return Header()
		else
			return This.Table()[ n + 1 ]
		ok
			
		def NthRow(n)
			return This.Row(n)

	  #--------------------------------------#
	 #   GETTING ROW BY NUMBER OR BY NAME   #
	#--------------------------------------#

	def Row(p)
		if isNumber(p)
			return This.RowN(p)

		but isList(p)
			return This.FindRow(p)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

	  #-------------------------------#
	 #  GETIING THE NUMBER OF CELLS  #
	#-------------------------------#

	def NumberOfCells()
		nResult = This.NumberOfCol() * This.NumberOfRows()
		return nResult

	  #---------------------------------------------------------------------------#
	 #  GETIING A CELL USING THE NUMBER OF ITS COLUMN AND THE NUMBER OF ITS ROW  #
	#---------------------------------------------------------------------------#

	def Cell(pCol, nRow)

		if type(pCol) = "NUMBER"
			return This.Row(nRow)[ pCol ]

		but type(pCol) = "STRING"
			return This.Row(nRow)[ This.FindCol(pCol) ]
		ok

		def CellQ(pCol, nRow)
			return Q( This.Cell(pCol, nRow) )
	
	  #---------------------------------#
	 #  GETIING THE LIST OF ALL CELLS  #
	#---------------------------------#

	def Cells()
		aResult = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return aResult

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
		aResult = This.SectionToHashListQR( panCellPos1, panCellPos2, :stzHashList ).Values()
		return aResult

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
		
	def SectionXT( panCellPos1, panCellPos2 )
		aResult = This.SectionToHashListQR( panCellPos1, panCellPos2, :stzHashList ).
				PerformOnKeysQ(' @key = Q(@key).ToList() ').Content()

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

	def SectionToHashList( panCellPos1, panCellPos2 )
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

		for v = nRow1 to This.NumberOfRows()
			for u = nCol1 to This.NumberOfCols()
				aResult + [ @@S([u, v]), This.Cell(u, v) ]
			next u
		next

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
		
	def SectionAsPositions( panCellPos1, panCellPos2 )
		aResult = StzGridQ( This.SectionXT(panCellPos1, panCellPos2) ).VLine(1)
		return aResult

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
		pcColName = Q(pcColName).Uppercased()
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

	  #=========================================================#
	 #  FINDING THE NTH OCCURRENCE OF A CELL INSIDE THE TABLE  #
	#=========================================================#

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

	  #================================#
	 #  FINDING CELLS IN A GIVEN RAW  #
	#================================#

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

	def FindCellsInColCS(n, pCellValue, pCaseSensitive)

		if isString(n)
			n = This.FindCol(n)
		ok

		aResult = []

		i = 0
		for cell in This.Col(n)
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

		def FindCellsInNthColCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pCellValue, pCaseSensitive)

		def FindCellsInColNCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pCellValue, pCaseSensitive)

		def FindInColCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pCellValue, pCaseSensitive)

		def FindInNthColCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pCellValue, pCaseSensitive)

		def FindInColNCS(n, pCellValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindCellsInCol(n, pCellValue)
		return This.FindCellsInColCS(n, pCellValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindCellsInNthCol(n, pCellValue)
			return This.FindCellsInCol(n, pCellValue)

		def FindCellsInColNC(n, pCellValue)
			return This.FindCellsInCol(n, pCellValue)

		def FindInCol(n, pCellValue)
			return This.FindCellsInCol(n, pCellValue)

		def FindInNthCol(n, pCellValue)
			return This.FindCellsInCol(n, pCellValue)

		def FindInColN(n, pCellValue)
			return This.FindCellsInCol(n, pCellValue)

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

	  #==================================================#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE A CELL   #
	#==================================================#

	def NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCell(pnCol, pnRow, pSubValue)
		return This.NumberOfOccurrenceInCellCS(pnCol, pnRow, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCell(pnCol, pnRow, pSubValue)
			return This.NumberOfOccurrenceInCell(pnCol, pnRow, pSubValue)

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

	  #======================================================#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE MANY CELLS   #
	#======================================================#

	def NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellsCS(paCellsPos, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCells(paCellsPos, pSubValue)
		return This.NumberOfOccurrenceInCellsCS(paCellsPos, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCells(paCellsPos, pSubValue)
			return This.NumberOfOccurrenceInCells(paCellsPos, pSubValue)

	  #=========================================================#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS  #
	#=========================================================#

	def FindInCellsCS(paCellsPos, pSubValue, pCaseSensitive)

		if NOT ( isList(paCellsPos) and Q(paCellsPos).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		aResult = []

		for cellPos in paCellsPos
			aResult + This.FindInCellCS(cellPos[1], cellPos[2], pSubValue, pCaseSensitive)
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

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#========================================================#

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

	def FindFirstOccurrenceInCellsCS(ppaCellsPos, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsCS(:First, paCellsPos, pSubValue, pCaseSensitive)

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

	  #=============================================#
	 #  CHECKING IF A CELL CONTAINS A GIVEN VALUE  #
	#=============================================#

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

	  #================================================#
	 #  CHECKING IF SOME CELLS CONTAINS A GIVEN CELL  #
	#================================================#

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

	  #-----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A GIVEN SECTION  #
	#-----------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive)
		nResult = len( This.FindInSectionCS(paCellPos1, paCellPos2, pSubValue, pCaseSensitive) )
		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInSection(paCellPos1, paCellPos2, pSubValue)
		return This.NumberOfOccurrenceInSectionCS(paCellPos1, paCellPos2, pSubValue, :CS = TRUE)

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

	  #---------------------------------------------#
	 #  FINDING A VALUE INSIDE A SECTION OF CELLS  #
	#---------------------------------------------#

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

	// Rendee=ring the result in a hash list
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

	def ReplaceCell(pnCol, pnRow, pNewValue)
		This.Row(pnRow)[pnCol] = pNewValue

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

	def AddColumn(pcColName, paColData) // TODO
		/* ... */
		This.Columns() + pcColName

		v = 0
		for u = 2 to len( @aTable )
			v++
			@aTable[u] + paColData[v]
		next

		def AddCol(pcColName, paCOlData)
			This.AddColumn(pcColName, paCOlData)

	def AddColumns(paColumns) // TODO
		/* ... */

		def AddCols(paColumns)
			This.AddColumns(paColumns)


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

	  #====================#
	 #  REMOVING COLUMNS  #
	#====================#

	def RemoveColumn(pColNameOrNumber) // TODO
		/* ... */

		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	def RemoveColumns(pColNamesOrNumbers) // TODO
		/* ... */

		def RemoveCols(pColNamesOrNumbers)
			This.EraseColumns(pacColNames)

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

	def Erase() // TODO
		/* ... */

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

	def EraseCell(pnCol, pnRow) // TODO
		/* ... */

	def EraseCells(panCellsPos) // TODO
		/* ... */

	def EraseSection(paCellPos1, paCellPos2) // TODO
		/* ... */

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
		if NOT This.HasColNames(pacColNames)
			stzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok

		oTable = new stzTable([])
		oTable.AddColumns(pacColNames)

		aResult = oTable.Content()
		return aResult

		def SubTableQ(pacColNames)
			return This.SubTableQR(pacColNames, :stzList)

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
		cTable = This.HeaderToString() + NL + NL + This.RowsToString()
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
