
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

	AddComputation(

		:When = :NumberFound,

		:Do = '{

		@value = @number(@value) * 2

		}'
	)

	# Step 3: Process some text to find and compute on matches

	? @@NL(
		Process("The total was 42 dollars and 13 cents.")
	)
	#--> [
	# 	[ "matches", [ "42", "13" ] ],
	# 	[ "results", [ 84, 26 ] ]
	# ]
}

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Finding and Processing Emails

pr()

rxuter() {

    # Step 1: Watch for email patterns
    AddTrigger(:EmailFound = "(\w+)@(\w+\.\w+)")

    # Step 2: Define how to process found emails
    AddComputation(
        :When = :EmailFound,
        :Do = "{
            @value = StzStringQ(@value).Split('@')[2]
        }"
    )

    # Step 3: Process text containing emails
    ? @@NL(
        Process("Contact us at support@example.com or sales@example.com")
    )
    #--> [
    # 	[ "matches", [ [ "support@example.com", "sales@example.com" ] ] ],
    # 	[ "results", [ "example.com", "example.com" ]
    # ]

}

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Computing multiple triggers

pr()

rxu() {
	# Multiple triggers for different patterns

	Trigger(:Number = "(\d+)")
	Trigger(:WordInQuotes = '"([^"]+)"')
	Trigger(:EmailAddr = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})")

	# Different computations for each trigger (with @C as a shorthand for AddComputation())

	@C(
		:When = :Number,
		:Do = '{
			@value = @number(@value) * 2
		}'
	)
	
	@C(
		:When = :WordInQuotes,
		:Do = '{
			@value = upper(@value)
		}'
	)
	
	@C(
		:When = :EmailAddr,
		:Do = '{
			@value = "CONTACT: " + @value
		}'
	)


	# Feeding the Regexuter with a string to process it by
	# firing the triggers and executing their computations

	? @@NL(
		Process('Contact "john doe" at john@example.com or
			call 555123 for a "quick response"')
	)
	#--> [
	# [ "matches", [ [ "555123" ], [ '"john doe"', '"quick response"' ], [ "john@example.com" ] ] ],
	# [ "results", [ 1110246, '"JOHN DOE"', '"QUICK RESPONSE"', "CONTACT: john@example.com" ] ]
	# ]
}

proff()
#--> Executed in 0.10 second(s) in Ring 1.22

/*---
*/
pr()

rxu() {
    # Define sensitive data pattern processor
    Trigger(:SensitiveData = "(password|secret|key):\s*(\w+)")
    
    # Define transformation with logging
    @C(:When = :SensitiveData, :Do = '{
        originalLength = len(@value)
        @value = "REDACTED-" + originalLength
    }')

    # Process sensitive content
    result = Process("User credentials: password: abc123 secret: def456")
    
    ? @@(result) + NL
    #--> [
    # 	[ "matches", [ [ "password: abc123", "secret: def456" ] ] ],
    # 	[ "results", [ "REDACTED-16", "REDACTED-14" ] ]
    # ]
    

    ? @@NL(State())
    #--> [
    #      [:sensitiviedata, [
    #          "password: abc123", 
    #          "REDACTED-13", 
    #          { 
    #            redactionTimestamp: "2024-02-06T12:34:56",
    #            originalType: "password",
    #            lengthPreserved: true
    #          }
    #      ]],
    #      [:sensitiviedata, [
    #          "secret: def456", 
    #          "REDACTED-12",
    #          { 
    #            redactionTimestamp: "2024-02-06T12:34:56",
    #            originalType: "secret", 
    #            lengthPreserved: true
    #          }
    #      ]]
    #    ]
}

proff()
