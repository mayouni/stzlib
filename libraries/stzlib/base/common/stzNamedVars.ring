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

func StzTempVars()
	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][1]
	next

	return aResult

	func TempVars()
		return StzTempVars()

	func StzTempVarsNames()
		return StzTempVars()

	func TempVarsNames()
		return StzTempVars()

	func StzTempVarNames()
		return StzTempVars()

	func TempVarNames()
		return StzTempVars()

	func @TempVars()
		return StzTempVars()

	func @TempVarsNames()
		return StzTempVars()

	func @TempVarNames()
		return StzTempVars()

func StzTempVals()
	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][2]
	next

	return aResult

	func TempVals()
		return StzTempVals()

	func @TempVals()
		return StzTempVals()

func StzTempVarsVals()
	return _aVars

	func TempVarsVals()
		return StzTempVarsVals()

	func StzTempVarsXT()
		return StzTempVarsVals()

	func TempVarsXT()
		return StzTempVarsVals()

	func @TempVarsVals()
		return StzTempVarsVals()

func StzTempVar()
	if len(_var) = 0
		return []
	else
		return _var[1]
	ok

	func TempVar()
		return StzTempVar()

	def StzTempVarName()
		return StzTempVar()

	def TempVarName()
		return StzTempVar()

	func @TempVar()
		return StzTempVar()

	def @TempVarName()
		return StzTempVar()

func StzTempVal()
	if len(_var) = 0
		return ""
	else
		return _var[2]
	ok

	func TempVal()
		return StzTempVal()

	func @TempVal()
		return StzTempVal()

func StzTempVarVal()
	return _var

	func TempVarVal()
		return StzTempVarVal()

	func StzTempVarXT()
		return StzTempVarVal()

	func TempVarXT()
		return StzTempVarVal()

	func @TempVarVal()
		return StzTempVarVal()

	func @TempVarXT()
		return StzTempVarVal()

func StzV(p)
	if isList(p) and Q(p).IsPair()
		aTemp = []
		aTemp + p
		StzSetV(aTemp)

	but isList(p) and Q(p).IsHashList()
		StzSetV(p)

	but isList(p) and Q(p).IsListOfStrings()
		return StzReadManyV(p)

	else
		return StzReadV(p)
	ok

	func V(p)
		return StzV(p)

	func @V(p)
		return StzV(p)

func StzVrVl(p)
	val = StzV(p)
	if isNull(val)
		val = []
		nLen = len(p)
		for i = 1 to nLen
			val + ""
		next
	ok

	aResult = Association([ p, val ])
	return aResult

	func VrVl(p)
		return StzVrVl(p)

	func StzVarVal(p)
		return StzVrVl(p)

	func VarVal(p)
		return StzVrVl(p)

	func @VrVl(p)
		return StzVrVl(p)

	func @VarVal(p)
		return StzVrVl(p)

func StzVxt(cVarName)
	if NOT isString(cVarName)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	cVarName = StzLower(cVarName)

	if NOT StzFind(TempVarNames(), cVarName)
		StzRaise("Variable name does not exist!")
	ok

	aResult = [ cVarName, StzV(cVarName) ]
	return aResult

	func vxt(cVarName)
		return StzVxt(cVarName)

	func @vxt(cVarName)
		return StzVxt(cVarName)

func StzSetV(paVarNamesAndTheirValues)
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

	func SetV(paVarNamesAndTheirValues)
		StzSetV(paVarNamesAndTheirValues)

	func @SetV(paVarNamesAndTheirValues)
		StzSetV(paVarNamesAndTheirValues)

func StzReadV(p)
	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(p)
	if n = 0
		StzRaise("Undefined named variable!")
	else
		return _aVars[n][2]
	ok

	func ReadV(p)
		return StzReadV(p)

	func @ReadV(p)
		return StzReadV(p)

func StzReadManyV(paVars)
	nLen = len(paVars)

	aResult = []
	for i = 1 to nLen
		aResult + StzReadV(paVars[i])
	next

	return aResult

	func ReadManyV(paVars)
		return StzReadManyV(paVars)

	func @ReadManyV(paVars)
		return StzReadManyV(paVars)

func StzDataVars()
	nLen = len(_aVars)
	aResult = []
	for i = 1 to nLen
		aResult + _aVars[i]
	next
	return aResult

	func DataVars()
		return StzDataVars()

	func @DataVars()
		return StzDataVars()

func StzDataVarsXT()
	return _aVars

	func DataVarsXT()
		return StzDataVarsXT()

	func @DataVarsXT()
		return StzDataVarsXT()

func StzVr(pacVars)

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

	func Vr(pacVars)
		return StzVr(pacVars)

	func @Vr(pacVars)
		return StzVr(pacVars)

func StzOldVar()
	return _oldVar

	func OldVar()
		return StzOldVar()

	func @OldVar()
		return StzOldVar()

func StzOldVarname()
	if len(StzOldVar()) = 0
		return []
	else
		return StzOldVar()[1]
	ok

	func OldVarname()
		return StzOldVarname()

	func @OldVarname()
		return StzOldVarname()

func StzOldVal()
	if len(StzOldVar()) = 0
		return ""
	else
		return StzOldVar()[2]
	ok

	func OldVal()
		return StzOldVal()

	func @OldVal()
		return StzOldVal()

func StzVl(paVals)
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
	nLen = @Min([ len(_aTempVars), len(paVals) ])
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
	if StzOldVal() = ""
		_oldVar = _var
	ok

	func Vl(paVals)
		StzVl(paVals)

	func @Vl(paVals)
		StzVl(paVals)

# Clear all named variables
func StzClearVars()
	_aTempVars = []
	_aVars = []
	_var = []
	_oldVar = []
	_bVarReset = 0

	func ClearVars()
		StzClearVars()

	func @ClearVars()
		StzClearVars()

	func StzResetVars()
		StzClearVars()

	func ResetVars()
		StzClearVars()

	func @ResetVars()
		StzClearVars()

# Check if a variable exists
func StzVarExists(cVarName)
	if NOT isString(cVarName)
		return FALSE
	ok

	oHash = new stzHashList(_aVars)
	return (oHash.FindKey(cVarName) > 0)

	func VarExists(cVarName)
		return StzVarExists(cVarName)

	func @VarExists(cVarName)
		return StzVarExists(cVarName)

	func StzHasVar(cVarName)
		return StzVarExists(cVarName)

	func HasVar(cVarName)
		return StzVarExists(cVarName)

	func @HasVar(cVarName)
		return StzVarExists(cVarName)

# Remove a variable
func StzRemoveVar(cVarName)
	if NOT isString(cVarName)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(cVarName)
	if n > 0
		del(_aVars, n)
	ok

	func RemoveVar(cVarName)
		StzRemoveVar(cVarName)

	func @RemoveVar(cVarName)
		StzRemoveVar(cVarName)

	func StzDeleteVar(cVarName)
		StzRemoveVar(cVarName)

	func DeleteVar(cVarName)
		StzRemoveVar(cVarName)

	func @DeleteVar(cVarName)
		StzRemoveVar(cVarName)

# Get number of variables
func StzNumberOfVars()
	return len(_aVars)

	func NumberOfVars()
		return StzNumberOfVars()

	func @NumberOfVars()
		return StzNumberOfVars()

	func StzVarsCount()
		return StzNumberOfVars()

	func VarsCount()
		return StzNumberOfVars()

	func @VarsCount()
		return StzNumberOfVars()
