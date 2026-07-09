


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

    _data_ = paList
	_nLenData_ = len(_data_)

    if _nLenData_ = 0
        return '<table class="data"><thead><tr></tr></thead><tbody></tbody></table>'
    ok
    
    # Ensure all columns have exactly the same number of values
    # This is critical for the buggy parser
    _nRows_ = 0
	
    for i = 1 to _nLenData_
        if len(_data_[i][2]) > _nRows_
            _nRows_ = len(_data_[i][2])
        ok
    next
    
    # Pad shorter columns with empty strings to match longest column
    for i = 1 to _nLenData_
        while len(_data_[i][2]) < _nRows_
            _data_[i][2] + ""
        end
    next
    
    _cHtml_ = '<table class="data" id="products">' + nl
    _cHtml_ += '<thead>' + nl
    _cHtml_ += nl
    _cHtml_ += '<tr>' + nl
    
    # Generate header row - ensure format matches parser expectations
    for i = 1 to _nLenData_
        _cHtml_ += '            ' + '<th scope="col">' + _data_[i][1] + '</th>' + nl
    next
    
    _cHtml_ += '</tr>' + nl
    _cHtml_ += nl
    _cHtml_ += '</thead>' + nl
    _cHtml_ += nl
    _cHtml_ += '<tbody>' + nl
    _cHtml_ += nl
    
    # Generate body rows - use exact format the parser expects
    for nRowIndex = 1 to _nRows_
        _cHtml_ += '<tr class="row">' + nl
        
        # For each column, get the value at this row index
        for nColIndex = 1 to _nLenData_
            _cValue_ = _data_[nColIndex][2][nRowIndex]
            _cHtml_ += '        ' + '<td>' + _cValue_ + '</td>' + nl
        next
        
        _cHtml_ += nl
        _cHtml_ += '</tr>' + nl
        _cHtml_ += nl
    next
    
    _cHtml_ += '</tbody>' + nl
    _cHtml_ += '</table>' + nl
	return _cHtml_

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
