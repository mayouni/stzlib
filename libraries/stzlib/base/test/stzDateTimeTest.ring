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
#--> 15/03/2024 10:30:00

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
*/
pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:30:00.750")

? @@NL( oDateTime1.DurationTo("2024-04-20 15:45:30") )
#-->
'
[
	[ "days", 565 ],
	[ "hours", 23 ],
	[ "minutes", 36 ],
	[ "seconds", 44 ],
	[ "milliseconds", 0 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Operator subtraction to get time difference

pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
nSecsDiff = oDateTime1 - "2024-03-15 12:30:00"
? nSecsDiff
#--> -9000 (2.5 hours in seconds)

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
*/
pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime.Hours()

oDateTime.AddNatural("2 days 3 hours 30 minutes 28 seconds 540 milliseconds")
? oDateTime.ToStringXT("yyyy-mm-dd hh-mm-ss.zzz")
#--> 2024-03-17 13:30:00

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Natural language time subtraction
pr()
oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime.SubtractNatural("1 day 2 hours")
? oDateTime.ToString()
#--> 2024-03-14 08:00:00
pf()
