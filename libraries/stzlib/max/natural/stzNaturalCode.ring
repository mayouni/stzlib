
  ///////////////////////////
 ///  GLOBALS VARIABLES  ///
///////////////////////////

_aFuture = [] # Stores future actions in natural-coding

WhatEverCaseItHas = _FALSE_ # Used in natural-coding

_oMainObject = ANullObject() # Used for chains of truth
_MainValue = _NULL_
_LastValue = _NULL_

# Glossary of Softanza actions

	_ActionsXT = [
	
		:Uppercase = [
			:Uppercase, :Uppercased, :IsUppercased, :InUppercase, :Uppercasing
		]
	]

	_cFutureOrder = :After

  //////////////////////////
 ///  GLOBAL FUNCTIONS  ///
//////////////////////////

func FutureOrder()
	return _cFutureOrder

	func @FutureOrder()
		return FutureOrder()

func SetFutureOrder(pcBeforeOrAfter) # Before or afer the action to be executed on an object
	if NOT isString(pcBeforeOrAfter)
		StzRaise("Incorrect param type! pcBeforeOrAfter must be a string.")
	ok

	if NOT ( _cFutureOrder = :Before or _cFutureOrder = :After )
		StzRaise("Incorrect value! pcBeforeOrAfter must be equal to :Before or :After.")
	ok

	if pcBeforeOrAfter = :Before
		_cFutureOrder = :Before

	else
		_cFutureOrder = :After
	ok

	#< @FunctionAlternativeForms

	def SetFutureExecutionOrder()
		SetFutureOrder(pcBeforeOrAfter)

	def @SetFutureOrder(pcBeforeOrAfter)
		SetFutureOrder(pcBeforeOrAfter)

 	def @SetFutureExecutionOrder()
		SetFutureOrder(pcBeforeOrAfter)

	#>

func Future()
	return _aFuture
	# Takes the form [
	# 	:Action1 = [param1, param2, ... ],
	# 	:Action2 = [param2, param2, ... ],
	# 	...
	# ]

	func FutureActions()
		return Future()

	func @FutureActions()
		return Future()

	func @Future()
		return Future()

func AddFuture(pAction)
	AddFutureXT(pAction, :After)

	func @AddFuture(pAction)
		AddFuture(pAction)

	func AddfutureAction(pAction)
		AddFuture(pAction)

	func @AddfutureAction(pAction)
		AddFuture(pAction)
	
func AddFutureXT(pAction, pcBeforeOrAfter)

	if NOT ( isString(pcBeforeOrAfter) and
		 ( pcBeforeOrAfter = :Before or pcBeforeOrAfter = :After) )

		StzRaise("Incorrect param type! pcBeforeOrAfter must be a string equal to :Before or :After.")
	ok

	if isString(pAction)
		aTemp = []
		aTemp + pAction
		aTemp + []
		pAction = aTemp
	ok

	if NOT ( isList(pAction) and len(pAction) = 2 and
		 isString(pAction[1]) and isList(pAction[2]) )

		StzRaise("cAction must be a list of the form [ cAction, [] ].")
	ok

	if pcBeforeOrAfter = :After
		_aFuture + pAction

	else // Before

		nLen = len(_aFuture)

		if nLen = 0
			_aFuture + pAction
		else

			ring_insert( _aFuture, nLen, pAction)
		ok
	ok

	#< @FunctionAlternativeForms

	func AddFutureActionXT(pAction, pcBeforeOrAfter)
		AddFutureXT(pAction, pcBeforeOrAfter)

	func @AddFutureXT(pAction, pcBeforeOrAfter)
		AddFutureXT(pAction, pcBeforeOrAfter)

	func @AddFutureActionXT(pAction, pcBeforeOrAfter)
		AddFutureXT(pAction, pcBeforeOrAfter)

	#>

func ExecuteActions(pActions, pStzObj)
	if CheckingParams()
		if NOT ( isList(pActions) and @IsHashList(pActions) )
			StzRaise("Incorrect param type! pActions must be a hashlist.")
		ok

		if isList(pStzObj) and Q(pStzObj).IsOnNamedParam()
			pStzObj = pStzObj[2]
		ok

		if NOT ( isObject(pStzObj) and @IsStzObject(pStzObj) )
			StzRaise("Incorrect param type! pActionsOnObj must be a list of the form [ aList, obj ].")
		ok			

	ok

	nLen = len(pActions)

	for i = 1 to nLen

		cCode = 'pStzObj.' + pActions[i][1]
		aParams = pActions[i][2]
		nLenParams = len(aParams)

		cParams = '('
		for j = 1 to nLenParams
			cParams += (""+ @@(aParams[j]))
			if j < nLenParams
				cParams += ', '
			ok
		next

		cParams += ')'

		cCode += cParams

		eval(cCode)

	next

	func @ExecuteActions(pActions, pStzObj)
		 ExecuteActions(pActions, pStzObj)

func CleanFuture()
	_aFuture = []

	#< @FunctionAlternativeForms

	func RemoveFuture()
		CleanFuture()

	func RemoveFutureActions()
		CleanFuture()

	func RemoveAllFutureActions()
		CleanFuture()

	#--

	func @CleanFuture()
		CleanFuture()

	func @RemoveFuture()
		CleanFuture()

	func @RemoveFutureActions()
		CleanFuture()

	func @RemoveAllFutureActions()
		CleanFuture()
	
	#>

func BeforeQ(value)
	if isString(value) and value = ''
		return new stzString('')

	but isList(value) and len(value) = 0
		return new stzList([])
	ok

	SetFutureOrder(:Before)
	return Q(value)

	func @BeforeQ(value)
		return BeforeQ(value)

func AfterQ(value)
	SetFutureOrder(:After)
	return Q(value)

	func @After(value)
		return AfterQ(value)

func MainObject() # Used in Chains of truth
	return _oMainObject

	func @MainObject()
		return _oMainObject

func SetMainObject(obj)
	_oMainObject = obj

func MainValue()
	return _MainValue

	def @MainValue()
		return _MainValue

func LastValue()
	return _LastValue

func SetLastValue(value)
	_LastValue = value


