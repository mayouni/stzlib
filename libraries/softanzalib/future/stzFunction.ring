
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

	if StzStringQ( cParam ).IsBoundedBy('"','"')
		cType = "STRING"
	
	but StzStringQ( cParam ).IsBoundedBy("[","]")
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
		return TRUE
	else
		return FALSE
	ok


def FunctionParamTypeIsOneOfThese(pcFunctionCall, paSubStr)
	cType = FunctionParamType(pcFunctionCall)
	return StzStringQ(cType).IsOneOfThese(paSubStr)


class stzFunction from stzObject
	cName
	aParam
	cBody
	cReturn
	cFuncOrDef = "func"

	bStartedUp = FALSE

	def Name()
		return cName

	def Params()
		return aParam

	def ParamsTypes()	
		aResult = []
		for param in aParam
			aResult += [ param, type(param) ]
		next
		return aResult

	def NumberOfParams()
		return len(aParam)

	def Signature()
		cResult = cName + "("
	
		for i=1 to len(aParam)
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
	
		for i=1 to len(paValue)
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
		bStartedUp = TRUE

	def IsStartedUp()
		return bStartedUp

	def ApplyFor(paValue)
		if bStartedUp
			eval( CallingCodeFor(paValue) )
		else
			stzRaise("fucntion is not started. Use startup() before ApplyFor()!")
		ok

	def ApplyForMany(paMany)
		for m in paMany
			This.ApplyFor([m])
		next

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
		return TRUE
