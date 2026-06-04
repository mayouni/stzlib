#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESUBSET              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table subset subclass -- extracting         #
#                  columns, rows, sub-tables, moving and       #
#                  swapping columns and rows.                  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableSubset from stzTable

	  #===================================================#
	 #  GETTING THE LIST OF COLUMNS (AS LISTS OF CELLS)  #
	#===================================================#

	def Cols()
		return This.TheseCols( 1 : This.NumberOfCols() )

		#< @FunctionFluentForm

		def ColsQ()
			return new stzList( This.Cols() )

		#>

		#< @FunctionAlternativeForms

		def Columns()
			return This.Cols()

			def ColumnsQ()
				return This.ColsQ()

		def AllCols()
			return This.Cols()

			def AllColsQ()
				return This.ColsQ()

		def AllColumns()
			return This.Cols()

			def AllColumnsQ()
				return This.ColsQ()

		#--

		def ColsData()
			return This.Cols()

			def ColsDataQ()
				return This.ColsQ()

		def ColumnsData()
			return This.Cols()

			def ColumnsDataQ()
				return This.ColsQ()

		def AllColsData()
			return This.Cols()

			def AllColsDataQ()
				return This.ColsQ()

		def AllColumnsData()
			return This.Cols()

			def AllColumnsDataQ()
				return This.ColsQ()

		#>

	  #--------------------------------------------------------------------#
	 #  GETTING THE LIST OF COLUMNS AS DEFINED BY THEIR NAMES OR NUMBERS  #
	#--------------------------------------------------------------------#

	def TheseColumns(pacColNamesOrNumbers)
		if NOT 	( isList(pacColNamesOrNumbers) and
			  ( Q(pacColNamesOrNumbers).IsListOfNumbers() or
			  Q(pacColNamesOrNumbers).IsListOfStrings() ) )

			StzRaise("Incorrect param type! pacColNamesOrNumbers must be a list of numbers or a list of strings.")
		ok

		nLen = ring_len(pacColNamesOrNumbers)
		aResult = []

		for i = 1 to nLen
			aResult + This.Column(pacColNamesOrNumbers[i])
		next

		return aResult

		#< @FunctionFluentForm

		def TheseColumnsQ(pacColNamesOrNumbers)
			return TheseColumnsQRT(pacColNamesOrNumbers, :stzList)

		def TheseColumnsQRT(pacColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzHashList
				return new stzHashList( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumns(pacColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumns(pacColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def TheseCols(pacColNamesOrNumbers)
			return This.TheseColumns(pacColNamesOrNumbers)

			def TheseColsQ(pacColNamesOrNumbers)
				return This.TheseColsQRT(pacColNamesOrNumbers, :stzList)

			def TheseColsQRT(pacColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsQRT(pacColNamesOrNumbers, pcReturnType)

		#>

	  #-----------------------------------------------------------------#
	 #  GETTING THE LIST OF COLUMNS (AS COLUMN NAMES AND THEIR CELLS)  #
	#-----------------------------------------------------------------#

	def ColsXT()
		return This.TheseColsXT( 1 : This.NumberOfCols() )

		def ColsXTQ()
			return new stzList( This.ColsXT() )

	  #-----------------------------------------------------#
	 #  GETTING THE LIST COLUMNS DEFINED BY THEIR NUMBERS  #
	#-----------------------------------------------------#

	def ColumnsAtPositions(panColNumbers)
		return This.TheseColumns(panColNumbers)

		#< @FunctionFluentForms

		def ColumnsAtPositionsQ(panColNumbers)
			return This.ColumnsAtPositionsQRT(panColNumbers, :stzList)

		def ColumnsAtPositionsQRT(panColNumbers, pcReturnType)
			return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		#>

		#< @FunctionAlternativeForms

		def ColumnsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColumnsAtQ(panColNumbers)
				return This.ColumnsAtQRT(panColNumbers, :stzList)

			def ColumnsAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		def ColsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColsAtQ(panColNumbers)
				return This.ColumnsAtQRT(panColNumbers, :stzList)

			def ColsAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsQRT(panColNumbers, pcReturnType)

		def ColAtPositions(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtPositionsQ(panColNumbers)
				return This.ColAtPositionsQRT(panColNumbers, :stzList)

			def ColAtPositionsQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQRT(panColNumbers, pcReturnType)

		def ColAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtQ(panColNumbers)
				return This.ColAtQRT(panColNumbers, :stzList)

			def ColAtQRT(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQRT(panColNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------#
	 #  GETTING THE LIST OF PROVIDED COLUMNS (THEIR NAMES AND THEIR CELLS)  #
	#----------------------------------------------------------------------#

	def TheseColumnsXT(paColNamesOrNumbers)

		if NOT ( isList(paColNamesOrNumbers) and
			 Q(paColNamesOrNumbers).IsListOfStringsOrNumbers() )

			StzRaise("Incorrect param type! paColNamesOrNumbers must be a list of strings or numbers.")
		ok

		nLen = ring_len(paColNamesOrNumbers)
		aResult = []

		for i = 1 to nLen
			p = paColNamesOrNumbers[i]
			aResult + [ This.ColName(p), This.ColData(p) ]
		next

		return aResult

		#< @FunctionFluentForm

		def TheseColumnsXTQ(paColNamesOrNumbers)
			return This.TheseColumnsXTQRT(paColNamesOrNumbers, :stzList)

		def TheseColumnsXTQRT(paColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumnsXT(paColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumnsXT(paColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumnsXT(paColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def TheseColsXT(paColNamesOrNumbers)
			return This.TheseColumnsXT(paColNamesOrNumbers)

			def TheseColsXTQ(paColNamesOrNumbers)
				return This.TheseColsXTQRT(paColNamesOrNumbers, :stzList)

			def TheseColsXTQRT(paColNamesOrNumbers, pcReturnType)
				return This.TheseColsXT(paColNamesOrNumbers, pcReturnType)

		def TheseColXT(paColNamesOrNumbers)
			return This.TheseColumnsXT(paColNamesOrNumbers)

			def TheseColXTQ(paColNamesOrNumbers)
				return This.TheseColXTQRT(paColNamesOrNumbers, :stzList)

			def TheseColXTQRT(paColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsXT(paColNamesOrNumbers, pcReturnType)

		#>

	  #-------------------------------------------------------------------------#
	 #  GETTING THE NAMES OF THE PROVIDED COLUMNS AS DEFINED BY THEIR NUMBERS  #
	#-------------------------------------------------------------------------#

	def TheseColNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! pacColNumbers muts be a list of numbers.")
		ok

		nCols = This.NumberOfCols()

		bAllValid = 1
		_nPanColNumbersLen_ = ring_len(panColNumbers)
		for _i = 1 to _nPanColNumbersLen_
			if panColNumbers[_i] < 1 or panColNumbers[_i] > nCols
				bAllValid = 0
				exit
			ok
		next
		if NOT bAllValid
			StzRaise("Incorrect param type! numbers in panColNumbers must all be between 1 and " + nCols + ".")
		ok

		panColNumbers  = new stzList(panColNumbers).Sorted()
		nLenColNumbers = ring_len(panColNumbers)

		pacColNames    = This.ColNames()

		nNumCols       = ring_len(pacColNames)

		if ring_len(panColNumbers) > nNumCols
			panColNumbers = Q(panColNumbers).Section( 1, nNumCols)
		ok

		aResult = []

		for i = 1 to nLenColNumbers
			aResult + pacColNames[panColNumbers[i]]
		next

		return aResult

		def TheseColumsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

		def TheseColsNames(panColNumbers)
			return This.TheseColNames(panColNumbers)

	  #------------------------------------------------------------------#
	 #  GETTING THE NAMES OF COLUMNS AS DEFINED BY THEIR GIVEN NUMBERS  #
	#------------------------------------------------------------------#

	def ColNumbersToNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsLIstOfNumbers() )
			StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
		ok

		nLen = ring_len(panColNumbers)
		aResult = []

		for i = 1 to nLen
			aResult + This.NthColName(panColNumbers[i])
		next

		return aResult

	  #------------------------------------------------------------------#
	 #  GETTING THE NUMBERS OF COLUMNS AS DEFINED BY THEIR GIVEN NAMES  #
	#------------------------------------------------------------------#

	def cColNamesToNumbers(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		nLen = ring_len(pacColNames)
		anResult = []

		for i = 1 to nLen
			n = This.FindColByName(pacColNames[i])
			anResult + n
		next

		return anResult

		#< @FunctionAlternativeForms

		def ColsNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		def ColumnNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		def ColumnsNamesToNumbers(pacColNames)
			return This.ColNamesToNumbers(pacColNames)

		#>

	  #=============================================================#
	 #  RETURNING THE SUBTABLE DEFINED BY THE GIVEN COLUMNS NAMES  #
	#=============================================================#

	def SubTable(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
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
			return This.SubTableQRT(pacColNames, :stzList)

		def SubTableQRT(pacColNames, pcReturnType)
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
				StzRaise("Unsupported return type!")
			off

	  #-----------------------------------------------------------------------#
	 #  RETURNING A SUBSET OF THE TABLE DEFININED BY THE GIVEN ROWS NUMBERS  #
	#-----------------------------------------------------------------------#

	def SubSet(panRowsNumbers)
		return This.TheseRows(panRowsNumbers)

		def SubSetQ(panRowsNumbers)
			return This.SubSetQRT(panRowsNumbers, :stzList)

		def SubSetQRT(panRowsNumbers, pcReturnType)
			return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

	  #========================================================#
	 #  GETTING THE LIST OF ROWS AS DEFINED BY THEIR NUMBERS  #
	#========================================================#

	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers() )

			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		aResult = []
		nLen = ring_len(panRowsNumbers)

		for i = 1 to nLen
			aResult + This.Row(panRowsNumbers[i])
		next

		return aResult

		#< @FunctionFluentForm

		def TheseRowsQ(panRowsNumbers)
			return TheseRowsQRT(panRowsNumbers, :stzList)

		def TheseRowsQRT(panRowsNumbers, pcReturnType)
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
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def RowsAtPositions(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtPositionsQ(panRowsNumbers)
				return This.RowsAtPositionsQRT(panRowsNumbers, :stzList)

			def RowsAtPositionsQRT(panRowsNumbers, pcReturnType)
				return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

		def RowsAt(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtQ(panRowsNumbers)
				return This.RowsAtPositionsQRT(panRowsNumbers, :stzList)

			def RowsAtQRT(panRowsNumbers, pcReturnType)
				return This.TheseRowsQRT(panRowsNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------------#
	 #  GETTING THE CELLS CONTAINED IN THE GIVEN ROWS ALONG WITH THEIR POSITIONS  #
	#----------------------------------------------------------------------------#

	def TheseRowsZ(panRowsNumbers)
		if NOT (isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers())
			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		nLen = ring_len(apnRowsNumbers)

		aResult = []
		for n in nLen
			aResult + This.RowZ(panRowsNumbers[i])
		next

		return aResult

		def TheseRowsZQ(panRowsNumbers)
			return This.TheseRowsZQRT(panRowsNumbers, :stzList)

		def TheseRowsZQRT(panRowsNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseRowsZ(panRowsNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseRowsZ(panRowsNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseRowsZ(panRowsNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

	  #==============================================#
	 #   MOVING A ROW FROM A POSITION TO AN OTHER   #
	#==============================================#

	def MoveRow(pnFrom, pnTo)

		# Checking the params correctness

		if isList(pnFrom) and
			( Q(pnFrom).IsFromNamedParam()  or
			  Q(pnFrom).IsFromPositionNamedParam() or
			  Q(pnFrom).IsAtPositionNamedParam() )

			pnFrom = pnFrom[2]
		ok

		if isList(pnTo) and
			( Q(pnTo).IsToNamedParam()  or
			  Q(pnTo).IsToPositionNamedParam() )

			pnTo = pnTo[2]
		ok

		if isString(pnFrom)
			if pnFrom = :First or
			   pnFrom = :FirstRow or
			   pnFrom = :FirstPosition

				pnFrom = 1

			but pnFrom = :Last or
			    pnFrom = :LastRow or
			    pnFrom = :LastPosition

				pnFrom = This.NumberOfRows()
			ok
		ok

		if isString(pnTo)
			if pnTo = :Last or pnTo = :LastRow
				pnTo = This.NumberOfRows()

			but pnTo = :First or pnTo = :FirstRow
				pnTo = 1
			ok
		ok

		if NOT Q([pnFrom, pnTo]).BothAreNumbers()
			StzRaise("Incorrect param types! Both pnFrom and pnTo must be numbers.")
		ok

		# Doing the job

		aRowCopy = This.Row(pnTo)
		This.ReplaceRow(pnTo, This.Row(pnFrom))
		This.ReplaceRow(pnFrom, aRowCopy)

	  #-----------------------#
	 #   SWAPPING TWO ROWS   #
	#-----------------------#

	def SwapRows(pnRow1, pnRow2)

		if isList(pnRow1) and
			( Q(pnRow1).IsAndNamedParam() or
			  Q(pnRow1).IsAndPositionNamedParam() or
			  Q(pnRow1).IsAndRowNamedParam() or
			  Q(pnRow1).IsAndRowAtNamedParam() or
			  Q(pnRow1).IsAndRowAtPositionNamedParam() or
			  Q(pnRow1).IsBetweenNamedParam() or
			  Q(pnRow1).IsBetweenRowNamedParam() or
			  Q(pnRow1).IsBetweenRowAtNamedParam() or
			  Q(pnRow1).IsBetweenRowAtPositionNamedParam() or
			  Q(pnRow1).IsBetweenPositionNamedParam() or
			  Q(pnRow1).IsBetweenPositionsNamedParam()
			)

			pnRow1 = pnRow1[2]
		ok

		if isList(pnRow2) and
			( Q(pnRow2).IsAndNamedParam() or
			  Q(pnRow2).IsAndRowNamedParam() or
			  Q(pnRow2).IsAndRowAtNamedParam() or
			  Q(pnRow2).IsAndRowAtPositionNamedParam()
			)

			pnRow2 = pnRow2[2]
		ok

		if AreBothNumbers(pnRow1, pnRow2)
			aCopyOfRow1 = This.Row(pnRow1)
			This.ReplaceRow(pnRow1, This.Row(pnRow2))
			This.ReplaceRow(pnRow2, aCopyOfRow1)
		ok

	  #-------------------------------------------------#
	 #   MOVING A COLUMN FROM A POSITION TO AN OTHER   #
	#-------------------------------------------------#

	def MoveCol(pnFrom, pnTo)

		# Checking the params correctness

		if isList(pnFrom) and
			 ( Q(pnFrom).IsFromNamedParam()  or
			   Q(pnFrom).IsFromPositionNamedParam() )

			pnFrom = pnFrom[2]
		ok

		if isList(pnTo) and
			( Q(pnTo).IsToNamedParam()  or
			  Q(pnTo).IsToPositionNamedParam() )

			pnTo = pnTo[2]
		ok

		if isString(pnFrom)

			if StzFind([
				:First, :FirstCol, :FirstColumn, :FirstPosition ], pnForm) > 0

				pnFrom = 1

			but StzFind([
				:Last, :LastCol, :LastColumn, :LastPosition ], pnFrom) > 0

				pnFrom = This.NumberOfCols()
			ok
		ok

		if isString(pnTo)

			if StzFind([
				:First, :FirstCol, :FirstColumn, :FirstPosition ], pnTo) > 0

				pnTo = 1

			but StzFind([
				:Last, :LastCol, :LastColumn, :LastPosition ], pnTo) > 0

				pnTo = This.NumberOfCols()
			ok
		ok

		if isString(pnFrom) and NOT This.HasColName(pnFrom)
			StzRaise("Incorrect column name!")
		ok

		if isString(pnTo) and NOT This.HasColName(pnTo)
			StzRaise("Incorrect column name!")
		ok

		pnFrom = This.ColToNumber(pnFrom)
		pnTo = This.ColToNumber(pnTo)

		# Doing the job

		aContent = @aContent

		if pnFrom != pnTo
			aCopy = @aContent[pnTo]
			aContent[pnTo] = @aContent[pnFrom]
			aContent[pnFrom] = aCopy
		ok

		This.UpdateWith(aContent)


		#< @FunctionAlternativeForm

		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

	def SwapcColNames(pCol1, pCol2)

		bCol1IsValid = ( isNumber(pCol1) and
				 pCol1 >= 1 and pCol1 <= This.NumberOfCol() )

		bCol2IsValid = ( isString(pCol2) and This.HasColName(pCol2) )

		if NOT ( bCol1IsValid or bCol2IsValid )
			StzRaise("Incorrect params! pCol1 and pCol2 must be valid columns names or strings.")
		ok

		cName1 = This.ColName(pCol1)
		cName2 = This.ColName(pCol2)

		nCol1 = This.ColNumber(pCol1)
		nCol2 = This.ColNumber(pCol2)

		aContent = @aContent
		aContent[nCol1][1] = cName2
		aContent[nCol2][1] = cName1

		This.UpdateWith(aContent)


		#< @FunctionAlternativeForm

		def SwapColumnNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

		def SwapColumnsNames(pcCol1, pcCol2)
			This.SwapcColNames(pcCol1, pcCol2)

		#>

	def SwapCol(pCol1, pCol2)
		if isList(pCol1) and
			( Q(pCol1).IsAndNamedParam() or
			  Q(pCol1).IsAndPositionNamedParam() or

			  Q(pCol1).IsAndcColNamedParam() or
			  Q(pCol1).IsAndColumnNamedParam() or

			  Q(pCol1).IsAndColAtNamedParam() or
			  Q(pCol1).IsAndColumnAtNamedParam() or

			  Q(pCol1).IsAndColAtPositionNamedParam() or
			  Q(pCol1).IsAndColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenNamedParam() or

			  Q(pCol1).IsBetweencColNamedParam() or
			  Q(pCol1).IsBetweenColumnNamedParam() or

			  Q(pCol1).IsBetweenColAtNamedParam() or
			  Q(pCol1).IsBetweenColumnAtNamedParam() or

			  Q(pCol1).IsBetweenColAtPositionNamedParam() or
			  Q(pCol1).IsBetweenColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenPositionNamedParam() or
			  Q(pCol1).IsBetweenPositionsNamedParam()
			)
			  #NOTE: I don't use IsOneOfTheseNamedParams() here
			  # to gain some performance by discarding eval()

			pCol1 = pCol1[2]
		ok

		if isList(pCol2) and
			( Q(pCol2).IsAndNamedParam() or
			  Q(pCol2).IsAndcColNamedParam() or
			  Q(pCol2).IsAndColumnNamedParam() or
			  Q(pCol2).IsAndColAtNamedParam() or
			  Q(pCol2).IsAndColumnAtNamedParam() or
			  Q(pCol2).IsAndColAtPositionNamedParam() or
			  Q(pCol2).IsAndColumnAtPositionNamedParam() or
			  Q(pCol2).IsAndcColNamedNamedParam() or
			  Q(pCol2).IsAndColumnNamedNamedParam()
			)

			pCol2 = pCol2[2]
		ok

		if This.ColNumber(pCol1) != This.ColNumber(pCol2)
			aCopyOfCol1 = This.Col(pCol1)
			This.ReplaceCol(pCol1, This.Col(pCol2) )
			This.ReplaceCol(pCol2, aCopyOfCol1)

			This.SwapcColNames(pCol1, pCol2)
		ok

		def SwapColums(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		#< @FunctionAlternativeForm

		def SwapColum(pCol1, pCol2)
			This.SwapCol(pCol1, pCol2)

		def SwapCols(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		def SwapColumns(pcCol1, pcCol2)
			This.SwapCol(pcCol1, pcCol2)

		#>

	  #=============================#
	 #   REPLACING A COLUMN NAME   #
	#=============================#

	def ReplaceNthColName(n, pcNewColName)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.ReplaceColName(n, pcNewColName)

	def ReplaceColName(pCol, pcNewColName)
		if isList(pcNewColName) and Q(pcNewColName).IsWithOrByNamedParam()
			pcNewColName = pcNewColName[2]
		ok

		if NOT isString(pcNewColName)
			StzRaise("Incorrect param type! pcNewColName must be a string.")
		ok

		if This.IsColName(pcNewColName)
			StzRaise("Can't replace the column with this name (" + pcNewColName + ")! Name you provided already exists.")
		ok

		aContent = @aContent
		n = This.ColNumber(pCol)
		@aContent[n][1] = pcNewColName
		This.UpdateWith(aContent)


		#< @FunctionAlternativeForm

		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

		#>

	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		nLen = ring_len(pacColNames)
		bResult = 1

		for i = 1 to nLen
			if NOT This.IsColName(pacColNames[i])
				bResult = 0
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForm

		def AreColumnNames(pacColNames)
			This.AreColNames(pacColNames)

		def AreColumnsNames(pacColNames)
			This.AreColNames(pacColNames)

		#>
