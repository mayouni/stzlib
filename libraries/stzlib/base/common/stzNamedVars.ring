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
	_aResult_ = []
	_nLen_ = len(_aVars)
	for i = 1 to _nLen_
		_aResult_ + _aVars[i][1]
	next

	return _aResult_

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
	_aResult_ = []
	_nLen_ = len(_aVars)
	for i = 1 to _nLen_
		_aResult_ + _aVars[i][2]
	next

	return _aResult_

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
		_aTemp_ = []
		_aTemp_ + p
		StzSetV(_aTemp_)

	but isList(p) and @IsHashList(p)
		StzSetV(p)

	but isList(p) and @IsListOfStrings(p)
		return StzReadManyV(p)

	else
		return StzReadV(p)
	ok

	func V(p)
		return StzV(p)

	func @V(p)
		return StzV(p)

func StzVrVl(p)
	_val_ = StzV(p)
	if isNull(_val_)
		_val_ = []
		_nLen_ = len(p)
		for i = 1 to _nLen_
			_val_ + ""
		next
	ok

	_aResult_ = Association([ p, _val_ ])
	return _aResult_

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

func StzVxt(_cVarName_)
	if NOT isString(_cVarName_)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	_cVarName_ = StzLower(_cVarName_)

	if NOT StzFindFirst(_cVarName_, TempVarNames())
		StzRaise("Variable name does not exist!")
	ok

	_aResult_ = [ _cVarName_, StzV(_cVarName_) ]
	return _aResult_

	func vxt(_cVarName_)
		return StzVxt(_cVarName_)

	func @vxt(_cVarName_)
		return StzVxt(_cVarName_)

func StzSetV(paVarNamesAndTheirValues)
	if isList(paVarNamesAndTheirValues) and
	   len(paVarNamesAndTheirValues) = 2 and
	   isString(paVarNamesAndTheirValues[1])

		_aTemp_ = []
		_aTemp_ + paVarNamesAndTheirValues
		paVarNamesAndTheirValues = _aTemp_
	ok

	if NOT ( isList(paVarNamesAndTheirValues) and @IsHashList(paVarNamesAndTheirValues) )
		StzRaise("Incorrect param type! paVarNamesAndTheirValues must be a hashlist.")
	ok

	# Memorizing the current var

	if len(_aVars) = 0
		_oldVar = []
	else
		_oldVar = _aVars[ len(_aVars) ]
	ok

	# Setting the new var

	_nLen_ = len(paVarNamesAndTheirValues)
	_oHash_ = new stzHashList(_aVars)

	for i = 1 to _nLen_
		_n_ = _oHash_.FindKey(paVarNamesAndTheirValues[i][1])
		if _n_ = 0
			_aVars + paVarNamesAndTheirValues[i]
		else
			_aVars[_n_] = paVarNamesAndTheirValues[i]
		ok
	next

	# The new var is the temp var

	_var = _aVars[len(_aVars)]

	func SetV(paVarNamesAndTheirValues)
		StzSetV(paVarNamesAndTheirValues)

	func @SetV(paVarNamesAndTheirValues)
		StzSetV(paVarNamesAndTheirValues)

func StzReadV(p)
	_oHash_ = new stzHashList(_aVars)
	_n_ = _oHash_.FindKey(p)
	if _n_ = 0
		StzRaise("Undefined named variable!")
	else
		return _aVars[_n_][2]
	ok

	func ReadV(p)
		return StzReadV(p)

	func @ReadV(p)
		return StzReadV(p)

func StzReadManyV(paVars)
	_nLen_ = len(paVars)

	_aResult_ = []
	for i = 1 to _nLen_
		_aResult_ + StzReadV(paVars[i])
	next

	return _aResult_

	func ReadManyV(paVars)
		return StzReadManyV(paVars)

	func @ReadManyV(paVars)
		return StzReadManyV(paVars)

func StzDataVars()
	_nLen_ = len(_aVars)
	_aResult_ = []
	for i = 1 to _nLen_
		_aResult_ + _aVars[i]
	next
	return _aResult_

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
		_aTemp_ = []
		_aTemp_ + pacVars
		pacVars = _aTemp_
	ok

	if NOT ( isList(pacVars) and IsListOfStrings(pacVars) )
		StzRaise("Incorrect param type! pcVars must be a list of strings.")
	ok

	_aTempVars = []
	_nLen_ = len(pacVars)

	for i = 1 to _nLen_

		_aTempVars + [ pacVars[i], "" ]

		_oHash_ = StzHashListQ(_aVars)
		_n_ = _oHash_.FindKey(pacVars[i])
		if _n_ = 0
			_aVars + [ pacVars[i], "" ]
		else
			_aVars[_n_][2] = []
		ok
	next

	# Set _var to the last one for consistency
	_var = [ pacVars[_nLen_], null ]

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
		_aTemp_ = []
		_aTemp_ + paVals
		paVals = _aTemp_
	ok

	# Taking a copy of the current temp var
	_oldVar = _Var

	# Doing the job
	_nLen_ = @Min([ len(_aTempVars), len(paVals) ])
	_oHash_ = new stzHashList(_aVars)

	for i = 1 to _nLen_
		_aTempVars[i][2] = paVals[i]
		_n_ = _oHash_.FindKey(_aTempVars[i][1])
		if _n_ > 0
			_aVars[_n_][2] = paVals[i]
			if ObjectIsStzObject(paVals[i])
				paVals[i].SetObjectVarNameTo(_aVars[_n_][1])
			ok
		else
			_aVars + [ _aTempVars[i][1], paVals[i] ]
			if ObjectIsStzObject(paVals[i])
				paVals[i].SetObjectVarNameTo(_aTempVars[i][1])
			ok
		ok
	next

	# Memorizing the last variable/value processed
	_var = [ _aTempVars[_nLen_][1], paVals[_nLen_] ]
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
func StzVarExists(_cVarName_)
	if NOT isString(_cVarName_)
		return FALSE
	ok

	_oHash_ = new stzHashList(_aVars)
	return (_oHash_.FindKey(_cVarName_) > 0)

	func VarExists(_cVarName_)
		return StzVarExists(_cVarName_)

	func @VarExists(_cVarName_)
		return StzVarExists(_cVarName_)

	func StzHasVar(_cVarName_)
		return StzVarExists(_cVarName_)

	func HasVar(_cVarName_)
		return StzVarExists(_cVarName_)

	func @HasVar(_cVarName_)
		return StzVarExists(_cVarName_)

# Remove a variable
func StzRemoveVar(_cVarName_)
	if NOT isString(_cVarName_)
		StzRaise("Incorrect param type! cVarName must be a string.")
	ok

	_oHash_ = new stzHashList(_aVars)
	_n_ = _oHash_.FindKey(_cVarName_)
	if _n_ > 0
		del(_aVars, _n_)
	ok

	func RemoveVar(_cVarName_)
		StzRemoveVar(_cVarName_)

	func @RemoveVar(_cVarName_)
		StzRemoveVar(_cVarName_)

	func StzDeleteVar(_cVarName_)
		StzRemoveVar(_cVarName_)

	func DeleteVar(_cVarName_)
		StzRemoveVar(_cVarName_)

	func @DeleteVar(_cVarName_)
		StzRemoveVar(_cVarName_)

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
