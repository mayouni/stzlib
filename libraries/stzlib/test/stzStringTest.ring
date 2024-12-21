load "../max/stzmax.ring"

/*-----

profon()

? Q("ring programming languge").UrlEncoded()
#--> ring%20programming%20languge

? Q("ring%20programming%20language").UrlDecoded() + NL
#--> ring programming language

? Q('<div class = "article">This is an article</div>').HtmlEscaped()
#--> &lt;div class = &quot;article&quot;&gt;This is an article&lt;/div&gt;

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*=====

profon()

o1 = new stzString("Softanza")
? o1.SizeInBytes()
#--> 435

proff()

/*--- #perf managing a big text

profon()

cBigText = read("../test/bigtext.txt")

oBig = new stzString(cBigText)

? oBig.NumberOfChars()
#--> 6617121

? oBig.NumberOfLines() + NL
#--> 128457

? oBig.SizeInBytes() + NL
#--> 491

? oBig.FindCS("madrid", _FALSE_)
#--> [
#	1538708
#	1543968
#	1544385
#	1546342
#	1550119
#	5270717
#	5621458
#	6590675
# ]

oBig.ReplaceCS("madrid", "Gaza", _FALSE_)

proff()
# Executed in 2.05 second(s) in Ring 1.22

/*==== #todo Write a #narration

profon()

? @N(3, ".")
#--> [ ".", ".", "." ]

? @NXT(3, ".", :InAList)
#--> [ ".", ".", "." ]

? @NXT(3, ".", :InAString) + NL
#--> ...

? Three(".")
#--> [ ".", ".", "." ]

? @3(".")
#--> [ ".", ".", "." ]

#--

? Q([ ".", ".", ".", "Tunis" ]).StartsWith( @3(".") )
#--> TRUE

? Q("...Tunis").StartsWith("...")
#--> TRUE

? Q("...Tunis").StartsWithXT( @3(".") )
#--> TRUE

? Q("..Tunis..").EndsWithXT( @2(".") )
#--> TRUE

? Q("...Tunis..").StartsWithXTQ( @3(".") ).AndQ().EndsWithXT( @2(".") )
#--> TRUE

proff()
# Executed in 0.01 second(s) in Ring 1.22


/*--- #narration XML/HTML tag analysis

profon()

# If you parse this XML snippet with a valid tool, an error will
# be raised. Let's see how Softanza could help in identifying it.

# First, we put the code in an stzString object:

xml = "<product><name>Phone<name></name><price>599</price></product>"
oXML = new stzString(xml)

# Then, we use SubStringsBoundedBy() to get the list of all XML entities
# used within the code (which are bounded by "<" and ">" chars).

# At the same time, we elevate the list to an stzList object using
# the Q() helper function.

# Finally, we use ItemsAndTheirNumberOfOccurrence() on it:

? Q( oXML.SubStringsBoundedBy([ "<", ">" ]) ).
  ItemsAndTheirNumberOfOccurrence()

# And so we get:

#--> [
#	[ "product", 1 ],
#	[ "name", 2 ],		#~> Focus on this line!
#	[ "/name", 1 ],
#	[ "price", 1 ],
#	[ "/price", 1 ],
#	[ "/product", 1 ]
# ]

# All entities should have an equal number of opening and
# closing tags, which is _TRUE_ for all except "name" (look at
# lines 2 and 3 of the list—you'll see 2 versus 1).

# The issue, then, is that we have an additional "<name>" entity
# that we should remove. To fix it, we say:

oXML.RemoveNth(2, "<name>")

# Look at the result:

? oXML.Content()
#--> <product><name>Phone</name><price>599</price></product>

# Now you can feed it back to your XML parser with total peace of mind!

proff()
# Executed in 0.01 second(s).

/*===========

StartProfiler()

? @@( AlignCenter("RING", 15) )
#--> "     RING      "

? @@( AlignLeft("RING", 15) )
#--> "RING           "

? @@( AlignRight("RING", 15) ) + NL
#-->"           RING"


? @@( AlignCenterXT("RING", 15, ".") )
#--> ".....RING......"

? @@( AlignLeftXT("RING", 15, ".") )
#--> "RING..........."

? @@( AlignRightXT("RING", 15, ".") ) + NL
#--> "...........RING"


? @@( AlignXT("RING", 15, "~", :Center) )
#--> "~~~~~RING~~~~~~"

? @@( AlignXT("RING", 15, "~", :Right) )
#--> "~~~~~RING~~~~~~"

? @@( AlignXT("RING", 15, "~", :Left) )
#--> "~~~~~RING~~~~~~"

StopProfiler()
# Executed in 0.03 second(s).

/*====

profon()

cStr = " line1 line1 line1 
line2 line2 line2
line3 line3 line3"

? stzsplit(cStr, NL)
#--> [
#	" line1 line1 line1",
#	"line2 line2 line2",
#	"line3 line3 line3"
# ]

proff()
# Executed in almost 0 second(s).

/*====

profon()

o1 = new stzString("me you all the others")
? o1.ContainsEither("me", :or = "you")
#--> _FALSE_

o1 = new stzString("me and all the others")
? o1.ContainsEither("me", :or = "you")
#--> _TRUE_

proff()
# Executed in 0.01 second(s)

/*----

profon()

o1 = new stzString("me you all the others")
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> _TRUE_
	
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> _FALSE_

o1 = new stzString("me and all the others")
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> _TRUE_

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*===

profon()

? Q("ring").IsReverseOf("gnir")
#--> _TRUE_

? Q(1:3).IsReverseOf(3:1)
#--> _TRUE_

proff()
# Executed in 0.01 second(s)

/*===

profon()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring kandaji")

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥♥♥ csharp ♥ ♥♥♥

proff()
#--> Executed in 0.01 second(s)

/*------

profon()

o1 = new stzString("ring qt softanza pyhton kandaji csharp zai")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥♥

proff()
# Executed in 0.01 second(s)

/*------

profon()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥

proff()
# Executed in 0.01 second(s)

#==== #narration

StartProfiler()

# You can find the positions of any substring occurring between
# two bounds by saying:

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@( o1.FindAnyBoundedBy(["<<",">>"]) )
#--> [7, 20]

# In fact, the substring "ring" occures in position 7 and "php" in position 20.

# Now, if you have the following case where the two bounds are
# the same (equal to "*" here):

o1 = new stzString("*2*45*78*0*")
? @@( o1.FindAnyBoundedBy(["*","*"]) ) # or simply FindAnyBoundedBy("*")
#--> [ 2, 4, 7, 10 ]

# Let's craft a visual explanation of what happened:

	# the positions	:  12345678901
	# the string	: "*2*45*78*0*"
	# the Occurrences:   ^ ^  ^  ^
	#--> [2, 4, 7, 10]


StopProfiler()
# Executed in 0.01 second(s)

/*=======

profon()

o1 = new stzString("12345678")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

proff()
# Executed in 0.01 second(s)

/*--------

profon()

o1 = new stzList(1:8)

? o1.Section(3, 5)
#--> [ 3, 4, 5 ]

? o1.Section(5, 3)
#--> [ 3, 4, 5 ]

proff()
# Executed in 0.01 second(s)

/*=========

profon()

o1 = new stzString("---ring---")

o1.RemoveThisCharFromStartXT("*")
? o1.Content()
#--> "---ring---"

o1.RemoveThisCharFromStartXT("-")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

proff()
# Executed in 0.01 second(s).

/*--------

profon()

o1 = new stzString("ring---")

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

proff()
# Executed in 0.01 second(s).

/*--------

profon()

o1 = new stzString("---ring")

o1.RemoveThisCharFromLeftXT("*")
? o1.Content()
#--> "---ring"

o1.RemoveThisCharFromLeftXT("-")
? o1.Content()
#--> ring

proff()
# Executed in 0.01 second(s).

/*--------

profon()

o1 = new stzString("ring---")

o1.RemoveThisCharFromRightXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromRightXT("-")
? o1.Content()
#--> "ring"

proff()
# Executed in 0.01 second(s).

/*======

profon()

o1 = new stzString("---ring")

? o1.LeftCharRemoved()
#--> --ring

? o1.CharRemovedFromLeft("*")
#--> ---ring

? o1.CharRemovedFromLeft("-")
#--> --ring

? o1.CharRemovedFromLeftXT("*")
#--> ---ring

? o1.CharRemovedFromLeftXT("-")
#--> ring

? o1.CharTrimmedFromLeft("-")
#--> --ring

proff()
# Executed in 0.01 second(s)

/*--------

profon()

o1 = new stzString("ring---")

? o1.RightCharRemoved()
#--> ring--

? o1.CharRemovedFromRight("*")
#--> ring---

? o1.CharRemovedFromRight("-")
#--> ring--

? o1.CharRemovedFromRightXT("*")
#--> ring---

? o1.CharRemovedFromRightXT("-")
#--> ring

? o1.CharTrimmedFromRight("-")
#--> ring--

proff()
# Executed in 0.01 second(s)

/*====

profon()

o1 = new stzString("12.58000")
o1.RemoveThisCharFromRightXT("0") # Or RemoveAnyOccurrenceOfCharFromRight("0")
? o1.Content()
#--> 12.58

proff()
# Executed in 0.01 second(s).

/*===

profon()

o1 = new stzString("00012.58")
o1.RemoveCharFromLeft("0")
? o1.Content()
#--> 0012.58

o1.RemoveCharFromLeftXT("0") # Or o1.RemoveAnyOccurrenceOfCharFromLeft("0")
? o1.Content()
#--> 12.58

proff()
# Executed in 0.01 second(s)

/*========

profon()

? Q("---ring").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharRightSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharRightSide("-")
#--> 3

#--

? Q("---ring").NumberOfOccurrenceOfCharStartSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharEndSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharEndSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharStartSide("-")
# #--> 3

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*==== #narration: eXTended form of RemoveFirstChar()

profon()

# Remove the 7 dashes in front of the word ring

o1 = new stzString("-------Ring")

o1.RemoveFirstChar()
? o1.Content()
#--> ------Ring

# Remove an other one
o1.RemoveFirstChar()
? o1.Content()
#--> -----Ring

# And an other one
o1.RemoveFirstChar()
? o1.Content()
#--> ----Ring

# Tired? Remove them all in one shot using the eXTend form
o1.RemoveFirstCharXT()
? o1.Content()
#--> Ring

#NOTE: we can get the same result by using RemoveLeadingChars()

o1 = new stzString("-------Ring")
o1.RemoveLeadingChars()
? o1.Content()
#--> Ring

proff()
# Executed in 0.02 second(s)

/*-----------

profon()

o1 = new stzString("---Ring---")

o1.RemoveFirstCharXT()
? o1.Content()
#--> Ring---

? o1.RemoveLastCharXT()
? o1.Content()
#--> Ring

proff()
# Executed in 0.01 second(s).

/*-----------

profon()

o1 = new stzString("---Ring---")

o1.RemoveThisFirstCharXT("*")
? o1.Content()
#--> "---Ring---"

? o1.RemoveThisFirstCharXT("-")
? o1.Content()
#--> "Ring---"

o1.RemoveThisLastCharXT("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisLastCharXT("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.02 second(s)

/*=== Section() and CharsInSection()

profon()

# Here, you cen get a section from a string
? Q("---ring---").Section(4, 7)
#--> ring

# And here you get the list of chars of that section
? Q("---ring---").CharsInSection(4, 7)
#--> [ "r", "i", "n", "g" ]

proff()
# Executed in 0.01 second(s)

/*===== LeadingChars() and LeadingCharsAsString()

profon()

o1 = new stzString("---Ring")
? o1.LeadingChars()
#--> [ "-", "-", "-" ]

? o1.LeadingCharsXT() # Or LeadingCharsAsString() or LeadingCharsAsSubString()
#--> "---"

o1 = new stzString("Ring---")
? o1.TrailingChars()
#--> [ "-", "-", "-" ]

? o1.TrailingCharsXT()
#--> "---"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

/*------

profon()

o1 = new stzString("---Ring")

o1.RemoveLeadingChar() # Or RemoveAnyLeadingChar() or RemoveLeadingChars()
? o1.Content()
#--> Ring

o1 = new stzString("Ring---")
o1.RemoveTrailingChar() # Or RemoveAnyTrailingChar() or RemoveTrailingChars()
? o1.Content()
#--> Ring

proff()
# Executed in 0.01 second(s).

/*------

profon()

o1 = new stzString("---Ring")

o1.RemoveThisLeadingChar("*")
? o1.Content()
#--> "---Ring"

o1.RemoveThisLeadingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.02 second(s)

/*------

profon()

o1 = new stzString("Ring---")

o1.RemoveThisTrailingChar("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisTrailingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.05 second(s)

/*====== #narration: Softanza permissiveness

profon()

# Suppose you have a string like this:

o1 = new stzString("rRing")

# And you want to remove the first character:

o1.RemoveFirstChar()
? o1.Content()
#--> Ring

# Now, what if you consider applying case sensitivity here?
# Meaning, you want the removal operation to be case sensitive...

# Actually, this doesn't make much sense, since the first character
# is the first character, regardless of its case!

# However, Softanza doesn't mind and allows you to apply it,
# but completely ignores the case sensitivity parameter:

o1 = new stzString("rRing")
o1.RemoveFirstCharCS(_TRUE_)
? o1.Content()
#--> Ring

# NOTE: This feature is available only for this function
# to demonstrate the principle of PERMISSIVENESS.
#~> It will be generalized in the future.

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.19

/*===

profon()

? HowMany( ArabicLetters() ) # Or HowManyArabicLetters() or NumberOfArabicLetters()
#--> 28

? 10PercentOf( ArabicLetters() ) # Or NPercentOf(10, ArabicLetters())
#o--> [ "ص", "ة", "د", "ص" ]

#NOTE : there is an eXTended list of arabic leters

? HowMany( ArabicLettersXT() )
#--> 34

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19

/*===

profon()

o1 = new stzString( "one two one three two one four five" )

? o1.HowManySubStrings()
#--> 630

? @@( SomeXT( o1.SubStrings(), 1/100 ) ) + NL # 1% of all the substrings
#--> [ " four", "e three two", "hree t", "one th", "one three two o", "th", "wo on" ]

# can also be written direcltly:
//? @@( OnePercentOf( o1.SubStrings() ) ) # or just 1Percent()

? @@( o1.SubStringsOccuringNTimes(3) ) + NL #NOTE // "occuring" is mispelled (one r instead of two)
#--> [ "o", "on", "one", "one ", "n", "ne", "ne ", "e", "e ", "e t", " ", " t", "t" ]

? @@( o1.SubStringsOccurringExactlyNtimes(3) ) + NL
#--> [ "on", "one", "one ", "n", "ne", "ne ", "e t", " t", "t" ]

? @@( o1.SubStringsOccurringNoMoreThanNTimes(1) )
#--> [ ]

proff()
# Executed in 0.90 second(s) in Ring 1.21
# Executed in 4.46 second(s) in Ring 1.19

/*---

profon()

o1 = new stzString( "ALLAH" )
? o1.HowManySubStrings()
#--> 15

? @@( o1.SubStringsOccurringOnlyNTimes(1) ) + NL
#--> [ "AL", "ALL", "ALLA", "ALLAH", "LL", "LLA", "LLAH", "LA", "LAH", "AH", "H" ]

? @@( o1.SubStringsOccurringNTimes(2) )
#--> [ "A", "L" ]

? HwoMany( o1.SubStringsOccurringNTimes(7) ) #NOTE //that "HwoMany" is misspelled
#--> 0

? HowMany( o1.SubStringsOccurringLessThanNTimes(3) )
#--> 13

? @@( Some( o1.SubStringsOccurringLessThanNTimes(3) ) )
#--> [ "ALLA", "L", "LLA", "LA" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19

#=====

# #narration: function active and passive forms (discussion with Mahmoud)

profon()

# The RemoveBounds() function exists and it acts on the object
# on place and changes its value, like this:

o1 = new stzString("<<Go!>>")
o1.RemoveBounds()
? o1.Content()
#--> "Go!"

# This is called the @FunctionActiveForm , while BoundsRemoved()
# is called the @FunctionPassiveForm.

# Typically, the first active form is used to sculpture the object
# at your will, action after action, like for example:

StzStringQ( "<<Go!>>") {
        RemoveBounds()
        Uppercase()
        AddBounds([ "~", "~" ])
        # and so on...
        ? Content()
        #--> "~GO!~"
}

# While the passive form is used to return the final result of the
# function WITHOUT altering the object value. Hence when we say:

o1 = new stzString("<<Go!>>")
? o1.BoundsRemoved()
#--> "Go!"
? o1.Content()
#--> <<Go!>>

# The value of the object won't be changed after BoundsRemoved() is used.

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.19

/*===

profon()

? Chars("SOFTANZA")
#--> [ "S", "O", "F", "T", "A", "Z", "A" ]

proff()
# Executed in almost 0 second(s).

/*===  #narration: long function names are necessary for Softanza, but not for you!

profon()

# When you dig into the Softanza code, you may occasionally encounter functions
# with very long names, such as:

#                         7.9....4.6                3.5....4.2
o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? @@( o1.FindSubStringBoundsUpToNCharsAsSections("Ring", 2) )
#--> [ [ 8, 9 ], [ 14, 15 ], [ 34, 35 ], [ 40, 41 ] ]

# This shouldn’t disappoint you. Let me explain why.

# Even though the function name clearly describes what it does (in this case,
# finding the substrings bounding "Ring" with up to 2 characters), it’s not
# meant to be used directly by you.

# These long functions are, in fact, used internally by other simpler functions
# that you will actually need in practice, while keeping the codebase more readable.

# In our case, the function you’d need is this one:

? o1.BoundsOfXT("Ring", 2, 2) # You will understand the XT() usage in a moment ;)
#--> [ [ "<<", ">>" ], [ "((", "))" ] ]

# This is what you should use when you don’t want all the bounding substrings returned
# (in this case all 3 chars), but only 2 chars from each bound.

# To return all the characters bounding the substring "Ring", you can use:

? o1.BoundsOf("Ring")
#--> [ [ "<<<", ">>" ], [ "(((", ")))" ] ]

# NOTE: Now you can see why we added the XT() extension to the BoundsOf() function name:
# it indicates an extended form of the main function, where you can specify the number
# of characters in the bound.

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*===

profon()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<<", ">>>"], [ "(((", ")))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()
#--> [ ["<<", ">>"], [ "((", "))" ] ]

proff()
# Executed in 0.03 second(s).

/*--- 5 cases of the many cheks Softanza has for bounds

profon()

# Case 1 : Checking if the string is bounded by ONE or TWO substrings

? Q("_world_").IsBoundedBy("_")
#--> _TRUE_

? Q("/world\").IsBoundedBy([ "/", "\" ])
#--> _TRUE_

# Case 3 : Checking if the string is bounded by one (or two)
# substrings INSIDE an other string

? Q("world").IsBoundedByXT( "_", :In = "_world_" )
#--> _TRUE_

? Q("world").IsBoundedByXT( ["/","\"], :In = "/world\" )
#--> _TRUE_

# Case 3 : Checking if a string (or two) is the bound of an other
# string inside a third string

? Q("_").IsBoundOfXT("world", :In = "Hello _world_ of Ring!")
#--> _TRUE_

? Q(["/","\"]).AreBoundsOfXT("world", :In = "Hello /world\ of Ring!")
#--> _TRUE_

proff()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.22 second(s) in Ring 1.19

/*--- #narration

profon()

# In Softanza, if you have a string bounded by some chars,
# you can remove them to keep only the string:

o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

# In case you don't know the bounds, Softanza knows them,
# and can remove them for you:

o1 = new stzString("<<Go!>>")
? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.BoundsRemoved()
#--> "Go!"

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.24 second(s) in Ring 1.18

/*======= #narration

profon()

# In Softanza, you can get a part of a list (or string) using
# Section() function, also called Slice()

o1 = new stzString("123456789")

? o1.Section(3, 5)
#--> "345"

# When you inverse the params so the first is greater then the second,
# nothing happens to the result ( the Section() function is not aware
# of the direction of parsing ) :

? o1.Section(5, 3)
#--> "345"

# You may argue that it would be useful, in this case, to embrace the
# Python-way of returning an inversed string (or list)...

# Softanza does not reject that, and finds it very useful too! But, it just
# requires that you use the extended form of the function, SectionXT() :

? o1.SectionXT(5,3)
#--> "543"

# As you see, the section has been reversed. But you can do more, and use
# negative numbers to order Softanza to start parsing from the end:

? o1.SectionXT(-4, -2)
#--> 678

? o1.SectionXT(-2, -4)
#--> 876

# Remember : if you try these fency things with the more conservative Section()
# methond (without ...XT() extension), and for Softanza to stay simple and
# consitent for the most common use cases, you will get an error:

//? o1.Section(-2, -4)
#--> Error message: Indexes out of range! n1 and n2 must be inside the string.

# Before you leave : All what works for stzString, will work for stzList.
# For our case, just change the first line of the code to use stzList instead
# of stzString, like this :

o1 = new stzList("1":"9")

# Now you can run the code sucessfully withou any modification.

proff()
# Executed in 0.01 second(s)

/*=========== #narration: case sensitivity in Softanza

profon()

# Do you know that case sensitivity is supported in Softanza,
# not only on stzString but also on stzList ?!

# Look how we can fin an item case-sensitively:

o1 = new stzList([ "emm", "EMM", "eMm", "EMM" ])

? o1.Find("EMM") # Same as FindCS("EMM", :CS = _TRUE_)
#--> [ 2, 4 ]

? o1.FindCS("EMM", :CS = _FALSE_)
#--> [ 1, 2, 3, 4 ]

# In fact, all items are equal when case sensitivity is not considered (set to _FALSE_)!
# In the same way, the size of the list can be counted in a case-sensity way:

? o1.NumberOfItems()
#--> 4

? o1.NumberOfItemsCS(_FALSE_)
#--> 1

# Now, softanza digs deeper and applies CaseSensitiviy on some other
# non trivial corners of the stzList class : the Content() method!

? o1.Content() # Same as ContentCS(_TRUE_)
#--> [ "emm", "EMM", "eMm", "EMM" ]

? o1.ContentCS(_FALSE_)
#--> [ "emm" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19

/*========

profon()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content() #--> "♥ php ruby ♥♥ python ♥♥♥"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

/*========

profon()

o1 = new stzString("Ring Programming Language")

? o1.Section(6, o1.RandomPositionAfter(6) )
#--> Programming Lang

? o1.Section(6, o1.FindNth(3, "g") )
#--> Programming

? o1.Section( :From = "L", :To = "e")
#--> Language

#--

? o1.Range(6, 11)
#--> Programming

? o1.SectionXT(6, :UpToNCHars = 11)
#--> Programming

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19

/*===

profon()

? IsMarquer("#01")
#--> _TRUE_

? IsMarquer("#02")
#--> _TRUE_

? BothAreMarquers("#01", "#02")
#--> _TRUE_

proff()
# Executed in 0.01 second(s)

/*-----

profon()

? Q('[  "ABC" , "EB" , "AA"  , 12 ]').ToList()
#--> [ "ABC", "EB", "AA", 12 ]

? Q(' "A" : "E" ').ToList()
#--> [ "A", "B", "C", "D", "E" ])

? Q(' "ا" : "ت" ').ToList()
#o--> [ "ا", "ب", "ة", "ت" ]

? Q(' "#1" : "#5" ').ToList()
#--> [ "#1", "#2", "#3", "#4", "#5" ]

proff()
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.42 second(s) in Ring 1.18

/*====

profon()

o1 = new stzString("ilir")

? o1.Copy().UppercaseQ().SpacifyQ().ReplaceQ(" ", "*").Content()
#--> "I*L*R"

? o1.Content()
#--> "ilir"

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.17

/*----

profon()

o1 = new stzString("123ruby89")
o1.ReplaceAt(4, "ruby", "ring")
? o1.Content()
#--> 123ring89

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18

/*----

profon()

put "What's your First name?"

fname = GetString()
# Enter Mahmoud in the keyboard...

print( Interpolate("It's nice to meet you {fname}!") )
#--> It's nice to meet you Mahmoud!

proff()
# Executed in 1.54 second(s).
#NOTE Most time is taken by the Ring GetString() function
# because it depends of your typing speed and the time you took
# before you start typing!

#~> Clarified by Mahmoud in this Google Group post:
# https://groups.google.com/g/ring-lang/c/spaMUfhUtgU/m/G7xHeO0kAAAJ

/*=======

profon()

# Replacing the string by reference

	o1 = new stzString("R I N G")
	o1.Replace(" ", "-")
	# This modifies the string itself

	? o1.Content()
	#--> R-I-N-G

# Replacing the string by copy

	o1 = new stzString("R I N G")
	? o1.Copy().ReplaceQ(" ", "-").Content()
	#--> R-I-N-G

	# Hence, the copy is modified, but the original
	# string stays the same

	? o1.Content()
	#--> R I N G

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.18

/*======

profon()

o1 = new stzString("1♥34♥♥")
o1.ReplaceByMany("♥", [ "2", "5", "6" ])
? o1.Content()
#--> 123456

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :By = [ "2", "5", "6" ])
? o1.Content()
#--> 123456

o1 = new stzString("1♥34♥♥")
o1.Replace("♥", :ByMany = [ "2", "5", "6" ])
? o1.Content()
#--> 123456

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.16 second(s) in Ring 1.17

/*======

profon()

o1 = new stzString( "a + b - c / d = 0")

o1.ReplaceMany( ["+", "-", "/" ], :By = "*" )
? o1.Content()	
#--> "a * b * c * d = 0"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.17

/*-----

profon()

o1 = new stzString("ring php ruby ring python ring")

o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> "♥ php ruby ♥♥ python ♥♥♥"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.17

/*------

profon()

o1 = new stzString("ring php ring ruby ring python ring")

o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
? o1.Content()
#--> "#1 php #2 ruby #1 python #2"

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.10 second(s) in Ring 1.17

/*------

profon()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")

o1.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> "♥ qt ♥♥ pyhton ♥♥♥ csharp ♥"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.17

/*------

profon()

o1 = new stzString("ring ruby ring php ring")

o1.ReplaceSubstringAtPositions([ 1, 20 ], "ring", :By = "♥♥♥")
? o1.Content()
#--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.17

/*------

profon()

o1 = new stzString("ring php ring ruby ring python ring csharp ring")

o1.ReplaceOccurrencesByMany([ 1, 3, 5], "ring", :By = [ "#1", "#3", "#5" ])
? o1.Content()
#--> "#1 php ring ruby #3 python ring csharp #5"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.09 second(s) in Ring 1.17

/*=====

profon()

	o1 = new stzString("**word1***word2**word3***")
	? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	#--> [ "**", "***", "**", "***" ]
		
	o1.RemoveManySections([
		[1,2], [8, 10], [16, 17], [23, 25]
	])
		
	? o1.Content()
	#--> "word1word2word3"

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.17 second(s) in Ring 1.17

/*-----

profon()

o1 = new stzString("1♥♥456♥♥901♥♥4")
o1.RemoveSections([ 2:3, 7:8, 12:13 ])
? o1.Content()
#--> 14569014

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17

/*-----

profon()

o1 = new stzString("1♥♥456♥♥901♥♥4")

o1 {
	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 4, 8, 9, 14, 15 ]

	# Doing someting with the positions

	ReplaceCharsAtPositions(anPos, :With = "★")
		? Content()
		#--> 1★★456★★901★★4

	#-- Finding sections

	aSections = FindAsSections("★★")
		? @@(aSections)
		#--> [ [ 2, 3 ], [ 7, 8 ], [ 12, 13 ] ]

	#-- Doing somethinh the sections

	RemoveSections(aSections)
		? o1.Content()
		#--> 14569014
	
}

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*==========

profon()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveAt(6, "♥♥♥") # Or RemoveSubStringAtPosition()

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.01 second(s)

/*----------

profon()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveXT("♥♥♥", :AtPosition = 6)

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.18

/*------------

profon()

	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveXT("♥♥♥", :AtPositions = [ 1, 9, 17 ])

	? o1.Content() #--> "ring ruby php"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17

/*------------

profon()

	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveAt([ 1, 9, 17 ], "♥♥♥") # Or RemoveSubstringAtPositions()

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.17

/*==========

profon()

	o1 = new stzString("ruby ring php")
	o1.ReplaceAt(6, "ring", :By = "♥♥♥") # Or ReplaceSubStringAtPosition()

	? o1.Content()
	#--> "ruby ♥♥♥ php"

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.16 second(s) in Ring 1.17

/*----------

profon()

	o1 = new stzString("ruby ring php")
	o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")

	? o1.Content()
	#--> "ruby ♥♥♥ php"

proff()
# Executed in 0.16 second(s)

/*------------

profon()

	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceXT("ring", :AtPositions = [ 1, 20 ], :By = "♥♥♥")

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.14 second(s)

/*------------

profon()

	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceAt([ 1, 20 ], "ring", :By = "♥♥♥") # Or ReplaceSubstringAtPositions()

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.07 second(s)

/*=============

profon()

o1 = new stzString( "a + b - c / d = 0")
o1.Replace( [ "+", "-", "/" ], :By = "*" ) # Or ReplaceMany()
 ? o1.Content()
	
#--> "a * b * c * d = 0"
	
proff()
# Executed in 0.05 second(s)

/*=========

profon()

StzNamedStringQ(:myname = "Mansour") {

	? Name()
	#--> :myname

	? Content()
	#--> "Mansour"

	? StzType()
	#--> :stznumber

}

proff()
#--> Executed in 0.04 second(s)

/*========

profon()

o1 = new stzString("--ring--&--softanza--")

? @@( o1.FindExceptZZ("--") )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except("--") ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

proff()
# Executed in 0.10 second(s)

/*--------

profon()

o1 = new stzString("--ring--&__softanza__")

? @@( o1.FindExceptZZ([ "--", "__" ]) )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except([ "--", "__" ]) ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

proff()
# Executed in 0.14 second(s)

/*--------

profon()

o1 = new stzString("--Ring--&__Softanza__")
o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
? o1.Content()
#--> Ring&Softanza

proff()

/*--------

profon()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
? o1.Content()
#--> Ring&♥Ring♥Softanza♥

proff()
# Executed in 0.11 second(s)

/*-------- TODO

profon()

o1 = new stzString("--Ring--Softanza--")

o1.ReplaceWithMany("--", ["1", "2", "3"])
? o1.Content()

proff()

/*-------- TODO

profon()

o1 = new stzString("--Ring__Softanza..")

o1.ReplaceManyWithMany(["--", "__", ".."], ["1", "2", "3"])
? o1.Content()

proff()

/*-------- #expressiveness #elegant-code

profon()

o1 = new stzString("--Ring--__Softanza__")

o1.ReplaceAllExcept([ "Ring", :And = "Softanza" ], :With = AHeart())
? o1.Content()
#--> ♥Ring♥Softanza♥

proff()

/*======== #narration

profon()

o1 = new stzString("okay one pepsi two three ")

# Declaring a condition in a string

cMyConditionIsVerified = '
	Q(This[@i]).ContainsAnyOfThese( Q("vwto").Chars() )
'

# Using the condition to find the words verifying it (using FindW())
# after the string is splitted (using Split())
? cMyConditionIsVerified

? o1.SplitQ(" ").FindWhere(cMyConditionIsVerified) # Or .FindW() for short!
#--> [ 1, 2, 4, 5 ]

# Getting the words themselves using ItemsW()

? o1.SplitQ(" ").ItemsWhere(cMyConditionIsVerified)
#--> [ "okay", "one", "two", "three" ]

# In general, any function in Softanza, like Find() and Items() here,
# can be used as they are, or exented with the W() letter, so we can
# instruct them to do their job upon a given condition.

proff()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.19

/*----------

profon()

o1 = new stzString("okay one pepsi two three ")
? o1.SplitQ(" ").FindWXT(' Q(@item).ContainsAnyOfThese( Q("vwto").Chars() ) ')
#--> [ 1, 2, 4, 5 ]

proff()
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.58 second(s) in Ring 1.17

/*=======

profon()

o1 = new stzString("ABC")
o1.ExtendTo(5)
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.01 second(s)

/*=============

str = "ring"
for i = 1 to 10000
	str += "ring"
next

profon()

oQStr = new QString2()
oQStr.append(str)

c1 = oQStr.mid(0, 1)
? c1
#--> "r"

c2 = oQStr.mid(oQStr.size()-1, 1)
? c2
#--> "g"

proff()
# Executed in 0.03 second(s)

/*----------------
/*==============

profon()

? Q(["A", "B", "C", "D", "E"])[-3]
#--> "C"

proff()
# Executed in 0.03 second(s)

/*========

profon()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 5, 6 ], [ 13, 17 ] ]

proff()
# Executed in 0.07 second(s)

/*-----------

profon()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSections("aa", "aa"))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.08 second(s)

/*-----------

profon()

#                       5 7  01    
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSectionsS("aa", "aa", :startingat = 2))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()

/*=============

profon()

o1 = new stzString("---♥♥...**---")

? o1.SubStringComesBetween("...", "♥♥", "**")
#--> _TRUE_

? o1.SubStringComesBetween("...", "**", "♥♥")
#--> _TRUE_

proff()
# Executed in 0.05 second(s)

/*=========

profon()

o1 = new stzString("123♥♥678**123♥♥678")

? o1.SubStringComesBefore("♥♥", :Position = 6)
#--> _TRUE_

? o1.SubStringComesBeforePosition("♥♥", 6)
#--> _TRUE_

? o1.SubStringComesBefore("♥♥", :SubString = "**")
#--> _TRUE_

? o1.SubStringComesBeforeSubString("♥♥", "**")
#--> _TRUE_

#--

? o1.SubStringComesAfter("♥♥", :Position = 3)
#--> _TRUE_

? o1.SubStringComesAfterPosition("♥♥", 3)
#--> _TRUE_

? o1.SubStringComesAfter("**", :SubString = "♥♥")
#--> _TRUE_

? o1.SubStringComesAfterSubString("**", "♥♥")
#--> _TRUE_

#--

? o1.SubStringComesBetween("♥♥", :Positions = 3, :And = 6)
#--> _TRUE_

? o1.SubStringComesBetweenPositions("♥♥", 3, 6)
#--> _TRUE_

? o1.SubStringComesBetween("678", :SubStrings = "♥♥", :And = "**")
#--> _TRUE_

? o1.SubStringComesBetweenSubStrings("678", "**", "♥♥")
#--> _TRUE_

#--

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> _TRUE_

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> _TRUE_

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> _TRUE_

proff()
# Executed in 0.12 second(s)

/*-----

profon()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----

profon()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

proff()
# Executed in 0.08 second(s)

/*===========

profon()

? @@( Digits() )
#--> [0, 1, 2, 3, 4, 5, 6, 7, 8 , 9 ]

? Q(5).IsADigit() # In this case, Q() transforms 5 to a stzNumber object
#--> _TRUE_

? Q("3").IsADigitInString() # In this case, Q() transforms 5 to a stzString object
#--> _TRUE_

? Q("").IsADigitInString() # Idem
#--> _FALSE_

? Q("125").IsADigitInString() # Idem
#--> _FALSE_

? QQ("3").IsADigit() #  In this case, QQ() transforms "3" to a stzChar object
#--> _TRUE_

proff()
# Executed in 0.13 second(s)

/*--------

profon()

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection = [10, 13],
	:Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)

#--> [ "<<", ">>>" ]

proff()
# Executed in 0.05 second(s)

/*--------

profon()

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
? ShowShort( Q(aList).Section(:FromPosition = 4, :To = :LastItem) )
#--> [ 4, 5, 6, "...", 18, 19, 20 ]

# Short form:
? ShowShort( Q(1:20).Slice(4, :Last) )
#--> [ 4, 5, 6, "...", 18, 19, 20 ]

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

/*-----

profon()

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

/*====

profon()()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsXT( "♥", :InSection = [ 3, 10 ] )
#-- _TRUE_

? o1.ContainsXT( "♥", :InSections = [ [ 3, 10 ], [ 8, 12 ], [ 14, 19 ] ] )
#--> _TRUE_

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.20

/*-----

profon()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsInSection("♥", 3, 10)
#--> _TRUE_

? o1.ContainsInSections("♥", [ [3,10], [8,12], [14,19] ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*==================

profon()

? Q("I").Unicode()
#--> 73

proff()
# Executed in 0.03 second(s)

/*-----

profon()

a = Q("abc").ToListOfStzChars()
? a[2].StzType()
#--> stzchar

proff()
# Executed in 0.05 second(s)

/*-----

profon()

? HexPrefix()
#--> Ox

? Q( HexPrefix() + '066E').RepresentsNumberInHexForm()
#--> _TRUE_

? Q('U+066E').RepresentsNumberInUnicodeHexForm()
#--> _TRUE_

proff()

/*---------

profon()

? TQ("משמש").Script()
#--> hebrew


proff()

/*----------

profon()

? Q('U+0649').IsHexUnicode() 	#--> _TRUE_
? StzCharQ("ڢ").HexUnicode() 	#--> U+06A2
? QQ('U+0649').Content() 	#--> ى
? QQ('U+06A2').Content() 	#--> ڢ
? HexUnicodeToUnicode('U+06A2')	#--> 1698
? UnicodeToHexUnicode(1698)	#--> U+06A2

proff()
# Executed in 1.20 second(s)

/*---------

profon()

? Q("ı").Unicode()
#--> 305

? Q("ȷ").Unicode()
#--> 567

? Q("abc").Unicodes()
#--> [ 97, 98, 99 ]

? Q([ "a", "b", "c" ]).Unicodes()
#--> [ 97, 98, 99 ]

? Q("a").HexUnicode()
#--> U+0061

? Q("abc").HexUnicodes()
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

? Q([ "a", "b", "c" ]).HexUnicodes()
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

? @@( Q([ "a", "bcd", "e" ]).Unicodes() )
#--> [ 97, [ 98, 99, 100 ], 101 ]

? @@( Q([ "a", "bcd", "e" ]).HexUnicodes() )
#--> [ "U+0061", [ "U+0062", "U+0063", "U+0064" ], "U+0065" ]

? Unicodes("abc")
#--> #--> [ 97, 98, 99 ]

? HexUnicodes("abc")
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

proff()
# Executed in 0.33 second(s)

/*===========

cName = "Gary"

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> It's been a real pleasure meeting you, Gary!

/*===========

profon()

? Q("♥").RepeatedNTimes(3)
#--> ♥♥♥

? Q("♥").Repeated3Times()
#--> ♥♥♥

? NCopies(3, "♥")
#--> ♥♥♥

? 3Copies(:of="♥")
#--> ♥♥♥

proff()

/*---------

profon()

#TODO // Those two functions must be unified
#--> Read the TODO in stzScripts.ring

? len( LocaleScripts() )
#--> 141

? len( UnicodeScripts() )
#--> 157

proff()

/*==============

profon()

? Dotless("alitalia extrême extèrieur aéorô ûltrâ")
#--> alıtalıa extreme exterıeur aeoro ultra

? Dotless("مشمش وخوخ وزيتون")	#--> مسمس وحوح ورٮٮوٮ


proff()

/*---------

profon()

? Dotless("فلسطين الأبيّة") 		#--> ٯلسطٮں الأٮٮّه
? Dotless("عاشت المقاومة") 		#--> عاسٮ المٯاومه
? Dotless("تونس معك يا غزّة")		#--> ٮوٮس معک ٮا عرّه
? Dotless("جمعية الخيرات")		#--> حمعٮه الحٮراٮ
? Dotless("أفديك بروحي يا قدس") 	#--> أٯدٮک ٮروحٮ ٮا ٯدس
? Dotless("مشمش وخوخ وزيتون")		#--> مسمس وحوح ورٮٮوٮ

#TODO // the implementation needs some enhancements/

proff()


/*==================

profon()

? Q("1234567890987654321").ShortenedN(2)
#--> 12...21
		
? Q("1234567890987654321").ShortenedXT(0, 2, " {...} ")
#--> 12 {...} 21

proff()
# Executed in 0.03 second(s)

/*--------------

profon()

? Q("1234567890987654321").Shortened()
#--> 123...321

? Q("1234567890987654321").ShortenedN(5)
#--> 12345...54321

? Q("1234567890987654321").ShortenedXT(0, 3, " ... ")
#--> 123 ... 321

proff()
# Executed in 0.04 second(s)

/*-------------

profon()

o1 = new stzString("1234567890987654321")
o1.Shorten()
? o1.Content()
#--> 123...321

o1 = new stzString("1234567890987654321")
o1.ShortenN(5)
? o1.Content()
#--> 12345...54321

proff()
# Executed in 0.04 second(s)

/*-------------

profon()

? Q("1234567890987654321").ShortenedUsing(" {...} ")
#--> 123 {...} 321

? Q("1234567890987654321").ShortenedNUsing(5, " {...} ")
#--> 12345 {...} 54321

proff()
# Executed in 0.03 second(s)

/*=============

profon()

o1 = new stzString("aa***aa**aa***aa")
? o1.IsBoundedByCS("aa", _TRUE_)
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*----------------

profon()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.BoundedBy("aa") )
#--> [ "***", "**", "***" ]

proff()
# Executed in 0.08 second(s)

/*----------------

profon()

o1 = new stzString("<<***>>**<<***>>")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 3, 5 ], [ 12, 14 ] ]

proff()
# Executed in 0.07 second(s)

/*----------------

profon()

o1 = new stzString("<<***>>**<<***>>")

? o1.Between("<<", :and = ">>")
#--> [ "***", "***" ]

? o1.BoundedBy(["<<", ">>"])
#--> [ "***", "***" ]

proff()
# Executed in 0.13 second(s)

/*----------------

profon()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.FindAnyBoundedBy("aa") )
#--> [ 3, 8, 12 ]

? @@( o1.FindAnyBoundedByAsSections("aa") )
#--> [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ]

proff()
# Executed in 0.10 second(s)

/*==============

profon()

o1 = new stzString("RINGORIALAND")

? o1.NumberOfSubStrings()
#--> 78

? @@S( o1.SubStrings() ) # S --> short : to show just a part of the long list
#--> [ "R", "RI", "RIN", ..., "N", "ND", "D" ]

proff()
#--> Executed in 0.01 second(s)

/*=============

profon()

o1 = new stzString("BEBE")

? o1.NumberOfSubStringsU()
#--> 7

? @@( o1.SubStringsU() )
#-< [ "B", "BE", "BEB", "BEBE", "E", "EB", "EBE" ]

proff()
# Executed in 0.01 second(s)

/*----------------

profon()

o1 = new stzString("BEbe")

? o1.NumberOfSubStringsCS(_TRUE_)
#--> 10

? @@( o1.SubStringsCS(_TRUE_) )
#--> [ "B", "BE", "BEb", "BEbe", "E", "Eb", "Ebe", "b", "be", "e" ]

? o1.NumberOfSubStringsCS(_FALSE_)
#--> 7

? @@( o1.SubStringsCS(_FALSE_) )
#--> [ "b", "be", "beb", "bebe", "e", "eb", "ebe" ]

proff()
# Executed in 0.01 second(s)

/*----------------

profon()

o1 = new stzString("HELLOhello")

? o1.NumberOfSubStringsCS(_TRUE_)
#--> 55

? @@S( o1.SubStringsCS(_TRUE_) ) + NL
#--> [ "H", "HE", "HEL", "...", "l", "lo", "o" ]

? o1.NumberOfSubStringsCS(_FALSE_)
#--> 39

? @@S( o1.SubStringsCS(_FALSE_) ) + NL
#--> [ "h", "he", "hel", "...", "ohel", "ohell", "ohello" ]

? @@( o1.FindSubStringsCS(_FALSE_) ) + NL
#--> [ 1, 2, 3, 4, 5 ]

? @@S( o1.SubStringsCSZ(_FALSE_) ) + NL
#--> [
#	[ "h", [ 1, 6 ] ],
#	[ "he", [ 1, 6 ] ],
#	[ "hel", [ 1, 6 ] ],
#	"...",
#	[ "ohel", [ 5 ] ],
#	[ "ohell", [ 5 ] ],
#	[ "ohello", [ 5 ] ]
# ]

? @@S( o1.FindSubStringsCSZZ(_FALSE_) ) + NL
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], "...", [ 5, 8 ], [ 5, 9 ], [ 5, 10 ] ]

? @@S( o1.SubStringsCSZZ(_FALSE_) ) + NL
#--> [
#	[ "h", [ [ 1, 1 ], [ 6, 6 ] ] ],
#	[ "he", [ [ 1, 2 ], [ 6, 7 ] ] ],
#	[ "hel", [ [ 1, 3 ], [ 6, 8 ] ] ],
#	"...",
#	[ "ohel", [ [ 5, 8 ] ] ],
#	[ "ohell", [ [ 5, 9 ] ] ],
#	[ "ohello", [ [ 5, 10 ] ] ]
# ]

? o1.NumberOfSubStringsOfNCharsCS(4, _FALSE_)
#--> 7

? @@( o1.SubStringsOfNCharsCS(4, _FALSE_) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel", "hell", "ello" ]

? o1.NumberOfSubStringsOfNCharsCSU(4, _FALSE_) + NL
#--> 5

? @@( o1.SubStringsOfNCharsCSU(4, _FALSE_) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel" ]

? @@( o1.SubStringsWXT('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ "Ohello", "hello", "ello" ]	# Takes 0.20 second(s)

? @@( o1.SubStringsWXTZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ [ "Ohello", [ 5 ] ], [ "hello", [ 6 ] ], [ "ello", [ 7 ] ] ]

? @@( o1.SubStringsWXTZZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
)
#--> [
#	[ "Ohello", [ [ 5, 10 ] ] ],
#	[ "hello", [ [ 6, 10 ] ] ],
#	[ "ello", [ [ 7, 10 ] ] ]
# ]

proff()
# Executed in 0.75 second(s) in Ring 1.21


/*==================

profon()

o1 = new stzString("RINGORIALAND")
? o1.Duplicates()

#--> [ "R", "RI", "I", "N", "A" ]

proff()
#--> Executed in 0.22 second(s)

/*=============

profon()

? Q("ABCDE")[-2]
#--> D

proff()
# Executed in 0.03 second(s)

/*=============

profon()

o1 = new stzString("Ringprogramminglanguageispowerful!")
//o1.InsertAfterPositions([ 4, 15, 23, 25], " ")
o1.InsertBeforePositions([ 5, 16, 24, 26], " ")
#--> Ring programming language is powerful!

proff()
# Executed in 0.03 second(s)

/*-------------

profon()

o1 = new stzString("Ringprogramminglanguageispowerful!")

o1.SpacifySections([ [ 5, 15 ], [ 24, 25 ] ])
? o1.Content()
#--> Ring programming language is powerful!

proff()
# Executed in 0.04 second(s)

/*------------

profon()

o1 = new stzString("Ringprogramminglanguageispowerful!")
o1.SpacifySubStrings([ "programming", "is" ])
? o1.Content()
#--> Ring programming language is powerful!

proff()
# Executed in 0.27 second(s)

/*=============

profon()

? Q(:stzListsOfStrings).IsPluralOfAStzType()
#--> _TRUE_

proff()

/*=============

profon()

o1 = new stzString("ABC")
o1.ExtendWith("DE")
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendToNChars(5)
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendToWith(5, "*")
o1.Show()
#--> "ABC**"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("123")
o1.ExtendToWithCharsRepeated(8)
o1.Show()
#--> "12312312"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("123")
o1.ExtendToWithCharsIn( 8, "1":"3" )
o1.Show()
#--> "12312312"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :With = "DE" )
o1.Show()
#--> "ABCDE"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :ToPosition = 5 )
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.05 second(s)

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
o1.Show()
#--> "ABCAB"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :ByCharsRepeated )

o1.Show()
#--> "ABCAB"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = "*" )
o1.Show()
#--> "ABC**"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18

/*----------------

profon()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :WithCharsIn = [ "D", "E" ])
o1.Show()
#--> "ABCDED"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18

/*----------------

profon()

o1 = new stzString("ABCDE")
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> "ABC"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.18

/*===============

profon()
#                     3  6  9  2
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.SubStringsWXT('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ "♥^^♥", "^♥♥^" ]

proff()
# Executed in 0.42 second(s) in Ring 1.21
# Executed in 1.98 second(s) in Ring 1.19

/*--------------

profon()
#                     3  6  9  2 
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.FindSubStringsAsSectionsWXT('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ [ 3, 6 ], [ 9, 12 ] ]

proff()
# Executed in 0.42 second(s) in Ring 1.21
# Executed in 1.92 second(s) in Ring 1.19

/*=============

profon()

o1 = new stzString("...♥...♥...")
? o1.FindWXT('@char = "♥"')
#--> [4, 8]

proff()
# Executed in 0.25 second(s) in Ring 1.21
# Executed in 1.69 second(s) in Ring 1.19

/*============

profon()

o1 = new stzString("abCDE")

? o1.First2Chars()
#--> [ "a", "b" ]

? o1.First2CharsAsString() + NL
#--> "ab"

? o1.Last3Chars()
#--> [ "C", "D", "E" ]

? o1.Last3CharsAsString() + NL
#--> "CDE"

? o1.Next3Chars(:StartingAt = 2)
#--> [ "C", "D", "E" ]

? o1.Next3CharsAsString(:StartingAt = 2)
#--> "CDE"

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18

/*=========

profon()

o1 = new stzString("aaA...")

? o1.FindCS("a", :CaseSensitive) # Or :IsCaseSensitive or :CS or :IsCS
				 # or _TRUE_ or _TRUE_ or _TRUE_
#--> [1, 2]

? o1.FindCS("a", :CaseInSensitive) # Or :NotCaseSensitive or :NotCS
				   # or :IsNotCaseSensitive  or :IsNotCS
				   # or :CaseSensitive = _FALSE_
				   # or :CS = _FALSE_
				   # or _FALSE_
#--> [1, 2, 3]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19

/*=========

profon()

o1 = new stzString("softanza")
? o1.Section(4, 6)
#--> "tan"

? o1.Section(6, 4)
#--> "tan"

proff()
# Executed in 0.03 second(s)

/*----

profon()

o1 = new stzList([ "s", "o", "f", "t", "a", "n", "z", "a" ])
? @@( o1.Section(4, 6) )
#--> [ "t", "a", "n" ]

? @@( o1.Section(6, 4) )
#--> [ "t", "a", "n" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18

/*==========

profon()

o1 = new stzString("..3..♥..♥..2..")
? o1.FindInSection("♥", 3, 12)
#--> [6, 9]

? o1.FindInSection("♥", 12, 3)
#--> [6, 9]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.18

/*=========

profon()

o1 = new stzString("---|ABC|---|ABC|---")

? @@( o1.FindBetweenAsSections("ABC", "|", "|") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindBoundedByAsSections([ "ABC", '|' ]) )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindXT("ABC", :Between = [ "|", "|" ]) )
#--> [ 5, 13 ]

? @@( o1.FindAsSectionsXT("ABC", :Between = [ "|", "|" ]) )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindXT("ABC", :BoundedBy = "|") )
#--> [ 5, 13 ]

? @@( o1.FindAsSectionsXT("ABC", :BoundedBy = "|") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.20

/*=========

profon()

o1 = new stzString(' this code:   txt1  =   "    withspaces    " and txt2  =  "nospaces"  ')
o1.SimplifyExcept( o1.FindAnyBoundedByAsSections('"') )

? o1.Content()

#--> 'this code: txt1 = "    withspaces    " and txt2 = "nospaces"'

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20


/*-----------

profon()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? @@( o1.Duplicates() )
#--> [ "*", "4" ]

proff()
# Executed in 0.17 second(s)

/*----------

profon()

? Script("鶊")
#--> han

? Name("鶊")
#--> CJK UNIFIED IDEOGRAPH-9D8A

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*----------

profon()

o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 12

? o1.Duplicates()
#--> [ "r", "ri", "rin", "ring", "i", "in", "ing", "n", "ng", "g", " ", "p" ]

proff()
# Executed in 0.65 second(s) in Ring 1.22

/*---------- #narration

profon()

o1 = new stzString("RINGORIALAND")

# Are there any duplicated substrings in this string?

? o1.ContainsDuplicates()
#--> _TRUE_

# The number of duplicates is 5:

? o1.NumberOfDuplicates()
#--> 5

# But, if we check their positions we get only 4 !

? @@( o1.FindDuplicates() )
#--> [ 6, 7, 10, 11 ]

# The dupicates are effectively 5:
? @@( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]

# To find an explication, let's use the DuplicatesAndTheirPositions()
# function, or use its short form DuplicatesZ()

? @@( o1.DuplicatesZ() )
#--> [ [ "R", 6 ], [ "RI", 6 ], [ "I", 7 ], [ "A", 10 ], [ "N", 11 ] ]

# Hence we see that position 6 corresponds to 2 duplicated substrings: "R" and "RI"                                                                                                                             

proff()
# Executed in 0.95 second(s) in Ring 1.22
# Executed in 2.20 second(s) in Ring 1.19

/*================

profon()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@( o1.FindBetweenAsSections( "hi!", "<<", ">>" ) )
#--> [ [ 8, 10 ], [ 29, 31 ] ]

? @@( o1.FindBetween( "hi!", "<<", ">>" ) )
#--> [ 8, 29 ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.19 second(s) in Ring 1.18

/*-----------------

profon()

? @@( Q("--<<♥♥♥>>--<<♥♥♥>>---<<♥♥♥>>").
	FindBoundedByAsSections([ "<<", ">>" ]) ) # Or Simply FindBoundedByZZ()
#--> [ [ 5, 7 ], [ 14, 16 ], [ 24, 26 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18

/*=========

profon()

o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")

? @@NL( o1.BoundedByUZ([ "<<", ">>" ]) ) + NL
#--> [
#	[ "teeba", [ 5, 27 ] ],
#	[ "rined", [ 16 ] ]
# ]

? @@NL( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> [
#	[ "teeba", [ [ 5, 9 ], [ 27, 31 ] ] ],
#	[ "rined", [ [ 16, 20 ] ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.17 in Ring 1.18

/*---------

profon()

aList = [ 1, "♥", 3, 4, "♥", 5, "♥" ]

? FindNth(aList, 2, "♥", :StartingAt = 2)
#--> 5

? FindNth(aList, 2, "♥", :StartingAt = 3)
#--> 7

? FindNextNth(aList, 2 , "♥", :StartingAt = 2)
#--> 7

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---------

profon()

? @ListContainsCS([ "hi!", "--♥♥♥--♥♥♥--" ], "hi!", _TRUE_)
#--> _TRUE_

? @FindNthSTCS([ "hi!", "--♥♥♥--♥♥♥--" ], 1, "hi!", :StartingAt = 1, _TRUE_)
#--> 1

? Q([ "hi!", "--♥♥♥--♥♥♥--" ]).ContainsCS("hi!", 1)
#--> 1

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")

? @@NL( o1.BoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [	[ "hi!", [3, 5] ],
#	[ "--♥♥♥--♥♥♥--", [ 12, 23 ] ],
#	[ "hi!", [ 30, 32 ] ]
# ]

? @@NL( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> [
#	[ "hi!", [ [ 3, 5 ], [ 30, 32 ] ] ],
#	[ "--♥♥♥--♥♥♥--", [ [ 12, 23 ] ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.20 second(s) in Ring 1.17

/*-------------

profon()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")

? @@( o1.SubStringsBoundedBy([ "<<", ">>" ]) )
#--> [ "--hi!--", "--", "hi!" ]

? @@NL( o1.BoundedByZZ([ "<<", ">>" ]) )
#--> [
#	[ "--hi!--", 	[  6, 12 ] ],
#	[ "--", 	[ 20, 21 ] ],
#	[ "hi!", 	[ 29, 31 ] ]
#]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.18

/*================

profon()

? Q("SOFTANZA").Section(:From = "F", :To = "A") #--> "FTA"

? Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A")
#--> ["F", "T", "A"]

proff()
# Executed in 0.10 second(s)

/*--------------

profon()

o1 = new stzString("1234567")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

? o1.SectionXT(3, -3)
#--> 345

? o1.SectionXT(-3, 3) + NL
#--> 543

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*===============

profon()

? Q("^^♥^^").ContainsAt(3, "♥")
#--> _TRUE_

? Q("^^♥^^").ContainsAt("♥", :Position = 3)
#--> _TRUE_

? Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)
#--> _TRUE_

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-----------

profon()

? Q("^^♥^^").ContainsInSection("♥", 2, 4)
#--> _TRUE_

? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4)
#--> _TRUE_

//? Q("^^♥^^").ContainsBoundedBy("♥", :Positions = [ 2, 4])
#--> _TRUE_

? Q("^^♥^^").ContainsInSection("♥", 1, 3)
#--> _TRUE_

proff()
# Executed in 0.05 second(s)

/*-----------
*
profon()

? Q("^^♥^^").ContainsBefore("♥", :Position = 4)
#--> _TRUE_

? Q("^^^♥^").ContainsAfter("♥", 3)
#--> _TRUE_

? Q("--♥--^^").ContainsBefore("♥", :SubString = "^^")
#--> _TRUE_

? Q("--^^--♥^^").ContainsAfter("♥", "^^")
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*-----------

profon()

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 2)
? Q("^^♥^^").ContainsInSection("^", 5, 3)

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*-----------

profon()

? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3)
#--> _TRUE_

? Q("--♥^^").ContainsXT("^", :AfterPosition = 2)
#--> _TRUE_

proff()
# Executed in 0.06 second(s)
 
/*-----------

profon()

? Q("^^♥^^").ContainsXT("^", :Before = 3)
#--> _TRUE_

? Q("--♥^^").ContainsXT("^", :After = 2)
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*-----------

profon()

? Q("^^♥^^").ContainsXT("^", :Before = "♥^")
#--> _TRUE_

? Q("--♥^^").ContainsXT("^", :After = "-♥")
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*---------

profon()

? Q("^♥^^♥^^♥^").ContainsAtPositions([2, 5, 8], "♥")
#--> _TRUE_

? Q("♥^^♥^^♥").ContainsAtPosition("♥", 1)

proff()
# Executed in 0.03 second(s)

/*---------

profon()

? Q("♥^^♥^^♥").ContainsAt([1, 4, 7], "♥")
#--> _TRUE_

? Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [1, 4, 7])
#--> _TRUE_

proff()
# Executed in 0.07 second(s)

/*===================

profon()

o1 = new stzString("...<<hi!>>...<<-->>...<<hi!>>...")

# Finding the substring "hi!" bounded by "<<" and ">>"
? @@( o1.FindBetween("hi!", "<<", ">>") )
#--< [ 6, 25 ]

# Written in a near-natural form:
? @@( o1.FindXT("hi!", :Between = ["<<", ">>"]) )
#--> [ 6, 25 ]

# We can yield not only the positions but the hole sections:
? @@( o1.FindBetweenAsSections("hi!", "<<", ">>") )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

# Written in a near-natural form:
? @@( o1.FindAsSectionsXT("hi!", :Between = ["<<", ">>"]) )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.19

/*--------------

profon()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")

# Inside the substrings encolsed between "<<" and ">>", find the
# occurrences of the substring "hi!"

? o1.FindBetween( "hi!", "<<", ">>" )
#--> [8, 29]

# Written in a near-natural form:

? o1.FindXT( "hi!", :Between = ["<<", :And = ">>"] )
#--> [8, 29]

# Yielding the sections not just the positions

? o1.FindBetweenAsSections( "hi!", "<<", ">>" )
#--> [ [8, 10], [29, 31] ]

# Written in a near-natural form:

? o1.FindAsSectionsXT( "hi!", :Between = ["<<", :And = ">>"] )
#--> [ [8, 10], [29, 31] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.34 second(s) in Ring 1.18

/*-----------

StartProfiler()

o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
? o1.FindBetweenAsSections("♥♥♥", "/", "\")	# FindXT( "♥", :Between = ["/","\"], :AsSections )
#--> [ [2, 4], [15, 17] ]

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> [ [2, 4], [15, 17] ]

StopProfiler()
# Executed in 0.02 second(s)

/*==============

profon()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
? @@( o1.FindAsSectionsXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ [ 6, 6 ], [ 14, 14 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------

StartProfiler()

o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")

? o1.FindBetweenAsSections("♥♥♥", "/", "\")	# FindXT( "♥", :Between = ["/","\"], :AsSections )
#--> [ [2, 4], [15, 17] ]

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> [ [2, 4], [15, 17] ]

StopProfiler()
# Executed in 0.02 second(s)

/*==============

StartProfiler()

? Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", ["^^","^^"])
#--> _TRUE_

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.18

/*=============

profon()

# Let's take this string of text:

o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")

# You may want to get the section between two positions:

? o1.BetweenIB(3, 5)
#--> ♥♥♥

# You can also say:
? o1.Section(3, 5)
#--> ♥♥♥

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*--------------- #narration

profon()

# Let's start with this string of text:

o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")

# If you want to extract all substrings bounded by << and >>,
# you can do so easily:

? o1.BoundedBy([ "<<", ">>" ])
#--> ["♥♥♥", "stars", "♥♥♥"]

# There are 3 substrings, and 2 of them are identical! No worries,
# you can retrieve only the unique substrings by appending the
# letter "U" (for Unique) to the function name:

? o1.BoundedByU([ "<<", ">>" ])
#--> ["♥♥♥", "stars"]

# Sometimes, the term "BETWEEN" can be interpreted differently,
# and you might want  to include the bounds along with the substrings. 

# This can be achieved by adding the "IB" prefix to the function
# name ("IB" for "Include Bounds"):

? o1.BoundedByIB([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<stars>>", "<<♥♥♥>>" ]

# Wonderful! But notice that "<<♥♥♥>>" appears twice...
# No problem, you know the solution: just append the "U" prefix:

? o1.BoundedByIBU([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<stars>>" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.18


proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.18

/*===============

profon()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.BoundedByIB([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<★★>>" ]

? o1.BoundedByIBZZ([ "<<", ">>" ])
#--> [
#	[ "<<♥♥♥>>", [ 4, 10 ] ],
#	[ "<<★★>>", [ 14, 19 ] ]
# ]

proff()
# Executed in 0.01 second(s)

/*=============

profon()

Q("♥♥♥ Ring programing language ♥♥♥") {

	ReplaceXT( :Each = "♥", [], :With = "*")
	? Content()
	#--> *** Ring programing language ***

	ReplaceXT("*", :With = "♥", [])
	? Content()
	#--> ♥♥♥ Ring programing language ♥♥♥
}

proff()
# Executed in 0.02 second(s) in Ring 1.21s
# Executed in 0.05 second(s) in Ring 1.20

/*--------------

profon()

o1 = new stzString("_/♥\__/♥\__/♥♥__/♥\_")
o1.ReplaceXT(:Nth = 4, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.01 second(s)

/*--------------

profon()

o1 = new stzString("_♥♥\__/♥\__/♥\_")
o1.ReplaceXT(:First, "♥", :With = "/")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.01 second(s)

/*--------------

profon()

o1 = new stzString("_/♥\__/♥\__/♥♥_")
o1.ReplaceXT(:Last, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.01 second(s)

/*--------------

profon()

o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~") # Or :AtPosition
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.01 second(s)

/*--------------

profon()

o1 = new stzString("~♥/♥\~♥")
o1.ReplaceXT("♥", :AtPositions = [2, 7], :With = "~") # Or :AtPositions
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.01 second(s)

/*----------------

profon()

o1 = new stzString("bla bla <<♥♥♥>> and bla!")
o1.ReplaceXT( [], :BoundedBy = ["<<",">>"], :With = "bla" )
#--> bla bla <<bla>> and bla!

? o1.Content()

proff()
#--> Executed in 0.04 second(s)

/*============ #narration ReplaceXT( ..., In = ..., :With = ... )

profon()

# Suppose you have this string:

o1 = new stzString("*** Ring programmin* language ***")

# As you see, the substring "programmin*" contains a
# misspelled char at the end (the "*").

# Let's try to fix it.

# You make think that replacing the "*" by "g" solves it:

o1.Replace("*", :With = "g")
? o1.Content()
#--> ggg Ring programing language ggg

# but it doesn't! Because all the other "*"s are also replaced!

# To this particular situation, Softanza has an anwser:
# the ReplaceIn() function:

o1 = new stzString("*** Ring programmin* language ***")

? o1.ReplaceXT("*", :In = "programmin*", :With = "g")
? o1.Content()
#--> *** Ring programming language ***

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*========== REMOVE BETWEEN

StartProfiler()

	o1 = new stzString("__/♥\__")

	o1.RemoveBetween("/", "\")
	? o1.Content()
	#--> __/\__

StopProfiler()
# Executed in 0.01 second(s)

/*---------

StartProfiler()

	o1 = new stzString("__/♥\__")

	o1.RemoveBetweenIB("/", "\") # ..XT() -> Bounds are also removed
	? o1.Content()
	#--> ____

StopProfiler()
# Executed in 0.01 second(s)

/*==================

profon()

o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedBy(["/", "/"], "bla")
? o1.Content()
#--> bla bla /bla/ and /bla/!

o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedByIB(["/", "/"], "bla")
? o1.Content()
#--> bla bla bla and bla!

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19
 
/*----------------

profon()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
? o1.Content()
#--> bla bla /bla/ and bla!

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedByIB = '/', :With = "bla" )
? o1.Content()
#--> bla bla bla and bla!

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.19

/*================ Find and AntiFind

profon()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*----------------

profon()

o1 = new stzList([ 1, 2, 3 , "*", 5, 6, "*", 8 ])

? @@( o1.SplitAt("*") )
#--> [ [ 1, 2, 3 ], [ 5, 6 ], [ 8 ] ]

? @@( o1.SplitAtZZ("*") ) + NL
#--> [ [ 1, 3 ], [ 5, 6 ], [ 8, 8 ] ]

? @@( o1.AntiPositions([ 4, 7 ]) )
#--> [ 1, 2, 3, 5, 6, 8 ]

? @@( o1.AntiPositionsZZ([ 4, 7 ]) )
# [ [ 1, 3 ], [ 5, 6 ], [ 8, 8 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzList([ 1, 2, 3, "ring", 5, 6, 7 ])

? @@( o1.AntiFind("ring") )
#--> [ 1, 2, 3, 5, 6, 7 ]

? @@( o1.AntiFindZZ("ring") )
#--> [ [ 1, 3 ], [ 5, 7 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*----------------

profon()
#                   1  4  78
o1 = new stzString("...ring...")

? o1.FindFirst("ring")
#--> 4

? @@( o1.FindAsSection("ring") )
#--> [ 4, 7 ]

? @@( o1.AntiFind("ring") )
#--> [ 1, 2, 3, 8, 9, 10 ]

? @@( o1.AntiFindAsSections("ring") )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*---------------- Sections and AntiSections

profon()

o1 = new stzString("^^^456---012...")

? o1.Sections([ [4, 6], [10, 12] ])
#--> [ "456", "012" ]

? o1.AntiSections([ [4, 6], [10, 12] ])
#--> [ "^^^", "---", "..." ]

? @@( o1.FindAsSections([ "456", "012" ]) )
#--> [ [ 4, 6 ], [ 10, 12 ] ]

? @@( o1.AntiFindAsSections([ "456", "012" ]) )
#--> [ [ 1, 3 ], [ 7, 9 ], [ 13, 15 ] ]

? @@( o1.AntiSectionsZ([ [4, 6], [10, 12] ]) )
#--> [ [ "^^^", [ 1, 3 ] ], [ "---", [ 7, 9 ] ], [ "...", [ 13, 15 ] ] ]

? @@( o1.AntiSectionsZZ([ [4, 6], [10, 12] ]) )
#--> [ [ "^^^", [ 1, 3 ] ], [ "---", [ 7, 9 ] ], [ "...", [ 13, 15 ] ] ]

proff()
# Executed in 0.07 second(s) in Ring 1.22
# Executed in 0.20 second(s) in Ring 1.20

/*-------------------

profon()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 20, 43 ], [ 67, 84 ] ]

? @@( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

proff()
# Executed in 0.15 second(s)
/*================ Find and AntiFind

profon()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

profon()
#                   1  4  78
o1 = new stzString("...ring...")

? o1.FindFirst("ring")
#--> 4

? @@( o1.FindAsSection("ring") )
#--> [ 4, 7 ]

? @@( o1.AntiFind("ring") )
#--> [1, 8]

? @@( o1.AntiFindAsSections("ring") )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18

/*---------------- Sections and AntiSections

profon()

o1 = new stzString("...456...012...")

? o1.Sections([ [4, 6], [10, 12] ])
#--> [ "456", "012" ]

? o1.AntiSections([ [4, 6], [10, 12] ])
#--> [ "...", "...", "..." ]

? @@( o1.FindAsSections([ "456", "012" ]) )
#--> [ [ 4, 6 ], [ 10, 12 ] ]

? @@( o1.AntiFindAsSections([ "456", "012" ]) )
#--> [ [ 1, 3 ], [ 7, 9 ], [ 13, 15 ] ]

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.20 second(s) in Ring 1.18

/*================ Find and AntiFind

profon()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

profon()
#                   1  4  78
o1 = new stzString("...ring...")

? o1.FindFirst("ring")
#--> 4

? @@( o1.FindAsSection("ring") )
#--> [ 4, 7 ]

? @@( o1.AntiFind("ring") )
#--> [1, 8]

? @@( o1.AntiFindAsSections("ring") )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()
# Executed in 0.12 second(s)

/*---------------- Sections and AntiSections

profon()

o1 = new stzString("...456...012...")

? o1.Sections([ [4, 6], [10, 12] ])
#--> [ "456", "012" ]

? o1.AntiSections([ [4, 6], [10, 12] ])
#--> [ "...", "...", "..." ]

? @@( o1.FindAsSections([ "456", "012" ]) )
#--> [ [ 4, 6 ], [ 10, 12 ] ]

? @@( o1.AntiFindAsSections([ "456", "012" ]) )
#--> [ [ 1, 3 ], [ 7, 9 ], [ 13, 15 ] ]

proff()
# Executed in 0.20 second(s)

/*------------------- FindAsSections() and AntiFindAsSections()

profon()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 20, 43 ], [ 67, 84 ] ]

? @@( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

proff()
# Executed in 0.15 second(s)

/*================= BOUNDEDBY

profon()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedBy("&") )
#--> [ "^^^", "...", "vvv", "..." ]

? @@( o1.BoundedByIB("&") )
#--> [ "&^^^&", "&...&", "&vvv&", "&...&" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.10 second(s) in ring 1.18

/*----------------

profon()

#                   ..3...7..0...4..7...1..4...8..  
o1 = new stzString("..&^^^&..&^^^&..&---&..&---&..")

? @@NL( o1.BoundedByZ("&") ) + NL
#--> [
#	[ "^^^", 4 ],
#	[ "..", 8 ],
#	[ "^^^", 11 ],
#	[ "..", 15 ],
#	[ "---", 18 ],
#	[ "..", 22 ],
#	[ "---", 25 ]
# ]

? @@NL( o1.BoundedByZZ("&") )
#--> [
#	[ "^^^", [ 4, 6 ] ],
#	[ "..", [ 8, 9 ] ],
#	[ "^^^", [ 11, 13 ] ],
#	[ "..", [ 15, 16 ] ],
#	[ "---", [ 18, 20 ] ],
#	[ "..", [ 22, 23 ] ],
#	[ "---", [ 25, 27 ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.18 second(s) in Ring 1.18

/*----------------

profon()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedBy("&") )
#--> [ 5, 9, 13, 17 ]

? @@( o1.FindAnyBoundedByIB("&") ) + NL
#--> [ 4, 8, 12, 16 ]

#--

? @@( o1.FindAnyBoundedByZZ("&") )
#--> [ [ 5, 7 ], [ 9, 11 ], [ 13, 15 ], [ 17, 19 ] ]

? @@( o1.FindAnyBoundedByIBZZ("&") ) + NL
#--> [ [ 4, 8 ], [ 8, 12 ], [ 12, 16 ], [ 16, 20 ] ]

#--

? @@( o1.BoundedBy("&") )
#--> [ "^^^", "...", "vvv", "..." ]

? @@( o1.BoundedByIB("&") )
#--> [ "&^^^&", "&...&", "&vvv&", "&...&" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*----------------

profon()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByIBZ("&") )
#--> [ [ "&^^^&", 4 ], [ "&vvv&", 12 ] ]

? @@( o1.BoundedByIBZZ("&") )
#--> [ [ "&^^^&", [ 4, 8 ] ], [ "&vvv&", [ 12, 16 ] ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-------------------

profon()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.SubStringsBoundedBy('"') )
#--> [
#	'<    leave spaces    >',
#	'< leave spaces >'
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*===================

profon()

? Q([ "I ", "believe ", "in ","Ring!" ]).Reduce()
#--> I believe in Ring!

proff()
#--> Executed in 0.93

/*------ #TODO Check after Yield() is included
*
profon()

# To return the ascii code of each letter we say:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('ascii(@item) - 65')
#--> [ 17, 8, 13, 6, 8, 18, 14, 22, 18, 14, 12, 4 ]

# To return the letter along with the asscii code, we write:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]')
#--> [
#	[ "R", 17 ], [ "I", 17 ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]

proff()
# Executed in 3.02 second(s)

/*------ #TODO Idem

profon()

? Q(["A", "B", "C"]).YieldWXT('[ @item, ascii(@item) - 64 ]')

proff()

/*------ #TODO Idem

profon()

? @@( Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]') )
#--> [
#	[ "R", 17 ], [ "I", 8  ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]
proff()

/*=======

profon()
#                   1  4 6  9 1   567      456
o1 = new stzString("...<<ring>>...<<softanza>>...")

? @@( o1.FindAnyBoundedBy(["<<",">>"]) )
#--> [6, 17]

? @@( o1.FindAnyBoundedByAsSections(["<<",">>"]) )
#--> [ [6, 9], [17, 24] ]

? @@( o1.AnyBoundedBy(["<<",">>"]) )
#--> ["ring", "softanza"]

? @@( o1.FindAnyBoundedByIB(["<<",">>"]) )
#--> [4, 15]

? @@( o1.FindAnyBoundedByAsSectionsIB(["<<",">>"]) )
#--> [ [4, 11], [15, 26] ]

? @@( o1.AnyBoundedByIB(["<<",">>"]) )
#--> ["<<ring>>", "<<softanza>>"]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.25 second(s) in Ring 1.18

/*------------

profon()
#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindFirst("<<<")
#--> 4

? @@( o1.FindFirstAsSection("<<<") )
#--> [4, 6]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*------------

profon()

#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindLast("<<<")
#--> 9

? @@( o1.FindLastAsSection("<<<") )
#--> [9, 11]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*------------

profon()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
? o1.FindPrevious("<<<", :StartingAt = 11)
#--> 4

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*------------ #TODO #narration BOUNDEDBY() VS BETWEEN()

profon()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")


? o1.BoundedBy([ "<<<", ">>>" ])
#--> ["ring", "softanza"]

? o1.Between("<<<", ">>>")
#--> "ring>>>___<<<softanza"

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*------------

StartProfiler()

o1 = new stzString('This[@i] = This[@i +   1] + @i -    2')
? o1.NumbersAfter("@i")
#--> [ "1", "-2" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.18

/*------------

profon()

o1 = new stzString("+10,")
? @@( o1.Numbers() )
#--> [ "10" ]

o1 = new stzString("+10,  12;kdjf")
? @@( o1.Numbers() )
#--> [ "10", "12" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*------------

profon()

o1 = new stzString(" @i + 10, @i- 125, e11")
? @@( o1.Numbers() ) + NL

? @@( o1.NumbersComingAfter("@i") )
#--> [ "+10", "-125", "11" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.18

/*------------

profon()

o1 = new stzString("emm +   12  456.50 emm 11. and -   4.12_")
? @@( o1.Numbers() )
#--> [ "12", "456.50", "11.", "-4.12" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.18

/*------------

profon()

o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
? @@( o1.ExtractNumbers() )
#--> [ "18", "16", "17.80" ]

? o1.Content()
#--> Math: , Geo: , :Physics: 

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.18

/*======

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.NumberOfChars()
#--> 1914201

? oLargeStr.NumberOfLines()
#--> 34933

? oLargeStr.SplitQ(NL).NumberOfItems()
#--> 34933

StopProfiler()
# Executed in 0.51 second(s) in Ring 1.21
# Executed in 0.85 second(s) in Ring 1.18

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() )
#~> Contains ~2M chars (1.914.201 exactly)

? oLargeStr.Reverse()
? oLargeStr.Content()

StopProfiler()
# Executed in  8.50 second(s) in Ring 1.22
# Executed in 14.56 second(s) in Ring 1.17

/*=========== #ringqt #ERROR #TODO post it in the ring-group for correction
# Read this discussion:
# https://groups.google.com/d/msgid/ring-lang/c5f6c5ea-9afd-411d-8000-6a695d8db2f4n%40googlegroups.com?utm_medium=email&utm_source=footer

profon()

o1 = new QString2()
o1.append("•••••••••")

? o1.indexOf("", 0, _FALSE_)
#--> 0

? o1.indexOf("•", 0, _FALSE_)
#--> 0

proff()

/*-----------

profon()

o1 = new stzString("•••••••••")

? o1.Contains("")
#--> _FALSE_

? o1.Contains("•")
#--> _TRUE_

proff()

/*-----------

profon()

# Testing extreme cases in FindNthNext()/FindNthPrevious on a small string

StartProfiler()
#                   .2....7.9
o1 = new stzString("•••••••••")

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("x", :StartingAt = 1)
#--> 0

? o1.FindNext("•", :startingAt = 5)
#--> 6

? o1.FindNthNext(6, "•", :StartingAt = 3)
#--> 9

? o1.FindNthNext(5, "•", :StartingAt = 1)
#--> 6

? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

? o1.FindPrevious("•", :StartingAt = 5)
#--> 4

? o1.FindPrevious("•", :StartingAt = 2)
#--> 1

? o1.FindNthPrevious(8, "•", :StartingAt = 9)
#--> 1

? o1.FindNthPrevious(3, "•", :StartingAt = 4)
#--> 1

StopProfiler()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18

/*-----------

# Testing FindNthNext()/FindNthPrevious
# on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("ARABIC HA", :StartingAt = 1)
#--> 110819

? o1.FindNthNext(6, "ARABIC", :StartingAt = 3)
#--> 106564

? o1.FindNthNext(12, "HAN", :StartingAt = 250_000)
#--> 300643

? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 2)
#--> 0

StopProfiler()
# Executed in 0.19 second(s) in Ring 1.21

/*-----------

# Testing FindLast() on a small string

StartProfiler()
#                    2    7
o1 = new stzString("•♥••••♥••")
? o1.FindLast("♥")
#--> 7

? o1.FindLast("_")
#--> 0

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

# Testing FindLast() on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars
? o1.Contains("جميل")
#--> _FALSE_

? o1.FindLast("جميل")
#--> _FALSE_

StopProfiler()
# Executed in 0.06 second(s) in Ring 1.21

/*============

profon()

o1 = new stzString("123456789")

? o1.FirstHalf()
#--> 1234
? o1.SecondHalf() + NL
#--> 56789

? o1.Halves() # Or Bisect()
#--> [ "1234", "56789" ]

? o1.FirstHalfXT()
#--> 12345
? o1.SecondHalfXT() + NL
#--> 6789

? o1.HalvesXT() # Or BisectXT()
#--> [ "12345", "6789" ]


proff()
# Executed in 0.02 second(s)

/*============

profon()
   
o1 = new stzString("123456789")

# FIRST HALF

	? o1.FirstHalf()
	#--> 1234

	? o1.FirstHalfXT()
	#--> 12345
	
	? @@( o1.FirstHalfZ() )
	#--> [ "1234", 1 ]

	? @@( o1.FirstHalfZZ() )
	#--> [ "1234", [ 1, 4 ] ]
	
	? @@( o1.FirstHalfXTZ() )
	#--> [ "12345", 1 ]

	? @@( o1.FirstHalfXTZZ() ) + NL
	#--> [ "12345", [ 1, 5 ] ]

# SECOND HALF

	? o1.SecondHalf()
	#--> 56789

	? o1.SecondHalfXT()
	#--> 6789
	
	? @@( o1.SecondHalfZ() )
	#--> [ "56789", 5 ]

	? @@( o1.SecondHalfZZ() )
	#--> [ "56789", [ 5, 9 ] ]
	
	? @@( o1.SecondHalfXTZ() )
	#--> [ "6789", 6 ]

	? @@( o1.SecondHalfXTZZ() ) + NL
	#--> [ "6789",  [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@( o1.Halves() )
	#--> [ "1234", "56789" ]

	? @@( o1.HalvesXT() )
	#--> [ "12345", "6789" ]

	? @@( o1.HalvesZ() )
	#--> [ [ "1234", 1 ], [ "56789", 5 ] ]

	? @@( o1.HalvesXTZ() )
	#--> [ [ "12345", 1 ], [ "6789", 6 ] ]

	? @@( o1.HalvesZZ() )
	#--> [ [ "1234", [ 1, 4 ] ], [ "56789", [ 5, 9 ] ] ]

	? @@( o1.HalvesXTZZ() )
	#--> [ [ "12345", [ 1, 5 ] ], [ "6789", [ 6, 9 ] ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*==============

profon()

#                      4     0     6    1
o1 = new stzString("---***---***---***---")

? o1.HowMany("***")
#--> 3

? o1.Nth(3, "***")
#--> 16

? o1.FindLast("***")
#--> 16

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*============= #perf

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.FindLast(";")
#--> 1897793

# Let's see the gains in performance between Ring 1.18 and Ring 1.22

? PerfGain100(12.99, 5.63) # Or simply PerfGain()
#--> 56.66%

? SpeedUpX(12.99, 5.63) # Or simply SpeedUp()
#--> 2.31X

StopProfiler()
# Executed in 5.63 second(s) in Ring 1.21
# Executed in 12.99 second(s) in Ring 1.18

/*----------- #perf

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? @@( oLargeStr.FindAll("ALIF") )
#--> [ 130655, 1714648, 1716479, 1718401 ]

? oLargeStr.Contains("ALIF")
#--> _TRUE_

? oLargeStr.FindFirst("ALIF")
#--> 130655

? oLargeStr.NumberOfOccurrence("ALIF")
#--> 4

? oLargeStr.FindNth(4, "ALIF")
#--> 1718401

? oLargeStr.FindLast("ALIF")
#--> 1718401

StopProfiler()
# Executed in 0.16 second(s) in Ring 1.21

/*----------- #perf

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.Contains("Plane 15 Private Use")
#--> _TRUE_

? oLargeStr.HowMany("Plane 15 Private Use") + NL
#--> 2

? oLargeStr.FindAll("Plane 15 Private Use")
#--> [ 1913993, 1914047 ]

? oLargeStr.FindFirst("Plane 15 Private Use") + NL
#--> 1913993

? oLargeStr.FindLast("Plane 15 Private Use")
#--> 1914047

StopProfiler()
#--> Executed in 0.12 second(s) in Ring 1.21

/*----------- #perf

StartProfiler()

#                    2    7
o1 = new stzString("•♥••••♥••")

? o1.FindNthW(2, '@char = "♥"')
#--> 7
# Executed in 0.13 second(s)

? o1.FindNthW(2, '@substring = "•♥•"')
#--> 6

StopProfiler()
#--> Executed in 0.25 second(s) in Ring 1.21

/*===========

StartProfiler()

? Q("RING").StringCase()
#--> :Uppercase

? Q("ring").StringCase()
#--> :Lowercase

? Q("Ring").StringCase()
#--> :Capitalcase

? Q("Ring is AWOSOME!").StringCase()
#--> :Hybridcase

StopProfiler()
# Executed in 0.28 second(s) in Ring 1.21

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Uppercased()
#--> I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").IsUppercase()
#--> _TRUE_

StopProfiler()
# Executed in 0.05 second(s) in Ring 1.21

/*----------

StartProfiler()

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").Lowercased()
#--> i believe in ring future and engage for it!

? Q("i believe in ring future and engage for it!").IsLowercase()
#--> _TRUE_

# As a side note, the last fuction used above (IsLowercase()) is
# misspelled (should be IsLowerCase() with an "r" after low),*
# but Softanza accepts it.

StopProfiler()
# Executed in 0.05 second(s) in Ring 1.21

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Capitalcased()
#--> I Believe In Ring Future And Engage For It!

? Q("I Believe In Ring Future And Engage For It!").IsCapitalcase()
#--> _TRUE_

StopProfiler()
# Executed in 0.07 second(s) in Ring 1.21

/*==================

profon()

o1 = new stzString("ABC*EF")
o1.QStringObject().replace(3, 1, "D")
? o1.Content()
#--> "ABCDEF"

proff()
# Executed in 0.01 second(s)

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")

o1.ReplaceCharAt( :Position = 4, :By = "D")
? o1.Content()
#--> "ABCDEF"

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")
o1.ReplaceSection( 4, 4, "D")
? o1.Content()
#--> ABCDEF

StopProfiler()
#--> Executed in 0.01 second(s)

/*===========

profon()

? Q("121212").IsMadeOf("12")
#--> _TRUE_

? Q("121212").IsMadeOf([ "1", "2" ])
#--> _TRUE_

? Q("984332").IsMadeOfNumbers()
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18

/*-----------

profon()

o1 = new stzString("ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

? o1.Lines()[3]
#--> "123346"

? Q( o1.Lines()[3] ).IsMadeOfNumbers()
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.18

/*-----------

profon()

o1 = new stzString("

ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332

")

? @@( o1.TrimQ().
	LinesQ().
	RemoveWXTQ("Q(@char).IsNumberInString()").
	Content()
)
#--> [ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*------

profon()

? @replace("صباح الخير أصدقائي", "خير", "نور")
#o--> صباح النور أصدقائي

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----------- #qt Issue in replacing empty substrings

profon()

oQStr = new QString2()

oQStr.append("Ring language")
oQStr.replace_2("ing", "uby", _FALSE_)
? QStringToString(oQStr) # A Softanza function
#--> Ruby language

oQStr.replace_2("", 'any', _FALSE_)
? QStringToString(oQStr)
#--> anylanyaanynanyganyuanyaanyganyeany

str = "Ring Language"
? substr(str, "", "any")
#--> ring message: Bad paramater value!

proff()

/*----------- #ring

profon()

? @@( substr("", 1, 1) )
#--> ""

? substr("blablabla", "")
#--> 1

? ring_substr1("blablabla", "")
#--> 0

proff()

/*-----------

profon()

o1 = new stzString(" isNumber( 0+  @item  ) ")

? @@( o1.FindZZ("") )
#--> []

o1.Replace("", "any")
? o1.Content()
#--> " isNumber( 0+  @item  ) "

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

profon()

o1 = new stzString(" isNumber( 0+  @item  ) ")
o1.ReplaceMany([ "" ], 'any')

? o1.Content()
#--> " isNumber( 0+  @item  ) "

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

profon()

o1 = new stzString(" isNumber( 0+  @item  ) ")
? o1.ReplaceManyCSQ([
	" @position ", " @CurrentPosition ",
	" @Current@i ", " @CurrentI ",
	" @EachPosition ", " @EachI " ],

	:By = " @i ", :CS = _FALSE_).Content()

#--> " isNumber( 0+  @item  ) "

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

profon()

o1 = new stzCCode("isNumber(0+ @item)")
o1.Transpile()
? o1.Content()
#--> isnumber( 0+  this[@i]  )

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*-----------

profon()

o1 = new stzList([
	"ABCDEF",
	"GHIJKL",
	"123346",
	"MNOPQU",
	"RSTUVW",
	"984332"
])

? o1.FindWXT(' @IsNumberInString(@item) ')
#--> [ 3, 6 ]

proff()
# Executed in 0.13 second(s) in Ring 1.22

/*-----------

StartProfiler()

o1 = new stzString("

ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332

")

? o1.TrimQ().LinesQ().RemoveWXTQ(' Q(@line).IsMadeOfNumbers() ').Content()

#-->
# "ABCDEF
#  GHIJKL
#  MNOPQU
#  RSTUVW"

StopProfiler()
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.19

/*=============

StartProfiler()

o1 = new stzString("I love <<Ring>> and <<Softanza>>!")

# Finding the positions of substrings enclosed between << and >>

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [10, 23]

	# Returning the same result but as sections
	? @@( o1.FindAnyBoundedByAsSections([ "<<",">>"] ) ) # Or simply FindAnyBoundedByZZ()
	#--> [ [10, 13], [23, 30] ]

	# Getting the substrings themselves

	? @@( o1.AnyBoundedBy([ "<<",">>" ]) ) # Or SubStringsBoundedBy([ "<<", :And = ">>" ])
	#--> [ "Ring", "Softanza" ]

# Now, we need to do the same thing but we want to return the
# bounding chars << and >> in the result as well. To do so,
# we can use the IB/extended form of the same functions like this:

? @@( o1.FindAnyBoundedByIB([ "<<",">>" ]) )
#--> [8, 21]

	? @@( o1.FindAnyBoundedByAsSectionsIB([ "<<", ">>" ]) ) # Or Simply FindAnyBoundedByZZ()
	#--> [ [ 8, 15 ], [ 21, 32 ] ]

	? @@( o1.AnyBoundedByIB([ "<<",">>" ]) ) # Or SubStringsBoundedByIB()
	#--> [ <<Ring>>, <<Softanza>> ]

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18

/*-----------

profon()

o1 = new stzString('[
	"1", "1",
		["2", "♥", "2"],
	"1",
		["2",
			["3", "♥",
				["4",
					["5", "♥"],
				"4",
					["5","♥"],
				"♥"],
			"3"]
		]

]')

? @@( o1.DeepFindBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 17, 29 ], [ 77, 84 ], [ 103, 109 ], [ 66, 119 ], [ 51, 128 ], [ 42, 132 ], [ 2, 135 ] ]

proff()
# Executed in 0.03 second(s)

/*=============

StartProfiler()

o1 = new stzString("99999999999")
o1.SpacifyChars()

? o1.Content()
#--> 9 9 9 9 9 9 9 9 9 9 9

StopProfiler()
# Executed in 0.01 second(s)

/*----------

profon()

o1 = new stzString("99999999999")
? o1.Spacified()
#--> 9 9 9 9 9 9 9 9 9 9 9 

? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

proff()
# Executed in 0.01 second(s)

/*----------

profon()

o1 = new stzString("99999999999")
o1.SpacifyXT( "_", 3, :Backward )

? o1.Content()
#--> 99_999_999_999

proff()
# Executed in 0.01 second(s)

/*----------

profon()

o1 = new stzString("99999999999")
o1.SpacifyXT( :Using = "_", :Step = 3, :Direction = :Backward )

? o1.Content()
#--> 99_999_999_999

proff()
# Executed in 0.02 second(s)

/*----------

profon()

o1 = new stzListOfNumbers([ 3, 7, 12, 15 ])

? @@( o1.ToSections() ) # Or Sectioned()
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 12 ], [ 13, 15 ] ]

proff()
#--> Executed in 0.02 second(s).

/*----------

profon()

o1 = new stzListOfNumbers([ 1, 3, 7, 12, 15 ])

? @@( o1.ToSections() )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 12 ], [ 13, 15 ] ]

proff()
#--> Executed in 0.02 second(s).

/*----------

profon()

o1 = new stzString("123456789")

? o1.SplitToPartsOfSizes([ 3, 4, 2 ])
#--> [ "123", "4567", "89" ]

# Or simply

? o1 / [ 3, 4, 2 ]
#--> #--> [ "123", "4567", "89" ]

proff()
# Executed in 0.01 second(s).

/*========

profon()

o1 = new stzString("99999999999")

o1.SpacifyXT( " ", 3, :Backward )
? o1.Content() + NL
#--> 99 999 999 999

proff()
# Executed in 0.01 second(s).

/*---

profon()

o1 = new stzString("99999999999")
o1.SpacifyXT( :Using = " ", :Step = 3, :Going = :Backward )
? o1.Content()
#--> 99 999 999 999

proff()
# Executed in 0.03 second(s).

/*-----------

StartProfiler()

o1 = new stzString("999999999999")
o1.SpacifyXT( [ " ", "." ], [ 3, 2 ], :Backward )
? o1.Content()
#--> 999 999 999 999

o1 = new stzString("999999999999")
o1.SpacifyXT( " ", [ 3, 2 ], :Backward )
? o1.Content()
#--> 999 999 999 999

o1 = new stzString("999999999999")
o1.SpacifyXT( " ", 3, [ :Forward, :Backward ] )
? o1.Content()
#--> 999 999 999 999

StopProfiler()
# Executed in 0.05 second(s).

/*-----------

profon()

? Q( :Step = [ 3, :Andthen = 2 ] ).IsStepNamedParam()
#--> 1

? Q( :Step = [ 3, :Andthen = 2 ] ).IsOneOfTheseNamedParams([ :Step, :Stepping, :EachNChars ])
#--> 1

proff()
# Executed in 0.01 second(s).

/*-----------

profon()

o1 = new stzString("999999999999")
o1.UpdateWith("999 999 999.999")
? o1.Content()

proff()
# Executed in 0.01 second(s).

/*-----------

StartProfiler()

o1 = new stzString("9999999999999999")

o1.SpacifyXT(
	:Separator = [ " ", :AndThen = "." , :LastNChars = 7 ],
	:Step      = [ 3, :AndThen = 2 ],
	:Direction = [ :Backward, :AndThen = :Forward ]
)

? o1.Content()
#--> 999 999 999.99 99 99 9

proff()
# Executed in 0.03 second(s).

/*-----------

profon()

? Q("123456789050").SpacifiedXT(

    :Separator	= [ ",", "." , :LastNChars = 3 ],
    :Step 	= [ 3, 0 ], 
    :Direction 	= :Backward

)
#--> 123,456,789.050

proff()
# Executed in 0.03 second(s).

/*-----------

StartProfiler()

o1 = new stzString("12345269775114")

o1.SpacifyXT(
	[ " ", ".", :LastChars = 6 ], [ 3, 2 ], :Backward
)

? o1.Content()
#--> 12 345 269.77 51 14

proff()
# Executed in 0.03 second(s).

/*-----------

StartProfiler()

o1 = new stzString("9999999999")

o1.SpacifyXT(
	:Using     = [ " ", :AndThen = ".", :LastNChars = 2 ],
	:Step      = [ 3, 2 ],
	:Direction = [ :Backward, :AndThen = 'forward' ]
)

? o1.Content()
#--> 99 999 999.99

proff()
# Executed in 0.03 second(s).

/*-----------

StartProfiler()

o1 = new stzString("999999999999")

o1.SpacifyXT(
	:Using     = [ " ", "." ],
	:Step      = [ 3, 	  :AndThen = 2, :LastNChars = 5	],
	:Direction = [ :Backward, :AndThen = 'forward' ]
)

? o1.Content()
#--> 9 999 999.99 99 9

proff()
# Executed in 0.03 second(s).

/*----------

StartProfiler()

o1 = new stzString("99999999999999")
o1.SpacifyXT(
	:Using     = [ " ", :AndThen = ".", :LastNChars = 6 ],
	:Step      = [ 2, :AndThen = 3],
	:Direction = :Backward
)

? o1.Content()
#--> 99 99 99 99.999 999

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.21

/*==============

profon()

o1 = new stzListOfNumbers([ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ])
? @@( o1.ContigToSections() )
#--> [ [ 3, 5 ], [ 7, 9 ], [ 11, 11 ], [ 14, 15 ], [ 20, 20 ] ]

proff()
# Executed in 0.02 second(s).

/*--------------

profon()
#                   1234567890123457890
o1 = new stzString("ABBBBbbbbCCcFFFaABCC")

? @@( o1.FindDupSecutiveChars() ) + NL
#--> [ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ]

? @@( o1.FindDupSecutiveCharsZZ() ) + NL
#--> [ [ 3, 5 ], [ 7, 9 ], [ 11, 11 ], [ 14, 15 ], [ 20, 20 ] ]

proff()
# Executed in 0.02 second(s).

/*--------------

profon()

o1 = new stzString("phpringringringpythonrubyruby")
#		       ↑   ↑   ↑  ↑
#                      4   8   12 15

? @@( o1.FindDupSecutiveSubString("ring") ) + NL
#--> [ 8, 12 ]

? @@( o1.FindDupSecutiveSubStringZZ("ring") ) + NL
#--> [ [ 8, 11 ], [ 12, 15 ] ]

? @@( o1.DupSecutiveSubStringZ("ring") ) + NL
#--> [ "ring", [ 8, 12 ] ]

? @@( o1.DupSecutiveSubStringZZ("ring") )
#--> [ "ring", [ [ 8, 11 ], [ 12, 15 ] ] ]

proff()
# Executed in 0.04 second(s).

#---------

profon()

o1 = new stzString("phpringringringpythonrubyruby")

? @@( o1.FindDupSecutiveSubStrings() ) + NL
#--> [ 9, 10, 26, 11, 8, 12 ]

? @@( o1.FindDupSecutiveSubStringsZZ() ) + NL
#--> [ [ 9, 12 ], [ 10, 13 ], [ 26, 29 ], [ 11, 14 ], [ 8, 11 ], [ 12, 15 ] ]

? @@( o1.DupSecutiveSubStrings() ) + NL
#--> [ "ingr", "ngri", "ruby", "grin", "ring" ]

? @@NL( o1.DupSecutiveSubStringsZ() ) + NL
#--> [
#	[ "ingr", [ 9 ] ],
#	[ "ngri", [ 10 ] ],
#	[ "ruby", [ 26 ] ],
#	[ "grin", [ 11 ] ],
#	[ "ring", [ 8, 12 ] ]
# ]

? @@NL( o1.DupSecutiveSubStringsZZ() )
#--> [
#	[ "ingr", [ [ 9, 12 ] ] ],
#	[ "ngri", [ [ 10, 13 ] ] ],
#	[ "ruby", [ [ 26, 29 ] ] ],
#	[ "grin", [ [ 11, 14 ] ] ],
#	[ "ring", [ [ 8, 11 ], [ 12, 15 ] ] ]
# ]

o1.RemoveDupSecutiveSubStrings()
? o1.Content()

proff()
# Executed in 0.17 second(s).

/*-------------

profon()

aSections = [ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ]

o1 = new stzListOfSections(aSections)
o1.MergeOverlapping()
? @@( o1.Content() )
#--> [ [ 8, 15 ], [ 26, 29 ] ]

proff()
# Executed in 0.04 second(s).

/*-------------

profon()

o1 = new stzString("PhpRingRingRingPythonRubyRuby")

aSections = [ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ]

o1.RemoveSections(aSections)
? o1.Content()

proff()

/*=============

profon()

o1 = new stzString("phpringringringpythonrubyruby")

? o1.NumberOfConsecutiveSubStringsOfNChars(4) + NL
#--> 26

? o1.ConsecutiveSubStringsOfNChars(4)
#--> [
#	"phpr", "ingr", "ingr", "ingp", "ytho", "nrub", "yrub",
#	"hpri", "ngri", "ngri", "ngpy", "thon", "ruby", "ruby",
#	"prin", "grin", "grin", "gpyt", "honr", "ubyr", "ring",
#	"ring", "ring", "pyth", "onru", "byru"
# ]


? o1.FindConsecutiveSubStringsOfNChars(4)
#--> [ 1, 2, 3, 4 ]

? @@NL( o1.FindConsecutiveSubStringsOfNCharsZZ(4) ) + NL
#--> [
#	[ 1, 4 ], [ 5, 8 ], [ 9, 12 ], [ 13, 16 ], [ 17, 20 ], [ 21, 24 ], [ 25, 28 ],
#	[ 2, 5 ], [ 6, 9 ], [ 10, 13 ], [ 14, 17 ], [ 18, 21 ], [ 22, 25 ], [ 26, 29 ],
#	[ 3, 6 ], [ 7, 10 ], [ 11, 14 ], [ 15, 18 ], [ 19, 22 ], [ 23, 26 ],
#	[ 4, 7 ], [ 8, 11 ], [ 12, 15 ], [ 16, 19 ], [ 20, 23 ], [ 24, 27 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZ(4) ) + NL
#--> [
#	[ "phpr", 1 ], [ "ingr", 5 ], [ "ingr", 9 ], [ "ingp", 13 ], [ "ytho", 17 ],
#	[ "nrub", 21 ], [ "yrub", 25 ], [ "hpri", 2 ], [ "ngri", 6 ], [ "ngri", 10 ],
#	[ "ngpy", 14 ], [ "thon", 18 ], [ "ruby", 22 ], [ "ruby", 26 ], [ "prin", 3 ],
#	[ "grin", 7 ], [ "grin", 11 ], [ "gpyt", 15 ], [ "honr", 19 ], [ "ubyr", 23 ],
#	[ "ring", 4 ], [ "ring", 8 ], [ "ring", 12 ], [ "pyth", 16 ], [ "onru", 20 ],
#	[ "byru", 24 ]
# ]

? @@( o1.ConsecutiveSubStringsOfNCharsZZ(4) )
#--> [
#	[ "phpr", [ 1, 4 ] ], [ "ingr", [ 5, 8 ] ], [ "ingr", [ 9, 12 ] ],
#	[ "ingp", [ 13, 16 ] ], [ "ytho", [ 17, 20 ] ], [ "nrub", [ 21, 24 ] ],
#	[ "yrub", [ 25, 28 ] ], [ "hpri", [ 2, 5 ] ], [ "ngri", [ 6, 9 ] ],
#	[ "ngri", [ 10, 13 ] ], [ "ngpy", [ 14, 17 ] ], [ "thon", [ 18, 21 ] ],
#	[ "ruby", [ 22, 25 ] ], [ "ruby", [ 26, 29 ] ], [ "prin", [ 3, 6 ] ],
#	[ "grin", [ 7, 10 ] ], [ "grin", [ 11, 14 ] ], [ "gpyt", [ 15, 18 ] ],
#	[ "honr", [ 19, 22 ] ], [ "ubyr", [ 23, 26 ] ], [ "ring", [ 4, 7 ] ],
#	[ "ring", [ 8, 11 ] ], [ "ring", [ 12, 15 ] ], [ "pyth", [ 16, 19 ] ],
#	[ "onru", [ 20, 23 ] ], [ "byru", [ 24, 27 ] ] 
# ]

proff()
# Executed in 0.02 second(s).

/*-----------

profon()

o1 = new stzString("phpringringringpythonrubyruby")

? o1.NumberOfConsecutiveSubStrings() + NL
#--> 315

? @@( o1.ConsecutiveSubStrings() ) + NL
#--> [
#	"p", "h", "p", "r", "i", "n", "g", "r", "i", "n", "g",
#	"r", "i", "n", "g", "p", "y", "t", "h", "o", "n", "r",
#	"u", "b", "y", "r", "u", "b", "y",
#
#	"ph", "pr", "in", "gr", "in", "gr", "in", "gp", "yt",
#	"ho", "nr", "ub", "yr", "ub", "hp", "ri", "ng", "ri",
#	"ng", "ri", "ng", "py", "th", "on", "ru", "by", "ru",
#	"by",
#
#	"php", "rin", "gri", "ngr", "ing", "pyt", "hon", "rub",
#	"yru", "hpr", "ing", "rin", "gri", "ngp", "yth", "onr",
#	"uby", "rub", "pri", "ngr", "ing", "rin", "gpy", "tho",
#	"nru", "byr", "uby", "phpr", "ingr", "ingr",
#
#	"ingp", "ytho", "nrub", "yrub", "hpri", "ngri", "ngri",
#	"ngpy", "thon", "ruby", "ruby", "prin", "grin", "grin",
#	"gpyt", "honr", "ubyr", "ring", "ring", "ring", "pyth",
#	"onru", "byru",
#
#	"phpri", "ngrin", "gring", "pytho", "nruby", "hprin",
#	"gring", "ringp", "ython", "rubyr", "pring", "ringr",
#	"ingpy", "thonr", "ubyru", "ringr", "ingri", "ngpyt",
#	"honru", "byrub", "ingri", "ngrin", "gpyth", "onrub",
#	"yruby",
#
#	"phprin", "gringr", "ingpyt", "honrub", "hpring", "ringri",
#	"ngpyth", "onruby", "pringr", "ingrin", "gpytho", "nrubyr",
#	"ringri", "ngring", "python", "rubyru", "ingrin", "gringp",
#	"ythonr", "ubyrub", "ngring", "ringpy", "thonru", "byruby",
#
#	"phpring", "ringrin", "gpython", "rubyrub", "hpringr", "ingring",
#	"pythonr", "ubyruby", "pringri", "ngringp", "ythonru", "ringrin",
#	"gringpy", "thonrub", "ingring", "ringpyt", "honruby", "ngringr",
#	"ingpyth", "onrubyr", "gringri", "ngpytho", "nrubyru",
#
#	"phpringr", "ingringp", "ythonrub", "hpringri", "ngringpy",
#	"thonruby", "pringrin", "gringpyt", "honrubyr", "ringring",
#	"ringpyth", "onrubyru", "ingringr", "ingpytho", "nrubyrub",
#	"ngringri", "ngpython", "rubyruby", "gringrin", "gpythonr",
#	"ringring", "pythonru",
#
#	"phpringri", "ngringpyt", "honrubyru", "hpringrin", "gringpyth",
#	"onrubyrub", "pringring", "ringpytho", "nrubyruby", "ringringr",
#	"ingpython", "ingringri", "ngpythonr", "ngringrin", "gpythonru",
#	"gringring", "pythonrub", "ringringp", "ythonruby", "ingringpy",
#	"thonrubyr",
#
#	"phpringrin", "gringpytho", "hpringring", "ringpython", "pringringr",
#	"ingpythonr", "ringringri", "ngpythonru", "ingringrin", "gpythonrub",
#	"ngringring", "pythonruby", "gringringp", "ythonrubyr", "ringringpy",
#	"thonrubyru", "ingringpyt", "honrubyrub", "ngringpyth", "onrubyruby",
#
#	"phpringring", "ringpythonr", "hpringringr", "ingpythonru", "pringringri",
#	"ngpythonrub", "ringringrin", "gpythonruby", "ingringring", "pythonrubyr",
#	"ngringringp", "ythonrubyru", "gringringpy", "thonrubyrub", "ringringpyt",
#	"honrubyruby", "ingringpyth", "ngringpytho", "gringpython",
#
#	"phpringringr", "ingpythonrub", "hpringringri", "ngpythonruby",
#	"pringringrin", "gpythonrubyr", "ringringring", "pythonrubyru",
#	"ingringringp", "ythonrubyrub", "ngringringpy", "thonrubyruby",
#	"gringringpyt", "ringringpyth", "ingringpytho", "ngringpython",
#	"gringpythonr", "ringpythonru",
#
#	"phpringringri", "ngpythonrubyr", "hpringringrin", "gpythonrubyru",
#	"pringringring", "pythonrubyrub", "ringringringp", "ythonrubyruby",
#	"ingringringpy", "ngringringpyt", "gringringpyth", "ringringpytho",
#	"ingringpython", "ngringpythonr", "gringpythonru", "ringpythonrub",
#	"ingpythonruby", "phpringringrin",
#
#	"gpythonrubyrub", "hpringringring", "pythonrubyruby", "pringringringp",
#	"ringringringpy", "ingringringpyt", "ngringringpyth", "gringringpytho",
#	"ringringpython", "ingringpythonr", "ngringpythonru", "gringpythonrub",
#	"ringpythonruby", "ingpythonrubyr", "ngpythonrubyru"
# ]

? @@( o1.FindConsecutiveSubStrings() ) + NL
#--> [
#	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
#	13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
#	23, 24, 25, 26, 27, 28, 29
# ]

? @@( o1.FindconsecutiveSubStringsZZ() ) + NL
#--> [
#	[ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ],
#	[ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ], [ 13, 13 ],
#	[ 14, 14 ], [ 15, 15 ], [ 16, 16 ], [ 17, 17 ], [ 18, 18 ], [ 19, 19 ],
#	[ 20, 20 ], [ 21, 21 ], [ 22, 22 ], [ 23, 23 ], [ 24, 24 ], [ 25, 25 ],
#	[ 26, 26 ], [ 27, 27 ], [ 28, 28 ], [ 29, 29 ],
#
#	[ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ], [ 6, 7 ], [ 7, 8 ],
#	[ 8, 9 ], [ 9, 10 ], [ 10, 11 ], [ 11, 12 ], [ 12, 13 ], [ 13, 14 ],
#	[ 14, 15 ], [ 15, 16 ], [ 16, 17 ], [ 17, 18 ], [ 18, 19 ], [ 19, 20 ],
#	[ 20, 21 ], [ 21, 22 ], [ 22, 23 ], [ 23, 24 ], [ 24, 25 ], [ 25, 26 ],
#	[ 26, 27 ], [ 27, 28 ], [ 28, 29 ],
#
#	[ 1, 3 ], [ 2, 4 ], [ 3, 5 ], [ 4, 6 ], [ 5, 7 ], [ 6, 8 ], [ 7, 9 ],
#	[ 8, 10 ], [ 9, 11 ], [ 10, 12 ], [ 11, 13 ], [ 12, 14 ], [ 13, 15 ],
#	[ 14, 16 ], [ 15, 17 ], [ 16, 18 ], [ 17, 19 ], [ 18, 20 ], [ 19, 21 ],
#	[ 20, 22 ], [ 21, 23 ], [ 22, 24 ], [ 23, 25 ], [ 24, 26 ], [ 25, 27 ],
#	[ 26, 28 ], [ 27, 29 ],
#
#	[ 1, 4 ], [ 2, 5 ], [ 3, 6 ], [ 4, 7 ], [ 5, 8 ], [ 6, 9 ], [ 7, 10 ],
#	[ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 13, 16 ],
#	[ 14, 17 ], [ 15, 18 ], [ 16, 19 ], [ 17, 20 ], [ 18, 21 ], [ 19, 22 ],
#	[ 20, 23 ], [ 21, 24 ], [ 22, 25 ], [ 23, 26 ], [ 24, 27 ], [ 25, 28 ],
#	[ 26, 29 ],
#
#	[ 1, 5 ], [ 2, 6 ], [ 3, 7 ], [ 4, 8 ], [ 5, 9 ], [ 6, 10 ], [ 7, 11 ],
#	[ 8, 12 ], [ 9, 13 ], [ 10, 14 ], [ 11, 15 ], [ 12, 16 ], [ 13, 17 ],
#	[ 14, 18 ], [ 15, 19 ], [ 16, 20 ], [ 17, 21 ], [ 18, 22 ], [ 19, 23 ],
#	[ 20, 24 ], [ 21, 25 ], [ 22, 26 ], [ 23, 27 ], [ 24, 28 ], [ 25, 29 ],
#
#	[ 1, 6 ], [ 2, 7 ], [ 3, 8 ], [ 4, 9 ], [ 5, 10 ], [ 6, 11 ], [ 7, 12 ],
#	[ 8, 13 ], [ 9, 14 ], [ 10, 15 ], [ 11, 16 ], [ 12, 17 ], [ 13, 18 ],
#	[ 14, 19 ], [ 15, 20 ], [ 16, 21 ], [ 17, 22 ], [ 18, 23 ], [ 19, 24 ],
#	[ 20, 25 ], [ 21, 26 ], [ 22, 27 ], [ 23, 28 ], [ 24, 29 ],
#
#	[ 1, 7 ], [ 2, 8 ], [ 3, 9 ], [ 4, 10 ], [ 5, 11 ], [ 6, 12 ], [ 7, 13 ],
#	[ 8, 14 ], [ 9, 15 ], [ 10, 16 ], [ 11, 17 ], [ 12, 18 ], [ 13, 19 ],
#	[ 14, 20 ], [ 15, 21 ], [ 16, 22 ], [ 17, 23 ], [ 18, 24 ], [ 19, 25 ],
#	[ 20, 26 ], [ 21, 27 ], [ 22, 28 ], [ 23, 29 ],
#
#	[ 1, 8 ], [ 2, 9 ], [ 3, 10 ], [ 4, 11 ], [ 5, 12 ], [ 6, 13 ], [ 7, 14 ],
#	[ 8, 15 ], [ 9, 16 ], [ 10, 17 ], [ 11, 18 ], [ 12, 19 ], [ 13, 20 ],
#	[ 14, 21 ], [ 15, 22 ], [ 16, 23 ], [ 17, 24 ], [ 18, 25 ], [ 19, 26 ],
#	[ 20, 27 ], [ 21, 28 ], [ 22, 29 ],
#
#	[ 1, 9 ], [ 2, 10 ], [ 3, 11 ], [ 4, 12 ], [ 5, 13 ], [ 6, 14 ], [ 7, 15 ],
#	[ 8, 16 ], [ 9, 17 ], [ 10, 18 ], [ 11, 19 ], [ 12, 20 ], [ 13, 21 ],
#	[ 14, 22 ], [ 15, 23 ], [ 16, 24 ], [ 17, 25 ], [ 18, 26 ], [ 19, 27 ],
#	[ 20, 28 ], [ 21, 29 ],
#
#	[ 1, 10 ], [ 2, 11 ], [ 3, 12 ], [ 4, 13 ], [ 5, 14 ], [ 6, 15 ], [ 7, 16 ],
#	[ 8, 17 ], [ 9, 18 ], [ 10, 19 ], [ 11, 20 ], [ 12, 21 ], [ 13, 22 ],
#	[ 14, 23 ], [ 15, 24 ], [ 16, 25 ], [ 17, 26 ], [ 18, 27 ], [ 19, 28 ],
#	[ 20, 29 ],
#
#	[ 1, 11 ], [ 2, 12 ], [ 3, 13 ], [ 4, 14 ], [ 5, 15 ], [ 6, 16 ], [ 7, 17 ],
#	[ 8, 18 ], [ 9, 19 ], [ 10, 20 ], [ 11, 21 ], [ 12, 22 ], [ 13, 23 ],
#	[ 14, 24 ], [ 15, 25 ], [ 16, 26 ], [ 17, 27 ], [ 18, 28 ], [ 19, 29 ],
#
#	[ 1, 12 ], [ 2, 13 ], [ 3, 14 ], [ 4, 15 ], [ 5, 16 ], [ 6, 17 ], [ 7, 18 ],
#	[ 8, 19 ], [ 9, 20 ], [ 10, 21 ], [ 11, 22 ], [ 12, 23 ], [ 13, 24 ],
#	[ 14, 25 ], [ 15, 26 ], [ 16, 27 ], [ 17, 28 ], [ 18, 29 ],
#
#	[ 1, 13 ], [ 2, 14 ], [ 3, 15 ], [ 4, 16 ], [ 5, 17 ], [ 6, 18 ], [ 7, 19 ],
#	[ 8, 20 ], [ 9, 21 ], [ 10, 22 ], [ 11, 23 ], [ 12, 24 ], [ 13, 25 ],
#	[ 14, 26 ], [ 15, 27 ], [ 16, 28 ], [ 17, 29 ],
#
#	[ 1, 14 ], [ 2, 15 ], [ 3, 16 ], [ 4, 17 ], [ 5, 18 ], [ 6, 19 ], [ 7, 20 ],
#	[ 8, 21 ], [ 9, 22 ], [ 10, 23 ], [ 11, 24 ], [ 12, 25 ], [ 13, 26 ],
#	[ 14, 27 ], [ 15, 28 ], [ 16, 29 ]
# ]

? @@( o1.ConsecutiveSubStringsZ() ) + NL
#--> [
#	[ "p", 1 ], [ "hp", 2 ], [ "pri", 3 ], [ "ring", 4 ], [ "ingri", 5 ],
#	[ "ngring", 6 ], [ "gringri", 7 ], [ "ringring", 8 ], [ "ingringpy", 9 ],
#	[ "ngringpyth", 10 ], [ "gringpython", 11 ], [ "ringpythonru", 12 ],
#	[ "ingpythonruby", 13 ], [ "ngpythonrubyru", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ],
#	[ "rubyruby", 22 ], [ "ubyruby", 23 ], [ "byruby", 24 ],
#	[ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ], [ "by", 28 ],
#	[ "y", 29 ],
#
#	[ "ph", 1 ], [ "hpr", 2 ], [ "prin", 3 ], [ "ringr", 4 ], [ "ingrin", 5 ],
#	[ "ngringr", 6 ], [ "gringrin", 7 ], [ "ringringp", 8 ], [ "ingringpyt", 9 ],
#	[ "ngringpytho", 10 ], [ "gringpythonr", 11 ], [ "ringpythonrub", 12 ],
#	[ "ingpythonrubyr", 13 ], [ "ngpythonrubyrub", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ],
#	[ "by", 28 ],
#
#	[ "php", 1 ], [ "hpri", 2 ], [ "pring", 3 ], [ "ringri", 4 ], [ "ingring", 5 ],
#	[ "ngringri", 6 ], [ "gringring", 7 ], [ "ringringpy", 8 ], [ "ingringpyth", 9 ],
#	[ "ngringpython", 10 ], [ "gringpythonru", 11 ], [ "ringpythonruby", 12 ],
#	[ "ingpythonrubyru", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ], [ "uby", 27 ],
#
#	[ "phpr", 1 ], [ "hprin", 2 ], [ "pringr", 3 ], [ "ringrin", 4 ], [ "ingringr", 5 ],
#	[ "ngringrin", 6 ], [ "gringringp", 7 ], [ "ringringpyt", 8 ], [ "ingringpytho", 9 ],
#	[ "ngringpythonr", 10 ], [ "gringpythonrub", 11 ], [ "ringpythonrubyr", 12 ],
#	[ "ingpythonrubyrub", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ], [ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#	[ "ubyruby", 23 ], [ "byruby", 24 ], [ "yruby", 25 ], [ "ruby", 26 ],
#
#	[ "phpri", 1 ], [ "hpring", 2 ], [ "pringri", 3 ], [ "ringring", 4 ],
#	[ "ingringri", 5 ], [ "ngringring", 6 ], [ "gringringpy", 7 ], [ "ringringpyth", 8 ],
#	[ "ingringpython", 9 ], [ "ngringpythonru", 10 ], [ "gringpythonruby", 11 ],
#	[ "ringpythonrubyru", 12 ], [ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ],
#	[ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ],
#	[ "thonrubyruby", 18 ], [ "honrubyruby", 19 ], [ "onrubyruby", 20 ],
#	[ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ], [ "byruby", 24 ],
#	[ "yruby", 25 ],
#
#	[ "phprin", 1 ], [ "hpringr", 2 ], [ "pringrin", 3 ], [ "ringringr", 4 ],
#	[ "ingringrin", 5 ], [ "ngringringp", 6 ], [ "gringringpyt", 7 ],
#	[ "ringringpytho", 8 ], [ "ingringpythonr", 9 ], [ "ngringpythonrub", 10 ],
#	[ "gringpythonrubyr", 11 ], [ "ringpythonrubyrub", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ],
#	[ "byruby", 24 ],
#
#	[ "phpring", 1 ], [ "hpringri", 2 ], [ "pringring", 3 ], [ "ringringri", 4 ],
#	[ "ingringring", 5 ], [ "ngringringpy", 6 ], [ "gringringpyth", 7 ],
#	[ "ringringpython", 8 ], [ "ingringpythonru", 9 ], [ "ngringpythonruby", 10 ],
#	[ "gringpythonrubyru", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ], [ "ubyruby", 23 ],
#
#	[ "phpringr", 1 ], [ "hpringrin", 2 ], [ "pringringr", 3 ], [ "ringringrin", 4 ],
#	[ "ingringringp", 5 ], [ "ngringringpyt", 6 ], [ "gringringpytho", 7 ],
#	[ "ringringpythonr", 8 ], [ "ingringpythonrub", 9 ], [ "ngringpythonrubyr", 10 ],
#	[ "gringpythonrubyrub", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ], [ "rubyruby", 22 ],
#
#	[ "phpringri", 1 ], [ "hpringring", 2 ], [ "pringringri", 3 ], [ "ringringring", 4 ],
#	[ "ingringringpy", 5 ], [ "ngringringpyth", 6 ], [ "gringringpython", 7 ],
#	[ "ringringpythonru", 8 ], [ "ingringpythonruby", 9 ], [ "ngringpythonrubyru", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],
#	[ "onrubyruby", 20 ], [ "nrubyruby", 21 ],
#
#	[ "phpringrin", 1 ], [ "hpringringr", 2 ], [ "pringringrin", 3 ], [ "ringringringp", 4 ],
#	[ "ingringringpyt", 5 ], [ "ngringringpytho", 6 ], [ "gringringpythonr", 7 ],
#	[ "ringringpythonrub", 8 ], [ "ingringpythonrubyr", 9 ], [ "ngringpythonrubyrub", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ],
#	[ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ], [ "honrubyruby", 19 ],	[ "onrubyruby", 20 ],
#
#	[ "phpringring", 1 ], [ "hpringringri", 2 ], [ "pringringring", 3 ],
#	[ "ringringringpy", 4 ], [ "ingringringpyth", 5 ], [ "ngringringpython", 6 ],
#	[ "gringringpythonru", 7 ], [ "ringringpythonruby", 8 ], [ "ingringpythonrubyru", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#	[ "honrubyruby", 19 ],
#
#	[ "phpringringr", 1 ], [ "hpringringrin", 2 ], [ "pringringringp", 3 ],
#	[ "ringringringpyt", 4 ], [ "ingringringpytho", 5 ], [ "ngringringpythonr", 6 ],
#	[ "gringringpythonrub", 7 ], [ "ringringpythonrubyr", 8 ], [ "ingringpythonrubyrub", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ], [ "thonrubyruby", 18 ],
#
#	[ "phpringringri", 1 ], [ "hpringringring", 2 ], [ "pringringringpy", 3 ],
#	[ "ringringringpyth", 4 ], [ "ingringringpython", 5 ], [ "ngringringpythonru", 6 ],
#	[ "gringringpythonruby", 7 ], [ "ringringpythonrubyru", 8 ], [ "ingringpythonrubyruby", 9 ],
#	[ "ngringpythonrubyruby", 10 ], [ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ],
#	[ "ingpythonrubyruby", 13 ], [ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ],
#	[ "pythonrubyruby", 16 ], [ "ythonrubyruby", 17 ],
#
#	[ "phpringringrin", 1 ], [ "hpringringringp", 2 ], [ "pringringringpyt", 3 ],
#	[ "ringringringpytho", 4 ], [ "ingringringpythonr", 5 ], [ "ngringringpythonrub", 6 ],
#	[ "gringringpythonrubyr", 7 ], [ "ringringpythonrubyrub", 8 ],
#	[ "ingringpythonrubyruby", 9 ], [ "ngringpythonrubyruby", 10 ],
#	[ "gringpythonrubyruby", 11 ], [ "ringpythonrubyruby", 12 ], [ "ingpythonrubyruby", 13 ],
#	[ "ngpythonrubyruby", 14 ], [ "gpythonrubyruby", 15 ], [ "pythonrubyruby", 16 ]
# ]

? @@( o1.ConsecutiveSubStringsZZ() )
#--> [
#	[ "p", [ 1, 1 ] ], [ "hp", [ 2, 2 ] ], [ "pri", [ 3, 3 ] ], [ "ring", [ 4, 4 ] ],
#	[ "ingri", [ 5, 5 ] ], [ "ngring", [ 6, 6 ] ], [ "gringri", [ 7, 7 ] ],
#	[ "ringring", [ 8, 8 ] ], [ "ingringpy", [ 9, 9 ] ], [ "ngringpyth", [ 10, 10 ] ],
#	[ "gringpython", [ 11, 11 ] ], [ "ringpythonru", [ 12, 12 ] ],
#	[ "ingpythonruby", [ 13, 13 ] ], [ "ngpythonrubyru", [ 14, 14 ] ],
#	[ "gpythonrubyruby", [ 15, 15 ] ], [ "pythonrubyruby", [ 16, 16 ] ],
#	[ "ythonrubyruby", [ 17, 17 ] ], [ "thonrubyruby", [ 18, 18 ] ],
#	[ "honrubyruby", [ 19, 19 ] ], [ "onrubyruby", [ 20, 20 ] ],
#	[ "nrubyruby", [ 21, 21 ] ], [ "rubyruby", [ 22, 22 ] ], [ "ubyruby", [ 23, 23 ] ],
#	[ "byruby", [ 24, 24 ] ], [ "yruby", [ 25, 25 ] ], [ "ruby", [ 26, 26 ] ],
#	[ "uby", [ 27, 27 ] ], [ "by", [ 28, 28 ] ], [ "y", [ 29, 29 ] ],
#
#	[ "ph", [ 1, 2 ] ], [ "hpr", [ 2, 3 ] ], [ "prin", [ 3, 4 ] ], [ "ringr", [ 4, 5 ] ],
#	[ "ingrin", [ 5, 6 ] ], [ "ngringr", [ 6, 7 ] ], [ "gringrin", [ 7, 8 ] ],
#	[ "ringringp", [ 8, 9 ] ], [ "ingringpyt", [ 9, 10 ] ], [ "ngringpytho", [ 10, 11 ] ],
#	[ "gringpythonr", [ 11, 12 ] ], [ "ringpythonrub", [ 12, 13 ] ],
#	[ "ingpythonrubyr", [ 13, 14 ] ], [ "ngpythonrubyrub", [ 14, 15 ] ],
#	[ "gpythonrubyruby", [ 15, 16 ] ], [ "pythonrubyruby", [ 16, 17 ] ],
#	[ "ythonrubyruby", [ 17, 18 ] ], [ "thonrubyruby", [ 18, 19 ] ],
#	[ "honrubyruby", [ 19, 20 ] ], [ "onrubyruby", [ 20, 21 ] ],
#	[ "nrubyruby", [ 21, 22 ] ], [ "rubyruby", [ 22, 23 ] ], [ "ubyruby", [ 23, 24 ] ],
#	[ "byruby", [ 24, 25 ] ], [ "yruby", [ 25, 26 ] ], [ "ruby", [ 26, 27 ] ],
#	[ "uby", [ 27, 28 ] ], [ "by", [ 28, 29 ] ],
#
#	[ "php", [ 1, 3 ] ], [ "hpri", [ 2, 4 ] ], [ "pring", [ 3, 5 ] ],
#	[ "ringri", [ 4, 6 ] ], [ "ingring", [ 5, 7 ] ], [ "ngringri", [ 6, 8 ] ],
#	[ "gringring", [ 7, 9 ] ], [ "ringringpy", [ 8, 10 ] ], [ "ingringpyth", [ 9, 11 ] ],
#	[ "ngringpython", [ 10, 12 ] ], [ "gringpythonru", [ 11, 13 ] ],
#	[ "ringpythonruby", [ 12, 14 ] ], [ "ingpythonrubyru", [ 13, 15 ] ],
#	[ "ngpythonrubyruby", [ 14, 16 ] ], [ "gpythonrubyruby", [ 15, 17 ] ],
#	[ "pythonrubyruby", [ 16, 18 ] ], [ "ythonrubyruby", [ 17, 19 ] ],
#	[ "thonrubyruby", [ 18, 20 ] ], [ "honrubyruby", [ 19, 21 ] ],
#	[ "onrubyruby", [ 20, 22 ] ], [ "nrubyruby", [ 21, 23 ] ], [ "rubyruby", [ 22, 24 ] ],
#	[ "ubyruby", [ 23, 25 ] ], [ "byruby", [ 24, 26 ] ], [ "yruby", [ 25, 27 ] ],
#	[ "ruby", [ 26, 28 ] ], [ "uby", [ 27, 29 ] ],
#
#	[ "phpr", [ 1, 4 ] ], [ "hprin", [ 2, 5 ] ], [ "pringr", [ 3, 6 ] ],
#	[ "ringrin", [ 4, 7 ] ], [ "ingringr", [ 5, 8 ] ], [ "ngringrin", [ 6, 9 ] ],
#	[ "gringringp", [ 7, 10 ] ], [ "ringringpyt", [ 8, 11 ] ],
#	[ "ingringpytho", [ 9, 12 ] ], [ "ngringpythonr", [ 10, 13 ] ],
#	[ "gringpythonrub", [ 11, 14 ] ], [ "ringpythonrubyr", [ 12, 15 ] ],
#	[ "ingpythonrubyrub", [ 13, 16 ] ], [ "ngpythonrubyruby", [ 14, 17 ] ],
#	[ "gpythonrubyruby", [ 15, 18 ] ], [ "pythonrubyruby", [ 16, 19 ] ],
#	[ "ythonrubyruby", [ 17, 20 ] ], [ "thonrubyruby", [ 18, 21 ] ],
#	[ "honrubyruby", [ 19, 22 ] ], [ "onrubyruby", [ 20, 23 ] ],
#	[ "nrubyruby", [ 21, 24 ] ], [ "rubyruby", [ 22, 25 ] ], [ "ubyruby", [ 23, 26 ] ],
#	[ "byruby", [ 24, 27 ] ], [ "yruby", [ 25, 28 ] ], [ "ruby", [ 26, 29 ] ],
#
#	[ "phpri", [ 1, 5 ] ], [ "hpring", [ 2, 6 ] ], [ "pringri", [ 3, 7 ] ],
#	[ "ringring", [ 4, 8 ] ], [ "ingringri", [ 5, 9 ] ], [ "ngringring", [ 6, 10 ] ],
#	[ "gringringpy", [ 7, 11 ] ], [ "ringringpyth", [ 8, 12 ] ],
#	[ "ingringpython", [ 9, 13 ] ], [ "ngringpythonru", [ 10, 14 ] ],
#	[ "gringpythonruby", [ 11, 15 ] ], [ "ringpythonrubyru", [ 12, 16 ] ],
#	[ "ingpythonrubyruby", [ 13, 17 ] ], [ "ngpythonrubyruby", [ 14, 18 ] ],
#	[ "gpythonrubyruby", [ 15, 19 ] ], [ "pythonrubyruby", [ 16, 20 ] ],
#	[ "ythonrubyruby", [ 17, 21 ] ], [ "thonrubyruby", [ 18, 22 ] ],
#	[ "honrubyruby", [ 19, 23 ] ], [ "onrubyruby", [ 20, 24 ] ],
#	[ "nrubyruby", [ 21, 25 ] ], [ "rubyruby", [ 22, 26 ] ], [ "ubyruby", [ 23, 27 ] ],
#	[ "byruby", [ 24, 28 ] ], [ "yruby", [ 25, 29 ] ],
#
#	[ "phprin", [ 1, 6 ] ], [ "hpringr", [ 2, 7 ] ], [ "pringrin", [ 3, 8 ] ],
#	[ "ringringr", [ 4, 9 ] ], [ "ingringrin", [ 5, 10 ] ], [ "ngringringp", [ 6, 11 ] ],
#	[ "gringringpyt", [ 7, 12 ] ], [ "ringringpytho", [ 8, 13 ] ],
#	[ "ingringpythonr", [ 9, 14 ] ], [ "ngringpythonrub", [ 10, 15 ] ],
#	[ "gringpythonrubyr", [ 11, 16 ] ], [ "ringpythonrubyrub", [ 12, 17 ] ],
#	[ "ingpythonrubyruby", [ 13, 18 ] ], [ "ngpythonrubyruby", [ 14, 19 ] ],
#	[ "gpythonrubyruby", [ 15, 20 ] ], [ "pythonrubyruby", [ 16, 21 ] ],
#	[ "ythonrubyruby", [ 17, 22 ] ], [ "thonrubyruby", [ 18, 23 ] ],
#	[ "honrubyruby", [ 19, 24 ] ], [ "onrubyruby", [ 20, 25 ] ],
#	[ "nrubyruby", [ 21, 26 ] ], [ "rubyruby", [ 22, 27 ] ], [ "ubyruby", [ 23, 28 ] ],
#	[ "byruby", [ 24, 29 ] ],
#
#	[ "phpring", [ 1, 7 ] ], [ "hpringri", [ 2, 8 ] ], [ "pringring", [ 3, 9 ] ],
#	[ "ringringri", [ 4, 10 ] ], [ "ingringring", [ 5, 11 ] ],
#	[ "ngringringpy", [ 6, 12 ] ], [ "gringringpyth", [ 7, 13 ] ],
#	[ "ringringpython", [ 8, 14 ] ], [ "ingringpythonru", [ 9, 15 ] ],
#	[ "ngringpythonruby", [ 10, 16 ] ], [ "gringpythonrubyru", [ 11, 17 ] ],
#	[ "ringpythonrubyruby", [ 12, 18 ] ], [ "ingpythonrubyruby", [ 13, 19 ] ],
#	[ "ngpythonrubyruby", [ 14, 20 ] ], [ "gpythonrubyruby", [ 15, 21 ] ],
#	[ "pythonrubyruby", [ 16, 22 ] ], [ "ythonrubyruby", [ 17, 23 ] ],
#	[ "thonrubyruby", [ 18, 24 ] ], [ "honrubyruby", [ 19, 25 ] ],
#	[ "onrubyruby", [ 20, 26 ] ], [ "nrubyruby", [ 21, 27 ] ], [ "rubyruby", [ 22, 28 ] ],
#	[ "ubyruby", [ 23, 29 ] ],
#
#	[ "phpringr", [ 1, 8 ] ], [ "hpringrin", [ 2, 9 ] ], [ "pringringr", [ 3, 10 ] ],
#	[ "ringringrin", [ 4, 11 ] ], [ "ingringringp", [ 5, 12 ] ],
#	[ "ngringringpyt", [ 6, 13 ] ], [ "gringringpytho", [ 7, 14 ] ],
#	[ "ringringpythonr", [ 8, 15 ] ], [ "ingringpythonrub", [ 9, 16 ] ],
#	[ "ngringpythonrubyr", [ 10, 17 ] ], [ "gringpythonrubyrub", [ 11, 18 ] ],
#	[ "ringpythonrubyruby", [ 12, 19 ] ], [ "ingpythonrubyruby", [ 13, 20 ] ],
#	[ "ngpythonrubyruby", [ 14, 21 ] ], [ "gpythonrubyruby", [ 15, 22 ] ],
#	[ "pythonrubyruby", [ 16, 23 ] ], [ "ythonrubyruby", [ 17, 24 ] ],
#	[ "thonrubyruby", [ 18, 25 ] ], [ "honrubyruby", [ 19, 26 ] ],
#	[ "onrubyruby", [ 20, 27 ] ], [ "nrubyruby", [ 21, 28 ] ],
#	[ "rubyruby", [ 22, 29 ] ],

#	[ "phpringri", [ 1, 9 ] ], [ "hpringring", [ 2, 10 ] ], [ "pringringri", [ 3, 11 ] ],
#	[ "ringringring", [ 4, 12 ] ], [ "ingringringpy", [ 5, 13 ] ],
#	[ "ngringringpyth", [ 6, 14 ] ], [ "gringringpython", [ 7, 15 ] ],
#	[ "ringringpythonru", [ 8, 16 ] ], [ "ingringpythonruby", [ 9, 17 ] ],
#	[ "ngringpythonrubyru", [ 10, 18 ] ], [ "gringpythonrubyruby", [ 11, 19 ] ],
#	[ "ringpythonrubyruby", [ 12, 20 ] ], [ "ingpythonrubyruby", [ 13, 21 ] ],
#	[ "ngpythonrubyruby", [ 14, 22 ] ], [ "gpythonrubyruby", [ 15, 23 ] ],
#	[ "pythonrubyruby", [ 16, 24 ] ], [ "ythonrubyruby", [ 17, 25 ] ],
#	[ "thonrubyruby", [ 18, 26 ] ], [ "honrubyruby", [ 19, 27 ] ],
#	[ "onrubyruby", [ 20, 28 ] ], [ "nrubyruby", [ 21, 29 ] ],
#
#	[ "phpringrin", [ 1, 10 ] ], [ "hpringringr", [ 2, 11 ] ],
#	[ "pringringrin", [ 3, 12 ] ], [ "ringringringp", [ 4, 13 ] ],
#	[ "ingringringpyt", [ 5, 14 ] ], [ "ngringringpytho", [ 6, 15 ] ],
#	[ "gringringpythonr", [ 7, 16 ] ], [ "ringringpythonrub", [ 8, 17 ] ],
#	[ "ingringpythonrubyr", [ 9, 18 ] ], [ "ngringpythonrubyrub", [ 10, 19 ] ],
#	[ "gringpythonrubyruby", [ 11, 20 ] ], [ "ringpythonrubyruby", [ 12, 21 ] ],
#	[ "ingpythonrubyruby", [ 13, 22 ] ], [ "ngpythonrubyruby", [ 14, 23 ] ],
#	[ "gpythonrubyruby", [ 15, 24 ] ], [ "pythonrubyruby", [ 16, 25 ] ],
#	[ "ythonrubyruby", [ 17, 26 ] ], [ "thonrubyruby", [ 18, 27 ] ],
#	[ "honrubyruby", [ 19, 28 ] ], [ "onrubyruby", [ 20, 29 ] ],
#
#	[ "phpringring", [ 1, 11 ] ], [ "hpringringri", [ 2, 12 ] ],
#	[ "pringringring", [ 3, 13 ] ], [ "ringringringpy", [ 4, 14 ] ],
#	[ "ingringringpyth", [ 5, 15 ] ], [ "ngringringpython", [ 6, 16 ] ],
#	[ "gringringpythonru", [ 7, 17 ] ], [ "ringringpythonruby", [ 8, 18 ] ],
#	[ "ingringpythonrubyru", [ 9, 19 ] ], [ "ngringpythonrubyruby", [ 10, 20 ] ],
#	[ "gringpythonrubyruby", [ 11, 21 ] ], [ "ringpythonrubyruby", [ 12, 22 ] ],
#	[ "ingpythonrubyruby", [ 13, 23 ] ], [ "ngpythonrubyruby", [ 14, 24 ] ],
#	[ "gpythonrubyruby", [ 15, 25 ] ], [ "pythonrubyruby", [ 16, 26 ] ],
#	[ "ythonrubyruby", [ 17, 27 ] ], [ "thonrubyruby", [ 18, 28 ] ],
#	[ "honrubyruby", [ 19, 29 ] ],
#
#	[ "phpringringr", [ 1, 12 ] ], [ "hpringringrin", [ 2, 13 ] ],
#	[ "pringringringp", [ 3, 14 ] ], [ "ringringringpyt", [ 4, 15 ] ],
#	[ "ingringringpytho", [ 5, 16 ] ], [ "ngringringpythonr", [ 6, 17 ] ],
#	[ "gringringpythonrub", [ 7, 18 ] ], [ "ringringpythonrubyr", [ 8, 19 ] ],
#	[ "ingringpythonrubyrub", [ 9, 20 ] ], [ "ngringpythonrubyruby", [ 10, 21 ] ],
#	[ "gringpythonrubyruby", [ 11, 22 ] ], [ "ringpythonrubyruby", [ 12, 23 ] ],
#	[ "ingpythonrubyruby", [ 13, 24 ] ], [ "ngpythonrubyruby", [ 14, 25 ] ],
#	[ "gpythonrubyruby", [ 15, 26 ] ], [ "pythonrubyruby", [ 16, 27 ] ],
#	[ "ythonrubyruby", [ 17, 28 ] ], [ "thonrubyruby", [ 18, 29 ] ],
#
#	[ "phpringringri", [ 1, 13 ] ], [ "hpringringring", [ 2, 14 ] ],
#	[ "pringringringpy", [ 3, 15 ] ], [ "ringringringpyth", [ 4, 16 ] ],
#	[ "ingringringpython", [ 5, 17 ] ], [ "ngringringpythonru", [ 6, 18 ] ],
#	[ "gringringpythonruby", [ 7, 19 ] ], [ "ringringpythonrubyru", [ 8, 20 ] ],
#	[ "ingringpythonrubyruby", [ 9, 21 ] ], [ "ngringpythonrubyruby", [ 10, 22 ] ],
#	[ "gringpythonrubyruby", [ 11, 23 ] ], [ "ringpythonrubyruby", [ 12, 24 ] ],
#	[ "ingpythonrubyruby", [ 13, 25 ] ], [ "ngpythonrubyruby", [ 14, 26 ] ],
#	[ "gpythonrubyruby", [ 15, 27 ] ], [ "pythonrubyruby", [ 16, 28 ] ],
#	[ "ythonrubyruby", [ 17, 29 ] ],
#
#	[ "phpringringrin", [ 1, 14 ] ], [ "hpringringringp", [ 2, 15 ] ],
#	[ "pringringringpyt", [ 3, 16 ] ], [ "ringringringpytho", [ 4, 17 ] ],
#	[ "ingringringpythonr", [ 5, 18 ] ], [ "ngringringpythonrub", [ 6, 19 ] ],
#	[ "gringringpythonrubyr", [ 7, 20 ] ], [ "ringringpythonrubyrub", [ 8, 21 ] ],
#	[ "ingringpythonrubyruby", [ 9, 22 ] ], [ "ngringpythonrubyruby", [ 10, 23 ] ],
#	[ "gringpythonrubyruby", [ 11, 24 ] ], [ "ringpythonrubyruby", [ 12, 25 ] ],
#	[ "ingpythonrubyruby", [ 13, 26 ] ], [ "ngpythonrubyruby", [ 14, 27 ] ],
#	[ "gpythonrubyruby", [ 15, 28 ] ], [ "pythonrubyruby", [ 16, 29 ] ]
# ]

proff()
# Executed in 0.15 second(s).

/*=============

profon()

o1 = new stzString(" so ftan   za ")
o1.Unspacify()
? o1.Content()
#--> "so ftan za"

proff()
# Executed in 0.01 second(s)

/*--------------

profon()

o1 = new stzListOfStrings([" r   in g", "r ing", "  r     i ng  "])
? o1.SpacesRemoved()
#--> [ "ring", "ring", "ring" ]

# Content of the string remained the same, because ...ed() functions
# work on a copy of it.

o1.RemoveSpaces()
? o1.Content()
#--> [ "ring", "ring", "ring" ]

proff()
# Executed in 0.03 second(s)

/*--------------

profon()

? @@( Q(" ").Unspacified() )
#--> ""

? @@( Q("  ").Unspacified() )
#--> " "

? @@( Q("   ").Unspacified() )
#--> " "

? @@( Q(" ♥").Unspacified() )
#--> "♥"

? @@( Q("♥ ").Unspacified() )
#--> "♥"

? @@( Q(" ♥ ").Unspacified() )
#--> "♥"

? Q("r  in  g ").Unspacified() # Does not remove spaces inside!
#--> "r  in  g"

? Q("    r  in  g ").Unspacified()
#--> "r  in  g"

proff()
# Executed in 0.02 second(s).

/*--------------

profon()

o1 = new stzSplitter(12)

? @@( o1.SplitAtSections([ [3, 5], [8, 9] ]) ) + NL
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 12 ] ]

? @@( o1.SplitAtSections([ [1, 12 ] ]) ) + NL
#--> [ ]

? @@( o1.SplitAtSections([ [1, 5], [ 8, 9 ] ]) ) + NL
#--> [ [ 6, 7 ], [ 10, 12 ] ]

? @@( o1.SplitAtSections([ [3, 5], [8, 9], [12, 12] ]) )
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.09 second(s).

/*--------------

profon()

o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")
? @@( o1.SplitAtSections([ [ 1, 8 ], [ 29, 34 ] ]) )
#--> [ "r  in  g", "r  ing" ]

proff()
# Executed in 0.08 second(s).

/*--------------

profon()

o1 = new stzString("Softanza is an acc  elera tive library f   or Ring.")

? @@( o1.FindZZ([ "acc  elera tive", "f   or" ]) )
#--> [ [ 16, 30 ], [ 40, 45 ] ]

o1.RemoveSpacesInSections([ [ 16, 30 ], [ 40, 45 ] ])
? o1.Content()
#--> Softanza ia an accelerative library for Ring.

proff()
# Executed in 0.06 second(s).

/*--------------

profon()

o1 = new stzString("Sof tan za is an acc  elera tive library for Rin g .")

? @@( o1.FindZZ([ "Sof tan za", "acc  elera tive", "Rin g ." ]) )
#--> [ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ]

o1.RemoveSpacesInSections([ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ])
? o1.Content()
#--> Softanza is an accelerative library for Ring.

proff()
# Executed in 0.06 second(s).

/*--------------

profon()

o1 = new stzString("R  in  g language is like a r  ing at your fingertips!")

? o1.Sections([ [ 1, 8 ], [ 29, 34 ] ])
#--> [ "R  in  g", "r  ing" ]

o1.RemoveSpacesInSections([ [ 1, 8 ], [ 29, 34 ] ])
? o1.Content()
#--> "Ring language is like a ring at your fingertips!"

proff()
# Executed in 0.02 second(s).

/*--------------

profon()

o1 = new stzString("Ring langua  ge is like a r  ing at your fing er  tips!")

? @@( o1.FindZZ([ "langua  ge", "r  ing", "fing er  tips!" ]) )
#--> [ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ]

o1.RemoveSpacesInSections([ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ])
? o1.Content()
#--> Ring language is like a ring at your fingertips!

proff()

/*--------------

profon()

o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")

acSubStrXT =  o1.SubStringsBoundedByIBZZ([ "r","g" ])
? @@SP(acSubStrXT) + NL
#--> [
#	[ "r in g", [  1, 8  ] ],
#	[ "r ing",  [ 29, 34 ] ],
#	[ "r fing", [ 42, 47 ] ]
# ]


oHashList = QR(acSubStrXT, :stzHashList)
acWithoutSpaces = oHashList.KeysQR(:stzListOfStrings).WithoutSapces()
? @@(acWithoutSpaces) + NL
#-->  [ "ring", "ring", "rfing" ]

aSectionsPos = Q(acWithoutSpaces).FindW('This[@i] = "ring"')
? @@(aSectionsPos)
#--> [1, 2]

aSections = oHashList.ValuesQ().ItemsAtPositions(aSectionsPos)
? @@(aSections) + NL
#--> [ [ 1, 8 ], [ 29, 34 ] ]

o1.RemoveSpacesInSections(aSections)
? o1.Content()

proff()
# Executed in 0.12 second(s)

/*-------------

profon()
#                      4      11      19   24
#                      v      v       v    v
o1 = new stzString("   r  in  g  is a rin  g  ")

? @@( o1.FindAnyBoundedByIBZZ([ "r", "g" ]) )
#--> [ [ 4, 11 ], [ 19, 24 ] ]

? QR( o1.SubStringsBoundedByIB([ "r","g" ]), :stzListOfStrings).WithoutSapces()
#NOTE: WithoutSapces() is misspelled and the correct form is WithoutSpaces!
# Despite that, softanza accepts it ;)

#--> [ "ring", "ring" ]

proff()
# Executed in 0.04 second(s) in Ring 1.21.
# Executed in 0.07 second(s) in Ring 1.18

/*--------------

profon()

? Q("believe").IsStringOrList()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------- SUBSTRONGS & SUBSTRINKS #narration #funny

profon()

o1 = new stzListOfStrings([
	"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
])

? @@( o1.SubStrongs() ) # the strings containing other strings from the list
#--> [ "Ring" ]

# In fact, "Ring" contains "in" and "in" is an item from the list

? @@( o1.SubStrinks() ) # the strings that are contained IN other strings from the list
#--> [ "in" ]

# In fact, "in" is contained in the item "Ring"

proff()
# Executed in 0.06 second(s)

/*============

profon()

o1 = new stzString("IbelieveinRingfutureandengageforit!")
o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()
#--> I believe in Ring future and engage for it!

proff()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.13 second(s) in Ring 1.19

/*--------------

profon()

o1 = new stzString(
"MahmoudBertAhmedMansourIlirGalMajdi"
)

o1.SpacifyTheseSubStrings([
	"Mahmoud", "Bert", "Ahmed", "Mansour", "Ilir", "Gal", "Majdi" ])

? o1.Content()
#--> Mahmoud Bert Ahmed Mansour Ilir Gal Majdi

proff()
# Executed in 0.06 second(s)

/*==============

profon()

o1 = new stzString("99999999999")

o1.InsertXT("_", :EachNChars = 3)
//o1.InsertXT("_", [ :EachNChars = 3, :Forward ]) #TODO

? o1.Content()
#--> 999_999_999_99

proff()
# Executed in 0.05 second(s)

/*-------------

profon()

o1 = new stzString("123456789")

o1.InsertBefore([4, 7], "_") # or o1.InsertBeforePositions([4, 7], "_")
#--> 123_456_789

? o1.Content()
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*-------------

profon()

o1 = new stzString("123456789")

o1.InsertAfterPositions([3, 6], "_") # or o1.InsertAfterPositions([4, 7], "_")
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*------------- TODO

profon()

o1 = new stzString("123456789")

o1.InsertAfterEachNCharsXT(3, :StartingFrom = :End)
? o1.Content()
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*==============

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthPrevious(:Last, "♥♥♥", :StartingAt = 12)
#--> 3

? o1.FindNthPrevious(:First, "♥♥♥", :StartingAt = 12)
#--> 8

proff()
# Executed in 0.06 second(s)

/*============ Using ..Z() and ..ZZ() extensions

profon()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirst("♥♥♥")
#--> 6

? o1.FindFirstAsSection("♥♥♥")
#--> [6, 8]

? o1.FirstZ("♥♥♥") # Or FindFirstZ()
#--> [ "♥♥♥", 6 ]

? o1.FirstZZ("♥♥♥") # Or FindfirstZZ()
#--> [ "♥♥♥", [6, 8] ]

proff()
# Executed in 0.02 second(s)

/*---------------

profon()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindLast("♥♥♥")
#--> 22

? o1.FindLastAsSection("♥♥♥") 	#NOTE //that the function is misspelled (there is an
#--> [22, 24]			#ERRonous "e" after "Last", but Softanza lets it go!

? o1.FindLastZ("♥♥♥")
#--> [ "♥♥♥", 22 ]

? o1.FindLastZZ("♥♥♥")
#--> [ "♥♥♥", [22, 24] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---------------

profon()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindNth(2, "♥♥♥")
#--> 22

? o1.FindNthAsSection(2, "♥♥♥")
#--> [22, 24]

? o1.NthZ(2, "♥♥♥") # Or o1.FindNthZ()
#--> [ "♥♥♥", 22 ]

? o1.FindNthZZ(2, "♥♥♥") # Or o1.NthZZ()
#--> [ "♥♥♥", [22, 24] ]

proff()
# Executed in 0.03 second(s)

/*=================

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthST(1, "♥♥♥", :StartingAt = 3)
#--> 3

? o1.FindNext("♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindPrevious("♥♥♥", :StartingAt = 10)
#--> 3

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18

/*================= Using ..ST() and ..STD() extension

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

# Spacifying the starting prosition with the S extension
? o1.FindNthST(2, "♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindFirstST("♥♥♥", :StartingAt = 5)
#--> 8

? o1.FindLastST("♥♥♥", :StartingAt = 6)
#--> 13

#--- Spacifying the direction with SD extension

? o1.FindNthSTD(2, "♥♥♥", :StartingAt = 10, :Going = :Backward)
#--> 3

? o1.FindFirstSTD("♥♥♥", :StartingAt = 14, :Backward)
#--> 8

? o1.FindLastSTD("♥♥♥", :StartingAt = 6, :Direction = :Backward)
#--> 3

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.17

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.NthSTZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", 8 ]

? o1.FirstSTZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", 8 ]

? o1.LastSTZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 13 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.18

/*----------------- Using ..ST() + ..D() + ZZ() prefixes

profon()

#                     3 5
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 10, :Backward)
#--> [ 3, 5 ]

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 5, :Backward)
#--> [ 3, 5 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = :LastChar, :Backward)
#--> [ 3, 5 ]

proff()
# Executed in 0.08 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzString("123456♥..♥♥")
? o1.HowManyST("♥", :StartingAt = 6) # Or NumberOfOuccurrenceST() or CountST()
#--> 3

o1 = new stzList( @Chars("123456♥..♥♥") )
? o1.HowManyST("♥", :StartingAt = 6)
#--> 3

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSZZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindFirstSZZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindLastSZZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", [13, 15] ]

proff()
# Executed in 0.05 second(s)

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 3, :Direction = :Forward)
#--> [ 8, 10 ]

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 5, :Direction = :Forward)
#--> [ 8, 10 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = 6, :Direction = :Forward)
#--> [ 13, 15 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*=================

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstST("♥♥♥", :StartingAt = 6)
#--> 8

? o1.FindLastST("♥♥♥", :StartingAt = 6)
#--> 13

? o1.FindNthST(2, "♥♥♥", :StartingAt = 6)
#--> 13

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTZZ("♥♥♥", :StartingAt = 6)
#--> [ 8, 10 ]

? o1.FindLastSTZZ("♥♥♥", :StartingAt = 6)
#--> [ 13, 15 ]

? o1.FindNthSTZZ(2, "♥♥♥", :StartingAt = 6)
#--> [ 13, 15 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ring 1.17

/*===============

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTD("♥♥♥", :StartingAt = 12, :Backward)
#--> 8

? o1.FindLastSTD("♥♥♥", :StartingAt = 12, :Backward)
#--> 3

? o1.FindNthSTD(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> 3

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FirstSTDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", 8 ]

? o1.LastSTDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥"", 3 ]

? o1.NthSTDZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", 3 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ 8, 10 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ 3, 5 ]

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ 3, 5 ]

proff()
# Executed in 0.08 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FirstSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 8, 10 ] ]

? o1.LastSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 3, 5 ] ]

? o1.NthSTDZZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 3, 5 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.18

/*===========

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstAsSection("♥♥♥")
#--> [3, 5]

? o1.FindFirstAsSectionST("♥♥♥", :StartingAt = 5)
#--> [8, 10]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstDZZ("♥♥♥", :Backward)
#--> [13, 15]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

/*=============

profon()
#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstD("♥♥♥", :Backward)
#--> 13

? o1.FindLastD("♥♥♥", :Backward)
#--> 3

? o1.FindNthD(2, "♥♥♥", :Backward) + NL
#--> 8

? o1.FindD("♥♥♥", :Backward)
#--> [13, 8, 3 ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstD("♥♥♥", :Backward)
#--> 13

? o1.FindLastD("♥♥♥", :Backward)
#--> 3

? o1.FindNthD(2, "♥♥♥", :Backward) + NL
#--> 8

? o1.FindD("♥♥♥", :Backward)
#--> [ 13, 8, 3 ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstDZZ("♥♥♥", :Backward)
#--> [ 13, 15 ]

? o1.FindLastDZZ("♥♥♥", :Backward)
#--> [ 3, 5 ]

? o1.FindNthDZZ(2, "♥♥♥", :Backward)
#--> [ 8, 10 ]

? @@( o1.FindDZZ("♥♥♥", :Backward) )
#--> [ [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.36 second(s) in Ring 1.17

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.Find( "♥♥♥" ) ) # or FindOccurrences( :Of = "♥♥♥" )
#--> [3, 8, 13 ]

? @@( o1.FindZ( :Of = "♥♥♥") )
#--> [ 3, 8, 13 ]

? @@( o1.FindZZ( :Of = "♥♥♥") )
#--> [ [3, 5], [8, 10], [13, 15] ]

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.FindD( "♥♥♥", :Backward ) )
#--> [ 13, 8, 3 ]

? @@( o1.FindAsSectionsD( "♥♥♥", :Backward ) )
#--> [ [13, 5], [8, 10], [3, 5] ]

? @@( o1.FindDZ( "♥♥♥", :Backward) )
#--> [ 13, 8, 3 ]

? @@( o1.FindDZZ( "♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.FindST( "♥♥♥", :StartingAt = 6 ) )
#--> [8, 13 ]

? @@( o1.FindSTZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ 8, 13 ]

? @@( o1.FindSTZZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ 8, 10], [13, 15] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.17

/*--------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindSTD( "♥♥♥", :StartingAt = 6, :Backward )
#--> [8, 13 ]

? o1.FindSTDZ( "♥♥♥", :StartingAt = 6, :Backward )
#--> [ "♥♥♥", [13, 8] ]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 12, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

? @@( o1.FindSTDZZ( "♥♥♥", :StartingAt = 12, :Backward ) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*===============

profon()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")
? o1.SplitQ("aa").IfQ('NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO // Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------------

profon()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? o1.SplitQ("aa").IfQ('This.NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO // IfQ() function Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

proff()
# Executed in 0.03 second(s)

/*===============

profon()

o1 = new stzString("aa***aa**aa***")

? @@( o1.FindAnyBoundedBy([ "aa", "aa" ]) )
#--> [ 3, 8 ]

? @@( o1.FindAnyBoundedByZZ([ "aa", "aa" ]) )
#--> [ [ 3, 5 ], [ 8, 9 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.17

/*---------------

profon()
#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@( o1.FindSubStringsBoundedByZZ(["aa", "aa"]) )
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=============

profon()

#                        6
o1 = new stzString("*aa***aa**aa***aa*")

? @@( o1.FindAsSections("aa") ) + NL
# [ [ 2, 3 ], [ 7, 8 ], [ 11, 12 ], [ 16, 17 ] ]

? @@( o1.FindAsAntiSections("aa") ) + NL
# [ [ 1, 1 ], [ 4, 6 ], [ 9, 10 ], [ 13, 15 ], [ 18, 18 ] ]

? o1.ContainsXT( :SubString = "***", :BoundedBy = "aa") # Or ? o1.ContainsSubStringBoundedBy()
#--> _TRUE_

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.18 second(s) in ring 1.18

/*---------

profon()
#                      4 6  90  3 5
o1 = new stzString("*aa***aa**aa***aa*")

? o1.FindAnyBoundedBy([ "aa", "aa" ])
#--> [4, 9, 13]

? @@( o1.FindAnyBoundedByAsSections([ "aa", "aa" ]) )
#--> [ [ 4, 6 ], [ 9, 10 ], [ 13, 15 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.15 second(s) in ring 1.17

proff()

/*---------

profon()
#                      4 6      3 5
o1 = new stzString("*<<***>>**<<***>>*")

? o1.FindAnyBoundedBy([ "<<", ">>" ])
#--> [4, 13]

? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

? "--"

? o1.FindAnyBoundedByIB([ "<<", ">>" ])
#--> [2, 11]

? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.17

/*-----------------

profon()

? Bounds([ "67", :And = "12" ])
#--> [ "67", "12" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindSubStringsBoundedBy([ "67", :And = "12" ]) ) # Same as o1.FindSubStringsBetween("67", "12")
#--> [ 8 ]

? @@( o1.FindSubStringBoundedBy("♥♥♥", [ "67", :And = "12" ]) ) # Same  as o1.FindSubStringsBetween( "♥♥♥", "67", "12")
#--> [ 8 ]

? @@( o1.FindXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]) )
#--> [ 8 ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "67", :And = "12" ]) )
#--> [ [ 8, 10 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "67", :And = "12" ]) )
#--> [ [ 6, 12 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = [ "12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = [ "12", "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

#-----

? @@( o1.FindXT( "♥♥♥", :BoundedBy = ["12", :And = "67" ]) )
#--> [3, 13]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedBy = ["12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]) )
#--> [1, 11]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BoundedByIB = ["12", :And = "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

proff()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 0.30 second(s) in Ring 1.18

/*---------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindAnyBoundedByAsSectionsIB([ "12", "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

? @@( o1.FindAnyBoundedByAsSections([ "♥♥♥", "♥♥♥" ]) )
#--> [ [ 6, 7 ], [ 11, 12 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.18

/*===================

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindD("♥♥♥", :Forward) )
#--> [ 3, 8, 13 ]

? @@( o1.FindAsSectionsD("♥♥♥", :Forward) )
#--> [ [ 3, 5 ], [ 8, 10 ], [ 13, 15 ] ]

#--

? @@( o1.FindD("♥♥♥", :Backward) )
#--> [ 13, 8, 3 ]

? @@( o1.FindAsSectionsD("♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

#--

? @@( o1.FindSTD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ 8, 13 ]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ [ 8, 10 ], [ 13, 15 ] ]

#--

? @@( o1.FindSTD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [8, 3]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.18 second(s) in Ring 1.18

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindOccurrences( [ 2, 3 ], :Of = "♥♥♥" ) ) # Or FindAllOccurrences()
#--> [ 8, 13 ]

? @@( o1.FindTheseOccurrences([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesXT()
#--> [ 8, 13 ]

? @@( o1.FindTheseOccurrencesZZ([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesAsSectionsXT
#--> [ [ 8, 10 ], [ 13, 15 ] ]

? @@( o1.FindTheseOccurrencesST([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ 3, 8, 13 ]

? @@( o1.FindTheseOccurrencesSTZZ([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ [ 3, 5 ], [ 8, 10 ], [ 13, 15 ] ]

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.18

/*-----------------

profon()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindD( :Of = "♥♥♥", :Backward ) ) 
#--> [ 13, 8, 3 ]

? @@( o1.FindTheseOccurrencesD([ 1, 2], :Of = "♥♥♥", :Backward) )
#--> [ 13, 8 ]

? @@( o1.FindTheseOccurrencesAsSectionsD([ 1, 2], :Of = "♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ] ]

? @@( o1.FindTheseOccurrencesSD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Bakcward) )
#--> [ 8, 3 ]

? @@( o1.FindTheseOccurrencesAsSectionsSTD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.10 second(s)

/*================

profon()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirstST("♥♥♥", :StartingAt = 8)
#--> 22

? o1.FindLastST("♥♥♥", :Startingat = 8)
#--> 22

? o1.FindNthST(2, "♥♥♥", :StartingAt = 3)
#--> 22

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*---------------

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindBoundedBy([ "{", "}" ]) ) + NL
#--> [ 23, 33 ]

? @@( o1.FindBoundedByZZ([ "{", "}" ]) ) + NL
#--> [ [ 23, 25 ], [ 33, 35 ] ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.18

/*------------

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindBoundedByIB([ "{", "}" ]) ) + NL
#--> [ 22, 32 ]

? @@( o1.BoundedByIBZ([ "{", "}" ]) ) + NL
#--> [ [ "{min}", 22 ], [ "{max}", 32 ] ]

? @@( o1.BoundedByIBZZ([ "{", "}" ]) )
#--> [ [ "{min}", [ 22, 26 ] ], [ "{max}", [ 32, 36 ] ] ]

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.24 second(s) in Ring 1.18

/*============

profon()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}")
? @@( o1.Find([ "♥♥♥", "✤✤✤" ]) ) # or FindMany()
#-->[ 6, 22, 35 ]

? @@( o1.TheseSubStringsZ([ "♥♥♥", "✤✤✤" ]) ) + NL
#--> [ [ "♥♥♥", [ 6, 22 ] ], [ "✤✤✤", [ 35 ] ] ]

? @@NL( o1.TheseSubStringsZZ([ "♥♥♥", "✤✤✤" ]) ) # or FindManyZZ()
#--> [
#	[ "♥♥♥", [ [ 6, 8 ], [ 22, 24 ] ] ],
#	[ "✤✤✤", [ [ 35, 37 ] ] ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*====# #todo #narration THE ART OF SPLITTING THINGS IN SOFTANZA
		
# Softanza can do all these splitting cases, both for strings and lists:

 -------------------+--------+--------+-------+--------- 
        SPLITTING   |   At   | Before | After | Around  
 ===================+========+========+=======+========= 
      A Position    |   ✓   |   ✓   |   ✓   |   ✓   
 -------------------+--------+--------+-------+---------
   Many Positions   |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
      A SubString   |   ✓   |   ✓   |   ✓   |   ✓   
 -------------------+--------+--------+-------+---------
   Many SubStrings  |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
       Section	    |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
      SectionIB     |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
    Many Sections   |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
   Many SectionsIB  |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
       Where        |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------

# See fellowing examples...

/*-----

profon()

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")

? @@( o1.SplitBeforeCS("a", :CS = _FALSE_) )
#--> [ "__", "a__", "A__" ]

? @@( o1.SplitCS( :Before = "a", :CS = _FALSE_) )
#--> [ "__", "a__", "A__" ]

? @@( o1.Split( :Before = [ "a", "A" ] ) ) + NL
#--> [ "__", "a__", "A__" ]

#---

o1 = new stzString("...♥...♥...")
? @@( o1.Split( :BeforePosition = 4 ) )
#--> [ "...", "♥...♥..." ]

? @@( o1.Split( :BeforePositions = [ 4, 8 ] ) )
#--> [ "...", "♥...", "♥..." ]

? @@( o1.Split( :BeforeSection = [ 4,  8 ] ) ) + NL
#--> [ "...", "♥...♥..." ]

#---

o1 = new stzString("...♥♥♥..♥♥..")
? @@( o1.Split( :BeforeSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...", "♥♥♥..", "♥♥.." ]

o1 = new stzString("...♥...♥...")
? @@( o1.SplitBeforeCharsWXT(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitBeforeSubStringsWXT(' @SubString = "♥♥" ') )
#--> [ "...", "♥♥...", "♥♥..." ]


proff()
# Executed in 0.50 second(s) in Ring 1.21

/*------

profon()

o1 = new stzString("hello ring what a nice ring!")

? @@( o1.FindAsSections( "ring" ) )
#--> [ [7, 10], [24, 27] ]

? @@( o1.FindAsAntiSections("ring") )
#--> [ [1, 6], [11, 23], [28, 28] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*============ SPLITTING AT

profon()

# Splitting at a given substring with case sensitivity

o1 = new stzString("__a__A__")

? o1.SplitCS("a", :CS = _FALSE_)
#--> [ "__", "__", "__" ]

# Splitting at a given substring (without case sensitivity)

? o1.Split("a")
#--> [ "__", "__A__" ]

# Splitting at a given position

o1 = new stzString("...♥...")
? o1.Split( :At = 4 )
#--> [ "...", "..." ]

# Splitting at many positions

o1 = new stzString("...♥...♥...")
? o1.Split( :At = [ 4, 8 ] )
#--> [ "...", "...", "..." ]

# Splitting at many substrings

o1 = new stzString("...♥...★...")
? o1.Split( :At = [ "♥", "★" ] )
#--> [ "...", "...", "..." ]

# Splitting at a given section

o1 = new stzString("...♥♥♥...")
? o1.SplitAt( :Section = [ 4, 6 ] )
#--> [ "...", "..." ]

? o1.Split( :AtSection = [ 4, 6 ] )
#--> [ "...", "..." ]

# Splitting at many sections

o1 = new stzString("...♥♥♥...♥♥...")
? o1.Split( :AtSections = [ [ 4, 6 ], [10, 11] ] )
#--> [ "...", "...", "..."]

# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitAtCharsWXT('@char = "♥"')
#--> [ "...", "...", "..." ]

# Splitting at a substring described by a condition

o1 = new stzString("...♥♥...♥♥...")
? o1.SplitAtSubStringsWXT('{ @SubString = "♥♥" }')
#--> [ "...", "...", "..." ]

o1 = new stzString("...ONE...TWO...ONE")
? o1.SplitAtsubStringsWXT('{ @SubString = "ONE" or @SubString = "TWO" }')
#--> [ "...", "...", "..." ]

? o1.SplitAtSubStringsWXT('{ Q(@SubString).IsOneOfThese([ "ONE", "TWO"]) }')
#--> [ "...", "...", "..." ]

? o1.SplitAtSubStringsWXT('{ Q(@SubString).IsEither( "ONE", :Or = "TWO") }')
#--> [ "...", "...", "..." ]

proff()
# Executed in 2.60 second(s) in Ring 1.21

/*============ SPLITTING AFTER

profon()

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@( o1.SplitAfterCS("a", :CS = _FALSE_) )
#--> [ "__a", "__A", "__" ]

? @@( o1.SplitCS( :After = "a", :CS = _FALSE_) )
#--> [ "__a", "__A", "__" ]

? @@( o1.Split( :After = [ "a", "A" ] ) )
#--> [ "__a", "__A", "__" ]

o1 = new stzString("...♥...")
? @@( o1.Split( :AfterPosition = 4 ) )
#--> [ "...♥", "..." ]

o1 = new stzString("...♥...♥...")
? @@( o1.Split( :AfterPositions = [ 4, 8 ] ) )
#--> [ "...♥", "...♥", "..." ]

? @@( o1.Split( :AfterSection = [ 4,  8 ] ) )
#--> [ "...♥...♥", "..." ]

o1 = new stzString("...♥♥♥..♥♥..")
? @@( o1.Split( :AfterSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...♥♥♥", "..♥♥", ".." ]

o1 = new stzString("...♥...♥...")
? @@( o1.SplitBeforeCharsWXT(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitAfterSubStringsWXT(' @SubString = "♥♥" ') )
#--> [ "...♥♥", "...♥♥", "..." ]

proff()
# Executed in 0.55 second(s) in Ring 1.21
# Executed in 3.89 second(s) in Ring 1.18

/*-----------------

profon()

o1 = new stzSplitter(10)
? @@( o1.SplitAroundSections([ [4, 5], [ 8, 8] ]) )
#--> [ [ 1, 3 ], [ 6, 7 ], [ 9, 10 ] ]

? @@( o1.SplitAroundSectionsIB([ [4, 5], [ 8, 8] ]) )

o1 = new stzString("...♥♥..♥..")
#		    1234567890

? @@( o1.SplitAroundSections([ [ 4, 5], [8,8] ]) )
#--> [ "...", "..", ".." ]

? @@( o1.SplitAroundSectionsIB([ [ 4, 5], [8,8] ]) )
#--> [ "...♥", "♥..♥", "♥.." ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzSplitter(10)

? @@( o1.SplitAtSection(3, 5) )
#--> [ [ 1, 2 ], [ 6, 10 ] ]

? @@( o1.SplitAtSectionIB(3, 5) ) + NL
#--> [ [ 1, 3 ], [ 5, 10 ] ]

#--

? @@( o1.SplitAtSection(1, 5) )
#--> [ [ 6, 10 ] ]

? @@( o1.SplitAtSectionIB(1, 5) ) + NL
#--> [ [ 5, 10 ] ]

#--

? @@( o1.SplitAtSection(5, 10) )
#--> [ [ 1, 4 ] ]

? @@( o1.SplitAtSectionIB(5, 10) )
#--> [ [ 1, 5 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*----------------

profon()

? @@( StzSplitterQ(10).splitAround(8) )
#--> [ [ 1, 7 ], [ 9, 10 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzString("...♥^♥.|.♥^♥...")

? @@( o1.SplitAround("♥^♥") )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundIB("♥^♥") )
#--> [ "...♥", "♥.|.♥", "♥..." ]

#--

? @@( o1.SplitAroundPosition(8) )
#--> [ "...♥^♥.", ".♥^♥..." ]

? @@( o1.SplitAroundPositions([ 5, 8, 11 ]) )
#--> [ "...♥", "♥.", ".♥", "♥..." ]

? @@( o1.SplitAroundSection(5, 11) )
#--> [ "...♥", "♥..." ]

? @@( o1.SplitAroundSectionIB(5, 11) )
#--> [ "...♥^", "^♥..." ]

? @@( o1.SplitAroundSections( o1.FindZZ("♥^♥") ) )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundSectionsIB( o1.FindZZ("♥^♥") ) )
#--> [ "...♥", "♥.|.♥", "♥..." ]

? @@( o1.SplitAroundSubString("♥^♥") )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundSubStringIB("♥^♥") )
#--> [ "...♥", "♥.|.♥", "♥..." ]

? @@( o1.SplitAroundSubStrings([ "♥^♥.", ".♥^♥" ]) )
#--> [ "..", "|", ".." ]

? @@( o1.SplitAroundSubStringsIB([ "♥^♥.", ".♥^♥" ]) )
#--> [ "...", ".|.", "..." ]

proff()
# Executed in 0.11 second(s) in Ring 1.21

/*==================

profon()

o1 = new stzString("...ONE...TWO...ONE")

? o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "ONE", "TWO", "THREE"

? o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "...", "...", "..." ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

/*================

profon()

o1 = new stzString("...ONE...TWO...ONE")
? @@( o1.FindSubstringsWXT('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ 4, 10, 16 ]

? @@( o1.FindSubstringsWXTZZ('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]

proff()
# Executed in 1.28 second(s) in Ring 1.21
# Executed in 3.91 second(s) in Ring 1.18

/*-----------------

profon()

o1 = new stzString("...♥♥...♥♥...")

? @@( o1.FindSubStringsWXT('{ @SubString = "♥♥" }') )
#--> [ 4, 9 ]

? @@( o1.FindSubStringsWXTZZ('{ @SubString = "♥♥" }') )
#--> [ [ 4, 5 ], [ 9, 10 ] ]

proff()
# Executed in 0.77 second(s) in Ring 1.21
# Executed in 3.79 second(s) in Ring 1.18

#-----------

profon()

o1 = new stzString("..ONE..TWO..ONE..")

? o1.NumberOfSubStrings()
#--> 153

? o1.NumberOfUniqueSubStrings()
#--> 120

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.17

#---------

profon()

o1 = new stzString("ABA")

? @@( o1.SubStrings() )
#--> [ "A", "AB", "B", "ABA", "A", "BA" ]

? @@( o1.UniqueSubStrings() ) # Or SubStringsU()
#--> [ "A", "AB", "ABA", "B", "BA" ]

? @@( o1.SubStringsZ() )
#--> [
#	[ "A", 	 [ 1, 3 ] ],
#	[ "AB",  [ 1 ] ],
#	[ "ABA", [ 1 ] ],
#	[ "B", 	 [ 2 ] ],
#	[ "BA",  [ 2 ] ]
# ]

? @@( o1.SubStringsZZ() )
#--> [
#	"A"	= [ [ 1, 1 ], [ 3, 3 ] ],
#	"AB"	= [ [ 1, 2 ] ],
#	"ABA"	= [ [ 1, 3 ] ],
#	"B"	= [ [ 2, 2 ] ],
#	"BA"	= [ [ 2, 3 ] ]
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.17

#========

profon()

? Q("one").IsEitherCS("ONE", :Or = "TWO", :CS = _FALSE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21

#=======

profon()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? o1.BoundsXT(:UpToNChars = 2)
#--> [ "<<", ">>" ]

? o1.BoundsXT([ 1, 2 ])
#--> [ "<", ">>" ]


? o1.BoundsUpToNChars(2)
#--> [ "<<", ">>" ]

? o1.BoundsUpToNChars([ 1, 2 ])
#--> [ "<", ">>" ]

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*-----

profon()

o1 = new stzString("<<<word>>>")

? o1.BoundsOf("word")
#--> [ "<<<", ">>>" ]

? o1.BoundsOfXT("word", :UpToNChars = 2)
#--> [ "<<", ">>" ]

? o1.BoundsOfXT("word", [ 1, 2 ])
#--> [ "<", ">>" ]

? o1.BoundsOfUpToNChars("word", 2)
#--> [ "<<", ">>" ]

? o1.BoundsOfUpToNChars("word", [ 1, 2 ])
#--> [ "<", ">>" ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*------

profon()

o1 = new stzString(" <<<<word>>> and ~~~~word~~~~~ ")

? @@( o1.BoundsOf( "word") )
#--> [ "<<<<", ">>>", "~~~~", "~~~~~" ]

? @@( o1.BoundsOfXT( "word", [ 3, 2 ] ) )
#--> [ "<<<", ">>", "~~~", "~~" ]

? @@( o1.BoundsOfXT( "word", 8 ) )
#--> [ "<<<<", ">>>", "~~~~", "~~~~~" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.17

/*--------------

profon()

? Q(".. ♥♥ring♥♥ ..").SubStringXT("♥♥", :IsBoundOf = "ring")
#--> _TRUE_

? Q(".. <<ring>> ..").SubStringXT("<<", :IsFirstBoundOf = "ring")
#--> _TRUE_

? Q(".. <<ring>> ..").SubStringXT(">>", :IsLastBoundOf = "ring")
#--> _TRUE_

? Q(".. <<ring>> ..").SubStringXT("<<", :IsLeftBoundOf = "ring")
#--> _TRUE_

? Q(".. <<ring>> ..").SubStringXT(">>", :IsRightBoundOf = "ring")
#--> _TRUE_

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*--------------

profon()

? Q(:IsBoundedBy = ".").IsIsBoundedByNamedParam()
#--> _TRUE_

? Q(".♥.").SubStringIsBoundedBy("♥", ".")
#--> _TRUE_

? Q(".♥.").SubStringXT("♥", :IsBoundedBy = ".")
#--> _TRUE_

proff()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.18

/*========================

profon()

#NOTE :
#	- RemoveNthItem(n) : Remove item at position n
#
#	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
# 	  (you can also use RemoveNthOccurrence(n, pItem)
#
#	- RemoveThisNthItem(n, pItem) : remove nth item only if it
#	  is equal to pItem


o1 = new stzString("_ABC_DE_")

o1.RemoveFirstChar()
? o1.Content()
#--> ABC_DE_

o1.RemoveThisFirstCharCS("a", :CS = _FALSE_)
? o1.Content()
#--> BC_DE_

o1.RemoveNthChar(:Last) # Works when ChekParams() = _TRUE_ (the default)
			# Otherwise use o1.RemoveLastChar() or
			# o1.RemoveNthChar(o1.NumberOfChars())
? o1.Content()
#--> BC_DE

o1.RemoveThisNthChar(3, "_")
? o1.Content()
#--> BCDE

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*========================

profon()

o1 = new stzString("ABC456DE")
o1.RemoveSection(4, 6)
? o1.Content()
#--> "ABCDE"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------------

profon()

o1 = new stzString("{HELLO}")
o1.RemoveFromStart("{")
? o1.Content()
#--> "HELLO}"

o1.RemoveFromEnd("}")
? o1.Content()
#--> "HELLO"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=================

StartProfiler()

o1 = new stzString("123456789")

o1.ReplaceSection(4, 6, :with = "♥♥♥")
? o1.Content()
#--> 123♥♥♥789

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21

/*===================

StartProfiler()

Q("Ring programmin language.") {

	AddXT("g", :After = "programmin") # You can use :To instead of :After
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.02 second(s) in Ring 1.21

/*-----------

StartProfiler()

Q("__(♥__(♥__(♥__") {

	AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.02 second(s)

/*-----------
*
StartProfiler()

Q("__♥__(♥__♥__") {

	AddXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__(♥__♥__♥__") {

	AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__(♥__") {

	AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()
# Executed in 0.04 second(s)

/*===------------

StartProfiler()

Q("Ring programming guage.") {	
	AddXT("lan", :Before = "guage")
	? Content()
	#--> Ring programming language.
}

StopProfiler()
# Executed in 0.06 second(s) in Ring 1.22

/*---------

StartProfiler()

Q("__♥)__♥)__♥)__") {

	AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.06 second(s) in Ring 1.22

/*---------

StartProfiler()

Q("__♥__♥)__♥__") {

	AddXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.05 second(s)

/*---------

StartProfiler()

Q("__♥)__♥__♥__") {

	AddXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __(♥)__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

Q("__♥__♥__♥)__") {

	AddXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()
# Executed in 0.05 second(s)

/*===------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT(" ", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
	? Content()
	#--> __/♥\__/♥\__/♥\__
}
# Executed in 0.06 second(s)

StopProfiler()

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__/♥\__♥__
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__♥__/♥\__/♥\__") {

	AddXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__/♥\__/♥\__♥__") {

	AddXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.07 second(s)

/*=====================

StartProfiler()

acOtherLangs = [ "JS", "C#", "PHP", "Python" ]

o1 = new stzString("JS style can be used in Ring!")

o1.Replace("JS", :By@ = '
	QR(acOtherLangs, :stzListOfStrings).
	ConcatenateXTQ([ :Using = ", ", :LastSep = ", and " ]).
	AddQ("s", :To = "style").
	Content()
')


? o1.Content()

StopProfiler()

/*------------------

StartProfiler()

o1 = new stzListOfStrings([ "Ring", "Python", "PHP", "JS" ])
? o1.ConcatenateXT(", ")
#--> Ring, Python, PHP, JS

? o1.ConcatenateXT(:Using = ", ")
#--> Ring, Python, PHP, JS

? o1.Concatenate()
#--> RingPythonPHPJS

? o1.ConcatenateUsing(", ")
#--> Ring, Python, PHP, JS

StopProfiler()
# Executed in 0.01 second(s)

/*==================

profon()

o1 = new stzString("ab")
? @@( o1.CommonSubStrings(:With = "abc") )
#--> [ "a", "ab", "b" ]

proff()
# Executed in 0.08 second(s)

/*-------------

profon()

aList1 = Q("Ring is nice").SubStrings()
aList2 = Q("I love Ring").SubStrings()

? @@( Q(aList1).CommonItems(aList2) ) + NL
#--> [ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ]
# Executed in 0.64 second(s)

o1 = new stzListOfLists([ aList1, aList2 ])
? @@( o1.CommonItems() )
#--> [ "i", " ", "n", "e", "R", "Ri", "Rin", "Ring", "in", "ing", "ng", "g" ]
#--> Executed in 0.64 second(s)

proff()
# Executed in 1.04 second(s)

/*-------------

profon()

o1 = new stzString("Ring is nice")
? @@( o1.CommonSubStrings(:With = "I love Ring") )
#--> [ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ]

proff()
# Executed in 0.64 second(s)

/*==================

StartProfiler()

o1 = new stzString("ABC♥DEF★GHI♥JKL")
o1.ReplaceW(' Q(@char).IsNotLetter() ', :With = " ")
? o1.Content()
#--> ABC DEF GHI JKL

StopProfiler()
#--> Executed in 0.14 second(s)

/*==================

o1 = new stzString("_♥_★_♥_")

? @@( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzString("_♥_★_♥_")
? @@( o1.TheseCharsZ([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@( o1.TheseCharsZ([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

/*-----------------

o1 = new stzString("12345")

? o1.Section(2, 4)
#--> "234"

? o1.Section(2, -2)
#--> "234"

? o1.Section(:First, :Last)
#--> "12345"

? o1.Section(3, :@)
#--> "3"

? o1.Section(:@, 3)
#--> "3"

/*================

profon()

o1 = new stzString("abAb")

? o1.NumberOfSubStrings()
#--> 10
# Executed in 0.02 second(s)

? @@( o1.SubStrings() )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ]
# Executed in 0.04 second(s)

? o1.NumberOfSubStringsCS(_FALSE_)
#--> 7
# Executed in 0.12 second(s)

? @@( o1.SubStringsCS(_FALSE_) )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ]
# Executed in 0.12 second(s)

proff()
#--> Executed in 0.27 second(s)

/*----------

profon()

o1 = new stzString("hello")
? o1.NumberOfSubStrings()
#--> 15

? @@( o1.SubStrings() )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "l", "lo",
#	"o"
# ]

proff()
# Executed in 0.06 second(s)

/*----------

profon()

o1 = new stzString("hello")
? o1.NumberOfSubStringsCS(_FALSE_)
#--> 14

? @@( o1.SubStringsCS(_FALSE_) )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "lo",
#	"o"
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.54 second(s) in Ring 1.18

/*----------

profon()

o1 = new stzString("*4*34")
? o1.NumberOfSubStrings()
#--> 15

? @@( o1.SubStrings() )
#--> [
#	"*", "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*",
#	"*3", "*34", "3", "34", "4"
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("123456")
? o1.NumberOfSubStrings()
#--> 21

? @@( o1.SubStrings() )
#--> [
#	"1", "12", "123", "1234", "12345", "123456", "2",
#	"23", "234", "2345", "23456", "3", "34", "345",
#	"3456", "4", "45", "456", "5", "56", "6"
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.19

/*==========

profon()

o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.NumbersComingAfter("@i")
#--> [ "-3", "3" ]

? o1.NumbersComingAfterQ("@i").NumbrifyQ().Smallest()
#--> -3

? o1.NumbersComingAfterQ("@i").NumberifyQ().Greatest()
#--> 3

proff()
# Executed in 0.23 second(s) in Ring 1.21

/*----------

profon()

o1 = new stzString("@item = This[ @i+1 ]")

? @@( o1.Numbers() ) + NL
#--> [ "+1" ]

? @@( o1.NumbersAfter("@i") )
#--> [ "+1" ]

proff()
# Executed in 0.12 second(s) in Ring 1.21

/*=================

profon()

o1 = new stzString("123456789")

//? o1.Section(3, -3)
#!--> ERROR: Indexes out of range! n1 and n2 must be inside the string.

? o1.SectionXT(3, -3)
#--> "34567"

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=================

profon()

o1 = new stzString("... ____ ... ____")
? o1.Find("...")
#--> [ 1, 10 ]

? @@( o1.FindZZ("...") )
#--> [ [ 1, 3 ], [ 10, 12 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------

profon()

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@( o1.Find("12.34") ) + NL
#--> [ 7, 39 ]

? @@( o1.FindAsSections("12.34") ) + NL
#--> [ [ 7, 11 ], [ 39, 43 ] ]

? @@( o1.FindManyAsSections([ "12.34", "-56.30", "77.12" ]) )
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*=================

profon()

o1 = new stzString("-23.67 pounds")
? o1.StartsWithANumber() # Or BeginsWith...
#--> _TRUE_

? o1.StartingNumber()
#--> "-23.67"

? o1.StartsWithThisNumber("-23.67") # OR StartsWithNumberN(...)
#--? _TRUE_

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzString("Amount: -132.45")
? o1.EndsWithANumber()
#--> _TRUE_

? o1.EndsWithThisNumber("-132.45")
#--> _TRUE_

? o1.TrailingNumber()
#--> "-132.45"

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> _TRUE_

//? o1.EndsWithNumber("+132.45")
#--> ERROR: Calling function with extra number of parameters

? o1.EndsWithNumberN("+132.45") #NOTE
				# the N a the end of function name
				# Or you can say EndsWithThisNumber(...)
#--> _TRUE_

? o1.TrailingNumber()
#--> "+132.45"

proff()
#--> Executed in 0.04 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> _TRUE_

? o1.EndsWithNumberN("132.45")
#--> _TRUE_

? o1.TrailingNumber()
#--> "+132.45"

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*==================

profon()

o1 = new stzList([ ".", ".", "M", ".", "I", "X" ])
? o1.FindWXT(' @char = "." ')
#--> [1, 2, 4]

proff()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.17

/*============== #TODO Test it after adding Yield()

profon()

o1 = new stzString("..ONE...TWO..")
? @@( o1.FindCharsWXT(:Where = 'QR(@char, :stzChar).IsALetter()') )
#--> [ 3, 4, 5, 9, 10, 11 ]

	#WARNING
	# If you use FindW instead of FindCharsW, yu will get an error:
	# ~> Can't create the char object.
	# The error occures because FindW is presumed to be FindSubStringsW,
	# and hence the string provided ("..ONE...TWO..") is transformed to
	# a list of all possible substrings ([ ".", "..", "..O", ...]), where
	# '..O' for example can not be caste into a char.

? @@( o1.YieldCharsWXT( '@char', :Where = 'Q(@char).IsALetter()' ) )
#--> [ "O", "N", "E", "T", "W", "O" ]

proff()
# Executed in 0.57 second(s).

/*===============

profon()

o1 = new stzString("AB12CD345")
? @@( o1.SplitToPartsOfNChars(2) ) # Same as SplitToPartsOfExactlyNChars(2)
#--> [ "AB", "12", "CD", "34" ]

? @@( o1.SplitToPartsOfNCharsXT(2) )
#--> [ "AB", "12", "CD", "34", "5" ]

proff()
# Executed in 0.04 second(s).

/*===================

profon()

o1 = new stzString("ABC")
? @@( o1.SubStrings() )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

proff()
# Executed in 0.02 second(s).

/*------------------

profon()

o1 = new stzString("*#!ABC$^..")
? o1.NumberOfSubStrings()
#--> 55

? @@( o1.SubStringsWXT(' Q(@SubString).IsMadeOfLetters() ') )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

proff()
# Executed in 0.58 second(s) in Ring 1.22
# Executed in 0.99 second(s) in Ring 1.19

/*==================

profon()

o1 = new stzList([ ".",".",".", 4, 5, 6,".",".","." ])

? o1.NextNItems(3, :StartingAtPosition = 3)
#--> [ 4, 5, 6 ]

? o1.PreviousNItems(3, :StartingAtPosition = 7)
#--> [ 4, 5, 6 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*------------------

profon()

o1 = new stzString("...456...")

? o1.NextNChars(3, :StartingAt = 3)
#--> [ "4", "5", "6" ]

? o1.PreviousNChars(3, :StartingAtPosition = 7)
#--> [ "4", "5", "6" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*================== 

profon()

? @@( QQ([ 4, 8, 10, 14, 16, 18 ]).Sectioned() )
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 10 ], [ 11, 14 ], [ 15, 16 ], [ 17, 18 ] ]

proff()
#--> Executed in 0.02 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("...12..1212..121212..12.")

aSections = o1.FindZZ("12")
#--> [ [ 4, 5 ], [ 8, 9 ], [ 10, 11 ], [ 14, 15 ], [ 16, 17 ], [ 18, 19 ], [ 22, 23 ] ]

o1 = new stzListOfSections(aSections)
o1.MergeContiguous()

? @@( o1.Content() )
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*------------------

StartProfiler()
#                      4   8 01  4 6 89  23
o1 = new stzString("...12..1212..121212..12.")

? @@( o1.FindMadeOf("12") ) + NL
#--> [ 4, 8, 14, 22 ]

? @@( o1.FindMadeOfZZ("12") ) + NL # Or FindMadeOfAsSections
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

? @@( o1.SubStringsMadeOf("12") ) + NL
#--> [ "12", "1212", "121212", "12" ]

? @@NL( o1.SubStringsMadeOfZZ("12") )
#--> [
#	[ "12", [ 4, 5 ] ],
#	[ "1212", [ 8, 11 ] ],
#	[ "121212", [ 14, 19 ] ],
#	[ "12", [ 22, 23 ] ]
# ]

StopProfiler()
# Executed in 0.06 second(s) in Ring 1.22

/*=============

profon()

o1 = new stzSplitter(8)
? @@( o1.SplitAt([3, 5]) )
#--> [ [ 1, 2 ], [ 4, 4 ], [ 6, 8 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*--------

profon()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? o1.FindW('This[@i] = "*"')
#--> [4, 7]
# Executed in 0.05 second(s)

o1.SplitAtPositions([ 4, 7])
? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.08 second(s) in Ring 1.21

/*--------

profon()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

o1.SplitW('This[@i] = "*"')

? @@( o1.Content() )
# [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.07 second(s) in Ring 1.21

/*--------

profon()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

? o1.FindWXT('@CurrentItem = "*"')

o1.SplitAtPositions([ 4, 7 ])
? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 0.44 second(s) in Ring 1.17

/*--------

profon()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

o1.SplitWXT('@CurrentItem = "*"')

? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.09 second(s) in Ring 1.21

/*==============

profon()

o1 = new stzString("..._...__...___...")
? @@( o1.FindALL("_") )
#--> [ 4, 8, 9, 13, 14, 15 ]

? @@( o1.FindSubstringsMadeOfZZ("_") )
#--> [ [ 4, 4 ], [ 8, 9 ], [ 13, 15 ] ]

? o1.SubStringsMadeOf("_")
#--> [ "_", "__", "___" ]

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("-132114.45 euros and 246 cents")

? @@( o1.FindNumbers() ) + NL
#--> [ 1, 22 ]

? @@( o1.FindNumbersZZ() )  + NL
#--> [ [ 1, 10 ], [ 22, 24 ] ]

? @@( o1.Numbers() ) + NL
#--> [ "-132114.45", "246" ]

? @@( o1.NumbersZZ() ) + NL
#--> [ [ "-132114.45", [ 1, 10 ] ], [ "246", [ 22, 24 ] ] ]

? o1.StartsWithANumber()
#--> _TRUE_

? o1.StartsWithThisNumber("-132")
#--> _TRUE_

? o1.StartsWithThisNumber("-132114.45") + NL
#--> _TRUE_

? o1.LeadingNumber()
#--> "-132114.45"

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@( o1.Numbers() ) + NL
#--> [ "12.34", "-56.30", "12.34", "77.12" ]

? @@( o1.UniqueNumbers() ) + NL
#--> [ "12.34", "-56.30", "77.12" ]

#--

? @@( o1.FindNumbers()) + NL
#--> [ 7, 21, 39, 55 ]

? @@( o1.FindNumbersZZ() ) + NL # FindNumbersAsSections
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

? @@NL( o1.NumbersZ() ) + NL # Same as NumbersAndTheirPositions()
#--> [
#	[ "12.34", [ 7, 39 ] ],
#	[ "-56.30", [ 21 ] ],
#	[ "77.12", [ 55 ] ]
# ]

? @@NL( o1.NumbersZZ() ) # Same as NumbersAndTheirSections()
#-->
# [
# 	[ "12.34", 	[ [ 7, 11 ], [ 39, 43 ]	] ],
#	[ "-56.30",	[ [ 21, 26 ] ] ],
#	[ "77.12", 	[ [ 55, 59 ] ] ]
# ]

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*================

StartProfiler()

o1 = new stzString( " This 10 : @i - 1.23 and this: @i + 378.12! " )
? o1.NumbersComingAfter("@i")
#--> [ "-1.23", "378.12" ]

? o1.NthNumberComingAfter(2, "@i") + NL
#--> "378.12"

? o1.Numbers()
#--> [ "10", "-1.23", "378.12" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.51 second(s) in Ring 1.17

/*-----------------

profon()

o1 = new stzString( " This[ @i - 1 ] = This[ @i + 3 ] " )
? o1.NumbersComingAfter("@i")
#--> [ "-1", "3" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.17

/*=============

profon()

? SoftanzaLogo()
#--> 
'
╭━━━┳━━━┳━━━┳━━━━┳━━━┳━╮╱╭┳━━━━┳━━━╮
┃╭━╮┃╭━╮┃╭━━┫╭╮╭╮┃╭━╮┃┃╰╮┃┣━━╮━┃╭━╮┃
┃╰━━┫┃╱┃┃╰━━╋╯┃┃╰┫┃╱┃┃╭╮╰╯┃╱╭╯╭┫┃╱┃┃
╰━━╮┃┃╱┃┃╭━━╯╱┃┃╱┃╰━╯┃┃╰╮┃┃╭╯╭╯┃╰━╯┃
┃╰━╯┃╰━╯┃┃╱╱╱╱┃┃╱┃╭━╮┃┃╱┃┃┣╯━╰━┫╭━╮┃
╰━━━┻━━━┻╯╱╱╱╱╰╯╱╰╯╱╰┻╯╱╰━┻━━━━┻╯╱╰━

Programming, by Heart! By: M.Ayouni╭
━━╮╭━━━━━━━━━━━━━━━━━━━━╮╱╭━━━━━━━━╯
  ╰╯
'
proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-----------------

profon()

? Basmalah()	#--> ﷽
? Heart()	#--> ♥
? 3Hearts()	#--> ♥♥♥
? 5Stars()	#--> ★★★★★

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------------

profon()

? Heart()
#--> ♥

? Q(Heart()).RepeatedNTimes(3)
#--> ♥♥♥

# or you can use the short form .NTimes(3)

? Q("Go").RepeatedNTimes(3)
#--> GoGoGo

? @@( Q([ "A", "B" ]).RepeatedNTimes(3) )
#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

? Five(Star())
#--> ★★★★★

? Three(Heart())
#--> ♥♥♥

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*------------------

profon()

o1 = new stzString("{abc}")

o1.RemoveThisFirstChar("{")
o1.RemoveThisLastChar("}")

? o1.Content()
#--> abc

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*------------------ #narration

profon()

# When applied to the string "Hi!", RepeatedNTimes() will duplicate
# it, resulting in "Hi!Hi!Hi!".

? Q("Hi!").RepeatedNTimes(3)
#--> "Hi!Hi!Hi!"

# For all other types (stzList, stzNumber, and stzObject),
# it repeats the object value within a list:

? Q(5).RepeatedNTimes(3)
#--> [5, 5, 5]

? Q(1:3).RepeatedNTimes(3)
#--> [ 1:3, 1:3, 1:3 ]

# You might ask why we chose different behavior for strings
# compared to other types, and why we don't produce a list 
# when the function is applied to a string, like this:
# ? Q("Hi!").RepeatNTimes(3) #!--> [ "Hi!", "Hi!", "Hi!" ] ?

# The reason is that it feels more intuitive to duplicate the
# string directly when asked to repeat it, producing a string
# as the result, rather than a list!

# If you'd like to avoid potential confusion from this dual behavior,
# you can use RepeatNTimesXT(), where you explicitly specify the
# desired output format, like this:

? Q("Hi!").RepeatedNTimesXT(3, :InAString)
#--> "Hi!Hi!Hi!"

? Q("Hi!").RepeatedNTimesXT(0, :InAList)
#--> [ "Hi!", "Hi!", "Hi!" ]

proff()
# Executed in 0.08 second(s) in Ring 1.21

/*----------------------

profon()

# Because Softanza mimics natural language train of thoughts,
# the computational form:

? NOT Q("*").IsLetter()

# Can be written:

? Q("*").IsNotLetter() + NL

# This called @FunctionNegativeForm in Softanza.

#NOTE: Not all Softanza functions made ready for their negative forms,
# but this will be done in the future.

#NOTE: @FunctionNegativeForm is different from @FunctionPassiveForm,
# which is the linguitsic passive form of the function verb. For example:

o1 = new stzString("RIxxNxG")
o1.Remove("x") # ~> This is the active form of the function
#--> All "x" chars are now removed from the object content.
? o1.Content()
#--> RING

# Hence, the active form (expressed with the verb Remove()) modifies
# the content of the object. In some cases, however, you need to
# perform the removal without altering the original content...

# Lingusitically speaking, you want a copy of this string from
# wich the "x" chars are removed, while leaving the original content as is.

# Here comes the usefulness of the @FunctionPassiveform. Let's redo
# the same sample to show you this:

o1 = new stzString("RIxxNxG")
? o1.Removed("x")
#--> RING

# and the original obkect is not changed:
? o1.Content()
#--> RIxxNxG


proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------------------

profon()

? Q("ONE-TWO-THREE").Split("-")
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE").SplitAtCharsWXT('{ Q(@char).IsNotLetter() }')
#--> [ "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.18 second(s) in Ring 1.21

/*=================

profon()

o1 = new stzString("RingRingRing")

? o1.SplitWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitAtWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitWXT(:At = "Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

proff()
# Executed in 0.41 second(s) in Ring 1.21

/*-----------

profon()

o1 = new stzString("RingRingRing")

? @@( o1.SplitWXT(:At = " @position % 4 = 0 ") )
#--> [ "Rin", "Rin", "Rin" ]

? @@( o1.SplitWXT(:After = " @position % 4 = 0 ") )
#--> [ "Ring", "Ring", "Ring" ]

proff()
# Executed in 0.19 second(s) in Ring 1.21

/*-----------

profon()

? Q([ "atchars", "Q(@char).IsUppercase()" ]).IsAtCharsNamedParam()
#--> _TRUE_

proff()

/*-------

profon()

o1 = new stzString("RingRingRing")

? o1.SplitAtCharsWXT("Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

? o1.SplitWXT(:AtChars = "Q(@char).IsUppercase()")
#--> [ "ing", "ing", "ing" ]

proff()
# Executed in 0.31 second(s) in Ring 1.21

/*-----------

profon()

o1 = new stzString("JuliaRingRuby")

? o1.SplitWXT(:AroundSubString = ' @substring = "Ring" ')
#--> [ "Julia", "Runby" ]

? o1.SplitWXT(:BeforeSubString = ' @substring = "Ring" ')
#--> [ "Julia", "Ruby" ]

? o1.SplitWXT(:AfterSubString = ' @substring = "Ring" ')
#--> [ "JuliaRing", "Ruby" ]

proff()
# Executed in 0.97 second(s) in Ring 1.21

/*-------------

profon()

o1 = new stzString("---4---8---")

? @@( o1.SplitBeforePositions([ 4, 8 ]) ) + NL
#--> [ "---", "4---", "8---" ]

? @@( o1.SplitWXT(:BeforePositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---", "4---", "8---" ]

proff()
# Executed in 0.13 second(s) in Ring 1.21

/*-------------

profon()

o1 = new stzString("---4---8---")

? @@( o1.SplitAfterPositions([ 4, 8 ]) ) + NL
#--> [ "---4", "---8", "---" ]

? @@( o1.SplitWXT(:AfterPositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---4", "---8", "---" ]

proff()
# Executed in 0.13 second(s) in Ring 1.21

/*-------------

profon()

o1 = new stzString("---4---8---")

? @@( o1.SplitAroundPositions([ 4, 8 ]) ) + NL
#--> [ "---", "---", "---" ]

? @@( o1.SplitWXT(:AroundPositions = ' Q(@position).IsOneOfThese([ 4, 8 ]) ') )
#--> [ "---", "---", "---" ]

proff()
# Executed in 0.13 second(s) in Ring 1.21

/*---------------------- #narration

profon()

# Five nice usecases of the / operator on a Softanza string:

# Use case 1: Dividing the string into 3 equal parts

? Q("RingRingRing") / 3
#--> [ "Ring", "Ring", "Ring" ]

# Use case 2: Splitting the string using a given char

? Q("Ring;Python;Ruby") / ";"
#--> [ "Ring", "Python", "Ruby" ]

# Use case 3: Splitting the string at chars that satisfy a condition

? Q("Ring:Python;Ruby") / WXT('Q(@Char).IsNotLetter()')
#--> [ "Ring", "Python", "Ruby" ]

# Use case 4: Distributing the string equally among three stakeholders

? @@( Q("RingRubyJava") / [ "Qute", "Nice", "Good" ] ) + NL
#--> [ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ]

# Usecase 5: Allocating chars to stakeholders based on specified portions

? @@( Q("IAmRingDeveloper") / [
	:Subject = 1,
	:Verb    = 2,
	:Noun1   = 4,
	:Noun2   = :RemainingChars
])
#--> [ :Subject = "I", :Verb = "Am", :Noun1 = "Ring", :Noun2 = "Developer" ]

proff()
# Executed in 0.20 second(s) in Ring 1.21

/*---------------

profon()

? PLuralOfThisStzType("stzChar")
#--> "stzchars"

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*---------------

profon()

? Q("stzchars").IsPluralOfAStzType()
#--> _TRUE_

? Q("stzchars").IsPluralOfThisStzType("stzchar")
#--> _TRUE_

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*---------------

profon()

? Q("punctuation").InfereMethod(:From = :stzChar)
#--> "ispunctuation"

? Q("punctuations").InfereMethod(:From = :stzChar)
#--> "ispunctauion"

proff()
# Executed in 0.32 second(s) in Ring 1.21

/*================= #narration "What You Think Is What You Write"

profon()

# In plain english, when you see "12309" you would say
# all "chars are numbers". In Softanza, it's the same:

? Q("12309").CharsQ().NumbrifiedQ().Are(:Numbers)
#--> _TRUE_

# For "248", yoou say "chars are even positive numbers"
# In Softanza, it's exactly the same:

? Q("248").CharsQ().NumberifiedQ().Are([ :Even, :Positive, :Numbers ])
#--> _TRUE_

# In this example, "chars are punctuations", right?

? Q([ ",", ":", ";" ]).Are([ :Punctuation, :Chars ])
#--> _TRUE_

# In Softanza, "What You Think Is What You Write".

proff()
# Executed in 0.19 second(s) in Ring 1.21

/*---

profon()

? Q("Riiiiinngg").UniqueChars()
#--> [ "R", "i", "n", "g" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*====

profon()

o1 = new stzList([ "A", "A", "A", "B", "B", "C" ])
? o1.FindNthCS(3, "A", _FALSE_)
#--> 3

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

profon()

? StzListQ([ "A", "A", "A", "B", "B", "C" ]).ContainsCS("a", _FALSE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

profon()

? StzListQ([ "A", "A", "A", "B", "B", "C" ]).DuplicatesRemoved()
#--> [ "A", "B", "C" ]

proff()
# Executed in almost 0 second(s).

/*---

profon()

? Q("Riiiiinngg").
	CharsQ().
	RemoveDuplicatesQ().
	ToStzListOfStrings().
	Concatenated()

#--> "Ring"

proff()
# Executed in 0.02 second(s).

/*---

profon()

? Q("Riiiiinngg").DuplicatedCharsRemoved()
#--> "Ring"

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*===========

profon()

? Q("123.98").IsNumberInString()
#--> _TRUE_

? IsNumberInString("123.98")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*----------

profon()

o1 = new stzString("(9, 7, 8)")

o1.RemoveCharsWXT('Q(@Char).IsNumberInString()')
? o1.Content()
#--> (, , )

proff()
# Executed in 0.15 second(s) in Ring 1.22

/*------

profon()

? Q("(9, 7, 8)").
	RemoveCharsWXTQ('Q(@Char).IsNumberInString()'). # becomes (, , )
	RemoveSpacesQ().			 	# becomes (,,)
	RemoveDuplicatedCharsQ().		 	# becomes (,)
	Content()

#--> (,)

proff()
# Executed in 0.17 second(s) in Ring 1.22

/*---

profon()

? Q(" ").IsNumberInString()
#--> _FALSE_

proff()

/*---

profon()

? @ReplaceCS("ruby RING python", "ring", "julia", _TRUE_)
#--> ruby RING python

? @ReplaceCS("ruby RING python", "ring", "julia", _FALSE_)
#--> ruby julia python

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

? @Contains(" Q(@char).IsNumberInString() ", "@char")
#--> _TRUE_

? @Contains(" Q(@char).IsNumberInString() ", "@substring")
#--> _FALSE_

? @ContainsCS(" Q(@char).IsNumberInString() ", "@CHAR", _FALSE_)
#--> _TRUE_

? @ContainsCS(" Q(@char).IsNumberInString() ", "@substring", _TRUE_)
#--> _FALSE_

? @ContainsCS(" Q(@char).IsNumberInString() ", "@substring", _FALSE_)
#--> _FALSE_

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

o1 = new stzString(" Q(@char).IsNumberInString() ")

? o1.ContainsCS("@char", _FALSE_)
#--> _TRUE_

? o1.ContainsCS("@substring", _FALSE_)
#--> _FALSE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---

profon()

? @@( Q("1 AA 6 B 0 CCC 6 DD 1 Z").FindWXT(' Q(@char).IsNumberInString() ') )
#--> [ 1, 6, 10, 16, 21 ]

proff()

/*======= KEEPING THE HISTORY OF UPDATES OF A SOFTANZA OBJECT

profon()

# Consider this basic string transformation chain in Softanza:

? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	Content() + NL
	#--> ABCDZ

# Here, we process the string, removing numbers, spaces,
# and # duplicate characters. The result is clear, but
# the path is forgotten.

# What if we could capture each step of this transformation?
# Say hello the QH() small function:

? @@NL( QH("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	History() ) + NL

#--> [
#	"1 AA 2 B 3 CCC 4 DD 5 Z",
#	" AA  B  CCC  DD  Z",
#	"AABCCCDDZ",
#	"ABCDZ"
# ]

proff()
# Executed in 0.44 second(s) in Ring 1.22

/*-----

profon()

? @@( Q([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
	RemoveWXTQ('isNumber(@item)').
	RemoveSpacesQ().
	RemoveDuplicatedItemsQ().
	Content() ) + NL

#--> [ "A", "B", "C", "D" ]

? @@NL( QH([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
	RemoveWXTQ('isNumber(@item)').
	RemoveSpacesQ().
	RemoveDuplicatedItemsQ().
	History() ) 

#--> [
#	[ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ],
#	[ " ", " ", "A", "A", "B", "C", "C", "C", "D", "D" ],
#	[ "A", "A", "B", "C", "C", "C", "D", "D" ],
#	[ "A", "B", "C", "D" ]
# ]

proff()
# Executed in 0.17 second(s) in Ring 1.22

/*-----

profon()

? Q(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	Value()

	#--> 45

? @@( Qh(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	History() )

	#--> [ 13000, 11500, 23, 46 ]

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*-----

profon()

? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	Content() + NL
#--> ABCDZ

KeepHistory()

? @@NL( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	History() ) + NL

#--> [
#	"1 AA 2 B 3 CCC 4 DD 5 Z",
#	" AA  B  CCC  DD  Z",
#	"AABCCCDDZ",
#	"ABCDZ"
# ]

DontKeepHistory()

? @@( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	History() )
#--> [ ]

proff()
# Executed in 0.65 second(s) in Ring 1.22

/*============

profon()

str = "sun"
? Q(str).IsEither("moon", :Or = "sun")
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

? Q("stzLen").IsAFunction() # or isFunc()
#--> _TRUE_

? Q("stzChar").IsAClass()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

? QQ("ر").StzType()
#--> stzChar

? @@( QQ("ر").UnicodeDirectionNumber() )
#--> "13"

? QQ("ر").IsRightToLeft()
#--> _TRUE_

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

? StzCharQ("L").Turned()
#--> ⅂

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

? Q("LOVE").Inverted()
#--> EVOL

? Q("LOVE").CharsInverted()	# Or Turned()
#--> ƎɅO⅂

? QQ("L").IsInvertible()	// #NOTE that QQ() elevates "L" to a stzChar
#--> _TRUE_

proff()
# Executed in 0.07 second(s).

/*-----------------

profon()

? Q("LOVE").Turned()
#--> ƎɅO⅂

proff()
# Executed in 0.05 second(s).

/*-----------------

profon()

? StzStringQ("s").IsAString()
#--> _TRUE_

? StzCharQ("s").IsAString()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

? Q("str").AllCharsAre(:Chars)
#--> _TRUE_

? Q("str").AllCharsAre(:Strings)
#--> _TRUE_

? Q("123").AllCharsAre(:Numbers)
#--> _TRUE_

? Q("(,)").AllCharsAre(:Punctuations)
#--> _TRUE_

? Q("نور").AllCharsAre(:Arabic)
#--> _TRUE_

? Q("نور").AllCharsAre(:RightToLeft)
#--> _TRUE_

? Q("LOVE").AllCharsAre(:Invertible)
#--> _TRUE_

? Q("LOVE").CharsInverted()
#--> ƎɅO⅂

proff()
# Executed in 2.71 second(s).

/*-----------------

profon()

? Q(2).IsANumber()
#--> _TRUE_

? Q(2).IsEven()
#--> _TRUE_

? Q(2).IsPositive()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

? QQ("①").IsCircledNumber()
#--> _TRUE_

# or QQ("①").IsCircledDigit() if you wana embrace the semantics of Unicode

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

? Q("①②③").AllCharsAre(:CircledNumbers)
#--> _TRUE_

? Q("①②③").AllCharsAre([:CircledNumber, :Chars]) #TODO check after reincluding check()
#--> _TRUE_

proff()

/*----------------- #TODO check after reincluding check()

profon()

? Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL)

? Q("123").Check( 'isnumber( 0+(@char) )' ) #--> _TRUE_

proff()

/*=================

profon()

# Inverting (or turning) chars and strings
#NOTE: In the mean time, Softanza uses Invert()
# and Turn() as alternatives, but this should
# change in the future to cope with their exact
# meaning in Unicode!

? StzCharQ("L").IsInvertible() # Or IsTurnable()
#--> _TRUE_

? StzCharQ("L").Inverted() # Or Turned()
#--> ⅂

? Q("LIFE").Inverted()
#--> EFIL

? Q("LIFE").Turned() # Or CharsInverted()
#--> ƎℲI⅂

proff()
# Executed in 0.07 second(s).

/*============

profon()

? Q(".;1;.;.;." ) / ";" # Same as: ? Q(".;1;.;.;." ).Splitted(:Using = ";")

#--> [ ".", "1", ".", ".", "." ]

proff()
# Executed in 0.01 second(s).

/*===============

profon()

? Q("Ring").Repeated(3)
#--> "RingRingRing"

? @@( Q([1,2]).Repeated(3) )
#--> [ [1,2], [1,2], [1,2] ]

proff()
# Executed in 0.03 second(s).

/*----------------

profon()

# Softanza have a Repeat() function you can use like thois:

? Repeat("A", 3)
#--> [ "A", "A", "A" ]

# Which is the same as:

? RepeatInList("A", 3)

# And when you want the repetinion putpt to be a sitring:

? RepeatInString("A", 3) # Equaivalent of Ring copy() function
#--> "AAA"

# But this is just a part of the story. Say hello the extented RepeatXT() function!
# ~> See next narration.
proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----------------

profon()

? Q("A").RepeatXTQ(:String, 3).StzType()
#--> "stzstring"

? Q("A").RepeatXTQ(:List, 3).StzType()
#--> "stzlist"

proff()
# Executed in 0.02 second(s).

/*---- #narration EXTENDED FORMS OF REPEATING OBJECTS IN SOFTANZA

profon()

# Repeating "5" twice in a list

? @@( Q("5").RepeatedXT(:InA = :List, :OfSize = 2) )
#--> [ "5", "5" ]

# Creating a pair with "A" repeated

? Q("A").RepeatedInAPair()
#--> [ "A", "A" ]

# Repeating char "5" three times in a list of numbers

? @@( Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3) )
#--> [ 5, 5, 5 ]

# Repeating the number 5 three times in a string

? Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

# Repeating number 5 three times in a string

? Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

# Repeating "5" three times in a list of numbers

? Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3)
#--> [ 5, 5, 5 ]

# Repeating number 5 three times in a list of strings

? @@( Q(5).RepeatedXT(:InA = :ListOfStrings, :OfSize = 3) )
#--> [ "5", "5", "5" ]

# Repeating "A" three times in a list of pairs

? @@( Q("A").RepeatedXT(:InA = :ListOfPairs, :OfSize = 3) ) + NL
#--> [ [ "A", "A" ], [ "A", "A" ], [ "A", "A" ] ]

# Repeating "A" three times in a list of lists

? @@( Q("A").RepeatedXT(:InA = :ListOfLists, :OfSize = 3) ) + NL
#--> [ [ "A" ], [ "A" ], [ "A" ] ]

# Repeating "A" three times in a list, then repeating that list three times

? @@( Q("A").
	RepeatXTQ(:InA = :List, :OfSize = 3).
	RepeatedXT(:InA = :List, :OfSize = 3)
) + NL
#--> [ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ]

# Creating a 3x3 grid filled with "A"

? @@( Q("A").RepeatedXT(:InA = :Grid, :OfSize = [3, 3]) ) + NL
#-->
# [
# [ "A", "A", "A" ],
# [ "A", "A", "A" ],
# [ "A", "A", "A" ]
# ]

# Creating a 3x3 table filled with "A"

? @@( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]) ) + NL
#--> [
# [ "COL1", [ "A", "A", "A" ] ],
# [ "COL2", [ "A", "A", "A" ] ],
# [ "COL3", [ "A", "A", "A" ] ]
# ]

? Q("A").RepeatXTQ(:InA = :Table, :OfSize = [3, 3]).ToStzTable().Show()
#-->
# COL1   COL2   COL3
# ----- ------ -----
#   A      A      A
#   A      A      A
#   A      A      A

proff()
# Executed in 0.16 second(s) in Ring 1.22

/*-------------------

profon()

? Q(5).RepeatedInAPair()
#--> [5, 5]

proff()
# Executed in 0.01 second(s).

/*============

profon()

? Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content() + NL
#--> "HELLO"

? QH("h e l l o").RemoveSpacesQ().UppercaseQ().History()
#--> [ "h e l l o", "hello", "HELLO" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------

profon()

? KeepingTime()
#--> FALSE

SetKeepingTimeTo(_TRUE_)

? KeepingTime()
#--> TRUE

proff()

/*--------------

profon()

o1 = new stzList([ "H", " ", "E", " ", "L", " ", "L", " ", "O" ])
? @@( o1.FindEmptyStrings() )
#--> []

? o1.FindSpaces()
#--> [ 2, 4, 6, 8 ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*===============

profon()

? @@NL( Combinations([ "A", "B", "C" ], 2) )
#--> [
#	[ "A", "B" ],
#	[ "A", "C" ],
#	[ "B", "C" ]
# ]

? NL@@NL( CombinationsXT([ "A", "B", "C" ], 2) )
#--> [
#	[ "A", "A" ],
#	[ "A", "B" ],
#	[ "A", "C" ],

#	[ "B", "A" ],
#	[ "B", "B" ],
#	[ "B", "C" ],

#	[ "C", "A" ],
#	[ "C", "B" ],
#	[ "C", "C" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()

o1 = new stzList([ "V", "T", "M", "S" ])
? @@NL( o1.Combinations() )
#--> [
#	[ "V", "T" ],
#	[ "V", "M" ],
#	[ "V", "S" ],
#	[ "T", "M" ],
#	[ "T", "S" ],
#	[ "M", "S" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*================

profon()

o1 = new stzList([ "R", "I", "N", "G" ])

if o1.IsNotAString() and
   o1.IsNotInLowercase() and
   o1.DoesNotContain("♥") and

   o1.NumberOfChars() < 5 and
   o1.NumberOfCharsQ().IsNotOdd()

    ? "It's ok!"
else  
    ? "Oops!"
ok
#--? "It's ok!"

# Let's see the negative conditions one by one

? o1.IsNotAString()
#--> TRUE

? o1.IsNotInLowercase()
#--> TRUE

? o1.DoesNotContain("♥")
#--> TRUE

? o1.NumberOfChars() < 5
#--> TRUE

? o1.NumberOfCharsQ().IsNotOdd()
#--> TRUE

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("RIxxNxG")

? o1.SubString("x")
#--> "x"

? o1.SubStringQ("x").StzType() + NL
#--> stzstring

#--

? @@( o1.SubString("y") )
#--> NULL

? o1.SubStringQ("y").StzType()
# stznullobject

proff()
# Executed in 0.01 second(s) in Ring 1.22

#== @FunctionTempForm #TODO #NARRATION

profon()

o1 = new stzString("__Ri__ng__")

? o1.@("__").@Removed()
#--> Ring

? o1.@("__").UppercasedQ().AndThenQ().@Removed()
#--> RING

proff()
# Executed in 0.06 second(s) in Ring 1.22

#---

profon()

o1 = new stzString("__Ri__ng__")

o1.@("__").@Remove()
? o1.content()
#--> Ring

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*---

profon()

o1 = new stzString("__Ri__ng__")

o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()

? o1.Content()
"--> RING

proff()

/*---

profon()

o1 = new stzString("__Ri__ng__")

o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyIt()

? o1.Content()
#--> R I N G

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*----
*/
profon()

? Q("__Ri__ng__").
	@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItQ()
.Content()

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*=================
*/
profon()

# Here is a fluent chain of actions that starts from
# the word "LIFE" and ends at the word "L ♥ F E"

? Q("LIFE").
	LowercaseQ().
	SpacifyQ().

	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().

	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).

	Content() + NL
	#--> L ♥ F E

# We can see what happened internally interms of updates
# by adding the H suffix to the Q() while using History()

? @@NL(
	QH("LIFE").
	LowercaseQ().
	SpacifyQ().

	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().

	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).

	History()
) + NL
#--> [
#	"LIFE",
#	"life",
#	"l i f e",
#
#	[ "l", "i", "f", "e" ],
#	[ "L", "I", "F", "E" ],
#	[ "L", "I", "F", "E" ],
#
#	"L I F E",
#	"L ♥ F E"
# ]

# Or we add an HH() suffix if we need more inforamtion
# about the types of intermediate objects updated
# the execution time those update have taken, and
# their size in memory in bytes (inside the Ring VM)

? @@NL(
	QHH("LIFE").
	LowercaseQ().
	SpacifyQ().
	CharsQ().

	RemoveSpacesQ().
	UppercaseQ().
	JoinQ().

	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).
	History()
) + NL
#--> [
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "life", "stzstring", 0.02, 435 ],
#	[ "l i f e", "stzstring", 0.04, 435 ],
#
#	[ [ "l", " ", "i", " ", "f", " ", "e" ], "stzlist", 0, 322 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0, 319 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "L I F E", "stzstring", 0.02, 435 ],
#
#	[ [ "with", "♥" ], "stzlist", 0, 322 ],
#
#	[ "L ♥ F E", "stzstring", 0.01, 435 ]
# ]

# NOTE that only the methods that update the objects are traced!

proff()
# Executed in 0.13 second(s) in Ring 1.22s

/*------------------

profon()

decimals(3)

o1 = new stzTable([
	[ "VALUE", "TYPE", "TIME" ],
	#---------------------------#
	[ "LIFE", "stzstring", 0 ],
	[ "LIFE", "stzstring", 0.009 ],
	[ "L I F E", "stzstring", 0.009 ],
	[ [ "l", "i", "f", "e" ], "stzlist", 0.011 ],
	[ "LIFE", "stzstring", 0.026 ],
	[ "⅂IℲƎ", "stzstring", 0.071 ]
])

o1.Show()
#-->
#                  VALUE        TYPE    TIME
# ----------------------- ----------- ------
#                   LIFE   stzstring       0
#                   LIFE   stzstring   0.009
#                L I F E   stzstring   0.009
# [ "l", "i", "f", "e" ]     stzlist   0.011
#                   LIFE   stzstring   0.026
#                   ⅂IℲƎ   stzstring   0.071

proff()
# Executed in 0.071 second(s) in Ring 1.22

/*==================

profon()

o1 = new stzString("ab_cd_ef_gh")

? o1.ContainsMoreThenN(1, "_")
#--> _TRUE_

? o1.ContainsMoreThenN(1, "a")
#--> _FALSE_

? o1.ContainsNTimes(1, "a")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("ab_cd_ef_gh")
? o1.FindFirst("_")
#--> 3

? o1.FindFirstST("*", :StartingAt = 4)
#--> 0

? o1.FindFirstST("_", :StartingAt = 3)
#--> 3

? o1.FindLast("_")
#--> 9

? o1.FindLast("*")
#--> 0

? o1.FindNth(2,"_")
#--> 6

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("ab_cd_ef_gh")

? o1.FindFirstNOccurrences(2, "_")
#--> [3, 6]
? o1.FindLastNOccurrences(2, "_")
#--> [6, 9]

proff()
# Executed in 0.03 second(s).

/*------------------

profon()

o1 = new stzString("ab_cd_ef_gh")
? o1.FindAll("_")
#--> [3, 6, 9]

proff()

/*=================

profon()

o1 = new stzString("
lfldfkdlfk
mlsdlk

llkslkflk
   
medmf")

? @@NL( o1.Lines() ) + NL

? o1.NumberOfEmptyLines() + NL
#--> 3

o1.RemoveEmptyLines()
? o1.Content()
#-->
# lfldfkdlfk
# mlsdlk
# llkslkflk
# medmf

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("

.;1;.;.;.
1;2;3;4;5
.;3;.;.;.
.;4;.;.;.
.;5;.;.;.  " )

? o1.RemoveEmptyLinesQ().Content()
#-->
# .;1;.;.;.
# 1;2;3;4;5
# .;3;.;.;.
# .;4;.;.;.
# .;5;.;.;.  

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

aStzStrList = StzListOfStringsQ([ "one", "two", "three" ]).ToListOfStzStrings()

foreach oStr in aStzStrList
	? oStr.Uppercased()
next
#-- [ "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.02 second(s).

/*----------------- #narration #data-cleansing #data-transformation

profon()

# Let's start with a string containing semi-structured data.
# The data is separated by semicolons and spread across multiple
# lines, including empty lines.

o1 = new stzString("

	.;1;.;.;.
	1;2;3;4;5


	.;3;.;.;.
	.;4;.;.;.

	.;5;.;.;.  ")

# The goal is to transform the string into a clean,
# structured list of lists, where each inner list
# represents a row of data, like this:

#--> [
#	[ ".", "1", ".", ".", "." ],
#	[ "1", "2", "3", "4", "5" ],
#	[ ".", "3", ".", ".", "." ],
#	[ ".", "4", ".", ".", "." ],
#	[ ".", "5", ".", ".", "." ]
# ]

# If you think about it, these are the necessary steps:
#	1. Remove empty lines
#	2. Convert the remaining lines into a list of strings
#	3. Trim each string to remove any extra whitespace
#	4. Split each string using the semicolon as a delimiter

# Here is the translation of this thought process in Softanza:

? @@SP(
	o1.RemoveEmptyLinesQ().
	LinesQR(:stzListOfStrings).
	TrimQ().
	StringsSplitted(:Using = ";")
)
#--> [
#	[ ".", "1", ".", ".", "." ],
#	[ "1", "2", "3", "4", "5" ],
#	[ ".", "3", ".", ".", "." ],
#	[ ".", "4", ".", ".", "." ],
#	[ ".", "5", ".", ".", "." ]
# ]

# It's totally WYTIWYG: "What You Think Is What You Get"!

proff()
# Executed in 0.04 second(s).

/*=================

profon()

o1 = new stzString("How many <<many>> are there in (many <<<many>>>): so <many>>!")

? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, 2, 0, 3, [1,2] ])) + NL
#--> [ [ _NULL_, _NULL_ ], [ "<<", ">>" ], [ _NULL_, _NULL_ ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

//Same as:
? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ [0,0], [2, 2], [0,0], [3,3], [1,2] ]))
#--> [ [ _NULL_, _NULL_ ], [ "<<", ">>" ], [ _NULL_, _NULL_ ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

proff()

/*=================

profon()

o1 = new stzString("ACB")
o1.Move( :CharFromPosition = 3, :To = 2 )
? o1.Content()
#--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content()
#--> "ACB"

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzList([ "A", "C", "B" ])
o1.Move( :ItemFromPosition = 3, :To = 2 )
? o1.Content()
#--> [ "A", "B", "C" ]

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("TWO, ONE, THREE!")
o1.Swap("TWO", :And = "ONE") # Or SwapSubStrings()
? o1.Content()
#--> ONE, TWO, THREE!

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--------

profon()

o1 = new stzList([ "TWO", "ONE", "THREE" ])
o1.Swap("TWO", :And = "ONE")
? o1.Content()

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("*AB*")

? @@( o1.Find("*") )
#--> [1, 4]

# Or you can say:
? @@( o1.Find( :SubString = "*" ) )
#--> [1, 4]

# Or also:
? @@( o1.FindSubString( "*" ) )
#--> [1, 4]

# And many other alternatives that you can discover in the fucntion code

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*==================

profon()

? Q("NEXTAV TUNISIA").Section(:From = 1, :To = 6)
#--> "NEXTAV"

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*-----------------

profon()

? Q("SOFTANZA").NthToLast(3)
#--> "A"

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

? Q("SOFTANZA").Section(1, 4)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = 1, :To = 4)
#--> "SOFT"

? Q("SOFTANZA").Section(4, 1)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = :LastChar, :To = :FirstChar)
#--> "SOFTANZA"

? Q("SOFTANZA").Section(:From = "F", :To = "A")
#--> "FTANZA"

? Q("SOFTANZA").Section( :From = "A", :To = :EndOfString )
#--> "ANZA"

? Q("Programming By Heart!
     This is Softanza motto.").
	Section( :From = "By", :To = :EndOfLine) + NL
#--> "By Heart!"

? Q("SOFTANZA").Section(4, :@)
#--> "T"

? Q("SOFTANZA").Section(:NthToLast = 3, :@)
#--> "A"

? Q("SOFTANZA").Section(:@, :@)
#--> "SOFTANZA"

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*-----------------


? @@( Q("SOFTANZA").Section(-99, 99) )
#--> Indexes out of range! n1 and n2 must be inside the string.

/*-----------------

profon()

o1 = new stzString("and **<Ring>** and _<<PHP>>_ AND <Python/> and _<<<Ruby>>>_ ANDand !!C++!! and")
? @@( o1.Split( :Using = "and" ) )
#--> [ "<Ring> ", " <<PHP>> ", " <Python/> ", " <<<Ruby>>> ", "", " !!C++!!" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----------------- TODO: FUTURE

? o1.SplitXT(
	:Using = "and",

	[ 
	TRUE,
	:SkipEmptyParts = _TRUE_,

	:IncludeLeadingSep = _TRUE_,
	:IncludeTrailingSep = _TRUE_,

	:ExcludeLeadingSubstrings_FromSplittedParts = [ "_", "**" ],
	
	:ExcludeTrailingSubstrings_FromSplittedParts = [ "_", "**", "/>" ],

	:ExcludeLeadingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, "<" ],
	:ExcludeTrailingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, ">" ]
	]
)

/*================= #narration IDENTIFYING LISTS INSIDE A STRING

#NOTE // I made an article on the subject here:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/doc/narrations/stz-narration-list-in-strings.md

profon()

# In many situations (especially in advanced metaprogramming scenarios),
# you may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in runtime, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used ( noramal [ _ , _ , _ ] or short _:_ ), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,2,3]').IsListInString()		#--> _TRUE_

? StzStringQ('1:3').IsListInString()			#--> _TRUE_

? StzStringQ(' "A":"C" ').IsListInString()		#--> _TRUE_
? StzStringQ(' "ا":"ج" ').IsListInString() + NL		#--> _TRUE_

# Softanza can tell you if the syntax used is normal or short:

? StzStringQ('[1,2,3]').IsListInNormalForm()		#--> _TRUE_
? StzStringQ('1:3').IsListInShortForm()			#--> _TRUE_

? StzStringQ(' "A":"C" ').IsListInShortForm()		#--> _TRUE_
? StzStringQ(' "ا":"ج" ').IsListInShortForm() + NL	#--> _TRUE_

# And knows about the list beeing contiguous or not:

? StzStringQ('[1,3]').IsContiguousListInString()	#--> _FALSE_
? StzStringQ('1:3').IsContiguousListInString()		#--> _TRUE_

? StzStringQ(' "A":"C" ').IsContiguousListInString()	#--> _TRUE_
? StzStringQ(' "ا":"ج" ').IsContiguousListInString()	#--> _TRUE_

	# REMINDER: A contiguous list can be made of  numbers,
	# or contiguous chars (based on their unicode numbers).
	# And you can identify them using the stzList.IsContiguous():

	? StzListQ(1:3).IsContiguous()			#--> _TRUE_
	? StzListQ("A":"E").IsContiguous() + NL	#--> _TRUE_

# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is contiguous
# or not, it can also see in what form they are:

? StzStringQ('[1,2,3]').IsContiguousListInNormalForm()	#--> _TRUE_
? StzStringQ('1:3').IsContiguousListInShortForm()	#--> _TRUE_

? StzStringQ(' "A":"C" ').IsContiguousListInShortForm()	#--> _TRUE_
? StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm()	#--> _TRUE_
? NL

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,2,3]').ToListInShortForm() )	#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

? StzStringQ(' ["A","B","C","D"] ').ToListInShortForm()	#--> "A" : "D"
? StzStringQ(' "ا":"ج" ').ToListInShortForm() + NL	#--> "ا" : "ج"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,2,3]').ToListInString() )	#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )	#--> "[1, 2, 3]"

? StzStringQ(' "A":"C" ').ToListInString()	#--> [ "A", "B", "C" ]
? StzStringQ(' "ا":"ج" ').ToListInString() + NL	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# If you prefer (or need) the short form, there is an interesting
# abbreviation to the ToListInShortForm() alternative that uses
# the simple SF prefix (S for Short and F for Form), like this:

? @@( StzStringQ('[1,2, 3]').ToListInStringSF() ) 		#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInStringSF() )			#--> "1 : 3"

? StzStringQ(' ["A","B","C","D"] ').ToListInStringSF()		#--> "A" : "D"
? StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInStringSF()+ NL	#--> "ا" : "ت"

# Finally, as a cherry on the cake, you can evaluate
# the string in list in runtime like this:

? StzStringQ('1:3').ToList()	   	#--> [1, 2, 3]
? StzStringQ(' "A":"C" ').ToList() 	#--> ["A", "B", "C"]
? StzStringQ(' "ا":"ج" ').ToList() 	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

proff()
# Executed in 1.62 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.SubstringsBoundedBy([ "<<", :and = ">>" ])
#--> [ "word", "noword", "word" ]

? o1.SubStringsBoundedByU([ "<<", :and = ">>" ]) # Or UniqueSubStringsBoundedBy()
#--> [ "word", "noword" ]

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? o1.NumberOfOccurrence(:OfSubString = "many")
#--> 5

? @@( o1.Positions(:of = "many") ) + NL	# or o1.FindSubString("many")
#--> [5, 12, 33, 40, 54]

? @@(o1.Sections(:Of = "many")) + NL # or o1.FindAsSections(:OfSubString = "many")
#--> [ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ], [ 40, 43 ], [ 54, 57 ] ]

	#NOTE that Sections() has an other syntax that returns, not the sections
	# as pairs of numbers as in the example above, the substrings corresponding
	# to the sections themselves:

	? o1.Sections([ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ] ])
	#--> [ "many", "many", "many" ]

? o1.NumberOfOccurrenceXT(
	:OfSubString = "many",
	:BoundedBy = [ "<<", :and = ">>" ]
	# or :BoundedBySubStrings = ["<<", :and = ">>"]
)
#--> 3

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("what a <<nice>>> day!")

? o1.Section(8, 9)
#--> "<<"
? o1.Section(14, 16) + NL
#--> ">>>"

? o1.Sections([ [8, 9], [14, 16] ])
#--> [ "<<", ">>>" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("what a <<nice>>> day!")

? o1.Section(3, 3)
#--> "a"

? o1.Section(10, 13)
#--> "nice"

? o1.Section(13, 10)
#--> "nice"

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

o1 = new stzString("what a <<nice>>> day!")

# All these return an error message:

? o1.Section(50, 0)	#--> _NULL_
? o1.Section(0, 0)	#--> _NULL_
? o1.Section(-20, 10)	#--> _NULL_

#--> ERROR MESSAGE:
#--> Indexes out of range! n1 and n2 must be inside the string.

/*==================

profon()

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = 1 ) ) + NL
#--> [ "<", ">", "(", "<", ">", "<", ">" ]

# Same as:
? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [1, 1] ) ) + NL
#--> [ "<", ">", "(", "<", ">", "<", ">" ]

? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [ 1, 2 ] ) ) + NL
#--> [ "<", ">>", "(", "<", ">>", "<", ">>" ]

? @@( o1.SubStringBoundsXT(:Of = "many", :UpToNChars = [ 2, 2 ] ) ) + NL
#--> [ "<<", ">>", "(", "<<", ">>", "<<", ">>" ]

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*----------

profon()

o1 = new stzString("what a <<<nice>>> day!")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = 3) )
#--> [ "<<<", ">>>" ]

o1 = new stzString("what a <nice>>> day!")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = [1, 3]) )
#--> [ "<", ">>>" ]

o1 = new stzString("what a <<nice>>> day! Really <nice>>.")
? @@( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = [ 2, 3 ]) )
#--> [ "<<", ">>>", "<", ">>" ]

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*==================

profon()

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ "<<", ">>>" ]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("what a <<nice>>> day!")
? o1.Sit(
	:OnPosition = 11, # the letter "i"
	:AndHarvest = [ :NCharsBefore = 1, :NCharsAfter = 2 ]
)
#--> [ "n", "ce" ]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("what a <<nice>>> day!")

? @@( o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvestSections = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
) )
#--> [ [8, 9], [14, 16] ]

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*----------------- TODO/FUTURE :CharsBeforeW

profon()

o1 = new stzString("what a 123nice>>> day!")

? o1.Sit(
	:OnSection  = o1.FindFirstAsSection("nice"),
	:AndHarvest = [ :CharsBeforeW = 'Q(@char).IsANumber()', :NCharsAfter = 3 ]
)
#--> [ "123", ">>>" ]

proff()

/*=================

profon()

o1 = new stzString("How many words in <<many many words>>? So many!")

? @@( o1.FindPositions(:Of = "many") ) + NL
#--> [ 5, 21, 26, 43 ]

? @@( o1.FindAsSections(:Of = "many") ) + NL
#--> [ [ 5, 8 ], [ 21, 24 ], [ 26, 29 ], [ 43, 46 ] ]

#--

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? @@( o1.AnySubstringsBoundedBy([ "<<", :and = ">>" ]) )
#--> [ "word", "noword", "word" ]

? @@( o1.FindSubStringsBoundedBy([ "<<", :and = ">>" ]) ) + NL
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByAsSections([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 46 ] ]

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*----------------

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? o1.Nth(2, "word") + NL
#--> 30

? @@( o1.NthAsSection(2, "word") )
#--> [ 30, 33 ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----------------

profon()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")

? o1.FindNthBoundedBy(2, "word", [ "<<", ">>" ]) + NL
#--> 28

? o1.FindNthBoundedByZZ(2, "word", [ "<<", ">>" ])
#--> [28, 31]

? o1.FindNthXT(2, "word", :BoundedBy = ["<<", ">>"]) + NL
#--> 28

# TODO
# ? o1.FindNthXTZZ(2, "word", :BoundedBy = ["<<", ">>"])

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*================

profon()

o1 = new stzString("**word1***word2**word3***")

? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveSections([
	[1,2], [8, 10], [16, 17], [23, 25]
])

? o1.Content()
#--> "word1word2word3"

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*----------------------

profon()

o1 = new stzString("**word1***word2**word3***")
? o1.Ranges([ [1,2], [8, 3], [16, 2], [23, 3] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveRanges([ [1,2], [8, 3], [16, 2], [23, 3] ])
? o1.Content()
#--> "word1word2word3"

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International 
")

o1.Simplify()

o1.RemoveCharsWXT('{ lower(@char) = "x" }')
? o1.Content()

#--> The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit
# home computer introduced in January 1982 by Commodore International

proff()
# Executed in 0.55 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

? o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = _FALSE_)
#--> [ 11, 43 ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("12*45*78*c")
? o1.FindAll("*")
#--> [3, 6, 9]

? o1.NFirstOccurrences(2, :Of = "*") 
#--> [3, 6]

? o1.NFirstOccurrencesST(2, :Of = "*", :StartingAt = 5)
#--> [6, 9]

? o1.LastNOccurrencesST(2, :Of = "*", :StartingAt = 2)
#--> [6, 9]

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("12abc67abc12abc")

? o1.FindAll("abc")
#--> [3, 8, 13]

#NOTE: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 8]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 1)
#--> [3, 8]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [8, 13]

? o1.NLastOccurrencesST(2, "abc", :StartingAt = 1)
#--> [8, 13]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 5)
#--> [8, 13]

? o1.LastNOccurrencesST(2, :Of = "abc", :StartingAt = 3)
#--> [8, 13]

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("**3**67**012**56**92**")

? @@( o1.FindSubStringsBoundedBy("**") ) + NL
#--> [ 3, 6, 10, 15, 19 ]

? @@( o1.FindSubStringsBoundedByZZ("**") )
#--> [ [ 3, 3 ], [ 6, 7 ], [ 10, 12 ], [ 15, 16 ], [ 19, 20 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("***ONE***TWO***THREE***")

? @@( o1.FindMany([ "ONE", "TWO", "THREE"]) ) + NL
#--> [ 4, 10, 16 ]

? @@( o1.SplitQ(:Using = "***").Content() ) + NL
#--> [ "ONE", "TWO", "THREE" ]

? @@( o1.FindAnyBoundedByIB("**") ) + NL
#--> [ 1, 7, 13 ]

? @@( o1.FindAnyBoundedByIBZZ("**") )
#--> [ [ 1, 8 ], [ 7, 14 ], [ 13, 22 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.18

/*-----------------

profon()

o1 = new stzString("txt <<ring>> txt <<php>>")

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [7, 20]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("*2*45*78*0*")

? @@( o1.FindAnyBoundedBy([ "*","*" ]) ) + NL # Or o1.FindAnyBoundedBy("*") 
#--> [ 2, 4, 7, 10 ]

? @@( o1.FindAnyBoundedByIB("*") ) + NL # Or o1.FindAnyBetweenIB("*", "*")
#--> [ 1, 3, 6, 9 ]

? @@( o1.AnyBoundedBy("*") ) + NL
#--> [ "2", "45", "78", "0" ]

? @@NL( o1.AnyBoundedByZZ("*") )
# [
#	[ "2", 	[ 2, 2 ] ],
#	[ "45", [ 4, 5 ] ],
#	[ "78", [ 7, 8 ] ],
#	[ "0", 	[ 10, 10 ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.31 second(s) in Ring 1.18

/*--------------

profon()

# For each one of the 3 function calls we made so far (see
# example above), you can get the result as sections and not
# as positions. To do so, just use the same functions while
# adding the keyword Sections like this:

o1 = new stzString("txt <<ring>> txt <<php>>")

? @@( o1.FindBoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [ [ 7, 10 ], [ 20, 22 ] ]

o1 = new stzString("*2*45*78*0*")
? @@( o1.FindBoundedByZZ("*") ) + NL
#--> [ [ 2, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.FindAnyBoundedByIBZZ("*") )
#--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 9 ], [ 9, 11 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.13 second(s) in Ring 1.18

/*-----------------

profon()

? @@( Q("txt <<ring>> txt <<ring>>").FindBoundedByAsSections([ "<<", ">>" ]) ) + NL
#--> [ [ 7, 10 ], [ 20, 23 ] ]

str = 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!'
? @@( Q(str).FindBoundedByAsSections('"') ) + NL
#--> [ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]

? @@( Q(str).Sections([ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]) )
#--> [ "   val1  ", "   to  ", "   val2" ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18

/*-----------------

profon()

o1 = new stzString("12*♥*78*♥*")

? @@( o1.FindSubStringBoundedBy("♥", "*") )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :BoundedBy = "*" ) )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :BoundedBy = [ "*", "*" ] ) )
#--> [ 4, 9 ]

proff()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20

/*-----------------

profon()

o1 = new stzString("12*45*78*90")

? o1.FindNthST(2, "*", :StartingAt = 4)
#--> 9

? o1.FindFirstST("*", :StartingAt = 4)
#--> 6

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.20

/*-----------------

profon()

o1 = new stzString("12*A*33*A*")
? o1.FindAll("*")
#--> [3, 5, 8, 10]

? o1.FindNth(3, "*") + NL
#--> 8

? o1.FindFirst("*") + NL
#--> 3

? o1.FindLast("*") + NL
#--> 10

? @@( o1.FindAsSections("*") )
#--> [ [ 3, 3 ], [ 5, 5 ], [ 8, 8 ], [ 10, 10 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.20

/*----------

profon()

o1 = new stzString("12*A*33*A*")

? o1.Sections([ 1:2, 6:7 ])
#--> [ "12", "33" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("12*A*33*A*")

? @@( o1.FindSubStringBoundedBy("A", [ "*", "*" ]) )
#--> [ 4, 9 ]

? @@( o1.FindSubStringBoundedByAsSections("A", [ "*", "*" ]) )
#--> [ [ 4, 4 ], [ 9, 9 ] ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = _FALSE_)
#--> [ 11, 43 ]

? o1.FindSubStringBoundedByAsSections("word", [ "<<", ">>" ])
#--> [ [11, 14], [43, 46] ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*-----------------

profon()

#                       +----------------------+
#                       |                      |
#                       V                      V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [ 6, 24 ]

#                       +----+            +----+
#                       |    |            |    |
#                       V    V            V    V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [6, 24]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindSubStringBoundedBy("word", [ "<<", ">>" ])
#--> [ 6, 24 ]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("my **word** and your **word**")

? o1.FindSubStringBoundedBy("word", [ "**", "**" ])
#--> [6, 24]

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*============= Near Natural Code

profon()

o1 = new stzString("my <<word>> and your <<word>>")
? @@( o1.FindXT("word", :StartingAt = 12) )
#--> [ 24 ]

? @@( o1.FindXT("word", :InSection = [3, 10]) )
#--> [ 6 ]

proff()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.19

/*-----------------

profon()

o1 = new stzString("12*♥*56*♥*")

? o1.FindFirstXT("♥", :BoundedBy = [ "*", "*"])
#--> 4

? o1.FindFirstXT("♥", :BoundedBy = "*")
#--> 4

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*==============

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

? @@( o1.FindSubStringBoundedBy("word", [ "<<", ">>" ]) )
#--> [ 11 ]

? @@( o1.FindSubStringBoundedByZZ("word", [ "<<", ">>" ]) ) + NL
#--> [ [ 11, 14 ] ]

#--

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByZZ([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 49 ] ]

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*=================

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

o1.ReplaceSubStringsBoundedBy([ "<<", ">>" ], "wrod")
? o1.Content()
#--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*================ FindBoundedSubString() VS FindSubStringBounds()

profon()
#                             11               28           41
#                             v                v            v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubString("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringZZ("word") ) + NL
#--> [ [ 11, 14 ], [ 28, 31 ], [ 41, 44 ] ]

? @@( o1.FindSubStringBounds("word") ) + NL
#--> [ 9, 15, 26, 32, 39, 45 ]

? @@( o1.FindSubStringBoundsZZ("word") )
#--< [ [ 9, 10 ], [ 15, 16 ], [ 26, 27 ], [ 32, 33 ], [ 39, 40 ], [ 45, 46 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.19

/*--------

profon()
#                           9      16        26     33    39     46
#                           v------v         v------v     v------v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubString("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringIB("word") ) + NL
#--> [ 9, 26, 39 ]

? @@( o1.FindBoundedSubStringIBZZ("word") )
#--> [ [ 9, 16 ], [ 26, 33 ], [ 39, 46 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--------

profon()

o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

o1.RemoveBoundedSubString("word")
? o1.Content()
#--> bla  bla <<>> bla bla <<>> bla <<>> word

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*--------

profon()

o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.SubStringBounds("word") )
#--> [ "<<", ">>", "<<", ">>", "<<", ">>" ]

o1.RemoveBoundedSubStringIB("word")
? o1.Content()
#--> bla word bla  bla bla  bla  word

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*--------

profon()

#                       5     11             26        36    42     50
#                       v     v              v         v     v      v
o1 = new stzString("The <<Ring>> programming <<language>> is <<Waooo!>>")

? @@( o1.FindTheseBounds("<<", ">>") ) + NL
#--> [ 5, 11, 26, 36, 42, 50 ]

? @@( o1.FindTheseBoundsZZ("<<", ">>") ) + NL
#--> [ [ 5, 6 ], [ 11, 12 ], [ 26, 27 ], [ 36, 37 ], [ 42, 43 ], [ 50, 51 ] ]

o1.RemoveTheseBounds("<<", ">>")
? o1.Content()
#--> The Ring programming language is Waooo!

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*=======

profon()

o1 = new stzString("bla <<nonword>> bla")

? @@( o1.FindSubStringBoundsZZ("word") )
#--> [ [ 9, 9 ], [ 14, 15 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------

profon()
#                                14    20                        46    52
#                                v     v                         v     v
o1 = new stzString("bla word bla <<word>> bla bla <<noword>> bla <<word>> word _word_")

? @@( o1.FindSubStringBoundsZZ("word") ) + NL
#--> [ 14, 20, 46, 52 ]

? @@( o1.FindTheseSubStringBounds("word", [ "<<", ">>" ]) ) + NL
# [ 14, 20, 46, 52 ]

? @@( o1.FindTheseSubStringBoundsZZ("word", [ "<<", ">>" ]) ) + NL
#--> [ [ 14, 15 ], [ 20, 21 ], [ 46, 47 ], [ 52, 53 ] ]

o1.RemoveTheseSubStringBounds("word", [ "<<", ">>" ])

? o1.Content()
# #--> bla word bla word bla bla <<noword>> bla word word _word_

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*------

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.ReplaceSubStringBoundedBy("noword", [ "<<", ">>" ], :With = "word")
? o1.Content() + NL
#--> bla bla <<word>> bla bla <<word>> bla <<word>>

# or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceXT("noword", :BoundedBy = ["<<", ">>"], :With = "word")
? o1.Content()
#--> bla bla <<word>> bla bla <<word>> bla <<word>>

proff()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19

/*------ ReplaceSubStringBoundedBy

profon()

o1 = new stzString("bla bla --word-- bla bla --nword- bla --word--")

o1.ReplaceSubStringBoundedBy("word", "--", :With = "WORD")
? o1.Content() + NL
#--> bla bla --WORD-- bla bla --nword- bla --WORD--

# or, more naturally, you can say:

o1 = new stzString("bla bla --word-- bla bla --nword- bla --word--")
o1.ReplaceXT("word", :BoundedBy = "--", :With = "word")
? o1.Content()
#--> bla bla --WORD-- bla bla --nword- bla --WORD--

proff()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.19

/*------ ReplaceSubStringBoundedIB

profon()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")

o1.ReplaceSubStringBoundedByIB("word", [ "<<", ">>" ], "WORD")
? o1.Content() + NL
#--> bla bla WORD bla bla WORD bla WORD.

# or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")

o1.ReplaceXT("word", :BoundedByIB = ["<<", ">>"], :With = "WORD")
? o1.Content()
#--> bla bla WORD bla bla WORD bla WORD.

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*------ 

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.RemoveAnySubStringBoundedBy([ "<<", ">>" ])
? o1.Content()
#--> bla bla <<>> bla bla <<>> bla <<>>

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.19

/*------ 

profon()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.RemoveAnySubStringBoundedByIB([ "<<", ">>" ])
? o1.Content()
#--> bla bla  bla bla  bla 

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*----------------- RemoveBetween RemoveAt

profon()

# EXAMPLE 1
#                             11
o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")

o1.RemoveXT("word", :AtPosition = 11)
? o1.Content() + NL
#--> bla bla <<>> bla bla <<noword>> bla <<word>>

# EXAMPLE 2
#                             11                              43
o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("word", :AtPositions = [ 11, 43 ])
? o1.Content()
#--> bla bla <<>> bla bla <<noword>> bla <<>>

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

/*-----------------

profon()

o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*================= #narration

profon()

# In Softanza, to remove a substring from left or right
# you can use RemoveFromLeft() and RemoveFromRight() functions:

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromLeft("let's say ")
? o1.Content()
#--> welcome to everyone!

# But when right-to-left strings are used, this can be confusing,
# since left is no longer at the start of the string, nor the
# right is at the end!

# Hence, if you want to retrieve a substring from the beginning
# of a right-to-left arabic text ("هذه" in the following example),
# you should inverse the orientation and use RemoveFromRight()
# instead...

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
? o1.NRightCharsAsSubstring(4) #--> "هذه "

o1.RemoveFromRight("هذه ")
? o1.Content() #--> "الكلمات الّتي سوف تبقى"

# To avoid this complication, Softanza provides a more general (semantic)
# solution working both for left-to-right and right-to-left strings:
# the RemoveFromStart() and RemoveFromEnd() functions...

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromStart("let's say ")
? o1.Content() #--> welcome to everyone!

# and the same code working for arabic:

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
o1.RemoveFromStart("هذه ")
? o1.Content() #--> "الكلمات الّتي سوف تبقى"

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.07 second(s) in Ring 1.17

/*========================

profon()

o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
o1.RemoveLast(" من") # Or o1.RemoveNthOccurrence(:Last, " من")
? o1.Content()
#--> Gives من كان في زمنه من أصحابه فهو أكبر المحظوظين

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrence(:Last, "A")
? o1.Content()
#--> **A1****A2***3

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrenceCS(:Last, "a", :CaseSensitive = _FALSE_)
? o1.Content()
#--> **A1****A2***3

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("**A1****A2***A3")
o1.RemoveLast("A")
? o1.Content()
#--> **A1****A2***3

proff()
# Executed in 0.03 second(s)

/*-----------------

profon()

o1 = new stzString("**A1****A2***A3")
o1.RemoveFirst("A")
? o1.Content()
#--> **1****A2***A3

proff()

/*==================

profon()

o1 = new stzString("<<word>>")

? o1.IsBoundedBy(["<<", ">>"])
#--> _TRUE_

o1.RemoveTheseBounds("<<",">>")
? o1.Content()
#--> word

proff()
# Executed in 0.04 second(s)

/*---------------

profon()

o1 = new stzString("word")
o1.AddBounds(["<<",">>"]) # or BoundWith(["<<",">>"])
? o1.Content()
#--> <<word>>

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------------

profon()

o1 = new stzString("Hello <<<Ring>>, the beautiful ((Ring))!")
? @@( o1.BoundsOf("Ring") )
#--> [ "<<<", ">>", "((", "))" ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20

/*---------------

profon()

o1 = new stzString("Ring>>, the nice ---Ring---, the beautiful ((Ring")
? @@( o1.BoundsOf("Ring") )
#--> [ "---", "---" ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.09 second(s) in ring 1.20

/*---------------

profon()

o1 = new stzString("Hello <<<Ring>>, the nice __Ring__ and beautiful ((Ring))!")

? @@( o1.BoundsOf("Ring") )
#--> [ "<<<", ">>", "__", "__", "((", "))" ]

? @@( o1.FirstBoundsOf("Ring") )
#--> [ "<<<", "__", "((" ]

? @@( o1.LastBoundsOf("Ring") )
#--> [ ">>", "__", "))" ]

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20

/*---------------

profon()

o1 = new stzString("<<word>>")

? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.LeftBound() + NL
#--> "<<"

? o1.RightBound()
#--> ">>"

# And also FirstBound() and LastBound() for general
# use with left-to-right and right-toleft strings

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.13 second(s) in Ring 1.20

/*================= StzRaise

? StzRaise("Simple error message!")
#--> Simple error message! 

/*------ #TODO Recheck it when adding CheckWXT()

? StzRaise([
	:Where	= "stzString.ring",
	:What 	= "Describes what happend",
	:Why  	= "Describes why it happened",
	:Todo 	= "Posposes an action to solve the error"
])

#--> Line ... in file stzString.ring:
#	  What : Describes what happend
#	  Why  : Describes why it happened
#	  Todo : Posposes an action to do
#

/*-----------------

profon()

o1 = new stzString("@str = Q(@str).Uppercased()")

? o1.BeginsWithOneOfTheseCS([ "@str =", :Or = "@str=" ], _TRUE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzString("Baba, Mama, and Dada")
? o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = _FALSE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

StzStringQ('') {

	FromURL("https://ring-lang.github.io/doc1.16/qt.html")
	Show()

}
#--> Shows the page content as Text/HTML

proff()
# Executed in 0.46 second(s) in Ring 1.22
# Executed in 2.63 second(s) in Ring 1.18

/*-----------------

profon()

StzStringQ("ring is not the ring you ware but the ring you program with") {
	? @@( FindAllOccurrencesCS(:Of = "ring", :CS = _FALSE_) )
	#--> [ 1, 17, 39 ]

	? @@( FindAsSectionsCS(:Of = "ring", :CS = _FALSE_) )
	#--> [ [ 1, 4 ], [ 17, 20 ], [ 39, 42 ] ]

	? @@( FindOccurrences([1, 3], :Of = "ring") )
	#--> [1, 39]

	? @@( FindOccurrences([1, 3], :Of = "foo") )
	#--> [ ]
}

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*-----------------

profon()

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? NextNthOccurrence(1, :of = "ring", :startingat = 1)
	#--> 2

	? NextNthOccurrence(2, :of = "ring", :startingat = 17)
	#--> 40
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

#           1          v    17            v       39
StzStringQ("ring is not the ring you ware but the ring you program with") {

	? @@( FindAll("ring") ) + NL
	#--> [ 1, 17, 39 ]

	? @@( FindNextOccurrences(:Of = "ring", :StartingAt = 12) ) + NL
	#--> [ 18, 40 ]

	? @@( FindPreviousOccurrences(:Of = "ring", :StartingAt = 32) )
	#--> [ 1, 17 ]

}

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*======================

profon()

o1 = new stzString("Softanza embraces ♥♥♥ simplicty and flexibility")

o1.ReplaceSubStringAtPosition(19, "♥♥♥", :With = "Ring")
? o1.Content()
#--> Softanza embraces Ring simplicty and flexibility

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*======================

profon()

? Q("RINGO").HasCentralChar()
#--> _TRUE_

? Q("RINGO").CentralChar()
#--> N

? Q("RINGO").PositionOfCentralChar()
#--> 3

? Q("RINGO").HasThisCentralChar("N")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22


/*----------------------

profon()

? Q("dfgfdgg Arabic Arabic Arabic dgdgf arabic KKKK").NumberOfOccurrenceCS("Arabic", _FALSE_)
#--> 4

proff()

/*----------------------

profon()

? Q("ArabicArabicArabic").IsMultipleOf("Arabic")
#--> _TRUE_

? Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic")
#--> _TRUE_

? Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic")
#--> _FALSE_

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", _TRUE_)
#--> _FALSE_

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = _FALSE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------------------

profon()

? Q("...").Marquer()
#--> "#"

? Q("#12500").IsMarquer()
#--> _TRUE_

? @@( Q("#12500").Marquers() )
#--> [ "12500" ]

proff()
# Executed in 0.02 second(s).

/*====================== WORKING WITH MARQUERS

profon()

? StzStringQ("My name is #.").ContainsMarquers()
#--> _FALSE_

? StzStringQ("My name is #0.").ContainsMarquers()
#--> _TRUE_

? StzStringQ("My name is #1.").ContainsMarquers()
#--> _TRUE_

? StzStringQ("My name is #01.").ContainsMarquers()
#--> _TRUE_

? @@( Q("bla #0 bla bla #1 bla #2 blabla").Marquers() )
#--> [ "#0", "#1", "#2" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.53 second(s) in Ring 1.14

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3.") {
	? Marquers()
	#--> [ "#1", "#2", "#3" ]
}

StzStringQ("My name is #2, my age is #3, and my job is #1.") {
	? Marquers()
	#--> [ "#2", "#3", "#1" ]
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.19
# Executed in 0.30 second(s) in Ring 1.18

/*---------------------- #perf

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( Marquers() ) + NL
	#--> [ "#1", "#2", "#3", "#1" ]

	? @@( MarquersPositions() ) + NL # or FindMarquers()
	#--> [ 12, 26, 44, 66 ]

	? @@( MarquersZ() ) + NL # Or MarquersAndPositions()
	#--> [ [ "#1", 12 ], [ "#2", 26 ], [ "#3", 44 ], [ "#1", 66 ] ]

	? @@( MarquersAndSections() ) + NL # Or MarquersAndSections()
	#--> [ [ "#1", [ 12, 13 ] ], [ "#2", [ 26, 27 ] ], [ "#3", [ 44, 45 ] ], [ "#1", [ 66, 67 ] ] ]

}

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.49 second(s) in Ring 1.19

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NumberOfMarquers()
	#--> 4

	? FirstMarquer()
	#--> #1

	? FindFirstMarquer()
	#--> 12
		# You can also say:
		# ? FirstMarquerOccurrence()
		# ? FirstMarquerPosition()

	? LastMarquer()
	#--> #1
	
	? FindLastMarquer()
	#--> 66
		# You can also say:
		# ? LastMarquerOccurrence()
		# ? LastMarquerPosition()

}

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 1.64 second(s) in Ring 1.21
# Executed in 1.64 second(s) in Ring 1.19

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NthMarquer(2)
	#--> #2

	? FindNthMarquer(2)
	#--> 26
		# You can also say:
		# ? NthMarquerOccurrence(2)
		# ? NthMarquerPosition(2)
}

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.63 second(s) in Ring 1.19

/*---------------------- #perf

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NextNthMarquerST(2, :StartingAt = 14) # You can omit the ..ST()
	#--> #3
		# Or you can say:
		# ? NthNextMarquer(2, :StartingAt = 14)
	
	? FindNextNthMarquerST(2, :StartingAt = 14)
	#--> 44
		# Or you can say:
		# ? NextNthMarquerOccurrence(2, :StartingAt = 14)
		# ? NthNextMarquerOccurrence(2, :StartingAt = 14)
		# ? NextNthMarquerPosition(2, :StartingAt = 14)
		# ? NthNextMarquerPosition(2, :StartingAt = 14)

}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.70 second(s) in Ring 1.17

/*=================== #narration DEALING IN EMPTINESS IN SOFTANZA

# Read documentaion here:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/doc/narrations/stz-narration-stzstring-emptiness.md#emptiness-in-strings-clear-rules-the-softanza-way

profon()

# Rule 1 - Emptiness is uncountable:
# We can not cout its occurrences inside any string, beeing empty or not

	? Q("").Count('')
	#--> 0
	
	? Q("text").Count('') + NL
	#--> 0  
	
# Rule 2 - Emptiness is unfindable (since it is uncountable ~> Rule 1)

	? @@( Q("").Find('') )
	#--> [ ]
	
	? @@( Q("text").Find('') ) + NL
	#--> [ ]

# Rule 3 - Emptiness is uncontainable in both directions

#~> An empty string contains nothing, being an empty string or not,
#~> and a non empty string does not contain any empty one
#~> (which is completely coherent with Rule 1)

	? Q("").Contains('') 
	#--> _FALSE_
	
	? Q("").Contains('text')
	#--> _FALSE_
	
	? Q("text").Contains('') + NL
	#--> _FALSE_

# Rule 4 - Emptiness is irreplaçable in both directions

	? @@( Q("").ReplaceQ('', '').Content() )
	#--> ""
	
	? @@( Q("").ReplaceQ('any', '').Content() )
	#--> ""
	
	? @@( Q("").ReplaceQ('', 'any').Content() )
	#--> ""
	
	? @@( Q("text").ReplaceQ('', "").Content() )
	#--> text
	
	? @@( Q("text").ReplaceQ('', "X").Content() ) + NL
	#--> text

# Rule 5 - Emptiness is irremovalbe in both directions

	? @@( Q("").RemoveQ('').Content() )
	#--> ""

	? @@( Q("").RemoveQ('text').Content() )
	#--> ""

	? @@( Q("text").RemoveQ('').Content() )
	#--> "text"

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*--------------------

profon()

? Q("ring").Contains("ring")
#--> _TRUE_

? Q("").Contains('')
#--> _FALSE_

? Q([ 12, 66 ]).IsIncludedIn([ 12, 66 ])
#--> _FALSE_

? Q([ 12, 66]).AreInCludedIn([ 12, 66 ])
#--> _TRUE_

? Q([]).Contains([])
#--> _FALSE_

? Q([ 1, [], 3 ]).Contains([])
#--> _TRUE_

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
# Executed in 0.03 second(s) in Ring 1.18

/*----------------------

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( MarquersUZ() ) # Or simply UniqueMarquersAndTheirPositions()
	#--> [ [ "#1", [ 12, 66 ] ], [ "#2", [ 26 ] ], [ "#3", [ 44 ] ] ]

	? @@( FindMarquer("#1") ) # Or ? OccurrencesOfMarquer("#1")
	#--> [ 12, 66]

	? @@( FindMarquer("#7") ) + NL
	#--> [ ]

	? MarquerByPosition(66)
	#--> #1

	? MarquerByPosition(44)
	#--> #3

	? MarquerByPositions([ 12, 66 ]) + NL
	#--> #1

	? MarquersByPositions([ 26, 44 ])
	#--> [ #2, #3 ]
}

proff()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 2.70 second(s) in Ring 1.18

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? PreviousMarquers(:StartingAt = 50 )
	#--> [ "#1", "#2", "#3" ]

	? NextMarquers(:StartingAt = 15)
	#--> [ "#2", "#3", "#1" ]

}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.66 second(s) in Ring 1.18

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? PreviousNthMarquer(3, :StartingAt = 50)
	#--> #1

	? FindPreviousNthMarquer(3, :StartingAt = 50) # or  PreviousNthMarquerPosition(3, :StartingAt = 50)
	#--> 12

	? @@( PreviousNthMarquerZ(3, :StartingAt = 50) ) # or PreviousNthMarquerAndItsPosition(3, :StartingAt = 50)
	#--> [ "#1", 12 ]

	#TODO : Add these functions	
	# 	? NthMarquerZ(n)
	# 	? NthMarquerZZ(n)
	
	# 	? NextNthMarquerZZ(n, nStart)
	# 	? PreviousNthMarquerZZ(n, nStart)
}

proff()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.02 second(s) in Ring 1.18

/*---------------------- 

profon()

CheckparamsOff() # Potential Gain of performance

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? FindNthPreviousMarquer(1, 50)
	#--> 44

	? @@( PreviousMarquerZ(50) )
	#--> [ "#3", 44 ]

}

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.79 second(s) in Ring 1.18

/*----------------------

profon()

CheckParamsOff() # Potential gain of performance

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( FindMarquersAsSections() ) + NL
	#--> [ [ 12, 13 ], [ 26, 27 ], [ 44, 45 ], [ 66, 67 ] ]

	? @@( MarquersZZ() ) + NL
	#--> [
	# 	[ "#1", [ 12, 13 ] ],
	# 	[ "#2", [ 26, 27 ] ],
	# 	[ "#3", [ 44, 45 ] ],
	# 	[ "#1", [ 66, 67 ] ]
	# ]

	? @@( MarquersUZZ() ) # Or UniqueMarquersAndTheirSections()
	#--> [
	# 	[ "#1", [ [ 12, 13 ], [ 66, 67 ] ] ],
	# 	[ "#2", [ [ 26, 27 ] ] ],
	# 	[ "#3", [ [ 44, 45 ] ] ]
	# ]

}

proff()

# Executed in 0.05 second(s) in Ring 1.21 WithCheckParamsOff()
# Executed in 0.05 second(s) in Ring 1.21 WithCheckParams()

# Executed in 1.67 second(s) in Ring 1.19 with CheckParamsOff()
# Executed in 2.58 second(s) in Ring 1.19 without CheckParamsOff()

# Executed in 4.65 second(s) in Ring 1.18
# Executed in 7.74 second(s) in Ring 1.17

/*---------------------- 

profon()

Q("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> _TRUE_
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> _FALSE_
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.54 second(s) in Ring 1.19
# Executed in 0.29 second(s) in Ring 1.18
# Executed in 0.45 second(s) in Ring 1.17

/*---------------------- 

profon()

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSortedIndescending()
	#--> _TRUE_
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInDescending()
	#--> _FALSE_
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.18

/*----------------------

profon()

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSorted()
	#--> _TRUE_

	? MarquersSortingOrder()
	#--> :Ascending
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18

/*---------------------- 

profon()

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSorted()
	#--> _TRUE_

	? MarquersSortingOrder()
	#--> :Descending
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #3, and my job is #2.") {	

	? MarquersAreUnsorted()
	#--> _TRUE_

	? MarquersSortingOrder()
	#--> :Unsorted

}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18
# Executed in 0.53 second(s) in Ring 1.17

/*----------------------

profon()

CheckParamsOff()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {
	
	? NumberOfMarquers() + NL
	#--> 3
	? MarquersPositions() # Or FindMarquers()
	#--> [ 24, 42, 65 ]
	
	? FindNextNthMarquer(2, 14) + NL
	#--> 42
	
	? MarquersPositionsSortedInAscending()
	#--> [ 24, 42, 65 ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.69 second(s) in Ring 1.18

/*----------------------

profon()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	? Marquers()
	#--> [ "#3", "#1", "#2" ]

	? @@( MarquersZ() ) + NL
	#--> [ [ "#3", 24 ], [ "#1", 42 ], [ "#2", 65 ] ]

	? @@( MarquersZZ() )
	#--> [ [ "#3", [ 24, 25 ] ], [ "#1", [ 42, 43 ] ], [ "#2", [ 65, 66 ] ] ]
}

proff()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 1.36 second(s) in Ring 1.18
# Executed in 2.22 second(s) in Ring 1.17

/*---------------------- 

profon()

o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
? @@( o1.MarquersSortedInDescendingZZ() )
#--> [ [ "#3", [ 12, 14 ] ], [ "#2", [ 27, 29 ] ], [ "#1", [ 45, 47 ] ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.27 second(s) in Ring 1.18
# Executed in 0.41 second(s) in Ring 1.17

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@( MarquersSortedZ() ) + NL
	#--> [ [ "#1", 12 ], [ "#1", 26 ], [ "#2", 44 ], [ "#3", 66 ] ]

	? @@( MarquersSortedZZ() )
	#--> [ [ "#1", [ 12, 13 ] ], [ "#1", [ 26, 27 ] ], [ "#2", [ 44, 45 ] ], [ "#3", [ 66, 67 ] ] ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.66 second(s) in Ring 1.18

/*---------------------- 

profon()

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@( MarquersSortedUZ() ) + NL
	#--> [ [ "#1", [ 12, 66 ] ], [ "#2", [ 44 ] ], [ "#3", [ 26 ] ] ]

	? @@( MarquersSortedUZZ() )
	#--> [
	# 	[ "#1", [ [ 12, 13 ], [ 66, 67 ] ] ],
	# 	[ "#2", [ [ 44, 45 ] ] ],
	# 	[ "#3", [ [ 26, 27 ] ] ]
	# ]
}

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.39 second(s) in Ring 1.18
# Executed in 0.57 second(s) in Ring 1.17

/*----------------------

profon()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	SortMarquersInAscending()
	? Content() + NL
	#--> The first candidate is #1, the second is #2, while the third is #3!

	SortMarquersInDescending()
	? Content()
	#--> The first candidate is #3, the second is #2, while the third is #1!
}

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.53 second(s) in Ring 1.18
# Executed in 0.81 second(s) in Ring 1.17

/*----------------------

profon()

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")

o1.MarkTheseSubStringsCS( [ "Ring", "Python", "Ruby", "PHP" ], _TRUE_ )
# Or ReplaceSubstringsWithMarquersCS

? o1.Content() + NL
#--> "#1 can be compared to #2, #3 and #4."

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.MarkSubStringsCS( [ "ring", "python", "ruby", "PHP" ], :CS = _FALSE_ )
# Or ReplaceSubstringsWithMarquersCS

? o1.Content()
#--> "#1 can be compared to #2, #3 and #4."

proff()
# Executed in 0.01 second(s)

/*----------------------

StartProfiler()

	acMyKids = [ "Teeba", "Haneen", "Hussein" ]
	
	o1 = new stzString("My three kids are #1, #2 and #3!")

	? @@( o1.MarquersZZ() )
	#--> [ [ "#1", [ 19, 20 ] ], [ "#2", [ 23, 24 ] ], [ "#3", [ 30, 31 ] ] ]

	o1.ReplaceMarquers(:with = acMyKids)
	? o1.Content() + NL
	#--> My three kids are Teeba, Haneen and Hussein!
	
	o1.ReplaceSubStringsWithMarquers(acMyKids)
	? o1.Content() + NL
	#--> My three kids are #1, #2 and #3!
	
	o1.SortMarquersInDescending()
	? o1.Content() + NL
	#--> My three kids are #3, #2 and #1!
	
	o1.ReplaceMarquers(:With = acMyKids)
	? o1.Content()
	#--> My three kids are Hussein, Haneen and Teeba!

StopProfiler()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 1.73 second(s) in Ring 1.18
# Executed in 2.90 second(s) in Ring 1.17

/*=====================

profon()

StzStringQ("BCAADDEFAGTILNXV") {

	? SortedInAscending()
	#--> AAABCDDEFGILNTVX
	
	? IsSortedInAscending()
	#--> _FALSE_
	
	? SortedInDescending()
	#--> XVTNLIGFEDDCBAAA
	
	? IsSortedInDescending()
	#--> _FALSE_
	
	? SortingOrder()
	#--> :Unsorted
	
	Sort()
	? Content()
	#--> AAABCDDEFGILNTVX
	
	? SortingOrder()
	#--> :ascending
}

proff()
# Executed in 0.17 second(s) in Ring 1.21
# Executed in 0.21 second(s) in Ring 1.18

/*-----------------------

profon()

Q("AAABCDDEFGILNTVX") {
	IsSorted() 
	#--> _TRUE_

	? SortingOrder()
	#--> :Ascending
}

Q("XVTNLIGFEDDCBAAA") {
	IsSorted()
	#--> _TRUE_

	SortingOrder()
	#--> :Descending
}

proff()
# Executed in 0.16 second(s) in Ring 1.21
# Executed in 0.32 second(s) in Ring 1.18
# Executed in 0.74 second(s) in Ring 1.17

/*=======================

profon()

o1 = new stzString("My name is Mansour. What's your name please?")

? @@( o1.FindManyCS( [ "name", "your", "please" ], _TRUE_ ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.FindMany( [ "name", "your", "please" ] ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.TheseSubStringsCSZ( [ "name", "your", "please" ], _TRUE_ ) ) + NL
#--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

o1 = new stzString("My name is Mansour. What's your name please?")
? @@(o1.TheseSubStringsZZ( [ "name", "nothing", "please" ] ))
#--> [ [ "name", [ [ 4, 7 ], [ 33, 36 ] ] ], [ "nothing", [ ] ], [ "please", [ [ 38, 43 ] ] ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.11 second(s) in Ring 1.17

/*==================== #narration GENERALISATION OF _:_ RING SYNTAX

profon()

# The "A":"E" syntax is a beautiful feature of Ring:

? "A" : "E"
#--> [ "A", "B", "C", "D", "E" ]

# And it works backward like this:

? "E" : "A"
#--> [ "E", "D", "C", "B", "A" ]

# Softanza reproduces it using UpTo() and DownTo() functions:

? Q("A").UpTo("E")
#--> [ "A", "B", "C", "D", "E" ]

? Q("E").DownTo("A")
#--> [ "E", "D", "C", "B", "A" ]

# And extends it to cover any Unicode char not only ASCII chars
# as it is the case for the Ring syntax:

? Q("ب").UpTo("ج") 	#--> [ "ب", "ة", "ت", "ث", "ج" ]
? Q("ج").DownTo("ب")	#--> [ "ج", "ث", "ت", "ة", "ب" ]

proff()
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17

/*----------------------

profon()

o1 = new stzString("I Work For Afterward")

? o1.RemoveCharQ(" ").Content()
#--> IWorkForAfterward

# Or you can say it more naturally:

? Q("I Work For Afterward").CharRemoved(" ")
#--> IWorkForAfterward

# Or even more expressively:

? Q("I Work For Afterward").WithoutSpaces()
#--> IWorkForAfterward

# Or if you prefer:

? Q("I Work For Afterward").SpacesRemoved()
#--> IWorkForAfterward

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.18

/*======================

profon()

? Q("9876543210").Reversed()
#--> 0123456789

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20

/*----------------------

profon()

StzStringQ("73964532041") {

	? SortedInAscending()
	#--> 01233445679

	? SortedInDescending()
	#--> 97654433210
}

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20

/*----------------------

profon()

? Q("01233445679").IsSortedInAscending()
#--> _TRUE_

? Q("01233445679").IsSortedInDescending()
#--> _FALSE_

proff()
# Executed in 0.08 second(s)

/*======================

profon()

? StzStringQ("Arc").IsAnagramOfCS("cra", :CS = _FALSE_)
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.18

/*=====================

profon()

o1 = new stzString("IloveRingprogramminglanguage!")
o1.SpacifySubStringsUsing( [ "love", "Ring", "programming" ], " " )
? o1.Content()
#--> I love Ring programming language!

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*---------------------

profon()

? StzCCodeQ('@char = "I"').Transpiled()
#--> This[@i]  = "I"

proff()
# Executed in 0.18 second(s)

/*---------------------

profon()

o1 = new stzString("KALIDIA")

? o1.FindCharsWXT('@char = "I"')
#--> [ 4, 6 ]

proff()
# Executed in 0.08 second(s) in Ring 1.22
# Executed in 0.42 second(s) in Ring 1.18
# Executed in 0.52 second(s) in Ring 1.17

/*----------------------

profon()

StzStringQ("12500;NAME;10;0") {

	? NextOccurrence( :Of = ";", :StartingAt = 1 )
	#--> 6

	? NextNthOccurrence( 2, :Of = ";", :StartingAt = 5)
	#--> 11
}

proff()
# Executed in 0.05 second(s)

/*======================= #narration 

profon()

# One of the design goals of Softanza is to be as consitent as possible
# in managing Strings and Lists. In other terms, what works for one,
# should work for the other, preserving the same semantics.

# To show this, the following code that plays with leading and trailing
# chars in a string...

StzStringQ( "***Ring++" ) {

	? HasLeadingChars()
	#--> _TRUE_

	? NumberOfLeadingChars()
	#--> 3

	? @@( LeadingChars() ) # Or LeadingCharsXT() #--> "***"
	#--> [ "*", "*", "*" ]
	
	? HasTrailingChars()
	#--> _TRUE_

	? NumberOfTrailingChars()
	#--> 2

	? @@( TrailingCharsXT() )
	#--> "++"

	ReplaceEachLeadingChar(:With = "+")
	? Content()
	#--> "+++Ring++"
	
	//ReplaceLeadingAndTrailingChars(:With = "*")
	ReplaceEachLeadingAndTrailingChar(:With = "*")
	? Content() + NL + NL + "---" + NL
	#--> "***Ring**"
}

# works quiet the same with leading and trailing items items of this list:

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems()
	#--> _TRUE_

	? NumberOfLeadingItems()
	#--> 3

	? @@( LeadingItems() )
	#--> [ "*", "*", "*" ]
	
	? HasTrailingItems()
	#--> _TRUE_

	? NumberOfTrailingItems()
	#--> 2
	? @@( TrailingItems() )
	#--> [ "+", "+" ]

	ReplaceLeadingItems(:With = "+")
	? @@( Content() )
	#--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItems(:With = "*") + NL+NL + "---" + NL
	? @@( Content() )
	#--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

#NOTE that, as far as strings are concerned, both if the main objec we
# are working on is a string or a list containing string itmes as leading
# or trailing chars, this feature is sensitive to case:
# so we can say:

StzStringQ("eeEEeeTUNISeeEE") {

	? NumberOfLeadingCharsCS(:CaseSensitive = _FALSE_)
	#--> 6

	? LeadingCharsCS(:CaseSensitive = _FALSE_)
	#--> eeEEee

	? NumberOfLeadingCharsCS(_TRUE_)
	#--> 2

	? LeadingCharsCS(_TRUE_)
	#--> ee

	? LeadingCharIsCS("E", :CaseSensitive = _FALSE_)	+ NL
	#--> _TRUE_

	#--

	? NumberOfTrailingCharsCS(:CaseSensitive = _FALSE_) + NL
	#--> 4

	? TrailingCharsCS(:CaseSensitive = _FALSE_)
	#--> EEee

	? NumberOfTrailingCharsCS(_TRUE_) + NL
	#--> 2

	? TrailingCharsCS(_TRUE_)
	#--> EE

	? LeadingCharIsCS("e", :CaseSensitive = _FALSE_)
	#--> _TRUE_

}

proff()
# Executed in 0.08 second(s) in Ring 1.22
# Executed in 0.35 second(s) in Ring 1.18
# Executed in 0.61 second(s) in Ring 1.17

#NOTE: Case sensitivity is also supported in Lists with most functions.
# In the future, all functions wil be covered.

/*=====================

profon()

o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
? o1.Content()
#--> ----@@--@@-------@@----##---

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.05 second(s) in Ring 1.17

/*----------------------

profon()

o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
? o1.Content()
#--> ----@@--##-------@@----@@---

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18

/*======================

profon()

? Q("DIGIT ZERO").IsCharName()
#--> _TRUE_

? Q("LATIN CAPITAL LETTER O").IsCharName()
#--> _TRUE_

? Q("JAVANESE PADA PISELEH").IsCharName()
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*----------------------

profon()

o1 = new stzString("ar_Arab_TN")
? o1.IsLocaleAbbreviation()
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*--------------------- TODO: review some stzLocale outputs...

profon()

# The standard (ISO) form of a locale is <langauge>_<script>_<country> where:
# 	-> <language> is an abbreviation of 2 or 3 lowercase letters
#	-> <script> is an abbreviation of 4 letters, the 1st beeing capitalised
#	-> <country> is an abbreviation of 2 or 3 uppercase letters
#
#	Example: "ar_Arab_TN" is the locale form where:
#	-> "ar" is the abbreviation of arabic language
#	-> "Arab" is the abbreviation of arabic script
#	-> "TN" is the abbreviation the country Tunisia
#
# Usually, locale is provided in <language>_<country> form like this:
#	-> "ar_TN" or "fr_FR" or "en_US" for example
#
# All these forms are supported by Softanza, but not only them!
#
# In fact, both of these standard forms return _TRUE_

? StzStringQ("ar_arab_tn").IsLocaleAbbreviation()
#--> _TRUE_

? StzStringQ("ar_TN").IsLocaleAbbreviation()
#--> _TRUE_
# (as a side note, Softanza doesn't care of the case, so do not feel any pressure)

# But this one also return _TRUE_
? StzStringQ("Arab_TN").IsLocaleAbbreviation()
#--> _TRUE_
# Which corresponds to the non-standard form <script>_<country>.

# And this is accepted by Softanza, because when you use it to create
# a locale object, Softanza inferes the language from the script, and
# constructs the hole standard-formed abbreviation for you:

? StzLocaleQ("Arab_TN").Abbreviation()	#--> "ar_Arab_TN"	TODO: Check it!
# (as a side note, even if you don't respect standard lettercasing,
# Softanza accepts your inputs, and returns an abbreviation that
# is wellformed regarding to the standard!)

# You may think that you would abuse this spirit of flexibility by
# trying to induce Softanza in error by providing sutch an abbreviation
# form <scrip>_<language>:

? StzStringQ("arab_ar").IsLocaleAbbreviation()
#--> _FALSE_

# The point is that the first abbreviation is a script ("arab" -> arabic),
# and that, conforming to the standard, the second one must be an abbreviation
# of a country ("ar" -> :Argentina). Try this:

? StzCountryQ("ar").Name()
#--> argentina

# And because :Argentina do not have arabic, neigher as a spoken language nor
# a written script, then the returned result is _FALSE_!

# When you do the same with a country like :Turkey or :Iran, for example,
# where arabic script is (historically) used in writtan turkish and persian
# languages, than the abbreviation is accepted to be well formed

? StzStringQ("arab_tk").IsLocaleAbbreviation()
# !--> _TRUE_	TODO: Check it!

# And, therefore, you can use it to create locale object:

? StzLocaleQ("arab_tk").Abbreviation()
#--> ar_Arab_TK	TODO: Check it!

? StzLocaleQ("ar_Arab_TK").CountryName()
# !--> :turkey NOT :Egypt

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17

/*=====================

profon()

o1 = new stzString("ritekode")

? o1.IsEqualTo("ritekode")
#--> _TRUE_

? o1.IsEqualToCS("RiteKode", :CS = _FALSE_)
#--> _TRUE_

? o1.IsEqualToCS("RiteKode", _TRUE_)
#--> _FALSE_

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.18

/*--------------------

profon()

? Q("date").IsLowercase()
#--> _TRUE_

? Q("date").IsLowercaseOf("DATE")
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*--------------------

profon()

# Here we take an example of a greek word

? TQ("Σίσυφος").Script()
#--> greek

? Q("Σίσυφος").StringCase()
#--> capitalcase

? Q("ΣΊΣΥΦΟΣ").StringCase()
#--> uppercase

? Q("ΣΊΣΥΦΟΣ").Lowercased()
#--> σίσυφοσ

? Q("σίσυφοσ").Uppercased()
#--> ΣΊΣΥΦΟΣ

? Q("σίσυφοσ").Capitalcased()
#--> Σίσυφοσ

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = _FALSE_)
#--> _TRUE_

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", _TRUE_)
#--> _FALSE_

proff()
# Executed in 0.12 second(s) in Ring 1.22
# Executed in 0.11 second(s) in Ring 1.18
# Executed in 0.21 second(s) in Ring 1.17

/*--------------------

profon()

# Let's take this example of a turkish letter ı that should be
# uppercased to İ and not I

? TQ("ı").Script()
#--> latin (in fact this is a turk letter) (TQ --> stzText object)

? Q("ı").StringCase()
#--> lowercase

? Q("İ").StringCase()
#--> uppercase

proff()
# Executed in 0.07 second(s)

/*--------------------

profon()

# This sample shows a logical error in Qt unicode:

? Q("ı").UppercasedInLocale("tr-TR")	#ERROR: --> I but must be İ
? Q("İ").Lowercased()	# i
? Q("İ").LowercasedInLocale("tr-TR")	#ERROR: --> i but must be ı

# In fact, this is a logical bug in Qt as demonstrated here:

oQLocale = new QLocale("tr-TR")
? oQLocale.toupper("ı") #ERROR: --> I but must be İ

#TODO // solve this by implementing the specialCasing of unicode as
# described in this file:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

proff()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18

/*-------------------- #narration

profon()

# Do you think "ê" and "ê" are the same?
# If one should trust the visual shape of these two strings, then yes...
# but, the truth, is that they are different.

# In fact, both Ring and Softanza know it:

? "ê" = "ê"
#--> _FALSE_

? Q("ê").IsEqualTo("ê")
#--> _FALSE_

# and that's because ê is just one char:

Q("ê") { ? NumberOfChars() ? Unicode() }
#--> 1
#--> 234

# while ê are two chars:

Q("ê") { ? NumberOfChars() ? Unicode() }
#--> 2
#--> [101, 770]

# And we can do even better by getting the names of the chars in every string.
# So "ê" contains one char called :

? Q("ê").CharName() 
#--> LATIN SMALL LETTER E WITH CIRCUMFLEX

# While "ê" contains two chars called:

? Q("ê").CharsNames() 	
#--> [ 'LATIN SMALL LETTER E', 'COMBINING CIRCUMFLEX ACCENT' ]

# Combining characters is an advanced aspect of Unicode we are not going to delve
# in now. For more details you can read these FAQs at the following link:
# http://unicode.org/faq/char_combmark.html

proff()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.36 second(s) in Ring 1.18
# Executed in 0.75 second(s) in Ring 1.17

/*-------------------- TODO: LOGICAL ERROR IN QT??

profon()

# Let's take the example of the german letter ß that
# should be uppercased to SS

? Q("ß").CharCase()
#--> lowercase

? Q("ß").Uppercased()
#--> SS

# Which is nice, and we can check it for a hole word
? StzStringQ("der fluß").Uppercased()
#--> DER FLUSS

# Now, if we check the other way around :
? Q("SS").Lowercased()
#--> ss

# we don't get "ß", which is expected, because Softanza is running
# at the default locale ("C" locale) and not the german locale.

# Therefore, we need to tune the previous expression by sepecifying
# the german locale ("ge-GE")

? Q("SS").LowercasedInLocale("ge-GE")
#--> ss (ERROR in QT: it should be ß)

proff()
# Executed in 0.08 second(s)

/*--------------------

profon()

? StzStringQ("der fluß").Uppercased()
#--> DER FLUSS

? StzStringQ("der fluß").IsLowercase()
#--> _TRUE_

proff()
# Executed in 0.03 second(s)

/*-------------------- LOGICAL ERROR IN QT: Revist after fixing stzLocale

profon()

? Q("DER FLUSS").LowercasedInLocale("de-DE")
#--> der fluss

? Q("der fluß").IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE")
#--> _FALSE_ (but should be _TRUE_!)

proff()
# Executed in 0.05 second(s)

/*===================

profon()

o1 = new stzText("in search of lost time")
? @@( o1.Words() )
#--> [ "in", "search", "of", "lost", "time" ]

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.40 second(s) in Ring 1.18
# Executed in 0.49 second(s) in Ring 1.17

/*--------------------

profon()

o1 = new stzString("...ONE...NONE...SONY...")

? o1.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ])
#--> 4

? @@ ( o1.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]) ) + NL
#--> [ 5, 10, 12, 19 ]

# Same functions work for lists

o1 = new stzList([
	".", ".", ".",
	"O", "N", "E",
	".", ".", ".",
	"N", "O", "N", "E",
	".", ".", ".",
	"S", "O", "N", "Y",
	".", ".", "."
])

? o1.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ])
#--> 4

? @@ ( o1.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]) )

proff()
# Executed in 0.04 second(s)

/*--------------------

profon()

o1 = new stzString("one;two;three;four;five")

? @@( o1.Splits(";") ) + NL
#--> [ "one", "two", "three", "four", "five" ]

? @@( o1.SplitsZ(";") ) + NL
#--> [ [ "one", 1 ], [ "two", 5 ], [ "three", 9 ], [ "four", 15 ], [ "five", 20 ] ]

? @@( o1.SplitsZZ(";") )
#--> [
#	[ "one", [ 1, 3 ] ], [ "two", [ 5, 7 ] ], [ "three", [ 9, 13 ] ],
#	[ "four", [ 15, 18 ] ], [ "five", [ 20, 23 ] ]
# ]

proff()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20

/*--------------------

profon()

o1 = new stzString("in search of lost time, all the time")
? @@( o1.FindWords() )
#--> [ 1, 4, 11, 14, 19, 25, 29, 33 ]

proff()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.17

/*--------------------

profon()

StzStringQ("in search of lost time") {

	? TitlecasedInLocale("en-US")
	#--> In Search Of Lost Time

	? CapitalisedInLocale("en-US")
	#--> In Search Of Lost Time
}

StzStringQ("à la recherche du temps perdu") {

	? TitlecasedInLocale("fr-FR")
	#--> À la recherche du temps perdu

	? CapitalisedInLocale("fr-FR")
	# !--> À la Recherche du Temps Perdu
}

proff()
# Executed in 0.39 second(s) in Ring 1.22

/*--------------------

profon()

? StzStringQ(:Arabic).IsScript()
#--> _TRUE_

? StzStringQ(:Arabic).IsScriptName()
#--> _TRUE_

? StzStringQ(:Arab).IsScriptAbbreviation()
#--> _TRUE_

? StzStringQ("1").IsScriptCode()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*====================

profon()

o1 = new stzString("125.450")
o1.RemoveNthChar(7)
? o1.Content()
#--> "125.45"

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("125.450")

o1.RemoveCharsWXT('{ @char = "2" }')
? o1.Content()
#--> "15.450"

proff()
# Executed in 0.14 second(s).

/*=====================

profon()

o1 = new stzString(".....mmMm")

? o1.HasTrailingChars()
#--> _FALSE_

? @@( o1.TrailingChar() ) + NL
#--> ""

? o1.HasTrailingCharsCS(:CaseSensitive = _FALSE_)
#--> _TRUE_

? o1.TrailingCharCS(_FALSE_)
#--> "m"

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("....00000")

? @@( o1.FindTrailingChars() )
#--> [ 5, 6, 7, 8, 9 ]

? @@( o1.FindTrailingCharsZZ() )
#--> [ 5, 9 ]

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("12.4560000")

? o1.HasTrailingChars()
#--> _TRUE_

? o1.HowManyTrailingChar()
#--> 4

? @@( o1.TrailingChar() )
#--> "0"

? o1.TrailingCharIs("0")
#--> _TRUE_

proff()
# Executed in 0.01 second(s).


/*-----------

profon()

o1 = new stzString("12.4560000")

o1.RemoveThisTrailingChar("0")
? o1.Content()
#--> 12.456

proff()
# Executed in 0.06 second(s).

#------

profon()

? Q("12.45600").ThisTrailingCharRemoved("0")
#--> "12.456"

proff()
# Executed in 0.01 second(s).

/*------ #narration TRAILING CHAR, TRAILING CHARS, AND TRAILiNG SUBSTRING

profon()

# You have a number in string an you want to get some info about its trailing part?

# A trailing part is a substring at the end of the string composed of repeated chars.

o1 = new stzString("12.4560000")

# You can check if the string contains a trailing part:

? o1.HasTrailingSubString() # Or HasTrailingChars()
#--> _TRUE_

# And even get their number:

? o1.HowManyTrailingChar()
#--> 4

# You can get theim as a string:

? o1.TrailingSubString() # Or TrailingCharsXT()
#--> "0000"

# or get them as a list of chars:

? @@( o1.TrailingChars() )
#--> [ "0", "0", "0", "0" ]

# Usually, in practice, you need to remove them:

o1.RemoveTrailingChars() # Or RemoveTrailingSubString()
? o1.Content()
#--> "12.456"

proff()
# Executed in 0.01 second(s).

/*---------

profon()

o1 = new stzString("12.4560000")

? o1.TrailingSubString()
#--> "0000"

? @@( o1.TrailingSubStringZZ() )
#--> [ "0000", [ 7, 10 ] ]

o1.RemoveTrailingSubString()
? o1.Content()
# 12.456

proff()
# Executed in 0.01 second(s).

/*=========

profon()

o1 = new stzString("000012.456")

? o1.HasLeadingSubString() # Or HasLeadingChars()
#--> _TRUE_

? o1.HowManyLeadingChar()
#--> 4

# You can get theim as a string:

? o1.LeadingSubString() # Or LeadingCharsXT()
#--> "0000"

# or get them as a list of chars:

? @@( o1.LeadingChars() )
#--> [ "0", "0", "0", "0" ]

# Usually, in practice, you need to remove them:

o1.RemoveLeadingChars() # Or RemoveLeadingSubString
? o1.Content()
#--> 12.456

proff()
# Executed in 0.02 second(s).

/*---------

profon()

o1 = new stzString("00012.456")

? o1.LeadingSubString()
#--> "000"

? @@( o1.LeadingSubStringZZ() )
#--> [ "000", [ 1, 3 ] ]

o1.RemoveLeadingSubString()
? o1.Content()
# 12.456

proff()
# Executed in 0.02 second(s).

/*---------

profon()

o1 = new stzString("000122.12")

? o1.HasLeadingChars()
#--> _TRUE_

? o1.LeadingCharsXT()
#--> "000"

? o1.LeadingCharsRemoved()
#--> "122.12"

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("000122.12")
? o1.LeadingChar() #--> "0"

o1.RemoveThisLeadingChar("0")
? o1.Content()	#--> "122.12"

proff()
# Executed in 0.01 second(s).

/*=====================

profon()

o1 = new stzString("ABC")
? o1.FirstChar() #--> A
? o1.LastChar()  #--> C

proff()
# Executed in 0.01 second(s).

/*------

profon()

o1 = new stzString("---Ring")

? o1.FirstChar()
#--> "-"

? o1.LastChar()
#--> "g"

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("BATISTA123")

o1.RemoveNLastChars(3)
? o1.Content()
#--> BATISTA

? StzStringQ("BATISTA123").LastNCharsRemoved(3)
#--> BATISTA

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("BATISTA1")
o1.RemoveLastChar()
? o1.Content()
#--> BATISTA

? StzStringQ("BATISTA1").LastCharRemoved()
#--> BATISTA

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("123BATISTA")

o1.RemoveNFirstChars(3)
? o1.Content()
#--> BATISTA

? StzStringQ("123BATISTA").FirstNCharsRemoved(3)
#--> BATISTA

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("1BATISTA")

o1.RemoveFirstChar()
? o1.Content()
#--> BATISTA

? StzStringQ("1BATISTA").FirstCharRemoved()
#--> BATISTA

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("SOFTANZA IS AWSOME!")

? o1.IsEqualTo("softanza is awsome!")
#--> _FALSE_

? o1.IsEqualToCS("softanza is awsome!", :CS = _FALSE_)
#--> _TRUE_

? o1.IsUppercaseOf("softanza is awsome!")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*================= Quiet-Equality of two strings
$
profon()

o1 = new stzString("SOFTANZA IS AWSOME!")

#TODO // Check performance of IsQuietEqualTo() --> Root cause RemoveDiacritics()
#UPDATE Done, performance is now good (Ring 1.22)

? o1.IsQuietEqualTo("softanza is awsome!")
#--> _TRUE_

? o1.IsQuietEqualTo("Softansa is aowsome!")
#--> _TRUE_ (we added an "o" to "awsome")

? o1.IsQuietEqualTo("Softansa iis aowsome!")
#--> _FALSE_ (we add "i" to "is" and "o" to "awsome")

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

# Quiet-eqality is particularily useful in french where "énoncé" and "ÉNONCÉ" are the same:

o1 = new stzString("énoncé")

? o1.IsEqualTo("enonce")
#--> _FALSE_

? o1.IsQuietEqualTo("enonce")
#--> _TRUE_

? o1.IsQuietEqualTo("ÉNONCÉ")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

? StzCharQ("é").Script()
#--> latin

? StzCharQ("ن").Script()
#--> arabic

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzText("père frère mère tête")

? o1.CountScripts()
#--> 2

? o1.Scripts()
#--> [ "latin", "common" ]

? o1.Script()
#--> "latin"

? o1.DiacriticsRemoved()
#--> "pere frere mere tete"

proff()
# Executed in 0.27 second(s) in Ring 1.22

/*--------------------

profon()

# We can adjust the ratio of QuitEquality by our selves (value between 0 and 1):

o1 = new stzString("mahmoud fayed")

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> _FALSE_

? QuietEqualityRatio()
#--> 0.09 (default value)

# If we need a more permissive quiet-eqality check, then we set it at a weaker value:

SetQuietEqualityRatio(0.35)

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*====================

profon()

# Operators on stzString

o1 = new stzString("SOFTANZA")

# Getting a char by position

? o1[5]
#--> "A"

# Finding the occurrences of a substring in the string

? o1["A"]
#--> [ 5, 8 ]

? o1["NZA"]
#--> [ 6 ]

# Comparing the string with other strings

? o1 = StringUppercase("softanza")
#--> _TRUE_

#TODO // Complete the other operators when COMPARAISON methods are made in stzString

proff()
# Executed in 0.02 second(s).

/*=================

profon()

o1 = new stzString("{{{ Scope of Life }}}")

? o1.BeginsWith("{")
#--> _TRUE_

? o1.EndsWith("}")
#--> _TRUE_

? o1.IsBoundedBy([ "{", "}" ])
#--> _TRUE_

? o1.TheseBoundsRemoved("{", "}")
#--> {{ Scope of Life }}

proff()
# Executed in 0.07 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString('"name"')
? o1.IsBoundedBy([ '"','"' ])	#--> _TRUE_

o1 = new stzString(':name')
? o1.IsBoundedBy([ ':', _NULL_ ])	#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("one two three four")
o1.ReplaceAll( "two", "---")
? o1.Content()
#--> "one --- three four"

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("one two three four")
o1.ReplaceMany([ "two", "four" ], :By = "---")
? o1.Content()
#--> "one --- three ---"

proff()
# Executed in 0.01 second(s).

/*=====================

profon()

o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceCS(3, "Mio", _TRUE_)
#--> 16

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")

? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 1)
#--> 4

? o1.FindNextNthOccurrence(2, "Mio", :StartingAt = 7)
#--> 16

? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 20)
#--> 22

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")

? o1.NextOccurrence("Mio", :StartingAt = 1)
#--> 4

? o1.NthPreviousOccurrence(2, "Mio", :StartingAt = 15)
#--> 4

? o1.NthPreviousOccurrence(4, "Mio", :StartingAt = 25)
#--> 4

proff()
# Executed in 0.02 second(s).

/*=====================
*
profon()

o1 = new stzString("216;TUNISIA;227;NIGER")

? o1.Section(5, o1.NextOccurrence( :Of = ";", :StartingAt = 5 ) - 1 )
#--> TUNISIA

proff()
# Executed in 0.01 second(s).

/*====================

profon()

o1 = new stzString("amd[bmi]kmc[ddi]kc")
? o1.SubStringsBoundedBy([ "[", "]" ])
#--> [ "bmi", "ddi" ]

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

# SubStringsBoundedBy can't manage DEEP combinations like this

o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
? o1.SubStringsBoundedBy([ "[", "]" ])

#!--> "A", "T", [ :hi, [ "deep1", [

proff()
# Executed in 0.01 second(s).

/*====================

profon()

# In Softanza both n and N chars correspond to the letter "N"

o1 = new stzString("Adoption of the plan B")
? o1.ContainsTheLetters([ "N", "b" ])
#--> _TRUE_

proff()
# Executed in 0.02 second(s).

/*--------------------

profon()

o1 = new stzString("opsus amcKLMbmi findus")

? o1.FindSubStringBetween("KLM", "amc", "bmi") # Or simply FindBetween()
#--> 10

proff()
# Executed in 0.01 second(s).

/*======= #narration ANALYZING THE SCRIPTS FORMING A STRING

profon()

StzStringQ("__b和平س__a__و") {

	? ContainsLettersInScript(:Latin)
	#--> _TRUE_

	? CharsWXT( ' Q(@char).IsLatin() ')
	#--> [ "b", "a" ]

	? ContainsLettersInScript(:Arabic)
	#--> _TRUE_

	? CharsWXT( ' Q(@char).IsArabic() ')
	#o--> [ "س", "و" ]

	? ContainsLettersInScript(:Han)
	#--> _TRUE_

	? CharsWXT( ' StzCharQ(@char).IsHanScript() ')
	#--> [ "和", "平" ]

	? ContainsCharsInScript(:Common)
	#--> _TRUE_

	? CharsWXT( ' StzCharQ(@char).IsCommonScript() ')
	#--> [ "_", "_", "_", "_", "_", "_" ]

	#NOTE that if you say
	? ContainsLettersInScript(:Common)	# or
	? ContainsLettersInScript(:Unkowan)
	# you get _FALSE_ because there is no sutch letter that has a script
	# 'common'. In other terms, any letter in the world has to belong
	# to a knowan script.
}

proff()
# Executed in 0.57 second(s) in Ring 1.22
# Executed in 0.61 second(s) in Ring 1.18

/*--------------------

profon()

o1 = new stzString("__b和平س__a__و")
? o1.ToStzText().Scripts()
#--> [ "latin", "han", "arabic" ]

proff()
# Executed in 0.04 second(s).

/*===================

profon()

o1 = new stzString("__b和平س__a_ووو")

? @@( o1.PartsUsingXT(' StzCharQ(@char).Script() ') )
#--> [ "__", "b", "和平", "س", "__", "a", "_", "ووو" ]

proff()
# Executed in 0.13 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("__b和平س__a_ووو")

? o1.PartsUsing(' StzCharQ(This[@i]).Script() ' )
# #--> [ "__", "b", "和平", "س", "__", "a", "_", "ووو" ]

proff()
# EExecuted in 0.09 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("__b和平س__a_ووو")
? @@NL( o1.PartsUsingZZ(' StzCharQ(This[@i]).Script() ' ) )
#-->
# [
#	[ "__", [ 1, 2 ] ],
#	[ "b", [ 3, 3 ] ],
#	[ "和平", [ 4, 5 ] ],
#o	[ "س", [ 6, 6 ] ],
#	[ "__", [ 7, 8 ] ],
#	[ "a", [ 9, 9 ] ],
#	[ "_", [ 10, 10 ] ],
#o	[ "ووو", [ 11, 13 ] ]
# ]

proff()
# Executed in 0.09 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18

/*====================

profon()

# Case sensisitivity is considered only for latin letters

? StzCharQ("9").IsLowercase()
#--> _FALSE_

? StzCharQ("9").IsUppercase()
#--> _FALSE_

? StzCharQ("ك").IsLowercase()
#--> _FALSE_

? StzCharQ("ك").IsUppercase()
#--> _FALSE_

? StzStringQ("120").IsLowercase()
#--> _FALSE_

? StzStringQ("120m").IsLowercase()
#--> _TRUE_

? StzStringQ("120M").IsUppercase()
#--> _TRUE_

? StzStringQ("كلام").IsLowercase()
#--> _FALSE_

proff()
# Executed in 0.09 second(s).

/*====================

profon()

o1 = new stzString("abcdef")

? o1.ContainsNoOneOfThese([ "xy", "xyz", "mwb" ])
#--> _TRUE_

? o1.ContainsNoOneOfThese([ "xy", "xyz", "de", "mwb" ])
#--> _FALSE_

proff()
# Executed in 0.01 second(s).

/*====================

profon()

? Q("tunis").Lowercased()
#--> tunis

? Q("tunis").Uppercased()
#--> TUNIS

? Q("tunis").Titlecased()
#--> Tunis

 //? Q("tunis").Foldcased()	#TODO

proff()
# Executed in 0.06 second(s).

/*--------------------

profon()

? StzStringQ("tunis").IsLowercased()
#--> _TRUE_

? StzStringQ("TUNIS").IsUppercased()
#--> _TRUE_

? StzStringQ("Tunis").IsTitlecased()
#--> _TRUE_

//? StzStringQ("tunis").IsFoldcased()	#TODO

proff()

/*====================

profon()

? StringsAreEqualCS([ "abc","abc" ], _TRUE_ )
#--> _TRUE_

? StringsAreEqual([ "cbad", "cbad", "cbad" ])
#--> _TRUE_

? BothStringsAreEqualCS("abc", "abc", _TRUE_)
#--> _TRUE_

? BothStringsAreEqual("abc", "abc")
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*====================

profon()

? Q("~~H/U/S/S/E/I/N~~").CharsWXT('{ Q(@char).isLetter() }')
#--> [ "H","U","S","S","E","I","N" ]

? Q("~~H/U/S/S/E/I/N~~").NumberOfCharsWXT('{ Q(@char).isLetter() }')
#--> 7

proff()
# Executed in 0.36 second(s).

/*--------------------

profon()

? Q("--A--B--").ContainsLetters()
#--> _TRUE_

? Q("--A--B--").ContainsLetter("A")
#--> _TRUE_

? Q("--A--B--").ContainsLetter("a")
#--> _TRUE_

? Q("--A--B--").ContainsLetter("M")
#--> _FALSE_

? Q("H").IsALetterOf("HUSSEIN")
#--> _TRUE_

? Q("h").IsALetterOf("HUSSEIN")
#--> _TRUE_

proff()
# Executed in 0.04 second(s).

/*=====================

profon()

? StzStringQ("SOFTANZA").CharsReversed()
#--> SOℲꞱⱯNZⱯ

? StzStringQ(" Softanza    Near-natural Programming   ").Simplified()
#--> Softanza Near-natural Programming

proff()
# Executed in 0.07 second(s).

/*--------------------

profon()

# TQ is an abbreviation of StzTextQ()

? TQ("عربي").Script()
#--> arabic

? TQ("ring").Script()
#--> latin

proff()
# Executed in 0.06 second(s).

/*-------------------

profon()

# Used internally by the library in evaluating conditional code:

? StzStringQ('myfunc()').IsAlmostAFunctionCall()
#--> _TRUE_

? StzStringQ('my_func("name")').IsAlmostAFunctionCall()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

? StzStringQ("G").IsLetter()
#--> _TRUE_

? UppercaseOf("b")
#--> B

? LowercaseOf("B")
#--> b

//? FoldcaseOf("sinus")		# !!! Undefined function #TODO

proff()
# Executed in 0.01 second(s).

/*=================== #narration CHARS, BYTES, UNICODE CODEPOINTS, AND BYTCODES

profon()

# Are you confused between chars, bytes, unicodes (or unicode code points), and bytecodes?!
# Here how Softanza can help you see them all in clarity:

StzStringQ("s㊱m") {

	? Chars()
	#--> [ "s", "㊱", "m" ]

	? Unicodes()
	#--> [ 115, 12977, 109 ]

	? UnicodesPerChar()
	#--> [ [ "s", 115 ], [ "㊱", 12977 ], [ "m", 109 ] ]

	? SizeInBytes() #--> 435

	? @@( SizeInBytesPerChar() ) + NL
	#--> [ [ "s", 33 ], [ "㊱", 35 ], [ "m", 33 ] ]

	#--

	? Bytes()
	#--> [ "s", "�", "�", "�", "m" ]

	? @@( BytesPerChar() ) + NL
	#--> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]

	? @@( NumberOfBytesPerChar() ) + NL
	#-->  [ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ]

	#--

	? Bytecodes()
	#--> [ 115, -29, -118, -79, 109 ]

	? @@( BytecodesPerChar() )
	#--> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]
}

proff()
# Executed in 0.07 second(s).

/*===================

profon()

? StzStringQ("sAlut").IsLowercase()
#--> _FALSE_

proff()
# Executed in 0.02 second(s).

/*===================

profon()

? StzStringQ("@char___@char___@char").ReplaceAllQ("@char","@item").Content()
#--> @item___@item___@item

proff()
# Executed in 0.01 second(s).

/*------------------

profon()

StzStringQ( "Text processing with Ring" ) {

	ReplaceCharsWXT(
		:Where = '{ @char = "i" }',
		:With = "*"	
	)

	? Content()
}

#--> "Text process*ng w*th R*ng"

proff()
# Executed in 0.20 second(s).

/*-------------------

profon()

StzStringQ("1a2b3c") {

	ReplaceCharsWXT(
		:Where = '{ Q(@char).isLowercase() }',
		:With  = "*"
	)

	? Content()
	#--> 1*2*3*
}

proff()
# Executed in 0.16 second(s).

/*====================

profon()

o1 = new stzString("LIFE")

? o1.Inverted()
#--> EFIL

? o1.CharsInverted() + NL
#--> ⅂IℲƎ

? o1.Turned()
#--> ƎℲI⅂

? o1.CharsTurned()
#--> ⅂IℲƎ

proff()
# Executed in 0.09 second(s).

/*--------------------

profon()

? Q("LIFE").Turned()
#--> ƎℲI⅂

? Q("GAYA").Turned()
#--> Ɐ⅄Ɐ⅁

? Q("TIBA").Turned()
#--> ⱯBIꞱ

? Q("HANEEN").Turned()
#--> NƎƎNⱯH

? Q("MILLAVOY (Y908$)").Turned()
#--> ($806⅄) ⅄OɅⱯ⅂⅂IƜ

proff()
# Executed in 0.17 second(s).

/*--------------------

profon()

? Q("LIFE").Inversed()
#--> EFIL

? Q("GAYA").Inversed()
#--> AYAG

? Q("TIBA").Inversed()
#--> ABIT

? Q("HANEEN").Inversed()
#--> NEENAH

? Q("MILLAVOY (Y908$)").Inversed()
#--> )$809Y( YOVALLIM

proff()
# Executed in 0.01 second(s).

/*================== #TODO

profon()

o1 = new stzString("Ring Programming Language")
? o1.WalkBackwardW( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ) #--> 5
? o1.WalkForwardW( :StartingAt =  6, :UntilBefore = '{ @char = "r" }' ) #--> 9

proff()

/*==================

profon()

? StzTextQ("abc سلام abc").ContainsScript(:Arabic)
#--> _TRUE_

? StzTextQ("abc سلام abc").ContainsArabicScript()
#--> _TRUE_

#NOTE: Scripts are now moved from stzString to stzText

# You can use this short form instead of StzTextQ()
? TQ("سلام").Script() #--> :Arabic

proff()
# Executed in 0.07 second(s).

/*==================

profon()

? StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content()
#--> év*nement

? StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content()
#--> év*nement

proff()
# Executed in 0.01 second(s).

/*==================

profon()

StzStringQ("original text before hashing") {

	Hash(:MD5)
	? Content()
	#--> 8ffad81de2e13a7b68c7858e4d60e263

}

proff()
# Executed in 0.02 second(s).

/*==================

profon()

? StzStringQ("ring").StringCase()
#--> :Lowercase

? StzStringQ("RING").StringCase()
#--> :Uppercase

? StzStringQ("RING and python").StringCase()
#--> :hybridcase

proff()
# Executed in 0.25 second(s).

/*========== STRING PARTS ===========

profon()

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@(o1.PartsUsingXT('StzCharQ(@char).CharCase()')) + NL # or simply o1.PartsUsing('StzCharQ(@char)')
# [
#	"H",
#	"anine",
#o	" حنين ",
#	"is",
#	" ",
#	"a",
#	" ",
#	"nice",
#o	" جميلة وعمرها 7 ",
#	"years",
#	"-",
#	"old",
#o	" سنوات ",
#	"girl",
#	"!"
# ]

? @@NL( o1.PartsAndPartitionersUsingXT('StzCharQ(@char).CharCase()') ) + NL # or Parts2UsingXT()
#--> [
#	[ "H", 			"uppercase" 	],
#	[ "anine", 		"lowercase" 	],
#o	[ " حنين ", 		"" 		],
#	[ "is", 		"lowercase" 	],
#	[ " ", 			"" 		],
#	[ "a", 			"lowercase" 	],
#	[ " ", 			"" 		],
#	[ "nice", 		"lowercase" 	],
#o	[ " جميلة وعمرها 7 ", 	"" 	],
#	[ "years", 		"lowercase" 	],
#	[ "-", 			"" 		],
#	[ "old", 		"lowercase" 	],
#o	[ " سنوات ", 		"" 		],
#	[ "girl", 		"lowercase" 	],
#	[ "!", 			"" 		]
# ]

? @@NL( o1.PartitionersAndPartsUsingXT('StzCharQ(@char).CharCase()') ) 
#--> [
#	[ "uppercase", 		"H" 			],
#	[ "lowercase", 		"anine" 		],
#o	[ "", 			" حنين " 		],
#	[ "lowercase", 		"is" 			],
#	[ "", 			" " 			],
#	[ "lowercase", 		"a" 			],
#	[ "", 			" " 			],
#	[ "lowercase", 		"nice" 			],
#o	[ "", 			" جميلة وعمرها 7 " 	],
#	[ "lowercase", 		"years" 		],
#	[ "", 			"-" 			],
#	[ "lowercase", 		"old" 			],
#o	[ "", 			" سنوات " 		],
#	[ "lowercase", 		"girl" 			],
#	[ "", 			"!" 			]
# ]

proff()
# Executed in 0.92 second(s).

/*-----------------

profon()

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@NL(o1.PartsUsingZZ( 'StzCharQ(This[@i]).CharCase()' ))

#--> [
#	[ "H", [ 1, 1 ] ],
#	[ "anine", [ 2, 6 ] ],
#o	[ " حنين ", [ 7, 12 ] ],
#	[ "is", [ 13, 14 ] ],
#	[ " ", [ 15, 15 ] ],
#	[ "a", [ 16, 16 ] ],
#	[ " ", [ 17, 17 ] ],
#	[ "nice", [ 18, 21 ] ],
#o	[ " جميلة وعمرها 7 ", [ 22, 37 ] ],
#	[ "years", [ 38, 42 ] ],
#	[ "-", [ 43, 43 ] ],
#	[ "old", [ 44, 46 ] ],
#o	[ " سنوات ", [ 47, 53 ] ],
#	[ "girl", [ 54, 57 ] ],
#	[ "!", [ 58, 58 ] ]
# ]

proff()
# Executed in 0.35 second(s).

/*-----------------

profon()

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@NL( o1.PartsClassifiedUsingXT( 'StzCharQ(@char).Script()' ) )

#--> [
#	:latin	 	= [ "Hanine", "is", "a", "nice", "years", "old", "girl" ],
#	:common		= [ " ", " ", " ", " ", " ", " ", " 7 ", "-", " ", " ", "!" ],
#	:arabic		= [ "حنين", "جميلة", "وعمرها", "سنوات" ],
#     ]

# Alternatives to PartsClassified(): Classify() and Classified()

proff()
# Executed in 0.36 second(s).

/*-----------------
profon()

o1 = new stzString("AM23-X ")
? o1.PartsAndPartitionersUsingXT('StzCharQ(@char).CharType()') # or Parts2UsingXT()
#--> [
#	"AM" = :Letter_Uppercase,
#	"23" = :Number_Decimaldigit,
#	"-"  = :Punctuation_Dash",
#	"X"  = :Letter_Uppercase,
#	" "  = :Separator_Space
#    ]

proff()
# Executed in 0.12 second(s).

/*-----------------

profon()

o1 = new stzString("Abc285XY&من")
? o1.Parts2UsingXT('{	# Or PartsAndPartitionersUsingXT()
	StzCharQ(@char).CharType()
}')

#--> [
#	"A"	= :Letter_Uppercase,
#	"bc"	= :Lerrer_Lowercase,
#	"285"	= :Number_DecimalDigit,
#	"XY"	= :Letter_Uppercase,
#	"&"	= :Punctauation_Other,
#o	"من"	= :Letter_Other
#    ]

proff()
# Executed in 0.15 second(s).

/*-----------------

profon()

o1 = new stzString("maliNIGERtogoSENEGAL")

? @@NL( o1.Parts2Using('{ StzCharQ(This[@i]).CharCase() }') ) + NL
#--> [ 	
#	"mali" 		= :Lowercase,
# 	"NIGER" 	= :Uppercase,
#	"togo" 		= :Lowercase,
#	"SENEGAL" 	= :Uppercase
#    ]

? @@NL( o1.Parts2UsingZZ('{ StzCharQ(This[@i]).CharCase() }') )
#--> [
#	[ "mali", [ 1, 4 ] ],
#	[ "NIGER", [ 5, 9 ] ],
#	[ "togo", [ 10, 13 ] ],
#	[ "SENEGAL", [ 14, 20 ] ]
# ]

proff()
# Executed in 0.32 second(s).

/*-----------------

profon()

o1 = new stzString("Abc285XY&من")

? @@( o1.Parts2Using( 'CharQ(@i).IsLetter()' ) ) + NL
#--> Gives:
# [ "Abc" = _TRUE_, "285" = _FALSE_, "XY" = _TRUE_, "&" = _FALSE_, "من" = _TRUE_ ]

? @@( o1.Parts2Using("CharQ(@i).Orientation()") ) + NL
#--> Gives:
# [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? @@( o1.Parts2Using("CharQ(@i).IsUppercase()") ) + NL
#--> Gives:
# [ "A" = _TRUE_, "bc285" = _FALSE_, "XY" = _TRUE_, "&من" = _FALSE_ ]

? @@( o1.Parts2Using("CharQ(@i).CharCase()") )
#--> Gives:
# [ "A" = :Uppercase, "bc" = :Lowercase, "285" = _NULL_, "XY" = :Uppercase, "&من" = _NULL_ ]

proff()
# Executed in 0.35 second(s).

/*========================

profon()

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceAllChars( :With = "*" )
? o1.Content()
#--> "*******************************"

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("Use these two letters: س and ص.")
? o1.FindCharsW(
	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		NOT StzCharQ(This[@i]).IsLatinLetter()
	}'
)
#--> [ 24, 30 ]

? o1.CharsW(
	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		NOT StzCharQ(This[@i]).IsLatinLetter()
	}'
)
#o--> [ "س", "ص" ]

proff()
# Executed in 0.64 second(s).

/*================

profon()

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceCharsW(

	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		(NOT StzCharQ(This[@i]).IsLatinLetter())
	}',

	:With = '***'
)

? o1.Content()
#--> "Use these two letters: *** and ***."

proff()
# Executed in 0.35 second(s).

/*================

profon()

? StzCharQ(":").IsPunctuation()
#--> _TRUE_

? StzCharQ(":").CharType()
#--> punctuation_other

proff()
# Executed in 0.35 second(s).

/*================

profon()

o1 = new stzString("Use these two letters: س , ص.")

o1.RemoveCharsWhereQ('{

	StzCharQ(This[@i]).IsArabicLetter() or
	StzCharQ(This[@i]).IsPunctuation()

}')

? o1.Simplified()
#--> "Use these two letters"

proff()
# Executed in 0.33 second(s).

/*---------------

profon()

o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceCharsWXT(
	:Where = '{ @char != " " and StzCharQ(@Char).IsArabicLetter() }',
	:With = "*"
)

? o1.Content()
#--> "Use these two letters: * and *."

proff()
# Executed in 0.36 second(s).

/*===============

profon()

? StzCharQ("س").Name()
#--> ARABIC LETTER SEEN

? StzCharQ("ص").Name()
#--> ARABIC LETTER SAD

proff()
# Executed in 0.15 second(s).

/*==============

profon()

o1 = new stzString("SoftAnza Libraray")

? o1.CountCharsWXT('{ @Char = "a" }')
#--> 3

? o1.CountCharsWXT('{	Q(@Char).IsEqualToCS("a", :CS = _FALSE_) }')
#--> 4

proff()
# Executed in 0.30 second(s).

/*--------------

profon()

o1 = new stzString("SoftAnza Libraray")
? o1.FindCharsWXT('{ StzCharQ(@Char).Lowercased() = "a" }')
#--> [ 5, 8, 14, 16 ]

proff()
# Executed in 0.19 second(s).

/*=================

profon()

o1 = new stzString("abc;123;gafsa;ykj")
? o1.SplitQ(";").NthItem(3)
#--> gafsa

# Same as:
? o1.NthSubstringAfterSplittingStringUsing(3, ";") # Long, but useful in natural-coding
#--> gafsa

proff()
# Executed in 0.01 second(s).

/*===================

profon()

? StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
	:Line = :Solid,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
	:TextAdjustedTo = :Center # or :Left or :Right or :Justified
])

#--> ╭─────────────────────┐
#    │ SOFTANZA IS AWSOME! │
#    └─────────────────────╯

proff()
# Executed in 0.02 second(s).

/*------------------

profon()

? StzStringQ("RING").BoxXT([ ])

proff()

/*------------------

profon()

StzStringQ("RING") {
	? Content()
	? Boxed()

	? BoxedRounded()
	? BoxedRoundedDashed()

	? EachCharBoxed()
	? EachCharboxedRounded()

	? VizFindBoxed("I")	#--> TODO: Add VizFindBoxed()
}

#--> RING
#   ┌──────┐
#   │ RING │
#   └──────┘
#   ╭──────╮
#   │ RING │
#   ╰──────╯
#   ╭╌╌╌╌╌╌╮
#   ┊ RING ┊
#   ╰╌╌╌╌╌╌╯
#   ┌───┬───┬───┬───┐
#   │ R │ I │ N │ G │
#   └───┴───┴───┴───┘
#   ╭───┬───┬───┬───╮
#   │ R │ I │ N │ G │
#   ╰───┴───┴───┴───╯
#   ┌───┬───┬───┬───┐
#   │ R │ I │ N │ G │
#   └───┴─•─┴───┴───┘

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*------------------

profon()

StzStringQ("RING IS NICE") {

	? Content()

	? Boxed()
	? BoxedRound()

	? EachCharBoxed()
	? EachCharBoxedRounded()

	// ? VizFindBoxed("I")	#TODO // Add it

	? BoxedDashed()
	? BoxedDashedRounded()

	? CharsBoxedXT([
		:Line = :Solid,
		:Corners = [
			:Round, :Rectangular,
			:Round, :Rectangular
		]
	])

}

#--> RING IS NICE
#   ┌──────────────┐
#   │ RING IS NICE │
#   └──────────────┘
#   ╭──────────────╮
#   │ RING IS NICE │
#   ╰──────────────╯
#   ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
#   │ R │ I │ N │ G │   │ I │ S │   │ N │ I │ C │ E │
#   └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
#   ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
#   │ R │ I │ N │ G │   │ I │ S │   │ N │ I │ C │ E │
#   ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
#   ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
#   ┊ RING IS NICE ┊
#   └╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
#   ╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
#   ┊ RING IS NICE ┊
#   ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯
#   ╭──────────────┐
#   │ RING IS NICE │
#   └──────────────╯

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*-----------------

profon()

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Center
])
#-->
# ╭────────────────────╮
# │ PARIS              │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Left
])
#-->
# ╭────────────────────╮
# │       PARIS        │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Right
])
#-->
# ╭────────────────────╮
# │ P    A   R   I   S │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Justified
])
#-->
# ╭────────────────────╮
# │              PARIS │
# ╰────────────────────╯

proff()
# Executed in 0.07 second(s).

/*---------------------

profon()

# You can box the entire string like this:
? StzStringQ("SOFTANZA").BoxedXT([])
#-->
# ┌──────────┐
# │ SOFTANZA │
# └──────────┘

# Or box it char by char like this:

? StzStringQ("SOFTANZA").BoxedXT([ :EachChar = _TRUE_ ])

#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.05 second(s).

/*--------------------- TODO

profon()

# Boxing work great for latin chars, but for non latin chars,
# it would break:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:TextAdjustedTo = :Center
])
#-->
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌┘

# That is because chars in non-latin script won't have necessarily
# same width. In fact, this is related to the font used to render
# the chars on the screen. Hence, if you use a fixed-width font,
# the boxing will work correclty (TODO: check this!).

# As a configuration option that helps in solving this issue (without
# switching ta a fixed-width font, Softanza provide the width option
# that you can adjust manually and get a nice result like this:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:Width = 30,
	:TextAdjustedTo = :Center
])
#--> TODO: Fix the output to return this
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘

proff()
# Executed in 0.03 second(s).

/*==================

profon()

? StzStringQ("ar_TN-tun").ContainsEachCS(["_", "-"],_TRUE_)
#--> _TRUE_

? StzStringQ("ar_TN-tun").ContainsBoth("_", "-")
#--> _TRUE_

proff()
# Executed in 0.03 second(s).

/*==================

profon()

o1 = new stzString("a")
o1.MultiplyBy([ "b", "c", "d" ])
? o1.Content() #--> "abacad"

proff()
# Executed in 0.01 second(s).

/*--------------

profon()

o1 = new stzString("a")
? o1 * [ "b", "c", "d" ]
#--> abacad

proff()
# Executed in 0.01 second(s).

/*---------------

profon()

o1 = new stzString("abcdefj")

? o1 / 2
#--> [ "abcd", "efj" ]

? o1 % 2
#--> "efj"

proff()
# Executed in 0.03 second(s).

/*--------------

profon()

o1 = new stzString("ab-ac-ad")
? o1 / "-" 			# Same as ? o1.Split("-")
#--> [ "ab", "ac", "ad" ]

proff()
# Executed in 0.01 second(s).

/*==================

profon()

o1 = new stzString("happy-holidays")

? o1.IsLowercase()
#--> _TRUE_

o1 = new stzString("HOLIDAYS!")
? o1.IsUppercase()
#--> _TRUE_

proff()
# Executed in 0.04 second(s).

/*==================

profon()

StzStringQ("What a tutorial! Very instructive tutorial.") {

	? FindAll("tutorial")
	#--> [ 8, 35 ]

	? NumberOfOccurrence("tutorial") + NL
	#--> 2

	? FindNextOccurrence("tutorial", :StartingAt = 20) + NL
	#--> 35

	? FindPreviousOccurrence("tutorial", :StartingAt = 20) + NL
	#--> 8

	? NumberOfChars() + NL
	#--> 43
	 
	? @@( SplitToPartsOfNChars(12) ) + NL
	#--> [
	# 	"What a tutor",
	# 	"ial! Very in",
	# 	"structive tu",
	# 	"torial."
	#    ]

	? @@( SplitBeforePositions([ 17, 34 ]) ) + NL
	#--> [
	# 	"What a tutorial!",
	# 	" Very instructive",
	# 	" tutorial."
	#    ]

	? @@( SplitBeforeCharsWXT(' @char = "a" ') ) + NL
	#--> [
	# 	"Wh", "at ", "a tutori",
	# 	"al! Very instructive tutori", "al."
	#     ]

}

proff()
# Executed in 0.25 second(s).

/*===================

profon()

str = "قَالُوا ادْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا هِيَ إِنَّ الْبَقَرَ 
تَشَابَهَ عَلَيْنَا وَإِنَّا إِن شَاءَ اللَّهُ لَمُهْتَدُونَ (70)
 قَالَ إِنَّهُ يَقُولُ إِنَّهَا بَقَرَةٌ لَّا ذَلُولٌ تُثِيرُ الْأَرْضَ وَلَا
 تَسْقِي الْحَرْثَ مُسَلَّمَةٌ لَّا شِيَةَ فِيهَا ۚ قَالُوا الْآنَ 
جِئْتَ بِالْحَقِّ ۚ فَذَبَحُوهَا وَمَا كَادُوا يَفْعَلُونَ (71)
 وَإِذْ قَتَلْتُمْ نَفْسًا فَادَّارَأْتُمْ فِيهَا ۖ وَاللَّهُ مُخْرِجٌ مَّا كُنتُمْ تَكْتُمُونَ (72)
 فَقُلْنَا اضْرِبُوهُ بِبَعْضِهَا ۚ كَذَٰلِكَ يُحْيِي اللَّهُ 
الْمَوْتَىٰ وَيُرِيكُمْ آيَاتِهِ لَعَلَّكُمْ تَعْقِلُونَ (73)
 ثُمَّ قَسَتْ قُلُوبُكُم مِّن بَعْدِ ذَٰلِكَ فَهِيَ كَالْحِجَارَةِ أَوْ أَشَدُّ قَسْوَةً 
ۚ وَإِنَّ مِنَ الْحِجَارَةِ لَمَا يَتَفَجَّرُ مِنْهُ الْأَنْهَارُ ۚ 
وَإِنَّ مِنْهَا لَمَا يَشَّقَّقُ فَيَخْرُجُ مِنْهُ الْمَاءُ 
ۚ وَإِنَّ مِنْهَا لَمَا يَهْبِطُ مِنْ خَشْيَةِ اللَّهِ ۗ وَمَا اللَّهُ بِغَافِلٍ
 عَمَّا تَعْمَلُونَ (74) ۞ أَفَتَطْمَعُونَ أَن يُؤْمِنُوا لَكُمْ
 وَقَدْ كَانَ فَرِيقٌ مِّنْهُمْ يَسْمَعُونَ كَلَامَ اللَّهِ ثُمَّ يُحَرِّفُونَهُ
 مِن بَعْدِ مَا عَقَلُوهُ وَهُمْ يَعْلَمُونَ (75)
 وَإِذَا لَقُوا الَّذِينَ آمَنُوا قَالُوا آمَنَّا
 وَإِذَا خَلَا بَعْضُهُمْ إِلَىٰ بَعْضٍ قَالُوا أَتُحَدِّثُونَهُم
 بِمَا فَتَحَ اللَّهُ عَلَيْكُمْ لِيُحَاجُّوكُم بِهِ عِندَ رَبِّكُمْ ۚ أَفَلَا تَعْقِلُونَ  (76)  
"

o1 = new stzString(str)

? ShowShort( o1.UniqueChars() ) //+ NL
#o--> [ "ق", "َ", "ا", "...", "ؤ", "5", "6" ]

? len( o1.SplitAt("۞") )
#--> 2

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.17

/*-------------------

profon()

o1 = new stzString(" same   ")
o1 {
	TrimLeft()
	? @@( Content() )
	#--> "same   "

	TrimRight()
	? @@( Content() )
	#--> "same"
}

# Try also: TrimStart(), TrimEnd()
# RemoveLeadingSpaces(), and RemoveTrailingSpaces

proff()
# Executed in 0.02 second(s).

/*==================

profon()

str = "   سلام"
o1 = new stzString(str)

? o1.HasRepeatedLeadingChars()
#--> _TRUE_

? @@( o1.RepeatedLeadingChar() )
#--> " "

o1.TrimRight() ? o1.Content()
#o--> سلام

proff()
# Executed in 0.02 second(s).

/*------------------

profon()

o1 = new stzString("eeeTUNIS")

? o1.RepeatedLeadingChar()
#--> "e"

? o1.RepeatedLeadingChars()
#--> [ "e", "e", "e" ]

? o1.LeadingSubString()
#--> "eee"

proff()
# Executed in 0.01 second(s).

/*------------------

profon()

o1 = new stzString("exeeeeeTUNIS")
 	
? @@( o1.RepeatedLeadingChar() )
#--> ""

? @@( o1.RepeatedLeadingChars() )
#--> ""

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("eeeeTUNISIAiiiii")

o1 {
	? HasRepeatedLeadingChars()
	#--> _TRUE_

	? NumberOfRepeatedLeadingChars()
	#--> 4

	? RepeatedLeadingchars()
	#--> [ "e", "e", "e", "e" ]

	? LeadingSubString()+ NL
	#--> "eeee"
	
	? HasRepeatedTrailingChars()
	#--> _TRUE_

	? NumberOfRepeatedTrailingChars()
	#--> 5

	? RepeatedTrailingChars()
	#--> [ "i", "i", "i", "i", "i" ]

	? TrailingSubString()
	#--> "iiiii"	
}

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("eeebxeTuniseee")
o1 {

	RemoveNLeftChars(3)
	RemoveNRightChars(3)

	# or alternatively:
	# RemoveFirstNChars(3)
	# RemoveLastNChars(3)

	? Content()
	#--> bxeTunis
	
}

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveRepeatedLeadingChars()
	RemoveRepeatedTrailingChars()
	
	? Content()
	#--> Tunis
}

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveLeadingAndTrailingChars()
	? Content()
	#--> Tunis
}

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

o1 = new stzString("eeebxeTuniseee")

? o1.Section(:FirstChar, :LastChar)
#--> eeebxeTuniseee

? o1.Section( 7, 4 )
#--> Texb

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("___VAR---")
o1.ReplaceLeadingChars(:With = "*")
? o1.Content()
#--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChars(:With = "*")
? o1.Content()
#--> ___VAR*

o1 = new stzString("___VAR---")
o1.ReplaceLeadingAndTrailingChars(:With = "*")
? o1.Content()
#--> *VAR*

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingChar(:With = "*")
? o1.Content()
#--> ***VAR---

o1 = new stzString("___VAR---")
o1.ReplaceEachTrailingChar(:With = "*")
? o1.Content()
#--> ___VAR***

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingAndTrailingChar(:With = "*")
? o1.Content()
#--> ***VAR***

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("___VAR---")
o1.ReplaceLeadingChar("_", :With = "*")
? o1.Content()
#--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChar("-", :With = "*")
? o1.Content()
#--> ___VAR*

proff()
# Executed in 0.02 second(s).

/*----------------- TODO (future)

profon()

StzStringQ("eeebxeTuniseee") {
	RemoveRepeatedLeadingCharsW('{
		cChar = "e"
	}')

	RemoveRepeatedLeadingCharsW('{ oChar.IsSpecialChar() }')
	RemoveRepeatedLeadingCharsW('{ oChar.IsPunctuation() }')

	RemoveRepeatedLeadingCharsW('{ nNumberOfLeadingChars = 5 }')
	RemoveRepeatedLeadingCharsW('{ cLeadingSubstring = "<<<" }')
	RemoveRepeatedLeadingCharsW('{ oLeadingSubstring.IsANumber() }')
	
	? Content()
}

proff()

/*----------------

profon()

o1 = new stzString("bbxeTuniseee")

? o1.RepeatedLeadingChars()
#--> [ "b", "b" ]

? o1.LeadingSubString()
#--> "bb"

? o1.HasRepeatedLeadingChars()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("aaaaah Tunisia!---")
o1 {
	ReplaceEachLeadingChar(:With = "O")
	? Content()
	#--> OOOOOh Tunisia!---

	ReplaceEachTrailingChar(:With = "")
	? Content()
	#--> OOOOOh Tunisia!
}

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("---Ring!")
o1.ReplaceFirstNChars(3, :With = "Hi ")
? o1.Content()
#--> Hi Ring!

o1 = new stzString("Hi Ring---")
o1.ReplaceLastNChars(3, :With= "!")
? o1.Content()
#--> Hi Ring!

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("oooo Tunisia---")
o1 {
	ReplaceLeadingChar("o", :With = "Hi")
	? Content()
	#--> Hi Tunisia---

	ReplaceTrailingChar("-", :With = "!")
	? Content()
	#--> Hi Tunisia!
}

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("aaaaah Tunisia---")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oh Tunisia---

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Oh Tunisia!

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("Oooooh TunisiammMmmM")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oooooh TunisiammmmM

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Aaaaah TunisiammmmM

o1 = new stzString("Oooooh TunisiammMmmM")
o1.ReplaceLeadingCharsCS(:With = "O", :CaseSensitive = _FALSE_)
? o1.Content()
#--> Oh TunisiammmmM

o1.ReplaceTrailingCharsCS(:With = "!", :CaseSensitive = _FALSE_)
? o1.Content()
#--> Oh Tunisia!

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("Oooo Tunisia---")

? o1.HasLeadingChars()
#--> _FALSE_

? @@( o1.LeadingChar() )
#--> ""

? o1.HasLeadingCharsCS(_FALSE_)
#--> _TRUE_

? o1.LeadingCharCS(:CS = _FALSE_)
#--> "O"

? @@( o1.LeadingChars()	)
#--> []

? o1.LeadingCharsCS(:CS=FALSE)
#--> [ "O", "o", "o", "o" ]

? o1.LeadingSubStringCS(_FALSE_)
#--> "Oooo"

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("oooTunisia")
o1.RemoveThisLeadingChar("O")
? o1.Content()
#--> oooTunisia

o1.RemoveThisLeadingCharCS("O", :CS=FALSE)
? o1.Content()
#--> Tunisia

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("oooTunisia")
o1.ReplaceLeadingChar("O", :With = "")
? o1.Content()
#--> oooTunisia

o1.ReplaceLeadingCharCS("O", :With = "", :CS=FALSE)
? o1.Content()
#--> Tunisia

proff()
# Executed in 0.02 second(s).

/*==================

profon()

? Q("A") * [ "1", "2", "3" ]
#--> A1A2A3

proff()

/*-----------

profon()

? Q("ORingoriaLand") - [ "O", "oria", "Land" ]
#--> Ring

? ( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).content()
#--> Ring

proff()
# Executed in 0.01 second(s).

/*==================

profon()

? StzStringQ("[ 2, 3, 5:7 ]").IsListInString()
#--> _TRUE_

? StzStringQ("'A':'F'").IsListInString()
#--> _TRUE_

proff()
# Executed in 0.04 second(s).

/*==================

profon()

o1 = new stzstring("123456789")
? o1.Section(4,6)
#--> "456"

proff()

/*-------------

profon()

o1 = new stzstring("123456789")
o1.ReplaceSection(4, 6, :with = "***")
? o1.Content()
#--> "123***789"

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAll("Tunis", "Niamey" )
	? Content()
}
#--> Niamey is the town of my memories.

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAllCS("TUNIS", "Niamey", :CS = _FALSE_ )
	? Content()
}
#--> Niamey is the town of my memories

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

StzStringQ( "a + b - c / d = 0" ) {
	ReplaceMany( [ "+", "-", "/" ], "*" )
	? Content()
}
#--> a * b * c * d = 0

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

StzStringQ("Tunisia is back! People united.") {

	ReplaceAll("People", "Tunisians")
	? Content() + NL
	#--> Tunisia is back! Tunisians united.

	? Section(3, 7)
	#--> nisia

	? Section(7, 3) + NL
	#--> nisia

	? Section(:From = 3, :To = :EndOfWord)
	#--> nisia

	? Section(:From = 12, :To = :EndOfWord) + NL
	#--> back!

	? Section(:From = 9, :To = :EndOfSentence) + NL
	#--> is back! Tunisians united.

	? Section(:From = :FirstChar, :To = :EndOfString) + NL
	#--> Tunisia is back! Tunisians united.

	ReplaceFirst("Tunisia", :With = "Egypt") 
	Replace( "Tunisians", :With = "Egyptians")
	? Content()
	#--> Egypt is back! Egyptians united.

}

proff()
# Executed in 0.06 second(s).

/*----------------

profon()

o1 = new stzString("this text is my text not your text, right?!")
? o1.FindAllCS("text", :CaseSensitive = _FALSE_)
#--> [6, 17, 31]

? o1.FindNthOccurrence(2, "Text")
#--> 0

? o1.FindNthOccurrenceCS(2, "Text", :CaseSensitive = _FALSE_)
#--> 17

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("This text is my text not your text, right?!")

? o1.ReplaceNthOccurrenceCSQ(2, "TEXT", :With = "narration", :Casesensitive = _FALSE_).Content()
#--> This text is my narration not your text, right?!

o1 = new stzString("هذا نصّ لا يشبه أيّ نصّ ويا له من نصّ يا صديقي")
? o1.FindAll("نصّ")
#--> [5, 21, 35]

? o1.FindFirst("نصّ")
#--> 5
? o1.FindLast("نصّ")
#--> 35

proff()
# Executed in 0.01 second(s).

/*---------------

profon()

o1 = new stzString("LandRingoriaLand")
o1.RemoveFirstOccurrence( :Of = "Land")
? o1.Content()
#--> RingoriaLand

proff()
# Executed in 0.01 second(s).

/*---------------

profon()

o1 = new stzString("RingoriaLandLand")
? o1 - "Land"
#--> Ringoria

proff()
# Executed in 0.01 second(s).

/*--------------- TODO: Maybe this should move to stzText

profon()

o1 = new stzString("ring language isسلام  a nice language")

? o1.Orientation()
#--> :LeftToRight

? o1.ContainsHybridOrientation()
#--> _TRUE_

#---

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")

? o1.Orientation()
#--> :RightToLeft

? o1.ContainsHybridOrientation()
#--> _TRUE_

proff()
# Executed in 0.09 second(s).

/*----------------

profon()

o1 = new stzString("ring language isسلام  a nice language")

? @@( o1.PartsUsingXT( 'StzCharQ(@char).Orientation()') ) + NL
#--> [ "ring language is", "سلام", "  a nice language" ]

? @@( o1.Parts2UsingXT( 'StzCharQ(@char).Orientation()') ) + NL
#--> [
#	[ "ring language is", "lefttoright" ],
#o	[ "سلام", "righttoleft" ],
#	[ "  a nice language", "lefttoright" ]
# ]

#---

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")

? @@( o1.PartsUsingXT( 'StzCharQ(@char).Orientation()') ) + NL #TODO // add PartitionBy() and PartionedBy()
#o--> [ "سلام", " ", "عليكم", " ", "ياأهل", " ", "مصر", " hello ", "الكرام" ]

? @@( o1.Parts2UsingXT( 'StzCharQ(@char).Orientation()') )
#o--> [
#o	[ "سلام", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "عليكم", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "ياأهل", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "مصر", "righttoleft" ],
#	[ " hello ", "lefttoright" ],
#o	[ "الكرام", "righttoleft" ]
# ]

proff()
# Executed in 0.88 second(s).

/*----------------

profon()

o1 = new stzString("سلام لأهل مصر الكرام")
o1.RemoveNLeftChars(7)
? o1.Content()
o#--> سلام لأهل مصر

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("ring language is nice language")

? o1.NLastCharsRemoved(9)
#--> ring language is nice

? o1.SectionQ(1,4).CharsReversed()
#--> ɹᴉnᵷ

proff()
# Executed in 0.06 second(s).

/*----------------

profon()

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveAllQ("<<script>>").Content()
#--> "func return :done"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveLeftOccurrenceQ("<<script>>").Content()
#--> "func return :done<<script>>"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveRightOccurrenceQ("<<script>>").Content()
#--> "<<script>>func return :done"

o1.RemoveNFirstChars(10)
? o1.Content()
#--> "func return :done"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17

/*----------------

profon()

o1 = new stzString("Softanza loves simplicity")
? o1.ReplaceFirstQ( o1.Section(10, :LastChar), "arrives!").Content()
#--> "Softanza arrives!"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17

/*----------------

profon()

o1 = new stzString("<script>func return :done<script/>")
? o1.IsBoundedBy(["<script>", :And = "<script/>"])
#--> _TRUE_

o1.RemoveTheseBounds("<script>", "<script/>")
? o1.Content()
#--> "func return :done"

proff()
# Executed in 0.03 second(s) in Ring 1.14
# Executed in 0.14 second(s) in Ring 1.17

/*----------------

profon()

? StzStringQ("{nnnnn}").IsBoundedBy(["{","}"])
#--> _TRUE_

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.IsBoundedBy(["بسم", "الرّحيم"])
#--> _TRUE_

proff()
# Executed in 0.01 second(s)

/*----------------

profon()

o1 = new stzString("بسم الله الرّحمن الرّحيم")

? @@( o1.FindTheseBounds("بسم", "الرّحيم") )
#--> [ 1, 18 ]

? @@( o1.FindBoundedBy([ "بسم", "الرّحيم" ]) ) + NL
#--> [ 4 ]

#--

? @@( o1.FindTheseBoundsZZ("بسم", "الرّحيم") )
#--> [ [ 1, 3 ], [ 18, 24 ] ]

? @@( o1.FindBoundedByZZ([ "بسم", "الرّحيم" ]) )
#--> [ [ 4, 17 ] ]

proff()
# Executed in 0.01 second(s).

/*=================

profon()

o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceQ("xo", "ng").Content()
#--> Ring Ring Ring

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("Ringos Ringos Ringos")
o1.RemoveAll("os")
? o1.Content()
#--> Ring Ring Ring

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("extrasection")
o1.RemoveSectionQ(6, :LastChar)
? o1.Content()
#--> extra

proff()
# Executed in 0.01 second(s).

/*----------------

profon()

o1 = new stzString("extrasection")
o1.RemoveRange(1, 5)
? o1.Content()
#--> section

proff()
# Executed in 0.01 second(s).

/*=======================

profon()

? Q("SFOTANZA").AlignedXT( :Width = 30, :Char= ".", :Direction = :Center )
#--> ...........SFOTANZA...........

proff()
# Executed in 0.02 second(s).

/*-----------------------

profon()

? StringAlignXT("SOFTANZA", 30, ".", :Left)
? StringAlignXT("SOFTANZA", 30, ".", :Right)
? StringAlignXT("SOFTANZA", 30, ".", :Center)
? StringAlignXT("SOFTANZA", 30, ".", :Justified) + NL

#-->
# SOFTANZA......................
# ......................SOFTANZA
# ...........SOFTANZA...........
# S....O...F...T...A...N...Z...A

proff()
# Executed in 0.05 second(s).

/*----------------

profon()

str = "منصوريّات"
? StringAlignXT(str, 30, ".", :Left)
? StringAlignXT(str, 30, ".", :Right)
? StringAlignXT(str, 30, ".", :Center)
? StringAlignXT(str, 30, ".", :Justified)

#-->
# ......................منصوريّات
# منصوريّات......................
# ...........منصوريّات...........
# م....ن...ص...و...ر...يّ...ا...ت

proff()
# Executed in 0.05 second(s).

/*==================

profon()

o1 = new stzString("مَنْصُورِيَّاتُُ")

? o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*==================

profon()

o1 = new stzString("ABCDEFGH")
o1.CompressUsingBinary("10011011")
? o1.Content()
 #--> ADEGH

proff()
# Executed in 0.01 second(s).

/*==================

profon()

o1 = new stzString("aabbcaacccbb")

? o1.IsMadeOf([ "aa", "bb", "c" ])
#--> _TRUE_

? o1.IsMadeOfSome([ "a", "b", "c", "x" ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*------------------

profon()

o1 = new stzString("سلسبيل")

? o1.IsMadeOf([ "ب", "ل", "س", "ي" ])
#--> _TRUE_

? o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ])
#--> _FALSE_

? o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*==================

profon()

o1 = new stzSplitter(10)

? @@( o1.GetPairsFromPositions([ 1, 3, 8 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 10 ] ]

proff()

/*-----------------

profon()

o1 = new stzSplitter(12)

? @@( o1.GetPairsFromPositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ], [ 10, 12 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 12 ] ]

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

#                   1.3....8.0..
o1 = new stzString("NoWomanNoCry")

anPos = o1.FindCharsWXT( :Where = 'Q(@char).IsUppercase()')

? @@(anPos)
#--> [ 1, 3, 8, 10 ]

? o1.SplitBeforePositions(anPos)
#--> [ "No", "Woman", "No", "Cry" ]

proff()
# Executed in 0.23 second(s).

/*------------------

profon()

o1 = new stzString("NoWomanNoCry")
? o1.SplitBeforeCharsWXT(:Where = 'Q(@char).IsUppercase()')
#--> [ "No", "Woman", "No", "Cry" ]

proff()
# Executed in 0.19 second(s) in Ring 1.22

/*==================

profon()

o1 = new stzString("Ring programming language")

anPos = o1.Find("in")
? anPos
#--> [ 2, 14 ]

o1.InsertBeforePositions(anPos, "_")
? o1.Content()
#--> R_ing programm_ing language

proff()
# R_ing programm_ing language

/*------

profon()

o1 = new stzString("Ring language")

o1.InsertBefore("language", "programming ")
? o1.Content()
# Ring programming language

proff()
# Executed in 0.01 second(s) in Ring 1.22

*------

profon()

o1 = new stzString("Ring language")

o1.InsertAfter("Ring", " programming")
? o1.Content()
# Ring programming language

proff()
# Executed in 0.01 second(s) in Ring 1.22

proff()
# Executed in 0.09 second(s).

/*-------------------

profon()

o1 = new stzString("Hi Dan! You are Dan, but your work is never done! 😉")
o1.ReplaceNthOccurrence(2, "Dan", "hardworker")

? o1.Content()
#--> Hi Dan! You are hardworker, but your work is never done! 😉

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("text this text is written with the text of my scrampy text")

? o1.FindAll("text")
#--> [ 1, 11, 36, 55 ]

? o1.FindNthOccurrence(4, :Of = "text") + NL
#--> 55

? o1.ContainsNtimes(4, "text")
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*================== STRING COMPARAISON

profon()

o1 = new stzString("reserve")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = _FALSE_ )
#--> :Equal

o1 = new stzString("réservé")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = _FALSE_ )
#--> :Greater

o1 = new stzString("reserv")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = _FALSE_ )
#--> :Less

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("RÉSERVÉ")

? o1.UnicodeCompareWithInSystemLocale("réservé")
#--> :Greater

//? o1.UnicodeCompareWithInLocale("réservé", "fr-FR")	#TODO

proff()
# Executed in 0.01 second(s).

/*==================

profon()

o1 = new stzString("  lots   of    whitespace  ")

? o1.Trimmed()
#--> "lots   of    whitespace"

? o1.SimplifyQ().UPPERcased()
#--> "LOTS OF WHITESPACE"

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
o1.ReplaceAll("فلانة", "فلسطين")
? o1.Content()
o#--> اسمي هو فلسطين، قلت لك فلسطين! أوَ لم يعجبك أن يكون اسمي فلسطين؟

proff()
# Executed in 0.01 second(s).

/*--------------------

profon()

o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
"Où bien tu n'aimes pas que ce soit Foulèna?")

o1.ReplaceAll("Foulèna", "Tiba")
? o1.Content()

#--> "Mon prénom c'est Tiba. J'ai bien dit Tiba! Où bien tu n'aimes pas que ce soit Tiba?"

proff()
# Executed in 0.01 second(s).

/*======================

profon()

o1 = new stzString("0o20723.034")
o1 {
	? RepresentsNumber()			#--> _TRUE_
	? RepresentsSignedNumber()		#--> _FALSE_
	? RepresentsUnsignedNumber()		#--> _TRUE_
	? RepresentsCalculableNumber() + NL	#--> _TRUE_
	
	? RepresentsInteger()			#--> _FALSE_
	? RepresentsSignedInteger()		#--> _FALSE_
	? RepresentsUnsignedInteger()		#--> _FALSE_
	? RepresentsCalculableInteger()	 + NL	#--> _FALSE_
	
	? RepresentsRealNumber()		#--> _TRUE_
	? RepresentsSignedRealNumber()		#--> _FALSE_
	? RepresentsUnsignedRealNumber()	#--> _TRUE_
	? RepresentsCalculableRealNumber() + NL	#--> _TRUE_
	
	? RepresentsNumberInDecimalForm()	#--> _FALSE_
	? RepresentsNumberInBinaryForm()	#--> _FALSE_
	? RepresentsNumberInHexForm()		#--> _FALSE_
	? RepresentsNumberInOctalForm()		#--> _TRUE_
}

proff()
# Executed in 0.16 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("12500543.12")
? o1.RepresentsRealNumber()
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> _TRUE_

o1 = new stzString("-0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> _TRUE_

o1 = new stzString("0b-110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> _FALSE_

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("0x12_5AB34.123F")

? o1.RepresentsNumber()
#--> _TRUE_

? o1.NumberForm()
#--> :Hex

? o1.RepresentsNumberInHexForm() + NL
#--> _TRUE_

#--

o1 = new stzString("0o2304.307")

? o1.RepresentsNumber()
#--> _TRUE_

? o1.NumberForm()
#--> :Octal

? o1.RepresentsNumberInOctalForm()
#--> _TRUE_

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*=================== #narration INSERTING LISTS INSIDE A STRING

profon()

# In the following example, we'll demonstrate how to use
# InsertSubstringsXT to insert a list of software versions into
# a sentence, complete with proper formatting, separators, and
# surrounding characters.

# Create a new stzString object with the initial text

o1 = new stzString("All our software versions must be updated!")

# Find the position right after the word "versions" in the string
# This is where we'll insert our list of version numbers

nPosition = o1.PositionAfter("versions")

# Use InsertSubstringsXT method to insert a formatted list of versions
# The result showcases how InsertSubstringsXT can create a
# well-formatted list within our original string, complete with
# proper punctuation, separators, and surrounding characters.

o1.InsertSubstringsXT(
	nPosition,
	
	# The list of version numbers to be inserted

	[ "V1", "V2", "V3", "V4", "V5" ],
	
	[
		# Insert the list before the found position

		:InsertBeforeOrAfter = :Before,
		
		# Define the opening and closing characters for the list

		:OpeningChar = "{ ",
		:ClosingChar = " }",
		
		# Set the main separator between list items

		:MainSeparator = ",",

		# Add a space after each separator for readability

		:AddSpaceAfterSeparator = _TRUE_,
		
		# Use "and" as the separator before the last item

		:LastSeparator = "and",

		# Combine the last separator with the main one (", and")

		:AddLastToMainSeparator = _TRUE_,
		
		# Add spaces around the entire inserted list

		:SpaceOption = :AddLeadingSpace //+ :AddTrailingSpace
	]
)

# Print the final result to see the formatted string
? o1.Content()
#--> All our software versions { V1, V2, V3, V4, and V5 } must be updated!

proff()
# Executed in 0.02 second(s).

/*-------------------

profon()

# You can use the simple form of InsertSubStrings() without ..XT and
# get default configurations that works:

o1 = new stzString("All our software versions must be updated!")
o1.InsertSubStrings( o1.PositionAfter("versions"), [ "V1", "V2", "V3" ])
? o1.Content()
#--> All our software versions (V1, V2, V3)  must be updated!

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

# You can use InsertSubStringsXT() with just the configurations you want:

o1 = new stzString("All our software versions must be updated!")
o1.InsertSubStringsXT(
	o1.PositionAfter("versions"),
	[ " V1", "V2", "V3" ],
	[ :MainSeparator = "+" ]
)
? o1.Content()
#--> All our software versions V1+V2+V3 must be updated!

proff()
# Executed in 0.02 second(s).

/*===================

profon()

o1 = new stzString("latin")
? o1.IsScriptName()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*------------------

profon()

o1 = new stzString("ar-tn")
? o1.IsLocaleAbbreviation()
#--> _TRUE_

o1 = new stzString("ar-fr")
? o1.IsLocaleAbbreviation()
#--> _FALSE_

o1 = new stzString("tn-fr")
? o1.IsLocaleAbbreviation()
#--> _FALSE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*------------------ #qt

profon()

@oQLocale = new QLocale("ar-tn")
? @oQLocale.name()
#--> ar_TN

proff()
# Executed in almost 0 second(s).


/*------------------

profon()

o1 = new stzLocale("ar-Arab") # Default arabi country is egypr
? o1.CountryName()
#--> egypt

o1 = new stzLocale("AR-Arab-tn")
? o1.CountryName()
#--> tunisia

o1 = new stzLocale("AR-tn")
? o1.CountryName()
#--> tunisia

o1 = new stzLocale("TN-Arab") # TN here means the TswaNa language in South Africa!
? o1.CountryName()
#--> south_africa

? o1.Langauge()
#--> tswana

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("fr")
? o1.IsLocaleAbbreviation()
#--> _FALSE_

o1 = new stzString("fr-fr")
? o1.IsLocaleAbbreviation()
#--> _TRUE_

? StzLocaleQ("fr-fr").Country()
# france

proff()
# Executed in 0.02 second(s).

/*------------------

profon()

o1 = new stzString("105")
? o1.IsLanguageNumber()
#--> _TRUE_

? StzLanguageQ("105").Name()
#--> sindhi

? StzLanguageQ("105").DefaultCountry()
#--> pakistan

proff()
# Executed in 0.01 second(s).

/*------------------

profon()

o1 = new stzString("ara")
? o1.IsLanguageAbbreviation()
#--> _TRUE_

? o1.IsShortLanguageAbbreviation()
#--> _FALSE_

? o1.IsLongLanguageAbbreviation()
#--> _TRUE_

? o1.LanguageAbbreviationForm()
#--> long

proff()
# Executed in 0.02 second(s).

/*------------------

profon()

o1 = new stzString("Ⅱ")
? o1.IsLatin()
#--> _TRUE_

o1 = new stzChar("Ⅱ")
? o1.IsRomanNumber()
#--> _TRUE_

proff()
# Executed in 0.04 second(s).

/*============== #qt

profon()

# How to add a string to a QString objet (Qt-side)
# Used internally by Softanza

oQStr = new QString2() #NOTE // QString2() is more performant then QString()
oQStr.append("salem")
? QStringToString(oQStr)

proff()
# Executed in almost 0 second(s).

/*===============

profon()

o1 = new stzString("10011033001")

? o1.IsMadeOf([ "1", "0", "3" ])
#--> _TRUE_

? o1.IsMadeOf([ "1", "0", :and = "3" ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------------

profon()

o1 = new stzString("01234567")
? o1.IsMadeOfSome( OctalChars() )
#--> _TRUE_

o1 = new stzString("001100101")
? o1.IsMadeOf( BinaryChars() )
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("o01234567")
? o1.RepresentsNumberInOctalForm()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("4E992")
? o1.IsMadeOfSome( HexChars() )
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("x4E992")
? o1.RepresentsNumberInHexForm()
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------------

profon()

o1 = new stzString("maan")
? o1.IsMadeOf([ "m", "a", "a", "n" ])
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------------- #narration INTERNAL IMPLEMENTATION OF UNICODE() FUNCTION

profon()

# In Softanza you get the unicode number of a char by saying:

? Unicode("鶊")
#--> 40330

# Once you have the code, you can pass it as an imput to a stzChar
# char object to get the char:

? StzCharQ(40330).Content()
#--> 鶊

# Qt is used internally to get the Unicode code, but many steps
# are necessary. Curious to know how I made it?

# First I created the QChar from whatever a decimal unicode could be:

oChar = new QChar(40220) # the char "鴜" coded on 3 bytes

# Second, I created a QString from that QChar

oStr = new QString2()
oStr.append_2(oChar)

# Third, I used toUtf8() on QString to get a QByteArray as a result,
# and then we call data() method on it to get the string with our "鴜"

? oStr.ToUtf8().data()
#--> 鶊

# As you see, Softanza leverages the power of Qt, but makes hudge efforts
# to simplify its use and unify it in a freindly mental model.

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------------

profon()

o1 = new stzString("abcbbaccbtttx")
? @@( o1.UniqueChars() )
#--> [ "a", "b", "c", "t", "x" ]

? o1.ContainsNOccurrences(2, :Of = "a")
#--> _TRUE_

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------------

profon()

o1 = new stzString("saस्तेb")
? o1.NumberOfChars()
#--> 7

? @@( o1.Unicodes() )
#--> [ 115, 97, 2360, 2381, 2340, 2375, 98 ]

? @@( o1.UnicodesXT() )
#--> [ [ 115, "s" ], [ 97, "a" ], [ 2360, "स" ], [ 2381, "्" ], [ 2340, "त" ], [ 2375, "े" ], [ 98, "b" ] ]

? @@( o1.CharsAndTheirUnicodes() )
#--> [ [ "s", 115 ], [ "a", 97 ], [ "स", 2360 ], [ "्", 2381 ], [ "त", 2340 ], [ "े", 2375 ], [ "b", 98 ] ]

proff()
# Executed in 0.03 second(s).

/*---------------

profon()

o1 = new stzString("number 12500 number 18200")
? o1.OnlyNumbers()
#--> "1250018200"

proff()
# Executed in 0.06 second(s).

/*================

profon()

o1 = new stzString("12500")
? o1.RepresentsNumberInDecimalForm()
#--> _TRUE_

o1 = new stzString("b100011")
? o1.RepresentsNumberInBinaryForm()
#--> _TRUE_

o1 = new stzString("100011") # Without the b, it's rather a decimal not binary number!
? o1.RepresentsNumberInBinaryForm()
#--> _FALSE_

o1 = new stzString("100011")
? o1.RepresentsNumberInDecimalForm()
#--> _TRUE_

proff()
# Executed in 0.02 second(s).

/*--------------- #todo Write a narration about it

profon()

o1 = new stzString("Приве́т नमस्ते שָׁלוֹם")

? @@( o1.PartsUsingXT( "StzCharQ(@char).Script()" ) ) + NL

? @@NL( o1.Parts2UsingXT( "StzCharQ(@char).Script()" ) ) + NL
#--> [
# 	[ "Приве", "cyrillic" 	],
# 	[ "́", 	   "inherited" 	],
# 	[ "т",     "cyrillic" 	],
# 	[ " ",     "common" 	], 
#	[ "नमस्ते",         "devanagari" ],
# 	[ " ",     "common" 	],
#o 	[ "שָׁלוֹם", "hebrew" 	]
# ]

? @@( o1.PartsWXT('{
	StzCharQ(@char).Script() = :Cyrillic
}') )
#--> [ "Приве", "́", "т", " नमस्ते שָׁלוֹם" ]

proff()
# Executed in 0.45 second(s) in Ring 1.22
# Executed in 0.58 second(s) in Ring 1.20

/*---------------

profon()

o1 = new QString2()
o1.append("M")
? o1.size()
#--> 1

o1 = new QString2()
o1.append("🐨")
? o1.count()
#--> 2

o1 = new QString2()
o1.append("🐨")
? o1.size()
#--> 2

proff()
# Executed in almost 0 second(s).

/*--------------- #todo write a narration about it

profon()

o1 = new stzString("🐨")

? o1.SizeInBytes()
#--> 491

? @@SP( o1.SizeInBytesXT() )
#--> [
#	[ "RING_64BIT_LIST_STRUCTURE_SIZE", 80 ],
#	[ "RING_64BIT_ITEM_STRUCTURE_SIZE * 7", 168 ],
#	[ "RING_64BIT_ITEMS_STRUCTURE_SIZE * 7", 224 ],
#	[ "RING_64BIT_ITEMS_CONTENT_SIZE", 19 ]
# ]

proff()
# Executed in 0.06 second(s).

/*---------------

profon()

? Q('[1, 2, 3]').ToList()
#--> [1, 2, 3]

proff()
# Executed in 0.01 second(s).

/*=============

profon()

? Heart()
#--> "♥"

? Smile()
#--> "😆"

? Handshake()
#--> "🤝"

? Sun()
#--> "🌞"

? Star()
#--> "★"

? CheckMark()
#--> "✓"

? Dot()
#--> "•"

? Flower()
#--> "✤"

proff()
# Executed in almost 0 second(s).

/*================

profon()

StzStringQ("MustHave@32@Chars") {

	? NumberOfOccurrenceCS(:Of = "@", _TRUE_) #--> 2
	? FindAll("@") #--> [9, 12]

	? FindNext("@", :StartingAt = 5) #--> 9
	? FindNextNth(2, "@", :StartingAt = 5) #--> 12

	? FindPrevious("@", :StartingAt = 10) #--> 9
	? FindPreviousNth(2, "@", :StartingAt = 12) #--> 9
}

proff()
# Executed in 0.02 second(s).

/*---------------- Used to enable constraint-oriented programming

profon()

o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
? o1.SubstringsBoundedBy("@") #--> ["32", "CharsAnd", "8" ]

o1 = new stzString("MustHave32CharsAnd8Spaces")
? @@( o1.SubstringsBoundedBy("@") ) #--> [ ]

proff()
# Executed in 0.01 second(s).

/*======== REMOVE XT ================= #todo Write a #narration

StartProfiler()
	
	o1 = new stzString("Ring programming♥ language")
	o1.RemoveXT("♥", :From = "programming♥")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.01 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Each = "*", :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.01 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring (progr(amming) language")
	o1.RemoveXT( :Nth = [ 2, "(" ], :From = "(progr(amming)")
	
	? o1.Content()
	#--> Ring (programming) language
	
StopProfiler()
# Executed in 0.01 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring mprogramming language")
	o1.RemoveXT( :First = "m", :From = "mprogramming")
	
	? o1.Content()
	#--> Ring progr*amming* language
	
StopProfiler()
# Executed in 0.01 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring programmingm language")
	o1.RemoveXT( :Last = "m", :From = "programmingm")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.01 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1, 3], "*" ], :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring progr*amming language
	
StopProfiler()
# Executed in 0.02 second(s)

/*==---------

StartProfiler()
	
	o1 = new stzString("programming*")
	o1.RemoveFromEnd("*")
	? o1.Content()
	#--> programming

StopProfiler()
# Executed in 0.01 second(s)

/*======== REMOVING AFTER
*
StartProfiler()
	
Q("Ring programming* language.") {
	
	RemoveXT("*", :After = "programming")
	? Content()
	#--> Ring programming language.	
}
	
StopProfiler()
#--> Executed in 0.02 second(s)
	
/*-----------

StartProfiler()
	
Q("__♥)__♥)__♥)__") {
	
	RemoveXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*-----------

StartProfiler()
	
Q("__♥__♥)__♥__") {
	
	RemoveXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__
	
}
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥)__♥__♥__") {

	RemoveXT( ")", :AfterFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.03 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥__♥__♥)__") {
	
	RemoveXT( ")", :AfterLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.04 second(s)

/*========== REMOVING BEFORE

StartProfiler()
	
Q("Ring ***programming language.") {
	
	RemoveXT("***", :Before = "programming")
	? Content()
	#--> Ring programming language.
	
}
	
StopProfiler()
#--> Executed in 0.04 second(s)
	
/*-----------

StartProfiler()
	
Q("__(♥__(♥__(♥__") {

	RemoveXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.04 second(s)
	
/*-----------

StartProfiler()
	
Q("__♥__(♥__♥__") {
	
	RemoveXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__

}
	
StopProfiler()
# Executed in 0.04 second(s)
	
/*-----------------

StartProfiler()
	
Q("__(♥__♥__♥__") {

	RemoveXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.05 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥__♥__(♥__") {
	
	RemoveXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.05 second(s)
	
/*------- REMOVING AROUND

StartProfiler()
	
Q("_-♥-_-♥-_-♥-_") {
	
	RemoveXT("-", :AroundEach = "♥") # Or simply :Around
	? Content()
	#--> _♥_♥_♥_
}
	
StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()
	
Q("__/♥\__/♥\__/♥\__") {
	
	RemoveXT([ "/","\" ], :Around = "♥") # or just :AroundEach = "♥" if you want
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()
	
Q("__♥__/♥\__♥__") {

	RemoveXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.07 second(s)

/*-----------------

StartProfiler()
	
Q("__/♥\__♥__♥__") {
	
	RemoveXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.10 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥__♥__/♥\__") {
	
	RemoveXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.10 second(s)

/*---------

StartProfiler()

	Q("/♥♥♥\__/\/\__/♥♥♥\__") {
		RemoveXT("♥♥♥", :BoundedBy = [ "/", :And = "\" ])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.12 second(s).

/*---------

StartProfiler()

	Q("__/\/\__/♥\__") {
		RemoveXT("♥", :BoundedByIB = ["/", "\"]) # IB -> Bounds are also removed
		? Content()
		#--> __/\/\____
	}

StopProfiler()
# Executed in 0.10 second(s).

/*---------

profon()

o1 = new stzString("__^^^__^^♥^^__")
o1.RemoveSubStringBoundedBy("♥", "^^")
? o1.Content()
#--> __^^^__^^^^__

proff()
# Executed in 0.03 second(s).

/*---------

StartProfiler()

	Q("__^^^__^^♥^^__") {
		RemoveXT("♥", :BoundedBy = "^^")
		? Content()
		#--> __^^^__^^^^__
	}

StopProfiler()
# Executed in 0.09 second(s)

/*---------

StartProfiler()

	Q("__/\/\__^^♥^^__") {
		RemoveXT("♥", :BoundedByIB = "^^")
		? Content()
		#--> __/\/\____
	}

StopProfiler()
# Executed in 0.10 second(s)

/*---------

StartProfiler()

	Q("/♥♥♥\__/♥\/♥♥\__/♥\__") {
		RemoveXT("♥", [])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.01 second(s)

/*---------

StartProfiler()

	Q("/♥♥♥\__/♥\/♥♥\__/♥\__") {
		RemoveXT([], "♥")
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.01 second(s)

/*---------

StartProfiler()

	Q("_/♥\_/♥\_/♥♥\_/♥\_") {
		RemoveXT(:Nth = 4, "♥")
		? Content()
		#--> _/♥\_/♥\_/♥\_/♥\_
	}

StopProfiler()
# Executed in 0.01 second(s)

/*---------

StartProfiler()

	Q("^^♥^^") {
		RemoveXT( "♥", :AtPosition = 3)
		? Content()
		#--> ^^^^
	}

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

/*---------

StartProfiler()

	Q("♥^^♥^^♥") {
		RemoveXT( "♥", :AtPositions = [1, 7]) # or :At = [1, 7]
		? Content()
		#--> ^^♥^^
	}

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19


/*=========== string comparaision logic in stzString

profon()

? Q("sam") < "samira"
#--> _TRUE_

? Q("samira") > "ira"
#--> _TRUE_

? Q("qam") = "sam"
#--> _FALSE_

? Q("QAM") = "qam"
#--> _FALSE_

proff()
# Executed in 0.02 second(s)

/*==================

profon()

o1 = new stzString("123SOFTANZA12345")

o1.RemoveNCharsLeft(3)
? o1.Content()
#--> SOFTANZA12345

o1.RemoveNCharsRight(5)
? o1.Content()
#--> SOFTANZA

proff()
# Executed in 0.01 second(s).

/*================== vizFind

profon()

? IsHashList([ [ "positionchar", "^" ] ])
#--> _TRUE_

proff()
# Executed in almost 0 second(s).

/*----------------

profon()

? StzStringQ("ABTCADNBBABEFACCC").VizFind("A")
#--> 
#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^---

proff()
# Executed in 0.06 second(s).

/*==================

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxedXT([
	[ "line", "thin" ],
	[ "eachchar", 1 ],
	[ "allcorners", "" ],
	[ "corners", "" ]
])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzString("RING")

? o1.BoxEachCharQ().Content()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.Content()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

? Q("RING").CharsBoxed()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.BoxifyChars()
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.BoxifyCharsXT([])
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzListOfChars(@Chars("SOFTANZA~RING"))
? o1.BoxifiedRounded()
#-->s
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzListOfChars([ "S", "O", "F", "T", "A", "N", "Z", "A" ])
? o1.BoxifiedXT([ :Round = _TRUE_ ])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴───┴───┴───┴───╯

? o1.BoxifiedXT([ :Corners = [ :Round, :Rect, :Round, :Rect ] ])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───╯

proff()
# Executed in 0.04 second(s).

/*-----------------

profon()

o1 = new stzlist([ "R", "I", "N", "G" ])
? o1.FindMany([ "R", "I", "N", "G" ])
#--> [ 1, 2, 3, 4 ]

proff()
# Executed in almost 0 second(s).

/*-----------------

profon()

o1 = new stzString("--R--I--N--G--")
? o1.FindMany([ "R", "I", "N", "G" ])
#--> [ 3, 6, 9, 12 ]

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxXT([ :Rounded, :Hilight = [ 1, 4 ], :NumberedXT ])

proff()

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxifyXT([ :Rounded, :Hilight = [ 1, 4 ], :Numbered ])

proff()
# Executed in 0.07 second(s).

/*-----------------

profon()

o1 = new stzString("Hello dear!")
o1.InsertBefore("my ", "dear")
? o1.Content()
# Hello my dear!

o1.InsertAfter(" friend", "dear")
? o1.Content()
# Hello my dear friend!

proff()
# Executed in 0.01 second(s).

/*==============

profon()

Q("Softanza is awosme!") {

	Replace("awosme", :with = "wonderful")
	? content()
	#--> Softanza is wonderful!

	Undo()
	? Content()
	#--> Softanza is awosme!

	Redo()
	? Content()
	#--> Softanza is wonderful!

	InsertXT("really ", :Before = "wonderful")
	? Content()
	#--> Softanza is really wonderful!

	Undo()
	? Content()
	#--> Softanza is wonderful!
}

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

o1 = new stzString("--*--*--*--")
o1.ReplaceByMany("*", [ "ONE", "TWO", :And = "THREE" ])
? o1.Content()

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
o1.ReplaceOccurrences([ 2, :and = 3 ], :of = "[...]", :by = [ "ONE", :and = "TWO"])
? o1.Content()
#--> --[...]---ONE---TWO---[~~~]--[~~~]--

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzList([ "ONE", "TWO", "TWO", "ONE", "THREE", "ONE", "THREE" ])
? @@NL( o1.SectionsOfSameItems() )
#--> [
#	[ "ONE", "ONE", "ONE" ],
#	[ "TWO", "TWO" ],
#	[ "THREE" ]
# ]

proff()
# Executed in almost 0 second(s).

/*-----------------

profon()

? @@SP( Q([ "[...]", "[...]", "[~~~]", "[~~~]" ]).SectionsOfSameItems() )
#--> [
#	[ "[...]", "[...]" ],
#	[ "[~~~]", "[~~~]" ]
# ]

proff()
# Executed in almost 0 second(s).

/*-----------------

profon()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
o1.ReplaceSubStringAtPositionsByMany([ 27, 34], "[~~~]", [ "bbb", "aaa" ])

? o1.Content()
#--> --[...]---[...]---[...]---bbb--aaa--

proff()
# Executed in 0.07 second(s).

/*-----------------

profon()

? IsSortedListOfPairsOfNumbers([ [4, 6], [10, 12], [16, 18] ])
#--> _TRUE_

? IsListOfPairsOfNumbersSortedUp([ [4, 6], [10, 12], [16, 18] ])
#--> _TRUE_

? IsListOfPairsOfNumbersSortedDown([ [16, 18], [10, 12], [4, 6] ])
#--> _TRUE_

proff()

/*-----------------

o1 = new stzString("...456...012...678..")
o1.ReplaceSectionsByMany([ [ 4, 6], [10, 20], [16, 18] ], ["A", "BB", "CCC"])
? o1.Content()
#--> ERROR MSG: Incorrect param type!
# ~> paSections must be a list of pairs of numbers sorted in ascending.

/*-----------------

o1 = new stzString("ab3de6gh9")
o1.ReplaceCharsAtPositionsByMany([3, 12, 9], [ "c", "f", "i" ])
? o1.Content()
#--> ERROR MSG: Incorrect param type! panPos must be a list of numbers sorted in ascending.

/*-----------------

profon()

o1 = new stzString("AB3CD6EF9GH")
o1.ReplaceCharsAtPositions([ 3, 9, 6], Heart())
? o1.Content()
#--> AB♥CD♥EF♥GH

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemsAtPositionsByMany([ 3, 5, 7], [ "♥", "♥♥", "♥♥♥" ])

? @@( o1.Content() )
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

proff()
# Executed in almost 0 second(s).

/*-----------------
profon()

? IsSortedString(1:5)
#--> _FALSE_

? IsSortedList("abc")
#--> _FALSE_

? IsSortedListInAscending(1:5)
#--> _TRUE_

? IsSortedListInDescending(5:1)
#--> _TRUE_

? IsSortedStringInAscending("abc")
#--> _TRUE_

? IsSortedStringInDescending("cba")
#--> _TRUE_

? StzStringQ("cba").IsSortedInDescending()
#--> _TRUE_

proff()
# Executed in 0.02 second(s).

/*-----------------

profon()

o1 = new stzString("ab3de6gh9")
o1.ReplaceCharsAtPositionsByMany([3, 6, 9], [ "c", "f", "i" ])

? o1.Content()
#--> "abcdefghi"

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("...456...012...678..")
o1.ReplaceSectionsByMany([ [ 4, 6], [10, 12], [16, 18] ], ["A", "BB", "CCC"])
? o1.Content()
#--> ...A...BB...CCC..

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE", "FOUR" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--FOUR--

#--

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE", "FOUR" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--[~~~]--

#--

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--[~~~]--

proff()
# Executed in 0.05 second(s).

/*=============

profon()

o1 = new stzListOfChars(@Chars("RINGORIALAND"))

? o1.BoxifyXT([
	:Rounded = _TRUE_,
	:Hilight = [ ],
	:Numbered = _TRUE_
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │ L │ A │ N │ D │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
#   1   2   3   4   5   6   7   8   9   10  11  12

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzListOfChars(@Chars("RINGORIA"))

? o1.BoxifyXT([
	:Rounded = _TRUE_,
	:Hilight = [ 1, 2, 3, 5 ],
	:Numbered = _TRUE_ # Shows only the highlited positions
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │
# ╰─•─┴─•─┴─•─┴───┴─•─┴───┴───┴───╯
#   1   2   3       5

proff()
# Executed in 0.08 second(s).

/*-----------------

profon()

o1 = new stzListOfChars(@Chars("RINGORIALAND"))

? o1.BoxifyXT([
	:Rounded = _TRUE_,
	:Hilight = [ 1, 2, 3, 5, 10, 12 ],
	:Sectioned = _TRUE_,
	:Numbered = _TRUE_
])

#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │ L │ A │ N │ D │
# ╰─•─┴─•─┴─•─┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴─•─╯
#   '---'   '-------'                   '-------'
#   1   2   3       5                   10     12   

proff()
# Executed in 0.09 second(s).

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "G", "N", "G" ])

? o1.BoxifyXT([ :Rounded, :Hilight = [ 1, 2, 4, 5 ], :Sectioned, :Numbered ])
#-->
# ╭───┬───┬───┬───┬───╮
# │ R │ I │ G │ N │ G │
# ╰─•─┴─•─┴───┴─•─┴─•─╯
#   '---'       '---'
#   1   2       4   5

proff()
# Executed in 0.10 second(s).

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "G", "N", "G" ])

? o1.BoxifyXT([ :Hilight = [ 1, 2, 4, 5 ], :Sectioned=FALSE, :Numbered ])
#-->
# ┌───┬───┬───┬───┬───┐
# │ R │ I │ G │ N │ G │
# └─•─┴─•─┴───┴─•─┴─•─┘
#   1   2       4   5

proff()
# Executed in 0.10 second(s).

/*-----------------

profon()

o1 = new stzSplitter(2)
? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 1 ], [ 2, 2 ] ]

? @@( o1.SplitToPartsOfNItemsXT(2) )
#--> [ [ 1, 2 ] ]

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

o1 = new stzSplitter(5)
? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitToPartsOfNItemsXT(5) )
#--> [ [ 1, 5 ] ]

? @@( o1.SplitToPartsOfNItemsXT(4) )
#--> [ [ 1, 4 ], [ 5, 5 ] ]

proff()
# Executed in 0.03 second(s).

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxifyXT([
	:Rounded = _TRUE_,
	:Hilight = [ 1, 4 ],
	:Sectioned = _TRUE_,
	:Numbered = _TRUE_ ]) + NL
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   '-----------'
#   1           4

# Force the display of all the positions ~> add an ..XT to :Numbered option

? o1.BoxifyXT([
	:Rounded = _TRUE_,
	:Hilight = [ 1, 4 ],
	:Sectioned = _TRUE_,
	:NumberedXT = _TRUE_
])
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   '-----------'
#   1   2   3   4

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxXT([
	:Rounded = _TRUE_,
	:Hilight = [ 1, 4 ],
	:NumberedXT = _TRUE_
]) + NL # OrBoxifyXT()
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   1   2   3   4

? o1.BoxifyXT([ :ShowPositions = [ 1, 4 ], :NumberedXT = _TRUE_ ])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └─•─┴───┴───┴─•─┘
#   1   2   3   4

proff()
# Executed in 0.10 second(s).

/*-----------------

profon()

? Q("RING").CharsBoxifiedXT([ :Numbered = _TRUE_ ]) + NL
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘
#   1   2   3   4

? Q(Chars("RING")).ToStzListOfChars().BoxifiedXT([ :Numbered = _TRUE_ ])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘
#   1   2   3   4

proff()
# Executed in 0.10 second(s) in Ring 1.22
# Executed in 0.18 second(s) in Ring 1.20

/*-----------------

profon()

o1 = new stzString("SOFTANZA~RING")

o1.BoxifyCharsXT([
	:Rounded = _TRUE_,
	:Corners = [ :Round, :Rect, :Round, :Rect ],
	:Numbered = _TRUE_
])

? o1.Content() + NL
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │
# └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
#   1   2   3   4   5   6   7   8   9   10  11  12  13

# When you define :Rounded = _FALSE_, the ouput is not rounded,
# even if the :Corners are defined:

o1 = new stzString("SOFTANZA~RING")

o1.BoxifyCharsXT([
	:Rounded = _FALSE_,
	:Corners = [ :Round, :Rect, :Round, :Rect ],
	:Numbered = _TRUE_
])

? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │
# └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
#   1   2   3   4   5   6   7   8   9   10  11  12  13

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*===============

profon()

o1 = new stzString("SOFTANZA")
? o1.Spacified()
#--> S O F T A N Z A

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.SpacifyCharsUsing("~")
? o1.Content()
#--> S~O~F~T~A~N~Z~A

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*-----------------

profon()

o1 = new stzList( @Chars("SOFTANZA") )
o1.InsertAfterPositions([ 2, 4, 6, 8 ], "~")
? @@( o1.Content() )
#--> [ "S", "O", "~", "F", "T", "~", "A", "N", "~", "Z", "A" ]

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzList( @Chars("SOFTANZA") )
o1.InsertBeforePositions([ 2, 4, 6, 8 ], "~")
? @@( o1.Content() )
#--> [ "S", "~", "O", "F", "~", "T", "A", "~", "N", "Z", "~", "A" ]

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.InsertBeforePositions([ 2, 4, 6, 8 ], " ")
? o1.Content()
#--> S OF TA NZ A

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.InsertAfterPositions([ 2, 4, 6, 8 ], " ")
? o1.Content()
#--> "SO FT AN ZA"

proff()
# Executed in 0.01 second(s).

/*===============

profon()

o1 = new stzString("SOFTANZA")
o1.SpacifyCharsXT(:Separator = "~", :Step = 2, :Direction = :Default)
? o1.Content()
#--> SO~FT~AN~ZA

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("SOFTANZA")
o1.SpacifyCharsXT("~", 3, :backward)
? o1.Content()
#--> SO~FTA~NZA

proff()
# Executed in 0.01 second(s).

/*----------------- #todo #narration

profon()

o1 = new stzString("SOFTANZA")

? o1.VizFind("A") + NL
#-->
# SOFTANZA
# ----^--^

? o1.VizFindXT("A", [ :Spacified = _TRUE_  ]) + NL
#-->
# S O F T A N Z A
# --------^-----^

? o1.VizFindXT("A", [ :Spacified = _TRUE_, :PositionSign = Heart() ]) + NL
#-->
# S O F T A N Z A
# --------♥-----♥

? o1.VizFindXT("A", [ :Spacified = 1, :PositionSign = Heart(), :Numbered = 1 ]) + NL
#-->
# S O F T A N Z A
# --------♥-----♥
#         9     15

? o1.VizFindBoxed("A") + NL
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴─•─┴───┴───┴─•─┘

? o1.VizFindBoxedXT("A", [
	:PositionSign = Heart(),
	:AllCorners = :Rounded
]) + NL

#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─♥─┴───┴───┴─♥─╯

? o1.VizFindXT( "A", [
	:Boxed = _TRUE_,
	:Rounded = _TRUE_, 
	:AllCorners = :Rounded,

	:Numbered = _TRUE_,

	:PositionSign = Heart()
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─♥─┴───┴───┴─♥─╯
#                   5           8

proff()
# Executed in 0.19 second(s) in Ring 1.22
# Executed in 0.23 second(s) in Ring 1.20

/*----- #narration FLEXIBLE OPTIONS SYNTAX

profon()

o1 = new stzString("SOFTANZA")

? o1.VizFindBoxedXT("A", [
	:Dashed = _TRUE_,
	:Rounded = _TRUE_,
	:Numbered = _TRUE_,
])

#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴─•─┴╌╌╌┴╌╌╌┴─•─╯
#                   5           8

# Let's change the position sign:

? PositionSign() # Or PositionChar() or HilightSign() or HilightChar()
#--> "•"

SetPositionSign("↑")

# When you provide one option, enclose it between [ and ]:

? o1.VizFindBoxedXT( "A", [ :Rounded = _TRUE_ ] )
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─↑─┴───┴───┴─↑─╯

proff()
# Executed in 0.12 second(s).

/*-----

profon()

o1 = new stzString("SOFTANZA")

? o1.VizFindBoxedXT("A", [
	:PositionChar = "↑", # Or :PositionSign or :HilightChar or :HilightSign
	:Numbered = _TRUE_,
	:Solid = _TRUE_,

	:Rounded = _TRUE_,
	:Corners = [ :round, :round, :rect, :rect ]

]) + NL
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴─↑─┴───┴───┴─↑─┘
#                   5           8 

? o1.VizFindBoxedXT("A", [
	:Dashed = _TRUE_,
	:Rounded = _TRUE_,

	:PositionSign = "↑",
	:Numbered = _TRUE_
])
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴─↑─┴╌╌╌┴╌╌╌┴─↑─╯
#                   5           8

proff()
# Executed in 0.10 second(s).

/*=====

profon()

o1 = new stzString("..STZ..STZ..STZ")

? o1.ToStzListOfChars().BoxXT([
	:Hilighted = Q( o1.FindZZ("STZ") ).Flattened(),
	:Sectioned = _TRUE_,
	:Numbered = _TRUE_
 ])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ . │ . │ S │ T │ Z │ . │ . │ S │ T │ Z │ . │ . │ S │ T │ Z │
# ╰───┴───┴─•─┴───┴─•─┴───┴───┴─•─┴───┴─•─┴───┴───┴─•─┴───┴─•─╯
#           '-------'           '-------'           '-------'
#           3       5           8     10            13     15

proff()
# Executed in 0.09 second(s) in Ring 1.21

/*-----

profon()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.Box()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.BoxXT([])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.BoxRound()
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰───┴───┴───┴───╯

? o1.BoxDash()
#-->
# ┌╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┐
# ┊ R ┊ I ┊ N ┊ G ┊
# └╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┘

? o1.BoxRoundDash()
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ R ┊ I ┊ N ┊ G ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

? o1.BoxDashRound()

proff()
# Executed in 0.06 second(s).

/*-----

profon()

o1 = new stzListOfChars( @Chars("..STZ..StZ..stz") )

? o1.Boxify() # Or simply Box()
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ . │ . │ S │ T │ Z │ . │ . │ S │ t │ Z │ . │ . │ s │ t │ z │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

? o1.BoxDash()
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ . ┊ . ┊ S ┊ T ┊ Z ┊ . ┊ . ┊ S ┊ t ┊ Z ┊ . ┊ . ┊ s ┊ t ┊ z ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

proff()
# Executed in 0.04 second(s).

/*-----

profon()

o1 = new stzString("..STZ..StZ..stz")

? o1.vizFindCS("stz", _FALSE_)
# ..STZ..StZ..stz
# --^----^----^--

proff()
# Executed in 0.01 second(s).

/*------

profon()

o1 = new stzString("..STZ..StZ..stz")

# The fellowing calls all return  the same result:

? o1.VizFindCSXT("STZ", :CS = _FALSE_, [ :Numbered = _TRUE_ ]) + NL
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

? o1.VizFindXT("stz", [ :Numbered = _TRUE_, :CS = _FALSE_ ] ) + NL
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

? o1.VizFindCSXT("stz", :CS = _FALSE_, [ :Numbered = _TRUE_ ] )
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*------

profon()

o1 = new stzString("..STZ..StZ..stz...STZ")

# The order of params is defined by the order of name suffixes:

? o1.VizFindBoxedCSXT("STZ", :CS = _FALSE_, [ :Numbered = _TRUE_ ])
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ . │ . │ S │ T │ Z │ . │ . │ S │ t │ Z │ . │ . │ s │ t │ z │ . │ . │ . │ S │ T │ Z │
# └───┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴───┴─•─┴───┴───┘

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*-----

profon()

? Q("ABTCADNBBABEFACCC").SpacifyQ().vizFind("A")
#-->
# A B T C A D N B B A B E F A C C C
# ^-------^---------^-------^------   

proff()
# Executed in 0.02 second(s) in Ring 1.22

/*------------------

profon()

o1 = new stzString("----^----------^----------^-----")

? o1.content()
#--> ----^----------^----------^-----

o1.ReplaceByMany("^", [ "A", "B", "C" ])
? o1.Content()
#--> ----A----------B----------C-----

proff()
# Executed in 0.01 second(s).

/*===============

profon()

? @@NL( CardsXT() ) + NL
#--> [
#	[ "ace","🂡" ],
#	[ "two", "🂢" ],
#	[ "three", "🂣" ],
#	[ "four", "🂤" ],
#	[ "five", "🂥" ],
#	[ "six", "🂦" ],
#	[ "seven", "🂧" ],
#	[ "eight", "🂨" ],
#	[ "nine", "🂩" ],
#	[ "ten", "🂪" ],
#	[ "jack", "🂫" ],
#	[ "queen", "🂭" ],
#	[ "king", "🂮" ]
# ]

? @@( Cards() ) + NL
#--> [ "🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮" ]

? Card(:jack) + NL
#--> 🂫

? @@( TheseCards([ :four, :nine, :king ]) ) + NL
#--> [ "🂤", "🂩", "🂮" ]

? @@NL( TheseCardsXT([ :four, :nine, :king ]) )
#--> [
#	[ "four", "🂤" ],
#	[ "nine", "🂩" ],
#	[ "king", "🂮" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*===============

profon()

o1 = new stzString("---456----123--67---")
? @@( o1.Sections([ [ 1, 3], [ 7, 10], [ 14, 15], [18, 20] ]) )
#--> [ "---", "----", "--", "---" ]

proff()
# Executed in 0.01 second(s).

/*-----------------

profon()

o1 = new stzString("---456----123--67---")
? @@( o1.SplitAtSections([ [4, 6], [11, 13], [16, 17] ]) )
#--> [ "---", "----", "--", "---" ]

proff()
# Executed in 0.07 second(s).

/*-----------------

profon()

o1 = new stzString("---456----123--67---")

o1.ReplaceSectionsByMany(
	[ [4, 6], [11, 13], [16, 17] ],
	[ "^^^", "^^^", "^^" ]
)

? o1.Content()
#--> ---^^^----^^^--^^---

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.19

/*------------------ #ring

profon()

? ring_substr2("--^---^^--^", "-", " ")
#--> "  ^   ^^  ^"

proff()
# Executed in almost 0 second(s).

/*=============

profon()

o1 = new stzString('123--67--')
o1.ReplaceSection(1, 3, "~")
? o1.Content()
#--> ~--67--

proff()
# Executed in 0.01 second(s).

/*--------------

profon()

o1 = new stzString("--345--89--")
o1.ReplaceSection(8, 9, "~")
? o1.Content()
# --345--~--

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("--345--89---")
o1.ReplaceSectionsByMany([ [3, 5], [8, 9] ], [ "^^^", "^^" ])
? o1.Content()
#--> --^^^--^^---

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.19

/*-------------

o1 = new stzString("123---789---")
o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], "^")
? o1.Content()
#--> ERROR MESSAGE: Incorrect param type! pacSubStr must be a list.

/*-------------



/*-------------

profon()

o1 = new stzString("123---789---")
o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], [ "^^^", "vvv" ])
? o1.Content()
#--> ^^^---vvv---

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("--345--89--")
o1.ReplaceSectionsByMany([ [3, 5], [8,9] ], [ "*", "~" ] )
? o1.Content()
#--> --*--~--

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("123---78--")
o1.ReplaceSectionsByMany([ [1, 3], [7,8] ], [ "*", "~" ] )
? o1.Content()
# *---~--

proff()
# Executed in 0.01 second(s).

/*-------------

profon()

o1 = new stzString("^---^---^---^---")

o1.ReplaceSectionsByMany(
	[ [ 1, 1 ], [ 5, 5 ], [ 9, 9 ], [ 13, 14 ] ],
	[ "1", "5", "9", "13" ]
)

? o1.Content()
#--> 1---5---9---13--

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*========

profon()

o1 = new stzString("ringringringring")

? o1.vizFind("ring") + NL
#-->
# ringringringring
# ^---^---^---^---

? o1.vizFindXT("ring", [ :Numbered = _TRUE_ ])
#-->
# ringringringring
# ^---^---^---^---
# 1   5   9   13 

proff()
# Executed in 0.02 second(s).

proff()

/*-------#narration #visiality VIZ-FINDING A RECURRING SUBSTRING

# This narration explores methods to locate and highlight recurring 
# sequences within strings, with both precision and visual assistance.

profon()

# Searching for "ring" within a jumble of letters:

o1 = new stzString("fjringljringdjringg")

# Let's start with a straightforward approach using Find(),
# which returns the list of positions where "ring" appears:

? @@( o1.Find("ring") ) + NL
#--> [ 3, 9, 15 ]

# We can go further and add a visual dimension by using
# the "viz" prefix with Find(), making the positions easy to spot:

? o1.vizFind("ring") + NL
#-->
# fjringljringdjringg
# --^-----^-----^----

# To gain even more insight, we can add the XT() suffix,
# providing a numeric guide for each matched position:

? o1.vizFindXT("ring", [ :Numbered = _TRUE_ ]) + NL
#-->
# fjringljringdjringg
# --^-----^-----^----
#   3     9     15       

# Now, let's find the positions of "ring" as sections:

? @@( o1.FindAsSections("ring") ) + NL # Or simply FindZZ()
#--> [ [3, 6], [9, 12], [15, 18] ]

# The sections can also be visualized by using
# the :Sectioned option:

? o1.vizFindZZ("ring") + NL
#-->
# fjringljringdjringg
#   '--'  '--'  '--'

? o1.vizFindXT("ring", [ :Sectioned = _TRUE_, :Numbered = _TRUE_ ]) + NL
#-->
# fjringljringdjringg
#   '--'  '--'  '--'
#   3  6  9 12  15 18

# For a more sophisticated display, we can box and section the output,
# the results become both visually structured and detailed:

? o1.vizFindXT("ring", [
	:Boxed = _TRUE_, :Rounded = _TRUE_, :Sectioned = _TRUE_, :Numbered = _TRUE_ ])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ f │ j │ r │ i │ n │ g │ l │ j │ r │ i │ n │ g │ d │ j │ r │ i │ n │ g │ g │
# ╰───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───╯
#           '-----------'           '-----------'           '-----------'
#           3           6           9         12            15         18

proff()
# Code executed in 0.17 second(s) in Ring 1.21

/*-----------------

profon()

o1 = new stzListOfChars( @Chars("fjringljringdjringg") )
aOptions = [
	[ "rounded", 1 ],
	[ "sectioned", 1 ],
	[ "numbered", 1 ],
	[ "hilighted", [ 3, 6, 9, 12, 15, 18 ] ],
	[ "casesensitive", 1 ]
]

? o1.BoxXT(aOptions)
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ f │ j │ r │ i │ n │ g │ l │ j │ r │ i │ n │ g │ d │ j │ r │ i │ n │ g │ g │
# ╰───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───╯
#          '-----------'           '-----------'           '-----------'
#          3           6           9         12            15         18

proff()

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindMany([ "A", "T", "V" ])

#--> Returns a string like this:

#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-.
#  "T" :  --^----.------.-^
#  "V" :  -------^------^--
#  "X" :  -----------------

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindManyXT("A")

#--> Returns a string like this:

#	  1..4..7..0..3..6.
#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-. (3)
#  "T" :  --^----.------.-^ (2)
#  "V" :  -------^------^-- (2)
#  "X" :  ----------------- (0)

/*======== #narration #perf CONCATENATING STRINGS IN RING AND SOFTANZA

StartProfiler()

# In Ring, concatenating 1 million strings takes about 45 seconds:
#~> (The code setion is commented,  because it takes a lot of time)

#	str = ""
#	for i = 1 to 1_000_000
#		str += "السّلام عليكم ورحمة الله"
#	next
#	? "Finished"
#
#	? ElapsedTime() + NL
#	# Executed in 44.94 second(s) in Ring 1.22

# While in Softanza, using  Concatenate(), this take about 4 seconds:

	ResetTimer()

	acList = []
	for i = 1 to 1_000_000
		acList + "السّلام عليكم ورحمة الله"
	next
	
	Concatenate(acList)
	#--> Executed in 3.64 second(s) in Ring 1.22

	? ElapsedTime()

# Which is a speed factor of about 11 times!

	? SpeedX(45, 4)
	#--> 11.25

StopProfiler()
# Executed in 3.83 second(s) in Ring 1.22

/*----- #perf #ring #unicode

profon()

# Ring can add 1 million strings to a list quickly:

	acList = []
	for i = 1 to 1_000_000
		acList + "any text"
	next

	? ElapsedTime()
	#--> 0.26 second(s)

# But when the string is unicode (arabic in this case),
# this becomes visibly less performant

	ResetTimer()

	acList = []
	for i = 1 to 1_000_000
		acList + "السّلام عليكم ورحمة الله"
	next

	? ElapsedTime()
	#--> 0.47 second(s)

proff()
# 0.47 second(s)

/*----- #narration #perf #ring CONCATENATING UNICODE STRINGS IN RING AND SOFTANZA

profon()

# Ring can concatenate 1 million latin strings in almost 2 seconds:

	cStr = ""
	for i = 1 to 1_000_000
		cStr += "any text"
	next

	? ElapsedTime()
	#--> 1.70 second(s)

# But when the string is in unicode (arabic in this case), Ring's
# performance degradates to more then 45 seconds:
#~> (The code setion is commented,  because it takes a lot of time)

#	ResetTimer()
#
#	cStr = ""
#	for i = 1 to 1_000_000
#		cStr += "السّلام عليكم ورحمة الله"
#	next
#
#	? ElapsedTime() + NL
#	#--> 45.63 second(s)

# Hopefully, Softanza has the Concatenate() function that
# does the job in less then 4 seconds:

	ResetTimer()

	aListOfStr = []

	for i = 1 to 1_000_000
		aListOfStr + "السّلام عليكم ورحمة الله"
	next
	# The filling takes 1.70 seconds

	str = Concat(aListOfStr)

	? ElapsedTime() + NL
	# 3.66 second(s)

# Which is a performance gain of +88%

	? PerfGain100(45.63, 3.66)
	#--> 91.98

# or a speed factor of +8 times!

	? SpeedFactor(45.63, 3.66)
	#--> 12.47

proff()
# Executed in 5.33 second(s) in Ring 1.22

/*----- #perf qt qstring qstringlist

profon()

# Qt String is not performant for appending a large
# number of strings (takes a lot of time to append
# 1000000 arabic strings)

# Check it by yourself (though i don't advise you
# to run the code):

#	salem = new QString2()
#	for i = 1 to 1_000_000
#		salem.append("السّلام عليكم ورحمة الله")
#	next
#	? ElapsedTime() + NL
#	#--> A lot! I cancelled the execution after minutes.

# Instead of QString, use QStringList which does
# the job very quickly:

	ResetTimer()

	oQStrList = new QStringList()
	for i = 1 to 1_000_000
		oQStrList.append("السّلام عليكم ورحمة الله")
	next
	
# In practice, you would need that QStringList to quickly
# concatenate the list usig the join() method:

	str = oQStrList.join("")
	# Executed in 0.01 second(s)

# Or better of all use Allegro via GameEngine library.
#NOTE Softanza will rely on it in string manipulation instead of Qt

proff()
# Executed in 2.72 second(s) in Ring 1.22

                 ///////////////////////////////////////////////
                //                              ///////////////
      ///////////      TO BE FIXED LATER       /////////////
 ///////////////                              //
///////////////////////////////////////////////

/*---------------- TODO/FUTURE : AFTER CONSTRAINT IMPLEMENTED

aList = [
	:Where = "file.ring",
	:What  = "Describes what happened",
	:Why   = "Describes why it happened",
	:Todo  = "Posposes an action to do"
]

StzListQ(aList).IsRaiseNamedParam() #--> _TRUE_

# Internally, StzList checks for a number of conditions

StzListQ(aList) {
	? NumberOfItems() <= 4 #--> _TRUE_
	? IsHashList() #--> _TRUE_
	? ToStzHashList().KeysQ().IsMadeOfSomeOfThese([ :Where, :What, :Why, :Todo ]) #--> _TRUE_
	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != _NULL_") #--> _TRUE_
}

# In a better world, those conditions could be expressed as
# constraints on the list object like this:

StzListQ(aList) {
	:MustHave@4@Items
	:MustBeAHashList
	:AKeyMustBeOneOfThese = [ :Where, :What, :Why, :Todo ]
	:ValuesMustBeNonNullStrings
}

# To make it happen, those constraints should be defined once at
# the global level, and then reused every where inside a stzList

/*-----------------// TODO - FUTURE //

# Constarints are defined at the global level and then reused every where
# inside your softanza objects

DefineConstraints([
	:OnStzString = [
		:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
		:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
		:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = _FALSE_) }'
	],

	:OnStzNumber = [
		:MustBeStrictlyPositive = '{ @number > 0 }'
	],

	:OnStzList = [
		:MustBeAHashList = '{ Q(@list).IsHashList() }'
	]

])

# Let's use the constraints defined in a StzString object

StzStringQ("SOFTANZA") {

	EnforeConstraints([
		:MustBeUppercase,
		:MustNotExceed10Chars
	])

	? "Passed"
}

/*----------------- TODO - FIX THIS : Revisit this after completing stzWalker

// WalkUntil has not same output in stzString and stzList!

# In stzString only the last position is returned

? StzStringQ("size()").WalkUntil('@char = "("') #--> 4
? StzStringQ("size()").WalkUntil('@char = "*"') #--> 0

# In stzList all the walked positions are returned

StzListQ([ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]) {
	? WalkUntil("@item = 'D'") #--> 1:5
	? WalkUntil('@item = "x"') #--> 0
}
