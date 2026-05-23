
func IsSciForm(cNumber)
	if not isString(cNumber)
		return FALSE
	ok

	nPos = ring_substr1(cNumber, "e")
	if nPos = 0
		return FALSE
	ok

	cBase = ""
	for i = 1 to nPos-1
		cBase += cNumberInStr[i]
	next

	cExp = ""
	nLen = len(cNumberInStr)
	for i = nPos+1 to nLen
		cExp += cNumberInStr[i]
	next

	nBase = 0+ cBase
	if NOT isNumber(nBase)
		return FALSE
	ok

	nExp = 0+ cExp
	if NOT isNumber(nExp)
		return FALSE
	ok

	return TRUE

func Number2Sci(n)
	return StzEngineNumberToScientific(0+ n)

func Sci2Number(cNumberInStr)
	cClean = trim( ring_substr2(cNumberInStr, "_", "") )
	return StzEngineNumberFromScientific(cClean)
	
class stzCoreSciNumber from stkSciNumber
class stkSciNumber
	@nBase
	@nExp

	@cStrValue

	def init(cNumberInSciForm)
		if not isString(cNumberInSciForm)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		nPos = ring_substr1(cNumberInSciForm, "e")
		if nPos = 0
			return FALSE
		ok
	
		cBase = ""
		for i = 1 to nPos-1
			cBase += cNumberInStr[i]
		next
	
		cExp = ""
		nLen = len(cNumberInSciForm)
		for i = nPos+1 to nLen
			cExp += cNumberInStr[i]
		next
	
		nBase = 0+ cBase
		if NOT isNumber(nBase)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		nExp = 0+ cExp
		if NOT isNumber(nExp)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		@nBase = nBase
		@nExp = nExp

		@cStrValue = cNumberInSciForm

	def Content()
		return @cStrValue

		def SciForm()
			return @cStrValue

	def Value()
		nResult = @nBase * pow(10, @nExp)
		return nResult

		def NValue()

	def Base()
		return @nBase

	def Exp()
		return @nExp
