load "stzlib.ring"

/*---------------

o1 = new stzString("123456789")
o1.InsertBefore(4, "*")
? o1.Content() #--> "123*456789

o1 = new stzString("123456789")
o1.InsertBefore(12, "*")
? o1.Content() #--> 123456789  * (The string is extended with blank spaces! Qt behaviour?)

o1 = new stzString("123456789")
o1.InsertAfter(4, "*")
? o1.Content() #--> 1234*56789

o1 = new stzString("123456789")
o1.InsertAfter(12, "*")
? o1.Content() #--> 123456789   * (The string is extended with blank spaces! Qt behaviour?)

/*---------------

o1 = new stzString("123456789")
o1.InsertAfterThesePositions([] , "*")
? o1.Content() #--> 123456789 (Nothing is inserted!)

o1 = new stzString("123456789")
o1.InsertAfterThesePositions([3, 5, 8] , "*")
? o1.Content() #--> 123*45*678*9

o1 = new stzString("123456789")
o1.InsertBeforeThesePositions([3, 5, 8] , "*")
? o1.Content() #--> 12*34*567*89

o1 = new stzString("123456789")
o1.InsertBeforeW('StzNumberQ(@char).IsEven()' , "*")
? o1.Content() #--> 1*23*45*67*89

o1 = new stzString("123456789")
o1.InsertAfterW('StzNumberQ(@char).IsEven()' , "*")
? o1.Content() #--> 12*34*56*78*9

/*---------------

o1 = new stzString("RINGORIALAND")
o1.InsertAfterW(' @i = 8 ', " ")
? o1.Content() #--> RINGORIA LAND

o1 = new stzString("RINGORIALAND")
o1.InsertAfterW('@i = Previous@i + 1', " ")
? o1.Content() #--> R I N G O R I A L A N D

/*===============

o1 = new stzString("RINGORIALAND")
o1.Spacify()
? o1.Content() #--> R I N G O R I A L A N D

o1 = new stzString("RIN   GOR   IALAN  D")
o1.Spacify()
? o1.Content() #--> R I N G O R I A L A N D

/*===============
*/
o1 = new stzString("aaa;bbb;ccc;ddd")
? o1.Split( :Using = ";")

/*===============

# As a string, this is not empty: it's filled with blank spaces!
? StzStringQ("   ").IsEmpty() #--> FALSE

# But as a text, this is empty, since it contains nothing meaningful:
? StzTextQ("   ").IsEmpty() #--> TRUE

/*========

o1 = new stzString("aaaAAARing")
o1.ReplaceThisRepeatedLeadingCharCS("a", :With = "o", :CaseSensitive = TRUE)
? o1.Content() #--> oooAAARing

/*----------

o1 = new stzString("aaaAAARing")
? o1.NumberOfLeadingChars() #-->
? o1.LeadingChars() #--> aaa

? o1.NumberOfLeadingCharsCS(:CaseSensitive = FALSE) #--> 6
? o1.LeadingCharsCS(:CS = FALSE) #--> aaaAAA

/*----------

o1 = new stzString("aaaAAAH RING!")
o1.ReplaceLeadingCharsCS(:With = "O", :CS = TRUE)
? o1.Content() #--> OOOAAAH RING!

o1 = new stzString("aaaAAAH RING!")
o1.ReplaceLeadingCharsCS(:With = "O", :CS = FALSE)
? o1.Content() #--> OOOOOOH RING!

/*----------

o1 = new stzString("RINGaaaAAA")
o1.ReplaceTrailingCharsCS( :With = "O", :CS = TRUE)
? o1.Content()
#--> Gives: "RINGaaaOOO"

o1 = new stzString("RINGaaaAAA")
o1.ReplaceTrailingCharsCS( :With = "O", :CS = FALSE)
? o1.Content()
#--> Gives: "RINGOOOOOO"

/*-----------

o1 = new stzString("aaaAAARING!")
o1.ReplaceThisLeadingCharCS( "a", :With = "O", :CS = TRUE)
? o1.Content()
#--> Gives: "RINGaaaOOO"

/*------------

o1 = new stzString("♥Ring♥AAAaaa")
o1.RemoveThisTrailingCharCS("a", :CaseSensitive = TRUE)
? o1.Content() #--> ♥Ring♥AAA

o1 = new stzString("♥Ring♥AAAaaa")
o1.RemoveThisTrailingCharCS("a", :CaseSensitive = FALSE)
? o1.Content() #--> ♥Ring♥

/*-----------

o1 = new stzString("aaaAAA♥Ring♥")
o1.RemoveThisLeadingCharCS("a", :CaseSensitive = TRUE)
? o1.Content() #--> AAA♥Ring♥

o1 = new stzString("aaaAAA♥Ring♥")
o1.RemoveThisLeadingCharCS("a", :CaseSensitive = FALSE)
? o1.Content() #--> ♥Ring♥

/*-----------

o1 = new stzString("aaaAAAI ♥ Ring!AAAaaa")
o1.RemoveTheseLeadingAndTrailingCharsCS( "a", "a", :CS = TRUE)
? o1.Content()
#--> Gives: "AAAI ♥ Ring!AAA"

o1 = new stzString("aaaAAAI ♥ Ring!AAAaaa")
o1.RemoveTheseLeadingAndTrailingCharsCS( "a", "a", :CS = FALSE)
? o1.Content()
#--> Gives: "I ♥ Ring!"

/*----------

StzStringQ("   clean code        ") {
	? @@( RepeatedLeadingChars() ) #--> "   "
	
	? @@( RepeatedLeadingChar() ) #--> " "
	
	RemoveThisRepeatedLeadingChar(" ")
	? @@( Content() ) #--> "clean code        "
	
	RemoveThisRepeatedTrailingChar(" ")
	? @@( Content() ) #--> "clean code"
}

/*----------

StzStringQ("   clean code        ") {
	RemoveLeadingSpaces()
	? @@( Content() ) #--> "clean code        "

	RemoveTrailingSpaces()
	? @@( Content() ) #--> "clean code"
}

/*----------

# The VizFindXT function accepts these options

# 	:CaseSensitive	= TRUE or FALSE
#	--> TRUE by default (you can use the short form :CS)

#	:PositionChar	= any char indicating the found positions
#	--> "^" by default

#	:BlankChar	= any char different to :PositionChar
#	--> "-" by default

#	:Numbered	= The found chars are labeled with their positions
#	--> FALSE by default

#	:Spacified	= The string is enlarged by inserting a space after each char
#	--> FALSE by default

#	:Boxed		= TRUE or FALSE
#	--> FALSE by default

#	:BoxOptions	= Any options onforming to IsBoxParamList()
#	--> Works only if :Boxed = TRUE

o1 = new stzString("RINGoriaLAND")
? o1.VizFindXT("I", []) + NL

#-->
# 'RINGoriaLAND"
#  -^----------

? o1.VizFindXT("I", [ :CaseSensitive = FALSE ]) + NL
# 'RINGoriaLAND"
#  -^----^-----

? o1.VizFindXT("I", [ :CS = FALSE, :Numbered = TRUE ]) + NL
# 'RINGoriaLAND"
#  -^----^-----
#   2    7    

? o1.VizFindXT("I", [ :CS = FALSE, :Numbered = TRUE, :Spacified = TRUE ]) + NL
# 'R I N G o r i a L A N D"
#  --^---------^----------
#    2         7      

? o1.VizFindXT("I", [
	:CS = FALSE, :Numbered = TRUE, :Spacified = TRUE,
	:BlankSign = ".", :PositionSign = "♥" ])

#-->
# "R I N G o r i a L A N D"
#  ..♥.........♥..........
#    2         7      

/*-------------

"R I N G o r i a L A N D"
 --[   ]-----[   ]------
   2   6     8   2
/*-------------------- TODO

o1 = new stzString("RINGing")
? o1.VizFindXT("I", [ :Boxed = TRUE ])

/*--------------------

StzStringQ("RINGing") {

	? BoxedRound()
	? EachCharBoxedRound()

	? VizFind("I")
//	? VizFindCS("I", :CS = FALSE)
	//? VizFindAll("I")
}

/*----------------
*
StzStringQ("PARIS") {
	LeftAlign(15, "-")
	? Content() #--> PARIS----------
}

StzStringQ("PARIS") {
	RightAlign(15, "-")
	? Content() #--> ----------PARIS
}

StzStringQ("PARIS") {
	CenterAlign(15, "-")
	? Content() #--> -----PARIS-----
}

StzStringQ("PARIS") {
	Justify(15, "-")
	? Content() #--> P---A---R--I--S
}

/*------------------------ TODO

o1 = new stzString("In these days, to be happy is a real challenge!
 I'm not sure how problems will leave us a window for this.
 Fortunately, hope will continue to be there.
 Quiet difficult but not impossible.")

? @@(o1.ToStzText().RemovePunctuationQ().

		LowercaseQ().
		SplitQR(" ", :stzListOfStrings).

		YieldQ('[ @str, Sentiment(@str) ]').
		RemoveDuplicatesQ().
		ToStzHashList().Classify() ) # ===> Dbug stzHashList.Classify()

//		Classify() )




//		ClassesAndTheirFrequencies()

//		DominantClass()
//		WeakestClass()

#--> [
# 	:Positive = 0.32
# 	:Neutral  = 0.16
# 	:Negative = 0.52
#    ]


func Sentiment(pcWord)
	# EXAMLE

	# ? Sentiment(:glad) 	#--> :Positive
	# ? Sentiment(:quiet) 	#--> :Neutral
	# ? Sentiment(:problem) 	#--> :Negative

	

	oHashList = new stzHashList([
		:Positive = [
			:happy, :nice, :glad, :beautiful, :wonderful,
			:fortunately, :hope, :sure, :continue ],

		:Neutral = [
			:in, :to, :be, :a, :is, :will, :can, :some,
			:these, :days, :quiet, :real, :us, :window,
			:for, :this, :there, :but
		],

		:Negative = [
			:no, :not, :must, :difficult, :problem, :leave,
			:impossible
		]
	])

	return oHashList.KeyByValueInList(pcWord)

