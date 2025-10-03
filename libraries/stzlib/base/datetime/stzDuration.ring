/*
	stzDuration - Duration/Interval Handling in Softanza
	Represents time spans independent of specific moments
*/

$cDurationDefaultFormat = "h:mm:ss"

func StzDurationQ(p)
	return new stzDuration(p)

func DurationQ(p)
	return new stzDuration(p)

func Duration(p)
	if isNumber(p)
		return StzDurationQ(p).ToString()
	but isString(p)
		return StzDurationQ(p).ToString()
	but isList(p)
		return StzDurationQ(p).ToString()
	ok

class stzDuration from stzObject
	@nTotalSeconds = 0
	
	def init(p)
		if isString(p)
			if p = NULL or p = ""
				@nTotalSeconds = 0
			else
				@nTotalSeconds = This.ParseDurationString(p)
			ok
			
		but isNumber(p)
			@nTotalSeconds = p
			
		but isList(p) and Q(p).IsHashList()
			nSecs = 0
			if ring_find(p, :Days) or ring_find(p, :Day)
				nSecs += (p[:Days] * 86400)
			ok
			if ring_find(p, :Hours) or ring_find(p, :Hour)
				nSecs += (p[:Hours] * 3600)
			ok
			if ring_find(p, :Minutes) or ring_find(p, :Minute)
				nSecs += (p[:Minutes] * 60)
			ok
			if ring_find(p, :Seconds) or ring_find(p, :Second)
				nSecs += p[:Seconds]
			ok
			if ring_find(p, :Milliseconds) or ring_find(p, :Millisecond)
				nSecs += (p[:Milliseconds] / 1000.0)
			ok
			@nTotalSeconds = nSecs
			
		else
			@nTotalSeconds = 0
		ok
		
	def TotalSeconds()
		return floor(@nTotalSeconds)
		
	def TotalMinutes()
		return floor(@nTotalSeconds / 60)
		
	def TotalHours()
		return floor(@nTotalSeconds / 3600)
		
	def TotalDays()
		return floor(@nTotalSeconds / 86400)
		
	def Days()
		return floor(@nTotalSeconds / 86400)
		
	def Hours()
		nRemainder = @nTotalSeconds % 86400
		return floor(nRemainder / 3600)
		
	def Minutes()
		nRemainder = @nTotalSeconds % 3600
		return floor(nRemainder / 60)
		
	def Seconds()
		return floor(@nTotalSeconds % 60)
		
	def Milliseconds()
		nFraction = @nTotalSeconds - floor(@nTotalSeconds)
		return round(nFraction * 1000)

	def Components()
		return [
			:Days = This.Days(),
			:Hours = This.Hours(),
			:Minutes = This.Minutes(),
			:Seconds = This.Seconds(),
			:Milliseconds = This.Milliseconds()
		]

	def ToString()
		return This.ToStringXT($cDurationDefaultFormat)
		
		def Duration()
			return This.ToString()

		def Content()
			return This.ToString()

	def ToStringXT(cFormat)
		nD = This.Days()
		nH = This.Hours()
		nM = This.Minutes()
		nS = This.Seconds()
		nMs = This.Milliseconds()
		
		cResult = cFormat
		
		# Days
		if substr(cFormat, "dd")
			cResult = substr(cResult, "dd", PadLeftXT('' + nD, 2, "0") )
		but substr(cFormat, "d")
			cResult = substr(cResult, "d", "" + nD)
		ok
		
		# Hours (24-hour)
		if substr(cFormat, "HH")
			cResult = substr(cResult, "HH", PadLeftXT('' + nH, 2, "0"))
		but substr(cFormat, "H")
			cResult = substr(cResult, "H", "" + nH)
		ok
		
		# Hours (total)
		if substr(cFormat, "hh")
			cResult = substr(cResult, "hh", PadLeftXT(''+ This.TotalHours(), 2, "0"))
		but substr(cFormat, "h")
			cResult = substr(cResult, "h", "" + This.TotalHours())
		ok
		
		# Minutes
		if substr(cFormat, "mm")
			cResult = substr(cResult, "mm", PadLeftXT("" + nM, 2, '0'))
		but substr(cFormat, "m")
			cResult = substr(cResult, "m", "" + nM)
		ok
		
		# Seconds
		if substr(cFormat, "ss")
			cResult = substr(cResult, "ss", PadLeftXT("" + nS, 2, '0'))
		but substr(cFormat, "s")
			cResult = substr(cResult, "s", "" + nS)
		ok
		
		# Milliseconds
		if substr(cFormat, "zzz")
			cResult = substr(cResult, "zzz", PzdLeftXT("" + nMs, 3, '0'))
		but substr(cFormat, "z")
			cResult = substr(cResult, "z", "" + nMs)
		ok
		
		return cResult

	def ToHuman()
		nD = This.Days()
		nH = This.Hours()
		nM = This.Minutes()
		nS = This.Seconds()
		
		aParts = []
		
		if nD > 0
			if nD = 1
				aParts + "1 day"
			else
				aParts + ("" + nD + " days")
			ok
		ok
		
		if nH > 0
			if nH = 1
				aParts + "1 hour"
			else
				aParts + ("" + nH + " hours")
			ok
		ok
		
		if nM > 0
			if nM = 1
				aParts + "1 minute"
			else
				aParts + ("" + nM + " minutes")
			ok
		ok
		
		if nS > 0 or len(aParts) = 0
			if nS = 1
				aParts + "1 second"
			else
				aParts + ("" + nS + " seconds")
			ok
		ok
		
		nLen = len(aParts)
		if nLen = 0
			return "0 seconds"
		but nLen = 1
			return aParts[1]
		but nLen = 2
			return aParts[1] + " and " + aParts[2]
		else
			cResult = ""
			for i = 1 to nLen - 1
				cResult += aParts[i] + ", "
			next
			cResult += "and " + aParts[nLen]
			return cResult
		ok

	def ToCompact()
		nD = This.Days()
		nH = This.Hours()
		nM = This.Minutes()
		nS = This.Seconds()
		
		cResult = ""
		if nD > 0
			cResult += ("" + nD + "d ")
		ok
		if nH > 0
			cResult += ("" + nH + "h ")
		ok
		if nM > 0
			cResult += ("" + nM + "m ")
		ok
		if nS > 0 or cResult = ""
			cResult += ("" + nS + "s")
		ok
		
		return trim(cResult)

	def ToSimple()
		nH = This.TotalHours()
		nM = This.Minutes()
		nS = This.Seconds()
		
		if nH > 0
			return "" + nH + ":" + 
			       StzStringQ("" + nM).PadLeftWithZerosToNCharsQ(2).Content() + ":" +
			       StzStringQ("" + nS).PadLeftWithZerosToNCharsQ(2).Content()
		else
			return StzStringQ("" + nM).PadLeftWithZerosToNCharsQ(2).Content() + ":" +
			       StzStringQ("" + nS).PadLeftWithZerosToNCharsQ(2).Content()
		ok

	# Arithmetic operators
	
	def operator(cOp, pValue)
		if cOp = "+"
			if isNumber(pValue)
				return new stzDuration(@nTotalSeconds + pValue)
			but isString(pValue)
				return new stzDuration(@nTotalSeconds + This.ParseDurationString(pValue))
			but IsObject(pValue) and classname(pValue) = "stzduration"
				return new stzDuration(@nTotalSeconds + pValue.TotalSeconds())
			ok
			
		but cOp = "-"
			if isNumber(pValue)
				return new stzDuration(@nTotalSeconds - pValue)
			but isString(pValue)
				return new stzDuration(@nTotalSeconds - This.ParseDurationString(pValue))
			but IsObject(pValue) and classname(pValue) = "stzduration"
				return new stzDuration(@nTotalSeconds - pValue.TotalSeconds())
			ok
			
		but cOp = "*"
			if isNumber(pValue)
				return new stzDuration(@nTotalSeconds * pValue)
			ok
			
		but cOp = "/"
			if isNumber(pValue) and pValue != 0
				return new stzDuration(@nTotalSeconds / pValue)
			ok
			
		but cOp = "<"
			return This.Compare(pValue) < 0
			
		but cOp = "<="
			return This.Compare(pValue) <= 0
			
		but cOp = ">"
			return This.Compare(pValue) > 0
			
		but cOp = ">="
			return This.Compare(pValue) >= 0
			
		but cOp = "="
			return This.Compare(pValue) = 0
			
		but cOp = "!="
			return This.Compare(pValue) != 0
		ok
		
		return NULL

	def Compare(pOther)
		nOtherSecs = 0
		
		if isNumber(pOther)
			nOtherSecs = pOther
		but isString(pOther)
			nOtherSecs = This.ParseDurationString(pOther)
		but IsObject(pOther) and classname(pOther) = "stzduration"
			nOtherSecs = pOther.TotalSeconds()
		ok
		
		if @nTotalSeconds < nOtherSecs
			return -1
		but @nTotalSeconds > nOtherSecs
			return 1
		else
			return 0
		ok

	# Comparison methods
	
	def IsEqualTo(pOther)
		return This.Compare(pOther) = 0
		
	def IsLessThan(pOther)
		return This.Compare(pOther) < 0
		
	def IsGreaterThan(pOther)
		return This.Compare(pOther) > 0
		
	def IsBetween(pMin, pMax)
		return This.Compare(pMin) >= 0 and This.Compare(pMax) <= 0

	def IsZero()
		return @nTotalSeconds = 0
		
	def IsPositive()
		return @nTotalSeconds > 0
		
	def IsNegative()
		return @nTotalSeconds < 0

	# Modification methods
	
	def Add(p)
		if isNumber(p)
			@nTotalSeconds += p
		but isString(p)
			@nTotalSeconds += This.ParseDurationString(p)
		but IsObject(p) and classname(p) = "stzduration"
			@nTotalSeconds += p.TotalSeconds()
		ok
		return This
		
	def Subtract(p)
		if isNumber(p)
			@nTotalSeconds -= p
		but isString(p)
			@nTotalSeconds -= This.ParseDurationString(p)
		but IsObject(p) and classname(p) = "stzduration"
			@nTotalSeconds -= p.TotalSeconds()
		ok
		return This
		
	def Multiply(n)
		if isNumber(n)
			@nTotalSeconds *= n
		ok
		return This
		
	def Divide(n)
		if isNumber(n) and n != 0
			@nTotalSeconds /= n
		ok
		return This

	def AddDays(n)
		@nTotalSeconds += (n * 86400)
		return This
		
	def AddHours(n)
		@nTotalSeconds += (n * 3600)
		return This
		
	def AddMinutes(n)
		@nTotalSeconds += (n * 60)
		return This
		
	def AddSeconds(n)
		@nTotalSeconds += n
		return This
		
	def AddMilliseconds(n)
		@nTotalSeconds += (n / 1000.0)
		return This

	# Utility
	
	def ParseDurationString(cStr)
		nTotal = 0
		cStr = lower(trim(cStr))
		
		# Days
		if substr(cStr, "day")
			nPos = substr(cStr, "day")
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 86400
			ok
		ok
		
		# Hours
		if substr(cStr, "hour") or substr(cStr, "hr")
			cPattern = "hour"
			if substr(cStr, "hr") and not substr(cStr, "hour")
				cPattern = "hr"
			ok
			nPos = substr(cStr, cPattern)
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 3600
			ok
		ok
		
		# Minutes
		if substr(cStr, "minute") or substr(cStr, "min")
			cPattern = "minute"
			if substr(cStr, "min") and not substr(cStr, "minute")
				cPattern = "min"
			ok
			nPos = substr(cStr, cPattern)
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 60
			ok
		ok
		
		# Seconds
		if substr(cStr, "second") or substr(cStr, "sec")
			cPattern = "second"
			if substr(cStr, "sec") and not substr(cStr, "second")
				cPattern = "sec"
			ok
			nPos = substr(cStr, cPattern)
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum)
			ok
		ok
		
		# Milliseconds
		if substr(cStr, "millisecond") or substr(cStr, "ms")
			cPattern = "millisecond"
			if substr(cStr, "ms") and not substr(cStr, "millisecond")
				cPattern = "ms"
			ok
			nPos = substr(cStr, cPattern)
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) / 1000.0
			ok
		ok
		
		return nTotal

	def Copy()
		return new stzDuration(@nTotalSeconds)
		
	def Clone()
		return This.Copy()
