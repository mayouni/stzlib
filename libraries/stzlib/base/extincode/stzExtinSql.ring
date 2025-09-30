# Functions and classes for porting SQL code to Ring

SMALLINT = :SMALLINT
TABLE = :TABLE

_oInitialTable = new stzTable([])
_oIntermediateTable = new stzTable([])

_aINSERT_INTO_VALUES = []

_aSELECT_FROM_WHERE = []

func VARCHAR(n)
	# Does nothing now --> TODO (future)
	
	#< @FunctionAlternativeForms
	func _VARCHAR(n)
		return VARCHAR(n)
	func VARCHAR_(n)
		return VARCHAR(n)
	func _VARCHAR_(n)
		return VARCHAR(n)
	func @VARCHAR(n)
		return VARCHAR(n)
	func VARCHAR@(n)
		return VARCHAR(n)
	func @VARCHAR@(n)
		return VARCHAR(n)
	#>

func CREATE_TABLE(pcName)
	oTable = new stzTable([])
	oTable.SetName(pcName)
	oTable.@aContent = []
	Vr(pcName) '=' Vl(oTable)
	return v(pcName)
	
	#< @FunctionAlternativeForms
	func _CREATE_TABLE(pcName)
		return CREATE_TABLE(pcName)
	func CREATE_TABLE_(pcName)
		return CREATE_TABLE(pcName)
	func _CREATE_TABLE_(pcName)
		return CREATE_TABLE(pcName)
	func @CREATE_TABLE(pcName)
		return CREATE_TABLE(pcName)
	func CREATE_TABLE@(pcName)
		return INSERT_INTO(pcName)
	func @CREATE_TABLE@(pcName)
		return CREATE_TABLE(pcName)
	#>

func INSERT_INTO(pcTableName, pacColNames)
	if CheckingParams()
		if NOT isString(pcTableName)
			StzRaise("Incorrect param type! pcTableName must be a string.")
		ok
		if NOT ring_find(TempVars(), pcTableName) > 0
			StzRaise("Undefined named variable!")
		ok
		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok
	ok
	_aINSERT_INTO_VALUES = [ pcTableName, pacColNames ]
	
	#< @FunctionAlternativeForms
	func _INSERT_INTO(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	func INSERT_INTO_(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	func _INSERT_INTO_(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	func @INSERT_INTO(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	func INSERT_INTO@(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	func @INSERT_INTO@(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)
	#>

func VALUES(paValues)
	if CheckingParams()
		if NOT ( isList(paValues) and Q(paValues).IsListOfLists() )
			StzRaise("Incorrect param type! paValues must be a list of lists.")
		ok
	ok
	_aINSERT_INTO_VALUES + paValues
	cTableName = _aINSERT_INTO_VALUES[1]
	oStzTable  = v(_aINSERT_INTO_VALUES[1])
	nLen = len(paValues)
	if nLen > 0
		if oStzTable.NumberOfRows() = 1 AND oStzTable.IsEmpty()
			oStzTable.ReplaceRow(1, paValues[1])
			if nLen > 1
				ring_remove(paValues, 1)
				oStzTable.AddRows(paValues)
			ok
		else
			oStzTable.AddRows(paValues)
		ok
	ok
	_aVars[cTableName] = oStzTable
	
	#< @FunctionAlternativeForms
	func _VALUES(paValues)
		return VALUES(paValues)
	func VALUES_(paValues)
		return VALUES(paValues)
	func _VALUES_(paValues)
		return VALUES(paValues)
	func @VALUES(paValues)
		return VALUES(paValues)
	func VALUES@(paValues)
		return VALUES(paValues)
	func @VALUES@(paValues)
		return VALUES(paValues)
	#>

func SELECT(pacColNames)
	if CheckingParams()
		if NOT ( isString(pacColNames) or
			( isList(pacColNames) and Q(pacColNames).IsListOfStrings() ) )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok
	ok
	_aSELECT_FROM_WHERE + pacColNames
	
	#< @FunctionAlternativeForms
	func _SELECT(pacColNames)
		return SELECT(pacColNames)
	func SELECT_(pacColNames)
		return SELECT(pacColNames)
	func _SELECT_(pacColNames)
		return SELECT(pacColNames)
	func @SELECT(pacColNames)
		return SELECT(pacColNames)
	func SELECT@(pacColNames)
		return SELECT(pacColNames)
	func @SELECT@(pacColNames)
		return SELECT(pacColNames)
	#>

func FROM_(pcTableName)
	if CheckingParams()
		if NOT isString(pcTableName)
			StzRaise("Incorrect param type! pcTableName must be a string.")
		ok
		if isString(v(pcTableName)) and v(pcTableName) = ""
			StzRaise("Incorrect type! The stzTable object managed by the SQL statement is not defined as a global named variable.")
		ok
		if NOT @IsStzTable(v(pcTableName))
			StzRaise("Incorrect param type! The named variable managed by the SQL statement is not a stzTable object.")
		ok
	ok
	_aSELECT_FROM_WHERE + pcTableName
	_oInitialTable = v(pcTableName)
	_oIntermediateTable = _oInitialTable
	if isString(_aSELECT_FROM_WHERE[1]) and 
	   _aSELECT_FROM_WHERE[1] = "*"
		// do nothing
	else
		_oIntermediateTable.RemoveColsOtherThan(_aSELECT_FROM_WHERE[1])
		return _oIntermediateTable
	ok
	
	#< @FunctionAlternativeForms
	func _FROM(pcTableName)
		return FROM_(pcTableName)
	func _FROM_(pcTableName)
		return FROM_(pcTableName)
	func @FROM(pcTableName)
		return FROM_(pcTableName)
	func FROM@(pcTableName)
		return FROM_(pcTableName)
	func @FROM@(pcTableName)
		return FROM_(pcTableName)
	#>

func WHERE_(pcCondition)
	if CheckingParams()
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok
		if NOT Q(pcCondition).ContainsOneOfTheseCS(_oIntermediateTable.ColsNames(), 0)
			StzRaise("Incorrect param type! The pcCondition must contain columns names of the stzTable object managed by the SQL statement.")
		ok
	ok
	_aSELECT_FROM_WHERE + pcCondition
	acColNames  = _aSELECT_FROM_WHERE[1]
	cTableName = _aSELECT_FROM_WHERE[2]
	cCondition  = _aSELECT_FROM_WHERE[3]
	aRows = _oIntermediateTable.Rows()
	nLen = len(aRows)
	acColNames = _oIntermediateTable.ColNames()
	nLenCols = len(acColNames)
	for i = 1 to nLenCols
		cColName = acColNames[i]
		cCondition = Q(cCondition).ReplaceQ( cColName,  'v(cTableName).cell(:' + cColName + ', i)' ).Content()
		cCode = 'bOk = ' + cCondition
	next
	anPos = []
	for i = 1 to nLen
		eval(cCode)
		if NOT bOk
			anPos + i
		ok
	next
	_oIntermediateTable.RemoveRows(anPos)
	_aVars[cTableName] = _oInitialTable
	return _oIntermediateTable
	
	#< @FunctionAlternativeForms
	func _WHERE(pcCondition)
		return WHERE_(pcCondition)
	func _WHERE_(pcCondition)
		return WHERE_(pcCondition)
	func @WHERE(pcCondition)
		return WHERE_(pcCondition)
	func WHERE@(pcCondition)
		return WHERE_(pcCondition)
	func @WHERE@(pcCondition)
		return WHERE_(pcCondition)
	#>

func WITH_(pcSQL)
	return new WITH(pcSQL)
	
	#< @FunctionAlternativeForms
	func _WITH(pcSQL)
		return WITH_(pcSQL)
	func _WITH_(pcSQL)
		return WITH_(pcSQL)
	func @WITH(pcSQL)
		return WITH_(pcSQL)
	func @WITH@(pcSQL)
		return WITH_(pcSQL)
	#>

func ORDER_BY(pcColName, pcSortOrder)
	if CheckingParams()
		if NOT isString(pcColName)
			StzRaise("Incorrect param type! pcColName must be a string.")
		ok
		if NOT ( isString(pcSortOrder) and Q(pcSortOrder).IsEither(:ASC, :DESC))
			StzRaise("Incorrect param type! pcSortOrder must be a string equal to :ASC or :DESC.")
		ok
	ok
	if pcSortOrder = :ASC
		v(:sqlTable).SortOnInAscending(pcColName)
	else
		v(:sqlTable).SortOnInDescending(pcColName)
	ok
	
	#< @FunctionAlternativeForms
	func _ORDER_BY(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)
	func ORDER_BY_(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)
	func _ORDER_BY_(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)
	func @ORDER_BY(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)
	func @ORDER_BY@(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)
	#>

class WITH
	cSQL
	def init(pcSQL)
		if CheckingParams()
			if NOT isString(pcSQL)
				StzRaise("Incorrect param type! pcSQL must be a string.")
			ok
		ok
		cSQL = pcSQL
	def As(paParams)
		if CheckingParams()
			if NOT ( isList(paParams) and
				 len(paParams) > 0 and len(paParams) <= 3 )
				StzRaise("Incorrect param type! paParams must be a list of 1 to 3 items.")
			ok
		ok
		n = StzHashListQ(_aVars).FindKey(cSQL)
		if n = 0
			_aVars + [ cSQL, _oIntermediateTable.rows() ]
			_aVars + [ cSQL + 'Data', _oIntermediateTable.rows() ]
			_aVars + [ cSQL + 'Table', _oIntermediateTable ]
			_aVars + [ cSQL + 'Object', _oIntermediateTable ]
		else
			_aVars[n] = [ cSQL, _oIntermediateTable.rows() ]
			_aVars[n] = [ cSQL + 'Data', _oIntermediateTable.rows() ]
			_aVars[n] = [ cSQL + 'Table', _oIntermediateTable ]
			_aVars[n] = [ cSQL + 'Object', _oIntermediateTable ]
		ok
