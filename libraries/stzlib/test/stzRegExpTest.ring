load "../max/stzmax.ring"

/*----

profon()

o1 = new stzRegExpMaker
o1 {
    addCharsRange("A-Z", :repeatedExactly, 2, 0)
    addAmongChars(["-", " "], :repeatedAtMost, 1, 0)
    addDigitsRange("0-9", :repeatedBetween, 1, 3)
    addAmongChars(["-", " "], :repeatedAtMost, 1, 0)
    addCharsRange("A-Z", :repeatedExactly, 2, 0)

    ? getPattern() + NL

    ? getNarration()

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

o1 = new stzRegExpMaker
o1.parsePattern("[A-Z]{2}[- ]?[0-9]{1,3}[- ]?[A-Z]{2}")
? o1.getNarration()

proff()

/*----

profon()
 
o1 = new stzRegExpMaker

# French registration number pattern

o1 {
	addCharsRange("A-Z", :RepeatedExactly, 2, 0)
	addAmongChars("- ", :RepeatedatMost, 1, 0)
	addDigitsRange("0-9", :RepeatedExactly, 3, 0)
	addAmongChars("- ", :RepeatedAtMost, 1, 0)
	addCharsRange("A-Z", :RepeatedExactly, 2, 0)

	? getPattern() + NL
	? getNarration()
}

proff()

/*------------

profon()

o1 = new stzRegExp()
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


/*=====

profon()

o1 = new stzRegExp("[-.a-z0-9]+[@][-.a-z0-9]+[.][a-z]{2,4}")

? o1.IsValid()
#--> TRUE

? o1.Match("kalidianow@gmail.com")
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----
*/
profon()

o1 = new stzRegExp("^(\d\d)/(\d\d)/(\d\d\d\d)$")

? o1.IsValid()
#--> TRUE

? o1.Match("07/01/2025") + NL
#--> TRUE

? o1.Capture()
#--> [ "07", "01", "2025" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22
