
func IsSciForm(cNumber)
	if not isString(cNumber)
		return FALSE
	ok

	nPos = substr(cNumber, "e")
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

	if n = 0
        	return "0"
	ok

	# Case n != 0

	if n > 0
		nAbs = n
	else
		nAbs = -n
	ok

        nExp   = floor(log10(nAbs))
	cExp = ""+ nExp

        nCoeff = n / pow(10, nExp)
	cCoeff = ""+ nCoeff

        cResult = cCoeff + "e" + cExp
	return cResult


func Sci2Number(cNumberInStr) # TODO: add a stzSicNumber class
	cNumberInStr = substr(cNumberInStr, "_", "")
	nPos = substr(cNumberInStr, "e")
	if nPos = 0
		raise("ERR-" + StkError(:IncorrectParamValue))
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
	nExp = 0+ cExp

	nResult = nBase * pow(10, nExp)
	return nResult
	
class stzCoreSciNumber from stkSciNumber

class stkSciNumber
	@nBase
	@nExp

	@cStrValue

	def init(cNumberInSciForm)
		if not isString(cNumberInSciForm)
			return raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		nPos = substr(cNumberInSciForm, "e")
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
