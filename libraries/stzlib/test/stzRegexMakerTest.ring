load "../max/stzmax.ring"

/*=============================================================#
#  CALLING PATTERNS BU THEIR NAMES FROM THE STZ-REGEX LIBRARY  #
#==============================================================#

pr()

# Match an Excel array formula
rx(pat(:xlsArrayFormula)) { ? Match("{=SUM(A1:A10)}") }
#--> TRUE

# Retrieve and inspect the pattern
rx(pat(:xlsArrayFormula)) { ? Pattern() + NL }
#--> Outputs the complex regex string

// Request a concise explanation
rx(pat(:xlsArrayFormula)) { ? Explain() + NL }
#--> "Matches an array formula in Excel"

// Request an extended breakdown of the regex
rx(pat(:xlsArrayFormula)) { ? ExplainXT() }
#--> Detailed line-by-line explanation of the regex components.

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:xlsConditionalExpression)) {

	? Match("B2<>C3")
	#--> TRUE

	? Pattern() + NL
	#--> "^.*(?:=|<|>|<>).*$"

	? Explain() + NL
	#--> Matches an Excel conditional expression

	? ExplainXT() + NL
	#-->
	# - `^.*(?:=|<|>|<>).*$`: Matches any formula containing comparison operators.

	# - Matches: `A1=A2`, `B1<>C1`, `A1>10`, `5<=6`.
	# - Non-matches: `A1A2`, `=A1`, `<B2`.

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:email)) {
	? Pattern() + NL
	? ExplainXT()
}
#--> [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
#
# - `^` and `$`: Start and end of the string.
# - `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters.
# - `@`: Required @ symbol.
# - `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens.
# - `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters.
#
# - Matches: `user@domain.com`, `user.name+tag@example.co.uk`
# - Non-matches: `@domain.com`, `user@.com`, `user@domain`

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:URL)) { ? Explain() ? Pattern() }
#-->
# Matches web URLs
# ^https?:\/\/(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$

rx(pat(:URL)) { ? ExplainXT() }
# - `^` and `$`: Start and end of the string.
# - `(https?:\/\/)?`: Optional protocol.
# - `([\da-z\.-]+)`: Domain name.
# - `\.([a-z\.]{2,6})`: Last segment (TLD) like `.com`, `.tn`, etc.
# - `([\/\w \.-]*)*\/?`: Optional path.
# - Matches: `https://example.com`, `domain.co.tn/path`
# - Non-matches: `http:/domain.com`, `.com`, `https://`

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:domain)) { ? Explain() + NL }
#--> Matches domain names

rx(pat(:domain)) { ? Pattern() + NL }
#--> ^(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$

rx(pat(:domain)) { ? ExplainXT() }
#-->
# - `^` and `$`: Start and end of the string.
# - `[a-z0-9](?:[a-z0-9-]*[a-z0-9])?`: Domain segments.
# - `\.`: Dot separator.
# - Matches: `example.com`, `sub.domain.co.eg`
# - Non-matches: `-example.com`, `domain..com`

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:ipv4)) {
	? Explain() + NL
	? Pattern() + NL
	? ExplainXT()
}
#-->
# Matches IPv4 addresses
# ^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
#
# - `^` and `$`: Start and end of the string.
# - `25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?`: Numbers 0-255.
# - Repeated 4 times with dots.
# - Matches: `192.168.0.1`, `10.0.0.0`
# - Non-matches: `256.1.2.3`, `1.2.3`, `a.b.c.d`

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:IPv6)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> (([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Matches basic IPv6 addresses

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `[A-F0-9]{1,4}`: Hexadecimal groups.
	#- Seven groups with colons, plus final group.
	# - Matches: `2001:0DB8:0000:0000:0000:0000:1428:57AB`
	# - Non-matches: `2001::1428:57AB` (compressed form)

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:SocialHandle)) { ? Pattern() + NL + Explain() + NL + ExplainXT() }
#--> ^@[a-zA-Z0-9._]{1,30}$
#--> Matches social media handles
#-->
# - `^` and `$`: Start and end of the string.
# - `@`: Required @ symbol.
# - `[a-zA-Z0-9_]{1,15}`: 1-15 alphanumeric or underscore characters.
# - Matches: `@user123`, `@User_name`
# - Non-matches: `user123`, `@user-name`, `@toolong123456789`

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:isoDate)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Matches ISO dates (YYYY-MM-DD)

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `\d{4}`: Four-digit year.
	# - `(?:0[1-9]|1[0-2])`: Months 01-12.
	# - `(?:0[1-9]|[12]\d|3[01])`: Days 01-31.
	# 
	# - Matches: `2024-01-14`, `2023-12-31`
	# - Non-matches: `2024-13-01`, `2024-01-32`

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

rx(pat(:isoDateTime)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-][01][0-9]:[0-5][0-9])?$

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Mmatches ISO datetime

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `T`: Time separator.
	# - `(?:[01]\d|2[0-3])`: Hours 00-23.
	# - `[0-5]\d`: Minutes and seconds 00-59.
	# - `(?:\.\d+)?`: Optional milliseconds.
	# - `(?:Z|[+-][01]\d:[0-5]\d)`: Timezone.
	# - Matches: `2024-01-14T15:30:00Z`, `2024-01-14T15:30:00.123+01:00`
	# - Non-matches: `2024-01-14 15:30:00`, `2024-01-14T25:00:00Z`

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

# Test Web & Email

	rx(pat(:email)) { ? Match("user@example.com") }
	#--> TRUE
	
	rx(pat(:email)) { ? Match("invalid@email") }
	#--> FALSE
	
	rx(pat(:url)) { ? Match("http://example.com/path") }
	#--> TRUE
	
	rx(pat(:url)) { ? Match("not-a-url") + NL }
	#--> FALSE

# Test Dates & Times

	rx(pat(:isoDate)) { ? Match("2024-01-14") }
	#--> TRUE
	
	rx(pat(:isoDate)) { ? Match("2024-13-14") }
	#--> FALSE
	
	rx(pat(:time24h)) { ? Match("23:59") }
	#--> TRUE
	
	rx(pat(:time24h)) { ? Match("25:00")  + NL }
	#--> FALSE

# Test Numbers & Currency

	rx(pat(:number)) { ? Match("-12,345.67") }
	#--> TRUE

	rx(pat(:number)) { ? Match("1.2.3") }
	#--> FALSE
	
	rx(pat(:currencyValue)) { ? Match("1,234.56") }
	#--> TRUE
	
	rx(pat(:currencyValue)) { ? Match("1234.567") + NL }
	#--> FALSE

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

? unicode('"')
#--> 34

? unicode("'")
#--> 39

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

? @@( Types([ 3, "ok", 1:3, ANullObject() ]) ) + NL
#--> [ "NUMBER", "STRING", "LIST", "OBJECT" ]

? @@NL( TypesXT([ 3, "ok", 1:3, ANullObject() ]) )
#--> [
#	[ 3, "NUMBER" ],
#	[ "ok", "STRING" ],
#	[ [ 1, 2, 3 ], "LIST" ],
#	[ @nullobject, "OBJECT" ]
# ]

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*=== Ring number() VS Softanza @Number()

pr()

? number("12 120.5")
#--> 12

? @Number("12 120.5") + NL
#--> 12120.50

#--

//? number("12_120.5")
#--> ERROR: Invalid numeric string

? @Number("12_120.5")
#--> 12120.50

proff()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

? IsNumberInString("-12120.5")
#--> TRUE

? IsNumberInString("-12 120.5")
#--> TRUE

? IsNumberInString("-12_120.5")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=======================================#
#  DECLARATIVE DESIGN OF REGEX PATTERNS  #
#========================================#

pr()

o1 = new stzRegexMaker()
o1 {
	# Sequence 1
	AddCharsRange( "A-Z", :RepeatedExactly, 2, :Times)

	# Sequence 2
	AddAmongChars("- ", :RepeatedAtMost, 1, :Time)

	# Sequence 3
	AddDigitsRange(	"0-9", :RepeatedBetween, 1, :And = [3, :Times])

	# Sequence 4
	AddNotAmongChars(["-", " "], :RepeatedAtMost, 1, :Time)

	# Sequence 5
	RepeatSequence(1)

	# Get the constructed pattern
	? Pattern() + NL
	#--> [A-Z]{2}[- ]?[0-9]{1,3}[^- ]?[A-Z]{2}
}
	# Get the pattern structure

	? @@NL( o1.FragmentsXT() )
	#--> [
	# [ "[A-Z]{2}", [ "between", "A-Z", "repeatedexactly", 2, "times" ] ],
	# [ "[- ]?", [ "among", "- ", "repeatedatmost", 1, "time" ] ],
	# [ "[0-9]{1,3}", [ "between", "0-9", "repeatedbetween", 1, 3 ] ],
	# [ "[^- ]?", [ "notamong", "- ", "repeatedatmost", 1, "time" ] ],
	# [ "[A-Z]{2}", [ "between", "A-Z", "repeatedexactly", 2, "times" ] ]
]

}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------

pr()

# Let's design the string pattern of the new french registration number.
# Here are some examples: 

# Standard Format (with hyphens):
#	AB-123-CD
#	XY-987-ZT

# Standard Format (with spaces):
#	AB 123 CD
#	XY 987 ZT

# Without Separators:
#	AB123CD
#	XY987ZT

o1 = new stzRegexMaker()
o1 {
	# Designing the pattern in a natural style:
	#------------------------------------------

	# Sequence 1:
	CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
	
	# Sequence 2:
	CanContainAChar(:Among = [ "-", " " ], :RepeatedAtMost = 1Time())
	
	# Sequence 3:
	CanContainADigit(:From = [ "0", :To = "9"], :RepeatedExactly = 3Times())
	
	# Sequence 4:
	RepeatSequence(2)
	
	# Sequence 5
	RepeatSequence(1)

	# Get the pattern constructed internally

	? Pattern()
	#---> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}
}
	# Everything has been stored as data for future use

	? @@NL( FragmentsXT() ) + NL // Regex Fragments and their relative Sequences
	# [
	# 	[ "[A-Z]{2}", 	[ "chars", "A-Z", "repeatedexactly", 2, 0 ] ],
	# 	[ "[- ]?", 	[ "among", [ "-", " " ], "repeatedatmost", 1, 0 ] ],
	# 	[ "[0-9]{3}", 	[ "chars", "0-9", "repeatedexactly", 3, 0 ] ],
	# 	[ "[- ]?", 	[ "among", [ "-", " " ], "repeatedatmost", 1, 0 ] ],
	# 	[ "[A-Z]{2}", 	[ "chars", "A-Z", "repeatedexactly", 2, 0 ] ]
	# ]

	# You have also other variants like SequencesXT(), Sequences(), Fragments().
	# And you can get a given sequence or fragment using Sequence(n), SequenceXT(n),
	# Fragment() or FragmentXT(n) like for example:

	? @@( SequenceXT(3) )
	#--> [ [ "chars", "0-9", "repeatedexactly", 3, 0 ], "[0-9]{3}" ]

}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*=====================================#
#  DESIGNING RECURSIVE REGEX PATTERNS  #
#======================================#

/*--- Example 1: Simple balanced parentheses

pr()

o1 = new stzRecursiveRegexMaker()
o1 {
	EnableNamedRecursion()
	
	AddLevel("expr", "\(")
	AddChildLevel("expr", "inner", "[^()]*")
	AddLevel("close", "\)")
	
	? Pattern()
	#--> (?P<expr>\()(?P<inner>[^()]*)\)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 2: Nested JSON-like structure

# In this example, we show how Softanza declarative style can help
# you design an interesting recursive regex pattern as complex as:
#
# (?P<object>\{)(?P<pair>"[^"]+"\s*:\s*)+(?P<value>[^{}]+)\}
#
# It matches an object-like structure (similar to a JSON object) with:
#
# - A starting {
# - One or more key-value pairs ("key": value)
# - A value that is not enclosed by {}

pr()

o2 = new stzRecursiveRegexMaker()
o2 {
	EnableNamedRecursion()
	
	AddLevel("object", "\{")
	AddChildLevel("object", "pair", '"[^"]+"\s*:\s*')
	AddChildLevel("pair", "value", '[^{}]+')
	AddLevel("close", "\}")
	
	AddQuantifier("pair", "+")
	
	? Pattern()
	#--> (?P<object>\{)(?P<pair>"[^"]+"\s*:\s*)+(?P<value>[^{}]+)\}
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 3: XML-like tags

pr()

o3 = new stzRecursiveRegexMaker()
o3 {
	EnableNamedRecursion()
	
	AddLevel("tag", "<([^>]+)>")
	AddChildLevel("tag", "content", "[^<>]*")
	AddLevel("close", "</\1>")
	
	? Pattern()
	#--> (?P<tag><([^>]+)>)(?P<content>[^<>]*)</\1>
}

? NL

# Getting pattern information

? @@NL( o3.Info() ) + NL
#--> [
#	[
#		[ "name", "tag" ],
#		[ "pattern", "<([^>]+)>" ],
#		[ "parent", "" ],
#		[ "children", [ 2 ] ],
#		[ "quantifier", "" ]
#	],
#
#	[
#		[ "name", "content" ],
#		[ "pattern", "[^<>]*" ],
#		[ "parent", 1 ],
#		[ "children", [ ] ],
#		[ "quantifier", "" ]
#	],
#
#	[
#		[ "name", "close" ],
#		[ "pattern", "</\1>" ],
#		[ "parent", "" ],
#		[ "children", [ ] ],
#		[ "quantifier", "" ]
#	]
# ]

? @@(o3.LevelNames()) + NL
#--> [ "tag", "content", "close" ]

? @@(o3.LevelChildren("tag"))
#--> [ "content" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 4: Empty Pattern

pr()

o1 = new stzRecursiveRegexMaker()
o1 {
	? @@(Pattern())
	#--> ""
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 5: Single Level No Children

pr()

o2 = new stzRecursiveRegexMaker()
o2 {
    EnableNamedRecursion()
    AddLevel("simple", "abc")
    ? Pattern()
    #--> (?P<simple>abc)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 6: Multiple Independent Levels

pr()

o3 = new stzRecursiveRegexMaker()
o3 {
    EnableNamedRecursion()
    AddLevel("first", "abc")
    AddLevel("second", "def")
    ? Pattern()
    #--> (?P<first>abc)(?P<second>def)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 7: Deeply Nested Structure

pr()

o4 = new stzRecursiveRegexMaker()
o4 {
    EnableNamedRecursion()
    AddLevel("outer", "\{")
    AddChildLevel("outer", "inner1", "\[")
    AddChildLevel("inner1", "inner2", "\(")
    AddChildLevel("inner2", "content", "[^()]*")
    AddLevel("close", "\)\]\}")
    ? Pattern()
    #--> (?P<outer>\{)(?P<inner1>\[)(?P<inner2>\()(?P<content>[^()]*)\)\]\}
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 9: Complex Quantifiers

pr()

o5 = new stzRecursiveRegexMaker()
o5 {
    EnableNamedRecursion()
    AddLevel("list", "\[")
    AddChildLevel("list", "item", "[0-9]+")
    AddChildLevel("item", "separator", ",\s*")
    AddLevel("close", "\]")
    AddQuantifier("item", "+")
    AddQuantifier("separator", "?")
    ? Pattern()
    #--> (?P<list>\[)(?P<item>[0-9]+)(?P<separator>,\s*)?+\]
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 10: Special Characters Escaping

pr()

o6 = new stzRecursiveRegexMaker()
o6 {
    EnableNamedRecursion()
    AddLevel("special", "\$\^\*\+\?\{\}\[\]\(\)")
    ? Pattern()
    #--> (?P<special>\$\^\*\+\?\{\}\[\]\(\))
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 11: Back References with Groups

pr()

o7 = new stzRecursiveRegexMaker()
o7 {
    EnableNamedRecursion()
    AddLevel("tag", "<([a-z]+)>")
    AddChildLevel("tag", "content", ".*?")
    AddLevel("close", "</\1>")
    ? Pattern()
    #--> (?P<tag><([a-z]+)>)(?P<content>.*?)</\1>
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 12: Multiple Quantified Children

pr()

o8 = new stzRecursiveRegexMaker()
o8 {

	EnableNamedRecursion()

	AddLevel("object", "\{")
	AddChildLevel("object", "key", '"[^"]+"\s*:\s*')
	AddChildLevel("key", "value", '[^,}]+')
    	AddChildLevel("object", "comma", ",\s*")
	AddLevel("close", "\}")

	AddQuantifier("key", "+")
	AddQuantifier("comma", "*")

	? Pattern()
	#--> (?P<object>\{(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+(?P<comma>,\s*)*)\}
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 13: Unicode Support

pr()

o9 = new stzRecursiveRegexMaker()
o9 {
    EnableNamedRecursion()
    AddLevel("unicode", "[\u0410-\u044F]+")
    AddChildLevel("unicode", "space", "\s+")
    ? Pattern()
    #--> (?P<unicode>[\u0410-\u044F]+)(?P<space>\s+)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 14: Empty Child Pattern

pr()

o10 = new stzRecursiveRegexMaker()
o10 {
    EnableNamedRecursion()
    AddLevel("parent", "start")
    AddChildLevel("parent", "empty", "")
    ? Pattern()
    #--> (?P<parent>start)(?P<empty>)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 15: Alternation Patterns

pr()

o11 = new stzRecursiveRegexMaker()
o11 {
    EnableNamedRecursion()
    AddLevel("choice", "(yes|no)")
    AddChildLevel("choice", "maybe", "(?:maybe)?")
    ? Pattern()
    #--> (?P<choice>(yes|no))(?P<maybe>(?:maybe)?)
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 16: Pattern Information
*/
pr()

# We use rrxm() instead of new stzRecursiveRegexMaker()

#--> "r": recursive, "rxm": regex maker

rrxm() {
    	EnableNamedRecursion()

	AddLevel("object", "\{")
	AddChildLevel("object", "key", '"[^"]+"\s*:\s*')
	AddChildLevel("key", "value", '[^,}]+')
	AddChildLevel("object", "comma", ",\s*")

	AddLevel("close", "\}")
	AddQuantifier("key", "+")
	AddQuantifier("comma", "*")

	? Pattern() + NL
	#--> (?P<object>\{(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+(?P<comma>,\s*)*)\}

	? @@(LevelNames())
	#--> ["object", "key", "value", "comma", "close"]
	
	? NumberOfLevels()
	#--> 5
	
	? @@(LevelChildren("object"))
	#--> ["key", "comma"]
	
	? HasLevel("key")
	#--> TRUE

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=======================================#
#  DESIGNING CONDITIONAL REGEX PATTERNS  #
#========================================#

pr()

o = new stzRegexConditionalMaker

# Basic conditional: if digit then match more digits else match letters
o.IfMatch("\d").
  ThenMatch("\d+").
  ElseMatch("[a-z]+")

? o.Pattern()
#--> (?(?=\d)\d+|[a-z]+)

# Using named parameters
o.Reset()
o.IfStartsWith(:Pattern = "\d").
  ThenMatch(:Pattern = "\d+").
  ElseMatch(:Pattern = "[a-z]+")

? o.Pattern()
#--> (?(?=^\d)\d+|[a-z]+)

# Checking content
? @@NL( o.Content() )
#--> [
#     :condition = "(?(?=^\d)",
#     :then = "\d+",
#     :else = "[a-z]+",
#     :pattern = "(?(?=^\d)\d+|[a-z]+)"
#    ]


proff()

/*==========================================#
#  DESIGNING LOOKING AROUND REGEX PATTERNS  #
#===========================================#

pr()

o = new stzRegexLookaroundMaker

o.MustBePrecededBy("Mr\.").ThenMatch("[A-Z][a-z]+")
o.CantBeFollowedBy("px").ThenMatch("\d+")
o.MustBeFollowedByWord("hello").ThenMatch("\w+")
? o.Pattern()
#--> (?=\bhello\b)\w+

# Still works with original "looking" terminology
o.LookingBehind("Mr\.").ThenMatch("[A-Z][a-z]+")
o.NotLookingAhead("px").ThenMatch("\d+")
o.LookingForWord("hello").ThenMatch("\w+")
? o.Pattern()
#--> (?=\bhello\b)\w+

proff()

#=========================#
#  OTHER EXAMPLES ...
#=========================#

/*--- Password Validation

pr()

o1 = new stzRegexMaker
o1 {
	AddWordBoundary(:start)
	AddCapturingGroup("length", ".{8,}")           # Min 8 chars
	AddCapturingGroup("upper", ".*[A-Z].*")        # Has uppercase
	AddCapturingGroup("lower", ".*[a-z].*")        # Has lowercase  
	AddCapturingGroup("digit", ".*\d.*")           # Has number
	AddCapturingGroup("special", ".*[!@#$%^&*].*") # Has special char
	AddWordBoundary(:end)

	? Pattern()
	#--> \b(?P<length>.{8,})(?P<upper>.*[A-Z].*)(?P<lower>.*[a-z].*)(?P<digit>.*\d.*)(?P<special>.*[!@#$%^&*].*)\b
}

proff()

/*--- HTML Tag Matcher

pr()

# Instead of cretaing a stzRegexMaker object, storing it in an o1
# variable, then use it, we can use the small function rxm()

#~> "rx" for Regex and "m" for Maker

rxm() {

	AddCapturingGroup("tag", "<([a-z]+)>")
	AddCapturingGroup("content", ".*?")
	AddBackReference(1)  # Match closing tag

	? Pattern()
	#--> (?P<tag><([a-z]+)>)(?P<content>.*?)\\1
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Smart Quote Matcher

pr()

o1 = new stzRegexMaker

o1.SetCase(:insensitive)
o1.AddCapturingGroup("quote", '[""].*?[""]')
o1.AddComment("Matches smart quotes and content")

? o1.Pattern()
#--> (?i)(?P<quote>[""].*?[""])(?#Matches smart quotes and content)

proff()

/*--- Data Validation

pr()

o1 = new stzRegexMaker

o1.AddCommonPattern(:date)
o1.AddCharClass(:space) 
o1.AddCommonPattern(:email)

? o1.Pattern()
#--> [\s]*[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- HTML Content Extraction - different matching behaviors:

pr()

rxm() {

	AddCapturingGroup("tag", "<div>")

	# :shortest - Matches each div's content separately
	AddMatchLength(".*", :shortest)  # Gets individual div contents

	# :longest - Matches from first div to last closing tag
	AddMatchLength(".*", :longest)   # Gets everything between first and last div

	# :complete - Matches full content without backtracking
	AddMatchLength(".*", :complete)  # More efficient for large HTML docs

	? Pattern()
	#--> (?P<tag><div>).*+?.*+.*++
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Data Parsing - choosing appropriate behavior:

pr()

o1 = new stzRegexMaker

# :shortest for individual items
o1.AddMatchLength("\w+", :shortest)  # Split "item1,item2" into separate matches

# :longest for full entries
o1.AddMatchLength(".+", :longest)    # Capture "key=value" as single entry

# :complete for fixed formats
o1.AddMatchLength("\d+", :complete)  # Match complete number without backtracking

? o1.Pattern()
#--> \w++?.++\d+++

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Match duplicated words

pr()

rxm() {
	AddWordBoundary(:start)
	DefineGroup("word", "\w+")      # Define word group
	AddCharacterClass(:space)
	MatchSameContentAs("word")      # Must match same word
	AddWordBoundary(:end)

	? Pattern()
	#--> \b(?P<word>\w+)[\s]*(?P=word)\b
}

# Examples of matches using the constructed pattern

rx("\b(?P<word>\w+)[\s]*(?P=word)\b") {

	? Match("the the")
	#--> TRUE

	? Match("hello hello")
	#--> TRUE

	? Match("the that the")
	#--> FALSE

	? Match("hello word")
	#--> FALSE

}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- HTML tag matching

pr()

rxm() {
	DefineGroup("tag", "<([a-z]+)>")   # Include < > in the tag pattern
	AddCharacterClass(:any)            # Add .* for content
	MatchOppositeTagAs("tag")         

	? Pattern()
	#--> (?P<tag><([a-z]+)>)</(?P=tag)>
}

rx("(?P<tag><([a-z]+)>).*</\2>") {

	? Match("<div>content</div>")
	#--> TRUE

	? Match("<p>text</p>")
	#--> TRUE

	? Match("<div>text</p>")
	#--> FALSE

	? Match("<div>text</span>")
	#--> FALSE
}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Format validation with reused patterns

pr()

rxm() {
	DefineGroup("num", "\d{2}")     # Define 2-digit pattern
	AddLiteral("/")
	ReuseGroupPattern("num")        # Reuse same pattern
	AddLiteral("/")
	ReuseGroupPattern("num")        # Reuse again

	? Pattern()
	#--> (?P<num>\d{2})/(?:\d{2})/(?:\d{2})

}

# Let's check the patter against some valid and valid dates

rx("(?P<num>\d{2})/(?:\d{2})/(?:\d{2})") {
	? Match("12/34/56")
	#--> TRUE

	? Match("1/2/3")
	#--> FALSE

	? Match("12/3/45")
	#--> FALSE
}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Use of IsBeforeGroup

pr()

o1 = new stzRegexMaker
o1 {
	AddCharacterClass(:word)	# Match word characters first
	AddCharacterClass(:space)	# Then space
	DefineGroup("num", "\d+")	# Then capture number

	? Pattern()
	#--> [\w]+[\s]+(?P<num>\d+)	# Correct order
}

rx("[\w]+[\s]+(?P<num>\d+)") {

	? Match("hello 123")
	#--> TRUE

	? Match("test 456")
	#--> TRUE

	? Match("123 hello")
	#--> FALSE

	? Match("test")
	#--> FALSE
}

proff()
# Executed in 0.02 second(s) in Ring 1.22
