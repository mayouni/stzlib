# Date Programming Made Easy in Softanza

## The Problem We All Know

You're building a project timeline tracker. The client wants to see "in 2 weeks" instead of "14/10/2025". You need to add three months to a contract start date, but only if it falls on a weekday. Your code becomes a maze of calculations, string formatting, and edge cases.
We've all been there. Date programming shouldn't be this hard.

## A Different Approach

Softanza takes date handling back to how we actually think about time. Built on Qt's rock-solid foundation, it lets you write code that mirrors natural language while running at native speed.

Let me show you what I mean.

### Starting Simply

```ring
# Getting the day name in a string

? Today()
#--> 30/09/2025

# Or in a stzDate object form

oDate = TodayQ()	# Or oDate = new stzDate(:Today)
? oDate.Date()
#--> 30/09/2025
```

No ceremony. No configuration. Just ask for today's date and you get it. The `Q` suffix returns an object when you need to do more—a pattern you'll see throughout Softanza.

### Arithmetic That Makes Sense

Remember that project deadline calculation?

```ring
oDate = new stzDate("01/01/2025")
? oDate + "2 months"
#--> 01/03/2025
```

No imports. No helper functions. No manual day calculations. Just add "2 months" like you'd say it out loud.

This works because Softanza understands:

```ring
oDate = new stzDate("15/06/2024")

# All of these just work
? oDate + 30                    # days
#--> 15/07/2024

? oDate + 15                    # Add 15 days
#--> 30/06/2024

# Chain operations naturally
oDate { AddMonths(3) AddYears(1) ? ToString() }
#--> 15/09/2025
```

### Comparisons Without Ceremony

```ring
oDate1 = StzDateQ("15/06/2024")
oDate2 = StzDateQ("20/06/2024")

? oDate1 < oDate2               #--> TRUE
? oDate1 < "20/06/2024"         #--> TRUE (compares with strings too)

# Calculate the difference
? oDate2 - oDate1               #--> 5
```

The code reads like the logic in your head.

### The Human Touch

That client requirement about showing "in 2 weeks" instead of dates?

```ring
o1 = new stzDate(:Today)
? o1.ToHuman()                  #--> today

o1 + "1 day"
? o1.ToHuman()                  #--> tomorrow

o1 - "2 days"
? o1.ToHuman()                  #--> yesterday

o1 + "2 weeks"
? o1.ToRelative()               #--> in 1 week
```

Just human-readable output that adapts to the time span.

### Real-World Scenario: Age Calculation

**Standard code:**
```ring
# Calculate age - manual date math required
cBirthday = "15/06/1990"
cToday = date()

# Parse dates, extract years, handle edge cases...
# What if birthday hasn't occurred this year yet?
# Complex logic needed!
```

**Softanza approach:**
```ring
oBirthday = new stzDate("15/06/1990")
? oBirthday.Age()
#--> 35
```

One line. Handles all edge cases automatically.

### Localization Made Simple

**Standard code:**
```ring
# Get day name

cDay = TimeList()[2]  # Remember: index 2 is full weekday name
? cDay
#--> Saturday

# French? You'll need to write your own translation logic...
```

**Softanza:**
```ring
oDate = new stzDate("27/09/2025")

? oDate.Day()
#--> Saturday

? oDate.DayIn(:French)
#--> Samedi

? oDate.DayIn(:Arabic)
#--> السبت
```

Built-in multilingual support. No translation tables needed.

### Smart Inspection

```ring
oDate = StzDateQ("15/07/2024")
oDate {
    ? Year()                    #--> 2024
    ? MonthNumber()             #--> 7
    ? DayNumber()               #--> 15
    ? DayOfWeek()               #--> 1
    ? DayOfYear()               #--> 197
}
```

Every aspect of a date is accessible with clarity without the need of remembering standard Ring `TimeList()` indices.

### Julian Day Conversion

Working with astronomical data, historical dates, or needing a universal date representation? Julian day numbers have you covered.

**Convert current date to Julian day number:**
```ring
o1 = new stzDate("") # Or any date you would supply instead of ""
? o1.ToJulianDay()
#--> 2460958
```

**Create a date from a Julian day number:**
```ring
o1 = new stzDate("")
o1.FromJulianDay(2460570)
? o1.Content()
#--> 16/09/2024	(the corresponding Gregorian date)
```

Julian day conversion runs at native (Qt C++) speed while providing a direct bridge to scientific computing and historical timelines.

### Validation Built-In

```ring
? IsDate("20/10/2025")          #--> TRUE
? IsDate("20/10/20025")         #--> FALSE

try
    oDate = StzDateQ("32/13/2024")  # Invalid
catch
    ? "Invalid date detected"
done
```

Errors are caught early with clear messages.

## Performance Matters

All this expressiveness runs on Qt's C++ date engine. Operations complete in microseconds. 
You're not trading performance for convenience. You're getting both.

## Comparative Analysis

| Task | Python/Java/JS | Softanza |
|------|----------------|----------|
| Get today | Various imports/objects | `Today()` or `TodayQ()` |
| Add months | Special methods/libraries | `oDate + "2 months"` |
| Compare | `.compareTo()`, `.isBefore()` | `oDate1 < oDate2` |
| Difference | Manual calculation | `oDate2 - oDate1` |
| Human format | External libraries | `oDate.ToHuman()` |
| Localize | Complex formatters | `oDate.DayIn(:French)` |
| Calculate age | Manual date math | `oBirthDate.Age()` |
| Validate | Try/catch parsing | `IsDate(cString)` |
| Julian day | Manual conversion | `oDate.ToJulianDay()` |

## Final Thoughts

Softanza's date programming feels like a breath of fresh air. It prioritizes developer experience without compromising performance, making it ideal for projects where dates are central (e.g., scheduling apps, timelines, or user interfaces). The human-readable output, localization features, and Julian day conversion are particularly compelling for both client-facing applications and scientific computing tasks.