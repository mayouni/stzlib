load "stzlib.ring"

/*----------------

# The @ symbol when used after _(v) elevates the v value ti its
# corresponding softanza object (stzNumber, stzString, stzList,
# or stzObject) so it is possible to chain other methods on it

? _("sun").@.DataType()	# --> "STRING"
? _(1250).@.DataType()	# --> "NUMBER"
? _([1,2]).@.DataType()	# --> "LIST"

obj = new Person { name = "moon" }
? _(obj).@.DataType()	# --> "OBJECT"

class Person Name

/*----------------

# Lerrers are not casesensitive, so x and X refer both to the letter X

? Letter("x") # --> "X"	( x in uppercased!)
? ListOfLetters([ "x", "Z", "Y" ]) # [ "X", "Z", "Y" ]

/*----------------
# All these retrun TRUE
*/
? _(["A","B","C"]).Is( :List )._
? _(["A","B","C"]).Is( ["A","B","C"] )._

? _(["A","B","C"]).Is( List(["A","B","C"]) )._
? _(["A","B","C"]).Is( ListOfStrings(["A","B","C"]) )._
? _(["A","B","C"]).Is( ListOfChars(["A","B","C"]) )._

? _(["A","b","C"]).Is( ListOfLetters(["A","B","C"]) )._	
/*
? _(["A","B","C"]).Is( :ListOfStrings )._
? _(["A","B","C"]).Is( :ListOfChars )._
? _(["A","B","C"]).Is( :ListOfLetters )._

? _(["A","B","C"]).Is( [ :ListOfStrings, :ListOfChars, :ListOfLetters ] ).AtTheSameTime._

/*-----------------

? _("one")._	# Returns the string one
? _("one")._@	# Returns the string one in a computable form => "one"
? _("one").@.ExistsIn([ "one", "two", "three" ]) # Returns TRUE
? _([ :name = "Ring", :age = "7" ]).@.IsHashlist() # Returns TRUE
# TODO: manage the case of objects

/*-----------------

# All these retrun TRUE

? _("G").IsAn(:Uppercase)._
? _(5).IsA(:Number)._
? _([]).IsA(:List)._
? _("G").IsA(:Letter)._
? _(5).IsA(:Number)._

/*-----------------

# All these return TRUE

? _("H").Is('LetterOf("HUSSEIN")')._
? _("H").Is('CharOf("HUSSEIN")')._

? _("H").IsA('LetterOf("HUSSEIN")')._
? _("H").IsA('CharOf("HUSSEIN")')._

/*-----------------

# All these return TRUE

? _("H").IsAn(:Uppercase)._
? _(5).Is(:Number)._
? _("5").Is(:NumberInString)._

/*-----------------

# Showcasing the speciefic semantic meaning of IsA()

? _("H").IsA('LetterOf("HUSSEIN")')._	# TRUE, because there are letters other than H
? _("H").IsA('LetterOf("--H--")')._ 	# FALSE, because H is is the only letter

? _("H").IsA('LetterOf(["A", "B", "H" ])')._ # TRUE
? _("H").IsA('LetterOf(["-", "-", "H" , "_" ])')._ # FALSE

? _(5).IsA('NumberOf( [ 2, "4", 5 ] )')._ # TRUE, because there is a number other than 5
? _(5).IsA('NumberOf( [ "2", "4", 5 ] )')._ # FALSE, because 5 is the only number

/*-----------------
//////////////////////////////////////////////////

# Showcasing the speciefic semantic meaning of IsThe()

# When we write the 2 following statements we get TRUE:
? _("H").Is('LetterOf("HUSSEIN")')._ 	# TRUE
? _("H").IsA('LetterOf("HUSSEIN")')._	# TRUE

# But if we use IsThe() instead we get FALSE
? _("H").IsThe('LetterOf("HUSSEIN")')._	# FALSE
# That's because H is not the only letter of the string HUSSEIN!

# In fact, IsThe() returns TRUE in a string made of many chars
# but containing only one letter:
? _("H").IsThe('LetterOf("-->H<--")')._	# TRUE

# To be more precise, use IsTheOnly(), which is an alternative
# name of IsThe(), like this:
? _("H").IsTheOnly('LetterOf("-->H<--")')._	# TRUE

# By analogy to this, IsA() return TRUE when the value
# is one among other (not unique):
? _("H").IsA('LetterOf("HUSSEIN")')._	# TRUE
# In fact, H is just a letter among others in HUSSEIN

# Therefore, if we say:
? _("H").IsA('LetterOf("-->H<--")')._	# FALSE
# then we get FALSE, because there are no other letters
# than H in the string -->H<--

# To be more eloquent, we can decorate our statement at the end
# with AmongOthers and say:
? _("H").IsA('LetterOf("HUSSEIN")').AmongOthers._

/*-----------------

# Both return TRUE

? _("H").IsThe( FirstLetterOf("HUSSEIN") )._
? _("N").IsThe( LastLetterOf("HUSSEIN") )._

/*----------

# Both return TRUE
? _("H").IsThe( FirstLetterOf("HUSSEIN") )._ # TRUE
? _("h").IsThe( FirstLetterOf("HUSSEIN") )._ # TRUE ------> FIX ERROR

/*----------

? _("H").IsThe( FirstItemIn([ "H", 3, 9 ])._ # TRUE ------> TODO

? _("H").IsThe( FirstLetterIn([ "H", 3, "B" ])._ # TRUE ------> TODO
? _("H").IsThe( FirstLetterIn([ "H", 3, 9 ])._ # TRUE ------> FALSE (because H is the unique letter there)

/*----------

? _("H").IsThe( _(1).st( LetterIn("HUSSEIN") )._ # TRUE ------> TODO
? _("H").IsThe( _(2).nd( LetterIn([ "V", 3, "H" ]) )._ # TRUE ------> TODO

/*----------

? _(10).IsThe( DoubleOf(5) )._		# TRUE
#? _(10).IsNotThe( DoubleOf(7) )._	# TRUE	 ------> FIX ERROR
#? _(10).IsNotThe( DoubleOf(5) )._	# FALSE	 ------> FIX ERROR

/*----------

# The following returns the entire object (stzNumber) related to the value 10
# provided in the beginning of the chain
? _(10).IsThe( DoubleOf(5) ).@

# Therefore, any feature of stzNumber can be chained:
? _(10).IsThe( DoubleOf(5) ).@.ToHexForm()	# Returns 0xA

# The following returns 10, which is what we should expect,
# becuse 10 is the computable form of number 10
? _(10).IsThe( DoubleOf(5) )._@

/*----------

# Both return TRUE

? _("A").IsNotThe( UppercaseOf("b") )._		# TRUE	 ------> FIX ERROR
? _("I").IsNotThe( FirstLetterOf("HUSSEIN") )._	# TRUE	 ------> FIX ERROR

/*-----------------

# Returning the 1st letter in a string 
? _(1).st(' LetterOf("HUSSEIN") ')._	# --> H

# Returning the value in its computable form
? _(1).st(' LetterOf("HUSSEIN") ')._@ 	# --> "H"

/*-----------------

# Returning the 7th letter in a string 
?  _(7).th('LetterOf("HUSSEIN")')._	# --> N

# Using this in a more elaborated expression
? _("N").IsThe( _(7).th('LetterOf("HUSSEIN")')._ )._	# --> TRUE
? _("H").IsThe( _(1).st('LetterOf("HUSSEIN")')._ )._	# --> TRUE

/*-----------------

# Which is equivalent to:
? _("N").IsThe( Letter("N") )._	# TRUE
? _("N").IsThe( Letter("n") )._	# TRUE	 ------> FIX ERROR
? _("n").IsThe( Letter("N") )._	# TRUE	 ------> FIX ERROR

? _("N").IsThe( LatinLetter("N") )._ # TRUE
? _("N").IsThe( LatinLetter("n") )._ # TRUE ------> FIX ERROR

/*-----------------

# By analogy, we can say:
? _("Ⅲ").IsThe( RomanNumber("Ⅲ") )._ # TRUE

/*-----------------

c = "و"
? _(c).IsThe( ArabicLetter(c) )._

? _("و").IsThe( ArabicLetter("و") )._

/*-----------------

? _(6).IsThe( Number(6) )._ # TRUE
? _(6).IsThe( 6 )._  # TRUE

/*-----------------

? _(6).Is(6)._	# TRUE
? _("Ring").Is("Ring")._ # TRUE

/*-----------------

? _(6).IsThe( DoubleOf(3) )._
? _(6).IsThe( NumberOfCharsIn("ABCDEF") )._

/*-----------------

AgeOf = [ :Teeba = 10, :Haneen = 8, :Cherihen = 36, :Mansour = 45 ]
? _(8).IsThe( AgeOf[:Haneen] )._ # TRUE

/*-----------------

# All these return TRUE

? _(6).Is( :Number )._

? _(6).IsA(:Number)._
? _(6).@.IsANumber()

? _("Ring").IsA("Ring")._

/*-----------------

# All these return TRUE

? _("Ring").IsThe( "Ring" )._
? _("Ring").IsThe( String("Ring") )._
? _("Ring").IsThe( Word("Ring") )._

? _("Ring is wonderful language!").IsThe( Text("Ring is wonderful language!") )._

cRingInArabic = "خاتم"
? _(cRingInArabic).IsThe( ArabicWord(cRingInArabic) )._

/*-----------------

? _("meem").IsThe( LowercaseOf("MEEM") )._	# TRUE

/*----------------------------------------

? _(1).st(' LetterOf("HUSSEIN") ')._	# --> H
? _(1).st(' LetterIn("HUSSEIN") ')._	# --> H
? _(2).nd(' LetterOf("HUSSEIN") ')._	# --> U
? _(3).rd(' LetterOf("HUSSEIN") ')._	# --> S
? _(4).th(' LetterOf("HUSSEIN") ')._	# --> S
? _(5).th(' LetterOf("HUSSEIN") ')._	# --> E

/*-----------------

? _(21).st(' CharOf("123456789012345678901") ')._	# --> 1
? _(12).th(' CharOf("123456789012345678901") ')._	# --> 2
? _(13).th(' CharOf("123456789012345678901") ')._	# --> 3

/*-----------------

# Looping over the chars of the word "HUSSEIN"

for i = 1 to 7
	? _(i).nth(' LetterOf("HUSSEIN") ')._
next i

/*-----------------
///////////////////////// TODO
? _("S").Happens(:Twice).In("HUSSEIN")._
? _("S").Happens(_(2).Times).In("HUSSEIN")._
? _("H").HappensOnly(_(1).Time).In("HUSSEIN")._

/*----------------- ERROR

? _("S").IsAn('ItemOf(["S", "A", "M", "B", "A"])')._

/*-----------------

MyFamily = ["Mansour", "Sherihen", "Tiba", "Hanine", "Hussein"]
? _("Sherihen").IsA('MemberOf(MyFamily)')._	# TRUE

/*-----------------

# In natural-coding, 'Mansour' is a symbol for something or
# somebody called 'Mansour'.

# Hence, it's obvious to say
? _("Mansour").Is("Mansour")._ # and get TRUE

# The same thing happens when we say (in Upper "M" then in lower "m")
? _("Mansour").Is("mansour")._ # --> TRUE

# NOTE that, from computational point of view, "Mansour" is different
# from "mansour", but in natural-coding they actually refer to the same
# symbol (the person "Mansour").

# Simply put, whatever you write to call the person Mansour (by writing
# "Mansour", "MANSOUR", "mansour", etc.), he is still the person Mansour!

? _("mansour").Is("MANSOUR")._

/*-----------------

# In this example, we show the beauty of using natural-coding
# with a good data-structure naming

# Let

@ = [
	:Me = :Mansour,
	:MyFriend = :Mahmoud,
	:MyProgrammingLanguage = :Ring,
	:CreatorOfRing = :Mahmoud
]

# Then all these statements return TRUE

? _(:Mansour).Is(@[ :Me ])._	# --> TRUE

? _(:Ring).Is(@[ :MyProgrammingLanguage ])._
? _(:Mahmoud).Is(@[ :MyFriend ]).AndThe(@[ :CreatorOfRing ])._

# Or if you like sutch a semantic enhancement at the end of the sentence
? _(:Mahmoud).Is(@[ :MyFriend ]).AndThe(@[ :CreatorOfRing ]).AtTheSameTime._

/*----------------------
/*----------------------
/*----------------------

# More interestingly, we can define the symbol ourselves like this:


# Transforming the value :Apple to an entity (stzEntity)
_(:Apple)._@( [
	:Type = :Company,
	:Domain = :Technology,
	:Founder = [ :Jobs, :Wosniack ]
])

_(:Apple)._@( [
	:Type = :Fruit,
	:Color = [ :Green, :Red ]
])

_(:Jobs)._@( [
	:Type = :Person,
	:Domain = :Technology
])


for aEntity in $oWorldEntities.Entities()
	for aProp in aEntity
		? aProp[1] + ": " + ComputableForm(aProp[2])
	next
	? ""
next

# and then use a statement like this
_(:Jobs).IsThe(:Founder).Of(:Apple)._

