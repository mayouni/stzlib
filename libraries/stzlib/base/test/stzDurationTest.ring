load "../stzbase.ring"

/*--- Creating duration from seconds

pr()

oDuration = new stzDuration(3665)
? oDuration.Content() # Or ToString() or Duration()
#--> 1:01:05

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creation duration from natural language string

pr()

oDuration = new stzDuration("2 hours 30 minutes")
? oDuration.ToHuman()
#--> 2 hours and 30 minutes

# From hash definition
oDuration = new stzDuration([
	:Days = 1,
	:Hours = 3,
	:Minutes = 45,
	:Seconds = 30
])
? oDuration.ToCompact()
#--> 1d 3h 45m 30s

# Quick construction with Q functions
oDur = DurationQ("1 hour 15 minutes")
? oDur.TotalMinutes()
#--> 75

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- Retriving duration components

pr()

oDuration = new stzDuration("2 days 5 hours 30 minutes 45 seconds")

? oDuration.Days()
#--> 2

? oDuration.Hours()
#--> 5

? oDuration.Minutes()
#--> 30

? oDuration.Seconds()
#--> 45

# Total conversions
? oDuration.TotalHours()
#--> 53

? oDuration.TotalMinutes()
#--> 3210

? oDuration.TotalSeconds()
#--> 192645

# Get all components as hash
? @@NL( oDuration.Components() )
#--> [ :Days = 2, :Hours = 5, :Minutes = 30, :Seconds = 45, :Milliseconds = 0 ]

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- Arithmetic operations

pr()

# Addition with numbers (seconds)
oDur1 = DurationQ("1 hour")
oDur2 = oDur1 + 1800  # Add 1800 seconds (30 minutes)
? oDur2.ToHuman() + NL
#--> 1 hour and 30 minutes

# Addition with strings
oDur3 = oDur1 + "45 minutes"
? oDur3.ToHuman() + NL
#--> 1 hour and 45 minutes

# Addition with duration objects
oDur4 = DurationQ("30 minutes")
oDur5 = oDur1 + oDur4
? oDur5.ToHuman() + NL
#--> 1 hour and 30 minutes

# Subtraction
oDur6 = DurationQ("3 hours")
oDur7 = oDur6 - "1 hour 15 minutes"
? oDur7.ToHuman() + NL
#--> 1 hour and 45 minutes

# Multiplication
oDur8 = DurationQ("45 minutes")
oDur9 = oDur8 * 3
? oDur9.ToHuman() + NL
#--> 2 hours and 15 minutes

# Division
oDur10 = DurationQ("2 hours")
oDur11 = oDur10 / 4
? oDur11.ToHuman()
#--> 30 minutes

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*--- Comparisons

pr()

oDur1 = DurationQ("1 hour")
oDur2 = DurationQ("90 minutes")

? oDur1 < oDur2
#--> TRUE

? oDur1 = "1 hour"
#--> TRUE

? oDur2 > 3600  # 3600 seconds = 1 hour
#--> TRUE

? oDur1.IsLessThan(oDur2)
#--> TRUE

? oDur2.IsGreaterThan("1 hour")
#--> TRUE

? oDur1.IsEqualTo(3600)
#--> TRUE

# Range checking
oDur3 = DurationQ("75 minutes")
? oDur3.IsBetween("1 hour", "2 hours")
#--> TRUE

pf()
# Executed in 0.09 second(s) in Ring 1.24


/*--- Formatting options

pr()

? @Section("Softanza", 4, 7) #--> tanz

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- #TODO Add this feature to stzDate

pr()

ToDate("20250912")

o1 = new stzDate("20250912")
? o1.Content()

pf()

/*---

pr()

oDuration = new stzDuration("3 hours 25 minutes 42 seconds")

# Default format (H:mm:ss)
? oDuration.ToString()
#--> 3:25:42

# Custom formats
? oDuration.ToStringXT("HH:mm:ss")
#--> 03:25:42

? oDuration.ToStringXT("H hours, m minutes")
#--> 3 hours, 25 minutes

# Human-readable
? oDuration.ToHuman()
#--> 3 hours, 25 minutes, and 42 seconds

# Compact notation
? oDuration.ToCompact()
#--> 3h 25m 42s

# Simple time format
? oDuration.ToSimple()
#--> 3:25:42

pf()
# Executed in 0.04 second(s) in Ring 1.24


pr()

oDuration = new stzDuration("1 hour")

oDuration.AddMinutes(30)
? oDuration.ToHuman()
#--> 1 hour and 30 minutes

oDuration.AddHours(2)
? oDuration.ToHuman()
#--> 3 hours and 30 minutes

oDuration.Subtract("30 minutes")
? oDuration.ToHuman()
#--> 3 hours

# Chaining modifications
oDuration = DurationQ("1 hour")
oDuration {
	AddMinutes(45)
	AddSeconds(30)
	? ToHuman()
}
#--> 1 hour, 45 minutes, and 30 seconds

pf()
# Executed in 0.03 second(s) in Ring 1.24


/*--- Task Timer

pr()

nStartTime = clock()

# Simulate work
for i = 1 to 1000000
	# Work happening...
next

nEndTime = clock()
o1 = DurationQ(nEndTime - nStartTime)

? o1.ToHuman()
#--> 14 seconds

? o1.TotalSeconds()
#--> 14

pf()
# Executed in 0.01 second(s) in Ring 1.24


/*--- Meeting Scheduler

pr()

nMeetings = 3
oMeetingDuration = DurationQ("1 hour 30 minutes")
oBreakTime = DurationQ("15 minutes")


oTotalTime = (oMeetingDuration * nMeetings) + (oBreakTime * (nMeetings - 1))

# Meeting length
? oMeetingDuration.ToHuman()
#--> 1 hour and 30 minutes

# Break between meetings
? oBreakTime.ToHuman()
#--> 15 minutes

# Total time needed
? oTotalTime.ToHuman()
#--> 5 hours

# End time format
? oTotalTime.ToCompact()
#--> 5h

pf()
# Executed in 0.03 second(s) in Ring 1.24


/*--- Project Time Estimation

pr()

aTasks = [
	[ "Design mockups", DurationQ("2 days") ],
	[ "Backend development", DurationQ("5 days") ],
	[ "Frontend development", DurationQ("4 days") ],
	[ "Testing", DurationQ("2 days") ],
	[ "Deployment", DurationQ("1 day") ]
]

oTotalProject = DurationQ(0)

? "Task breakdown:"
for aTask in aTasks
	? "  " + aTask[1] + ": " + aTask[2].ToCompact()
	oTotalProject = oTotalProject + aTask[2]
next

? ""
? "Total project duration: " + oTotalProject.ToHuman()
? "Working days: " + oTotalProject.TotalDays()

# Add 20% buffer
oBuffer = oTotalProject * 0.20
oWithBuffer = oTotalProject + oBuffer

? "With 20% buffer: " + oWithBuffer.ToHuman()
? "Total days (with buffer): " + oWithBuffer.TotalDays()

#-->
# Task breakdown:
#   Design mockups: 2d
#   Backend development: 5d
#   Frontend development: 4d
#   Testing: 2d
#   Deployment: 1d
# 
# Total project duration: 14 days
# Working days: 14
# With 20% buffer: 16 days, 19 hours, and 12 minutes
# Total days (with buffer): 16

pf()
# Executed in 0.04 second(s) in Ring 1.24


/*--- High Precision Duration

pr()

oPrecise = new stzDuration([
	:Hours = 1,
	:Minutes = 23,
	:Seconds = 45,
	:Milliseconds = 678
])

? oPrecise.ToStringXT("HH:mm:ss.zzz")
#--> 01:23:45.678

? oPrecise.Milliseconds()
#--> 678

? oPrecise.TotalSeconds()
#--> 5025

pf()
# Executed in almost 0 second(s) in Ring 1.24


/*--- Duration State Checks

pr()

oZero = DurationQ(0)
? oZero.IsZero()
#--> TRUE

oPositive = DurationQ("2 hours")
? oPositive.IsPositive()
#--> TRUE

oNegative = DurationQ(-3600)
? oNegative.IsNegative()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.24


/*--- Copy and Clone

pr()

oOriginal = DurationQ("2 hours 30 minutes")
oCopy = oOriginal.Copy()

oCopy.AddMinutes(15)

# Original
? oOriginal.ToHuman()
#--> 2 hours and 30 minutes

# Copy (modified)
? oCopy.ToHuman()
#--> 2 hours and 45 minutes

oClone = oOriginal.Clone()
? oClone.ToHuman()
#--> 2 hours and 30 minutes

pf()
# Executed in 0.04 second(s) in Ring 1.24


/*--- Edge Cases

pr()

# Empty/null duration
oEmpty = DurationQ("")
? oEmpty.IsZero() + NL
#--> TRUE

# Very large duration
oLarge = DurationQ("365 days")
? oLarge.ToHuman()
? oLarge.TotalHours() + NL

# Single unit durations
oOneSecond = DurationQ("1 second")
? oOneSecond.ToHuman()
#--> 1 second

oOneMinute = DurationQ("1 minute")
? oOneMinute.ToHuman()
#--> 1 minute

oOneHour = DurationQ("1 hour")
? oOneHour.ToHuman()
#--> 1 hour

oOneDay = DurationQ("1 day")
? oOneDay.ToHuman()
#--> 1 day

pf()
# Executed in 0.06 second(s) in Ring 1.24
