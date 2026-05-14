
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

func NowTime()
    return StzTimeQ("").ToString()

func IsTime(str)
    if not isString(str) or len(str) = 0
        return FALSE
    ok

    aParts = split(str, ":")
    if len(aParts) < 2 or len(aParts) > 3
        cUpper = upper(str)
        if right(cUpper, 3) = " AM" or right(cUpper, 3) = " PM"
            cCore = trim(left(str, len(str) - 3))
            aParts = split(cCore, ":")
            if len(aParts) < 2 or len(aParts) > 3
                return FALSE
            ok
        else
            return FALSE
        ok
    ok

    for i = 1 to len(aParts)
        cPart = aParts[i]
        if i = len(aParts) and substr(cPart, ".")
            aSubParts = split(cPart, ".")
            cPart = aSubParts[1]
        ok
        if not isdigit(cPart)
            return FALSE
        ok
    next

    nH = 0+ aParts[1]
    nM = 0+ aParts[2]
    if nH < 0 or nH > 23 or nM < 0 or nM > 59
        return FALSE
    ok
    if len(aParts) = 3
        cSecPart = aParts[3]
        if substr(cSecPart, ".")
            aSubParts = split(cSecPart, ".")
            cSecPart = aSubParts[1]
        ok
        nS = 0+ cSecPart
        if nS < 0 or nS > 59
            return FALSE
        ok
    ok

    return TRUE

    func IsValidTime(str)
        return IsTime(str)

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
            nHours = floor(pTime / 3600)
            nMinutes = floor((pTime % 3600) / 60)
            nSeconds = pTime % 60
            @nHour = nHours
            @nMinute = nMinutes
            @nSecond = nSeconds
            @nMillisecond = 0

        but isList(pTime) and IsHashList(pTime)
            nHour   = 0
            nMinute = 0
            nSecond = 0
            nMs     = 0

            if HasKey(pTime, :Hour)
                nHour = 0+ pTime[:Hour]
            ok

            if HasKey(pTime, :Minute)
                nMinute = 0+ pTime[:Minute]
            ok

            if HasKey(pTime, :Second)
                nSecond = 0+ pTime[:Second]
            ok

            if HasKey(pTime, :Millisecond)
                nMs = 0+ pTime[:Millisecond]
            ok

            @nHour = nHour
            @nMinute = nMinute
            @nSecond = nSecond
            @nMillisecond = nMs
        ok

        if not This.pvtIsValidHMS(@nHour, @nMinute, @nSecond, @nMillisecond)
            StzRaise("Invalid time provided!")
        ok

    def ParseStringTime(cTime)
        cTime = trim(cTime)

        cAmPm = ""
        cUpper = upper(cTime)
        if right(cUpper, 3) = " AM" or right(cUpper, 3) = " PM"
            cAmPm = upper(right(cTime, 2))
            cTime = trim(left(cTime, len(cTime) - 3))
        ok

        aParts = split(cTime, ":")
        if len(aParts) < 2 or len(aParts) > 3
            StzRaise("Cannot parse time string: " + cTime)
        ok

        nH = 0+ aParts[1]
        nM = 0+ aParts[2]
        nS = 0
        nMs = 0

        if len(aParts) = 3
            cSecPart = aParts[3]
            if substr(cSecPart, ".")
                aSubParts = split(cSecPart, ".")
                nS = 0+ aSubParts[1]
                if len(aSubParts) > 1
                    nMs = 0+ aSubParts[2]
                ok
            else
                nS = 0+ cSecPart
            ok
        ok

        if cAmPm = "PM" and nH < 12
            nH = nH + 12
        but cAmPm = "AM" and nH = 12
            nH = 0
        ok

        @nHour = nH
        @nMinute = nM
        @nSecond = nS
        @nMillisecond = nMs

    #--- ARITHMETIC OPERATIONS ---#

    def AddSeconds(nSeconds)
        This.pvtAddTotalSeconds(nSeconds)
        return This.ToString()

    def AddSecondsQ(nSeconds)
        This.AddSeconds(nSeconds)
        return This

    def AddMinutes(nMinutes)
        This.pvtAddTotalSeconds(nMinutes * 60)
        return This.ToString()

    def AddMinutesQ(nMinutes)
        This.AddMinutes(nMinutes)
        return This

    def AddHours(nHours)
        This.pvtAddTotalSeconds(nHours * 3600)
        return This.ToString()

    def AddHoursQ(nHours)
        This.AddHours(nHours)
        return This

    def AddMilliseconds(nMs)
        nTotalMs = This.pvtToTotalMs() + nMs
        This.pvtFromTotalMs(nTotalMs)
        return This.ToString()

    def AddMillisecondsQ(nMs)
        This.AddMilliseconds(nMs)
        return This

    def SubtractSeconds(nSeconds)
        This.pvtAddTotalSeconds(-nSeconds)
        return This.ToString()

    def SubtractSecondsQ(nSeconds)
        This.SubtractSeconds(nSeconds)
        return This

    def SubtractMinutes(nMinutes)
        This.pvtAddTotalSeconds(-nMinutes * 60)
        return This.ToString()

    def SubtractMinutesQ(nMinutes)
        This.SubtractMinutes(nMinutes)
        return This

    def SubtractHours(nHours)
        This.pvtAddTotalSeconds(-nHours * 3600)
        return This.ToString()

    def SubtractHoursQ(nHours)
        This.SubtractHours(nHours)
        return This

    def SubtractMilliseconds(nMs)
        nTotalMs = This.pvtToTotalMs() - nMs
        This.pvtFromTotalMs(nTotalMs)
        return This.ToString()

    def SubtractMillisecondsQ(nMs)
        This.SubtractMilliseconds(nMs)
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
                oOtherTime = new stzTime(v)
                return -This.SecsTo(oOtherTime)

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
            if (isObject(v) and classname(v) = "stztime") or (isString(v) and IsTime(v))
                return This.IsEqualTo(v)
            ok
        ok

    #--- COMPARISON METHODS ---#

    def SecsTo(oOtherTime)
        if isString(oOtherTime)
            oTempTime = new stzTime(oOtherTime)
			oOtherTime = oTempTime
        ok
        nThisSecs = This.SecondsSinceMidnight()
        nOtherSecs = oOtherTime.SecondsSinceMidnight()
        return nOtherSecs - nThisSecs

    def MSecsTo(oOtherTime)
        if isString(oOtherTime)
            oOtherTime = new stzTime(oOtherTime)
        ok
        nThisMs = This.pvtToTotalMs()
        nOtherMs = (oOtherTime.HourN() * 3600000) + (oOtherTime.MinuteN() * 60000) + (oOtherTime.SecondN() * 1000) + oOtherTime.MillisecondN()
        return nOtherMs - nThisMs

    def MinutesTo(oOtherTime)
        return floor(This.SecsTo(oOtherTime) / 60)

    def HoursTo(oOtherTime)
        return floor(This.SecsTo(oOtherTime) / 3600)

    def IsBefore(oOtherTime)
        return This.SecsTo(oOtherTime) > 0

    def IsAfter(oOtherTime)
        return This.SecsTo(oOtherTime) < 0

    def IsEqualTo(oOtherTime)
        return This.SecsTo(oOtherTime) = 0

        def IsEqual(oOtherTime)
            return This.IsEqualTo(oOtherTime)

    def IsBetween(oStartTime, oEndTime)
        if CheckParams()
            if isList(oEndTime) and StzListQ(oEndTime).IsAndNamedParam()
                oEndTime = oEndTime[2]
            ok
        ok

        if isString(oStartTime)
            oTempStartTime = new stzTime(oStartTime)
			oStartTime = oTempStartTime
        ok
        if isString(oEndTime)
            oTempEndTime = new stzTime(oEndTime)
			oEndTime = oTempEndTime
        ok

        return This.IsAfter(oStartTime) and This.IsBefore(oEndTime)

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
        nNowH = StzEngineTimeHour(pHandle)
        nNowM = StzEngineTimeMinute(pHandle)
        nNowS = StzEngineTimeSecond(pHandle)
        StzEngineTimeFree(pHandle)
        nNowTotal = (nNowH * 3600) + (nNowM * 60) + nNowS
        nDiff = abs(This.SecondsSinceMidnight() - nNowTotal)
        return nDiff < 60

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
        oCopy = This.Copy()
        oCopy.AddSeconds(3600)
        return oCopy.ToString()

    def PreviousHour()
        oCopy = This.Copy()
        oCopy.SubtractSeconds(3600)
        return oCopy.ToString()

    def NextMinute()
        oCopy = This.Copy()
        oCopy.AddSeconds(60)
        return oCopy.ToString()

    def PreviousMinute()
        oCopy = This.Copy()
        oCopy.SubtractSeconds(60)
        return oCopy.ToString()

    def RoundToNearestHour()
        if @nMinute >= 30
            nNewHour = @nHour + 1
            if nNewHour >= 24
                nNewHour = 0
            ok
            @nHour = nNewHour
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
        return PadLeft(''+ @nHour, 2, "0") + ":00:00"

    def EndOfHour()
        return PadLeft(''+ @nHour, 2, "0") + ":59:59"

    #--- FORMATTING ---#

    def Content()
        return This.ToString()

    def Time()
        return This.ToString()

    def ToString()
        return This.ToStringXT("")

    def ToStringXT(cFormat)

        if cFormat = ""
            cFormat = $cDefaultTimeFormat
        ok
		cLowerFormat = lower(cFormat)

		cFormat = trim(cFormat)
		if right(cFormat, 2) = "ap"

			return This.ToStringXT(left(cFormat, len(cFormat)-2)) +
				   " " + This.AMPM()

		but cFormat = "ampm"
			return This.ToString() + " " + This.AMPM()

		ok

        for aFormat in $aTimeFormats
            if lower(aFormat[1]) = cLowerFormat
                cFormat = aFormat[2]
                exit
            ok
        next

		if cFormat = "long"
			return This.ToLong()
		else
        	return This.pvtFormatTime(cFormat)
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
        nHour = This.Hour12()
        nMinute = This.MinuteN()
        cAMPM = This.AMPM()

        if nMinute = 0
            return '' + nHour + " o'clock " + cAMPM

        but nMinute = 15
            return "Quarter past " + nHour + " " + cAMPM

        but nMinute = 30
            return "Half past " + nHour + " " + cAMPM

        but nMinute = 45
            return "Quarter to " + (nHour + 1) + " " + cAMPM

        else
            return '' + nHour + ":" + PadLeft(''+ nMinute, 2, "0") + " " + cAMPM
        ok

    def ToRelative()
        oNow = new stzTime("")
        nSecs = This.SecsTo(oNow)

        if abs(nSecs) < 60
            return "now"

        but nSecs < 0  # In the past
            nAbsSecs = -nSecs
            if nAbsSecs < 3600
                nMins = floor(nAbsSecs / 60)
                return '' + nMins + " minute" + Iff(nMins=1, "", "s") + " ago"

            else
                nHours = floor(nAbsSecs / 3600)
                return '' + nHours + " hour" + Iff(nHours=1, "", "s") + " ago"
            ok

        else  # In the future
            if nSecs < 3600
                nMins = floor(nSecs / 60)
                return "in " + nMins + " minute" + Iff(nMins=1, "", "s")

           else
                nHours = floor(nSecs / 3600)
                return "in " + nHours + " hour" + Iff(nHours=1, "", "s")
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
        oNewTime = new stzTime([:Hour = @nHour, :Minute = @nMinute, :Second = @nSecond, :Millisecond = @nMillisecond])
        return oNewTime

    def QTimeObject()
        StzRaise("QTimeObject() is no longer available. stzTime no longer uses Qt.")

    def SetQTime(oNewQTime)
        StzRaise("SetQTime() is no longer available. stzTime no longer uses Qt.")

    def SetQTimeQ(oNewQTime)
        StzRaise("SetQTimeQ() is no longer available. stzTime no longer uses Qt.")

    def IsValid()
        return This.pvtIsValidHMS(@nHour, @nMinute, @nSecond, @nMillisecond)

    def IsAStzTime()
        return TRUE

    #--- PRIVATE HELPERS ---#

    private

    def pvtIsValidHMS(nH, nM, nS, nMs)
        if nH < 0 or nH > 23
            return FALSE
        ok
        if nM < 0 or nM > 59
            return FALSE
        ok
        if nS < 0 or nS > 59
            return FALSE
        ok
        if nMs < 0 or nMs > 999
            return FALSE
        ok
        return TRUE

    def pvtAddTotalSeconds(nSecs)
        nTotal = This.SecondsSinceMidnight() + nSecs
        nTotal = nTotal % 86400
        if nTotal < 0
            nTotal = nTotal + 86400
        ok
        @nHour = floor(nTotal / 3600)
        @nMinute = floor((nTotal % 3600) / 60)
        @nSecond = nTotal % 60

    def pvtToTotalMs()
        return (@nHour * 3600000) + (@nMinute * 60000) + (@nSecond * 1000) + @nMillisecond

    def pvtFromTotalMs(nTotalMs)
        nTotalMs = nTotalMs % 86400000
        if nTotalMs < 0
            nTotalMs = nTotalMs + 86400000
        ok
        @nHour = floor(nTotalMs / 3600000)
        nRem = nTotalMs % 3600000
        @nMinute = floor(nRem / 60000)
        nRem = nRem % 60000
        @nSecond = floor(nRem / 1000)
        @nMillisecond = nRem % 1000

    def pvtFormatTime(cFormat)
        cResult = cFormat

        cResult = substr(cResult, "HH", PadLeft(''+ @nHour, 2, "0"))
        cResult = substr(cResult, "hh", PadLeft(''+ @nHour, 2, "0"))

        if substr(cResult, "h")
            cResult = substr(cResult, "h", ''+ @nHour)
        ok

        cResult = substr(cResult, "mm", PadLeft(''+ @nMinute, 2, "0"))
        cResult = substr(cResult, "ss", PadLeft(''+ @nSecond, 2, "0"))
        cResult = substr(cResult, "zzz", PadLeft(''+ @nMillisecond, 3, "0"))
        cResult = substr(cResult, "AP", This.AMPM())

        return cResult
