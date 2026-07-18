
#TODO Make a bridge with stzLocale to let the stzTime class be locale-sensitive

# Global time format configurations
$cDefaultTimeFormat = "hh:mm:ss"

$aTimeFormats = [
    [ :Standard, "hh:mm:ss" ],
    [ :Short, "hh:mm" ],
    [ :WithMs, "hh:mm:ss.zzz" ],
    [ :AmPm, "h:mm:ss AP" ],
    [ :Military, "HH:mm:ss" ],
    [ :Simple, "h:mm AP" ]
]

# Quick time creation functions
func StzTimeQ(pTime)
    return new stzTime(pTime)

func StzNowTime()
    return StzTimeQ("").ToString()

	func NowTime()
		return StzNowTime()

func StzIsTime(str)
    if not isString(str) or StzLen(str) = 0
        return FALSE
    ok

    _aParts_ = split(str, ":")
    if len(_aParts_) < 2 or len(_aParts_) > 3
        _cUpper_ = StzUpper(str)
        if StzRight(_cUpper_, 3) = " AM" or StzRight(_cUpper_, 3) = " PM"
            _cCore_ = trim(StzLeft(str, StzLen(str) - 3))
            _aParts_ = split(_cCore_, ":")
            if len(_aParts_) < 2 or len(_aParts_) > 3
                return FALSE
            ok
        else
            return FALSE
        ok
    ok

    _nPartsLen_ = len(_aParts_)
    for i = 1 to _nPartsLen_
        _cPart_ = _aParts_[i]
        if i = len(_aParts_) and StzFindFirst(".", _cPart_)
            _aSubParts_ = split(_cPart_, ".")
            _cPart_ = _aSubParts_[1]
        ok
        if not isdigit(_cPart_)
            return FALSE
        ok
    next

    _nH_ = 0+ _aParts_[1]
    _nM_ = 0+ _aParts_[2]
    if _nH_ < 0 or _nH_ > 23 or _nM_ < 0 or _nM_ > 59
        return FALSE
    ok
    if len(_aParts_) = 3
        _cSecPart_ = _aParts_[3]
        if StzFindFirst(".", _cSecPart_)
            _aSubParts_ = split(_cSecPart_, ".")
            _cSecPart_ = _aSubParts_[1]
        ok
        _nS_ = 0+ _cSecPart_
        if _nS_ < 0 or _nS_ > 59
            return FALSE
        ok
    ok

    return TRUE

    func IsTime(str)
        return StzIsTime(str)

    func StzIsValidTime(str)
        return StzIsTime(str)

    func IsValidTime(str)
        return StzIsTime(str)

class stzTime from stzObject
    @nHour = 0
    @nMinute = 0
    @nSecond = 0
    @nMillisecond = 0

    def init(pTime)

        if IsNull(pTime) or pTime = ""
            pHandle = StzEngineTimeNow()
            @nHour = StzEngineTimeHour(pHandle)
            @nMinute = StzEngineTimeMinute(pHandle)
            @nSecond = StzEngineTimeSecond(pHandle)
            @nMillisecond = StzEngineTimeMillisecond(pHandle)
            StzEngineTimeFree(pHandle)

        but isString(pTime)
            This.ParseStringTime(pTime)

        but isNumber(pTime)
            _nHours_ = floor(pTime / 3600)
            _nMinutes_ = floor((pTime % 3600) / 60)
            _nSeconds_ = pTime % 60
            @nHour = _nHours_
            @nMinute = _nMinutes_
            @nSecond = _nSeconds_
            @nMillisecond = 0

        but isList(pTime) and IsHashList(pTime)
            _nHour_   = 0
            _nMinute_ = 0
            _nSecond_ = 0
            _nMs_     = 0

            if HasKey(pTime, :Hour)
                _nHour_ = 0+ pTime[:Hour]
            ok

            if HasKey(pTime, :Minute)
                _nMinute_ = 0+ pTime[:Minute]
            ok

            if HasKey(pTime, :Second)
                _nSecond_ = 0+ pTime[:Second]
            ok

            if HasKey(pTime, :Millisecond)
                _nMs_ = 0+ pTime[:Millisecond]
            ok

            @nHour = _nHour_
            @nMinute = _nMinute_
            @nSecond = _nSecond_
            @nMillisecond = _nMs_
        ok

        if not This.pvtIsValidHMS(@nHour, @nMinute, @nSecond, @nMillisecond)
            StzRaise("Invalid time provided!")
        ok

    def ParseStringTime(_cTime_)
        _cTime_ = trim(_cTime_)

        _cAmPm_ = ""
        _cUpper_ = StzUpper(_cTime_)
        if StzRight(_cUpper_, 3) = " AM" or StzRight(_cUpper_, 3) = " PM"
            _cAmPm_ = StzUpper(StzRight(_cTime_, 2))
            _cTime_ = trim(StzLeft(_cTime_, StzLen(_cTime_) - 3))
        ok

        _aParts_ = split(_cTime_, ":")
        if len(_aParts_) < 2 or len(_aParts_) > 3
            StzRaise("Cannot parse time string: " + _cTime_)
        ok

        _nH_ = 0+ _aParts_[1]
        _nM_ = 0+ _aParts_[2]
        _nS_ = 0
        _nMs_ = 0

        if len(_aParts_) = 3
            _cSecPart_ = _aParts_[3]
            if StzFindFirst(".", _cSecPart_)
                _aSubParts_ = split(_cSecPart_, ".")
                _nS_ = 0+ _aSubParts_[1]
                if len(_aSubParts_) > 1
                    _nMs_ = 0+ _aSubParts_[2]
                ok
            else
                _nS_ = 0+ _cSecPart_
            ok
        ok

        if _cAmPm_ = "PM" and _nH_ < 12
            _nH_ = _nH_ + 12
        but _cAmPm_ = "AM" and _nH_ = 12
            _nH_ = 0
        ok

        @nHour = _nH_
        @nMinute = _nM_
        @nSecond = _nS_
        @nMillisecond = _nMs_

    #--- ARITHMETIC OPERATIONS ---#

    def AddSeconds(_nSeconds_)
        This.pvtAddTotalSeconds(_nSeconds_)
        return This.ToString()

    def AddSecondsQ(_nSeconds_)
        This.AddSeconds(_nSeconds_)
        return This

    def AddMinutes(_nMinutes_)
        This.pvtAddTotalSeconds(_nMinutes_ * 60)
        return This.ToString()

    def AddMinutesQ(_nMinutes_)
        This.AddMinutes(_nMinutes_)
        return This

    def AddHours(_nHours_)
        This.pvtAddTotalSeconds(_nHours_ * 3600)
        return This.ToString()

    def AddHoursQ(_nHours_)
        This.AddHours(_nHours_)
        return This

    def AddMilliseconds(_nMs_)
        _nTotalMs_ = This.pvtToTotalMs() + _nMs_
        This.pvtFromTotalMs(_nTotalMs_)
        return This.ToString()

    def AddMillisecondsQ(_nMs_)
        This.AddMilliseconds(_nMs_)
        return This

    def SubtractSeconds(_nSeconds_)
        This.pvtAddTotalSeconds(-_nSeconds_)
        return This.ToString()

    def SubtractSecondsQ(_nSeconds_)
        This.SubtractSeconds(_nSeconds_)
        return This

    def SubtractMinutes(_nMinutes_)
        This.pvtAddTotalSeconds(-_nMinutes_ * 60)
        return This.ToString()

    def SubtractMinutesQ(_nMinutes_)
        This.SubtractMinutes(_nMinutes_)
        return This

    def SubtractHours(_nHours_)
        This.pvtAddTotalSeconds(-_nHours_ * 3600)
        return This.ToString()

    def SubtractHoursQ(_nHours_)
        This.SubtractHours(_nHours_)
        return This

    def SubtractMilliseconds(_nMs_)
        _nTotalMs_ = This.pvtToTotalMs() - _nMs_
        This.pvtFromTotalMs(_nTotalMs_)
        return This.ToString()

    def SubtractMillisecondsQ(_nMs_)
        This.SubtractMilliseconds(_nMs_)
        return This

    #--- OPERATOR OVERLOADING ---#

    def operator(op, v)
        if op = "+"
            if isNumber(v)
                This.AddSeconds(v)
                return This
            ok

        but op = "-"
            if isNumber(v)
                This.SubtractSeconds(v)
                return This

            but isObject(v) and v.IsAStzTime()
                return -This.SecsTo(v)

            but isString(v) and IsTime(v)
                _oOtherTime_ = new stzTime(v)
                return -This.SecsTo(_oOtherTime_)

            ok

        but op = "<"
            if (isObject(v) and v.IsAStzTime()) or (isString(v) and IsTime(v))
                return This.IsBefore(v)
            ok

        but op = "<="
            if (isObject(v) and v.IsAStzTime()) or (isString(v) and IsTime(v))
                return This.IsBefore(v) or This.IsEqualTo(v)
            ok

        but op = ">"
            if (isObject(v) and v.IsAStzTime()) or (isString(v) and IsTime(v))
                return This.IsAfter(v)
            ok

        but op = ">="
            if (isObject(v) and v.IsAStzTime()) or (isString(v) and IsTime(v))
                return This.IsAfter(v) or This.IsEqualTo(v)
            ok

        but op = "="
            # Use IsAStzTime() rather than classname(v) -- the latter
            # is a Ring builtin that mis-resolves inside class-method
            # scope on Ring 1.26 and trips R20.
            if (isObject(v) and v.IsAStzTime()) or (isString(v) and IsTime(v))
                return This.IsEqualTo(v)
            ok
        ok

    #--- COMPARISON METHODS ---#

    def SecsTo(_oOtherTime_)
        if isString(_oOtherTime_)
            _oTempTime_ = new stzTime(_oOtherTime_)
			_oOtherTime_ = _oTempTime_
        ok
        _nThisSecs_ = This.SecondsSinceMidnight()
        _nOtherSecs_ = _oOtherTime_.SecondsSinceMidnight()
        return _nOtherSecs_ - _nThisSecs_

    def MSecsTo(_oOtherTime_)
        if isString(_oOtherTime_)
            _oOtherTime_ = new stzTime(_oOtherTime_)
        ok
        _nThisMs_ = This.pvtToTotalMs()
        _nOtherMs_ = (_oOtherTime_.HourN() * 3600000) + (_oOtherTime_.MinuteN() * 60000) + (_oOtherTime_.SecondN() * 1000) + _oOtherTime_.MillisecondN()
        return _nOtherMs_ - _nThisMs_

    def MinutesTo(_oOtherTime_)
        return floor(This.SecsTo(_oOtherTime_) / 60)

    def HoursTo(_oOtherTime_)
        return floor(This.SecsTo(_oOtherTime_) / 3600)

    def IsBefore(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) > 0

    def IsAfter(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) < 0

    def IsEqualTo(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) = 0

        def IsEqual(_oOtherTime_)
            return This.IsEqualTo(_oOtherTime_)

    def IsBetween(_oStartTime_, _oEndTime_)
        if CheckParams()
            if isList(_oEndTime_) and IsAndNamedParamList(_oEndTime_)
                _oEndTime_ = _oEndTime_[2]
            ok
        ok

        if isString(_oStartTime_)
            _oTempStartTime_ = new stzTime(_oStartTime_)
			_oStartTime_ = _oTempStartTime_
        ok
        if isString(_oEndTime_)
            _oTempEndTime_ = new stzTime(_oEndTime_)
			_oEndTime_ = _oTempEndTime_
        ok

        return This.IsAfter(_oStartTime_) and This.IsBefore(_oEndTime_)

    #--- UTILITY CHECKS ---#

    def IsAM()
        return @nHour < 12

    def IsPM()
        return @nHour >= 12

    def IsMidnight()
        return @nHour = 0 and @nMinute = 0 and @nSecond = 0

    def IsNoon()
        return @nHour = 12 and @nMinute = 0 and @nSecond = 0

    def IsMorning()
        return @nHour >= 5 and @nHour < 12

    def IsAfternoon()
        return @nHour >= 12 and @nHour < 17

    def IsEvening()
        return @nHour >= 17 and @nHour < 21

    def IsNight()
        return @nHour >= 21 or @nHour < 5

    def IsWorkHours()
        return @nHour >= 9 and @nHour < 17

    def IsNow()
        pHandle = StzEngineTimeNow()
        _nNowH_ = StzEngineTimeHour(pHandle)
        _nNowM_ = StzEngineTimeMinute(pHandle)
        _nNowS_ = StzEngineTimeSecond(pHandle)
        StzEngineTimeFree(pHandle)
        _nNowTotal_ = (_nNowH_ * 3600) + (_nNowM_ * 60) + _nNowS_
        _nDiff_ = abs(This.SecondsSinceMidnight() - _nNowTotal_)
        return _nDiff_ < 60

    #--- GETTERS ---#

    def Hour()
        return @nHour

        def HourN()
            return @nHour

	def Hours()
		return @nHour

	def HoursN()
		return @nHour

	#--

	def ToHour()
		return @nHour

        def ToHourN()
            return @nHour

	def ToHours()
		return @nHour

	def ToHoursN()
		return @nHour

    def Minute()
        return @nMinute

        def MinuteN()
            return @nMinute

	def Minutes()
		return @nMinute

	def MinutesN()
		return @nMinute


    def Second()
        return @nSecond

        def SecondN()
            return @nSecond

        def Seconds()
            return @nSecond

        def SecondsN()
            return @nSecond


    def Millisecond()
		return @nMillisecond

        def MillisecondN()
            return @nMillisecond

	def Milliseconds()
		return @nMillisecond

	def MillisecondsN()
		return @nMillisecond


    def Hour12()
        if @nHour = 0
            return 12
        but @nHour > 12
            return @nHour - 12
        else
            return @nHour
        ok

	def Hour12N()
		return This.Hour12()

	def HourN12()
		return This.Hour12()

	def Hours12()
		return This.Hour12()

	def Hours12N()
		return This.Hour12()

	def HoursN12()
		return This.Hour12()

    def AMPM()
        if This.IsAM()
            return "AM"
        else
            return "PM"
        ok

    def SecondsSinceMidnight()
        return (@nHour * 3600) + (@nMinute * 60) + @nSecond

	def ToSecondsSinceMidnight()
		return This.SecondsSinceMidnight()

    def SecondsUntilMidnight()
        return 86400 - This.SecondsSinceMidnight()

	def ToSecondsUntilMidnight()
		return This.SecondsUntilMidnight()

    #--- SMART NAVIGATION ---#

    def NextHour()
        _oCopy_ = This.Copy()
        _oCopy_.AddSeconds(3600)
        return _oCopy_.ToString()

    def PreviousHour()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractSeconds(3600)
        return _oCopy_.ToString()

    def NextMinute()
        _oCopy_ = This.Copy()
        _oCopy_.AddSeconds(60)
        return _oCopy_.ToString()

    def PreviousMinute()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractSeconds(60)
        return _oCopy_.ToString()

    def RoundToNearestHour()
        if @nMinute >= 30
            _nNewHour_ = @nHour + 1
            if _nNewHour_ >= 24
                _nNewHour_ = 0
            ok
            @nHour = _nNewHour_
        ok
        @nMinute = 0
        @nSecond = 0
        @nMillisecond = 0
        return This.ToString()

    def RoundToNearestMinute()
        if @nSecond >= 30
            This.pvtAddTotalSeconds(60 - @nSecond)
        ok
        @nSecond = 0
        @nMillisecond = 0
        return This.ToString()

    def StartOfHour()
        return StzPadLeftXT(''+ @nHour, 2, "0") + ":00:00"

    def EndOfHour()
        return StzPadLeftXT(''+ @nHour, 2, "0") + ":59:59"

    #--- FORMATTING ---#

    def Content()
        return This.ToString()

    def Time()
        return This.ToString()

    def ToString()
        return This.ToStringXT("")

    def ToStringXT(_cFormat_)

        if _cFormat_ = ""
            _cFormat_ = $cDefaultTimeFormat
        ok
		_cLowerFormat_ = StzLower(_cFormat_)

		_cFormat_ = trim(_cFormat_)
		if StzRight(_cFormat_, 2) = "ap"

			return This.ToStringXT(StzLeft(_cFormat_, StzLen(_cFormat_)-2)) +
				   " " + This.AMPM()

		but _cFormat_ = "ampm"
			return This.ToString() + " " + This.AMPM()

		ok

        _nTimeFormats1Len_ = len($aTimeFormats)
        for _iLoopTimeFormats1_ = 1 to _nTimeFormats1Len_
        	_aFormat_ = $aTimeFormats[_iLoopTimeFormats1_]
            if StzLower(_aFormat_[1]) = _cLowerFormat_
                _cFormat_ = _aFormat_[2]
                exit
            ok
        next

		if _cFormat_ = "long"
			return This.ToLong()
		else
        	return This.pvtFormatTime(_cFormat_)
    	ok

    def To12Hour()
        return This.ToStringXT("h:mm:ss AP")

    def To24Hour()
        return This.ToStringXT("HH:mm:ss")

    def ToShort()
        return This.ToStringXT("hh:mm")

    def ToLong()
        return This.ToStringXT("hh:mm:ss.zzz")

    def ToSimple()
        return This.ToStringXT("h:mm") + " " + This.AMPM()

    #--- HUMAN-READABLE ---#

    def ToHuman()
        _nHour_ = This.Hour12()
        _nMinute_ = This.MinuteN()
        _cAmPm_ = This.AMPM()

        if _nMinute_ = 0
            return '' + _nHour_ + " o'clock " + _cAmPm_

        but _nMinute_ = 15
            return "Quarter past " + _nHour_ + " " + _cAmPm_

        but _nMinute_ = 30
            return "Half past " + _nHour_ + " " + _cAmPm_

        but _nMinute_ = 45
            return "Quarter to " + (_nHour_ + 1) + " " + _cAmPm_

        else
            return '' + _nHour_ + ":" + StzPadLeftXT(''+ _nMinute_, 2, "0") + " " + _cAmPm_
        ok

    def ToRelative()
        _oNow_ = new stzTime("")
        _nSecs_ = This.SecsTo(_oNow_)

        if abs(_nSecs_) < 60
            return "now"

        but _nSecs_ < 0  # In the past
            _nAbsSecs_ = -_nSecs_
            if _nAbsSecs_ < 3600
                _nMins_ = floor(_nAbsSecs_ / 60)
                return '' + _nMins_ + " minute" + Iff(_nMins_=1, "", "s") + " ago"

            else
                _nHours_ = floor(_nAbsSecs_ / 3600)
                return '' + _nHours_ + " hour" + Iff(_nHours_=1, "", "s") + " ago"
            ok

        else  # In the future
            if _nSecs_ < 3600
                _nMins_ = floor(_nSecs_ / 60)
                return "in " + _nMins_ + " minute" + Iff(_nMins_=1, "", "s")

           else
                _nHours_ = floor(_nSecs_ / 3600)
                return "in " + _nHours_ + " hour" + Iff(_nHours_=1, "", "s")
            ok
        ok

    def PartOfDay()
        if This.IsMorning()
            return "morning"

        but This.IsAfternoon()
            return "afternoon"

        but This.IsEvening()
            return "evening"

        else
            return "night"
        ok

    #--- UTILITY METHODS ---#

    def Copy()
        _oNewTime_ = new stzTime([:Hour = @nHour, :Minute = @nMinute, :Second = @nSecond, :Millisecond = @nMillisecond])
        return _oNewTime_

    def IsValid()
        return This.pvtIsValidHMS(@nHour, @nMinute, @nSecond, @nMillisecond)

    def IsAStzTime()
        return TRUE

    #--- PRIVATE HELPERS ---#

    private

    def pvtIsValidHMS(_nH_, _nM_, _nS_, _nMs_)
        if _nH_ < 0 or _nH_ > 23
            return FALSE
        ok
        if _nM_ < 0 or _nM_ > 59
            return FALSE
        ok
        if _nS_ < 0 or _nS_ > 59
            return FALSE
        ok
        if _nMs_ < 0 or _nMs_ > 999
            return FALSE
        ok
        return TRUE

    def pvtAddTotalSeconds(_nSecs_)
        _nTotal_ = This.SecondsSinceMidnight() + _nSecs_
        _nTotal_ = _nTotal_ % 86400
        if _nTotal_ < 0
            _nTotal_ = _nTotal_ + 86400
        ok
        @nHour = floor(_nTotal_ / 3600)
        @nMinute = floor((_nTotal_ % 3600) / 60)
        @nSecond = _nTotal_ % 60

    def pvtToTotalMs()
        return (@nHour * 3600000) + (@nMinute * 60000) + (@nSecond * 1000) + @nMillisecond

    def pvtFromTotalMs(_nTotalMs_)
        _nTotalMs_ = _nTotalMs_ % 86400000
        if _nTotalMs_ < 0
            _nTotalMs_ = _nTotalMs_ + 86400000
        ok
        @nHour = floor(_nTotalMs_ / 3600000)
        _nRem_ = _nTotalMs_ % 3600000
        @nMinute = floor(_nRem_ / 60000)
        _nRem_ = _nRem_ % 60000
        @nSecond = floor(_nRem_ / 1000)
        @nMillisecond = _nRem_ % 1000

    def pvtFormatTime(_cFormat_)
        _cResult_ = _cFormat_

        _cResult_ = StzReplace(_cResult_, "HH", StzPadLeftXT(''+ @nHour, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "hh", StzPadLeftXT(''+ @nHour, 2, "0"))

        if StzFindFirst("h", _cResult_)
            _cResult_ = StzReplace(_cResult_, "h", ''+ @nHour)
        ok

        _cResult_ = StzReplace(_cResult_, "mm", StzPadLeftXT(''+ @nMinute, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "ss", StzPadLeftXT(''+ @nSecond, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "zzz", StzPadLeftXT(''+ @nMillisecond, 3, "0"))
        _cResult_ = StzReplace(_cResult_, "AP", This.AMPM())

        return _cResult_
