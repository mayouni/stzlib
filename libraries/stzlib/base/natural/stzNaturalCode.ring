
  //////////////////////////
 ///  GLOBAL VARIABLES  ///
//////////////////////////

_aFuture = [] # Stores future actions in natural-coding

_WhatEverCaseItHas_ = FALSE # Used in natural-coding

_oMainObject = ANullObject() # Used for chains of truth
_MainValue = NULL
_LastValue = NULL

# Glossary of Softanza actions

	_ActionsXT = [
	
		:Uppercase = [
			:Uppercase, :Uppercased, :IsUppercased, :InUppercase, :Uppercasing
		]
	]

	_cFutureOrder = :After

#--

func QM(p)
	_obj_ = Q(p)
	SetMainObject(_obj_)
	return _obj_

func QRT(p, pcType)
	if NOT isString(pcType)
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if Q(pcType).IsStzClassName()
		_cCode_ = "oResult = new " + pcType + '(' + @@(p) + ')'

		eval(_cCode_)

		return oResult
	else
		StzRaise("Unsupported Softanza type!")
	ok

  //////////////////////////
 ///  GLOBAL FUNCTIONS  ///
//////////////////////////

func FutureOrder()
	return _cFutureOrder

	func @FutureOrder()
		return FutureOrder()

func SetFutureOrder(pcBeforeOrAfter) # Before or after the action to be executed on an object
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
		_aTemp_ = []
		_aTemp_ + pAction
		_aTemp_ + []
		pAction = _aTemp_
	ok

	if NOT ( isList(pAction) and len(pAction) = 2 and
		 isString(pAction[1]) and isList(pAction[2]) )

		StzRaise("cAction must be a list of the form [ cAction, [] ].")
	ok

	if pcBeforeOrAfter = :After
		_aFuture + pAction

	else // Before

		_nLen_ = len(_aFuture)

		if _nLen_ = 0
			_aFuture + pAction
		else

			ring_insert( _aFuture, _nLen_, pAction)
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

		if isList(pStzObj) and len(pStzObj) = 2 and
		   isString(pStzObj[1]) and ( pStzObj[1] = "on" or pStzObj[1] = "of" )

			pStzObj = pStzObj[2]
		ok

		if NOT ( isObject(pStzObj) and @IsStzObject(pStzObj) )
			StzRaise("Incorrect param type! pActionsOnObj must be a list of the form [ aList, obj ].")
		ok			

	ok

	_nLen_ = len(pActions)

	for i = 1 to _nLen_

		_cCode_ = 'pStzObj.' + pActions[i][1]
		_aParams_ = pActions[i][2]
		_nLenParams_ = len(_aParams_)

		_cParams_ = '('
		for j = 1 to _nLenParams_
			_cParams_ += (""+ @@(_aParams_[j]))
			if j < _nLenParams_
				_cParams_ += ', '
			ok
		next

		_cParams_ += ')'

		_cCode_ += _cParams_

		eval(_cCode_)

	next

	func @ExecuteActions(pActions, pStzObj)
		 ExecuteActions(pActions, pStzObj)

	func RunActions(pActions, psTzObj)
		ExecuteActions(pActions, pStzObj)

	func @RunActions(pActions, psTzObj)
		ExecuteActions(pActions, pStzObj)

func ExecuteFuture(pStzObj)
	ExecuteFutureActions(Future(), pStzObj)

	func RunFuture(pStzObj)
		ExecuteFuture(pStzObj)

	func @ExecuteFuture(pStzObj)
		ExecuteFuture(pStzObj)

	func @RunFuture(pStzObj)
		ExecuteFuture(pStzObj)

func ExecuteFutureOn(pStzObj)
	ExecuteFutureActions(Future(), pStzObj)

	func RunFutureOn(pStzObj)
		ExecuteFutureOn(pStzObj)

	func @ExecuteFutureOn(pStzObj)
		ExecuteFutureOn(pStzObj)

	func @RunFutureOn(pStzObj)
		ExecuteFutureOn(pStzObj)

	#--

	func RunFutureOf(pStzObj)
		ExecuteFutureOn(pStzObj)

	func @ExecuteFutureOf(pStzObj)
		ExecuteFutureOn(pStzObj)

	func @RunFutureOf(pStzObj)
		ExecuteFutureOn(pStzObj)


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

func SetMainObject(_obj_)
	_oMainObject = _obj_

func MainValue()
	return _MainValue

	def @MainValue()
		return _MainValue

func LastValue()
	return _LastValue

func SetLastValue(value)
	_LastValue = value


