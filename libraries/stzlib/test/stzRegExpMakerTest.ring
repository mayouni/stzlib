load "../max/stzmax.ring"

/*----

profon()

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
# Executed in 0.02 second(s) in Ring 1.22

/*----

*/
profon()

o1 = new stzRegExpMaker
o1 {
	# Sequence 1
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Sequence 2
	AddAmongChars(	"- ", 	    :RepeatedAtMost, 1, :Time)

	# Sequence 3
	AddDigitsRange(	"0-9", 	    :RepeatedBetween, 1, :And = [3, :Times])

	# Sequence 4
	AddAmongChars(	["-", " "], :RepeatedAtMost, 1, :Time)

	# Sequence 5
	AddCharsRange(	"A-Z", 	    :RepeatedExactly, 2, :Times)

	# Get the constructed pattern
	? Pattern() + NL

	# Get a narration that explains the pattern
	? Explain()
}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*------------

profon()

o1 = new stzRegExpMaker()
o1 {

	# Designing the pattern in a natural style:

		# Sequence 1:
		CanContainACharBetween("A", :And = "Z", :RepeatedExactly = 2Times())
	
		# Sequence 2:
		CanContainAChar(:Among = [ "-", " " ], :RepeatdAtMost = 1Time())
	
		# Sequence 3:
		CanContainADigit(:From = [ "0", :To = "9"], :RepeatedExactly = 3Times())
	
		# Sequence 4:
		RepeatSequence(2)
	
		# Sequence 5
		RepeatSequence(1)

		CanContainADigit(:From = [ "0", :To = "9"], :RepeatedBetween = [ 2, :To = 3Times() ])

	# Math the pattern

		? Match("your pattern here")
		#--> TRUE

	# Check the pattern in many ways

		? Pattern()

		? Narration()

		? Sequences()

		? SequencesXT()

		? SequenceXT(3)

	
}

proff()


/*---- Should use stzRegExpParser in the background

profon()

o1 = new stzRegExpMaker
o1.parsePattern("[A-Z]{2}[- ]?[0-9]{1,3}[- ]?[A-Z]{2}")
? o1.getNarration()

proff()
