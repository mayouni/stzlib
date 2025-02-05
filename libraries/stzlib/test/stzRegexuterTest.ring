
load "../max/stzmax.ring"

/*---

pr()

rx("(\d+)") {

	# Currently we can say()

	? Match("The total was 42 dollars and 13 cents.")
	#--> TRUE

	# What I want is to write

	? @@( AllMatches() )
	#--> [ "42", "13" ]

}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

? @@( Match("The total was 42 dollars and 13 cents.", "(\d+)") )
#--> [ "42", "13" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Processing Numbers in Text
*/
pr()

rxu = rxuter()
rxu {
    # Step 1: Define what pattern should trigger computation
    AddTrigger(:NumberFound = "(\d+)")

    # Step 2: Define what to do when the trigger fires
    AddComputation(
        :When = :NumberFound,
        :Do = "{
            @value = @number(@value)
            @value = @value * 2
        }"
    )

    # Step 3: Process some text to find and compute on matches
    ? @@NL(
        Process(:NumberFound = "The total was 42 dollars and 13 cents.")
    )
    #--> Would show matches [42, 13] and computations [84, 26]
}

proff()

/*--- Finding and Processing Emails

rxu = rxuter()
rxu {
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
        Process(:EmailFound = "Contact us at support@example.com or sales@example.com")
    )
    #--> Would find both emails and extract their domains
}

proff()
