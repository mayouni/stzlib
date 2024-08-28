
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
	@bIsNegative

	@cFullFractPart
	@nFullPrecision

	@cFractPart
	@nPrecision

	@bSpace = FALSE
	@nSpace = 3
	@cSpace = "_"

	  #-------------------------------------------------------#
	 #  INITIALIZING THE BIG NUMBER FROM A NUMBER IN STRING  #
	#-------------------------------------------------------#

    	def init(cValue)
	       This.Update(cValue)

		# Storing the full precision of the number
		# We need it if SetPrecision(n) is used with n > @nPrecision

		@cFullFractPart = @cFractPart
		@nFullPrecision = @nPrecision

	  #--------------------------------------------------------------#
	 #  UPDATING THE BIG NUMBER WITH A NUMBER PROVIDED AS A STRING  #
	#--------------------------------------------------------------#

	func Update(cNumberInStr)

		# The object is set using a string

 		if not isString(cNumberInStr)
	            	raise("ERR-" + StkError(:IncorrectParamType))
	        ok

		# Checking if the number is spacified (using "_")
		# and if so, keeping this feature avtive

		cNumberInStr = trim(cNumberInStr)
		nUnderscore = substr(cNumberInStr, "_")
		if nUnderscore = 0
			This.@bSpace = FALSE
		else
			This.@bSpace = TRUE
			cNumberInStr = substr(cNumberInStr, "_", "")
		ok

		# The string provided must contain a number

		if not isNumber(0+ cNumberInStr)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# Checking if the number is negative, and if so
		# keeping the info in the object

	        @bIsNegative = (left(cNumberInStr, 1) = "-")

	        if @bIsNegative
	            	cNumberInStr = substr(cNumberInStr, "-", "")
	        ok
	        
		# Splitting the number into parts, intpart and fractpart
		# (without potential sign if the number is negative)

	        acParts = split(cNumberInStr, ".")
	        @cIntPart = This.pvtStripLeadingZeros(acParts[1])

		@cFractPArt = ""
		@nPrecision = 0

	        if len(acParts) > 1
	            	@cFractPart = This.pvtStripTrailingZeros(acParts[2])
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
		if @bSpace = TRUE
			return This.IntPartSpacified()
		ok

		if This.IsNegative()
			return "-" + @cIntPart
		else
			return @cIntPart
		ok

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

        	result = @cIntPart

	        if @cFullFractPart != ""
	            result += "." + @cFullFractPart
	        ok

	        if @bIsNegative and result != "0"
	            result = "-" + result
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

		if @bSpace or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpace = TRUE
		ok

	        if This.IsNegative() = oOtherBigNumber.isNegative()
	        	cResult = This.pvtAddDecimalStrings(SValue(), oOtherBigNumber.SValue())

	        else
		
			cResult = This.pvtSubtractDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())

			if This.IsNegative() and This.pvtCompareAbsValues(This.SValue(), oOtherBigNumber.SValue()) > 0
				This.@bIsNegative = TRUE
			else
				This.@bIsNegative = FALSE
	            	ok

	        ok

		# Updating the big number with the result

		This.Update(cResult)

		if oOtherBigNumber.@bSpace = TRUE
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

		if This.pvtCompareStrings(This.SValue(), cOtherBigNumber) < 0

			This.@bIsNegative = TRUE
			oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

			if @bSpace or substr(cOtherBigNumber, "_") > 0
				oOtherBigNumber.@bSpace = TRUE
			ok

			oOtherBigNumber.Subtract(This.SValue())
			
		else

			oOtherBigNumber = new stkBigNumber(cOtherBigNumber)
		        oOtherBigNumber.SNegate()	

			if @bSpace or substr(cOtherBigNumber, "_") > 0
				oOtherBigNumber.@bSpace = TRUE
			ok

		        This.SAdd(oOtherBigNumber.SValue())
		ok

		if oOtherBigNumber.@bSpace = TRUE
			This.Spacify()
		ok

		def SSubtract(cOtherBigNumber)
			This.Subtract(cOtherBigNumber)


	  #-------------------------------------------------------------------#
	 #  MULTIPLYING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#-------------------------------------------------------------------#

   	 def Multiply(cOtherBigNumber)

	   	oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

		if @bSpace or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpace = TRUE
		ok

	        cResult = This.pvtMultiplyDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())

	        if ( (This.IsNegative() and NOT oOtherBigNumber.IsNegative()) or
		   (NOT This.IsNegative() and oOtherBigNumber.IsNegative()) ) and

 		   cResult != "0"

			cResult = "-" + cResult
		
	        ok

		# Updating the big number with the result

		This.Update(cResult)

		if oOtherBigNumber.@bSpace = TRUE
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

		if @bSpace or substr(cOtherBigNumber, "_") > 0
			oOtherBigNumber.@bSpace = TRUE
		ok

	    	cResult = pvtDivideDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())
	    
	        if ( (This.IsNegative() and NOT oOtherBigNumber.IsNegative()) or
		   (NOT This.IsNegative() and oOtherBigNumber.IsNegative()) ) and

 		   cResult != "0"

			cResult = "-" + cResult
		
	        ok

		# Updating the big number with the result

		This.Update(cResult)

		if oOtherBigNumber.@bSpace = TRUE
			This.Spacify()
		ok

		#< @FunctionAlternativeForm

		def SDivide(cOtherBigNumber, nPrecision)
			This.Divide(cOtherBigNumber, nPrecision)

		#>

	  #--------------------------------------------------------------#
	 #  GETTING THE ABSOLUTE VALUE OF THE BIG NUMBER (IN A STRING)  #
	#--------------------------------------------------------------#

	def SAbs()
		if This.IsNegative()
			cResult = substr(This.SValue(), "-", "")
			return cResult
			
		else
			return This.SValue()
		ok

	  #------------------------------------------#
	 #  CHECKING IF THE BIG NUMBER IS NEGATIVE  #
	#------------------------------------------#

   	 def IsNegative() // #ai #chatgpt identified that I should be in uppercase!
        	return @bIsNegative

    	def SNegate()

        	if SValue() != "0"
            		@bIsNegative = not @bIsNegative
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

	def RoundedTo(precision) #ai #claude #chatgpt

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
	    intPart = @cIntPart
	
	    # Case 1: Desired precision is higher than or equal to actual precision
	    if len(fraction) <= precision
	        result = intPart + "." + fraction + pvtCopy("0", precision - len(fraction))
	        return result
	    ok
	
	    # Case 2: Desired precision is lower than actual precision
	    result = left(fraction, precision)
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

		    if @bIsNegative
			intPart = pvtSubtractOneFromIntPart()
		    else
		   	intPart = pvtAddOneToIntPart()
		    ok

	            result = pvtCopy("0", precision)
	        ok
	    ok
	
	    # Construct final result

	    if @bSpace
	    	intPart = pvtSpacify(intPart, @cSpace, @nSpace)
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


	    def Rounded(n)
		return This.RoundedTo(n)

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
			@cFractPart = acSplits[2]
		ok

		def SetRound(n)
			This.RoundTo(n)

		def SetRoundTo(n)
			This.RoundTo(n)

		def SetPrecision(n)
			This.RoundTo(n)

		def SetPrecisionTo(n)
			This.RoundTo(n)

	#------------------------------------------#
	#  SPACIFYING THE BIG NUMBER STRING VALUE  #
	#------------------------------------------#

	def Spacify()
		@bSpace = TRUE

	def Unspacify()
		@bSpace = FALSE

	def IntPartSpacified()
		return This.pvtSpacify(@cIntPart, @cSpace, @nSpace)

		def SIntPartSpacified()
			return This.IntPartSpacified()

	def Spacified()

		cResult = This.IntPartSpacified()

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
        newIntPart = This.pvtStripLeadingZeros(newIntPart)
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
	        
	        cResult = This.pvtStripTrailingZeros(intPart + "." + fracPart)
		return cResult

	# Two helper functions to perform subtraction

   	 def pvtSubtractStrings(s1, s2) #ai #claude

	        result = ""
	        borrow = 0
	        maxLen = This.pvtMax(len(s1), len(s2))
	        s1 = This.pvtPadLeft(s1, maxLen, "0")
	        s2 = This.pvtPadLeft(s2, maxLen, "0")
	        
	        for i = maxLen to 1 step -1
	            diff = 0+ s1[i] - s2[i] - borrow

	            if diff < 0
	                diff += 10
	                borrow = 1

	            else
	                borrow = 0
	            ok

	            result = ""+ diff + result
	        next
	        
	        return This.pvtStripLeadingZeros(result)

   	 def pvtSubtractDecimalStrings(s1, s2) #ai #claude

	        n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)

	        maxFracLen = This.pvtMax(len(n1.@cFractPart), len(n2.@cFractPart))
	        n1Padded   = This.pvtPadRight(n1.@cIntPart + n1.@cFractPart, len(n1.@cIntPart) + maxFracLen, "0")
	        n2Padded   = This.pvtPadRight(n2.@cIntPart + n2.@cFractPart, len(n2.@cIntPart) + maxFracLen, "0")
	        
	        if pvtCompareAbsValues(s1, s2) < 0
	            diff = This.pvtSubtractStrings(n2Padded, n1Padded)
	            isNegative = true

	        else
	            diff = This.pvtSubtractStrings(n1Padded, n2Padded)
	            isNegative = false
	        ok
	        
	        diff     = This.pvtPadLeft(diff, len(n1Padded), "0")
	        intPart  = left(diff, len(diff) - maxFracLen)
	        fracPart = right(diff, maxFracLen)
	        
	        result = This.pvtStripLeadingZeros(intPart) + "." + This.pvtStripTrailingZeros(fracPart)

	        if isNegative and result != "0"
	            result = "-" + result
	        ok
	        
	        return result

	# Two helper functiions to perform multiplication

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
	        
	        return This.pvtStripTrailingZeros(This.pvtStripLeadingZeros(intPart) + "." + fracPart)

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
    result = This.pvtStripLeadingZeros(result)

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

	      		remainder = pvtStripLeadingZeros(remainder)
	        
			# Calculate quotient digit

			digit = 0

		        while pvtCompareStrings(remainder, intPart2) >= 0
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
	    
	   	# Strip trailing zeros in the fractional part

	    	return pvtStripTrailingZeros(quotient)

	# Helper function to compare two numbers in strings

    	def pvtCompareStrings(s1, s2) #ai #claude

	        maxLen = This.pvtMax(len(s1), len(s2))
	        s1 = This.pvtPadLeft(s1, maxLen, "0")
	        s2 = This.pvtPadLeft(s2, maxLen, "0")
		        
	        for i = 1 to maxLen
	            if s1[i] != s2[i]
	                return ascii(s1[i]) - ascii(s2[i])
	            ok
	        next
		        
	        return 0

	# Two helper functions to perform absolute values

	def pvtCompareAbsValues(s1, s2) #ai #claude

	        n1 = new stkBigNumber(This.pvtSAbs(s1))
	        n2 = new stkBigNumber(This.pvtSAbs(s2))
		        
	        if n1.@cIntPart != n2.@cIntPart
	            return len(n1.@cIntPart) - len(n2.@cIntPart) or 
	                   This.pvtCompareStrings(n1.@cIntPart, n2.@cIntPart)
	        ok
		        
	        return This.pvtCompareStrings(n1.@cFractPart, n2.@cFractPart)
	
	def pvtSAbs(s) #ai #claude
	        if left(s, 1) = "-"
	            s = substr(s, "-", "")
	        ok
	        return s

	# Helper function to strip zeros from left

    	def pvtStripLeadingZeros(s) #ai #claude
	        while TRUE
			if NOT (left(s, 1) = "0" and len(s) > 1)
				exit
			ok
	
	            	s = substr(s, 2)
	        end
	
	        return s

	# Helper function to strip zeros at the end

	def pvtStripTrailingZeros(s) #ai #claude
	
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
