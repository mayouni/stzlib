#=== NEW stzDateTime CLASS ===#

class stzDateTime from stzObject
    oQDateTime
    
    def init(pDateTime)
        oQDateTime = new QDateTime()
        
        if pDateTime = NULL or pDateTime = ""
            # Current date and time
            oQDateTime = oQDateTime.currentDateTime()
            
        but isString(pDateTime)
            This.ParseStringDateTime(pDateTime)
            
        but isNumber(pDateTime)
            # Unix timestamp
            oQDateTime.setMSecsSinceEpoch(pDateTime * 1000)
            
        but isList(pDateTime)
            if len(pDateTime) = 2 and isObject(pDateTime[1]) and isObject(pDateTime[2])
                # [stzDate, stzTime] format
                oQDateTime.setDate(pDateTime[1].QDateObject())
                oQDateTime.setTime(pDateTime[2].QTimeObject())
            else
                # Hash format
                nYear = pDateTime[:Year]
                nMonth = pDateTime[:Month]
                nDay = pDateTime[:Day]
                nHour = pDateTime[:Hour]
                nMinute = pDateTime[:Minute]
                nSecond = pDateTime[:Second]
                
                oDate = new QDate()
                oDate.setDate(nYear, nMonth, nDay)
                oTime = new QTime()
                oTime.setHMS(nHour, nMinute, nSecond, 0)
                
                oQDateTime.setDate(oDate)
                oQDateTime.setTime(oTime)
            ok
        ok
        
        if not oQDateTime.isValid()
            StzRaise("Invalid date/time provided!")
        ok
    
    def ParseStringDateTime(cDateTime)
        aFormats = [ "dd/MM/yyyy hh:mm:ss", "yyyy-MM-dd hh:mm:ss",
                    "dd/MM/yyyy hh:mm", "yyyy-MM-dd hh:mm",
                    "MM/dd/yyyy hh:mm:ss", "dd-MM-yyyy hh:mm:ss" ]
        
        for cFormat in aFormats
            oTemp = oQDateTime.fromString(
				StringToQString(cDateTime),
				StringToQString(cFormat)
			)

            if oTemp.isValid()
                oQDateTime = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse date/time string: " + cDateTime)
    
    #--- ARITHMETIC OPERATIONS ---#
    
    def AddDays(nDays)
        oResult = oQDateTime.addDays(nDays)
    
    def AddMonths(nMonths)
        oResult = oQDateTime.addMonths(nMonths)
    
    def AddYears(nYears)
        oResult = oQDateTime.addYears(nYears)
    
    def AddSeconds(nSeconds)
        oResult = oQDateTime.addSecs(nSeconds)
    
    def AddMinutes(nMinutes)
        This.AddSeconds(nMinutes * 60)
    
    def AddHours(nHours)
        This.AddSeconds(nHours * 3600)
    
    def AddMilliseconds(nMs)
        oResult = oQDateTime.addMSecs(nMs)
    
    #--- GETTERS ---#
    
    def Date()
        return new stzDate().SetQDate(oQDateTime.date())
    
    def Time()
        return new stzTime().SetQTime(oQDateTime.time())
    
    def Year()
        return oQDateTime.date().year()
    
    def Month()
        return oQDateTime.date().month()
    
    def Day()
        return oQDateTime.date().day()
    
    def Hour()
        return oQDateTime.time().hour()
    
    def Minute()
        return oQDateTime.time().minute()
    
    def Second()
        return oQDateTime.time().second()
    
    def DaysTo(oOtherDateTime)
        return oQDateTime.daysTo(oOtherDateTime.QDateTimeObject())
    
    def SecsTo(oOtherDateTime)
        return oQDateTime.secsTo(oOtherDateTime.QDateTimeObject())
    
    def MSecsTo(oOtherDateTime)
        return oQDateTime.msecsTo(oOtherDateTime.QDateTimeObject())
    
    #--- UNIX TIMESTAMP ---#
    
    def ToUnixTimeStamp()
        return oQDateTime.toMSecsSinceEpoch() / 1000
    
    def ToUnixTimeStampMs()
        return oQDateTime.toMSecsSinceEpoch()
    
    #--- TIME ZONE OPERATIONS ---#
    
    def ToUTC()
        oResult = oQDateTime.toUTC()
        return new stzDateTime().SetQDateTime(oResult)
    
    def ToLocalTime()
        oResult = oQDateTime.toLocalTime()
        return new stzDateTime().SetQDateTime(oResult)
    
    #--- FORMATTING ---#
    
    def ToString(cFormat)
        if cFormat = NULL or cFormat = ""
            cFormat = _cDefaultDateTimeFormat
        ok
        return oQDateTime.toString(cFormat)
    
    def ToISO8601()
        return This.ToString("yyyy-MM-ddThh:mm:ss")
    
    def ToRFC3339()
        return This.ToUTC().ToString("yyyy-MM-ddThh:mm:ss") + "Z"
    
    #--- UTILITY METHODS ---#
    
    def SetQDateTime(oNewQDateTime)
        oQDateTime = oNewQDateTime
        return This
    
    def QDateTimeObject()
        return oQDateTime
    
    def IsValid()
        return oQDateTime.isValid()

