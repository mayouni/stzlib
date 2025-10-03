load "../stzbase.ring"

/*=======================
   CREATING DURATIONS
========================)

/*--- From seconds

pr()

oDuration = new stzDuration(3665)
? oDuration.ToString()
#--> 1:01:05

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- From natural language string
*/
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

/*=======================
   COMPONENT ACCESS
========================)

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
? oDuration.Components()
#--> [ :Days = 2, :Hours = 5, :Minutes = 30, :Seconds = 45, :Milliseconds = 0 ]

/*=======================
   ARITHMETIC OPERATIONS
========================)

# Addition with numbers (seconds)
oDur1 = DurationQ("1 hour")
oDur2 = oDur1 + 1800  # Add 1800 seconds (30 minutes)
? oDur2.ToHuman()
#--> 1 hour and 30 minutes

# Addition with strings
oDur3 = oDur1 + "45 minutes"
? oDur3.ToHuman()
#--> 1 hour and 45 minutes

# Addition with duration objects
oDur4 = DurationQ("30 minutes")
oDur5 = oDur1 + oDur4
? oDur5.ToHuman()
#--> 1 hour and 30 minutes

# Subtraction
oDur6 = DurationQ("3 hours")
oDur7 = oDur6 - "1 hour 15 minutes"
? oDur7.ToHuman()
#--> 1 hour and 45 minutes

# Multiplication
oDur8 = DurationQ("45 minutes")
oDur9 = oDur8 * 3
? oDur9.ToHuman()
#--> 2 hours and 15 minutes

# Division
oDur10 = DurationQ("2 hours")
oDur11 = oDur10 / 4
? oDur11.ToHuman()
#--> 30 minutes

/*=======================
   COMPARISONS
========================)

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

/*=======================
   FORMATTING OPTIONS
========================)

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

/*=======================
   MODIFICATION METHODS
========================)

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

/*============================
   REAL-WORLD EXAMPLE: TASK TIMER
=============================)

? "--- Task Timer ---"

oTaskDuration = DurationQ(0)
nStartTime = clock()

# Simulate work
for i = 1 to 1000000
	# Work happening...
next

nEndTime = clock()
oTaskDuration = DurationQ(nEndTime - nStartTime)

? "Task completed in: " + oTaskDuration.ToHuman()
? "Total seconds: " + oTaskDuration.TotalSeconds()

/*====================================
   REAL-WORLD EXAMPLE: MEETING SCHEDULER
=====================================)

? ""
? "--- Meeting Scheduler ---"

oMeetingLength = DurationQ("1 hour 30 minutes")
oBreakTime = DurationQ("15 minutes")
nMeetings = 3

oTotalTime = (oMeetingLength * nMeetings) + (oBreakTime * (nMeetings - 1))

? "Meeting length: " + oMeetingLength.ToHuman()
? "Number of meetings: " + nMeetings
? "Break between meetings: " + oBreakTime.ToHuman()
? "Total time needed: " + oTotalTime.ToHuman()
? "End time format: " + oTotalTime.ToCompact()

/*====================================
   REAL-WORLD EXAMPLE: VIDEO PLAYER
=====================================)

? ""
? "--- Video Player Duration ---"

oVideoDuration = DurationQ(7342)  # seconds from media file

? "Duration: " + oVideoDuration.ToStringXT("HH:mm:ss")
? "Human-readable: " + oVideoDuration.ToHuman()
? "Compact: " + oVideoDuration.ToCompact()

# Calculate chapters (every 30 minutes)
oChapterLength = DurationQ("30 minutes")
nChapters = ceil(oVideoDuration.TotalSeconds() / oChapterLength.TotalSeconds())
? "Suggested chapters: " + nChapters

/*====================================
   REAL-WORLD EXAMPLE: WORKOUT TRACKER
=====================================)

? ""
? "--- Workout Tracker ---"

oWarmup = DurationQ("10 minutes")
oExercise = DurationQ("45 minutes")
oCooldown = DurationQ("5 minutes")

oTotalWorkout = oWarmup + oExercise + oCooldown

? "Warmup: " + oWarmup.ToCompact()
? "Exercise: " + oExercise.ToCompact()
? "Cooldown: " + oCooldown.ToCompact()
? "Total workout time: " + oTotalWorkout.ToHuman()

# Check if workout fits in available time
oAvailableTime = DurationQ("1 hour 15 minutes")

if oTotalWorkout < oAvailableTime
	oExtraTime = oAvailableTime - oTotalWorkout
	? "Workout fits! Extra time: " + oExtraTime.ToHuman()
else
	oOverTime = oTotalWorkout - oAvailableTime
	? "Need more time: " + oOverTime.ToHuman()
ok

/*====================================
   REAL-WORLD EXAMPLE: COOKING TIMER
=====================================)

? ""
? "--- Cooking Timer ---"

oPrepTime = DurationQ("15 minutes")
oCookTime = DurationQ("45 minutes")
oRestTime = DurationQ("10 minutes")

oTotalRecipeTime = oPrepTime + oCookTime + oRestTime

? "Prep: " + oPrepTime.ToCompact()
? "Cook: " + oCookTime.ToCompact()
? "Rest: " + oRestTime.ToCompact()
? ""
? "Total time: " + oTotalRecipeTime.ToHuman()
? "Ready in: " + oTotalRecipeTime.ToStringXT("H:mm")

# Multiple servings
nServings = 3
oTotalForAll = oTotalRecipeTime * nServings
? ""
? "For " + nServings + " batches: " + oTotalForAll.ToHuman()

/*====================================
   REAL-WORLD EXAMPLE: PROJECT ESTIMATION
=====================================)

? ""
? "--- Project Time Estimation ---"

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

/*====================================
   REAL-WORLD EXAMPLE: STREAMING SERVICE
=====================================)

? ""
? "--- Streaming Watch Time ---"

aWatchHistory = [
	DurationQ("45 minutes"),  # Episode 1
	DurationQ("43 minutes"),  # Episode 2
	DurationQ("48 minutes"),  # Episode 3
	DurationQ("1 hour 30 minutes")  # Movie
]

oTotalWatched = DurationQ(0)
for oDur in aWatchHistory
	oTotalWatched = oTotalWatched + oDur
next

? "Total watch time: " + oTotalWatched.ToHuman()
? "Hours watched: " + oTotalWatched.TotalHours()

# Monthly limit check
oMonthlyLimit = DurationQ("30 hours")
oRemaining = oMonthlyLimit - oTotalWatched

if oRemaining.IsPositive()
	? "Remaining this month: " + oRemaining.ToHuman()
else
	? "Monthly limit reached!"
ok

/*====================================
   MILLISECOND PRECISION
=====================================)

? ""
? "--- High Precision Duration ---"

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

/*====================================
   DURATION STATE CHECKS
=====================================)

? ""
? "--- Duration State Checks ---"

oZero = DurationQ(0)
? oZero.IsZero()
#--> TRUE

oPositive = DurationQ("2 hours")
? oPositive.IsPositive()
#--> TRUE

oNegative = DurationQ(-3600)
? oNegative.IsNegative()
#--> TRUE

/*====================================
   INTEGRATION WITH DATETIME CLASSES
=====================================)

? ""
? "--- Duration with DateTime ---"

# Note: This assumes stzDateTime is available
# Adding duration to time
oMeetingLength = DurationQ("1 hour 30 minutes")
# oStartTime = TimeQ("09:00:00")
# oEndTime = oStartTime + oMeetingLength.TotalSeconds()
# ? "Meeting ends at: " + oEndTime

? "Meeting duration: " + oMeetingLength.ToHuman()

/*====================================
   COPY AND CLONE
=====================================)

? ""
? "--- Copy and Clone ---"

oOriginal = DurationQ("2 hours 30 minutes")
oCopy = oOriginal.Copy()

oCopy.AddMinutes(15)

? "Original: " + oOriginal.ToHuman()
#--> 2 hours and 30 minutes

? "Copy (modified): " + oCopy.ToHuman()
#--> 2 hours and 45 minutes

oClone = oOriginal.Clone()
? "Clone: " + oClone.ToHuman()
#--> 2 hours and 30 minutes

/*====================================
   EDGE CASES
=====================================)

? ""
? "--- Edge Cases ---"

# Empty/null duration
oEmpty = DurationQ("")
? oEmpty.IsZero()
#--> TRUE

# Very large duration
oLarge = DurationQ("365 days")
? "Large duration: " + oLarge.ToHuman()
? "Total hours: " + oLarge.TotalHours()

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
