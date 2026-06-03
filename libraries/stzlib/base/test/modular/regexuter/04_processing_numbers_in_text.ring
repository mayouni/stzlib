# Narrative
# --------
# Processing Numbers in Text
#
# Extracted from stzregexutertest.ring, block #4.

load "../../../stzBase.ring"


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

pf()
# Executed in 0.02 second(s) in Ring 1.22
