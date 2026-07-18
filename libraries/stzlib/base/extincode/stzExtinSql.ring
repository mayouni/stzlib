# Functions and classes for porting SQL code to Ring

SMALLINT = :SMALLINT
TABLE = :TABLE

_oInitialTable = new stzTable([])
_oIntermediateTable = new stzTable([])

_aINSERT_INTO_VALUES = []

_aSELECT_FROM_WHERE = []

func VARCHAR(_n_)
	# Does nothing now --> TODO (future)
	
	#< @FunctionAlternativeForms
	func _VARCHAR(_n_)
		return VARCHAR(_n_)
	func VARCHAR_(_n_)
		return VARCHAR(_n_)
	func _VARCHAR_(_n_)
		return VARCHAR(_n_)
	func @VARCHAR(_n_)
		return VARCHAR(_n_)
	func VARCHAR@(_n_)
		return VARCHAR(_n_)
	func @VARCHAR@(_n_)
		return VARCHAR(_n_)
	#>

func CREATE_TABLE(pcName)
	_oTable_ = new stzTable([])
	_oTable_.SetName(pcName)
	_oTable_.@aContent = []
	Vr(pcName) '=' Vl(_oTable_)
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
		if NOT StzFindFirst(pcTableName, TempVars()) > 0
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
	_cTableName_ = _aINSERT_INTO_VALUES[1]
	_oStzTable_  = v(_aINSERT_INTO_VALUES[1])
	_nLen_ = len(paValues)
	if _nLen_ > 0
		if _oStzTable_.NumberOfRows() = 1 AND _oStzTable_.IsEmpty()
			_oStzTable_.ReplaceRow(1, paValues[1])
			if _nLen_ > 1
				ring_remove(paValues, 1)
				_oStzTable_.AddRows(paValues)
			ok
		else
			_oStzTable_.AddRows(paValues)
		ok
	ok
	_aVars[_cTableName_] = _oStzTable_
	
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
	_acColNames_  = _aSELECT_FROM_WHERE[1]
	_cTableName_ = _aSELECT_FROM_WHERE[2]
	_cCondition_  = _aSELECT_FROM_WHERE[3]
	_aRows_ = _oIntermediateTable.Rows()
	_nLen_ = len(_aRows_)
	_acColNames_ = _oIntermediateTable.ColNames()
	_nLenCols_ = len(_acColNames_)
	for i = 1 to _nLenCols_
		_cColName_ = _acColNames_[i]
		_cCondition_ = Q(_cCondition_).ReplaceQ( _cColName_,  'v(cTableName).cell(:' + _cColName_ + ', i)' ).Content()
		_cCode_ = '_bOk_ = ' + _cCondition_
	next
	_anPos_ = []
	for i = 1 to _nLen_
		eval(_cCode_)
		if NOT _bOk_
			_anPos_ + i
		ok
	next
	_oIntermediateTable.RemoveRows(_anPos_)
	_aVars[_cTableName_] = _oInitialTable
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
	_cSQL_
	def init(pcSQL)
		if CheckingParams()
			if NOT isString(pcSQL)
				StzRaise("Incorrect param type! pcSQL must be a string.")
			ok
		ok
		_cSQL_ = pcSQL
	def As(paParams)
		if CheckingParams()
			if NOT ( isList(paParams) and
				 len(paParams) > 0 and len(paParams) <= 3 )
				StzRaise("Incorrect param type! paParams must be a list of 1 to 3 items.")
			ok
		ok
		_n_ = StzHashListQ(_aVars).FindKey(_cSQL_)
		if _n_ = 0
			_aVars + [ _cSQL_, _oIntermediateTable.rows() ]
			_aVars + [ _cSQL_ + 'Data', _oIntermediateTable.rows() ]
			_aVars + [ _cSQL_ + 'Table', _oIntermediateTable ]
			_aVars + [ _cSQL_ + 'Object', _oIntermediateTable ]
		else
			_aVars[_n_] = [ _cSQL_, _oIntermediateTable.rows() ]
			_aVars[_n_] = [ _cSQL_ + 'Data', _oIntermediateTable.rows() ]
			_aVars[_n_] = [ _cSQL_ + 'Table', _oIntermediateTable ]
			_aVars[_n_] = [ _cSQL_ + 'Object', _oIntermediateTable ]
		ok
