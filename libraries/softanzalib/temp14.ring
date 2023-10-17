load "stzlib.ring"

/*---------

pron()

? HexPrefix()
#--> Ox

? Q( HexPrefix() + '066E').RepresentsNumberInHexForm()
#--> TRUE

? Q('U+066E').RepresentsNumberInUnicodeHexForm()
#--> TRUE

proff()

/*---------
*/
pron()

/*
U+066E ARABIC LETTER DOTLESS BEH
U+066F ARABIC LETTER DOTLESS QAF
U+06A1 ARABIC LETTER DOTLESS FEH
U+06BA ARABIC LETTER NOON GHUNNA

TODO Add these functions:

? ArabicDottlessLetters()

? ArabicDottlessLettersUnicodes()

? ArabicDottlessLettersAndTheirUnicodes()

? ArabicDottlessLettersXT() # ArabicDotllessAnsTheirDottlessLetters()
? ArabicDottedAndTheirDottlessLetters()
*/

StzCharQ('U+066E') {
	? Content() 	#--> ٮ
	? Name()	#--> ARABIC LETTER DOTLESS BEH
	? Unicode()	#--> 1646
}

StzCharQ('U+066F') {
	? Content() 	#--> ٯ
	? Name()	#--> ARABIC LETTER DOTLESS QAF
	? Unicode()	#--> 1647
}

StzCharQ('U+06A1') {
	? Content() 	#--> ڡ
	? Name()	#--> ARABIC LETTER DOTLESS FEH
	? Unicode()	#--> 1697
}

StzCharQ('U+06BA') {
	? Content() 	#--> ں
	? Name()	#--> ARABIC LETTER DOTLESS NOON GHUNNA
	? Unicode()	#--> 1722
}

#--> ARABIC LETTER DOTLESS BEH


proff()

/*--------

cName = "Gary"

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> It's been a real pleasure meeting you, Gary!

/*=====

pron()

? Q([ "a", "b", "c" ]).IsListOfChars()
#--> TRUE

? Q([ 1, 2, 3 ]).IsListOfChars()
#--> TRUE

proff()

/*------

pron()

? Q(1:3).Unicodes()
#--> [1, 2, 3]

? Unicodes([2, 3])
#--> [2, 3]

? Unicodes([ "a", "b", "c" ])
#--> [97, 98, 99]

? @@( Unicodes([ "How", "are", "you?" ]) )
#--> [ [ 72, 111, 119 ], [ 97, 114, 101 ], [ 121, 111, 117, 63 ] ]

? @@( Unicodes([ "A", "HI", [ 1, 2 ] ]) )
#--> [ 65, [ 72, 73 ], [ 1, 2 ] ]

? @@( Unicodes([ "a", [ 1, ["b","c"], 2], "d" ]) )
#--> [ 97, [ 1, [ 98, 99 ], 2 ], 100 ]

? @@( Unicodes([ "a", [ 1, ["b", [ "ring" ] ], 2 ], "d" ]) )
#--> [ 97, [ 1, [ 98, [ [ 114, 105, 110, 103 ] ] ], 2 ], 100 ]


proff()

/*========

# TODO: Add TurnUp, TurnDown, Turn, IsTurnedUp, IsTurnedDown
# here in stzChar then in stzString

*/
pron()
/*
#-- TURNABLE NUMBERS

? @@(TurnableNumbers())
#--> [ 2, 3 ]

? @@(TurnableNumbersUnicodes())
#--> [ 2, 3 ]

? @@(TurnableNumbersXT()) # NOTE: Font in Notepad may not show the turned numbers
#--> [ [ 2, "↊" ], [ 3, "↋" ] ]

#-- TURNED NUMBERS

? @@(TurnedNumbersUnicodes())
#--> [ 8586, 8587 ]

? @@(TurnedNumbers()) # NOTE: Idem
#--> [ "↊", "↋" ]

? @@( Q([ "↊", "↋" ]).Names() )
#--> [ "TURNED DIGIT TWO", "TURNED DIGIT THREE" ]

? @@(TurnedNumbersXT()) # Or TurnedNumberAndTheirUnicodes()
#--> [ [ "↊", 8586 ], [ "↋", 8587 ] ]
*/
#-- TURNABLE CHARS

//? HowManyTurnableChars() + NL
//? @@( TurnableChars() ) + NL

//? HowManyTurnableUnicodes() + NL
//? @@( TurnableUnicodes() )

? @@S( TurnableUnicodesXT()) # Or ShowShort()
#--> [
#	[ 36, "$" ], [ 38, "&" ], [ 40, "(" ], "...",
#	[ 43843, "ꭃ" ], [ 43856, "ꭐ" ], [ 43857, "ꭑ" ] ]
# ]



//? @@( TurnableAndTurnedChars() )
#-- TURNED CHARS

//TurnedUnicodes()
//TurnedChars()
//TurnedCharsXT()

proff()

/*-------

pron()

o1 = new stzChar("M")
? o1.Reverted()
#--> Ɯ

o1 = new stzChar("Ɯ")
? o1.Reverted()
#--> M

proff()

/*---

pron()

o1 = new stzChar("Ɯ")
? o1.IsTurned()
#--> TRUE

? o1.IsTurnable()
#--> TRUE

#--

o1 = new stzChar("M")
? o1.IsTurned()
#--> FALSE

? o1.IsTurnable()
#--> TRUE

proff()

/*=====
*/
pron()

? Q("ƎℲI⅂").IsTurned()
/*
# First, this is your name, nicely printed in a rounded box

? Q("GARY").EachCharBoxedRound()
#--> ╭───┬───┬───┬───╮
#    │ G │ A │ R │ Y │
#    ╰───┴───┴───┴───╯

# Now, look to these two examples and try to tell me what
# the difference between Inverse() and Invert() in Softanza:

? Q("GARY").Inversed() # Inverses the order of chars
#--> YRAG

? Q("GARY").Inverted() # Turns the chars down
#--> ⅁ⱯR⅄

# Feels a bit confusing? I understand, and I provide you
# with more clarity using these alternatives:

? Q("GARY").CharsOrderInversed()
#--> YRAG

? Q("GARY").CharsTurnedDown()
#--> ⅁ⱯR⅄

proff()

/*-----

pron()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsXT( "♥", :InSection = [3, 10] )
#-- TRUE

? o1.ContainsXT( "♥", :InSections = [ [3,10], [8,12], [14,19] ] )
#--> TRUE

proff()
# Executed in 0.10 second(s)

/*-----

pron()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsInSection("♥", 3, 10)
#--> TRUE

? o1.ContainsInSections("♥", [ [3,10], [8,12], [14,19] ])
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*-----

pron()

? Q([ "a", "♥", "*" ]).ContainsThese([ "♥", "*"])
#--> TRUE

o1 = new stzList([ [ "a", "♥", "*" ], [ "♥", "*"], [ "a", "b", "♥", "*" ] ])
? o1.EachContainsThese([ "♥", "*" ])
#--> TRUE

proff()

/*-----

pron()

o1 = new stzList([ "ee♥ee", "b♥bbb", "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ ["ee","♥","ee"], ["♥", "bb"], "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ "a♥a" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ 0, "a♥a" ])
? o1.EachContains("♥")
#--> FALSE

proff()


/*-----

pron()

# Hi Irwin, Softanza made this for you:

Q("Thank you Irwin Rodriguez!") {

	# Your name is uppercased
	UppercaseSubString("Irwin")

	# Then it's decoraded with hearts
	AddXT( 2Hearts(), :Around = "IRWIN" )

	# And finally it's nicely boxed
	? BoxedRound()

	# Thank you for your trust!
}

#--> ╭────────────────────────────────╮
#    │ Thank you ♥♥IRWIN♥♥ Rodriguez! │
#    ╰────────────────────────────────╯

proff()
#--> Executed in 0.14 second(s)

/*--------

pron()

? Digits()
#--> [0, 1, 2, 3, 4, 5, 6, 7, 8 , 9 ]

? Q(5).IsADigit() # In this case, Q() transforms 5 to a stzNumber object
#--> TRUE

? Q("3").IsADigitInString() # In this case, Q() transforms 5 to a stzString object
#--> TRUE

? Q("").IsADigitInString() # Idem
#--> FALSE

? Q("125").IsADigitInString() # Idem
#--> FALSE

? QQ("3").IsADigit() #  In this case, QQ() transforms "3" to a stzChar object
#--> TRUE

proff()
# Executed in 0.13 second(s)

/*--------

pron()

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection = [10, 13],
	:Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)

#--> [ "<<", ">>>" ]

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzString("what a <<nice>>> day!")
? o1.SectionBounds(10, 13, 2, 3)
#--> [ "<<", ">>>" ]

? o1.SectionBoundsIB(9, 14, 2, 3)
#--> [ "<<", ">>>" ]

#--

? @@( o1.SectionBoundsZ(10, 13, 2, 3) )
#--> [ [ "<<", 8 ], [ ">>>", 14 ] ]

? @@( o1.SectionBoundsZZ(10, 13, 2, 3) )
#--> [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ]

#--

? @@( o1.SectionBoundsIBZ(9, 14, 2, 3) )
#--> [ [ "<<", 8 ], [ ">>>", 14 ] ]

? @@( o1.SectionBoundsIBZZ(9, 14, 2, 3) )
#--> [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ]

proff()
# Executed in 0.21 second(s)

/*=======

# Using Section() (or Slice()) to get a part of a list

aList = 1:20

# Verbose form:
? Q(aList).Section(:FromPosition = 4, :To = :LastItem)
#--> 4:20

# Short form:
? Q(1:20).Slice(4, :Last)
#--> 4:20

/*======

Q("PROGRAMMING") {

   ? Boxed()

   ? BoxedRound()

   ? BoxEachChar()

   ? BoxEachCharRound()

}

#-->
# ┌─────────────┐
# │ PROGRAMMING │
# └─────────────┘
# ╭─────────────╮
# │ PROGRAMMING │
# ╰─────────────╯
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ P │ R │ O │ G │ R │ A │ M │ M │ I │ N │ G │
# └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ P │ R │ O │ G │ R │ A │ M │ M │ I │ N │ G │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
