# stzDateTime: Elegant DateTime Operations in Softanza

DateTime manipulation is a universal programming challenge—combining date and time logic while handling formats, timezones, and arithmetic. The `stzDateTime` class from Softanza transforms this complexity into an intuitive, expressive experience built on Qt's robust foundation.

## The Three-Class Architecture: Why DateTime, Date, and Time?

Softanza recognizes that temporal data exists in three distinct forms, each with unique use cases:

- **`stzDate`**: Pure calendar operations (birthdays, deadlines, historical events)
- **`stzTime`**: Clock-based logic (business hours, durations, scheduling)
- **`stzDateTime`**: Combined operations requiring both components (logging, event scheduling, timestamps)

This separation mirrors real-world thinking. When you schedule a meeting, you need `stzDateTime`. When you calculate someone's age, `stzDate` suffices. When you track elapsed seconds in a race, `stzTime` is perfect. The architecture prevents conceptual confusion while allowing seamless interoperability—`stzDateTime` can extract its `DateQ()` or `TimeQ()` components when you need specialized operations.

## Creating DateTime Objects: Flexibility by Design

Softanza accepts multiple input styles because your data comes from various sources. Whether parsing user input, deserializing APIs, or working with Unix timestamps, there's a natural path:

```ring
# Current moment - empty string captures now
oNow = StzDateTimeQ("")
? oNow.Content() 		# Or ToString() or DataTime()
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

This is datetime arithmetic as it should be—intuitive, predictable, powerful.

## Duration Calculations: From Seconds to Stories

When you need granular breakdowns, `DurationTo()` delivers complete temporal distance analysis:

```ring
oProject = StzDateTimeQ("2024-01-01 09:00:00")
oLaunch = StzDateTimeQ("2024-03-15 14:30:45.123")

aDuration = oProject.DurationTo(oLaunch)
? aDuration
#--> [
#-->   :Days = 74,
#-->   :Hours = 5,
#-->   :Minutes = 30,
#-->   :Seconds = 45,
#-->   :Milliseconds = 123
#--> ]
```

This hash format makes it trivial to build user-facing messages: "Your project took 74 days, 5 hours, and 30 minutes." For quick math, specialized methods bypass the hash:

```ring
? oProject.DaysTo(oLaunch)      #--> 74
? oProject.HoursTo(oLaunch)     #--> 1781
? oProject.MinutesTo(oLaunch)   #--> 106870
```

Each method returns total units—`HoursTo()` gives 1781, not just the 5 hours within the final day. This flexibility lets you choose precision versus simplicity based on context.

## Formatting: A Hierarchical Philosophy

Softanza's formatting system reflects a deliberate design: **Time System → Localization → Precision → Verbosity**. This hierarchy gives you control without complexity.

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

Want AM/PM? Simply append `12h` to any format name. This consistent pattern eliminates memorization:

```ring
? oEvent.ToISO12h()
#--> 2024-03-15 02:30:45 PM

? oEvent.ToStandard12h()
#--> 15/03/2024 02:30:45 PM

? oEvent.ToVerbose12h()
#--> Friday, March 15, 2024 02:30:45 PM
```

The suffix works universally because it represents a fundamental transformation, not a new format. This orthogonality keeps the API learnable.

### Convenience Formats: Balanced Defaults

For common scenarios where you don't want to choose between verbosity and brevity, convenience formats provide balanced presets:

```ring
? oEvent.ToSimple()
#--> 15/03/2024 2:30 PM

? oEvent.ToMedium()
#--> Fri, Mar 15 2:30 PM

? oEvent.ToLong()
#--> Friday, March 15, 2024 2:30:45 PM

? oEvent.ToShort()
#--> 15/03 2:30 PM
```

These formats automatically use 12-hour time because they're designed for user-facing contexts where AM/PM convention dominates.

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
? oDateTime.Month()     #--> 3
? oDateTime.Day()       #--> 15
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
? oNow.IsBetween(oPast, :and = oFuture)  #--> TRUE
```

The named parameter `:and` in `IsBetween()` makes range checks self-documenting—no guessing which parameter is the upper bound.

## Human-Readable Output: Bridging Technical and Natural

Technical timestamps serve machines; human formats serve people. Softanza makes the bridge seamless:

```ring
oEvent = StzDateTimeQ("2024-12-25 18:00:00")

? oEvent.ToHuman()
#--> Christmas Day, 2024 at 6:00 PM

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
? oEvent.ToYearsSinceEpoch() " or ToEpochYears()
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
| **Natural Language Parsing** | `+ "2 days 3 hours"` | plugin required | No | No | No |
| **Unified Format System** | 24h default + `12h` suffix | Mixed methods | Mixed methods | strftime codes | DateTimeFormatter |
| **Duration Objects** | Hash with named keys | Yes | Yes | timedelta | Duration |
| **Component Extraction** | Direct methods + `DateQ()`/`TimeQ()` | Direct methods | Direct properties | Direct properties | Direct methods |
| **Timezone Handling** | `ToUTC()`, auto-convert | Good (deprecated) | Excellent | pytz required | ZonedDateTime |
| **Millisecond Precision** | Built-in | Built-in | Built-in | microsecond level | nanosecond level |
| **Relative Formatting** | `ToRelative()` | `.fromNow()` | `.toRelative()` | Manual | Manual |
| **Immutability** | Mutable | Mutable (Luxon fixes) | Immutable | Immutable | Immutable |
| **Underlying Engine** | Qt (via RingQt) | Native JS Date | Native JS Intl | C implementation | Java Time API |
| **Learning Curve** | Low (intuitive syntax) | Medium | Medium | Low-Medium | High |

**Key Differentiators:**
- **Operator overloading**: Only stzDateTime lets you write `oEnd - oStart` for duration
- **Natural language**: `+ "2 days"` is unique to Softanza's parsing
- **Format suffix pattern**: The `12h` convention is more systematic than other libraries' multiple method names
- **Qt foundation**: Inherits Qt's maturity and cross-platform consistency

## Conclusion

The `stzDateTime` class exemplifies Softanza's philosophy: make common operations effortless while keeping advanced capabilities accessible. By leveraging Qt's robust foundation through RingQt and wrapping it in Ring's expressive syntax, Softanza delivers datetime handling that feels natural yet powerful.