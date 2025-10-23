/*
	stzDuration - Duration/Interval Handling in Softanza
	Represents time spans independent of specific moments
*/

$cDurationDefaultFormat = "h:mm:ss"


# Global container for duration formulations
# Add new patterns here without modifying ToHuman() code
$aDurationPatterns = [
	# [days, hours, minutes, seconds, output_string]
	[365, 23, 59, 59, "1 year"],
	[183, 23, 59, 59, "6 months"],
	[30, 23, 59, 59, "1 month"],
	[7, 0, 0, 0, "1 week"],
	[14, 0, 0, 0, "2 weeks"]
	# Add more patterns as needed
]

# Global container for unit names
$aUnitNames = [
	# [unit_value_getter, singular, plural]
	[:Days, "day", "days"],
	[:Hours, "hour", "hours"],
	[:Minutes, "minute", "minutes"],
	[:Seconds, "second", "seconds"]
]


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
	@nMilliseconds = 0

	def init(p)
		if isString(p)
			if p = ""
				@nTotalSeconds = 0
				@nMilliseconds = 0
			else
				nTotal = This.ParseDurationString(p)
				@nTotalSeconds = floor(nTotal)
				@nMilliseconds = round((nTotal - floor(nTotal)) * 1000)
			ok
			
		but isNumber(p)
			@nTotalSeconds = floor(p)
			@nMilliseconds = round((p - floor(p)) * 1000)
			
		but isList(p) and @IsHashList(p)
			nSecs = 0
			nMs = 0
			
			# Days
			if HasKey(p, "days")
				nSecs += (p["days"] * 86400)
			ok

			if HasKey(p, "day")
				nSecs += (p["day"] * 86400)
			ok
			
			# Hours
			if HasKey(p, "hours")
				nSecs += (p["hours"] * 3600)
			ok

			if HasKey(p, "hour")
				nSecs += (p["hour"] * 3600)
			ok
			
			# Minutes
			if HasKey(p, "minutes")
				nSecs += (p["minutes"] * 60)
			ok

			if HasKey(p, "minute")
				nSecs += (p["minute"] * 60)
			ok
			
			# Seconds
			if HasKey(p, "seconds")
				nSecs += p["seconds"]
			ok

			if HasKey(p, "second")
				nSecs += p["second"]
			ok
			
			# Milliseconds
			if HasKey(p, "milliseconds")
				nMs = p["milliseconds"]
			ok

			if HasKey(p, "millisecond")
				nMs = p["millisecond"]
			ok
			
			@nTotalSeconds = nSecs
			@nMilliseconds = nMs
			
		else
			@nTotalSeconds = 0
			@nMilliseconds = 0
		ok

		
	def TotalSeconds()
		return floor(@nTotalSeconds)
		
		def ToSeconds()
			return floor(@nTotalSeconds)

	def TotalMinutes()
		return floor(@nTotalSeconds / 60)
		
		def ToMinutes()
			return floor(@nTotalSeconds / 60)

	def TotalHours()
		return floor(@nTotalSeconds / 3600)
		
		def ToHours()
			return floor(@nTotalSeconds / 3600)

	def TotalDays()
		return floor(@nTotalSeconds / 86400)
		
		def ToDays()
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
		return @nMilliseconds

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
	
	cResult = ""
	i = 1
	nLen = len(cFormat)
	
	while i <= nLen
		# Three-character patterns
		if i <= nLen - 2 and substr(cFormat, i, 3) = "zzz"
			cResult += PadLeftXT("" + nMs, 3, '0')
			i += 3
			loop
		ok
		
		# Two-character patterns
		if i <= nLen - 1
			cTwo = substr(cFormat, i, 2)
			if cTwo = "dd"
				cResult += PadLeftXT('' + nD, 2, "0")
				i += 2
				loop
			but cTwo = "HH"
				cResult += PadLeftXT('' + nH, 2, "0")
				i += 2
				loop
			but cTwo = "hh"
				cResult += PadLeftXT('' + This.TotalHours(), 2, "0")
				i += 2
				loop
			but cTwo = "mm"
				cResult += PadLeftXT("" + nM, 2, '0')
				i += 2
				loop
			but cTwo = "ss"
				cResult += PadLeftXT("" + nS, 2, '0')
				i += 2
				loop
			ok
		ok
		
		# Single-character patterns - check if it's an ISOLATED format char
		# by verifying previous and next chars aren't letters
		cOne = cFormat[i]
		cPrev = ""
		cNext = ""
		if i > 1
			cPrev = cFormat[i-1]
		ok
		if i < nLen
			cNext = cFormat[i+1]
		ok
		
		bIsolated = (not isalpha(cPrev)) and (not isalpha(cNext))
		
		if bIsolated
			if cOne = "d"
				cResult += ("" + nD)
				i += 1
				loop
			but cOne = "H"
				cResult += ("" + nH)
				i += 1
				loop
			but cOne = "h"
				cResult += ("" + This.TotalHours())
				i += 1
				loop
			but cOne = "m"
				cResult += ("" + nM)
				i += 1
				loop
			but cOne = "s"
				cResult += ("" + nS)
				i += 1
				loop
			but cOne = "z"
				cResult += ("" + nMs)
				i += 1
				loop
			ok
		ok
		
		# Literal character
		cResult += cFormat[i]
		i += 1
	end
	
	return cResult

	def ToHuman()
		nD = This.Days()
		nH = This.Hours()
		nM = This.Minutes()
		nS = This.Seconds()
		
		# Check against patterns
		nLen = len($aDurationPatterns)
		for i = 1 to nLen
			if nD = $aDurationPatterns[i][1] and nH = $aDurationPatterns[i][2] and 
			   nM = $aDurationPatterns[i][3] and nS = $aDurationPatterns[i][4]
				return $aDurationPatterns[i][5]
			ok
		next
		
		# Build component-based description
		aParts = []
		aValues = [nD, nH, nM, nS]
		nLen = len($aUnitNames)

		for i = 1 to nLen
			nValue = aValues[i]
			if nValue > 0
				if nValue = 1
					aParts + ("1 " + $aUnitNames[i][2])
				else
					aParts + ('' + nValue + " " + $aUnitNames[i][3])
				ok
			ok
		next
		
		# Handle edge case: no time components
		if len(aParts) = 0
			aParts + "0 seconds"
		ok
		
		# Format output
		return This.JoinParts(aParts)

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
			       PadLeftXT('' + nM, 2, " ") + ":" +
			       PadLeftXT('' + nS, 2, " ")
		else
			return PadLeftXT('' + nM, 2, " ") + ":" +
			       PadLeftXT('' + nS, 2, " ")
		ok

	# Arithmetic operators
	
	def operator(cOp, pValue)
		if cOp = "+"
			if isNumber(pValue)
				return new stzDuration(@nTotalSeconds + pValue)
			but isString(pValue)
				return new stzDuration(@nTotalSeconds + This.ParseDurationString(pValue))
			but isObject(pValue) and ring_classname(pValue) = "stzduration"
				return new stzDuration(@nTotalSeconds + pValue.TotalSeconds())
			ok
			
		but cOp = "-"
			if isNumber(pValue)
				return new stzDuration(@nTotalSeconds - pValue)
			but isString(pValue)
				return new stzDuration(@nTotalSeconds - This.ParseDurationString(pValue))
			but IsObject(pValue) and ring_classname(pValue) = "stzduration"
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
		but IsObject(pOther) and ring_classname(pOther) = "stzduration"
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
		but IsObject(p) and ring_classname(p) = "stzduration"
			@nTotalSeconds += p.TotalSeconds()
		ok
		return This
		
	def Subtract(p)
		if isNumber(p)
			@nTotalSeconds -= p
		but isString(p)
			@nTotalSeconds -= This.ParseDurationString(p)
		but IsObject(p) and ring_classname(p) = "stzduration"
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
		
		# Extract all numbers followed by units
		# Days
		nPos = substr(cStr, "day")
		if nPos > 0
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				but c = " " or c = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 86400
			ok
		ok
		
		# Hours
		nPos = substr(cStr, "hour")
		if nPos = 0
			nPos = substr(cStr, "hr")
		ok
		if nPos > 0
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				but c = " " or c = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 3600
			ok
		ok
		
		# Minutes
		nPos = substr(cStr, "minute")
		if nPos = 0
			nPos = substr(cStr, "min")
		ok
		if nPos > 0
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				but c = " " or c = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum) * 60
			ok
		ok
		
		# Seconds
		nPos = substr(cStr, "second")
		if nPos = 0
			nPos = substr(cStr, "sec")
		ok
		if nPos > 0
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				but c = " " or c = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if cNum != ""
				nTotal += (0 + cNum)
			ok
		ok
		
		# Milliseconds
		nPos = substr(cStr, "millisecond")
		if nPos = 0
			nPos = substr(cStr, "ms")
		ok
		if nPos > 0
			cNum = ""
			for i = nPos - 1 to 1 step -1
				c = cStr[i]
				if isdigit(c) or c = "." or c = "-"
					cNum = c + cNum
				but c = " " or c = "	"
					# Continue through whitespace
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

	PRIVATE
	
	def JoinParts(aParts)
		nLen = len(aParts)
		if nLen = 1
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
