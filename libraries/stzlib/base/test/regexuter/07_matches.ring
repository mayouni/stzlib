# Narrative
# --------
# pr()
#
# Extracted from stzregexutertest.ring, block #7.

load "../../stzBase.ring"


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

pf()
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
pf()
# Executed in 0.07 second(s) in Ring 1.22
