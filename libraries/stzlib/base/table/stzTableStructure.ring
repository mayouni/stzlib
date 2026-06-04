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

		o1.AddCol( :AGE = [ 12, 28, 32 ] )

		*/

		if NOT ( isList(pacColNameAndData) and
			 ring_len(pacColNameAndData) = 2 and
			 isString(pacColNameAndData[1]) and
			 isList(pacColNameAndData[2]) )

			StzRaise("Incorrect column format! pacColNameAndData must take the form :cColName = [ cell1, cell2, ... ].")
		ok

		if This.IsColName(pacColNameAndData[1])
			StzRaise("Can't add the column! The name your provided already exists.")
		ok

		nLen = ring_len(pacColNameAndData[2])
		nRows = This.NumberOfRows()

		if nLen < nRows
			for i = nLen+1 to nRows
				pacColNameAndData[2] + ""
			next

		but nLen > nRows
			for i = nLen to nRows+1 step - 1
				ring_remove(pacColNameAndData[2], i)
			next
		ok

		@aContent + pacColNameAndData
		This._InvalidateEngine()

		def AddCol(pacColNameAndData)
			This.AddColumn(pacColNameAndData)

	def AddColumns(pacColNamesAndData)
		nLen = ring_len(pacColNamesAndData)

		for i = 1 to nLen
			This.AddColumn(pacColNamesAndData[i])
		next

		def AddCols(pacColNamesAndData)
			This.AddColumns(pacColNamesAndData)

	  #===============#
	 #  ADDING ROWS  #
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

		nLen = This.NumberOfCols()

		if NOT ring_len(paRow) = This.NumberOfCols()
			StzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
		ok

		aContent = @aContent

		for i = 1 to nLen
			aContent[i][2] + paRow[i]
		next

		This.UpdateWith(aContent)

	def AddRows(paRows)
		if NOT isList(paRows)
			StzRaise("Incorrect param type! paRows must be a list.")
		ok

		nLen = ring_len(paRows)
		for i = 1 to nLen
			This.AddRow(paRows[i])
		next

	  #=======================#
	 #  EXTANDING THE TABLE  # // TODO
	#=======================#

	def Extend(nCol, nRow)

		/* ... */
		StzRaise("Unsupported feature in this release!")

		def ExtendTo(nCol, nRow)

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

			if StzFind([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = 1

			but StzFind([ :First, :FirstCol, :FirstColumn ], pCol) > 0
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

		nLen = ring_len(paColsAndTheirNewNames)

		for i = 1 to nLen
			This.RenameCol(paColsAndTheirNewNames[i][1], paColsAndTheirNewNames[i][2])
		next

	def RenameNthCol(n, pcNewName)
		if isList(pcNewName) and Q(pcNewName).IsWithOrByNamedParam()
			pcNewName = pcNewName[2]
		ok

		if NOT isString(pcNewName)
			StzRaise("Incorrect param type! pcNewName must be a string.")
		ok

		@aContent[n][1] = pcNewName

		def RenameColN(n, pcNewName)
			This.RenameNthCol(n, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		nLen = ring_len(panColsNumbers)

		for i = 1 to nLen
			This.RenameColN(panColsNumbers[i])
		next

	def RenameFirstCol(pcNewName)
		This.RenameNthCol(1, pcNewName)

	def RenameLastCol(pcNewName)
		This.RenameNthCol(:Last, pcNewName)

	  #=====================#
	 #  REMOVING A COLUMN  #
	#=====================#

	def RemoveNthCol(n)
		if This.NumberOfCols() = 1
			This.UpdateWith( [ [ :COL1, [ "" ] ] ] )
			return
		ok

		aContent = @aContent
		ring_remove(aContent, n)
		This.UpdateWith(aContent)


		def RemoveColAt(n)
			This.RemoveNthCol(n)

		def RemoveNthColumn(n)
			This.RemoveNthCol(n)

		def RemoveColumnAt(n)
			This.RemoveNthCol(n)

	def RemoveColumn(pColNameOrNumber)
		nCol = This.ColToColNumber(pColNameOrNumber)

		if This.NumberOfCols() = 1 and nCol = 1
			This.UpdateWith( [ [ :COL1, [ "" ] ] ] )
			return
		ok

		aContent = @aContent
		ring_remove(aContent, nCol)
		This.UpdateWith(aContent)

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

		anColNumbers = new stzList( U(TpacColNamesOrNumbers) ).Sorted()
		nLen = ring_len(anColNumbers)

		aContent = @aContent

		for i = nLen to 1 step -1
			ring_remove(aContent, anColNumbers[i])
		next

		This.UpdateWith(aContent)



		def RemoveColsAt(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthCols(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthColumns(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

	def RemoveColumns(pacColNamesOrNumbers)
		anColNumbers = new stzList( U(This.TheseColsToColNumbers(pacColNamesOrNumbers)) ).Sorted()
		nLen = ring_len(anColNumbers)

		aContent = @aContent

		for i = nLen to 1 step -1
			ring_remove(aContent, anColNumbers[i])
		next

		if ring_len(aContent) = 0
			aContent = [ :COL1 = [ "" ] ]
		ok

		This.UpdateWith(aContent)


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

		anPos = This.FindColsExcept(paCols)
		This.RemoveCols(anPos)

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
			n = This.FindRow(pRowOrRowNumber)[1]
			This.RemoveNthRow(n)
		ok

	def RemoveNthRow(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		aContent = @aContent
		nLen = ring_len(aContent)

		for i = 1 to nLen
			ring_remove(aContent[i][2], n)
		next

		This.UpdateWith(aContent)


		def RemoveRowAt(n)
			This.RemoveNthRow(n)

		def RemoveRowNumber(n)
			This.RemoveNthRow(n)

		def RemoveRowN(n)
			This.RemoveNthRow(n)

	  #---------------------------#
	 #  REMOVING THE GIVEN ROWS  #
	#---------------------------#

	def RemoveNthRows(panRows)

		if CheckingParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		aContent = @aContent
		nLen = ring_len(aContent)
		anPos = new stzList( U(panRows) ).Sorted()
		nLenPos = ring_len(anPos)

		for i = nLen to 1 step -1
			for j = 1 to nLen
				ring_remove(aContent[j][2], anPos[i])
			next
		next

		This.UpdateWith(aContent)


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
			anPos = This.FindTheseRows(pRowsOrRowsNumbers)
			This.RemoveRowsAt(anPos)
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

		anPos = This.FindRowsExceptAt(panRows)
		This.RemoveRows(anPos)

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

			anPos = This.FindRowsExceptThese(pRowsOrRowsNumbers)
			This.RemoveRowsAt(anPos)
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

		aContent = @aContent

		nLen = ring_len(aContent)

		for i = 1 to nLen
			nLenLine = ring_len(aContent[i][2])
			for j = 1 to nLenLine
				aContent[i][2][j] = ""
			next
		next

		This.UpdateWith(aContent)


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

	def EraseColumns(pcColNamesOrNumbers)
		nCols = This.TheseColsToColsNumbers(pcColNamesOrNumbers)

		_nCols1Len_ = ring_len(nCols)
		for _iLoopCols1_ = 1 to _nCols1Len_
			n = nCols[_iLoopCols1_]
			This.EraseCol(n)
		next

		def EraseCols(pcColNamesOrNumbers)
			This.EraseColumns(pcColNamesOrNumbers)

	  #----------------#
	 #  ERASING ROWS  #
	#----------------#

	def EraseRow(n)
		aCellsPos = This.RowAsPositions(n)
		This.EraseCells(aCellsPos)

	def EraseRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers!")
		ok

		_nPanRows1Len_ = ring_len(panRows)
		for _iLoopPanRows1_ = 1 to _nPanRows1Len_
			n = panRows[_iLoopPanRows1_]
			This.EraseRow(n)
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

		aContent = @aContent

		nCol = This.ColToColNumber(pCol)
		aContent[nCol][2][pnRow] = ""

		This.UpdateWith(aContent)


		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

	def EraseCells(paCellsPos)
		if NOT ( isList(paCellsPos) and @IsListOfPairsOfNumbers(paCellsPos) )
			StzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		aContent = @aContent
		nLen = ring_len(paCellsPos)

		for i = 1 to nLen
			nCol = paCellsPos[i][1]
			nRow = paCellsPos[i][2]
			aContent[nCol][2][nRow] = ""
		next

		This.UpdateWith(aContent)


		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	  #------------------------------#
	 #  ERASING A SECTION OF CELLS  #
	#------------------------------#

	def EraseSection(paCellPos1, paCellPos2)
		aCellsPso = This.SectionAsPositions()
		This.EraseCells(aCellsPos)

	  #======================#
	 #  INSERTING A COLUMN  #
	#======================#

	def InsertCol(n, paColData)
		if CheckingParams()
			if isList(n) and IsOneOfTheseNamedParamsList(n,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				n = n[2]
			ok

			if NOT ( isNumber(n) or ( isList(n) and @IsListOfNumbers(n) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT ( isList(paColData) and ring_len(paColData) > 1 and isString(paColData[1]) )
				StzRaise("Incorrect param type! paColData must be a list with the first item beeing a string.")
			ok
		ok

		if isList(n)
			This.InsertColAtPositions(n, paRowData)
			return
		ok

		# Preparing the column name and data

		cColName = paColData[1]
		paColData = paColData[2]

		nLenColData = ring_len(paColData)
		nRows = This.NumberOfRows()
		nMin = @Min([ nLenColData, nRows ])

		aColData = []

		for i = 1 to nMin
			aColData + paColData[i]
		next

		if nLenColData < nRows
			for i = nLenColData + 1 to nRows
				aColData + ""
			next
		ok

		# Adding the column

		aContent = @aContent
		@aContent + [ cColName, aColData ]
		This.UpdateWith(aContent)


		#< @FunctionAlternativeForms

		def InsertColBefore(n, paRowData)
			This.InsertCol(n, paRowData)

		def InsertColBeforePosition(n, paRowData)
			This.InsertCol(n, paRowData)

		#--

		def insertColAt(n, paRowData)
			This.InsertCol(n, paRowData)

		def InsertColAtPosition(n, paRowData)
			This.InsertCol(n, paRowData)

		#==

		def InsertColumn(n, paRowData)
			This.InsertCol(n, paRowData)

		def InsertColumnBefore(n, paRowData)
			This.InsertCol(n, paRowData)

		def InsertColumnBeforePosition(n, paRowData)
			This.InsertCol(n, paRowData)

		#--

		def insertColumnAt(n, paRowData)
			This.InsertCol(n, paRowData)

		def InsertColumnAtPosition(n, paRowData)
			This.InsertCol(n, paRowData)

		#>

	def InsertColAfter(n, paRowData)
		This.InsertColAt(n+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertColAfterPosition(n, paRowData)
			This.InsertColAfter(n, paRowData)

		#--

		def InsertColumnAfter(n, paRowData)
			This.InsertColAfter(n, paRowData)

		def InsertColumnAfterPosition(n, paRowData)
			This.InsertColAfter(n, paRowData)

		#>

	  #===================#
	 #  INSERTING A ROW  #
	#===================#

	def InsertRow(n, paRowData)
		if CheckingParams()
			if isList(n) and IsOneOfTheseNamedParamsList(n,[
					:At, :Before,
					:AtPosition, :BeforePosition,
					:AtPositions, :BeforePositions
				])

				n = n[2]
			ok

			if NOT ( isNumber(n) or ( isList(n) and @IsListOfNumbers(n) ) )
				StzRaise("Incorrect param type! n must be a number or a list of numbers.")
			ok

			if NOT isList(paRowData)
				StzRaise("Incorrect param type! paRowData must be a list.")
			ok
		ok

		if isList(n)
			This.InsertRowAtPositions(n, paRowData)
			return
		ok

		nCols = This.NumberOfCols()
		nRows = This.NumberOfRows()
		nRowData = ring_len(parowData)
		nMin = @Min([nRowData , nCols ])

		# Filling the missing cells by ""

		if nRowData < nCols
			for i = nRowData+1 to nCols
				paRowData + ""
			next
		ok

		# Doing the job

		aContent = @aContent

		for i = 1 to nCols
			ring_insert(aContent[i][2], n, paRowData[i])
		next

		This.UpdateWith(aContent)



		#< @FunctionAlternativeForms

		def InsertRowBefore(n, paRowData)
			This.InsertRow(n, paRowData)

		def InsertRowBeforePosition(n, paRowData)
			This.InsertRow(n, paRowData)

		#--

		def insertRowAt(n, paRowData)
			This.InsertRow(n, paRowData)

		def InsertRowAtPosition(n, paRowData)
			This.InsertRow(n, paRowData)

		#>

	def InsertRowAfter(n, paRowData)
		This.InsertRowAt(n+1, paRowData)

		#< @FunctionAlternativeForm

		def InsertRowAfterPosition(n, paRowData)
			This.InsertRowAfter(n, paRowData)

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

		anPos = new stzList( U(panPos) ).Sorted()
		nLen = ring_len(anPos)

		for i = nLen to 1 step -1
			This.InsertRowAtPosition(panPos[i], paRow)
		next

		def InsertRows(panPos, paRow)
			This.InsertRowAtPositions(panPos, paRow)

		def InsertRowsAt(panPos, paRow)
			InsertRowAtPositions(panPos, paRow)
