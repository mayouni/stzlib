load "../stzlib.ring"

/*====

pron()

o1 = new stzString("me you all the others")
? o1.ContainsEither("me", :or = "you")
#--> FALSE

o1 = new stzString("me and all the others")
? o1.ContainsEither("me", :or = "you")
#--> TRUE

proff()
# Executed in 0.01 second(s)

/*----

pron()

o1 = new stzString("me you all the others")
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE
	
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> FALSE

o1 = new stzString("me and all the others")
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

proff()
# Executed in 0.03 second(s)

/*===

pron()

? Q("ring").IsReverseOf("gnir")
#--> TRUE

? Q(1:3).IsReverseOf(3:1)
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*===

pron()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring kandaji")

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥♥♥ csharp ♥ ♥♥♥

proff()
#--> Executed in 0.01 second(s)

/*------

pron()

o1 = new stzString("ring qt softanza pyhton kandaji csharp zai")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥♥

proff()
# Executed in 0.02 second(s)

/*------

pron()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥

proff()
# Executed in 0.01 second(s)

#==== @narration

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
# Executed in 0.02 second(s)

/*=======

pron()

o1 = new stzString("12345678")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

proff()
# Executed in 0.01 second(s)

/*--------

pron()

o1 = new stzList(1:8)

? o1.Section(3, 5)
#--> [ 3, 4, 5 ]

? o1.Section(5, 3)
#--> [ 3, 4, 5 ]

proff()
# Executed in 0.01 second(s)

/*=========

pron()

o1 = new stzString("ring---")

? o1.RightCharRemoved()
#--> ring--

? o1.CharRemovedFromRight("-")
#--> ring--

? o1.TrailingCharsRemoved()
#--> ring

? o1.CharRemovedFromRightXT("-")
#--> ring

? o1.CharTrimmedFromRight("-")
#--> ring--

proff()

/*=====

pron()

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

/*--------

pron()

o1 = new stzString("ring---")

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

proff()

/*--------

pron()

o1 = new stzString("---ring")

o1.RemoveThisCharFromLeftXT("*")
? o1.Content()
#--> "---ring"

o1.RemoveThisCharFromLeftXT("-")
? o1.Content()
#--> ring

proff()

/*--------

pron()

o1 = new stzString("ring---")

o1.RemoveThisCharFromRightXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromRightXT("-")
? o1.Content()
#--> "ring"

proff()

/*======

pron()

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
# Executed in 0.02 second(s)

/*--------

pron()

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
# Executed in 0.02 second(s)

/*====

pron()

o1 = new stzString("12.58000")
o1.RemoveThisCharFromRightXT("0") # Or RemoveAnyOccurrenceOfCharFromRight("0")
? o1.Content()
#--> 12.58

proff()

/*===

pron()

o1 = new stzString("00012.58")
o1.RemoveCharFromLeft("0")
? o1.Content()
#--> 0012.58

o1.RemoveCharFromLeftXT("0") # Or o1.RemoveAnyOccurrenceOfCharFromLeft("0")
? o1.Content()
#--> 12.58

proff()
# Executed in 0.02 second(s)

/*========

pron()

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
# Executed in 0.04 second(s)

/*==== @narration: eXTended form of RemoveFirstChar()

pron()

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

pron()

o1 = new stzString("---Ring---")

o1.RemoveFirstCharXT()
? o1.Content()
#--> Ring---

? o1.RemoveLastCharXT()
? o1.Content()
#--> Ring

proff()

/*-----------

pron()

o1 = new stzString("---Ring---")

o1.RemoveThisFirstCharXT("*")
? o1.Content()
#--> "---Ring---"

? o1.RemoveThisFirstCharXT("-")
? o1.Content()
#--> "Ring---"

o1.RemoveThisLastCharXT("*")
? o1.Content()
#--> Ring---

o1.RemoveThisLastCharXT("-")
? o1.Content()
#--> Ring

proff()
# Executed in 0.02 second(s)

/*=== Section() and CharsInSection()

pron()

# Here, you cen get a section from a string
? Q("---ring---").Section(4, 7)
#--> ring

# And here you get the list of chars of that section
? Q("---ring---").CharsInSection(4, 7)
#--> [ "r", "i", "n", "g" ]

proff()
# Executed in 0.02 second(s)

/*===== LeadingChars() and LeadingCharsAsString()

pron()

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
# Executed in 0.04 second(s)

/*------

pron()

o1 = new stzString("---Ring")

o1.RemoveLeadingChar() # Or RemoveAnyLeadingChar() or RemoveLeadingChars()
? o1.Content()

o1 = new stzString("Ring---")
o1.RemoveTrailingChar() # Or RemoveAnyTrailingChar() or RemoveTrailingChars()

proff()

/*------

pron()

o1 = new stzString("---Ring")

o1.RemoveThisLeadingChar("*")
? o1.Content()
#--> "---Ring"

o1.RemoveThisLeadingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.05 second(s)

/*------

pron()

o1 = new stzString("Ring---")

o1.RemoveThisTrailingChar("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisTrailingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.05 second(s)

/*====== @narration: Softanza permissiveness

pron()

# Suppose you have a string like this:
o1 = new stzString("rRing")

# And you want to remove the first char:
o1.RemoveFirstChar()
? o1.Content()
#--> Ring

# What if you think of applying CaseSensitivity here?
# Means that you want to the removal operation to
# be case sensitive...

# In fact, this is not logical, since the first char is
# the first char whatever case it has!

# But, Softanza don't care, and let you do it, and ignores
# the CS param completely:

o1 = new stzString("rRing")
o1.RemoveFirstCharCS(TRUE)
? o1.Content()
#--> Ring

#NOTE: This feature is made available only for this function,
# so we can show the principle of PERMISSIVENESS.
#~> It will be generalised in future.

proff()
# Executed in 0.03 second(s)

/*===

pron()

? HowMany( ArabicLetters() ) # Or HowManyArabicLetters() or NumberOfArabicLetters()
#--> 28

? 10PercentOf( ArabicLetters() ) # Or NPercentOf(10, ArabicLetters())
#o--> [ "ص", "ة", "د", "ص" ]

#NOTE : there is an eXTended list of arabic leters

? HowMany( ArabicLettersXT() )
#--> 34

proff()
# Executed in 0.02 second(s)

/*===

pron()

o1 = new stzString( "one two one three two one four five" )

? o1.HowManySubStrings()
#--> 630

? @@( SomeXT( o1.SubStrings(), 1/100 ) ) + NL # 1% of all the substrings
#--> [ " four", "e three two", "hree t", "one th", "one three two o", "th", "wo on" ]

# can also be written direcltly:
//? @@( OnePercentOf( o1.SubStrings() ) ) # or just 1Percent()

? @@( o1.SubStringsOccuringNTimes(3) ) + NL #NOTE "occuring" is mispelled (one r instead of two)
#--> [ "o", "on", "one", "one ", "n", "ne", "ne ", "e", "e ", "e t", " ", " t", "t" ]

? @@( o1.SubStringsOccurringExactlyNtimes(3) ) + NL
#--> [ "on", "one", "one ", "n", "ne", "ne ", "e t", " t", "t" ]

? @@( o1.SubStringsOccurringNoMoreThanNTimes(1) )
#--> [ ]

proff()
# Executed in 4.46 second(s)

/*---

pron()

o1 = new stzString( "ALLAH" )
? o1.HowManySubStrings()
#--> 15

? @@( o1.SubStringsOccurringOnlyNTimes(1) ) + NL
#--> [ "AL", "ALL", "ALLA", "ALLAH", "LL", "LLA", "LLAH", "LA", "LAH", "AH", "H" ]

? @@( o1.SubStringsOccurringNTimes(2) )
#--> [ "A", "L" ]

? HwoMany( o1.SubStringsOccurringNTimes(7) ) #NOTE that "HwoMany" is misspelled
#--> 0

? HowMany( o1.SubStringsOccurringLessThanNTimes(3) )
#--> 13

? @@( Some( o1.SubStringsOccurringLessThanNTimes(3) ) )
#--> [ "ALLA", "L", "LLA", "LA" ]

proff()
# Executed in 0.05 second(s)

#=====

# @narration: function active form and passive form (discussion with Mahmoud)

pron()

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
# Executed in 0.29 second(s)

/*===

pron()

? Chars("SOFTANZA")
#--> [ "S", "O", "F", "T", "A", "Z", "A" ]

proff()
# Executed in 0.02 second(s)

/*===  @narration: long functions names are necessary to Softanza but not to you!

pron()

# When you dig inside Softanza code, you will sometimes encouter functions
# with very long names like for example:

#                         7.9....4.6                3.5....4.2
o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? @@( o1.FindSubStringBoundsUpToNCharsAsSections("Ring", 2) )
#--> [ [ 8, 9 ], [ 14, 15 ], [ 34, 35 ], [ 40, 41 ] ]

# This shouldn't dissiponts you Let me explain why.

# Although the function is clear enough about what its does (in this case:
# finding the substrings bounding the substring "Ring" up to 2 chars), it
# is not made to be used directly by you.

# In fact, those long functions are used internally by other usual functions
# that you will need in practice, while letting the codebase be more readable.

# In our case, you would need this one:

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # You will understand the use of XT() in a moment ;)
#--> [ [ "<<", ">>" ], [ "((", "))" ] ]

# That you should use when you don't want all the bounding sunstrings to be returned
# (in this case all the 3 chars), but only 2 chars of each bound.

# To return all the chars bounding the substring "Ring" you say:

? o1.BoundsOf("Ring")
#--> [ [ "<<<", ">>" ], [ "(((", ")))" ] ]

#NOTE: Now you understand why we used the XT() extension to the name of BoundsOf()
# function, to say its an extended form of the main function, where we can specify
# the number of chars in the bound.

proff()

/*===

pron()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<<", ">>>"], [ "(((", ")))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()
#--> [ ["<<", ">>"], [ "((", "))" ] ]

proff()

/*--- 5 cases of the many cheks Softanza has for bounds

pron()

# Case 1 : Checking if the string is bounded by ONE or TWO substrings

? Q("_world_").IsBoundedBy("_")
#--> TRUE

? Q("/world\").IsBoundedBy([ "/", "\" ])
#--> TRUE

# Case 3 : Checking if the string is bounded by one (or two)
# substrings INSIDE an other string

? Q("world").IsBoundedBy([ "_", :In = "_world_" ])
#--> TRUE

? Q("world").IsBoundedBy([ ["/","\"], :In = "/world\" ])
#--> TRUE

# Case 3 : Checking if a string (or two) is the bound of an other
# string inside a third string

? Q("_").IsBoundOf("world", :In = "Hello _world_ of Ring!")
#--> TRUE

? Q(["/","\"]).AreBoundsOf("world", :In = "Hello /world\ of Ring!")
#--> TRUE

proff()
# Executed in 0.22 second(s)

/*--- @narrative

pron()

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
# Executed in 0.24 second(s)

/*======= @stzarration

pron()

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

# Rember : if you try these fency things with the more conservative Section()
# methond (without ...XT() extension), and for Softanza to stay simple and
# consitent for the most common use cases, you will get an error:

? o1.Section(-2, -4)
#--> Error message: n1 and n2 must be inside the list.

# Before you leave : All what works for stzString, will work for stzList.
# For our case, just change the first line of the code to use stzList instead
# of stzString, like this :

o1 = new stzList("1":"9")

# Now you can run the code sucessfully withou any modification.

proff()
# Executed in 0.03 second(s)

/*=========== @narration: case sensitivity in Softanza

pron()

# Do you know that case sensitivity is supported in Softanza,
# not only on stzString but also on stzList ?!

# Look how we can fin an item case-sensitively:

o1 = new stzList([ "emm", "EMM", "eMm", "EMM" ])

? o1.Find("EMM") # Same as FindCS("EMM", :CS = TRUE)
#--> [ 2, 4 ]

? o1.FindCS("EMM", :CS = FALSE)
#--> [ 1, 2, 3, 4 ]

# In fact, all items are equal when case sensitivity is not considered (set to FALSE)!
# In the same way, the size of the list can be counted in a case-sensity way:

? o1.NumberOfItems()
#--> 4

? o1.NumberOfItemsCS(FALSE)
#--> 1

# Now, softanza digs deeper and applies CaseSensitiviy on some other
# non trivial corners of the stzList class : the Content() method!

? o1.Content() # Same as ContentCS(TRUE)
#--> [ "emm", "EMM", "eMm", "EMM" ]

? o1.ContentCS(FALSE)
#--> [ "emm" ]

proff()
# Executed in 0.05 second(s)

/*========

pron()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content() #--> "♥ php ruby ♥♥ python ♥♥♥"

proff()
# Executed in 0.07 second(s)

/*========

pron()

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
# Executed in 0.08 second(s)

/*===

pron()

? IsMarquer("#01")
#--> TRUE

? IsMarquer("#02")
#--> TRUE

? BothAreMarquers("#01", "#02")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*-----

pron()

? Q('[  "ABC" , "EB" , "AA"  , 12 ]').ToList()
#--> [ "ABC", "EB", "AA", 12 ]

? Q(' "A" : "E" ').ToList()
#--> [ "A", "B", "C", "D", "E" ])

? Q(' "ا" : "ت" ').ToList()
#o--> [ "ا", "ب", "ة", "ت" ]

? Q(' "#1" : "#5" ').ToList()
#--> [ "#1", "#2", "#3", "#4", "#5" ]

proff()
# Executed in 0.42 second(s)

/*====

pron()

o1 = new stzString("ilir")

? o1.Copy().UppercaseQ().SpacifyQ().ReplaceQ(" ", "*").Content()
#--> "I*L*R"

? o1.Content()
#--> "ilir"

proff()
# Executed in 0.10 second(s)

/*----

pron()

o1 = new stzString("123ruby89")
o1.ReplaceAt(4, "ruby", "ring")
? o1.Content()
#--> 123ring89

proff()
# Executed in 0.04 second(s)

/*---- TODO: Retesting after re-establishing SubStringBetweenZZ() inside the file

pron()

put "What's your Firsts name?"
gname = getstring()
print( Interpolate("It's nice to meet you {fnmae}!") )
#--> It's nice to meet you {fnmae}!

proff()

/*=======

pron()

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
# Executed in 0.04 second(s)

/*======

pron()

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
# Executed in 0.16 second(s)

/*======

pron()

o1 = new stzString( "a + b - c / d = 0")

o1.ReplaceMany( ["+", "-", "/" ], :By = "*" )
? o1.Content()	
#--> "a * b * c * d = 0"

proff()
# Executed in 0.05 second(s)

/*-----

pron()

o1 = new stzString("ring php ruby ring python ring")

o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> "♥ php ruby ♥♥ python ♥♥♥"

proff()
# Executed in 0.08 second(s)

/*------

pron()

o1 = new stzString("ring php ring ruby ring python ring")

o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
? o1.Content() #--> "#1 php #2 ruby #1 python #2"

proff()
# Executed in 0.10 second(s)

/*------

pron()

o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")

o1.ReplaceManyByMany([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content() #--> "♥ qt ♥♥ pyhton ♥♥♥ csharp ♥"

proff()
# Executed in 0.04 second(s)

/*------

pron()

o1 = new stzString("ring ruby ring php ring")

o1.ReplaceSubstringAtPositions([ 1, 20 ], "ring", :By = "♥♥♥")
? o1.Content()
#--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.07 second(s)

/*------

pron()

o1 = new stzString("ring php ring ruby ring python ring csharp ring")

o1.ReplaceOccurrencesByMany([ 1, 3, 5], "ring", :By = [ "#1", "#3", "#5" ])
? o1.Content() #--> "#1 php ring ruby #3 python ring csharp #5"

proff()
# Executed in 0.09 second(s)

/*=====

pron()

	o1 = new stzString("**word1***word2**word3***")
	? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	#--> [ "**", "***", "**", "***" ]
		
	o1.RemoveManySections([
		[1,2], [8, 10], [16, 17], [23, 25]
	])
		
	? o1.Content() #--> "word1word2word3"

proff()
#--> Executed in 0.17 second(s)

/*-----

pron()

o1 = new stzString("1♥♥456♥♥901♥♥4")
o1.RemoveSections([ 2:3, 7:8, 12:13 ])
? o1.Content()
#--> 14569014

proff()
# Executed in 0.14 second(s)

/*-----

pron()

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

/*-----
/*==========

pron()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveAt(6, "♥♥♥") # Or RemoveSubStringAtPosition()

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.01 second(s)

/*----------

pron()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveXT("♥♥♥", :AtPosition = 6)

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.05 second(s)

/*------------

pron()

	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveXT("♥♥♥", :AtPositions = [ 1, 9, 17 ])

	? o1.Content() #--> "ring ruby php"

proff()
# Executed in 0.14 second(s)

/*------------

pron()

	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveAt([ 1, 9, 17 ], "♥♥♥") # Or RemoveSubstringAtPositions()

	? o1.Content()
	#--> "ring ruby php"

proff()
# Executed in 0.07 second(s)

/*==========

pron()

	o1 = new stzString("ruby ring php")
	o1.ReplaceAt(6, "ring", :By = "♥♥♥") # Or ReplaceSubStringAtPosition()

	? o1.Content()
	#--> "ruby ♥♥♥ php"

proff()
# Executed in 0.16 second(s)

/*----------

pron()

	o1 = new stzString("ruby ring php")
	o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")

	? o1.Content()
	#--> "ruby ♥♥♥ php"

proff()
# Executed in 0.16 second(s)

/*------------

pron()

	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceXT("ring", :AtPositions = [ 1, 20 ], :By = "♥♥♥")

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.14 second(s)

/*------------

pron()

	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceAt([ 1, 20 ], "ring", :By = "♥♥♥") # Or ReplaceSubstringAtPositions()

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

proff()
# Executed in 0.07 second(s)

/*=============

pron()

o1 = new stzString( "a + b - c / d = 0")
o1.Replace( [ "+", "-", "/" ], :By = "*" ) # Or ReplaceMany()
 ? o1.Content()
	
#--> "a * b * c * d = 0"
	
proff()
# Executed in 0.05 second(s)

/*=========

pron()

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

pron()

o1 = new stzString("--ring--&--softanza--")

? @@( o1.FindExceptZZ("--") )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except("--") ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

proff()
# Executed in 0.10 second(s)

/*--------

pron()

o1 = new stzString("--ring--&__softanza__")

? @@( o1.FindExceptZZ([ "--", "__" ]) )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except([ "--", "__" ]) ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

proff()
# Executed in 0.14 second(s)

/*--------

pron()

o1 = new stzString("--Ring--&__Softanza__")
o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
? o1.Content()
#--> Ring&Softanza

proff()

/*--------

pron()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
? o1.Content()
#--> Ring&♥Ring♥Softanza♥

proff()
# Executed in 0.11 second(s)

/*-------- TODO

pron()

o1 = new stzString("--Ring--Softanza--")

o1.ReplaceWithMany("--", ["1", "2", "3"])
? o1.Content()

proff()

/*-------- TODO

pron()

o1 = new stzString("--Ring__Softanza..")

o1.ReplaceManyWithMany(["--", "__", ".."], ["1", "2", "3"])
? o1.Content()

proff()

/*-------- #TODO

pron()

o1 = new stzString("--Ring--__Softanza__")

o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], [ "1", "2", "3"])
? o1.Content()
#--> 1Ring2Softanza3

proff()

/*======== #narration

pron()

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
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.19

/*----------

pron()

o1 = new stzString("okay one pepsi two three ")
? o1.SplitQ(" ").FindWXT(' Q(@item).ContainsAnyOfThese( Q("vwto").Chars() ) ')
#--> [ 1, 2, 4, 5 ]

proff()
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.58 second(s) in Ring 1.17

/*=======

pron()

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

pron()

oQStr = new QString2()
oQStr.append(str)

c1 = oQStr.mid(0, 1)
? c1
#--> "r"

c2 = oQStr.mid(oQStr.count()-1, 1)
? c2
#--> "g"

proff()
# Executed in 0.03 second(s)

/*----------------
/*==============

pron()

? Q(["A", "B", "C", "D", "E"])[-3]
#--> "C"

proff()
# Executed in 0.03 second(s)

/*========

pron()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 5, 6 ], [ 13, 17 ] ]

proff()
# Executed in 0.07 second(s)

/*-----------

pron()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSections("aa", "aa"))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()
# Executed in 0.08 second(s)

/*-----------

pron()

#                       5 7  01    
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSectionsS("aa", "aa", :startingat = 2))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

proff()

/*=============

pron()

o1 = new stzString("---♥♥...**---")

? o1.SubStringComesBetween("...", "♥♥", "**")
#--> TRUE

? o1.SubStringComesBetween("...", "**", "♥♥")
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*=========

pron()

o1 = new stzString("123♥♥678**123♥♥678")

? o1.SubStringComesBefore("♥♥", :Position = 6)
#--> TRUE

? o1.SubStringComesBeforePosition("♥♥", 6)
#--> TRUE

? o1.SubStringComesBefore("♥♥", :SubString = "**")
#--> TRUE

? o1.SubStringComesBeforeSubString("♥♥", "**")
#--> TRUE

#--

? o1.SubStringComesAfter("♥♥", :Position = 3)
#--> TRUE

? o1.SubStringComesAfterPosition("♥♥", 3)
#--> TRUE

? o1.SubStringComesAfter("**", :SubString = "♥♥")
#--> TRUE

? o1.SubStringComesAfterSubString("**", "♥♥")
#--> TRUE

#--

? o1.SubStringComesBetween("♥♥", :Positions = 3, :And = 6)
#--> TRUE

? o1.SubStringComesBetweenPositions("♥♥", 3, 6)
#--> TRUE

? o1.SubStringComesBetween("678", :SubStrings = "♥♥", :And = "**")
#--> TRUE

? o1.SubStringComesBetweenSubStrings("678", "**", "♥♥")
#--> TRUE

#--

? SubStringQ([ "♥♥", :In = "--♥♥--**--" ]).ComesBeforeSubString("**")
#--> TRUE

? SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")
#--> TRUE

? Q("--♥♥--**--").SubStringQ("♥♥").ComesBeforeSubString("**")
#--> TRUE

proff()
# Executed in 0.12 second(s)

/*-----

pron()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----

pron()

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

pron()

? @@( Digits() )
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

/*====

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

/*==================

pron()

? Q("I").Unicode()
#--> 73

proff()
# Executed in 0.03 second(s)

/*-----

pron()

a = Q("abc").ToListOfStzChars()
? a[2].StzType()
#--> stzchar

proff()
# Executed in 0.05 second(s)

/*-----

pron()

? HexPrefix()
#--> Ox

? Q( HexPrefix() + '066E').RepresentsNumberInHexForm()
#--> TRUE

? Q('U+066E').RepresentsNumberInUnicodeHexForm()
#--> TRUE

proff()

/*---------

pron()

? TQ("משמש").Script()
#--> hebrew


proff()

/*----------

pron()

? Q('U+0649').IsHexUnicode() 	#--> TRUE
? StzCharQ("ڢ").HexUnicode() 	#--> U+06A2
? QQ('U+0649').Content() 	#--> ى
? QQ('U+06A2').Content() 	#--> ڢ
? HexUnicodeToUnicode('U+06A2')	#--> 1698
? UnicodeToHexUnicode(1698)	#--> U+06A2

proff()
# Executed in 1.20 second(s)

/*---------

pron()

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

pron()

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

pron()

#TODO: Those two functions must be unified
#--> Read the TODO in stzScripts.ring

? len( LocaleScripts() )
#--> 141

? len( UnicodeScripts() )
#--> 157

proff()

/*==============

pron()

? Dotless("alitalia extrême extèrieur aéorô ûltrâ")
#--> alıtalıa extreme exterıeur aeoro ultra

? Dotless("مشمش وخوخ وزيتون")	#--> مسمس وحوح ورٮٮوٮ


proff()

/*---------

pron()

? Dotless("فلسطين الأبيّة") 		#--> ٯلسطٮں الأٮٮّه
? Dotless("عاشت المقاومة") 		#--> عاسٮ المٯاومه
? Dotless("تونس معك يا غزّة")		#--> ٮوٮس معک ٮا عرّه
? Dotless("جمعية الخيرات")		#--> حمعٮه الحٮراٮ
? Dotless("أفديك بروحي يا قدس") 	#--> أٯدٮک ٮروحٮ ٮا ٯدس
? Dotless("مشمش وخوخ وزيتون")		#--> مسمس وحوح ورٮٮوٮ

#TODO: the implementation needs some enhancements/

proff()


/*==================

pron()

? Q("1234567890987654321").ShortenedN(2)
#--> 12...21
		
? Q("1234567890987654321").ShortenedXT(0, 2, " {...} ")
#--> 12 {...} 21

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

? Q("1234567890987654321").Shortened()
#--> 123...321

? Q("1234567890987654321").ShortenedN(5)
#--> 12345...54321

? Q("1234567890987654321").ShortenedXT(0, 3, " ... ")
#--> 123 ... 321

proff()
# Executed in 0.04 second(s)

/*-------------

pron()

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

pron()

? Q("1234567890987654321").ShortenedUsing(" {...} ")
#--> 123 {...} 321

? Q("1234567890987654321").ShortenedNUsing(5, " {...} ")
#--> 12345 {...} 54321

proff()
# Executed in 0.03 second(s)

/*=============

pron()

o1 = new stzString("aa***aa**aa***aa")
? o1.IsBoundedByCS("aa", TRUE)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.BoundedBy("aa") )
#--> [ "***", "**", "***" ]

proff()
# Executed in 0.08 second(s)

/*----------------

pron()

o1 = new stzString("<<***>>**<<***>>")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 3, 5 ], [ 12, 14 ] ]

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzString("<<***>>**<<***>>")

? o1.Between("<<", :and = ">>")
#--> [ "***", "***" ]

? o1.BoundedBy(["<<", ">>"])
#--> [ "***", "***" ]

proff()
# Executed in 0.13 second(s)

/*----------------

pron()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.FindAnyBoundedBy("aa") )
#--> [ 3, 8, 12 ]

? @@( o1.FindAnyBoundedByAsSections("aa") )
#--> [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ]

proff()
# Executed in 0.10 second(s)

/*==============

pron()

o1 = new stzString("RINGORIALAND")

? o1.NumberOfSubStrings()
#--> 78

? @@S( o1.SubStrings() ) # S --> short : to show just a part of the long list
#--> [ "R", "RI", "RIN", ..., "N", "ND", "D" ]

proff()
#--> Executed in 0.01 second(s)

/*=============

pron()

o1 = new stzString("BEBE")

? o1.NumberOfSubStringsU()
#--> 7

? @@( o1.SubStringsU() )
#-< [ "B", "BE", "BEB", "BEBE", "E", "EB", "EBE" ]

proff()
# Executed in 0.01 second(s)

/*----------------

pron()

o1 = new stzString("BEbe")

? o1.NumberOfSubStringsCS(TRUE)
#--> 10

? @@( o1.SubStringsCS(TRUE) )
#--> [ "B", "BE", "BEb", "BEbe", "E", "Eb", "Ebe", "b", "be", "e" ]

? o1.NumberOfSubStringsCS(FALSE)
#--> 7

? @@( o1.SubStringsCS(FALSE) )
#--> [ "b", "be", "beb", "bebe", "e", "eb", "ebe" ]


proff()
# Executed in 0.01 second(s)
/*----------------

pron()

o1 = new stzString("HELLOhello")

? o1.NumberOfSubStringsCS(TRUE)
#--> 55

? @@S( o1.SubStringsCS(TRUE) ) + NL
#--> [ "H", "HE", "HEL", "...", "l", "lo", "o" ]

? o1.NumberOfSubStringsCS(FALSE)
#--> 39

? @@S( o1.SubStringsCS(FALSE) ) + NL
#--> [ "h", "he", "hel", "...", "ohel", "ohell", "ohello" ]

? @@( o1.FindSubStringsCS(FALSE) ) + NL
#--> [ 1, 2, 3, 4, 5 ]

? @@S( o1.SubStringsCSZ(FALSE) ) + NL
#--> [
#	[ "h", [ 1, 6 ] ],
#	[ "he", [ 1, 6 ] ],
#	[ "hel", [ 1, 6 ] ],
#	"...",
#	[ "ohel", [ 5 ] ],
#	[ "ohell", [ 5 ] ],
#	[ "ohello", [ 5 ] ]
# ]

? @@S( o1.FindSubStringsCSZZ(FALSE) ) + NL
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], "...", [ 5, 8 ], [ 5, 9 ], [ 5, 10 ] ]

? @@S( o1.SubStringsCSZZ(FALSE) ) + NL
#--> [
#	[ "h", [ [ 1, 1 ], [ 6, 6 ] ] ],
#	[ "he", [ [ 1, 2 ], [ 6, 7 ] ] ],
#	[ "hel", [ [ 1, 3 ], [ 6, 8 ] ] ],
#	"...",
#	[ "ohel", [ [ 5, 8 ] ] ],
#	[ "ohell", [ [ 5, 9 ] ] ],
#	[ "ohello", [ [ 5, 10 ] ] ]
# ]

? o1.NumberOfSubStringsOfNCharsCS(4, FALSE)
#--> 7

? @@( o1.SubStringsOfNCharsCS(4, FALSE) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel", "hell", "ello" ]

? o1.NumberOfSubStringsOfNCharsCSU(4, FALSE) + NL
#--> 5

? @@( o1.SubStringsOfNCharsCSU(4, FALSE) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel" ]

? @@( o1.SubStringsW('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ "Ohello", "hello", "ello" ]	# Takes 0.20 second(s)

? @@( o1.SubStringsWZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ [ "Ohello", [ 5 ] ], [ "hello", [ 6 ] ], [ "ello", [ 7 ] ] ]

? @@( o1.SubStringsWZZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
)
#--> [
#	[ "Ohello", [ [ 5, 10 ] ] ],
#	[ "hello", [ [ 6, 10 ] ] ],
#	[ "ello", [ [ 7, 10 ] ] ]
# ]

proff()
#Executed in 0.86 second(s)


/*==================

pron()

o1 = new stzString("RINGORIALAND")
? o1.Duplicates()

#--> [ "R", "RI", "I", "N", "A" ]

proff()
#--> Executed in 0.22 second(s)

/*=============

pron()

? Q("ABCDE")[-2]
#--> D

proff()
# Executed in 0.03 second(s)

/*=============

pron()

o1 = new stzString("Ringprogramminglanguageispowerful!")
//o1.InsertAfterPositions([ 4, 15, 23, 25], " ")
o1.InsertBeforePositions([ 5, 16, 24, 26], " ")
#--> Ring programming language is powerful!

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

o1 = new stzString("Ringprogramminglanguageispowerful!")

o1.SpacifySections([ [ 5, 15 ], [ 24, 25 ] ])
? o1.Content()
#--> Ring programming language is powerful!

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzString("Ringprogramminglanguageispowerful!")
o1.SpacifySubStrings([ "programming", "is" ])
? o1.Content()
#--> Ring programming language is powerful!

proff()
# Executed in 0.27 second(s)

/*=============

pron()

? Q(:stzListsOfStrings).IsPluralOfAStzType()
#--> TRUE

proff()

/*=============

pron()

o1 = new stzString("ABC")
o1.ExtendWith("DE")
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendToNChars(5)
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendToWith(5, "*")
o1.Show()
#--> "ABC**"

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("123")
o1.ExtendToWithCharsRepeated(8)
o1.Show()
#--> "12312312"

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("123")
o1.ExtendToWithCharsIn( 8, "1":"3" )
o1.Show()
#--> "12312312"

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :With = "DE" )
o1.Show()
#--> "ABCDE"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :ToPosition = 5 )
o1.Show()
#--> "ABC  "

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
o1.Show()
#--> "ABCAB"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :ByCharsRepeated )

o1.Show()
#--> "ABCAB"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = "*" )
o1.Show()
#--> "ABC**"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :WithCharsIn = [ "D", "E" ])
o1.Show()
#--> "ABCDED"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("ABCDE")
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> "ABC"

proff()
# Executed in 0.05 second(s)

/*===============

pron()
#                     3  6  9  2
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.SubStringsW('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ "♥^^♥", "^♥♥^" ]

proff()
# Executed in 1.98 second(s)

/*--------------

pron()
#                     3  6  9  2 
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.FindSubStringsAsSectionsW('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ [ 3, 6 ], [ 9, 12 ] ]

proff()
# Executed in 1.92 second(s)

/*=============

pron()

o1 = new stzString("...♥...♥...")
? o1.FindW('@char = "♥"')
#--> [4, 8]

proff()
# Executed in 1.69 second(s)

/*============

pron()

o1 = new stzString("abCDE")

? o1.First2Chars()
#--> [ "a", "b" ]

? o1.First2CharsAsString()
#--> "ab"

? o1.Last3Chars()
#--> [ "C", "D", "E" ]

? o1.Last3CharsAsString()
#--> "CDE"

? o1.Next3Chars(:StartingAt = 3)
#--> [ "C", "D", "E" ]

? o1.Next3CharsAsString(:StartingAt = 3)
#--> "CDE"

proff()
# Executed in 0.07 second(s)

/*=========

pron()

o1 = new stzString("aaA...")

? o1.FindCS("a", :CaseSensitive) # Or :IsCaseSensitive or :CS or :IsCS
				 # or TRUE or TRUE or TRUE
#--> [1, 2]

? o1.FindCS("a", :CaseInSensitive) # Or :NotCaseSensitive or :NotCS
				   # or :IsNotCaseSensitive  or :IsNotCS
				   # or :CaseSensitive = FALSE
				   # or :CS = FALSE
				   # or FALSE
#--> [1, 2, 3]

proff()
# Executed in 0.05 second(s)

/*=========

pron()

o1 = new stzString("softanza")
? o1.Section(4, 6)
#--> "tan"

? o1.Section(6, 4)
#--> "tan"

proff()
# Executed in 0.03 second(s)

/*----

pron()

o1 = new stzList([ "s", "o", "f", "t", "a", "n", "z", "a" ])
? @@( o1.Section(4, 6) )
#--> [ "t", "a", "n" ]

? @@( o1.Section(6, 4) )
#--> [ "t", "a", "n" ]

proff()
# Executed in 0.07 second(s)

/*==========

pron()

o1 = new stzString("..3..♥..♥..2..")
? o1.FindInSection("♥", 3, 12)
#--> [6, 9]

? o1.FindInSection("♥", 12, 3)
#--> [6, 9]

proff()
# Executed in 0.06 second(s)

/*=========

pron()

o1 = new stzString("---|ABC|---|ABC|---")

? @@( o1.FindBetweenAsSections("ABC", "|", "|") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindBoundedByAsSections("ABC", '|') )
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
# Executed in 0.12 second(s)

/*=========

pron()

o1 = new stzString(' this code:   txt1  =   "    withspaces    " and txt2  =  "nospaces"  ')
o1.SimplifyExcept( o1.FindAnyBoundedByAsSections('"') )

? o1.Content()

#--> 'this code: txt1 = "    withspaces    " and txt2 = "nospaces"'

proff()
# Executed in 0.08 second(s)


/*-----------

pron()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? @@( o1.Duplicates() )
#--> [ "*", "4" ]

proff()
# Executed in 0.17 second(s)

/*----------

pron()

o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 12

? o1.Duplicates()
#--> [ "r", "ri", "rin", "ring", "i", "in", "ing", "n", "ng", "g", " ", "p" ]

proff()
# Executed in 1.32 second(s)

/*----------

pron()

o1 = new stzString("RINGORIALAND")

# Are there any duplicated substrings in this string?
? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.35 second(s)

# The number of duplicates is 5:
? o1.NumberOfDuplicates()
#--> 5
# Executed in 0.37 second(s)

# But, if we check their positions we get only 4 !
? @@( o1.FindDuplicates() )
#--> [ 6, 7, 10, 11 ]
# Executed in 0.45 second(s)

# The dupicates are effectively 5:
? @@( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]
# Executed in 0.45 second(s)

# To find an explication, let's use the DuplicatesAndTheirPositions()
# function, or use its short form DuplicatesZ()
? @@( o1.DuplicatesZ() )
#--> [ [ "R", 6 ], [ "RI", 6 ], [ "I", 7 ], [ "A", 10 ], [ "N", 11 ] ]
# Executed in 0.80 second(s)

# Hence we see that position 6 corresponds to two duplicated substrings: "R" and "RI"                                                                                                                             

proff()
# Executed in 2.20 second(s)

/*================

pron()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@( o1.FindBetweenAsSections( "hi!", "<<", ">>" ) )
#--> [ [ 8, 10 ], [ 29, 31 ] ]

? @@( o1.FindBetween( "hi!", "<<", ">>" ) )
#--> [ 8, 29 ]

proff()
# Executed in 0.19 second(s)

/*-----------------

pron()

? @@( Q("..<<--♥♥♥--♥♥♥-->>..<<---♥♥♥>>..").
	FindBetweenAsSections("♥♥♥", "<<", ">>") ) # Or Simply FindBetweenZZ()
#--> [ [ 7, 9 ], [ 12, 14 ], [ 26, 28 ] ]

proff()
# Executed in 0.12 second(s)

/*=========

pron()

o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")
? @@( o1.BetweenZ("<<", ">>") ) + NL
#--> [ [ "teeba", 5 ], [ "rined", 16 ], [ "teeba", 27 ] ]

? @@( o1.BetweenZZ("<<", ">>") )
#--> [ [ "teeba", [ 5, 9 ] ], [ "rined", [ 16, 20 ] ], [ "teeba", [ 27, 31 ] ] ]

proff()
#--> Executed in 0.17

/*---------

pron()

o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")
? @@( o1.BetweenZZ("<<", ">>") ) + NL
#--> [	[ "hi!", [3, 5] ],
#	[ "--♥♥♥--♥♥♥--", [ 12, 23 ] ],
#	[ "hi!", [ 30, 32 ] ]
# ]

? @@( o1.BetweenUZZ("<<", ">>") )
#--> [
#	[ "hi!", [ [ 3, 5 ], [ 30, 32 ] ] ],
#	[ "--♥♥♥--♥♥♥--", [ [ 12, 23 ] ] ]
# ]

proff()
#--> Executed in 0.20 second(s)

/*-------------

pron()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@( o1.SubStringsBetween("<<", ">>") )
#--> [ "--hi!--", "--", "hi!" ]

? @@( o1.BetweenZZ("<<", ">>") )
#--> [
#	[ "--hi!--", 	[  6, 12 ] ],
#	[ "--", 	[ 20, 21 ] ],
#	[ "hi!", 	[ 29, 31 ] ]
#]

proff()
#--> Executed in 0.14 second(s)

/*================

pron()

? Q("SOFTANZA").Section(:From = "F", :To = "A") #--> "FTA"

? Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A")
#--> ["F", "T", "A"]

proff()
# Executed in 0.10 second(s)

/*--------------

pron()

o1 = new stzString("1234567")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 543

? o1.Section(3, -3)
#--> 345

? o1.Section(-3, 3)
#--> 543

? o1.Range(3, 3)
#--> 345

? o1.Range(3, -3)
#--> 123

? o1.Range(-5, -3)
#--> 123

proff()
# Executed in 0.04 second(s)

/*===============

pron()

? Q("^^♥^^").ContainsAt(3, "♥")
#--> TRUE

? Q("^^♥^^").ContainsAt("♥", :Position = 3)
#--> TRUE

? Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsInSection("♥", 2, 4)
#--> TRUE

? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4)
#--> TRUE

? Q("^^♥^^").ContainsBoundedBy("♥", :Positions = [ 2, :And = 4])
#--> TRUE

? Q("^^♥^^").ContainsInSection("♥", 1, 3)
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsBefore("♥", :Position = 4)
#--> TRUE

? Q("^^^♥^").ContainsAfter("♥", 3)
#--> TRUE

? Q("--♥--^^").ContainsBefore("♥", :SubString = "^^")
#--> TRUE

? Q("--^^--♥^^").ContainsAfter("♥", "^^")
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 2)
? Q("^^♥^^").ContainsInSection("^", 5, 3)

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3)
#--> TRUE

? Q("--♥^^").ContainsXT("^", :AfterPosition = 2)
#--> TRUE

proff()
# Executed in 0.06 second(s)
 
/*-----------

pron()

? Q("^^♥^^").ContainsXT("^", :Before = 3)
#--> TRUE

? Q("--♥^^").ContainsXT("^", :After = 2)
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsXT("^", :BeforeSubString = "♥^")
#--> TRUE

? Q("--♥^^").ContainsXT("^", :AfterSubString = "-♥")
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

? Q("^^♥^^").ContainsXT("^", :Before = "♥^")
#--> TRUE

? Q("--♥^^").ContainsXT("^", :After = "-♥")
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*---------

pron()

? Q("^♥^^♥^^♥^").ContainsAtPositions([2, 5, 8], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsAtPosition("♥", 1)

proff()
# Executed in 0.03 second(s)

/*---------

pron()

? Q("♥^^♥^^♥").ContainsAt([1, 4, 7], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [1, 4, 7])
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*===================

pron()

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
# Executed in 0.11 second(s)

/*--------------

pron()

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
# Executed in 0.34 second(s)

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

pron()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
? @@( o1.FindAsSectionsXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ [ 6, 6 ], [ 14, 14 ] ]

proff()

/*----------

StartProfiler()

o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
//? o1.FindBetweenAsSections("♥♥♥", "/", "\")	# FindXT( "♥", :Between = ["/","\"], :AsSections )
#--> [ [2, 4], [15, 17] ]

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> [ [2, 4], [15, 17] ]

StopProfiler()
# Executed in 0.02 second(s)

/*==============

StartProfiler()

? Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", ["^^","^^"])
#--> TRUE

StopProfiler()
# Executed in 0.28 second(s)

/*=============

pron()

# Let's take this string of text:

o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")

# You may want to get the section between two positions:

? o1.Between(3, 5)
#--> ♥♥♥

# You can also say:
? o1.Section(3, 5)
#--> ♥♥♥
# But let's stick with the Between() function
# to see how mutch it is flexible...

# Ok. What if you want to get all the substrings bounded by << and >>:
? o1.Between("<<", ">>")
#--> ["♥♥♥", "stars", "♥♥♥"]

# They are 3, 2 of them are the same! No worry, you can get
# a unique instance of each of them by extending the function
# name by the "U" letter (for Unique):

? o1.BetweenU("<<", ">>")
#--> ["♥♥♥", "stars"]

# Sometimes, people have different interpretations for the
# term BETWEEN, and they may want to have the strings inbetween
# along with the bounds themselves...

# You can do it simply by adding the IB extensions to the name
# of the fuction ("IB" for "Include Bounds")

? o1.BetweenIB("<<", ">>")
#--> [ "<<♥♥♥>>", "<<stars>>", "<<♥♥♥>>" ]

# Oh, great! But "<<♥♥♥>>" is repeated twice...
# Well, you know how to manage it: just add the "U" extension:

 ? o1.BetweenIBU("<<", ">>")
#--> [ "<<♥♥♥>>", "<<stars>>", "<<♥♥♥>>" ]

proff()
# Executed in 0.15 second(s)

/*===============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<♥♥♥>>...")
? @@( o1.FindAnyBoundedByAsSectionsD([ "<<", ">>" ], :Backward) )
#--> [ [ 25, 27 ], [ 16, 17 ], [ 6, 8 ] ]

? @@( o1.FindAnyBoundedByAsSectionsS([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ 16, 17 ], [ 25, 27 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSD([ "<<", ">>" ], :StoppingAt = 10, :Backward) )
#--> [ [ 25, 27 ], [ 16, 17 ] ]
? @@( o1.FindAnyBoundedByAsSectionsSDIB([ "<<", ">>" ], :StoppingAt = 10, :Backward) )
#--> [ [ 23, 29 ], [ 14, 19 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSD([ "<<", ">>" ], :StoppingAt = 10, :Forward) )
#--> [ [ 6, 8 ] ]
? @@( o1.FindAnyBoundedByAsSectionsSDIB([ "<<", ">>" ], :StoppingAt = 10, :Forward) )
#--> [ [ 4, 10 ] ]

proff()
# Executed in 0.42 second(s)

/*--------------

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<--->>...")

? @@( o1.FindAnyBoundedByAsSectionsSDIB([ "<<",">>" ], :StoppingAt = 10, :Going = :Backward) )
#--> [ [ 23, 29 ], [ 14, 19 ] ]

? @@( o1.BoundedBySDIB([ "<<", ">>" ], :StoppingAt = 10, :Going = :Backward) )
#--> [ "<<--->>", "<<★★>>" ]

? @@( o1.FindAnyBoundedByAsSectionsSDIB([ "<<", ">>" ], :InSection = [4, 20], :Going = :Forward) )
#--> [ [ 4, 10 ], [ 14, 19 ] ]

? @@( o1.BloundedBySDIB( [ "<<", ">>" ], :InSection = [4, 20], :Going = :Forward) )
#--> [ "<<♥♥♥>>", "<<★★>>" ]

proff()
# Executed in 0.26 second(s)

/*----------------

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<--->>...")

? @@( o1.FindAnyBoundedbySDIB([ "<<",">>" ], :StoppingAt = 10, :Going = :Backward) )
#--> [ 23, 14 ]

? @@( o1.FindAnyBoundedBySDIB([ "<<", ">>" ], :InSection = [4, 20], :Going = :Forward) )
#--> [ 4, 14 ]

proff()
# Executed in 0.16 second(s)

/*-------------

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.BoundedByIB([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<★★>>" ]

? o1.BoundedBySIB([ "<<", ">>" ], :StartingAt = 10)
#--> [ <<★★>> ]

? o1.BoundedBySIB([ "<<", ">>" ], :StoppingAt = 10)
#--> [ <<♥♥♥>>]

? o1.BoundedBySIB([ "<<", ">>" ], :InSection = [4, 20])
#--> [ "<<♥♥♥>>", "<<★★>>" ]

proff()
# Executed in 0.20 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? @@( o1.FindAnyBoundedByAsSectionsIB("<<", ">>") )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSIB([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ 14, 20 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSIB([ "<<", ">>" ], :StoppingAt = 10) )
#--> [ [ 4, 10 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSIB([ "<<", ">>" ], :InSection = [4, 20]) )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

proff()
# Executed in 0.19 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? o1.FindAnyBoundedByIB([ "<<", ">>" ])
#--> [ 4, 14 ]

? o1.FindAnyBoundedBSIB([ "<<", ">>" ], :StartingAt = 10)
#--> [ 14 ]

? o1.FindAnyBoundedBSIB([ "<<", ">>" ], :StoppingAt = 10)
#--> [ 4 ]

? o1.FindAnyBoundedBSIB([ "<<", ">>" ], :InSection = [4, 20])
#--> [ 4, 14 ]

proff()
# Executed in 0.16 second(s)

/*=============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<--->>...")

? @@( o1.FindAnyBoundedByAsSectionsS([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ 16, 17 ], [ 25, 27 ] ]

? @@( o1.FindAnyBoundedByS([ "<<", ">>" ], :StartingAt = 10) )
#--> [ 16, 25 ]

? @@( o1.BoundedByS([ "<<", ">>" ], :StartingAt = 10) )
#--> [ "★★", "---" ]

? NL + "--" + NL

? @@( o1.FindAnyBoundedByAsSectionsSD([ "<<", ">>" ], :StartingAt = :LastChar, :Backward ) )
#--> [ [ 25, 27 ], [ 16, 17 ], [ 6, 8 ] ]

? @@( o1.FindAnyBoundedByAsSectionsSD([ "<<", ">>" ], :StartingAt = 10, :Going = :Backward ) )
#--> [ [ 6, 8 ] ]

? @@( o1.BoundedBySD([ "<<", ">>" ], :StartingAt = 10, :Going = :Backward ) )
#--> [ "♥♥♥" ]

? NL + "--" + NL

? @@( o1.BoundedBySDZ([ "<<", ">>" ], :StartingAt = 10, :Going = :Backward ) )
#--> [ [ "♥♥♥", 6 ] ]

? @@( o1.BoundedBySDZZ([ "<<", ">>" ], :StartingAt = 10, :Going = :Backward ) )
#--> [ [ "♥♥♥", [ 6, 8 ] ] ]

? NL + "--" + NL

? @@( o1.BoundedBySD([ "<<", ">>" ], :StartingAt = 10, :Forward) )
#--> [ "★★", "---" ]

? @@( o1.BoundedBySZ([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ "★★", 16 ], [ "---", 25 ] ]

? NL + "--" + NL

? @@( o1.BoundedBySZZ([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ "★★", [ 16, 17 ] ], [ "---", [ 25, 27 ] ] ]

? @@( o1.BoundedBySDZ([ "<<", ">>" ], :StartingAt = 10, :Forward) )
#--> [ [ "★★", 16 ], [ "---", 25 ] ]

? @@( o1.BoundedBySDZZ([ "<<", ">>" ], :StartingAt = 10, :Forward) )
#--> [ [ "★★", [ 16, 17 ] ], [ "---", [ 25, 27 ] ] ]

? NL + "--" + NL

? @@( o1.BoundedBySDIBZ([ "<<", ">>" ], :StartingAt = 10, :Forward) )
#--> [ [ "<<★★>>", 14 ], [ "<<--->>", 23 ] ]

? @@( o1.BoundedBySDIBZZ([ "<<", ">>" ], :StartingAt = 10, :Forward) )
#--> [ [ "<<★★>>", [ 14, 19 ] ], [ "<<--->>", [ 23, 29 ] ] ]

proff()
# Executed in 0.78 second(s)

/*=============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.BoundedBy([ "<<", ">>" ])
#--> [ "♥♥♥", "★★" ]

? o1.BoundedByS([ "<<", ">>" ], :StartingAt = 10)
#--> [ "★★" ]

? o1.BoundedByS([ "<<", ">>" ], :StoppingAt = 10)
#--> [ "♥♥♥" ]

? o1.BoundedByS([ "<<", ">>" ], :InSection = [4, 20])
#--> [ "♥♥♥", "★★" ]

proff()
# Executed in 0.16 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 6, 8 ], [ 16, 18 ] ]

? @@( o1.FindAnyBoundedByAsSectionsS([ "<<", ">>" ], :StartingAt = 10) )
#--> [ [ 16, 18 ] ]

? @@( o1.FindAnyBoundedByAsSectionsS([ "<<", ">>" ], :StoppingAt = 10) )
#--> [ [ 6, 8 ] ]

? @@( o1.FindAnyBoundedByAsSectionsS([ "<<", ">>" ], :InSection = [4, 20]) )
#--> [ [ 6, 8 ], [ 16, 18 ] ]

proff()
# Executed in 0.19 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? o1.FindAnyBoundedBy([ "<<", ">>" ])
#--> [ 6, 16 ]

? o1.FindAnyBBoundedByS([ "<<", ">>" ], :StartingAt = 10)
#--> [ 16 ]

? o1.FindAnyBoundedByS([ "<<", ">>" ], :StoppingAt = 10)
#--> [ 6 ]

? o1.FindAnyBoundedByS([ "<<", ">>" ], :InSection = [4, 20])
#--> [ 6, 16 ]

proff()
# Executed in 0.16 second(s)

/*=============

pron()

Q("♥♥♥ Ring programing language ♥♥♥") {

	ReplaceXT( :Each = "♥", [], :With = "*")
	? Content()
	#--> *** Ring programing language ***

	ReplaceXT("*", :With = "♥", [])
	? Content()
	#--> ♥♥♥ Ring programing language ♥♥♥
}

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

o1 = new stzString("_/♥\__/♥\__/♥♥__/♥\_")
o1.ReplaceXT(:Nth = 4, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("_♥♥\__/♥\__/♥\_")
o1.ReplaceXT(:First, "♥", :With = "/")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("_/♥\__/♥\__/♥♥_")
o1.ReplaceXT(:Last, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~") # Or :AtPosition
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.04 second(s)

/*--------------

pron()

o1 = new stzString("~♥/♥\~♥")
o1.ReplaceXT("♥", :AtPositions = [2, 7], :With = "~") # Or :AtPositions
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.06 second(s)

/*----------------

pron()

o1 = new stzString("bla bla <<♥♥♥>> and bla!")
o1.ReplaceXT( [], :Between = ["<<",">>"], :With = "bla" )
#--> bla bla <<bla>> and bla!

? o1.Content()

proff()
#--> Executed in 0.07 second(s)

/*============ ReplaceXT( ..., In = ..., :With = ... )

pron()

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
# Executed in 0.07 second(s)

/*========== REMOVE BETWEEN

StartProfiler()

	o1 = new stzString("__/♥\__")

	o1.RemoveBetween("♥", "/", "\")
	? o1.Content()
	#--> __/\__

StopProfiler()
# Executed in 0.02 second(s)

/*---------

StartProfiler()

	o1 = new stzString("__/♥\__")

	o1.RemoveBetweenIB("♥", "/", "\") # ..XT() -> Bounds are also removed
	? o1.Content()
	#--> ____

StopProfiler()
# Executed in 0.02 second(s)

/*==================

pron()

o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedBy(["/", "/"], "bla")
? o1.Content()
#--> bla bla /bla/ and /bla/!

o1 = new stzString("bla bla /.../ and /---/!")
o1.ReplaceAnyBoundedByIB(["/", "/"], "bla")
? o1.Content()
#--> bla bla bla and bla!

proff()
# Executed in 0.08 second(s)
 
/*----------------

pron()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
? o1.Content()
#--> bla bla /bla/ and bla!

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedByIB = '/', :With = "bla" )
? o1.Content()
#--> bla bla bla and bla!

proff()
#--> Executed in 0.12 second(s)

/*================ Find and AntiFind

pron()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

pron()
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

pron()

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

/*-------------------

pron()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 20, 43 ], [ 67, 84 ] ]

? @@( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

proff()
# Executed in 0.15 second(s)
/*================ Find and AntiFind

pron()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

pron()
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

pron()

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

/*================ Find and AntiFind

pron()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

pron()
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

pron()

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

pron()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 20, 43 ], [ 67, 84 ] ]

? @@( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

proff()
# Executed in 0.15 second(s)

/*================= BOUNDEDBY

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? o1.BoundedBy("&")
#--> [ "^^^", "vvv" ]

? o1.BoundedByIB("&")
#--> [ "&^^^&", "&vvv&" ]

? o1.BoundedByD("&", :Going = :Backward)
#--> [ "...", "..." ]

? o1.BoundedByDIB("&", :Going = :Backward)
#--> [ "&...&", "&...&" ]

proff()
# Executed in 0.10 second(s)

/*----------------

pron()
#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedByAsSectionsD("&", :Forward) )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindAnyBoundedByD("&", :Forward) )
#--> [ 5, 13 ]

? @@( o1.BoundedByD("&", :Going = :Backward) )
#--> [ "...", "..." ]

proff()
# Executed in 0.12 second(s)

/*----------------

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedByAsSectionsD("&", :Backward) )
#--> [ [ 9, 11 ], [ 17, 19 ] ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

#                   ...4.6...0.2...6.8...2.4...8.0...   
o1 = new stzString("...&&&^^^&&&...&&&vvv&&&...&&&...")

? @@( o1.FindAnyBoundedByAsSectionsD("&&&", :Backward) )
#--> [ [ 13, 15 ], [ 25, 27 ] ]

? @@( o1.FindAnyBoundedByAsSectionsDIB("&&&", :Backward) )
#--> [ [ 10, 18 ], [ 22, 30 ] ]

proff()
# Executed in 0.08 second(s)

/*----------------

pron()

#                   ...4.6...0.2...6.8...2.4...8.0...   
o1 = new stzString("...&&&^^^&&&...&&&vvv&&&...&&&...")

? @@( o1.FindAnyBoundedByAsSectionsDIB("&&&", :Forward) )
#--> [ [ 4, 12 ], [ 16, 24 ] ]

? @@( o1.BoundedByDIB("&&&", :Forward) )
#--> [ "&&&^^^&&&", "&&&vvv&&&" ]

? NL + "--" + NL

? @@( o1.FindAnyBoundedByAsSectionsDIB("&&&", :Backward) )
#--> [ [ 10, 18 ], [ 22, 30 ] ]

? @@( o1.BoundedByDIB("&&&", :Backward) )
#--> [ "&&&...&&&", "&&&...&&&" ]

proff()
# Executed in 0.14 second(s)

/*----------------

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedByAsSectionsDIB("&", :Forward) )
#--> [ [ 4, 8 ], [ 12, 16 ] ]

? @@( o1.BoundedByDIB("&", :Forward) )
# [ "&^^^&", "&vvv&" ]

? NL + "--" + NL

? @@( o1.FindAnyBoundedByAsSectionsDIB("&", :Backward) )
#--> [ [ 8, 12 ], [ 16, 20 ] ]

? @@( o1.BoundedByDIB("&", :Going = :Backward) )
#--> [ "&...&", "&...&" ]

proff()
#--> Executed in 0.14 second(s)

/*----------------

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByZ("&") )
# [
#	[ "^^^", [ 5  ] ],
#	[ "vvv", [ 13 ] ]
# ]

?  @@( o1.BoundedByZZ("&") )
# [
#	[ "^^^", [ [ 5, 7   ] ] ],
#	[ "vvv", [ [ 13, 15 ] ] ]
# ]

proff()
# Executed in 0.16 second(s)

/*----------------

pron()

#                   ..3...7..0...4..7...1..4...8..  
o1 = new stzString("..&^^^&..&^^^&..&---&..&---&..")

? @@( o1.BoundedByZ("&") )
#--> [
#	[ "^^^", [  4, 11 ] ],
#	[ "---", [ 18, 25 ] ]
# ]

? @@( o1.BoundedByZZ("&") )
#--> [
#	[ "^^^", [ [  4,  6 ], [ 11, 13 ] ] ],
#	[ "---", [ [ 18, 20 ], [ 25, 27 ] ] ]
# ]

proff()
# Executed in 0.18 second(s)

/*----------------

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? o1.FindAnyBoundedBy("&")
#--> [5, 13]

? o1.FindAnyBoundedByIB("&")
#--> [4, 12]

? NL + "--" + NL

? @@( o1.FindAnyBoundedByAsSections("&") )
#--> [ [ 5, 7 ], [ 13, 15 ] ]

? @@( o1.FindAnyBoundedByAsSectionsIB("&") )
#--> [ [ 4, 8 ], [ 12, 16 ] ]

proff()
# Executed in 0.09 second(s)

/*----------------

pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByIBZ("&") )
#--> [ [ "&^^^&", 4 ], [ "&vvv&", 12 ] ]

? @@( o1.BoundedByIBZZ("&") )
#--> [ [ "&^^^&", [ 4, 8 ] ], [ "&vvv&", [ 12, 16 ] ] ]

proff()
# Executed in 0.14 second(s)

/*----------------


pron()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByD("&", :Forward) )
#--> [ "^^^", "vvv" ]

? @@( o1.BoundedByD("&", :Backward) )
#--> [ "...", "..." ]

? NL + "--" + NL

? @@( o1.BoundedByDZ("&", :Forward) )
#--> [ [ "^^^", 5 ], [ "vvv", 13 ] ]

? @@( o1.BoundedByDZ("&", :Backward) )
#--> [ [ "...", 9 ], [ "...", 17 ] ]

? @@( o1.BoundedByDZZ("&", :Backward) )
#--> [ [ "...", [ 9, 11 ] ], [ "...", [ 17, 19 ] ]

? NL + "--" + NL

? @@( o1.BoundedByDIBZ("&", :Forward) )
#--> [ [ "&^^^&", 4 ], [ "&vvv&", 12 ] ]

? @@( o1.BoundedByDIBZZ("&", :Forward) )
#--> [ [ "&^^^&", [ 4, 8 ] ], [ "&vvv&", [ 12, 16 ] ] ]

? @@( o1.BoundedByDIBZ("&", :Backward) )
#--> [ [ "&...&", 8 ], [ "&...&", 16 ] ]

? @@( o1.BoundedByDIBZZ("&", :Backward) )
#--> [ [ "&...&", [ 8, 12 ] ], [ "&...&", [ 16, 20 ] ] ]

proff()
# Executed in 0.58 second(s)

/*-------------------

pron()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.SubStringsBoundedBy('"') )
#--> [
#	'<    leave spaces    >',
#	'< leave spaces >'
# ]

proff()
# Executed in 0.05 second(s)

/*===================

? Q([ "I", "believe", "in","Ring!" ]).ReduceXT('@string + " "')
#--> I believe in Ring!

proff()
#--> Executed in 0.93

/*------

pron()

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

/*------

pron()

? Q(["A", "B", "C"]).YieldWXT('[ @item, ascii(@item) - 64 ]')

proff()

/*------

pron()

? @@( Q("ring is owsome!").UppercaseQ().LettersQ().YieldWXT('[ @item, ascii(@item) - 65 ]') )
#--> [
#	[ "R", 17 ], [ "I", 8  ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]
proff()

/*=======

pron()
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
# Executed in 0.25 second(s)

/*------------

pron()
#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindFirst("<<<")
#--> 4

? @@( o1.FindFirstAsSection("<<<") )
#--> [4, 6]

proff()
# Executed in 0.02 second(s)

/*------------

pron()

#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindLast("<<<")
#--> 9

? @@( o1.FindLastAsSection("<<<") )
#--> [9, 11]

proff()
# Executed in 0.03 second(s)

/*------------

pron()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
? o1.FindPrevious("<<<", :StartingAt = 11)
#--> 4

? o1.Between("<<<", ">>>")
#--> ["ring", "softanza"]

proff()
# Executed in 0.07 second(s)

/*------------

StartProfiler()

o1 = new stzString('This[@i] = This[@i + 1] + @i - 2')
? o1.NumbersAfter("@i")
#--> [ "+1", "-2" ]

StopProfiler()
# Executed in 0.14 second(s)

/*------------

pron()

o1 = new stzString(" @i + 10, @i- 125, e11")
? o1.NumbersComingAfter("@i")
#--> [ "+10", "-125", "11" ]

proff()
# Executed in 0.11 second(s)

/*------------

pron()

o1 = new stzString("emm +   12_456.50 emm 11. and -   4.12_")
? o1.Numbers()
#--> [ "+12_456.50", "11", "-4.12" ]

proff()
# Executed in 0.19 second(s)

/*------------

pron()

o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
? @@( o1.ExtractNumbers() )
#--> [ "18", "16", "17.80" ]

? o1.Content()
#--> Math: , Geo: , :Physics: 

proff()
# Executed in 0.17 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.NumberOfChars()
#--> 1_897_793
# Executed in 0.02 second(s)

? oLargeStr.NumberOfLines()
#--> 34_627
# Executed in 0.02 second(s)

? oLargeStr.SplitQ(NL).NumberOfItems()
#--> 34_627
#--> Executed in 0.45 second(s)

StopProfiler()
# Executed in 0.85 second(s)

/*-----------
#WARNING: takes 14 seconds to complete!

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.Reverse()
? oLargeStr.Content()

StopProfiler()
# Executed in 14.56 second(s)

/*-----------
	
# Testing extreme cases in FindNthNext()/FindNthPrevious on a small string

StartProfiler()
#                   .2....7.9
o1 = new stzString("•••••••••")

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("x", :StartingAt = 1)
#--> 0

? o1.FindNthNext(6, "•", :StartingAt = 3)
#--> 9

? o1.FindNthNext(5, "•", :StartingAt = 1)
#--> 6


? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

? o1.FindNthPrevious(8, "•", :StartingAt = 9)
#--> 1

? o1.FindNthPrevious(3, "•", :StartingAt = 4)
#--> 1

StopProfiler()
# Executed in 0.12 second(s)

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
#--> 106563

? o1.FindNthNext(12, "HAN", :StartingAt = 250_000)
#--> 300537


? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

StopProfiler()
# Executed in 0.08 second(s)

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
# Executed in 0.03 second(s)

/*-----------

# Testing FindLast() on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars
? o1.Contains("جميل")
#--> FALSE

? o1.FindLast("جميل")
#--> FALSE

StopProfiler()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzString("123456789")

? o1.FirstHalf()
#--> 1234
? o1.SecondHalf()
#--> 56789

? o1.Halves() # Or Bisect()
#--> [ "1234", "56789" ]

? o1.FirstHalfXT()
#--> 12345
? o1.SecondHalfXT()
#--> 6789

? o1.HalvesXT() # Or BisectXT()
#--> [ "12345", "6789" ]


proff()
# Executed in 0.02 second(s)

/*============

pron()
   
o1 = new stzString("123456789")

# FIRST HALF

	? o1.FirstHalf()
	#--> 1234
	? o1.FirstHalfXT()
	#--> 12345
	
	? @@( o1.FirstHalfAndItsPosition() )
	#--> [ "1234", 1 ]
	? @@( o1.FirstHalfAndItsSection() )
	#--> [ "1234", [ 1, 4 ] ]
	
	? @@( o1.FirstHalfAndItsPositionXT() )
	#--> [ "12345", 1 ]
	? @@( o1.FirstHalfAndItsSectionXT() )
	#--> [ "12345", [ 1, 5 ] ]

# SECOND HALF

	? o1.SecondHalf()
	#--> 56789
	? o1.SecondHalfXT()
	#--> 6789
	
	? @@( o1.SecondHalfAndItsPosition() )
	#--> [ "56789", 5 ]
	? @@( o1.SecondHalfAndItsSection() )
	#--> [ "56789", [ 5, 9 ] ]
	
	? @@( o1.SecondHalfAndItsPositionXT() )
	#--> [ "6789", 6 ]
	? @@( o1.SecondHalfAndItsSectionXT() )
	#--> [ "6789",  [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@( o1.Halves() )
	#--> [ "1234", "56789" ]

	? @@( o1.HalvesXT() )
	#--> [ "12345", "6789" ]

	? @@( o1.HalvesAndPositions() )
	#--> [ [ "1234", 1 ], [ "56789", 5 ] ]

	? @@( o1.HalvesAndPositionsXT() )
	#--> [ [ "12345", 1 ], [ "6789", 6 ] ]

	? @@( o1.HalvesAndSections() )
	#--> [ [ "1234", [ 1, 4 ] ], [ "56789", [ 5, 9 ] ] ]

	? @@( o1.HalvesAndSectionsXT() )
	#--> [ [ "12345", [ 1, 5 ] ], [ "6789", [ 6, 9 ] ] ]

proff()

/*==============

pron()

#                      4     0     6    1
o1 = new stzString("---***---***---***---")

? o1.HowMany("***")
#--> 3

? o1.Nth(3, "***")
#--> 16

? o1.FindLast("***")
#--> 16

proff()
# Executed in 0.02 second(s)

/*=============

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.FindLast(";")
#--> 1897793

StopProfiler()
# Executed in 12.99 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? @@( oLargeStr.FindAll("ALIF") )

? oLargeStr.Contains("ALIF")
#--> TRUE

? oLargeStr.FindFirst("ALIF")
#--> 130655

? oLargeStr.NumberOfOccurrence("ALIF")
#--> 4

? oLargeStr.FindNth(4, "ALIF")
#--> 1703275

? oLargeStr.FindLast("ALIF")
#--> 1703275

StopProfiler()
# Executed in 0.06 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.Contains("Plane 15 Private Use")
#--> TRUE
# Executed in 0.02 second(s)

? oLargeStr.HowMany("Plane 15 Private Use")
#--> 2
# Executed in 0.03 second(s)

? oLargeStr.FindAll("Plane 15 Private Use")
#--> [ 1_897_586, 1_897_640 ]
# Executed in 0.02 second(s)

? oLargeStr.FindFirst("Plane 15 Private Use")
#--> 1_897_586
# Executed in 0.02 second(s)

? oLargeStr.FindLast("Plane 15 Private Use")
#--> 1897640
# Executed in 0.04 second(s)

StopProfiler()
#--> Executed in 0.06 second(s)

/*-----------

StartProfiler()

#                    2    7
o1 = new stzString("•♥••••♥••")
//? o1.FindNthW(2, '@char = "♥"')
#--> 7
# Executed in 0.13 second(s)

? o1.FindNthW(2, '@substring = "•♥•"')
#--> 6

StopProfiler()
#--> Executed in 0.30 second(s)

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
# Executed in 0.18 second(s)

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Uppercased()
#--> I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").IsUppercase()
#--> TRUE

StopProfiler()
# Executed in 0.01 second(s)

/*----------

StartProfiler()

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").Lowercased()
#--> i believe in ring future and engage for it!

? Q("i believe in ring future and engage for it!").IsLowercase()
#--> TRUE

# As a side note, the last fuction used above (IsLowercase()) is
# misspelled (should be IsLowerCase() with an "r" after low),*
# but Softanza accepts it.

StopProfiler()
# Executed in 0.02 second(s)

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Capitalcased()
#--> I Believe In Ring Future And Engage For It!

? Q("I Believe In Ring Future And Engage For It!").IsCapitalcase()
#--> TRUE

StopProfiler()
# Executed in 0.05 second(s)

/*==================

pron()

o1 = new stzString("ABC*EF")
o1.QStringObject().replace(3, 1, "D")
? o1.Content()
#--> "ABCDEF"

proff()
# Executed in 0.02 second(s)

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")

o1.ReplaceCharAt( :Position = 4, :By = "D")
? o1.Content()
#--> "ABCDEF"

StopProfiler()
# Executed in 0.02 second(s)

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")
o1.ReplaceSection( 4, 4, "D")
? o1.Content()
#--> ABCDEF

StopProfiler()
#--> Executed in 0.01 second(s)

/*===========

pron()

? Q("121212").IsMadeOf("12")
#--> TRUE

? Q("984332").IsMadeOfNumbers()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

o1 = new stzString("ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

? o1.Lines()[3]
#--> "123346"

? Q( o1.Lines()[3] ).IsMadeOfNumbers()
#--> TRUE

proff()
# Executed in 0.05 second(s)

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

o1.TrimQ().RemoveLinesW(' Q(@line).IsMadeOfNumbers() ')
? @@(o1.Content())
#-->
# "ABCDEF
#  GHIJKL
#  MNOPQU
#  RSTUVW"

StopProfiler()
# Executed in 0.14 second(s)

/*=============

StartProfiler()

o1 = new stzString("I love <<Ring>> and <<Softanza>>!")

# Finding the positions of substrings enclosed between << and >>
? @@( o1.FindanyBoundedBy([ "<<",">>" ]) )
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

	? @@( o1.AnyBoundedByIB([ "<<",">>" ]) )
	#--> [ <<Ring>>, <<Softanza>> ]

StopProfiler()
#--> Executed in 0.12 second(s)

/*-----------

pron()

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
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
? o1.Spacified()
#--> 9 9 9 9 9 9 9 9 9 9 9 

//? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
o1.SpacifyXT( "_", 3, :Backward )
# Or you can be explicit and name the params like this:
# //o1.SpacifyXT( :Using = "_", :Step = 3, :Direction = :Backward )

? o1.Content()
#--> 99_999_999_999

proff()
# Executed in 0.03 second(s)

/*----------

StartProfiler()

o1 = new stzString("9999999999")
o1.SpacifyXT(
	:Using     = [ ".", :AndThen = " " ],
	:Step      = [ 2, :AndThen = 3],
	:Direction = :Backward
)

? o1.Content()
#--> 99 999 999.99

StopProfiler()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzString(" so ftan  za ")
o1.Unspacify()
? o1.Content()
#--> so ftan  za

proff()
# Executed in 0.01 second(s)

/*--------------

pron()

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

pron()

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
# Executed in 0.01 second(s).

/*--------------

pron()

o1 = new stzSplitter(1:12)

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

pron()

o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")
? @@( o1.SplitAtSections([ [ 1, 8 ], [ 29, 34 ] ]) )
#--> [ "r  in  g", "r  ing" ]

proff()
# Executed in 0.08 second(s).

/*--------------

pron()

o1 = new stzString("Softanza is an acc  elera tive library f   or Ring.")

? @@( o1.FindZZ([ "acc  elera tive", "f   or" ]) )
#--> [ [ 16, 30 ], [ 40, 45 ] ]

o1.RemoveSpacesInSections([ [ 16, 30 ], [ 40, 45 ] ])
? o1.Content()
#--> Softanza ia an accelerative library for Ring.

proff()
# Executed in 0.06 second(s).

/*--------------

pron()

o1 = new stzString("Sof tan za is an acc  elera tive library for Rin g .")

? @@( o1.FindZZ([ "Sof tan za", "acc  elera tive", "Rin g ." ]) )
#--> [ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ]

o1.RemoveSpacesInSections([ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ])
? o1.Content()
#--> Softanza is an accelerative library for Ring.

proff()
# Executed in 0.06 second(s).

/*--------------

pron()

o1 = new stzString("R  in  g language is like a r  ing at your fingertips!")

? o1.Sections([ [ 1, 8 ], [ 29, 34 ] ])
#--> [ "R  in  g", "r  ing" ]

o1.RemoveSpacesInSections([ [ 1, 8 ], [ 29, 34 ] ])
? o1.Content()
#--> "Ring language is like a ring at your fingertips!"

proff()
# Executed in 0.02 second(s).

/*--------------

pron()

o1 = new stzString("Ring langua  ge is like a r  ing at your fing er  tips!")

? @@( o1.FindZZ([ "langua  ge", "r  ing", "fing er  tips!" ]) )
#--> [ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ]

o1.RemoveSpacesInSections([ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ])
? o1.Content()
#--> Ring language is like a ring at your fingertips!

proff()

/*--------------

pron()

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

pron()
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

pron()

? Q("believe").IsStringOrList()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-------------- SUBSTRONGS & SUBSTRINKS #narration #funny

pron()

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

pron()

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

pron()

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

pron()

o1 = new stzString("99999999999")

o1.InsertXT("_", :EachNChars = 3)
//o1.InsertXT("_", [ :EachNChars = 3, :Forward ]) #TODO

? o1.Content()
#--> 999_999_999_99

proff()
# Executed in 0.05 second(s)

/*-------------

pron()

o1 = new stzString("123456789")

o1.InsertBefore([4, 7], "_") # or o1.InsertBeforePositions([4, 7], "_")
#--> 123_456_789

? o1.Content()
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

o1 = new stzString("123456789")

o1.InsertAfterPositions([3, 6], "_") # or o1.InsertAfterPositions([4, 7], "_")
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*------------- TODO

pron()

o1 = new stzString("123456789")

o1.InsertAfterEachNCharsXT(3, :StartingFrom = :End)
? o1.Content()
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*==============

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthPrevious(:Last, "♥♥♥", :StartingAt = 12)
#--> 3

? o1.FindNthPrevious(:First, "♥♥♥", :StartingAt = 12)
#--> 8

proff()
# Executed in 0.06 second(s)

/*============ Using ..Z() and ..ZZ() extensions

pron()

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

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindLast("♥♥♥")
#--> 22

? o1.FindLastAsSection("♥♥♥") 	#NOTE that the function is misspelled (there is an
#--> [22, 24]			#ERRonous "e" after "Last", but Softanza lets it go!

? o1.FindLastZ("♥♥♥")
#--> [ "♥♥♥", 22 ]

? o1.FindLastZZ("♥♥♥")
#--> [ "♥♥♥", [22, 24] ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

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

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthS(1, "♥♥♥", :StartingAt = 3)
#--> 3

? o1.FindNext("♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindPrevious("♥♥♥", :StartingAt = 10)
#--> 3

proff()
# Executed in 0.06 second(s)

/*================= Using ..S() and ..SD() extension

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

# Spacifying the starting prosition with the S extension
? o1.FindNthS(2, "♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindFirstS("♥♥♥", :StartingAt = 5)
#--> 8

? o1.FindLastS("♥♥♥", :StartingAt = 6)
#--> 13

#--- Spacifying the direction with SD extension

? o1.FindNthSD(2, "♥♥♥", :StartingAt = 10, :Going = :Backward)
#--> 3

? o1.FindFirstSD("♥♥♥", :StartingAt = 14, :Backward)
#--> 8

? o1.FindLastSD("♥♥♥", :StartingAt = 6, :Direction = :Backward)
#--> 3

proff()
# Executed in 0.15 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", 8 ]

? o1.FindFirstSZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", 8 ]

? o1.FindLastSZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 13 ]

proff()
# Executed in 0.08 second(s)

/*----------------- Using ..S() + ..D() + Z() extensions

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSDZ(2, "♥♥♥", :StartingAt = 10, :Backward)
#--> [ "♥♥♥", 3 ]

? o1.FindFirstSDZ("♥♥♥", :StartingAt = 5, :Backward)
#--> [ "♥♥♥", 3 ]

? o1.FindLastSDZ("♥♥♥", :StartingAt = :LastChar, :Backward)
#--> [ "♥♥♥", 3 ]

proff()
# Executed in 0.10 second(s)

/*-----------------

pron()

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

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSDZZ(2, "♥♥♥", :StartingAt = 3, :Direction = :Forward)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindFirstSDZZ("♥♥♥", :StartingAt = 5, :Direction = :Forward)
#--> [ "♥♥♥", [8, 10] ]

? @@(o1.FindLastSDZZ("♥♥♥", :StartingAt = 6, :Direction = :Forward))
#--> [ "♥♥♥", [13, 15] ]

proff()
# Executed in 0.05 second(s)

/*=================

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstS("♥♥♥", :StartingAt = 6)
#--> 8

? o1.FindLastS("♥♥♥", :StartingAt = 6)
#--> 13

? o1.FindNthS(2, "♥♥♥", :StartingAt = 6)
#--> 13

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 8 ]

? o1.FindLastSZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥"", 13 ]

? o1.FindNthSZ(2, "♥♥♥", :StartingAt = 6)
#--> #--> [ "♥♥♥"", 13 ]

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSZZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindLastSZZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥"", [13, 15] ]

? o1.FindNthSZZ(2, "♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥"", [13, 15] ]

proff()
# Executed in 0.16 second(s)

/*===============

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSD("♥♥♥", :StartingAt = 12, :Backward)
#--> 8

? o1.FindLastSD("♥♥♥", :StartingAt = 12, :Backward)
#--> 3

? o1.FindNthSD(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> 3

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", 8 ]

? o1.FindLastSDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥"", 3 ]

? o1.FindNthSDZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> #--> [ "♥♥♥"", 3 ]

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindLastSDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥"", [3, 5] ]

? o1.FindNthSDZZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥"", [3, 5] ]

proff()
# Executed in 0.26 second(s)

/*===========

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstAsSection("♥♥♥")
#--> [3, 5]

? o1.FindFirstAsSectionS("♥♥♥", :StartingAt = 5)
#--> [8, 10]

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstAsSectionD("♥♥♥", :Backward)
#--> [13, 15]

proff()
# Executed in 0.07 second(s)

/*=============

pron()
#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstD("♥♥♥", :Backward)
#--> 13

? o1.FindLastD("♥♥♥", :Backward)
#--> 3

? o1.FindNthD(2, "♥♥♥", :Backward)
#--> 8

? o1.FindD("♥♥♥", :Backward)
#--> [13, 8, 3 ]

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
? o1.FindFirstDZ("♥♥♥", :Backward)
#--> [ "♥♥♥", 13 ]

? o1.FindLastDZ("♥♥♥", :Backward)
#--> [ "♥♥♥", 3 ]

? o1.FindNthDZ(2, "♥♥♥", :Backward)
#--> [ "♥♥♥", 8 ]

? o1.FindDZ("♥♥♥", :Backward)
#--> [ "♥♥♥"", [ 13, 8, 3 ] ]

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstDZZ("♥♥♥", :Backward)
#--> [ "♥♥♥", [13, 15] ]

? o1.FindLastDZZ("♥♥♥", :Backward)
#--> [ "♥♥♥", [3, 5] ]

? o1.FindNthDZZ(2, "♥♥♥", :Backward)
#--> [ "♥♥♥", [8, 10] ]

? @@( o1.FindDZZ("♥♥♥", :Backward) )
#--> [ "♥♥♥"", [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ] ]

proff()
# Executed in 0.36 second(s)

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
/*
? @@( o1.Find( "♥♥♥" ) ) # or FindOccurrences( :Of = "♥♥♥" )
#--> [3, 8, 13 ]

? @@( o1.FindZ( :Of = "♥♥♥") )
#--> [ "♥♥♥", [3, 8, 13 ] ]

? @@( o1.FindZZ( :Of = "♥♥♥") )
#--> [ "♥♥♥", [ [3, 5], [8, 10], [13, 15] ] ]

proff()

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.FindD( "♥♥♥", :Backward ) )
#--> [ 13, 8, 3 ]

? o1.FindAsSectionsD( "♥♥♥", :Backward )
#--> [ [13, 5], [8, 10], [3, 5] ]

? @@( o1.FindDZ( "♥♥♥", :Backward) )
#--> [ "♥♥♥", [ 13, 8, 3 ] ]

? @@( o1.FindDZZ( "♥♥♥", :Backward) )
#--> [ "♥♥♥", [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ] ]

proff()

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindS( "♥♥♥", :StartingAt = 6 )
#--> [8, 13 ]

? @@( o1.FindSZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ "♥♥♥", [8, 13 ] ]

? @@( o1.FindSZZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ "♥♥♥", [ [8, 10], [13, 15] ] ]

proff()
# Executed in 0.11 second(s)

/*--------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindSD( "♥♥♥", :StartingAt = 6, :Backward )
#--> [8, 13 ]

? o1.FindSDZ( "♥♥♥", :StartingAt = 6, :Backward )
#--> [ "♥♥♥", [13, 8] ]

? @@( o1.FindAsSectionsSD("♥♥♥", :StartingAt = 6, :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ] ]

? @@( o1.FindSDZZ( "♥♥♥", :StartingAt = 6, :Backward ) )
#--> [ "♥♥♥", [ [ 13, 15 ], [ 8, 10 ] ] ]

proff()


/*-----------------

pron()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")
? o1.SplitQ("aa").IfQ('NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO: Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

proff()

/*-----------------

pron()

#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? o1.SplitQ("aa").IfQ('This.NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content()
#--> ["***", "**"]

#TODO: IfQ() function Needs more thinking, because the ELSE case should also be considered.
#--> A use case better suited for stzChainOfValue

proff()
# Executed in 0.03 second(s)

/*===============

pron()

o1 = new stzString("aa***aa**aa***")

? o1.FindAnyBetween("aa", "aa")
#--> 8

? o1.FindAnyBetweenAsSections("aa", "aa")
#--> [ 8, 9 ]

proff()
# Executed in 0.10 second(s)

/*---------------

pron()
#                     3    8   3
o1 = new stzString("**aa***aa**aa***")

? @@(o1.FindAnyBoundedByAsSectionsS("aa", "aa", 1))
#--> [ [ 5, 7 ], [ 10, 11 ] ]

? @@(o1.FindAnyBoundedByDZZ("aa", "aa", :Backward))
#--> [ [ 10, 11 ], [ 5, 7 ] ]

? @@(o1.FindAnyBoundedBySZZ("aa", "aa", :StartingAt = 3))
#--> [ [ 10, 11 ] ]

proff()
# Executed in 0.18 second(s)

#---------

pron()

#                        6
o1 = new stzString("*aa***aa**aa***aa*")

? @@( o1.FindAsSections("aa") )
# [ [ 2, 3 ], [ 7, 8 ], [ 11, 12 ], [ 16, 17 ] ]

? @@( o1.FindAsAntiSections("aa") )
# [ [ 1, 1 ], [ 4, 6 ], [ 9, 10 ], [ 13, 15 ], [ 18, 18 ] ]

? o1.ContainsXT( :SubString = "***", :BoundedBy = "aa") # Or ? o1.ContainsSubStringBoundedBy()
#--> TRUE

proff()
# Executed in 0.18 second(s)

#---------

pron()

#                        6
o1 = new stzString("*aa***aa**aa***aa*")
? @@( o1.FindAnyBetweenAsSections("aa", "aa") ) # o1.FindAnyBetweenAsSections("aa", "aa")
#--> [ [ 4, 6 ], [ 13, 15 ] ]

proff()

#---------

pron()
#                      4 6  90  3 5
o1 = new stzString("*aa***aa**aa***aa*")

? o1.FindAnyBetween("aa", "aa")
#--> [4, 9, 13]

? @@( o1.FindAnyBetweenAsSections("aa", "aa") )
#--> [ [ 4, 6 ], [ 9, 10 ], [ 13, 15 ] ]

proff()
# Executed in 0.15 second(s)

#---------

pron()
#                      4 6      3 5
o1 = new stzString("*<<***>>**<<***>>*")

? o1.FindAnyBetween("<<", ">>")
#--> [4, 13]

? @@( o1.FindAnyBetweenAsSections("<<", ">>") )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

? "--"

? o1.FindAnyBetweenIB("<<", ">>")
#--> [2, 11]

? @@( o1.FindAnyBetweenAsSections("<<", ">>") )
#--> [ [ 4, 6 ], [ 13, 15 ] ]

proff()
# Executed in 0.17 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindAnyBetween("67", :And = "12") ) # Same as o1.FindSubStringsBetween("67", "12")
#--> [ 8 ]

? @@( o1.FindBetween("♥♥♥", "67", :And = "12") ) # Same  as o1.FindSubStringsBetween( "♥♥♥", "67", "12")
#--> [ 8 ]

? @@( o1.FindXT( "♥♥♥", :Between = [ "67", :And = "12" ]) )
#--> [ 8 ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :Between = [ "67", :And = "12" ]) )
#--> [ [ 8, 10 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BetweenIB = [ "67", :And = "12" ]) )
#--> [ [ 6, 12 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :Between = [ "12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BetweenIB = [ "12", "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

#-----

? @@( o1.FindXT( "♥♥♥", :Between = ["12", :And = "67" ]) )
#--> [3, 13]

? @@( o1.FindAsSectionsXT( "♥♥♥", :Between = ["12", :And = "67" ]) )
#--> [ [ 3, 5 ], [ 13, 15 ] ]

? @@( o1.FindXT( "♥♥♥", :BetweenIB = ["12", :And = "67" ]) )
#--> [1, 11]

? @@( o1.FindAsSectionsXT( "♥♥♥", :BetweenIB = ["12", :And = "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

proff()
# Executed in 0.30 second(s)

/*---------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindAnyBetweenAsSectionsIB("12", "67") )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

? @@( o1.FindAnyBetweenAsSections("♥♥♥", "♥♥♥") )
#--> [ [ 6, 7 ] ]

proff()
# Executed in 0.09 second(s)

/*===================

pron()

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

? @@( o1.FindSD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ 8, 13 ]

? @@( o1.FindAsSectionsSD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ [ 8, 10 ], [ 13, 15 ] ]

#--

? @@( o1.FindSD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [8, 3]

? @@( o1.FindAsSectionsSD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.18 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindOccurrences( :Of = "♥♥♥" ) ) # Or FindAllOccurrences()
#--> [ 3, 8, 13 ]

? @@( o1.FindTheseOccurrences([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesXT()
#--> [ 8, 13 ]

? @@( o1.FindTheseOccurrencesAsSections([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesAsSectionsXT
#--> [ [ 8, 10 ], [ 13, 15 ] ]

? @@( o1.FindTheseOccurrencesS([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ 3, 8, 13 ]

? @@( o1.FindTheseOccurrencesAsSectionsS([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ [ 3, 5 ], [ 8, 10 ], [ 13, 15 ] ]

proff()
# Executed in 0.09 second(s)

/*-----------------

pron()

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

? @@( o1.FindTheseOccurrencesAsSectionsSD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

proff()
# Executed in 0.10 second(s)

/*================

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")


? o1.FindFirstS("♥♥♥", :StartingAt = 8)
#--> 22

? o1.FindLastS("♥♥♥", :Startingat = 8)
#--> 22

? o1.FindNthS(2, "♥♥♥", :StartingAt = 3)
#--> 22

proff()

/*---------------

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindAnyBetween("{", "}") ) + NL
#--> [ 23, 33 ]

? @@( o1.FindAnyBetweenAsSections("{", "}") ) + NL
#--> [ [ 23, 25 ], [ 33, 35 ] ]

StopProfiler()
# Executed in 0.10 second(s)

/*------------

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@( o1.FindAnyBetweenIB("{", "}") ) + NL
#--> [ 22, 32 ]

? @@( o1.AnyBetweenIBZ("{", "}") ) + NL
#--> [ [ "{min}", 22 ], [ "{max}", 32 ] ]

? @@( o1.AnyBetweenIBZZ("{", "}") )
#--> [ [ "{min}", [ 22, 26 ] ], [ "{max}", [ 32, 36 ] ] ]

StopProfiler()
# Executed in 0.24 second(s)

/*============

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}")
? @@( o1.Find([ "♥♥♥", "✤✤✤" ]) ) # or FindMany()
#-->[ 6, 22, 35 ]

? @@( o1.FindZ([ "♥♥♥", "✤✤✤" ]) ) + NL # or FindManyZ()
#--> [ [ "♥♥♥", [ 6, 22 ] ], [ "✤✤✤", [ 35 ] ] ]

? @@( o1.FindZZ([ "♥♥♥", "✤✤✤" ]) ) # or FindManyZZ()
#--> [
#	[ "♥♥♥",   [ [6, 8], [22, 24] ] ],
# 	[ "✤✤✤", [ [ 35, 37 ] ] ]
# ]

proff()
# Executed in 0.07 second(s)

/*==================================================
			 
 -------------------+--------+--------+-------+--------- 
        SPLITTING   |   At   | Before | After | Around  
 ===================+========+========+=======+========= 
      A Position    |   ✓   |   ✓   |   ✓   |   ...   
 -------------------+--------+--------+-------+---------
   Many Positions   |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------
      A SubString   |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------
   Many SubStrings  |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------
       Section	    |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------
    Many Sections   |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------
       Where        |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------


/*============ SPLITTING BEFORE

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@( o1.SplitBeforeCS("a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@( o1.SplitCS( :Before = "a", :CS = FALSE) )
#--> [ "__", "a__", "A__" ]

? @@( o1.Split( :Before = [ "a", "A" ] ) ) + NL
#--> [ "__", "a__", "A__" ]

o1 = new stzString("...♥...♥...")
? @@( o1.Split( :BeforePosition = 4 ) )
#--> [ "...", "♥...♥..." ]

? @@( o1.Split( :BeforePositions = [ 4, 8 ] ) )
#--> [ "...", "♥...", "♥..." ]

? @@( o1.Split( :BeforeSection = [ 4,  8 ] ) )
#--> [ "...", "♥...♥..." ]

o1 = new stzString("...♥♥♥..♥♥..")
? @@( o1.Split( :BeforeSections = [ [4, 6], [9, 10] ] ) )
#--> [ "...", "♥♥♥..", "♥♥.." ]

o1 = new stzString("...♥...♥...")
? @@( o1.SplitBeforeCharsWXT(' @char = "♥" ') )
#--> [ "...", "♥...", "♥..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitBeforeSubStringsWXT(' @SubString = "♥♥" ') )
#--> [ "...", "♥♥...", "♥♥..." ]

/*============ SPLITTING AT

pron()

# Splitting at a given substring with case sensitivity

o1 = new stzString("__a__A__")
? o1.SplitCS("a", :CS = FALSE)
#--> [ "__", "__", "__" ]

# Splitting at a given substring (without case sensitivity)

? @@( o1.Split("a") )
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

? @@( o1.Split( :AtSection = [ 4, 6 ] ) )
#--> [ "...", "..." ]

# Splitting at many sections

o1 = new stzString("...♥♥♥...♥♥...")
? o1.Split( :AtSections = [ [ 4, 6 ], [10, 11] ] )
#--> [ "...", "...", "..."]

# Splitting at a char described by a condition

o1 = new stzString("...♥...♥...")
? o1.SplitW('@char = "♥"')
#--> [ "...", "...", "..." ]

# Splitting at a substring described by a condition

o1 = new stzString("...♥♥...♥♥...")
? o1.SplitW('{ @SubString = "♥♥" }')
#--> [ "...", "...", "..." ]

o1 = new stzString("...ONE...TWO...ONE")
? o1.SplitW('{ @SubString = "ONE" or @SubString = "TWO" }')
#--> [ "...", "...", "..." ]

? o1.SplitW('{ Q(@SubString).IsOneOfThese([ "ONE", "TWO"]) }')
#--> [ "...", "...", "..." ]

? o1.SplitW('{ Q(@SubString).IsEither( "ONE", :Or = "TWO") }')
#--> [ "...", "...", "..." ]

proff()

/*============ SPLITTING AFTER

pron()

# Splitting before a given substring with case sensitivity

o1 = new stzString("__a__A__")
? @@( o1.SplitAfterCS("a", :CS = FALSE) )
#--> [ "__a", "__A", "__" ]

? @@( o1.SplitCS( :After = "a", :CS = FALSE) )
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
? @@( o1.SplitAfterW(' @char = "♥" ') )
#--> [ "...♥", "...♥", "..." ]

o1 = new stzString("...♥♥...♥♥...")
? @@( o1.SplitAfterW(' @SubString = "♥♥" ') )
#--> [ "...♥", "♥...♥", "♥..." ]

proff()
# Executed in 3.89 second(s)

/*==================

pron()

o1 = new stzString("...ONE...TWO...ONE")

? o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "ONE", "TWO", "THREE"

? o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ])
#--> [ "...", "...", "..." ]

proff()
# Executed in 0.07 second(s)

/*================

pron()

o1 = new stzString("...ONE...TWO...ONE")
? @@( o1.FindSubstringsW('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ 4, 10, 16 ]

? @@( o1.FindSubstringsAsSectionsW('{ @SubString = "ONE" or @SubString = "TWO" }') )
#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]

proff()
# Executed in 3.91 second(s)

/*-----------------

pron()

o1 = new stzString("...♥♥...♥♥...")

? @@( o1.FindSubStringsW('{ @SubString = "♥♥" }') )
#--> [ 4, 9 ]

? @@( o1.FindSubStringsAsSectionsW('{ @SubString = "♥♥" }') )
#--> [ [ 4, 5 ], [ 9, 10 ] ]

proff()
# Executed in 3.79 second(s)

#-----------

pron()

o1 = new stzString("..ONE..TWO..ONE..")

? o1.NumberOfSubStrings()
#--> 153

? o1.NumberOfUniqueSubStrings()
#--> 120

proff()
# Executed in 0.28 second(s)

#---------

pron()

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
# Executed in 0.19 second(s)

#========

pron()

? Q("one").IsEitherCS("ONE", :Or = "TWO", :CS = FALSE)
#--> TRUE

proff()

#=======

pron()

o1 = new stzString("<<word>> and __word__")
? @@( o1.BoundsXT( :Of = "word", :UpToNChars = 2 ) )
#--> [ [ "<<", ">>" ], [ "__", "__" ] ]

proff()
# Executed in 0.11 second(s)
	
#-------

pron()
	
o1 = new stzString("<<word>> and __word__")
? @@( o1.BoundsXT( :Of = "word", :UpToNChars = [ 2, 2 ]  ) )
#--> [ [ "<<", ">>" ], [ "__", "__" ] ]

proff()
# Executed in 0.11 second(s)
		
#-------

pron()

o1 = new stzString("<<word>>> and  _word__")
? @@( o1.BoundsXT( :Of = "word", :UpToNChars = [ [ 2, 3 ], [ 1, 2 ] ]  ) )
#--> [ [ "<<", ">>>" ], [ "_", "__" ] ]

proff()
# Executed in 0.09 second(s)

/*--------------

pron()

? Q(:IsBoundedBy = ".").IsISBoundedByNamedParam()
#--> TRUE

? Q(".♥.").SubStringIsBoundedBy("♥", ".")
#--> TRUE

? Q(".♥.").SubString("♥", :IsBoundedBy = ".")
#--> TRUE

proff()
# Executed in 0.17 second(s)

/*========================

#NOTE :
#	- RemoveNthItem(n) : Remove item at position n
#
#	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
# 	  (you can also use RemoveNthOccurrence(n, pItem)
#
#	- RemoveThisNthItem(n, pItem) : remove nth item only if it
#	  is equal to pItem

/*
o1 = new stzString("_ABC_DE_")

o1.RemoveFirstChar()
? o1.Content()
#--> ABC_DE_

o1.RemoveThisFirstCharCS("a", :CS = FALSE)
? o1.Content()
#--> BC_DE_

o1.RemoveNthChar(:Last) # Works when ChekParams() = TRUE (the default)
			# Otherwise use o1.RemoveLastChar() or
			# o1.RemoveNthChar(o1.NumberOfChars())
? o1.Content()
#--> BC_DE

o1.RemoveThisNthChar(3, "_")
? o1.Content()
#--> BCDE

/*========================

o1 = new stzString("ABC456DE")
o1.RemoveSection(4, 6)
? o1.Content()
#--> "ABCDE"

/*----------------------

o1 = new stzString("{HELLO}")
o1.RemoveFromStart("{")
? o1.Content()
#--> "HELLO}"

o1.RemoveFromEnd("}")
? o1.Content()
#--> "HELLO"

/*=================

StartProfiler()

o1 = new stzString("123456789")
o1.ReplaceSection(4, 6, :with = "♥♥♥")
? o1.Content()

StopProfiler()
#--> Executed in 0.02 second(s)

/*----------------

StartProfiler()

o1 = new stzString("ABcdeFG")

o1.ReplaceSection(3, 5, :By@ = 'Q(@EachChar).Uppercased()')
? o1.Content()
#--> ABCDEFG

StopProfiler()
#--> Executed in 0.28 second(s)

/*----------------

StartProfiler()

o1 = new stzList([ "A", "B", "c", "d", "e", "F" , "G" ])

o1.ReplaceSection(3, 5, :By@ = 'Q(@EachItem).Uppercased()')
? o1.Content()
#--> [ "A", "B", "C", "D", "E", "F", "G" ]

StopProfiler()
#--> Executed in 0.26 second(s)

/*===================

StartProfiler()

Q("Ring programmin language.") {

	AddXT("g", :After = "programmin") # You can use :To instead of :After
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.04 second(s)

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
# Executed in 0.04 second(s)

/*---------

StartProfiler()

Q("__♥)__♥)__♥)__") {

	AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.02 second(s)

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

pron()

o1 = new stzString("ab")
? @@( o1.CommonSubStrings(:With = "abc") )
#--> [ "a", "ab", "b" ]

proff()
# Executed in 0.08 second(s)

/*-------------

pron()

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

pron()

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

pron()

o1 = new stzString("abAb")

? o1.NumberOfSubStrings()
#--> 10
# Executed in 0.02 second(s)

? @@( o1.SubStrings() )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ]
# Executed in 0.04 second(s)

? o1.NumberOfSubStringsCS(FALSE)
#--> 7
# Executed in 0.12 second(s)

? @@( o1.SubStringsCS(FALSE) )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ]
# Executed in 0.12 second(s)

proff()
#--> Executed in 0.27 second(s)

/*----------

pron()

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

pron()

o1 = new stzString("hello")
? o1.NumberOfSubStringsCS(FALSE)
#--> 14

? @@( o1.SubStringsCS(FALSE) )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "lo",
#	"o"
# ]

proff()
# Executed in 0.54 second(s)

/*----------

pron()

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
# Executed in 0.05 second(s)

/*----------------

pron()

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
# Executed in 0.06 second(s)

/*==========

o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.NumbersComingAfter("@i")
#--> [ "-3", "3" ]

? o1.NumbersComingAfterQ("@i").Smallest()
#--> "-3"

? o1.NumbersComingAfterQ("@i").Greatest()
#--> "3"

/*----------

o1 = new stzString("@item = This[ @i+1 ]")
? o1.Numbers()
//? @@( o1.NumbersAfter("@i") )

/*=================

o1 = new stzString("123456789")
? o1.Section(3, -3)
#--> "34567"

/*=================
*
o1 = new stzString("... ____ ... ____")
? o1.Find("...")
#--> [ 1, 10 ]

? @@( o1.FindOccurrencesXT( :Of = "...", :AndReturnThemAs = :Positions ) )
#--> [ 1, 10 ]

? @@( o1.FindOccurrencesXT( :Of = "...", :AndReturnThemAs = :Sections ) )
#--> [ [ 1, 3 ], [ 10, 12 ] ]

/*----------------

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")
? @@( o1.Find("12.34") )
#--> [ 7, 39 ]
? @@( o1.FindAsSections("12.34") )
#--> [ [ 7, 11 ], [ 39, 43 ] ]

? @@( o1.FindManyAsSections([ "12.34", "-56.30", "77.12" ]) )
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

/*=================

pron()

o1 = new stzString("-23.67 pounds")
? o1.StartsWithANumber() # Or BeginsWith...
#--> TRUE

? o1.StartingNumber()
#--> "-23.67"

? o1.StartsWithThisNumber("-23.67") # OR StartsWithNumberN(...)
#--? TRUE

proff()

/*-----------------

pron()

o1 = new stzString("Amount: -132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithThisNumber("-132.45")
#--> TRUE

? o1.TrailingNumber()
#--> "-132.45"

proff()
# Executed in 0.07 second(s)

/*-----------------

pron()

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

//? o1.EndsWithNumber("+132.45")
#--> ERROR: Calling function with extra number of parameters

? o1.EndsWithNumberN("+132.45") #NOTE
				# the N a the end of function name
				# Or you can say EndsWithThisNumber(...)
#--> TRUE

? o1.TrailingNumber()
#--> "+132.45"

proff()
#--> Executed in 0.06 second(s)

/*-----------------

pron()

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithNumberN("132.45")
#--> TRUE

? o1.TrailingNumber()
#--> "+132.45"

proff()
# Executed in 0.06 second(s)s

/*==================

pron()

o1 = new stzList([ ".", ".", "M", ".", "I", "X" ])
? o1.FindWXT(' @char = "." ')
#--> [1, 2, 4]

proff()
# Executed in 0.17 second(s).

/*==============

pron()

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

pron()

o1 = new stzString("AB12CD345")
? @@( o1.SplitToPartsOfNChars(2) ) # Same as SplitToPartsOfExactlyNChars(2)
#--> [ "AB", "12", "CD", "34" ]

? @@( o1.SplitToPartsOfNCharsXT(2) )
#--> [ "AB", "12", "CD", "34", "5" ]

proff()
# Executed in 0.04 second(s).

/*===================

pron()

o1 = new stzString("ABC")
? @@( o1.SubStrings() )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

proff()
# Executed in 0.02 second(s).

/*------------------

pron()

o1 = new stzString("*#!ABC$^..")
? o1.NumberOfSubStrings()
#--> 55

? @@( o1.SubStringsWXT(' Q(@SubString).IsMadeOfLetters() ') )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

proff()
# Executed in 0.99 second(s).

/*==================

o1 = new stzList([ ".",".",".","4","5","6",".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 4)
#--> [ "4", "5", "6" ]

? o1.PreviousNItems(3, :StartingAtPosition = 6)
#--> [ "4", "5", "6" ]

/*------------------

o1 = new stzString("...456...")
? o1.NextNChars(3, :StartingAtPosition = 4)
#--> [ "4", "5", "6" ]

? o1.PreviousNChars(3, :StartingAtPosition = 6)
#--> [ "4", "5", "6" ]

/*================== 

StartProfiler()
#                      4   8 01  4 6 89  23
o1 = new stzString("...12..1212..121212..12.")
? @@( o1.FindMadeOf("12") )
#--> [ 4, 8, 10, 14, 16, 18 ]

? @@( o1.FindMadeOfAsSections("12") )
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

? @@( o1.SubStringsMadeOf("12") )
#--> [ "12", "1212", "121212", "12" ]

? @@( o1.SubStringsMadeOfXT("12") )
#--> [
#	[ "12", [ 4, 5 ] ],
#	[ "1212", [ 8, 11 ] ],
#	[ "121212", [ 14, 19 ] ],
#	[ "12", [ 22, 23 ] ]
# ]

StopProfiler()

/*=============

pron()

o1 = new stzSplitter(1:8)
? @@( o1.SplitAt([3, 5]) )
#--> [ [ 1, 2 ], [ 4, 4 ], [ 6, 8 ] ]

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? o1.FindW('This[@i] = "*"')
#--> [4, 7]
# Executed in 0.05 second(s)

? @@( o1.SplitAtPositions([ 4, 7]) )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]
# Executed in 0.03 second(s)

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? @@( o1.SplitW('This[@i] = "*"') )
# [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

? o1.FindWXT('@CurrentItem = "*"')
# Executed in 0.22 second(s)

? @@(o1.SplitWXT('@CurrentItem = "*"'))
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]
# Executed in 0.22 second(s)

proff()
# Executed in 0.44 second(s)

/*==============

o1 = new stzString("..._...__...___...")
? @@( o1.FindALL("_") )
#--> [ 4, 8, 9, 13, 14, 15 ]

? @@( o1.FindSubstringsMadeOf("_") )
#--> [ 4, 8, 13 ]

? o1.SubStringsMadeOf("_")
#--> [ "_", "__", "___" ]

STOP()

/*-----------------

o1 = new stzString("_-132__114.45_ euros")
? o1.Numbers()

/*
? o1.StartsWithANumber()
#--> TRUE

? o1.StartsWithNumber("-132114.45")
#--> TRUE
/*
? o1.LeadingNumber()
#--> +132.45

/*=================

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@( o1.Numbers() ) + NL
#--> [ "12.34", "-56.30", "12.34", "77.12" ]


? @@( o1.UniqueNumbers() )
#--> [ "12.34", "-56.30", "77.12" ]


? @@( o1.FindNumbers()) + NL
#--> [ 7, 21, 39, 55 ]

? @@( o1.NumbersAndTheirPositions() ) + NL
#-->
# [
# 	[ "12.34",  [ 7, 39 ] ],
#	[ "-56.30", [ 21 ]    ],
#	[ "77.12",  [ 55 ]    ]
# ]

? @@( o1.NumbersAndTheirSections() ) #TODO: Enhance performance!
#-->
# [
# 	[ "12.34", 	[ [ 7, 11 ], [ 39, 43 ]	] ],
#	[ "-56.30",	[ [ 21, 26 ] 		   	] ],
#	[ "77.12", 	[ [ 55, 59 ] 			] ]
# ]

? @@( o1.FindNumbersAsSections() ) + NL
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

/*================

StartProfiler()

o1 = new stzString( " This 10 : @i - 1.23 and this: @i + 378.12! " )
? o1.NumbersComingAfter("@i")
#--> [ "-1.23", "+378.12" ]

? o1.NthNumberComingAfter(2, "@i")
#--> "+378.12"

? o1.Numbers()
#--> [ "10", "-1.23", "+378.12" ]

StopProfiler()
# Executed in 0.51 second(s)

/*-----------------

pron()

o1 = new stzString( " This[ @i - 1 ] = This[ @i + 3 ] " )
? o1.NumbersComingAfter("@i")
#--> [ "-1", "+3" ]

proff()
#--> Executed in 0.14 second(s)

/*-----------------

? SoftanzaLogo()
/* --> 

╭━━━┳━━━┳━━━┳━━━━┳━━━┳━╮╱╭┳━━━━┳━━━╮
┃╭━╮┃╭━╮┃╭━━┫╭╮╭╮┃╭━╮┃┃╰╮┃┣━━╮━┃╭━╮┃
┃╰━━┫┃╱┃┃╰━━╋╯┃┃╰┫┃╱┃┃╭╮╰╯┃╱╭╯╭┫┃╱┃┃
╰━━╮┃┃╱┃┃╭━━╯╱┃┃╱┃╰━╯┃┃╰╮┃┃╭╯╭╯┃╰━╯┃
┃╰━╯┃╰━╯┃┃╱╱╱╱┃┃╱┃╭━╮┃┃╱┃┃┣╯━╰━┫╭━╮┃
╰━━━┻━━━┻╯╱╱╱╱╰╯╱╰╯╱╰┻╯╱╰━┻━━━━┻╯╱╰━

Programming, by Heart! By: M.Ayouni╭
━━╮╭━━━━━━━━━━━━━━━━━━━━╮╱╭━━━━━━━━╯
  ╰╯

/*-----------------

? Basmalah()	#--> ﷽
? Heart()	#--> ♥
? 3Hearts()	#--> ♥♥♥
? 5Stars()	#--> ★★★★★

/*-----------------

? Heart() #--> ♥
? Q(Heart()).RepeatedNTimes(3) #--> ♥♥♥
# or you can use the short form .NTimes(3)

? Q("Go").RepeatedNTimes(3) #--> GoGoGo

? @@( Q([ "A", "B" ]).RepeatedNTimes(3) )
#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

? Five(Star()) #--> ★★★★★
? Three(Heart()) #--> ♥♥♥
/*---

/*------------------

o1 = new stzString("{abc}")
o1.RemoveThisFirstChar("{")
o1.RemoveThisLastChar("}")
? o1.Content()

/*------------------

# When applied to the string "Hi!", RepeatedNTimes() will update
# it to become "Hi!Hi!Hi!".

? Q("Hi!").RepeatedNTimes(3)
#--> "Hi!Hi!Hi!"

# When used with all other types (stzList, stzNumber, and stzObject),
# it will repeat the object value inside a list:

? Q(5).RepeatedNTimes(3)
#--> [5, 5, 5]

? Q(1:3).RepeatedNTimes(3)
#--> [ 1:3, 1:3, 1:3 ]

# You my ask we we opted for a different behavior for
# strings compared to other types, and why we don't produce
# a list even when we use the function on a string, like this
# ? Q("Hi!").RepeatNTimes(3) #!--> [ "Hi!", "Hi!", "Hi" ] ?

# Well, because I think it's more natural to update the
# string when we ask to repeat it, and have a string as a
# result not a list!

# If you want to avoid any confusuion coming from this double-usage,
# rely on RepeatedXT() instead, and specify explicitly what
# you hant to have as an output, like this:

? Q("Hi!").RepeatedNTimesXT( 3, :InString)
#--> "Hi!Hi:Hi!

? Q("Hi!").RepeatedNTimesXT( 3, :InList)
#--> [ "Hi!", "Hi!", "Hi!" ]

/*----------------------

? Q("*").IsNotLetter()
#--> TRUE

/*----------------------

? Q("ONE-TWO-THREE").Split("-")
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE").SplitW('{ Q(@char).IsNotLetter() }')
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE") / W('Q(@char).IsNotLetter()')
#--> [ "ONE", "TWO", "THREE" ]

/*----------------------

# Five nice usecases of the / operator on a Softanza string:

# Usecase 1: Dividing the string into 3 equal parts
? Q("RingRingRing") / 3
#--> [ "Ring", "Ring", "Ring" ]

# Usecase 2: Splitting the string using a given char
? Q("Ring;Python;Ruby") / ";"
#--> [ "Ring", "Python", "Ruby" ]

# Usecase 3: Splitting the string on each char verifying a condition
? Q("Ring:Python;Ruby") / W('Q(@Char).IsNotLetter()')
#--> [ "Ring", "Python", "Ruby" ]

# Usecase 4: Sharing the string equally between three stakeholders
? Q("RingRubyJava") / [ "Qute", "Nice", "Good" ]
#--> [ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ]

# Usecase 5: Specifying how mutch char we should give to every stakeholder
? Q("IAmRingDeveloper") / [
	:Subject = 1,
	:Verb    = 2,
	:Noun1   = 4,
	:Noun2   = :RemainingChars
]
#--> [ :Subject = "I", :Verb = "Am", :Noun1 = "Ring", :Noun2 = "Developer" ]

/*---------------

? PLuralOfThisStzType("stzChar")
#--> "stzchars"

/*---------------

? Q("stzchars").IsPluralOfAStzType()
#--> TRUE

? Q("stzchars").IsPluralOfThisStzType("stzchar")

/*---------------

? Q("punctuation").InfereMethod(:From = :stzChar)
#--> "ispunctuation"

? Q("punctuations").InfereMethod(:From = :stzChar)
#--> "ispunctauion"

/*================= "What You Think Is What You Write"

# In plain english, when you see "12309" you would say
# "all chars are numbers". In Softanza, it's the same:
? Q("12309").AllCharsAre(:Numbers)
#--> TRUE

# For "248", yoou say "All chars are even positive numbers"
# In Softanza, it's exactly the same:
? Q("248").AllCharsAre([ :Even, :Positive, :Numbers ])
#--> TRUE

# In this example, "all chars are punctuations", right?
? Q(",:;").AllCharsAre(:Punctuations)
#--> TRUE

# And in this one, "all chars are arabic":
? Q("سلام").AllCharsAre(:Arabic)
#--> TRUE

# Yes, "all chars are arabic chars"!
? Q("سلام").AllCharsAre([ :Arabic, :Chars ])
#--> TRUE

# And yes, "all chars are right-to-left arabic chars"! 
? Q("سلام").AllCharsAre([ :RightToLeft, :Arabic, :Chars ])
#--> TRUE

# In fact, you can be as expressive as you want, and say:
# "all chars are right-to-left chars, where each char is an arabic char"!
# In Softanza, it's the same, exactly the same:
? Q("سلام").AllCharsAre([ :RightToLeft, :Chars, Where('Q(@EachChar).IsAnArabic()'), :Char ])
#--> TRUE

# In Softanza, "What You Think Is What You Write".

/*---

? Q("Riiiiinngg").UniqueChars() #--> [ "R", "i", "n", "g" ]

/*---

pron()

? StzListOfStringsQ([ "A", "A", "A", "B", "B", "C" ]).ContainsCS("a", :CS = FALSE)
#--> TRUE

proff()
# Executed in 0.03 second(s).

/*---

pron()

? StzListQ([ "A", "A", "A", "B", "B", "C" ]).DuplicatesRemoved()
#--> [ "A", "B", "C" ]

proff()
# Executed in almost 0 second(s).

/*---

pron()

? Q("Riiiiinngg").
	CharsQ().
	RemoveDuplicatesQ().
	ToStzListOfStrings().
	Concatenated()

#--> "Ring"

proff()
# Executed in 0.02 second(s).

/*---

pron()

? Q("Riiiiinngg").DuplicatedCharsRemoved()
#--> "Ring"

proff()
# Executed in 0.03 second(s).

/*===========

pron()

? Q("123.98").IsNumberInString()
#--> TRUE

? IsNumberInString("123.98")
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*----------

pron()

o1 = new stzString("(9, 7, 8)")

o1.RemoveCharsWXT('Q(@Char).IsNumberInString()')
? o1.Content()
#--> (, , )

proff()
# Executed in 0.18 second(s).

/*------

pron()

? Q("(9, 7, 8)").
	RemoveCharsWXTQ('Q(@Char).IsNumberInString()'). # becomes (, , )
	RemoveSpacesQ().			 	# becomes (,,)
	RemoveDuplicatedCharsQ().		 	# becomes (,)
	AllCharsAre(:Punctuations)
#--> TRUE

proff()
# Executed in 0.71 second(s).

/*--- TODO - FUTURE: Add a Qh() function (h for history) that traces the intermediate results:

pron()

? Qh("(9, 7, 8)").
	RemoveWQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	AllCharsAre(:Punctuations)
#--> [ "(, , )", "(,,)", "(,)", TRUE ]

proff()

/*-----------------

pron()

str = "sun"
? Q(str).IsEither("moon", :Or = "sun")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? Q("stzLen").IsAFunction() # or isFunc()
#--> TRUE

? Q("stzChar").IsAClass()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? QQ("ر").StzType()
#--> stzChar

? @@( QQ("ر").UnicodeDirectionNumber() )
#--> "13"

? QQ("ر").IsRightToLeft()
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*-----------------

pron()

? StzCharQ("L").Turned()
#--> ⅂

proff()
# Executed in 0.04 second(s).

/*-----------------

pron()

? Q("LOVE").Inverted()
#--> EVOL

? Q("LOVE").CharsInverted()	# Or Turned()
#--> ƎɅO⅂

? QQ("L").IsInvertible()	// #NOTE that QQ() elevates "L" to a stzChar
#--> TRUE

proff()
# Executed in 0.07 second(s).

/*-----------------

pron()

? Q("LOVE").Turned()
#--> ƎɅO⅂

proff()
# Executed in 0.05 second(s).

/*-----------------

pron()

? StzStringQ("s").IsAString()
#--> TRUE

? StzCharQ("s").IsAString()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? Q("str").AllCharsAre(:Chars)
#--> TRUE

? Q("str").AllCharsAre(:Strings)
#--> TRUE

? Q("123").AllCharsAre(:Numbers)
#--> TRUE

? Q("(,)").AllCharsAre(:Punctuations)
#--> TRUE

? Q("نور").AllCharsAre(:Arabic)
#--> TRUE

? Q("نور").AllCharsAre(:RightToLeft)
#--> TRUE

? Q("LOVE").AllCharsAre(:Invertible)
#--> TRUE

? Q("LOVE").CharsInverted()
#--> ƎɅO⅂

proff()
# Executed in 2.71 second(s).

/*-----------------

pron()

? Q(2).IsANumber()
#--> TRUE

? Q(2).IsEven()
#--> TRUE

? Q(2).IsPositive()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? QQ("①").IsCircledNumber()
#--> TRUE

# or QQ("①").IsCircledDigit() if you wana embrace the semantics of Unicode

proff()
# Executed in 0.03 second(s).

/*-----------------

pron()

? Q("①②③").AllCharsAre(:CircledNumbers)
#--> TRUE

? Q("①②③").AllCharsAre([:CircledNumber, :Chars]) #TODO check after reincluding check()
#--> TRUE

proff()

/*----------------- #TODO check after reincluding check()

pron()

? Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL)

? Q("123").Check( 'isnumber( 0+(@char) )' ) #--> TRUE

proff()

/*=================

pron()

# Inverting (or turning) chars and strings
#NOTE: In the mean time, Softanza uses Invert()
# and Turn() as alternatives, but this should
# change in the future to cope with their exact
# meaning in Unicode!

? StzCharQ("L").IsInvertible() # Or IsTurnable()
#--> TRUE

? StzCharQ("L").Inverted() # Or Turned()
#--> ⅂

? Q("LIFE").Inverted()
#--> EFIL

? Q("LIFE").Turned() # Or CharsInverted()
#--> ƎℲI⅂

proff()
# Executed in 0.07 second(s).

/*============

pron()

? Q(".;1;.;.;." ) / ";" # Same as: ? Q(".;1;.;.;." ).Splitted(:Using = ";")

#--> [ ".", "1", ".", ".", "." ]

proff()
# Executed in 0.01 second(s).

/*===============

pron()

? Q("Ring").Repeated(3)
#--> "RingRingRing"

? @@( Q([1,2]).Repeated(3) )
#--> [ [1,2], [1,2], [1,2] ]

proff()
# Executed in 0.03 second(s).

/*----------------

pron()

? Q("A").RepeatXTQ(:String, 3).StzType()
#--> "stzstring"

? Q("A").RepeatXTQ(:List, 3).StzType()
#--> "stzlist"

proff()
# Executed in 0.02 second(s).

/*---- #narration EXTENDED FORMS OF REPEATING OBJECTS IN SOFTANZA

pron()

# Repeating "5" twice in a list

? @@( Q("5").RepeatedXT(:InA = :List, :OfSize = 2) )
#--> [ "5", "5" ]

# Creating a pair with "A" repeated

? Q("A").RepeatedInAPair()
#--> [ "A", "A" ]

# Repeating "5" three times in a list of numbers

? @@( Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3) )
#--> [ 5, 5, 5 ]

# Repeating "5" three times in a string

? Q("5").RepeatedXT(:InA = :String, :OfSize = 3)
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

? @@( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]) )
#--> [
# [ "COL1", [ "A", "A", "A" ] ],
# [ "COL2", [ "A", "A", "A" ] ],
# [ "COL3", [ "A", "A", "A" ] ]
# ]

proff()
# Executed in 0.16 second(s).

/*-------------------

pron()

? Q(5).RepeatedInAPair()
#--> [5, 5]

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzString("ab_cd_ef_gh")

? o1.ContainsMoreThenN(1, "_")
#--> TRUE

? o1.ContainsMoreThenN(1, "a")
#--> FALSE

? o1.ContainsNTimes(1, "a")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

o1 = new stzString("ab_cd_ef_gh")
? o1.FindFirst("_")
#--> 3

? o1.FindFirstS("*", :StartingAt = 4)
#--> 0

? o1.FindFirstS("_", :StartingAt = 3)
#--> 3

? o1.FindLast("_")
#--> 9

? o1.FindLast("*")
#--> 0

? o1.FindNth(2,"_")
#--> 6

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

o1 = new stzString("ab_cd_ef_gh")

? o1.FindFirstNOccurrences(2, "_")
#--> [3, 6]
? o1.FindLastNOccurrences(2, "_")
#--> [6, 9]

proff()
# Executed in 0.03 second(s).

/*------------------

pron()

o1 = new stzString("ab_cd_ef_gh")
? o1.FindAll("_")
#--> [3, 6, 9]

proff()

/*=================

pron()

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

pron()

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

pron()

aStzStrList = StzListOfStringsQ([ "one", "two", "three" ]).ToListOfStzStrings()

foreach oStr in aStzStrList
	? oStr.Uppercased()
next
#-- [ "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.02 second(s).

/*----------------- #narration #data-cleansing #data-transformation

pron()

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

pron()

o1 = new stzString("How many <<many>> are there in (many <<<many>>>): so <many>>!")

? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, 2, 0, 3, [1,2] ])) + NL
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

//Same as:
? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ [0,0], [2, 2], [0,0], [3,3], [1,2] ]))
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

proff()

/*=================

o1 = new stzString("ACB")
o1.Move( :CharFromPosition = 3, :To = 2 )
? o1.Content() #--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> "ACB"

/*------------------

o1 = new stzListOfStrings([ "A", "C", "B" ])
o1.Move( :StringFromPosition = 3, :To = 2 )
? o1.Content() #--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> "ACB"

/*------------------

o1 = new stzList([ "A", "C", "B" ])
o1.Move( :ItemFromPosition = 3, :ToPosition = 2 )
? o1.Content() #--> [ "A", "B", "C" ]

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> [ "A", "C", "B" ]

/*------------------

pron()

o1 = new stzString("TWO, ONE, THREE!")
o1.SwapSubStrings("TWO", "ONE")
? o1.Content()
#--> ONE, TWO, THREE!

proff()
# Executed in 0.03 second(s)

/*=================

o1 = new stzString("*AB*")

? @@( o1.Find("*") )	#--> [1, 4]

# Or you can say:
? @@( o1.Find( :SubString = "*" ) )	#--> [1, 4]

# Or also:
? @@( o1.FindSubString( "*" ) )	#--> [1, 4]

# And many other alternatives that you can discover in the fucntion code

/*==================

? Q("NEXTAV TUNISIA").Section(:From = 1, :To = 6)
#--> "NEXTAV"

? Q("NEXTAV TUNISIA").Section(:From = (:NthToLastChar = 6), :To = :LastChar)
#--> "TUNISIA"

/*-----------------

? Q("SOFTANZA").NthToLast(3)
#--> "A"

/*-----------------

? Q("SOFTANZA").Section(1, 4)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = 1, :To = 4)
#--> "SOFT"

? Q("SOFTANZA").Section(4, 1)
#--> "TFOS"

? Q("SOFTANZA").Section(:From = :LastChar, :To = :FirstChar)
#--> "AZNATFOS"

? Q("SOFTANZA").Section(:From = (:NthToLastChar = 3), :To = :LastChar)
#--> "ANZA"

? Q("SOFTANZA").Section(:From = "F", :To = "A")
#--> "FTA"

? Q("SOFTANZA").Section( :From = "A", :To = :EndOfString )
#--> "ANZA"

? Q("Programming By Heart!
     This is Softanza motto.").
	Section( :From = "By", :To = :EndOfLine)
#--> "By Heart!"

? Q("SOFTANZA").Section(-99, 99)
#--> ""

? Q("SOFTANZA").Section(4, :@)
#--> "T"

? Q("SOFTANZA").Section(:NthToLast = 3, :@)
#--> "A"

? Q("SOFTANZA").Section(:@, :@)
#--> "SOFTANZA"

/*-----------------

o1 = new stzString("and **<Ring>** and _<<PHP>>_ AND <Python/> and _<<<Ruby>>>_ ANDand !!C++!! and")
? @@( o1.Split( :Using = "and" ) )
#--> [ "<Ring> ", " <<PHP>> ", " <Python/> ", " <<<Ruby>>> ", "", " !!C++!!" ]

/*----------------- TODO: FUTURE

? o1.SplitXT(
	:Using = "and",

	[ 
	TRUE,
	:SkipEmptyParts = TRUE,

	:IncludeLeadingSep = TRUE,
	:IncludeTrailingSep = TRUE,

	:ExcludeLeadingSubstrings_FromSplittedParts = [ "_", "**" ],
	
	:ExcludeTrailingSubstrings_FromSplittedParts = [ "_", "**", "/>" ],

	:ExcludeLeadingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, "<" ],
	:ExcludeTrailingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, ">" ]
	]
)

/*=================

# IDENTIFYING LISTS INSIDE A STRING

# In many situations (especially in advanced metaprogramming scenarios),
# you may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in real time, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used ( noramal [_,_,_] or short _:_ ), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,2,3]').IsListInString()		#--> TRUE

? StzStringQ('1:3').IsListInString()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInString()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInString()		#--> TRUE

# Softanza can tell you if the syntax used is normal or short:

? StzStringQ('[1,2,3]').IsListInNormalForm()		#--> TRUE
? StzStringQ('1:3').IsListInShortForm()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInShortForm()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInShortForm()		#--> TRUE

# And knows about the list beeing contiguous or not:

? StzStringQ('[1,3]').IsContiguousListInString()	#--> FALSE
? StzStringQ('1:3').IsContiguousListInString()		#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInString()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInString()	#--> TRUE

	# REMINDER: A contiguous list can be made of  numbers,
	# or contiguous chars (based on their unicode numbers).
	# And you can identify them using the stzList.IsContiguous():

	? StzListQ(1:3).IsContiguous()		#--> TRUE
	? StzListQ("A":"E").IsContiguous()	#--> TRUE


# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is contiguous
# or not, it can also see in what form they are:

? StzStringQ('[1,2,3]').IsContiguousListInNormalForm()	#--> TRUE
? StzStringQ('1:3').IsContiguousListInShortForm()	#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInShortForm()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm()	#--> TRUE

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,2,3]').ToListInShortForm() )	#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

? StzStringQ(' ["A","B","C","D"] ').ToListInShortForm()	#--> "A" : "D"
? StzStringQ(' "ا":"ج" ').ToListInShortForm()		#--> "ا" : "ج"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,2,3]').ToListInString() )	#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )	#--> "[1, 2, 3]"

? StzStringQ(' "A":"C" ').ToListInString()	#--> [ "A", "B", "C" ]
? StzStringQ(' "ا":"ج" ').ToListInString()	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# If you prefer (or need) the short form, there is an interesting
# abbreviation to the ToListInShortForm() alternative that uses
# the simple SF prefix (S for Short and F for Form), like this:

? @@( StzStringQ('[1,2, 3]').ToListInStringSF() ) 		#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInStringSF() )			#--> "1 : 3"

? StzStringQ(' ["A","B","C","D"] ').ToListInStringSF()		#--> "A" : "D"
? StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInStringSF() 	#--> "ا" : "ت"

# Finally, as a cherry on the cake, you can evaluate
# the string in list in real time like this:

? StzStringQ('1:3').ToList()	   	#--> [1, 2, 3]
? StzStringQ(' "A":"C" ').ToList() 	#--> ["A", "B", "C"]
? StzStringQ(' "ا":"ج" ').ToList() 	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

/*=================

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.SubstringsBoundedBy([ "<<", :and = ">>" ])
#--> [ "word", "noword", "word" ]

? o1.UniqueSubStringsBoundedBy("<<", :and = ">>")
#--> [ "word", "noword" ]

/*-----------------

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? o1.NumberOfOccurrence(:OfSubString = "many")
#--> 5
? @@( o1.Positions(:of = "many") ) + NL	# or o1.FindSubString("many")
#--> [5, 12, 33, 40, 54]

? @@(o1.Sections(:Of = "many")) + NL		# or o1.FindAsSections(:OfSubString = "many")
#--> [ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ], [ 40, 43 ], [ 54, 57 ] ]

	#NOTE that Sections() has an other syntax that returns, not the sections
	# as pairs of numbers as in the example above, the substrings corresponding
	# to the sections themselves:

	? o1.Sections([ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ] ])
	#--> [ "many", "many", "many" ]

? o1.NumberOfOccurrenceXT(
	:OfSubString = "many",
	:BoundedBy = ["<<", :and = ">>"]
	# or :Between = ["<<", :and = ">>"]
	# or :BetweenSubStrings = ["<<", :and = ">>"]
	# or :BoundedBySubStrings = ["<<", :and = ">>"]
)
#--> 3

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Section(8, 9)
#--> "<<"
? o1.Section(14, 16)
#--> ">>>"
? o1.Sections([ [8, 9], [14, 16] ])
#--> [ "<<", ">>>" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Section(50, 0)	#--> NULL
? o1.Section(0, 0)	#--> NULL
? o1.Section(-20, 10)	#--> NULL
? o1.Section(3, 3)	#--> "a"
? o1.Section(10, 13)	#--> "nice"
? o1.Section(13, 10)	#--> "ecin"

/*==================

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? @@( o1.BoundsXT( :Of = "many", :UpToNChars = 1 ) ) + NL
#--> [ [ " ", " " ], [ "<", ">" ], [ "(", " " ], [ "<", ">" ], [ "<", ">" ] ]

# Same as:
? @@( o1.BoundsXT( :Of = "many", :UpToNChars = [1, 1] ) ) + NL
#--> [ [ " ", " " ], [ "<", ">" ], [ "(", " " ], [ "<", ">" ], [ "<", ">" ] ]

? @@( o1.BoundsXT( :Of = "many", :UpToNChars = [ 0, 2, 0 ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ] ]

? @@( o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, 2, 0, 2, 2 ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ], [ "<<", ">>" ], [ "<<", ">>" ] ]

? @@( o1.BoundsXT(:Of = "many", :UpToNChars = [ [0,0], [2,2] ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ] ]

? @@( o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, [2,2], 0, 2, [2, 2] ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ], [ "<<", ">>" ], [ "<<", ">>" ] ]

/*----------

o1 = new stzString("what a <<<nice>>> day!")
? @@( o1.BoundsXT(:Of = "nice", :UpToNChars = 3) )
#--> [ [ "<<<", ">>>" ] ]

o1 = new stzString("what a <nice>>> day!")
? @@( o1.BoundsXT(:Of = "nice", :UpToNChars = [1, 3]) )
#--> [ [ "<", ">>>" ] ]

o1 = new stzString("what a <<nice>>> day! Really <nice>>.")
? @@( o1.BoundsXT(:Of = "nice", :UpToNChars = [ [2, 3], [1, 2] ]) )
#--> [ [ "<<", ">>>" ], [ "<", ">>" ] ]

/*==================

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ "<<", ">>>" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Sit(
	:OnPosition = 11, # the letter "i"
	:AndHarvest = [ :NCharsBefore = 1, :NCharsAfter = 2 ]
)
#--> { "n", "ce" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvestSections = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ [8, 9], [14, 16] ]

/*----------------- TODO

o1 = new stzString("what a 123nice>>> day!")

? o1.Sit(
	:OnSection  = o1.FindFirstSection("nice"),
	:AndHarvest = [ :CharsBeforeW = 'Q(@char).IsANumber()', :NCharsAfter = 3 ]
)
#--> [ "123", ">>>" ]

/*=================

o1 = new stzString("How many words in <<many many words>>? So many!")
? @@( o1.FindPositions(:Of = "many") )
#--> [ 5, 21, 26, 43 ]
? @@( o1.FindAsSections(:Of = "many") ) + NL
#--> [ [ 5, 8 ], [ 21, 24 ], [ 26, 29 ], [ 43, 46 ] ]

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? @@( o1.AnySubstringsBoundedBy([ "<<", :and = ">>" ]) )
#--> [ "word", "noword", "word" ]

? @@( o1.FindSubStringsBoundedBy([ "<<", :and = ">>" ]) ) + NL
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByAsSections([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 46 ] ]



/*----------------

o1 = new stzString("bla bla <<word1>> bla bla <<word2>> bla <<word3>>")
? o1.NthSubStringBoundedBy(2, [ "<<", ">>" ] ) #--> "word2"
# or you can say:
? o1.NthSubStringXT(2, :BoundedBy = ["<<", ">>"]) #--> "word2"

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.Nth(2, "word")		#--> 30
? o1.NthAsSection(2, "word")	#--> [ 30, 33 ]

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
? o1.FindNthBoundedBy(2, "word", [ "<<", ">>" ])
#--> 28
? o1.FindNthSectionBoundedBy(2, "word", [ "<<", ">>" ])
#--> [28, 31]

? o1.FindNthXT(2, "word", :BoundedBy = ["<<", ">>"])
#--> 28
? o1.FindNthSectionXT(2, "word", :BoundedBy = ["<<", ">>"])

/*================

o1 = new stzString("**word1***word2**word3***")
? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveSections([
	[1,2], [8, 10], [16, 17], [23, 25]
])

? o1.Content() #--> "word1word2word3"

/*----------------------

o1 = new stzString("**word1***word2**word3***")
? o1.Ranges([ [1,2], [8, 3], [16, 2], [23, 3] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveRanges([ [1,2], [8, 3], [16, 2], [23, 3] ])
? o1.Content()
#--> "word1word2word3"

/*-----------------

o1 = new stzString("..AA..aa..BB..bb")

o1.RemoveSectionsW(
	[ [3, 4], [7,8], [11,12], [15,16] ],
	:Where = '{ Q( @section ).IsLowercase() }'
)

? o1.Content()
#--> "..AA....BB.."

/*-----------------

o1 = new stzString("..AA..aa..BB..bb")

o1.RemoveRangesW(
	[ [3, 2], [7,2], [11,2], [15,2] ],
	:Where = '{ Q( @range ).IsLowercase() }'
)

? o1.Content()
#--> "..AA....BB.."

/*=================

o1 = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International 
")

o1.Simplify()

o1.RemoveCharsW('{ lower(@char) = "x" }')
? o1.Content()

#--> 	The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit
#	home computer introduced in January 1982 by Commodore International

/*=================

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE)
#--> [ 11, 43 ]

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindNthXT(2, "word", :BoundedBy = ["<<", ">>"])
#--> 43

? o1.FindNthSectionXT(2, "word", :BoundedBy = ["<<", ">>"])
#--> [43, 46]

? o1.FindNthXT(2, "word", :ReturnSection)

/*-----------------

o1 = new stzString("12*45*78*c")
? o1.FindAll("*")
#--> [3, 6, 9]

? o1.NFirstOccurrences(2, :Of = "*") 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = "*", :StartingAt = 5)
#--> [3, 6]

? o1.LastNOccurrencesXT(2, :Of = "*", :StartingAt = 2)
#--> [6, 9]

/*-----------------

o1 = new stzString("12abc67abc12abc")
? o1.FindAll("abc")
#--> [3, 8, 13]

#NOTE: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 8]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 1)
#--> [3, 8]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [8, 13]

? o1.NLastOccurrencesXT(2, "abc", :StartingAt = 1)
#--> [8, 13]


? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 6)
#--> [8, 13]

? o1.LastNOccurrencesXT(2, :Of = "abc", :StartingAt = 10)
#--> [8, 13]

/*=================

o1 = new stzString("**3**67**012**56**92**")
? @@( FindAnySeparatedBy("**") )
#--> [ 3, 6, 10, 15, 19 ]

? @@( o1.FindAnySeparatedByIB("**") )
#--> [ [3,3], [6, 7], [10, 12], [15,16], [19,20] ]

/*-----------------

pron()

o1 = new stzString("***ONE***TWO***THREE***")
? @@( o1.FindMany([ "ONE", "TWO", "THREE"]) )
#--> [ 4, 10, 16 ]

? @@( o1.SplitQ(:Using = "***").Content() )
#--> [ "", "ONE", "TWO", "THREE", "" ]
#TODO: Should we remove the "" from the result?

? @@( o1.FindAnyBoundedByIB("**") )
#--> [ 2, 8, 14 ]

? @@( o1.FindAnyBoundedByAsSectionsIB("**") )
#--> [ [ 2, 8 ], [ 8, 14 ], [ 14, 22 ] ]

proff()
# Executed in 0.14 second(s)

/*-----------------

pron()

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@( o1.FindAnyBetween("<<",">>") )
#--> [7, 20]

o1 = new stzString("*2*45*78*0*")

? @@( o1.FindAnyBetween("*","*") ) # Or o1.FindAnyBoundedBy("*") 
#--> [ 2, 4, 7, 10 ]

? @@( o1.FindAnyBoundedByIB("*") ) # Or o1.FindAnyBetweenIB("*", "*")
#--> [ 1, 3, 6, 9 ]

? @@( o1.AnyBoundedBy("*") )
#--> [ "2", "45", "78", "0" ]

? @@( o1.AnyBoundedByZZ("*") )
# [
#	[ "2", 	[ 2, 2 ] ],
#	[ "45", [ 4, 5 ] ],
#	[ "78", [ 7, 8 ] ],
#	[ "0", 	[ 10, 10 ] ]
# ]

proff()
# Executed in 0.31 second(s)

/*--------------

pron()

# For each one of the 3 function calls we made so far (see
# example above), you can get the result as sections and not
# as positions. To do so, just use the same functions while
# adding the keyword Sections like this:

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@( o1.FindAnyBetweenAsSections("<<",">>") )
#--> [ [ 7, 10 ], [ 20, 22 ] ]

o1 = new stzString("*2*45*78*0*")
? @@( o1.FindAnyBetweenAsSections("*","*") )
#--> [ [ 2, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.FindAnyBoundedByAsSectionsIB("*") )
#--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 9 ], [ 9, 11 ] ]

proff()
# Executed in 0.13 second(s)

/*-----------------

pron()

? @@( Q("txt <<ring>> txt <<ring>>").FindAnyBetweenAsSections("<<",">>") ) + NL
#--> [ [ 7, 10 ], [ 20, 23 ] ]

str = 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!'
? @@( Q(str).FindAnyBetweenAsSections('"', '"') ) + NL
#--> [ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]

? @@( Q(str).Sections([ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]) )
#--> [ "   val1  ", "   to  ", "   val2" ]

proff()
# Executed in 0.12 second(s)

/*-----------------

pron()

o1 = new stzString("12*♥*78*♥*")

? @@( o1.FindThisBetween("♥", "*","*") )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :Between = ["*", "*"]) )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :BoundedBy = "*" ) )
#--> [ 4, 9 ]

proff()
# Executed in 0.08 second(s)

/*-----------------

pron()

o1 = new stzString("12*45*78*90")
? o1.FindNthS(2, "*", :StartingAt = 4)
#--> 9

? o1.FindFirstS("*", :StartingAt = 4)
#--> 6

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

o1 = new stzString("12*A*33*A*")
? o1.FindAll("*")
#--> [3, 5, 8, 10]

? o1.FindNth(3, "*")
#--> 8

? o1.FindFirst("*")
#--> 3

? o1.FindLast("*")
#--> 10

? @@( o1.FindAsSections("*") )
#--> [ [ 3, 3 ], [ 5, 5 ], [ 8, 8 ], [ 10, 10 ] ]

proff()
# Executed in 0.05 second(s)

/*----------

pron()

o1 = new stzString("12*A*33*A*")
? o1.Sections([ 1:2, 6:7 ])
#--> [ "12", "33" ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("12*A*33*A*")
? @@( o1.FindBetween("A", "*", "*") )
#--> [4, 9]

? @@( o1.FindBetweenAsSections("A", "*", "*") )
#--> [ [4, 4], [9, 9] ]

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE)
#--> [ 11, 43 ]

? o1.FindBoundedByAsSections("word", [ "<<", ">>" ])
#--> [ [11, 14], [43, 46] ]

? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [ 11, 43 ]

proff()
# Executed in 0.07 second(s)

/*-----------------

pron()

#                       +----------------------+
#                       |                      |
#                       V                      V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :Between = [ "<<", ">>" ])
#--> [6, 24]

#                       +----+            +----+
#                       |    |            |    |
#                       V    V            V    V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [6, 24]

proff()
# Executed in 0.06 second(s)

/*-----------------

pron()

o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindBoundedBy("word", "<<", ">>")
#--> [6, 24]

proff()

/*-----------------

pron()

o1 = new stzString("my **word** and your **word**")

? o1.FindBoundedBy("word", "**", "**")
#--> [6, 24]

? o1.FindXT("word", :BoundedBy = "**")
#--> [6, 24]

proff()
# Executed in 0.05 second(s)

/*============= Near Natural Code

pron()

o1 = new stzString("my <<word>> and your <<word>>")
? @@( o1.FindXT("word", :StartingAt = 12) )
#--> [ 13 ]

? @@( o1.FindXT("word", :InSection = [3, 10]) )
#--> [ 6 ]

proff()
# Executed in 0.08 second(s)

/*-----------------

pron()

o1 = new stzString("12*♥*56*♥*")

? o1.FindFirstXT("♥", :Between = [ "*", "*"])
#--> 4

? o1.FindFirstXT("♥", :BoundedBy = [ "*", "*"])
#--> 4

? o1.FindFirstXT("♥", :BoundedBy = "*")
#--> 4

proff()
# Executed in 0.07 second(s)

/*==============

pron()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

? @@( o1.FindBetween("word", "<<", ">>") )
#--> [ 11 ]

? @@( o1.FindBetweenAsSections("word", "<<", ">>") ) + NL
#--> [ [ 11, 14 ] ]

#--

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [ 11, 28, 43 ]

? @@( o1.FindAnyBoundedByAsSections([ "<<",">>" ]) )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 49 ] ]

proff()
# Executed in 0.02 second(s)

/*=================

pron()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")

o1.ReplaceSubStringsBoundedBy([ "<<", ">>" ], "wrod")
? o1.Content()
#--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

proff()
# Executed in 0.05 second(s)

/*================ FindBoundedSubString() VS FindSubStringBounds()

pron()
#                             11               28           41
#                             v                v            v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubString("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringZZ("word") )
#--> [ [ 11, 14 ], [ 28, 31 ], [ 41, 44 ] ]

? "--"

? @@( o1.FindSubStringBounds("word") ) + NL
#--> [ 9, 15, 26, 32, 39, 45 ]

? @@( o1.FindSubStringBoundsZZ("word") ) + NL
#--< [ [ 9, 10 ], [ 15, 16 ], [ 26, 27 ], [ 32, 33 ], [ 39, 40 ], [ 45, 46 ] ]

proff()
# Executed in 0.07 second(s)

/*--------

pron()
#                           9      16        26     33    39     46
#                           v------v         v------v     v------v
o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.FindBoundedSubStringIB("word") ) + NL
#--> [ 11, 28, 41 ]

? @@( o1.FindBoundedSubStringIBZZ("word") )
#--> [ [ 11, 14 ], [ 28, 31 ], [ 41, 44 ] ]

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

o1.RemoveBoundedSubString("word")
? o1.Content()
#--> bla  bla <<>> bla bla <<>> bla <<>> word

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")

? @@( o1.SubStringBounds("word") )
#--> [ "<<", ">>", "<<", ">>", "<<", ">>" ]

o1.RemoveBoundedSubStringIB("word")
? o1.Content()
#--> bla word bla  bla bla  bla  word

proff()
# Executed in 0.05 second(s)

/*--------

pron()

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
# Executed in 0.02 second(s)

/*=======

pron()

o1 = new stzString("bla <<nonword>> bla")
? @@( o1.FindSubStringBoundsZZ("word") )
#--> [ [ 9, 9 ], [ 14, 15 ] ]

proff()

/*------

pron()
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
#--> bla word bla word bla bla <<noword>> bla word word _word_

? o1.Content()
# Executed in 0.06 second(s)

pron()

/*------

pron()

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

pron()

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

pron()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")
o1.ReplaceSubStringBoundedByIB("word", [ "<<", ">>" ], "WORD")
? o1.Content() + NL
#--> bla bla WORD bla bla WORD bla WORD.

# or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")
o1.ReplaceXT("word", :BoundedByIB = ["<<", ">>"], :With = "WORD")
? o1.Content()
#-->

proff()
# Executed in 0.09 second(s)

/*------ 

pron()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnySubStringBoundedBy([ "<<", ">>" ])
? o1.Content()	#--> "bla bla <<>> bla bla <<>> bla <<>>"
#--> bla bla <<>> bla bla <<>> bla <<>>

proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.07 second(s) in Ring 1.19

/*------ 

pron()

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnySubStringBoundedByIB([ "<<", ">>" ])
? o1.Content()
#--> "bla bla  bla bla  bla"

proff()
# Executed in 0.03 second(s)

/*----------------- RemoveBetween RemoveAt

pron()

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

pron()

o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

proff()
# Executed in 0.04 second(s)

/*================= #narration

pron()

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

pron()

o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
o1.RemoveLast(" من") # Or o1.RemoveNthOccurrence(:Last, " من")
? o1.Content()
#--> Gives من كان في زمنه من أصحابه فهو أكبر المحظوظين

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrence(:Last, "A")
? o1.Content()
#--> **A1****A2***3

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrenceCS(:Last, "a", :CaseSensitive = FALSE)
? o1.Content() #--> **A1****A2***3

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("**A1****A2***A3")
o1.RemoveLast("A")
? o1.Content()
#--> **A1****A2***3

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("**A1****A2***A3")
o1.RemoveFirst("A")
? o1.Content()
#--> **1****A2***A3

proff()

/*==================

pron()

o1 = new stzString("<<word>>")

? o1.IsBoundedBy(["<<", ">>"])
#--> TRUE

o1.RemoveTheseBounds("<<",">>")
? o1.Content()
#--> word

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzString("word")
o1.AddBounds(["<<",">>"]) # or BoundWith(["<<",">>"])
? o1.Content()
#--> <<word>>

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzString("Hello <<<Ring>>, the beautiful ((Ring))!")
? @@( o1.BoundsOf("Ring") )
#--> [ ["<<", ">>"], [ "((", "))" ] ]

proff()
# Executed in 0.08 second(s)

/*---------------

pron()

o1 = new stzString("Ring>>, the nice ---Ring---, the beautiful ((Ring")
? @@( o1.BoundsOf("Ring") )
#--> [ [ "---", "---" ] ]

proff()
# Executed in 0.09 second(s)

/*---------------

pron()

o1 = new stzString("Hello <<<Ring>>, the nice __Ring__ and beautiful ((Ring))!")
? @@( o1.BoundsOf("Ring") )
#--> [ [ "<<<", ">>" ], [ "__", "__" ], [ "((", "))" ] ]

? @@( o1.FirstBoundsOf("Ring") )
#--> [ "<<<", "__", "((" ]

? @@( o1.LastBoundsOf("Ring") )
#--> [ ">>", "__", "))" ]

proff()
# Executed in 0.08 second(s)

/*---------------

pron()

o1 = new stzString("<<word>>")

? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.LeftBound()
#--> "<<"

? o1.RightBound()
#--> ">>"

# And also FirstBound() and LastBound() for general
# use with left-to-right and right-toleft strings

proff()
# Executed in 0.13 second(s)

/*================= StzRaise


? StzRaise("Simple error message!")
#--> Simple error message! 

/*------


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

pron()

o1 = new stzString("@str = Q(@str).Uppercased()")
? o1.BeginsWithOneOfTheseCS([ "@str =", :Or = "@str=" ], TRUE)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzString("Baba, Mama, and Dada")
? o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = FALSE)
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

StzStringQ('') {

	FromURL("https://ring-lang.github.io/doc1.16/qt.html")
	Show()

}
#--> Shows the page content as Text/HTML

proff()
# Executed in 2.63 second(s)


/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {
	? @@( FindAllOccurrencesCS(:Of = "ring", :CS = FALSE) )
	#--> [ 1, 17, 39 ]

	? @@( FindAsSectionsCS(:Of = "ring", :CS = FALSE) )
	#--> [ [ 1, 4 ], [ 17, 20 ], [ 39, 42 ] ]

	? @@( FindOccurrences([1, 3], :Of = "ring") )
	#--> [1, 39]

	? @@( FindOccurrences([1, 3], :Of = "foo") )
	#--> [ ]
}

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? NextNthOccurrence(1, :of = "ring", :startingat = 1)	#--> 1
	? NextNthOccurrence(2, :of = "ring", :startingat = 17)	#--> 39

}

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? FindNextOccurrences(:Of = "ring", :StartingAt = 12)
	#--> [ 18, 40 ]

	? FindPreviousOccurrences(:Of = "ring", :StartingAt = 30)
	#--> [ 1, 17 ]

}

/*======================

o1 = new stzString("Softanza embraces ♥♥♥ simplicty and flexibility")
o1.ReplaceSubStringAtPosition(19, "♥♥♥", :With = "Ring")
? o1.Content() #--> Softanza embraces Ring simplicty and flexibility

/*======================

? Q("RINGO").HasCentralChar()		 #--> TRUE
? Q("RINGO").CentralChar()		 #--> N
? Q("RINGO").PositionOfCentralChar()	 #--> 3
? Q("RINGO").HasThisCharInTheCenter("N") #--> TRUE

/*----------------------

? Q("ArabicArabicArabic").IsMultipleOf("Arabic")	  #--> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic") #--> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic") #--> FALSE

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", TRUE)	  #--> FALSE
? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = FALSE)	  #--> TRUE

/*------------------------

pron()

? Q("...").Marquer()
#--> "#"

? Q("#12500").IsMarquer()
#--> TRUE

? @@( Q("#12500").Marquers() )
#--> [ "12500" ]

proff()
# Executed in 0.02 second(s).

/*====================== WORKING WITH MARQUERS

pron()

? StzStringQ("My name is #.").ContainsMarquers()
#--> FALSE

? StzStringQ("My name is #0.").ContainsMarquers()
#--> TRUE

? StzStringQ("My name is #1.").ContainsMarquers()
#--> TRUE

? StzStringQ("My name is #01.").ContainsMarquers()
#--> TRUE

? @@( Q("bla #0 bla bla #1 bla #2 blabla").Marquers() )
#--> [ "#0", "#1", "#2" ]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.53 second(s) in Ring 1.14

/*---------------------- 

pron()

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

pron()

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
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.49 second(s) in Ring 1.19

/*---------------------- 

pron()

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
# Executed in 1.64 second(s) in Ring 1.21
# Executed in 1.64 second(s) in Ring 1.19

/*---------------------- 

pron()

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
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.63 second(s) in Ring 1.19

/*---------------------- #perf

pron()

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

/*=================== #perf

pron()

? Q("ring").Contains("ring")
#--> TRUE

? Q("").Contains('')
#--> TRUE

? Q([ 12, 66 ]).IsIncludedIn([ 12, 66 ])
#--> TRUE

? Q([]).Contains([])
#--> FALSE

? Q([ 1, [], 3 ]).Contains([])
#--> TRUE

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19 (32 bits)
# Executed in 0.03 second(s) in Ring 1.18

/*----------------------

pron()

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

pron()

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

pron()

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
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.02 second(s) in Ring 1.18

/*---------------------- 

pron()

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

pron()

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

pron()

Q("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> FALSE
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.54 second(s) in Ring 1.19
# Executed in 0.29 second(s) in Ring 1.18
# Executed in 0.45 second(s) in Ring 1.17

/*---------------------- 

pron()

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSortedIndescending()
	#--> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInDescending()
	#--> FALSE
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.18

/*----------------------

pron()

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Ascending
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18

/*---------------------- 

pron()

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Descending
}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18

/*---------------------- 

pron()

StzStringQ("My name is #1, my age is #3, and my job is #2.") {	

	? MarquersAreUnsorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Unsorted

}

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18
# Executed in 0.53 second(s) in Ring 1.17

/*----------------------

pron()

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

pron()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	? Marquers()
	#--> [ "#3", "#1", "#2" ]

	? @@( MarquersZ() ) + NL
	#--> [ [ "#3", 24 ], [ "#1", 42 ], [ "#2", 65 ] ]

	? @@( MarquersZZ() )
	#--> [ [ "#3", [ 24, 25 ] ], [ "#1", [ 42, 43 ] ], [ "#2", [ 65, 66 ] ] ]
}

proff()
# Executed in 0.04 second(s) in Ring 0.04
# Executed in 1.36 second(s) in Ring 1.18
# Executed in 2.22 second(s) in Ring 1.17

/*---------------------- 

pron()

o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
? @@( o1.MarquersSortedInDescendingZZ() )
#--> [ [ "#3", [ 12, 14 ] ], [ "#2", [ 27, 29 ] ], [ "#1", [ 45, 47 ] ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.27 second(s) in Ring 1.18
# Executed in 0.41 second(s) in Ring 1.17

/*---------------------- 

pron()

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

pron()

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@( MarquersSortedZU() ) + NL
	#--> [ [ "#1", [ 12, 66 ] ], [ "#2", [ 44 ] ], [ "#3", [ 26 ] ] ]

	? @@( MarquersSortedZZU() )
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

pron()

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

pron()

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")

o1.MarkTheseSubStringsCS( [ "Ring", "Python", "Ruby", "PHP" ], TRUE )
# Or ReplaceSubstringsWithMarquersCS

? o1.Content() + NL
#--> "#1 can be compared to #2, #3 and #4."

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.MarkSubStringsCS( [ "ring", "python", "ruby", "PHP" ], :CS = FALSE )
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
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 1.73 second(s) in Ring 1.18
# Executed in 2.90 second(s) in Ring 1.17

/*=====================

pron()

StzStringQ("BCAADDEFAGTILNXV") {

	? SortedInAscending()
	#--> AAABCDDEFGILNTVX
	
	? IsSortedInAscending()
	#--> FALSE
	
	? SortedInDescending()
	#--> XVTNLIGFEDDCBAAA
	
	? IsSortedInDescending()
	#--> FALSE
	
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

pron()

Q("AAABCDDEFGILNTVX") {
	IsSorted() 
	#--> TRUE

	? SortingOrder()
	#--> :Ascending
}

Q("XVTNLIGFEDDCBAAA") {
	IsSorted()
	#--> TRUE

	SortingOrder()
	#--> :Descending
}

proff()
# Executed in 0.16 second(s) in Ring 1.21
# Executed in 0.32 second(s) in Ring 1.18
# Executed in 0.74 second(s) in Ring 1.17

/*=======================

pron()

o1 = new stzString("My name is Mansour. What's your name please?")

? @@( o1.FindManyCS( [ "name", "your", "please" ], TRUE ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.FindMany( [ "name", "your", "please" ] ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.TheseSubStringsCSZ( [ "name", "your", "please" ], TRUE ) ) + NL
#--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

o1 = new stzString("My name is Mansour. What's your name please?")
? @@(o1.TheseSubStringsZZ( [ "name", "nothing", "please" ] ))
#--> [ [ "name", [ [ 4, 7 ], [ 33, 36 ] ] ], [ "nothing", [ ] ], [ "please", [ [ 38, 43 ] ] ] ]

proff()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.11 second(s) in Ring 1.17

/*==================== #narration GENERALISATION OF _:_ RING SYNTAX

pron()

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
# Executed in 0.06 second(s) in Ring 106
# Executed in 0.14 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17

/*----------------------

pron()

o1 = new stzString("I Work For Afterward")
? o1.RemoveCharQ(" ").Content()
#--> IWorkForAfterward

# Or you can say it more naturally:
? Q("I Work For Afterward").CharRemoved(" ")

# Or even more expressively:
? Q("I Work For Afterward").WithoutSpaces()
# Or if you prefer:
? Q("I Work For Afterward").SpacesRemoved()

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.18

/*======================

pron()

? Q("9876543210").Reversed()
#--> 0123456789

proff()
# Executed in 0.04 second(s)

/*----------------------

pron()

StzStringQ("73964532041") {

	? SortedInAscending()
	#--> 01233445679

	? SortedInDescending()
	#--> 97654433210
}

proff()
# Executed in 0.04 second(s)

/*----------------------

pron()

? Q("01233445679").IsSortedInAscending()
#--> TRUE

? Q("01233445679").IsSortedInDescending()
#--> FALSE

proff()
# Executed in 0.08 second(s)

/*======================

pron()

? StzStringQ("Arc").IsAnagramOfCS("car", :CS = FALSE)
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*=====================

pron()

o1 = new stzString("IloveRingprogramminglanguage!")
o1.SpacifySubStringsUsing( [ "love", "programming" ], " " )
? o1.Content()
#--> 
proff()
# Executed in 0.05 second(s)

/*---------------------

pron()

? StzCCodeQ('@char = "I"').Transpiled()
#--> This[@i]  = "I"

proff()
# Executed in 0.18 second(s)

/*---------------------

pron()

o1 = new stzString("KALIDIA")
? o1.FindW('@char = "I"')
#--> [ 4, 6 ]

o1.InsertBeforeW( '{ @char = "I" }', "*" )
? o1.Content() #--> KAL*ID*IA

proff()
# Executed in 0.42 second(s) in Ring 1.18
# Executed in 0.52 second(s) in Ring 1.17

/*----------------------

pron()

o1 = new stzString("KALIDIA")
o1.InsertAfterW( '{ @char = "I" }', "*" )
? o1.Content() #--> KALI*DI*A

proff()
# Executed in 0.26 second(s) in Ring 1.18
# Executed in 0.28 second(s) in Ring 1.17

/*----------------------

pron()

StzStringQ("12500;NAME;10;0") {

	? NextOccurrence( :Of = ";", :StartingAt = 1 )
	#--> 6

	? NextNthOccurrence( 2, :Of = ";", :StartingAt = 5)
	#--> 11
}

proff()
# Executed in 0.05 second(s)

/*=======================

pron()

# One of the design goals of Softanza is to be as consitent as possible
# in managing Strings and Lists. In other terms, what works for one,
# should work for the other, preserving the same semantics.

# To show this, the following code that plays with leading and trailing
# chars in a string...

StzStringQ( "***Ring++" ) {

	? HasLeadingChars()
	#--> TRUE

	? NumberOfLeadingChars()
	#--> 3

	? @@( LeadingChars() )
	#--> "***"
	
	? HasTrailingChars()
	#--> TRUE

	? NumberOfTrailingChars()
	#--> 2

	? @@( TrailingChars() )
	#--> "++"

	ReplaceEachLeadingChar(:With = "+")
	? Content()
	#--> "+++Ring++"
	
	//ReplaceLeadingAndTrailingChars(:With = "*")
	ReplaceEachLeadingAndTrailingChar(:With = "*")
	? Content()
	#--> "***Ring**"
}

# works quiet the same with leading and trailing items items of this list:

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems()
	#--> TRUE

	? NumberOfLeadingItems()
	#--> 3

	? @@( LeadingItems() )
	#--> [ "*", "*", "*" ]
	
	? HasTrailingItems()
	#--> TRUE

	? NumberOfTrailingItems()
	#--> 2
	? @@( TrailingItems() )
	#--> [ "+", "+" ]

	ReplaceLeadingItems(:With = "+")
	? @@( Content() )
	#--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItems(:With = "*")
	? @@( Content() )
	#--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

#NOTE that, as far as strings are concerned, this feature is sensitive to case,
# so we can say:

StzStringQ("eeEEeeTUNISeeEE") {

	? NumberOfLeadingCharsCS(:CaseSensitive = FALSE)
	#--> 6

	? LeadingCharsCS(:CaseSensitive = FALSE)
	#--> eeEEee

	? NumberOfLeadingCharsCS(TRUE)
	#--> 2

	? LeadingCharsCS(TRUE)
	#--> ee

	? LeadingCharIsCS("E", :CaseSensitive = FALSE)	+ NL
	#--> TRUE

	#--

	? NumberOfTrailingCharsCS(:CaseSensitive = FALSE)
	#--> 4

	? TrailingCharsCS(:CaseSensitive = FALSE)
	#--> EEee

	? NumberOfTrailingCharsCS(TRUE)
	#--> 2

	? TrailingCharsCS(TRUE)
	#--> EE

	? LeadingCharIsCS("e", :CaseSensitive = FALSE)
	#--> TRUE

}

proff()
# Executed in 0.35 second(s) in Ring 1.18
# Executed in 0.61 second(s) in Ring 1.17

#NOTE: Case sensitivity is supported in Lists with some functions.
# In the future, all functions wil be covered.

/*=====================

pron()

o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
? o1.Content()
#--> ----@@--@@-------@@----##---

proff()
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.05 second(s) in Ring 1.17

/*----------------------

pron()

o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
? o1.Content()
#--> ----@@--##-------@@----@@---

proff()
# Executed in 0.07 second(s)

/*======================

pron()

? Q("DIGIT ZERO").IsCharName()
#--> TRUE

? Q("LATIN CAPITAL LETTER O").IsCharName()
#--> TRUE

? Q("JAVANESE PADA PISELEH").IsCharName()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*----------------------

pron()

o1 = new stzString("ar_Arab_TN")
? o1.IsLocaleAbbreviation()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*--------------------- TODO: review some stzLocale outputs...

pron()

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
# In fact, both of these standard forms return TRUE

? StzStringQ("ar_arab_tn").IsLocaleAbbreviation()
#--> TRUE

? StzStringQ("ar_TN").IsLocaleAbbreviation()
#--> TRUE
# (as a side note, Softanza doesn't care of the case, so do not feel any pressure)

# But this one also return TRUE
? StzStringQ("Arab_TN").IsLocaleAbbreviation()
#--> TRUE
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
#--> FALSE

# The point is that the first abbreviation is a script ("arab" -> arabic),
# and that, conforming to the standard, the second one must be an abbreviation
# of a country ("ar" -> :Argentina). Try this:

? StzCountryQ("ar").Name()
#--> argentina

# And because :Argentina do not have arabic, neigher as a spoken language nor
# a written script, then the returned result is FALSE!

# When you do the same with a country like :Turkey or :Iran, for example,
# where arabic script is (historically) used in writtan turkish and persian
# languages, than the abbreviation is accepted to be well formed

? StzStringQ("arab_tk").IsLocaleAbbreviation()
# !--> TRUE	TODO: Check it!

# And, therefore, you can use it to create locale object:

? StzLocaleQ("arab_tk").Abbreviation()
#--> ar_Arab_TK	TODO: Check it!

? StzLocaleQ("ar_Arab_TK").CountryName()
# !--> :turkey NOT :Egypt

proff()
# Executed in 0.14 second(s)

/*=====================

pron()

o1 = new stzString("ritekode")

? o1.IsEqualTo("ritekode")
#--> TRUE

? o1.IsEqualToCS("RiteKode", :CS = FALSE)
#--> TRUE

? o1.IsEqualToCS("RiteKode", TRUE)
#--> FALSE

proff()
# Executed in 0.05 second(s)

/*--------------------

pron()

? Q("date").IsLowercase()
#--> TRUE

? Q("date").IsLowercaseOf("DATE")
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*--------------------

pron()

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

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = FALSE)
#--> TRUE

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", TRUE)
#--> FALSE

proff()
# Executed in 0.11 second(s) in Ring 1.18
# Executed in 0.21 second(s) in Ring 1.17

/*--------------------

pron()

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

pron()

# This sample shows a logical error in Qt unicode:

? Q("ı").UppercasedInLocale("tr-TR")	#ERROR: --> I but must be İ
? Q("İ").Lowercased()	# i
? Q("İ").LowercasedInLocale("tr-TR")	#ERROR: --> i but must be ı

# In fact, this is a logical bug in Qt as demonstrated here:

oQLocale = new QLocale("tr-TR")
? oQLocale.toupper("ı") #ERROR: --> I but must be İ

#TODO: solve this by implementing the specialCasing of unicode as
# described in this file:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

proff()
# Executed in 0.07 second(s)

/*--------------------

pron()

# Do you think "ê" and "ê" are the same?
# If one should trust the visual shape of these two strings, then yes...
# but, the truth, is that they are different.

# In fact, both Ring and Softanza know it:

? "ê" = "ê"
#--> FALSE

? Q("ê").IsEqualTo("ê")
#--> FALSE

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
# Executed in 0.36 second(s) in Ring 1.18
# Executed in 0.75 second(s) in Ring 1.17

/*-------------------- TODO: LOGICAL ERROR IN QT??

pron()

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

pron()

? StzStringQ("der fluß").Uppercased()
#--> DER FLUSS

? StzStringQ("der fluß").IsLowercase()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*-------------------- LOGICAL ERROR IN QT: Revist after fixing stzLocale

pron()

? Q("DER FLUSS").LowercasedInLocale("de-DE")
#--> der fluss

? Q("der fluß").IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE")
#--> FALSE (but should be TRUE!)

proff()
# Executed in 0.05 second(s)

/*===================

pron()

o1 = new stzText("in search of lost time")
? @@( o1.Words() )
#--> [ "in", "search", "of", "lost", "time" ]

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.40 second(s) in Ring 1.18
# Executed in 0.49 second(s) in Ring 1.17

/*--------------------

pron()

o1 = new stzString("...ONE...NONE...SONY...")
? o1.NumberOfOccurrenceInSections("N", [ [3, 5], [9, 12], [16, 19] ])
#--> 4

proff()
# Executed in 0.04 second(s)

/*--------------------

pron()

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
# Executed in 0.08 second(s).

/*--------------------

pron()

o1 = new stzString("in search of lost time, all the time")
? @@( o1.FindWords() )
#--> [ 1, 4, 11, 14, 19, 24, 28, 32 ]

proff()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.17

/*-------------------- #todo check it

pron()

StzStringQ("in search of lost time") {

	? TitlecasedInLocale("en-US")
	#--> In Search Of Lost Time

	? CapitalisedInLocale("en-US")
	# !--> In Search Of Lost Time
}

StzStringQ("à la recherche du temps perdu") {

	? TitlecasedInLocale("fr-FR")
	#--> À la recherche du temps perdu

	? CapitalisedInLocale("fr-FR")
	# !--> À la Recherche du Temps Perdu
}

proff()

/*--------------------

pron()

? StzStringQ(:Arabic).IsScript()
#--> TRUE

? StzStringQ(:Arabic).IsScriptName()
#--> TRUE

? StzStringQ(:Arab).IsScriptAbbreviation()
#--> TRUE

? StzStringQ("1").IsScriptCode()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*====================

pron()

o1 = new stzString("125.450")
o1.RemoveNthChar(7)
? o1.Content()
#--> "125.45"

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("125.450")

o1.RemoveCharsWXT('{ @char = "2" }')
? o1.Content()
#--> "15.450"

proff()
# Executed in 0.14 second(s).

/*=====================

pron()

o1 = new stzString(".....mmMm")

? o1.HasTrailingChars()
#--> FALSE

? @@( o1.TrailingChar() ) + NL
#--> ""

? o1.HasTrailingCharsCS(:CaseSensitive = FALSE)
#--> TRUE

? o1.TrailingCharCS(FalSE)
#--> "m"

proff()
# Executed in 0.01 second(s).

/*-------------

pron()

o1 = new stzString("....00000")

? @@( o1.FindTrailingChars() )
#--> [ 5, 6, 7, 8, 9 ]

? @@( o1.FindTrailingCharsZZ() )
#--> [ 5, 9 ]

proff()
# Executed in 0.01 second(s).

/*-------------

pron()

o1 = new stzString("12.4560000")

? o1.HasTrailingChars()
#--> TRUE

? o1.HowManyTrailingChar()
#--> 4

? @@( o1.TrailingChar() )
#--> "0"

? o1.TrailingCharIs("0")
#--> TRUE

proff()
# Executed in 0.01 second(s).


/*-----------

pron()

o1 = new stzString("12.4560000")

o1.RemoveThisTrailingChar("0")
? o1.Content()
#--> 12.456

proff()
# Executed in 0.06 second(s).

#------

pron()

? Q("12.45600").ThisTrailingCharRemoved("0")
#--> "12.456"

proff()
# Executed in 0.01 second(s).

/*------ #narration TRAILING CHAR, TRAILING CHARS, AND TRAILiNG SUBSTRING

pron()

# You have a number in string an you want to get some info about its trailing part?

# A trailing aprt is a substring at the end of the string composed of repeated chars.

o1 = new stzString("12.4560000")

# You can check if the string contains a trailing part:

? o1.HasTrailingSubString() # Or HasTrailingChars()

# And even get their number:

? o1.HowManyTrailingChar()
#--> 4

# You can get theim as a string:

? o1.TrailingSubString()
#--> "0000"

# or get them as a list of chars:

? @@( o1.TrailingChars() )
#--> [ "0", "0", "0", "0" ]

# Usually, in practice, you need to remove them:

o1.RemoveTrailingChars() # Or RemoveTrailingSubString
? o1.Content()
#--> 12.456

proff()
# Executed in 0.01 second(s).

/*---------

pron()

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

pron()

o1 = new stzString("000012.456")

? o1.HasLeadingSubString() # Or HasLeadingChars()
#--> TRUE

? o1.HowManyLeadingChar()
#--> 4

# You can get theim as a string:

? o1.LeadingSubString()
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

pron()

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

pron()

o1 = new stzString("000122.12")

? o1.HasLeadingChars()
#--> TRUE

? o1.LeadingCharsXT()
#--> "000"

? o1.LeadingCharsRemoved()
#--> "122.12"

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("000122.12")
? o1.LeadingChar() #--> "0"

o1.RemoveThisLeadingChar("0")
? o1.Content()	#--> "122.12"

proff()
# Executed in 0.01 second(s).

/*=====================

pron()

o1 = new stzString("ABC")
? o1.FirstChar() #--> A
? o1.LastChar()  #--> C

proff()
# Executed in 0.01 second(s).

/*------

pron()

o1 = new stzString("---Ring")

? o1.FirstChar()
#--> "-"

? o1.LastChar()
#--> "g"

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("BATISTA123")

o1.RemoveNLastChars(3)
? o1.Content()
#--> BATISTA

? StzStringQ("BATISTA123").LastNCharsRemoved(3)
#--> BATISTA

proff()
# Executed in 0.01 second(s).

/*--------------------

o1 = new stzString("BATISTA1")
o1.RemoveLastChar()
? o1.Content()	#--> BATISTA

? StzStringQ("BATISTA1").LastCharRemoved() #--> BATISTA

/*--------------------

o1 = new stzString("123BATISTA")
o1.RemoveNFirstChars(3)
? o1.Content()	#--> BATISTA

? StzStringQ("123BATISTA").FirstNCharsRemoved(3) #--> BATISTA

/*--------------------

o1 = new stzString("1BATISTA")
o1.RemoveFirstChar()
? o1.Content()	#--> BATISTA

? StzStringQ("1BATISTA").FirstCharRemoved() #--> BATISTA

/*--------------------

o1 = new stzString("SOFTANZA IS AWSOME!")
? o1.IsEqualTo("softanza is awsome!")			#--> FALSE
? o1.IsEqualToCS("softanza is awsome!", :CS = FALSE)	#--> TRUE
? o1.IsUppercaseOf("softanza is awsome!")		#--> TRUE

/*================= Quiet-Equality of two strings

o1 = new stzString("SOFTANZA IS AWSOME!")
#TODO: Check performance of IsQuietEqualTo() --> Root cause RemoveDiacritics()
? o1.IsQuietEqualTo("softanza is awsome!")	#--> TRUE
? o1.IsQuietEqualTo("Softansa is aowsome!")	#--> TRUE (we added an "o" to "awsome")
? o1.IsQuietEqualTo("Softansa iis aowsome!")	#--> FALSE (we add "i" to "is" and "o" to "awsome")

/*--------------------

# Quiet-eqality is particularily useful in french where "énoncé" and "ÉNONCÉ" are the same:
o1 = new stzString("énoncé")
? o1.IsEqualTo("enonce")	#--> FALSE
? o1.IsQuietEqualTo("enonce")	#--> TRUE
? o1.IsQuietEqualTo("ÉNONCÉ")	#--> TRUE

/*--------------------

pron()

? StzCharQ("é").Script()
#--> latin

? StzCharQ("ن").Script()
#--> arabic

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

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
# Executed in 0.25 second(s).

/*--------------------

pron()

# We can adjust the ratio of QuitEquality by our selves (value between 0 and 1):

o1 = new stzString("mahmoud fayed")

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> FALSE

? QuietEqualityRatio()
#--> 0.09 (default value)

# If we need a more permissive quiet-eqality check, then we set it at a weaker value:

SetQuietEqualityRatio(0.35)

? o1.IsQuietEqualTo("Mahmood al-feiyed")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*====================

pron()

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
#--> TRUE

#TODO: Complete the other operators when COMPARAISON methods are made in stzString

proff()
# Executed in 0.02 second(s).

/*=================

pron()

o1 = new stzString("{{{ Scope of Life }}}")

? o1.BeginsWith("{")
#--> TRUE

? o1.EndsWith("}")
#--> TRUE

? o1.IsBoundedBy([ "{", "}" ])
#--> TRUE

? o1.TheseBoundsRemoved("{", "}")
#--> {{ Scope of Life }}

proff()
# Executed in 0.03 second(s).

/*--------------------

pron()

o1 = new stzString('"name"')
? o1.IsBoundedBy([ '"','"' ])	#--> TRUE

o1 = new stzString(':name')
? o1.IsBoundedBy([ ':', NULL ])	#--> TRUE

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("one two three four")
o1.ReplaceAll( "two", "---")
? o1.Content()
#--> "one --- three four"

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("one two three four")
o1.ReplaceMany([ "two", "four" ], :By = "---")
? o1.Content()
#--> "one --- three ---"

proff()
# Executed in 0.01 second(s).

/*=====================

pron()

o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceCS(3, "Mio", TRUE)
#--> 16

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

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

pron()

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

pron()

o1 = new stzString("216;TUNISIA;227;NIGER")

? o1.Section(5, o1.NextOccurrence( :Of = ";", :StartingAt = 5 ) - 1 )
#--> TUNISIA

proff()
# Executed in 0.01 second(s).

/*====================

pron()

o1 = new stzString("amd[bmi]kmc[ddi]kc")
? o1.SubStringsBoundedBy([ "[", "]" ])
#--> [ "bmi", "ddi" ]

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

# SubStringsBoundedBy can't manage DEEP combinations like this

o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
? o1.SubStringsBoundedBy([ "[", "]" ])

#!--> "A", "T", [ :hi, [ "deep1", [

proff()
# Executed in 0.01 second(s).

/*====================

pron()

# In Softanza both n and N chars correspond to the letter "N"

o1 = new stzString("Adoption of the plan B")
? o1.ContainsTheLetters([ "N", "b" ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*--------------------

pron()

o1 = new stzString("opsus amcKLMbmi findus")

? o1.FindSubStringBetween("KLM", "amc", "bmi") # Or simply FindBetween()
#--> 10

proff()
# Executed in 0.01 second(s).

/*======= #narration ANALYZING THE SCRIPTS FORMING A STRING

pron()

StzStringQ("__b和平س__a__و") {

	? ContainsLettersInScript(:Latin)
	#--> TRUE

	? CharsWXT( ' Q(@char).IsLatin() ')
	#--> [ "b", "a" ]

	? ContainsLettersInScript(:Arabic)
	#--> TRUE

	? CharsWXT( ' Q(@char).IsArabic() ')
	#o--> [ "س", "و" ]

	? ContainsLettersInScript(:Han)
	#--> TRUE

	? CharsWXT( ' StzCharQ(@char).IsHanScript() ')
	#--> [ "和", "平" ]

	? ContainsCharsInScript(:Common)
	#--> TRUE

	? CharsWXT( ' StzCharQ(@char).IsCommonScript() ')
	#--> [ "_", "_", "_", "_", "_", "_" ]

	#NOTE that if you say
	? ContainsLettersInScript(:Common)	# or
	? ContainsLettersInScript(:Unkowan)
	# you get FALSE because there is no sutch letter that has a script
	# 'common'. In other terms, any letter in the world has to belong
	# to a knowan script.
}

proff()
# Executed in 0.61 second(s).

/*--------------------

pron()

o1 = new stzString("__b和平س__a__و")
? o1.ToStzText().Scripts()
#--> [ "latin", "han", "arabic" ]

proff()
# Executed in 0.04 second(s).

/*===================

pron()

o1 = new stzString("__b和平س__a_ووو")
? o1.PartsUsingXT(' StzCharQ(@char).Script() ')

proff()
# Executed in 0.15 second(s).

/*--------------------

pron()

o1 = new stzString("__b和平س__a_ووو")
? o1.PartsUsing(' StzCharQ(This[@i]).Script() ' )

proff()
# Executed in 0.07 second(s).

/*--------------------

pron()

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
# Executed in 0.12 second(s).

/*====================

pron()

# Case sensisitivity is considered only for latin letters

? StzCharQ("9").IsLowercase()
#--> FALSE

? StzCharQ("9").IsUppercase()
#--> FALSE

? StzCharQ("ك").IsLowercase()
#--> FALSE

? StzCharQ("ك").IsUppercase()
#--> FALSE

? StzStringQ("120").IsLowercase()
#--> FALSE

? StzStringQ("120m").IsLowercase()
#--> TRUE

? StzStringQ("120M").IsUppercase()
#--> TRUE

? StzStringQ("كلام").IsLowercase()
#--> FALSE

proff()
# Executed in 0.09 second(s).

/*====================

pron()

o1 = new stzString("abcdef")

? o1.ContainsNoOneOfThese([ "xy", "xyz", "mwb" ])
#--> TRUE

? o1.ContainsNoOneOfThese([ "xy", "xyz", "de", "mwb" ])
#--> FALSE

proff()
# Executed in 0.01 second(s).

/*====================

pron()

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

pron()

? StzStringQ("tunis").IsLowercased()
#--> TRUE

? StzStringQ("TUNIS").IsUppercased()
#--> TRUE

? StzStringQ("Tunis").IsTitlecased()
#--> TRUE

//? StzStringQ("tunis").IsFoldcased()	#TODO

proff()

/*====================

pron()

? StringsAreEqualCS([ "abc","abc" ], TRUE )
#--> TRUE

? StringsAreEqual([ "cbad", "cbad", "cbad" ])
#--> TRUE

? BothStringsAreEqualCS("abc", "abc", TRUE)
#--> TRUE

? BothStringsAreEqual("abc", "abc")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*====================

pron()

? Q("~~H/U/S/S/E/I/N~~").CharsWXT('{ Q(@char).isLetter() }')
#--> [ "H","U","S","S","E","I","N" ]

? Q("~~H/U/S/S/E/I/N~~").NumberOfCharsWXT('{ Q(@char).isLetter() }')
#--> 7

proff()
# Executed in 0.36 second(s).

/*--------------------

pron()

? Q("--A--B--").ContainsLetters()
#--> TRUE

? Q("--A--B--").ContainsLetter("A")
#--> TRUE

? Q("--A--B--").ContainsLetter("a")
#--> TRUE

? Q("--A--B--").ContainsLetter("M")
#--> FALSE

? Q("H").IsALetterOf("HUSSEIN")
#--> TRUE

? Q("h").IsALetterOf("HUSSEIN")
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*=====================

pron()

? StzStringQ("SOFTANZA").CharsReversed()
#--> SOℲꞱⱯNZⱯ

? StzStringQ(" Softanza    Near-natural Programming   ").Simplified()
#--> Softanza Near-natural Programming

proff()
# Executed in 0.07 second(s).

/*--------------------

pron()

# TQ is an abbreviation of StzTextQ()

? TQ("عربي").Script()
#--> arabic

? TQ("ring").Script()
#--> latin

proff()
# Executed in 0.06 second(s).

/*-------------------

pron()

# Used internally by the library in evaluating conditional code:

? StzStringQ('myfunc()').IsAlmostAFunctionCall()
#--> TRUE

? StzStringQ('my_func("name")').IsAlmostAFunctionCall()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

? StzStringQ("G").IsLetter()
#--> TRUE

? UppercaseOf("b")
#--> B

? LowercaseOf("B")
#--> b

//? FoldcaseOf("sinus")		# !!! Undefined function #TODO

proff()
# Executed in 0.01 second(s).

/*=================== #narration CHARS, BYTES, UNICODE CODEPOINTS, AND BYTCODES

pron()

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

pron()

? StzStringQ("sAlut").IsLowercase()
#--> FALSE

proff()
# Executed in 0.02 second(s).

/*===================

pron()

? StzStringQ("@char___@char___@char").ReplaceAllQ("@char","@item").Content()
#--> @item___@item___@item

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

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

pron()

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

pron()

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

pron()

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

pron()

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

pron()

o1 = new stzString("Ring Programming Language")
? o1.WalkBackwardW( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ) #--> 5
? o1.WalkForwardW( :StartingAt =  6, :UntilBefore = '{ @char = "r" }' ) #--> 9

proff()

/*==================

pron()

? StzTextQ("abc سلام abc").ContainsScript(:Arabic)
#--> TRUE

? StzTextQ("abc سلام abc").ContainsArabicScript()
#--> TRUE

#NOTE: Scripts are now moved from stzString to stzText

# You can use this short form instead of StzTextQ()
? TQ("سلام").Script() #--> :Arabic

proff()
# Executed in 0.07 second(s).

/*==================

pron()

? StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content()
#--> év*nement

? StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content()
#--> év*nement

proff()
# Executed in 0.01 second(s).

/*==================

pron()

StzStringQ("original text before hashing") {

	Hash(:MD5)
	? Content()
	#--> 8ffad81de2e13a7b68c7858e4d60e263

}

proff()
# Executed in 0.02 second(s).

/*==================

pron()

? StzStringQ("ring").StringCase()
#--> :Lowercase

? StzStringQ("RING").StringCase()
#--> :Uppercase

? StzStringQ("RING and python").StringCase()
#--> :hybridcase

proff()
# Executed in 0.25 second(s).

/*========== STRING PARTS ===========

pron()

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

pron()

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

pron()

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
pron()

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

pron()

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

pron()

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

pron()

o1 = new stzString("Abc285XY&من")

? @@( o1.Parts2Using( 'CharQ(@i).IsLetter()' ) ) + NL
#--> Gives:
# [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

? @@( o1.Parts2Using("CharQ(@i).Orientation()") ) + NL
#--> Gives:
# [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? @@( o1.Parts2Using("CharQ(@i).IsUppercase()") ) + NL
#--> Gives:
# [ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

? @@( o1.Parts2Using("CharQ(@i).CharCase()") )
#--> Gives:
# [ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

proff()
# Executed in 0.35 second(s).

/*========================

pron()

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceAllChars( :With = "*" )
? o1.Content()
#--> "*******************************"

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

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

pron()

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

pron()

? StzCharQ(":").IsPunctuation()
#--> TRUE

? StzCharQ(":").CharType()
#--> punctuation_other

proff()
# Executed in 0.35 second(s).

/*================

pron()

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

pron()

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

pron()

? StzCharQ("س").Name()
#--> ARABIC LETTER SEEN

? StzCharQ("ص").Name()
#--> ARABIC LETTER SAD

proff()
# Executed in 0.15 second(s).

/*==============

pron()

o1 = new stzString("SoftAnza Libraray")

? o1.CountCharsWXT('{ @Char = "a" }')
#--> 3

? o1.CountCharsWXT('{	Q(@Char).IsEqualToCS("a", :CS = FALSE) }')
#--> 4

proff()
# Executed in 0.30 second(s).

/*--------------

pron()

o1 = new stzString("SoftAnza Libraray")
? o1.FindCharsWXT('{ StzCharQ(@Char).Lowercased() = "a" }')
#--> [ 5, 8, 14, 16 ]

proff()
# Executed in 0.19 second(s).

/*=================

pron()

o1 = new stzString("abc;123;gafsa;ykj")
? o1.SplitQ(";").NthItem(3)
#--> gafsa

# Same as:
? o1.NthSubstringAfterSplittingStringUsing(3, ";") # Long, but useful in natural-coding
#--> gafsa

proff()
# Executed in 0.01 second(s).

/*===================

pron()

? StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
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

pron()

? StzStringQ("RING").BoxXT([ ])

proff()

/*------------------

pron()

StzStringQ("RING") {
	? Content()
	? Boxed()

	? BoxedRound()
	? BoxedRoundDashed()

	? EachCharBoxed()
	? EachCharboxedRound()

	//? VizFindBoxed("I")	#--> TODO: Add VizFindBoxed()
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
# Executed in 0.05 second(s).

/*------------------

pron()

StzStringQ("RING IS NICE") {

	? Content()

	? Boxed()
	? BoxedRound()

	? EachCharBoxed()
	? EachCharBoxedRound()

	// ? VizFindBoxed("I")	#TODO: Add it

	? BoxedDashed()
	? BoxedDashedRound()

	? BoxedXT([
		:Line = :Thin,
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
# Executed in 0.09 second(s).

/*-----------------

pron()

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

pron()

# You can box the entire string like this:
? StzStringQ("SOFTANZA").BoxedXT([])
#-->
# ┌──────────┐
# │ SOFTANZA │
# └──────────┘

# Or box it char by char like this:

? StzStringQ("SOFTANZA").BoxedXT([ :EachChar = TRUE ])

#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.05 second(s).

/*--------------------- TODO

pron()

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

pron()

? StzStringQ("ar_TN-tun").ContainsEachCS(["_", "-"],TRUE)
#--> TRUE

? StzStringQ("ar_TN-tun").ContainsBoth("_", "-")
#--> TRUE

proff()
# Executed in 0.03 second(s).

/*==================

pron()

o1 = new stzString("a")
o1.MultiplyBy([ "b", "c", "d" ])
? o1.Content() #--> "abacad"

proff()
# Executed in 0.01 second(s).

/*--------------

pron()

o1 = new stzString("a")
? o1 * [ "b", "c", "d" ]
#--> abacad

proff()
# Executed in 0.01 second(s).

/*---------------

pron()

o1 = new stzString("abcdefj")

? o1 / 2
#--> [ "abcd", "efj" ]

? o1 % 2
#--> "efj"

proff()
# Executed in 0.03 second(s).

/*--------------

pron()

o1 = new stzString("ab-ac-ad")
? o1 / "-" 			# Same as ? o1.Split("-")
#--> [ "ab", "ac", "ad" ]

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzString("happy-holidays")

? o1.IsLowercase()
#--> TRUE

o1 = new stzString("HOLIDAYS!")
? o1.IsUppercase()
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*==================

pron()

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

pron()

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

pron()

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

pron()

str = "   سلام"
o1 = new stzString(str)

? o1.HasRepeatedLeadingChars()
#--> TRUE

? @@( o1.RepeatedLeadingChar() )
#--> " "

o1.TrimRight() ? o1.Content()
#o--> سلام

proff()
# Executed in 0.02 second(s).

/*------------------

pron()

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

pron()

o1 = new stzString("exeeeeeTUNIS")
 	
? @@( o1.RepeatedLeadingChar() )
#--> ""

? @@( o1.RepeatedLeadingChars() )
#--> ""

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("eeeeTUNISIAiiiii")

o1 {
	? HasRepeatedLeadingChars()
	#--> TRUE

	? NumberOfRepeatedLeadingChars()
	#--> 4

	? RepeatedLeadingchars()
	#--> [ "e", "e", "e", "e" ]

	? LeadingSubString()+ NL
	#--> "eeee"
	
	? HasRepeatedTrailingChars()
	#--> TRUE

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

pron()

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

pron()

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

pron()

o1 = new stzString("eeebxeTuniseee")

? o1.Section(:FirstChar, :LastChar)
#--> eeebxeTuniseee

? o1.Section( 7, 4 )
#--> Texb

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

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

pron()

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

pron()

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

pron()

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

pron()

o1 = new stzString("bbxeTuniseee")

? o1.RepeatedLeadingChars()
#--> [ "b", "b" ]

? o1.LeadingSubString()
#--> "bb"

? o1.HasRepeatedLeadingChars()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

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

pron()

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

pron()

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

pron()

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

pron()

o1 = new stzString("Oooooh TunisiammMmmM")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oooooh TunisiammmmM

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Aaaaah TunisiammmmM

o1 = new stzString("Oooooh TunisiammMmmM")
o1.ReplaceLeadingCharsCS(:With = "O", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh TunisiammmmM

o1.ReplaceTrailingCharsCS(:With = "!", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh Tunisia!

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzString("Oooo Tunisia---")

? o1.HasLeadingChars()
#--> FALSE

? @@( o1.LeadingChar() )
#--> ""

? o1.HasLeadingCharsCS(FALSE)
#--> TRUE

? o1.LeadingCharCS(:CS = FALSE)
#--> "O"

? @@( o1.LeadingChars()	)
#--> []

? o1.LeadingCharsCS(:CS=FALSE)
#--> [ "O", "o", "o", "o" ]

? o1.LeadingSubStringCS(FALSE)
#--> "Oooo"

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

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

pron()

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

pron()

? Q("A") * [ "1", "2", "3" ]
#--> A1A2A3

proff()

/*-----------

pron()

? Q("ORingoriaLand") - [ "O", "oria", "Land" ]
#--> Ring

? ( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).content()
#--> Ring

proff()
# Executed in 0.01 second(s).

/*==================

pron()

? StzStringQ("[ 2, 3, 5:7 ]").IsListInString()
#--> TRUE

? StzStringQ("'A':'F'").IsListInString()
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*==================

pron()

o1 = new stzstring("123456789")
? o1.Section(4,6)
#--> "456"

proff()

/*-------------

pron()

o1 = new stzstring("123456789")
o1.ReplaceSection(4, 6, :with = "***")
? o1.Content()
#--> "123***789"

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAll("Tunis", "Niamey" )
	? Content()
}
#--> Niamey is the town of my memories.

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAllCS("TUNIS", "Niamey", :CS = FALSE )
	? Content()
}
#--> Niamey is the town of my memories

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

StzStringQ( "a + b - c / d = 0" ) {
	ReplaceMany( [ "+", "-", "/" ], "*" )
	? Content()
}
#--> a * b * c * d = 0

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

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

pron()

o1 = new stzString("this text is my text not your text, right?!")
? o1.FindAllCS("text", :CaseSensitive = false)
#--> [6, 17, 31]

? o1.FindNthOccurrence(2, "Text")
#--> 0

? o1.FindNthOccurrenceCS(2, "Text", :CaseSensitive = false)
#--> 17

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("This text is my text not your text, right?!")

? o1.ReplaceNthOccurrenceCSQ(2, "TEXT", :With = "narration", :Casesensitive = FALSE).Content()
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

pron()

o1 = new stzString("LandRingoriaLand")
o1.RemoveFirstOccurrence( :Of = "Land")
? o1.Content()
#--> RingoriaLand

proff()
# Executed in 0.01 second(s).

/*---------------

pron()

o1 = new stzString("RingoriaLandLand")
? o1 - "Land"
#--> Ringoria

proff()
# Executed in 0.01 second(s).

/*--------------- TODO: Maybe this should move to stzText

pron()

o1 = new stzString("ring language isسلام  a nice language")

? o1.Orientation()
#--> :LeftToRight

? o1.ContainsHybridOrientation()
#--> TRUE

#---

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")

? o1.Orientation()
#--> :RightToLeft

? o1.ContainsHybridOrientation()
#--> TRUE

proff()
# Executed in 0.09 second(s).

/*----------------

pron()

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

pron()

o1 = new stzString("سلام لأهل مصر الكرام")
o1.RemoveNLeftChars(7)
? o1.Content()
o#--> سلام لأهل مصر

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("ring language is nice language")

? o1.NLastCharsRemoved(9)
#--> ring language is nice

? o1.SectionQ(1,4).CharsReversed()
#--> ɹᴉnᵷ

proff()
# Executed in 0.06 second(s).

/*----------------

pron()

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

pron()

o1 = new stzString("Softanza loves simplicity")
? o1.ReplaceFirstQ( o1.Section(10, :LastChar), "arrives!").Content()
#--> "Softanza arrives!"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17

/*----------------

pron()

o1 = new stzString("<script>func return :done<script/>")
? o1.IsBoundedBy(["<script>", :And = "<script/>"])
#--> TRUE

o1.RemoveTheseBounds("<script>", "<script/>")
? o1.Content()
#--> "func return :done"

proff()
# Executed in 0.03 second(s) in Ring 1.14
# Executed in 0.14 second(s) in Ring 1.17

/*----------------

pron()

? StzStringQ("{nnnnn}").IsBoundedBy(["{","}"])
#--> TRUE

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.IsBoundedBy(["بسم", "الرّحيم"])
#--> TRUE

proff()
# Executed in 0.01 second(s)

/*----------------

pron()

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

pron()

o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceQ("xo", "ng").Content()
#--> Ring Ring Ring

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("Ringos Ringos Ringos")
o1.RemoveAll("os")
? o1.Content()
#--> Ring Ring Ring

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("extrasection")
o1.RemoveSectionQ(6, :LastChar)
? o1.Content()
#--> extra

proff()
# Executed in 0.01 second(s).

/*----------------

pron()

o1 = new stzString("extrasection")
o1.RemoveRange(1, 5)
? o1.Content()
#--> section

proff()
# Executed in 0.01 second(s).

/*=======================

pron()

? Q("SFOTANZA").AlignedXT( :Width = 30, :Char= ".", :Direction = :Center )
#--> ...........SFOTANZA...........

proff()
# Executed in 0.02 second(s).

/*-----------------------

pron()

? StringAlign("SOFTANZA", 30, ".", :Left)
? StringAlign("SOFTANZA", 30, ".", :Right)
? StringAlign("SOFTANZA", 30, ".", :Center)
? StringAlign("SOFTANZA", 30, ".", :Justified) + NL

#-->
# SOFTANZA......................
# ......................SOFTANZA
# ...........SOFTANZA...........
# S....O...F...T...A...N...Z...A

proff()
# Executed in 0.05 second(s).

/*----------------

pron()

str = "منصوريّات"
? StringAlign(str, 30, ".", :Left)
? StringAlign(str, 30, ".", :Right)
? StringAlign(str, 30, ".", :Center)
? StringAlign(str, 30, ".", :Justified)

#-->
# ......................منصوريّات
# منصوريّات......................
# ...........منصوريّات...........
# م....ن...ص...و...ر...يّ...ا...ت

proff()
# Executed in 0.05 second(s).

/*==================

pron()

o1 = new stzString("مَنْصُورِيَّاتُُ")

? o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzString("ABCDEFGH")
o1.CompressUsingBinary("10011011")
? o1.Content()
 #--> ADEGH

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzString("aabbcaacccbb")

? o1.IsMadeOf([ "aa", "bb", "c" ])
#--> TRUE

? o1.IsMadeOfSome([ "a", "b", "c", "x" ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

o1 = new stzString("سلسبيل")

? o1.IsMadeOf([ "ب", "ل", "س", "ي" ])
#--> TRUE

? o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ])
#--> FALSE

? o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzSplitter(1:10)

? @@( o1.GetPairsFromPositions([ 1, 3, 8 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 10 ] ]

proff()

/*-----------------

pron()

o1 = new stzSplitter(1:12)

? @@( o1.GetPairsFromPositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ], [ 10, 12 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 12 ] ]

proff()
# Executed in 0.03 second(s).

/*-----------------

pron()

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

pron()

o1 = new stzString("NoWomanNoCry")
? o1.SplitBeforeCharsWXT(:Where = 'Q(@char).IsUppercase()')
#--> [ "No", "Woman", "No", "Cry" ]

proff()
# Executed in 0.23 second(s).

/*==================

pron()

StzStringQ("أهلا بأيّ كانَ، ومرحبا بأيّ كان، ومرحى لأيّ كان، أيّا كان من سمَّاهُ حُسَيْنْ") {

	cSubStr = "أيّ كان"
	cNewSubStr = " اسْمُهُ حُسَيْنْ"

	InsertBefore(cSubStr,cNewSubStr)
	? Content()
}
#-->
# أهلا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحبا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحى لأيّ كان اسْمُهُ حُسَيْنْ، أيّا كان من سمَّاهُ حُسَيْنْ

proff()
# Executed in 0.09 second(s).

/*-------------------

pron()

o1 = new stzString("Hi Dan! Your are Dan, but your work is always not done ;)")
o1.ReplaceNthOccurrence(2, "Dan", "hardworker")
? o1.Content()
#--> Hi Dan! Your are harworker, but your work is always not done ;)

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

o1 = new stzString("text this text is written with the text of my scrampy text")
? o1.FindAll("text")
#--> [ 1, 11, 36, 55 ]

? o1.FindNthOccurrence(4, :Of = "text")
#--> 55

? o1.ContainsNtimes(4, "text")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*================== STRING COMPARAISON

pron()

o1 = new stzString("reserve")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False )
#--> :Equal

o1 = new stzString("réservé")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False )
#--> :Greater

o1 = new stzString("reserv")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False )
#--> :Less

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("RÉSERVÉ")

? o1.UnicodeCompareWithInSystemLocale("réservé")
#--> :Greater

//? o1.UnicodeCompareWithInLocale("réservé", "fr-FR")	#TODO

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzString("  lots   of    whitespace  ")

? o1.Trimmed()
#--> "lots   of    whitespace"

? o1.SimplifyQ().UPPERcased()
#--> "LOTS OF WHITESPACE"

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
o1.ReplaceAll("فلانة", "فلسطين")
? o1.Content()
o#--> اسمي هو فلسطين، قلت لك فلسطين! أوَ لم يعجبك أن يكون اسمي فلسطين؟

proff()
# Executed in 0.01 second(s).

/*--------------------

pron()

o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
"Où bien tu n'aimes pas que ce soit Foulèna?")

o1.ReplaceAll("Foulèna", "Tiba")
? o1.Content()

#--> "Mon prénom c'est Tiba. J'ai bien dit Tiba! Où bien tu n'aimes pas que ce soit Tiba?"

proff()
# Executed in 0.01 second(s).

/*======================

pron()

o1 = new stzString("0o20723.034")
o1 {
	? RepresentsNumber()			#--> TRUE
	? RepresentsSignedNumber()		#--> FALSE
	? RepresentsUnsignedNumber()		#--> TRUE
	? RepresentsCalculableNumber() + NL	#--> TRUE
	
	? RepresentsInteger()			#--> FALSE
	? RepresentsSignedInteger()		#--> FALSE
	? RepresentsUnsignedInteger()		#--> FALSE
	? RepresentsCalculableInteger()	 + NL	#--> FALSE
	
	? RepresentsRealNumber()		#--> TRUE
	? RepresentsSignedRealNumber()		#--> FALSE
	? RepresentsUnsignedRealNumber()	#--> TRUE
	? RepresentsCalculableRealNumber() + NL	#--> TRUE
	
	? RepresentsNumberInDecimalForm()	#--> FALSE
	? RepresentsNumberInBinaryForm()	#--> FALSE
	? RepresentsNumberInHexForm()		#--> FALSE
	? RepresentsNumberInOctalForm()		#--> TRUE
}

proff()
# Executed in 0.59 second(s).

/*------------------

pron()

o1 = new stzString("12500543.12")
? o1.RepresentsRealNumber()
#--> TRUE

proff()
# Executed in 0.03 second(s).

/*------------------
*/
pron()

o1 = new stzString("0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("-0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("0b-110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> FALSE

proff()
# Executed in 0.02 second(s).

/*------------------

o1 = new stzString("0x12_5AB34.123F")
? o1.RepresentsNumber() 		#--> TRUE
? o1.NumberForm()			#--> :Hex

? o1.RepresentsNumberInHexForm()	#--> TRUE

o1 = new stzString("0o2304.307")
? o1.RepresentsNumber()			#--> TRUE
? o1.NumberForm()			#--> :Octal
? o1.RepresentsNumberInOctalForm()	#--> TRUE

/*===================

o1 = new stzString("All our software versions must be updated!")

# Defining the position of insertion
nPosition = o1.PositionAfter("versions")

# Inserting the list of string using extended configuration
o1.InsertSubstringsXT(
	nPosition,

	[ "V1", "V2", "V3", "V4", "V5" ], 

	[
	:InsertBeforeOrAfter = :Before,
	:OpeningChar = "{ ",
	:ClosingChar = " }", 

	:MainSeparator = ",",
	:AddSpaceAfterSeparator = TRUE,

	:LastSeparator = "and",
	:AddLastToMainSeparator = TRUE,	# adds an ", and" as a last separator

	:SpaceOption = :AddLeadingSpace //+ :AddTrailingSpace	# or :DoNothing
	])

? o1.Content()
#--> All our software versions { V1, V2, V3, V4, and V5 } must be updated!

/*===================

o1 = new stzString("latin")
? o1.IsScriptName()
#--> TRUE

/*------------------

o1 = new stzString("TN-fr") # Fix this; tn-fr gives true --> Incorrect!
? o1.IsLocaleAbbreviation()
#--> TRUE

/*------------------

o1 = new stzString("fr")
? o1.IsLocaleAbbreviation()
#--> TRUE

/*------------------

o1 = new stzString("105")
? o1.IsLanguageNumber()
#--> TRUE

? StzLanguageQ("105").Name()
#--> :Sindhi

? StzLanguageQ("105").DefaultCountry()
#--> :Pakistan

/*------------------

o1 = new stzString("ara")
? o1.IsLanguageAbbreviation()		#--> TRUE
? o1.IsShortLanguageAbbreviation()	#--> FALSE
? o1.IsLongLanguageAbbreviation()	#--> TRUE
? o1.LanguageAbbreviationForm()		#--> :Long

/*------------------

o1 = new stzString("Ⅱ")
? o1.IsLatin()
#--> TRUE

o1 = new stzChar("Ⅱ")
? o1.IsRomanNumber()
#-->

/*----------------

# How to add a string to a QString objet (Qt-side)
# Used internally by Softanza

oQStr = new QString() #NOTE: It's better to use QString2()
oQStr.append("salem")
? QStringToString(oQStr)

/*--------------------

o1 = new stzString("100110001")
? o1.IsMadeOf([ "1","0" ])
#--> TRUE

/*--------------------

o1 = new stzString("01234567")
? o1.IsMadeOfSome( OctalChars() )
#--> TRUE

o1 = new stzString("001100101")
? o1.IsMadeOf( BinaryChars() )
#--> TRUE

/*-------------------

o1 = new stzString("o01234567")
? o1.RepresentsNumberInOctalForm()
#--> TRUE

/*-------------------

o1 = new stzString("4E992")
? o1.IsMadeOfSome( HexChars() )
#--> TRUE

/*-------------------

o1 = new stzString("x4E992")
? o1.RepresentsNumberInHexForm()
#--> TRUE

/*-------------------

o1 = new stzString("maan")
? o1.IsMadeOf([ "m", "a", "a", "n" ])
#--> TRUE

/*--------------

# In Softanza you get get the unicode number of a char by saying:
? Unicode("鶊")
# And you have the code, you can pass it as an imput to a stzChar
# char object to get the char:
? StzCharQ(40330).Content() #--> 鶊

# If you are curious to know how I made it internally inside the
# Unicode() function, then fellow the following discussion...

# First we create the QChar from whatever a decimal unicode could be

oChar = new QChar(40220) # the char "鴜" coded on 3 bytes

# Second, we create a QString from that QChar

oStr = new QString2()
oStr.append_2(oChar)

# Third, we use toUtf8() on QString to get a QByteArray as a result,
# and then we call data() method on it to get the string with our "鴜"

? oStr.ToUtf8().data()
#--> 鶊

/*--------------

o1 = new stzString("abcbbaccbtttx")
? @@( o1.UniqueChars() )
#--> [ "a", "b", "c", "t", "x" ]

? o1.ContainsNOccurrences(2, :Of = "a")
#--> TRUE

/*---------------

o1 = new stzString("saस्तेb")
? o1.NumberOfChars()
#--> 7

? @@( o1.Unicodes() )
#--> [ 115, 97, 2360, 2381, 2340, 2375, 98 ]

? @@( o1.UnicodesXT() )
#--> [ [ 115, "s" ], [ 97, "a" ], [ 2360, "स" ], [ 2381, "्" ], [ 2340, "त" ], [ 2375, "े" ], [ 98, "b" ] ]

? @@( o1.CharsAndTheirUnicodes() )
#--> [ [ "s", 115 ], [ "a", 97 ], [ "स", 2360 ], [ "्", 2381 ], [ "त", 2340 ], [ "े", 2375 ], [ "b", 98 ] ]

/*---------------

o1 = new stzString("number 12500 number 18200")
? o1.OnlyNumbers()
#--> "1250018200"

/*================

o1 = new stzString("12500")
? o1.RepresentsNumberInDecimalForm() #--> TRUE

o1 = new stzString("b100011")
? o1.RepresentsNumberInBinaryForm() #--> TRUE

o1 = new stzString("100011") # Withount the b, it's rather a decimal not binary number!
? o1.RepresentsNumberInBinaryForm() #--> FALSE

o1 = new stzString("100011")
? o1.RepresentsNumberInDecimalForm() #--> TRUE

/*---------------

o1 = new stzString("Приве́т नमस्ते שָׁלוֹם")
? @@( o1.PartsUsing( "StzCharQ(@char).Script()" ) )
#--> [
# 	[ "Приве", "cyrillic" 	],
# 	[ "́", 	   "inherited" 	],
# 	[ "т",     "cyrillic" 	],
# 	[ " ",     "common" 	], 
#	[ "नमस्ते",         "devanagari" ],
# 	[ " ",     "common" 	],
o# 	[ "שָׁלוֹם", "hebrew" 	]
# ]

#TODO
? o1.PartsW('{
	Q(@part).Script() = :Cyrillic
}')
#--> [ "Приве", "т" ]

/*---------------

o1 = new stzString("🐨")
? o1.NumberOfChars() # returns 2! --> Number of CodePoints()
? o1.SizeInBytes() # returns 4

#TODO: Reflect on this: NumberOfChars() is actually NumberOfCodePoints()

/*---------------

? Q('[1, 2, 3]').ToList() #--> [1, 2, 3]

/*=============

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

/*================

StzStringQ("MustHave@32@Chars") {
	? NumberOfOccurrenceCS(:Of = "@", TRUE) #--> 2
	? FindAll("@") #--> [9, 12]

	? FindNext("@", :StartingAt = 5) #--> 9
	? FindNextNth(2, "@", :StartingAt = 5) #--> 12

	? FindPrevious("@", :StartingAt = 10) #--> 9
	? FindPreviousNth(2, "@", :StartingAt = 12) #--> 9
}

/*---------------- Used to enable constraint-oriented programming

o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
? o1.SubstringsBetween("@","@") #--> ["32", "8" ]

o1 = new stzString("MustHave32CharsAnd8Spaces")
? @@( o1.SubstringsBetween("@","@") ) #--> [ ]

/*======== REMOVE XT ==================================================

StartProfiler()
	
	o1 = new stzString("Ring programming♥ language")
	o1.RemoveXT("♥", :From = "programming♥")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*----------------
	
StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Each = "*", :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring programming language
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ 2, "*" ], :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring *programming* language
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :First = "*", :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring progr*amming* language
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Last = "*", :From = "*progr*amming*")
	
	? o1.Content()
	#--> Ring *progr*amming language
	
StopProfiler()
# Executed in 0.02 second(s)
	
/*----------------

StartProfiler()
	
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1,3], "*" ], :From = "*progr*amming*")
	
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

StartProfiler()
	
Q("Ring programming* language.") {
	
	RemoveXT("*", :After = "programming")
	? Content()
	#--> Ring programming language.
	
}
	
StopProfiler()
#--> Executed in 0.04 second(s)
	
/*-----------

StartProfiler()
	
Q("__♥)__♥)__♥)__") {
	
	RemoveXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.04 second(s)
	
/*-----------

StartProfiler()
	
Q("__♥__♥)__♥__") {
	
	RemoveXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__♥__♥__
	
}
	
StopProfiler()
# Executed in 0.04 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥)__♥__♥__") {

	RemoveXT( ")", :AfterFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.04 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥__♥__♥)__") {
	
	RemoveXT( ")", :AfterLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.05 second(s)

/*========== REMOVING BEFORE

StartProfiler()
	
Q("Ring ***programming language.") {
	
	RemoveXT("***", :Before = "programming")
	? Content()
	#--> Ring programming language.
	
}
	
StopProfiler()
#--> Executed in 0.05 second(s)
	
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
# Executed in 0.07 second(s)
	
/*-----------------

StartProfiler()
	
Q("__(♥__♥__♥__") {

	RemoveXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.07 second(s)
	
/*-----------------

StartProfiler()
	
Q("__♥__♥__(♥__") {
	
	RemoveXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__♥__
}
	
StopProfiler()
# Executed in 0.07 second(s)
	
/*------- REMOVING AROUND

StartProfiler()
	
Q("_-♥-_-♥-_-♥-_") {
	
	RemoveXT("-", :AroundEach = "♥") # Or simply :Around
	? Content()
	#--> _♥_♥_♥_
}
	
StopProfiler()
# Executed in 0.07 second(s)

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
# Executed in 0.06 second(s)

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
		RemoveXT("♥♥♥", :Between = ["/", :And = "\"])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.08 second(s)

/*---------

StartProfiler()

	Q("__/\/\__/♥\__") {
		RemoveXT("♥", :BetweenIB = ["/", "\"]) # BetweenIB -> Bounds are also removed
		? Content()
		#--> __/\/\____
	}

StopProfiler()
# Executed in 0.09 second(s)

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
# Executed in 0.12 second(s)

/*---------

StartProfiler()

	Q("/♥^♥\__/♥\/vv\__/^^^\__") {
		RemoveXT([], :Between = ["/", :And = "\"])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.08 second(s)

/*---------

StartProfiler()

	Q("/♥^♥\__/♥\/vv\__/^^^\__") {
		RemoveXT([], :BetweenIB = ["/", :And = "\"])
		? Content()
		#--> ______
	}

StopProfiler()
# Executed in 0.08 second(s)

/*---------

StartProfiler()

	Q("/♥♥♥\__/♥\/♥♥\__/♥\__") {
		RemoveXT("♥", [])
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.02 second(s)

/*---------

StartProfiler()

	Q("/♥♥♥\__/♥\/♥♥\__/♥\__") {
		RemoveXT([], "♥")
		? Content()
		#--> /\__/\/\__/\__
	}

StopProfiler()
# Executed in 0.02 second(s)

/*---------

StartProfiler()

	Q("_/♥\_/♥\_/♥♥\_/♥\_") {
		RemoveXT(:Nth = 4, "♥")
		? Content()
		#--> _/♥\_/♥\_/♥\_/♥\_
	}

StopProfiler()
# Executed in 0.02 second(s)

/*---------

StartProfiler()

	Q("^^♥^^") {
		RemoveXT( "♥", :AtPosition = 3)
		? Content()
		#--> ^^^^
	}

StopProfiler()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

	Q("♥^^♥^^♥") {
		RemoveXT( "♥", :AtPositions = [1, 7]) # or :At = [1, 7]
		? Content()
		#--> ^^♥^^
	}

StopProfiler()
# Executed in 0.08 second(s)

                 ///////////////////////////////////////////////
                //                              ///////////////
      ///////////      TO BE FIXED LATER       /////////////
 ///////////////                              //
///////////////////////////////////////////////

/*---------------- TODO : AFTER CONSTRAINT IMPLEMENTED

aList = [
	:Where = "file.ring",
	:What  = "Describes what happened",
	:Why   = "Describes why it happened",
	:Todo  = "Posposes an action to do"
]

StzListQ(aList).IsRaiseNamedParam() #--> TRUE

# Internally, StzList checks for a number of conditions

StzListQ(aList) {
	? NumberOfItems() <= 4 #--> TRUE
	? IsHashList() #--> TRUE
	? ToStzHashList().KeysQ().IsMadeOfSomeOfThese([ :Where, :What, :Why, :Todo ]) #--> TRUE
	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL") #--> TRUE
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
		:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = FALSE) }'
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

/*================== TODO: Fix error

? StzStringQ("ABTCADNBBABEFACCC").VizFind("A")

#--> 
#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^---

/*-----------------

o1 = new stzString("ABTCADNBBABEFACCC")
? o1.VizFindXT("A", [ :Numbered = TRUE, :Spacified = TRUE, :PositionSign = Heart() ])

#--> Returns a string like this:

#    "A B T C A D N B B A B E F A C C C "
#     ♥-------♥---------♥-------♥-------
#     1       5         0       4

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

/*=========== TODO: Review string comparaision logic in stzString

pron()

? Q("sam") < "samira"
#--> TRUE

? Q("samira") > "ira"
#--> TRUE

? Q("qam") = "sam"
#--> FALSE

? Q("QAM") = "qam"
#--> FALSE

proff()
# Executed in 0.06 second(s)
