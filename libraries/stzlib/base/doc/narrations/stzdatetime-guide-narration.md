# stzDateTime: Elegant DateTime Operations in Softanza

DateTime manipulation is a universal programming challenge—combining date and time logic while handling formats, timezones, and arithmetic. The `stzDateTime` class from Softanza transforms this complexity into an intuitive, expressive experience built on Qt's robust foundation.

## The Temporal Class Suite: stzDate, stzTime, stzDateTime, stzDuration, stzTimeline, and stzCalendar

Softanza's temporal system comprises a suite of interconnected classes, each addressing specific aspects of time handling to avoid conceptual overlap while enabling seamless integration:

* **stzDate**: Pure calendar operations (birthdays, deadlines, historical events).
* **stzTime**: Clock-based logic (business hours, durations, scheduling).
* **stzDateTime**: Combined operations requiring both date and time (logging, event scheduling, timestamps).
* **stzDuration**: Dedicated handling of time spans independently of specific dates/times, with arithmetic, unit conversions, and formatting (e.g., "2 days 3 hours" as an object).
* **stzTimeline**: Management of sequences or series of temporal events, supporting interval calculations, overlaps, timelines, and event ordering.
* **stzCalendar**: #TODO

This modular design mirrors real-world reasoning: Use stzDateTime for timestamps, extract stzDate or stzTime for specialized ops via DateQ() or TimeQ(), wrap durations in stzDuration for reusable spans, and organize events with stzTimeline. The classes interoperate fluidly—e.g., adding a stzDuration to a stzDateTime or building a stzTimeline from stzDateTime instances.


## Creating DateTime Objects: Flexibility by Design

Softanza accepts multiple input styles because your data comes from various sources. Whether parsing user input, deserializing APIs, or working with Unix timestamps, there's a natural path:

```ring
# Current moment - empty string or dedicated functions
? NowXT()  # Or NowDateTime()
#--> 2025-10-04 21:30:44

oNow = StzDateTimeQ("")
? oNow.Content() 		# Or ToString() or DateTime()
#--> 2025-10-02 14:30:45

# String parsing - auto-detects common formats
oMeeting = StzDateTimeQ("2024-03-15 14:30:45")
? oMeeting.DateTime()
#--> 2024-03-15 14:30:45

# Explicit hash - perfect for programmatic construction
oDeadline = StzDateTimeQ([
    :Year = 2024, :Month = 12, :Day = 31,
    :Hour = 23, :Minute = 59, :Second = 59
])
? oDeadline.ToString()
#--> 2024-12-31 23:59:59

# Unix timestamp - seamless API integration
oEpoch = StzDateTimeQ(1710511845)
? oEpoch.Content()
#--> 2024-03-15 14:30:45
```

Validation ensures robustness:
```ring
? IsDateTime("2024-03-15 10:00:00")  #--> TRUE
? IsValidDateTime("invalid")         #--> FALSE
```

This flexibility eliminates boilerplate—no manual parsing, no format juggling. Just natural instantiation.

## Arithmetic: Where Operators Become Language

The hallmark of great API design is making code read like thought. Softanza's operator overloading achieves this by understanding context:

```ring
oStart = StzDateTimeQ("2024-03-15 14:30:00")

# Add seconds numerically
oPlus5 = oStart + 5
? oPlus5.Content()
#--> 2024-03-15 14:30:05

# Or use natural language
oFuture = oStart + "2 days 3 hours"
? oFuture.Content()
#--> 2024-03-17 17:30:00

# Explicit natural methods for complex durations
oStart.AddNatural("2 days 3 hours 30 minutes 28 seconds 540 milliseconds")
? oStart.ToStringXT("yyyy-MM-dd hh:mm:ss.zzz")
#--> 2024-03-17 17:30:28.540

oStart.SubtractNatural("1 day 2 hours")
? oStart.Content()
#--> 2024-03-16 15:30:28.540
```

Notice how the `+` operator adapts? With a number, it adds seconds. With a string, it parses duration syntax. This polymorphism mirrors human reasoning—you don't think "I'll add 172800 seconds," you think "add 2 days."

Subtraction reveals duration automatically:

```ring
oEnd = StzDateTimeQ("2024-03-17 17:30:00")
nSeconds = oEnd - oStart
? nSeconds
#--> 183600  # Total seconds between moments

# Comparisons work exactly as expected
? oStart < oEnd      #--> TRUE
? oStart <= oStart   #--> TRUE
```

Chaining enhances fluidity:
```ring
? oStart.AddDaysQ(5).AddHoursQ(3).AddMinutesQ(30).ToString()
#--> 2024-03-20 17:30:30
```

## Duration Calculations: From Seconds to Stories

When you need granular breakdowns, `DurationTo()` delivers complete temporal distance analysis:

```ring
oProject = StzDateTimeQ("2024-01-01 09:00:00")
oLaunch = StzDateTimeQ("2024-03-15 14:30:45.123")

aDuration = oProject.DurationTo(oLaunch)
? aDuration
#--> [
#    :Days = 74,
#    :Hours = 5,
#    :Minutes = 30,
#    :Seconds = 45,
#    :Milliseconds = 123
# ]

# Specialized units
? oProject.DurationTo(oLaunch, :In = :Weeks)  #--> 10 (approx.)
? oProject.DurationTo(oLaunch, :InYears)      #--> 0
```

This hash format makes it trivial to build user-facing messages: "Your project took 74 days, 5 hours, and 30 minutes." For quick math, specialized methods bypass the hash:

```ring
? oProject.DaysTo(oLaunch)      #--> 74
? oProject.HoursTo(oLaunch)     #--> 1781
? oProject.MinutesTo(oLaunch)   #--> 106870
```

Each method returns total units—`HoursTo()` gives 1781, not just the 5 hours within the final day. This flexibility lets you choose precision versus simplicity based on context.

## Formatting: A Hierarchical Philosophy

Softanza's formatting system reflects a deliberate design: **Time System → Localization → Precision → Verbosity**. This hierarchy gives you control without complexity. Defaults to 24-hour for precision, with easy 12-hour variants.

### Named Formats: 24-Hour Default

The library defaults to 24-hour time for precision and international clarity, with formats organized by use case:

```ring
oEvent = StzDateTimeQ("2024-03-15 14:30:45")

# ISO formats - for data interchange and logs
? oEvent.ToISO()
#--> 2024-03-15 14:30:45

? oEvent.ToISO8601()
#--> 2024-03-15T14:30:45

# Compact - when space matters
? oEvent.ToCompact()
#--> 2024-03-15 14:30

# Localized conventions
? oEvent.ToStandard()    # European DD/MM/YYYY
#--> 15/03/2024 14:30:45

? oEvent.ToAmerican()    # US MM/DD/YYYY
#--> 03/15/2024 14:30:45

# Verbose - full human readability
? oEvent.ToVerbose()
#--> Friday, March 15, 2024 14:30:45
```

### 12-Hour Variants: One Suffix, Universal Application

Want AM/PM? Simply append `12h` to any format name. This consistent pattern eliminates memorization and supports locale-aware AM/PM text:

```ring
? oEvent.ToISO12h()
#--> 2024-03-15 02:30:45 PM

? oEvent.ToStandard12h()
#--> 15/03/2024 02:30:45 PM

? oEvent.ToVerbose12h()
#--> Friday, March 15, 2024 02:30:45 PM
```

Edge cases like midnight/noon and single-digit hours are handled gracefully:
```ring
oMidnight = StzDateTimeQ("2024-03-15 00:00:00")
? oMidnight.ToString12h()
#--> 2024-03-15 12:00:00 AM

oSingle = StzDateTimeQ("2024-03-15 03:05:00")
? oSingle.ToStringXT("h:mm AP")
#--> 3:05 AM
```

### Convenience Formats: Balanced Defaults

For common scenarios, convenience formats provide balanced presets with variants:

```ring
? oEvent.ToSimple()
#--> 15/03/2024 2:30 PM

? oEvent.ToSimple24h()
#--> 15/03/2024 14:30

? oEvent.ToMedium12h()
#--> Fri, Mar 15 2:30 PM

? oEvent.ToShort24h()
#--> 15/03 14:30

? oEvent.ToLong()
#--> Friday, March 15, 2024 2:30:45 PM

? oEvent.ToLongDate()  # Date-only verbose
#--> Friday, March 15, 2024
```

These formats automatically use 12-hour time because they're designed for user-facing contexts where AM/PM convention dominates. Error handling is built-in:
```ring
? oEvent.ToStringXT(:NonExistentFormat)
#--> ERROR: The pattern name you provided does not exist in stzRegexData file.
```

### Custom Patterns: Qt's Power, Simplified

When presets don't fit, Qt's format string syntax or symbolic names give unlimited control:

```ring
# Qt format string - leverage the full power
? oEvent.ToStringXT("yyyy-MM-dd HH:mm:ss.zzz")
#--> 2024-03-15 14:30:45.000

# Symbolic name - readable and reusable
? oEvent.ToStringXT(:ISOWithMs)
#--> 2024-03-15 14:30:45.000

# Creative patterns
? oEvent.ToStringXT("dddd 'at' h:mm AP")
#--> Friday at 2:30 PM
```

This layered approach means you start simple and reach for power only when needed.

## Component Extraction: Direct Access Without Parsing

Need a specific part? Direct accessor methods bypass string manipulation:

```ring
oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.Year()      #--> 2024
? oDateTime.Month()     #--> March
? oDateTime.MonthN()    #--> 3
? oDateTime.Day()       #--> Friday
? oDateTime.DayN()      #--> 15
? oDateTime.Hours()     #--> 14
? oDateTime.Minutes()   #--> 30
? oDateTime.Seconds()   #--> 45

# Access specialized objects for date/time-specific operations
oDate = oDateTime.DateQ()  # Returns stzDate
oTime = oDateTime.TimeQ()  # Returns stzTime
```

The `DateQ()` and `TimeQ()` methods demonstrate the architecture's power—extract components as fully-functional objects when you need their specialized methods.

## Comparison: Operators and Methods in Harmony

Softanza provides both operators for conciseness and methods for clarity. Choose based on context:

```ring
oNow = StzDateTimeQ("")
oFuture = oNow + "5 days"
oPast = oNow - "5 days"

# Operators - compact in conditionals
if oNow < oFuture
    ? "Time moves forward"
ok

# Methods - readable in complex logic
if oNow.IsBefore(oFuture) and oNow.IsAfter(oPast)
    ? "Present is between past and future"
ok

# Named checks for semantic clarity
? oNow.IsToday()      #--> TRUE
? oNow.IsNow()        #--> TRUE
? oNow.IsBetween(oPast, :and = oFuture)  #--> TRUE
? (oNow + "1 day").IsTomorrow()  #--> TRUE
? (oNow - "1 day").IsYesterday() #--> TRUE
```

The named parameter `:and` in `IsBetween()` makes range checks self-documenting—no guessing which parameter is the upper bound.

## Human-Readable Output: Bridging Technical and Natural

Technical timestamps serve machines; human formats serve people. Softanza makes the bridge seamless:

```ring
oEvent = StzDateTimeQ("2024-12-25 18:00:00")

? oEvent.ToHuman()
#--> Christmas Day, 2024 at 6:00 PM  # (Enhanced with ordinals and phrasing like "Half past 2 PM" where applicable)

# Relative time - context-aware phrasing
oRecent = StzDateTimeQ("") - "2 hours"
? oRecent.ToRelative()
#--> 2 hours ago

oUpcoming = StzDateTimeQ("") + "3 days"
? oUpcoming.ToRelative()
#--> in 3 days
```

These methods understand tense and phrasing conventions, generating grammatically correct output for UI display.

## Time Zones and Unix Timestamps: Global Compatibility

Modern applications operate globally. Softanza handles timezone conversion and epoch timestamps naturally:

```ring
oLocal = StzDateTimeQ("")
? oLocal.Content()
#--> 2025-10-02 14:30:45

# Convert to UTC for storage/APIs
oUTC = oLocal.ToUTC()
? oUTC
#--> 2025-10-02 12:30:45  # Adjusted for local offset

# Unix timestamps for interop
? oLocal.ToUnixTimeStamp()
#--> 1727876445

? oLocal.ToUnixTimeStampMs()  # Millisecond precision
#--> 1727876445000
```

### Epoch Conversions: Multiple Time Scales

Beyond basic Unix timestamps, Softanza provides epoch conversions in multiple time units. Each method has semantic aliases for clarity in different contexts:

```ring
oEvent = StzDateTimeQ("2024-03-15 14:30:45")

# Seconds - the standard Unix timestamp
? oEvent.ToSecondsSinceEpoch() # Or ToEpochSeconds() or ToUnixTimestamp() 
#--> 1710511845

# Milliseconds - for high-precision APIs
? oEvent.ToMillisecondsSinceEpoch() # or ToEpochMilliseconds() or ToUnixTimestampMs()
#--> 1710511845000

# Minutes - useful for session tracking
? oEvent.ToMinutesSinceEpoch() # or ToEpochMinutes()
#--> 28508530

# Hours - for analytics and aggregation
? oEvent.ToHoursSinceEpoch() # or ToEpochHours()
#--> 475142

# Days - for date-based comparisons
? oEvent.ToDaysSinceEpoch() # or ToEpochDays()
#--> 19797

# Weeks - for weekly reporting periods
? oEvent.ToWeeksSinceEpoch() # or ToEpochWeeks() 
#--> 2828

# Months - calendar-aware calculation
? oEvent.ToMonthsSinceEpoch() # or ToEpochMonths() 
#--> 649  # Accounts for variable month lengths

# Years - handles leap years correctly
? oEvent.ToYearsSinceEpoch() # or ToEpochYears()
#--> 54

# Decades - for historical analysis
? oEvent.ToDecadesSinceEpoch() # or ToEpochDecades()
#--> 5

# Centuries - for very long-term data
? oEvent.ToCenturiesSinceEpoch() # or ToEpochCenturies()
#--> 0
```

**Why Multiple Time Scales?**

Different domains need different granularity:
- **Seconds/Milliseconds**: API interchange, logging, precise timing
- **Minutes**: Session duration, cache expiration, polling intervals  
- **Hours**: Hourly analytics, time-slot booking systems
- **Days**: Date-based bucketing, retention policies, daily aggregates
- **Weeks**: Weekly reports, sprint planning, subscription cycles
- **Months**: Billing cycles, subscription periods, contract durations (calendar-aware)
- **Years**: Historical analysis, age validation, multi-year trends (handles leap years)
- **Decades**: Generational studies, long-term business cycles, demographic analysis
- **Centuries**: Archaeological data, historical timelines, climate research

The semantic aliases (`ToEpochSeconds()`, `ToUnixTimestamp()`) let you choose terminology that matches your domain—financial systems might prefer "epoch," while web developers might prefer "Unix timestamp."

## Historical Epochs and Origin-Based Calculations

Softanza extends epoch handling to historical and cultural origins, enabling timeline-based applications. Create datetimes by counting forward from predefined points:

```ring
# From epoch units
oDateTime = new stzDateTime([ :FromEpochSeconds = 1609459200 ])
? oDateTime.ToString()
#--> 2021-01-01 00:00:00

oDateTime = new stzDateTime([ :FromEpochDays = 20000 ])
? oDateTime.ToStringXT(:Standard)
#--> 2024-10-04 00:00:00

# Natural language with "from epoch"
oDateTime = new stzDateTime("54 years 9 months 3 days from epoch")
? oDateTime.ToVerbose()
#--> Sunday, October 3, 2024 00:00:00  # (Adjusted for example)

# Hash-based duration from epoch
oDateTime = new stzDateTime([
    :FromEpochDuration = [
        :Years = 54, :Months = 9, :Days = 3,
        :Hours = 14, :Minutes = 30
    ]
])
? oDateTime.ToISO()
#--> 2024-10-03 14:30:00

# Other units
oDateTime = new stzDateTime([ :FromEpochWeeks = 2857 ])
? oDateTime.ToStringXT(:Compact)
#--> 2024-10-03 00:00

oDateTime = new stzDateTime([ :FromEpochMilliseconds = 1609459200500 ])
? oDateTime.ToStringXT(:ISOWithMs)
#--> 2021-01-01 00:00:00.500

# Historical origins
oDateTime = new stzDateTime([ :CountingFromYearOne = 63113904000 ])  # Seconds from Year 1 AD
? oDateTime.Content()
#--> 2001-01-01 00:00:00

oDateTime = new stzDateTime([
    :CountingFromIslamicCalendar = [ :Years = 1400 ]
])
? oDateTime.Content()
#--> 2020-08-09 00:00:00  # Approx. from Hijra

oDateTime = new stzDateTime("5 years 3 months counting from space age")
? oDateTime.Content()
#--> 1962-01-12 00:00:00  # Space Age start: 1957-10-04 (Sputnik)

oDateTime = new stzDateTime([
    :CountingFromUSIndependence = [ :Years = 248, :Months = 3 ]
])
? oDateTime.Content()
#--> 2024-10-04 00:00:00  # From 1776-07-04

oDateTime = new stzDateTime("79 years 2 months counting from atomic age")
? oDateTime.Content()
#--> 2024-09-16 00:00:00  # Atomic Age: 1945-07-16 (Trinity test)

# Custom origin with hash
oDateTime = new stzDateTime([
    :CountingFrom = [ :Origin = :UnixStart, :Years = 50, :Days = 100 ]
])
? oDateTime.Content()
#--> 2020-04-10 00:00:00
```

Query durations from these origins to now:
```ring
oNow = new stzDateTime("")

? oNow.YearsSince(:YearOne)                #--> 2025 (from 1 AD)
? oNow.SecondsSince(:Epoch)                #--> ~1759588945 (Unix epoch)
? oNow.DurationSince(:IslamicHijra, :In = :Centuries)  #--> 14 (from 622 AD)
? oNow.SecondsSince(:SpaceAge)             #--> Massive number (from 1957)
? oNow.YearsSince(:InternetAge)            #--> 56 (from 1969 ARPANET)
? oNow.WeeksSince(:FrenchRevolution)       #--> ~12159 (from 1789)
? oNow.YearsSince("1976-08-01")            #--> 49
```

Supported origins include `:YearOne`, `:Epoch` (Unix), `:IslamicHijra`, `:SpaceAge`, `:AtomicAge`, `:USIndependence`, `:FrenchRevolution`, `:InternetAge`, and custom dates. This feature supports historical simulations, cultural calendars, and educational tools.

### Practical Example: Multi-Scale Time Tracking

```ring
oStart = StzDateTimeQ("2024-01-01 00:00:00")
oEnd = StzDateTimeQ("2024-03-15 14:30:45")

# Calculate project duration in different scales
? "Project duration:"
? "  Days: " + (oEnd.ToEpochDays() - oStart.ToEpochDays())
#--> Days: 74

? "  Weeks: " + (oEnd.ToEpochWeeks() - oStart.ToEpochWeeks())
#--> Weeks: 10

? "  Hours: " + (oEnd.ToEpochHours() - oStart.ToEpochHours())
#--> Hours: 1790

# Store as milliseconds for database precision
nTimestampMs = oEnd.ToUnixTimestampMs()
? "Stored timestamp: " + nTimestampMs
#--> Stored timestamp: 1710511845000

# Later: reconstruct from milliseconds
oReconstructed = StzDateTimeQ(nTimestampMs / 1000)
? oReconstructed.Content()
#--> 2024-03-15 14:30:45
```

## Millisecond Precision: When Microseconds Matter

For high-precision logging, performance measurement, or financial timestamps, millisecond operations maintain accuracy:

```ring
oPrecise = StzDateTimeQ("2024-03-15 14:30:45.123")

? oPrecise.MilliSeconds()
#--> 123

oAdded = oPrecise.AddMilliseconds(877)
? oAdded
#--> 2024-03-15 14:30:46.000  # Rolled to next second

nMs = oPrecise.MSecsTo("2024-03-15 14:30:46.000")
? nMs
#--> 877
```

## Real-World Example: Event Scheduling System

Let's see these capabilities unified in a practical scheduler:

```ring
# Create a webinar event
oWebinar = StzDateTimeQ([
    :Year = 2024, :Month = 6, :Day = 20,
    :Hour = 15, :Minute = 0, :Second = 0
])

# Calculate reminder times using natural syntax
oReminder1 = oWebinar - "1 day"
oReminder2 = oWebinar - "1 hour"

# Generate user-friendly notifications
? "Webinar: " + oWebinar.ToLong()
#--> Webinar: Thursday, June 20, 2024 3:00:00 PM

? "First reminder: " + oReminder1.ToMedium()
#--> First reminder: Wed, Jun 19 3:00 PM

? "Final reminder: " + oReminder2.ToSimple()
#--> Final reminder: 20/06/2024 2:00 PM

# Check proximity and generate countdown
oNow = StzDateTimeQ("")
if oNow < oWebinar
    nDays = oNow.DaysTo(oWebinar)
    nHours = oNow.HoursTo(oWebinar) % 24
    ? "Webinar in " + nDays + " days, " + nHours + " hours"
ok
```

This example demonstrates the API's coherence—creation, arithmetic, formatting, and comparison work together naturally.

## Softanza Advantage

| Feature | stzDateTime (Softanza) | Moment.js | Luxon | Python datetime | Java LocalDateTime |
|---------|----------------------|-----------|-------|-----------------|-------------------|
| **Operator Overloading** | `+`, `-`, `<`, `<=`, etc. | No | No | Limited (`-` only) | No |
| **Natural Language Parsing** | `+ "2 days 3 hours"`, AddNatural() | plugin required | No | No | No |
| **Unified Format System** | 24h default + `12h` suffix | Mixed methods | Mixed methods | strftime codes | DateTimeFormatter |
| **Duration Objects** | Hash with named keys | Yes | Yes | timedelta | Duration |
| **Component Extraction** | Direct methods + `DateQ()`/`TimeQ()` | Direct methods | Direct properties | Direct properties | Direct methods |
| **Timezone Handling** | `ToUTC()`, auto-convert | Good (deprecated) | Excellent | pytz required | ZonedDateTime |
| **Millisecond Precision** | Built-in | Built-in | Built-in | microsecond level | nanosecond level |
| **Relative Formatting** | `ToRelative()` | `.fromNow()` | `.toRelative()` | Manual | Manual |
| **Historical Origins** | Built-in (:YearOne, :IslamicHijra, etc.) | No | Limited | No | No |
| **Immutability** | Mutable | Mutable (Luxon fixes) | Immutable | Immutable | Immutable |
| **Underlying Engine** | Qt (via RingQt) | Native JS Date | Native JS Intl | C implementation | Java Time API |
| **Learning Curve** | Low (intuitive syntax) | Medium | Medium | Low-Medium | High |

**Key Differentiators:**
- **Operator overloading**: Only stzDateTime lets you write `oEnd - oStart` for duration
- **Natural language**: `+ "2 days"` is unique to Softanza's parsing
- **Format suffix pattern**: The `12h` convention is more systematic than other libraries' multiple method names
- **Historical epochs**: Unique support for origin-based creation and queries
- **Qt foundation**: Inherits Qt's maturity and cross-platform consistency

## Conclusion

The `stzDateTime` class exemplifies Softanza's philosophy: make common operations effortless while keeping advanced capabilities accessible. By leveraging Qt's robust foundation through RingQt and wrapping it in Ring's expressive syntax, Softanza delivers datetime handling that feels natural yet powerful. With new historical epoch features, it's now even better suited for global and timeline-based applications.