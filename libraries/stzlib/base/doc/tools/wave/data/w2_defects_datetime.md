# defects (method: symptom: cause) -- each verified by two calls on different data

## stzDateTime
- DurationInDecadesTo: raises R24: param cTo, body reads pcUnit (undefined) [2 samples]
- MillisecondsFrom, MillisecondsSince, DurationInMillisecondsSince: raise R24: param cFrom, body reads pOrigin (undefined) [5 samples]
- FromSecondsSinceEpoch/FromMillisecondsSinceEpoch/FromMinutes/Hours/Days/Weeks: negative count gives 0-00-00 invalid date: engine FromUnix(negative) answers zeros [days, hours, ms, minutes, weeks, seconds tried]
- every origin but UnixEpoch (:YearOne, :AtomicAge ...) via SetCountingFrom, ParseCountingFrom, SetFromNaturalDuration, FromXSinceEpochXT: invalid date; same cause (negative ms) [YearOne, AtomicAge, USIndependence, IslamicHijra]
- FromMonthsSinceEpoch(-n): month <= 0, formatting month -2 panics inside the DLL and ends the Ring process (month 0 survives) [-1, -3]
- ToMonths/Years/Decades/CenturiesSinceEpochXT + DurationIn*From/Since for months+: wrong for pre-1970 origins: origin date comes out as year 0 [YearOne, AtomicAge]
- Origin as mixed-case quoted text ("YearOne"): counts as the Unix epoch: Ring = is case-sensitive, symbols are lowercase [GetOriginBase, DurationInDaysFrom]
- DurationSince/From with a datetime text as origin: silently the Unix epoch [2 samples]
- ParseNaturalEpoch (and init with "x from epoch"/"since epoch"): plural units counted 2-3 times (units list holds days and day, minutes minute min ...; substring find) [2 days -> 4, 5 minutes -> 15, 90 seconds -> 270, 2 months, 3 days 2 hours 1 week]
- ToVerbose family (9 roots), ToLong24h, ToLongDate, ToTextDate: day number printed as the letter d: single d token never replaced by _DateTimeFormatString [3 dates]
- GuessDateTimeFormat: R3 for ISO text with T and a time without ms: CountOccurrences defined nowhere [2 samples]
- FromEpochHash: :milliseconds ignored; HashToMilliseconds same; SetFromEpochDuration reads it
- TryManualParse/TryManualDateParse: out-of-range parts answer 0 but remain stored [2 samples each]
- SetComponents, SetFromHash, ParseStringDateTime: no range check (month 13/14 stored)
- ParseStringDateTime: ".5" read as 5 ms
- init with [stzDate, stzTime] list: R41 in IsValid [2 samples]; init with "03/15/2026": Invalid date/time (read day-first)
- AddNatural/SubtractNatural: weeks silently ignored; SubtractNatural does nothing when text has - or :
- SubtractHours, SubtractMinutes: answer nothing, unlike the other Subtract methods
- ToUTC/ToLocalTime: no conversion
- operator "-": a - b is seconds from a to b (positive when b later), opposite sign of arithmetic (matches test 36)
- DurationTo unit "in days" (with space): Unsupported unit
- MapOriginName("modern computing"): unixepoch

## stzMatrix
- MultiplyByInRow: scales a COLUMN: body calls MultiplyColBy [2 samples]
- Diagonal1: empty body, answers nothing: `func Diagonal1()` inside the class [2 receivers]
- Add(matrix): adds then raises Incorrect param type or incorrect syntax [2 samples]
- Add([v, :ToCol = n]) and [v, :ToRow = n]: change nothing: pair read backwards [3 samples]
- FindElementsInSection: pairs are [column, row] (the other Find methods give [row, column]) [3 samples]
- ReplaceSection, ReplaceSectionByMany, ReplaceElementsInSectionByMany: wrong cells for a non-square rectangle (use FindElementsInSection); ReplaceSection on 2x3 raises R2 after changing cells [3 samples]
- Section: corners read [column, row], Section([1,1],[2,3]) raises R2 on 2x3; one-column section wrapped in an extra list [4 samples]
- ReplaceRow, ReplaceRows, ReplaceCols: refuse 0 and negative new values (IsListOfNonZeroPositiveNumbers); ReplaceCol accepts them [3 samples]
- ReplaceThisElementAt: raises Can't proceed when the cell holds another number [2 samples]
- DivideElementwise: raises at the first zero divisor after dividing the cells before it [1 sample + code]
- MultiplyByMatrixQ: raises (wraps nothing in new stzMatrix) [1 sample]
- MultiplyCol(1, "x"): non-number factor not checked, multiplies by 0 [1 sample]; (not written as a defect, only seen)

## stzLocale
- ToTimeAsString, ToTimeAsLongString, ToTimeAsShortString, ToTimeAsNarrowString: raise R20: stzTime.ToString takes no argument [3 samples]
- StringTitlecased, ToTitleCase, StringIsTitlecased: R14 (English: CharAtPositionQ missing via StringCapitalised; other: Char missing) [fr-FR, en-US, 3 strings]
- StringCapitalcased, StringIsCapitalised: R14 CharAtPositionQ missing [3 samples]
- StringFoldcased, CharFoldcased, StringIsfoldcased, CharIsFoldcased: body is a TODO, answer empty / FALSE [3 samples]
- ScriptNumber/ScriptName/ScriptAbbreviation: common (0, Zyyy) for every locale without a script in its code (fr-FR, en-US, ar-EG, ja-JP, ru-RU ...); country-name locales (France) give latin [10+ samples]
- StringLowercased/Uppercased, Char*: ASCII only, locale ignored (E acute, Cyrillic, Greek, Turkish I, sharp s unchanged) [6 samples]
- StringLowercased(5) / StringUppercased(5): the Ring process exits silently (exit 1) [2 samples, separate processes]; StringLowercased([1]) answers ""
- NthDayOfWeek(0|8): raises R3 (stzLocaleError missing) [2 samples]
- NativeDaysOfWeek + abbreviations + symbols: English for languages with no table (ja, zh, ko, hi, sw, ha) [6 samples]
- CountryNativeName: English name [alias, 2 samples]
- amText/pmText: locale-independent
- MeasurementSystem: values spelled metricsytem / imperialussystem / imperialuksystem
- init(5): no error, empty locale
