load "../max/stzmax.ring"


/*===============
*/
@N = "-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?"
# - Matches numbers including negatives, commas for thousands, and decimals
# - Examples: "123", "-123", "1,234", "123.45"

@S = "\" + char(34) + "([^\" + char(34) + "]*)\" + char(34) + "|'([^']*)'"

# - Matches strings in double or single quotes
# - Handles escaped characters
# - Examples: "hello", 'world', "escaped\"quote"

@Item = "(?:" + @N + "|" + @S + ")" # This line wraps the alternation between @N and @S in a non-capturing group using (?: ... ).
@L = "(?:" + @Item + "(?:\s*,\s*" + @Item + ")*)?"
# - Matches a list of numbers and/or strings
# - Items separated by commas with optional whitespace

@OpenBr = "\[\s*("
@CloseBr = ")\s*\]"
@Comma = ")\s*,\s*("

@Sstar   = QuantifierPattern(@S, "*", "")  # Any number of strings
@Splus   = QuantifierPattern(@S, "+", "")  # One or more strings
@Smark   = QuantifierPattern(@S, "?", "")  # Optional string
@S1_3    = QuantifierPattern(@S, "1", "3") # 1 to 3 strings
@S3      = QuantifierPattern(@S, "3", "3") # Exactly 3 strings

@Nstar   = QuantifierPattern(@N, "*", "")  
@Nplus   = QuantifierPattern(@N, "+", "")  
@Nmark   = QuantifierPattern(@N, "?", "")  
@N1_3    = QuantifierPattern(@N, "1", "3")  
@N3      = QuantifierPattern(@N, "3", "3")  

@Lstar   = QuantifierPattern(@L, "*", "")  
@Lplus   = QuantifierPattern(@L, "+", "")  
@Lmark   = QuantifierPattern(@L, "?", "")  
@L1_3    = QuantifierPattern(@L, "1", "3")  
@L3      = QuantifierPattern(@L, "3", "3")

/*---

pr()

rx( @OpenBr + @L + @CloseBr ) {
    ? Match("[]")
    #--> TRUE
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Basic List Tests (Two Numbers)
www
pr()

rx( @OpenBr + @N + @Comma + @N + @CloseBr ) {
	? Match("[ 124, 34.12 ]")      #--> TRUE - Basic numbers
	? Match("[-5, 1000.42]")       #--> TRUE - Negative and decimal
	? Match("[1 234, 5_678.90]")   #--> TRUE - Thousands separator
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List of Two Strings

pr()

rx( @OpenBr + @S + @Comma + @S + @CloseBr ) {
	? Match('[ "hello", "world" ]')	#--> TRUE - Basic strings
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Mixed List (String & Number)

pr()

rx( @OpenBr + @S + @Comma + @N + @CloseBr ) {
	? Match('[ "age", 32 ]')	#--> TRUE - Basic mix
	? Match('["temp", -273.15]')	#--> TRUE - Negative decimal
	? Match('[ "price", 1234.56 ]')	#--> TRUE - With thousands
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- General List (@L)

pr()

rx( @OpenBr + @L + @CloseBr ) {
	? Match('[]')				#--> TRUE - Empty list
	? Match('[ 1, "hello", "world" ]')	#--> TRUE - Mixed types
	? Match('[ "a", 2, "b", 3 ]')		#--> TRUE - Alternating
	? Match('[ 1, "hello", [ 2, 3 ] ]')	#--> TRUE - Nested list
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List of Strings with Star (@Sstar): @S* Zero ore More

pr()

rx( @OpenBr + @Sstar + @CloseBr ) {
	? Match("[]")				#--> TRUE - Empty list
	? Match('[ "hello" ]')			#--> TRUE - Single item
	? Match('[ "hello", "world" ]')		#--> TRUE - Two items
	? Match('[ "a", "b", "c", "d" ]')	#--> TRUE - Multiple items
}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- List of Strings with Plus (@Splus) : S+ One or More

pr()

rx( @OpenBr + @Splus + @CloseBr ) {
	? Match("[]")			#--> FALSE - Empty not allowed

	? Match('[ "hello" ]')		#--> TRUE - Single required
	? Match('[ "a", "b", "c" ]')	#--> TRUE - Multiple OK
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List of 1-3 Strings (@S1_3)

pr()

rx( @OpenBr + @S1_3 + @CloseBr ) {
	? Match("[]")				#--> FALSE - Empty not allowed

	? Match('["one"]')			#--> TRUE - Minimum
	? Match('["one", "two"]')		#--> TRUE - Middle
	? Match('["one", "two", "three"]')	#--> TRUE - Maximum

	? Match('["a", "b", "c", "d"]')		#--> FALSE - Too many
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List of Exactly 3 Strings (@S3)

pr()

rx( @OpenBr + @S3 + @CloseBr ) {
	? Match('["one", "two"]')		#--> FALSE - Too few
	? Match('["one", "two", "three"]')	#--> TRUE - Exact match

	? Match('["a", "b", "c", "d"]')		#--> FALSE - Too many
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List with Optional Number (@Nmark)

pr()

rx( @OpenBr + @Nmark + @CloseBr ) {
	? Match("[]")		#--> TRUE - Empty is valid
	? Match("[42]")		#--> TRUE - Single number

	? Match("[42, 43]")	#--> FALSE - Multiple not allowed
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- List with Optional String (@Smark)

pr()

rx( @OpenBr + @Smark + @CloseBr ) {
	? Match("[]")		#--> TRUE - Empty is valid
	? Match('["hello"]')	#--> TRUE - Single string

	? Match('["a", "b"]')	#--> FALSE - Multiple not allowed
}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- List with Optional Mixed Item (@Lmark)
www
*/
pr()

str = '[ @N, @L* ]'

rx( @OpenBr + @N + @Comma + @Lmark + @CloseBr ) {
	? Match("[ 1, ]")	#--> TRUE - Empty is valid
	? Match("[4, [] ]")	#--> TRUE - Single number
	? Match('[7, [1] ]')	#--> TRUE - Single string

	? Match("[42, 43]")	#--> FALSE - Multiple not allowed
}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Testing @N + @Comma + @Lmark Pattern (Number followed by optional list)
www

pr()

rx( @OpenBr + @N + @Comma + @Lmark + @CloseBr ) {

	? Match("[1,]")			#--> TRUE - Number with no list
	? Match("[1, []]")		#--> TRUE - Number with empty list
	? Match('[1, ["a", "b"]]')	#--> TRUE - Number with string list
	? Match("[1, [42, 43]]")	#--> TRUE - Number with number list
	? Match('[1, ["a", 42, "b"]]')	#--> TRUE - Number with mixed list

	? Match('["hi"]')		#--> FALSE - Starts with string, not number
	? Match("[1, [2], [3]]")	#--> FALSE - Has two lists after number
	? Match("[1, 2]")		#--> FALSE - Second item not a list
	? Match("[1, [2], 3]")		#--> FALSE - List followed by non-list
}

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Testing @S + @Comma + @Lmark Pattern (String followed by optional list)
www
pr()

rx( @OpenBr + @S + @Comma + @Lmark + @CloseBr ) {
	? Match('["name", ]')		#--> TRUE - String with no list
	? Match('["name", []]')		#--> TRUE - String with empty list
	? Match('["name", [1, 2, 3]]')	#--> TRUE - String with number list
	? Match('["name", ["a", "b"]]')	#--> TRUE - String with string list

	? Match('[42]')			#--> FALSE - Starts with number, not string
	? Match('["name", [1], [2]]')	#--> FALSE - Has two lists after string
	? Match('["name", "value"]')	#--> FALSE - Second item not a list
}

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Testing standalone @Lmark Pattern (Optional list by itself)

pr()

rx( @OpenBr + @Lmark + @CloseBr ) {
	? Match("[]")		#--> TRUE - Empty outer list
	? Match("[[]]")		#--> TRUE - Contains empty list
	? Match("[[1, 2, 3]]")	#--> TRUE - Contains number list
	? Match('[["a", "b"]]')	#--> TRUE - Contains string list

	? Match("[[1], [2]]")	#--> FALSE - Contains multiple lists
	? Match("[1]")		#--> FALSE - Contains number instead of list
	? Match('["a"]')	#--> FALSE - Contains string instead of list
}

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*---
*/

func QuantifierPattern(base, min, max)

	# Special handling for list patterns

	if base = @L
		if min = "?"
			# For @Lmark, we want to match an optional nested list
			# The pattern should match either nothing or a complete
			# list in brackets

            		return "(?:\[\s*(?:" + @L + ")\s*\])?"
		ok
	ok

	# Regular handling for non-list patterns

	wrapped = "(?:" + base + ")"
    
	if min = "*"
		return "(?:" + wrapped + "(?:\s*,\s*" + wrapped + ")*)?"

	but min = "+"
		return wrapped + "(?:\s*,\s*" + wrapped + ")*"

	but min = "?"
		return wrapped + "?"
	ok

	if NOT IsNumberInString(min)
		StzRaise("Can't proceed! Insupported syntax in 'min' varaible.")
	ok

	if max = ""  # min is a number
		min_count = @number(min)
		if min_count = 1
			return wrapped
		else
			return wrapped + "(?:\s*,\s*" + wrapped + "){" + (min_count - 1) + "}"
		ok
	ok

	min_count = @number(min)
	max_count = @number(max)

	return wrapped + "(?:\s*,\s*" + wrapped + "){" + (min_count - 1) + "," + (max_count - 1) + "}"



/*---

rx('\[ \d+(?:\.\d+)?, \d+(?:\.\d+)?, "[^"]*" \]') {
	? Match('[ 1, 2, "hello" ]')
}
#--> TRUE

/*---

pr()

rx('^\s*\[\s*[\d+\s*,\s* "[^"]*"+]\s*\]\s*$') {
	? Match('[ 10, "hi" ]')
}

proff()

/*---

pr()

# Match [number, string+] (number followed by one or more strings)
lx = new stzListex("[@N, @S+ ]")
? lx.regexpattern()
#--> ^\[\s*\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s*,\s* "\[\s*^"\s*\]{0\s*,\s*}"{1\s*,\s*}\s*\]$

? lx.match([42, "hello", "world"])     # true
? lx.match([42, "hello"])              # true  
? lx.match([42])                       # false - needs strings
? lx.match(["hello", 42])              # false - wrong order

# Match nested lists
lx = new stzListex("[@L, @N]") 
? lx.match([[1,2], 3])                 # true

proff()

/*---

pr()

# Create patterns to match different list structures

Lx = new stzListex('[ @N, @N, @S, "World", 3 ]') # Lx for Listex
Lx {

	? Match([1, 2, "hello", "World", 3 ])
	#ERROR returned FALSE but should return TRUE

	? Match([1, "hello", 2])
	#--> FALSE

? Pattern()
#--> [ @N, @N, @S, "World", 3 ]

? RegexPattern()
#--> ^[ ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*})\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*})\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*})\s*,\s* "World"\s*,\s* 3 ]$

}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

Lx = new stzListex("[ @N+, @S? ]")  # Match one or more numbers followed by an optional string

? Lx.match([1, 2, 3, "hello"])
#ERROR returned FALSE but should return TRUE

? Lx.match([1, 2, 3])
#--> #ERROR returned FALSE but should be TRUE (string is optional)

? Lx.match(["hello"])
#--> FALSE (needs at least one number)

? Lx.Pattern()
#--> [ @N+, @S? ]

? Lx.RegexPattern()
#--> ^[ ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*}){1\s*,\s*}\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*}){0\s*,\s*1} ]$

proff()

/*=== repeating patterns

pr()

Lx = new stzListex("[ @NR2-4, @S? ]")
? Lx.match([1, 2])     #--> #ERROR returned FALSE but should be TRUE
? Lx.match([1, 2, 3])  #--> #ERROR returned FALSE but should be TRUE
? Lx.match([1])        #--> FALSE

? Lx.Pattern()
#--> [ @NR2-4, @S? ]

? Lx.RegexPattern()
#--> ^[ ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*})R2-4\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*}){0\s*,\s*1} ]$

proff()

/*---

pr()

Lx = new stzListex("[ @N+, @S2-3 ]")

? Lx.match([["hello"]])              #--> FALSE  # Too few
? Lx.match([5, "hello", "world"])    #ERROR: returned FALSE but should return TRUE   # Correct
? Lx.match(["a", "b", "c", "d"])     #--> FALSE  # Too many

? Lx.Pattern()
#--> [ @N+, @S2-3 ]

? Lx.RegexPattern()
#--> ^[ ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*}){1\s*,\s*}\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*})2-3 ]$

proff()

/*---

pr()

Lx = new stzListex("[ @N+, @S?, @ANY2-3 ]")

? Lx.match([42, "hello", [1, 2, 3] ])      #ERROR returnded FALSE but should return TRUE
? Lx.match([true, 42, null])   		#--> FALSE
? Lx.match([42, "str", 1])               #ERROR returned FALSE but should return TRUE

? Lx.Pattern()
#--> [ @N+, @S?, @ANY2-3 ]

? Lx.RegexPattern()
#--> ^[ ({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*}){1\s*,\s*}\s*,\s* ({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*}){0\s*,\s*1}\s*,\s* ({0\s*,\s*1}:({0\s*,\s*1}:\s{0\s*,\s*}\d{1\s*,\s*}({0\s*,\s*1}:\.\d{1\s*,\s*}){0\s*,\s*1}\s{0\s*,\s*})|({0\s*,\s*1}:\s{0\s*,\s*}"[^"]{0\s*,\s*}"\s{0\s*,\s*})|({0\s*,\s*1}:\s{0\s*,\s*}\[({0\s*,\s*1}:[^\[\]]{0\s*,\s*}|\[({0\s*,\s*1}:[^\[\]]{0\s*,\s*}|({0\s*,\s*1}R)){0\s*,\s*}\]){0\s*,\s*}\]\s{0\s*,\s*})|({0\s*,\s*1}:\s{0\s*,\s*}({0\s*,\s*1}i)({0\s*,\s*1}:true|false)\s{0\s*,\s*})|({0\s*,\s*1}:\s{0\s*,\s*}({0\s*,\s*1}i)({0\s*,\s*1}:null)\s{0\s*,\s*}))2-3 ]$

proff()

/*---


// Exact match of 3 numbers
Lx = new stzListex("[ @NR3 ]")
? Lx.Match([1, 2, 3])  // TRUE
? Lx.Match([1, 2])     // FALSE


// One or more numbers, optional string
Lx = new stzListex("[ @N+, @S? ]")
? Lx.Match([1, 2, 3])        // TRUE
? Lx.Match([1, 2, "hello"])  // TRUE

// 2-4 strings
Lx = new stzListex("[ @SR2-4 ]")
? Lx.Match(["a", "b"])           // TRUE
? Lx.Match(["a", "b", "c"])      // TRUE
? Lx.Match(["a", "b", "c", "d"]) // TRUE
? Lx.Match(["a"])                // FALSE
? Lx.Match(["a", "b", "c", "d", "e"]) // FALSE
