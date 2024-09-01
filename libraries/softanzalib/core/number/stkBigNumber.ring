
# NOTE: this class was made in collaboration between me, ClaudeAI and ChatGPT.
# ClaudeAI generated the overall design and proposed the majority of helper functions.
# ChatGPT helped debugging an issue and fixing it.
# I manually crafted several adaptations and refactorings to cope with Softanza style.

$BIG_NUMBER_MAX_PRECISION = 28
$BIG_NUMBER_DEFAULT_PRECISION = 6

#--

func BigNumberMaxPrecision()
	return $BIG_NUMBER_MAX_PRECISION

	func BigNumberMaxRound()
		return $BIG_NUMBER_MAX_PRECISION

func SetBigNumberMaxPrecision(n)
    	if not isNumber(n)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	$BIG_NUMBER_MAX_PRECISION = n

	func SetBigNumberMaxRound(n)
		SetBigNumberMaxPrecision(n)

#--

func BigNumberDefaultPrecision()
	return $BIG_NUMBER_DEFAULT_PRECISION

	func BigNumberDefaultRound()
		return $BIG_NUMBER_DEFAULT_PRECISION

func SetBigNumberDefaultPrecision(n) // #ai #chatgpt fixed an error
    	if n > $BIG_NUMBER_MAX_PRECISION
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	$BIG_NUMBER_DEFAULT_PRECISION = n

	func SetBigNumberDefaultRound(n)
		SetBigNumberDefaultPrecision(n)

#---------#
#  CLASS  #
#---------#

class stkBigNumber
	@cIntPart
	@bNegative

	@cFullFractPart
	@nFullPrecision

	@cFractPart
	@nPrecision

	@bSpacify = FALSE
	@nSpace = 3
	@cSpace = "_"

	  #-------------------------------------------------------#
	 #  INITIALIZING THE BIG NUMBER FROM A NUMBER IN STRING  #
	#-------------------------------------------------------#

    	def init(cValue)

		bSpacify = FALSE

		if substr(cValue, "_") > 0
			bSpacify = TRUE
		ok

		This.Update(cValue, bSpacify)

		# Storing the full precision of the number
		# We need it if SetPrecision(n) is used with n > @nPrecision

		@cFullFractPart = @cFractPart
		@nFullPrecision = @nPrecision

	  #--------------------------------------------------------------#
	 #  UPDATING THE BIG NUMBER WITH A NUMBER PROVIDED AS A STRING  #
	#--------------------------------------------------------------#

	func Update(cNumberInStr, bSpacify)

		@bNegative = FALSE

		# The object is set using a string

 		if not isString(cNumberInStr)
	            	raise("ERR-" + StkError(:IncorrectParamType))
	        ok

		# Cleansing the string form leading and trailing spaces

		cNumberInStr = trim(cNumberInStr)

		# If the new number is spacified then store that info and unspaicify it

		if substr(cNumberInStr, "_") > 0
			@bSpacify = TRUE
			cNumberInStr = substr(cNumberInStr, "_", "")
		ok

		# The string must contain a valid number

		if not isNumber(0+ cNumberInStr)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# If the new number is negative, then remove the negative sign

		if left(cNumberInStr, 1) = "-"
			@bNegative = TRUE
	       		cNumberInStr = substr(cNumberInStr, "-", "")
	        ok

		# Splitting the number into 2 parts, intpart and fractpart

	        acParts = split(cNumberInStr, ".")
	        @cIntPart = This.pvtTrimLeadingZeros(acParts[1])

		@cFractPArt = ""
		@nPrecision = 0

	        if len(acParts) > 1
	            	@cFractPart = This.pvtTrimTrailingZeros(acParts[2])
			@nPrecision = len(@cFractPart)
	        ok
	        
	        if @cIntPart = "" and
		   @cFractPart = ""

	           	@cIntPart = "0"
	        ok

		# If the big number has a higer percision than
		# the allowed $BIG_NUMBER_MAX_PRECISION, let
		# the max precision be the full precision

		# ~> As a corollary of this, the provided number
		# is rounded to the maximum allowed precision

		if @nPrecision > $BIG_NUMBER_MAX_PRECISION
			This.RoundTo($BIG_NUMBER_MAX_PRECISION)
			@cFullFractPart = @cFractPart
			@nFullPrecision = @nPrecision
		ok

	  #-----------------------------------------------------------------#
	 #  GETTING THE VALUE OF THE BIG NUMBER AND ITS PARTS (IN STRING)  #
	#-----------------------------------------------------------------#

   	def Value()

        	result = This.IntPart() #NOTE may be spacified

	        if @cFractPart != ""
	            result += "." + @cFractPart
	        ok

	        return result

		def SValue()
			return This.Value()

		def Content()
			return This.Value()

	def IntPart()
		cResult = ""

		if @bSpacify = TRUE
			cResult += This.IntPartSpacified()
		else
			cResult += @cIntPart
		ok

		if @bNegative and left(cResult, 1) != "-"
			cResult = "-" + cResult
		ok

		return cResult


		def Int()
			return This.IntPart()

		def SIntPart()
			return This.IntPart()

		def SInt()
			return This.IntPart()

	def FractPart()
		return @cFractPart

		def Fract()
			return @cFractPart

		def SFractPart()
			return @cFractPart

		def SFract()
			return @cFractPart

	  #------------------------------------------------------------------------------#
	 #  GETTING THE INITIAL FULL VALUE OF THE BIG NUMBER AND ITS PARTS (IN STRING)  #
	#------------------------------------------------------------------------------#
	# before any rounding has occured on it using SetRound(n)

   	def InitialValue()

        	result = This.SIntPart()

	        if @cFullFractPart != ""
	            result += "." + @cFullFractPart
	        ok
 
	        return result

		#< @FunctionAlternativeForms

		def SInitialValue()
			return This.InitialValue()

		def InitialContent()
			return This.InitialValue()

		def SInitialContent()
			return This.InitialValue()

		#>

	def FullFractPart()
		return @cFullFractPart

		def FullFract()
			return @cFullFractPart

		def SFullFractPart()
			return @cFullFractPart

		def SFullFract()
			return @cFullFractPart

	def FullPrecision()
		return @nFullPrecision

		def InitialPrecsion()
			return @nFullPrecision

		def FullRound()
			return @nFullPrecision

		def InitialRound()
			return return @nFullPrecision

	  #-------------------------------------------------#
	 #  RESTORING THE INITIAL VALUE OF THE BIG NUMBER  #
	#-------------------------------------------------#

	def Restore()
		@cFractPart = @cFullFractPart
		@nPrecision = @nFullPrecision


	  #------------------------------------------------------------#
	 #  ADDING A NUMBER IN STRING (BIG OR NOT) TO THE BIG NUMBER  #
	#------------------------------------------------------------#

    	def Add(cOtherBigNumber)

		oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

		if @bSpacify or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpacify = TRUE
		ok

	        if This.IsNegative() = oOtherBigNumber.isNegative()
	        	cResult = This.pvtAddDecimalStrings(SValue(), oOtherBigNumber.SValue())

	        else
		
			cResult = This.pvtSubtractDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())

			if This.IsNegative() and This.pvtCompareAbsValues(This.SValue(), oOtherBigNumber.SValue()) > 0
				This.@bNegative = TRUE
			else
				This.@bNegative = FALSE
	            	ok

	        ok

		# Updating the big number with the result

		This.Update(cResult, @bSpacify)

		if oOtherBigNumber.@bSpacify = TRUE
			This.Spacify()
		ok

		#< @FunctionAlternativeForm

		def SAdd(cOtherBigNumber)
			This.Add(cOtherBigNumber)

		#>

	  #-------------------------------------------------------------------#
	 #  SUBTRACTING A NUMBER IN STRING (BIG OR NOT) FROM THE BIG NUMBER  #
	#-------------------------------------------------------------------#

    	def Subtract(cOtherBigNumber)
? "-->"
		result = This.pvtSubtractStrings(This.Unspacified(), cOtherBigNumber)
? "<"
		bSpacify = FALSE

		if @bSpacify or substr(cOtherBigNumber, "_") > 0
			bSpacify = TRUE
		ok

		This.Update(result, bSpacify)

		def SSubtract(cOtherBigNumber)
			This.Subtract(cOtherBigNumber)


	  #-------------------------------------------------------------------#
	 #  MULTIPLYING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#-------------------------------------------------------------------#

   	 def Multiply(cOtherBigNumber)

	   	oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

		if @bSpacify or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpacify = TRUE
		ok

	        cResult = This.pvtMultiplyDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())

	        if ( (This.IsNegative() and NOT oOtherBigNumber.IsNegative()) or
		   (NOT This.IsNegative() and oOtherBigNumber.IsNegative()) ) and

 		   cResult != "0"

			cResult = "-" + cResult
		
	        ok

		# Updating the big number with the result

		This.Update(cResult)

		if oOtherBigNumber.@bSpacify = TRUE
			This.Spacify()
		ok

		#< @FunctionAlternativeForm

		def SMultiply(cOtherBigNumber)
			This.Multiply(cOtherBigNumber)

		#>

	  #-----------------------------------------------------------------#
	 #  DIVIDING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#----------------------------------------------------------------#

	def Divide(cOtherBigNumber)

		if cOtherBigNumber = "0"
	        	raise("ERR-" + StkError(:DivisionByZero))
	   	 ok
	    
	    	oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

		if @bSpacify or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpacify = TRUE
		ok

	    	cResult = pvtDivideDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())
	    
	        if ( (This.IsNegative() and NOT oOtherBigNumber.IsNegative()) or
		   (NOT This.IsNegative() and oOtherBigNumber.IsNegative()) ) and

 		   cResult != "0"

			cResult = "-" + cResult
		
	        ok

		# Updating the big number with the result

		This.Update(cResult)

		if oOtherBigNumber.@bSpacify = TRUE
			This.Spacify()
		ok

		#< @FunctionAlternativeForm

		def SDivide(cOtherBigNumber, nPrecision)
			This.Divide(cOtherBigNumber, nPrecision)

		#>

	  #---------------------------------------------#
	 #  ELEVATION THE BIG NUMBER TO A GIVEN POWER  #
	#---------------------------------------------#

	# Power function for big numbers using exponentiation by squaring

	# This algorithm efficiently computes x^n by reducing the number of multiplications

	# It has a time complexity of O(log n) multiplications, where each multiplication
	# is performed using the Karatsuba algorithm for big numbers
	
	def Power(n) #ai #claude #me

		if not isNumber(n)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		if n < 0
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok

		# Base cases
		if n = 0 return "1" ok
		if n = 1 return This.SValue() ok
		    
		# Initialize result
		result = "1"
		cBigNumber = This.SValue()

		# Binary exponentiation algorithm
		while n > 0
			# If n is odd, multiply result with cBigNumber
			if n % 2 = 1
				result = pvtMultiplyDecimalStrings(result, cBigNumber)
			ok
		        
			# Square cBigNumber and halve n
			cBigNumber = pvtMultiplyDecimalStrings(cBigNumber, cBigNumber)
			n = floor(n / 2)
		end


		bTempNegative = FALSE
		if This.IsNegative()
			if  @IsOdd(n)
				bTempNegative = TRUE
			ok
		else
			if n < 0
				bTempNegative = TRUE
			ok
		ok

		bTempSpace = @bSpacify

		This.Update(result)

		@bNegative = bTempNegative
		@bSpacify = bTempSpace

	  #--------------------------------------------------------------#
	 #  GETTING THE ABSOLUTE VALUE OF THE BIG NUMBER (IN A STRING)  #
	#--------------------------------------------------------------#

	def SAbs()
		if @bSpacify
			cValue = This.Spacified()
		else
			cValue = This.Unspacified()
		ok

		if This.IsNegative()
			cResult = substr(cValue, "-", "")
			return cResult
			
		else
			return cValue
		ok

		def Abs()
			return This.SAbs()

	  #-------------------------------------------------------#
	 #  COMPARING THE BIG NUMBER WITH AN OTHER (BIG) NUMBER  #
	#-------------------------------------------------------#

	def Compare(cOtherBigNumber)

		return This.pvtCompareEqualStrings(This.SValue(), cOtherBigNumber)

		def CompareWith(cOtherBigNumber)
			return This.Compare(cOtherBigNumber)


	  #------------------------------------------#
	 #  CHECKING IF THE BIG NUMBER IS NEGATIVE  #
	#------------------------------------------#

   	 def IsNegative() // #ai #chatgpt identified that I should be in uppercase!
        	return @bNegative

    	def SNegate()

        	if SValue() != "0"
            		@bNegative = not @bNegative
       		ok

       		return SValue()

		def Negate()
			return This.SNegate()

	  #-----------------------------------------#
	 #  CHECKING IF THE BIG NUMBER IS INTEGER  #
	#-----------------------------------------#

	def IsInt()

		cFract = trim(@cFractPart)

		if cFract = "" or cFract = '0'
			return TRUE
		else
			return FALSE
		ok

		def IsInteger()
			return This.IsInt()

	  #---------------------------------------#
	 #  GETTING THE ROUND OF THE BIG NUMBER  #
	#---------------------------------------#

	def Round()
		return @nPrecision

		def Precision()
			return @nPrecision

		def GetRound()
			return @nPrecision

		def GetPrecision()
			return @nPrecision

	  #--------------------------------------------------------------------#
	 #  GETTING THE VALUE OF THE BIG NUMBER ROUNDED TO A GIVEN PRECISION  #
	#--------------------------------------------------------------------#

	def RoundedTo(precision) #ai #claude #chatgpt #me

		if isString(precision)

			if precision = :Max
				precision = $BIG_NUMBER_MAX_PRECISION

			but precision = :Default or precision = ""
				precision = $BIG_NUMBER_DEFAULT_PRECISION

			else
				raise("ERR-" + StkError(:IncorrectParamValue))
			ok
		ok
	
		if not isNumber(precision)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		if precision > $BIG_NUMBER_MAX_PRECISION
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok
	
		if precision = 0 and This.IsInt()
			return This.SInt()
		ok
	
		fraction = @cFractPart
		intPart = @cIntPart # We need it without spacers
	
		# Case 1: Desired precision is higher than or equal to actual precision

		if len(fraction) <= precision

			if @bSpacify
				intPart = pvtSpacify(intPart, @cSpace, @nSpace)
			ok
	
			if @bNegative
				intPart = "-" + intPart
			ok
	
			result = intPart + "." + fraction + pvtCopy("0", precision - len(fraction))
	
			return result
		ok

		# Case 2: Desired precision is lower than actual precision
		# and the fraction part (up to the precision) is made of "9"s

		cFractPArt = left(fraction, precision)

		if precision > 0 and cFractPArt = pvtCopy("9", precision)

			intPart = pvtAddOneToIntPart()

			if @bSpacify
				intPart = pvtSpacify(intPart, @cSpace, @nSpace)
			ok

			if @bNegative
				intPart = "-" + intPart
			ok
			
			result = intPart + "." + pvtCopy("0", precision)

			return result
		ok

		# Case 3: Desired precision is lower than actual precision
		# and the fract part (upto the precision) is not made of "9"s

		result = cFractPArt
		nextDigit = 0 + pvtMid(fraction, precision + 1, 1)
	
		if nextDigit >= 5

			carry = 1

			# Start from the end of the result and handle carry-over

			for i = precision to 1 step -1

				digit = 0 + pvtMid(result, i, 1)

				if digit < 9

					result = left(result, i-1) + ("" + (digit + carry))
					carry = 0
					break

				else
					result = left(result, i-1) + "0"

				ok
			next
	
			# Handle the case where carry results in extra digit

			if carry > 0 # carry is equal to 1
	
				# Increment the integer part and reset the fractional part
	
				if @bNegative
					intPart = pvtSubtractOneFromIntPart()
				else
					intPart = pvtAddOneToIntPart()
				ok
	
				result = pvtCopy("0", precision)
			ok
		ok

		if @bSpacify
			intPart = pvtSpacify(intPart, @cSpace, @nSpace)
		ok
		if @bNegative
			intPart = "-" + intPart
		ok
	
		if result = ""
			result = ""+ intPart + "." + pvtCopy("0", precision)
		else
			result = ""+ intPart + "." + result
		ok
		
		if precision = 0
			result = substr(result, ".", "")
		ok
	
		return result


		#< @FunctionAlternativeForms

		def Rounded(n)
			return This.RoundedTo(n)

		#>

	  #------------------------------------------------#
	 #  ROUNDING THE BIG NUMBER TO A GIVEN PRECISION  #
	#------------------------------------------------#

	def RoundTo(n)
		cRounded = This.RoundedTo(n)

		if isString(n)
			if n = :Max
				n = $BIG_NUMBER_MAX_PRECISION
			but n = :Default or n = ""
				n = $BIG_NUMBER_DEFAULT_PRECISION
			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok
		ok

		if not isNumber(n)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@nPrecision = n

		if substr(cRounded, ".") = 0
			@cIntPart = cRounded
			@cFractPart = ""
			
		else

			acSplits = split(cRounded, ".")
			@cIntPart = acSplits[1]
			@cFractPart = acSplits[2]
		ok


		#< @FunctionAlternativeForms

		def SetRound(n)
			This.RoundTo(n)

		def SetRoundTo(n)
			This.RoundTo(n)

		def SetPrecision(n)
			This.RoundTo(n)

		def SetPrecisionTo(n)
			This.RoundTo(n)

		#>

	#------------------------------------------#
	#  SPACIFYING THE BIG NUMBER STRING VALUE  #
	#------------------------------------------#

	def Spacify()
		@bSpacify = TRUE

	def Unspacify()
		@bSpacify = FALSE

	def IntPartSpacified()
		
		cResult = This.pvtSpacify(@cIntPart, @cSpace, @nSpace)
		if @bNegative
			cResult = "-" + cResult
		ok

		return cResult

		def SIntPartSpacified()
			return This.IntPartSpacified()

	def IntPartUnSpacified()

		cResult = @cIntPart
		if @bNegative
			cResult = "-" + cResult
		ok

		return cResult

		def SIntPartunSpacified()
			return This.IntPartUnSpacified()

	def Spacified()

		cResult = This.IntPartSpacified()

	        # Add the fractional part if it exists

		if @cFractPart != ""
			cResult += "." + @cFractPart
		ok

		return cResult

	def UnSpacified()
	
		cResult = @cIntPart
		if @bNegative
			cResult = "-" + cResult
		ok

	        # Add the fractional part if it exists

		if @cFractPart != ""
			cResult += "." + @cFractPart
		ok

		return cResult
	
	#--------------------------------#
	PRIVATE // KITCHEN OF THE CLASS  #
	#--------------------------------#

	#TODO
	# Study these helper functions and see which of them can
	# be promoted to be a common function

	# Helper function to spacify a number in string

	def pvtSpacify(str, cSpace, nSpace)
		if not (isString(str) and isString(cSpace) and isNumber(nSpace))
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		if not len(cSpace) = 1
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok

		str = trim(str)

		bNegative = FALSE
		if left(str, 1) = "-"
			bNegative = TRUE
		ok

		cResult = ""

	        nLen = len(str)
		if nLen <= nSpace
			return str
		ok

	        for i = nLen to 1 step -1

			cResult = str[i] + cResult

			if (nLen - i + 1) % nSpace = 0 and i != 1
				cResult = cSpace + cResult
			ok

	        next
	
	        # Add the sign back

		if bNegative
	        	cResult = "-" + cResult
		ok

		return cResult

	# Helper function to add one to the integer part
	
	def pvtAddOneToIntPart()

		intPart = @cIntPart	// #Warining Don't use IntPart() ~> may be spaciefied
		length = len(intPart)
		carry = 1
		newIntPart = ""
	
		for i = length to 1 step -1
	
			digit = 0 + pvtMid(intPart, i, 1)
	
		        if digit + carry = 10
				newIntPart = "0" + newIntPart
				carry = 1
		        else
				newIntPart = ("" + (digit + carry)) + newIntPart
				carry = 0
		        ok
	
		next
	
		if carry > 0
			newIntPart = "1" + newIntPart
		ok
	
		return newIntPart

	# Helper function to subtract one from the integer part

	def pvtSubtractOneFromIntPart()
   
		intPart = @cIntPart
		carry = 1
		newIntPart = ""
	    
		// Iterate over the digits of the integer part from right to left
	
		for i = len(intPart) to 1 step -1
	
			digit = 0 + pvtMid(intPart, i, 1)
	        
			if carry = 1
				if digit > 0
					digit -= 1
					carry = 0
				else
					digit = 9
				ok
			ok
	        
			newIntPart = ("" + digit) + newIntPart
		next
    
		// Handle the case where the integer part was "-1" and needs to become "-2", etc.

		if carry = 1
			newIntPart = "-" + pvtSubtractOne(newIntPart)

		else
			newIntPart = This.pvtTrimLeadingZeros(newIntPart)
		ok

		return newIntPart


	# Two helper functions to perform addition

   	def pvtAddStrings(s1, s2) #ai #claude

	        result = ""
	        carry = 0
	
	        maxLen = This.pvtMax(len(s1), len(s2))
	        s1 = This.pvtPadLeft(s1, maxLen, "0")
	        s2 = This.pvtPadLeft(s2, maxLen, "0")
	        
	        for i = maxLen to 1 step -1

			sum = 0+ (s1[i]) + s2[i] + carry
			result = "" + (sum % 10) + result
			carry = floor(sum / 10)

	        next
	 
	        if carry > 0
			result = ""+ carry + result
	        ok
	        
	        return result

	def pvtAddDecimalStrings(s1, s2) #ai #claude

	        n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)

	        maxFracLen = This.pvtMax(len(n1.@cFractPart), len(n2.@cFractPart))
	        n1Padded   = This.pvtPadRight(n1.@cIntPart + n1.@cFractPart, len(n1.@cIntPart) + maxFracLen, "0")
	        n2Padded   = This.pvtPadRight(n2.@cIntPart + n2.@cFractPart, len(n2.@cIntPart) + maxFracLen, "0")
	        
	        sum = This.pvtAddStrings(n1Padded, n2Padded)
	        
	        if len(sum) > maxFracLen
			intPart = left(sum, len(sum) - maxFracLen)
			fracPart = right(sum, maxFracLen)

	        else
			intPart = "0"
			fracPart = This.pvtPadLeft(sum, maxFracLen, "0")
	        ok
	        
	        cResult = This.pvtTrimTrailingZeros(intPart + "." + fracPart)
		return cResult

	# Two helper functions to perform multiplication

	def pvtMultiplyDecimalStrings(s1, s2) #ai #claude

		n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)

	        fracLen1 = len(n1.@cFractPart)
	        fracLen2 = len(n2.@cFractPart)
	        
	        int1 = n1.@cIntPart + n1.@cFractPart
	        int2 = n2.@cIntPart + n2.@cFractPart
       
	        product = This.pvtKaratsubaMultiply(int1, int2)
	        totalFracLen = fracLen1 + fracLen2
	        
	        if len(product) > totalFracLen
			intPart = left(product, len(product) - totalFracLen)
			fracPart = right(product, totalFracLen)

	        else
			intPart = "0"
			fracPart = This.pvtPadLeft(product, totalFracLen, "0")
	        ok
	        
	        return This.pvtTrimTrailingZeros(This.pvtTrimLeadingZeros(intPart) + "." + fracPart)

	# A specital algorithm efficient for multiplying large big numbers

   	def pvtKaratsubaMultiply(x, y) #ai #claude

	        # If the numbers are relatively small, opt for normal multiplication

	        if len(x) < 10 or len(y) < 10

		        cResult = This.pvtMultiplyStringsDigitByDigit(x, y)
		        return cResult
	        ok

		# Otherwise, use the Karatsuba algorithm

	        m = pvtMin(len(x), len(y))
	        m2 = floor(m / 2)
	
	        # Split the digit sequences about the middle

	        high1 = left(x, len(x) - m2)
	        low1  = right(x, m2)
	        high2 = left(y, len(y) - m2)
	        low2  = right(y, m2)

	        # 3 recursive calls made to numbers approximately half the size

	        z0 = This.pvtKaratsubaMultiply(low1, low2)
	        z1 = This.pvtKaratsubaMultiply(pvtAddStrings(low1, high1), pvtAddStrings(low2, high2))
	        z2 = This.pvtKaratsubaMultiply(high1, high2)

	        cResult = This.pvtAddStrings(
			This.pvtAddStrings(
				This.pvtShiftLeft(z2, 2*m2),
				This.pvtShiftLeft(This.pvtSubtractStrings(This.pvtSubtractStrings(z1, z2), z0), m2)
			),
			z0
	        )

		return cResult

	# Helper function to multiply integer strings directly, digit by digit
	
	def pvtMultiplyStringsDigitByDigit(x, y) // #ai #chatgpt
	
		lenX = len(x)
		lenY = len(y)
	
	    	# Initialize the result array with zeros
	
		result = pvtArray(lenX + lenY, "0")
	
		# Reverse the strings to simplify multiplication
	
		x = reverse(x)
		y = reverse(y)
	
		for i = 1 to lenX
	
			carry = 0
	
			for j = 1 to lenY
	
				# Multiply digit by digit and add to the result
	
				product = (0 + pvtMid(x, i, 1)) * (0 + pvtMid(y, j, 1)) + (0 + result[i + j - 1]) + carry
				result[i + j - 1] = "" + (product % 10)
				carry = floor(product / 10)
	
			next
	
			result[i + lenY] = "" + (carry)
	
		next
	
		# Reverse result to get the final product and remove leading zeros
	
		result = reverse(pvtJoin(result, ""))
		result = This.pvtTrimLeadingZeros(result)
	
		# Handle the case where the result is zero
	
		if result = ""
			result = "0"
		ok
	
		return result

	# Helper function to create an array (list) with a given size and initial value
	
	def pvtArray(size, value) // #ai #chatgpt
	
		result = []
	
		for i = 1 to size
			result + value
		next
	
		return result

	# Helper function to extract a substring from a string
	
	def pvtMid(string, start, length) // #ai #chatgpt
	
		# Extract a substring from the string
		# Since Ring uses 1-based indexing, we'll adjust for that
	
		startIndex = start
		endIndex = start + length - 1
		result = ""
	    
		for i = startIndex to endIndex
			if i <= len(string)
				result += string[i]
			ok
		next
	    
		return result

	# Helper function to join a list of strings with a separator
	
	def pvtJoin(list, separator) // #ai #chatgpt
	
		result = ""
	
		for i = 1 to len(list)
	
			if i > 1
				result += separator
			ok
	
			result += list[i]
		next
	
		return result

	# Helper function to perform division

	def pvtDivideDecimalStrings(s1, s2) #ai #claude #chatgpt

		n1 = new stkBigNumber(s1)
	    	n2 = new stkBigNumber(s2)
	    
	    	# Align decimal points and prepare for division

	    	decimalShift = max(len(n1.@cFractPart), len(n2.@cFractPart))
	    	intPart1 = n1.@cIntPart + n1.@cFractPart + pvtCreateZeros(decimalShift - len(n1.@cFractPart))
	   	intPart2 = n2.@cIntPart + n2.@cFractPart + pvtCreateZeros(decimalShift - len(n2.@cFractPart))
	    
	   	 # Ensure that intPart2 is not "0" to avoid infinite loops or division by zero

	    	if intPart2 = "0"
	        	raise("ERR-DivisionByZero")
	    	ok
	    
	    	# Perform long division

		quotient = ""
		remainder = "0"
		dividendIndex = 1
		decimalPointInserted = false
		nLength = len(intPart1)
		maxPrecision = $BIG_NUMBER_DEFAULT_PRECISION  # Adjust this for desired precision
		    
	   	while true

	        	# Add the next digit to the remainder

	        	if dividendIndex <= nLength
	            		remainder += substr(intPart1, dividendIndex, 1)
	            		dividendIndex++
	        	else
	            		remainder += "0"
	       		 ok
	        
	        	# Normalize remainder by removing leading zeros

	      		remainder = pvtTrimLeadingZeros(remainder)
	        
			# Calculate quotient digit

			digit = 0

		        while pvtCompareEqualStrings(remainder, intPart2) >= 0
		            	remainder = pvtSubtractStrings(remainder, intPart2)
		            	digit++
		        end

	       		quotient += "" + digit
	        
	       		# Insert decimal point if needed

		        if dividendIndex > nLength and not decimalPointInserted
				quotient += "."
				decimalPointInserted = true
		        ok
	        
	       		# Stop if we've reached desired precision after decimal point

		        if decimalPointInserted and len(substr(quotient, substr(quotient, ".") + 1)) >= maxPrecision
		            	break
		        ok
	        
	        	# Stop if the quotient becomes too long (as a safeguard)

		        if len(quotient) > 100
		            	break
		        ok
	   	end
	    
	   	# Trim trailing zeros in the fractional part

	    	return pvtTrimTrailingZeros(quotient)

	# Helper function to compare two numbers in strings



# Helper function to pad with zeros after decimal point
func pvtPadFraction(str, length)
    nLen = len(str)

    if nLen < length
	str += pvtCopy("0", (length - nLen))
    ok
    return str

# Function to subtract two big numbers represented as strings
func pvtSubtractStrings(nbr1, nbr2)
? "emm"
    nbr1 = substr(nbr1, "_", "")
    nbr2 = substr(nbr2, "_", "")

    # Handle negative numbers
    if left(nbr1, 1) = "-" and left(nbr2, 1) != "-"
        return "-" + pvtAddStrings(right(nbr1, len(nbr1)-1), nbr2)

    but left(nbr1, 1) != "-" and left(nbr2, 1) = "-"
        return pvtAddStrings(nbr1, right(nbr2, len(nbr2)-1))

    but left(nbr1, 1) = "-" and left(nbr2, 1) = "-"
        return pvtSubtractStrings(right(nbr2, len(nbr2)-1), right(nbr1, len(nbr1)-1))
    ok

    # Split numbers into integer and fractional parts
    parts1 = substr(nbr1, ".")
    parts2 = substr(nbr2, ".")
    
    if parts1 > 0
        int1 = left(nbr1, parts1-1)
        frac1 = right(nbr1, len(nbr1) - parts1)
    else
        int1 = nbr1
        frac1 = ""
    ok
    
    if parts2 > 0
        int2 = left(nbr2, parts2-1)
        frac2 = right(nbr2, len(nbr2) - parts2)
    else
        int2 = nbr2
        frac2 = ""
    ok

//? int1 + " : " + frac1
//? int2 + " : " + frac2 + NL
    # Ensure int1 is not smaller than int2
    if pvtCompareStrings(int1, int2) = 1
        return "-" + pvtSubtractStrings(nbr2, nbr1)
    ok

    # Pad fractional parts to equal length
    maxFracLen = pvtMax(len(frac1), len(frac2))
    frac1 = pvtPadFraction(frac1, maxFracLen)
    frac2 = pvtPadFraction(frac2, maxFracLen)

    # Pad int2 with leading zeros to match length of int1
    int2 = pvtCopy("0", len(int1) - len(int2)) + int2

//? int1 + " : " + frac1
//? int2 + " : " + frac2 + nl


    borrow = 0
    resultInt = ""
    resultFrac = ""

    # Subtract fractional parts
    for i = len(frac1) to 1 step -1

        digit1 = 0+ frac1[i]

        if i <= len(frac2)
            digit2 = 0+ frac2[i]
        else
            digit2 = 0
        ok

        digit1 -= borrow

        if digit1 < digit2
            digit1 += 10
            borrow = 1

        else
            borrow = 0
        ok

        resultFrac = ""+ (digit1 - digit2) + resultFrac

    next

    # Subtract integer parts

    for i = len(int1) to 1 step -1
        digit1 = 0+ int1[i]
        if i <= len(int2)
            digit2 = 0+ int2[i]
        else
            digit2 = 0
        ok
        digit1 -= borrow
        if digit1 < digit2
            digit1 += 10
            borrow = 1
        else
            borrow = 0
        ok
        resultInt = ""+ (digit1 - digit2) + resultInt
    next

    # Combine results and clean up
    result = pvtTrimLeadingZeros(resultInt)
    if len(resultFrac) > 0
        result += "." + resultFrac
    ok
    result = pvtTrimTrailingZeros(result)

    return result


###############################

# Helper function to compare two strings of equal length
def pvtCompareSameSizeStrings(str1, str2)
    for i = 1 to len(str1)
        if ascii(str1[i]) > ascii(str2[i])
            return 1
        but ascii(str1[i]) < ascii(str2[i])
            return -1
        ok
    next
    return 0  # If we get here, the strings are equal

# Main function to compare big numbers
func pvtCompareStrings(str1, str2)
? "hi"
    # Remove leading and trailing zeros
    str1 = pvtTrimLeadingZeros(pvtTrimTrailingZeros(str1))
    str2 = pvtTrimLeadingZeros(pvtTrimTrailingZeros(str2))
    
    # Check for negative numbers
    isNegative1 = (left(str1, 1) = "-")
    isNegative2 = (left(str2, 1) = "-")
    
    # If signs are different, we can immediately determine the result
    if isNegative1 and !isNegative2
        return -1
    elseif !isNegative1 and isNegative2
        return 1
    ok
    
    # Remove minus signs for further processing
    if isNegative1
        str1 = right(str1, len(str1) - 1)
    ok
    if isNegative2
        str2 = right(str2, len(str2) - 1)
    ok
    
    # Split into integer and fractional parts
    parts1 = substr(str1, ".")
    parts2 = substr(str2, ".")
    
    int1 = str1
    int2 = str2
    frac1 = ""
    frac2 = ""
    
    if parts1 > 0
        int1 = left(str1, parts1-1)
        frac1 = right(str1, len(str1) - parts1)
    ok
    if parts2 > 0
        int2 = left(str2, parts2-1)
        frac2 = right(str2, len(str2) - parts2)
    ok
    
    # Compare integer parts
    if len(int1) != len(int2)
        if len(int1) > len(int2)
		result = 1
	else
		result = -1
	ok
    else
        result = pvtCompareSameSizeStrings(int1, int2)
    ok
    
    # If integer parts are equal, compare fractional parts
    if result = 0 and (len(frac1) > 0 or len(frac2) > 0)
        # Pad shorter fractional part with zeros
        maxFracLen = max(len(frac1), len(frac2))
        frac1 = frac1 + copy("0", maxFracLen - len(frac1))
        frac2 = frac2 + copy("0", maxFracLen - len(frac2))
        result = pvtCompareSameSizeStrings(frac1, frac2)
    ok
    
    # If numbers were negative, reverse the result
    if isNegative1
        result = -result
    ok
? result
    return result


##############################



	# Two helper functions to compare absolute values

	def pvtCompareAbsValues(s1, s2) #ai #claude

	        n1 = new stkBigNumber(This.pvtSAbs(s1))
	        n2 = new stkBigNumber(This.pvtSAbs(s2))
		        
	        if n1.@cIntPart != n2.@cIntPart

	            return len(n1.@cIntPart) - len(n2.@cIntPart) or 
	                   This.pvtCompareEqualStrings(n1.@cIntPart, n2.@cIntPart)

	        ok
		        
	        return This.pvtCompareEqualStrings(n1.@cFractPart, n2.@cFractPart)
	
	def pvtSAbs(s) #ai #claude

	        if left(s, 1) = "-"
			s = substr(s, "-", "")
	        ok

	        return s

	# Helper function to Trim zeros from left

    	def pvtTrimLeadingZeros(s) #ai #claude

	        while TRUE

			if NOT (left(s, 1) = "0" and len(s) > 1)
				exit
			ok
	
	            	s = substr(s, 2)
	        end
	
	        return s

	# Helper function to Trim zeros at the end

	def pvtTrimTrailingZeros(s) #ai #claude
	
		while TRUE

			nLen = len(s)

			if nLen < 0
				exit
			ok
		
			if right(s, 1) != "0"
				exit
			ok
		
			s = left(s, nLen - 1)
	        end
		
		if right(s, 1) = "."
			s = left(s, nLen - 1)
		ok
			
	        return s
	
	# Helper function to pad n chars to the left of a given string

 	def pvtPadLeft(s, n, char) #ai #claude

	       	while len(s) < n
	        	s = char + s
	        end

	        return s

	# Helper function to pad n chars to the right of a given string

	def pvtPadRight(s, n, char) #ai #claude

	        while len(s) < n
	            	s = s + char
	        end

	        return s

	# Helper function to shif n chars left of a given string

    	def pvtShiftLeft(s, n) #ai #claude

        	return s + This.pvtCopy("0", n)
	
 	# Helper function to duplicate a char n times
	
	def pvtCopy(s, n) #ai #claude

		result = ""
		
		        for i = 1 to n
				result += s
		        next
		
		        return result
	
	# Helper function to get the min of two numbers

	def pvtMin(a, b) #ai #claude
		
	        if a < b
			return a
	        else
			return b
	        ok

	# Helper function to get the max of two numbers

	def pvtMax(a, b) #ai #claude

	        if a < b
			return b
	        else
			return a
	        ok

	# Helper function to append a string with n zeros

	def pvtAppendZeros(str, n) #ai #claude

		for i = 1 to n
			str += "0"
		next

	    	return str

	# Helper function to create a string of zeros

	def pvtCreateZeros(n) #ai #claude

		result = ""
	
	    	for i = 1 to n
	        	result += "0"
	    	next
	
	    	return result
