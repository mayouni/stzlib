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
    _oQTime_ = new QTime()
    aFormats = [ "hh:mm:ss", "hh:mm", "h:mm:ss", "h:mm",
                "hh:mm:ss.zzz", "h:mm:ss AP", "hh:mm AP" ]
    
    for cFormat in aFormats
        oTemp = _oQTime_.fromString(str, cFormat)
        if oTemp.isValid()
            return TRUE
        ok
    next
    return FALSE

    func IsValidTime(str)
        return IsTime(str)

class stzTime from stzObject
    oQTime
    
    def init(pTime)
        oQTime = new QTime()
        
        if IsNull(pTime) or pTime = ""
            # Current time
            oQTime = oQTime.currentTime()
            
        but isString(pTime)
            This.ParseStringTime(pTime)
            
        but isNumber(pTime)
            # Seconds since midnight
            nHours = floor(pTime / 3600)
            nMinutes = floor((pTime % 3600) / 60)
            nSeconds = pTime % 60
            oQTime.setHMS(nHours, nMinutes, nSeconds, 0)
            
        but isList(pTime) and IsHashList(pTime)
            # Hash format [:Hour = 14, :Minute = 30, :Second = 45]
            nHour   = 0
            nMinute = 0
            nSecond = 0
            nMs     = 0

            if pTime[:Hour] != NULL
                nHour = 0+ pTime[:Hour]
            ok
            if pTime[:Minute] != NULL
                nMinute = 0+ pTime[:Minute]
            ok
            if pTime[:Second] != NULL
                nSecond = 0+ pTime[:Second]
            ok
            if pTime[:Millisecond] != NULL
                nMs = 0+ pTime[:Millisecond]
            ok

            oQTime.setHMS(nHour, nMinute, nSecond, nMs)
        ok
        
        if not oQTime.isValid()
            StzRaise("Invalid time provided!")
        ok
    
    def ParseStringTime(cTime)
        aFormats = [ "hh:mm:ss", "hh:mm", "h:mm:ss", "h:mm",
                    "hh:mm:ss.zzz", "h:mm:ss AP", "hh:mm AP", "h:mm AP" ]
        
        for cFormat in aFormats
            oTemp = oQTime.fromString(cTime, cFormat)
            if oTemp.isValid()
                oQTime = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse time string: " + cTime)
    
    #--- ARITHMETIC OPERATIONS ---#
    
    def AddSeconds(nSeconds)
        oQTime = oQTime.addSecs(nSeconds)
        return This.ToString()
    
    def AddSecondsQ(nSeconds)
        This.AddSeconds(nSeconds)
        return This
    
    def AddMinutes(nMinutes)
        oQTime = oQTime.addSecs(nMinutes * 60)
        return This.ToString()
    
    def AddMinutesQ(nMinutes)
        This.AddMinutes(nMinutes)
        return This
    
    def AddHours(nHours)
        oQTime = oQTime.addSecs(nHours * 3600)
        return This.ToString()
    
    def AddHoursQ(nHours)
        This.AddHours(nHours)
        return This
    
    def AddMilliseconds(nMs)
        oQTime = oQTime.addMSecs(nMs)
        return This.ToString()
    
    def AddMillisecondsQ(nMs)
        This.AddMilliseconds(nMs)
        return This

    def SubtractSeconds(nSeconds)
        oQTime = oQTime.addSecs(-nSeconds)
        return This.ToString()
    
    def SubtractSecondsQ(nSeconds)
        This.SubtractSeconds(nSeconds)
        return This
    
    def SubtractMinutes(nMinutes)
        oQTime = oQTime.addSecs(-nMinutes * 60)
        return This.ToString()
    
    def SubtractMinutesQ(nMinutes)
        This.SubtractMinutes(nMinutes)
        return This
    
    def SubtractHours(nHours)
        oQTime = oQTime.addSecs(-nHours * 3600)
        return This.ToString()
    
    def SubtractHoursQ(nHours)
        This.SubtractHours(nHours)
        return This
    
    def SubtractMilliseconds(nMs)
        oQTime = oQTime.addMSecs(-nMs)
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
        return oQTime.secsTo(oOtherTime.QTimeObject())
    
    def MSecsTo(oOtherTime)
        if isString(oOtherTime)
            oOtherTime = new stzTime(oOtherTime)
        ok
        return oQTime.msecsTo(oOtherTime.QTimeObject())

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
        return oQTime.hour() < 12

    def IsPM()
        return oQTime.hour() >= 12

    def IsMidnight()
        return oQTime.hour() = 0 and oQTime.minute() = 0 and oQTime.second() = 0

    def IsNoon()
        return oQTime.hour() = 12 and oQTime.minute() = 0 and oQTime.second() = 0

    def IsMorning()
        nHour = oQTime.hour()
        return nHour >= 5 and nHour < 12

    def IsAfternoon()
        nHour = oQTime.hour()
        return nHour >= 12 and nHour < 17

    def IsEvening()
        nHour = oQTime.hour()
        return nHour >= 17 and nHour < 21

    def IsNight()
        nHour = oQTime.hour()
        return nHour >= 21 or nHour < 5

    def IsWorkHours()
        nHour = oQTime.hour()
        return nHour >= 9 and nHour < 17

    def IsNow()
        oNow = new QTime()
        oNow = oNow.currentTime()
        nDiff = abs(oQTime.secsTo(oNow))
        return nDiff < 60  # Within 1 minute

    #--- GETTERS ---#
    
    def Hour()
        return oQTime.hour()

        def HourN()
            return oQTime.hour()
    
    def Minute()
        return oQTime.minute()

        def MinuteN()
            return oQTime.minute()
    
    def Second()
        return oQTime.second()

        def SecondN()
            return oQTime.second()
    
    def Millisecond()
        return oQTime.msec()

        def MillisecondN()
            return oQTime.msec()

    def Hour12()
        nHour = oQTime.hour()
        if nHour = 0
            return 12
        but nHour > 12
            return nHour - 12
        else
            return nHour
        ok

    def AMPM()
        if This.IsAM()
            return "AM"
        else
            return "PM"
        ok

    def SecondsSinceMidnight()
        return (oQTime.hour() * 3600) + (oQTime.minute() * 60) + oQTime.second()

    def SecondsUntilMidnight()
        return 86400 - This.SecondsSinceMidnight()

    #--- SMART NAVIGATION ---#

    def NextHour()
		oQCopy = oQTime
        oQCopy.addSecs(3600)
        return oQCopy.ToString()

    def PreviousHour()
		oQCopy = oQTime
        oQCopy.addSecs(-3600)
        return oQCopy.ToString()

    def NextMinute()
		oQCopy = oQTime
        oQCopy.addSecs(60)
        return oQCopy.ToString()

    def PreviousMinute()
		oQCopy = oQTime
        oQCopy.addSecs(-60)
        return oQCopy.ToString()

    def RoundToNearestHour()
        if oQTime.minute() >= 30
            oQTime.setHMS(oQTime.hour() + 1, 0, 0, 0)
        else
            oQTime.setHMS(oQTime.hour(), 0, 0, 0)
        ok
        return This.ToString()

    def RoundToNearestMinute()
        if oQTime.second() >= 30
            oQTime = oQTime.addSecs(60 - oQTime.second())
        ok
        oQTime.setHMS(oQTime.hour(), oQTime.minute(), 0, 0)
        return This.ToString()

    def StartOfHour()
        oQCopy = new QTime()
		oQCopy.fromString(This.Content(), $cDefaultTimeFormat)
        oQCopy.setHMS(oQTime.hour(), 0, 0, 0)
        return oQCopy.ToString($cDefaultTimeFormat)

    def EndOfHour()
        oQCopy = new QTime()
		oQCopy.fromString(This.Content(), $cDefaultTimeFormat)
        oQCopy.setHMS(oQTime.hour(), 59, 59, 999)
        return oQCopy.ToString($cDefaultTimeFormat)

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

		cFormat = trim(cFormat)
		if right(cFormat, 2) = "AP"

			return This.ToStringXT(left(cFormat, len(cFormat)-2)) +
				   " " + This.AMPM()

		but cFormat = "AmPm"
			return This.ToString() + " " + This.AMPM()

		ok

        # Handle named formats
        cLowerFormat = lower(cFormat)
        for aFormat in $aTimeFormats
            if lower(aFormat[1]) = cLowerFormat
                cFormat = aFormat[2]
                exit
            ok
        next
        
        return oQTime.toString(cFormat)
    
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
        oNewTime = new stzTime("")
        oNewTime.SetQTime(new QTime())
        oNewTime.QTimeObject().setHMS(This.HourN(), This.MinuteN(), This.SecondN(), This.MillisecondN())
        return oNewTime
    
    def SetQTime(oNewQTime)
        oQTime = oNewQTime
        return This

    def SetQTimeQ(oNewQTime)
        This.SetQTime(oNewQTime)
        return This
    
    def QTimeObject()
        return oQTime
    
    def IsValid()
        if oQTime.isValid()
            return TRUE
        else
            return FALSE
        ok
    
    def IsAStzTime()
        return TRUE
