/* NOTE: About closures in Ring (by Mahmoud)

In Ring what we have is anoymous functions (not closure)
I.e. the function doesn't capture the variables in the outside scope. 

You have to pass the variables as parameters to the function OR use the global scope

*/

func StzFunctionQ()
	return new stzFunction()

# Used for natural-coding

def FunctionName( pcFunctionCall )
	oStzStr = new stzString(pcFunctionCall)

	n = oStzStr.FindFirstOccurrence("(") - 1

	return StzStringQ(pcFunctionCall).SectionQ(1, n).Content()

def FunctionParam( pcFunctionCall )
	oStzStr = new stzString(pcFunctionCall)

	n1 = oStzStr.FindFirstOccurrence("(") + 1
	n2 = oStzStr.FindFirstOccurrence(")") - 1

	return StzStringQ(pcFunctionCall).SectionQ(n1, n2).Trimmed()

def FunctionParamType( pcFunctionCall )
	cParam = FunctionParam(pcFunctionCall)

	if StzStringQ( cParam ).IsBoundedBy('"')
		cType = "STRING"
	
	but StzStringQ( cParam ).IsBoundedBy([ "[","]" ])
		cType = "LIST"
	
	but StzStringQ(cParam).IsNumberInString()
		cType = "NUMBER"
	
	else
		cType = "OBJECT"
	ok

	return cType

def FunctionNameFinishesWithOneOfThese( pcFunctionCall, paSubStr )

	/* Example:
	FunctionNameFinishesWithOneOfThese( pThing, [ "in", "of" ] )
	*/

	cLast2Chars = StzStringQ(FunctionName(pcFunctionCall)).NLastCharsQ(2).Lowercased()

	if cLast2Chars = "in" or cLast2Chars = "of"
		return _TRUE_
	else
		return _FALSE_
	ok


def FunctionParamTypeIsOneOfThese(pcFunctionCall, paSubStr)
	if CheckingParams()
		if NOT isString(pcFunctionCall)
			StzRaise("Incorrect param type! pcFunctionCall must be a string.")
		ok
	
		if pcFunctionCall = ""
			StzRaise("Incorrect param value! pcFunctionCall must be a non empty string.")
		ok
	
		if NOT ( isList(pacSubStr) and IsListOfStrings(pacSubStr) )
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		if len(pacSubStr) = 0
			StzRaise("Incorrect param value! pacSubStr must be a nom empty list.")
		ok
	ok

	cType = FunctionParamType(pcFunctionCall)
	if cType = ""
		return _FALSE_
	ok

	cTypeLow = lower(cType)

	nLen = len(pacSubStr)
	acSubStrLow = []

	for i = 1 to nLen
		acSubStrLow + lower(pacSubStr[i])
	next

	if ring_find(acSubStrLow, cTypeLow) > 0
		return _TRUE_
	else
		return _FALSE_
	ok


class stzFunction from stzObject
	cName
	aParam
	cBody
	cReturn
	cFuncOrDef = "func"

	bStartedUp _FALSE_

	def Name()
		return cName

	def Params()
		return aParam

	def ParamsTypes()	
		aResult = []
		for param in aParam
			aResult += [ param, ring_type(param) ]
		next
		return aResult

	def NumberOfParams()
		return len(aParam)

	def Signature()
		cResult = cName + "("
	
		for i = 1 to len(aParam)
			cResult += aParam[i]
			if i < len(aParam)
				cResult += ", "
			ok
		next
		cResult += ")"

		return cResult

	def Body()
		return cBody
		
	def Returned()
		return cReturn

	def DesignCode()
		cResult = cFuncOrDef + " " + Signature() + NL + Body() + NL
		return cResult

	def CallingCodeFor(paValue)
		cResult = cName + "("
	
		for i = 1 to len(paValue)
			if isString(paValue[i]) { cResult += '"' }
			cResult += paValue[i]
			if isString(paValue[i]) { cResult += '"' }
			if i < len(paValue)
				cResult += ", "
			ok
		next
		cResult += ")"
		return cResult

	def PlainCodeFor(paValue)
		cResult = CallingCodeFor(paValue) + NL + NL + DesignCode()
		return cResult

	def Startup()
		eval( DesignCode() )
		bStartedUp _TRUE_

	def IsStartedUp()
		return bStartedUp

	def ApplyFor(paValue)
		if bStartedUp
			eval( CallingCodeFor(paValue) )
		else
			StzRaise("fucntion is not started. Use startup() before ApplyFor()!")
		ok

	def ApplyForMany(paMany)
		for m in paMany
			This.ApplyFor([m])
		next

		def ApplyForThese(paMany)
			This.ApplyForMany(paMany)

	def ElpasedTime()
		t1 = clocks()
		This.Startup()
		t2 = clock()

		t = (t2 - t1) / clocksPerSecond()
		return t

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsFunction() # required by stzChainOfTruth
		return _TRUE_
