# Regular Expression Examples for Softanza Library
# These examples demonstrate both classic and enhanced usage patterns

load "../max/stzmax.ring"

/*=== 1. Basic Pattern Matching Examples

pr()
  
# Simple literal match

o1 = new stzRegExp("hello")

? o1.Match("hello world")
#--> TRUE
    
# Case sensitivity

? o1.Match("Hello World")
#--> FALSE
    
o1.CaseInsensitive()
? o1.Match("Hello World")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== 2. Scoped Pattern Matching Examples

pr()
    
text = "This is line 1
This is line 2"

rx("^.*$") {

	# Match entire text

	? Match(text)
	#--> FALSE

	# Math the text line by line

	? MatchLine(text)
	#--> TRUE
}

rx("word") {

	# Match single words

	? MatchWord("This word here")
	#--> TRUE

	? MatchWord("sword")
	#--> FALSE
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== 3. Character Classes Examples

pr()
    
# Basic character class

rx("[aeiou]") {

        ? Match("hello")
	#--> TRUE

        ? Match("rhythm")
	#--> FALSE
}
    
# Range in character class

rx("[a-z]") {
	
        ? Match("hello")
	#--> TRUE

        ? Match("123")
	#--> FALSE
}

proff()

/*=== 4. Capture Groups Examples

pr()

# Named capture groups
o1 = new stzRegExp("(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})")

o1.Match("2024-01-15")

? @@(o1.CapturedGroups())
#--> [ [ "year", "2024" ], [ "month", "01" ], [ "day", "15" ] ]
    
# Simple capture

rx("(\d+)") {
	Match("age: 25")
	? @@( Capture() )
	#--> [ "25" ]/////////////////////////
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== 5. Pattern Options Examples

pr()
    
o1 = new stzRegExp("pattern")
    
# Case sensitivity

o1.CaseSensitive()
? o1.IsCaseSensitive()
#--> TRUE
    
o1.CaseInsensitive()
? o1.IsCaseInsensitive()
#--> TRUE
    
# Multiline mode

o1.MultiLine()
? o1.IsMultiLine()
#--> TRUE
    
# Reset options

o1.ResetOptions()
? o1.GetOptions()
#--> 0

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== 6. Unicode Support Examples

pr()

o1 = new stzRegExp("\p{Script=Arabic}")

o1.UseUnicode()

? o1.Match("مرحبا")
#--> TRUE

? o1.Match("Hello")
#--> FALSE

proff()
# # Executed in almost 0 second(s) in Ring 1.22

/*=== 7. Real-world Examples ======================================

load "../max/stzmax.ring"

/*---

pr()

cStr = "أهواك وأتمنى لو أنساك وأنسى روحي وياك
وإن ضاعت يبقى فداك لو تنساني
وأنساك وأتاريني بنسى جفاك وأشتاق لعذابي معاك
وألقى دموعي فكراك أرجع تانى
في لقاك الدنيا تجيني معاك ورضاها يبقي رضاك
وساعتها يهون في هواك، في هواك طول حرماني
أهواك وأتمنى لو أنساك وأنسى روحي وياك
وإن ضاعت يبقى فداك لو تنساني
وأنساك وأتاريني بنسى جفاك وأشتاق لعذابي معاك
وألقى دموعي فاكرك أرجع تانى
في لقاك الدنيا تجيني معاك ورضاها يبقي رضاك
وساعتها يهون في هواك، في هواك طول حرماني
وألاقيك مشغول وشاغلني بيك
وعينيا تيجي في عينيك
وكلامهم يبقى عليك وإنت تداري
وأراعيك وأصحى من الليل أناديك
وأبعت روحي تصحيك
قوم يلي شاغلني بيك جرب ناري
ألاقيك مشغول وشاغلني بيك
وعينيا تيجي في عينيك
وكلامهم يبقى عليك وإنت تداري
وأراعيك وأصحى من الليل أناديك
وأبعت روحي تصحيك
قوم يلي شاغلني بيك جرب ناري
ألاقيك مشغول وشاغلني بيك
وعينيا تيجي في عينيك
وكلامهم يبقى عليك وإنت تداري
وأراعيك وأصحى من الليل أناديك
وأبعت روحي تصحيك
قوم يلي شاغلني بيك جرب ناري
أهواك وأتمنى لو أنساك وأنسى روحي وياك
وإن ضاعت يبقى فداك لو تنساني
وأنساك وأتاريني بنسى جفاك وأشتاق لعذابي معاك
وألقى دموعي فاكرك أرجع تانى
في لقاك الدنيا تجيني معاك ورضاها يبقي رضاك
وساعتها يهون في هواك، في هواك طول حرماني
"
? Q(cStr).LinesQ().WithoutDuplications()

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*===

pron()

? StzStartupTime() # in seconds
#--> 0.05

proff()
# Executed in almost 0 second(s) in Ring 1.22

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

/*=== Case Sensitivity Examples

pr()

o1 = new stzRegExp("softanza")
o1 {

	# Let it be case incensitive

	CaseInsensitive()

	? IsCaseSensitive()
	#--> FALSE

	? Match("Softanza")
	#--> TRUE

	? Match("SOFTANZA") + NL
	#--> TRUE

	# Now, let it be rather case sensitive

	CaseSensitive()

	? IsCaseSensitive()
	#--> TRUE

	? Match("SOFTANZA")
	#--> FALSE
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== UNDERStANDING CHARACTER CLASSES (From Mozilla MSDN)

# Character classes distinguish kinds of characters such as,
# for example, distinguishing between letters and digits.

pr()

# Pattern [xyz]
# Matches any one among the enclosed characters.

rx("[abcd]") { ? Match("chop") }
#--> TRUE

# Pattern [x-z]
# You can specify a range of characters by using a hyphen.

rx("[a-d]") { ? Match("brisket") }
#--> TRUE

# But if the hyphen appears as the first or last character
# enclosed in the square brackets, it is taken as a literal
# hyphen to be included in the character class as a normal char.

rx("[abcd-]") { ? Match("chop") }
#--> TRUE

rx("[abcd-]") { ? Match("brisket") }
#--> TRUE

rx("[abcd-]") { ? Match("-profit") }
#--> TRUE

rx("[abcd-]") { ? Match("non-profit") }
#--> TRUE

# [\w-] is the same as [A-Za-z0-9_-]

rx("[\w-]") { ? Match("chop") }
#--> TRUE

rx("[\w-]") { ? Match("brisket") }
#--> TRUE

rx("[\w-]") { ? Match("non-profit") }
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== UNDERStANDING CAPTURED AND NON CAPTURED GROUPS (From Mozilla MSDN)

pr()

#TODO

proff()

/*=== UNDERSTANDING THE AMOMONG OPERATOR

pr()

# The | regular expression operator separates two or more alternatives.

# The pattern first tries to match the first alternative;
# if it fails, it tries to match the second one, and so on.

# For example, the following matches "a" instead of "ab",
# because the first alternative already matches successfully:

rx("a|ab") { ? Match("abc") }
#--> TRUE

rx("a|ab") { ? Match("abc") ? @@( Capture() ) }
#--> [ "a" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== MATCHING ARABIC

pr()

rx("[أ-د]") { ? Match("نور") }
#--> FALSE

rx("[أ-د]") { ? Match("أنوار") }
#--> TRUE

rx("م|من") { ? Match("منجم") ? @@( Capture() ) }
#o--> [ "م" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== BACKREFERENCE

pr()

# \n pattern: Where "n" is a positive integer.

#~> Matches the same substring matched by the nth capturing group
# in the regular expression (counting left parentheses).

# For example:

rx("apple(,)\sorange\1") { Match("apple, orange, cherry, peach") ? Values()[1] }
#--> "apple, orange,"

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*===///////

pr()

# Match() - Whole String Matching

text = "Start
Middle
End"

rx("Start.*End") { ? Match(text) } #TODO check it: should return TRUE!
#--> TRUE

# MatchLine() - Line-by-Line Processing

text = "Header: Content
Footer: More"

rx("^[^:]+: .*$") { ? MatchLine(text) }
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Multiline Pattern Examples

pr()

# In this example we use the regexp pattern "^Start.*$".

# This pattern will:
# - Match lines that begin with "Start"
# - Followed by any characters (or no characters)
# - Until the end of the line

# Let's take a multiline string to match the pattern with:

cMultilineText = "Start of line 1
End of line 1
Start of line 2
End of line 2"

# Without MultiLine option

	o1 = new stzRegExp("^Start.*$")
	
	? o1.Match(cMultilineText)
	#--> FALSE

# With MultiLine option

	o1.MultiLine()
	
	? o1.IsMultiLine()
	#--> TRUE
	
	? o1.Match(cMultilineText)
	#--> TRUE

# Softanza can make it for you in one line by using:

	? o1.MatchLine(cMultilineText)
	#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Dot Matches Everything Examples

pr()

cText = "Line 1
Line 2"

o1 = new stzRegExp("Line.*Line")
o1 {
	? Match(cText) #TODO //MatchLine() should return TRUE
	#--> FALSE

	DotMatchesEverything()

	? DotMatchesAll()
	#--> TRUE

	? Match(cText)
	#--> TRUE
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Extended Syntax Examples (comments allowed)

pr()

# Instead of using the following cryptic regular expression:
# "(?<day>[0-9]{2})/(?<month>[0-9]{2})/(?<year>[0-9]{4})"
# We can provide a more expressive version in a commented style:

o1 = new stzRegExp("
	# Match a valid date format

	(?<day>[0-9]{2})   # Named Group 1 : Two digits for the day
	/                  # Literal slash

	(?<month>[0-9]{2}) # Named Group 2 : Two digits for the month
	/                  # Literal slash

	(?<year>[0-9]{4})  # Named Group 3 : Four digits for the year
")

o1 {
	# Enable the extended syntax option to make
	# the commented pattern computable

	EnableExtendedSyntax()

	# Which can be verified by

	? HasExtendedSyntax()
	#--> TRUE

	# Perform the match against a date string

	? Match("25/12/2024")
	#--> TRUE

	# Retrieve and display the captured groups
	# (those enclosed between "(" and  ")" in the pattern)

	? @@( CapturedGroups() )
	#--> [ [ "day", "25" ], [ "month", "12" ], [ "year", "2024" ] ]

	
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*=== Greedy vs Lazy Matching

pr()

# In this example, we'll illustrate the difference between greedy 
# and lazy matching using the same pattern but contrasting outcomes.

# Example HTML string

cHtml = "<p>First paragraph</p><p>Second paragraph</p>"

# Greedy matching (default behavior)
#-----------------------------------

#~> Captures the entire string because it matches as much text 
#   as possible between the first <p> and the last </p>.

	o1 = new stzRegExp("<p>.*</p>")
	
	? o1.Match(cHtml)
	#--> TRUE
	
	? @@( o1.CapturedValues() )
	#--> [ "<p>First paragraph</p><p>Second paragraph</p>" ]

# Lazy matching (precise behavior)
#---------------------------------

#~> stops at the first closing </p>, extracting 
#   only the first <p> tag content.

	o1.LazyMatching()
	? o1.IsLazyMatching()
	#--> TRUE

	? o1.Match(cHtml)
	#--> TRUE

	? @@( o1.CapturedValues() )
	#--> [ "<p>First paragraph</p>" ]

# Which can be made by one function:

	? o1.MatchOne(cHtml)
	#--> TRUE

	? @@( o1.Values() )
	#--> [ "<p>First paragraph</p>" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Unicode Support Examples

pr()

o1 = new stzRegExp("\p{Script=Arabic}")

? o1.Match("مرحبا")
 #--> TRUE
? o1.Match("Hello")
#--> FALSE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Capture Groups Examples

pr()

o1 = new stzRegExp("(?<fname>[A-Za-z]+)\s+(?<lname>[A-Za-z]+)")

? o1.Match("John Doe")
#--> TRUE

? o1.CountCaptures()
#--> 2

? @@( o1.CaptureNames() )
#--> [ "fname", "lname" ]

? @@( o1.CapturedGroups() )
#--> [ [ "fname", "John" ], [ "lname", "Doe" ] ]

# Non-capturing groups

o1.DontCapture()
? o1.IsNonCapturing()
#--> TRUE

? o1.CountCaptures() #TODO // Check why it returns 2
#--> 0

proff()

/*=== Position-specific Matching Examples ==="

pr()

o1 = new stzRegExp("world")

? o1.MatchAt("Hello world!", 6)
#--> TRUE

? o1.MatchAt("Hello world!", 1)
#--> FALSE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Error Handling Examples

pr()

o1 = new stzRegExp("(unclosed")

? o1.IsValid()
#--> FALSE

? o1.LastError()
#--> "Missing closing parenthesis"

? o1.PatternErrorOffset()
#--> 9

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Pattern Options Reset Examples

pr()

o1 = new stzRegExp("pattern")

o1.CaseInsensitive()
o1.MultiLine()
o1.ExtendedSyntax()

? o1.GetOptions()
#--> 13 	# Binary: 1101

o1.ResetOptions()
? o1.GetOptions()
#--> 0

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Complex Real-world Examples

/*--- Example 1: Parsing Log Files

pr()

cLogPattern = new stzRegExp("
	(?<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+	# Timestamp
	(?<level>INFO|WARN|ERROR)\s+				# Log level
	(?<message>.+)						# Message content
")

cLogPattern.ExtendedSyntax()
cLogPattern.MultiLine()

cLogEntry = "2024-01-09 15:30:45 ERROR Database connection failed"

? cLogPattern.Match(cLogEntry)
#--> TRUE

? @@NL( cLogPattern.CapturedGroups() )
#--> [
#	[ "timestamp", "2024-01-09 15:30:45" ],
#	[ "level", "ERROR" ],
#	[ "message", "Database connection failed" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 2: Email Validation with Unicode Support

pr()

cEmailPattern = new stzRegExp("
	^
	(?<local>[\p{L}\p{N}._%+-]+)	# Local part allowing Unicode letters
	@
	(?<domain>[\p{L}\p{N}.-]+)	# Domain part
	\.
	(?<tld>\p{L}{2,})		# TLD with min 2 letters
	$
")

cEmailPattern.ExtendedSyntax()
//cEmailPattern.UseUnicode()

? cEmailPattern.Match("user.name@example.com")
#--> TRUE

? cEmailPattern.Match("användare@例子.com")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 3: Phone Number Parser

pr()

cPhonePattern = new stzRegExp("
	# Format: +XX-XXX-XXX-XXXX or (XXX) XXX-XXXX
	(?:
		(?<intl>\+\d{2}-)?		# Optional international prefix
		(?<area>\d{3}-)?		# Area code
		(?<prefix>\d{3}-)		# Prefix
		(?<line>\d{4}) 			# Line number
	) |
	(?:
		\((?<area2>\d{3})\)\s		# Area code in parentheses
		(?<prefix2>\d{3}-) 		# Prefix
		(?<line2>\d{4}) 		# Line number
	)
")

cPhonePattern.ExtendedSyntax()

? cPhonePattern.Match("+1-555-123-4567")
#--> TRUE

? cPhonePattern.Match("(555) 123-4567")
#--> TRUE

? @@NL( cPhonePattern.CapturedGroups() )
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

/*====
*/
pr()

o1 = new stzRegExp("(?<day>\d\d)-(?<month>\d\d)-(?<year>\d\d\d\d) (\w+) (?<name>\w+)")

? @@NL( o1.CaptureNames() )
#--> [
#	"",
#	"day",
#	"month",
#	"year",
#	"",
#	"name"
# ]

? @@NL( o1.CaptureGroups() )
#--> [
#	[ "day", "" ],
#	[ "month", "" ],
#	[ "year", "" ],
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22








/*===== CLASSIC STYLE ==============

pr()

o1 = new stzRegExp("[-.a-z0-9]+[@][-.a-z0-9]+[.][a-z]{2,4}")

? o1.IsValid()
#--> TRUE

? o1.Match("kalidianow@gmail.com")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

o1 = new stzRegExp("^(\d\d)/(\d\d)/(\d\d\d\d)$")

? o1.IsValid()
#--> TRUE

? o1.Match("07/01/2025") + NL
#--> TRUE

? o1.Capture()
#--> [ "07", "01", "2025" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== DECLARATIVE STYLE: #todo Implement it using stzRegExpMaker in background

pr()

o1 = new stzRegExp([])
o1 {
	# Sequence 1
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Sequence 2
	AddAmongChars(	"- ", 	    :RepeatedAtMost, 1, :Time)

	# Sequence 3
	AddDigitsRange(	"0-9", 	    :RepeatedBetween, 1, :And = [3, :Times])

	# Sequence 4
	AddAmongChars(	["-", " "], :RepeatedAtMost, 1, :Time)

	# Sequence 5
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Get the constructed pattern
	? getPattern() + NL

	# Get a narration that explains the pattern
	? getNarration()
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*------------ #todo Implement it using stzRegExpMaker in background

pr()

o1 = new stzRegExp()
o1 {

	# Designing the pattern in a natural style:

		# Sequence 1:
		CanContainACharBetween("A", :And = "Z", :RepeatedExactly = 2Times())
	
		# Sequence 2:
		CanContainAChar(:Among = [ "-", " " ], :RepeatdAtMost = 1Time())
	
		# Sequence 3:
		CanContainADigit(:From = [ "0", :To = "9"], :RepeatedExactly = 3Times())
	
		# Sequence 4:
		RepeatSequence(2)
	
		# Sequence 5
		RepeatSequence(1)

		CanContainADigit(:From = [ "0", :To = "9"], :RepeatedBetween = [ 2, :To = 3Times() ])

	# Math the pattern

		? Match("your pattern here")
		#--> TRUE

	# Check the pattern in many ways

		? Pattern()

		? Narration()

		? Sequences()

		? SequencesXT()

		? SequenceXT(3)

	
}

proff()


/*---- #todo Should use stzRegExpParser in the background

pr()

o1 = new stzRegExp
o1.parsePattern("[A-Z]{2}[- ]?[0-9]{1,3}[- ]?[A-Z]{2}")
? o1.getNarration()

proff()

