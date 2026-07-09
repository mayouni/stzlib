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
		_nResult_ = This.NumberOfCol() * This.NumberOfRows()
		return _nResult_

	  #-------------------------------------------------------------------#
	 #  GETIING A CELL VALUE BY ITS POSITION (COLUMN, ROW) IN THE TABLE  #
	#-------------------------------------------------------------------#

	def Cell(pCol, pnRow)

		if isString(pCol)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], pCol) > 0
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

		_nCol_   = This.ColToColNumber(pCol)
		_result_ = @aContent[_nCol_][2][pnRow]
		return _result_

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
		_nCol_ = This.ColToNumber(pCol)
		_nRow_ = This.RowToNumber(pnRow)

		_aResult_ = [ This.Cell(pCol, _nRow_), [ _nCol_, _nRow_ ] ]

		return _aResult_

		def CellAndPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

		def CellAndItsPosition(pCol, pRow)
			return This.CellZ(pCol, pnRow)

	  #-----------------------------#
	 #  CELL FUNTCTION - EXTENDED  #
	#-----------------------------#

	def CellCSXT(pCellCol, pCellRow, pExpr, pValueORSubValue, pCaseSensitive)
		/*
		_o1_ = new stzTable([
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
		_o1_ = new stzTable([
			[ :NATION,	:LANGUAGE ],
			[ "___",	"Arabic"  ],
			[ "France",	"___"  ],
			[ "USA",	"___" ]
		])

		_aSomeCells_ = [ [1, 1], [2, 2], [2, 3] ]

		? _o1_.TheseCells(_aSomeCells_)
		#--> [ "___", "___", "___" ]
		*/

		_aResult_ = []
		_nLen_ =  len(paCellsPos)

		for i = 1 to _nLen_

			_aResult_ + This.Cell( paCellsPos[i][1], paCellsPos[i][2] )
		next

		return _aResult_

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

		_aResult_ = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return _aResult_

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

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_

			for u = 1 to _nCols_
				_aResult_ + [ This.Cell(u, v), [u, v ] ]
			next u

		next

		return _aResult_

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

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_
			for u = 1 to _nCols_
				_aResult_ + [ [u, v ], This.Cell(u, v) ]
			next
		next

		return _aResult_

	def CellsAsPositions()

		_aResult_ = []
		_nRows_   = This.NumberOfRows()
		_nCols_   = This.NumberOfCol()

		for v = 1 to _nRows_
			for u = 1 to _nCols_
				_aResult_ + [u, v ]
			next
		next

		return _aResult_

		def AllCellsAsPositions()
			return This.CellsAsPositions()

	  #-----------------------------------------------------------#
	 #  GETIING THE LIST OF THE GIVEN CELLS AND THEIR POSITIONS  #
	#-----------------------------------------------------------#

	def TheseCellsZ(paCells)
		_aResult_ = []
		_nCells_ = len(paCells)

		for i = 1 to _nCells_
			_aCell_ = paCells[i]
			_aResult_ + [ This.Cell(_aCell_[1], _aCell_[2]), _aCell_ ]
		next

		return _aResult_

		def TheseCellsAndTheirPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsAndPositions(paCells)
			return This.TheseCellsZ(paCells)

		def TheseCellsXT(paCells)
			return This.TheseCellsZ(paCells)

	def PositionsAndTheseCells(paCells)
		_aResult_ = []
		_nCells_ = len(paCells)

		for i = 1 to _nCells_
			_aCell_ = paCells[i]
			_aResult_ + [ _aCell_, This.Cell(paCells[1], paCells[2]) ]
		next

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETIING THE LIST OF ALL CELLS BY TRANSFORMING IT TO A HASHLIST  #
	#------------------------------------------------------------------#

	def CellsToHashList()
		_aResult_ = This.TheseCellsToHashList( This.CellsAsPositions() )
		return _aResult_

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

		_aResult_ = []
		_nLen_ = len(paCellsPos)

		for i = 1 to _nLen_
			_cellPos_ = paCellsPos[i]
			_aResult_ + [ @@(_cellPos_), This.Cell(_cellPos_[1], _cellPos_[2]) ]
		next

		return _aResult_

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
		_aCells_ = This.SectionAsPositions( panCellPos1, panCellPos2 )
		_nCells_ = len(_aCells_)
		_aResult_ = []

		for i = 1 to _nCells_
			_aCell_ = _aCells_[i]
			_aResult_ + This.Cell(_aCell_[1], _aCell_[2])
		next

		return _aResult_

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

		_aResult_ = This.SectionAsPositionsQ(panCellPos1, panCellPos2).
			       AssociatedWith( This.Section(panCellPos1, panCellPos2) )

		return _aResult_

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

		_nCol1_ = panCellPos1[1]
		_nRow1_ = panCellPos1[2]

		_nCol2_ = panCellPos2[1]
		_nRow2_ = panCellPos2[2]

		_aResult_ = []

		# If only one column is concerned

		if _nCol1_ = _nCol2_
			for j = _nRow1_ to _nRow2_
				_aResult_ + [ _nCol1_, j ]
			next

			return _aResult_
		ok

		# If the sections span mote then one column

		_nRows_ = This.NumberOfRows()

		# Adding the first column

		for j = _nRow1_ to _nRows_
			_aResult_ + [ _nCol1_, j ]
		next

		_nCols_ = len( @aContent )
		if _nCols_ = 1
			return
		ok

		# Adding all the cells except the first and last columns

		if _nCols_ > 2

			for i = (_nCol1_ + 1) to (_nCol2_ - 1)
				for j = _nRow1_ to _nRows_
					_aResult_ + [ i, j ]
				next
			next

		ok

		# Adding the remaining cells in the last column

		for j = 1 to _nRow2_
			_aResult_ + [ _nCol2_, j ]
		next

		return _aResult_

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

	def ColSection(pCol, _n1_, _n2_)

		_aCellsPos_ =  This.ColSectionAsPositions(pCol, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		def ColumnSection(pCol, _n1_, _n2_)
			return This.ColSection(pCol, _n1_, _n2_)

	def ColSectionAsPositions(pCol, _n1_, _n2_)
		if CheckingParams()
			if isList(_n1_)

				if StzListIsOneOfTheseNamedParamsList(_n1_,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)
				if StzListIsOneOfTheseNamedParamsList(_n2_,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					_n2_ = _n2_[2]
				ok
			ok

			if isString(pCol)
				if StzFindFirst([ :First, :FirstCol, :FirstColumn ], pCol) > 0
					pCol = 1

				but StzFindFirst([ :Last, :LastCol, :LastColumn ], pCol) > 0
					pCol = This.NumberOfColumns()

				but This.HasColName(pCol)
					pCol = This.FindCol(pCol)
				ok
			ok

			if NOT isNumber(pCol)
				StzRaise("Incorrect param type! pCol must be a number.")
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstRow
					_n1_ = 1
				ok
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok

			if isString(_n2_)
				if _n2_ = :Last or _n2_ = :LastRow
					_n2_ = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(_n2_)
				StzRaise("Incorrect param type! n2 must be a number.")
			ok
		ok

		_aResult_ = []
		for i = _n1_ to _n2_
			_aResult_ + [pCol, i]
		next

		return _aResult_

		#< @FunctionAlternativeForm

		def ColumnSectionAsPositions(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindColSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindColumnSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindCellsInColSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		def FindCellsColumnSection(pCol, _n1_, _n2_)
			return This.ColSectionAsPositions(pCol, _n1_, _n2_)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A COL SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	def CellsInColSectionZ(_nCol_, _n1_, _n2_)
		_anCellsPos_ = This.FindCellsInColSection(_nCol_, _n1_, _n2_)
		_aCells_ = This.CellsAtPositions(_anCellsPos_)
		_aResult_ = Association([ _aCells_, _anCellsPos_ ])

		return _aResult_

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#====================================================#

	def RowSection(_nRow_, _n1_, _n2_)
		_aCellsPos_ =  This.RowSectionAsPositions(_nRow_, _n1_, _n2_)
		_aResult_ = This.CellsAtPositions(_aCellsPos_)

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInRowSection(_nRow_, _n1_, _n2_)
			return This.RowSection(_nRow_, _n1_, _n2_)

		#>

	def RowSectionAsPositions(_nRow_, _n1_, _n2_)
		if CheckingParams()

			if isList(_n1_)
				if StzListIsOneOfTheseNamedParamsList(_n1_,[
					:From, :FromCell, :FromPosition,
					:FromCellAt, :FromCellAtPosition
				])

					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)

				if StzListIsOneOfTheseNamedParamsList(_n2_,[
					:To, :ToCell, :ToPosition,
					:ToCellAt, :ToCellAtPosition
				])

					_n2_ = _n2_[2]
				ok
			ok

			if isString(_nRow_)

				if StzFindFirst([ :First, :FirstRow], _nRow_) > 0
					_nRow_ = 1

				but StzFindFirst([ :Last, :LastRow ], _nRow_) > 0
					_nRow_ = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(_nRow_)
				StzRaise("Incorrect param type! nRow must be a number.")
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstCol
					_n1_ = 1
				ok
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok

			if isString(_n2_)
				if _n2_ = :Last or _n2_ = :LastCol
					_n2_ = This.NumberOfCols()
				ok
			ok

			if NOT isNumber(_n2_)
				StzRaise("Incorrect param type! n2 must be a number.")
			ok
		ok

		_aResult_ = []
		for i = _n1_ to _n2_
			_aResult_ + [i, _nRow_]
		next

		return _aResult_

		#< @FunctionAlternativeForm

		def FindRowSection(_nRow_, _n1_, _n2_)
			return This.RowSectionAsPositions(_nRow_, _n1_, _n2_)

		def FindCellsInRowSection(_nRow_, _n1_, _n2_)
			return This.RowSectionAsPositions(_nRow_, _n1_, _n2_)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING CELLES IN A ROW SECTION ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------------------#

	def CellsInRowSectionZ(_nRow_, _n1_, _n2_)
		_anCellsPos_ = This.FindCellsInRowSection(_nRow_, _n1_, _n2_)
		_aCells_ = This.CellsAtPositions(_anCellsPos_)
		_aResult_ = Association([ _aCells_, _anCellsPos_ ])

		return _aResult_

	  #-------------------------------------------------#
	 #   CONVERTING A SECTION OF CELLS TO A HASHLIST   #
	#=================================================#

	def SectionToHashList(panCellPos1, panCell2)
		_aResult_ = TheseCellsToHashList( This.SectionAsPositions(panCellPos1, panCell2) )
		return _aResult_

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

	def SectionToRange(_n1_, _n2_) // TODO
		StzRaise("Feature not implemented yet!")

	def Range(paPair, paRange) // TODO
		StzRaise("Feature not implemented yet!")
