# Narrative
# --------
# Computing multiple triggers
#
# Extracted from stzregexutertest.ring, block #6.

load "../../../stzBase.ring"


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

pf()
#--> Executed in 0.05 second(s) in Ring 1.22
