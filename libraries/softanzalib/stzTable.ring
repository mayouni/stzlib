
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
			// --> TODO: Verfy of it is well formatted
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

	def Cell(pCol,nLine)
		if type(pCol) = "NUMBER"
			return line(nLine)[pCol]

		but type(pCol) = "STRING"
			return line(nLine)[findCol(pCol)]
		ok
	
	  #------------------#
	 #  FINDING THINGS  #
	#------------------#

	def FindCol(pcColName)
		pcColName = Q(pcColName).Uppercased()
		n = find( This.Header(), pcColName)
		return n

		def FindColumn(pcColName)
			return This.FindCol(pcColName)

	def FindLine(paLine)
		n = Q(This.Lines()).FindAll(paLine)

		if len(n) = 0
			n = 0

		but len(n) = 1
			n = n[1]
		ok

		return n

	def FindInColCS(n, pValue, pCaseSensitive)
		if isString(n)
			n = This.FindCol(n)
		ok

		aResult = []

		i = 0
		for cell in This.Col(n)
			i++
			if isString(cell)
				if Q(cell).ContainsCS(pValue, pCaseSensitive)
					aResult + [n, i]
				ok
			else
				if Q(cell).Contains(pValue)
					aResult + [n, i]
				ok

			ok
		next

		return aResult

	def FindInCol(n, pValue)
		return This.FindInColCS(n, pValue, :CaseSensitive = TRUE)

	def FindInLine(n, pValue)

	def FindInCS(pValue, pCaseSensitive)
		aResult = []

		for i = 1 to This.NumberOfCol()
			aPairs = This.FindInColCS(i, pValue, pCaseSensitive)
			for pair in aPairs
				if len(pair) != 0
					aResult + pair
				ok
			next
		next

		return aResult

	def FindIn(pValue)
		return This.FindInCS(pValue, :CaseSensitive = TRUE)

	  #---------------------#
	 #  SHOWING THE TABLE  #
	#---------------------#

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
			cLine += aLine[x]
			if x < This.NumberOfCols()
				cLine += TAB
			ok
		next x
		return cLine

		def LineToStringQ(n)
			return new stzString( This.LineToString(n) )

