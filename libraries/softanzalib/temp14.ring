load "stzlib.ring"


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
