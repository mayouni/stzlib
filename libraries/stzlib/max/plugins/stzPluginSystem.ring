#TODO Work in porgress

#---------------------------------------#
#  IMPLEMENTATION OF THE PLUGIN SYSTEM  #
#=======================================#

func PathSeparator()
	if isWindows()
		return "\"
	else
		return "/"
	ok

	func PathSep()
		return PathSeparator()

func LoadPlugins()
	aList = dir("plugins")
	nLen = len(aList)

	aResult = []
	
	for i = 1 to nLen
		cPluginFile = aList[i][1]
		acParts = split(cPluginFile, "_")
		cPluginFunc = split(acParts[3], ".")[1]
		aResult + [ cPluginFunc, cPluginFile ]
	next

	return aResult

class XString from BaseString
	@acFuncs = []
	@aCalls = []

	def XCalls()
		return @aCalls

		def XCallsXT()
			return XCalls()

	def NumberOfXCalls()
		return len(@aCalls)

		#< @FunctionAlternativeForms

		def HowManyXCalls()
			return len(@aCalls)

		def HowManyXCall()
			return len(@aCalls)

		#>

	def XTime(cFuncName)

		anPos = This.XfsZ()[cFuncName]

		nTime = 0
		aCallsXT = This.XCallsXT()
		nLen = len(aCallsXT)

		for i = 1 to nLen
			if ring_find(anPos, i) > 0
				nTime += aCallsXT[i][5]
			ok
		next

		return nTime

		def XTimeOfLastCall(cFuncName)
			return This.XTime(cFuncName)

		def XLastTime(cFunctName)
			return This.XTime(cFuncName)

	def XTimes(cFuncName)
		anPos = This.XfsZ()[cFuncName]
		nLen = len(anPos)

		anTimes = []
		for i = 1 to nLen
			anTimes + This.XCallsXT()[anPos[i]][5]
		next

		return anTimes

	def XErrors()
		aResult = []
		nLen = len(@aCalls)

		for i = 1 to nLen
			if @aCalls[i][3] = 0
				aResult + [ @aCalls[i][1], @aCalls[i][2], @aCalls[i][4] ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XErroneousCalls()
			return This.XErrors()

		def XFailedCalls()
			return This.XErrors()

		#>

	def NumberOfXErrors()
		return len( This.XErrors() )

		#< @FunctionAlternativeForms

		def HowManyXErrors()
			return This.NumberOfXErrors()

		def HowManyXError()
			return This.NumberOfXErrors()

		def NumberofXErrorneousCalls()
			return This.NumberOfXErrors()

		def HowManyXErroneousCalls()
			return This.NumberOfXErrors()

		def HowManyXErroneousCall()
			return This.NumberOfXErrors()

		def NumberofXFailedCalls()
			return This.NumberOfXErrors()

		def HowManyXFailedCalls()
			return This.NumberOfXErrors()

		def HowManyXFailedCall()
			return This.NumberOfXErrors()

		#>

	def XSuccesses()
		aResult = []
		nLen = len(@aCalls)

		for i = 1 to nLen
			if @aCalls[i][3] = 1
				aResult + [ @aCalls[i][1], @aCalls[i][2], @aCalls[i][4] ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XSuccessfulCalls()
			return This.XSuccesses()

		def XSucceededCalls()
			return This.XSuccesses()

		def XSucceeded()
			return This.XSuccesses()

		#>

	def NumberOfXSuccesses()
		return len( This.XSuccesses() )

		#< @FunctionAlternativeForms

		def HowManyXSuccess()
			return This.NumberOfXSuccesses()

		def HowManyXSuccesses()
			return This.NumberOfXSuccesses()

		def NumberOfXSucessfulCalls()
			return This.NumberOfXSuccesses()

		def NumberOfXSucceededCalls()
			return This.NumberOfXSuccesses()

		def HowManyXSucceededCalls()
			return This.NumberOfXSuccesses()

		def HowManyXSucceededCall()
			return This.NumberOfXSuccesses()

		#>

	def XFunctions()
		return @acFuncs

		#< @FunctionAlternativeForms

		def XFuncts()
			return @acFuncs

		def Xfs() # s for plural
			return @acFuncs

		#>

	def NumberOfXFunctions()
		return len(@acFuncs)

		#< @FunctionAlternativeForms

		def NumberOfXFuncts()
			return len(@acFuncs)

		def NumberOfXfs()
			return len(@acFuncs)

		#--

		def HowManyXFunctions()
			return len(@acFuncs)

		def HowManyXFunction()
			return len(@acFuncs)

		def HowManyXFuncts()
			return len(@acFuncs)

		def HowManyXFunct()
			return len(@acFuncs)

		def HowManyXfs()
			return len(@acFuncs)

		def HowManyXf()
			return len(@acFuncs)

		#>

	def XfunctionsZ()
		aResult = []
		nLen = len(@aCalls)
		acSeen = []

		for i = 1 to nLen

			if ring_find(acSeen, @aCalls[i][1]) = 0
				aResult + [ @aCalls[i][1], [ i ] ]
				acSeen + @aCalls[i][1]
			else
				aResult[ @aCalls[i][1] ] + i
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def XFuncsZ()
			return This.XfunctionsZ()

		def XfsZ()
			return This.XfunctionsZ()

		#>

	def XfU(FuncOrFuncAndParams)
		try
			result = This.Xf(FuncOrFuncAndParams)
			This.UpdateWith(result)
			return _TRUE_
		catch
			return _FALSE_
		done

	def Xf(FuncOrFuncAndParams)

		if isString(FuncOrFuncAndParams)
			cFuncName = FuncOrFuncAndParams
			aParams = []

		but isList(FuncOrFuncAndParams) and len(FuncOrFuncAndParams) = 2 and
		    isString(FuncOrFuncAndParams[1])
			cFuncName = FuncOrFuncAndParams[1]
			aParams = FuncOrFuncAndParams[2]

		else
			raise("Bad function name!")
		ok

		# Getting the name of the plugin file name

		if _aPlugins[cFuncName] = _NULL_
			raise("Inexistant function name!")
		ok

		cPluginFile = 'plugins' + PathSep() + _aPlugins[cFuncName]

		# Setting the containers of the output
		result = ""
		error = ""

		# Initiating and running the plugin in a separate VM
		pState = ring_state_init()

		try

			cCode = read(cPluginFile)
			ring_state_runcode(pState, cCode)

			# Setting the value and params of the pluging function

			cValue = '@plugin_value = ' + @@(This.Content())
			ring_state_runcode(pState, cValue)

			cParam = '@plugin_param = ' + @@(aParams)
			ring_state_runcode(pState, cParam)

			# Getting the result
			result = ring_state_findvar(pState, '@plugin_result')[3]

			# Recording the plugin

			if find(@acFuncs, cFuncName) = 0
				@acFuncs + cFuncName
			ok

			time = ring_state_findvar(pState, '@plugin_time')[3]
			@aCalls + [ cFuncName, aParams, _TRUE_, result, time ]

		catch
			error = cCatchError
			@aCalls + [ cFuncName, aParams, _FALSE_, error, 0 ]
		done

		# Removing the state from memory
		ring_state_delete(pState)
		
		# Returning the result or raising an error

		if error = ""
			return result
		else
			raise(error)
		ok

	# The fault-tolerant form of Xf()

	def Xff(FuncOrFuncAndParams)

		if isString(FuncOrFuncAndParams)
			cFuncName = FuncOrFuncAndParams
			aParams = []

		but isList(FuncOrFuncAndParams) and len(FuncOrFuncAndParams) = 2 and
		    isString(FuncOrFuncAndParams[1])
			cFuncName = FuncOrFuncAndParams[1]
			aParams = FuncOrFuncAndParams[2]

		else
			raise("Bad function name!")
		ok

		# Getting the name of the plugin file name

		cPluginFile = 'plugins' + PathSep() + _aPlugins[cFuncName]

		# Setting the containers of the output
		result = ""
		error = ""

		# Initiating and running the plugin in a separate VM
		pState = ring_state_init()

		try

			cCode = read(cPluginFile)
			ring_state_runcode(pState, cCode)

			# Setting the value and params of the pluging function

			cValue = '@plugin_value = ' + @@(This.Content())
			ring_state_runcode(pState, cValue)

			cParam = '@plugin_param = ' + @@(aParams)
			ring_state_runcode(pState, cParam)

			# Getting the result
			result = ring_state_findvar(pState, '@plugin_result')[3]

			# Recording the plugin
			time = ring_state_findvar(pState, '@plugin_time')[3]
			@aCalls + [ cFuncName, aParams, _TRUE_, result, time ]

		catch
			error = cCatchError
			@aCalls + [ cFuncName, aParams, _FALSE_, error, 0 ]

			? NL+ '!!!' + error + '!!!'
		done

		# Removing the state from memory
		ring_state_delete(pState)
		
		# Returning the result or raising an error

		if error = ""
			return result
		ok

class BaseString
	@str

	def init(pcStr)
		@str = pcStr

	def content()
		return @str

	def updateWith(str)
		@str = str

	def size()
		return len(@str)

	def upp()
		return upper(@str)
