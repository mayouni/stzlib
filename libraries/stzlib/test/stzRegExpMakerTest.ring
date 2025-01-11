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

/*=== Ring number() VS Softanza @Number()

profon()

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
*/
profon()

? IsNumberInString("-12120.5")
#--> TRUE

? IsNumberInString("-12 120.5")
#--> TRUE

? IsNumberInString("-12_120.5")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*===


profon()

o1 = new stzRegExpMaker()
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
	? Explain() + NL

	# Get the pattern structure

	? @@NL( o1.FragmentsXT() )
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
*
profon()

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

o1 = new stzRegExpMaker()
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

	# Checking the constructed pattern:
	#---------------------------------

	? Pattern() + NL
	#--> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}

	# Getting a visual-narrative explanation of the pattern

	? Narration()
	# START
	# │
	# 1─▶ [A-Z]{2} : Can contain a char from A to Z,
	# │              repeated exactly 2 times.
	# │
	# 2─▶ [- ]?    : Can contain a char among [ "-", " " ],
	# │              repeated at most 1 time.
	# │
	# 3─▶ [0-9]{3} : Can contain a char from 0 to 9,
	# │              repeated exactly 3 times.
	# │
	# 4─▶ [- ]?    : Can contain a char among [ "-", " " ],
	# │              repeated at most 1 time.
	# │
	# 5─▶ [A-Z]{2} : Can contain a char from A to Z,
	# │              repeated exactly 2 times.
	# │
	# END

	# Everything has been stored as data for future use

	? @@NL( FragmentsXT() ) + NL // RegExp Fragments and their relative Sequences
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
# Executed in 0.03 second(s) in Ring 1.22


/*---- Should use stzRegExpParser in the background

profon()

o1 = new stzRegExpMaker
o1.parsePattern("[A-Z]{2}[- ]?[0-9]{1,3}[- ]?[A-Z]{2}")
? o1.getNarration()

proff()
