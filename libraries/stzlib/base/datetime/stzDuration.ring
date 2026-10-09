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

# Holds a length of time, independent of any date, and reads it back as parts, as words or as clock text.
#
# A duration is built from a number of seconds, from a text such as 1 hour 30 min, or from a hash
# list of days, hours, minutes, seconds and milliseconds. It answers totals (TotalHours counts past
# one day) and parts (Hours is the hour of the day), compares with other durations, numbers or
# texts, and is changed in place by Add, Subtract, Multiply and Divide, which return the duration so
# calls chain. Limits today: the fraction of a second is lost when it is built from a number or a
# text, and AddMilliseconds, Copy and the operator results do not carry milliseconds; a negative
# duration answers wrong parts.
#
#   receiver   o1 = new stzDuration("1 day 2 hours 3 minutes 4 seconds")
#   example    ? o1.TotalSeconds()
#              #--> 93784
#              ? o1.ToHuman()
#              #--> 1 day, 2 hours, 3 minutes, and 4 seconds
#              ? o1.ToString()
#              #--> 26:03:04
#   see        stzDate, stzDateTime, stzTime
class stzDuration from stzObject
	@nTotalSeconds = 0
	@nMilliseconds = 0

	# Builds a length of time from seconds, from text such as 1 hour 30 min, or from a hash list of parts.
	#
	#   p          the length: a number of seconds, a text of numbers followed by day, hour, minute,
	#              second or ms units, or a hash list with the keys days, hours, minutes, seconds
	#              and milliseconds
	#   returns    nothing; the object is built
	#   note       an empty text gives a zero duration
	#   warning    the fraction of a second is lost today for a number or a text: 90.5 and 90
	#              seconds 250 ms both answer Milliseconds 0; only a hash list with a milliseconds
	#              key keeps it, and Copy or Add then drop it
	#   see        ParseDurationString, Components
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

		
	# Returns the whole length counted in seconds, dropping any fraction.
	#
	#   returns    a number
	#   note       1 day 2 hours 3 minutes 4 seconds is 93784
	#   see        TotalMinutes, Seconds
	def TotalSeconds()
		return floor(@nTotalSeconds)
		
		# Returns the whole length counted in seconds, dropping any fraction.
		#
		#   returns    a number
		#   note       the same value as TotalSeconds
		#   see        TotalSeconds, ToMinutes
		def ToSeconds()
			return floor(@nTotalSeconds)

	# Returns the whole length counted in minutes, rounded down.
	#
	#   returns    a number
	#   note       93784 seconds is 1563 minutes
	#   see        TotalSeconds, TotalHours
	def TotalMinutes()
		return floor(@nTotalSeconds / 60)
		
		# Returns the whole length counted in minutes, rounded down.
		#
		#   returns    a number
		#   note       the same value as TotalMinutes
		#   see        TotalMinutes, ToHours
		def ToMinutes()
			return floor(@nTotalSeconds / 60)

	# Returns the whole length counted in hours, rounded down, and without wrapping at one day.
	#
	#   returns    a number
	#   note       93784 seconds is 26 hours, where Hours answers 2
	#   see        TotalDays, Hours
	def TotalHours()
		return floor(@nTotalSeconds / 3600)
		
		# Returns the whole length counted in hours, rounded down, and without wrapping at one day.
		#
		#   returns    a number
		#   note       the same value as TotalHours
		#   see        TotalHours, ToDays
		def ToHours()
			return floor(@nTotalSeconds / 3600)

	# Returns the whole length counted in days, rounded down.
	#
	#   returns    a number
	#   note       93784 seconds is 1 day
	#   see        TotalHours, Days
	def TotalDays()
		return floor(@nTotalSeconds / 86400)
		
		# Returns the whole length counted in days, rounded down.
		#
		#   returns    a number
		#   note       the same value as TotalDays
		#   see        TotalDays, ToHours
		def ToDays()
			return floor(@nTotalSeconds / 86400)

	# Returns the number of whole days in the length.
	#
	#   returns    a number
	#   note       the same value as TotalDays
	#   warning    a negative duration gives a wrong part: -90 seconds answers Days -1, not 0
	#   see        Hours, Components
	def Days()
		return floor(@nTotalSeconds / 86400)

	# Returns the hours left over after whole days are taken out, from 0 to 23.
	#
	#   returns    a number
	#   note       26 hours total is 2 here
	#   warning    a negative duration gives a wrong part: -90 seconds answers Hours -1
	#   see        TotalHours, Minutes
	def Hours()
		_nRemainder_ = @nTotalSeconds % 86400
		return floor(_nRemainder_ / 3600)

	# Returns the minutes left over after whole hours are taken out, from 0 to 59.
	#
	#   returns    a number
	#   warning    a negative duration gives a wrong part: -90 seconds answers Minutes -2
	#   see        TotalMinutes, Seconds
	def Minutes()
		_nRemainder_ = @nTotalSeconds % 3600
		return floor(_nRemainder_ / 60)

	# Returns the seconds left over after whole minutes are taken out, from 0 to 59.
	#
	#   returns    a number
	#   note       90 seconds answers 30
	#   warning    a negative duration gives a wrong part: -90 seconds answers Seconds -30
	#   see        TotalSeconds, Milliseconds
	def Seconds()
		return floor(@nTotalSeconds % 60)

	# Returns the milliseconds part kept with the length, from 0 to 999.
	#
	#   returns    a number
	#   warning    stays 0 for a duration built from a number or a text, and AddMilliseconds does
	#              not change it: only the milliseconds key of a hash list sets it
	#   see        Seconds, Components
	def Milliseconds()
		return @nMilliseconds

	# Returns the length split into its parts, as a hash list of days, hours, minutes, seconds and milliseconds.
	#
	#   returns    a hash list with the keys days, hours, minutes, seconds and milliseconds
	#   note       93784 seconds gives 1, 2, 3, 4 and 0
	#   warning    a negative duration gives negative parts, which do not add back to the length
	#   see        Days, ToString
	def Components()
		return [
			:Days = This.Days(),
			:Hours = This.Hours(),
			:Minutes = This.Minutes(),
			:Seconds = This.Seconds(),
			:Milliseconds = This.Milliseconds()
		]

	# Returns the length as clock text, hours in total then minutes and seconds in two digits, such as 26:03:04.
	#
	#   returns    a text, h:mm:ss by default; ToStringXT takes a format of your own
	#   note       ToStringXT reads d, H, h, m, s and z for the parts and dd, HH, hh, mm, ss and zzz
	#              for the padded ones, where H is the hour of the day, h the total hours and zzz
	#              the milliseconds; a letter that touches another letter stays as written, and
	#              Duration and Content are the same call
	#   see        ToStringXT, ToSimple, ToCompact
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

	# Returns the length in words, such as 1 day, 2 hours, 3 minutes, and 4 seconds.
	#
	#   returns    a text; 0 seconds for a zero length
	#   note       whole weeks and a few long spans have their own phrase: 7 days is 1 week, 14 days
	#              is 2 weeks, 30 days with 23:59:59 is 1 month, 183 days with 23:59:59 is 6 months
	#              and 365 days with 23:59:59 is 1 year, while exactly 30 or 365 days stay in days
	#   warning    a negative duration answers 0 seconds
	#   see        ToCompact, ToString
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

	# Returns the length in short units, such as 1d 2h 3m 4s, leaving out the parts that are zero.
	#
	#   returns    a text; 0s for a zero length
	#   note       milliseconds are not shown; 100 days is 100d
	#   see        ToHuman, ToSimple
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

	# Returns the length as h:m:s, or as m:s under one hour, with minutes and seconds padded by spaces.
	#
	#   returns    a text such as 26: 3: 4 or  1:30
	#   note       the padding is a space, not a zero, so 90 seconds gives a leading space; ToString
	#              pads with zeros
	#   see        ToString, ToCompact
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

	# Combines or compares the duration with another value by a sign, giving a new duration or TRUE or FALSE.
	#
	#   cOp        the operator as text: +, -, *, /, <, <=, >, >=, = or !=
	#   pValue     the right-hand side: a number of seconds, a text of units or a stzDuration, where
	#              * and / take a number only
	#   returns    a stzDuration for + - * /, TRUE or FALSE for < <= > >= = !=, an empty text for
	#              any other operator or a division by zero
	#   note       90 seconds plus 2 minutes is 210 seconds
	#   warning    the duration itself is not changed; the result of + - * / drops the milliseconds
	#   see        Compare, Add
	#@ aka  Arithmetic operators
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
		
		return ""

	# Compares the length with another and returns -1, 0 or 1.
	#
	#   pOther     a number of seconds, a text of units or a stzDuration
	#   returns    a number: -1 if shorter than pOther, 0 if equal, 1 if longer
	#   warning    a value of another kind counts as zero seconds, so the answer is 1 for any
	#              positive duration
	#   see        IsEqualTo, IsLessThan, IsGreaterThan
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

	# TRUE if the length equals another, given as seconds, text or a stzDuration.
	#
	#   pOther     a number of seconds, a text of units or a stzDuration
	#   returns    TRUE or FALSE
	#   note       90 seconds equals 1 minute 30 seconds
	#   see        Compare
	#@ aka  Comparison methods
	def IsEqualTo(pOther)
		return This.Compare(pOther) = 0
		
	# TRUE if the length is shorter than another.
	#
	#   pOther     a number of seconds, a text of units or a stzDuration
	#   returns    TRUE or FALSE
	#   see        Compare, IsGreaterThan
	def IsLessThan(pOther)
		return This.Compare(pOther) < 0
		
	# TRUE if the length is longer than another.
	#
	#   pOther     a number of seconds, a text of units or a stzDuration
	#   returns    TRUE or FALSE
	#   see        Compare, IsLessThan
	def IsGreaterThan(pOther)
		return This.Compare(pOther) > 0
		
	# TRUE if the length is within a range, both ends included.
	#
	#   pMin       the shortest accepted length
	#   pMax       the longest accepted length
	#   returns    TRUE or FALSE
	#   note       90 seconds is between 90 and 90
	#   warning    a reversed range, with pMin above pMax, is never satisfied
	#   see        Compare
	def IsBetween(pMin, pMax)
		return This.Compare(pMin) >= 0 and This.Compare(pMax) <= 0

	# TRUE if the length is exactly zero seconds.
	#
	#   returns    TRUE or FALSE
	#   see        IsPositive, IsNegative
	def IsZero()
		return @nTotalSeconds = 0
		
	# TRUE if the length is above zero.
	#
	#   returns    TRUE or FALSE
	#   see        IsZero, IsNegative
	def IsPositive()
		return @nTotalSeconds > 0
		
	# TRUE if the length is below zero, as after subtracting more than was there.
	#
	#   returns    TRUE or FALSE
	#   note       the parts of a negative duration are wrong: see Days
	#   see        IsZero, IsPositive
	def IsNegative()
		return @nTotalSeconds < 0

	# Adds a length to the duration in place; the length is a number of seconds, a text of units or a stzDuration.
	#
	#   p          the length to add
	#   returns    the duration itself, so calls chain
	#   note       90 seconds plus 30 is 120
	#   see        Subtract, AddHours
	#@ aka  Modification methods
	def Add(p)
		if isNumber(p)
			@nTotalSeconds += p
		but isString(p)
			@nTotalSeconds += This.ParseDurationString(p)
		but IsObject(p) and ring_classname(p) = "stzduration"
			@nTotalSeconds += p.TotalSeconds()
		ok
		return This
		
	# Takes a length off the duration in place; the length is a number of seconds, a text of units or a stzDuration.
	#
	#   p          the length to remove
	#   returns    the duration itself, so calls chain
	#   warning    the duration can go below zero
	#   see        Add
	def Subtract(p)
		if isNumber(p)
			@nTotalSeconds -= p
		but isString(p)
			@nTotalSeconds -= This.ParseDurationString(p)
		but IsObject(p) and ring_classname(p) = "stzduration"
			@nTotalSeconds -= p.TotalSeconds()
		ok
		return This
		
	# Multiplies the duration by a number, in place.
	#
	#   n          the factor, a number
	#   returns    the duration itself, so calls chain
	#   note       100 seconds times 3 is 300
	#   see        Divide, Add
	def Multiply(n)
		if isNumber(n)
			@nTotalSeconds *= n
		ok
		return This
		
	# Divides the duration by a number, in place.
	#
	#   n          the divisor, a number
	#   returns    the duration itself, so calls chain
	#   note       300 seconds divided by 4 is 75
	#   warning    a division by zero is ignored without an error
	#   see        Multiply
	def Divide(n)
		if isNumber(n) and n != 0
			@nTotalSeconds /= n
		ok
		return This

	# Adds a number of days to the duration, in place.
	#
	#   n          the number of days, which may be negative
	#   returns    the duration itself, so calls chain
	#   see        AddHours, Add
	def AddDays(n)
		@nTotalSeconds += (n * 86400)
		return This
		
	# Adds a number of hours to the duration, in place.
	#
	#   n          the number of hours, which may be negative
	#   returns    the duration itself, so calls chain
	#   see        AddMinutes, AddDays
	def AddHours(n)
		@nTotalSeconds += (n * 3600)
		return This
		
	# Adds a number of minutes to the duration, in place.
	#
	#   n          the number of minutes, which may be negative
	#   returns    the duration itself, so calls chain
	#   see        AddSeconds, AddHours
	def AddMinutes(n)
		@nTotalSeconds += (n * 60)
		return This
		
	# Adds a number of seconds to the duration, in place.
	#
	#   n          the number of seconds, which may be negative
	#   returns    the duration itself, so calls chain
	#   see        AddMilliseconds, AddMinutes
	def AddSeconds(n)
		@nTotalSeconds += n
		return This
		
	# Adds a number of milliseconds to the duration, in place, but the sub-second part is not shown.
	#
	#   n          the number of milliseconds
	#   returns    the duration itself, so calls chain
	#   note       adding 1500 ms to 93784.5 s gives 93786 s
	#   warning    the milliseconds go into a hidden fraction of the total: 500 ms added to 93784 s
	#              leaves Milliseconds 0 and ToString unchanged, and only a later carry into a whole
	#              second shows
	#   see        AddSeconds
	def AddMilliseconds(n)
		@nTotalSeconds += (n / 1000.0)
		return This

	# Returns the number of seconds written in a text such as 2 hours 30 min, ignoring case.
	#
	#   _cStr_     the text to read: numbers followed by the units day, hour or hr, minute or min,
	#              second or sec, millisecond or ms
	#   returns    a number of seconds, which may have a decimal part; 0 when no unit is found
	#   note       1.5 hr is 5400 and 250 ms is 0.25
	#   warning    the units week, month and year are not understood and give 0; a number with no
	#              unit is ignored
	#   see        init, Add
	#@ aka  Utility
	def ParseDurationString(_cStr_)
		_nTotal_ = 0
		_cStr_ = StzLower(trim(_cStr_))
		
		# Extract all numbers followed by units
		# Days
		_nPos_ = StzFindFirst("day", _cStr_)
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
		_nPos_ = StzFindFirst("hour", _cStr_)
		if _nPos_ = 0
			_nPos_ = StzFindFirst("hr", _cStr_)
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
		_nPos_ = StzFindFirst("minute", _cStr_)
		if _nPos_ = 0
			_nPos_ = StzFindFirst("min", _cStr_)
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
		_nPos_ = StzFindFirst("second", _cStr_)
		if _nPos_ = 0
			_nPos_ = StzFindFirst("sec", _cStr_)
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
		_nPos_ = StzFindFirst("millisecond", _cStr_)
		if _nPos_ = 0
			_nPos_ = StzFindFirst("ms", _cStr_)
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

	# Returns a new duration of the same length, independent of the first.
	#
	#   returns    a stzDuration
	#   note       changing the copy does not change the original
	#   warning    the milliseconds are dropped from the copy
	#   see        Clone, Add
	def Copy()
		return new stzDuration(@nTotalSeconds)
		
	# Returns a new duration of the same length, independent of the first.
	#
	#   returns    a stzDuration
	#   note       the same call as Copy
	#   warning    the milliseconds are dropped from the copy
	#   see        Copy
	def Clone()
		return This.Copy()

	PRIVATE
	
	# Joins phrases such as 1 hour and 2 minutes into one sentence, with commas and a last and.
	#
	#   _aParts_   the list of phrases, as text
	#   returns    a text: one phrase as it is, two joined by and, three or more separated by commas
	#              ending with and
	#   note       ToHuman is the public way to reach it
	#   warning    private: calling it from outside the class raises an error R26
	#   see        ToHuman
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
