

func @IsPpointer(p)
	return isPointer(p) # A Ring standard function

func ArePointers(paPointers)
	if NOT isList(paPointers)

		return FALSE
	ok

	bResult = TRUE
	nLen = len(paPointers)

	for i = 1 to nLen
		if NOT isPointer(paPointers[i])
			bResult = FALSE
			exit
		ok
	next

	return bResult

	func @ArePointers(paPointers)
		return ArePointers(paPointers)

func IsRingState(pPointer)
	if isPointer(pPointer) and pPointer[2] = "RINGSTATE"
		try
			ring_state_runcode(pPointer, '_ = 0')
			return TRUE
		catch
			return FALSE
		done

	else
		return FALSE
	ok

	func @IsRingState(pPointer)
		return IsRingState(pPointer)

	func IsRingInstance(pPointer)
		return IsRingState(pPointer)

	func @IsRingInstance(pPointer)
		return IsRingState(pPointer)

	func IsRingVMInstance(pPointer)
		return IsRingState(pPointer)

	func @IsRingVMInstance(pPointer)
		return IsRingState(pPointer)

	func IsRingVM(pPointer)
		return IsRingState(pPointer)

	func @IsRingVM(pPointer)
		return IsRingState(pPointer)

func AreRingStates(paPointers)

	if NOT ( isList(paPointers) and @ArePointers(paPointers) )

		return FALSE
	ok

	bResult = TRUE
	nLen = len(paPointers)

	for i = 1 to nLen
		if paPointers[i][2] != "RINGSTATE"
			bResult = FALSE
			exit
		ok
	next

	return bResult

	func @AreRingStates(paPointers)
		return AreRingStates(paPointers)

	func AreRingInstances(paPointers)
		return AreRingStates(paPointers)

	func @AreRingInstances(paPointers)
		return AreRingStates(paPointers)

	func AreRingVMInstances(paPointers)
		return AreRingStates(paPointers)

	func @AreRingVMInstances(paPointers)
		return AreRingStates(paPointers)

	func AreRingVMs(paPointers)
		return AreRingStates(paPointers)

	func @AreRingVMs(paPointers)
		return AreRingStates(paPointers)

class stzRingVMInstance from stzRingInstance
class stzRingVM from stzRingInstance

class stzRingInstance
	@cName
	@pPointer

	@acCodes
	@acFiles

	def init(cName)
		@pPointer = ring_state_init()
		@cName = cName

	def Pointer()
		return @pPointer

		def State()
			return This.Pointer()

	def RunCode(cCode)
		try
			ring_state_runcode(This.State(), cCode)
			@acCodes + cCode
		catch
			return cCatchError
		done

	def RunFile(cCode)
		ring_state_runfile(This.State(), cFile)
		@acFiles + cFile

	def Codes()
		return @acCodes

	def Files()
		return @acFiles

	def Code()
		cResult = ""
		nLen = len(@acCodes)

		for i = 1 to nLen
			cResult += @acCodes[i] + NL
		next

		return cResult

	def CodeXT()
		cResult = ""
		nLen = len(@acCodes)

		for i = 1 to nLen
			cResult += @acCodes[i] + NL + NL
		next

		return cResult
	
	def ContainsVar(cVar)
		if NOT isString(cVar)
			raise("err")
		ok

		cVar = trim(cVar)

		bResult = TRUE
		nLen = len(@acCodes)

		for i = 1 to nLen
			oQStr = new QString2()
			oQStr.append(@acCodes[i])
			nFound = oQStr.index(cVar, 0)
			if nFound < 0
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def VarVal(cVar)
		if NOT This.ContainsVar(cVar)
			raise("err: var not found in this state!")
		ok

		result = ring_state_findvar(This.State(), cVar)
		return result

		#< @FunctionAlternativeForms

		def VariableValue(cVar)
			return This.VarVal(cVar)

		def VVal(cVar)
			return This.VarVal(cVar)

		def VValue(cVar)
			return This.VarVal(cVar)

		def ValVar(cVar)
			return This.VarVal(cVar)

		def ValOfVar(cVar)
			return This.VarVal(cVar)

		def ValueOfVariable(cVar)
			return This.VarVal(cVar)

		def v(cVar)
			return This.VarVal(cVar)

		def vv(cVar)
			return This.VarVal(cVar)

		#--

		def GetVarVal(cVar)
			return This.VarVal(cVar)

		def GetVal(cVar)
			return This.VarVal(cVar)

		def GetValue(cVar)
			return This.VarVal(cVar)

		def Val(cVar)
			return This.VarVal(cVar)

		def Value(cVar)
			return This.VarVal(cVar)

		#-- In Ring semantics

		def FindVar()
			return This.VarVal(cVar)

		#>
