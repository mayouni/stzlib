#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZTABLE			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing tables in SoftanzaLib      #
#	Version		: V1.0 (2020-2023)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*

TODO: Get inspiration from this article to manage duplicated data in stzTable:
https://docs.getdbt.com/blog/how-we-remove-partial-duplicates

TODO: Get insipration of realworld use cases and features from this article
describing the difference between NumPy and Pandas (Pyhthon ecosystem):
https://betterprogramming.pub/pandas-illustrated-the-definitive-visual-guide-to-pandas-c31fa921a43

#TODO (Future): use Apache Arrow as a C++ backend for stzLargeTable
# https://arrow.apache.org/

	Apache Arrow is a software development platform for
	building high performance applications that process
	and transport large data sets. It is designed to both
	improve the performance of analytical algorithms and
	the efficiency of moving data from one system or
	programming language to another.

	A critical component of Apache Arrow is its in-memory
	columnar format, a standardized, language-agnostic
	specification for representing structured, table-like
	datasets in-memory. This data format has a rich data
	type system (included nested and user-defined data types)
	designed to support the needs of analytic database
	systems, data frame libraries, and more.

#TODO: Add support of Excel functions (see at the bottom of the file)

#TODO: Add Paging feature

#TODO : Support SQL statements

*/

func StzTableQ(paTable)
	return new stzTable( paTable )

Class stzTable from stzObject
	@aContent = []

	# Table content is stored as a hashlist where keys are col names
	# EXAMPLE:
	# 	[
	# 		[ "COL1", [ "A", "B", "C" ] ],
	# 		[ "COL2", [ "a", "b", "c" ] ],
	# 		[ "COL3", [ "1", "2", "3" ] ]
	# 	]

	# This choice is made firstly, because columns have names and
	# rows have'nt. But mainly, to enable (future) data analytics and
	# data science operations on tables of data, where variables are
	# always represented as columns.

	def init(paTable)

		# A table can be created in 6 different ways

		if NOT isList(paTable)
			StzRaise("Incorrect param format! paTable must be a list.")
		ok

		if len(paTable) = 0 or Q(paTable).IsPairOfNumbers()
	
		# Way 1: new stzTable([])
		#--> Creates an empty table with just a column and a row

		# Way 2: new stzTable([3, 4])
		#--> Creates a table of 3 columns and 4 rows, all cells are empty

		# Both ways (1 and 2) are made by the following code:
		
			nCols = 1
			nRows = 1

			if  Q(paTable).IsPairOfNumbers()
				nCols = paTable[1]
				nRows = paTable[2]
			ok

			aRow = []
			for i = 1 to nRows
				aRow + NULL
			next

			for i = 1 to nCols
				@aContent + [ "COL"+i, aRow ]
			next

			return

		but Q(paTable).ItemsAreListsOfSameSize() and
		    Q(paTable[1]).IsListOfStrings()

		# Way 3 (the more natural way) The table is described in a
		# a list of lists that mimics the realworld presentation
		# of a table (first line represents colums, and the other
		# lines represent rows):

		# o1 = new stzTable([
		# 	[ :ID,	 :EMPLOYEE,    	:SALARY	],
		# 	#-------------------------------#
		# 	[ 10,	 "Ali",		35000	],
		# 	[ 20,	 "Dania",	28900	],
		# 	[ 30,	 "Han",		25982	],
		# 	[ 40,	 "Ali",		12870	]
		# ])
			nLen = len(paTable[1])

			for i = 1 to nLen
				cCol = paTable[1][i]
				@aContent + [ cCol, [] ]
			next
			#--> [
			# 	:ID       = [],
			# 	:EMPLOYEE = [],
			# 	:SALARY   = []
			#    ]

			for r = 2 to len(paTable)
				i = 0
				nLen = len(paTable[r])

				for i = 1 to nLen
					@aContent[i][2] + paTable[r][i]
				next
			next

			return

		but Q(paTable).ItemsAreListsOfSameSize() and
		    Q(paTable).IsNotHashList()

		# WAY 4: Similar to way 3 but the line of column names is
		# not provided. Means that you privided only the rows of
		# your table!
		#--> Softanza accepts the rows and adds automatically the
		# column names as :COL1, :COL2, :COL3...

		# EXAMPLE:
		# o1 = new stzTable([
		# 	[ 10,	 "Ali",		35000	],
		# 	[ 20,	 "Dania",	28900	],
		# 	[ 30,	 "Han",		25982	],
		# 	[ 40,	 "Ali",		12870	]
		# ])

			aTempTable = []

			acColNames = []
			for i = 1 to len(paTable[1])
				acColNames + ("col" + i)
			next
				

			insert(paTable, 0, acColNames)
			This.Init(paTable)
			return

		but Q(paTable).IsHashList()
		# Way 5: The table is provided in the same format of how
		# it is implemented in this class: a hashlist.
		# ~> the most performant way!

		# EXAMPLE:

		# o1 = new stzTable([
		#  	:NAME   = [ "Ali", 	  "Dania", 	"Han" 	 ],
		#  	:JOB    = [ "Programmer", "Manager", 	"Doctor" ],
		# 	:SALARY = [ 35000, 	  50000, 	62500    ]
		# ])
		
		# o1.Show()
		#--> 	#    NAME          JOB   SALARY
		# 	1     Ali   Programmer    35000
		# 	2   Dania      Manager    50000
		# 	3     Han       Doctor    62500

			# We need a supplemenatary check here of the case
			# where the values of the hashlist are not list
			# So for example, if the use provides:

			# o1 = new stzTable([ [ "i", 1 ], [ "ring", 4 ], [ "language", 8 ] ])
			# where 1, 4 and 8 are not lists...

			# It should be transformed to:

			# o1 = new stzTable([ [ "i", [1] ], [ "ring", [4] ], [ "language", [8] ] ])

			nLen = len(paTable)
			@aContent = []

			for i = 1 to nLen
				if isList(paTable[i][2])
					@aContent + [ paTable[i][1], paTable[i][2] ]
				else
					aTemp = []
					aTemp + paTable[i][2]
					@aContent + [ paTable[i][1], aTemp ]
				ok
			next

		but isList(paTable) and Q(paTable).IsFromFileNamedParam()
		# Way 5: The table is created from the content of a text file

		#  ~> The first line of the file corrspond the column names

		#  ~> If the first line is empty or contains a type other then
		#     string, then Softanza adds column names :COL1, :COL2, etc.

		#  ~> The lines are separated by a NL
		#  ~> The cells are separated by a ;
		#  ~> Numbers and lists are imported in their native types
		#  ~> Lists in the file must be in the form [item1,item2,item3]

			# Reading the data from the file

			cData = ring_read(paTable[2])
			#TODO should we close the file handle?

			# If the file is empty, make an empty table
			#TODO should we raise an error instead?

			if ring_trim(cData) = ""
				@aContent = [ :COL1 = [ ] ]
				return
			ok

			# Splitting the lines

			acLines = ring_split(cData, NL)
			nLen = len(acLines)

			# Checking the first line

			cLine1 = acLines[1]

			bColNamesProvided = TRUE

			if ring_trim(cLine1) = ""
				bColNamesProvided = FALSE

			else

				acLine1Splits = ring_split(cLine1, ";")
				nLen1 = len(acLine1Splits)

				bMadeOfStrings = TRUE
				for i = 1 to nLen1
					if @IsNumberInString(acLine1Splits[i]) or
					   @IsListInString(acLine1Splits[i])
	
						bMadeOfStrings = FALSE
						exit
					ok
				next

				if NOT bMadeOfStrings 
					bColNamesProvided = FALSE
				ok
			ok
			#NOTE
			# ~> we will use bColNamesProvided later while
			# constructing the header of the table

			# Doing the job

			anLens = []
			aTable = []

			for i = 1 to nLen
				if acLines[i] = ""
					i++
				ok

				acLine = ring_split(acLines[i], ";")

				nLenLine = len(acLine)
				anLens + nLenLine
				nMin = Min(anLens)

				aRow = []

				for j = 1 to nMin

					cell = acLine[j]

					if @IsNumberInString(cell)
						cellValue = 0+ cell

					but @IsListInString(cell)
						cCode = 'cellValue = ' + cell
						eval(cCode)

					else
						cellValue = cell
					ok

					aRow + cellValue

				next

				aTable + aRow

			next

			# Construction the table content

			# Defining the minimal number or rows provided

			nLenTable = len(aTable)
			nMin = 0
			if nLenTable > 1
				nMin = len(aTable[1])
			ok

			for i = 2 to nLenTable
				nLenTemp = len(aTable[i])
				if nLenTemp < nMin
					nMin = nLenTemp
				ok
			next

			# Composing the header of the table

			for i = 1 to nMin
				if bColNamesProvided
					@aContent + [ aTable[1][i], [] ]
				else
					@aContent + [ "col"+i, [] ]
				ok
			next

			# Composing the rows of the table

			jStart = 1
			if bColNamesProvided
				jStart = 2
			ok

			for i = 1 to nMin
				for j = jStart to nLenTable
					@aContent[i][2] + aTable[j][i]
				next
			next

		else
			# If the param provided don't fit in any of the ways above
			StzRaise("Incorrect param format! There are 5 possible ways in creating a table. " +
				 "None fits with the param you provided. Check the code/comments under " +
				 "stzTable.Init() method.")
		ok

	def Content()
		return @aContent

		def Table()
			return This.Content()

			def TableQ()
				return new stzList( This.Table() )

		def Value()
			return Content()

	
	def Copy()
		oCopy = new stzTable(This.Content())
		return oCopy

	def IsEmpty()
		if This.CellsQ().AllItemsAreNull()
			return TRUE

		else
			return FALSE
		ok
	
	  #================================================#
	 #   CHECHKING IF THE TABLE HAS GIVEN COLUMN(S)   #
	#================================================#

	def HasColumName(pcName)
		cName = StzStringQ(pcName).Lowercased()
		bResult = This.ColNamesQ().Contains(cName)

		return bResult

		#< @FunctionAlternativeForms

		def HasColName(pcName)
			return This.HasColumName(pcName)

		def HasCol(pcName)
			return This.HasColumName(pcName)

		def HasColumn(pcName)
			return This.HasColumName(pcName)

		#--

		def ContainsColumName(pcName)
			return This.HasColumName(pcName)

		def ContainsColName(pcName)
			return This.HasColumName(pcName)

		#>

	def HasColumnsNames(pacNames)
		nLen = len(pacNames)
		bResult = TRUE
		for i = 1 to nLen
			if NOT This.HasColName(pacNames[i])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def HasColNames(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasColumns(pacNames)
			return This.HasColumnsNames(pacNames)

		def HasCols(pacNames)
			return This.HasColumnsNames(pacNames)

		#--

		def ContainsColumnsNames(pacNames)
			return This.HasColumnsNames(pacNames)

		def ContainsColNames(pacNames)
			return This.HasColumnsNames(pacNames)

		#>

	  #-------------------------------#
	 #   GETTING NUMBER OF COULMNS   #
	#-------------------------------#

	def NumberOfColumns()
		nResult = len( This.Table() )
		return nResult

		def NumberOfCols()
			return This.NumberOfColumns()

		def NumberOfCol()
			return This.NumberOfColumns()

	  #---------------------------------#
	 #   GETTING THE LIST OF COULMNS   #
	#---------------------------------#

	def ColumnsNames()
		return This.ToStzHashList().Keys()

		#< @FunctionFluentForm

		def ColumnsNamesQ()
			return This.ColumnsQR( :stzList )

		def ColumnsNamesQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ColumnsNames() )

			on :stzListOfStrings
				return new stzListOfStrings( This.ColumnsNames() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.ColumnsNames() )

			on :stzListOfLists
				return new stzListOfLists( This.ColumnsNames() )

			on :stzListOfPairs
				return new stzListOfPairs( This.ColumnsNames() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def AllColumnsNames()
			return This.ColumnsNames()

			def AllColumnsNamesQ()
				return This.AllColumnsNamesQ()

			def AllColumnsNamesQR(pcReturnType)
				return This.ColumnsNamesQR(pcReturnType)

		def ColumnNames()
			return This.ColumnsNames()

			def ColumnNamesQ()
				return This.ColumnsNamesQ()

			def ColumnNamesQR(pcReturnType)
				return This.ColumnsNamesQR(pcReturnType)

		def AllColumnNames()
			return This.ColumnsNames()

			def AllColumnNamesQ()
				return This.ColumnsNamesQ()

			def AllColumnNamesQR(pcReturnType)
				return This.ColumnsNamesQR(pcReturnType)

		def ColsNames()
			return This.ColumnsNames()

			def ColsNamesQ()
				return This.ColumnsNamesQ()

			def ColsNamesQR(pcReturnType)
				return This.ColumnsNamesQR(pcReturnType)

		def AllColsNames() # Useful by contrast to TheseCols(paCols)
			return This.ColumnsNames()

			def AllColsNamesQ()
				return This.ColsNamesQR(:stzList)

			def AllColsNamesQR(pcReturnType)
				return This.ColsNamesQR(pcReturnType)

		def ColNames()
			return This.ColumnsNames()

			def ColNamesQ()
				return This.AllColsNamesQR(:stzList)

			def ColNamesQR(pcReturnType)
				return This.ColsNamesQR(pcReturnType)

		def AllColNames()
			return This.ColumnsNames()

			def AllColNamesQ()
				return This.AllColsNamesQR(:stzList)

			def AllColNamesQR(pcReturnType)
				return This.ColsNamesQR(pcReturnType)

		def Header()
			return This.ColumnsNames()

			def HeaderQ()
				return This.HeaderQ()

			def HeaderQR(pcReturnType)
				return This.HeaderQR(pcReturnType)

		#>

	  #====================================================#
	 #  CHECKING IF THE PROVIDED STRING IS A COLUMN NAME  #
	#====================================================#

	def IsColName(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		cName = Q(pcName).Lowercased()

		bResult = FALSE
		if This.ColNamesQ().Contains(pcName)
			bResult = TRUE
		ok

		return bResult

		#< @FunctionAlternativeForm

		def IsColumnName(pcName)
			return This.IsColName(pcName)

		#>

	  #------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED NUMBER IS A COLUMN NUMBER  #
	#------------------------------------------------------#

	def IsColNumber(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if n < 1 or n > This.NumberOfCols()
			return FALSE
		else
			return TRUE
		ok

		def IsColumnNumber(n)
			return This.IsColNumber(n)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED VALUE IS A COLUMN NUMBER OR NAME  #
	#-------------------------------------------------------------#

	def IsColNameOrNumber(pCol)

		if ( isString(pCol) and This.IsColName(pCol) ) or
		   ( isNumber(pCol) and This.IsColNumber(pCol) )
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def IsCol(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColmun(pcol)
			return This.IsColNameOrNumber(pCol)

		def IsColNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#--

		def IsColumnNameOrNumber(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColumnNumberOrName(pCol)
			return This.IsColNameOrNumber(pCol)

		def IsColumnIdentifier(pCol)
			return This.IsColNameOrNumber(pCol)

		#>

	  #---------------------------------------------------------------#
	 #  CHECKING IF THE PROVIDED VALUES ARE COLUMN NUMBERS OR NAMES  #
	#---------------------------------------------------------------#

	def AreColNamesOrNumbers(paCols)
		oTemp = Q(paCols)

		if NOT ( isList(paCols) and
			( oTemp.IsListOfNumbers() or
			  oTemp.IsListOfStrings() or
			  oTemp.IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be of list of numbers or strings.")
		ok

		bResult = TRUE
		nLen = len(paCols)

		for i = 1 to nLen
			if NOT This.IsColNameOrNumber(paCols[i])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def AreColNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColID(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#--

		def AreColumnNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)		

		#==

		def AreColsNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColsNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColsIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#--

		def AreColumnsNamesOrNumbers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnsNumbersOrNames(paCols)
			return This.AreColNamesOrNumbers(paCols)

		def AreColumnsIdentifiers(paCols)
			return This.AreColNamesOrNumbers(paCols)

		#>

  	  #================================#
	 #  FINDING A COLUMN BY ITS NAME  #
	#================================#

	def FindColByName(pcColName)

		if CheckParams()

			if NOT isString(pcColName)
				StzRaise("Incorrect param type! pcColName must be a string.")
			ok

		
			if Q(pcColName).IsOneOfThese([:First, :FirstCol, :FirstColumn])
				pcColName = This.FirstColName()

			but Q(pcColName).IsOneOfThese([:Last, :LastCol, :LastColumn])
				pcColName = This.LastColName()
			ok

		ok

		pcColName = Q(pcColName).Lowercased()
		n = ring_find( This.Header(), pcColName)
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

		if CheckParams()

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
		if CheckParams()
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
		return This.FindColByValueCS(paColData, TRUE)

		def FindColumnByValue(paColData)
			return This.FindColByValue(paColData)

	  #----------------------------------#
	 #  FINDING MANY COLUMNS BY VALUES  #
	#----------------------------------#

	def FindColsByValueCS(paManyColData, pCaseSensitive)

		if CheckParams()

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

		anResult = ring_sort(anResult)
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
		return This.FindColsByValueCS(paManyColData, TRUE)

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
		if CheckParams()
			if NOT ( isList(panColNumbers) and @IsListOfLists(panColNumbers) )
				StzRaise("Incorrect param type! apnColNumbers must be a list of numbers.")
			ok
		ok

		anColNumbers = U(panColNumbers)
		nLen = len(@aContent)

		anResult = []

		for i = 1 to nLen
			if ring_find(anColNumbers, i) = 0
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
		if CheckParams()
			if NOT isList(paColNumbersOrColNamesOrColData)
				StzRaise("Incorrect param type! paColNumbersOrColNamesOrColData must be a list.")
			ok

			if NOT ( @IsListOfNumbers(paColNumbersOrColNamesOrColData) or
				 @IsListOfStrings(paColNumbersOrColNamesOrColData) )
				StzRaise("Incorrect param type! paColNumbersOrColNames must be a list of numbers or a list of strings.")
			ok
		ok

		anResult = Q(1:This.NumberOfCols()) - These( This.FindCols(paColNumbersOrColNames) )

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
		return This.FindColsByValueExceptCS(paCols, TRUE)

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
		return This.FindRowCS(paRow, TRUE)

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
		return This.FindNthRowCS(paRow, TRUE)

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
		return This.FindRowsCS(paRows, TRUE)

		def FindManyRows(paRows)
			return This.FindRows(paRows)

	  #------------------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED - AS ROWS OR POSITIONS #
	#------------------------------------------------------------------#

	def FindRowsExceptCS(paRows, pCaseSensitive)
		if CheckParams()
			if NOT isList(paRows) and ( @IsListOfNumbers(paRows) or @IsListOfLists(paRows) ) 
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
		return This.FindRowsExceptCS(paRows, TRUE)

		def FindAllRowsExcept(paRows)
			return This.FindRowsExcept(paRows)

		def FindRowsOtherThan(paRows)
			return This.FindRowsExcept(paRows)

	  #------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (AS ROWS)  #
	#------------------------------------------------------#

	def FindRowsExceptTheseCS(paRows, pCaseSensitive)
		if CheckParams()
			if NOT ( isList(paRows) and @IsListOfLists(paRows) )
				StzRaise("Incorrect param type! paRows must be a list of lists.")
			ok
		ok

		anPos = This.FindRowsCS(paRows, pCaseSensitive)
		nRows = This.NumberOfRows()

		anResult = []

		for i = 1 to nRows
			if ring_find(anPos, i) = 0 and ring_find(anResult, i) = 0
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
		return This.FindRowsExceptTheseCS(paRows, TRUE)

		def FindAllRowsExceptThese(paRows)
			return This.FindRowsExceptThese(paRows)

		def FindRowsOtherThanThese(paRows)
			return This.FindRowsExceptThese(paRows)

	  #-----------------------------------------------------------#
	 #  FINDINING ROWS OTHER THAN THOSE PROVIDED (َAS POSITIONS)  #
	#-----------------------------------------------------------#

	def FindRowsExceptAtCS(panRowNumbers, pCaseSensitive)
		if CheckParams()
			if NOT ( isList(panRowNumbers) and @IsListOfNumbers(panRowNumbers) )
				StzRaise("Incorrect param type! panRowNumbers must be a list of numbers.")
			ok
		ok

		nRows = This.NumberOfRows()

		anResult = []

		for i = 1 to nRows
			if ring_find(panRowNumbers, i) = 0 and ring_find(anResult, i) = 0
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
		return This.FindRowsExceptAtCS(panRowNumbers, TRUE)

		def FindAllRowsExceptAt(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindRowsOtherThanPositions(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

		def FindAllRowsExceptAtPosiitons(panRowNumbers)
			return This.FindRowsExceptAt(panRowNumbers)

	  #===============================================#
	 #   GETTING A COLUMN DATA (IN A LIST OF CELLS)  #
	#===============================================#

	def Col(p)

		if isString(p)
			oTemp = Q(p)
			if oTemp.IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but oTemp.IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfColumns()

			but This.HasColName(p)
				p = This.FindCol(p)
			ok
		ok

		aResult = This.VerticalSection( p, 1, This.NumberOfRows() )

		return aResult

		#< @FunctionFluentForm

		def ColQ(p)
			return This.ColQR(p, :stzList)

		def ColQR(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Col(p) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Col(p) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Col(p) )

			on :stzListOfLists
				return new stzListOfLists( This.Col(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Col(p) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Col(p) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Col(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def Column(p)
			return This.Col(p)

			def ColumnQ(p)
				return This.ColumnQR(p, :stzList)

			def ColumnQR(p, pcReturnType)
				return This.ColQR(p, pcReturnType)

		def ColumnData(p)
			return This.Col(p)

			def ColumnDataQ(p)
				return This.ColumnQR(p, :stzList)

			def ColumnDataQR(p, pcReturnType)
				return This.ColQR(p, pcReturnType)

		def ColData(p)
			return This.Col(p)

			def ColDataQ(p)
				return This.ColumnQR(p, :stzList)

			def ColDataQR(p, pcReturnType)
				return This.ColQR(p, pcReturnType)

		def CellsInCol(p)
			return This.Col(p)

			def CellsInColQ(p)
				return This.CellsInColQR(p, :stzList)

			def CellsInColQR(p, pcReturnType)
				return This.CellsInColQR(p, pcReturnType)

		def CellsInColumn(p)
			return This.Col(p)

			def CellsInColumnQ(p)
				return This.CellsInColumnQR(p, :stzList)

			def CellsInColumnQR(p, pcReturnType)
				return This.CellsInColumnQR(p, pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE PROVIDED COLUMNS  #
	#-----------------------------------------------------#

	def CellsInCols(paCols)

		if NOT ( isList(paCols) and
			Q(paCols).IsListOfNumbersOrStrings() and
			This.AreColumnsIdentifiers(paCols))

			StzRaise("Incorrect param type! paCols must be a list of string containing existing columns names.")
		ok

		nLen = len(paCols)

		aResult = []
		for i = 1 to nLen
			aResult + This.CellsInCol(paCols[i])
		next

		aResult = Q(aResult).Flattened()
		return aResult

	  #------------------------------------------------#
	 #  GETTING THE COLUMN NAME AND THE COLUMN CELLS  #
	#------------------------------------------------#

	def ColXT(p)
		aResult = [ This.ColName(p) ]

		aCells = This.Col(p)
		nLen = len(aCells)

		for i = 1 to nLen
			aResult + aCells[i]
		next

		return aResult

		#< @FunctionFluentForm

		def ColXTQ(p)
			return This.ColXTQR(p, :stzList)

		def ColXTQR(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ColXT(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.COlXT(p) )

			on :stzListOfLists
				return new stzListOfLists( This.ColXT(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ColumnXT(p)
			return This.ColXT(p)

			def ColumnXTQ(p)
				return This.ColumnXTQR(p, :stzList)

			def ColumnXTQR(p, pcReturnType)
				return This.ColXTQR(p, pcReturnType)

		def CellsInColXT(p)
			return This.ColXT(p)

			def CellsInColXTQ(p)
				return This.CellsInColXTQR(p, :stzList)

			def CellsInColXTQR(p, pcReturnType)
				return This.CellsInColXTQR(p, pcReturnType)

		def CellsInColumnXT(p)
			return This.ColXT(p)

			def CellsInColumnXTQ(p)
				return This.CellsInColumnXTQR(p, :stzList)

			def CellsInColumnXTQR(p, pcReturnType)
				return This.CellsInColumnXTQR(p, pcReturnType)

		#>

	  #=========================================#
	 #   GETTING TTHE NAME OF THE NTH COLUMN   #
	#=========================================#

	def NthColName(n)
		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				n = This.NumberOfColumns()

			else
				StzRaise("syntax error in (" + n + ")! Allowed values are :First or :Last ( or :FirstCol or :LastCol).")

			ok
		ok

		cResult = This.ColNames()[n]

		return cResult

		def NthColumnName(n)
			return This.NthColName(n)

	  #------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE NTH COLUMN   #
	#------------------------------------------------#

	def NthCol(n)
		return This.Col(n)

		def NthColumn(n)
			return This.NthCol(n)

		def CellsInNthCol(n)
			return This.NthCol(n)

		def CellsInNthColumn(n)
			return This.NthCol(n)

		def NthColData(n)
			return This.NthCol(n)

		def NthColumnData(n)
			return This.NthCol(n)

	  #-------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF NTH COLUMN ALONG WITH ITS CELLS  #
	#-------------------------------------------------------------------------#

	def NthColXT(n)
		if isString(n)
			if n = :first or n = :FirstCol or n = :FirstColumn
				n = 1

			but n = :Last or n = :LastCol or n = :LastColumn
				n = This.NumberOfCol()
			ok
		ok

		return This.ColXT(n)

		def NthColumnXT(n)
			return This.ColXT(n)

		def CellsInNthColXT(n)
			return This.ColXT(n)

		def CellsInNthColumnXT(n)
			return This.ColXT(n)

		def CellsInNthColAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInColNAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInNthColumnAndTheirPositions(n)
			return This.ColXT(n)

		def CellsInColumnNAndTheirPositions(n)
			return This.ColXT(n)
		
	  #----------------------------------------#
	 #  GETTING THE NAME OF THE FIRST COLUMN  #
	#========================================#

	def FirstColName()
		return This.NthColName(1)

		def FirstColumnName()
			return This.FirstColName()

	  #------------------------------------------------------#
	 #   GETTING FIRST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#------------------------------------------------------#

	def FirstCol()
		return This.NthCol(1)

		def FirstColumn()
			return This.FirstCol()

		def FirstColData()
			return This.FirstCol()

		def FirstColumnData()
			return This.FirstCol()

	  #---------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF FIRST COLUMN ALONG WITH IST CELLS  #
	#---------------------------------------------------------------------------#

	def FirstColXT()
		return This.NthCOlXT(1)

		def FirstColumnXT()
			return This.FirstColXT()


	  #---------------------------------------#
	 #  GETTING THE NAME OF THE LAST COLUMN  #
	#=======================================#

	def LastColName()
		return This.NthColName(This.NumberOfCols())

		def LastColumnName()
			return This.LastColName()

	  #-----------------------------------------------------#
	 #   GETTING LAST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#-----------------------------------------------------#

	def LastCol()
		return This.NthCol(This.NumberOfCols())

		def LastColumn()
			return This.LastCol()

		def LastColData()
			return This.LastCol()

		def LastColumnData()
			return This.LastCol()

	  #--------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF LAST COLUMN ALONG WITH IST CELLS  #
	#--------------------------------------------------------------------------#

	def LastColXT()
		return This.NthCOlXT(This.NumberOfCols())

		def LastColumnXT()
			return This.LastColXT()

	  #=======================#
	 #  GETTING COLUMN NAME  #
	#=======================#

	def ColName(n)
		if isString(n)
			if This.HasColName(n)
				return n
			else
				StzRaise("Incorrect column name! The name you provided does not exist.")
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLenCols = len(@aContent)
			
		if n < 1 or n > nLenCols
			StzRaise("Index out of range! n must is not a valid number of column.")
		ok

		cResult = @aContent[n][1]
		return cResult

		def ColNameQ(n)
			return new stzString( This.ColName(n) )

		def ColumnName(n)
			return This.ColName(n)

			def ColumnNameQ(n)
				return new stzString( This.ColumnName(n) )

	  #--------------------------------------------------------#
	 #  GETTING CELLS AND THEIR POSITIONS IN A GIVEN COLUMN   #
	#--------------------------------------------------------#

	def CellsAndPositionsInCol(p)
		aResult = This.ColQ(p).AssociatedWith( This.CellsInColAsPositions(p) )

		return aResult

		#< @FunctionFluentForm

		def CellsAndPositionsInColQ(p)
			return This.CellsAndPositionsInColQR(p, :stzList)

		def CellsAndPositionsInColQR(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.CellsAndPositionsInCol(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.CellsAndPositionsInCol(p) )

			on :stzListOfLists
				return new stzListOfLists( This.CellsAndPositionsInCol(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInColumn(p)
			return This.CellsAndPositionsInCol(p)

			def CellsAndPositionsInColumnQ(p)
				return This.CellsAndPositionsInColumnQR(p, :stzList)

			def CellsAndPositionsInColumnQR(p, pcReturnType)
				return This.CellsAndPositionsInColQR(p, pcReturnType)

		def ColZ(p)
			return This.CellsAndPositionsInCol(p)

			def ColZQ(p)
				return This.ColZQR(p, :stzList)

			def ColZQR(p, pcReturnType)
				return This.CellsAndPositionsInColQR(p, pcReturnType)

		def CellsInColZ(p)
			return This.CellsAndPositionsInCol(p)

			def CellsInColZQ(p)
				return This.ColZQR(p, :stzList)

			def CellsInColZQR(p, pcReturnType)
				return This.CellsAndPositionsInColQR(p, pcReturnType)

		#>

	  #----------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN COLUMN   #
	#----------------------------------------------------------#

	def ColAsPositions(pCol)
		if NOT This.IsCol(pCol)
			StzRaise("Incorrect param value! " + @@(pCol) + " is not a valid column identifier.")
		ok

		nCol = This.ColToColNumber(pCol)

		nNumberOfRows = This.NumberOfRows()

		aResult = []

		for i = 1 to nNumberOfRows
			aResult + [ nCol, i]
		next

		return aResult

		#< @FunctionAlternativeForms

		def ColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#==

		def PositionsOfCellsInCol(pCol)
			return This.ColAsPositions(pCol)

		def PositionsOfCellsInColumn(pCol)
			return This.ColAsPositions(pCol)

		#==

		def CellsToColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def ColToPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		#>

	  #--------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY COLUMNS   #
	#--------------------------------------------------------#

	def ColsAsPositions(paCols)
		nLen = len(paCols)
		anColNumbers = This.TheseColsAsNumbers(paCols)
		aResult = []

		for i = 1 to nLen
			aCellsPos = This.CellsInColAsPositions(anColNumbers[i])
			nLenCells = len(aCellsPos)

			for j = 1 to nLenCells
				aResult + aCellsPos[j]
			next
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColumnsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def PositionsOfCellsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def PositionsOfCellsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def CellsToColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInCols(pCol)
			return This.ColsAsPositions(pCol)

		def ColsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#>

	  #==============================#
	 #  GETTING THE CELLS OF A ROW  #
	#==============================#

	def Row(n)

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstRow ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastRow ])
				n = This.NumberOfRows()

			ok
		ok

		aResult = This.HorizontalSection( n, 1, This.NumberOfCols() )
		return aResult

		#< @FunctionFluentForm

		def RowQ(n)
			return This.RowQR(n, :stzList)

		def RowQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(n) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(n) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def RowN(n)
			return This.Row(n)

			def RowNQ(n)
				return This.RownQR(n, :stzList)

			def RowNQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def NthRow(n)
			return This.Row(n)

			def NthRowQ(n)
				return This.NthRowQR(n, :stzList)

			def NthRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInRow(n)
			return This.Row(n)

			def CellsInRowQ(n)
				return This.CellsInRowQR(n, :stzList)

			def CellsInRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInRowN(n)
			return This.Row(n)

			def CellsInRowNQ(n)
				return This.CellsInRowNQR(n, :stzList)

			def CellsInRowNQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)

		def CellsInNthRow(n)
			return This.Row(n)

			def CellsInNthRowQ(n)
				return This.CellsInNthRowQR(n, :stzList)

			def CellsInNthRowQR(n, pcReturnType)
				return This.CellsInRowQR(n, pcReturnType)
		#>

	  #----------------------------------#
	 #  GETTING THE CELLS OF MANY ROWS  #
	#----------------------------------#

	def CellsInRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers.")
		ok

		aResult = This.TheseCells(RowsAsPositions(panRows))
		return aResult

	  #-----------------------#
	 #   GETTING FIRST ROW   #
	#-----------------------#

	def FirstRow()
		return This.NthRow(1)

	def FirstRowXT()
		return This.NthRowXT(1)

	  #----------------------#
	 #   GETTING LAST ROW   #
	#----------------------#

	def LastRowXT()
		return This.NthRowXT(This.NumberOfRows())

	def LastRow()
		return This.NthRow(This.NumberOfRows())

	  #--------------------------------#
	 #   GETTING THE NUMBER OF ROWS   #
	#--------------------------------#

	def NumberOfRows()
		nResult = len(This.Table()[1][2])
		return nResult

		def Size()
			return NumberOfRows()

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

	def Rows()
		nRows   = This.NumberOfRows()
		aResult = []

		for i = 1 to nRows
			aResult + This.RowN(i)
		next

		return aResult

		def RowsQ()
			return This.RowsQR(:stzList)

		def RowsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Rows() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Rows() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Rows() )

			on :stzListOfChars
				return new stzListOfChars( This.Rows() )

			on :stzListOfLists
				return new stzListOfLists( This.Rows() )

			on :stzListOfHashLists
				return new stzListOfHashLists( This.Rows() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Rows() )

			on :stzListOfSets
				return new stzListOfSets( This.Rows() )

			on :stzListOfObjects
				return new stzListOfNumbers( This.Rows() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def AllRows() # In contrast with TheseRows(panRows)
			return This.Rows()

			def AllRowsQ()
				return This.AllRowsQR(:stzList)

			def AllRowsQR(pcReturnType)
				return This.RowsQR(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #   GETTING CELLS AND THEIR POSITIONS IN A GIVN ROW   #
	#-----------------------------------------------------#

	def RowZ(n)
		aResult = RowQ(n).AssociatedWith( This.CellsInRowAsPositions(n) )
		return aResult		

		#< @FunctionFluentForm

		def RowZQ(n)
			return This.RowZQR(p, :stzList)

		def RowZQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowZ(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowZ(n) )

			on :stzListOfLists
				return new stzListOfLists( This.RowZ(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInRow(n)
			return This.RowZ(n)

			def CellsAndPositionsInRowQ(n)
				return This.CellsAndPositionsInRowNQR(n, :stzList)

			def CellsAndPositionsInRowQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def CellsInRowZ(n)
			return This.RowZ(n)

			def CellsInRowZQ(n)
				return This.CellsInRowZQR(n, :stzList)

			def CellsInRowZQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def CellsInRowNAndTheirPositions(n)
			return This.RowZ(p)

			def CellsInRowNAndTheirsPositionsQ(n)
				return This.CellsInRowNAndTheirsPositionsQR(n, :stzList)

			def CellsInRowNAndTheirsPositionsQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)
		
		def CellsAndPositionsInRowN(n)
			return This.RowZ(n)

			def CellsAndPositionsInRowNQ(n)
				return This.CellsAndPositionsInRowNQR(n, :stzList)

			def CellsAndPositionsInRowNQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def CellsAndPositionsInNthRow(n)
			return This.RowZ(p)

			def CellsAndPositionsInNthRowQ(n)
				return This.CellsAndPositionsInNthRowQR(n, :stzList)

			def CellsAndPositionsInNthRowQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def CellsInNthRowAndTheirPositions(n)
			return This.RowZ(p)

			def CellsInNthRowAndTheirPositionsQ(n)
				return This.CellsInNthRowAndTheirPositionsQR(n, :stzList)

			def CellsInNthRowAndTheirPositionsQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def RowNZ(n)
			return This.RowZ(n)

			def RowNZQ(n)
				return This.RowNZQR(n, :stzList)

			def RowNZQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		def NthRowZ(n)
			return This.RowZ(n)

			def NtRowZQ(n)
				return This.NthRowZQR(n, :stzList)

			def NthRowZQR(n, pcReturnType)
				return This.RowZQR(n, pcReturnType)

		#>

	  #-------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN ROW   #
	#-------------------------------------------------------#

	def RowAsPositions(pnRow)
		if CheckParams()

			if isString(pnRow)
				if pnRow = :First or pnRow = :FirstRow
					pnRow = 1
	
				but pnRow = :Last or pnRow = :LastRow
					pnRow = This.NumberOfRows()
				ok
			ok
	
			if NOT isNumber(pnRow)
				StzRaise("Incorrect param type! pnRow must be a number.")
			ok

		ok

		nNumberOfCols = This.NumberOfCols()
		aResult = []

		for i = 1 to nNumberOfCols
			aResult + [ i, pnRow ]
		next

		return aResult

		#< @Alternativefunctions

		def CellsInRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		#==

		def CellsInThisRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInThisRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInThisRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def RowToCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#>
	  #----------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY ROWS  #
	#----------------------------------------------------#

	def RowsAsPositions(panRows)
		nNumberOfCols = This.NumberOfCols()
		nLenRows = len(panRows)

		aResult = []

		for i = 1 to nLenRows
	
			for j = 1 to nNumberOfCols
				aResult + [ j, panRows[i] ]
			next
	
		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		#==

		def CellsInTheseRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInTheseRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInTheseRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def RowsToCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		#>

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
			if Q(pCol).IsOneOfThese([:First, :FirstCol, :FirstColumn])
				pCol = 1

			but Q(pCol).IsOneOfThese([:Last, :LastCol, :LastColumn])
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
		return This.CellCSXT(pCellCol, pCellRow, pExpr, pValueORSubValue, TRUE)

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
			return TheseCellsQR(paCellsPos, :stzList)

		def TheseCellsQR(paCellsPos, pcReturnType)
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

			def CellsAtPositionsQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def CellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def CellsAtQ(paCellsPos)
				return This.CellsAtPositions(paCellsPos, :stzList)

			def CellsAtQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def TheseCellsAt(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtQ(paCellsPos)
				return This.TheseCellsAt(paCellsPos, :stzList)

			def TheseCellsAtQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		def TheseCellsAtPositions(paCellsPos)
			return This.TheseCells(paCellsPos)

			def TheseCellsAtPositionsQ(paCellsPos)
				return This.TheseCellsAtPositions(paCellsPos, :stzList)

			def TheseCellsAtPositionsQR(paCellsPos, pcReturnType)
				return This.TheseCellsQR(paCellsPos, pcReturnType)

		#>

	  #---------------------------------#
	 #  GETIING THE LIST OF ALL CELLS  #
	#---------------------------------#

	def Cells()

		aResult = This.Section( [ :FirstCol, :FirstRow ], [ :LastCol, :LastRow ] )
		return aResult

		#< @FunctionFluentForm

		def CellsQ()
			return This.CellsQR(:stzList)

		def CellsQR(pcReturnType)
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
				return This.CellsQR(:stzList)

			def AllCellsQR(pcReturnType)
				return This.CellsQR(pcReturnType)

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
			return This.CellsToHashListQR( :stzList )

		def CellsToHashListQR(pcReturnType)
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
				return This.CellsAsHashListQR(:stzList)

			def CellsAsHashListQR(pcReturnType)
				return This.CellsToHashListQR(pcReturnType)

		#>

	def TheseCellsToHashList(paCellsPos)
		#TODO: check if paCells are really cells and belong to the table!

		aResult = []
		nLen = len(paCellsPos)

		for i = 1 to nLen
			cellPos = paCellsPos[i]
			aResult + [ @@(cellPos), This.Cell(cellPos[1], cellPos[2]) ]
		next

		return aResult

		#< @FunctionFluentForm

		def TheseCellsToHashListQ(paCellsPos)
			return This.TheseCellsToHashListQR(paCellsPos, pcReturnType)

		def TheseCellsToHashListQR(paCellsPos, pcReturnType)
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
				return This.TheseCellsAsHashListQR(paCellsPos, pcReturnType)

			def TheseCellsAsHashListQR(paCellsPos, pcReturnType)
				return This.TheseCellsToHashListQR(paCellsPos, pcReturnType)

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
				StzRaise("Unsupported return type!")
			off

		#>
		
	def SectionZ( panCellPos1, panCellPos2 )
		
		aResult = This.SectionAsPositionsQ(panCellPos1, panCellPos2).
			       AssociatedWith( This.Section(panCellPos1, panCellPos2) )

		return aResult

		#< @FunctionFluentForms

		def SectionZQ( panCellPos1, panCellPos2 )
			return This.SectionZQR( panCellPos1, panCellPos2, :stzList )

		def SectionZQR( panCellPos1, panCellPos2, pcReturnType )
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

			def SectionAndPositionQR( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQR( panCellPos1, panCellPos2, pcReturnType )
	
		def SectionAndItsPosition( panCellPos1, panCellPos2 )
			return This.SectionZ( panCellPos1, panCellPos2 )

			def SectionAndItsPositionQ( panCellPos1, panCellPos2 )
				return This.SectionZQ( panCellPos1, panCellPos2 )

			def SectionAndItsPositionQR( panCellPos1, panCellPos2, pcReturnType )
				return This.SectionZQR( panCellPos1, panCellPos2, pcReturnType )
	
		#>

	def SectionAsPositions( panCellPos1, panCellPos2 )
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

		ok

		if NOT ( isList(panCellPos1) and Q(panCellPos1).IsPairOfNumbers() and
			 isList(panCellPos2) and Q(panCellPos2).IsPairOfNumbers() )

			StzRaise("Incorrect params types! panCellPos1 and panCellPos2 must be pairs of numbers.")
		ok

		anPairs = Q([ panCellPos1, panCellPos2 ]).SortedInAscending()
		nCol1   = anPairs[1][1]
		nRow1   = anPairs[1][2]
		nCol2   = anPairs[2][1]
		nRow2   = anPairs[2][2]

		aResult = []
		for u = nRow1 to nRow2
			for v = nCol1 to nCol2
				aResult + [ v, u ]
			next v
		next u
	
		return aResult

		#< @FunctionFluentForm

		def SectionAsPositionsQ( panCellPos1, panCellPos2 )
			return This.SectionAsPositionsQR( panCellPos1, panCellPos2, :stzList )

		def SectionAsPositionsQR( panCellPos1, panCellPos2, pcReturnType )
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

	  #-----------------------------------------------------#
	 #   VERTICAL SECTIONS (SOME CELLS OF A GIVEN COLUMN)  #
	#-----------------------------------------------------#

	def VerticalSection(pCol, n1, n2)

		aCellsPos =  This.VerticalSectionAsPositions(pCol, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

	def VerticalSectionAsPositions(pCol, n1, n2)
		if isList(n1) and Q(n1).IsFromNamedParam()
			n1 = n1[2]
		ok

		if isList(n2) and Q(n2).IsToNamedParam()
			n2 = n2[2]
		ok

		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
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

		aResult = []
		for i = n1 to n2
			aResult + [pCol, i]
		next

		return aResult

	  #----------------------------------------------------#
	 #   HORIZONTAL SECTIONS (SOME CELLS OF A GIVEN ROW)  #
	#----------------------------------------------------#

	def HorizontalSection(nRow, n1, n2)
		aCellsPos =  This.HorizontalSectionAsPositions(nRow, n1, n2)
		aResult = This.CellsAtPositions(aCellsPos)

		return aResult

	def HorizontalSectionAsPositions(nRow, n1, n2)
		if isString(nRow)
			if Q(nRow).IsOneOfThese([ :First, :FirstRow ])
				pRow = 1

			but Q(nRow).IsOneOfThese([ :Last, :LastRow ])
				nRow = This.NumberOfRows()

			ok
		ok

		if NOT isNumber(nRow)
			StzRaise("Incorrect param type! nRow must be a number.")
		ok

		if isString(n1)
			if Q(n1).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n1 = 1
			ok
		ok

		if NOT isNumber(n1)
			StzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if Q(n2).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				n2 = This.NumberOfCols()
			ok
		ok

		if NOT isNumber(n2)
			StzRaise("Incorrect param type! n2 must be a number.")
		ok

		aResult = []
		for i = n1 to n2
			aResult + [i, nRow]
		next

		return aResult

	  #----------------------------------------#
	 #   FIRST CELL AND LAST CELL POSITIONS   #
	#----------------------------------------#

	def FirstCellPosition()
		return [1, 1]

	def LastCellPosition()
		return [ This.NumberOfCol(), This.NumberOfRows() ]

	  #-------------------------------------------------#
	 #   CONVERTING A SECTION OF CELLS TO A HASHLIST   #
	#-------------------------------------------------#

	def SectionToHashList(panCellPos1, panCell2)
		aResult = TheseCellsToHashList( This.SectionAsPositions(panCellPos1, panCell2) )
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
				StzRaise("Unsupported return type!")
			off		

	  #============================#
	 #  GETTING A RANGE OF CELLS  #
	#============================#

	// TODO

	def SectionToRange(paSection) // TODO
		aResult = []
		/* ... */

		return aResult

	def Range(paPair, paRange) // TODO
		/* ... */

	/// WORKING ON TABLE /////////////////////////////////////////////////////////////////

	  #==================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==================================================================================#

	def FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.FindAll("Ali") // or o1.FindAll( :Cells = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? o1.FindAll( :SubValue = "A" )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1] ]
		     ]
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([
				:Cell, :OfCell, :Value, :OfValue,
				:CellValue, :OfCellValue, :Of ])

				return This.FindCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([
					:SubValue, :OfSubValue,
					:Part, :OfPart, :CellPart, :OfCellPart,
					:SubPart, :OfSubPart ])

				return This.FindSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		else
			return This.FindCellCS(pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForms

		def FindCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindAllOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def PositionsCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAll(pCellValueOrSubValue)
		return This.FindAllCS(pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms

		def Find(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)

		def FindAllOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)		
	
		def FindOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
	
		def Occurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		
		def Positions(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		#>

	  #--------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL IN THE TABLE  #
	#--------------------------------------------------#

	def FindCellCS(pCellValue, pCaseSensitive)
		aResult = StzListOfListsQ( This.Cols() ).FindInListsCS(pCellValue, pCaseSensitive)
		return aResult	

		#< @FunctionAlternativeForms
			
		def OccurrencesOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def PositionsOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		#--

		def FindValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)
			
		def OccurrencesOfValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCell(pValue)
		return This.FindCellCS(pValue, TRUE)

		#< @FunctionAlternativeForms

		def OccurrencesOfCell(pValue)
			return This.FindCell(pValue)

		def PositionsOfCell(pValue)
			return This.FindCell(pValue)

		#--
	
		def FindValue(pCellValue)
			return This.FindCell(pCellValue)
					
		def OccurrencesOfValue(pCellValue)
			return This.FindCell(pCellValue)
	
		#>
	
	  #-----------------------------------#
	 #  FINDING MANY CELLS IN THE TABLE  #
	#-----------------------------------#

	def FindCellsCS(paValues, pCaseSensitive)
		if CheckParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		paValues = StzListQ(paValues).WithoutDuplicationCS(pCaseSensitive)
		nLen = len(paValues)

		aResult = []

		for i = 1 to nLen
			aTemp = This.FindCellCS(paValues[i], pCaseSensitive)
			nLen = len(aTemp)

			for j = 1 to nLen
				aResult + aTemp[j]
			next
		next

		return aResult

		def FindValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCellsCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCells(paValues)
		return This.FindCellsCS(paValues, TRUE)

		def FindValues(paValues)
			return This.FindCells(paValues)

		def FindMany(paValues)
			return This.FindCells(paValues)

		def FindManyCells(paValues)
			return This.FindCells(paValues)

		def FindManyValues(paValues)
			return This.FindCells(paValues)

	  #-------------------------------------------#
	 #  FINDING ALL CELLS EXCEPT THOSE PROVIDED  #
	#-------------------------------------------#

	def FindCellsExceptCS(paValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindCellsExcept(paValues)
		return This.FindCellsExceptCS(paValues, TRUE)

	  #------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN SUBVALUE IN THE TABLE  #
	#------------------------------------------------------#

	def FindSubValueCS(pSubValue, pCaseSensitive)
		bCheckCase = FALSE
		if @IsStringOrList(pSubValue)
			bCheckCase = TRUE
		ok

		aCellsXT = This.CellsAndTheirPositions()

		aResult = []
		for i = 1 to len(aCellsXT)
			cellValue = aCellsXT[i][1]
			oCellValue = Q(cellValue)

			aCellPos  = aCellsXT[i][2]

			bCellIsString = isString(cellValue)
			bCellIsListOfStrings = isList(cellValue) and oCellValue.IsListOfStrings()


			if bCheckCase
				if bCellIsString = TRUE or bCellIsListOfStrings = TRUE

					if oCellValue.ContainsCS(pSubValue, pCaseSensitive)
						aResult + [ aCellPos, oCellValue.FindAllCS(pSubValue, pCaseSensitive) ]
					ok
				ok
			else

				if isList(cellValue) and oCellValue.Contains(pSubValue)
					aResult + [ aCellPos, oCellValue.FindAll(pSubValue) ]
				ok
			ok
		next

		return aResult

		#< @FuntionAlternativeForm

		def PositionsOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubValue(pSubValue)
		return This.FindSubValueCS(pSubValue, TRUE)

		#< @FuntionAlternativeForm

		def PositionsOfSubValue(pSubValue)
			return This.FindSubValue(pSubValue)

		#>

	  #-------------------------------------------#
	 #  FINFING MANY SUBVALUES INSIDE THE TABLE  #
	#-------------------------------------------#

	def FindSubValuesCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindSubValues(paSubValues)
		return This.FindSubValuesCS(paSubValues, TRUE)

	  #-----------------------------------------------#
	 #  FINFING ALL SUBVALUES EXCEPT THOSE PROVIDED  #
	#-----------------------------------------------#

	def FindSubValuesExceptCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindSubValuesExcept(paSubValues)
		return This.FindSubValuesExceptCS(paSubValues, TRUE)

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#---------------------------------------------------------------------------------------#

	def FindNthCS(n, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindNthValueCS(n, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindNthSubValueCS(n, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok

		else
			return This.FindNthValueCS(n, pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(n, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthCS(n, pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNth(n, pCellValueOrSubValue)
		return This.FindNthCS(n, pCellValueOrSubValue, TRUE)
	
		def FindNthOccurrence(n, pCellValueOrSubValue)
			return This.FindNth(n, pCellValueOrSubValue)	

	  #-------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------#

	def FindNthCellCS(n, pCellValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence ])
				n = This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = []

		aFoundCells = This.FindCellCS(pCellValue, pCaseSensitive)

		if n > 0 and n <= len(aFoundCells)
			aResult = aFoundCells[n]
		ok	

		return aResult

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfCellCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		def FindNthValueCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueCS(n, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(n, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthCell(n, pValue)
		return This.FindNthCellCS(n, pValue, TRUE)

		#< @FunctionAlternativeForms
	
		def FindNthOccurrenceOfCell(n, pCellValue)
			return This.FindNthCell(n, pCellValue)
	
		def FindNthValue(n, pCellValue)
			return This.FindNthCell(n, pCellValue)
	
		def FindNthOccurrenceOfValue(n, pCellValue)
			return This.FindNthCell(n, pCellValue)
	
		#>

	  #-----------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------#
	
	def FindNthSubValueCS(n, pSubValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence ])
				n = This.CountSubValueCS(pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindSubValueCS(pSubValue, pCaseSensitive)

		nLen = len(anPos)

		aResult = []
		m = 0
		for i = 1 to nLen
			line = anPos[i]
			for j = 1 to len(line[2])
				m += 1
				if m = n
					aResult = [ line[1], line[2][j] ]
					exit 2
				ok
			next
		next

		return aResult
			
		def FindNthOccurrenceOfSubValueCS(n, pSubValue, pCaseSensitive)
			return This.FindNthSubValueCS(n, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValue(n, pSubValue)
		return This.FindNthSubValueCS(n, pSubValue, TRUE)

		def FindNthOccurrenceOfSubValue(n, pSubValueValue)
			return This.FindNthSubValue(n, pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindFirstCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindFirstCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindFirstSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstCellCS(pCellValueOrSubValue, pCaseSensitive)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstCS(pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirst(pCellValueOrSubValue)
		return This.FindFirstCS(pCellValueOrSubValue, TRUE)
	
		def FindFirstOccurrence(pCellValueOrSubValue)
			return This.FindFirst(pCellValueOrSubValue)	

	  #---------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL VALUE IN THE TABLE  #
	#---------------------------------------------------------#

	def FindFirstCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(1, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstCell(pValue)
		return This.FindFirstCellCS(pValue, TRUE)

		def FindFirstOccurrenceOfCell(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstOccurrenceOfValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
	  #-------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-------------------------------------------------------#

	def FindFirstSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(1, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindFirstSubValueCS(pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValue(pSubValue)
		return This.FindFirstSubValueCS(pSubValue, TRUE)

		def FindFirstOccurrenceOfSubValue(pSubValueValue)
			return This.FindFirstSubValue(pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindLastCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindLastCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindLastSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastCellCS(pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastCS(pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLast(pCellValue)
		return This.FindLastCS(pCellValue, TRUE)
	
		def FindLastOccurrence(pCellValue)
			return This.FindLast(pCellValue)	

	  #-------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE  #
	#-------------------------------------------#

	def FindLastCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(:Last, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastCell(pValue)
		return This.FindLastCellCS(pValue, TRUE)

		def FindLastOccurrenceOfCell(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastOccurrenceOfValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
	  #-----------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE  #
	#-----------------------------------------#

	def FindLastSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(:Last, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindLastSubValueCS(pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValue(pSubValue)
			return This.FindLastSubValueCS(pSubValue, TRUE)

			def FindLastOccurrenceOfSubValue(pSubValueValue)
				return This.FindLastSubValue(pSubValue)

	  #==========================================================================================#
	 #  GETTING NUMBER OF OCCURRENCE A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==========================================================================================#

	def NumberOfOccurrenceCS(pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrence( :OfCell = "Ali" ) #--> 2
		? o1.NumberOfOccurrence( :OfSubValue = "A" ) #--> 3
		*/

		if isList(pValue)
			if Q(pValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Cells, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrenceOfCellCS(pValue[2], pCaseSensitive)

			but Q(pValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrenceOfSubValueCS(pValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def CountCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrenceCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrence(pValue)
		return This.NumberOfOccurrenceCS(pValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		def Count(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowMany(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrence(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		#>

	  #-------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellCS(pCellValue, pCaseSensitive)
		return len( This.FindCellCS(pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#==

		def HowManyCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCell(pCellValue)
		return This.NumberOfOccurrenceOfCellCS(pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def NumberOfOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def HowManyCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#>

	  #-----------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		aPos = This.FindSubValueCS(pSubValue, pCaseSensitive)
		nLen = len(aPos)

		nResult = 0

		for i = 1 to nLen
			nResult += len(aPos[i][2])
		next

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValue(pSubValue)
		return This.NumberOfOccurrenceOfSubValueCS(pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#--

		def HowManyOccurrenceOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrenceOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#>

	   #------------------------------------------------------------------#
	  #  GETTING NUMBER OF OCCURRENCE OF A GIVEN CELL VALUE OR SUBVALUE  #
	 #  IN THE GIVEN CELL(S) OR COL(S) OR ROW(S)                        #
	#------------------------------------------------------------------#

	def NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzTable([

		])

		? o1.NumberOfOccurrenceXT( :InCol = :NAME, :OfSubValue = "Ali" )
		*/

		if NOT isList(pInCellsOrColOrRow)
			StzRaise("Incorrect param type! pInCellsOrColOrRow must be a list.")
		ok

		nResult = 0

		oTempList = new stzList(pInCellsOrColOrRow)
		if oTempList.IsInCellNamedParam()
			coll = pInCellsOrColOrRow[2][1]
			nRow = pInCellsOrColOrRow[2][2]
			nResult = This.NumberOfOccurrenceInCellCS(coll, nRow, pValueOrSubValue, pCaseSensitive)

		but oTempList.IsInCellsNamedParam()
			nResult = This.NumberOfOccurrenceInCellsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but oTempList.IsInColNamedParam()
			nResult = This.NumberOfOccurrenceInColCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but oTempList.IsInColsNamedParam()
			nResult = This.NumberOfOccurrenceInColsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but oTempList.IsInRowNamedParam()
			nResult = This.NumberOfOccurrenceInRowCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but oTempList.IsInRowsNamedParam()
			nResult = This.NumberOfOccurrenceInRowsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		else
			StzRaise("Syntax error! pInCellsOrColOrRow must be one of these lists ( :InCells = ..., :InCol = ..., or :InRow = ...).")

		ok

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def CountCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)
		return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def CountXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		#>

	  #=============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A CELL  #
	#=============================================================================#

	def ContainsCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Dan", "Ali", "Sam" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.Contains( :Cell = "Ali" ) #--> TRUE
		? o1.Contains( :SubValue = "a" ) #--> TRUE
		*/

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :Value ])
				return This.ContainsCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :Part, :CellPart ])
				return This.ContainsSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.ContainsCellCS(pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY
	
		def Contains(pCellValueOrSubValue)
			return This.ContainsCS(pCellValueOrSubValue, TRUE)

	def ContainsCellCS(pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def ContainsValueCS(pCellValue, pCaseSensitive)
			return This.ContainsCellCS(pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsCell(pCellValue)
			return This.ContainsCellCS(pCellValue, TRUE)

			def ContainsValue(pCellValue)
				return This.ContainsCell(pCellValue)

	  #-----------------------------------------------#
	 #  CHECKING IF THE TABBLE CONTAINS A GIVEN ROW  #
	#-----------------------------------------------#

	def ContainsRowCS(paRow, pCaseSensitive)
		bResult = FALSE

		if isList(paRow) and len(paRow) = This.NumberOfRows()

			bResult = This.RowsQ().ContainsCS(paRow, pCaseSensitive)
		ok

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsRow(paRow)
		return This.ContainsRowCS(paRow, TRUE)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN ROWS  #
	#-------------------------------------------------#

	def ContainsRowsCS(paRows, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCols([
			[ 10, "Imed", 52  ],
			[ 30, "Karim", 48 ]
		])

		#--> TRUE
		*/

		bResult = TRUE
		nLen = len(paRows)

		for i = 1 to nLen
			if NOT This.ContainsRowCS(paRows[i], pCaseSensitive)
				bResult = FALSE
				exit
			ok

		next

		return bResult

		def ContainsTheseRowsCS(paRows, pCaseSensitive)
			return This.ContainsRowsCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsRows(paRows)
		return This.ContainsRowsCS(paRows, TRUE)

		def ContainsTheseRows(paRows)
			return This.ContainsRows(paRows)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN COLUMN  #
	#-------------------------------------------------#

	def ContainsColCS(paCol, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
		#--> TRUE
		*/

		bResult = FALSE

		if isList(paCol) and len(paCol) = 2 and
		   isString(paCol[1]) and This.HasColName(paCol[1]) and
		   isList(paCol[2]) and len(paCol[2]) = This.NumberOfRows()

			cCol = paCol[1]
			bResult = This.ColQ(cCol).IsEqualToCS(paCol[2], pCaseSensitive)
		ok

		return bResult

		def ContainsColumnCS(paCol, pCaseSensitive)
			return This.ContainsColCS(paCol, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsCol(paCol)
		return This.ContainsColCS(paCol, TRUE)

		def ContainsColumn(paCol)
			return This.ContainsCol(paCol)

	  #----------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN COLUMNS  #
	#----------------------------------------------------#

	def ContainsColsCS(paCols, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? o1.ContainsCols([
			:NAME = [ "Imed", "Hatem", "Karim" ],
			:AGE  = [ 52, 46, 48 ]
		])

		#--> TRUE
		*/

		bResult = TRUE
		nLen = len(paCols)

		for i = 1 to nLen
			if NOT This.ContainsColCS(paCols[i], pCaseSensitive)
				bResult = FALSE
				exit
			ok

		next

		return bResult

		def ContainsTheseColsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsTheseColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsCols(paCols)
		return This.ContainsColsCS(paCols, TRUE)

		def containsTheseCols(paCols)
			return This.ContainsCols(paCols)

		def ContainsColumns(paCols)
			return This.ContainsCols(paCol)

		def ContainsTheseColumns(paCols)
			return This.ContainsCols(paCol)

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS CELLS THAT INCLUDE A GIVEN SUBVALUE  #
	#----------------------------------------------------------------------#

	def ContainsSubValueCS(pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#-- WITHOUT CASESENSITIVITY

	def ContainsSubValue(pSubValue)
		return This.ContainsSubValueCS(pSubValue, TRUE)


	/// WORKING ON SOME CELLS //////////////////////////////////////////////////

	  #=====================================================#
	 #  FINDING A GIVEN VALUE OR SUBVALUE IN A GIVEN CELL  #
	#=====================================================#

	def FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		bValue = FALSE
		bSubValue = TRUE

		if isList(pCellValueOrSubValue)
			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				bValue = TRUE
				bSubValue = FALSE

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				bValue = FALSE
				bSubValue = TRUE
			ok
		
		ok

		if bValue
			bResult = This.CellQ(pCellCol, pCellRow).IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
			return bResult

		else // bSubValue

			anResult = []

			oCell = This.CellQ(pCellCol, pCellRow)

			if @IsStzFindable(oCell)
				anResult = oCell.FindCS(pCellValueOrSubValue, pCaseSensitive)

			ok

			return anResult
		ok

	#-- WITHOUT CASESENSITIVITY

	def FindInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, TRUE)

	  #---------------------------------------------#
	 #  FINDING A GIVEN VALUE INSIDE A GIVEN CELL  #
	#---------------------------------------------#

	def FindValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :Value = pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCell(pCellCol, pCellRow, pValue)
		return This.FindValueInCellCS(pCellCol, pCellRow, pValue, TRUE)

	  #------------------------------------------------#
	 #  FINDING A GIVEN SUBVALUE INSIDE A GIVEN CELL  #
	#------------------------------------------------#

	def FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :SubValue = pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, TRUE)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN A GIVEN NUMBER OF CELLS  #
	#================================================================================================#

	def FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPairs() )
			StzRaise("Incorrect param type! paCells must be a list of pairs.")
		ok

		bValue = FALSE
		bSubValue = TRUE

		if isList(pCellValueOrSubValue)

			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])

				bValue = TRUE
				bSubValue = FALSE
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])

				bValue = FALSE
				bSubValue = TRUE
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			ok

		ok

		nLen = len(paCells)
		aResult = []

		if bValue

			for i = 1 to nLen
				cellValue = This.Cell(paCells[i][1], paCells[i][2])
				oCell = Q(cellValue)

				if @BothAreNumbers(cellValue, pCellValueOrSubValue)

					if cellValue = pCellValueOrSubValue
						aResult + paCells[i]
					ok

				but @BothAreStrings(cellValue, pCellValueOrSubValue) or
				    @BothAreLists(cellValue, pCellValueOrSubValue)
				
					if oCell.IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
						aResult + paCells[i]
					ok

				but @BothAreStzObjects( cellValue, pCellValueOrSubValue)

					if oCell.IsEqualTo(pCellValueOrSubValue)
						aResult + paCells[i]
					ok

				ok
			next

		else // bSubValue

			for i = 1 to nLen
				aPos = This.FindSubValueInCellCS(paCells[i][1], paCells[i][2], pCellValueOrSubValue, pCaseSensitive)
				if len(aPos) > 0
					aResult + [ paCells[i], aPos ]
				ok
			next
		ok

		return aResult
				
		#< @FunctionAlternativeForms

		def FindAllOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def PositionsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllInCells(paCells, pCellValueOrSubValue)

		return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def FindAllOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def FindOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def OccurrencesInCells(pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
		
		def PositionsInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		def FindInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		#>

	  #--------------------------------------------#
	 #  FINDING A VALUE IN A GIVEN LIST OF CELLS  #
	#--------------------------------------------#

	def FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		aCellsXT = This.TheseCellsAndTheirPositions(paCells)

		aResult = []

		for i = 1 to len(aCellsXT)

			CellValue = aCellsXT[i][1]
			aCellPos  = aCellsXT[i][2]

			if @BothAreNumbers(cellValue, pCellValue)
				if cellValue = pCellValue
					aResult + aCellPos
				ok

			but @BothAreStrings(cellValue, pCellValue) or
			    @BothAreLists(cellValue, pCellValue)

				if Q(CellValue).IsEqualToCS(pCellValue, pCaseSensitive)
					aResult + aCellPos
				ok

			but @BothAreStzObjects(cellValue, pCellValue)

				if Q(cellValue).IsEqualTo(pCellValue)
					aResult + aCellPos
				ok
			ok
		next

		return aResult

		#< @FunctionAlternativeForms
			
		def OccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def PositionsOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(ppaCells, CellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCells(pValue)
		return This.FindValueInCellsCS(pValue, TRUE)
			
		def OccurrencesOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(paCells, pCellValue)

		def PositionsOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(ppaCells, CellValue)
	
	  #-----------------------------------------------#
	 #  FINDING A SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-----------------------------------------------#

	def FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		aCellsXT = This.TheseCellsAndTheirPositions(paCells)

		aResult = []

		for i = 1 to len(aCellsXT)

			cellValue = aCellsXT[i][1]
			oCellValue = Q(cellValue)

			aCellPos  = aCellsXT[i][2]

			if @BothAreStrings(cellValue, pSubValue) or
			   @BothAreLists(cellValue, pSubValue)

				if oCellValue.ContainsCS(pSubValue, pCaseSensitive)
					aResult + [ aCellPos, oCellValue.FindAllCS(pSubValue, pCaseSensitive) ]
				ok

			but @BothAreNumbers(cellValue, pSubValue) or
				( (isString(cellValue) and isNumber(pSubValue)) or
			     	  (isNumber(cellValue) and @IsNumberInString(pSubValue))
				)

				oStzStrCellValue = new stzString(""+ cellValue)

				if oStzStrCellValue.Contains(''+ pSubValue)
					aResult + [ aCellPos, oStzStrCellValue.FindAll(""+ pSubValue) ]
				ok
			ok

		next

		return aResult

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def PositionsOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCells(paCells, pSubValue)
		return This.FindSubValueInCellsCS(paCells, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		def PositionsOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#---------------------------------------------------------------------------------------------#

	def FindNthInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindNthValueInCellsCS(n, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindNthSubValueInCellsCS(n, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindNthValueInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInCellsCS(n, paCells, pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCells(n, paCells, pCellValueOrSubValue)
		return This.FindNthInCellsCS(n, paCells, pCellValueOrSubValue, TRUE)
	
		def FindNthOccurrenceInCells(n, paCells, pCellValueOrSubValue)
			return This.FindNthInCells(n, paCells, pCellValueOrSubValue)	

	  #----------------------------------------------#
	 #  FINDING NTH VALUE IN A GIVEN LIST OF CELLS  #
	#----------------------------------------------#

	def FindNthValueInCellsCS(n, paCells, pCellValue, pCaseSensitive)
		# Returns the cell position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence, :FirstValue ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence, :LastValue ])
				n = This.NumberOfOccurrenceInCellsCS(paCells, pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindValueInCellsCS( paCells, pCellValue, pCaseSensitive)

		aResult = []

		if len(anPos) > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		def FindNthOccurrenceOfValueInCellCS(n, paCells, pCellValue, pCaseSensitive)
			return This.FindNthValueInCellCS(n, paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCells(n, paCells, pValue)
		return This.FindNthCellCS(n, pValue, TRUE)

		def FindNthOccurrenceOfValueInCells(n, paCells, pCellValue)
			return This.FindNthValueInCells(n, paCells, pValue)
	
	  #-------------------------------------------------#
	 #  FINDING NTH SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-------------------------------------------------#

	def FindNthSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)
		# Returns the subvalue position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence, :FirstSubValue ])
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence, :LastSubValue ])
				n = This.CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		nLen = len(anPos)

		aResult = []
		m = 0

		for i = 1 to nLen
			line = anPos[i]
			nLen2 = len(line[2])

			for j = 1 to nLen2
				m += 1
				if m = n
					aResult = [ line[1], line[2][j] ]
					exit 2
				ok
			next
		next

		return aResult
			
		def FindNthOccurrenceOfSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInCellsCS(n, paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCells(n, paCells, pSubValue)
		return This.FindNthSubValueInCellsCS(n, paCells, pSubValue, TRUE)

		def FindNthOccurrenceOfSubValueInCells(n, paCells, pSubValueValue)
			return This.FindNthSubValueInCells(n, paCells, pSubValue)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#------------------------------------------------------------------------------------------------#

	def FindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindFirstSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FFindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCells(paCells, pCellValueOrSubValue)
		return This.FindFirstInCellsCS(paCells, pCellValueOrSubValue, TRUE)
	
		def FindFirstOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.FindFirstInCells(paCells, pCellValueOrSubValue)	

	  #--------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL IN THE PROVIDED LIST OF CELLS  #
	#--------------------------------------------------------------------------#

	def FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(1, paCells, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCells(paCells, pValue)
		return This.FindFirstValueInCellCS(paCells, pValue, TRUE)

		def FindFirstOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindFirstValueInCells(paCells, pValue)

	  #------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN THE PROVIDED LIST OF CELLS  #
	#------------------------------------------------------------------------------#

	def FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(1, paCells, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCells(paCells, pSubValue)
		return This.FindFirstSubValueInCellsCS(paCells, pSubValue, TRUE)

		def FindFirstOccurrenceOfSubValueInCells(paCells, pSubValueValue)
			return This.FindFirstSubValueInCells(paCells, pSubValue)

	  #-----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------------------------------------#

	def FindLastInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfPart ])
				return This.FindLastSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FFindLastnCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCells(paCells, pCellValueOrSubValue)
		return This.FindLastInCellsCS(paCells, pCellValueOrSubValue, TRUE)
	
		def FindLastOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.FindLastInCells(paCells, pCellValueOrSubValue)	

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN VAULUE IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------#

	def FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(:Last, paCells, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCells(paCells, pValue)
		return This.FindLastValueInCellCS(paCells, pValue, TRUE)

		def FindLastOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindLastValueInCells(paCells, pValue)

	  #-------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN SUBVALUE IN SOME GIVEN CELLS  #
	#-------------------------------------------------------------------#
	
	def FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCells(paCells, pSubValue)
		return This.FindLastSubValueInCellsCS(paCells, pSubValue, TRUE)

		def FindLasttOccurrenceOfSubValueInCells(paCells, pSubValueValue)
			return This.FindLastSubValueInCells(paCells, pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF  CELLS  #
	#----------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, TRUE)
	
		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
	
		def CountInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF  CELLS  #
	#-------------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		nResult = len( This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def CountValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, TRUE)

		#--

		def NumberOfOccurrenceOfValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def CountValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		#--

		def NumberOfOccurrencesInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def NumberOfOccurrenceInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF  CELLS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		nLen = len(anPos)

		nResult = 0

		for i = 1 to nLen
			nResult += len(anPos[i][2])
		next

		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pSubValue, TRUE)

	#--

	def NumberOfOccurrenceOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def CountSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#--

	def NumberOfOccurrencesInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def NumberOfOccurrenceInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.CellsContainValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.CellsContainSubValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.CellsContainValueCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def ContainsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContain(paCells, pCellValueOrSubValue)
		return This.CellsContainCS(paCells, pCellValueOrSubValue, TRUE)

		def ContainsInCells(paCells, pCellValueOrSubValue)
			return This.CellsContain(paCells, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellsContainValueCS(paCells, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellsCS(paCells, pValue, pCaseSensitive) ) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsValueInCellsCS(paCells, pValue, pCaseSensitive)
			return This.CellsContainValueCS(paCells, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContainValue(paCells, pValue)
		return This.CellsContainValueCS(paCells, pValue, TRUE)

		def ContainsValueInCells(paCells, pValue)
			return This.CellsContainValue(paCells, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)
		aTemp = This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		if isList(aTemp) and len(aTemp) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContainSubValue(paCells, pSubValue)
		return This.CellsContainSubValueCS(paCells, pSubValue, TRUE)

		def ContainsSubValueInCells(paCells, pSubValue)
			return This.CellsContainSubValue(paCells, pSubValue)

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN A GIVEN CELL  #
	#========================================================#

	def FindNthInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		anResult = anPos[n]

		#TODO: Implement a more performant alortithm by adding FindNext...()

		return anResult

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindNthSubValueInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindNthOccurrenceOfSubValueInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(n, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCell(n, pCellCol, pCellRow, pSubValue)
		return This.FindNthInCellCS(n, pCellCol, pCellRow, pSubValue, TRUE)
	
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCell(n, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(n, pCellCol, pCellRow, pSubValue)

		def FindNthSubValueInCell(n, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(n, pCellCol, pCellRow, pSubValue)
			
		def FindNthOccurrenceOfSubValueInCell(n, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(n, pCellCol, pCellRow, pSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN A CELL)  #
	#-----------------------------------------------------------#

	def FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(1, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCell(pCellCol, pCellRow, pSubValue)
		return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, TRUE)
	
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		def FindFirstSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)
			
		def FindFirstOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELL  #
	#----------------------------------------------------------------------------------------------#

	def FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(:Last, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindLastSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCell(pCellCol, pCellRow, pSubValue)
		return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, TRUE)
	
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		def FindLastSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)
			
		def FindLastOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #--------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF CELL  #
	#--------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, TRUE)
	
		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
	
		def CountInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF CELL  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
		nResult = len( This.FindValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def CountValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def CountValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		#--

		def NumberOfOccurrencesInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def NumberOfOccurrenceInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		#>

	  #---------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF CELL  #
	#---------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		nResult = len( This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def CountSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfSubValueCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pSubValue, TRUE)

	#--

	def NumberOfOccurrenceOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def CountSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#--

	def NumberOfOccurrencesInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def NumberOfOccurrenceInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		bValue = FALSE
		bSubValue = TRUE

		if isList(pCellValueOrSubValue)
			if Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :Cell, :OfCell, :Value, :OfValue, :Of ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				bValue = TRUE
				bSubValue = FALSE
				
			but Q(pCellValueOrSubValue).IsOneOfTheseNamedParams([ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		bResult = FALSE

		if bValue
			bResult = This.CellContainsValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		else // bSubValue
			bResult = This.CellContainsSubValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		ok

		def ContainsInCellCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.CellContainsCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContains(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, TRUE)

		def ContainsInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.CellContains( pCellCol, pCellRow, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellContainsValueCS( pCellCol, pCellRow, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive) ) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return This.CellContainValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContainValue(pCellCol, pCellRow, pValue)
		return This.CellContainValueCS(pCellCol, pCellRow, pValue, TRUE)

		def ContainsValueInCell(pCellCol, pCellRow, pValue)
			return This.CellContainValue( pCellCol, pCellRow, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		nPos = This.FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		if nPos > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContainsSubValue(pCellCol, pCellRow, pSubValue)
		return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, TRUE)

		def ContainsSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.CellContainsSubValue(pCellCol, pCellRow, pSubValue)

	/// WORKING ON ROWS //////////////////////////////////////////////////////////////////////

	  #======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#======================================================================================#

	def FindInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? o1.FindInRow(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? o1.FindInRow(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? o1.FindInRow( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		aCellsPos = This.RowCellsAsPositions(pRow)

		if isList(pCellValueOrSubValue)
			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(aCellsPos, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(aCellsPos, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.FindValueInCellsCS(aCellsPos, pCellValueOrSubValue, pCaseSensitive)


		#-- WITHOUT CASESENSITIVITY

		def FindInRow(pRow, pCellValueOrSubValue)
			return This.FindInRowCS(pRow, pCellValueOrSubValue, TRUE)

	def FindValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInRow(pRow, pCellValue)
			return This.FindValueInRowCS(pRow, pSubValue, TRUE)

	def FindSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInRow(pRow, pSubValue)
			return This.FindValueInRowCS(pRow, pSubValue, TRUE)

	  #=========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#=========================================================================================#

	def FindNthInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :N, :Nth, :Occurrence ])
			n = n[2]
		ok

		if isList(pRow) and Q(pRow).IsOneOfTheseNamedParams([ :Row, :InRow ])
			pRow = pRow[2]
		ok

		return This.FindNthInCellsCS(n, This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowCS(n, pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInRow(n, pRow, pCellValueOrSubValue)
			return This.FindNthInRowCS(n, pRow, pCellValueOrSubValue, TRUE)
		
			def FindNthOccurrenceInRow(n, pRow, pCellValueOrSubValue)
				return This.FindNthInRow(n, pRow, pCellValueOrSubValue)

	def FindNthValueInRowCS(n, pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(n, This.RowAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInRow(n, pRow, pCellValue)
			return This.FindNthValueInRowCS(n, pRow, pCellValue, TRUE)

			def FindNthOccurrenceOfValueInRow(n, pRow, pCellValue)
				return This.FindNthValueInRow(n, pRow, pCellValue)

	def FindNthSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(n, This.RowAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowCS(n, pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInRow(n, pRow, pSubValue)
			return This.FindNthSubValueInRowCS(n, pRow, pSubValue, TRUE)

			def FindNthOccurrenceOfSubValueInRow(n, pRow, pSubValue)
				return This.FindNthSubValueInRow(n, pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(1, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInRow(pRow, pCellValueOrSubValue)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, TRUE)
		
			def FindFirstOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindFirstInRow(pRow, pCellValueOrSubValue)

	def FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInRow(pRow, pCellValue)
			return This.FindFirstValueInRowCS(pRow, pCellValue, TRUE)

			def FindFirstOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindFirstValueInRow(pRow, pCellValue)

	def FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInRow(pRow, pSubValue)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, TRUE)

			def FindFirstOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindFirstSubValueInRow(pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInRow(pRow, pCellValueOrSubValue)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, TRUE)
		
			def FindLastOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindLastInRow(pRow, pCellValueOrSubValue)

	def FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInRow(pRow, pCellValue)
			return This.FindLastValueInRowCS(pRow, pCellValue, TRUE)

			def FindLastOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindLastValueInRow(pRow, pCellValue)

	def FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowCS(pRow, pSubValue, TRUE)

		def FindLastOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInRow(pRow, pSubValue)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, TRUE)

			def FindLastOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindLastSubValueInRow(pRow, pSubValue)

	  #---------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A ROW  #
	#---------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInRow( :OfCell = "Ali" ) #--> 2
		? o1.CountInRow( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.RowAsPositions(pRow), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		def CountInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

		def CountInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, pCaseSensitive)
		return len( This.FindCellInRowCS(pRow, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInRow(pRow, pCellValue)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def NumberOfOccurrencesOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#--

		def NumberOfOccurrenceOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfValueInRowInRow(pRow, pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRowInRow(pRow, pRow, pValue)

		def CountValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		#>

	  #============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A ROW  #
	#============================================================================#

	def ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInRow(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInRow(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInRowCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowContainsCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInRow(pRow, pCellValueOrSubValue)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, TRUE)

			def RowContains(pRow, pCellValueOrSubValue)
				return This.ContainsInRow(pRow, pCellValueOrSubValue)

	def ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def RowContainsCellCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def ContainsValueInRowCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def RowContainsValueCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def ContainsCellInRow(pRow, pCellValue)
			return This.ContainsCellInRowCS(pRow, pCellValue, TRUE)

			def RowContainsCell(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)

			def ContainsValueInRow(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)
	
	def ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def RowContainsSubValueCS(pRow, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInRow(pRow, pSubValue)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, TRUE)

			def RowContainsSubValue(pRow, pSubValue)
				return This.ContainsSubValueInRow(pRow, pSubValue)

	/// WORKING ON A LIST OF ROWS /////////////////////////////////////////////////////////////

	  #=======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#=======================================================================================#

	def FindInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? o1.FindInRows( [ 2, 3 ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? o1.FindInRowsCS(  [ 1, 3 ], :SubValue = "a", :CS = FALSE )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [3, 1], [6] ],
			[ [3, 3], [2] ]
		     ]
		*/

		aCellsPositions = This.RowsToCellsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)
		
			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.FindInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)
				
			ok
		ok

		return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInRows(panRows, pCellValueOrSubValue)
		return This.FindInRowsCS(panRows, pCellValueOrSubValue, TRUE)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN ROWS  #
	#------------------------------------------------------------#

	def FindValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInRows(panRows, pCellValue)
		return This.FindValueInRowsCS(panRows, pSubValue, TRUE)

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.RowsAsPositions(panRows), pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInRows(panRows, pSubValue)
		return This.FindValueInRowsCS(panRows, pSubValue, TRUE)

	  #==========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#==========================================================================================#

	def FindNthInRowsCS(n, panRows, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :Nth, :N, :Occurrence ])
			n = n[2]
		ok

		panRows = This.RowsToNames(panRows)

		return This.FindNthInCellsCS(n, This.RowsAsPositions(panRows), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRowsCS(n, panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowsCS(n, panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInRows(n, panRows, pCellValueOrSubValue)
		return This.FindNthInRowsCS(n, panRows, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRows(n, panRows, pCellValueOrSubValue)
			return This.FindNthInRows(n, panRows, pCellValueOrSubValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN ROWS  #
	#------------------------------------------------------#

	def FindNthValueInRowsCS(n, panRows, pCellValue, pCaseSensitive)

		if isList(panRows) and
		   Q(panRows).IsOneOfTheseNamedParams([ :Rows, :InRows, :OfRows ])

			panRows = panRows[2]
		ok

		return This.FindNthInCellsCS(n, This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRowsCs(n, panRows, pCellValue, pCaseSensitive)
			return This.FindNthValueInRowsCS(n, panRows, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInRows(n, panRows, pCellValue)
		return This.FindNthValueInRowsCS(n, panRows, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRows(n, panRows, pCellValue)
			return This.FindNthValueInRows(n, panRows, pCellValue)

		#>

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindNthSubValueInRowsCS(n, panRows, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		aResult = []
		if n > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindNthOccurrenceOfSubValueInRowsCS(n, panRows, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowsCS(n, panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInRows(n, panRows, pSubValue)
		return This.FindNthSubValueInRowsCS(n, panRows, pSubValue, TRUE)

		#< @FuntionAlternativeForm

		def FindNthOccurrenceOfSubValueInRows(n, panRows, pSubValue)
			return This.FindNthSubValueInRows(n, panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(1, panRows, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInRows(panRows, pCellValueOrSubValue)
		return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindFirstInRows(panRows, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRowsCs(panRows, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInRows(panRows, pCellValue)
		return This.FindFirstValueInRowsCS(panRows, pCellValue, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindFirstValueInRows(panRows, pCellValue)

		#>

	  #------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------#

	def FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInRows(panRows, pSubValue)
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindFirstSubValueInRows(panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInRows(panRows, pCellValueOrSubValue)
		return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindLastInRows(panRows, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF ROWS  #
	#-------------------------------------------------------------#

	def FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInRows(panRows, pCellValue)
		return This.FindLastValueInRowsCS(panRows, pCellValue, TRUE)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindLastValueInRows(panRows, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#-----------------------------------------------------------------#

	def FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInRows(panRows, pSubValue)
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindLastSubValueInRows(panRows, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.RowsAsPositions(panRows), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

		def CountInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
		return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrencesInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		def CountInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		#>

	  #----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF ROWS  #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		return len( This.FindCellInRowsCS(panRows, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		def CountOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInRows(panRows, pCellValue)
		return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, TRUE)

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def NumberOfOccurrenceOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		#>

	  #--------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowsAsPositions(panRows), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		def CountOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		#>

	  #===========================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF ROWS  #
	#===========================================================================================#

	def ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		if isList(panRows) and
		   Q(panRows).IsOneOfTheseNamedParams([ :Rows, :InRows, :OfRows ])
			pRow = pRow[2]
		ok

		aRowPos = This.RowsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(aRowPos, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(aRowPos, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(aRowPos, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowsContainCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInRows(panRows, pCellValueOrSubValue)
		return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForm

		def RowsContain(panRows, pCellValueOrSubValue)
			return This.ContainsInRows(panRows, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF ROWS CONTAIN THE GIVEN CELL  #
	#-----------------------------------------------------------#

	def ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def RowsContainCellCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def ContainsValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def RowsContainValueCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInRows(panRows, pCellValue)
		return This.ContainsCellInRowsCS(panRows, pCellValue, TRUE)

		#< @FunctionAlternativeForms
	
		def RowsContainCell(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def ContainsValueInRows(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def RowsContainValue(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)
	
		#>

	  #-------------------------------------------------------#
	 #  CHECKING IF A LIST OF ROWS CONTAIN A GIVEN SUBVALUE  #
	#-------------------------------------------------------#
	
	def ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def RowsContainSubValueCS(panRows, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInRows(panRows, pSubValue)
		return This.ContainsSubValueInRowsCS(panRows, pSubValue, TRUE)

		#< @FunctionAlternativeForm
		
		def RowsContainSubValue(panRows, pSubValue)
			return This.ContainsSubValueInRows(panRows, pSubValue)
		
		#>

	/// WORKING ON COLUMNS //////////////////////////////////////////////////////////////////////

	  #=========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#=========================================================================================#

	def FindInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])

		? o1.FindInCol( :FIRSTNAME, :Value = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? o1.FindInCol( :FIRSTNAME, :SubValue = "a" ) #--> [ ]

		? o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE )
		#--> [
			[ [2, 1], [2]    ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		pCol = This.ColToName(pCol)
		aCellsPositions = This.ColAsPositions(pCol)

		if isList(pCellValueOrSubValue)

			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCol(pCol, pCellValueOrSubValue)
		return This.FindInColCS(pCol, pCellValueOrSubValue, TRUE)

		def FindInColumn(pCol, pCellValueOrSubValue)
			return This.FindInCol(pCol, pCellValueOrSubValue)

	  #--------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMN  #
	#--------------------------------------------------------------#

	def FindValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		def FindValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindValueInColCS(pCol, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCol(pCol, pCellValue)
		return This.FindValueInColCS(pCol, pSubValue, TRUE)

		def FindValueInColumn(pCol, pCellValue)
			return This.FindValueInCol(pCol, pCellValue)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		def FindSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCol(pCol, pSubValue)
		return This.FindValueInColCS(pCol, pSubValue, TRUE)

		def FindSubValueInColumn(pCol, pSubValue)
			return This.FindSubValueInCol(pCol, pSubValue)

	  #============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#============================================================================================#

	def FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :Nth, :N, :Occurrence ])
			n = n[2]
		ok

		pCol = This.ColToName(pCol)

		return This.FindNthInCellsCS(n, This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCol(n, pCol, pCellValueOrSubValue)
		return This.FindNthInColCS(n, pCol, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindNthInColumn(n, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInCol(n, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInColumn(n, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(n, pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMN  #
	#--------------------------------------------------------#

	def FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		if isList(pCol) and Q(pCol).IsOneOfTheseNamedParams([
					:Col, :InCol, :OfCol,
					:Column, :InColumn, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		return This.FindNthInCellsCS(n, This.ColAsPositions(pcol), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumCS(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColCs(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnCS(n, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(n, pCol, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCol(n, pCol, pCellValue)
		return This.FindNthValueInColCS(n, pCol, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindNthValueInColumn(n, pCol, pCellValue)
			return This.FindNthValueInCol(n, pCol, pCellValue)

		def FindNthOccurrenceOfValueInCol(n, pCol, pCellValue)
			return This.FindNthValueInCol(n, pCol, pCellValue)

		def FindNthOccurrenceOfValueInColumn(n, pCol, pCellValue)
			return This.FindNthValueInCol(n, pCol, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		aResult = []
		if n > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnCS(n, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(n, pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCol(n, pCol, pSubValue)
		return This.FindNthSubValueInColCS(n, pCol, pSubValue, TRUE)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColum(n, pCol, pSubValue)
			return This.FindNthSubValueInCol(n, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInCol(n, pCol, pSubValue)
			return This.FindNthSubValueInCol(n, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInColumn(n, pCol, pSubValue)
			return This.FindNthSubValueInCol(n, pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(1, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCol(pCol, pCellValueOrSubValue)
		return This.FindFirstInColCS(pCol, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A COLUMN  #
	#--------------------------------------------------#

	def FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCol(pCol, pCellValue)
		return This.FindFirstValueInColCS(pCol, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A COLUMN  #
	#------------------------------------------------------#

	def FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCol(pCol, pSubValue)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCol(pCol, pCellValueOrSubValue)
		return This.FindLastInColCS(pCol, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindLastInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		#>

	  #---------------------------------#
	 #  FINDING LAST CELL IN A COLUMN  #
	#---------------------------------#

	def FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCol(pCol, pCellValue)
		return This.FindLastValueInColCS(pCol, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindLastValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		#>

	  #-------------------------------------#
	 #  FINDING LAST SUBVALUE IN A COLUMN  #
	#-------------------------------------#

	def FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCol(pCol, pSubValue)
		return This.FindLastSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		#>

	  #------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A COLUMN  #
	#------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInCol( :OfCell = "Ali" ) #--> 2
		? o1.CountInCol( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
		return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		def NumberOfOccurrencesInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def NumberOfOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		def CountInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def CountInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		#--

		def HowManyOccurrenceInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrenceInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A COLUMN  #
	#----------------------------------------------#

	def NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, pCaseSensitive)
		return len( This.FindCellInColCS(pCol, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValueInColumCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#==

		def HowManyValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def HowManyOcurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
		return This.NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountValueInColum(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#==

		def HowManyValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#--

		def HowManyOcurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#>

	  #--------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN COLUMN  #
	#--------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def HowManyOcurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def CountOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def CountOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#==

		def HowManySubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#--

		def HowManyOcurrenceOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#>

	  #===============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A COLUMN  #
	#===============================================================================#

	def ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInCol(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInCol(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInColCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		if isList(pCol) and Q(pCol).IsOneOfTheseNamedParams([
					:Col, :Column, :InCol, :InColumn, :OfCol, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		if isString(pCol)
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				pCol = This.NumberOfCols()
		
			else
				StzRaise("Incorrect param type! pCol must be a number.")
			ok
		ok

		aCellsPos = This.ColAsPositions(pCol)

		if isList(pCellValueOrSubValue)

			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(aCellsPos, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(aCellsPos, pCellValueOrSubValue[2], pCaseSensitive)

			ok

		ok

		return This.ContainsValueInCellsCS(aCellsPos, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColumnContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInCol(pCol, pCellValueOrSubValue)
		return This.ContainsInColCS(pCol, pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms

		def ContainsInColumn(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColumnContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------#
	 #  CHECKING IF A GIVEN COLUMN CONTAINS A GIVEN CELL  #
	#----------------------------------------------------#

	def ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ContainsValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInCol(pCol, pCellValue)
		return This.ContainsCellInColCS(pCol, pCellValue, TRUE)

		#< @FunctionAlternativeForms
	
		def ContainsCellInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ContainsValueInCol(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ContainsValueInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#>

	  #--------------------------------------------------#
	 #  CHECKING IF A COLUMN CONTAINS A GIVEN SUBVALUE  #
	#--------------------------------------------------#
	
	def ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColumnContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCol(pCol, pSubValue)
		return This.ContainsSubValueInColCS(pCol, pSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumn(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColumnContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		#>

	/// WORKING ON A LIST OF COLUMNS /////////////////////////////////////////////////////////////

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#==========================================================================================#

	def FindInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? o1.FindInColsCS(  [ :FIRSTNAME, :LASTNAME ], :SubValue = "a", :CS = FALSE )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		bValue = TRUE
		bSubValue = FALSE

		aCellsPositions = This.ColsToCellsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)
		
			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(aCellsPositions, pCellValueOrSubValue[2], pCaseSensitive)
		
			ok
		ok

		return This.FindValueInCellsCS(aCellsPositions, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCols(paCols, pCellValueOrSubValue)
		return This.FindInColsCS(paCols, pCellValueOrSubValue, TRUE)

		def FindInColumns(paCols, pCellValueOrSubValue)
			return This.FindInCols(paCols, pCellValueOrSubValue)

	  #---------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------------#

	def FindValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		def FindValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindValueInColsCS(paCols, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCols(paCols, pCellValue)
		return This.FindValueInColsCS(paCols, pSubValue, TRUE)

		def FindValueInColumns(paCols, pCellValue)
			return This.FindValueInCols(paCols, pCellValue)

	  #-------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMNS  #
	#-------------------------------------------------------------#

	def FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.ColsAsPositions(paCols), pSubValue, pCaseSensitive)

		def FindSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCols(paCols, pSubValue)
		return This.FindValueInColsCS(paCols, pSubValue, TRUE)

		def FindSubValueInColumns(paCols, pSubValue)
			return This.FindSubValueInCols(paCols, pSubValue)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#=============================================================================================#

	def FindNthInColsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :Nth, :N, :Occurrence ])
			n = n[2]
		ok

		paCols = This.ColsToNames(paCols)

		return This.FindNthInCellsCS(n, This.ColsAsPositions(paCols), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(n, paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCols(n, paCols, pCellValueOrSubValue)
		return This.FindNthInColsCS(n, paCols, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindNthInColumns(n, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(n, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInCols(n, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(n, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInColumns(n, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(n, paCols, pCellValueOrSubValue)

		#>

	  #---------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------#

	def FindNthValueInColsCS(n, paCols, pCellValue, pCaseSensitive)

		if isList(paCols) and Q(paCols).IsOneOfTheseNamedParams([
					:Cols, :InCols, :OfCols,
					:Columns, :InColumns, :OfColumns
				    ])

			paCols = paCols[2]
		ok

		return This.FindNthInCellsCS(n, This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumsCS(n, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(n, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColsCs(n, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(n, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnsCS(n, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(n, paCols, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCols(n, paCols, pCellValue)
		return This.FindNthValueInColsCS(n, paCols, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindNthValueInColumns(n, paCols, pCellValue)
			return This.FindNthValueInCols(n, paCols, pCellValue)

		def FindNthOccurrenceOfValueInCols(n, paCols, pCellValue)
			return This.FindNthValueInCols(n, paCols, pCellValue)

		def FindNthOccurrenceOfValueInColumns(n, paCols, pCellValue)
			return This.FindNthValueInCols(n, paCols, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColsCS(n, paCols, pSubValue, pCaseSensitive)
		anPos = This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		aResult = []
		if n > 0 and n <= len(anPos)
			aResult = anPos[n]
		ok

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumsCS(n, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(n, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColsCS(n, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(n, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnsCS(n, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(n, paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCols(n, paCols, pSubValue)
		return This.FindNthSubValueInColsCS(n, paCols, pSubValue, TRUE)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColums(n, paCols, pSubValue)
			return This.FindNthSubValueInCols(n, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInCols(n, paCols, pSubValue)
			return This.FindNthSubValueInCols(n, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInColumns(n, paCols, pSubValue)
			return This.FindNthSubValueInCols(n, paCols, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMN  #
	#------------------------------------------------------------------------------------------#

	def FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(1, paCols, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCols(paCols, pCellValueOrSubValue)
		return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCols(paCols, pCellValue)
		return This.FindFirstValueInColsCS(paCols, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------#

	def FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCols(paCols, pSubValue)
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMNS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCols(paCols, pCellValueOrSubValue)
		return This.FindLastInColsCS(paCols, pCellValueOrSubValue, TRUE)
		
		#< @FunctionAlternativeForms

		def FindLastInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF COLUMNS  #
	#----------------------------------------------------------------#

	def FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCols(paCols, pCellValue)
		return This.FindLastValueInColsCS(paCols, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def FindLastValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#--------------------------------------------------------------------#

	def FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCols(paCols, pSubValue)
		return This.FindLastSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.ColsAsPositions(paCols), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCoslCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
		return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def NumberOfOccurrencesInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def NumberOfOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def CountInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def CountInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#--

		def HowManyOccurrenceInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#>

	  #-------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF COLUMNS  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, pCaseSensitive)
		return len( This.FindCellInColsCS(paCols, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountValueInColumsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#==

		def HowManyValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def HowManyOcurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInCols(paCols, pCellValue)
		return This.NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountValueInColums(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#==

		def HowManyValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#--

		def HowManyOcurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColsAsPositions(paCols), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def HowManyOcurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		
		#--
	
		def CountOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def CountOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#==

		def HowManySubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#--

		def HowManyOcurrenceOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#>

	  #==============================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#==============================================================================================#

	def ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		if isList(paCols) and Q(paCols).IsOneOfTheseNamedParams([
					:Cols, :Columns, :InCols, :InColumns, :OfCols, :OfColumns
				    ])

			pCol = pCol[2]
		ok

		aColPos = This.ColsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(aColPos, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(aColPos, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(aColPos, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColumnsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInCols(paCols, pCellValueOrSubValue)
		return This.ContainsInColsCS(paCols, pCellValueOrSubValue, TRUE)

		#< @FunctionAlternativeForms

		def ContainsInColumns(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColumnsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF COLUMNS CONTAIN THE GIVEN CELL  #
	#--------------------------------------------------------------#

	def ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ContainsValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainsValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInCols(paCols, pCellValue)
		return This.ContainsCellInColsCS(paCols, pCellValue, TRUE)

		#< @FunctionAlternativeForms
	
		def ContainsCellInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ContainsValueInCols(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ContainsValueInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#>

	  #----------------------------------------------------------#
	 #  CHECKING IF A LIST OF COLUMNS CONTAIN A GIVEN SUBVALUE  #
	#----------------------------------------------------------#
	
	def ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColumnsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCols(paCols, pSubValue)
		return This.ContainsSubValueInColsCS(paCols, pSubValue, TRUE)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumns(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColumnsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		#>

	/// WORKING ON SECTIONS //////////////////////////////////////////////////////////////////////
	#TODO: Working on SELECTIONS

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#==========================================================================================#

	def FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? o1.FindInSection(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? o1.FindInSection(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? o1.FindInSection( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		if isList(pCellValueOrSubValue)
			oTemp = Q(pCellValueOrSubValue)

			if oTemp.IsOneOfTheseNamedParams([ :Value, :Cell, :CellValue ])
				return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)

			but oTemp.IsOneOfTheseNamedParams([ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)
			ok
		ok

		return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, TRUE)

	def FindValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInSection(paSection1, paSection2, pCellValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

	def FindSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#=============================================================================================#

	def FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		if isList(n) and Q(n).IsOneOfTheseNamedParams([ :N, :Nth, :Occurrence ])
			n = n[2]
		ok

		return This.FindNthInCellsCS(n, This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInSection(n, paSection1, paSection2, pCellValueOrSubValue)
			return This.FindNthInSectionCS(n, paSection1, paSection2, pCellValueOrSubValue, TRUE)
		
			def FindNthOccurrenceInSection(n, paSection1, paSection2, pCellValueOrSubValue)
				return This.FindNthInSection(n, paSection1, paSection2, pCellValueOrSubValue)

	def FindNthValueInSectionCS(n, paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(n, This.SectionAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInSection(n, paSection1, paSection2, pCellValue)
			return This.FindNthValueInSectionCS(n, paSection1, paSection2, pCellValue, TRUE)

			def FindNthOccurrenceOfValueInSection(n, paSection1, paSection2, pCellValue)
				return This.FindNthValueInSection(n, paSection1, paSection2, pCellValue)

	def FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(n, This.SectionAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInSection(n, paSection1, paSection2, pSubValue)
			return This.FindNthSubValueInSectionCS(n, paSection1, paSection2, pSubValue, TRUE)

			def FindNthOccurrenceOfSubValueInSection(n, paSection1, paSection2, pSubValue)
				return This.FindNthSubValueInSection(n, paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(1, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, TRUE)
		
			def FindFirstOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInSection(paSection1, paSection2, pCellValue)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, TRUE)

			def FindFirstOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindFirstValueInSection(paSection1, paSection2, pCellValue)

	def FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

		def FindFirstOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

			def FindFirstOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindFirstSubValueInSection(paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(:Last, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, TRUE)
		
			def FindLastOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInSection(paSection1, paSection2, pCellValue)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, TRUE)

			def FindLastOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindLastValueInSection(paSection1, paSection2, pCellValue)

	def FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

		def FindLastOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

			def FindLastOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindLastSubValueInSection(paSection1, paSection2, pSubValue)

	  #-------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A SECTION  #
	#-------------------------------------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? o1.NumberOfOccurrenceInSection( :OfCell = "Ali" ) #--> 2
		? o1.CountInSection( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.SectionAsPositions(paSection1, paSection2), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def CountInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return len( This.FindCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#==

		def HowManyCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pCellValue)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def NumberOfOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#--

		def NumberOfOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfValueInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)

		def CountValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#==

		def HowManyCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		#>

	  #================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A SECTION  #
	#================================================================================#

	def ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? o1.ContainsInSection(2, :Value = "Abraham") #--> TRUE
		
		? o1.ContainsInSection(2, :SubValue = "AL") #--> FALSE
		? o1.ContainsInSectionCS(2, :SubValue = "AL", :CS = FALSE) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def SectionContainsCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, TRUE)

			def SectionContains(paSection1, paSection2, pCellValueOrSubValue)
				return This.ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)

	def ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfCell = pCellValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def SectionContainsCellCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def ContainsValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def SectionContainsValueCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def ContainsCellInSection(paSection1, paSection2, pCellValue)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, TRUE)

			def SectionContainsCell(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)

			def ContainsValueInSection(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)
	
	def ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		def SectionContainsSubValueCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInSection(paSection1, paSection2, pSubValue)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, TRUE)

			def SectionContainsSubValue(paSection1, paSection2, pSubValue)
				return This.ContainsSubValueInSection(paSection1, paSection2, pSubValue)

	  #==========================================================================#
	 #  REPLACING A GIVEN CELL, DEFINED BY ITS POSITION, BY THE PROVIDED VALUE  #
	#==========================================================================#

	def ReplaceCell(pCol, pnRow, pNewCellValue)
		if CheckParams()
			if isList(pNewCellValue) and Q(pNewCellValue).IsOneOfTheseNamedParams([ :By, :With, :Using ])
				pNewCellValue = pNewCellValue[2]
			ok
			if NOT isNumber(pnRow)
				StzRaise("Incorrect param type! pnRow must be a number.")
			ok
		ok

		cCol = This.ColToName(pCol)
		@aContent[cCol][pnRow] = pNewCellValue

		#< @FunctionAlternativeForms

		def ReplaceCellByPosition(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		def ReplaceByPositionCell(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		#>

	  #---------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY THE PROVIDED VALUE  #
	#---------------------------------------------------------------------------#

	def ReplaceCells(paCellsPos, paNewCellValue)

		if ChekParams() #NOTE this is a misspelled form (c in Check is lacking)
			        # But Softanza forgives it (PERMISSIVENESS prinicle of the FLEXIBILITY goal)

			if isList(paNewCellValue) and Q(paNewCellValue).IsOneOfTheseNamedParams([ :By, :With, :Using ])
				paNewCellValue = paNewCellValue[2]
			ok
	
		ok

		for i = 1 to len(paCellsPos)
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewCellValue)
		next

		#< @FunctionAlternatives

		def ReplaceTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		#TODO: Add the fellowing semantics to all simular functions in the library

		def ReplaceEachOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceEveryOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEachOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEveryOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceByPositionCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES  #
	#-----------------------------------------------------------------------------#

	def ReplaceCellsByMany(paCellsPos, paNewValues)

		if CheckParams()

			if isList(paNewValues) and
			   Q(paNewValues).IsOneOfTheseNamedParams([ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok
	
			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		nLenCells  = len(paCellsPos)
		nLenValues = len(paNewValues)
		nMin = Min([ nLenCells, nLenValues ])

		for i = 1 to nMin
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewValues[i])
		next

		#< @FunctionAlternativeForms

		def ReplaceTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfTheseByMany([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceEachOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceEveryOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceByPositionEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceByPositionEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES, EXTENDED  #
	#---------------------------------------------------------------------------------------#

	def ReplaceCellsByManyXT(paCellsPos, paNewValues)

		if CheckParams()

			if isList(paNewValues) and
			   Q(paNewValues).IsOneOfTheseNamedParams([ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok
	
			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		nLenPos = len(paCellsPos)
		nLenNew = len(paNewValues)

		if nLenNew < nLenPos
			paNewValues = Q(paNewValues).ExtendXTQ(:To = nLenPos, :ByRepeatingItems).Content()

		but nLenNew > nLenPos
			This.ExtendTo( QR(paCellsPos, :stzListOfPairs).Max() )
		ok

		This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#< @FunctionAlternatives

		def ReplaceTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfTheseByManyXT([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and Q(paCellsPos).IsOneOfThese([ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#>

	  #-----------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF A CELL (VALUE) BY THE PROVIDED VALUE  #
	#=================================================================#

	def ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)
		aPos = This.FindCellCS(pCellValue, pCaseSensitive)
		This.ReplaceCellsByPositions(aPos, pNewCellValue)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValueCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceByValueOccurrencesOfCellByCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIIVTY

	def ReplaceCellByValue(pCellValue, pNewCellValue)
		This.ReplaceCellByValueCS(pCellValue, pNewCellValue, TRUE)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValue(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#--

		def ReplaceByValueCell(pCellValue, pNewCellValue)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		def ReplaceByValueOccurrencesOfCellBy(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY THE PROVIDED VALUE  #
	#--------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValue(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, TRUE)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValue(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#--

		def ReplaceByValueManyCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		def ReplaceByValueCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES  #
	#--------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, TRUE)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		def ReplaceByValueCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES -- XT FORM  #
	#-------------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, TRUE)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		#>

	  #=============================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS  #
	#=============================================================#

	def ReplaceCol(pCol, paCol)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthCol(nCol, paCol)

		def ReplaceColumn(pCol, paCol)
			This.ReplaceCol(pCol, paCol)

	def ReplaceNthCol(n, paCol)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if NOT isList(paCol)
				StzRaise("Incorrect param type! paCol must be a list.")
			ok
		ok

		nRows = This.NumberOfRows()
		nLen = len(paCol)

		if nLen > nRows
			nLen = nRows
		ok

		aCol = []

		for i = 1 to nRows
			if i <= nLen
				aCol + paCol[i]
			else
				aCol + @aContent[n][2][i]
			ok
		next

		@aContent[n][2] = aCol

		#< @FunctionAlternativeForms

		def ReplaceNthColumn(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColN(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnN(n, paCol)
			This.ReplaceNthCol(n, paCol)

		#--

		def ReplaceColAt(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColAtPosition(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnAt(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnAtPosition(n, paCol)
			This.ReplaceNthCol(n, paCol)

		#>

	  #-------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------#
	# ~> XT : If paCol has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColXT(pCol, paCol)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColXT(nCol, paCol)

		def ReplaceColumnXT(pCol, paCol)
			This.ReplaceColXT(pCol, paCol)

	def ReplaceNthColXT(n, paCol)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if NOT isList(paCol)
				StzRaise("Incorrect param type! paCol must be a list.")
			ok
		ok

		nRows = This.NumberOfRows()
		nLen = len(paCol)

		if nLen > nRows
			nLen = nRows
		ok

		aCol = []
		j = 0

		for i = 1 to nRows
			if i <= nLen
				aCol + paCol[i]
			else
				j++
				if j > nLen
					j = 1
				ok
				aCol + paCol[j]
			ok
		next

		@aContent[n][2] = aCol

		#< @FunctionAlternativeForms

		def ReplaceNthColumnXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColNXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnNXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		#--

		def ReplaceColAtXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColAtPositionXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnAtXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnAtPositionXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------------#

	def ReplaceColsAt(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = len(anPosU)

		for i = 1 to nLen
			This.ReplaceColAt(anPosU[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplacesNthCols(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAt(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplacesNthColumns(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		#>

	  #----------------------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------------#

	def ReplaceColsAtXT(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = len(anPosU)

		for i = 1 to nLen
			This.ReplaceColAtXT(anPosU[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColumnsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------------#

	def ReplaceTheseCols(paCols, paNewCol)
		if Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		anPos = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositions(anPos, paNewCol)

		def ReplaceTheseColumns(paCols, paNewCol)
			This.ReplaceTheseCols(paCols, paNewCol)


	  #-------------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------------#

	def ReplaceTheseColsXT(paCols, paNewCol)
		if Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		anPos = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositionsXT(anPos, paNewCol)

		def ReplaceTheseColumnsXT(paCols, paNewCol)
			This.ReplaceTheseColsXT(paCols, paNewCol)

	  #===============================================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS  #
	#===============================================================================#

	def ReplaceColNameAndData(pCol, pcColName, paColData)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColName(nCol, pcColName)
		This.ReplaceNthCol(nCol, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndData(pCol, pcColName, paColData)
			This.ReplaceColNameAndData(pCol, pcColName, paColData)

		#>

	def ReplaceNthColNamedAndData(n, pcColName, paColData)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if isList(pcColName) and Q(pcColName).IsWithOrByOrUsingNamedParam()
				pcColName = pcColName[2]
			ok

			if isList(paColData) and Q(paColData).IsAndNamedParam()
				pacolData = paColData[2]
			ok

			if NOT isString(pcColName)
				StzRaise("Incorrect param type! pcColName must be a string.")
			ok

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok
		ok

		nMin = Min([ len(paColData), This.NumberOfRows() ])
		aTemp = []
		for i = 1 to nMin
			aTemp + paColData[i]
		next

		@aContent[n][1] = pcColName
		@aContent[n][2] = aTemp

		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		def ReplaceColNNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		def ReplaceColumnNNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#
	# ~> XT : If paColData has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColNameAndDataXT(pCol, pcColName, paColData)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColName(nCol, pcColName)
		This.ReplaceNthColXT(nCol, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndDataXT(pCol, pcColName, paColData)
			This.ReplaceColNameAndDataXT(pCol, pcColName, paColData)

		#>

	def ReplaceNthColNamedAndDataXT(n, pcColName, paColData)
		This.ReplaceNthColName(n, pcColName)
		This.ReplaceNthColXT(n, paColData)

		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		def ReplaceColNNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		def ReplaceColumnNNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		#>

	  #==================================================================#
	 #  REPLACING ALL THE CELLS OF A COLUMN BY THE SAME PROVIDED VALUE  #
	#==================================================================#

	def ReplaceCellsInCol(pCol, pCell)
		if CheckParams()
			if isList(pCell) and Q(pCell).IsWithOrByOrUsingNamedParam()
				pCell = pCell[2]
			ok
		ok

		nCol = This.ColToColNumber(pCol)
		nRows = This.NumberOfRows()

		for i = 1 to nRows
			@aContent[nCol][2][i] = pCell
		next

		def ReplaceCellsInColumn(pCol, pCell)
			This.ReplaceCellsInCol(pCol, pCell)

	  #------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#------------------------------------------------------------------------------------------------#
	#TODO: check for performance

	def ReplaceAllCols(paNewCol)
		if CheckParams()

			if isList(paNewCol) and
			   Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok
	
			if NOT isList(paNewCol) 
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		nLen = This.NumberOfCols()

		for i = 1 to nLen
			This.ReplaceCol(i, paNewCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceAllColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		def ReplaceCols(paNewCols)
			This.ReplaceAllCols(paNewCols)

		def ReplaceColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		#>

	  #------------------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#------------------------------------------------------------------------------------------------------------#
	#TODO: check for performance

	def ReplaceAllColsXT(paNewCol)
		if CheckParams()

			if isList(paNewCol) and
			   Q(paNewCol).IsOneOfTheseNamedParams([ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok
	
			if NOT isList(paNewCol) 
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		nLen = This.NumberOfCols()

		for i = 1 to nLen
			This.ReplaceColXT(i, paNewCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceAllColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		def ReplaceColsXT(paNewCols)
			This.ReplaceAllColsXT(paNewCols)

		def ReplaceColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#----------------------------------------------------------------------------------------------#

	def ReplaceAllColsByMany(paCols, paNewCols)
		/* ... */

		StzRaise("Insupported feature in this release!")

		def ReplaceAllColumsByMany(paCols, paNewCols)
			This.ReplaceAllColsByMany(paCols, paNewCols)

	#TODO : Add ReplaceAllColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #-----------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#-----------------------------------------------------------------------------------#

	def ReplaceTheseColsByMany(paCols, paNewCols)
		if Q(paNewCols).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewCols = paNewCols[2]
		ok

		/* ... */

		StzRaise("Insupported feature in this release!")

		#< @FunctionAlternativeForms

		def ReplaceTheseColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		#>

	#TODO: Add ReplaceTheseColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #===================================================================#
	 #  REPLACING THE CELLS OF THE GIVEN ROW BY THE PRIVIDED CELL VALUE  #
	#===================================================================#

	def ReplaceCellsInRow(pnRow, pCell)
		aNewRow = []
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			aNewRow + pCell
		next

		This.ReplaceRow(pnRow, aNewRow)

	  #-----------------------------------------------------------------------------------------#
	 #  REPLACING A ROW (DEFINED BY ITS NUMBER) BY AN OTHER ONE (PROVIDED AS A LIST OF CELLS)  #
	#-----------------------------------------------------------------------------------------#

	def ReplaceRow(pnRow, paNewRow)
		if CheckParams()
			if isList(pnRow) and
			   ( Q(pnRow).IsAtNamedParam() or
			     Q(pnRow).IsAtPositionNamedParam() )
				pnRow = pnRow[2]
			ok
	
			if isList(paNewRow) and
			   ( Q(paNewRow).IsOneOfTheseNamedParams([ :By, :With, :Using ]) or
			     Q(paNewRow).IsByRowNamedParam() or
			     Q(paNewRow).IsWithRowNamedParam() )
	
				paNewRow = paNewRow[2]
			ok
		ok

		aRowCells = This.RowAsPositions(pnRow)
		This.ReplaceCellsByMany(aRowCells, paNewRow)

		#< @FunctionAlternativeForm

		def ReplaceNthRow(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowN(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowAt(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowAtPosition(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		#>

	#-- EXTENDED FORM

	def ReplaceRowXT(pnRow, paNewRow)
		nNew  = len(paNewRow)
		nRows = This.NumberOfRows()

		n = 0

		if nNew < nRows
			for i = nNew + 1 to nRows
				n++
				if n > nNew
					n = 1
				ok
				
				paNewRow + paNewRow[n]
			next

		but nNew > nRows
			for i = nNew to nRows + 1 step -1
				ring_remove(paNewRow, i)
			next
		ok

		This.ReplaceRow(pnRow, paNewRow)

		#< @FunctionAlternativeForm

		def ReplaceNthRowXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowNXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtPositionXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#--------------------------------------------------------------------------------#

	def ReplaceAllRows(paNewRow)
		if CheckParams()
			if isList(paNewRow) and
			   Q(paNewRow).IsOneOfTheseNamedParams([ :With, :By, :Using ])
				paNewRow = paNewRow[2]
			ok
	
			if NOT isList(paNewRow) 
				StzRaise("Incorrect param type! paNewRow must be a list.")
			ok
		ok

		nLenCols = Min([ len(paNewRow), len(@aContent) ])
		nLenRows = This.NumberOfRows()

		for i = 1 to nLenCols
			for j = 1 to nLenRows
				@aContent[i][2][j] = paNewRow[i]
			next
		next

		#< @FunctionAlternativeForms

		def ReplaceRows(paNewRow)
			This.ReplaceAllRows(paNewRow)

		def ReplaceRowsWith(paNewRow)
			This.ReplaceAllRows(paNewRow)
	
		def ReplaceRowsBy(paNewRow)
			This.ReplaceAllRows(paNewRow)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#--------------------------------------------------------------------------------------------#

	def ReplaceAllRowsXT(paNewRow)
		nRows = This.NumberOfRows()

		for i = 1 to nRows
			This.ReplaceRowXT(i, paNewRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		def ReplaceRowsWithXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)
	
		def ReplaceRowsByXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		#>

	  #----------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------#

	def ReplaceRowsAt(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = len(anPosU)

		for i = 1 to nLen
			This.ReplaceRowAt(anPosU[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplacesNthRows(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAt(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplacesNthRowumns(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------#

	def ReplaceRowsAtXT(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = len(anPosU)

		for i = 1 to nLen
			This.ReplaceRowAtXT(anPosU[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowumnsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		#>

	  #-------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------#

	def ReplaceTheseRows(panRowsNumbers, paNewRow)
		if Q(paNewRow).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositions(panRowsNumbers, paNewRow)

		def ReplaceTheseRowumns(panRowsNumbers, paNewRow)
			This.ReplaceTheseRows(panRowsNumbers, paNewRow)

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#

	def ReplaceTheseRowsXT(panRowsNumbers, paNewRow)
		if Q(paNewRow).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositionsXT(panRowsNumbers, paNewRow)

		def ReplaceTheseRowumnsXT(panRowsNumbers, paNewRow)
			This.ReplaceTheseRowsXT(panRowsNumbers, paNewRow)

	  #===============================================================#
	 #  REPLACING THE CELLS IN THE GIVEN ROWS BY THE PTOVIDED VALUE  #
	#===============================================================#

	def ReplaceCellsInTheseRows(paRows, pCell)
		if Q(paNewrows).IsOneOfTheseNamedParams([ :With, :By, :Using ])
			paNewrows = paNewrows[2]
		ok

		aCells = This.CellsInTheseRowsAsPositions(paRows)
		This.ReplaceCells(aCells, pCell)


		def ReplaceTheseRowsWith(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)

		def ReplaceTheseRowsBy(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)


	  #===================================================#
	 #  REPLACING ALL OCCURRENCE OF A CELL IN THE TABLE  #
	#===================================================#

	def ReplaceAllCS(pCellValue, pNewCellValue, pCaseSensitive)
		aCellsPos = This.FindAllCS(pCellValue, pCaseSensitive)
		This.ReplaceCells(aCellsPos, pNewCellValue)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceAllOccurrencesCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAll(pCellValue, pNewCellValue)
		This.ReplaceAllCS(pCellValue, pNewCellValue, TRUE)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#--

		def ReplaceAllOccurrences(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#>

	  #---------------------------------------------------#
	 #  REPLACING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#---------------------------------------------------#

	def ReplaceNthCS(n, pValue, pNewCellValue, pCaseSensitive)
		aCellPos = This.FindNthCS(n, pValue, pCaseSensitive)
		This.ReplaceCell(aCellPos, pNewCellValue)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNth(n, pValue, pNewCellValue)
		This.ReplaceNthCS(n, pValue, pNewCellValue, TRUE)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceFirstCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(1, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirst(pValue, pNewCellValue)
		This.ReplaceFirstCS(pValue, pNewCellValue, TRUE)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceLastCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(:Last, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLast(pValue, pNewCellValue)
		This.ReplaceLastCS(pValue, pNewCellValue, TRUE)

	  #====================================#
	 #  REPLACING SUBVALUES INSIDE CELLS  #
	#====================================#

	def ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInCell(pnCol, pnRow, pSubValue, pNewSubValue)
		This.ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, TRUE)

	#--

	def ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInCells(paCellsPos, pSubValue, pNewSubValue)
		This.ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, TRUE)

	#--

	def ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInCellsByMany(paCellsPos, pSubValues, pNewSubValue)
		This.ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, TRUE)

	# Add ReplaceInCellsByManyXT() : if all repalaced restart at the 1st one

	#--

	def ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInSection(paCellPos1, paCellPos2,  pSubValue, pNewSubValue)
		This.ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, TRUE)

	#--

	def ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */

	def ReplaceInSectionByMany(paCellPos1, paCellPos2,  pSubValues, pNewSubValue)
		This.ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, ;CaseSensitive = TRUE)

	# Add ReplaceInSectionByManyXT() : if all replaced restart at the 1st one

	#--

	def ReplaceInSectionsCS(aSections, pSubValue, pCaseSensitive)
		/* ... */

	ReplaceInSections(aSections, pSubValue)
		This.ReplaceInSectionsCS(aSections, pSubValue, TRUE)

	#--

	def ReplaceInSectionsByManyCS(aSections, paSubValues, pCaseSensitive)
		/* ... */

	ReplaceInSectionsByMany(aSections, paSubValues)
		This.ReplaceInSectionsByManyCS(aSections, paSubValues, TRUE)

	#-- Add ReplaceInSectionsByManyXT() : if all replaced restrat at 1st one

	  #==================#
	 #  ADDING COLUMNS  #
	#==================#

	def AddColumn(paColNameAndData)
		/* EXAMPLE

		o1.AddCol( :AGE = [ 12, 28, 32 ] )

		*/

		if NOT ( isList(paColNameAndData) and 
			 len(paColNameAndData) = 2 and
			 isString(paColNameAndData[1]) and
			 isList(paColNameAndData[2]) )
			
			StzRaise("Incorrect column format! paColNameAndData must take the form :ColName = [ cell1, cell2, ... ].")
		ok

		if This.IsColName(paColNameAndData[1])
			StzRaise("Can't add the column! The name your provided already exists.")
		ok

		nLen = len(paColNameAndData[2])
		nRows = This.NumberOfRows()

		if nLen < nRows
			for i = nLen+1 to nRows
				paColNameAndData[2] + NULL
			next

		but nLen > nRows
			for i = nLen to nRows+1 step - 1
				ring_remove(paColNameAndData[2], i)
			next
		ok
			
		This.Content() + paColNameAndData

		def AddCol(paColNameAndData)
			This.AddColumn(paColNameAndData)

	def AddColumns(paColNamesAndData)
		nLen = len(paColNamesAndData)

		for i = 1 to nLen
			This.AddColumn(paColNamesAndData[i])
		next

		def AddCols(paColNamesAndData)
			This.AddColumns(paColNamesAndData)

	  #===============#
	 #  ADDING RAWS  #
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

		if NOT len(paRow) = This.NumberOfCols()
			StzRaise("Incorrect format! paRow must contain " + This.NumberOfCols() + " items.")
		ok

		for i = 1 to nLen
			@aContent[i][2] + paRow[i]
		next

	def AddRows(paRows)
		if NOT isList(paRows)
			StzRaise("Incorrect param type! paRows must be a list.")
		ok

		nLen = len(paRows)
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
		if isList(paNewTable) and Q(paNewTable).IsWithOrByOrUsingNamedParam()
			paNewTable = paNewTable[2]
		ok

		if NOT( isList(paNewTable) and Q(paNewTable).IsHashList() and
			StzHashListQ(paNewTable).ValuesAreListsOfSameSize()  )

			StzRaise("Incorrect param type! paNewTable must be a hashlist where values are lists of the same size.")
		ok

		@aContent = paNewTable

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
			if Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				pCol = 1

			but Q(pCol).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
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

		nLen = len(paColsAndTheirNewNames)

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

		This.Table()[n][1] = pcNewName

		def RenameColN(n, pcNewName)
			This.RenameNthCol(n, pcNewName)

	def RemnameNthCols(panColsNumbers)
		if NOT (isList(paColsNumbers) and Q(paColsNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! panColsNumbers must be a list of numbers.")
		ok

		nLen = len(panColsNumbers)

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
			@aContent = [ [ :COL1, [ NULL ] ] ]
			return
		ok

		ring_remove(@aContent, n)
	
		def RemoveColAt(n)
			This.RemoveNthCol(n)

		def RemoveNthColumn(n)
			This.RemoveNthCol(n)

		def RemoveColumnAt(n)
			This.RemoveNthCol(n)
	
	def RemoveColumn(pColNameOrNumber)
		nCol = This.ColToColNumber(pColNameOrNumber)

		if This.NumberOfCols() = 1 and nCol = 1
			@aContent = [ [ :COL1, [ NULL ] ] ]
			return
		ok

		ring_remove(@aContent, nCol)

		def RemoveCol(pColNameOrNumber)
			This.RemoveColumn(pColNameOrNumber)

	  #------------------------------#
	 #  REMOVING THE GIVEN COLUMNS  #
	#------------------------------#

	def RemoveColumnsAt(panColNumbers)
		if CheckParams()
			if NOT ( isList(panColNumbers) and @IsListOfNumbers(panColNumbers) )
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		anColNumbers = ring_sort( U(TpaColNamesOrNumbers) )
		nLen = len(anColNumbers)

		for i = nLen to 1 step -1
			ring_remove(@aContent, anColNumbers[i])
		next

		def RemoveColsAt(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthCols(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

		def RemoveNthColumns(panColNumbers)
			This.RemoveColumnsAt(panColNumbers)

	def RemoveColumns(paColNamesOrNumbers)
		anColNumbers = ring_sort( U(This.TheseColsToColNumbers(paColNamesOrNumbers)) )
		nLen = len(anColNumbers)

		for i = nLen to 1 step -1
			ring_remove(@aContent, anColNumbers[i])
		next

		if len(@aContent) = 0
			@aContent = [ :COL1 = [ NULL ] ]
		ok

		def RemoveCols(pColNamesOrNumbers)
			This.RemoveColumns(pColNamesOrNumbers)

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
		if CheckParams()
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
		@aContent = [ :COL1 = [ NULL ] ]

		def RemoveAllCols()
			This.RemoveAll()

		def RemoveAllColumns()
			This.RemoveAll()

	  #------------------------#
	 #  REMOVING A GIVEN ROW  #
	#========================#

	def RemoveRow(pRowOrRowNumber)
		if CheckParams()
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
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = len(@aContent)

		for i = 1 to nLen
			ring_remove(@aContent[i][2], n)
		next

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

		if CheckParams()
			if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
				StzRaise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		nLen = len(@aContent)
		anPos = ring_sort(panRows)
		nLenPos = len(anPos)

		for i = nLen to 1 step -1
			for j = 1 to nLen
				ring_remove(@aContent[j][2], anPos[i])
			next
		next


		def RemoveRowsAt(panRows)
			This.RemoveNthRows(panRows)

	def RemoveRows(pRowsOrRowsNumbers)
		if CheckParams()
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
		if CheckParams()
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

		if CheckParams()
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

		nLen = len(@aContent)

		for i = 1 to nLen
			nLenLine = len(@aContent[i][2])
			for j = 1 to nLenLine
				@aContent[i][2][j] = NULL
			next
		next

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

	def EraseColumns(pColNamesOrNumbers)
		nCols = This.TheseColsToColsNumbers(pColNamesOrNumbers)

		for n in nCols
			This.EraseCol(n)
		next

		def EraseCols(pColNamesOrNumbers)
			This.EraseColumns(pColNamesOrNumbers)

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

		for n in panRows
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

		@aContent[pCol][2][pnRow] = NULL

		def EraseCellAtPosition(pCol, pnRow)
			This.EraseCell(pCol, pnRow)

	def EraseCells(paCellsPos)
		if NOT ( isList(paCellsPos) and @IsListOfPairsOfNumbers(paCellsPos) )
			StzRaise("Incorrect param type! paCellsPos must be a list of pairs of numbers.")
		ok

		nLen = len(paCellsPos)

		for i = 1 to nLen
			nCol = paCellsPos[i][1]
			nRow = paCellsPos[i][2]
			@aContent[nCol][2][nRow] = NULL
		next

		def EraseCellsAtPositions(paCellsPos)
			This.EraseCells(paCellsPos)

	def EraseSection(paCellPos1, paCellPos2)
		aCellsPso = This.SectionAsPositions()
		This.EraseCells(aCellsPos)

	  #======================#
	 #  INSERTING A COLUMN  # // TODO
	#======================#

	def InsertColumn(n, paColData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertCol(n, paColData)
			return This.InsertColumn(n, paColData)

		def InsertColumnBefore(n, paColData)
			return This.InsertColumn(n, paColData)

		def InsertColBefore(n, paColData)
			return This.InsertColumn(n, paColData)

	def InsertColumnAfter(n, paColData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColAfter(n, paColData)
			This.InsertColumnAfter(n, paColData)

	def InsertColumnAt(n, paColData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColAt(n, paColData)
			This.InsertColumnAt(n, paColData)

	  #-----------------------------------------------#
	 #  INSERTING MANY COLUMNS IN THE SAME POSITION  # // TODO
	#-----------------------------------------------#

	def InsertColumns(n, paColsData) // TODO
		if isList(n) and Q(n).IsListOfNumbers()
			This.InsertColumnsInThesePositions(n, paColsData)
		ok

		StzRaise("Inexistant feature in this release!")

		def InsertCols(n, paColsData)
			return This.InsertColumns(n, paColsData)

		def InsertColumnsBefore(n, paColsData)
			return This.InsertColumns(n, paColsData)

		def InsertColsBefore(n, paColsData)
			return This.InsertsColumn(n, paColsData)

	def InsertColumnsAfter(n, paColsData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColsAfter(n, paColsData)
			This.InsertColumnsAfter(n, paColsData)

	def InsertColumnsAt(n, paColsData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColsAt(n, paColsData)
			This.InsertColumnsAt(n, paColsData)

	  #-------------------------------------------------#
	 #  INSERTING MANY COLUMNS IN DIFFERENT POSITIONS  # // TODO
	#-------------------------------------------------#

	def InsertColumnsInThesePositions(panPos, paColsData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColsInThesePositions(panPos, paColsData)
			return This.InsertColumnsInThesePositions(panPos, paColsData)

		def InsertColumnsBeforeThesePositions(panPos, paColsData)
			return This.InsertColumnsInThesePositions(panPos, paColsData)

	def InsertColumnsAfterThesePositions(panPos, paColsData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColsAfterThesePositions(panPos, paColsData)
			This.InsertColumnsAfterThesePositions(panPos, paColsData)

	def InsertColumnsAtThesePositions(panPos, paColsData) // TODO
		StzRaise("Inexistant feature in this release!")

		def InsertColsAtThesePositions(panPos, paColsData)
			This.InsertColumnsAtThesePositions(panPos, paColsData)

	  #==================#
	 #  INSERTING ROWS  # // TODO
	#==================#

	def InsertRow(n, paRowData)
		StzRaise("Inexistant feature in this release!")

		def InsertRowBefore(n, paRowData)
			return This.InsertRow(n, paRowData)

	def InsertRowAfter(n, paRowData)
		StzRaise("Inexistant feature in this release!")


	def InsertRowAt(n, paRowData)
		StzRaise("Inexistant feature in this release!")

	  #--------------------------------------------#
	 #  INSERTING MANY ROWS IN THE SAME POSITION  # // TODO
	#--------------------------------------------#

	def InsertRows(n, paRowsData)
		if isList(n) and Q(n).IsListOfNumbers()
			This.InsertRowsInThesePositions(n, paRowsData)
		ok

		StzRaise("Inexistant feature in this release!")


		def InsertRowsBefore(n, paRowsData)
			return This.InsertRows(n, paRowsData)

	def InsertRowsAfter(n, paRowsData)
		StzRaise("Inexistant feature in this release!")

	def InsertRowsAt(n, paRowsData)
		StzRaise("Inexistant feature in this release!")

	  #-----------------------------------------#
	 #  INSERTING MANY ROWS IN MANY POSITIONS  #
	#-----------------------------------------#

	def InsertRowsAtThesePositions(panPos, paRowsData)
		StzRaise("Inexistant feature in this release!")

		def InsertRowsBeforeThesePositions(panPos, paRowsData)
			return This.InsertRowsInThesePositions(panPos, paRowsData)

	def InsertRowsAfterThesePositions(panPos, paRowsData)
		StzRaise("Inexistant feature in this release!")

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

	def TheseColumns(paColNamesOrNumbers)
		if NOT 	( isList(paColNamesOrNumbers) and
			  ( Q(paColNamesOrNumbers).IsListOfNumbers() or
			  Q(paColNamesOrNumbers).IsListOfStrings() ) )

			StzRaise("Incorrect param type! paColNamesOrNumbers must be a list of numbers or a list of strings.")
		ok

		nLen = len(paColNamesOrNumbers)
		aResult = []

		for i = 1 to nLen
			aResult + This.Column(paColNamesOrNumbers[i])
		next

		return aResult

		#< @FunctionFluentForm

		def TheseColumnsQ(paColNamesOrNumbers)
			return TheseColumnsQR(paColNamesOrNumbers, :stzList)

		def TheseColumnsQR(paColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumns(paColNamesOrNumbers) )

			on :stzHashList
				return new stzHashList( This.TheseColumns(paColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumns(paColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumns(paColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def TheseCols(paColNamesOrNumbers)
			return This.TheseColumns(paColNamesOrNumbers)

			def TheseColsQ(paColNamesOrNumbers)
				return This.TheseColsQR(paColNamesOrNumbers, :stzList)

			def TheseColsQR(paColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsQR(paColNamesOrNumbers, pcReturnType)

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
			return This.ColumnsAtPositionsQR(panColNumbers, :stzList)

		def ColumnsAtPositionsQR(panColNumbers, pcReturnType)
			return This.TheseColumnsQR(panColNumbers, pcReturnType)

		#>

		#< @FunctionAlternativeForms

		def ColumnsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColumnsAtQ(panColNumbers)
				return This.ColumnsAtQR(panColNumbers, :stzList)

			def ColumnsAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsQR(panColNumbers, pcReturnType)

		def ColsAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColsAtQ(panColNumbers)
				return This.ColumnsAtQR(panColNumbers, :stzList)

			def ColsAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsQR(panColNumbers, pcReturnType)

		def ColAtPositions(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtPositionsQ(panColNumbers)
				return This.ColAtPositionsQR(panColNumbers, :stzList)

			def ColAtPositionsQR(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQR(panColNumbers, pcReturnType)

		def ColAt(panColNumbers)
			return This.TheseColumns(panColNumbers)

			def ColAtQ(panColNumbers)
				return This.ColAtQR(panColNumbers, :stzList)

			def ColAtQR(panColNumbers, pcReturnType)
				return This.TheseColumnsXTQR(panColNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------#
	 #  GETTING THE LIST OF PROVIDED COLUMNS (THEIR NAMES AND THEIR CELLS)  #
	#----------------------------------------------------------------------#

	def TheseColumnsXT(panColNamesOrNumbers)

		if NOT ( isList(panColNamesOrNumbers) and
			 Q(panColNamesOrNumbers).IsListOfStringsOrNumbers() )

			StzRaise("Incorrect param type! panColNamesOrNumbers must be a list of strings or numbers.")
		ok

		nLen = len(panColNamesOrNumbers)
		aResult = []

		for i = 1 to nLen
			p = panColNamesOrNumbers[i]
			aResult + [ This.ColName(p), This.ColData(p) ]
		next

		return aResult

		#< @FunctionFluentForm

		def TheseColumnsXTQ(panColNamesOrNumbers)
			return This.TheseColumnsXTQR(panColNamesOrNumbers, :stzList)

		def TheseColumnsXTQR(panColNamesOrNumbers, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.TheseColumnsXT(panColNamesOrNumbers) )

			on :stzListOfPairs
				return new stzListOfPairs( This.TheseColumnsXT(panColNamesOrNumbers) )

			on :stzListOfLists
				return new stzListOfLists( This.TheseColumnsXT(panColNamesOrNumbers) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def TheseColsXT(panColNamesOrNumbers)
			return This.TheseColumnsXT(panColNamesOrNumbers)

			def TheseColsXTQ(panColNamesOrNumbers)
				return This.TheseColsXTQR(panColNamesOrNumbers, :stzList)

			def TheseColsXTQR(panColNamesOrNumbers, pcReturnType)
				return This.TheseColsXT(panColNamesOrNumbers, pcReturnType)

		def TheseColXT(panColNamesOrNumbers)
			return This.TheseColumnsXT(panColNamesOrNumbers)

			def TheseColXTQ(panColNamesOrNumbers)
				return This.TheseColXTQR(panColNamesOrNumbers, :stzList)

			def TheseColXTQR(panColNamesOrNumbers, pcReturnType)
				return This.TheseColumnsXT(panColNamesOrNumbers, pcReturnType)

		#>

	  #-------------------------------------------------------------------------#
	 #  GETTING THE NAMES OF THE PROVIDED COLUMNS AS DEFINED BY THEIR NUMBERS  #
	#-------------------------------------------------------------------------#

	def TheseColNames(panColNumbers)
		if NOT ( isList(panColNumbers) and Q(panColNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! pacColNumbers muts be a list of numbers.")
		ok

		panColNumbers  = Q(panColNumbers).SortedInAscending()
		nLenColNumbers = len(panColNumbers)

		pacColNames    = This.ColNames()
		nNumCols       = len(pacColNames)
		
		if len(panColNumbers) > nNumCols
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

		nLen = len(panColNumbers)
		aResult = []

		for i = 1 to nLen
			aResult + This.NthColName(panColNumbers[i])
		next

		return aResult
	
	  #------------------------------------------------------------------#
	 #  GETTING THE NUMBERS OF COLUMNS AS DEFINED BY THEIR GIVEN NAMES  #
	#------------------------------------------------------------------#

	def ColNamesToNumbers(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok
	
		nLen = len(pacColNames)
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

	  #=============#
	 #  SUBTABLES  #
	#=============#

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
			return This.SubTableQR(pacColNames, :stzList)

		def SubTableQR(pacColNames, pcReturnType)
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

	  #-----------------------#
	 #  SUBSET OF THE TABLE  #
	#-----------------------#

	def SubSet(panRowsNumbers)
		return This.TheseRows(panRowsNumbers)

		def SubSetQ(panRowsNumbers)
			return This.SubSetQR(panRowsNumbers, :stzList)

		def SubSetQR(panRowsNumbers, pcReturnType)
			return This.TheseRowsQR(panRowsNumbers, pcReturnType)

	  #========================================================#
	 #  GETTING THE LIST OF ROWS AS DEFINED BY THEIR NUMBERS  #
	#========================================================#

	def TheseRows(panRowsNumbers)
		if NOT 	( isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers() )

			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		aResult = []

		for n in panRowsNumbers
			aResult + This.Row(n)
		next

		return aResult

		#< @FunctionFluentForm

		def TheseRowsQ(panRowsNumbers)
			return TheseRowsQR(panRowsNumbers, :stzList)

		def TheseRowsQR(panRowsNumbers, pcReturnType)
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
				return This.RowsAtPositionsQR(panRowsNumbers, :stzList)

			def RowsAtPositionsQR(panRowsNumbers, pcReturnType)
				return This.TheseRowsQR(panRowsNumbers, pcReturnType)

		def RowsAt(panRowsNumbers)
			return This.TheseRows(panRowsNumbers)

			def RowsAtQ(panRowsNumbers)
				return This.RowsAtPositionsQR(panRowsNumbers, :stzList)

			def RowsAtQR(panRowsNumbers, pcReturnType)
				return This.TheseRowsQR(panRowsNumbers, pcReturnType)

		#>

	  #----------------------------------------------------------------------------#
	 #  GETTING THE CELLS CONTAINED IN THE GIVEN ROWS ALONG WITH THEIR POSITIONS  #
	#----------------------------------------------------------------------------#

	def TheseRowsZ(panRowsNumbers)
		if NOT (isList(panRowsNumbers) and Q(panRowsNumbers).IsListOfNumbers())
			StzRaise("Incorrect param type! panRowsNumbers must be a list of numbers.")
		ok

		nLen = len(apnRowsNumbers)

		aResult = []
		for n in nLen
			aResult + This.RowZ(panRowsNumbers[i])
		next

		return aResult

		def TheseRowsZQ(panRowsNumbers)
			return This.TheseRowsZQR(panRowsNumbers, :stzList)

		def TheseRowsZQR(panRowsNumbers, pcReturnType)
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
			if Q(pnFrom).IsOneOfThese([
				:First, :FirstCol, :FirstColumn, :FirstPosition ])

				pnFrom = 1

			but Q(pnFrom).IsOneOfThese([
				:Last, :LastCol, :LastColumn, :LastPosition ])

				pnFrom = This.NumberOfCols()
			ok
		ok

		if isString(pnTo)
			if Q(pnTo).IsOneOfThese([
				:First, :FirstCol, :FirstColumn, :FirstPosition ])

				pnTo = 1

			but Q(pnTo).IsOneOfThese([
				:Last, :LastCol, :LastColumn, :LastPosition ])

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

		if pnFrom != pnTo
			aCopy = @aContent[pnTo]
			@aContent[pnTo] = @aContent[pnFrom]
			@aContent[pnFrom] = aCopy
		ok

		#< @FunctionAlternativeForm

		def MoveColumn(pnFrom, pnTo)
			This.MoveCol(pnFrom, pnTo)

		#>

	  #--------------------------#
	 #   SWAPPING TWO COLUMNS   #
	#--------------------------#

	def SwapColNames(pCol1, pCol2)
		bCol1IsValid = ( isNumber(pCol1) and Q(pCol1).IsBetween(1, This.NumberOfCol()) )
		bCol2IsValie = ( isString(pCol2) and This.HasColName(pCol2) )

		if NOT ( bCol1IsValid or bCol2IsValie )
			StzRaise("Incorrect params! pCol1 and pCol2 must be valid columns names or strings.")
		ok

		cName1 = This.ColName(pCol1)
		cName2 = This.ColName(pCol2)

		nCol1 = This.ColNumber(pCol1)
		nCol2 = This.ColNumber(pCol2)

		@aContent[nCol1][1] = cName2
		@aContent[nCol2][1] = cName1

		#< @FunctionAlternativeForm

		def SwapColumnNames(pcCol1, pcCol2)
			This.SwapColNames(pcCol1, pcCol2)

		def SwapColumnsNames(pcCol1, pcCol2)
			This.SwapColNames(pcCol1, pcCol2)

		#>

	def SwapCol(pCol1, pCol2)
		if isList(pCol1) and
			( Q(pCol1).IsAndNamedParam() or
			  Q(pCol1).IsAndPositionNamedParam() or

			  Q(pCol1).IsAndColNamedParam() or
			  Q(pCol1).IsAndColumnNamedParam() or

			  Q(pCol1).IsAndColAtNamedParam() or
			  Q(pCol1).IsAndColumnAtNamedParam() or

			  Q(pCol1).IsAndColAtPositionNamedParam() or
			  Q(pCol1).IsAndColumnAtPositionNamedParam() or

			  Q(pCol1).IsBetweenNamedParam() or

			  Q(pCol1).IsBetweenColNamedParam() or
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
			  Q(pCol2).IsAndColNamedParam() or
			  Q(pCol2).IsAndColumnNamedParam() or
			  Q(pCol2).IsAndColAtNamedParam() or
			  Q(pCol2).IsAndColumnAtNamedParam() or
			  Q(pCol2).IsAndColAtPositionNamedParam() or
			  Q(pCol2).IsAndColumnAtPositionNamedParam() or
			  Q(pCol2).IsAndColNamedNamedParam() or
			  Q(pCol2).IsAndColumnNamedNamedParam()
			)

			pCol2 = pCol2[2]
		ok

		if This.ColNumber(pCol1) != This.ColNumber(pCol2)
			aCopyOfCol1 = This.Col(pCol1)
			This.ReplaceCol(pCol1, This.Col(pCol2) )
			This.ReplaceCol(pCol2, aCopyOfCol1)
	
			This.SwapColNames(pCol1, pCol2)
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

		n = This.ColNumber(pCol)
		@aContent[n][1] = pcNewColName

		#< @FunctionAlternativeForm

		def ReplaceColumnName(pCol, pcNewColName)
			This.ReplaceColName(pCol, pcNewColName)

		#>

	def AreColNames(pacColNames)
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of strings.")
		ok

		nLen = len(pacColNames)
		bResult = TRUE

		for i = 1 to nLen
			if NOT This.IsColName(pacColNames[i])
				bResult = FALSE
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

	  #==================================#
	 #  SORTING THE TABLE IN ASCENDING  #
	#==================================#

	def Sort()
		This.SortOn(1)

		#< @FunctionAlternativeForms

		def SortUp()
			This.Sort()

		def SortOnAsecending()
			This.Sort()

		#>

	  #-----------------------------------#
	 #  SORTING THE TABLE IN DESCENDING  #
	#-----------------------------------#

	def SortDown()
		This.SortOnDown(1)

		def SortOnInDesending()
			This.SortDown()

	  #----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN ASCENDiNG  #
	#====================================================#

	#TODO
	# Check performance on large tables

	def SortOn(pCol)
		nCol = This.ColToColNumber(pCol)
		aRowsSorted = @SortOn( This.Rows(), nCol)

		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next


		#< @FunctionAlternativeForms

		def SortOnUp(pCol)
			This.SortOn(pCol)

		def SortOnInAscending(pCol)
			This.SortOn(pCol)

		def SortOnCol(pCol)
			This.SortOn(pCol)

		def SortOnColUp(pCol)
			This.SortOn(pCol)

		def SortOnColInAscending(pCol)
			This.SortOn(pCol)

		def SortOnColumn(pCol)
			This.SortOn(pCol)

		def SortOnColumnUp(pCol)
			This.SortOn(pCol)

		def SortOnColumnInAscending(pCol)
			This.SortOn(pCol)

		#>

	  #-----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN DESCENDiNG  #
	#=====================================================#

	def SortOnDown(pCol)

		nCol = This.ColToColNumber(pCol)
		aRowsSorted = ring_reverse( @SortOn( This.Rows(), nCol) )

		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next

		#< @FunctionAlternativeForms

		def SortOnInDescending(pCol)
			This.SortOnDown(pCol)

		def SortOnColDown(pCol)
			This.SortOnDown(pCol)

		def SortInColInDescending(pCol)
			This.SortOnDown(pCol)

		def SortOnColumnDown(pCol)
			This.SortOnDown(pCol)

		def SortOnColumnInDescending(pCol)
			This.SortOnDown(pCol)

		#>

	  #========================================================#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN ASCENDING  #
	#========================================================#

	def SortBy(pcExpr)
		This.SortOnBy(1, pcExpr)

		def SortByUp(pcExpr)
			This.SortBy(pcExpr)

		def SortByInAsecending(pcExpr)
			This.SortBy(pcExpr)

		#>

	  #---------------------------------------------------------#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN DESCENDING  #
	#---------------------------------------------------------#

	def SortByDown(pcExpr)
		This.SortOnByDown(1, pcExpr)

		def SortOnByInDesending(pcExpr)
			This.SortByDown(pcExpr)

	  #--------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN ASCENDiNG  #
	#==========================================================================#

	def SortOnBy(pCol, pcExpr)

		nCol = This.ColToColNumber(pCol)
		oLoL = new stzListOfLists( This.Rows() )
		pcExpr = StzStringQ(pcExpr).ReplaceCSQ("@cell", "@item", FALSE).Content()

		oLoL.SortOnBy(nCol, pcExpr)

		aRowsSorted = oLoL.Content()
		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next

		#< @FunctionAlternativeForms

		def SortOnByUp(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnByInAscending(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColByUp(pCol)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColByInAscending(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColumnByUp(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		def SortOnColumnByInAscending(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

		#>

	  #---------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN DESCENDiNG  #
	#===========================================================================#

	def SortOnByDown(pCol, pcExpr)

		nCol = This.ColToColNumber(pCol)

		oLoL = new stzListOfLists( This.Rows() )
		pcExpr = StzStringQ(pcExpr).ReplaceCSQ("@cell", "@item", FALSE).Content()
		oLoL.SortOnByDown(nCol, pcExpr)

		aRowsSorted = oLol.Content()
		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next

		#< @FunctionAlternativeForms

		def SortOnByInDescending(pCol, pcExpr)
			This.SortOnByDown(nCol, pcExpr)

		def SortOnColByDown(nCol, pcExpr)
			This.SortOnByDown(pCol, pcExpr)

		def SortInColByInDescending(pCol, pcExpr)
			This.SortOnByDown(pCol, pcExpr)

		def SortOnColumnByDown(pCol, pcExpr)
			This.SortOnByDown(pCol, pcExpr)

		def SortOnColumnByInDescending(pCol, pcExpr)
			This.SortOnByDown(pCol, pcExpr)

		#>

	  #=====================#
	 #  SHOWING THE TABLE  #
	#=====================#

	def Show()
		? This.ToString()
	
		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	def ToString()
		aDefaultOptions = [
			:Separator 	  = "   ",
			:Alignment 	  = :Right,
		
			:UnderLineHeader  = TRUE,
			:UnderLineChar 	  = "-",
			:IntersectionChar = " ",
		
			:ShowRowNumbers   = FALSE
		]

		cResult = This.ToStringXT(aDefaultOptions)
		return cResult

	def ToStringXT(paOptions)
		/* EXAMPLE

		? o1.toStringXT([
			:Separator = " | ",
			:Alignment = :Left,
			:UnderLineHeader = TRUE,
			:UnderLineChar = "-",
			:IntersectionChar = " "
			:ShowRowNumbers = TRUE
		])

		*/

		# Accelerating access using just one option provided in a string
		# inclunding when no option is provided at all
		#--> ShowXT(NULL) or ShowXT([])

		if isString(paOptions)
			if isNull(paOptions)

				return This.ToStringXT([])

			but paOptions = :UnderLineHeader or
			    paOptions = :AddLineUnderHeader or

			    paOptions = :UnderLineColNames or
			    paOptions = :AddLineUnderColNames or

			    paOptions = :UnderLineColsNames or
			    paOptions = :AddLineUnderColsNames or

			    paOptions = :UnderLineColumnNames or
			    paOptions = :AddLineUnderColumnNames or

			    paOptions = :UnderLineColumnsNames or
			    paOptions = :AddLineUnderColumnsNames

				return This.ShowXT([ :UnderLineHeader = TRUE ])

			but paOptions = :ShowRowNumbers or	#TODO: Add those named params
			    paOptions = :AddRowNumbers or	# to ShowXT([ ... ])
			    paOptions = :WithRowNumbers or
			    paOptions = :RowNumbers

				return This.ToStringXT([ :ShowRowNumbers = TRUE ])

			but paOptions = :AlignedToLeft or
			    paOptions = :AdjustedToLeft or
			    paOptions = :ToLeft or
			    paOptions = :Lefted

				return This.ToStringXT([ :Alignment = :Left ])
			
			but paOptions = :AlignedToRight or
			    paOptions = :AdjustedToRight or
			    paOptions = :ToRight or
			    paOptions = :Righted

				return This.ToStringXT([ :Alignment = :Right ])

			but paOptions = :AlignedToCenter or
			    paOptions = :AdjustedToLeft or
			    paOptions = :ToLeft or
			    paOptions = :Lefted

				return This.ToStringXT([ :Alignment = :Right ])
			ok
		ok

		# Providing the options in a list

		if NOT isList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a list.")
		ok

		if len(paOptions) = 0

			cResult = This.ToStringXT([ 
				:UnderLineHeader = TRUE,
				:UnderLineChar = "-",
				:InterSectionChar = " ",
				//:Seprator = "   ",
				:Alignment = :Right
			])

			return cResult

		ok

		nLen = len(paOptions)
		aOptions = []
		for i = 1 to nLen

			if isString(paOptions[i]) and
			   ( paOptions[i] = :UnderLineHeader or paOptions[i] = :ShowRowNumbers )

				aOptions + [ paOptions[i], TRUE ]
					
			else
				aOptions + paOptions[i]
			ok
		next

		if NOT (len(aOptions) = 0 or Q(aOptions).IsHashList())
			StzRaise("Incorrect param! paOptions must be either an empty list or a hashlist.")
		ok

		# Setting the default options

		cSeparator = " | "
		cAlignment = :Right
		
		bUnderlineHeader = TRUE
		cUnderLineChar = "-"
		cIntersectionChar = "+"

		bShowRowNumbers = TRUE

		# Reading the options provided by the user

		pSeparator = aOptions[:Separator]

		if pSeparator != NULL and isString(pSeparator)
			if pSeparator = :Default
				cSeparator = "  "
			else
				cSeparator = pSeparator
			ok

		but pSeparator = NULL
			pSeparator = " | "
		ok

		#--

		pAlignment = aOptions[:Alignment]

		if pAlignment != NULL and isString(pAlignment)

			if ( pAlignment = :Right or pAlignment = :Left or pAlignment = :Center)
				cAlignment = pAlignment

			but pAlignment = :Default
				cAlignment = :Right
			ok

		but pAlignment = NULL
			pAlignment = :Right
		ok

		#--

		pUnderLineHeader = aOptions[:UnderLineHeader]

		if isString(pUnderlineHeader) and pUnderLineHeader = NULL
			bUnderLineHeader = FALSE

		but isNumber(pUnderLineHeader) and ( pUnderLineHeader = 0 or pUnderLineHeader = 1 )
			bUnderLineHeader = pUnderLineHeader

		else
			StzRaise("Incorrect param type! bUnderLineHeader must be a boolean.")
		ok

		#--

		cUnderLineChar = aOptions[:UnderLineChar]

		if NOT isString(cUnderLineChar)
			StzRaise("Incorrect param type! You must provide a string in :UnderLineChar = ...")
		ok

		if cUnderLineChar != NULL
			bUnderLineHeader = TRUE
		ok

		if bUnderLineHeader = TRUE and cUnderLineChar = ""
			cUnderLineChar = "-"
		ok

		#--

		cIntersectionChar = aOptions[:IntersectionChar]

		if NOT isString(cUnderLineChar)
			StzRaise("Incorrect param type! You must provide a string in :InterSectionChar = ...")
		ok

		if cInterSectionChar != NULL
			bUnderLineHeader = TRUE
			if cUnderLineChar = ""
				cUnderLineChar = "-"
			ok
			cInterSectionChar = cUnderLineChar + cInterSectionChar + cUnderLineChar

		else
			cInterSectionChar = "---"
		ok

		#--

		pShowRowNumbers = aOptions[:ShowRowNumbers]

		if isString(pShowRowNumbers) and pShowRowNumbers = NULL
			bShowRowNumbers = FALSE

		but isNumber(pShowRowNumbers)
			if pShowRowNumbers = TRUE
				bShowRowNumbers = TRUE

			else pShowRowNumbers = FALSE
				bShowRowNumbers = FALSE
			ok

		else
			StzRaise("Incorrect param type! bShowRowNumbers must be TRUE or FALSE.")
		ok

		# Doing the job

		acAdjustedCols = []
		nLen = This.NumberOfCols()
		
		# Adjusting the widths of all cells

		for i = 1 to nLen

			cName = This.ColName(i)
			acCurrentColAdjusted = This.ColQ(i).Stringified() + cName

			if bUnderLineHeader and cUnderLineChar != ""
				oColXT = This.ColQ(i).AddItemQ(cName)

				cUnderline = StzStringQ(cUnderLineChar).RepeatedNTimes( oColXT.StringifyQ().MaxSize() )
				ring_insert(acCurrentColAdjusted, 1, cUnderline)
			ok

			oListOfStr = new stzListOfStrings(acCurrentColAdjusted)
			acCurrentColAdjusted = oListOfStr.AdjustedTo(cAlignment)

			acAdjustedCols + acCurrentColAdjusted
	
		next

		# Putting the adjusted cells in a stzTable object

		nLast = len(acAdjustedCols[1])

		aTable = []
		
		for i = 1 to nLen
			aTable + [ acAdjustedCols[i][nLast], Q(acAdjustedCols[i]).LastItemRemoved() ]
		next
		
		oTable = new stzTable(aTable)
		nCols = oTable.NumberOfCols()
		nRows = oTable.NumberOfRows()

		cString = ""

		# Constructing the header()

		if bUnderLineHeader = TRUE
			acRowNumbers = (0 : (nRows-1)) + "#"
		else
			acRowNumbers = (1 : nRows ) + "#"
		ok

		acRowNumbersAdjusted  = Q(acRowNumbers).
					StringifyQ().
					ToStzListOfStrings().
					AdjustedToRight()

		if bShowRowNumbers
			cString = acRowNumbersAdjusted[ len(acRowNumbersAdjusted) ] + cSeparator
		ok
		for i = 1 to nCols
			cString += oTable.ColNameQ(i).Uppercased()
			if i < nCols
				cString += cSeparator
			ok
		next

		# Constructing the underline

		nStart = 1

		if bUnderlineHeader
			cUnderline = ""
			if bShowRowNumbers
				nTemp = len( ""+ This.NumberOfRows() )
				cTemp = ""
				for i = 1 to nTemp
					cTemp += cUnderLineChar
				next
				cUnderline = cTemp + cInterSectionChar
			ok

			for i = 1 to nCols
				cUnderline += oTable.Cell(i, 1)
				if i < nCols
					cUnderline += cInterSectionChar
				ok
			next

			cString += (NL + cUnderline)
			nStart = 2
		ok

		# Constructing the rows

		for j = nStart to nRows
			cRow = ""
			if bShowRowNumbers
				cRow += acRowNumbersAdjusted[j] + cSeparator
			ok

			for i = 1 to nCols
				cCell = oTable.Cell(i, j)

				cRow += cCell
				
				if i < nCols
					cRow += cSeparator
				ok
	
			next

			cString += (NL + cRow)
		next

		return cString

	  #-----------------------------------------------------------#
	 #  FILLING ALL THE TABLE WITH A GIVEN CELL, COLUMN, OR ROW  #
	#-----------------------------------------------------------#

	def Fill(pValue)
		/*

		EXAMPLE 1:

		o1 = new stzTable([3, 3])
		o1.Fill( :With = "A" )	# or ( :WithCell = "A" )
		o1.Show()
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "A"	  "A"	  "A"
		# 3	  "A"	  "A"	  "A"

		EXAMPLE 2:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithCol = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "B"	  "B"	  "B"
		# 3	  "C"	  "C"	  "C"

		EXAMPLE 3:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithRow = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "B"	  "C"
		# 2	  "A"	  "B"	  "C"
		# 3	  "A"	  "B"	  "C"

		*/

		cFill = :WithCell

		if isList(pValue) and
		   Q(pValue).IsOneOfTheseNamedParams([
			:With, :WithCell, :WithCol, :WithColumn, :WithRow,
			:Using, :UsingCell, :UsingCol, :UsingColumn, :UsingRow ])

			cFill  = pValue[1]
			pValue = pValue[2]
		ok

		if cFill = :With or cFill = :WithCell
			for i = 1 to This.NumberOfCols()
				for v = 1 to This.NumberOfRows()
					This.ReplaceCell(i, v, pValue)
				next v
			next i

		but Q(cFill).IsOneOfThese([
			:WithCol, :WithColumn, :UsingCol, :UsingColumn ])
		    
			This.ReplaceCols(:With = pValue)

		but cFill = :WithRow or cFill = :UsingRow

			This.ReplaceRows(:By = pValue)

		else
			StzRaise("Unsupported syntax! Allowed named params are: " +
				 ":WithCell, :WithColumn, and :WithRow.")
		ok
		
		#< @FunctionFuentForm

		def FillQ(pValue)
			This.Fill(pValue)
			return This

		def FillCQ(pValue) #TODO: Add this to all functions
			return This.Copy().FillQ(pValue)

	def Filled(pValue)
		aResult = This.Copy().FillQ(pValue).Content()
		return aResult

	  #=================================#
	 #  MISC. : SOME USEFUL UTILITIES  #
	#=================================#

	def ToStzHashList()
		return new stzHashList( This.Table() )

	def ColToColName(p)
		if isList(p) and
		   Q(p).IsOneOfTheseNamedParams([
			:Col, :InCol, :Cols, :InCols,
			:Column, :InColumn, :Columns, :InColumns	
		   ])

			p = p[2]
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		cResult = This.ColName(p)
		return cResult

		def ColumnToColumnName(p)
			return This.ColToColName(p)

		def ColToName(p)
			return This.ColToColName(p)

		def ColAsName(p)
			return This.ColToColName(p)

		def ColumnAsName(p)
			return This.ColToColName(p)

	def TheseColsToColNames(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		nLen = len(paCols)
		acResult = []

		for i = 1 to nLen
			acResult + This.ColToColName(paCols[i])
		next

		return acResult

		#< @FunctionAlternativeForms

		def TheseColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#--

		def ColsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#>

	def ColToColNumber(p)
		if isNumber(p) and p <= This.NumberOfCol()
			return p
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)
			if Q(p).IsOneOfThese([ :First, :FirstCol, :FirstColumn ])
				p = 1

			but Q(p).IsOneOfThese([ :Last, :LastCol, :LastColumn ])
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.ColNamesQ().FindFirst(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		if NOT Q(p).IsBetween(1, This.NumberOfCols())
			StzRaise("Incorrect value! n must correspond to a valid number of column.")
		ok

		nResult = p
		return nResult

		#< @functionAlternativeForms

		def ColumnToColumnNumber(p)
			return This.ColToColNumber(p)

		def ColToNumber(p)
			return This.ColToColNumber(p)

		def ColNumber(p)
			return This.ColToColNumber(p)

		def ColumnToNumber(p)
			return This.ColToColNumber(p)

		def ColumnNumber(p)
			return This.ColToColNumber(p)

		def ColAsNumber(p)
			return This.ColToColNumber(p)

		def ColumnAsNumber(p)
			return This.ColToColNumber(p)

		#>

	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		nLen = len(paCols)
		anResult = []

		for i = 1 to nLen
			anResult + This.ColToColNumber(paCols[i])
		next

		return anResult

		#< @FunctionAlternativeForms

		def TheseColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		#--

		def ColsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		#>

	def RowToRowNumber(pRow)
		if isList(pRow) and Q(pRow).IsOneOfTheseNamedParams([ :Row, :Rows, :InRow, :InRows, :OfRow, :OfRows ])
			pRow = pRow[2]
		ok

		if isString(pRow)
			if pRow = :First or pRow = :FirstRow
				pRow = 1
			but pRow = :Last or pRow = :LastRow
				pRow = This.NumberOfRows()
			ok
		ok

		if NOT isNumber(pRow)
			StzRaise("Incorrect param type! pRow must be a number.")
		ok

		return pRow

		def RowToNumber(pRow)
			return This.RowToRowNumber(pRow)

		def RowAsNumber(pRow)
			return This.RowToRowNumber(pRow)

	def TheseRowsToRowsNumbers(paRows)
		if NOT ( isList(paRows) and Q(paRows).IsListOfLists() )
			StzRaise("Incorrect param type! paRows must be a list of lists.")
		ok

		nLen = len(paRows)
		aResult = []

		for i = 1 to nLen
			aResult + This.RowToNumber(paRows[i])
		next

		return aResult

		#< @FunctionAlternativeForms

		def TheseRowsToNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def TheseRowsAsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		#>

	  #=============================#
	 #  USED BY SQL EXTERNAL CODE  #
	#=============================#

	def @(paColNames)
		/*
		@([

		:id    = SMALLINT,
		:name  = VARCHAR(30),
		:score = SMALLINT

		])
		*/

		if CheckParams()
			if NOT ( isList(paColNames) and Q(paColNames).IsHasHListOrListOfStrings() )
				StzRaise("Incorrect param type! paColNames must be a hashlist.")
			ok
		ok

		nLen = len(paColNames)
		acColNames = []

		if Q(paColNames).IsListOfStrings()
			for i = 1 to nLen
				acColNames + [ paColNames[i], [NULL] ]
			next

		else // IsHashList()
			for i = 1 to nLen
				acColNames + [ paColNames[i][1], [NULL] ]
			next
		ok

		This.AddCols(acColNames)
		This.RemoveCol(1)

#================
/*
#TODO: stzTable add (all) excel functions
# Some common used functions are:

| Function Name     | Short Description           | Example               | Output               |
|-------------------|-----------------------------|-----------------------|----------------------|
| SUM               | Sums up a range of cells    | =SUM(A1:A10)          | 55                   |
| AVERAGE           | Calculates the average      | =AVERAGE(B1:B10)      | 23.5                 |
| COUNT             | Counts the number of cells  | =COUNT(C1:C10)        | 7                    |
| MAX               | Returns the maximum value   | =MAX(D1:D10)          | 98                   |
| MIN               | Returns the minimum value   | =MIN(E1:E10)          | 12                   |
| CONCATENATE       | Joins text strings together | =CONCATENATE("Hello", " ", "World") | Hello World |
| IF                | Checks a condition and returns one value if true, another if false | =IF(A1>10, "Yes", "No") | Yes |
| VLOOKUP           | Searches for a value in the first column of a range and returns a value from the same row in a specified column | =VLOOKUP("apple", A1:B10, 2, FALSE) | Red |
| INDEX             | Returns the value of a cell in a specified row and column number | =INDEX(C1:E10, 3, 2) | 75 |
| MATCH             | Searches for a value in a range and returns its relative position | =MATCH("apple", A1:A10, 0) | 3 |
| SUMIF             | Sums cells that meet a certain condition | =SUMIF(F1:F10, ">50") | 167 |
| COUNTIF           | Counts cells that meet a certain condition | =COUNTIF(G1:G10, "Yes") | 3 |
| AVERAGEIF         | Calculates the average of cells that meet a certain condition | =AVERAGEIF(H1:H10, "<>0") | 26.4 |
| IFERROR           | Returns a value if a formula results in an error; otherwise, returns the result of the formula | =IFERROR(I1/J1, "Error") | Error |
| TEXT              | Converts a value to text using a specified format | =TEXT(NOW(), "dd-mmm-yyyy") | 04-Aug-2023 |
| RAND              | Generates a random number between 0 and 1 | =RAND() | 0.8742356 |

	# Other excel functions:
	SUMPRODUCT
	COUNTIFS
	AVERAGEIFS
	IFNA
	ROUND
	TEXTJOIN
	LEFT
	RIGHT
	MID
	TODAY
	NOW
	NETWORKDAYS
	RANK
	OFFSET
	INDIRECT
*/
