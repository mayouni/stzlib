#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESTRUCTURE           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table structure subclass -- adding,         #
#                  removing, inserting, renaming, and erasing  #
#                  columns and rows.                           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableStructure from stzTable

	  #==================#
	 #  ADDING COLUMNS  #
	#==================#

	def AddColumn(pacColNameAndData)
		/* EXAMPLE

		_o1_.AddCol( :AGE = [ 12, 28, 32 ] )

		*/

		if NOT ( isList(pacColNameAndData) and
			 len(pacColNameAndData) = 2 and
			 isString(pacColNameAndData[1]) and
			 isList(pacColNameAndData[2]) )

			StzRaise("Incorrect column format! pacColNameAndData must take the form :cColName = [ cell1, cell2, ... ].")
		ok

		if This.IsColName(pacColNameAndData[1])
			StzRaise("Can't add the column! The name your provided already exists.")
		ok

		_nLen_ = len(pacColNameAndData[2])
		_nRows_ = This.NumberOfRows()

		if _nLen_ < _nRows_
			for i = _nLen_+1 to _nRows_
				pacColNameAndData[2] + ""
			next

		but _nLen_ > _nRows_
			for i = _nLen_ to _nRows_+1 step - 1
				ring_remove(pacColNameAndData[2], i)
			next
		ok

		@aContent + pacColNameAndData
		This._InvalidateEngine()

		def AddCol(pacColNameAndData)
			This.AddColumn(pacColNameAndData)

	def AddColumns(pacColNamesAndData)
		_nLen_ = len(pacColNamesAndData)

		for i = 1 to _nLen_
			This.AddColumn(pacColNamesAndData[i])
		next

		def AddCols(pacColNamesAndData)
			This.AddColumns(pacColNamesAndData)

	  #===============#
	 #  ADDING ROWS  #
	#===============#

	def AddRow(paRow)
		/*
		_o1_ = new stzTable([
			:ID 	  = [ 10,	20,		30	],
			:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
			:SALARY	  = [ 14500,	17630,		20345	]
		])

		_o1_.AddRow([ 40, "Peter", 12500 ])
		? _o1_.Row(4) #--> [ 40, "Peter", 12500 ]

		*/

		if NOT isList(paRow)
			StzRaise("Incorrect param type! paRow must be a list.")
		ok

		_nLen_ = This.NumberOfCols()

		if NOT len(paRow) = This.NumberOfCols()
			StzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
		ok

		_aContent_ = @aContent

		for i = 1 to _nLen_
			_aContent_[i][2] + paRow[i]
		next

		This.UpdateWith(_aContent_)

	def AddRows(paRows)
		if NOT isList(paRows)
			StzRaise("Incorrect param type! paRows must be a list.")
		ok

		_nLen_ = len(paRows)
		for i = 1 to _nLen_
			This.AddRow(paRows[i])
		next

	  #=======================#
	 #  EXTANDING THE TABLE  # // TODO
	#=======================#

	def Extend(_nCol_, _nRow_)

		/* ... */
		StzRaise("Unsupported feature in this release!")

		def ExtendTo(_nCol_, _nRow_)

	  #======================#
	 #  UPDATING THE TABLE  #
	#======================#

	def Update(paNewTable)
		if CheckingParams() = 1
			if isList(paNewTable) and Q(paNewTable).IsWithOrByOrUsingNamedParam()
				paNewTable = paNewTable[2]
			ok

			if NOT( isList(paNewTable) and Q(paNewTable).IsHashList() and
				StzHashListQ(paNewTable).ValuesAreListsOfSameSize()  )

				StzRaise("Incorrect param type! paNewTable must be a hashlist where values are lists of the same size.")
			ok
		ok

		@aContent = paNewTable
		This._InvalidateEngine()

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(paNewTable)
			This.Update(paNewTable)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(paNewTable)
			This.Update(paNewTable)

			def UpdateWithQ(paNewTable)
				return This.UpdateQ(paNewTable)

		def UpdateBy(paNewTable)
			This.Update(paNewTable)

			def UpdateByQ(paNewTable)
				return This.UpdateQ(paNewTable)

		def UpdateUsing(paNewTable)
			This.Update(paNewTable)

			def UpdateUsingQ(paNewTable)
				return This.UpdateQ(paNewTable)

		#>

	def Updated(paNewTable)
		return paNewTable

		#< @FunctionAlternativeForms

		def UpdatedWith(paNewTable)
			return This.Updated(paNewTable)

		def UpdatedBy(paNewTable)
			return This.Updated(paNewTable)

		def UpdatedUsing(paNewTable)
			return This.Updated(paNewTable)

		#>

	  #====================#
	 #  RENAMING COLUMNS  #
	#====================#

	def RenanmeCol(pCol, pcNewName)

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		if isString(pCol)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = 1

			but StzFindFirst([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = This.NumberOfCols()

			but This.HasColName(pCol)
				pCol = This.ColToColNumber(pCol)

			else
				StzRaise("Incorrect value! Allowed values :FirstCol, :LastCol, or use a number instead.")
			ok
		ok

		This.RenameColN(pCol, pcNewName)

	def RenameCols(paColsAndTheirNewNames)

		if NOT (isList(paColsAndTheirNewNames) and Q(paColsAndTheirNewNames).IsHashList())
			StzRaise("Incorrect param type! paColsAndTheirNewNames must be a hashlist.")
		ok

		_nLen_ = len(paColsAndTheirNewNames)

		for i = 1 to _nLen_
			This.RenameCol(paColsAndTheirNewNames[i][1], paColsAndTheirNewNames[i][2])
		next

	def RenameNthCol(_n_, pcNewName)
		if isList(pcNewName) and Q(pcNewName).IsWithOrByNamedParam()
			pcNewName = pcNewName[2]
		ok

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		@aContent[_n_][1] = pcNewName

		def RenameColN(_n_, pcNewName)
			This.RenameNthCol(_n_, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		_nLen_ = len(panColsNumbers)

		for i = 1 to _nLen_
			This.RenameColN(panColsNumbers[i])
		next

	def RenameFirstCol(pcNewName)
		This.RenameNthCol(1, pcNewName)

	def RenameLastCol(pcNewName)
		This.RenameNthCol(:Last, pcNewName)

	  #=====================#
	 #  REMOVING A COLUMN  #
	#=====================#

	def RemoveNthCol(_n_)
		if This.NumberOfCols() = 1
			This.UpdateWith( [ [ :COL1, [ "" ] ] ] )
			return
		ok

		_aContent_ = @aContent
		ring_remove(_aContent_, _n_)
		This.UpdateWith(_aContent_)


		def RemoveColAt(_n_)
			This.RemoveNthCol(_n_)

		def RemoveNthColumn(_n_)
			This.RemoveNthCol(_n_)

		def RemoveColumnAt(_n_)
			This.RemoveNthCol(_n_)

	def RemoveColumn(pColNameOrNumber)
		_nCol_ = This.ColToColNumber(pColNameOrNumber)

		if This.NumberOfCols() = 1 and _nCol_ = 1
			This.UpdateWith( [ [ :COL1, [ "" ] ] ] )
			return
		ok

		_aContent_ = @aContent
		ring_remove(_aContent_, _nCol_)
		This.UpdateWith(_aContent_)

		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	  #------------------------------#
	 #  REMOVING THE GIVEN COLUMNS  #
	#------------------------------#

	def RemoveColumnsAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		_anColNumbers_ = new stzList( U(TpacColNamesOrNumbers) ).Sorted()
		_nLen_ = len(_anColNumbers_)

		_aContent_ = @aContent

		for i = _nLen_ to 1 step -1
			ring_remove(_aContent_, _anColNumbers_[i])
		next

		This.UpdateWith(_aContent_)



		def RemoveColsAt(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthCols(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthColumns(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

	def RemoveColumns(pacColNamesOrNumbers)
		_anColNumbers_ = new stzList( U(This.TheseColsToColNumbers(pacColNamesOrNumbers)) ).Sorted()
		_nLen_ = len(_anColNumbers_)

		_aContent_ = @aContent

		for i = _nLen_ to 1 step -1
			ring_remove(_aContent_, _anColNumbers_[i])
		next

		if len(_aContent_) = 0
			_aContent_ = [ :COL1 = [ "" ] ]
		ok

		This.UpdateWith(_aContent_)


		def RemoveCols(pcColNamesOrNumbers)
			This.RemoveColumns(pcColNamesOrNumbers)

	  #--------------------------------------------------#
	 #  REMOVING ALL THE COLUMNS EXCEPT THOSE PROVIDED  #
	#--------------------------------------------------#

	def RemoveAllColsExceptAt(panColNumbers)
		This.RemoveAllColsExcept(paColNumbers)

		#< @FunctionAlternativeForms

		def RemoveColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColumnsExceptPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#--

		def RemoveColsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#--

		def RemoveAllColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsExceptAt(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveAllColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		def RemoveColumnsOtherThanPositions(panColNumbers)
			This.RemoveAllColsExceptAt(panColNumbers)

		#>

	def RemoveAllColsExcept(paCols)
		if CheckingParams()
			if NOT ( isList(paCols) and Q(paCols).IsListOfNumbersOrStrings() )
				StzRaise("Incorrect param type! panRows must be a list of numbers or strings.")
			ok
		ok

		_anPos_ = This.FindColsExcept(paCols)
		This.RemoveCols(_anPos_)

		#< @FunctionAlternativeForms

		def RemoveColsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveAllColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#--

		def RemoveAllColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColumnsExcept(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveAllColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		def RemoveColumnsOtherThan(panRow)
			This.RemoveAllColsExcept(panRow)

		#>

	  #---------------------------------------------#
	 #  REMOVING ALL THE COLUMNS AND ALL THE ROWS  #
	#=============================================#

	def RemoveAll()
		This.UpdateWith([ :COL1 = [ "" ] ])

		def RemoveAllCols()
			This.RemoveAll()

		def RemoveAllColumns()
			This.RemoveAll()

	  #------------------------#
	 #  REMOVING A GIVEN ROW  #
	#========================#

	def RemoveRow(pRowOrRowNumber)
		if CheckingParams()
			if NOT ( isNumber(pRowOrRowNumber) or isList(pRowOrRowNumber) )
				StzRaise("Incorrect param type! pRowOrRowNumber must be a number or list.")
			ok
		ok

		if isNumber(pRowOrRowNumber)
			This.RemoveNthRow(pRowOrRowNumber)

		else
			_n_ = This.FindRow(pRowOrRowNumber)[1]
			This.RemoveNthRow(_n_)
		ok

	def RemoveNthRow(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_aContent_ = @aContent
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			ring_remove(_aContent_[i][2], _n_)
		next

		This.UpdateWith(_aContent_)


		def RemoveRowAt(_n_)
			This.RemoveNthRow(_n_)

		def RemoveRowNumber(_n_)
			This.RemoveNthRow(_n_)

		def RemoveRowN(_n_)
			This.RemoveNthRow(_n_)

	  #---------------------------#
	 #  REMOVING THE GIVEN ROWS  #
	#---------------------------#

	def RemoveNthRows(panRows)

		if CheckingParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_aContent_ = @aContent
		_nLen_ = len(_aContent_)
		_anPos_ = new stzList( U(panRows) ).Sorted()
		_nLenPos_ = len(_anPos_)

		for i = _nLen_ to 1 step -1
			for j = 1 to _nLen_
				ring_remove(_aContent_[j][2], _anPos_[i])
			next
		next

		This.UpdateWith(_aContent_)


		def RemoveRowsAt(panRows)
			This.RemoveNthRows(panRows)

	def RemoveRows(pRowsOrRowsNumbers)
		if CheckingParams()
			if NOT isList(pRowsOrRowsNumbers)
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers.")
			ok

			if NOT ( @IsListOfNumbers(pRowsOrRowsNumbers) or @IsListOfLists(pRowsOrRowsNumbers) )
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(pRowsOrRowsNumbers)
			This.RemoveRowsAt(pRowsOrRowsNumbers)

		else // @IsListOfLists(pRowsOrRowsNumbers)
			_anPos_ = This.FindTheseRows(pRowsOrRowsNumbers)
			This.RemoveRowsAt(_anPos_)
		ok

	  #-----------------------------------------------#
	 #  REMOVING ALL THE ROWS EXCEPT THOSE PROVIDED  #
	#-----------------------------------------------#

	def RemoveAllRowsExceptAt(panRows)
		if CheckingParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		_anPos_ = This.FindRowsExceptAt(panRows)
		This.RemoveRows(_anPos_)

		#< @FunctionAlternativeForms

		def RemoveRowsExceptAt(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		def RemoveAllRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		def RemoveRowsOtherThanPositions(panRow)
			This.RemoveAllRowsExceptAt(panRow)

		#>

	def RemoveAllRowsExcept(pRowsOrRowsNumbers)

		if CheckingParams()
			if NOT isList(pRowsOrRowsNumbers)
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers.")
			ok

			if NOT ( @IsListOfNumbers(pRowsOrRowsNumbers) or @IsListOfLists(pRowsOrRowsNumbers) )
				StzRaise("Incorrect param type! pRowsOrRowsNumbers must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(pRowsOrRowsNumbers)
			This.RemoveRowsAt(pRowsOrRowsNumbers)

		else // @IsListOfLists(pRowsOrRowsNumbers)

			_anPos_ = This.FindRowsExceptThese(pRowsOrRowsNumbers)
			This.RemoveRowsAt(_anPos_)
		ok


		#< @FunctionAlternativeForms

		def RemoveRowsExcept(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		def RemoveAllRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		def RemoveRowsOtherThan(pRowsOrRowsNumbers)
			This.RemoveAllRowsExcept(pRowsOrRowsNumbers)

		#>

	  #=====================#
	 #  ERASING THE TABLE  #
	#=====================#

	def Erase()
		#NOTE
		# Only data in cells is erased, columns and
		# rows remain as they are!

		_aContent_ = @aContent

		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			_nLenLine_ = len(_aContent_[i][2])
			for j = 1 to _nLenLine_
				_aContent_[i][2][j] = ""
			next
		next

		This.UpdateWith(_aContent_)


		def EraseTable()
			This.Erase()

	  #-------------------#
	 #  ERASING COLUMNS  #
	#-------------------#

	def EraseColumn(pColNameOrNumber)
		_aCellsPos_ = This.ColAsPositions(pColNameOrNumber)
		This.EraseCells(_aCellsPos_)

		def EraseCol(pColNameOrNumber)
			This.EraseColumn(pColNameOrNumber)

	def EraseColumns(pcColNamesOrNumbers)
		_nCols_ = This.TheseColsToColsNumbers(pcColNamesOrNumbers)

		_nCols1Len_ = len(_nCols_)
		for _iLoopCols1_ = 1 to _nCols1Len_
			_n_ = _nCols_[_iLoopCols1_]
			This.EraseCol(_n_)
		next

		def EraseCols(pcColNamesOrNumbers)
			This.EraseColumns(pcColNamesOrNumbers)

	  #----------------#
	 #  ERASING ROWS  #
	#----------------#

	def EraseRow(_n_)
		_aCellsPos_ = This.RowAsPositions(_n_)
		This.EraseCells(_aCellsPos_)

	def EraseRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers!")
		ok

		_nPanRows1Len_ = len(panRows)
		for _iLoopPanRows1_ = 1 to _nPanRows1Len_
			_n_ = panRows[_iLoopPanRows1_]
			This.EraseRow(_n_)
		next

	  #-----------------#
	 #  ERASING CELLS  #
	#-----------------#

	def EraseCell(pCol, pnRow)
		if isNumber(pCol)
			pCol = This.ColName(pCol)
		ok

		if NOT ( isString(pCol) and This.HasColName(pCol) )
			StzRaise("Incorrect column name!")
		ok

		_aContent_ = @aContent

		_nCol_ = This.ColToColNumber(pCol)
		_aContent_[_nCol_][2][pnRow] = ""

		This.UpdateWith(_aContent_)


		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

	def EraseCells(paCellsPos)
		if NOT ( isList(paCellsPos) and @IsListOfPairsOfNumbers(paCellsPos) )
			StzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		_aContent_ = @aContent
		_nLen_ = len(paCellsPos)

		for i = 1 to _nLen_
			_nCol_ = paCellsPos[i][1]
			_nRow_ = paCellsPos[i][2]
			_aContent_[_nCol_][2][_nRow_] = ""
		next

		This.UpdateWith(_aContent_)


		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	  #------------------------------#
	 #  ERASING A SECTION OF CELLS  #
	#------------------------------#

	def EraseSection(paCellPos1, paCellPos2)
		_aCellsPso_ = This.SectionAsPositions()
		This.EraseCells(_aCellsPos_)

	  #======================#
	 #  INSERTING A COLUMN  #
	#======================#

	def InsertCol(_n_, paColData)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				_n_ = _n_[2]
			ok

			if NOT ( isNumber(_n_) or ( isList(_n_) and @IsListOfNumbers(_n_) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT ( isList(paColData) and len(paColData) > 1 and isString(paColData[1]) )
				StzRaise("Incorrect param type! paColData must be a list with the first item beeing a string.")
			ok
		ok

		if isList(_n_)
			This.InsertColAtPositions(_n_, paRowData)
			return
		ok

		# Preparing the column name and data

		_cColName_ = paColData[1]
		paColData = paColData[2]

		_nLenColData_ = len(paColData)
		_nRows_ = This.NumberOfRows()
		_nMin_ = @Min([ _nLenColData_, _nRows_ ])

		_aColData_ = []

		for i = 1 to _nMin_
			_aColData_ + paColData[i]
		next

		if _nLenColData_ < _nRows_
			for i = _nLenColData_ + 1 to _nRows_
				_aColData_ + ""
			next
		ok

		# Adding the column

		_aContent_ = @aContent
		@aContent + [ _cColName_, _aColData_ ]
		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForms

		def InsertColBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#--

		def insertColAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#==

		def InsertColumn(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnBefore(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnBeforePosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#--

		def insertColumnAt(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		def InsertColumnAtPosition(_n_, paRowData)
			This.InsertCol(_n_, paRowData)

		#>

	def InsertColAfter(_n_, paRowData)
		This.InsertColAt(_n_+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertColAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		#--

		def InsertColumnAfter(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		def InsertColumnAfterPosition(_n_, paRowData)
			This.InsertColAfter(_n_, paRowData)

		#>

	  #===================#
	 #  INSERTING A ROW  #
	#===================#

	def InsertRow(_n_, paRowData)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				_n_ = _n_[2]
			ok

			if NOT ( isNumber(_n_) or ( isList(_n_) and @IsListOfNumbers(_n_) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT isList(paRowData)
				StzRaise("Incorrect param type! paRowData must be a list.")
			ok
		ok

		if isList(_n_)
			This.InsertRowAtPositions(_n_, paRowData)
			return
		ok

		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()
		_nRowData_ = len(parowData)
		_nMin_ = @Min([_nRowData_ , _nCols_ ])

		# Filling the missing cells by ""

		if _nRowData_ < _nCols_
			for i = _nRowData_+1 to _nCols_
				paRowData + ""
			next
		ok

		# Doing the job

		_aContent_ = @aContent

		for i = 1 to _nCols_
			ring_insert(_aContent_[i][2], _n_, paRowData[i])
		next

		This.UpdateWith(_aContent_)



		#< @FunctionAlternativeForms

		def InsertRowBefore(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		def InsertRowBeforePosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		#--

		def insertRowAt(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		def InsertRowAtPosition(_n_, paRowData)
			This.InsertRow(_n_, paRowData)

		#>

	def InsertRowAfter(_n_, paRowData)
		This.InsertRowAt(_n_+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertRowAfterPosition(_n_, paRowData)
			This.InsertRowAfter(_n_, paRowData)

		#>

	  #-------------------------------------#
	 #  INSERTING A ROW IN MANY POSITIONS  #
	#-------------------------------------#

	def InsertRowAtPositions(panPos, paRow)
		if CheckingParams()
			if NOT ( isList(panPos) and @isListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_anPos_ = new stzList( U(panPos) ).Sorted()
		_nLen_ = len(_anPos_)

		for i = _nLen_ to 1 step -1
			This.InsertRowAtPosition(panPos[i], paRow)
		next

		def InsertRows(panPos, paRow)
			This.InsertRowAtPositions(panPos, paRow)

		def InsertRowsAt(panPos, paRow)
			InsertRowAtPositions(panPos, paRow)
