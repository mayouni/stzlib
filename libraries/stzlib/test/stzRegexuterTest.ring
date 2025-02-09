
load "../max/stzmax.ring"

/*---

pr()

? @@( AllMatches("The total was 42 dollars and 13 cents.", "(\d+)") )
#--> [ "42", "13" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Processing Numbers in Text

pr()

rxu() {
	# Step 1: Define what pattern should trigger computation

	AddTrigger(:NumberFound = "(\d+)")

	# Step 2: Define what to do when the trigger fires

	AddCode( :When = :NumberFound, :Do = '{
		@value = @number(@value) * 2
	}')

	# Step 3: Process some text to find and compute on matches

	Process("The total was 42 dollars and 13 cents.")

	? @@( Matches() )
	#--> [ "42", "13" ]

	? @@( Results() )
	#--> [ 84, 26 ]

}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Finding and Processing Emails

pr()

rxuter() {

	# Step 1: Watch for email patterns

	AddTrigger(:EmailFound = "(\w+)@(\w+\.\w+)")

	# Step 2: Define how to process found emails

	AddComputation( :When = :EmailFound, :Do = "{
	          @value = StzStringQ(@value).Split('@')[2]
	}")

	# Step 3: Process text containing emails

	Process("Contact us at support@example.com or sales@example.com")

	? @@NL( MatchesAndTheirResults() ) # or simply MatchesXT()
	#--> [
	# 	[ "support@example.com", "example.com" ],
	# 	[ "sales@example.com", "example.com" ]
	# ]

}

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Computing multiple triggers

pr()

rxu() {
	# Multiple triggers for different patterns

	Trigger(:Number = "(\d+)")
	Trigger(:WordInQuotes = '"([^"]+)"')
	Trigger(:EmailAddr = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})")

	# Different computations for each trigger (with @C as a shorthand for AddComputation())

	@C( :When = :Number, :Do = '{
		@value = @number(@value) * 2
	}')
	
	@C( :When = :WordInQuotes, :Do = '{
		@value = upper(@value)
	}')
	
	@C( :When = :EmailAddr, :Do = '{
		@value = "CONTACT: " + @value
	}')

	# Feeding the Regexuter with a string to process it by
	# firing the triggers and executing their computations

	Process('Contact "john doe" at john@example.com or
	call 555123 for a "quick response"')

	? @@NL( ResultXT() ) # or ResultsAndTheirMatches()
	#--> [
	# 	[ 1110246, "555123" ],
	# 	[ '"JOHN DOE"', '"john doe"' ],
	# 	[ '"QUICK RESPONSE"', '"quick response"' ],
	# 	[ "CONTACT: john@example.com", "john@example.com" ]
	# ]

}

proff()
#--> Executed in 0.05 second(s) in Ring 1.22

/*---

pr()

rxu() {

	# Define sensitive data pattern processor

	Trigger(:SensitiveData = "(password|secret|key):\s*(\w+)")
    
	# Define transformation with logging

	@C(:When = :SensitiveData, :Do = '{
		nOriginalLength = len(@value)
		@value = "REDACTED-" + nOriginalLength
	}')

	# Process sensitive content

	Process("User credentials: password: abc123 secret: def456")

	? @@( Matches() )
	#--> [ "password: abc123", "secret: def456" ]

	? @@( Results() ) + NL
	#--> [ "REDACTED-16", "REDACTED-14" ]

	? @@NL( State() )
	#--> [
	# 	[
	# 		[ "timestamp", "09/02/2025 12:32:40" ],
	# 		[ "computationorder", 1 ],
	# 
	# 		[ "triggername", "sensitivedata" ],
	# 		[ "pattern", "(password|secret|key):\s*(\w+)" ],
	# 		[ "matchedvalue", "password: abc123" ],
	# 		[ "computedvalue", "REDACTED-16" ],
	# 		[ "position", 19 ],
	# 
	# 		[ "dependson", [ "sensitivedata" ] ],
	# 		[ "affects", [ ] ]
	# 	],

	# 	[
	# 		[ "timestamp", "09/02/2025 12:32:40" ],
	# 		[ "computationorder", 2 ],
	# 
	# 		[ "triggername", "sensitivedata" ],
	# 		[ "pattern", "(password|secret|key):\s*(\w+)" ],
	# 		[ "matchedvalue", "secret: def456" ],
	# 		[ "computedvalue", "REDACTED-14" ],
	# 		[ "position", 36 ],
	# 
	# 		[ "dependson", [ "sensitivedata" ] ],
	# 		[ "affects", [ "sensitivedata" ] ]
	# 	]
	# ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22

#--- Text Processing Pipeline with Dependencies
# Shows how state tracking helps understand transformation order

pr()

rxu = new stzRegexuter()
rxu {
	# Add triggers for a text processing pipeline

	Trigger(["numbers", "\d+"])
	Trigger(["words", "[a-zA-Z]+"])
	Trigger(["spaces", "\s+"])

	# Add computations

	@C( :For = "numbers", 	:Do = '{ @value = number(@value) * 2 }' )
	@C( :For = "words", 	:Do = '{ @value = upper(@value) }' )
	@C( :For = "spaces", 	:Do = '{ @value = "-" }' )

	# Process text
	Process("hello 123 world 456")

	# Check matches and their results

	? @@NL( MatchesXT() ) + NL
	#--> [
	# 	[ "123", 246 ],
	# 	[ "456", 912 ],
	# 	[ "hello", "HELLO" ],
	# 	[ "world", "WORLD" ],
	# 	[ " ", "-" ],
	# 	[ " ", "-" ],
	# 	[ " ", "-" ]
	# ]

	# Check state to see transformation order and dependencies
	? @@NL( State() )
	#--> [
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 1 ],

	# 		[ "triggername", "numbers" ],
	# 		[ "pattern", "\d+" ],
	# 		[ "matchedvalue", "123" ],
	# 		[ "computedvalue", 246 ],
	# 		[ "position", 7 ],
	# 		[ "dependson", [ "numbers" ] ],
	# 		[ "affects", [ ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 2 ],
	# 		[ "triggername", "numbers" ],
	# 		[ "pattern", "\d+" ],
	# 		[ "matchedvalue", "456" ],
	# 		[ "computedvalue", 912 ],
	# 		[ "position", 17 ],
	# 		[ "dependson", [ "numbers" ] ],
	# 		[ "affects", [ "numbers" ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 3 ],
	# 		[ "triggername", "words" ],
	# 		[ "pattern", "[a-zA-Z]+" ],
	# 		[ "matchedvalue", "hello" ],
	# 		[ "computedvalue", "HELLO" ],
	# 		[ "position", 1 ],
	# 		[ "dependson", [ "words" ] ],
	# 		[ "affects", [ ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 4 ],
	# 		[ "triggername", "words" ],
	# 		[ "pattern", "[a-zA-Z]+" ],
	# 		[ "matchedvalue", "world" ],
	# 		[ "computedvalue", "WORLD" ],
	# 		[ "position", 11 ],
	# 		[ "dependson", [ "words" ] ],
	# 		[ "affects", [ "words" ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 5 ],
	# 		[ "triggername", "spaces" ],
	# 		[ "pattern", "\s+" ],
	# 		[ "matchedvalue", " " ],
	# 		[ "computedvalue", "-" ],
	# 		[ "position", 6 ],
	# 		[ "dependson", [ "spaces" ] ],
	# 		[ "affects", [ ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 6 ],
	# 		[ "triggername", "spaces" ],
	# 		[ "pattern", "\s+" ],
	# 		[ "matchedvalue", " " ],
	# 		[ "computedvalue", "-" ],
	# 		[ "position", 6 ],
	# 		[ "dependson", [ "spaces" ] ],
	# 		[ "affects", [ "spaces" ] ]
	# 	],
	# 
	# 	[
	# 		[ "timestamp", "09/02/2025 12:54:45" ],
	# 		[ "computationorder", 7 ],
	# 		[ "triggername", "spaces" ],
	# 		[ "pattern", "\s+" ],
	# 		[ "matchedvalue", " " ],
	# 		[ "computedvalue", "-" ],
	# 		[ "position", 6 ],
	# 		[ "dependson", [ "spaces" ] ],
	# 		[ "affects", [ "spaces" ] ]
	# 	]
	# ]
}
proff()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Data Validation Pipeline
# Shows how state helps track validation errors

pr()

rxu = new stzRegexuter()

# Add validation triggers
rxu.AddTrigger(["email", "[^@]+@[^@]+\.[^@]+"])
rxu.AddTrigger(["phone", "\d{3}-\d{3}-\d{4}"])
rxu.AddTrigger(["zipcode", "\d{5}"])

# Add validation computations
rxu.AddCode("email", '{
    if NOT ( contains(@value, ".com") or contains(@value, ".org") )
        @value = "INVALID {" + @value + "}"
    ok
}')

rxu.AddCode("phone", '{
    if NOT beginswith(@value, "555")
        @value = "INVALID {" + @value + "}"
    ok
}')

# Process contact info

rxu.Process("Contact: john@email.net 123-456-7890 12345")
? @@NL( rxu.MatchesXT() ) + NL
#--> [
#	[
#		"Contact: john@email.net 123-456-7890 12345",
#		"INVALID {Contact: john@email.net 123-456-7890 12345}"
#	],
#
#	[
#		"123-456-7890",
#		"INVALID {123-456-7890}"
#	],
#
#	[ "12345", "12345" ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Example 3: Code Analysis Pipeline
# Shows how state helps track code transformations

pr()

rxu = new stzRegexuter()

# Add code analysis triggers
rxu.AddTrigger(["function", "func\s+\w+\s*\([^\)]*\)"])
rxu.AddTrigger(["variable", "var\s+\w+\s*="])
rxu.AddTrigger(["comment", "#.*$"])

# Add analysis computations
rxu.AddCode("function", '{
    @value = "FUNCTION {" + trim(@value) + "}"
}')

rxu.AddCode("variable", '{
    @value = "VAR {" + trim(@value) + "}"
}')

rxu.AddCode("comment", '{
    @value = "COMMENT {" + trim(@value) + "}"
}')

# Process code

codeText = "
func calculate(x, y)
    # Add two numbers
    var result = x + y
    return result
"

rxu.Process(codeText)

# Use state to analyze code structure

See "Code Analysis:" + NL + NL

for entry in rxu.State()

    ? "Found " + entry[:triggerName] + " at position " + entry[:position] + ":"
    ? "  Original: " + entry[:matchedValue]
    ? "  Processed: " + entry[:computedValue]

    if len(entry[:affects]) > 0
        ? "  Affects: " + @@(entry[:affects])
    ok

next
#-->
# Found function at line 2:
#    Original: func calculate(x, y)
#    Processed: FUNCTION:func calculate(x, y)
# Found variable at line 49:
#    Original: var result =
#    Processed: VAR:var result =

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*===================================
