
func IsSciForm(cNumber)
	if not isString(cNumber)
		return FALSE
	ok

	_nPos_ = ring_substr1(cNumber, "e")
	if _nPos_ = 0
		return FALSE
	ok

	_cBase_ = ""
	for i = 1 to _nPos_-1
		_cBase_ += cNumberInStr[i]
	next

	_cExp_ = ""
	_nLen_ = len(cNumberInStr)
	for i = _nPos_+1 to _nLen_
		_cExp_ += cNumberInStr[i]
	next

	_nBase_ = 0+ _cBase_
	if NOT isNumber(_nBase_)
		return FALSE
	ok

	_nExp_ = 0+ _cExp_
	if NOT isNumber(_nExp_)
		return FALSE
	ok

	return TRUE

func Number2Sci(n)
	return StzEngineNumberToScientific(0+ n)

func Sci2Number(cNumberInStr)
	_cClean_ = trim( ring_substr2(cNumberInStr, "_", "") )
	return StzEngineNumberFromScientific(_cClean_)
	
class stzCoreSciNumber from stkSciNumber
class stkSciNumber
	@nBase
	@nExp

	@cStrValue

	def init(cNumberInSciForm)
		if not isString(cNumberInSciForm)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		_nPos_ = ring_substr1(cNumberInSciForm, "e")
		if _nPos_ = 0
			return FALSE
		ok
	
		_cBase_ = ""
		for i = 1 to _nPos_-1
			_cBase_ += cNumberInStr[i]
		next
	
		_cExp_ = ""
		_nLen_ = len(cNumberInSciForm)
		for i = _nPos_+1 to _nLen_
			_cExp_ += cNumberInStr[i]
		next
	
		_nBase_ = 0+ _cBase_
		if NOT isNumber(_nBase_)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		_nExp_ = 0+ _cExp_
		if NOT isNumber(_nExp_)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		@nBase = _nBase_
		@nExp = _nExp_

		@cStrValue = cNumberInSciForm

	def Content()
		return @cStrValue

		def SciForm()
			return @cStrValue

	def Value()
		_nResult_ = @nBase * pow(10, @nExp)
		return _nResult_

		def NValue()

	def Base()
		return @nBase

	def Exp()
		return @nExp
