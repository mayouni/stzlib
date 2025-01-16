load "../max/stzmax.ring"

/*=== REGEX EXPLANATIONS

pr()

rx(pat(:xlsArrayFormula)) { ? Match("{=SUM(A1:A10)}") }
#--? TRUE

# You want to see the regex pattern itself?

rx(pat(:xlsArrayFormula)) { ? Pattern() + NL }
#--> 

# Hard to understand? Don't worry, ask Softanza to explain it

//rx(pat(:xlsArrayFormula)) { ? Explain() + NL }
#--> "Matches an array formula in Excel"

# You want a detailed explanation of the regex itself? There an eXTended explanaltion

//rx(pat(:xlsArrayFormula)) { ? ExplainXT() }
#-->
# - `^\\{`: Matches the opening curly brace for the array formula.
# - `(?:`: Start of a non-capturing group.
# - `\\s*=\\s*[A-Za-z]+\\([^\\)]*\\)`: Matches a formula starting with an equal
#   sign, a function name, and arguments enclosed in parentheses.
# - `|`: Alternation to match either a function or plain array values.
# - `\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+`: Matches numeric or textual values,
#   operators, and parenthesized expressions.
# - `(\\s*,\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+)*`: Optionally matches additional
#   array elements separated by commas.
# - `\\s*`: Allows trailing whitespace.
# - `\\}`: Matches the closing curly brace for the array formula.
# - `$`: Ensures the entire string matches the pattern.

# - Matches: `{=SUM(A1:A10)}`, `{1, 2, 3}`, `{A1+B1, C1*D1}`.
# - Non-matches: `{SUM(A1:A10}`, `{1, 2}`, `=SUM(A1:A10)`.

//proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---
*/
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
*/
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

/*---



/*====

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

# Test Security Patterns

	rx(pat(:passwordComplexity)) { ? Match("Password123!") }
	#--> TRUE (Strong enough)

	rx(pat(:passwordComplexity)) { ? Match("abc") }
	#--> FALSE (weak password)

	rx(pat(:noSqlKeywords)) { ? Match("SELECT * FROM users") }
	#--> FALSE (SQL injection attempt!)

	rx(pat(:noSqlKeywords)) { ? Match("normal text") + NL }
	#--> TRUE (Safe text)

# Test Mobile & Web App

	rx(pat(:appVersion)) { ? Match("1.2.3") }
	#--> TRUE

	rx(pat(:appVersion)) { ? Match("1.2") }
	#--> FALSE

# Test Content Security

	rx(pat(:allowedHtml)) { ? Match("<p>text</p>") }
	#--> TRUE

	rx(rxp(:allowedHtml)) { ? Match("<script>alert(1)</script>") }
	#--> FALSE

	rx(pat(:allowedFileTypes)) { ? Match("document.pdf") }
	#--> TRUE

	rx(pat(:allowedFileTypes)) { ? Match("script.exe") + NL }
	#--> FALSE

# Misc patterns

	rx(pat(:coordinates)) { ? Match("40.7128,-74.0060") }
	#--> TRUE

	rx(pat(:coordinates)) { ? Match("12.8") + NL }
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

/*===
*/
pr()

o1 = new stzRegexMaker()
o1 {
	# Sequence 1
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Sequence 2
	AddAmongChars(	"- ", 	    :RepeatedAtMost, 1, :Time)

	# Sequence 3
	AddDigitsRange(	"0-9", 	    :RepeatedBetween, 1, :And = [3, :Times])

	# Sequence 4
	AddAmongChars(	["-", " "], :RepeatedAtMost, 1, :Time)
#TODO Teste AddNotAmongChars()
	# Sequence 5
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Get the constructed pattern
	? Pattern() + NL

	# Get the pattern structure

//	? @@NL( o1.FragmentsXT() )
	#--> [
	# 	[ "[A-Z]{2}", 	[ "chars", "A-Z", "repeatedexactly", 2, "times" ] ],
	# 	[ "[- ]?", 	[ "among", [ "-", " " ], "repeatedatmost", 1, "time" ] ],
	# 	[ "[0-9]{1,3}", [ "digits", "0-9", "repeatedbetween", 1, 3 ] ],
	# 	[ "[- ]?", 	[ "among", [ "-", " " ], "repeatedatmost", 1, "time" ] ],
	# 	[ "[A-Z]{2}", 	[ "chars", "A-Z", "repeatedexactly", 2, "times" ] ]
	# ]

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

	# Get the patter constructed internally

	? Pattern()
	#---> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}

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
# Executed in 0.05 second(s) in Ring 1.22
