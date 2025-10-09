# stzDuration: Measuring Time in Softanza

## The Timeline Challenge

You're building a project tracker. Three tasks took "2 days", "5 days", and "4 days" respectively. How long is the project? Add a 20% buffer and show it in human terms.

```ring
oDur1 = DurationQ("2 days")
oDur2 = DurationQ("5 days")
oDur3 = DurationQ("4 days")

oTotal = oDur1 + oDur2 + oDur3
? oTotal.ToHuman()
#--> 11 days

oWithBuffer = oTotal * 1.20
? oWithBuffer.ToHuman()
#--> 13 days, 4 hours, and 48 minutes
```

That's `stzDuration`—intuitive creation, natural arithmetic, readable output.

## Creating Durations: Accept Anything

Duration data arrives in many forms. Softanza handles them all:

```ring
# From seconds (API responses, timers)
oDur1 = new stzDuration(3665)
? oDur1.Content()
#--> 1:01:05

# From natural language (user input)
oDur2 = new stzDuration("2 hours 30 minutes")
? oDur2.ToHuman()
#--> 2 hours and 30 minutes

# From hash definition (programmatic construction)
oDur3 = new stzDuration([
    :Days = 1,
    :Hours = 3,
    :Minutes = 45,
    :Seconds = 30
])
? oDur3.ToCompact()
#--> 1d 3h 45m 30s

# Quick construction with Q functions
oDur4 = DurationQ("1 hour 15 minutes")
? oDur4.TotalMinutes()
#--> 75
```

No format conversion needed—just instantiate and work.

## Component Access: Precise Breakdowns

Extract exactly what you need:

```ring
oDuration = new stzDuration("2 days 5 hours 30 minutes 45 seconds")

# Individual components
? oDuration.Days()           #--> 2
? oDuration.Hours()          #--> 5
? oDuration.Minutes()        #--> 30
? oDuration.Seconds()        #--> 45

# Total conversions (cumulative)
? oDuration.TotalHours()     #--> 53
? oDuration.TotalMinutes()   #--> 3210
? oDuration.TotalSeconds()   #--> 192645

# Complete breakdown as hash
? oDuration.Components()
#--> [:Days = 2, :Hours = 5, :Minutes = 30, :Seconds = 45, :Milliseconds = 0]
```

Notice `TotalHours()` returns 53 (cumulative), while `Hours()` returns 5 (component within days). Choose based on your calculation needs.

## Arithmetic: Natural Operations

Duration math works like you'd expect, with intelligent polymorphism:

```ring
oDur1 = DurationQ("1 hour")

# Add seconds directly
oDur2 = oDur1 + 1800
? oDur2.ToHuman()
#--> 1 hour and 30 minutes

# Add natural language strings
oDur3 = oDur1 + "45 minutes"
? oDur3.ToHuman()
#--> 1 hour and 45 minutes

# Add duration objects
oDur4 = DurationQ("30 minutes")
oDur5 = oDur1 + oDur4
? oDur5.ToHuman()
#--> 1 hour and 30 minutes

# Subtraction
oDur6 = DurationQ("3 hours") - "1 hour 15 minutes"
? oDur6.ToHuman()
#--> 1 hour and 45 minutes

# Multiplication for scaling
oDur7 = DurationQ("45 minutes") * 3
? oDur7.ToHuman()
#--> 2 hours and 15 minutes

# Division for splitting
oDur8 = DurationQ("2 hours") / 4
? oDur8.ToHuman()
#--> 30 minutes
```

The `+` operator adapts: numbers mean seconds, strings parse as natural language, objects combine directly. This polymorphism eliminates conversion boilerplate.

## Comparisons: Intuitive and Flexible

Compare durations using operators or named methods:

```ring
oDur1 = DurationQ("1 hour")
oDur2 = DurationQ("90 minutes")

# Operator comparisons
? oDur1 < oDur2              #--> TRUE
? oDur1 = "1 hour"           #--> TRUE
? oDur2 > 3600               #--> TRUE (3600 seconds)

# Named methods for clarity
? oDur1.IsLessThan(oDur2)    #--> TRUE
? oDur2.IsGreaterThan("1 hour")  #--> TRUE
? oDur1.IsEqualTo(3600)      #--> TRUE

# Range checking
oDur3 = DurationQ("75 minutes")
? oDur3.IsBetween("1 hour", "2 hours")  #--> TRUE
```

Comparisons accept durations, strings, or seconds—whatever your code logic needs.

## Formatting: From Technical to Human

Display durations appropriately for context:

```ring
oDuration = new stzDuration("3 hours 25 minutes 42 seconds")

# Default time format
? oDuration.ToString()
#--> 3:25:42

# Custom Qt format patterns
? oDuration.ToStringXT("HH:mm:ss")
#--> 03:25:42

? oDuration.ToStringXT("H hours, m minutes")
#--> 3 hours, 25 minutes

# Human-readable (for UI display)
? oDuration.ToHuman()
#--> 3 hours, 25 minutes, and 42 seconds

# Compact notation (for tight spaces)
? oDuration.ToCompact()
#--> 3h 25m 42s

# Simple colon-separated
? oDuration.ToSimple()
#--> 3:25:42
```

Choose between technical precision (`ToString()`) and user-friendly text (`ToHuman()`).

## Customizing Human Output: Data-Driven Patterns

`ToHuman()` is designed for extensibility. Add custom patterns globally without modifying the class code:

```ring
# Global pattern container (defined once in your application)

? @@NL($aDurationPatterns) + NL
#--> [
#    [365, 23, 59, 59, "1 year"],
#    [183, 23, 59, 59, "6 months"],
#    [30, 23, 59, 59, "1 month"],
#    [7, 0, 0, 0, "1 week"],
#    [14, 0, 0, 0, "2 weeks"]
# ]

# Now durations matching these patterns display specially
o1 = new stzDuration("365 days 23 hours 59 minutes 59 seconds")
? o1.ToHuman()
#--> 1 year

o1 = new stzDuration("7 days")
? o1.ToHuman() + NL
#--> 1 week

# Non-matching durations fall back to component-based format
o1 = new stzDuration("8 days")
? o1.ToHuman()
#--> 8 days

# Add domain-specific patterns for your application
$aDurationPatterns + [90, 0, 0, 0, "1 quarter"]
$aDurationPatterns + [1, 0, 0, 0, "1 business day"]

o1 = new stzDuration("90 days")
? o1.ToHuman()
#--> 1 quarter

? StzDurationQ("1 day").ToHuman()
#--> 1 business day
```

**How it works:**

1. **Pattern structure:** Each pattern is `[days, hours, minutes, seconds, label]`
2. **Exact matching:** `ToHuman()` checks if duration components match any pattern exactly
3. **Fallback logic:** Non-matching durations use component-based formatting ("5 days, 3 hours, and 20 minutes")
4. **Global scope:** Patterns defined once apply to all `stzDuration` instances

**Customizing unit names:**

```ring
# Global unit container
$aUnitNames = [
    [:Days, "day", "days"],
    [:Hours, "hour", "hours"],
    [:Minutes, "minute", "minutes"],
    [:Seconds, "second", "seconds"]
]

# Change to abbreviated forms
$aUnitNames = [
    [:Days, "d", "d"],
    [:Hours, "h", "h"],
    [:Minutes, "m", "m"],
    [:Seconds, "s", "s"]
]

oDur = DurationQ("2 days 5 hours")
? oDur.ToHuman()
#--> 2 d and 5 h
```

This pattern-driven approach separates presentation logic from core functionality. Define patterns that match your domain (sprints, billing cycles, service intervals) without touching class internals.

## High Precision: Millisecond Support

When accuracy matters:

```ring
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
```

Millisecond precision handles performance profiling, financial timestamps, and high-frequency logging.

## Practical Example: Meeting Scheduler

Calculate total time for a meeting series:

```ring
nMeetings = 3
oMeetingDuration = DurationQ("1 hour 30 minutes")
oBreakTime = DurationQ("15 minutes")

# Total = (meetings × duration) + (breaks × duration)
oTotalTime = (oMeetingDuration * nMeetings) + 
             (oBreakTime * (nMeetings - 1))

? "Meeting length: " + oMeetingDuration.ToHuman()
#--> Meeting length: 1 hour and 30 minutes

? "Break between: " + oBreakTime.ToHuman()
#--> Break between: 15 minutes

? "Total time needed: " + oTotalTime.ToHuman()
#--> Total time needed: 5 hours

? "End time format: " + oTotalTime.ToCompact()
#--> End time format: 5h
```

The arithmetic reads like the problem statement—no manual conversion logic needed.

## Task Timer: Real-World Profiling

Measure actual execution time:

```ring
nStartTime = clock()

# Simulate work
for i = 1 to 1000000
    # Processing...
next

nEndTime = clock()
oDuration = DurationQ(nEndTime - nStartTime)

? "Elapsed: " + oDuration.ToHuman()
#--> Elapsed: 14 seconds

? "Total seconds: " + oDuration.TotalSeconds()
#--> Total seconds: 14
```

Perfect for performance monitoring and progress indicators.

## Project Time Estimation: Complete Example

The opening example expanded with real-world details:

```ring
aTasks = [
    ["Design mockups", DurationQ("2 days")],
    ["Backend development", DurationQ("5 days")],
    ["Frontend development", DurationQ("4 days")],
    ["Testing", DurationQ(172800)],        # API gave us seconds (2 days)
    ["Deployment", DurationQ("1 day")]
]

# Calculate total project time
oTotalProject = DurationQ(0)

? "Task breakdown:"
for aTask in aTasks
    ? "  " + aTask[1] + ": " + aTask[2].ToCompact()
    oTotalProject = oTotalProject + aTask[2]
next

? ""
? "Total: " + oTotalProject.ToHuman()
#--> Total: 14 days

# Add 20% buffer for realistic estimates
oWithBuffer = oTotalProject * 1.20
? "With buffer: " + oWithBuffer.ToHuman()
#--> With buffer: 16 days, 19 hours, and 12 minutes

? "Working days needed: " + oWithBuffer.TotalDays()
#--> Working days needed: 16

#-->
# Task breakdown:
#   Design mockups: 2d
#   Backend development: 5d
#   Frontend development: 4d
#   Testing: 2d
#   Deployment: 1d
# 
# Total: 14 days
# With buffer: 16 days, 19 hours, and 12 minutes
# Working days needed: 16
```

This is duration handling that adapts to your data's reality—flexible input, powerful arithmetic, readable output.

## State Checks and Edge Cases

Validate duration states:

```ring
# Zero duration
oZero = DurationQ(0)
? oZero.IsZero()             #--> TRUE

# Positive/negative checks
oPositive = DurationQ("2 hours")
? oPositive.IsPositive()     #--> TRUE

oNegative = DurationQ(-3600)
? oNegative.IsNegative()     #--> TRUE

# Empty input defaults to zero
oEmpty = DurationQ("")
? oEmpty.IsZero()            #--> TRUE

# Large durations work seamlessly
oLarge = DurationQ("365 days")
? oLarge.TotalHours()        #--> 8760
```

## Copy and Clone: Safe Modifications

Create independent copies:

```ring
oOriginal = DurationQ("2 hours 30 minutes")
oCopy = oOriginal.Copy()

oCopy.AddMinutes(15)

? oOriginal.ToHuman()        #--> 2 hours and 30 minutes (unchanged)
? oCopy.ToHuman()            #--> 2 hours and 45 minutes (modified)
```

Both `Copy()` and `Clone()` create independent objects—modify one without affecting the other.

## Modification Methods: Chainable Operations

Update durations fluently:

```ring
oDuration = DurationQ("1 hour")

oDuration.AddMinutes(30)
? oDuration.ToHuman()
#--> 1 hour and 30 minutes

oDuration.AddHours(2)
? oDuration.ToHuman()
#--> 3 hours and 30 minutes

oDuration.Subtract("30 minutes")
? oDuration.ToHuman()
#--> 3 hours

# Chaining for complex adjustments
oDuration = DurationQ("1 hour")
oDuration {
    AddMinutes(45)
    AddSeconds(30)
    ? ToHuman()
}
#--> 1 hour, 45 minutes, and 30 seconds
```

## The Softanza Advantage

`stzDuration` integrates seamlessly with the temporal family:

```ring
# From stzTime differences
oStart = TimeQ("09:00:00")
oEnd = TimeQ("17:30:00")
oDuration = oStart.DurationTo(oEnd)
? oDuration.ToHuman()
#--> 8 hours and 30 minutes

# From stzDateTime calculations
oEvent = StzDateTimeQ("2024-03-15 14:00:00")
oDeadline = StzDateTimeQ("2024-03-20 17:00:00")
oTimeLeft = oEvent.DurationTo(oDeadline)
? oTimeLeft.TotalHours()
#--> 123
```

All three classes speak the same arithmetic dialect—natural language parsing, operator overloading, human-readable output.

## Built on Qt's Foundation

Like `stzTime` and `stzDateTime`, durations leverage Qt's C++ engine through RingQt. You get microsecond-level performance with Ring's expressive syntax.

## Conclusion

`stzDuration` transforms time measurements from data juggling into natural operations. Whether you're building dashboards, schedulers, or timers, it handles the complexity while keeping your code readable. The data-driven customization system means your duration displays adapt to your domain language without code changes—define patterns once, apply everywhere. The unified design across Softanza's temporal classes means patterns learned here apply everywhere—one philosophy, three specialized tools.
