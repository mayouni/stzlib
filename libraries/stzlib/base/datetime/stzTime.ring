
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

# TRUE if the text is one or more digits and nothing else. Ring's isdigit() tests only the first
# character, so "23" passed but a two-digit part such as "23" in 23:00 was the very case it missed.
func _IsAllDigits(_cText_)
    if not isString(_cText_)
        return 0
    ok
    _nTextLen_ = len(_cText_)
    if _nTextLen_ = 0
        return 0
    ok
    for _i_ = 1 to _nTextLen_
        if not isdigit(_cText_[_i_])
            return 0
        ok
    next
    return 1

func StzIsTime(str)
    if not isString(str) or StzLen(str) = 0
        return 0
    ok

    _aParts_ = split(str, ":")
    if len(_aParts_) < 2 or len(_aParts_) > 3
        _cUpper_ = StzUpper(str)
        if StzRight(_cUpper_, 3) = " AM" or StzRight(_cUpper_, 3) = " PM"
            _cCore_ = trim(StzLeft(str, StzLen(str) - 3))
            _aParts_ = split(_cCore_, ":")
            if len(_aParts_) < 2 or len(_aParts_) > 3
                return 0
            ok
        else
            return 0
        ok
    ok

    _nPartsLen_ = len(_aParts_)
    for i = 1 to _nPartsLen_
        _cPart_ = _aParts_[i]
        if i = len(_aParts_) and StzFindFirst(".", _cPart_)
            _aSubParts_ = split(_cPart_, ".")
            _cPart_ = _aSubParts_[1]
        ok
        if not _IsAllDigits(_cPart_)
            return 0
        ok
    next

    _nH_ = 0+ _aParts_[1]
    _nM_ = 0+ _aParts_[2]
    if _nH_ < 0 or _nH_ > 23 or _nM_ < 0 or _nM_ > 59
        return 0
    ok
    if len(_aParts_) = 3
        _cSecPart_ = _aParts_[3]
        if StzFindFirst(".", _cSecPart_)
            _aSubParts_ = split(_cSecPart_, ".")
            _cSecPart_ = _aSubParts_[1]
        ok
        _nS_ = 0+ _cSecPart_
        if _nS_ < 0 or _nS_ > 59
            return 0
        ok
    ok

    return 1

    func IsTime(str)
        return StzIsTime(str)

    func StzIsValidTime(str)
        return StzIsTime(str)

    func IsValidTime(str)
        return StzIsTime(str)

# Holds one time of day (hour, minute, second, millisecond) with no date, moves it around the clock, compares it and writes it in several formats.
#
# A stzTime is four numbers and never knows the day: adding 10 hours to 14:30 gives 00:30 and 23:00
# is not before 01:00. Build it from a text (14:30, 14:30:15.250, 2:30 PM with a space before PM),
# from a number of seconds since midnight, from a hash with :Hour, :Minute, :Second and
# :Millisecond, or from an empty text for the clock now (the engine clock, which ran an hour behind
# Ring time() on this machine). The Add and Subtract methods move the object itself and answer the
# new HH:mm:ss text (the Q forms answer the object so calls chain); the Next and Previous methods
# answer a text and leave the object alone. Measure with SecsTo, MinutesTo and HoursTo, compare with
# IsBefore, IsAfter, IsEqualTo and IsBetween (to the second: the milliseconds are ignored), ask
# about the day with IsMorning, IsNight, IsWorkHours and PartOfDay, and write it with ToString,
# ToShort, ToLong or ToStringXT. Hours, Minutes, Seconds and Milliseconds are the parts of the time,
# not totals. Known gaps today, each carried as a warning on its method: To12Hour, ToSimple and the
# AP formats keep the 24-hour hour, ToHuman words the quarter-to wrongly at 11:45, 12:45, 23:45 and
# 00:45, ToRelative reads past as future, new stzTime(0) reads the clock, MSecsTo reads a time text
# as midnight, and the operators and comparisons refuse a time text such as 15:45 because StzIsTime
# accepts only one-digit parts.
#
#   receiver   o1 = new stzTime("14:30:00")
#   example    ? o1.AddMinutes(45)
#              #--> 15:15:00
#   see        stzDateTime, stzDate, stzCalendar
class stzTime from stzObject
    @nHour = 0
    @nMinute = 0
    @nSecond = 0
    @nMillisecond = 0

    # Builds the time of day from a time text, a number of seconds since midnight, a hash of parts, or the clock when the text is empty.
    #
    #   pTime      a time text such as 14:30:15.250 or 2:30 PM, a number of seconds since midnight
    #              such as 3661, a hash [ :Hour = 8, :Minute = 5, :Second = 9, :Millisecond = 45 ],
    #              or an empty text for now
    #   returns    nothing; the object is built
    #   note       digits after a dot are a whole number of milliseconds, so .5 is 5 ms and .250 is
    #              250 ms; an empty text reads the engine clock, which showed one hour less than
    #              Ring time() on this machine; hash keys are the singular :Hour, :Minute, :Second,
    #              :Millisecond and a missing one is 0
    #   warning    the number 0 reads the current clock instead of midnight (0 equals an empty text
    #              in Ring); a negative number or one of 86400 and more raises Invalid time
    #              provided!; a fraction of a second gives a broken second (01:01:1.50); a plain
    #              list [ 8, 5, 9 ] is ignored and gives 00:00:00; 2:30pm without a space before PM
    #              raises R41; hour 24, minute 60 and second 60 raise Invalid time provided!
    #   see        ParseStringTime, Copy
    def init(pTime)

        # the number 0 equals "" in Ring, so only a text can ask for the clock
        if isString(pTime) and (IsNull(pTime) or pTime = "")
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

    # Sets the time from a text of hours and minutes, with seconds, milliseconds and AM or PM when present.
    #
    #   _cTime_    the time text, such as 07:45:10.500 or 3:15 PM, with a space before AM or PM
    #   returns    nothing; the object changes in place
    #   note       12:xx AM becomes hour 0 and a PM hour below 12 gets 12 added; an hour of 13 or
    #              more with PM is kept as given
    #   warning    does not check ranges: 25:61:61 is stored and IsValid then answers FALSE; a text
    #              without two or three parts separated by : raises Cannot parse time string
    #   see        init, IsValid
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

    # Moves the time forward by n seconds, or back when n is negative, wrapping around midnight, and answers the new time text.
    #
    #   _nSeconds_   the number of seconds to add
    #   returns      the new time as HH:mm:ss text, without milliseconds
    #   note         changes the object in place and keeps its milliseconds; 23:59:30 plus 45
    #                seconds is 00:00:15; AddSecondsQ answers the object so calls chain
    #   warning      a fractional count leaves a fractional second in the object (12:00:0.50)
    #   see          SubtractSeconds, AddMinutes
    def AddSeconds(_nSeconds_)
        This.pvtAddTotalSeconds(_nSeconds_)
        return This.ToString()

    def AddSecondsQ(_nSeconds_)
        This.AddSeconds(_nSeconds_)
        return This

    # Moves the time forward by n minutes, or back when n is negative, wrapping around midnight, and answers the new time text.
    #
    #   _nMinutes_   the number of minutes to add
    #   returns      the new time as HH:mm:ss text, without milliseconds
    #   note         changes the object in place; AddMinutesQ answers the object so calls chain
    #   see          SubtractMinutes, AddHours
    def AddMinutes(_nMinutes_)
        This.pvtAddTotalSeconds(_nMinutes_ * 60)
        return This.ToString()

    def AddMinutesQ(_nMinutes_)
        This.AddMinutes(_nMinutes_)
        return This

    # Moves the time forward by n hours, or back when n is negative, wrapping around midnight, and answers the new time text.
    #
    #   _nHours_   the number of hours to add, a half hour is 0.5
    #   returns    the new time as HH:mm:ss text, without milliseconds
    #   note       changes the object in place; the date is not tracked, so 14:30 plus 10 hours is
    #              00:30; AddHoursQ answers the object so calls chain
    #   see        SubtractHours, AddMinutes
    def AddHours(_nHours_)
        This.pvtAddTotalSeconds(_nHours_ * 3600)
        return This.ToString()

    def AddHoursQ(_nHours_)
        This.AddHours(_nHours_)
        return This

    # Moves the time forward by n milliseconds, carrying into seconds and wrapping around midnight, and answers the new time text.
    #
    #   _nMs_      the number of milliseconds to add
    #   returns    the new time as HH:mm:ss text, without milliseconds
    #   note       changes the object in place; the milliseconds show in ToLong, not in the answer;
    #              23:59:59.900 plus 200 is 00:00:00.100; AddMillisecondsQ answers the object
    #   see        SubtractMilliseconds, AddSeconds
    def AddMilliseconds(_nMs_)
        _nTotalMs_ = This.pvtToTotalMs() + _nMs_
        This.pvtFromTotalMs(_nTotalMs_)
        return This.ToString()

    def AddMillisecondsQ(_nMs_)
        This.AddMilliseconds(_nMs_)
        return This

    # Moves the time back by n seconds, wrapping around midnight, and answers the new time text.
    #
    #   _nSeconds_   the number of seconds to subtract
    #   returns      the new time as HH:mm:ss text, without milliseconds
    #   note         changes the object in place; 00:00:10 minus 20 seconds is 23:59:50;
    #                SubtractSecondsQ answers the object
    #   see          AddSeconds, SubtractMinutes
    def SubtractSeconds(_nSeconds_)
        This.pvtAddTotalSeconds(-_nSeconds_)
        return This.ToString()

    def SubtractSecondsQ(_nSeconds_)
        This.SubtractSeconds(_nSeconds_)
        return This

    # Moves the time back by n minutes, wrapping around midnight, and answers the new time text.
    #
    #   _nMinutes_   the number of minutes to subtract
    #   returns      the new time as HH:mm:ss text, without milliseconds
    #   note         changes the object in place; SubtractMinutesQ answers the object so calls chain
    #   see          AddMinutes, SubtractHours
    def SubtractMinutes(_nMinutes_)
        This.pvtAddTotalSeconds(-_nMinutes_ * 60)
        return This.ToString()

    def SubtractMinutesQ(_nMinutes_)
        This.SubtractMinutes(_nMinutes_)
        return This

    # Moves the time back by n hours, wrapping around midnight, and answers the new time text.
    #
    #   _nHours_   the number of hours to subtract
    #   returns    the new time as HH:mm:ss text, without milliseconds
    #   note       changes the object in place; 00:30 minus 1 hour is 23:30; SubtractHoursQ answers
    #              the object
    #   see        AddHours, SubtractMinutes
    def SubtractHours(_nHours_)
        This.pvtAddTotalSeconds(-_nHours_ * 3600)
        return This.ToString()

    def SubtractHoursQ(_nHours_)
        This.SubtractHours(_nHours_)
        return This

    # Moves the time back by n milliseconds, carrying into seconds and wrapping around midnight, and answers the new time text.
    #
    #   _nMs_      the number of milliseconds to subtract
    #   returns    the new time as HH:mm:ss text, without milliseconds
    #   note       changes the object in place; SubtractMillisecondsQ answers the object
    #   see        AddMilliseconds, SubtractSeconds
    def SubtractMilliseconds(_nMs_)
        _nTotalMs_ = This.pvtToTotalMs() - _nMs_
        This.pvtFromTotalMs(_nTotalMs_)
        return This.ToString()

    def SubtractMillisecondsQ(_nMs_)
        This.SubtractMilliseconds(_nMs_)
        return This

    #--- OPERATOR OVERLOADING ---#

    # Applies one of the operators + - < <= > >= = between the time and a number of seconds or another time.
    #
    #   op         the operator text: + - < <= > >= =
    #   v          the right-hand value: a number of seconds or a stzTime object
    #   returns    for + and - with a number, the object itself; for - with a stzTime, the signed
    #              seconds; for a comparison, TRUE or FALSE
    #   note       whole seconds only, the milliseconds are ignored
    #   warning    + and - change the object itself and answer it; time minus time is this minus the
    #              other, negative when this is earlier; a time text as right-hand value answers
    #              nothing for - and for every comparison (StzIsTime reads only one-digit parts), as
    #              do + with anything but a number and any other operator
    #   see        SecsTo, IsBefore
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

    # Returns the signed number of whole seconds from the time to another one, negative when the other is earlier.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        a number of seconds; 4500 from 14:30:00 to 15:45:00
    #   note           works with a time text as well as an object
    #   warning        the day is not tracked: 23:00 to 01:00 is -79200, not 7200; milliseconds are
    #                  ignored
    #   see            MSecsTo, MinutesTo, HoursTo
    def SecsTo(_oOtherTime_)
        if isString(_oOtherTime_)
            _oTempTime_ = new stzTime(_oOtherTime_)
			_oOtherTime_ = _oTempTime_
        ok
        _nThisSecs_ = This.SecondsSinceMidnight()
        _nOtherSecs_ = _oOtherTime_.SecondsSinceMidnight()
        return _nOtherSecs_ - _nThisSecs_

    # Returns the signed number of milliseconds from the time to another one, negative when the other is earlier.
    #
    #   _oOtherTime_   the other time as a stzTime object
    #   returns        a number of milliseconds; 4484500 from 14:30:15.500 to 15:45:00
    #   note           the only distance that counts milliseconds
    #   warning        a time text is read as 00:00:00 (every text gives the same answer): the
    #                  parameter is overwritten by the object being built before it is read
    #   see            SecsTo
    def MSecsTo(_oOtherTime_)
        _oOther_ = _oOtherTime_
        if isString(_oOtherTime_)
            # built from a separate variable: Ring binds `x = new stzTime(x)` to x before init reads it
            _cOtherText_ = _oOtherTime_
            _oOther_ = new stzTime(_cOtherText_)
        ok
        _nThisMs_ = This.pvtToTotalMs()
        _nOtherMs_ = (_oOther_.HourN() * 3600000) + (_oOther_.MinuteN() * 60000) + (_oOther_.SecondN() * 1000) + _oOther_.MillisecondN()
        return _nOtherMs_ - _nThisMs_

    # Returns the number of whole minutes from the time to another one, rounded down.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        a number of minutes; 75 from 14:30:00 to 15:45:00
    #   note           built on SecsTo, so milliseconds are ignored
    #   warning        rounds down, so a negative distance of 330.25 minutes is -331
    #   see            HoursTo, SecsTo
    def MinutesTo(_oOtherTime_)
        return floor(This.SecsTo(_oOtherTime_) / 60)

    # Returns the number of whole hours from the time to another one, rounded down.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        a number of hours; 1 from 14:30:00 to 15:45:00
    #   note           built on SecsTo, so milliseconds are ignored
    #   warning        rounds down, so -5.5 hours is -6
    #   see            MinutesTo, SecsTo
    def HoursTo(_oOtherTime_)
        return floor(This.SecsTo(_oOtherTime_) / 3600)

    # TRUE if the time is strictly earlier than the other time within the day, compared to the second.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        TRUE or FALSE
    #   note           the day is not tracked: 23:00 is not before 01:00
    #   warning        milliseconds are ignored, so 14:30:15.500 is equal to 14:30:15.900
    #   see            IsAfter, IsEqualTo, SecsTo
    def IsBefore(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) > 0

    # TRUE if the time is strictly later than the other time within the day, compared to the second.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        TRUE or FALSE
    #   note           the day is not tracked
    #   warning        milliseconds are ignored
    #   see            IsBefore, IsEqualTo
    def IsAfter(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) < 0

    # TRUE if both times are the same to the second.
    #
    #   _oOtherTime_   the other time: a stzTime object or a time text
    #   returns        TRUE or FALSE
    #   note           IsEqual does the same
    #   warning        milliseconds are ignored, so 14:30:15.500 and 14:30:15.900 are equal
    #   see            IsBefore, IsAfter
    def IsEqualTo(_oOtherTime_)
        return This.SecsTo(_oOtherTime_) = 0

        def IsEqual(_oOtherTime_)
            return This.IsEqualTo(_oOtherTime_)

    # TRUE if the time is strictly after the start time and strictly before the end time, within the day.
    #
    #   _oStartTime_   the lower bound: a stzTime object or a time text
    #   _oEndTime_     the upper bound: a stzTime object or a time text
    #   returns        TRUE or FALSE
    #   note           the end bound may be written [ :And, oEnd ]
    #   warning        both bounds are excluded; a range that crosses midnight (22:00 to 02:00)
    #                  gives FALSE for every time
    #   see            IsBefore, IsAfter
    def IsBetween(_oStartTime_, _oEndTime_)
        _pEnd_ = _oEndTime_
        if CheckParams()
            if isList(_oEndTime_) and IsAndNamedParamList(_oEndTime_)
                _pEnd_ = _oEndTime_[2]
            ok
        ok

        # the bounds are read into locals: a list parameter is shared with the caller
        _oStart_ = _oStartTime_
        if isString(_oStartTime_)
            _oStart_ = new stzTime(_oStartTime_)
        ok
        _oEnd_ = _pEnd_
        if isString(_pEnd_)
            _oEnd_ = new stzTime(_pEnd_)
        ok

        return This.IsAfter(_oStart_) and This.IsBefore(_oEnd_)

    #--- UTILITY CHECKS ---#

    # TRUE if the hour is before 12, from midnight up to 11:59:59.
    #
    #   returns    TRUE or FALSE
    #   see        IsPM, AMPM
    def IsAM()
        return @nHour < 12

    # TRUE if the hour is 12 or later, from noon up to 23:59:59.
    #
    #   returns    TRUE or FALSE
    #   note       noon is PM
    #   see        IsAM, AMPM
    def IsPM()
        return @nHour >= 12

    # TRUE if the hour, minute and second are all 0.
    #
    #   returns    TRUE or FALSE
    #   note       milliseconds are ignored, so 00:00:00.500 is midnight
    #   see        IsNoon
    def IsMidnight()
        return @nHour = 0 and @nMinute = 0 and @nSecond = 0

    # TRUE if the time is 12:00:00.
    #
    #   returns    TRUE or FALSE
    #   note       milliseconds are ignored
    #   see        IsMidnight
    def IsNoon()
        return @nHour = 12 and @nMinute = 0 and @nSecond = 0

    # TRUE if the time is from 05:00 up to 11:59:59.
    #
    #   returns    TRUE or FALSE
    #   note       midnight to 04:59:59 is night, not morning
    #   see        IsAfternoon, PartOfDay
    def IsMorning()
        return @nHour >= 5 and @nHour < 12

    # TRUE if the time is from 12:00 up to 16:59:59.
    #
    #   returns    TRUE or FALSE
    #   note       noon is afternoon
    #   see        IsMorning, IsEvening, PartOfDay
    def IsAfternoon()
        return @nHour >= 12 and @nHour < 17

    # TRUE if the time is from 17:00 up to 20:59:59.
    #
    #   returns    TRUE or FALSE
    #   see        IsAfternoon, IsNight, PartOfDay
    def IsEvening()
        return @nHour >= 17 and @nHour < 21

    # TRUE if the time is from 21:00 up to 04:59:59, across midnight.
    #
    #   returns    TRUE or FALSE
    #   see        IsEvening, PartOfDay
    def IsNight()
        return @nHour >= 21 or @nHour < 5

    # TRUE if the time is from 09:00 up to 16:59:59.
    #
    #   returns    TRUE or FALSE
    #   note       the lunch hour is included; the range is fixed
    #   see        IsMorning
    def IsWorkHours()
        return @nHour >= 9 and @nHour < 17

    # TRUE if the time is within 60 seconds of the engine clock now, in either direction.
    #
    #   returns    TRUE or FALSE
    #   note       reads the engine clock, which showed one hour less than Ring time() on this
    #              machine; midnight wrap is not handled
    #   see        ToRelative
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

    # Returns the hour of the time, from 0 to 23.
    #
    #   returns    a number from 0 to 23
    #   note       the same as HourN, Hours and ToHour
    #   see        Hour12, Minute
    def Hour()
        return @nHour

        # Returns the hour of the time, from 0 to 23.
        #
        #   returns    a number from 0 to 23
        #   see        Hour
        def HourN()
            return @nHour

	# Returns the hour of the time, from 0 to 23, not a count of hours.
	#
	#   returns    a number from 0 to 23
	#   note       the same as Hour
	#   see        Hour
	def Hours()
		return @nHour

	# Returns the hour of the time, from 0 to 23, not a count of hours.
	#
	#   returns    a number from 0 to 23
	#   see        Hour
	def HoursN()
		return @nHour

	# Returns the hour of the time, from 0 to 23.
	#
	#   returns    a number from 0 to 23
	#   see        Hour
	#@ aka  --
	def ToHour()
		return @nHour

        # Returns the hour of the time, from 0 to 23.
        #
        #   returns    a number from 0 to 23
        #   see        Hour
        def ToHourN()
            return @nHour

	# Returns the hour of the time, from 0 to 23, not a count of hours.
	#
	#   returns    a number from 0 to 23
	#   see        Hour
	def ToHours()
		return @nHour

	# Returns the hour of the time, from 0 to 23, not a count of hours.
	#
	#   returns    a number from 0 to 23
	#   see        Hour
	def ToHoursN()
		return @nHour

    # Returns the minute of the hour, from 0 to 59.
    #
    #   returns    a number from 0 to 59
    #   note       the same as MinuteN and Minutes
    #   see        Hour, Second
    def Minute()
        return @nMinute

        # Returns the minute of the hour, from 0 to 59.
        #
        #   returns    a number from 0 to 59
        #   see        Minute
        def MinuteN()
            return @nMinute

	# Returns the minute of the hour, from 0 to 59, not a count of minutes.
	#
	#   returns    a number from 0 to 59
	#   note       for a total use SecondsSinceMidnight; a caller that reads this as minutes since
	#              midnight gets the minute only
	#   see        Minute, SecondsSinceMidnight
	def Minutes()
		return @nMinute

	# Returns the minute of the hour, from 0 to 59, not a count of minutes.
	#
	#   returns    a number from 0 to 59
	#   see        Minute
	def MinutesN()
		return @nMinute


    # Returns the second of the minute, from 0 to 59.
    #
    #   returns    a number from 0 to 59
    #   note       the same as SecondN and Seconds
    #   see        Minute, Millisecond
    def Second()
        return @nSecond

        # Returns the second of the minute, from 0 to 59.
        #
        #   returns    a number from 0 to 59
        #   see        Second
        def SecondN()
            return @nSecond

        # Returns the second of the minute, from 0 to 59, not a count of seconds.
        #
        #   returns    a number from 0 to 59
        #   see        Second, SecondsSinceMidnight
        def Seconds()
            return @nSecond

        # Returns the second of the minute, from 0 to 59, not a count of seconds.
        #
        #   returns    a number from 0 to 59
        #   see        Second
        def SecondsN()
            return @nSecond


    # Returns the millisecond part of the time, from 0 to 999.
    #
    #   returns    a number from 0 to 999
    #   note       the same as MillisecondN and Milliseconds
    #   see        Second
    def Millisecond()
		return @nMillisecond

        # Returns the millisecond part of the time, from 0 to 999.
        #
        #   returns    a number from 0 to 999
        #   see        Millisecond
        def MillisecondN()
            return @nMillisecond

	# Returns the millisecond part of the time, from 0 to 999, not a count of milliseconds.
	#
	#   returns    a number from 0 to 999
	#   see        Millisecond
	def Milliseconds()
		return @nMillisecond

	# Returns the millisecond part of the time, from 0 to 999, not a count of milliseconds.
	#
	#   returns    a number from 0 to 999
	#   see        Millisecond
	def MillisecondsN()
		return @nMillisecond


    # Returns the hour on a 12-hour clock, from 1 to 12, with midnight and noon both 12.
    #
    #   returns    a number from 1 to 12
    #   note       14:30 is 2 and 00:05 is 12
    #   see        AMPM, Hour
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

    # Returns AM for a time before noon and PM from noon on.
    #
    #   returns    the text AM or PM
    #   see        IsAM, Hour12
    def AMPM()
        if This.IsAM()
            return "AM"
        else
            return "PM"
        ok

    # Returns the number of seconds elapsed since 00:00:00, whole seconds only.
    #
    #   returns    a number from 0 to 86399; 52200 for 14:30:00
    #   note       milliseconds are ignored
    #   see        SecondsUntilMidnight, SecsTo
    def SecondsSinceMidnight()
        return (@nHour * 3600) + (@nMinute * 60) + @nSecond

	def ToSecondsSinceMidnight()
		return This.SecondsSinceMidnight()

    # Returns the number of seconds left until the next midnight, 86400 minus the seconds since midnight.
    #
    #   returns    a number from 1 to 86400; 34200 for 14:30:00
    #   note       exactly midnight gives 86400, not 0
    #   see        SecondsSinceMidnight
    def SecondsUntilMidnight()
        return 86400 - This.SecondsSinceMidnight()

	def ToSecondsUntilMidnight()
		return This.SecondsUntilMidnight()

    #--- SMART NAVIGATION ---#

    # Returns the time one hour later as HH:mm:ss text, wrapping around midnight, leaving the object unchanged.
    #
    #   returns    a time text such as 15:30:00
    #   note       23:45:20 gives 00:45:20; AddHours moves the object itself
    #   see        PreviousHour, AddHours
    def NextHour()
        _oCopy_ = This.Copy()
        _oCopy_.AddSeconds(3600)
        return _oCopy_.ToString()

    # Returns the time one hour earlier as HH:mm:ss text, wrapping around midnight, leaving the object unchanged.
    #
    #   returns    a time text such as 13:30:00
    #   note       00:10 gives 23:10
    #   see        NextHour, SubtractHours
    def PreviousHour()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractSeconds(3600)
        return _oCopy_.ToString()

    # Returns the time one minute later as HH:mm:ss text, wrapping around midnight, leaving the object unchanged.
    #
    #   returns    a time text such as 14:31:00
    #   see        PreviousMinute, AddMinutes
    def NextMinute()
        _oCopy_ = This.Copy()
        _oCopy_.AddSeconds(60)
        return _oCopy_.ToString()

    # Returns the time one minute earlier as HH:mm:ss text, wrapping around midnight, leaving the object unchanged.
    #
    #   returns    a time text such as 14:29:00
    #   see        NextMinute, SubtractMinutes
    def PreviousMinute()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractSeconds(60)
        return _oCopy_.ToString()

    # Rounds the time to the nearest hour, up from 30 minutes, clears seconds and milliseconds, and answers the new text.
    #
    #   returns    the new time as HH:mm:ss text
    #   note       changes the object in place; only the minute decides (14:29:59.999 goes down,
    #              14:30:00 goes up); 23:30 wraps to 00:00:00
    #   see        RoundToNearestMinute, StartOfHour
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

    # Rounds the time to the nearest minute, up from 30 seconds, clears the milliseconds, and answers the new text.
    #
    #   returns    the new time as HH:mm:ss text
    #   note       changes the object in place; only the second decides, so 10:15:29.600 goes down
    #              and 10:15:30.600 goes up; 23:59:30 wraps to 00:00:00
    #   see        RoundToNearestHour
    def RoundToNearestMinute()
        if @nSecond >= 30
            This.pvtAddTotalSeconds(60 - @nSecond)
        ok
        @nSecond = 0
        @nMillisecond = 0
        return This.ToString()

    # Returns the first second of the time's hour as HH:00:00 text, leaving the object unchanged.
    #
    #   returns    a time text such as 14:00:00
    #   see        EndOfHour, RoundToNearestHour
    def StartOfHour()
        return StzPadLeftXT(''+ @nHour, 2, "0") + ":00:00"

    # Returns the last second of the time's hour as HH:59:59 text, leaving the object unchanged.
    #
    #   returns    a time text such as 14:59:59
    #   note       the milliseconds are not part of the answer
    #   see        StartOfHour
    def EndOfHour()
        return StzPadLeftXT(''+ @nHour, 2, "0") + ":59:59"

    #--- FORMATTING ---#

    def Content()
        return This.ToString()

    def Time()
        return This.ToString()

    # Returns the time as hh:mm:ss text on a 24-hour clock, without milliseconds.
    #
    #   returns    a time text such as 14:30:00
    #   note       Content and Time give the same text; ToStringXT takes a format made of HH, hh, h,
    #              mm, ss, zzz and AP, or a name (short, long, withms, military, ampm, simple)
    #   see        ToLong, To24Hour, ToShort
    def ToString()
        return This.ToStringXT("")

    def ToStringXT(_cFormat_)

        if _cFormat_ = ""
            _cFormat_ = $cDefaultTimeFormat
        ok
		_cLowerFormat_ = StzLower(_cFormat_)

		_cFormat_ = trim(_cFormat_)
		if StzRight(_cFormat_, 2) = "ap"

			return This.ToStringXT(trim(StzLeft(_cFormat_, StzLen(_cFormat_)-2)) + " AP")

		but _cFormat_ = "ampm"
			return This.ToStringXT("h:mm:ss AP")

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

    # Returns the time as h:mm:ss text followed by AM or PM, meant to be on a 12-hour clock.
    #
    #   returns    a time text such as 14:30:00 PM
    #   note       Hour12 holds the 12-hour hour
    #   warning    the hour is NOT converted: 14:30 gives 14:30:00 PM and 00:05 gives 0:05:09 AM,
    #              because the h token prints the 24-hour value
    #   see        To24Hour, ToSimple
    def To12Hour()
        return This.ToStringXT("h:mm:ss AP")

    # Returns the time as HH:mm:ss text on a 24-hour clock.
    #
    #   returns    a time text such as 14:30:00
    #   note       the same as ToString
    #   see        To12Hour, ToString
    def To24Hour()
        return This.ToStringXT("HH:mm:ss")

    # Returns the time as hh:mm text, without seconds.
    #
    #   returns    a time text such as 14:30
    #   see        ToString, ToLong
    def ToShort()
        return This.ToStringXT("hh:mm")

    # Returns the time as hh:mm:ss.zzz text, with the milliseconds.
    #
    #   returns    a time text such as 14:30:15.250
    #   note       the only text form that shows the milliseconds
    #   see        ToString, ToShort
    def ToLong()
        return This.ToStringXT("hh:mm:ss.zzz")

    # Returns the time as h:mm text followed by AM or PM, meant to be on a 12-hour clock.
    #
    #   returns    a time text such as 14:30 PM
    #   note       the hour has no leading zero
    #   warning    the hour is NOT converted: 14:30 gives 14:30 PM and 00:05 gives 0:05 AM
    #   see        To12Hour, ToHuman
    def ToSimple()
        return This.ToStringXT("h:mm AP")

    #--- HUMAN-READABLE ---#

    # Returns the time in words, such as 2 o'clock PM, Quarter past 2 PM, Half past 2 PM, Quarter to 3 PM, or 2:07 PM.
    #
    #   returns    a short English sentence
    #   note       only 0, 15, 30 and 45 minutes get a word form
    #   warning    at 11:45, 12:45, 23:45 and 00:45 the quarter-to form is wrong: it adds 1 to the
    #              12-hour hour and keeps the AM or PM (12:45 gives Quarter to 13 PM, 11:45 gives
    #              Quarter to 12 AM)
    #   see        ToSimple, ToRelative
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
            _nNextHour_ = (@nHour + 1) % 24
            return "Quarter to " + StzConvertTo12Hour(_nNextHour_) + " " + StzGetAmPmText(_nNextHour_)

        else
            return '' + _nHour_ + ":" + StzPadLeftXT(''+ _nMinute_, 2, "0") + " " + _cAmPm_
        ok

    # Returns the time as a distance from the clock now, such as now, 10 minutes ago or in 3 hours.
    #
    #   returns    text such as now, 10 minutes ago or in 3 hours
    #   note       within 60 seconds is now; under an hour counts minutes, else hours; the day is
    #              not tracked; reads the engine clock
    #   warning    the direction is reversed: a time 10 minutes in the past reads in 10 minutes, and
    #              a time 5 hours ahead reads 5 hours ago, because the sign of SecsTo is read the
    #              wrong way
    #   see        ToHuman, IsNow
    def ToRelative()
        _oNow_ = new stzTime("")
        # this minus now: negative is the past, positive the future
        _nSecs_ = -This.SecsTo(_oNow_)

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

    # Returns morning, afternoon, evening or night for the time, by the hour.
    #
    #   returns    the text morning, afternoon, evening or night
    #   note       05:00 to 11:59 morning, 12:00 to 16:59 afternoon, 17:00 to 20:59 evening, 21:00
    #              to 04:59 night
    #   see        IsMorning, IsNight
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

    # Returns a new stzTime holding the same hour, minute, second and millisecond, so the copy can change without the original.
    #
    #   returns    a new stzTime object
    #   see        init
    def Copy()
        _oNewTime_ = new stzTime([:Hour = @nHour, :Minute = @nMinute, :Second = @nSecond, :Millisecond = @nMillisecond])
        return _oNewTime_

    # TRUE if the hour, minute, second and millisecond are all inside their ranges.
    #
    #   returns    TRUE or FALSE
    #   note       FALSE appears after ParseStringTime was given 25:61:61, since init refuses such
    #              values
    #   see        ParseStringTime, init
    def IsValid()
        return This.pvtIsValidHMS(@nHour, @nMinute, @nSecond, @nMillisecond)

    # TRUE if the value is a stzTime, which every stzTime object answers, so other code can tell it from another value.
    #
    #   returns    TRUE
    #   see        IsValid
    def IsAStzTime()
        return 1

    #--- PRIVATE HELPERS ---#

    private

    # Checks that hour is 0 to 23, minute 0 to 59, second 0 to 59 and millisecond 0 to 999.
    #
    #   _nH_       the hour
    #   _nM_       the minute
    #   _nS_       the second
    #   _nMs_      the millisecond
    #   returns    TRUE or FALSE
    #   note       a private helper that IsValid and the constructor call; a fractional second
    #              passes
    #   see        IsValid
    def pvtIsValidHMS(_nH_, _nM_, _nS_, _nMs_)
        if _nH_ < 0 or _nH_ > 23
            return 0
        ok
        if _nM_ < 0 or _nM_ > 59
            return 0
        ok
        if _nS_ < 0 or _nS_ > 59
            return 0
        ok
        if _nMs_ < 0 or _nMs_ > 999
            return 0
        ok
        return 1

    # Adds n seconds to the seconds since midnight and sets hour, minute and second from the sum, wrapping within 24 hours.
    #
    #   _nSecs_    the number of seconds to add, negative to go back
    #   returns    nothing; the object changes in place
    #   note       a private helper behind the Add and Subtract methods for seconds, minutes and
    #              hours; the milliseconds are kept
    #   see        AddSeconds
    def pvtAddTotalSeconds(_nSecs_)
        _nTotal_ = This.SecondsSinceMidnight() + _nSecs_
        _nTotal_ = _nTotal_ % 86400
        if _nTotal_ < 0
            _nTotal_ = _nTotal_ + 86400
        ok
        @nHour = floor(_nTotal_ / 3600)
        @nMinute = floor((_nTotal_ % 3600) / 60)
        @nSecond = _nTotal_ % 60

    # Returns the milliseconds elapsed since 00:00:00, counting hour, minute, second and millisecond.
    #
    #   returns    a number of milliseconds
    #   note       a private helper behind AddMilliseconds and MSecsTo
    #   see        pvtFromTotalMs, MSecsTo
    def pvtToTotalMs()
        return (@nHour * 3600000) + (@nMinute * 60000) + (@nSecond * 1000) + @nMillisecond

    # Sets hour, minute, second and millisecond from a count of milliseconds since midnight, wrapping within 24 hours.
    #
    #   _nTotalMs_   the count of milliseconds since midnight, negative counts wrap backwards
    #   returns      nothing; the object changes in place
    #   note         a private helper behind AddMilliseconds and SubtractMilliseconds
    #   see          pvtToTotalMs
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

    # Replaces the tokens HH, hh, h, mm, ss, zzz and AP in a format text by the parts of the time.
    #
    #   _cFormat_   the format text, made of the tokens HH, hh, h, mm, ss, zzz and AP
    #   returns     the format text filled in
    #   note        a private helper behind ToString and the other format methods; hh, HH and h all
    #               print the 24-hour value
    #   warning     any other letter that equals a token is replaced too, so a quoted h in hh 'h' mm
    #               becomes the hour
    #   see         ToString
    def pvtFormatTime(_cFormat_)
        _cResult_ = _cFormat_

        # with an AP marker the clock is the 12-hour one, so h and hh print the 12-hour hour
        _nShownHour_ = @nHour
        if StzFindFirst("AP", _cFormat_) > 0
            _nShownHour_ = This.Hour12()
        ok

        _cResult_ = StzReplace(_cResult_, "HH", StzPadLeftXT(''+ @nHour, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "hh", StzPadLeftXT(''+ _nShownHour_, 2, "0"))

        if StzFindFirst("h", _cResult_)
            _cResult_ = StzReplace(_cResult_, "h", ''+ _nShownHour_)
        ok

        _cResult_ = StzReplace(_cResult_, "mm", StzPadLeftXT(''+ @nMinute, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "ss", StzPadLeftXT(''+ @nSecond, 2, "0"))
        _cResult_ = StzReplace(_cResult_, "zzz", StzPadLeftXT(''+ @nMillisecond, 3, "0"))
        _cResult_ = StzReplace(_cResult_, "AP", This.AMPM())

        return _cResult_
