
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

class stzBigNumber
	@cIntPart
	@bNegative

	@cFullFractPart
	@nFullPrecision

	@cFracPart
	@nPrecision

	@bSpacify = FALSE
	@nSpace = 3
	@cSpace = "_"

	  #-------------------------------------------------------#
	 #  INITIALIZING THE BIG NUMBER FROM A NUMBER IN STRING  #
	#=======================================================#

    	def init(cValue)

		bSpacify = FALSE

		if ring_substr1(cValue, "_") > 0
			bSpacify = TRUE
		ok

		This.Update(cValue, bSpacify)

		# Storing the full precision of the number
		# We need it if SetPrecision(n) is used with n > @nPrecision

		@cFullFractPart = @cFracPart
		@nFullPrecision = @nPrecision

	  #--------------------------------------------------------------#
	 #  UPDATING THE BIG NUMBER WITH A NUMBER PROVIDED AS A STRING  #
	#==============================================================#

	func Update(cNumberInStr, bSpacify)

		@bNegative = FALSE

		# The object is set using a string

 		if not isString(cNumberInStr)
	            	raise("ERR-" + StkError(:IncorrectParamType))
	        ok

		# Cleansing the string form leading and trailing spaces

		cNumberInStr = trim(cNumberInStr)

		# If the new number is spacified then store that info and unspaicify it

		if ring_substr1(cNumberInStr, "_") > 0
			@bSpacify = TRUE
			cNumberInStr = ring_substr2(cNumberInStr, "_", "")
		ok

		# The string must contain a valid number

		if not isNumber(0+ cNumberInStr)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# If the new number is negative, then remove the negative sign

		if left(cNumberInStr, 1) = "-"
			@bNegative = TRUE
	       		cNumberInStr = ring_substr2(cNumberInStr, "-", "")
	        ok

		# Splitting the number into 2 parts, intpart and fractpart

	        acParts = split(cNumberInStr, ".")
	        @cIntPart = This.pvtTrimLeadingZeros(acParts[1])

		@cFracPart = ""
		@nPrecision = 0

	        if len(acParts) > 1
	            	@cFracPart = This.pvtTrimTrailingZeros(acParts[2])
			@nPrecision = len(@cFracPart)
	        ok
	        
	        if @cIntPart = "" and
		   @cFracPart = ""

	           	@cIntPart = "0"
	        ok

		# If the big number has a higer percision than
		# the allowed $BIG_NUMBER_MAX_PRECISION, let
		# the max precision be the full precision

		# ~> As a corollary of this, the provided number
		# is rounded to the maximum allowed precision

		if @nPrecision > $BIG_NUMBER_MAX_PRECISION
			This.RoundTo($BIG_NUMBER_MAX_PRECISION)
			@cFullFractPart = @cFracPart
			@nFullPrecision = @nPrecision
		ok

	  #-----------------------------------------------------------------#
	 #  GETTING THE VALUE OF THE BIG NUMBER AND ITS PARTS (IN STRING)  #
	#=================================================================#

   	def Value()

        	result = This.IntPart() #NOTE may be spacified

	        if @cFracPart != ""
	            result += "." + @cFracPart
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
		return @cFracPart

		def Fract()
			return @cFracPart

		def SFractPart()
			return @cFracPart

		def SFract()
			return @cFracPart

	  #------------------------------------------------------------------------------#
	 #  GETTING THE INITIAL FULL VALUE OF THE BIG NUMBER AND ITS PARTS (IN STRING)  #
	#==============================================================================#
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
			return @nFullPrecision

	  #-------------------------------------------------#
	 #  RESTORING THE INITIAL VALUE OF THE BIG NUMBER  #
	#-------------------------------------------------#

	def Restore()
		@cFracPart = @cFullFractPart
		@nPrecision = @nFullPrecision


	  #--------------------------------------------------------------#
	 #  GETTING THE ABSOLUTE VALUE OF THE BIG NUMBER (IN A STRING)  #
	#==============================================================#

	def SAbs()
		if @bSpacify
			cValue = This.Spacified()
		else
			cValue = This.Unspacified()
		ok

		if This.IsNegative()
			cResult = ring_substr2(cValue, "-", "")
			return cResult
			
		else
			return cValue
		ok

		def Abs()
			return This.SAbs()

	  #-------------------------------------------------------#
	 #  COMPARING THE BIG NUMBER WITH AN OTHER (BIG) NUMBER  #
	#=======================================================#

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

		cFract = trim(@cFracPart)

		if cFract = "" or cFract = '0'
			return TRUE
		else
			return FALSE
		ok

		def IsInteger()
			return This.IsInt()

	  #---------------------------------------#
	 #  GETTING THE ROUND OF THE BIG NUMBER  #
	#=======================================#

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

	def RoundedTo(precision) #chatgpt #me

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
	
		fraction = @cFracPart
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

		cFracPart = left(fraction, precision)

		if precision > 0 and cFracPart = pvtCopy("9", precision)

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

		result = cFracPart
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
			result = ring_substr2(result, ".", "")
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

		if ring_substr1(cRounded, ".") = 0
			@cIntPart = cRounded
			@cFracPart = ""
			
		else

			acSplits = split(cRounded, ".")
			@cIntPart = acSplits[1]
			@cFracPart = acSplits[2]
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
	#==========================================#

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

		if @cFracPart != ""
			cResult += "." + @cFracPart
		ok

		return cResult

	def UnSpacified()
	
		cResult = @cIntPart
		if @bNegative
			cResult = "-" + cResult
		ok

	        # Add the fractional part if it exists

		if @cFracPart != ""
			cResult += "." + @cFracPart
		ok

		return cResult


	  #------------------------------------------------------------#
	 #  ADDING A NUMBER IN STRING (BIG OR NOT) TO THE BIG NUMBER  #
	#------------------------------------------------------------#

    	def Add(cOtherNumber)

		#== PREPARING NUMBER FOR CALCULATION

		# Checking the param type (must be a string)

		if not isString(cOtherNumber)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# Checking spacification

		bSpace = FALSE
		if @bSpacify or ring_substr1(cOtherNumber, "_") > 0
			bSpace = TRUE
			cOtherNumber = ring_substr2(cOtherNumber, "_", "")
		ok

		# Checking the param value (must be a number in string)

		if not isNumber(0+ cOtherNumber)
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok

		# Trimming the number

		cOtherNumber = trim(cOtherNumber)

		# Checking sing

		bNegative2 = (left(cOtherNumber,1) = "-")

		# Trimming leading and trailing zeros

		cOtherNumber = pvtTrimZeros(cOtherNumber)
		nLenOtherNumber = len(cOtherNumber)

		# If negative, store the info and take absolute value

		if bNegative2
			cOtherNumber = right(cOtherNumber, nLenOtherNumber-1)
		ok

		#== GETTING THE INT AND FRAC PARTS OF THE TWO NUMBERS

		cInt1  = @cIntPart
		cFrac1 = @cFracPart

		nDot2 = ring_substr1(cOtherNumber, ".")
		cInt2  = cOtherNumber
		cFrac2 = ""

		bHasFrac = FALSE
		if nDot2 > 0
			bHasFrac = TRUE
			cInt2  = left(cOtherNumber, nDot2 - 1)
			cFrac2 = right(cOtherNumber, nLenOtherNumber - nDot2)
			cFrac2 = ring_substr2(cFrac2, ".", "") # to be safe
		ok
	
		nLenInt1 = len(cInt1)
		nLenInt2 = len(cInt2)
		nLenIntMax = pvtMax(nLenInt1, nLenInt2)

		nLenFrac1 = len(cFrac1)
		nLenFrac2 = len(cFrac2)
		nLenFracMax = pvtMax(nLenFrac1, nLenFrac2)

		#== DOING THE CALCULATION

		cResult = ""

		# CASE 1 : If the two numbers are positive ~> (subtraction)

		if !@bNegative and !bNegative2

			acPaddedLeft = pvtPadLeft(cInt1, cInt2)
			cInt1 = acPaddedLeft[1]
			cInt2 = acPaddedLeft[2]

			cIntSum  = pvtSumInts(cInt1, cInt2)

			if bHasFrac
				acPaddedRight = pvtPadRight(cFrac1, cFrac2)
				cFrac1 = acPaddedRight[1]
				cFrac2 = acPaddedRight[2]

				cFracSum = pvtSumInts(cFrac1, cFrac2)

				if len(cFracSum) > nLenFracMax
					cFracSum = right(cFracSum, nLenFracMax)
					cIntSum = pvtAddOne(cIntSum)
				ok
			ok

			cResult = cIntSum
			if bHasFrac
				cResult += "." + cFracSum
			ok

		# CASE 2 : if two numbers are negative ~> - (addition)

		but @bNegative and bNegative2

			cNumber1 = cInt1
			if cFrac1 != ""
				cNumber1 += "." + cFrac1
			ok

			cNumber2 = cInt2

			if cFrac2 != ""
				cNumber2 += "." + cFrac2
			ok

			oTempBig = new stzBigNumber(cNumber1)
			oTempBig.Add(cNumber2)
			cResult = "-" + oTempBig.SValue()

		# CASE 3 : if they have different signs ~> (subtraction)

		but !@bNegative and bNegative2
? "ici + -"
return

		but @bNegative and !bNegative2

? "ici - + "
return
		ok

		# Updating the number
		
		This.Update(cResult, bSpace)

def pvtPadLeft(cInt1, cInt2) # must be int, positive, unspacified

	nLen1 = len(cInt1)
	nLen2 = len(cInt2)
	cZeros = ""

	if nLen1 > nLen2
		for i = 1 to (nLen1 - nLen2)
			cZeros += "0"
		next
		cInt2 = cZeros + cInt2
	else
		for i = 1 to (nLen2 - nLen1)
			cZeros += "0"
		next
		cInt1 = cZeros + cInt1
	ok

	return [ cInt1, cInt2 ]

def pvtPadRight(cInt1, cInt2) # must be int, positive, unspacified

	nLen1 = len(cInt1)
	nLen2 = len(cInt2)
	cZeros = ""

	if nLen1 > nLen2
		for i = 1 to (nLen1 - nLen2)
			cZeros += "0"
		next
		cInt2 = cInt2 + cZeros
	else
		for i = 1 to (nLen2 - nLen1)
			cZeros += "0"
		next
		cInt1 = cInt1 + cZeros
	ok

	return [ cInt1, cInt2 ]

def pvtSumInts(cInt1, cInt2)

	nLen = len(cInt1)
	cResult = ""
	nRemains = 0

	for i = nLen to 1 step -1
		n1 = 0+ cInt1[i]
		n2 = 0+ cInt2[i]

		n = n1 + n2 + nRemains

		if n > 9
			nRemains = 1
		else
			nRemains = 0
		ok

		cResult += right( (""+ n), 1)
	next

	return reverse(cResult)

pvtAddOne(cNumber) # Must ba an int
	if not ( isString(cNumber) and isNumber(0+ cNumber) )
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	if ring_substr1(cNumber, ".") > 0
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	cNumber = ring_substr2(cNumber, "_", "")
	nLen = len(cNumber)

	cResult = ""
	nCarry = 1

	for i = nLen to 1 step -1
		nDigit = 0+ cNumber[i] + nCarry
	
		if nDigit = 10
			cResult = "0" + cResult
			nCarry = 1
		else
			cResult = ""+ nDigit + cResult
			nCarry = 0
		ok

	next

	if nCarry = 1
		cResult = "1" + cResult
	ok

	return cResult

	  #-------------------------------------------------------------------#
	 #  SUBTRACTING A NUMBER IN STRING (BIG OR NOT) FROM THE BIG NUMBER  #
	#-------------------------------------------------------------------#


	  #-------------------------------------------------------------------#
	 #  MULTIPLYING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#-------------------------------------------------------------------#

 
	  #-----------------------------------------------------------------#
	 #  DIVIDING THE BIG NUMBER WITH A NUMBER IN STRING (BIG OR NOT)  #
	#----------------------------------------------------------------#



	  #---------------------------------------------#
	 #  ELEVATION THE BIG NUMBER TO A GIVEN POWER  #
	#---------------------------------------------#


	  #-------------------------#
	 #  OPERATORS OVERLOADING  #
	#=========================#



	#--------------------------------#
	PRIVATE // KITCHEN OF THE CLASS  #
	#================================#

	#TODO
	# Study these helper functions and see which of them can
	# be promoted to be a common function

	# Helper function to spacify a number in string
	/*
	pvtSpacify(cStr, cSpace, nSpace)
	pvtAddOne(cNbrInStr)
	pvtMid(cStr, nStart, nRange)
	pvtJoin(acList, cSep)
	pvtCompareStrings(cNbrInStr1, cNbrInStr2)
	pvtTrimZeros(cStr)
	pvtTrimLeadingZeros(cStr)
	pvtTrimTrailingZeros(cStr)
	pvtPadLeft(cStr, n, cChar)
	pvtPadRight(cStr, n, cChar)
	pvtCopy(cChar, n)
	pvtMin(anList)
	pvtMax(anList)
*/
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
	
	def pvtJoin(list, separator)
	
		result = ""
	
		for i = 1 to len(list)
	
			if i > 1
				result += separator
			ok
	
			result += list[i]
		next
	
		return result

	func pvtCompareStrings(strNum1, strNum2) #me

		if not ( isString(strNum1) and isString(strNum2))
			raise("Incorrect param type!")
		ok
	
		strNum1 = ring_substr2(strNum1, "_", "")
		strNum2 = ring_substr2(strNum2, "_", "")
	
		strNum1 = pvtTrimLeadingZeros(pvtTrimTrailingZeros(strNum1))
		strNum2 = pvtTrimLeadingZeros(pvtTrimTrailingZeros(strNum2))
	
		# Case 1 : bother are equal
	
		if strNum1 = strNum2
			return "11"
		ok
	
		# Case 2 : One of them is negative
	
		bNegative1 = (left(strNum1, 1) = "-")
		bNegative2 = (left(strNum2, 1) = "-")
	
		if bNegative1 and !bNegative2
			return "01"
	
		but !bNegative1 and bNegative2
			return "10"
		ok
	
		# Getting int and fract parts
	
		nLen1 = len(strNum1)
		nLen2 = len(strNum2)
	
		intPart1 = ""
		fracPart1 = ""
	
		intPart2 = ""
		fractPart2 = ""
	
		nDot1 = ring_substr1(strNum1, ".")
		if nDot1 = 0
			intPart1 = strNum1
			fracPart1 = ""
		else
			intPart1 = left(strNum1, nDot1-1)
			fracPart1 = right(strNum1, nLen1 - nDot1)
		ok
	
		nDot2 = ring_substr1(strNum2, ".")
		if nDot2 = 0
			intPart2 = strNum2
			fracPart2 = ""
		else
			intPart2 = left(strNum2, nDot2-1)
			fracPart2 = right(strNum2, nLen2 - nDot2)
		ok
	
		nLenIntPart1 = len(intPart1)
		nLenFracPart1 = len(fracPart1)
	
		nLenIntPart2 = len(intPart2)
		nLenFracPart2 = len(fracPart2)
	
		# Case both are positive
	
		if !bNegative1 and !bNegative2
	
			if nLenIntPart1 < nLenIntPart2
				return "01"
	
			but nLenIntPart1 > nLenIntPart2
				return "10"
	
			else // same length
	
				# Start by comparing int parts
	
				for i = nLenIntPart1 to 1 step -1
					if (0+ intPart1[i]) < (0+ intPart2[i])
						return "01"
	
					but (0+ intPart1[i]) > (0+ intPart2[i])
						return "10"
					ok
				next
	
				# At this level, int parts are equal, let's
				# compare the fract part (if they exist)
	
				if nLenFracPart1 = 0 and nLenFracPart2 = 0
					return "11"
	
				but nLenFracPart1 = 0 and nLenFracPart2 != 0
					return "01"
	
				but nLenFracPart1 != 0 and nLenFracPart2 = 0
					return "10"
				ok
	
				# Both numbers contain fractions, adjust them
	
				if nLenFracPart1 < nLenFracPart2
					nDiff = nLenFracPart2 - nLenFracPart1
					for i = 1 to nDiff
						fracPart1 += "0"
					next
				else
					nDiff = nLenFracPart1 - nLenFracPart2
					for i = 1 to nDiff
						fracPart2 += "0"
					next
				ok
	
				nLen = len(fracPart1)
	
				for i = nLen to 1 step -1
					if (0+ fracPart1[i]) < (0+ fracPart2[i])
						return "01"
					but (0+ fracPart1[i]) > (0+ fracPart2[i])
						return "10"
					ok
				next
				
				# At this level, not only intpart are equal, but fractions too
	
				return "11"
			ok
	
		ok
	
		# Case both are negative ~> use their absolute values
	
		strNum1 = right(strNum1, nLen1 - 1)
		strNum2 = right(strNum2, nLen2 - 1)
	
		cResult = pvtCompareStrings(strNum1, strNum2)
	
		if cResult = "11"
			return "11"
	
		but cResult = "01"
			return "10"
	
		else
			return "01"
		ok
	
	def pvtSAbs(s)

	        if left(s, 1) = "-"
			s = ring_substr2(s, "-", "")
	        ok

	        return s

	# Helper function to Trim zeros from left

    	def pvtTrimLeadingZeros(s)

	        while TRUE

			if NOT (left(s, 1) = "0" and len(s) > 1)
				exit
			ok
	
	            	s = ring_substr1(s, 2)
	        end
	
	        return s

	# Helper function to Trim zeros at the end

	def pvtTrimTrailingZeros(s)
	
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

	def pvtTrimZeros(str)
		return pvtTrimLeadingZeros(pvtTrimTrailingZeros(str))
	
 	# Helper function to duplicate a char n times
	
	def pvtCopy(s, n)

		result = ""
		
		        for i = 1 to n
				result += s
		        next
		
		        return result
	
	# Helper function to get the min of two numbers

	def pvtMin(a, b)
		
	        if a < b
			return a
	        else
			return b
	        ok

	# Helper function to get the max of two numbers

	def pvtMax(a, b)

	        if a < b
			return b
	        else
			return a
	        ok


