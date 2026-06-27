#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEFINDER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table finder subclass -- finding columns,   #
#                  rows by name, value, or position.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableFinder from stzTable

	def FindColByName(pcColName)

		if CheckingParams()

			if NOT isString(pcColName)
				StzRaise("Incorrect param type! pcColName must be a string.")
			ok

			if StzFindFirst([:First, :FirstCol, :FirstColumn], pcColName) > 0
				pcColName = This.FirstColName()

			but StzFindFirst([:Last, :LastCol, :LastColumn], pcColName) > 0
				pcColName = This.LastColName()
			ok

		ok

		pcColName = StzLower(pcColName)
		n = StzFindFirst( This.Header(), pcColName)
		return n

		#< @FunctionAlternativeForm

		def FindColumnByName(pcColName)
			return This.FindColByName(pcColName)

		def FindCol(pcColName)
			return This.FindColByName(pcColName)

		def FindColumn(pcColName)
			return This.FindColByName(pcColName)

		#>

	def FindColsByName(pacColNames)

		if CheckingParams()

			if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
				StzRaise("Incorrect param type! pacColNames must be a list of strings.")
			ok

			nLen = len(pacColNames)
			for i = 1 to nLen
				if pacColNames[i] = :First 	 or
				   pacColNames[i] = :FirstCol	 or
				   pacColNames[i] = :FirstColumn

					pacColNames[i] = This.FirstColName()

				but pacColNames[i] = :Last 	 or
				    pacColNames[i] = :LastCol	 or
				    pacColNames[i] = :LastColumn

					pacColNames[i] = This.LastColName()
				ok
			next

		ok

		anResult = Q( This.ColNames() ).FindMany(pacColNames)
		return anResult

		#< @FunctionAlternativeForm

		def FindColsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumnsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumnsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		#--

		def FindManyColsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumnsByNames(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumnsByName(pacColNames)
			return This.FindColsByName(pacColNames)

		#==

		def FindCols(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindColumns(pacColNames)
			return This.FindColsByName(pacColNames)

		#--

		def FindManyCols(pacColNames)
			return This.FindColsByName(pacColNames)

		def FindManyColumns(pacColNames)
			return This.FindColsByName(pacColNames)

		#>

	  #-----------------------------#
	 #  FINDING A COLUMN BY VALUE  #
	#-----------------------------#

	def FindColByValueCS(paColData, pCaseSensitive)
		if CheckingParams()
			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok
		ok

		anResult = This.ToStzHashList().FindValueCS(paColData, pCaseSensitive)
		return anResult

		def FindColumnByValueCS(paColData, pCaseSensitive)
			return This.FindColByValueCS(paColData, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindColByValue(paColData)
		return This.FindColByValueCS(paColData, 1)

		def FindColumnByValue(paColData)
			return This.FindColByValue(paColData)

	  #----------------------------------#
	 #  FINDING MANY COLUMNS BY VALUES  #
	#----------------------------------#

	def FindColsByValueCS(paManyColData, pCaseSensitive)

		if CheckingParams()

			if NOT ( isList(paManyColData) and Q(paManyColData).IsListOfLists() )
				StzRaise("Incorrect param type! paManyColData must be a list of lists.")
			ok

		ok

		paManyColData = U( paManyColData ) # Duplicates are removed

		nLen = len(paManyColData)
		anResult = []

		for i = 1 to nLen
			anPos = This.FindColByValueCS(paManyColData[i], pCaseSensitive)
			nLenPos = len(anPos)
			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = new stzList(anResult).Sorted()
		return anResult

		#< @FunctionAlternativeForms

		def FindColsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindColumnsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindColumnsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		#==

		def FindMAnyColsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColumnsByValueCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		def FindManyColumnsByValuesCS(paManyColData, pCaseSensitive)
			return This.FindColsByValueCS(paManyColData, pCaseSensitive)

		#>

	#-- WTIHOUT CASESENSITIVITY

	def FindColsByValue(paManyColData)
		return This.FindColsByValueCS(paManyColData, 1)

		#< @FunctionAlternativeForms

		def FindColsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindColumnsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindColumnsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		#==

		def FindMAnyColsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColumnsByValue(paManyColData)
			return This.FindColsByValue(paManyColData)

		def FindManyColumnsByValues(paManyColData)
			return This.FindColsByValue(paManyColData)

		#>

	  #-----------------------------------------------#
	 #  FINING COLUMNS BY NAME EXPET THOSE PROVIDED  #
	#===============================================#

	def FindColsExceptAt(panColNumbers)
		if CheckingParams()
			if NOT ( isList(panColNumbers) and @IsListOfLists(panColNumbers) )
				StzRaise("Incorrect param type! apnColNumbers must be a list of numbers.")
			ok
		ok

		anColNumbers = U(panColNumbers)
		nLen = len(@aContent)

		anResult = []

		for i = 1 to nLen
			if StzFindFirst(anColNumbers, i) = 0
				anResult + i
			ok
		next

		return anResult

		def FindColumnsExceptAt(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)

		def FindColsExceptPositions(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)

		def FindColumnsExceptPositions(panColNumbers)
			return This.FindColsExceptAt(panColNumbers)


	def FindColsExcept(paColNumbersOrColNames)
		if CheckingParams()
			if NOT isList(paColNumbersOrColNames)
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list.")
			ok

			if NOT ( @IsListOfNumbers(paColNumbersOrColNames) or
				 @IsListOfStrings(paColNumbersOrColNames) )
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list of numbers or a list of strings.")
			ok
		ok

		anResult = Q(1:This.NumberOfCols()) - These( This.FindCols(paColNumbersOrColNames) )
		// #TODO Make a more performant solution!

		return anResult

		#< @FunctionAlternativeForms

		def FindAllColsExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindColsOtherThan(paCols)
			return This.FindColsExcept(paCols)

		def FindColumnsExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColumnsExcept(paCols)
			return This.FindColumnsExcept(paCols)

		def FindColumnsOtherThan(paCols)
			return This.FindColumnsExcept(paCols)

		#--

		def FindColsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindColsByNameOtherThan(paCols)
			return This.FindColsExcept(paCols)

		def FindColumnsByNameExcept(paCols)
			return This.FindColsExcept(paCols)

		def FindAllColumnsByNameExcept(paCols)
			return This.FindColumnsExcept(paCols)

		def FindColumnsByNameOtherThan(paCols)
			return This.FindColumnsExcept(paCols)

		#>

	  #------------------------------------------------#
	 #  FINING COLUMNS BY VALUE EXPET THOSE PROVIDED  #
	#------------------------------------------------#

	def FindColsByValueExceptCS(paCols, pCaseSensitive)

		anResult = Q(1:This.NumberOfCols()) -
			   These( This.FindColsByValueCS(paCols, pCaseSensitive) )

		return anResult

		#< @FunctionAlternativeForms

		def FindAllColsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindColsByValueOtherThanCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindColumnsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColsByValueExceptCS(paCols, pCaseSensitive)

		def FindAllColumnsByValueExceptCS(paCols, pCaseSensitive)
			return This.FindColumnsByValueExceptCS(paCols, pCaseSensitive)

		def FindColumnsByValueOtherThanCS(paCols, pCaseSensitive)
			return This.FindColumnsByValueExceptCS(paCols, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindColsByValueExcept(paCols)
		return This.FindColsByValueExceptCS(paCols, 1)

		#< @FunctionAlternativeForms

		def FindAllColsByValueExcept(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindColsByValueOtherThan(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindColumnsByValueExcept(paCols)
			return This.FindColsByValueExcept(paCols)

		def FindAllColumnsByValueExcept(paCols)
			return This.FindColumnsByValueExcept(paCols)

		def FindColumnsByValueOtherThan(paCols)
			return This.FindColumnsByValueExcept(paCols)

		#>

	  #==============================#
	 #  FINDING A ROW BY ITS VALUE  #
	#==============================#

	def FindRowCS(paRow, pCaseSensitive)
		anResult = Q(This.Rows()).FindAllCS(paRow, pCaseSensitive)
		return anResult

	#-- WITHOUT CASESENSITIVITY

	def FindRow(paRow)
		return This.FindRowCS(paRow, 1)

	  #----------------------------------#
	 #  FINDINING NTH ROW BY ITS VALUE  #
	#----------------------------------#

	def FindNthRowCS(paRow, pCaseSensitive)
		nPos = Q(This.Rows()).FindNthCS(parow, pCaseSensitive)
		return nPos

		def FindNthOccurrenceOfRowCS(paRow, pCaseSensitive)
			return This.FindNthRowCS(paRow, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthRow(paRow)
		return This.FindNthRowCS(paRow, 1)

		def FindNthOccurrenceOfRow(paRow)
			return This.FindNthRow(paRow)

	  #----------------------------------------#
	 #  FINDINING MANYS ROWS BY THEIR VALUES  #
	#----------------------------------------#

	def FindRowsCS(paRows, pCaseSensitive)
		anResult = Q(This.Rows()).FindManyCS(paRows, pCaseSensitive)
		return anResult

		def FindManyRowsCS(paRows, pCaseSensitive)
			return This.FindRowsCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindRows(paRows)
		return This.FindRowsCS(paRows, 1)

		def FindManyRows(paRows)
			return This.FindRows(paRows)

	  #------------------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED - AS ROWS OR POSITIONS #
	#------------------------------------------------------------------#

	def FindRowsExceptCS(paRows, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(paRows) and ( @IsListOfNumbers(paRows) or @IsListOfLists(paRows) )  )
				StzRaise("Incorrect param type! paRows must be a list of numbers or a list of lists.")
			ok
		ok

		if @IsListOfNumbers(paRows)
			return This.FindRowsExceptAtCS(paRows, pCaseSensitive)

		else // @IsListOfLists
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)
		ok


		def FindAllRowsExceptCS(paRows, pCaseSensitive)
			return This.FindRowsExceptCS(paRows, pCaseSensitive)

		def FindRowsOtherThanCS(paRows, pCaseSensitive)
			return This.FindRowsExceptCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindRowsExcept(paRows)
		return This.FindRowsExceptCS(paRows, 1)

		def FindAllRowsExcept(paRows)
			return This.FindRowsExcept(paRows)

		def FindRowsOtherThan(paRows)
			return This.FindRowsExcept(paRows)

	  #------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (AS ROWS)  #
	#------------------------------------------------------#

	def FindRowsExceptTheseCS(paRows, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(paRows) and @IsListOfLists(paRows) )
				StzRaise("Incorrect param type! paRows must be a list of lists.")
			ok
		ok

		anPos = This.FindRowsCS(paRows, pCaseSensitive)
		nRows = This.NumberOfRows()

		anResult = []

		for i = 1 to nRows
			if StzFindFirst(anPos, i) = 0 and StzFindFirst(anResult, i) = 0
				anResult +i
			ok
		next

		return anResult

		def FindAllRowsExceptTheseCS(paRows, pCaseSensitive)
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)

		def FindRowsOtherThanTheseCS(paRows, pCaseSensitive)
			return This.FindRowsExceptTheseCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindRowsExceptThese(paRows)
		return This.FindRowsExceptTheseCS(paRows, 1)

		def FindAllRowsExceptThese(paRows)
			return This.FindRowsExceptThese(paRows)

		def FindRowsOtherThanThese(paRows)
			return This.FindRowsExceptThese(paRows)

	  #-----------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (ÙŽAS POSITIONS)  #
	#-----------------------------------------------------------#

	def FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)
		if CheckingParams()
			if NOT ( isList(panRowNumbers) and @IsListOfNumbers(panRowNumbers) )
				StzRaise("Incorrect param type! panRowNumbers must be a list of numbers.")
			ok
		ok

		nRows = This.NumberOfRows()

		anResult = []

		for i = 1 to nRows
			if StzFindFirst(panRowNumbers, i) = 0 and StzFindFirst(anResult, i) = 0
				anResult + i
			ok
		next

		return anResult

		def FindAllRowsExceptAtCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)

		def FindRowsOtherThanPositionsCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)

		def FindAllRowsExceptAtPositionsCS(panRowNumbers, pCaseSensitive)
			return This.FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def FindRowsExceptAt(panRowNumbers)
		return This.FindRowsExceptAtCS(panRowNumbers, 1)

		def FindAllRowsExceptAt(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindRowsOtherThanPositions(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindAllRowsExceptAtPosiitons(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)
