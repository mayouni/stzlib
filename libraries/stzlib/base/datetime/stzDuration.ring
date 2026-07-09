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

func IsStzDuration(p)
	if isObject(p) and classname(p) = "stzduration"
		return 1
	else
		return 0
	ok

	def @IsStzDuration(p)
		return IsStzDuration(p)

class stzDuration from stzObject
	@nTotalSeconds = 0
	@nMilliseconds = 0

	def init(p)
		if isString(p)
			if p = ""
				@nTotalSeconds = 0
				@nMilliseconds = 0
			else
				_nTotal_ = This.ParseDurationString(p)
				@nTotalSeconds = floor(_nTotal_)
				@nMilliseconds = round((_nTotal_ - floor(_nTotal_)) * 1000)
			ok
			
		but isNumber(p)
			@nTotalSeconds = floor(p)
			@nMilliseconds = round((p - floor(p)) * 1000)
			
		but isList(p) and @IsHashList(p)
			_nSecs_ = 0
			_nMs_ = 0
			
			# Days
			if HasKey(p, "days")
				_nSecs_ += (p["days"] * 86400)
			ok

			if HasKey(p, "day")
				_nSecs_ += (p["day"] * 86400)
			ok
			
			# Hours
			if HasKey(p, "hours")
				_nSecs_ += (p["hours"] * 3600)
			ok

			if HasKey(p, "hour")
				_nSecs_ += (p["hour"] * 3600)
			ok
			
			# Minutes
			if HasKey(p, "minutes")
				_nSecs_ += (p["minutes"] * 60)
			ok

			if HasKey(p, "minute")
				_nSecs_ += (p["minute"] * 60)
			ok
			
			# Seconds
			if HasKey(p, "seconds")
				_nSecs_ += p["seconds"]
			ok

			if HasKey(p, "second")
				_nSecs_ += p["second"]
			ok
			
			# Milliseconds
			if HasKey(p, "milliseconds")
				_nMs_ = p["milliseconds"]
			ok

			if HasKey(p, "millisecond")
				_nMs_ = p["millisecond"]
			ok
			
			@nTotalSeconds = _nSecs_
			@nMilliseconds = _nMs_
			
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
		_nRemainder_ = @nTotalSeconds % 86400
		return floor(_nRemainder_ / 3600)

	def Minutes()
		_nRemainder_ = @nTotalSeconds % 3600
		return floor(_nRemainder_ / 60)

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
	_nD_ = This.Days()
	_nH_ = This.Hours()
	_nM_ = This.Minutes()
	_nS_ = This.Seconds()
	_nMs_ = This.Milliseconds()
	
	_cResult_ = ""
	_i_ = 1
	_nLen_ = StzLen(cFormat)
	
	while _i_ <= _nLen_
		# Three-character patterns
		if _i_ <= _nLen_ - 2 and StzMid(cFormat, _i_, 3) = "zzz"
			_cResult_ += PadLeftXT("" + _nMs_, 3, '0')
			_i_ += 3
			loop
		ok
		
		# Two-character patterns
		if _i_ <= _nLen_ - 1
			_cTwo_ = StzMid(cFormat, _i_, 2)
			if _cTwo_ = "dd"
				_cResult_ += PadLeftXT('' + _nD_, 2, "0")
				_i_ += 2
				loop
			but _cTwo_ = "HH"
				_cResult_ += PadLeftXT('' + _nH_, 2, "0")
				_i_ += 2
				loop
			but _cTwo_ = "hh"
				_cResult_ += PadLeftXT('' + This.TotalHours(), 2, "0")
				_i_ += 2
				loop
			but _cTwo_ = "mm"
				_cResult_ += PadLeftXT("" + _nM_, 2, '0')
				_i_ += 2
				loop
			but _cTwo_ = "ss"
				_cResult_ += PadLeftXT("" + _nS_, 2, '0')
				_i_ += 2
				loop
			ok
		ok
		
		# Single-character patterns - check if it's an ISOLATED format char
		# by verifying previous and next chars aren't letters
		_cOne_ = cFormat[_i_]
		_cPrev_ = ""
		_cNext_ = ""
		if _i_ > 1
			_cPrev_ = cFormat[_i_-1]
		ok
		if _i_ < _nLen_
			_cNext_ = cFormat[_i_+1]
		ok
		
		_bIsolated_ = (not isalpha(_cPrev_)) and (not isalpha(_cNext_))
		
		if _bIsolated_
			if _cOne_ = "d"
				_cResult_ += ("" + _nD_)
				_i_ += 1
				loop
			but _cOne_ = "H"
				_cResult_ += ("" + _nH_)
				_i_ += 1
				loop
			but _cOne_ = "h"
				_cResult_ += ("" + This.TotalHours())
				_i_ += 1
				loop
			but _cOne_ = "m"
				_cResult_ += ("" + _nM_)
				_i_ += 1
				loop
			but _cOne_ = "s"
				_cResult_ += ("" + _nS_)
				_i_ += 1
				loop
			but _cOne_ = "z"
				_cResult_ += ("" + _nMs_)
				_i_ += 1
				loop
			ok
		ok
		
		# Literal character
		_cResult_ += cFormat[_i_]
		_i_ += 1
	end
	
	return _cResult_

	def ToHuman()
		_nD_ = This.Days()
		_nH_ = This.Hours()
		_nM_ = This.Minutes()
		_nS_ = This.Seconds()
		
		# Check against patterns
		_nLen_ = len($aDurationPatterns)
		for _i_ = 1 to _nLen_
			if _nD_ = $aDurationPatterns[_i_][1] and _nH_ = $aDurationPatterns[_i_][2] and 
			   _nM_ = $aDurationPatterns[_i_][3] and _nS_ = $aDurationPatterns[_i_][4]
				return $aDurationPatterns[_i_][5]
			ok
		next
		
		# Build component-based description
		_aParts_ = []
		_aValues_ = [_nD_, _nH_, _nM_, _nS_]
		_nLen_ = len($aUnitNames)

		for _i_ = 1 to _nLen_
			_nValue_ = _aValues_[_i_]
			if _nValue_ > 0
				if _nValue_ = 1
					_aParts_ + ("1 " + $aUnitNames[_i_][2])
				else
					_aParts_ + ('' + _nValue_ + " " + $aUnitNames[_i_][3])
				ok
			ok
		next
		
		# Handle edge case: no time components
		if len(_aParts_) = 0
			_aParts_ + "0 seconds"
		ok
		
		# Format output
		return This.JoinParts(_aParts_)

	def ToCompact()
		_nD_ = This.Days()
		_nH_ = This.Hours()
		_nM_ = This.Minutes()
		_nS_ = This.Seconds()
		
		_cResult_ = ""
		if _nD_ > 0
			_cResult_ += ("" + _nD_ + "d ")
		ok
		if _nH_ > 0
			_cResult_ += ("" + _nH_ + "h ")
		ok
		if _nM_ > 0
			_cResult_ += ("" + _nM_ + "m ")
		ok
		if _nS_ > 0 or _cResult_ = ""
			_cResult_ += ("" + _nS_ + "s")
		ok
		
		return trim(_cResult_)

	def ToSimple()
		_nH_ = This.TotalHours()
		_nM_ = This.Minutes()
		_nS_ = This.Seconds()
		
		if _nH_ > 0
			return "" + _nH_ + ":" + 
			       PadLeftXT('' + _nM_, 2, " ") + ":" +
			       PadLeftXT('' + _nS_, 2, " ")
		else
			return PadLeftXT('' + _nM_, 2, " ") + ":" +
			       PadLeftXT('' + _nS_, 2, " ")
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
		_nOtherSecs_ = 0
		
		if isNumber(pOther)
			_nOtherSecs_ = pOther
		but isString(pOther)
			_nOtherSecs_ = This.ParseDurationString(pOther)
		but IsObject(pOther) and ring_classname(pOther) = "stzduration"
			_nOtherSecs_ = pOther.TotalSeconds()
		ok
		
		if @nTotalSeconds < _nOtherSecs_
			return -1
		but @nTotalSeconds > _nOtherSecs_
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
	
	def ParseDurationString(_cStr_)
		_nTotal_ = 0
		_cStr_ = StzLower(trim(_cStr_))
		
		# Extract all numbers followed by units
		# Days
		_nPos_ = StzFindFirst(_cStr_, "day")
		if _nPos_ > 0
			_cNum_ = ""
			for _i_ = _nPos_ - 1 to 1 step -1
				_c_ = _cStr_[_i_]
				if isdigit(_c_) or _c_ = "." or _c_ = "-"
					_cNum_ = _c_ + _cNum_
				but _c_ = " " or _c_ = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if _cNum_ != ""
				_nTotal_ += (0 + _cNum_) * 86400
			ok
		ok
		
		# Hours
		_nPos_ = StzFindFirst(_cStr_, "hour")
		if _nPos_ = 0
			_nPos_ = StzFindFirst(_cStr_, "hr")
		ok
		if _nPos_ > 0
			_cNum_ = ""
			for _i_ = _nPos_ - 1 to 1 step -1
				_c_ = _cStr_[_i_]
				if isdigit(_c_) or _c_ = "." or _c_ = "-"
					_cNum_ = _c_ + _cNum_
				but _c_ = " " or _c_ = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if _cNum_ != ""
				_nTotal_ += (0 + _cNum_) * 3600
			ok
		ok
		
		# Minutes
		_nPos_ = StzFindFirst(_cStr_, "minute")
		if _nPos_ = 0
			_nPos_ = StzFindFirst(_cStr_, "min")
		ok
		if _nPos_ > 0
			_cNum_ = ""
			for _i_ = _nPos_ - 1 to 1 step -1
				_c_ = _cStr_[_i_]
				if isdigit(_c_) or _c_ = "." or _c_ = "-"
					_cNum_ = _c_ + _cNum_
				but _c_ = " " or _c_ = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if _cNum_ != ""
				_nTotal_ += (0 + _cNum_) * 60
			ok
		ok
		
		# Seconds
		_nPos_ = StzFindFirst(_cStr_, "second")
		if _nPos_ = 0
			_nPos_ = StzFindFirst(_cStr_, "sec")
		ok
		if _nPos_ > 0
			_cNum_ = ""
			for _i_ = _nPos_ - 1 to 1 step -1
				_c_ = _cStr_[_i_]
				if isdigit(_c_) or _c_ = "." or _c_ = "-"
					_cNum_ = _c_ + _cNum_
				but _c_ = " " or _c_ = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if _cNum_ != ""
				_nTotal_ += (0 + _cNum_)
			ok
		ok
		
		# Milliseconds
		_nPos_ = StzFindFirst(_cStr_, "millisecond")
		if _nPos_ = 0
			_nPos_ = StzFindFirst(_cStr_, "ms")
		ok
		if _nPos_ > 0
			_cNum_ = ""
			for _i_ = _nPos_ - 1 to 1 step -1
				_c_ = _cStr_[_i_]
				if isdigit(_c_) or _c_ = "." or _c_ = "-"
					_cNum_ = _c_ + _cNum_
				but _c_ = " " or _c_ = "	"
					# Continue through whitespace
				else
					exit
				ok
			next
			if _cNum_ != ""
				_nTotal_ += (0 + _cNum_) / 1000.0
			ok
		ok
		
		return _nTotal_

	def Copy()
		return new stzDuration(@nTotalSeconds)
		
	def Clone()
		return This.Copy()

	PRIVATE
	
	def JoinParts(_aParts_)
		_nLen_ = len(_aParts_)
		if _nLen_ = 1
			return _aParts_[1]
		but _nLen_ = 2
			return _aParts_[1] + " and " + _aParts_[2]
		else
			_cResult_ = ""
			for _i_ = 1 to _nLen_ - 1
				_cResult_ += _aParts_[_i_] + ", "
			next
			_cResult_ += "and " + _aParts_[_nLen_]
			return _cResult_
		ok
