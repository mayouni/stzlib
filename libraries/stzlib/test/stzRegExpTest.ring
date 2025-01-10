load "../max/stzmax.ring"

/*==

profon()

? StzStartupTime() # in seconds
#--> 0.05

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Basic Pattern Matching

profon()

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

profon()

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

/*=== Multiline Pattern Examples

profon()

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


proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Dot Matches Everything Examples

profon()

cText = "Line 1
Line 2"

o1 = new stzRegExp("Line.*Line")
o1 {
	? Match(cText)
	#--> FALSE

	DotMatchesEverything()

	? DotMatchesAll()
	#--> TRUE

	? Match(cText)
	#--> TRUE
}

proff()

/*=== Extended Syntax Examples (comments allowed)

profon()

o1 = new stzRegExp("

	# Match a valid date format

	(?<day>[0-9]{2})   # Two digits for day
	/                  # Literal slash

	(?<month>[0-9]{2}) # Two digits for month
	/                  # Literal slash

	(?<year>[0-9]{4})  # Four digits for year
")

o1 {
	ExtendedSyntax()
	? HasExtendedSyntax()
	#--> TRUE

	? Match("25/12/2024")
	#--> TRUE

	? @@( CapturedGroups() )
	#--> [["day","25"], ["month","12"], ["year","2024"]]

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=== Greedy vs Lazy Matching Example ===*/

profon()

/*
In this example, we'll illustrate the difference between greedy 
and lazy matching using the same pattern but contrasting outcomes.
The goal is to extract only the first <p> tag content from a string.
*/

// Example HTML string
cHtml = "<p>First paragraph</p><p>Second paragraph</p>"

// Greedy matching (default behavior)
o1 = new stzRegExp("<p>.*</p>")
? o1.Match(cHtml)
#--> TRUE
? @@( o1.CapturedValues() )
#--> [ "<p>First paragraph</p><p>Second paragraph</p>" ]
// Greedy matching captures the entire string because it matches 
// as much text as possible between the first <p> and the last </p>.

// Lazy matching (precise behavior)
o1.LazyMatching()
? o1.IsLazyMatching()
#--> TRUE
? o1.Match(cHtml)
#--> TRUE
? @@( o1.CapturedValues() )
#--> [ "<p>First paragraph</p>" ]
// Lazy matching stops at the first closing </p>, extracting only 
// the first <p> tag content.

proff()

/*=== Summary ===
- Greedy matching captures the largest possible match, which is useful 
  for broad parsing tasks, such as extracting large sections of text.
- Lazy matching focuses on capturing the smallest possible match, 
  making it ideal for extracting specific elements like individual tags.
*/


/*=== Unicode Support Examples

profon()

o1 = new stzRegExp("\p{Script=Arabic}")
o1.UseUnicode()
? o1.UsesUnicode()                #--> TRUE
? o1.Match("مرحبا")               #--> TRUE
? o1.Match("Hello")               #--> FALSE

proff()

/*=== Capture Groups Examples

profon()

o1 = new stzRegExp("(?<fname>[A-Za-z]+)\s+(?<lname>[A-Za-z]+)")
? o1.Match("John Doe")            #--> TRUE
? o1.CaptureCount()               #--> 2
? o1.CaptureNames()               #--> ["fname", "lname"]
? o1.CapturedGroups()             #--> [["fname","John"], ["lname","Doe"]]

# Non-capturing groups
o1.DontCapture()
? o1.IsNonCapturing()             #--> TRUE
? o1.CaptureCount()               #--> 0

proff()

/*=== Position-specific Matching Examples ==="

profon()

o1 = new stzRegExp("world")
? o1.MatchAt("Hello world!", 6)   #--> TRUE
? o1.MatchAt("Hello world!", 0)   #--> FALSE

proff()

/*=== Error Handling Examples ==="

profon()

o1 = new stzRegExp("(unclosed")
? o1.IsValid()                    #--> FALSE
? o1.LastError()                  #--> "Missing closing parenthesis"
? o1.PatternErrorOffset()         #--> 8

proff()

/*=== Pattern Options Reset Examples ==="

profon()

o1 = new stzRegExp("pattern")
o1.CaseInsensitive()
o1.MultiLine()
o1.ExtendedSyntax()

? o1.GetOptions()                 #--> 13 # Binary: 1101

o1.ResetOptions()
? o1.GetOptions()                 #--> 0

proff()
/*=== Complex Real-world Examples

/*--- Example 1: Parsing Log Files

profon()

cLogPattern = new stzRegExp("
	(?<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+  # Timestamp
	(?<level>INFO|WARN|ERROR)\s+                            # Log level
	(?<message>.+)                                          # Message content
")
cLogPattern.ExtendedSyntax()
cLogPattern.MultiLine()

cLogEntry = "2024-01-09 15:30:45 ERROR Database connection failed"
? cLogPattern.Match(cLogEntry)    #--> TRUE
? cLogPattern.CapturedGroups()    #--> Shows parsed log components

proff()

/*--- Example 2: Email Validation with Unicode Support

profon()

cEmailPattern = new stzRegExp("
	^
	(?<local>[\p{L}\p{N}._%+-]+)   # Local part allowing Unicode letters
	@
	(?<domain>[\p{L}\p{N}.-]+)     # Domain part
	\.
	(?<tld>\p{L}{2,})              # TLD with min 2 letters
	$
")
cEmailPattern.ExtendedSyntax()
cEmailPattern.UseUnicode()

? cEmailPattern.Match("user.name@example.com")        #--> TRUE
? cEmailPattern.Match("användare@例子.com")           #--> TRUE

proff()

/*--- Example 3: Phone Number Parser

profon()

cPhonePattern = new stzRegExp("
	# Format: +XX-XXX-XXX-XXXX or (XXX) XXX-XXXX
	(?:
		(?<intl>\+\d{2}-)? 		# Optional international prefix
		(?<area>\d{3}-)? 		# Area code
		(?<prefix>\d{3}-) 		# Prefix
		(?<line>\d{4}) 			# Line number
	) |
	(?:
		\((?<area2>\d{3})\)\s 	# Area code in parentheses
		(?<prefix2>\d{3}-) 		# Prefix
		(?<line2>\d{4}) 		# Line number
	)
")

cPhonePattern.ExtendedSyntax()

? cPhonePattern.Match("+1-555-123-4567")             #--> TRUE
? cPhonePattern.Match("(555) 123-4567")              #--> TRUE
? cPhonePattern.CapturedGroups()                     #--> Shows parsed phone components

proff()












/*===== CLASSIC STYLE ==============

profon()

o1 = new stzRegExp("[-.a-z0-9]+[@][-.a-z0-9]+[.][a-z]{2,4}")

? o1.IsValid()
#--> TRUE

? o1.Match("kalidianow@gmail.com")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

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

profon()

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

profon()

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

profon()

o1 = new stzRegExp
o1.parsePattern("[A-Z]{2}[- ]?[0-9]{1,3}[- ]?[A-Z]{2}")
? o1.getNarration()

proff()
