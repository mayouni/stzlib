#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLECELLACCESS          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table cell access subclass -- getting cell  #
#                  values, positions, sections, and ranges.    #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableCellAccess from stzTable

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

			if StzFind([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = 1

			but StzFind([ :Last, :LastCol, :LastColumn ], pCol) > 0
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

		nCol   = This.ColToColNumber(pCol)
		result = @aContent[nCol][2][pnRow]
		return result

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

	  #------------------------------------------#
	 #  GETTING A CELL ALONG WITH ITS POSITION  #
	#------------------------------------------#

	def CellZ(pCol, pnRow)
		nCol = This.ColToNumber(pCol)
		nRow = This.RowToNumber(pnRow)

		aResult = [ This.Cell(pCol, nRow), [ nCol, nRow ] ]

		return aResult

		def CellAndPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

		def CellAndItsPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

	  #-----------------------------#
	 #  CELL FUNTCTION - EXTENDED  #
	#-----------------------------#

	def CellCSXT(pCellCol, pCellRow, pExpr, pValueORSubValue, pCaseSensitive)
		/*
		o1 = new stzTable([
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
		nLen =  len(paCellsPos)

		for i = 1 to nLen

			aResult + This.Cell( paCellsPos[i][1], paCellsPos[i][2] )
		next

		return aResult

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

		aResult = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return aResult

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

		aResult = []
		nRows   = This.NumberOfRows()
		nCols   = This.NumberOfCol()

		for v = 1 to nRows

			for u = 1 to nCols
				aResult + [ This.Cell(u, v), [u, v ] ]
			next u

		next

		return aResult

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

	def TheseCellsZ(paCells)
		aResult = []
		nCells = len(paCells)

		for i = 1 to nCells
			aCell = paCells[i]
			aResult + [ This.Cell(aCell[1], aCell[2]), aCell ]
		next

		return aResult

		def TheseCellsAndTheirPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsAndPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsXT(paCells)
			return This.TheseCellsZ(paCells)

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

		aResult = []
		nLen = len(paCellsPos)

		for i = 1 to nLen
			cellPos = paCellsPos[i]
			aResult + [ @@(cellPos), This.Cell(cellPos[1], cellPos[2]) ]
		next

		return aResult

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

		aResult = This.SectionAsPositionsQ(panCellPos1, panCellPos2).
			       AssociatedWith( This.Section(panCellPos1, panCellPos2) )

		return aResult

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

		nCol1 = panCellPos1[1]
		nRow1 = panCellPos1[2]

		nCol2 = panCellPos2[1]
		nRow2 = panCellPos2[2]

		aResult = []

		# If only one column is concerned

		if nCol1 = nCol2
			for j = nRow1 to nRow2
				aResult + [ nCol1, j ]
			next

			return aResult
		ok

		# If the sections span mote then one column

		nRows = This.NumberOfRows()

		# Adding the first column

		for j = nRow1 to nRows
			aResult + [ nCol1, j ]
		next

		nCols = len( @aContent )
		if nCols = 1
			return
		ok

		# Adding all the cells except the first and last columns

		if nCols > 2

			for i = (nCol1 + 1) to (nCol2 - 1)
				for j = nRow1 to nRows
					aResult + [ i, j ]
				next
			next

		ok

		# Adding the remaining cells in the last column

		for j = 1 to nRow2
			aResult + [ nCol2, j ]
		next

		return aResult

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

	def ColSection(pCol, n1, n2)

		aCellsPos =  This.ColSectionAsPositions(pCol, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

		def ColumnSection(pCol, n1, n2)
			return This.ColSection(pCol, n1, n2)

	def ColSectionAsPositions(pCol, n1, n2)
		if CheckingParams()
			if isList(n1)

				if StzListIsOneOfTheseNamedParamsList(n1,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					n1 = n1[2]
				ok
			ok

			if isList(n2)
				if StzListIsOneOfTheseNamedParamsList(n2,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					n2 = n2[2]
				ok
			ok

			if isString(pCol)
				if StzFind([ :First, :FirstCol, :FirstColumn ], pCol) > 0
					pCol = 1

				but StzFind([ :Last, :LastCol, :LastColumn ], pCol) > 0
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
		ok

		aResult = []
		for i = n1 to n2
			aResult + [pCol, i]
		next

		return aResult

		#< @FunctionAlternativeForm

		def ColumnSectionAsPositions(pCol, n1, n2)
			return This.ColSectionAsPositions(pCol, n1, n2)

		def FindColSection(pCol, n1, n2)
			return This.ColSectionAsPositions(pCol, n1, n2)

		def FindColumnSection(pCol, n1, n2)
			return This.ColSectionAsPositions(pCol, n1, n2)

		def FindCellsInColSection(pCol, n1, n2)
			return This.ColSectionAsPositions(pCol, n1, n2)

		def FindCellsColumnSection(pCol, n1, n2)
			return This.ColSectionAsPositions(pCol, n1, n2)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A COL SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	def CellsInColSectionZ(nCol, n1, n2)
		anCellsPos = This.FindCellsInColSection(nCol, n1, n2)
		aCells = This.CellsAtPositions(anCellsPos)
		aResult = Association([ aCells, anCellsPos ])

		return aResult

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#====================================================#

	def RowSection(nRow, n1, n2)
		aCellsPos =  This.RowSectionAsPositions(nRow, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

		#< @FunctionAlternativeForms

		def CellsInRowSection(nRow, n1, n2)
			return This.RowSection(nRow, n1, n2)

		#>

	def RowSectionAsPositions(nRow, n1, n2)
		if CheckingParams()

			if isList(n1)
				if StzListIsOneOfTheseNamedParamsList(n1,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					n1 = n1[2]
				ok
			ok

			if isList(n2)

				if StzListIsOneOfTheseNamedParamsList(n2,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					n2 = n2[2]
				ok
			ok

			if isString(nRow)

				if StzFind([ :First, :FirstRow], nRow) > 0
					nRow = 1

				but StzFind([ :Last, :LastRow ], nRow) > 0
					nRow = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(nRow)
				StzRaise("Incorrect param type! nRow must be a number.")
			ok

			if isString(n1)
				if n1 = :First or n1 = :FirstCol
					n1 = 1
				ok
			ok

			if NOT isNumber(n1)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok

			if isString(n2)
				if n2 = :Last or n2 = :LastCol
					n2 = This.NumberOfCols()
				ok
			ok

			if NOT isNumber(n2)
				StzRaise("Incorrect param type! n2 must be a number.")
			ok
		ok

		aResult = []
		for i = n1 to n2
			aResult + [i, nRow]
		next

		return aResult

		#< @FunctionAlternativeForm

		def FindRowSection(nRow, n1, n2)
			return This.RowSectionAsPositions(nRow, n1, n2)

		def FindCellsInRowSection(nRow, n1, n2)
			return This.RowSectionAsPositions(nRow, n1, n2)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A ROW SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	def CellsInRowSectionZ(nRow, n1, n2)
		anCellsPos = This.FindCellsInRowSection(nRow, n1, n2)
		aCells = This.CellsAtPositions(anCellsPos)
		aResult = Association([ aCells, anCellsPos ])

		return aResult

	  #-------------------------------------------------#
	 #   CONVERTING A SECTION OF CELLS TO A HASHLIST   #
	#=================================================#

	def SectionToHashList(panCellPos1, panCell2)
		aResult = TheseCellsToHashList( This.SectionAsPositions(panCellPos1, panCell2) )
		return aResult

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

	def SectionToRange(n1, n2) // TODO
		StzRaise("Feature not implemented yet!")

	def Range(paPair, paRange) // TODO
		StzRaise("Feature not implemented yet!")
