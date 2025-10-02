# Time Programming in Softanza: A Gentle Introduction

Time is everywhere in software. Birthdays, deadlines, business hours, event timestamps—each scenario needs a different lens. Softanza recognizes this with three specialized classes that work together seamlessly.

## Meet the Family

**stzDate** handles pure calendar logic:
```ring
oBirthday = new stzDate("15/06/1990")
? oBirthday.Age()                #--> 35
```

**stzTime** manages clock operations:
```ring
oStart = new stzTime("09:15:00")
? oStart + 75                    #--> 10:30:00 (adds 75 minutes)
```

**stzDateTime** combines both for complete timestamps:
```ring
oMeeting = StzDateTimeQ("2024-03-15 14:30:00")
? oMeeting + "2 days 3 hours"    #--> 2024-03-17 17:30:00
```

## Why Three Classes?

You don't calculate age with timestamps. You don't schedule meetings with just dates. Separating concerns keeps code clear:

- Planning a project deadline? → **stzDate**
- Measuring task duration? → **stzTime**  
- Logging user actions? → **stzDateTime**

Each class focuses on its domain while sharing a common design philosophy.

## The Common Language

All three speak the same dialect:

```ring
# Natural arithmetic
oDate + "3 months"
oTime + "45 minutes"
oDateTime + "2 days"

# Intuitive comparisons
? oDate1 < oDate2                #--> TRUE
? oTime1 > "14:30:00"            #--> FALSE

# Human-readable output
? oDate.ToHuman()                #--> tomorrow
? oTime.ToHuman()                #--> Half past 2 PM
? oDateTime.ToRelative()         #--> 2 hours ago
```

This consistency means learning one class teaches you patterns for all three.

## A Quick Taste

Here's real power in action—calculating when to send event reminders:

```ring
# Event next month
oEvent = StzDateTimeQ("2024-06-20 15:00:00")

# Send email 3 days before
oReminder = oEvent - "3 days"
? oReminder.ToLong()
#--> Monday, June 17, 2024 3:00:00 PM

# Extract just the date for calendar display
oEventDate = oEvent.DateQ()
? oEventDate.DayName()           #--> Thursday

# Calculate event duration
oEnd = oEvent + "2 hours"
? oEvent.HoursTo(oEnd)           #--> 2
```

See how they interoperate? `DateQ()` and `TimeQ()` methods let you extract components as full-featured objects when you need specialized operations.

## Built on Solid Ground

Behind the expressive syntax lies Qt's battle-tested C++ engine. Operations execute in microseconds. You get both elegance and performance.

## Dive Deeper

Each class deserves its own exploration:

- **[stzDate: Date Programming Made Easy](stzdate-date-programming-in-softanza.md)** - Calendar arithmetic, age calculations, multilingual day names, and human-readable formatting
- **[stzTime: Time Handling in Softanza](stztime-handling-time-in-softanza.md)** - Duration math, format conversion, precision handling, and clock comparisons
- **[stzDateTime: Elegant DateTime Operations](stzdatetime-guide-narration.md)** - Combined operations, timezone handling, comprehensive formatting, and Unix timestamps

These guides show the full API with real-world examples and design rationale.

## Start Experimenting

```ring
# Try this right now
oToday = TodayQ()
? oToday + "100 days"

oNow = TimeQ()
? oNow.ToHuman()

oTimestamp = StzDateTimeQ("")
? oTimestamp.ToRelative()
```

Time programming in Softanza feels less like wrestling an API and more like having a conversation. The three classes are there when you need them, invisible when you don't.