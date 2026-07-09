
	
#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE NUMBER  #
#~~~~~~~~~~~~~~~~~~~#

class stzCoreNumber from stkNumber

class stkNumber
	@content
	@nRound

	@bSpacify = FALSE
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

				@bSpacify = TRUE
			else
				@bSpacify = FALSE
			ok

			@content = @Val(pNumber)
			@nRound = @Round(@content)

		ok

	#--------------------------------------------#
	#  NUMBER VALUE, IN NUMBER AND STRING FORMS  #
	#--------------------------------------------#

	def Copy()
		_oCopy_ = This
		return _oCopy_

	def Content()
		return @content

		def NValue()
			return @content

		def Value()
			return @content

	def SValue()
		
		_cResult_ = This.SIntPart() + "." + SFractPartWithoutZeroDot()
		return _cResult_

	#-----------------------------------------------------#
	#  UPDATING THE NUMBER WITH A NUMBER OR STRING FORM   #
	#-----------------------------------------------------#

	def Update(pNumber)

		if isNumber(pNumber)

			@content = pNumber
			

		else # the number is provided in a string

			@content = @Val(pNumber)

			if ring_substr1(pNumber, '_') > 0
				@bSpacify = TRUE
			else
				@bSpacify = FALSE
			ok
		ok

		@nRound = @Round(pNumber)

		if KeepingHisto() = TRUE
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

		_cSpaceChar_ = ""
		if @bSpacify
			_cSpaceChar_ = @cSpaceChar
		ok

		_nInt_ = This.IntPart()
		_nRound_ = @Round(_nInt_)
		_cResult_ = NStringify(_nInt_, _cSpaceChar_, @nSpaceStep, _nRound_)

		return _cResult_


	#------------------------------------------------------#
	#  GETTING THE STRING PART IN NUMBER AND STRING FORMS  #
	#------------------------------------------------------#

	def FractPart()

		_n_ = @content
		if _n_ < 0
			_n_ = -_n_
		ok

		_nResult_ = _n_ - floor(_n_)
		return _nResult_

		def FPart()
			return This.FractPart()

		def FractValue()
			return This.FractPart()

		def FValue()
			return This.FractPart()

	def SFractPart()
		_nTempRound_ = CurrentRound() # in Ring program
		_nRound_ = This.Round()

		decimals(_nRound_)

		_nRound_ = @Round(@content)

		_cTempStr_ = "" + @content
		_nLen_ = len(_cTempStr_)

		decimals(_nTempRound_)

		_nPos_ = ring_substr1(_cTempStr_, ".")

		if _nPos_ = 0
			return ""

		else
			if @content < 0
				_cResult_ = "-0."
			else
				_cResult_ = "0."
			ok

			_n1_ = _nPos_ + 1
			_n2_ = _nPos_ + _nRound_

			for i = _n1_ to _n2_
				_cResult_ += _cTempStr_[i]
			next
		ok

		return _cResult_

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
			return TRUE
		else
			return FALSE
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

		_cResult_ = This.SFractPart()
		_cResult_ = ring_substr2(_cResult_, "0.", "")
		_cResult_ = ring_substr2(_cResult_, "+", "")
		_cResult_ = ring_substr2(_cResult_, "-", "")

		return _cResult_

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

	def SetRound(_n_)
		if not isNumber(_n_)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@nRound = _n_

	def RoundedTo(_n_)
		if NOT isNumber(_n_)
			raise(StkError(:IncorrectParamType))
		ok

		_nTempRound_ = CurrentRound()

		decimals(_n_)
		return @content


	def SRoundedTo(_n_)
		if NOT isNumber(_n_)
			raise(StkError(:IncorrectParamType))
		ok

		_nTempRound_ = CurrentRound()

		decimals(_n_)
		_cResult_ = ""+ @content
		decimals(_nTempRound_)

		return _cResult_

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
		@bSpacify = TRUE

	def Unspacify()
		@bSpacify = FALSE

	def UnSpacified()
		_bTemp_ = @bSpacify
		@bSpacify = FALSE
		_cResult_ This.SValue()
		@bSpacify = _bTemp_

	def Spacified()
		
		_cResult_ = NStringify(@content, @cSpaceChar, @nSpaceStep, @Round(@content))
		return _cResult_

	#-------------------------------------------#
	#  SETTING AND GETTING SPACE CHAR AND STEP  #
	#-------------------------------------------#

	def SpaceChar()
		return @cSpaceChar

	def SetSpaceChar(c)
		@cSpaceChar = c

	def SpaceStep()
		return @nSpaceStep

	def SetSpaceStep(_n_)
		@nSpaceStep = _n_

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

	def IsEqual(_n_)
		_oOtherNumber_ = new stkNumber(_n_)
		if This.SNumber() = _oOtherNumber_.SNumber()
			return TRUE
		else
			return FALSE
		ok

		def Equals(_n_)
			return IsEqual(_n_)

		def IsEqualTo(_n_)
			return IsEqual(_n_)

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

				_cTempStr_ = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content + (0+ _cTempStr_)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				_cSpaceChar_ = @cSpaceChar
				if not @bSpacify
					_cSpaceChar_ = ""
				ok

				_nRound1_ = @Round(nValue)
				_nRound2_ = This.Round()

				if _nRound1_ < _nRound2_
					_nRound_ = _nRound1_
				else
					_nRound_ = _nRound2_
				ok
				
				_cResult_ = NStringify(nValue, @bSpacify, _cSpaceChar_, _nRound_)

				# Returning the result

				return _cResult_

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "-"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				_cTempStr_ = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content - (0+ _cTempStr_)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				_cSpaceChar_ = @cSpaceChar
				if not @bSpacify
					_cSpaceChar_ = ""
				ok

				_nRound1_ = @Round(nValue)
				_nRound2_ = This.Round()

				if _nRound1_ < _nRound2_
					_nRound_ = _nRound1_
				else
					_nRound_ = _nRound2_
				ok

				_cResult_ = NStringify(nValue, @bSpacify, _cSpaceChar_, _nRound_)

				# Returning the result

				return _cResult_

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "*"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				_cTempStr_ = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content * (0+ _cTempStr_)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				_cSpaceChar_ = @cSpaceChar
				if not @bSpacify
					_cSpaceChar_ = ""
				ok

				_nRound1_ = @Round(nValue)
				_nRound2_ = This.Round()

				if _nRound1_ < _nRound2_
					_nRound_ = _nRound1_
				else
					_nRound_ = _nRound2_
				ok

				_cResult_ = NStringify(nValue, @bSpacify, _cSpaceChar_, _nRound_)

				# Returning the result

				return _cResult_

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		but op = "/"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				_cTempStr_ = trim( ring_substr2(value, "_", "") )

				# Getting the numeric value

				nValue = @content + (0+ _cTempStr_)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				_cSpaceChar_ = @cSpaceChar
				if not @bSpacify
					_cSpaceChar_ = ""
				ok

				_nRound1_ = nValue
				_nRound2_ = This.Round()

				if _nRound1_ < _nRound2_
					_nRound_ = _nRound1_
				else
					_nRound_ = _nRound2_
				ok

				_cResult_ = NStringify(nValue, @bSpacify, _cSpaceChar_, _nRound_)

				# Returning the result

				return _cResult_

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		else
			raise("ERR-" + StkError(:UnsupportedOperator) + NL)
		ok
