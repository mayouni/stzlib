#--------------------------------------------------------------#
#            SOFTANZA LIBRARY (V0.9) - STZSTRINGCORE           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Core string class -- engine handle,         #
#                  content access, and shared primitives.       #
#                  All stzString subclasses inherit from this.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCore from stzObject

	@pEngine

	These
	Those

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pcStr)

		if CheckingParams()

			if NOT ( isString(pcStr) or
				 (isList(pcStr) and StzListQ(pcStr).IsPairOfStrings()) )

				StzRaise("Can't create the stzStringCore object! pcStr must be a string or a pair of strings.")
			ok

			if isList(pcStr) and StzListQ(pcStr).IsPairOfStrings()
				@cVarName = pcStr[1]
				@pEngine = StzEngineStringFrom(pcStr[2])
				return
			ok

		ok

		@pEngine = StzEngineStringFrom(pcStr)

		These = This
		Those = This

	  #=======================================#
	 #     GETTING CONTENT OF THE STRING     #
	#=======================================#

	def Content()
		return StzEngineStringData(@pEngine)

		#< @FunctionFluentForm

		def ContentQ()
			return new stzStringCore(This.Content())

		#>

		#< @FunctionAlternativeForm

		def Value()
			return This.Content()

		def String()
			return This.Content()

		def TheString()
			return This.Content()

		def R()
			return This.Content()

		#>

	  #=======================================#
	 #     GETTING THE ENGINE HANDLE         #
	#=======================================#

	def Engine()
		return @pEngine

	  #=======================================#
	 #     GETTING THE SIZE OF THE STRING    #
	#=======================================#

	def NumberOfChars()
		return len(This.Content())

		#< @FunctionAlternativeForm

		def Size()
			return This.NumberOfChars()

		def Len()
			return This.NumberOfChars()

		def Length()
			return This.NumberOfChars()

		def NChars()
			return This.NumberOfChars()

		#>

	  #=======================================#
	 #  CHECKING IF THE STRING IS EMPTY      #
	#=======================================#

	def IsEmpty()
		return This.Content() = ""

	  #=======================================#
	 #  GETTING A COPY OF THE STRING OBJECT  #
	#=======================================#

	def Copy()
		return new stzStringCore( This.String() )

	  #=======================================#
	 #     UPDATING THE STRING CONTENT       #
	#=======================================#

	def Update(pcNewStr)
		if CheckingParams() = 1
			if isList(pcNewStr) and StzListQ(pcNewStr).IsWithOrByOrUsingNamedParam()
				pcNewStr = pcNewStr[2]
			ok
		ok

		StzEngineStringFree(@pEngine)
		@pEngine = StzEngineStringFrom(pcNewStr)

		#< @FunctionFluentForm

		def UpdateQ(pcNewStr)
			This.Update(pcNewStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def SetContent(pcNewStr)
			This.Update(pcNewStr)

		#>

	  #========================================#
	 #     INTERNAL ENGINE PRIMITIVES         #
	#========================================#

	def _FindSubStr(pcSubStr, nStartAt, bCaseSensitive)
		if len(pcSubStr) = 0 or nStartAt < 1
			return 0
		ok

		nByteStart = nStartAt - 1

		if bCaseSensitive
			nResult = StzEngineStringIndexOfFrom(@pEngine, pcSubStr, nByteStart)
		else
			nResult = StzEngineStringIndexOfCI(@pEngine, pcSubStr, nByteStart)
		ok

		if nResult >= 0
			return nResult + 1
		else
			return 0
		ok

	def _ReplaceRange(n1, nRange, pcNew)
		pResult = StzEngineStringReplaceRange(@pEngine, n1 - 1, nRange, pcNew)
		if pResult = NULL
			return This.Content()
		ok
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def _SplitByStr(cSep)
		nCount = StzEngineStringSplitCount(@pEngine, cSep)
		aResult = []
		for i = 0 to nCount - 1
			pPart = StzEngineStringSplitGet(@pEngine, cSep, i)
			if pPart != NULL
				aResult + StzEngineStringData(pPart)
				StzEngineStringFree(pPart)
			else
				aResult + ""
			ok
		next
		return aResult
