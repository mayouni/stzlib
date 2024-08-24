
# NOTE: this class was made in collaboration between me, ClaudeAI and ChatGPT.

$BIG_NUMBER_MAX_PRECISION = 28
$BIG_NUMBER_DEFAULT_PRECISION = 6

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

	  #-------------------------------------------------------#
	 #  INITIALIZING THE BIG NUMBER FROM A NUMBER IN STRING  #
	#-------------------------------------------------------#

    	def init(cValue)
	       This.Update(cValue)

		# Storing the full precision of the number
		# We need it if SetPrecision(n) is used with n > @nPrecision

		@cFullFractPart = @cFractPart
		@nFullPrecision = @nPrecision

	  #-----------------------------------------------------------------#
	 #  GETTING THE VALUE OF THE BIG NUMBER AND ITS PARTS (IN STRING)  #
	#-----------------------------------------------------------------#

   	def Value()

        	result = @cIntPart

	        if @cFractPart != ""
	            result += "." + @cFractPart
	        ok

	        if @bIsNegative and result != "0"
	            result = "-" + result
	        ok

	        return result

		def SValue()
			return This.Value()

		def Content()
			return This.Value()

	def IntPart()
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

	  #--------------------------------------------------------------#
	 #  UPDATING THE BIG NUMBER WITH A NUMBER PROVIDED AS A STRING  #
	#--------------------------------------------------------------#

	func Update(cNumberInStr)

 		if not isString(cNumberInStr)
	            	raise("ERR-" + StkError(:IncorrectParamType))
	        ok

		cNumberInStr = trim( substr(cNumberInStr, "_", "") )

		if not isNumber(0+ cNumberInStr)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

	        @bIsNegative = (left(cNumberInStr, 1) = "-")

	        if @bIsNegative
	            	cNumberInStr = substr(cNumberInStr, "-", "")
	        ok
	        
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

	  #------------------------------------------------------------#
	 #  ADDING A NUMBER IN STRING (BIG OR NOT) TO THE BIG NUMBER  #
	#------------------------------------------------------------#

    	def Add(cOtherBigNumber)

		oOtherBigNumber = new stkBigNumber(cOtherBigNumber)

	        if @bIsNegative = oOtherBigNumber.isNegative()
	        	cResult = This.pvtAddDecimalStrings(SValue(), oOtherBigNumber.SValue())

	        else
		
			cResult = This.pvtSubtractDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())

			if @bIsNegative and This.pvtCompareAbsValues(This.SValue(), oOtherBigNumber.SValue()) > 0
				@bIsNegative = TRUE
			else
				@bIsNegative = FALSE
	            	ok

	        ok

		# Updating the big number with the result

		This.Update(cResult)


		#< @FunctionAlternativeForm

		def SAdd(cOtherBigNumber)
			This.Add(cOtherBigNumber)

		#>

	  #-------------------------------------------------------------------#
	 #  SUBTRACTING A NUMBER IN STRING (BIG OR NOT) FROM THE BIG NUMBER  #
	#-------------------------------------------------------------------#

    	def Subtract(cOtherBigNumber)

		oOtherBigNumber = new stkBigNumber(cOtherBigNumber)
	        oOtherBigNumber.SNegate()	
	        This.SAdd(oOtherBigNumber.SValue())

		def SSubtract(cOtherBigNumber)
			This.Subtract(cOtherBigNumber)


	  #-------------------------------------------------------------------#
	 #  MULTIPLYING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#-------------------------------------------------------------------#

   	 def Multiply(cOtherBigNumber)

	   	oOtherBigNumber = new stkBigNumber(cOtherBigNumber)
	        cResult = This.pvtMultiplyDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())
	
	        if @bIsNegative != oOtherBigNumber.isNegative() and result != "0"
			@bIsNegative = TRUE
		else
			@bIsNegative = FALSE
	        ok

		# Updating the big number with the result

		This.Update(cResult)


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
	    	cResult = pvtDivideDecimalStrings(This.SAbs(), oOtherBigNumber.SAbs())
	    
		# Updating the big number with the result

		This.Update(cResult)


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

   	 def isNegative()
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

	def RoundedTo(precision) #ai #claude #me
	    	
	   	if not isNumber(precision)
	        	raise("ERR-" + StkError(:IncorrectParamType))
	   	ok

		if precision = 0 and This.IsInt()
			return This.SInt()
		ok

		fraction = @cFractPart

	    	if len(fraction) <= precision
			result = This.IntPart() + "." + fraction + pvtCopy("0", precision - len(fraction))
	        	return result
	   	 ok
	    
	    	result = left(fraction, precision)
	    	nextDigit = 0 + substr(fraction, precision + 1, 1)
	    
	    	if nextDigit >= 5
	        	for i = precision to 1 step -1
	            		digit = 0 + substr(result, i, 1)
	            		if digit < 9
	                		result = left(result, i-1) + ("" + (digit + 1))
	                		exit
	           		else
	                		result = left(result, i-1) + "0"
	                		if i = 1
	                    			result = "1" + result
	                		ok
	            		ok
	       		next
	    	ok

		if result = ""
			cRoundedTo1 = This.RoundedTo(1)
			nDotPos = substr(cRoundedTo1, ".")
			if nDotPos > 0
				nDigit = 0+ cRoundedTo1[nDotPos+1]
				if nDigit > 5
					nIntPart = 0+ @cIntPart
					nIntPart++
					cIntPart = ""+ nIntPart
					if This.IsNegative
						result = "-" + cIntPart
					else
						result = cIntPart
					ok
				ok
			ok

		else
			result = This.IntPart() + "." + result
		ok

	    	return result

		def Rounded(n)
			return This.RoundedTo(n)

	def RoundTo(n)
		cRounded = This.RoundedTo(n)
		if substr(cRounded, ".") = 0
			return
		else
			@cFractPart = split(cRounded, ".")[2]
			@nPrecision = len(@cFractPart)
		ok

	#--------------------------------#
	PRIVATE // KITCHEN OF THE CLASS  #
	#--------------------------------#

	# Two helper functions to perform addition

   	func pvtAddStrings(s1, s2) #ai #claude
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

	func pvtAddDecimalStrings(s1, s2) #ai #claude

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

   	 func pvtSubtractStrings(s1, s2) #ai #claude

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

   	 func pvtSubtractDecimalStrings(s1, s2) #ai #claude

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

	func pvtMultiplyDecimalStrings(s1, s2) #ai #claude

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

   	func pvtKaratsubaMultiply(x, y) #ai #claude

	        # Base case for recursion

	        if len(x) < 10 or len(y) < 10
	            return ""+ ( (0+ x) * (0+ y))
	        ok
	
	        m = min(len(x), len(y))
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
	
	        return This.pvtAddStrings(
	            This.pvtAddStrings(
	                This.pvtShiftLeft(z2, 2*m2),
	                This.pvtShiftLeft(This.pvtSubtractStrings(This.pvtSubtractStrings(z1, z2), z0), m2)
	            ),
	            z0
	        )

	# Helper function to perform division

	func pvtDivideDecimalStrings(s1, s2) #ai #claude #chatgpt

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

	# Helper function to compare two strings

    	func pvtCompareStrings(s1, s2) #ai #claude

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

	func pvtCompareAbsValues(s1, s2) #ai #claude

	        n1 = new stkBigNumber(This.pvtSAbs(s1))
	        n2 = new stkBigNumber(This.pvtSAbs(s2))
		        
	        if n1.@cIntPart != n2.@cIntPart
	            return len(n1.@cIntPart) - len(n2.@cIntPart) or 
	                   This.pvtCompareStrings(n1.@cIntPart, n2.@cIntPart)
	        ok
		        
	        return This.pvtCompareStrings(n1.@cFractPart, n2.@cFractPart)
	
	func pvtSAbs(s) #ai #claude
	        if left(s, 1) = "-"
	            s = substr(s, "-", "")
	        ok
	        return s

	# Helper function to strip zeros from left

    	func pvtStripLeadingZeros(s) #ai #claude
	        while TRUE
			if NOT (left(s, 1) = "0" and len(s) > 1)
				exit
			ok
	
	            	s = substr(s, 2)
	        end
	
	        return s

	# Helper function to strip zeros at the end

	func pvtStripTrailingZeros(s) #ai #claude
	
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

 	func pvtPadLeft(s, n, char) #ai #claude

	       	while len(s) < n
	        	s = char + s
	        end
	        return s

	# Helper function to pad n chars to the right of a given string

	func pvtPadRight(s, n, char) #ai #claude

	        while len(s) < n
	            	s = s + char
	        end
	        return s

	# Helper function to shif n chars left of a given string

    	func pvtShiftLeft(s, n) #ai #claude

        	return s + This.pvtCopy("0", n)
	
 	# Helper function to duplicate a char n times
	
	func pvtCopy(s, n) #ai #claude

		result = ""
		
		        for i = 1 to n
		            result += s
		        next
		
		        return result
	
	# Helper function to get the min of two numbers

	func pvtMin(a, b) #ai #claude
		
	        if a < b
	            return a
	        else
	            return b
	        ok

	# Helper function to get the max of two numbers

	func pvtMax(a, b) #ai #claude

	        if a < b
	            return b
	        else
	            return a
	        ok

	# Helper function to append a string with n zeros

	func pvtAppendZeros(str, n) #ai #claude

		for i = 1 to n
			str += "0"
		next
	    	return str

	# Helper function to create a string of zeros

	func pvtCreateZeros(n) #ai #claude

		result = ""
	
	    	for i = 1 to n
	        	result += "0"
	    	next
	
	    	return result
