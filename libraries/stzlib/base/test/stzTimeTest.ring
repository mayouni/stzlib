load "../stzbase.ring"

/*--- Getting current time with NowTime()

pr()

? Now()
#--> 30/09/2025 23:05:00

? NowTime() # Or simply Time()
#--> 23:05:39

oTime = StzTimeQ("")
? oTime.Time() # Or Content() or ToString()
#--> 23:05:39

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating time from string

pr()

oTime = new stzTime("14:30:00")
? oTime.Content()
#--> 14:30:00

oTime2 = new stzTime("14:30")
? oTime2.Content()
#--> 14:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating time from hash list

pr()

oTime = new stzTime([:Hour = 14, :Minute = 30, :Second = 45])
? oTime.ToString()
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating time from seconds since midnight

pr()

oTime = new stzTime(52245)
? oTime.ToString()
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Validating time strings

pr()

? IsTime("14:30:00")
#--> TRUE

? IsTime("2:3 PM")  #TODO ERROR
#--> TRUE

? IsTime("25:00:00")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting time components

pr()

oTime = new stzTime("14:30:45")
? oTime.Hour()
#--> 14

? oTime.Minute()
#--> 30

? oTime.Second()
#--> 45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- 12-hour format operations

pr()

oTime = new stzTime("14:30:00")

? oTime.Hour12()
#--> 2

? oTime.AMPM()
#--> PM

? oTime.To12Hour()
#--> 2:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding time units

pr()

oTime = new stzTime("10:00:00")
oTime {

	AddSeconds(30)
	? Content()
	#--> 10:00:30

	AddMinutes(15)
	? Content()
	#--> 10:15:30

	oTime.AddHours(2)
	? Content()
	#--> 12:15:30
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Subtracting time units

pr()

oTime = new stzTime("12:30:45")
oTime {

	SubtractSeconds(45)
	? Content()
	#--> 12:30:00

	SubtractMinutes(30)
	? Content()
	#--> 12:00:00

	SubtractHours(2)
	? Content()
	#--> 10:00:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Operator overloading with +

pr()

oTime = new stzTime("10:00:00")
oTime + 3600  # Add 1 hour (3600 seconds)
? oTime.Content()
#--> 11:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Operator overloading with -

pr()

oTime = new stzTime("10:00:00")
oTime - 1800  # Subtract 30 minutes (1800 seconds)
? oTime.Content()
#--> 09:30:00

pf()

/*--- Time difference with - operator

pr()

oTime1 = new stzTime("14:00:00")
oTime2 = new stzTime("10:00:00")

nSecsDiff = oTime2 - oTime1
? nSecsDiff
#--> -14400  # 4 hours = 14400 seconds (negative because oTime2 is earlier)

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparing times with SecsTo and MinutesTo

pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:30:00")

? oTime1.SecsTo(oTime2)
#--> 16200

? oTime1.MinutesTo(oTime2)
#--> 270

? oTime1.HoursTo(oTime2)
#--> 4

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparison operators

pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:00:00")

? oTime1 < oTime2
#--> TRUE

? oTime1 > oTime2
#--> FALSE

? oTime1 = new stzTime("10:00:00")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- IsBefore, IsAfter, IsEqualTo

pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:00:00")

? oTime1.IsBefore(oTime2)
#--> TRUE

? oTime1.IsAfter(oTime2)
#--> FALSE

? oTime1.IsEqualTo("10:00:00")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- IsBetween

pr()

oTime = new stzTime("12:00:00")
? oTime.IsBetween("10:00:00", :And = "14:00:00")
#--> TRUE

? oTime.IsBetween("13:00:00", :And = "14:00:00")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Time of day checks

pr()

oMorning = new stzTime("09:00:00")
? oMorning.IsMorning()
#--> TRUE

oAfternoon = new stzTime("14:00:00")
? oAfternoon.IsAfternoon()
#--> TRUE

oEvening = new stzTime("19:00:00")
? oEvening.IsEvening()
#--> TRUE

oNight = new stzTime("23:00:00")
? oNight.IsNight()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- AM/PM checks

pr()

oTime1 = new stzTime("09:00:00")
? oTime1.IsAM()
#--> TRUE

oTime2 = new stzTime("15:00:00")
? oTime2.IsPM()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Special time checks

pr()

oMidnight = new stzTime("00:00:00")
? oMidnight.IsMidnight()
#--> TRUE

oNoon = new stzTime("12:00:00")
? oNoon.IsNoon()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Work hours check

pr()

oTime1 = new stzTime("10:00:00")
? oTime1.IsWorkHours()
#--> TRUE

oTime2 = new stzTime("18:00:00")
? oTime2.IsWorkHours()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Seconds since/until midnight

pr()

oTime = new stzTime("12:30:45")
? oTime.SecondsSinceMidnight()
#--> 45045

? oTime.SecondsUntilMidnight()
#--> 41355

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Time navigation

pr()

oTime = new stzTime("10:30:00")

? oTime.NextHour()
#--> 11:30:00

? oTime.PreviousHour()
#--> 10:30:00

? oTime.NextMinute()
#--> 10:31:00

? oTime.PreviousMinute()
#--> 10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Rounding times

pr()

oTime = new stzTime("10:45:30")

oTime2 = oTime.Copy()
oTime2.RoundToNearestHour()
? oTime2.Content()
#--> 11:00:00

oTime3 = new stzTime("10:45:45")
oTime3.RoundToNearestMinute()
? oTime3.Content()
#--> 10:46:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Start and end of hour

pr()

oTime = new stzTime("10:45:30")

? oTime.StartOfHour()
#--> 10:00:00

? oTime.EndOfHour()
#--> 10:59:59

? oTime.Content()
#--> 10:45:30

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Different format outputs

pr()

oTime = new stzTime("14:30:45")

? oTime.To12Hour()
#--> 2:30:45 PM

? oTime.To24Hour()
#--> 14:30:45

? oTime.ToShort()
#--> 14:30

? oTime.ToSimple()
#--> 2:30 PM

? oTime.AMPM()
#~-> PM

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Custom format strings

pr()

oTime = new stzTime("14:30:45")

? oTime.ToStringXT("hh:mm")
#--> 14:30

? oTime.ToStringXT("h:mm AP")
#--> 2:30 PM

? oTime.ToStringXT("HH:mm:ss")
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Named format strings

pr()

oTime = new stzTime("14:30:45")

? oTime.ToStringXT("Standard")
#--> 14:30:45

? oTime.ToStringXT("Short")
#--> 14:30

? oTime.ToStringXT("AmPm")
#--> 2:30:45 PM

pf()
Executed in almost 0 second(s) in Ring 1.23

/*--- Human-readable time

pr()

oTime1 = new stzTime("14:00:00")
? oTime1.ToHuman()
#--> 2 o'clock PM

oTime2 = new stzTime("14:15:00")
? oTime2.ToHuman()
#--> Quarter past 2 PM

oTime3 = new stzTime("14:30:00")
? oTime3.ToHuman()
#--> Half past 2 PM

oTime4 = new stzTime("14:45:00")
? oTime4.ToHuman()
#--> Quarter to 3 PM

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Part of day

pr()

oTime1 = new stzTime("09:00:00")
? oTime1.PartOfDay()
#--> morning

oTime2 = new stzTime("14:00:00")
? oTime2.PartOfDay()
#--> afternoon

oTime3 = new stzTime("19:00:00")
? oTime3.PartOfDay()
#--> evening

oTime4 = new stzTime("23:00:00")
? oTime4.PartOfDay()
#--> night

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Copying time objects

pr()

oTime1 = new stzTime("14:30:00")
oTime2 = oTime1.Copy()
oTime2.AddHours(2)

? oTime1.ToString()
#--> 14:30:00

? oTime2.ToString()
#--> 16:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Working with milliseconds

pr()

oTime = new stzTime([:Hour = 14, :Minute = 30, :Second = 45, :Millisecond = 123])
? oTime.Millisecond()
#--> 123

? oTime.ToLong()
#--> 14:30:45.123

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Chaining operations with Q functions

pr()

oTime = StzTimeQ("10:00:00")
? oTime.AddHoursQ(2).AddMinutesQ(30).ToString()
#--> 12:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
