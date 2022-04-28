
Class stzTable from stzList
	aTable = []

	def init(paTable)
		if len(paTable)=2 and
		isInteger(paTable[1]) and
		isInteger(paTable[2])
			// TODO: Creating an empty table()

		but isString(paTable)
			// TODO: Extracting a table from the string

		else
			// The table is provided as a parameter
			// --> Verfy it is well formatted
			aTable = paTable
		ok

	def IsWellFormatted()

		if ( NOT isList(aTable) ) or
		   ( NOT EachItemIsList(aTable) ) or	# --> Should go to stzList
		   ( NumberOfLevels() > 2 )	# --> Depth() : Should go to stzList

			return FALSE
		else
			return TRUE
		ok

	def Line(n)
		if n=0
			return Header()
		else
			return aTable[n+1]
		ok
	
	def Header()
		return aTable[1]
	
	def NumberOfCol()
		return len(Header())
	
	def NumberOfLines()
		return len(aTable)-1
	
	def HeaderToString()
		return LineToString(0)
	
	def Cell(pCol,nLine)
		if type(pCol) = "NUMBER"
			return line(nLine)[pCol]
		but type(pCol) = "STRING"
			return line(nLine)[findCol(pCol)]
		ok
	
	def FindCol(pColName)
		n = find(Header(),pColName)
		return n
	
	def ToString()
		cTable = HeaderToString() + NL + LinesToString()
		return cTable
		
	def LinesToString()
		cLines = ""

		for y = 1 to NumberOfLines()
			cLines += LineToString(y) + NL
		next

		return cLines
	
	def LineToString(n)
		cLine = ""
		aLine = line(n)
	
		for x=1 to len(aLine)
			cLine += aLine[x]
			if x < NumberOfCol()
				cLine += TAB
			ok
		next x
		return cLine

