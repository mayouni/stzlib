load "../max/stzmax.ring"

#TODO: explain each regexp briefly before using it in each example

/*=== Basic Pattern Matching

pr()

o1 = new stzRegExp("softanza")

? o1.IsValid()
#--> TRUE

? o1.Match("softanza")
#--> TRUE

? o1.Match("Softanza")
#--> FALSE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Case Sensitivity

pr()

o1 = new stzRegExp("softanza")
o1 {
	CaseInsensitive()

	? IsCaseSensitive()
	#--> FALSE

	? Match("Softanza")
	#--> TRUE

	? Match("SOFTANZA")
	#--> TRUE

	CaseSensitive()

	? IsCaseSensitive()
	#--> TRUE

	? Match("SOFTANZA")
	#--> FALSE
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Character Classes (From Mozilla MSDN)

pr()

# Pattern [xyz] - Match any one of the enclosed characters

rx("[abcd]") { ? Match("chop") }
#--> TRUE

# Pattern [x-z] - Range of characters

rx("[a-d]") { ? Match("brisket") }
#--> TRUE

# Hyphen as noramal character (when not between two chars)

rx("[abcd-]") { ? Match("non-profit") }
#--> TRUE

# \w shorthand and hyphen (matches one or more alphanumeric characters)

rx("[\w-]") { ? Match("non-profit") }
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Understanding Captured vs Non-Captured Groups

pr()

# In RegExp, groups are enclosed between parentheses.

# They are captured so we can get their values directly.
# In this case, we can get a list of all the values, or
# access a given value by it's index reflecting the order
# of its occurrence in the regexp pattern.

# We can also name them and get their names along with their values.
# This last feature enables us to get a give group value by its name.

# Normal capturing groups

rx("(\d+)-(\d+)") { Match("123-456")  ? Capture() }
#--> [ "123", "456" ]

# Named capturing groups

rx("(?<year>\d{4})-(?<month>\d{2})") {
	Match("2024-01")
	? @@( CapturedGroups() ) # Or simply Groups()
}

#--> [ [ "year", "2024" ], [ "month", "01" ] ]
#TODO rename it GroupsXT(), Groups() should return only names

# Non-capturing groups using (?:...)
# Useful for better performance

rx("(?:\d+)-(?:\d+)") { Match("123-456") ? @@(Capture()) }
#--> []
# No captures since groups are non-capturing

# Or you can use the more expressive DontCapture() method

rx("(\d+)-(\d+)") {

	DontCapture()

	Match("123-456")
	? CountCaptures()
	#--> 0
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Alternative Pattern Matching

pr()

# The | operator matches first successful alternative

rx("a|ab") { 
	? Match("abc") 
	? @@(Capture())
}
#--> TRUE
#--> ["a"]

#TODO check error: returned [] isntead of ["a"]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Multiline Pattern

pr()

cMultilineText = "Start of line 1
End of line 1
Start of line 2
End of line 2"


o1 = new stzRegExp("^Start.*$")
? o1.Match(cMultilineText) # Multiline() enable automatically in Match()
#--> TRUE

proff()
# # Executed in almost 0 second(s) in Ring 1.22

/*=== Dot Matches Everything

pr()

cText = "Line 1
Line 2"

o1 = new stzRegExp("Line.*Line")
? o1.Match(cText) # DotMatchesEverything enabled automaticall in Match()
#--> TRUE

? o1.MatchLine(cText) # Both MultiLine and DotMatchesEverything enabled
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Extended Syntax

pr()

# Commented pattern for better readability

o1 = new stzRegExp("
	# Match a valid date format
	(?<day>[0-9]{2})   # Day
	/                  # Separator
	(?<month>[0-9]{2}) # Month
	/                  # Separator
	(?<year>[0-9]{4})  # Year
")

# Because the pattern is multiline, EnableExtendedSyntax()
# is automatically activated and Match works fine

? o1.Match("25/12/2024")
#--> TRUE

? @@(o1.CapturedGroups())
#--> [ ["day","25" ], [ "month", "12" ], [ "year", "2024" ] ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Greedy vs Lazy Matching

pr()

cHtml = "<p>First paragraph</p><p>Second paragraph</p>"

# Greedy matching (default)

o1 = new stzRegExp("<p>.*</p>")
o1.Match(cHtml) # Matches the strings as a whole (Greedy by default)
? @@(o1.CapturedValues())
#--> ["<p>First paragraph</p><p>Second paragraph</p>"]
#TODO ERROR should return all the matches

# Lazy matching


o1.MatchOne(cHtml) # Sets LazyMatching() automatically
? @@(o1.CapturedValues())
#--> ["<p>First paragraph</p>"]
#TODO ERROR returned []

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Real-world Examples

/*--- Example 1: Log Parser

pr()

oLogPattern = new stzRegExp("
	(?<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+
	(?<level>INFO|WARN|ERROR)\s+
	(?<message>.+)
")

cLogEntry = "2024-01-09 15:30:45 ERROR Database connection failed"

? oLogPattern.Match(cLogEntry)
#--> TRUE

? @@NL(oLogPattern.CapturedGroups())
#--> [
#	[ "timestamp", "2024-01-09 15:30:45" ],
#	[ "level", "ERROR" ],
#	[ "message", "Database connection failed" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 2: Email Validation

pr()

oEmailPattern = new stzRegExp("
	^
	(?<local>[\p{L}\p{N}._%+-]+)
	@
	(?<domain>[\p{L}\p{N}.-]+)
	\.
	(?<tld>\p{L}{2,})
	$
")

# oEmailPattern.ExtendedSyntax() # Set automaticallu by Softanza

? oEmailPattern.Match("user.name@example.com")
#--> TRUE

# oEmailPattern.UseUnicode() # Seems to be set automatically by Qt

? oEmailPattern.Match("användare@例子.com")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 3: Phone Number Parser

pr()

oPhonePattern = new stzRegExp("
	(?:
		(?<intl>\+\d{2}-)?
		(?<area>\d{3}-)
		(?<prefix>\d{3}-)
		(?<line>\d{4})
	)|
	(?:
		\((?<area2>\d{3})\)\s
		(?<prefix2>\d{3}-)
		(?<line2>\d{4})
	)
")

oPhonePattern.ExtendedSyntax()

? oPhonePattern.Match("+1-555-123-4567")
#--> TRUE

? oPhonePattern.Match("(555) 123-4567")
#--> TRUE

? @@NL(oPhonePattern.CapturedGroups())
#--> [
#	[ "intl", "" ],
#	[ "area", "" ],
#	[ "prefix", "" ],
#	[ "line", "" ],
#	[ "area2", "555" ],
#	[ "prefix2", "123-" ],
#	[ "line2", "4567" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 4: URL Parser

pr()

oUrlPattern = new stzRegExp("
	^
	(?<protocol>https?://)
	(?<domain>[^/]+)
	(?<path>/[^?#]*)?
	(?<query>\?[^#]*)?
	(?<fragment>#.*)?
	$
")

# oUrlPattern.ExtendedSyntax() is set automatically

? oUrlPattern.Match("https://example.com/path?q=test#section")
#--> TRUE
#TODO #ERROR Returned FALSE instead of TRUE

? @@NL(oUrlPattern.CapturedGroups())
#TODO #ERROR Returned empty list []

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 5: Code Comment Parser

pr()

oCommentPattern = new stzRegExp("
	(?<type>//|/\*|\*/)

	\s*
	(?<content>.+?)
	(?:\s*\*/)?
	$
")

? oCommentPattern.Match("// This is a single line comment")
#--> TRUE

? oCommentPattern.Match("/* This is a multi-line comment */")
#--> TRUE

? @@NL(oCommentPattern.CapturedGroups())
#--> [
#	[ "type", "/*" ],
#	[ "content", "This is a multi-line comment" ]
# ]
#TODO Is this what we should exoect?

proff()
# Executed in almost 0 second(s) in Ring 1.22
