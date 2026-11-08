# Narrative
# --------
# Computing multiple triggers
#
# Extracted from stzregexutertest.ring, block #6.

load "../../stzBase.ring"


pr()

rxu() {
	# Multiple triggers for different patterns

	Trigger(:Number = "(\d+)")
	Trigger(:WordInQuotes = '"([^"]+)"')
	Trigger(:EmailAddr = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})")

	# Different computations for each trigger (with @C as a shorthand for AddComputation()),
	# each a function of the matched value: Haro runs no text as code

	@C( :When = :Number, :Do = func v {
		v = @number(v) * 2
		return v
	})
	
	@C( :When = :WordInQuotes, :Do = func v {
		v = upper(v)
		return v
	})
	
	@C( :When = :EmailAddr, :Do = func v {
		v = "CONTACT: " + v
		return v
	})

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
