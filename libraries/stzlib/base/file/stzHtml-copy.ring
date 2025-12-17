


func ListToHtml(paList)
	return @Simplify(ListToHtmlXT(paList))

	func ToHtmlTable()
		return This.ToHtml()

func ListToHtmlXT(paList)
	if CheckPrams()
		if NOt (isList(paList) and IsList2D(paList))
			StzRaise("Incorrect param type! paList must be a 2D list.")
		ok
	ok

    data = paList
	nLenData = len(data)

    if nLenData = 0
        return '<table class="data"><thead><tr></tr></thead><tbody></tbody></table>'
    ok
    
    # Ensure all columns have exactly the same number of values
    # This is critical for the buggy parser
    nRows = 0
	
    for i = 1 to nLenData
        if len(data[i][2]) > nRows
            nRows = len(data[i][2])
        ok
    next
    
    # Pad shorter columns with empty strings to match longest column
    for i = 1 to nLenData
        while len(data[i][2]) < nRows
            data[i][2] + ""
        end
    next
    
    cHtml = '<table class="data" id="products">' + nl
    cHtml += '<thead>' + nl
    cHtml += nl
    cHtml += '<tr>' + nl
    
    # Generate header row - ensure format matches parser expectations
    for i = 1 to nLenData
        cHtml += '            ' + '<th scope="col">' + data[i][1] + '</th>' + nl
    next
    
    cHtml += '</tr>' + nl
    cHtml += nl
    cHtml += '</thead>' + nl
    cHtml += nl
    cHtml += '<tbody>' + nl
    cHtml += nl
    
    # Generate body rows - use exact format the parser expects
    for nRowIndex = 1 to nRows
        cHtml += '<tr class="row">' + nl
        
        # For each column, get the value at this row index
        for nColIndex = 1 to nLenData
            cValue = data[nColIndex][2][nRowIndex]
            cHtml += '        ' + '<td>' + cValue + '</td>' + nl
        next
        
        cHtml += nl
        cHtml += '</tr>' + nl
        cHtml += nl
    next
    
    cHtml += '</tbody>' + nl
    cHtml += '</table>' + nl
	return cHtml

	func ToHtmlTableXT()
		return This.ToHtmlXT()


func IsHtmlTable(pcStr)
	return StzStringQ(pcStr).IsHtmltable()

		func @IsHtmlTable(pcStr)
			return IsHtmlTable(pcStr)

func HtmlToList(pcHtmlTable)
	return StzStringQ(pcHtmlTable).HtmlToDataTable()

	func StringToHtmlList(pcHtmlTable)
		return HtmlToList(pcHtmlTable)

	func @HtmlToList(pcHtmlTable)
		return HtmlToList(pcHtmlTable)

	func @StringToHtmlList(pcHtmlTable)
		return HtmlToList(pcHtmlTable)

def ContainsHtmlTable(pcStr)
	return StzStringQ(pcStr).ContainsHtmlTable()

	func @ContainsHtmlTable(pcStr)
		return ContainsHtmlTable(pcStr)
