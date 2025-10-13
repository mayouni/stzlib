# A small CSV class ~Softanza library

$cCSVSep = ";"

# Functions for setting and reading the default separator

func CSVSeparator()
	return $cCSVSep

	func CSVSep()
		return $cCSVSep

	func DefaultCSVSeparator()
		return $cCSVSep

	func DefaultCSVSep()

		return $cCSVSep

	#-- @FunctionMisspelledForm

	func CSVSeperator()
		return $cCSVSep

	func DefaultCSVSeperator()
		return $cCSVSep

func SetCSVSeparator(cSep)

	if CheckParams()
		if NOT isString(cSep)
			StzRaise("Incorrect param type! cSep must be a string.")
		ok
	ok

	$cCSVSep = cSep

	func SetCSVSep(cSep)
		This.SetCSVSeparator(cSep)

	#-- @Misspelled

	func SetCSVSeperator(cSep)
		return func SetCSVSeparator(cSep)

# Functions for transformin a list to cCSV

func ListToCSV(aList)
	return ListToCSVXT(aList, CSVSeparator())

func ListToCSVXT(aList, cSep)

	if CheckParams()
		if NOT ( isList(aList) and IsList2D(aList))
			StzRaise("Incorrect param type! aList must be a 2D list.")
		ok
	ok

    cResult = ""
    nCols = len(aList)
    if nCols = 0 return cResult ok
    
    # Get number of rows from the first sublist
    nRows = len(aList[1][2])
    
    # Add headers
    for i = 1 to nCols
        cResult += aList[i][1]
        if i < nCols cResult += cSep ok
    next

    cResult += nl
    
    # Add data rows
    for j = 1 to nRows
        for i = 1 to nCols
            cResult += aList[i][2][j]
            if i < nCols cResult += cSep ok
        next
        if j < nRows cResult += nl ok
    next
    
    return cResult

	func List2DToCSVXT(aList, cSep)
		return ListToCSV(aList, cSep)

# Function to transform a CSV string to a list

func StringToCSVList(cStr)
	return StringToCSVListXT(cStr, CSVSeparator())

	func CSVToList(cStr)
		return StringToCSVListXT(cStr, CSVSeparator())

func StringToCSVListXT(cStr, cSep)

	if CheckParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok

		if NOT IsCSV(cStr)
			StzRaise("Can't proceed! The string must be in CSV format.")
		ok
	ok

		cStr = @trim(cStr)

		if cStr = ""
			return FALSE
		ok

		cSep = CSVSep()
		acLines = @split(cStr, NL)
		nLen = len(acLines)

		# First line

		acItemsInFirstLine = @split(acLines[1], cSep)
		nCols = len(acItemsInFirstLine)
		bColNamesProvided = TRUE

		for i = 1 to nCols

			if @IsNumberInString(acItemsInFirstLine[i]) or
			   @IsListInString(acItemsInFirstLine[i]) #TODO // Check for perfmance
				bColNamesProvided = FALSE
				exit
			ok

		next

		aResult = []

		if NOT bColNamesProvided
			for i = 1 to nCols
				aResult + [ ("COL"+i), acItemsInFirstLine[i] ]
			next

		else
			for i = 1 to nCols
				aResult + [ acItemsInFirstLine[i], []]
			next

		ok
	
		# Other lines

		for i = 2 to nLen

			acItems = @Split(acLines[i], cSep)

			for j = 1 to nCols

				item = acItems[j]

				if @IsNumberInString(item)
					item = 0+ acItems[j]

				but @IsListInString(item)
					cCode = 'item = ' + acItems[j]
					eval(cCode)
				ok

				aResult[j][2] + item
			next

		next

		return aResult

	func CSVToListXT(cStr, cSep)
		return StringToCSvlistXT(cStr, cSep)

func IsCSV(cStr)
	return IsCSVXT(cStr, CSVSeparator())

func IsCSVXT(cStr, cSep)
    # Check if string is empty
	cStr = @trim(cStr)
    if len(cStr) = 0 return false ok
    
    # Split into lines
    aLines = @split(cStr, nl)
	nLenL = len(aLines)
    if nLenL < 2 return false ok
    
    # Get number of columns from header
    aHeader = @split(aLines[1], cSep)
    nCols = len(aHeader)
    if nCols = 0 return false ok
    
    # Check if all rows have same number of columns
    for i = 2 to nLenL
        if len(@trim(aLines[i])) = 0 loop ok
        aRow = @split(aLines[i], cSep)
        if len(aRow) != nCols return false ok
    next
    
    return true
