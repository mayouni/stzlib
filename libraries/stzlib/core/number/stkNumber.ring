
	
#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE NUMBER  #
#~~~~~~~~~~~~~~~~~~~#

class stzCoreNumber from stkNumber

class stkNumber
	@content
	@nRound

	@bSpacify = _FALSE_
	@nSpaceStep = 3
	@cSpaceChar = "_"

	#----------------------------------------------------------------#
	#  INITIALISING THE NUMBER, FROM A NUMBER OR A NUMBER IN STRING  #
	#----------------------------------------------------------------#

	def init(pNumber)
		if NOT (isNumber(pNumber) or isString(pNumber))
			raise("ERR-" + StkErrror(:IncorrectParamType) + NL )
		ok

		if isNumber(pNumber)

			@content = pNumber
			@nRound = @Round(""= @content)

		else # the number is provided in a string
			if ring_substr1(pNumber, '_') > 0

				@bSpacify = _TRUE_
			else
				@bSpacify = _FALSE_
			ok

			@content = @Val(pNumber)
			@nRound = @Round(@content)

		ok

	#--------------------------------------------#
	#  NUMBER VALUE, IN NUMBER AND STRING FORMS  #
	#--------------------------------------------#

	def Copy()
		oCopy = This
		return oCopy

	def Content()
		return @content

		def NValue()
			return @content

		def Value()
			return @content

	def SValue()
		
		cResult = This.SIntPart() + "." + SFractPartWithoutZeroDot()
		return cResult

	#-----------------------------------------------------#
	#  UPDATING THE NUMBER WITH A NUMBER OR STRING FORM   #
	#-----------------------------------------------------#

	def Update(pNumber)

		if isNumber(pNumber)

			@content = pNumber
			

		else # the number is provided in a string

			@content = @Val(pNumber)

			if ring_substr1(pNumber, '_') > 0
				@bSpacify = _TRUE_
			else
				@bSpacify = _FALSE_
			ok
		ok

		@nRound = @Round(pNumber)

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

	#-------------------------------------------------------#
	#  GETTING THE INTEGER PART IN NUMBER AND STRING FORMS  #
	#-------------------------------------------------------#

	def IntPart()
		if @content > 0
			return floor(@content)
		else
			return ceil(@content)
		ok

	def SIntPart()

		cSpaceChar = ""
		if @bSpacify
			cSpaceChar = @cSpaceChar
		ok

		nInt = This.IntPart()
		nRound = @Round(nInt)
		cResult = NStringify(nInt, cSpaceChar, @nSpaceStep, nRound)

		return cResult


	#------------------------------------------------------#
	#  GETTING THE STRING PART IN NUMBER AND STRING FORMS  #
	#------------------------------------------------------#

	def FractPart()

		n = @content
		if n < 0
			n = -n
		ok

		nResult = n - floor(n)
		return nResult

		def FPart()
			return This.FractPart()

		def FractValue()
			return This.FractPart()

		def FValue()
			return This.FractPart()

	def SFractPart()
		nTempRound = CurrentRound() # in Ring program
		nRound = This.Round()

		decimals(nRound)

		nRound = @Round(@content)

		cTempStr = "" + @content
		nLen = len(cTempStr)

		decimals(nTempRound)

		nPos = ring_substr1(cTempStr, ".")

		if nPos = 0
			return ""

		else
			if @content < 0
				cResult = "-0."
			else
				cResult = "0."
			ok

			n1 = nPos + 1
			n2 = nPos + nRound

			for i = n1 to n2
				cResult += cTempStr[i]
			next
		ok

		return cResult

		#< @FunctionAlternativeForms

		def SFPart()
			return This.SFractPart()

		def SFractValue()
			return This.SFractPart()

		def SFValue()
			return This.SFractPart()

		def SFraction()
			return This.SFractPart()
		#>

	def HasFractPart()
		if ring_substr1( This.SValue(), "." ) > 0
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def HasFraction()
			return This.HasFractPart()

		def IsRealNumber()
			return This.HasFractPart()

		def IsReal()
			return This.HasFractPart()

		def HasFValue()
			return This.HasFractPart()

		def HasFPart()
			return This.HasFractPart()

		#>

	def SFractPartWithoutZeroDot()

		cResult = This.SFractPart()
		cResult = ring_substr2(cResult, "0.", "")
		cResult = ring_substr2(cResult, "+", "")
		cResult = ring_substr2(cResult, "-", "")

		return cResult

		#< @FunctionAlternativeForms

		def SFractValueWithoutZeroDot()
			return This.SFractPartWithoutZeroDot()

		def SFPartWithoutZeroDot()
			return This.SFractPartWithoutZeroDot()

		def SFValueWithoutZeroDot()
			return This.SFractPartWithoutZeroDot()

		def SFractionWithoutZeroDot()
			return This.SFractPartWithoutZeroDot()

		#>

	#-----------------------------------------------#
	#  GETTING AND SETTING THE ROUND OF THE NUMBER  #
	#-----------------------------------------------#

	def Round()
		return @nRound

	def SetRound(n)
		if not isNumber(n)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@nRound = n

	def RoundedTo(n)
		if NOT isNumber(n)
			raise(StkError(:IncorrectParamType))
		ok

		nTempRound = CurrentRound()

		decimals(n)
		return @content


	def SRoundedTo(n)
		if NOT isNumber(n)
			raise(StkError(:IncorrectParamType))
		ok

		nTempRound = CurrentRound()

		decimals(n)
		cResult = ""+ @content
		decimals(nTempRound)

		return cResult

	#----------------------------------#
	#  GETTING THE SIGN OF THE NUMBER  #
	#----------------------------------#

	def Sign()
		if @content < 0
			return "-"
		else
			return "+"
		ok

	#----------------------------------------------------#
	#  GETTING THE SDTRING FORM OF THE NUMBER SPACIFIED  #
	#----------------------------------------------------#

	def Spacify()
		@bSpacify = _TRUE_

	def Unspacify()
		@bSpacify = _FALSE_

	def UnSpacified()
		bTemp = @bSpacify
		@bSpacify = _FALSE_
		cResult This.SValue()
		@bSpacify = bTemp

	def Spacified()
		
		cResult = NStringify(@content, @cSpaceChar, @nSpaceStep, @Round(@content))
		return cResult

	#-------------------------------------------#
	#  SETTING AND GETTING SPACE CHAR AND STEP  #
	#-------------------------------------------#

	def SpaceChar()
		return @cSpaceChar

	def SetSpaceChar(c)
		@cSpaceChar = c

	def SpaceStep()
		return @nSpaceStep

	def SetSpaceStep(n)
		@nSpaceStep = n

	#-------------------------#
	#  ARITHMETIC OPERATIONS  #
	#-------------------------#

	def Add(pNumber)
		if isNumber(pNumber)
			@content += pNumber

		but isString(pNumber)
			@content += @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

	def Substruct(pNumber)
		if isNumber(pNumber)
			@content -= pNumber

		but isString(pNumber)
			@content -= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Substract(pNumber)
			This.Substruct(pNumber)

	def MultiplyBy(pNumber)
		if isNumber(pNumber)
			@content *= pNumber

		but isString(pNumber)
			@content *= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Multiply(pNumber)
			This.MultiplyBy(pNumber)

	def DivideBy(pNumber)
		if isNumber(pNumber)
			@content /= pNumber

		but isString(pNumber)
			@content /= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Divide(pNumber)
			return This.DivideBy(pNumber)

	func Abs()
		if @content > 0
			return @content
		else
			return -@content
		ok

	func SAbs()
		if @content > 0
			return This.SValue()
		else
			return "-" + SValue()
		ok	

	#------------------------------------------#
	#  CHECKING EQUALITY WITH AN OTHER NUMBER  #
	#------------------------------------------#

	def IsEqual(n)
		oOtherNumber = new stkNumber(n)
		if This.SNumber() = oOtherNumber.SNumber()
			return _TRUE_
		else
			return _FALSE_
		ok

		def Equals(n)
			return IsEqual(n)

		def IsEqualTo(n)
			return IsEqual(n)

	#------------------------#
	#  OVERLOADED OPERATORS  #
	#------------------------#

	def Operator(op, value)

		if op = "="
			return This.Equals(value)

		but op = "+"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content + (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok
				
				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "-"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content - (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "*"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content * (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		but op = "/"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content + (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = nValue
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		else
			raise("ERR-" + StkError(:UnsupportedOperator) + NL)
		ok
