/* #TODO

Apply this from Mahmoud message:

	Two things to add about these functions:
	
	They were added when I was developing a prototype for PWCT2 on Mobile.
	The idea was to run Ring programs without starting a new process.
	Later, they were updated to support "Try Ring Online." 
	
	The real use case for these functions can be found here:
	https://github.com/ring-lang/ring/blob/master/tools/tryringonline/ringvm.ring#L120
	
	Note that I am using ring_state_new() and ring_state_mainfile() only once.
	
	Regarding the (E3) error, the code behind this message exists here:
	https://github.com/ring-lang/ring/blob/master/language/src/vmvars.c#L389
	
	In some cases, it might be sufficient to avoid printing this message
	and replace exit() with return; But the purpose of this message is
	to indicate that we are using Ring VM in a way that it's not
	designed/tested for.
	
	Summary: Use ring_state_new() and ring_state_mainfile() and
	avoid ring_state_init() and ring_state_runcode().

*/

func IsRingState(pPointer)

	if isPointer(pPointer) and type(pPointer) = "RINGSTATE"
		return _TRUE_

	else
		return _FALSE_
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

		return _FALSE_
	ok

	bResult _TRUE_
	nLen = len(paPointers)

	for i = 1 to nLen
		if paPointers[i][2] != "RINGSTATE"
			bResult _FALSE_
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
class stzRingState from stzRingInstance

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

	def RunFile(cFile)
		cColde = load(cFile)
		ring_state_runcode(This.State(), cCode)
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

		bResult _TRUE_
		nLen = len(@acCodes)

		for i = 1 to nLen
			oQStr = new QString2()
			oQStr.append(@acCodes[i])
			nFound = oQStr.index(cVar, 0)
			if nFound < 0
				bResult _FALSE_
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
