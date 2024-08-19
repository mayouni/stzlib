
#-------------#
#  FUNCTIONS  #
#-------------#

	func addDecimalStrings(s1, s2)

	        n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)
	        maxFracLen = max(len(n1.@sFractionalPart), len(n2.@sFractionalPart))
	        n1Padded = padRight(n1.@sIntegerPart + n1.@sFractionalPart, len(n1.@sIntegerPart) + maxFracLen, "0")
	        n2Padded = padRight(n2.@sIntegerPart + n2.@sFractionalPart, len(n2.@sIntegerPart) + maxFracLen, "0")
	        
	        sum = addStrings(n1Padded, n2Padded)
	        
	        if len(sum) > maxFracLen
	            intPart = left(sum, len(sum) - maxFracLen)
	            fracPart = right(sum, maxFracLen)
	        else
	            intPart = "0"
	            fracPart = padLeft(sum, maxFracLen, "0")
	        ok
	        
	        return stripTrailingZeros(intPart + "." + fracPart)

   	 func subtractDecimalStrings(s1, s2)
	        n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)
	        maxFracLen = max(len(n1.@sFractionalPart), len(n2.@sFractionalPart))
	        n1Padded = padRight(n1.@sIntegerPart + n1.@sFractionalPart, len(n1.@sIntegerPart) + maxFracLen, "0")
	        n2Padded = padRight(n2.@sIntegerPart + n2.@sFractionalPart, len(n2.@sIntegerPart) + maxFracLen, "0")
	        
	        if compareAbsValues(s1, s2) < 0
	            diff = subtractStrings(n2Padded, n1Padded)
	            isNegative = true
	        else
	            diff = subtractStrings(n1Padded, n2Padded)
	            isNegative = false
	        ok
	        
	        diff = padLeft(diff, len(n1Padded), "0")
	        intPart = left(diff, len(diff) - maxFracLen)
	        fracPart = right(diff, maxFracLen)
	        
	        result = stripLeadingZeros(intPart) + "." + stripTrailingZeros(fracPart)
	        if isNegative and result != "0"
	            result = "-" + result
	        ok
	        
	        return result

   	 func multiplyDecimalStrings(s1, s2)
		// #NOTE For very large numbers use Karatsuba algorithm!
	        n1 = new stkBigNumber(s1)
	        n2 = new stkBigNumber(s2)
	        fracLen1 = len(n1.@sFractionalPart)
	        fracLen2 = len(n2.@sFractionalPart)
	        
	        int1 = number(n1.@sIntegerPart + n1.@sFractionalPart)
	        int2 = number(n2.@sIntegerPart + n2.@sFractionalPart)
	        
	        product = string(int1 * int2)
	        totalFracLen = fracLen1 + fracLen2
	        
	        if len(product) > totalFracLen
	            intPart = left(product, len(product) - totalFracLen)
	            fracPart = right(product, totalFracLen)
	        else
	            intPart = "0"
	            fracPart = padLeft(product, totalFracLen, "0")
	        ok
	
	        cResult = stripTrailingZeros(stripLeadingZeros(intPart) + "." + fracPart)
		return cResult

    	func compareAbsValues(s1, s2)
	        n1 = new stkBigNumber(@abs(s1))
	        n2 = new stkBigNumber(@abs(s2))
	        
	        if n1.@sIntegerPart != n2.@sIntegerPart
	            return len(n1.@sIntegerPart) - len(n2.@sIntegerPart) or 
	                   compareStrings(n1.@sIntegerPart, n2.@sIntegerPart)
	        ok
	        
	        return compareStrings(n1.@sFractionalPart, n2.@sFractionalPart)
	
    	func stripLeadingZeros(s)
	        while left(s, 1) = "0" and len(s) > 1
	            s = substr(s, 2)
	        end
	        return s

    func stripTrailingZeros(s)

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

    func isValidNumber(s)
	        for i = 1 to len(s)
	            if not (ascii(s[i]) >= 48 and ascii(s[i]) <= 57)
	                return false
	            ok
	        next
	        return true

   	 func @abs(s)
	        if left(s, 1) = "-"
	            s = substr(s, "-", "")
	        ok
	        return s

    	func padLeft(s, n, char)
	        while len(s) < n
	            s = char + s
	        end
	        return s

    	func padRight(s, n, char)
	        while len(s) < n
	            s = s + char
	        end
	        return s

    	func addStrings(s1, s2)
	        result = ""
	        carry = 0
	
	        maxLen = max(len(s1), len(s2))
	        s1 = padLeft(s1, maxLen, "0")
	        s2 = padLeft(s2, maxLen, "0")
	        
	        for i = maxLen to 1 step -1
	            sum = 0+ (s1[i]) + s2[i] + carry
	            result = "" + (sum % 10) + result
	            carry = floor(sum / 10)
	        next
	 
	        if carry > 0
	            result = ""+ carry + result
	        ok
	        
	        return result

   	 func subtractStrings(s1, s2)
	        result = ""
	        borrow = 0
	        maxLen = max(len(s1), len(s2))
	        s1 = padLeft(s1, maxLen, "0")
	        s2 = padLeft(s2, maxLen, "0")
	        
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
	        
	        return stripLeadingZeros(result)

   	 func compareStrings(s1, s2)
	        maxLen = max(len(s1), len(s2))
	        s1 = padLeft(s1, maxLen, "0")
	        s2 = padLeft(s2, maxLen, "0")
	        
	        for i = 1 to maxLen
	            if s1[i] != s2[i]
	                return ascii(s1[i]) - ascii(s2[i])
	            ok
	        next
	        
	        return 0

#---------#
#  CLASS  #
#---------#

class stkBigNumber
	@sIntegerPart
	@sFractionalPart
	@bIsNegative

    	def init(value)

	        if not isString(value)
	            	raise("ERR-" + StkError(:IncorrectParamType))
	        ok


	        value = trim( substr(value, "_","") )
	        @bIsNegative = (left(value, 1) = "-")

	        if @bIsNegative
	            	value = substr(value, "-", "")
	        ok
	        
	        parts = split(value, ".")
	        @sIntegerPart = stripLeadingZeros(parts[1])

	        if len(parts) > 1
	            	@sFractionalPart = stripTrailingZeros(parts[2])
	        else
	            	@sFractionalPart = ""
	        ok
	        
	        if @sIntegerPart = "" and
		   @sFractionalPart = ""

	           	@sIntegerPart = "0"
	        ok


	        if not isValidNumber(@sIntegerPart + @sFractionalPart)
	            raise("ERR-" + StkError(:InvalidNumber))
	        ok

	def SIntegerPart()
		return @sIntegerPart

	def SFractionalPart()
		return @sFractionalPart

    def SValue()
        result = @sIntegerPart
        if @sFractionalPart != ""
            result += "." + @sFractionalPart
        ok
        if @bIsNegative and result != "0"
            result = "-" + result
        ok
        return result

    def add(oOtherBigNumber)
        if not (isObject(oOtherBigNumber) and classname(oOtherBigNumber) = "stkbignumber")
            raise("ERR-" + StkError(:IncorrectParamType))
        ok
        
        if @bIsNegative = oOtherBigNumber.isNegative()
            result = addDecimalStrings(SValue(), oOtherBigNumber.SValue())
        else

            result = subtractDecimalStrings(@abs(This.SValue()), @abs(oOtherBigNumber.SValue()))
            if @bIsNegative and compareAbsValues(This.SValue(), oOtherBigNumber.SValue()) > 0
                result = "-" + result
            elseif not @bIsNegative and compareAbsValues(This.SValue(), oOtherBigNumber.SValue()) < 0
                result = "-" + result
            ok
        ok
        return result

    def subtract(oOtherBigNumber)
        if not (isObject(oOtherBigNumber) and classname(oOtherBigNumber) = "stkbignumber")
            raise("ERR-" + StkError(:IncorrectParamType))
        ok
        
        negatedoOtherBigNumber = new stkBigNumber(oOtherBigNumber.SValue())
        negatedoOtherBigNumber.negate()
        return add(negatedoOtherBigNumber)

    def multiply(oOtherBigNumber)
        if not (isObject(oOtherBigNumber) and classname(oOtherBigNumber) = "stkbignumber")
            raise("ERR-" + StkError(:IncorrectParamType))
        ok
        
        result = multiplyDecimalStrings(@abs(This.SValue()), @abs(oOtherBigNumber.SValue()))

        if @bIsNegative != oOtherBigNumber.isNegative() and result != "0"
            result = "-" + result
        ok

        return result


    def isNegative()
        return @bIsNegative

    def negate()
        if SValue() != "0"
            @bIsNegative = not @bIsNegative
        ok
        return SValue()

    def abs()
        return new stkBigNumber(@abs(This.SValue()))

