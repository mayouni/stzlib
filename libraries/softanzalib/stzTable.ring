
func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable
	aTable = []

	def init(paTable)
		if len(paTable) = 2 and
		isInteger(paTable[1]) and
		isInteger(paTable[2])
			// TODO: Creating an empty table()

		but isString(paTable)
			// TODO: Extracting a table from the string

		else
			// The table is provided as a parameter
			// --> TODO: Verify of it is well formatted
			// Implement isTable() in stzList and use it here

			aTable = paTable

			# Transforming column names to uppercase
			for str in aTable[1]
				str = Q(str).Uppercased()
			next
		ok

	def Content()
		return aTable

		def Table()
			return This.Content()

	  #----------#
	 #  HEADER  #
	#----------#

	def Header()
		return aTable[1]
	
	  #-------------#
	 #   COLUMNS   #
	#-------------#

	def NumberOfColumns()
		return len(Header())

		def NumberOfCols()
			return This.NumberOfColumns()

		def NumberOfCol()
			return This.NumberOfColumns()

	def Columns()
		return This.Header()

		def Cols()
			return This.Header()

	#--

	def ColNXT(n)
		aResult = []

		for aLine in This.Table()
			aResult + aLine[n]
		next

		return aResult

		def ColumnNXT(n)
			return This.ColNXT(n)

		def NthColXT(n)
			return This.ColNXT(n)

		def NthColumnXT(n)
			return This.ColNXT(n)

	def ColXT(p)
		if isNumber(p)
			return This.ColNXT(p)

		but isString(p)
			p = Q(p).Uppercased()
			n = This.FindCol(p)
			return This.ColNXT(n)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

		def ColumnXT(p)
			return This.ColXT(p)
			
	#--

	def ColN(n)
		aResult = StzListQ( This.ColNXT(n) ).Section(2, :LastItem)
		return aResult

		def ColumnN(n)
			return This.ColN(n)

		def NthCol(n)
			return This.ColN(n)

		def NthColumn(n)
			return This.ColN(n)

	def Col(p)
		if isNumber(p)
			return This.ColN(p)

		but isString(p)
			p = Q(p).Uppercased()
			n = This.FindCol(p)
			return This.ColN(n)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

		def Column(p)
			return This.Col(p)

	  #-----------#
	 #   LINES   #
	#-----------#

	def NumberOfLines()
		return len(aTable)-1

	def Lines()
		return Q( This.Content() ).Section(2, :LastItem)

	def LineN(n)
		if n = 0
			return Header()
		else
			return This.Table()[n+1]
		ok
			
		def NthLine(n)
			return This.Line(n)

	def Line(p)
		if isNumber(p)
			return This.LineN(p)

		but isList(p)
			return This.FindLine(p)

		else
			stzRaise("Incorrect param type! p must be a number or string.")
		ok

	  #---------#
	 #  CELLS  #
	#---------#

	def NumberOfCells()
		nResult = This.NumberOfCol() * This.NumberOfLines()
		return nResult

	def Cell(pCol, nLine)

		if type(pCol) = "NUMBER"
			return This.Line(nLine)[pCol]

		but type(pCol) = "STRING"
			return This.Line(nLine)[ This.FindCol(pCol) ]
		ok

		def CellQ(pCol, nLine)
			return Q( This.Cell(pCol, nLine) )
	
	def Cells()
		aResult = This.Section( [ :FirstCol, :FirstLine ], [ :LastCol, :LastLine ] )
		return aResult

	def CellsAndTheirPositions()
		aResult = []

		for v = 1 to This.NumberOfLines()
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

		for v = 1 to This.NumberOfLines()
			for u = 1 to This.NumberOfCol()
				aResult + [ [u, v ], This.Cell(u, v) ]
			next
		next

		return aResult

	def CellsToHashList()
		aResult = []

		for v = 1 to This.NumberOfLines()
			for u = 1 to This.NumberOfCol()
				aResult + [ @@S([u, v ]), This.Cell(u, v) ]
			next
		next

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

	  #==============================#
	 #  GETTING A SECTION OF CELLS  #
	#==============================#

	def SectionAsPositions( panCell1, panCell2 )
		aResult = StzGridQ( This.SectionXT(panCell1, panCell2) ).VLine(1)
		return aResult

	def Section( panCell1, panCell2 )
		aResult = This.SectionToHashListQR( panCell1, panCell2, :stzHashList ).Values()
		return aResult

		def SectionQ( panCell1, panCell2 )
			return This.SectionQR( panCell1, panCell2, :stzList )

		def SectionQR( panCell1, panCell2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.Section( panCell1, panCell2 ) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Section( panCell1, panCell2 ) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Section( panCell1, panCell2 ) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Section( panCell1, panCell2 ) )

			other
				stzRaise("Unsupported return type!")
			off
		
	def SectionXT( panCell1, panCell2 )
		aResult = This.SectionToHashListQR( panCell1, panCell2, :stzHashList ).
				PerformOnKeysQ(' @key = Q(@key).ToList() ').Content()

		return aResult

		def SectionXTQ( panCell1, panCell2 )
			return This.SectionXTQR( panCell1, panCell2, :stzList )

		def SectionXTQR( panCell1, panCell2, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionXT( panCell1, panCell2 ) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionXT( panCell1, panCell2 ) )

			other
				stzRaise("Unsupported return type!")
			off

	def SectionToHashList( panCell1, panCell2 )
		if isList(panCell1)
			if isString(panCell1[1]) and panCell1[1] = :FirstCol
				panCell1 = Q(panCell1).FirstItemReplaced( :With = 1)
			ok

			if isString(panCell1[2]) and panCell1[2] = :FirstLine
				panCell1 = Q(panCell1).NthItemReplaced( 2, :With = 1)
			ok

			if isString(panCell2[1]) and panCell2[1] = :LastCol
				panCell2 = Q(panCell2).FirstItemReplaced( :With = This.NumberOfCol() )
			ok

			if isString(panCell2[2]) and panCell2[2] = :LastLine
				panCell2 = Q(panCell2).NthItemReplaced( 2, :With = This.NumberOfLines() )
			ok
		ok

		if isList(panCell2)
			if isString(panCell2[1]) and panCell2[1] = :LastCol
				panCell2[1] = This.NumberOfCol()
			ok

			if isString(panCell2[2]) and panCell2[2] = :LastLine
				panCell2[2] = This.NumberOfLines()
			ok

		ok

		if NOT ( isList(panCell1) and Q(panCell1).IsPairOfNumbers() and
			 isList(panCell2) and Q(panCell2).IsPairOfNumbers() )

			stzRaise("Incorrect params types! panCell1 and panCell2 must be pairs of numbers.")
		ok

		anPairs = Q([ panCell1, panCell2 ]).SortedInAscending()
		nCol1   = anPairs[1][1]
		nLine1  = anPairs[1][2]
		nCol2   = anPairs[2][1]
		nLine2  = anPairs[2][2]

		aResult = []

		for v = nLine1 to This.NumberOfLines()
			for u = nCol1 to This.NumberOfCols()
				aResult + [ @@S([u, v]), This.Cell(u, v) ]
			next u
		next

		return aResult

		def SectionToHashListQ(panCell1, panCell2)
			return This.SectionsToHashListQR(panCell1, panCell2, :stzList)

		def SectionToHashListQR(panCell1, panCell2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionToHashList(panCell1, panCell2) )

			on :stzHashList
				return new stzHashList( This.SectionToHashList(panCell1, panCell2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SectionToHashList(panCell1, panCell2) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SectionToHashList(panCell1, panCell2) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionToHashList(panCell1, panCell2) )

			other
				stzRaise("Unsupported return type!")
			off
		
	  #----------------------------#
	 #  GETTING A RANGE OF CELLS  #
	#----------------------------#

	# TODO

	  #================================#
	 #  FINDING A COLUMN BY ITS NAME  #
	#================================#

	def FindCol(pcColName)
		pcColName = Q(pcColName).Uppercased()
		n = find( This.Header(), pcColName)
		return n

		def FindColumn(pcColName)
			return This.FindCol(pcColName)

	  #--------------------------------#
	 #  FINDING A LINE BY ITS VALUE  #
	#-------------------------------#

	def FindLine(paLine)
		n = Q(This.Lines()).FindAll(paLine)

		if len(n) = 0
			n = 0

		but len(n) = 1
			n = n[1]
		ok

		return n

	  #-----------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------#

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

	  #--------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A GIVEN LINE  #
	#--------------------------------------------------#

	def NumberOfOccurrenceInLineCS(n, pCellValue, pCaseSensitive)
		if isList(pCellValue) and Q(pCellValue).IsOfNamedParam()
			pCellValue = pCellValue[2]
		ok

		nResult = len( This.FindCellsInLineCS(n, pCellValue, pCaseSensitive) )
		return nResult

		def NumberOfOccurrencesInLineCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInLineCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfCellInLineCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInLineCS(n, pCellValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInLineCS(n, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceInLineCS(n, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInLine(n, pCellValue)
		return This.NumberOfOccurrenceInLineCS(n, pCellValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInLine(n, pCellValue)
			return This.NumberOfOccurrenceInLine(n, pCellValue)

		def NumberOfOccurrenceOfCellInLine(n, pCellValue)
			return This.NumberOfOccurrenceInLine(n, pCellValue)

		def NumberOfOccurrencesOfCellInLine(n, pCellValue)
			return This.NumberOfOccurrenceInLine(n, pCellValue)

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

		return aResult

	def FindCells(pValue)
		return This.FindCellsCS(pValue, :CaseSensitive = TRUE)

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

	  #=================================#
	 #  FINDING CELLS IN A GIVEN LINE  #
	#=================================#

	def FindCellsInLineCS(n, pValue, pCaseSensitive)

		if isString(n)
			n = This.FindLine(n)
		ok

		aResult = []

		i = 0
		for cell in This.Line(n)
			i++

			if isString(cell) or
			   (isList(cell) and Q(cell).IsListOfStrings())

				if isString(pValue)
					if Q(cell).IsEqualToCS(pValue, pCaseSensitive)
						aResult + [n, i]
					ok
				ok

			else
				if Q(cell).IsEqualTo(pValue)
					aResult + [n, i]
				ok
			ok
		next

		return aResult

		def FindInLineCS(n, pValue, pCaseSensitive)
			return This.FindCellsInLineCS(n, pValue, pCaseSensitive)

	def FindCellsInLine(n, pValue)
		return This.FindInLineCS(n, pValue, :CaseSensitive = TRUE)

		def FindInLine(n, pValue)
			return This.FindCellsInLine(n, pValue)

	  #-----------------------------------#
	 #  FINDING CELLS IN A GIVEN COLUMN  #
	#-----------------------------------#

	def FindCellsInColCS(n, pValue, pCaseSensitive)

		if isString(n)
			n = This.FindCol(n)
		ok

		aResult = []

		i = 0
		for cell in This.Col(n)
			i++

			if isString(cell) or
			   (isList(cell) and Q(cell).IsListOfStrings())

				if isString(pValue)
					if Q(cell).IsEqualToCS(pValue, pCaseSensitive)
						aResult + [n, i]
					ok
				ok

			else
				if Q(cell).IsEqualTo(pValue)
					aResult + [n, i]
				ok
			ok
		next

		return aResult

		def FindInColCS(n, pValue, pCaseSensitive)
			return This.FindCellsInColCS(n, pValue, pCaseSensitive)

	def FindCellsInCol(n, pValue)
		return This.FindCellsInColCS(n, pValue, :CaseSensitive = TRUE)

		def FindInCol(n, pValue)
			return This.FindCellsInCol(n, pValue)

	  #----------------------------------------#
	 #  FINDING A CELL IN A SECTION OF CELLS  #
	#----------------------------------------#

	def FindCellsInSectionCS(panPair1, panPair2, pValue, pCaseSensitive)

		aCellsXT = This.SectionXT(panPair1, panPair2)

		bCaseSensitive = pCaseSensitive[2]

		if isString(pValue) and bCaseSensitive = TRUE
			pValue = Q(pValue).Lowercased()
		ok

		aResult = []

		for cellxt in aCellsXT
			aCellPosition = cellxt[1]
			cellValue = cellxt[2]

			if bCaseSensitive and isString(cellValue)
				cellValue = Q(cellValue).Lowercased()
			ok
				
			if Q(cellValue).IsEqualTo(pValue)
				aResult + aCellPosition
			ok
		next

		return aResult
		

		def FindInSectionCS(panPair1, panPair2, pValue, pCaseSensitive)
			return This.FindCellsInSectionCS(panPair1, panPair2, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCellsInSection(panPair1, panPair2, pValue)
		return This.FindCellsInSectionCS(panPair1, panPair2, pValue, :CaseSensitive = TRUE)

		def FindInSection(panPair1, panPair2, pValue)
			return This.FindCellsInSection(panPair1, panPair2, pValue)

	  #=======================================================#
	 #  CHECKING IF SOME CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#=======================================================#

	def CellsContainCS(paCells, pSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		
		for cell in paCells
			if This.CellContainsCS(cell[1], cell[2], pSubValue, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def CellsContain(paCells, pSubValue)
		return This.CellsContainCS(paCells, pSubValue, :CaseSensitive = TRUE)

	  #------------------------------------------------------#
	 #  CHECKING IF ALL CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#------------------------------------------------------#

	def AllCellsContainCS(paCells, pSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = TRUE
		
		for cell in paCells
			if NOT This.CellContainsCS(cell[1], cell[2], pSubValue, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def EachCellContainsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def AllCellsContain(paCells, pSubValue)
		return This.AllCellsContainsCS(paCells, pSubValue, :CaseSensitive = TRUE)

		def EachCellContains(paCells, pSubValue)
			return This.AllCellsContain(paCells, pSubValue)

	  #-----------------------------------------------------#
	 #  CHECKING IF NO CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#-----------------------------------------------------#

	def NoCellsContainCS(paCells, pSubValue, pCaseSensitive)
		return NOT This.AllCellsContainCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NoCellsContain(paCells, pSubValue)
		return This.NoCellsContainCS(paCells, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------#
	 #  CHECKING IF N OF THE GIVEN CELLS CONTAIN A GIVEN VALUE INSIDE  #
	#-----------------------------------------------------------------#

	def NCellsContainCS(n, paCells, pSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		i = 0

		for cell in paCells
			if This.CellContainsCS(cell[1], cell[2], pSubValue, pCaseSensitive)
				i++
				if i = n
					bResult = TRUE
					exit
				ok
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def NCellsContain(paCells, pSubValue)
		return This.NCellsContainCS(paCells, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------#
	 #  CHECKING IF CELLS CONTAIN N OCCUURENCES OF GIVEN VALUE INSIDE  #
	#-----------------------------------------------------------------#

	def CellsContainNOccurrenceCS(n, paCells, pSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPAirsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		bResult = FALSE
		i = 0

		for cell in paCells
			i += This.NumberOfOccurrenceCS(cell[1], cell[2], pSubValue, pCaseSensitive)
			if i = n
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def CellsContainNOccurrencesCS(n, paCells, pSubValue, pCaseSensitive)
			return This.CellsContainNOccurrenceCS(n, paCells, pSubValue, pCaseSensitive)

	def CellsContainNOccurrence(n, paCells, pSubValue)
		return This.CellsContainNOccurrenceCS(n, paCells, pSubValue, :CaseSensitive = TRUE)

		def CellsContainNOccurrences(n, paCells, pSubValue)
			return This.CellsContainNOccurrence(n, paCells, pSubValue)

	  #==================================================#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE A CELL   #
	#==================================================#

	def NumberOfOccurrenceInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCell(pnCol, pnLine, pSubValue)
		return This.NumberOfOccurrenceInCellCS(pnCol, pnLine, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCell(pnCol, pnLine, pSubValue)
			return This.NumberOfOccurrenceInCell(pnCol, pnLine, pSubValue)

	  #----------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE A CELL  #
	#----------------------------------------------------#

	def FindInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
		if isList(pSubValue) and Q(pSubValue).IsOfNamedParam()
			pSubValue = pSubValue[2]
		ok

		cell = This.Cell(pnCol, pnLine)

		aResult = []

		if isString(cell) or ( isList(cell) and Q(cell).IsListOfString())
			aResult = Q(cell).FindAllCS(pSubValue, pCaseSensitive)

		else
			aResult = Q(cell).FindAll(pSubValue)
		ok

		return aResult

		def FindAllOccurrencesInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
			return This.FindInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
	
	#-- WITHOUT CASESENSITIVITY

	def FindInCell(pnCol, pnLine, pSubValue)
		return This.FindInCellCS(pnCol, pnLine, pSubValue, :CaseSensitive = TRUE)

		def FindAllOccurrencesInCell(pnCol, pnLine, pSubValue)
			return This.FindInCell(pnCol, pnLine, pSubValue)

	  #---------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE A CELL  #
	#---------------------------------------------------#

	def FindNthOccurrenceInCellCS(n, pnCol, pnLine, pSubValue, pCaseSensitive)
		if isString(n)
			if n = :First
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
			ok
		ok

		nResult = This.FindAllOccurrencesInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)[n]

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCell(n, pnCol, pnLine, pSubValue)
		return This.FindNthOccurrenceInCellCS(n, pnCol, pnLine, pSubValue, :CaseSensitive = TRUE)

	  #-----------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE A CELL  #
	#-----------------------------------------------------#

	def FindFirstOccurrenceInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellCS(:First, pnCol, pnLine, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCell(pnCol, pnLine, pSubValue)
		return This.FindFirstOccurrenceInCellCS(pnCol, pnLine, pSubValue, :CaseSensitive = TRUE)

	  #----------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE A CELL  #
	#----------------------------------------------------#

	def FindLastOccurrenceInCellCS(pnCol, pnLine, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellCS(:Last, pnCol, pnLine, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCell(pnCol, pnLine, pSubValue)
		return This.FindLastOccurrenceInCellCS(pnCol, pnLine, pSubValue, :CaseSensitive = TRUE)

	  #======================================================#
	 #  NUMBER OF OCCURRENCE OF A VALUE INSIDE MANY CELLS   #
	#======================================================#

	def NumberOfOccurrenceInCellsCS(paCells, pSubValue, pCaseSensitive)
		nResult = len( This.FindInCellsCS(paCells, pSubValue, pCaseSensitive) )

		def NumberOfOccurrencesInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCells(paCells, pSubValue)
		return This.NumberOfOccurrenceInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

		def NumberOfOccurrencesInCells(paCells, pSubValue)
			return This.NumberOfOccurrenceInCells(paCells, pSubValue)

	  #=========================================================#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS  #
	#=========================================================#

	def FindInCellsCS(paCells, pSubValue, pCaseSensitive)

		if NOT ( isList(paCells) and Q(paCells).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		aResult = []

		for cell in paCells
			aResult + This.FindInCellCS(cell[1], cell[2], pSubValue, pCaseSensitive)
		next

		return aResult

		def FindAllInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindInCellsCS(paCells, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindInCellsCS(paCells, pSubValue, pCaseSensitive)
	
	#-- WITHOUT CASESENSITIVITY

	def FindInCells(paCells, pSubValue)
		return This.FindInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

		def FindAllInCells(paCells, pSubValue)
			return This.FindInCell(paCells, pSubValue)

		def FindOccurrencesInCells(paCells, pSubValue)
			return This.FindInCell(paCells, pSubValue)

	  #---------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A VALUE INSIDE GIVEN CELLS -- EXTENDED  #
	#---------------------------------------------------------------------#

	def FindInCellsXTCS(paCells, pSubValue, pCaseSensitive)
		
		if NOT ( isList(paCells) and Q(paCells).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! paCells must be a list of pairs of numbers.")
		ok

		aResult = []

		aPairs  = This.FindInCellCS(paCells, pSubValue, pCaseSensitive)

		for i = 1 to len(paCells)
			aResult + [ paCells[i], aPairs[i] ]
		next

		return aResult

		def FindAllInCellsXTCS(paCells, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCells, pSubValue, pCaseSensitive)

		def FindOccurrencesInCellsXTCS(paCells, pSubValue, pCaseSensitive)
			return This.FindInCellsXTCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCellsXT(paCells, pSubValue)
		return This.FindInCellsXTCS(paCells, pSubValue, :CaseSensitive = TRUE)

		def FindAllInCellsXT(paCells, pSubValue)
			return This.FindInCellsXT(paCells, pSubValue)

		def FindOccurrencesInCellsXT(paCells, pSubValue)
			return This.FindInCellsXT(paCells, pSubValue)

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#========================================================#

	def FindNthOccurrenceInCellsCS(n, paCells, pSubValue, pCaseSensitive)
		if isString(n)
			if n = :First
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceInCellsCS(paCells, pSubValue, pCaseSensitive)
			ok
		ok

		nResult = This.FindAllOccurrencesInCellsCS(paCells, pSubValue, pCaseSensitive)[n]

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceInCells(n, paCells, pSubValue)
		return This.FindNthOccurrenceInCellsCS(n, paCells, pSubValue, :CaseSensitive = TRUE)

	  #----------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#----------------------------------------------------------#

	def FindFirstOccurrenceInCellsCS(pnCol, pnLine, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsCS(:First, paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceInCells(paCells, pSubValue)
		return This.FindFirstOccurrenceInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

	  #---------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A VALUE INSIDE GIVEN CELLS  #
	#---------------------------------------------------------#

	def FindLastOccurrenceInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthOccurrenceInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceInCells(paCells, pSubValue)
		return This.FindLastOccurrenceInCellsCS(paCells, pSubValue, :CaseSensitive = TRUE)

	  #=====================#
	 #  SHOWING THE TABLE  #
	#=====================#
	/* 
	TODO: Enhance it using the StzString.ExtendToNChars() function.
	*/

	def Show()
		? This.ToString()

	def ToString()
		cTable = "#" + TAB + This.HeaderToString() + NL + This.LinesToString()
		return cTable

	def HeaderToString()
		return This.LineToString(0)
		
	def LinesToString()
		cLines = ""

		for y = 1 to NumberOfLines()
			cLines += ""+ y + TAB + LineToString(y) + NL
		next

		return cLines
	
	def LineToString(n)
		cLine = ""
		aLine = line(n)
	
		for x = 1 to len(aLine)
			if isList(aLine[x])
				cLine += @@S(aLine[x])
			else
				cLine += aLine[x]
			ok

			if x < This.NumberOfCols()
				cLine += TAB
			ok
		next x
		return cLine

		def LineToStringQ(n)
			return new stzString( This.LineToString(n) )

