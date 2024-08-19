	load "bignumber.ring" # Thanks to Bert Meriani and Gal Zsolt (2018)

def IsBigInteger(n)
	if NOT isNumber(n)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	cStringified = ""+ n
	nDigits = len(cStringified)

	if nDigits > $MAX_NUMBER_SIZE
		return TRUE
	else
		return FALSE
	ok

##################"

   # Helper methods
    func addStrings(s1, s2)
        result = ""
        carry = 0
        i = len(s1)
        j = len(s2)
        while i > 0 or j > 0 or carry > 0
            digit1 = 0
            digit2 = 0
            if i > 0
                digit1 = number(s1[i])
            ok
            if j > 0
                digit2 = number(s2[j])
            ok
            sum = digit1 + digit2 + carry
            result = string(sum % 10) + result
            carry = floor(sum / 10)
            i = i - 1
            j = j - 1
        end
        return stripLeadingZeros(result)

    func subtractStrings(s1, s2)
        result = ""
        borrow = 0
        i = len(s1)
        j = len(s2)
        while i > 0
            digit1 = number(s1[i]) - borrow
            digit2 = 0
            if j > 0
                digit2 = number(s2[j])
            ok
            if digit1 < digit2
                digit1 = digit1 + 10
                borrow = 1
            else
                borrow = 0
            ok
            result = string(digit1 - digit2) + result
            i = i - 1
            j = j - 1
        end
        return stripLeadingZeros(result)

    func multiplyStrings(s1, s2)
        len1 = len(s1)
        len2 = len(s2)
        result = list(len1 + len2)
        for k = 1 to len(result)
            result[k] = 0
        next
        for i = len1 to 1 step -1
            for j = len2 to 1 step -1
                product = number(s1[i]) * number(s2[j])
                sum = result[i+j-1] + product
                result[i+j-1] = sum % 10
                result[i+j-2] = result[i+j-2] + floor(sum / 10)
            next
        next
        resultStr = ""
        for k = 1 to len(result)
            resultStr = resultStr + string(result[k])
        next
        return stripLeadingZeros(resultStr)

    func compareAbsValues(s1, s2)
        if len(s1) != len(s2)
            return len(s1) - len(s2)
        ok
        for i = 1 to len(s1)
            if s1[i] != s2[i]
                return ascii(s1[i]) - ascii(s2[i])
            ok
        next
        return 0

    func stripLeadingZeros(s)
        while left(s, 1) = "0" and len(s) > 1
            s = right(s, len(s) - 1)
        end
        return s

    func isValidNumber(s)
        for i = 1 to len(s)
            if not (ascii(s[i]) >= 48 and ascii(s[i]) <= 57)
                return false
            ok
        next
        return true

#####

class stkBigInteger
	@sValue
	@bIsNegative

	def init(value)
	
		if type(value) = "STRING"
			@sValue = stripLeadingZeros(value)
	
			if left(@sValue, 1) = "-"
				@bIsNegative = true
				@sValue = right(@sValue, len(@sValue) - 1)
	
			else
				@bIsNegative = false
			ok
	
	        but type(value) = "NUMBER"
			@sValue = string(abs(value))
			@bIsNegative = (value < 0)
	
	        else
			raise("ERR-" + StkError(:IncorrectParamType))
	        ok
	
	        if not isValidNumber(@sValue)
	            raise("ERR-" + StkError(:InvalidNumber))
	        ok
	
	def SValue()
	        if @bIsNegative
	            return "-" + @sValue
	        else
	            return @sValue
	        ok
	
		def Content()
			return This.SValue()
	
	def add(nOther)
	        if not (isObject(nOther) and classname(nOther) = "stkBigInteger")
	            raise("ERR-" + StkError(:IncorrectParamType))
	        ok
	        
	        if @bIsNegative = nOther.isNegative()
	            result = addStrings(@sValue, nOther.getAbsValue())
	            if @bIsNegative
	                return "-" + result
	            else
	                return result
	            ok
	        else
	            cmp = compareAbsValues(@sValue, nOther.getAbsValue())
	            if cmp = 0
	                return "0"
	            elseif cmp > 0
	                result = subtractStrings(@sValue, nOther.getAbsValue())
	                if @bIsNegative
	                    return "-" + result
	                else
	                    return result
	                ok
	            else
	                result = subtractStrings(nOther.getAbsValue(), @sValue)
	                if nOther.isNegative()
	                    return "-" + result
	                else
	                    return result
	                ok
	            ok
	        ok
	
	def subtract(nOther)
	        if not (isObject(nOther) and classname(nOther) = "stkBigInteger")
	            raise("ERR-" + StkError(:IncorrectParamType))
	        ok
	        
	        negatednOther = new stkBigInteger(nOther.getValue())
	        negatednOther.negate()
	        return add(negatednOther)
	
	    func multiply(nOther)
	        if not (isObject(nOther) and classname(nOther) = "stkBigInteger")
	            raise("ERR-" + StkError(:IncorrectParamType))
	        ok
	        
	        result = multiplyStrings(@sValue, nOther.getAbsValue())
	        if @bIsNegative != nOther.isNegative()
	            return "-" + result
	        else
	            return result
	        ok
	
	def isNegative()
	        return @bIsNegative
	
	def getAbsValue()
	        return @sValue
	
	def negate()
	        @bIsNegative = not @bIsNegative
	
	 
