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

		_nLen_ = len(pacColNamesOrNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.Column(pacColNamesOrNumbers[i])
		next

		return _aResult_

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

		_nLen_ = len(paColNamesOrNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			p = paColNamesOrNumbers[i]
			_aResult_ + [ This.ColName(p), This.ColData(p) ]
		next

		return _aResult_

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

		_nCols_ = This.NumberOfCols()

		_bAllValid_ = 1
		_nPanColNumbersLen_ = len(panColNumbers)
		for _i = 1 to _nPanColNumbersLen_
			if panColNumbers[_i] < 1 or panColNumbers[_i] > _nCols_
				_bAllValid_ = 0
				exit
			ok
		next
		if NOT _bAllValid_
			StzRaise("Incorrect param type! numbers in panColNumbers must all be between 1 and " + _nCols_ + ".")
		ok

		panColNumbers  = new stzList(panColNumbers).Sorted()
		_nLenColNumbers_ = len(panColNumbers)

		pacColNames    = This.ColNames()

		_nNumCols_       = len(pacColNames)

		if len(panColNumbers) > _nNumCols_
			panColNumbers = Q(panColNumbers).Section( 1, _nNumCols_)
		ok

		_aResult_ = []

		for i = 1 to _nLenColNumbers_
			_aResult_ + pacColNames[panColNumbers[i]]
		next

		return _aResult_

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

		_nLen_ = len(panColNumbers)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.NthColName(panColNumbers[i])
		next

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETTING THE NUMBERS OF COLUMNS AS DEFINED BY THEIR GIVEN NAMES  #
	#------------------------------------------------------------------#

	def cColNamesToNumbers(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		_nLen_ = len(pacColNames)
		_anResult_ = []

		for i = 1 to _nLen_
			_n_ = This.FindColByName(pacColNames[i])
			_anResult_ + _n_
		next

		return _anResult_

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
			_aResult_ = []
			_nPacColNames1Len_ = len(pacColNames)
			for _iLoopPacColNames1_ = 1 to _nPacColNames1Len_
				_cColName_ = pacColNames[_iLoopPacColNames1_]
				_aResult_ + [ _cColName_, This.Col(_cColName_) ]
			next

			return _aResult_
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

		_aResult_ = []
		_nLen_ = len(panRowsNumbers)

		for i = 1 to _nLen_
			_aResult_ + This.Row(panRowsNumbers[i])
		next

		return _aResult_

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

		_nLen_ = len(apnRowsNumbers)

		_aResult_ = []
		_nLen1Len_ = len(_nLen_)
		for _iLoopLen1_ = 1 to _nLen1Len_
			_n_ = _nLen_[_iLoopLen1_]
			_aResult_ + This.RowZ(panRowsNumbers[i])
		next

		return _aResult_

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

		_aRowCopy_ = This.Row(pnTo)
		This.ReplaceRow(pnTo, This.Row(pnFrom))
		This.ReplaceRow(pnFrom, _aRowCopy_)

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
			_aCopyOfRow1_ = This.Row(pnRow1)
			This.ReplaceRow(pnRow1, This.Row(pnRow2))
			This.ReplaceRow(pnRow2, _aCopyOfRow1_)
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

			if StzFindFirst([
				:First, :FirstCol, :FirstColumn, :FirstPosition ], pnForm) > 0

				pnFrom = 1

			but StzFindFirst([
				:Last, :LastCol, :LastColumn, :LastPosition ], pnFrom) > 0

				pnFrom = This.NumberOfCols()
			ok
		ok

		if isString(pnTo)

			if StzFindFirst([
				:First, :FirstCol, :FirstColumn, :FirstPosition ], pnTo) > 0

				pnTo = 1

			but StzFindFirst([
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

		_aContent_ = @aContent

		if pnFrom != pnTo
			_aCopy_ = @aContent[pnTo]
			_aContent_[pnTo] = @aContent[pnFrom]
			_aContent_[pnFrom] = _aCopy_
		ok

		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForm

		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

	def SwapcColNames(pCol1, pCol2)

		_bCol1IsValid_ = ( isNumber(pCol1) and
				 pCol1 >= 1 and pCol1 <= This.NumberOfCol() )

		_bCol2IsValid_ = ( isString(pCol2) and This.HasColName(pCol2) )

		if NOT ( _bCol1IsValid_ or _bCol2IsValid_ )
			StzRaise("Incorrect params! pCol1 and pCol2 must be valid columns names or strings.")
		ok

		_cName1_ = This.ColName(pCol1)
		_cName2_ = This.ColName(pCol2)

		_nCol1_ = This.ColNumber(pCol1)
		_nCol2_ = This.ColNumber(pCol2)

		_aContent_ = @aContent
		_aContent_[_nCol1_][1] = _cName2_
		_aContent_[_nCol2_][1] = _cName1_

		This.UpdateWith(_aContent_)


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
			_aCopyOfCol1_ = This.Col(pCol1)
			This.ReplaceCol(pCol1, This.Col(pCol2) )
			This.ReplaceCol(pCol2, _aCopyOfCol1_)

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

	def ReplaceNthColName(_n_, pcNewColName)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.ReplaceColName(_n_, pcNewColName)

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

		_aContent_ = @aContent
		_n_ = This.ColNumber(pCol)
		@aContent[_n_][1] = pcNewColName
		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForm

		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

		#>

	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		_nLen_ = len(pacColNames)
		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT This.IsColName(pacColNames[i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionAlternativeForm

		def AreColumnNames(pacColNames)
			This.AreColNames(pacColNames)

		def AreColumnsNames(pacColNames)
			This.AreColNames(pacColNames)

		#>
