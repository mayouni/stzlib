# Time Handling in Softanza

## The Common Challenges

In applications such as scheduling tools or timers, developers often face repetitive tasks when handling time. These include converting between 12-hour and 24-hour formats, calculating durations with potential carry-overs across hours or days, and performing comparisons that require multiple conditional checks. Such operations can lead to verbose code that is difficult to maintain and susceptible to errors, especially when dealing with edge cases like midnight transitions.

Softanza addresses these issues by providing a streamlined way to work with time, making it easier to integrate into projects without extensive boilerplate.

## Softanza's Approach

At its core, Softanza leverages Qt's robust C++ engine for accurate and performant time operations. However, it goes further by layering a natural-oriented API that prioritizes developer intuition and readability. This design emphasizes feature-rich methods that align with everyday language—such as adding "20 minutes" directly or describing time in human terms like "quarter past 2"—while keeping the interface simple and extensible. The result is an API that reduces cognitive load, allowing focus on application logic rather than low-level details.

Let's explore this through practical examples, starting with basic retrieval and building toward more advanced usage.

### Retrieving and Representing Time

To get the current time quickly, Softanza offers a straightforward function that returns it as a formatted string, ideal for simple displays.

```ring
? Time()
#--> 14:23:17
```

This call uses the system's clock and formats the output in 24-hour notation by default, with no need for imports or setup. For scenarios requiring manipulation, such as adjustments or comparisons, convert it to an stzTime object using the `Q` variant. This object encapsulates the time and exposes methods for further interaction.

```ring
oTime = TimeQ()  # Equivalent to new stzTime(:Now)
? oTime.ToString()
#--> 14:23:17
```

The object form maintains the same current time but allows chaining operations, demonstrating Softanza's emphasis on fluent, natural workflows.

### Performing Time Arithmetic

Adding or subtracting intervals is a frequent need, and Softanza simplifies it by supporting direct operator overloading with numeric values interpreted as seconds, minutes, or hours based on context. For instance, to extend a start time by 75 minutes—common in scheduling—you can add the value directly to the object.

```ring
oTime = new stzTime("09:15:00")
? oTime + 75  # Interpreted as 75 minutes
#--> 10:30:00
```

This handles carry-overs automatically, such as rolling minutes into hours. For more explicit control, use dedicated methods like AddMinutes(), which can be chained for multi-step adjustments.

```ring
oTime = new stzTime("08:45:00")
oTime { 
    AddMinutes(20) 
    AddHours(1) 
    ? Content() 
}
#--> 10:05:00
```

Here, Content() retrieves the updated string representation. This chaining pattern, inspired by natural expression, keeps the code concise while building complex calculations step by step.

Subtraction works similarly, enabling quick backtracking for scenarios like logging past events.

### Comparing and Measuring Durations

Comparisons in Softanza use familiar operators, extending to strings for flexibility, which reduces the need for explicit conversions.

```ring
oTime1 = TimeQ("07:30:00")
oTime2 = TimeQ("11:45:00")

? oTime1 < oTime2  #--> TRUE
? oTime1 < "11:45:00"  #--> TRUE
```

To measure the span between two times, subtract one from the other for seconds, or use specialized methods for higher units like hours.

```ring
? oTime2 - oTime1  #--> 15900 (seconds)
? oTime1.HoursTo(oTime2)  #--> 4.25
```

The HoursTo() method even supports optional parameters for detailed output, such as including minutes.

```ring
? oTime1.HoursTo(oTime2, :AndMinutes = TRUE)  #--> 4 hours and 15 minutes
```

This feature-rich approach ensures precise duration reporting without manual division or formatting.

### Generating Readable Output

For user interfaces, raw timestamps can feel impersonal. Softanza's ToHuman() method translates times into natural language, adapting to common phrases based on the hour and minute.

```ring
oNow = new stzTime(:Now)
? oNow.ToHuman()  #--> Half past 2 PM (example for 14:30)

oAdjusted = oNow + 20  # Add 20 minutes
? oAdjusted.ToHuman()  #--> Twenty past 2 PM
```

Subtracting intervals yields similar intuitive results.

```ring
oPast = oNow - 60  # Subtract 1 hour
? oPast.ToHuman()  #--> 1 o'clock PM
```

This API layer, built atop Qt's precision, makes output suitable for emails, notifications, or dashboards, enhancing usability without external libraries.

### Example: Calculating Shift Duration

Consider a real-world task like determining the length of a work shift from 1:00 PM to 9:30 PM. Traditionally, this involves parsing strings, subtracting components, and handling overflows manually. Softanza consolidates this into object-based methods.

```ring
oStart = new stzTime("13:00:00")
oEnd = new stzTime("21:30:00")
? oStart.MinutesTo(oEnd)  #--> 510
? oStart.HoursTo(oEnd, :AndMinutes = TRUE)  #--> 8 hours and 30 minutes
```

The methods compute the difference reliably, even across potential day boundaries, showcasing the API's robustness for backend calculations.

### Handling Formats and Components

Format flexibility is key for diverse displays, and Softanza provides preset and custom options to avoid string manipulation. For a 24-hour time, convert to 12-hour effortlessly.

```ring
oTime = new stzTime("15:20:00")
? oTime.ToSimple()     #--> 3:20 PM
? oTime.To12Hour()     #--> 3:20:00 PM
? oTime.AMPM()         #--> PM
```

Custom formats use a template string for precise control.

```ring
? oTime.ToStringXT("h:mm:ss AP")  #--> 3:20:00 PM
```

Accessing individual components is equally direct, supporting both 24-hour and contextual views.

```ring
oDetailed = TimeQ("15:20:45.123")
oDetailed {
    ? Hour()          #--> 15
    ? Minute()        #--> 20
    ? Second()        #--> 45
    ? Hour12()        #--> 3
    ? PartOfDay()     #--> afternoon
    ? IsPM()          #--> TRUE
    ? Millisecond()   #--> 123
}
```

These getters integrate seamlessly into conditional logic, like checking if a time falls in the afternoon for workflow rules.

### Ensuring Valid Inputs

To prevent runtime issues, Softanza includes built-in validation. The IsTime() function checks strings upfront.

```ring
? IsTime("15:20:00")   #--> TRUE
? IsTime("24:00:00")   #--> FALSE
```

For object creation, wrap in a try-catch to handle invalids gracefully.

```ring
try
    oTime = TimeQ("15:70:00")
catch
    ? "Invalid time"
done
```

This early detection aligns with the API's easy-to-use philosophy, catching errors before they propagate.

## Performance Considerations

Thanks to Qt's optimized C++ implementation, all these operations— from arithmetic to formatting—execute in microseconds, balancing the rich feature set with high efficiency suitable for real-time applications.

## Comparison Table

To highlight how Softanza streamlines common time-handling tasks relative to approaches in languages like Python, Java, or JavaScript, the following table contrasts the two sides.

| Task                  | Softanza                          | Python/Java/JS Approach          |
|-----------------------|-----------------------------------|----------------------------------|
| Current time         | `Time()` or `TimeQ()`             | Imports and constructors         |
| Add interval         | `oTime + 45`                      | Duration objects                 |
| Comparison           | `oTime1 > oTime2`                 | Dedicated methods                |
| Duration             | `oTime1.SecsTo(oTime2)`           | Subtraction and conversion       |
| Readable format      | `oTime.ToHuman()`                 | Additional libraries             |
| Format conversion    | `oTime.To12Hour()`                | String manipulation              |
| Duration details     | `oStart.HoursTo(oEnd)`            | Manual arithmetic                |
| Validation           | `IsTime(cInput)`                  | Exception handling               |

## Conclusion

By building on Qt's foundation and investing in a natural-oriented, feature-rich API, Softanza's stzTime class transforms time handling from a tedious chore into an intuitive process. This is particularly valuable for time-centric applications like calendars, event trackers, or analytics tools, where clarity and reliability directly impact development speed and user experience.