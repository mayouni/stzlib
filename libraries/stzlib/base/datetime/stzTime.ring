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
            nHours = pTime / 3600
            nMinutes = (pTime % 3600) / 60
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
                    "hh:mm:ss.zzz", "h:mm:ss AP", "hh:mm AP" ]
        
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
        return This
    
    def AddMinutes(nMinutes)
        return This.AddSeconds(nMinutes * 60)
    
    def AddHours(nHours)
        return This.AddSeconds(nHours * 3600)
    
    def AddMilliseconds(nMs)
        oQTime = oQTime.addMSecs(nMs)
        return This
    
    #--- GETTERS ---#
    
    def Hour()
        return oQTime.hour()
    
    def Minute()
        return oQTime.minute()
    
    def Second()
        return oQTime.second()
    
    def Millisecond()
        return oQTime.msec()
    
    def SecsTo(oOtherTime)
        return oQTime.secsTo(oOtherTime.QTimeObject())
    
    def MSecsTo(oOtherTime)
        return oQTime.msecsTo(oOtherTime.QTimeObject())
    
    #--- FORMATTING ---#
    
	def Content()
		return This.ToStringXT("")

	def ToString()
		return This.ToStringXT("")

    def ToStringXT(cFormat)
        if cFormat = NULL or cFormat = ""
            cFormat = _cDefaultTimeFormat
        ok
        
        # Handle named formats
        if isString(cFormat) and substr(cFormat, 1, 1) = ":"
            cFormatName = substr(cFormat, 2, len(cFormat)-1)
            for aFormat in _aTimeFormats
                if lower(aFormat[1]) = lower(cFormatName)
                    cFormat = aFormat[2]
                    exit
                ok
            next
        ok
        
        return oQTime.toString(cFormat)
    
    def To12Hour()
        return This.ToString("h:mm:ss AP")
    
    def To24Hour()
        return This.ToString("HH:mm:ss")
    
    #--- UTILITY METHODS ---#
    
    def SetQTime(oNewQTime)
        oQTime = oNewQTime
        return This
    
    def QTimeObject()
        return oQTime
    
    def IsValid()
        return oQTime.isValid()
