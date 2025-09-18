# Named Variables Management System for Softanza
# Extracted from stzExtinCode.ring - handles dynamic variable creation and management

  ///////////////////
 ///  VARIABLES  ///
///////////////////

_aTempVars = []
_aVars = []	# the list of all temp vars and their values

_bVarReset = 0
_var = []	# Current temp var and its value
_oldVar = []	# A copy of the temp var before it is changed

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func TempVars()
	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][1]
	next

	return aResult

	func TempVarsNames()
		return TempVars()

	func TempVarNames()
		return TempVars()

	func @TempVars()
		return TempVars()

	func @TempVarsNames()
		return TempVars()

	func @TempVarNames()
		return TempVars()

func TempVals()
	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][2]
	next

	return aResult

	func @TempVals()
		return TempVals()

func TempVarsVals()
	return _aVars

	func TempVarsXT()
		return TempVarsVals()

	func @TempVarsVals()
		return TempVarsVals()

func TempVar()
	if len(_var) = 0
		return []
	else
		return _var[1]
	ok

	def TempVarName()
		return TempVar()

	func @TempVar()
		return TempVar()

	def @TempVarName()
		return TempVar()

func TempVal()
	if len(_var) = 0
		return ""
	else
		return _var[2]
	ok

	func @TempVal()
		return TempVal()

func TempVarVal()
	return _var

	func TempVarXT()
		return TempVarVal()

	func @TempVarVal()
		return TempVarVal()

	func @TempVarXT()
		return TempVarVal()

func V(p)
	if isList(p) and Q(p).IsPair()
		aTemp = []
		aTemp + p
		SetV(aTemp)

	but isList(p) and Q(p).IsHashList()
		SetV(p)

	but isList(p) and Q(p).IsListOfStrings()
		return ReadManyV(p)

	else
		return ReadV(p)
	ok

	func @V(p)
		return V(p)

func VrVl(p)
	val = v(p)
	if isNull(val)
		val = []
		nLen = len(p)
		for i = 1 to nLen
			val + ""
		next
	ok
		
	aResult = Association([ p, val ])
	return aResult

	func VarVal(p)
		return VrVl(p)

	func @VrVl(p)
		return VrVl(p)

	func @VarVal(p)
		return VrVl(p)

func vxt(cVarName)
	if NOT isString(cVarName)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	cVarName = ring_lower(cVarName)

	if NOT ring_find(TempVarNames(), cVarName)
		StzRaise("Variable name does not exist!")
	ok

	aResult = [ cVarName, v(cVarName) ]
	return aResult
	
	func @vxt(cVarName)
		return vxt(cVarName)

func SetV(paVarNamesAndTheirValues)
	if isList(paVarNamesAndTheirValues) and
	   len(paVarNamesAndTheirValues) = 2 and
	   isString(paVarNamesAndTheirValues[1])

		aTemp = []
		aTemp + paVarNamesAndTheirValues
		paVarNamesAndTheirValues = aTemp
	ok

	if NOT ( isList(paVarNamesAndTheirValues) and Q(paVarNamesAndTheirValues).IsHashList() )
		StzRaise("Incorrect param type! paVarNamesAndTheirValues must be a hashlist.")
	ok

	# Memorizing the current var

	if len(_aVars) = 0
		_oldVar = []
	else
		_oldVar = _aVars[ len(_aVars) ]
	ok

	# Setting the new var

	nLen = len(paVarNamesAndTheirValues)
	oHash = new stzHashList(_aVars)

	for i = 1 to nLen
		n = oHash.FindKey(paVarNamesAndTheirValues[i][1])
		if n = 0
			_aVars + paVarNamesAndTheirValues[i]
		else
			_aVars[n] = paVarNamesAndTheirValues[i]
		ok
	next

	# The new var is the temp var

	_var = _aVars[len(_aVars)]

	func @SetV(paVarNamesAndTheirValues)
		SetV(paVarNamesAndTheirValues)

func ReadV(p)
	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(p)
	if n = 0
		StzRaise("Undefined named variable!")
	else
		return _aVars[n][2]
	ok

	func @ReadV(p)
		return ReadV(p)

func ReadManyV(paVars)
	nLen = len(paVars)

	aResult = []
	for i = 1 to nLen
		aResult + ReadV(paVars[i])
	next

	return aResult

	func @ReadManyV(paVars)
		return ReadManyV(paVars)

func DataVars()
	nLen = len(_aVars)
	aResult = []
	for i = 1 to nLen
		aResult + _aVars[i]
	next
	return aResult

	func @DataVars()
		return DataVars()

func DataVarsXT()
	return _aVars

	func @DataVarsXT()
		return DataVarsXT()

func Vr(pacVars)

	if isString(pacVars)
		aTemp = []
		aTemp + pacVars
		pacVars = aTemp
	ok

	if NOT ( isList(pacVars) and IsListOfStrings(pacVars) )
		StzRaise("Incorrect param type! pcVars must be a list of strings.")
	ok

	_aTempVars = []
	nLen = len(pacVars)

	for i = 1 to nLen

		_aTempVars + [ pacVars[i], "" ]

		oHash = StzHashListQ(_aVars)
		n = oHash.FindKey(pacVars[i])
		if n = 0
			_aVars + [ pacVars[i], "" ]
		else
			_aVars[n][2] = []
		ok
	next

	# Set _var to the last one for consistency
	_var = [ pacVars[nLen], null ]

	func @Vr(pacVars)
		return Vr(pacVars)

func OldVar()
	return _oldVar

	func @OldVar()
		return OldVar()

func OldVarname()
	if len(oldVar()) = 0
		return []
	else
		return oldvar()[1]
	ok

	func @OldVarname()
		return OldVarname()

func OldVal()
	if len(oldvar()) = 0
		return ""
	else
		return oldvar()[2]
	ok

	func @OldVal()
		return OldVal()

func Vl(paVals)
	# Checking the paVals param
	if len(_aTempVars) = 0 or (isList(paVals) and len(paVals) = 0)
		return
	ok

	# In case one value is provided (not a list), make it a list
	if NOT isList(paVals)
		aTemp = []
		aTemp + paVals
		paVals = aTemp
	ok

	# Taking a copy of the current temp var
	_oldVar = _Var

	# Doing the job
	nLen = Min([ len(_aTempVars), len(paVals) ])
	oHash = new stzHashList(_aVars)

	for i = 1 to nLen
		_aTempVars[i][2] = paVals[i]
		n = oHash.FindKey(_aTempVars[i][1])
		if n > 0
			_aVars[n][2] = paVals[i]
			if ObjectIsStzObject(paVals[i])
				paVals[i].SetObjectVarNameTo(_aVars[n][1])
			ok
		else
			_aVars + [ _aTempVars[i][1], paVals[i] ]
			if ObjectIsStzObject(paVals[i])
				paVals[i].SetObjectVarNameTo(_aTempVars[i][1])
			ok
		ok
	next

	# Memorizing the last variable/value processed
	_var = [ _aTempVars[nLen][1], paVals[nLen] ]
	if oldval() = ""
		_oldVar = _var
	ok

	func @Vl(paVals)
		Vl(paVals)

# Clear all named variables
func ClearVars()
	_aTempVars = []
	_aVars = []
	_var = []
	_oldVar = []
	_bVarReset = 0

	func @ClearVars()
		ClearVars()

	func ResetVars()
		ClearVars()

	func @ResetVars()
		ClearVars()

# Check if a variable exists
func VarExists(cVarName)
	if NOT isString(cVarName)
		return FALSE
	ok
	
	oHash = new stzHashList(_aVars)
	return (oHash.FindKey(cVarName) > 0)

	func @VarExists(cVarName)
		return VarExists(cVarName)

	func HasVar(cVarName)
		return VarExists(cVarName)

	func @HasVar(cVarName)
		return VarExists(cVarName)

# Remove a variable
func RemoveVar(cVarName)
	if NOT isString(cVarName)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(cVarName)
	if n > 0
		del(_aVars, n)
	ok

	func @RemoveVar(cVarName)
		RemoveVar(cVarName)

	func DeleteVar(cVarName)
		RemoveVar(cVarName)

	func @DeleteVar(cVarName)
		RemoveVar(cVarName)

# Get number of variables
func NumberOfVars()
	return len(_aVars)

	func @NumberOfVars()
		return NumberOfVars()

	func VarsCount()
		return NumberOfVars()

	func @VarsCount()
		return NumberOfVars()
