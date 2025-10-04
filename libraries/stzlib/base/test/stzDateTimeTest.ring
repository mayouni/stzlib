load "../stzbase.ring"

/*--- Getting current datetime with NowXT()

pr()

? NowXT()
#--> 2025-10-01 14:23:45

? NowDateTime()
#--> 2025-10-01 14:23:45

oDateTime = StzDateTimeQ("")
? oDateTime.DateTime() # Or Content() or ToString()
#--> 2025-10-01 14:23:45

pf()

/*--- Creating datetime from standard format

pr()

oDateTime = new stzDateTime("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating datetime from European format

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToEuropean()
#--> 2024-03-15 10:30:00

? oDateTime.ToEuropeanAMPM()
#--> 15/03/2024 10:30:00 AM

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating datetime from American format

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToAmerican()
#--> 03/15/2024 10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating datetime from ISO8601 format

pr()

oDateTime = StzDateTimeQ("2024-03-15T10:30:00")

? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToISO8601()
#--> 2024-03-15T10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating datetime from hash format

pr()

oDateTime = StzDateTimeQ([
    :Year = 2024,
    :Month = 3,
    :Day = 15,
    :Hour = 10,
    :Minute = 30,
    :Second = 45
])

? oDateTime.Content()
#--> 2024-03-15 10:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating datetime from unix timestamp

pr()

oDateTime = StzDateTimeQ(1710498600) # March 15, 2024, 10:30:00 UTC
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToUnixTimeStamp()
#--> 1710498600

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Extracting date and time components

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.Date()
#--> 2024-03-15

? oDateTime.DateQ().Content() + NL
#--> 15/03/2024

? oDateTime.Time()
#--> 14:30:45

? oDateTime.TimeQ().Content()
#--> 14:30:45

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Adding days to datetime

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {

	AddDays(5)
	? Content()
	#--> 2024-03-20 10:00:00

	AddDays(-3)
	? Content()
	#--> 2024-03-17 10:00:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding months and years

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {
	AddMonths(2)
	? Content()
	#--> 2024-05-15 10:00:00

	AddYears(1)
	? Content()
	#--> 2025-05-15 10:00:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding hours, minutes, seconds

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime.AddHours(3)
#--> 2024-03-15 13:00:00

? oDateTime.AddMinutes(45)
#--> 2024-03-15 13:45:00

? oDateTime.AddSeconds(30)
#--> 2024-03-15 13:45:30

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Subtracting time units

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime.SubtractDays(5)
#--> 2024-03-10 10:00:00

? oDateTime.SubtractHours(2)
#--> 2024-03-10 08:00:00

? oDateTime.SubtractMinutes(30)
#--> 2024-03-10 07:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using operator overloading for addition

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

oDateTime + "2 days"
? oDateTime.Content()
#--> 2024-03-17 10:00:00

oDateTime + "3 hours"
? oDateTime.Content()
#--> 2024-03-17 13:00:00

oDateTime + "2 days 5 hours"
? oDateTime.Content()
#--> 2024-03-19 18:00:00

pf()

/*--- Using operator overloading for subtraction

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime - "2 days"
? oDateTime.Content()
#--> 2024-03-13 10:00:00

oDateTime - "3 hours"
? oDateTime.Content()
#--> 2024-03-13 07:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Calculating duration between two datetimes (string param) #TODO #ERR

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime1.ToString()
? oDateTime1.DaysTo("2024-03-20 14:30:00")
#--> 5

? oDateTime1.HoursTo("2024-03-20 14:30:00")
#--> 124

? oDateTime1.MinutesTo("2024-03-20 14:30:00")
#--> 7470

? oDateTime1.SecsTo("2024-03-20 14:30:00")
#--> 448200
pf()

/*--- Calculating duration between two datetimes (object param)

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 14:30:00")

? oDateTime1.DaysTo(oDateTime2)
#--> 5

? oDateTime1.HoursTo(oDateTime2)
#--> 124

? oDateTime1.MinutesTo(oDateTime2)
#--> 7470

? oDateTime1.SecsTo(oDateTime2)
#--> 448200

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Duration (string param) #TODO #ERR

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
? @@NL( oDateTime1.DurationTo("2024-03-20 14:30:15") )
#-->
'
[
	[ "days", 566 ],
	[ "hours", 0 ],
	[ "minutes", 4 ],
	[ "seconds", 53 ],
	[ "milliseconds", 0 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Duration (object param)

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 14:30:15")
? @@NL( oDateTime1.DurationTo(oDateTime2) )
#-->
'
[
	[ "days", 5 ],
	[ "hours", 4 ],
	[ "minutes", 30 ],
	[ "seconds", 15 ],
	[ "milliseconds", 0 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparing datetimes with operators (string)

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime1 < "2024-03-20 10:00:00"
#--> TRUE

? oDateTime1 > "2024-03-20 10:00:00"
#--> FALSE

? oDateTime1 = "2024-03-15 10:00:00"
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparing datetimes with operators (object)

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 10:00:00")

? oDateTime1 < oDateTime2
#--> TRUE

? oDateTime1 > oDateTime2
#--> FALSE

? oDateTime1 = oDateTime1
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using comparison methods (string param) #TODO #ERR

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime1.IsBefore("2024-03-20 10:00:00")
#--> TRUE

? oDateTime1.IsAfter("2024-03-20 10:00:00")
#--> FALSE

? oDateTime1.IsEqualTo("2024-03-15 10:00:00") #ERR returned FALSE!
#--> TRUE

pf()

/*--- Using comparison methods (object param)

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 10:00:00")

? oDateTime1.IsBefore(oDateTime2)
#--> TRUE

? oDateTime1.IsAfter(oDateTime2)
#--> FALSE

? oDateTime1.IsEqualTo(oDateTime1)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Checking if datetime is between two others (string params) #TODO #ERR

pr()

oDateTime = StzDateTimeQ("2024-03-17 10:00:00")
? oDateTime.IsBetween("2024-03-15 10:00:00", :And = "2024-03-20 10:00:00")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Checking if datetime is between two others (object params)

pr()

oDateTime = StzDateTimeQ("2024-03-17 10:00:00")
oStart = StzDateTimeQ("2024-03-15 10:00:00")
oEnd = StzDateTimeQ("2024-03-20 10:00:00")
? oDateTime.IsBetween(oStart, :And = oEnd)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Formatting datetime with named formats

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT(:Standard)
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT(:Short)
#--> 15/03/2024 14:30

? oDateTime.ToStringXT(:ISO8601)
#--> 2024-03-15T14:30:45

? oDateTime.ToStringXT(:Long)
#--> Friday, March 15, 2024 2:30:45 PM

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Converting to UTC and local time

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToUTC()
#--> 2024-03-15 13:30:45 (depends on timezone)

? oDateTime.ToLocalTime()
#--> 2024-03-15 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Human-readable datetime

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
? oDateTime.ToHuman()
#--> Friday, March 3rd, 2024 at Half past 2 PM

pf()

/*--- Relative time description

pr()

oDateTime = StzDateTimeQ('') - "2 hours"
? oDateTime.ToRelative()
#--> 2 hours ago

oFuture = StzDateTimeQ('') + "3 days"
? oFuture.ToRelative()
#--> in 3 days

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Checking if datetime is now/today

pr()

oNow = StzDateTimeQ("")
? oNow.IsNow()
#--> TRUE

? oNow.IsToday()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Checking if datetime is tomorrow/yesterday

pr()

oTomorrow = StzDateTimeQ('') + "1 day"
? oTomorrow.IsTomorrow()
#--> TRUE

oYesterday = StzDateTimeQ('') - "1 day"
? oYesterday.IsYesterday()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Working with milliseconds

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
? oDateTime.ToUnixTimeStampMs()
#--> 1710515445000

? oDateTime.AddMilliseconds(500)
#--> 2024-03-15 14:30:45.500

# Or you can also say:
? oDateTime.ToStringXT("yyyy-MM-dd hh:mm:ss.zzz")
#--> 2024-03-15 14:30:45.500

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Validating datetime strings

pr()

? IsDateTime("2024-03-15 10:00:00")
#--> TRUE

? IsDateTime("2024-03-15T10:00:00")
#--> TRUE

? IsDateTime("invalid")
#--> FALSE

? IsValidDateTime("2024-03-15 10:00:00")
#--> TRUE

pf()

/*--- Chaining operations with Q methods

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

oResult = oDateTime.AddDaysQ(5).AddHoursQ(3).AddMinutesQ(30)
? oResult.ToString()
#--> 2024-03-20 13:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Complex duration with multiple units

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:30:00.750")

? @@NL( oDateTime1.DurationTo("2024-04-20 15:45:30") )
#-->
'
[
	[ "days", 36 ],
	[ "hours", 5 ],
	[ "minutes", 15 ],
	[ "seconds", 29 ],
	[ "milliseconds", 250 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Date time components

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:18.750")
oDateTime {

	? Year()	#--> 2024

	? Month()	#--> March
	? MonthN()	#--> 3

	? Day()		#--> Friday
	? DayN()	#--> 15

	? Hours()	#--> 10
	? Minutes()	#--> 30
	? Seconds()	#--> 18
	? Milliseconds() #--> 750

}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Operator subtraction to get time difference

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
nSecsDiff = oDateTime1 - "2024-03-15 12:30:00"
? nSecsDiff
#--> 9000 (2.5 hours in seconds)

pf()
# # Executed in almost 0 second(s) in Ring 1.23

/*--- Simple datetime formatting

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

? oDateTime.ToLong()
#--> Friday, March 15, 2024 2:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Adding seconds directly with operator

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime + 3600 # Add 3600 seconds (1 hour)
? oDateTime.ToString()
#--> 2024-03-15 11:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Natural language time addition

pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime.Hours()
#--> 10

oDateTime.AddNatural("2 days 3 hours 30 minutes 28 seconds 540 milliseconds")
? oDateTime.ToStringXT("yyyy-mm-dd hh-mm-ss.zzz")
#--> 2024-30-17 13-30-28.540

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Natural language time subtraction
pr()
oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime.SubtractNatural("1 day 2 hours")
? oDateTime.ToString()
#--> 2024-03-14 08:00:00
pf()

#===============================#
#  12H / 24H FORMAT TEST CASES  #
#===============================#

/*--- Default 24-hour behavior

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToString()
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT("")
#--> 2024-03-15 14:30:45 (uses $cDefaultDateTimeFormat)

? oDateTime.ToStringXT("yyyy-MM-dd HH:mm:ss")
#--> 2024-03-15 14:30:45

? oDateTime.ToEuropean()
#--> 15/03/2024 14:30:45

? oDateTime.ToAmerican()
#--> 03/15/2024 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Named format configs (24-hour)

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT(:Standard)
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT(:European)
#--> 15/03/2024 14:30:45

? oDateTime.ToStringXT(:American)
#--> 03/15/2024 14:30:45

? oDateTime.ToStringXT(:ISO8601)
#--> 2024-03-15T14:30:45

? oDateTime.ToStringXT(:RFC2822) # Depends on your system locale language
#--> 15 Mar 2024 14:30:45

pf()
# # Executed in almost 0 second(s) in Ring 1.23

/*--- Explicit 12-hour methods

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

? oDateTime.ToLong() # Depends on your system locale language
#--> Friday, March 15, 2024 2:30:45 PM

? oDateTime.ToString12h()
#--> 2024-03-15 2:30:45 PM

? oDateTime.ToEuropean12h()
#--> 15/03/2024 2:30:45 PM

? oDateTime.ToAmerican12h()
#--> 03/15/2024 2:30:45 PM

pf()
# Executed in 0.02 second(s) in Ring 1.23

#-------------------------------------------------------

# ISO/Normalized formats (safe for storage/interchange)

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToISO()
#--> 2024-03-15 14:30:45

? oDateTime.ToISO8601()
#--> 2024-03-15T14:30:45

? oDateTime.ToStringXT(:ISOWithMs)
#--> 2024-03-15 14:30:45.000

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Compact formats

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToCompact()
 #--> 2024-03-15 14:30

? oDateTime.ToStringXT(:CompactSec)
#--> 2024-03-15 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- # Standard formats (region-aware)

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStandard()         #--> 15/03/2024 14:30:45
? oDateTime.ToEuropean()         #--> 15/03/2024 14:30:45
? oDateTime.ToAmerican()         #--> 03/15/2024 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- # Verbose formats

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToVerbose() # Depends on your current system language
#--> Friday, March 15, 2024 14:30:45

# 12-hour formats (automatic AM/PM)

? oDateTime.ToISO12h()
#--> 2024-03-15 02:30:45 PM

? oDateTime.ToStandard12h()
#--> 15/03/2024 02:30:45 PM

? oDateTime.ToVerbose12h() # Depends on your current system language
#--> Friday, March 15, 2024 02:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Custom format strings

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT("yyyy.MM.dd HH:mm")
#--> 2024.03.15 14:30

? oDateTime.ToStringXT("dd-MM-yy hh:mm AP") # Qt does not distinguis h from H
#--> 15-03-24 02:30 PM

# Named format access
? oDateTime.ToStringXT(:RFC2822)
#--> 15 Mar 2024 14:30:45

? oDateTime.ToStringXT(:UnixLog)
#--> Mar 15 14:30:45

pf()
# Executed in 0.01 second(s) in Ring 1.23

#================================================#
# NORMALIZATION STRATEGY #TODO Write a narration #
#================================================#

/*
FOR SAFE DATA STORAGE AND INTERCHANGE:
Always use ISO formats:
- :ISO ~> Standard normalized format
- :ISO8601 ~> T-separated ISO format
- :ISOWithMs ~> When precision matters

These formats are:
1. Timezone-independent (always state clearly if UTC or local)
2. Unambiguous (YYYY-MM-DD is universal)
3. Sortable as strings
4. Parseable across systems

FOR DISPLAY TO USERS:
Use Standard, Verbose, or region-specific formats:
- :Standard ~> Common readable
- :European ~> DD/MM/YYYY format
- :American ~> MM/DD/YYYY format
- :Verbose ~> Full text for reports

Add 12h suffix for 12-hour display:
- :Standard12h
- :European12h
- :American12h
- :Verbose12h

/*--- Named formats

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
oDateTime {


	? ToStringXT(:Simple) # 12h by default	; can be written ToSimple()
	#--> 15/03/2024 2:30 PM

	? ToStringXT(:Simple12h)		# Or ToSimple12h()
	#--> 15/03/2024 2:30 PM

	? ToStringXT(:Simple24h) + NL	# Or ToSimple24h()
	#--> 15/03/2024 14:30

	#---

	? ToLong()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToLong12h()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToLong24h() + NL
	#--> Friday, March 15, 2024 14:30

	#---

	? ToShort()
	#--> 15/03 2:30 PM

	? ToShort12h()
	#--> 15/03 2:30 PM

	? ToShort24h() + NL
	#--> 15/03 14:30 + NL

	#---

	? ToMedium()
	#--> Fri., March 15 2:30 PM

	? ToMedium12h()
	#--> Fri., March 15 2:30 PM

	? ToMedium24h()
	#--> Fri., March 15 14:30

}

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

oDateTime {

	? ToEuropean()
	#--> 15/03/2024 2:30:45 PM

	? ToEuropean12h()
	#--> 15/03/2024 2:30:45 PM

	? ToEuropean24h() + NL
	#--> 15/03/2024 14:30:45

	#---

	? ToAmerican()
	#--> 03/15/2024 2:30:45 PM

	? ToAmerican12h()
	#--> 03/15/2024 2:30:45 PM

	? ToAmerican24h() + NL
	#--> 03/15/2024 14:30:45

	#---

	? ToISO()
	#--> 2024-03-15 2:30:45 PM

	? ToIso12h()
	#--> 2024-03-15 2:30:45 PM

	? ToIso24h() + NL
	#--> 2024-03-15 14:30:45

	#--

	? ToStandard()
	#--> 15/03/2024 2:30:45 PM

	? ToStandard12h()
	#--> 15/03/2024 2:30:45 PM

	? ToStandard24h() + NL
	#--> 15/03/2024 14:30:45

	#--

	? ToVerbose()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToVerbose12h()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToVerbose24h()
	#--> Friday, March 15, 2024 14:30:45

}

pf()
# Executed in 0.05 second(s) in Ring 1.23

/*--- Custom 12-hour format strings

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT("dd/MM/yyyy h:mm AP")
#--> 15/03/2024 2:30 PM

? oDateTime.ToStringXT("MM-dd-yyyy h:mm:ss AP")
#--> 03-15-2024 2:30:45 PM

? oDateTime.ToStringXT("dddd h:mm AP")
#--> Friday 2:30 PM

? oDateTime.ToStringXT("MMMM d, yyyy at h:mm AP")
#--> March 15, 2024 at 2:30 PM

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---  Morning times (AM)

pr()

oMorning = StzDateTimeQ("2024-03-15 09:15:30")

? oMorning.ToSimple()
#--> 15/03/2024 9:15 AM

? oMorning.ToSimple12h()
#--> 15/03/2024 9:15 AM

? oMorning.ToSimple24h()
#--> 15/03/2024 09:15

? oMorning.ToStringXT("h:mm AP")
#--> 9:15 AM

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---  Morning times (AM)

pr()

oMorning = StzDateTimeQ("2024-03-15 09:15:30")

? oMorning.ToCompact()
#--> 2024-03-15 9:15 AM

? oMorning.ToCompact12h()
#--> 2024-03-15 9:15 AM

? oMorning.ToCompact24h()
#--> 2024-03-15 09:15

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Midnight and Noon edge cases

pr()

oMidnight = StzDateTimeQ("2024-03-15 00:00:00")
oNoon = StzDateTimeQ("2024-03-15 12:00:00")

? oMidnight.ToString12h()
#--> 2024-03-15 12:00:00 AM (midnight = 12 AM)

? oNoon.ToString12h()
#--> 2024-03-15 12:00:00 PM (noon = 12 PM)

? oMidnight.ToSimple()
#--> 15/03/2024 12:00 AM

? oNoon.ToSimple()
#--> 15/03/2024 12:00 PM

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- Hour boundaries

pr()

oEleven = StzDateTimeQ("2024-03-15 11:59:59")
oOne = StzDateTimeQ("2024-03-15 13:00:00")

? oEleven.ToString12h()
#--> 2024-03-15 11:59:59 AM

? oOne.ToString12h()
#--> 2024-03-15 1:00:00 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Format consistency across operations

pr()

oDT = StzDateTimeQ("2024-03-15 08:30:00")

? oDT.ToString12h()
#--> 2024-03-15 8:30:00 AM

oDT.AddHours(6)
? oDT.ToString12h()
#--> 2024-03-15 2:30:00 PM (crossed noon)

oDT.AddHours(12)
? oDT.ToString12h()
#--> 2024-03-16 2:30:00 AM (crossed midnight)

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Locale-aware AM/PM text

pr()

# Assumes stzLocale returns locale-specific AM/PM

Lc = new stzLocale("")
? Lc.amText() #--> AM
? Lc.pmText() #--> PM

oDateTime = StzDateTimeQ("2024-03-15 14:30:00")
? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Parsing preserves original hou

pr()

oParsed = StzDateTimeQ("2024-03-15 14:30:45")

# Hours (24h)

? oParsed.Hours()
#--> 14

# Display 24h

? oParsed.ToString()
#--> 2024-03-15 14:30:45

# Display 12h

? oParsed.ToString12h()
#--> 2024-03-15 2:30:45 PM

pf() 
# Executed in 0.01 second(s) in Ring 1.23

/*--- Integration with ToHuman()

pr()

oHuman = StzDateTimeQ("2024-03-15 14:30:00")

? oHuman.ToHuman()
#--> Friday March 15, 2024 at 2:30 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Single digit hours

pr()

oSingle = StzDateTimeQ("2024-03-15 03:05:00")

? oSingle.ToString12h()
#--> 2024-03-15 3:05:00 AM

? oSingle.ToStringXT("h:mm AP")
#--> 3:05 AM

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Error handling

pr()

oTest = StzDateTimeQ("2024-03-15 14:30:00")

? oTest.ToStringXT("INVALID_FORMAT")
#--> ERROR: The pattern name you provided does not exist in stzRegexData file.

? oTest.ToStringXT(:NonExistentFormat)
#--> ERROR: The pattern name you provided does not exist in stzRegexData file.

pf()

#===================================================================#
#  USAGE EXAMPLES OF CREATION A STZDATETIME OBJECT FROM EPOCH TIME  #
#==================================================================="

/*--- Example 1: From epoch seconds

pr()

oDateTime = new stzDateTime([ :FromEpochSeconds = 1609459200 ])
? oDateTime.ToStringXT(:ISO)
#--> 2021-01-01 00:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 2: From epoch days

pr()

oDateTime = new stzDateTime([ :FromEpochDays = 20000 ])
? oDateTime.ToStringXT(:Standard)
#--> 04/10/2024 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 3: Natural language string (auto-detected - must include "from epoch")

pr()

oDateTime = new stzDateTime("54 years 9 months 3 days from epoch")
? oDateTime.ToVerbose()
#--> Sunday, July 11, 2079 13:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 4: From epoch duration hash

pr()

oDateTime = new stzDateTime([
    :FromEpochDuration = [
        :Years = 54,
        :Months = 9,
        :Days = 3,
        :Hours = 14,
        :Minutes = 30
    ]
])
? oDateTime.ToISOWithAmPm()
#--> 2024-09-21 9:30:00 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 5: From epoch weeks

pr()

oDateTime = new stzDateTime([ :FromEpochWeeks = 2857 ])
? oDateTime.ToStringXT(:Compact)
#--> 2024-10-03 01:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 6: Complex natural language (auto-detected - must include "from epoch")

pr()

oDateTime = new stzDateTime("5 years 3 months 20 days 8 hours 45 minutes 30 seconds from epoch")
? oDateTime.ToStringXT(:ISO8601)
#--> 1980-08-09T07:16:30

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Example 7: From epoch milliseconds

pr()

oDateTime = new stzDateTime([ :FromEpochMilliseconds = 1609459200500 ])
? oDateTime.ToStringXT(:ISOWithMs)
#--> 2021-01-01 01:00:00.500

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 8: Natural epoch via hash

pr()

oDateTime = new stzDateTime([ :FromNaturalEpoch = "2 years 6 months 15 days" ])
? oDateTime.ToStringXT(:European)
#--> 30/01/1975 01:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 9: From epoch hours

pr()

oDateTime = new stzDateTime([ :FromEpochHours = 480000 ])
? oDateTime.ToStringXT(:American12h)
#--> 10/04/2024 1:00:00 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 10: From epoch years

pr()

oDateTime = new stzDateTime([ :FromEpochYears = 55 ])
? oDateTime.ToLong()
#--> Wednesday, January 1, 2025 12:00:00 AM

? oDateTime.ToLongDate()
#--> Wednesday, January 1, 2025

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 11 : Seconds counting from Unix start

pr()

oDateTime = new stzDateTime([ :CountingFromUnixStart = 1609459200 ])
? oDateTime.ToCompact()  #--> 2021-01-01 01:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 12: Duration counting from specific origin

pr()

oDateTime = new stzDateTime([
    :CountingFrom = [ :Origin = :UnixStart, :Years = 50, :Days = 100 ]
])

? oDateTime.Content()
#--> 2020-03-29 01:00:00

pf()

/*--- Example 13: Natural language with origin

pr()

oDateTime = new stzDateTime("5 years 3 months counting from space age")
? oDateTime.Content()
#--> 1975-04-01 07:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 14: Counting from Year One

pr()

oDateTime = new stzDateTime([ :CountingFromYearOne = 63_113_904_000 ])  # seconds
? oDateTime.Content()
#--> 2001-01-01 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 15: Counting from Islamic calendar

pr()

oDateTime = new stzDateTime([
    :CountingFromIslamicCalendar = [ :Years = 1400 ]
])

? oDateTime.Content()
#--> 2021-08-13 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Example 16: Query methods
*/
pr()

oNow = new stzDateTime("")
? oNow.SecondsSinceUnixStart()
#--> 1759579659

//? @@NL(oNow.CountingFromUnixStartXT())
#--> [
#	[ "milliseconds", 1759579946021 ],
#	[ "seconds", 1759579946 ],
#	[ "minutes", 29326332 ],
#	[ "hours", 488772 ],
#	[ "days", 20365 ],
#	[ "weeks", 2909 ],
#	[ "years", 55 ]
# ]

? oNow.CountingInSecondsFrom(:SpaceAge) # Or CountingInSecondsFrom(:SpaceAge)
#--> 2153995946021

pf()

/*--- Example 17: US Independence reference
oDate7 = new stzDateTime([
    :CountingFromUSIndependence = [ :Years = 248, :Months = 3 ]
])
? oDate7.Content()

/*--- Example 18: Natural with atomic age
oDate8 = new stzDateTime("79 years 2 months counting from atomic age")
? oDate8.Content()
