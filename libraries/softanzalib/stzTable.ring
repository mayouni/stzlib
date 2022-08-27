
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

	  #----------#
	 #   CELS   #
	#----------#

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

	def Sections( panCell1, panCell2 )
		/* ... */

	def SectionsAndPositions( panCell1, panCell2 )
		/* ... */

		def SectionsXT( panCell1, panCell2 )
			/* ... */

	def PositionsAndSections( panCell1, panCell2 )
		/* ... */

	def SectionsToHashList( panCell1, panCell2 )

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

		def SectionsToHashListQ(panCell1, panCell2)
			return This.SectionsToHashListQR(panCell1, panCell2, :stzList)

		def SectionsToHashListQR(panCell1, panCell2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SectionsToHashList(panCell1, panCell2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SectionsToHashList(panCell1, panCell2) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SectionsToHashList(panCell1, panCell2) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SectionsToHashList(panCell1, panCell2) )

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

		oList   = This.SectionQ(panPair1, panPair2)

		if pCaseSensitive[1] = FALSE
			oList.Lowercased()
		ok

		aResult = oList.FindAll(pValue)

		return aResult
		

/*
		for section in aResult
			nCol1  = section[1][1]
			nLine1 = section[1][2]

			nCol2  = section[2][1]
			nLine2 = section[2][2]

			section = [
				[ nCol1 + panPair1[1], nLine1 + panPair1[2] ],
				[ nCol2 + panPair2[1], nLine2 + panPair2[2] ]
			]
		next

		return aResult
*/
	#-- WITHOUT CASESENSITIVITY

	def FindCellsInSection(panPair1, panPair2, pValue)
		return This.FindCellsInSectionCS(panPair1, panPair2, pValue, :CaseSensitive = TRUE)

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

