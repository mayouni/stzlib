load "stzlib.ring"

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

? Basmalah() # --> ﷽

/*-----------------

o1 = new stzString("   ﷽ ")
o1.Trim()
? o1.Content() # --> 

/*-----------------

o1 = new stzString("   ﷽ ")
o1.Simplify()
? o1.Content()

/*=================

o1 = new stzString('[ "A","B", "C", "D", ]')
? o1.SplitXT(",", [])
#--> [ '[ "A"', '"B"', ' "C"', ' "D"', ' ]' ]

/*=================

# IDENTIFYING LISTS INSIDE A STRING

# In many situations (especially in advanced AI and ML applications),
# you may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in real time, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used (noramal [_,_,_] or short _:_), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,2,3]').IsListInString()		#--> TRUE
? StzStringQ('1:3').IsListInString()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInString()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInString()		#--> TRUE

# It tells you if the syntax used is normal or short:

? StzStringQ('[1,2,3]').IsListInNormalForm()		#--> TRUE
? StzStringQ('1:3').IsListInShortForm()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInShortForm()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInShortForm()		#--> TRUE

# And knows about the list beeing continuous or not:

? StzStringQ('[1,3]').IsContiguousListInString()	#--> TRUE
? StzStringQ('1:3').IsContiguousListInString()		#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInString()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInString()	#--> TRUE

	# REMINDER: A continuous list can be made of contiguous
	#  chars (base on their unciode codepints) or numbers,
	# and you can identify them using the stzList.IsContinuous():

	? StzListQ(1:3).IsContiguous()		#--> TRUE
	? StzListQ("A":"E").IsContiguous()	#--> TRUE


# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is contiguous
# or not, it can also see in what syntax thery are:

? StzStringQ('[1,3]').IsContiguousListInNormalForm()	#--> TRUE
? StzStringQ('1:3').IsContiguousListInShortForm()	#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInShortForm()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm()	#--> TRUE

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,2,3]').ToListInShortForm() )	#--> "1:3"
? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

? StzStringQ(' ["A","B","C","D"] ').ToListInShortForm()	#--> "A" : "D"
? StzStringQ(' "ا":"ج" ').ToListInShortForm()		#--> "ا" : "ج"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,2,3]').ToListInString() )	#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )	#--> "[1, 2, 3]"

? StzStringQ(' "A":"C" ').ToListInString()	#--> [ "A", "B", "C" ]
? StzStringQ(' "ا":"ج" ').ToListInString()	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# If you prefer (or need) the short form, there is an interesting
# alternative to the ToListInShortForm() alternative that uses
# the simple @C prefix, like this:

? @@( StzStringQ('[1,2, 3]').ToListInString@C() ) #--> "1 : 3"

? @@( StzStringQ('1:3').ToListInString@C() )		#--> "1 : 3"

? StzStringQ(' ["A","B","C","D"] ').ToListInString@C()	#--> "A" : "D"
? StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInString@C() #--> "ا" : "ت"


# Finally, as a "cerise sur le gâteau", you can evaluate
# the string in list in real time like this:

? StzStringQ('1:3').ToList()	   #--> [1, 2, 3]
? StzStringQ(' "A":"C" ').ToList() #--> ["A", "B", "C"]
? StzStringQ(' "ا":"ج" ').ToList() #--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

/*=================

# While finding occurrences of a substring inside a string,
# Softanza can return the positions or the sections of
# those substrings:

o1 = new stzString("how many many are there? So many!")
? @@( o1.FindPositions("many") )#--> [ 5, 10, 29 ]
? @@( o1.FindSections("many") )	#--> [ [ 5, 9 ], [ 10, 14 ], [ 29, 33 ] ]


# Softanza can also find substrings bounded between other substrings
# and return their positions, their sections, or their content:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? @@( o1.FindAnyBetween("<<",">>") )		# --> [ 9, 26, 41 ]
? @@( o1.FindAnySectionsBetween("<<",">>") )	# --> [ [ 9, 10 ], [ 26, 27 ], [ 41, 42 ] ]
? @@( o1.AnySubstringBetween("<<", ">>") )	# --> [ "word", "noword", "word" ]

# Or when you want to find not any bounded-substring but a speciefic one,
# just provide it to the following functions to get, for all its occurrences,
# the positions or the sections:

? @@( o1.FindBetween("word", "<<", ">>") )		# --> [ 9, 41 ]
? @@( o1.FindSectionsBetween("word", "<<", ">>") )	# --> [ [ 9, 16 ], [ 41, 48 ] ]

/*================

o1 = new stzString("**word1***word2**word3***")
? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveManySections([
	[1,2], [8, 10], [16, 17], [23, 25]
])

? o1.Content() # --> "word1word2word3"

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

# Let's pufify this nostalogic text from the "x" chars nlown everywhere in the string:

o1 = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International 
")

o1.Simplify() # Jst to remove spaces I put for readabiliy

o1.RemoveCharsWhereCS('{ @char = "X" }', :CS = true)
? o1.Content()

/*================= WORK IN PROGESS*******************************************

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceAnyBetween("<<", ">>", :With = "word")
? o1.Content()  # !--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceBetween("noword", "<<", ">>", :With = "word")
? o1.Content()  # !--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

/*================= TODO

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnyBetween("<<", ">>")
? o1.Content()	# !--> "bla bla <<>> bla bla <<>> bla <<>>"

/*---------------- TODO

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveBetween("noword", "<<", ">>")
? o1.Content()	# !--> "bla bla <<word>> bla bla <<>> bla <<word>>"

/*------------------- TODO (future)

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnyBetweenXT("<<", ">>", [ :RemoveBounds = TRUE ])
? o1.Content()  # !--> "bla bla  bla bla  bla "

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnyBetweenXT("<<", ">>", [ :RemoveBounds = TRUE, :Simplify = TRUE ])
? o1.Content()  # !--> "bla bla bla bla bla "

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnyBetween@("<<", ">>", '{ @str = Q(@str).Remove("<<>>")Q.Simplied()}')
? o1.Content()  # !--> "bla bla bla bla bla "

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveBetween("noword", "<<", ">>")
? o1.Content()	"bla bla <<word>> bla bla <<>> bla <<word>>"

/*================

StzStringQ("MustHave@32@Chars") {
	? NumberOfOccurrenceCS("@", :cs = true) #--> 2
	? FindAll("@") #--> [9, 12]

	? FindNext("@", :startingat = 5) #--> 9
	? FindNextNth(2, "@", :startingat = 5) #--> 12

	? FindPrevious("@", :startingat = 10) #--> 9
	? FindPreviousNth(2, "@", :startingat = 12) #--> 9
}

/*----------------

o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
? o1.SubstringsBetween("@","@") #--> ["32", "8" ]

o1 = new stzString("MustHave32CharsAnd8Spaces")
? o1.SubstringsBetween("@","@") #--> [ ]

/*=================

# To remove a substring form left or right you can
# use RemoveFromLeft() and RemoveFromRight() functions.

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromLeft("let's say ")
? o1.Content() # --> welcome to everyone!

# But when right-to-left strings are used, this can be
# confusing, because left is no longer at the start
# and right is no longer at the end of the string.

# So, if you wan to retrieve a substring from the
# beginnning of an arabic text, you should use
# RemoveFromRight() instead...

o1 = new stzString("أللّهم ارزقنا حسن الخاتمة")
o1.RemoveFromRight("أللّهم ")
? o1.Content() # --> ارزقنا حسن الخاتمة

# To avoid this complication, Softanza provides a more
# general (semantic) solution working both for
# left-to-right and right-to-left strings:
# the RemoveFromStart() and RemoveFromEnd() functions.

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromStart("let's say ")
? o1.Content() # --> welcome to everyone!

# and the same code for arabic:
o1 = new stzString("أللّهم ارزقنا حسن الخاتمة")
o1.RemoveFromStart("أللّهم ")
? o1.Content() # --> ارزقنا حسن الخاتمة

/*========================

o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
o1.RemoveNthOccurrence(:Last, "من")
? o1.Content()
# --> Gives من كان في زمنه من أصحابه فهو  أكبر المحظوظين

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrence(:Last, "A")
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrenceCS(:Last, "a", :CaseSensitive = FALSE)
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveLast("A")
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveFirst("A")
? o1.Content() # --> **1****A2***A3

/*==================

o1 = new stzString("<<word>>")

? o1.IsBoundedBy("<<", ">>") # --> TRUE

o1.RemoveBounds("<<",">>")
? o1.Content() # --> word

/*---------------

o1 = new stzString("word")
o1.AddBounds("<<",">>")	# --> or BoundWith()
? o1.Content()
#--> <<word>>

/*--------------- TODO (future)

o1 = new stzString("<<word>>")

? o1.Bounds() # !--> [ "<<", ">>" ]

? o1.LeftBound() # !--> "<<"
? o1.RightBound() # !--> ">>"

# And also FirstBound() and LastBound() for general
# use with left-to-right and right-toleft strings

/*==================//////////////////////// REVIEW AFTER CONSTRAINT IMPLEMENTED

aList = [
	:Where = "file.ring",
	:What  = "Describes what happend",
	:Why   = "Describes why it happened",
	:Todo  = "Posposes an action to do"
]

StzListQ(aList).IsRaiseParamList() # --> TRUE

# Internally, StzList checks for a number of conditions

StzListQ(aList) {
	? NumberOfItems() <= 4 # --> TRUE
	? IsHashList() # --> TRUE
	? ToStzHashList().KeysQ().IsMadeOfSome([ :Where, :What, :Why, :Todo ]) # --> TRUE
	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL") # --> TRUE
}

# In a better world, those conditions could be expressed as
# constraints on the list object like this:

StzListQ(aList) {
	:MustHave@4@Items,
	:MustBeAHashList,
	:AKeyMustBeOneOfThese = [ :Where, :What, :Why, :Todo ],
	:ValuesMustBeNonNullStrings
}

# To make it happen, those constraints should be defined once at
# the global level, and then reused every where inside a stzList




/*-----------------

? stzRaise("Simple error message!")
# --> Simple error message! 

/*-----------------

? stzRaise([
	:InFile	= "stzString.ring"
	:What 	= "Describes what happend",
	:Why  	= "Describes why it happened",
	:Todo 	= "Posposes an action to solve the error",
])
# --> Line 47 in file file.ring:
#	  What : Describes what happend
#	  Why  : Describes why it happened
#	  Todo : Posposes an action to do
#

/*-----------------/////////////////////////////////////////////////////////////////////*/
/*
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

]

# Let's use the constraints defined in a StzString object

StzStringQ("SOFTANZA") {

	EnforeConstraints([
		:MustBeUppercase,
		:MustNotExceed10Chars
	])

	? "Passed"
}

/*--------------- REFACTORED: test it again

# When the string is initiated with a non-null value,
# then the constraint is immediately active

StzStringQ("tunisia") {

//	CanNotBe(:NumberInString)
	MustBe('Uppercase()')

//	MustHave("NumberOfChars() <= 7")
//	CanNotHave("NumberOfChars() = 3")

//	Update("tunis") // "11223" is not lowercase nor uppercase!

}

/*--------------- //////////////////   ERROR: Fix constraints

# but when the string is initiated with a NULL value,
# then the constraint understands that it will be
# applicable in the future when the string gets updated

StzStringQ(NULL) {
	MustBe(:UpperCase)
}

? "--> Passed"

/*
StzListQ([ "a", "b" ]).MustBe(:IsSet)
? "--> Passed"

StzStringQ("12340").MustBe(:IsNumberInString)
? "--> Passed"

StzListQ([ "a", "b", "b" ]).CanNotBe(:IsSet)
? "--> Passed"

StzStringQ("18").CanNotBe(:IsNumberInString)
? "--> Passed"
/*

? StzStringQ("isChar").IsIsMethod()

/*

? IsTrue(:CaseSensitive = TRUE)
? IsFalse(:CaseSensitive = FALSE)

/*-----------------

o1 = new stzString("<<Go!>>")
? o1.BoundsRemoved("<<", ">>") # --> "Go!"

/*-----------------

o1 = new stzString("@str = Q(@str).Uppercased()")
? o1.BeginsWithOneOfTheseCS([ "@str =", "@str=" ], :CS = TRUE) # --> TRUE

/*-----------------

o1 = new stzString("Baba, Mama, and Dada")

? o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = FALSE) # --> TRUE

/*-----------------

StzStringQ('') {
	UpdateFromURL("https://ring-lang.github.io/doc1.16/qt.html")
	//? Split(" ")
	? Content()
}


/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {
	? FindOccurrenceCS(:of = "ring")
	# --> [ 1, 17, 39 ]

	? FindOccurrenceXT(:of = "ring")
	# --> [ [1, 4], [17, 20], [39, 42] ]
}

/*-----------------

#? VizFind("r")
StzStringQ("ring is not the ring you ware but the ring you program with") {

	? NextNthOccurrence(1, :of = "ring", :startingat = 1) # --> 1

	? NextNthOccurrence(2, :of = "ring", :startingat = 17) # --> 39

}

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? FindNextOccurrences(:Of = "ring", :StartingAt = 12) # --> [ 18, 40 ]

	? FindPreviousOccurrences(:Of = "ring", :StartingAt = 30) # --> [ 1, 17 ]

}

/*-----------------

? StzStringQ("ABTCADNBBABEFACCC").VizFindChar("A")

# --> Returns a string like this:

#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^---

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFACCC").VizFindCharXT("A")

# --> Returns a string like this:

#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^--- (4)
#	 1...5....0...4...

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindManyChars([ "A", "T", "V" ])

# --> Returns a string like this:

#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-.
#  "T" :  --^----.------.-^
#  "V" :  -------^------^--
#  "X" :  -----------------

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindMantCharsXT("A")

# --> Returns a string like this:

#	  1..4..7..0..3..6.
#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-. (3)
#  "T" :  --^----.------.-^ (2)
#  "V" :  -------^------^-- (2)
#  "X" :  ----------------- (0)

/*------------------

? Q("RINGO").HasCentralChar()		# --> TRUE
? Q("RINGO").CentralChar()		# --> N
? Q("RINGO").CentralCharPosition()	# --> 3
? Q("RINGO").HasThisCharInTheCenter("N") # --> TRUE

/*----------------------

? Q("ArabicArabicArabic").IsMultipleOf("Arabic")	  # --> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic") # --> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic") # --> FALSE

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = TRUE)	  # --> FALSE
? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = FALSE)	  # --> TRUE

/*----------------------

? Q("RingRingRing") / 3		# --> "Ring"
? Q("Ring;Python;Ruby") / ";"	# --> [ "Ring", "Pyhton", "Ruby" ]

? Q("RubyJavaRing") / [ "1993", "1995", "2016" ]
# --> [ "1993" = "Ring", "1995" = "Java", "2016" = "Ruby" ]

/*---------------------- 

? StzStringQ("My name is #.").ContainsMarquers()  # --> FALSE
? StzStringQ("My name is #0.").ContainsMarquers() # --> FALSE
? StzStringQ("My name is #1.").ContainsMarquers() # --> TRUE
? StzStringQ("My name is #01.").ContainsMarquers() # --> TRUE

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {

	? Marquers() # --> #1, #2, #3
}

StzStringQ("My name is #2, my age is #3, and my job is #1.") {

	? Marquers() # --> #2, #3, #1
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? Marquers()
	# --> [ "#1", "#2", "#3", "#1" ]

	? MarquersPositions()
	# --> [   12,   25,   44,   66 ]

	? MarquersAndPositions()
	# --> [ "#1" = 12, "#2" = 25 , "#3" = 44, "#1" = 66 ]

	? MarquersAndTheirpositions()
	# --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? FirstMarquer()		# --> #1

	? FindFirstMarquer()		# --> 12
	# You can also say:
	# 	? FirstMarquerOccurrence()	# --> 12
	# 	? FirstMarquerPosition()	# --> 12

	? LastMarquer()			# --> #1
	
	? FindLastMarquer()		# --> 66
	# You can also say:
		? LastMarquerOccurrence()	# --> 66
		? LastMarquerPosition()		# --> 66
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NthMarquer(2)			# --> #2

	? FindNthMarquer(2)		# --> 26
	# You can also say:
	#	? NthMarquerOccurrence(2)	# --> 26
	#	? NthMarquerPosition(2)		# --> 26
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NextNthMarquer(2, :StartingAt = 14) # --> #3
		? NthNextMarquer(2, :StartingAt = 14) # --> #3

	? FindNextNthMarquer(2, :StartingAt = 14) # --> 44
		? NextNthMarquerOccurrence(2, :StartingAt = 14)	# --> 44
		? NthNextMarquerOccurrence(2, :StartingAt = 14)	# --> 44
		? NextNthMarquerPosition(2, :StartingAt = 14) 	# --> 44
		? NthNextMarquerPosition(2, :StartingAt = 14)	# --> 44

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? MarquersAndTheirPositions()
	# --> # --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]

	? OccurrencesOfMarquer("#1") # --> [ 12, 66]
	? OccurrencesOfMarquer("#7") # --> []

	? MarquerByPosition(66)	# --> #1
	? MarquerByPosition(44) # --> #3

}
/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	? PreviousMarquers(:StartingAt = 50 ) # --> [ "#1", "#2", "#3" ]
	? NextMarquers(:StartingAt = 15)      # --> [ "#2", "#3", "#1" ]
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	? PreviousNthMarquer(3, :StartingAt = 50) # --> #1
	? PreviousNthMarquerPosition(3, :StartingAt = 50) # --> 12
	? PreviousNthMarquerAndItsPosition(3, :StartingAt = 50) # --> [ "#1", 12 ]
}
/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? PreviousMarquerAndItsPosition(:StartingAt = 50) # --> [ "#3", 44 ]

	? PreviousNthMarquerOccurrence(1, :StartingAt = 50)	# --> 44
	? NthPreviousMarquerOccurrence(1, :StartingAt = 50)	# --> 44
	? PreviousNthMarquerPosition(1, :StartingAt = 50) 	# --> 44
	? NthPreviousMarquerPosition(1, :StartingAt = 50)	# --> 44

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	//? MarquersSections()
	# --> [  [12, 13], [ 25, 26],  [44, 45], [66, 67]  ]

	//? MarquersAndSections()
	# --> [ "#1" = [12, 13], "#2" = [ 25, 26],  "#3" = [44, 45], "#1" = [66, 67] ]

	? MarquersAndTheirSections()
	# --> [ "#1" = [ [12,13], [66,67] ], "#2" = [ 25, 26],  "#3" = [44, 45] ]
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSortedInAscending() # --> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInAscending() # --> FALSE
}

/*---------------------- 

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSortedIndescending() # --> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInDescending() # --> FALSE
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSorted()		# --> TRUE
	? MarquersSortingOrder() 	# --> :Ascending
}

/*---------------------- 

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSorted()		# --> TRUE
	? MarquersSortingOrder() 	# --> :Descending
}

/*---------------------- 

StzStringQ("My name is #1, my age is #3, and my job is #2.") {	

	? MarquersAreUnsorted()		# --> TRUE
	? MarquersSortingOrder()	# --> :Unsorted

}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {	
	? NumberOfMarquers()	# --> 3
	? MarquersPositions()	# --> [ 24, 42, 65 ]
	
	? FindNextNthMarquer(2, :startingat = 14) # --> 42
	
	? MarquersPositionsSortedInAscending() # --> [ 24, 42, 65 ]
}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	? Marquers() # --> [ "#3", "#1", "#2" ]

	? MarquersAndPositionsSortedInAscending()
	# --> [ [ "#1", 24 ], [ "#2", 42 ], [ "#3", 65 ] ]

	? MarquersAndSectionsSortedInAscending()
	# --> [ "#1" = [24, 25], "#2" = [42, 43], "#3" = [65, 66] ]
}

/*---------------------- 

o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
? o1.MarquersAndSectionsSortedInDescending()
# --> [ "#3" = [45, 46], "#2" = [27, 28], "#1" = [12, 13] ]

/*---------------------- 

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? MarquersAndPositionsSortedInDescending()
	# --> [ [ "#3", 66 ], [ "#2", 44 ], [ "#1", 26 ], [ "#1", 12 ]   ]

	? MarquersAndSectionsSortedInDescending()
	# --> [ "#3" = [66, 67], "#2" = [44, 45], "#1" = [26, 27], "#1" = [12, 13 ] ]

}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	SortMarquersInAscending()
	? Content()
	# --> The first candidate is #1, the second is #2, while the third is #3!

	SortMarquersInDescending()
	? Content()
	# --> The first candidate is #3, the second is #2, while the third is #1!
}

/*----------------------

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.ReplaceSubstringsWithMarquersCS( [ "Ring", "Python", "Ruby", "PHP" ], :CS = TRUE )
? o1.Content()
# --> "#1 can be compared to #2, #3 and #4."

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.ReplaceSubstringsWithMarquersCS( [ "ring", "python", "ruby", "PHP" ], :CS = FALSE )
? o1.Content()
# --> "#1 can be compared to #2, #3 and #4."

/*----------------------

o1 = new stzString("BCAADDEFAGTILNXV")

? o1.CharsSortedInAscending()		# --> AAABCDDEFGILNTVX
? o1.CharsAreSortedInAscending()	# --> FALSE

? o1.CharsSortedInDescending()		# --> XVTNLIGFEDDCBAAA
? o1.CharsAreSortedInDescending()	# --> FALSE

? o1.charsSortingOrder()		# --> :Unsorted

/*----------------------

o1 = new stzString("BCAADDEFAGTILNXV")
? o1.CharsSortingOrder()	# --> :Unsorted

? o1.CharsSortedInAscending() 	# --> AAABCDDEFGILNTVX
? o1.CharsSortedInDescending()	# --> XVTNLIGFEDDCBAAA

? Q("AAABCDDEFGILNTVX").CharsAreSorted()	# --> TRUE
? Q("AAABCDDEFGILNTVX").CharsSortingOrder()	# --> :Ascending

? Q("XVTNLIGFEDDCBAAA").CharsSortingOrder()	# --> :Descending

/*----------------------

o1 = new stzString("My name is Mansour. What's your name please?")
? o1.FindManyCS( [ "name", "your", "please" ], :CS = TRUE )

# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

/*----------------------

o1 = new stzString("My name is Mansour. What's your name please?")
? o1.FindMany( [ "name", "your", "please" ] )

# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

/*----------------------

o1 = new stzString("My name is Mansour. What's your name please?")
? o1.FindManyCSXT( [ "name", "your", "please" ], :CS = TRUE )

# --> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

/*----------------------

o1 = new stzString("My name is Mansour. What's your name please?")
? o1.FindManyXT( [ "name", "your", "please" ] )

# --> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

/*----------------------

# The "A":"E" syntax is a beautiful feature of Ring:

? "A" : "E"	# --> [ "A", "B", "C", "D", "E" ]

# And it works backward also like this:

? "E" : "A"	# --> [ "E", "D", "C", "B", "A" ]

# Softanza reproduces it using UpTo() and DownTo() functions:

? Q("A").UpTo("E")	# --> [ "A", "B", "C", "D", "E" ]
? Q("E").DownTo("A")	# --> [ "E", "D", "C", "B", "A" ]

# And extends it to cover any Unicode char not only ASCII chars
# as it is the case for the Ring syntax:

? Q("ب").UpTo("ج") 	# --> [ "ب", "ة", "ت", "ث", "ج" ]
? Q("ج").DownTo("ب")	# --> [ "ج", "ث", "ت", "ة", "ب" ]

/*----------------------

o1 = new stzString("I Work For My Tomorrow")
? o1.RemoveCharQ(" ").Content() # --> IWorkForMyTomorrow

/*----------------------

? StzStringQ("geksjhsy").CharsReversed()	# --> yshjskeg

/*----------------------

StzStringQ("geksjhsy") {
	? CharsSortedInAscending()	# --> eghjkssy
	? CharsSortedInDescending()	# --> ysskjhge
}

/*----------------------

? StzStringQ("eghjkssy").CharsAreSortedInAscending()	# --> TRUE
? StzStringQ("ysskjhge").CharsAreSortedInDescending()	# --> TRUE

/*----------------------

? StzStringQ("abcd").IsAnagramOf("bcda")

/*----------------------

o1 = new stzString("KALIDIA")
o1.InsertBeforeW( '{ @char = "I" }', "*" )
? o1.Content() # --> KAL*ID*IA

/*----------------------

o1 = new stzString("KALIDIA")
o1.InsertAfterW( '{ @char = "I" }',"*" )
? o1.Content() # --> KALI*DI*A

/*----------------------

StzStringQ("12500;NAME;10;0") {
	? NextOccurrence( :Of = ";", :StartingAt = 1 ) # --> 6
	? NextNthOccurrence( 2, :Of = ";", :StartingAt = 5) # --> 11
}

/*----------------------

# One of the design goals of Softanza is to be as consitent as possible
# in managing Strings and Lists. In other terms, What works for both
# should provide you with the same semantics.

# To show this, the following code that plays with leading and trailing
# chars in a string...

StzStringQ( "***Ring++" ) {

	? HasLeadingChars() # --> TRUE
	? NumberOfLeadingChars() # 3
	? LeadingChars() # --> "***"
	
	? HasTrailingChars() # --> TRUE
	? NumberOfTrailingChars() # 2
	? TrailingChars() # --> "++"

	ReplaceRepeatedLeadingCharWith("+")
	? Content() # --> "+++Ring++"
	
	ReplaceLeadingAndTrailingCharsWith("*")
	? Content() # --> "***Ring**"
}

# works quiet the same with the items of this list:

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems() # --> TRUE
	? NumberOfLeadingItems() # 3
	? LeadingItems() # --> [ "*", "*", "*" ]
	
	? HasTrailingItems() # --> TRUE
	? NumberOfTrailingItems() # 2
	? TrailingItems() # --> [ "+", "+" ]

	ReplaceRepeatedLeadingItemWith("+")
	? Content() # --> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItemsWith("*")
	? Content() # --> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

/*----------------------

o1 = new stzString( "----@@--@@-------@@----@@---")
o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
? o1.Content() # --> ----@@--@@-------@@----##---

/*----------------------

o1 = new stzString( "----@@--@@-------@@----@@---")
o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
? o1.Content() # --> ----@@--##-------@@----@@---

/*----------------------

# Suppose you have this string containing data about some unicode chars
# and having this structure:
# HexCode	DecimalCode	CharName

str = "
0x005A	90	LATIN CAPITAL LETTER Z
0x005B	91	LEFT SQUARE BRACKET
0x005C	56	REVERSE SOLIDUS
0x005D	93	RIGHT SQUARE BRACKET
0x005E	94	CIRCUMFLEX ACCENT
0x005F	95	LOW LINE
"

# You are asked to extract the decimal code of a given char name,
# say "REVERSE SPLIDUS" for example

# Here is the solution:

o1 = new stzString(str)
n = o1.FindFirst("REVERSE SOLIDUS")
n2 = o1.PreviousOccurrence(:Of = TAB, :StartingAt = n) - 1
n1 = o1.PreviousOccurrence(:Of = TAB, :StartingAt = n2) + 1

? o1.Section(n1, n2) # --> 56

/*----------------------

? _@("DIGIT ZERO").IsCharName()
? _@("LATIN CAPITAL LETTER O").IsCharName()
? _@("JAVANESE PADA PISELEH").IsCharName()	// Fix this

/*----------------------

//? CharsNames()

/*----------------------

o1 = new stzString("ar_Arab_TN")
? o1.IsLocaleAbbreviation()

/*---------------------

# The standard (ISO) form of a locale is <langauge>_<script>_<country> where:
# 	-> <langauge> is an abbreviation of 2 or 3 lowercase letters
#	-> <script> is an abbreviation of 4 letters, the 1st beeing capitalised
#	-> <country) is an abbreviation of 2 or 2 uppercase letters
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
# In fact, both of these stadard forms return TRUE

? StzStringQ("ar_arab_tn").IsLocaleAbbreviation()	# --> TRUE

? StzStringQ("ar_TN").IsLocaleAbbreviation()		# --> TRUE
# (as a side note, Softanza doesn't care of the case, so do not feel any pressure)

# But this one also return TRUE
? StzStringQ("Arab_TN").IsLocaleAbbreviation()		# --> TRUE
# Which corresponds to the non-standard form <script>_<country>.

# And this is accepted by Softanza, because when you use it to create
# a locale object, Softanza inferes the language from the script, and
# constructs the hole standard-formed abbreviation for you:

? StzLocaleAbbreviationStringQ("Arab_TN").Abbreviation()	# --> "ar_Arab_TN"
# (as a side note, even if you don't respect standard lettercasing,
# Softanza accepts your inputs, and returns an abbreviation that
# is wellformed regarding to the standard!)

# You may think that you would abuse this spirit of flexibility by
# trying to induce Softanza in error by providing sutch an abbreviation
# form <scrip>_<language>:

? StzStringQ("arab_ar").IsLocaleAbbreviation()		# !--> FALSE

# The point is that the first abbreviation is a script ("arab" -> arabic),
# and that, conforming to the standard, the second one must be an abbreviation
# of a country ("ar" -> :Argentina). Try this:

? StzCountryQ("ar").Name()	# --> argentina

# And because :Argentina do not have arabic, neigher as a spoken language nor
# a written script, then the returned result is FALSE!

# When you do the same with a country like :Turkey or :Iran, for example,
# where arabic script is (historically) used in writtan turkish and persian
# languages, than the abbreviation is accepted to be well formed

? StzStringQ("arab_tk").IsLocaleAbbreviation()		# !--> TRUE

# And, therefore, you can use it to create locale object:

? StzLocaleAbbreviationStringQ("arab_tk").Abbreviation()	# --> ar_Arab_TK
? StzLocaleQ("ar_Arab_TK").CountryName()	# !--> :turkey NOT :Egypt

/*--------------------

o1 = new stzString("ritekode")

? o1.IsEqualTo("ritekode")			# --> TRUE
? o1.IsEqualToCS("RiteKode", :CS = FALSE)	# --> TRUE
? o1.IsEqualToCS("RiteKode", :CS = TRUE)	# --> FALSE


/*--------------------

? _("date").Q.IsLowercase() # --> TRUE
? _("date").Q.IsLowercaseOf("DATE") # --> TRUE

/*--------------------
# Here we take an example of a greek word

? _@("Σίσυφος").Script()	# --> greek
? _@("Σίσυφος").StringCase()	# --> capitalcase
? _@("ΣΊΣΥΦΟΣ").StringCase()	# --> uppercase
? _@("ΣΊΣΥΦΟΣ").Lowercased()	# --> σίσυφοσ
? _@("σίσυφοσ").Uppercased()	# --> ΣΊΣΥΦΟΣ
? _@("σίσυφοσ").Capitalcased()	# --> Σίσυφοσ

? _@("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = FALSE)	# --> TRUE
? _@("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = TRUE)	# --> FALSE

/*--------------------

# Let's take this example of a turkish letter ı that should be
# uppercased to İ and not I

? _@("ı").Script()	# latin (in fact this is a turk letter)
? _@("ı").StringCase()	# lowercase
? _@("İ").StringCase()	# uppercase

? _@("ı").UppercasedInLocale("tr-TR")	# ERROR: --> I but !--> İ
? _@("İ").Lowercased()	# i
? _@("İ").LowercasedInLocale("tr-TR")	# ERROR: --> i but !--> ı

# In fact, this is a logical bug in Qt as demonstrated here:

oQLocale = new QLocale("tr-TR")
? oQLocale.toupper("ı") # ERROR: --> I but !--> İ

# TODO: solve this by implementing the specialCasing of unicode as
# described in this file:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

/*
/*--------------------

# Do you think "ê" and "ê" are the same?
# If one should trust the visual shape of these two strings, then yes...
# but, the truth, is that they are different.

# In fact, both Ring and Softanza know it:
? "ê" = "ê" # --> FALSE
? _@("ê").IsEqualTo("ê") # --> FALSE

# and that's because:
_@("ê") { ? NumberOfChars() ? Unicode() } # --> 1 char	Unicode: 234

# while:
_@("ê") { ? NumberOfChars() ? Unicode() } # --> 2 chars	Unicodes: 101, 770

# And we can do even better by getting the names of the chars in every string
? _@("ê").CharName() # --> So "ê" contains one char called:
		     #     'LATIN SMALL LETTER E WITH CIRCUMFLEX'

? _@("ê").CharsNames() 	# --> while "ê" contains two chars called:
			#   [ 'LATIN SMALL LETTER E', 'COMBINING CIRCUMFLEX ACCENT' ]

# Combining characters is an advanced aspect of Unicode we are not going to delve
# in now. For more details you can read these FAQs at the following link:
# http://unicode.org/faq/char_combmark.html

/*-------------------- /////////// LOGICAL ERROR IN QT ////////////////

# Let's take the example of the german letter ß that
# should be uppercased to SS

? _@("ß").CharCase() # lowercase
? _@("ß").Uppercased() # --> SS

# Which is nice, and we can check it for a hole word
? StzStringQ("der fluß").Uppercased()	# --> DER FLUSS

# Now, if we check the other way around :
? _@("SS").Lowercased() # --> ss

# we don't get "ß", which is expected, because Softanza is running
# at the default locale ("C" locale) and not the german locale.

# Therefore, we need to tune the previous expression by sepecifying
# the german locale ("ge-GE")

? _@("SS").LowercasedInLocale("ge-GE") # !--> ß		ERROR --> ss

/*--------------------

? StzStringQ("der fluß").Uppercased()	# --> DER FLUSS
? StzStringQ("der fluß").IsLowercase()	# --> DER FLUSS

/*--------------------

//SetActiveLocale("de-DE")
? _@("DER FLUSS").Lowercased()


/*--------------------

//? _("der fluß").Q.IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE") # !--> TRUE

/*--------------------

StzStringQ("in search of lost time") {
	? TitlecasedInLocale([ :Country = :United_States ])
	# --> In Search Of Lost Time
	? CapitalisedInLocale([ :Country = :United_States ])
	# !--> In Search Of Lost Time
}

StzStringQ("à la recherche du temps perdu") {
	? TitlecasedInLocale([ :Country = :France ])
	# --> À la recherche du temps perdu
	? CapitalisedInLocale([ :Country = :France ])
	# !--> À la Recherche du Temps Perdu
}

/*--------------------

# All these return TRUE

? StzStringQ(:Arabic).IsScript()
? StzStringQ(:Arabic).IsScriptName()
? StzStringQ(:Arab).IsScriptAbbreviation()
? StzStringQ("1").IsScriptCode()

/*--------------------

o1 = new stzString("125.450")
o1.RemoveNthChar(7)
? o1.Content()

/*--------------------

o1 = new stzString("125.450")

o1.RemoveNthCharW(2, '{ @char = "2" }')
? o1.Content()	# --> "125.45"

? StzStringQ("125.450").NthCharRemovedW(2, '{ @char = "2" }')	# --> "125.45"

/*--------------------

? _("12.45600").@.RepeatedTrailingCharRemoved("0")	# --> "12.456"

/*--------------------

o1 = new stzString("000122.12")

? o1.HasRepeatedLeadingChars()		# --> TRUE
? o1.RepeatedLeadingChars()		# --> "000"
? o1.RepeatedLeadingCharsRemoved()	# --> "122.12"

/*--------------------

o1 = new stzString("000122.12")

? o1.RepeatedLeadingChar()		# --> "0"
? o1.RepeatedLeadingCharRemoved("0")	# --> "122.12"

? o1.RepeatedLeadingCharRemoved("X")	# --> "000122.12"

/*--------------------

o1 = new stzString("22.3450000")

? o1.HasRepeatedTrailingChars()		# --> TRUE
? o1.RepeatedTrailingChars()		# --> "0000"
? o1.RepeatedTrailingCharsRemoved()	# --> "2.345"

/*--------------------

o1 = new stzString("22.3450000")

? o1.RepeatedTrailingChar()		# --> "2"
? o1.RepeatedTrailingCharRemoved("2")	# --> "22.345"

? o1.RepeatedTrailingCharRemoved("X")	# --> "22.3450000"

/*--------------------

o1 = new stzString("ABC")
? o1.FirstChar() # --> A
? o1.LastChar()  # --> C

/*--------------------

o1 = new stzString("BATISTA123")
o1.RemoveNLastChars(3)
? o1.Content()	# --> BATISTA

? StzStringQ("BATISTA123").LastNCharsRemoved(3) # --> BATISTA

/*--------------------

o1 = new stzString("BATISTA1")
o1.RemoveLastChar()
? o1.Content()	# --> BATISTA

? StzStringQ("BATISTA1").LastCharRemoved() # --> BATISTA

/*--------------------

o1 = new stzString("123BATISTA")
o1.RemoveNFirstChars(3)
? o1.Content()	# --> BATISTA

? StzStringQ("123BATISTA").FirstNCharsRemoved(3) # --> BATISTA

/*--------------------

o1 = new stzString("1BATISTA")
o1.RemoveFirstChar()
? o1.Content()	# --> BATISTA

? StzStringQ("1BATISTA").FirstCharRemoved() # --> BATISTA

/*--------------------

o1 = new stzString("SOFTANZA IS AWSOME!")
? o1.IsEqualTo("softanza is awsome!")		# --> FALSE

/*--------------------

o1 = new stzString("SOFTANZA IS AWSOME!")
# TODO: Check performance of IsQuietEqualTo() --> Root cause RemoveDiacritics()
? o1.IsQuietEqualTo("softanza is awsome!")	# --> TRUE
? o1.IsQuietEqualTo("Softansa is aowsome!")	# --> TRUE
? o1.IsQuietEqualTo("Softansa iis aowsome!")	# --> FALSE

/*--------------------

o1 = new stzString("énoncé")
? o1.IsEqualTo("enonce")	# --> FALSE
? o1.IsQuietEqualTo("enonce")	# --> TRUE
? o1.IsQuietEqualTo("ÉNONCÉ")	# --> TRUE

/*--------------------

o1 = new stzString("mahmoud fayed")
? o1.IsQuietEqualTo("Mahmood al-feiyed")	# --> FALSE
? QuietEqualityRatio()	# --> 0.09

SetQuietEqualityRatio(0.35)
? o1.IsQuietEqualTo("Mahmood al-feiyed")	# --> TRUE

/*--------------------

# Operators on stzString

o1 = new stzString("SOFTANZA")

# Getting a char by position
? o1[5]		# --> "A"

# Finding the occurrences of a substring in the string
? o1["A"]	# --> [ 5, 8 ]
? o1["NZA"]	# --> [ 6 ]

# Getting occurrences chars verifying a given condition
? o1[ '{ _(@char).@.IsOneOfThese(["A", "T", "Z"]) }' ]	# --> [ 4, 5, 7, 8 ]

# Comparing the string with other strings
#? o1 = StringUppercase("softanza")	# --> TODO

# TODO: Complete the other operators when COMPARAISON methods are made in stzString

/*--------------------

o1 = new stzString("{{{ Scope of Life }}}")
? o1.IsBoundedBy("{","}") # --> TRUE
? o1.BoundsRemoved("{","}") # --> {{ Scope of Life }}

/*--------------------

o1 = new stzString("|<- Scope of Life ->|")
? o1.IsBoundedManyTimesBy([ ["|","|"], ["<",">"], ["-","-"] ]) # !--> TRUE
? o1.ManyBoundsRemoved([ ["|","|"], ["<",">"], ["-","-"] ]) # --> " Scope of Life "

/*--------------------

o1 = new stzString('"name"')
? o1.IsBoundedBy('"','"')

o1 = new stzString(':name')
? o1.IsBoundedBy(':', NULL)

/*--------------------

o1 = new stzString("one two three four")
o1.ReplaceAll( "two", "---")
? o1.Content() # --> one --- three four

/*--------------------

o1 = new stzString("one two three four")
o1.Replace([ "two", "four" ], "---")
? o1.Content() # --> one --- three ---

/*-------------------- //// TODO IN FUTURE /////

//? _("-").@.RepeatedNTimes( _("one").@.NumberOfChars() )

o1 = new stzString("one two three four")
o1.ReplaceAll("two", '{ _("-").@.RepeatedNTimes( _(@newstr).@.NumberOfChars() ) }')
? o1.Content() # --> one --- three ---

/*-------------------- //// TODO IN FUTURE /////

o1 = new stzString("one two three four")
o1.ReplaceAll([ "two", "four" ], '{ _("-").@.RepeatedNTimes( _(@newstr).@.NumberOfChars() ) }')
? o1.Content() # --> one --- three ---

/*-------------------- //// TODO IN FUTURE /////

o1 = new stzString("one two three four")
o1.ReplaceAll('{ _(@word).@.IsUppercase() }', '{ _("-").@.RepeatedNTimes( _(@word).@.NumberOfChars() ) }')
? o1.Content() # --> one --- three ---

/*--------------------

o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceCS(3, "Mio", :CS = TRUE)	# --> 16

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceStartingAtCS(1, "Mio", 1, :CS = TRUE)  # --> 4
? o1.FindNthOccurrenceStartingAtCS(2, "Mio", 7, :CS = TRUE)  # --> 16
? o1.FindNthOccurrenceStartingAtCS(1, "Mio", 20, :CS = TRUE) # --> 22

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceStartingAt(1, "Mio", 1)  # --> 4
? o1.FindNthOccurrenceStartingAt(2, "Mio", 7)  # --> 16
? o1.FindNthOccurrenceStartingAt(1, "Mio", 20) # --> 22

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.NthNextOccurrenceStartingAt(1, "Mio", 1) 	# --> 4
? o1.NthPreviousOccurrenceStartingAt(2, "Mio", 15)  # --> 4
? o1.NthPreviousOccurrenceStartingAt(4, "Mio", 25)  # --> 4

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.NextOccurrenceStartingAt("Mio", 7)       # --> 10
? o1.PreviousOccurrenceStartingAt("Mio", 15)  # --> 10

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.NextOccurrenceStartingAtCS("Mio", 7, :CS = TRUE)       # --> 10
? o1.PreviousOccurrenceStartingAtCS("Mio", 15, :CS = TRUE)  # --> 10

/*--------------------

o1 = new stzString("amd[bmi]kmc[ddi]kc")
? o1.ExtractBetweenSubstrings("[","]") # --> "bmi"
? "--"

/*--------------------

o1 = new stzString("216;TUNISIA;227;NIGER")
? o1.ExtractBetween(5, o1.NextOccurrenceOf( ";", :StartingAt = 5 ) - 1 )

/*--------------------

# Should return a list of strings but it returns nothing!
o1 = new stzString("amd[bmi]kmc[hvi]tnc")
? o1.ExtractBetween("[","]") # !--> [ "bmi", "hvi" ]

/*-------------------- ////////////// FIX IT //// or TODO in the future

# ExtractBetween can't manage deep combinations like this

o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
? o1.ExtractBetween("[","]")

/*--------------------

# In Softanza both n and N chars correspond to the letter "N"
o1 = new stzString("Adoption of the plan B")
? o1.ContainsTheLetters([ "N", "b" ]) # --> TRUE

/*--------------------

o1 = new stzString("opsus amcKLMbmi findus")
? o1.FindBetween("KLM", "amc", "bmi") # --> 10

/*--------------------

StzStringQ("__和平__a__و") {
	? ContainsLettersInScript(:Latin) 	# TRUE
	? ContainsLettersInScript(:Arabic)	# TRUE
	? ContainsLettersInScript(:Han)		# TRUE
	? ContainsCharsInScript(:Common)	# TRUE

	# Note that if you say
	? ContainsLettersInScript(:Common)	# or
	? ContainsLettersInScript(:Unkowan)
	# you get FALSE because there is no sutch letter that has a script
	# 'common'. In other terms, any letter in the worlds has to belong
	# to a knwan script.
}

/*--------------------

# Case sensisitivit is considered only for latin letters

? StzCharQ("9").IsLowercase() # FALSE
? StzCharQ("9").IsUppercase() # FALSE

? StzCharQ("ك").IsLowercase() # FALSE
? StzCharQ("ك").IsUppercase() # FALSE

? StzStringQ("120").IsLowercase() # FALSE
? StzStringQ("120m").IsLowercase() # TRUE
? StzStringQ("120M").IsUppercase() # TRUE

? StzStringQ("كلام").IsLowercase() # FALSE

/*--------------------

? StzStringQ("abcdef").ContainsNoOneOfThese([ "xy", "xyz", "mwb" ])

/*--------------------

? StzStringQ("tunis").Lowercased()	# tunis
? StzStringQ("tunis").Uppercased()	# TUNIS
? StzStringQ("tunis").Titlecased()	# Tunis
? StzStringQ("tunis").Foldcased()	# tunis

/*--------------------

? StzStringQ("tunis").IsLowercased()	# TRUE
? StzStringQ("TUNIS").IsUppercased()	# TRUE
? StzStringQ("Tunis").IsTitlecased()	# TRUE
? StzStringQ("tunis").IsFoldcased()	# TRUE

/*--------------------

? StringsAreEqualCS([ "abc","abc" ], :CaseSensitive = TRUE )
? StringsAreEqual([ "cbad", "cbad", "cbad" ])

? BothStringsAreEqualCS("abc", "abc", :CaseSensitive = TRUE)
? BothStringsAreEqual("abc", "abc")

/*--------------------

? StzStringQ("NumberOf").Section(1, -3)

/*--------------------

? _("HUSSEIN").@.ItemsW('{ _(@item).@.isLetter() }')
? _("HUSSEIN").@.NumberOfItemsW('{ _(@item).@.isLetter() }')

/*--------------------

? _("H").@.IsLetterOf("HUSSEIN")

/*--------------------

? StzStringQ("SOFTANZA").CharsReversed()
? StzStringQ(" softanza    natural coding   ").Simplified()

/*--------------------

# Counts the number of times a given Is/Method is verified
# on each char of the string ( IsLetter() and IsNumber()
# respectively in these two examples)

? StzStringQ("A1B2C3").NumberOfItemsThatAre(:Letter) # --> 3
? StzStringQ("A1B2C3").NumberOfItemsThatAre(:NumberInString) # --> 3

# Note that Item is used here on string, where normally char is
# used, like this:
/*
? StzStringQ("A1B2C3").NumberOfCharsThatAre(:Letter) # --> 3
? StzStringQ("A1B2C3").NumberOfCharsThatAre(:Number) # --> 3

# This naming exception is made to allow some generality in certain
# natural-coding features.

/*--------------------

? StringScript("عربي") # --> arabic
? StringScript("ring") # --> latin

/*-------------------

? StzStringQ('myfunc()').IsAlmostAFunctionCall()	#--> TRUE
? StzStringQ('my_func("name")').IsAlmostAFunctionCall()	#--> TRUE

/*-------------------

? StzStringQ("G").IsLetter() 	#	--> TRUE
? UppercaseOf("b")		# --> B
? LowercaseOf("B")		# --> b
? FoldcaseOf("sinus")		# !!! Undefined function

/*-------------------

# Are you confused between chars, bytes, unicodes (or unicode code points), and bytecodes?!
# Here how Softanza can help you see them all in all clarity:

StzStringQ("s㊱m") {
	? Chars()
	# --> [ "s", "㊱", "m" ]

	? Unicodes()
	# --> [ 115, 12977, 109 ]

	? UnicodesPerChar()
	# --> [ [ "s", 115 ], [ "㊱", 12977 ], [ "m", 109 ] ]

	? SizeInBytes() # --> 5

	? Bytes()
	# --> [ "s", "�", "�", "�", "m" ]
	? BytesPerChar()
	# --> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]
	? NumberOfBytesOfChar()
	# -->  [ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ]

	? Bytecodes()
	# --> [ 115, -29, -118, -79, 109 ]
	? BytecodesPerChar()
	# --> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]
}

/*-------------------

? StzStringQ("sAlut").IsLowercase() #--> FALSE

/*-------------------

? StzStringQ("@char___@char___@char").ReplaceAllQ("@char","@item").Content()
# --> @item___@item___@item


/*------------------

StzStringQ( "Text processing with Ring" ) {
	ReplaceAllCharsW(
		:Where = '{ @char = "i" }',
		:With = "*"	
	)

	? Content()
} # --> "Text process*ng w*th R*ng"

/*------------------- ERROR: FIX and add support of :With@ = "{ Condition }"

StzStringQ("1a2b3c") {
	ReplaceAllCharsW(
		:Where = '{ isString(@char) and stzStringQ(@char).isLowercase() }',
		:With  = "*"
	)

	? Content()
}

StzStringQ("1a2b3c") {
	ReplaceAllCharsW(
		:Where = '{ StzCharQ(@char).IsLetter() and StzCharQ(@char).isLowercase() }',
		:With@  = '{ StzCharQ(@char).Uppercased() }'
	)

	? Content()
}

StzStringQ("1a2b3c") {
	ReplaceAllCharsW(
		:Where = '{ _(@char).@.isLetter() and _(@char).@.IsLowercase() }',
		:With@  = '{ _(@char).@.Uppercased() }'
	)

	? Content()
}

/*-------------------- // ERROR : fix it

? StzStringQ("سَلَامُُ").IsMadeOfSomeOfThese( ListsMerge([ ArabicLetters(), Arabic7araket() ] ) )

/*--------------------

? StringInvert("LIFE") 	# --> ƎℲI⅂
? StringInvert("GAYA")	# --> Ɐ⅄Ɐ⅁
? StringInvert("TIBA")	# --> ⱯBIꞱ
? StringInvert("HANEEN") # --> NƎƎNⱯH
? StringInvert("MILLAVOY (Y908$)") # --> ($806⅄) ⅄OɅⱯ⅂⅂IƜ

/*-------------------

? "TIBA -->"
? StzStringQ("TIBA").Inverted()
? ""
? "HANEEN -->"
? StzStringQ("HANEEN").Inverted()
? "LIFE -->"
? StzStringQ("LIFE").Inverted()
? ""
? "GAYA -->"
? StzStringQ("GAYA").Inverted()
? ""
? "TELLAVIX (Y908$) -->"
? StzStringQ("TELLAVIX (Y908$)").Inverted()

/*------------------

o1 = new stzString("Ring Programming Language")
? o1.WalkBackward( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ) # --> 5
? o1.WalkForeward( :StartingAt =  6, :UntilBefore = '{ @char = "r" }' ) # --> 9

/*------------------

? StzTextQ("abc سلام abc").ContainsScript(:Arabic)	#--> TRUE
? StzTextQ("abc سلام abc").ContainsArabicScript()	#--> TRUE
# NOTE: Scripts are now moved from stzString to stzText
/*------------------

? StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content()		#--> év*nement
? StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content()	#--> év*nement

/*------------------

StzStringQ("original text before hashing") {
	Hash(:MD5)
	? Content() #--> 8ffad81de2e13a7b68c7858e4d60e263
}

/*-------------------
*/

//? StzStringQ("ring").StringCase() # --> :Lowercase
//? StzStringQ("RING").StringCase() # --> :Uppercase
//? StzStringQ("Ring").StringCase() # --> :Titlecase-----------------------------

/*-----------------

StzStringQ( "Text processing with Ring" ) {

	ReplaceAllCharsW(
		:Where = '{ @char = "i" }',
		:With = "*"
	)

	? Content()
}

/*-----------------

o1 = new stzString("A la recherche du temps perdu")
? o1.Titlecased()

/*-----------------////////////////////////

o1 = new stzString("Der Fluß")
? o1.Lowercased() # --> der fluß
? o1.LowercasedInLocale([ :Language = :German ]) # --> Should give fluss
#? o1.CaseFolded()

# --? TODO: support the special cases documented in unicode here:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

/*----------------- FIX THIS

// WalkUntil has not same output in stzString and stzList!

# In stzString only the last position is returned

? StzStringQ("size()").WalkUntil('@char = "("') # --> 4
? StzStringQ("size()").WalkUntil('@char = "*"') # --> 0

# In stzList all the walked positions are returned

StzListQ([ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]) {
	? WalkUntil("@item = 'D'") # --> 1:5
	? WalkUntil('@item = "x"') # --> 0
}

/*====================================

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@(o1.PartsAsSubstrings( :Using = 'StzCharQ(@char).CharCase()' ))	# or simply o1.Parts('StzCharQ(@char)')
# [
# 	[ "H", "uppercase" ],
# 	[ "anine", "lowercase" ],
# 	[ "o حنين o", NULL ],
# 	[ "is", "lowercase" ],
# 	[ " ", NULL ],
# 	[ "a", "lowercase" ],
# 	[ " ", NULL ],
# 	[ "nice", "lowercase" ],
# 	[ "o جميلة وعمرها 7 o", NULL ],
# 	[ "years", "lowercase" ],
# 	[ "-", NULL ],
# 	[ "old", "lowercase" ],
# 	[ "o سنوات o", NULL ],
# 	[ "girl", "lowercase" ],
# 	[ "!", NULL ]
# ]

? @@(o1.PartsAsSections( :Using = 'StzCharQ(@char).CharCase()' ))

#--> [
# 	[ [ 1, 1 ], 	"uppercase" 	],
# 	[ [ 2, 6 ], 	"lowercase" 	],
# 	[ [ 7, 12 ], 	NULL 		],
# 	[ [ 13, 14 ], 	"lowercase"	],
# 	[ [ 15, 15 ], 	NULL 		],
# 	[ [ 16, 16 ], 	"lowercase" 	],
# 	[ [ 17, 17 ], 	NULL		],
# 	[ [ 18, 21 ], 	"lowercase" 	],
# 	[ [ 22, 37 ], 	NULL		],
# 	[ [ 38, 42 ], 	"lowercase" 	],
# 	[ [ 43, 43 ], 	NULL		],
# 	[ [ 44, 46 ], 	"lowercase" 	],
# 	[ [ 47, 53 ], 	NULL 		],
# 	[ [ 54, 57 ], 	"lowercase"  	],
# 	[ [ 58, 58 ], 	NULL 		]
#    ]

? @@( o1.PartsAsSubstringsAndSections( :Using = 'StzCharQ(@char).CharCase()' ) )

#-->
# [ 	
# 	[ "H", 				[ 1, 1 ], 	"uppercase" 	],
# 	[ "anine", 			[ 2, 6 ], 	"lowercase" 	],
# 	[ "o حنين o", 			[ 7, 12 ], 	NULL		],
# 	[ "is", 			[ 13, 14 ], 	"lowercase" 	],
# 	[ " ", 				[ 15, 15 ], 	NULL		],
# 	[ "a", 				[ 16, 16 ], 	"lowercase" 	],
# 	[ " ", 				[ 17, 17 ], 	NULL		],
# 	[ "nice", 			[ 18, 21 ], 	"lowercase" 	],
# 	[ "o جميلة وعمرها 7 o", 	[ 22, 37 ], 	NULL		],
# 	[ "years", 			[ 38, 42 ], 	"lowercase" 	],
# 	[ "-", 				[ 43, 43 ], 	NULL		],
# 	[ "old", 			[ 44, 46 ], 	"lowercase" 	],
# 	[ "o سنوات o", 			[ 47, 53 ], 	NULL		],
# 	[ "girl", 			[ 54, 57 ], 	"lowercase" 	],
# 	[ "!", 				[ 58, 58 ], 	NULL		]
# ]

? @@( o1.PartsAsSectionsAndSubstrings( :Using = 'StzCharQ(@char).CharCase()' ) )

#-->
# [ 	
# 	[ [ 1, 1 ],	"H", 			"uppercase" 	],
# 	[ [ 2, 6 ],	"anine", 		"lowercase" 	],
# 	[ [ 7, 12 ],	"o حنين o", 		NULL		],
# 	[ [ 13, 14 ],	"is", 			"lowercase" 	],
# 	[ [ 15, 15 ],	" ", 			NULL		],
# 	[ [ 16, 16 ],	"a", 			"lowercase" 	],
# 	[ [ 17, 17 ],	" ", 			NULL		],
# 	[ [ 18, 21 ],	"nice", 		"lowercase" 	],
# 	[ [ 22, 37 ],	"o جميلة وعمرها 7 o", 	 NULL		],
# 	[ [ 38, 42 ],	"years", 		"lowercase" 	],
# 	[ [ 43, 43 ],	"-", 			NULL		],
# 	[ [ 44, 46 ],	"old", 			"lowercase" 	],
# 	[ [ 47, 53 ],	"o سنوات o", 		NULL		],
# 	[ [ 54, 57 ],	"girl", 		"lowercase" 	],
# 	[ [ 58, 58 ],	"!", 			NULL		]
# ]

//? o1.PartsClassified( :Using = 'StzCharQ(@char)' )  # TODO

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@( o1.Parts('{
	StzCharQ(@char).Script()
}') )

#--> [
#	[ "Hanine", "latin" 	],
#	[ " ", "common" 	],
#o 	[ "حنين", "arabic" 	],
#	[ " ", "common" 	],
#	[ "is", "latin" 	],
#	[ " ", "common" 	],
#	[ "a", "latin"	 	],
#	[ " ", "common" 	],
#	[ "nice", "latin" 	],
#	[ " ", "common" 	],
#o	[ "جميلة", "arabic" 	],
#	[ " ", "common" 	],
#o	[ "وعمرها", "arabic" 	],
#	[ " 7 ", "common" 	],
#	[ "years", "latin" 	],
#	[ "-", "common" 	],
#	[ "old", "latin" 	],
#	[ " ", "common" 	],
#o	[ "جميلة", "arabic" 	],
#	[ " ", "common" 	],
#	[ "girl", "latin" 	],
#	[ "!", "common" 	]
#    ]


/*---

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? o1.UniquePartsQ('StzCharQ(@char).Script()').ToStzHashList().Classify()
# --> [
#	:latin	 	= [ "Hanine", "is", "a", "nice", "years", "old", "girl" ],
#	:common		= [ " ", " 7 ", "-", "!" ],
#	:arabic		= [ "حنين", "جميلة", "وعمرها", "سنوات" ],
#     ]

? o1.UniquePartsQ('StzCharQ(@char).Script()').ToStzHashList().Klass(:arabic)
#--> Gives [ "حنين", "جميلة", "وعمرها", "سنوات" ]

/*-----------------

o1 = new stzString("AM23-X ")
? o1.Parts('StzCharQ(@char).CharType()')
# --> [
#	"AM" = :Letter_Uppercase,
#	"23" = :Number_Decimaldigit,
#	"-"  = :Punctuation_Dash",
#	"X"  = :Letter_Uppercase,
#	" "  = :Separator_Space
#    ]

/*-----------------

o1 = new stzString("Abc285XY&من")
? o1.Parts('{
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

/*-----------------

o1 = new stzString("maliNIGERtogoSENEGAL")
? o1.Parts(:Using = '{ StzCharQ(@char).CharCase() }')
#--> [ 	
#	"mali" 		= :Lowercase,
# 	"NIGER" 	= :Uppercase,
#	"togo" 		= :Lowercase,
#	"SENEGAL" 	= :Uppercase
#    ]

? o1.PartsAsSections(:Using = '{ StzCharQ(@char).CharCase() }')
#--> [ 	
#	[1, 4  ] = :Lowercase,
# 	[5, 9  ] = :Uppercase,
#	[10, 13] = :Lowercase,
#	[14, 20] = :Uppercase
#    ]

/*-----------------

o1 = new stzString("Abc285XY&من")
? o1.Parts( :Using = 'StzCharQ(@char).IsLetter()' )
# --> Gives:
# [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

? o1.Parts(:Using = "StzCharQ(@char).Orientation()")
# --> Gives:
# [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? o1.Parts(:Using = "StzCharQ(@char).IsUppercase()")
# --> Gives:
# [ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

? o1.Parts(:Using = "StzCharQ(@char).CharCase()")
# --> Gives:
# [ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

/*========================

StzStringQ( "Text processing with Ring" ) {

	ReplaceAllCharsW(
		:Where = '{ @char = "i" }',
		:With = "*"
	)

	? Content() #--> Text process*ng *ith*Ring
}

/*---------------

o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceAllChars( :With = "*" )

? o1.Content()
#--> *******************************

/*---------------

o1 = new stzString("Use these two letters: س and ص.")
? o1.FindAllCharsW(
	:Where = '{
		StzCharQ(@char).IsLetter() AND
		NOT StzCharQ(@Char).IsLatinLetter()
	}'
)
#--> [ 24, 30 ]

? o1.CharsW(
	:Where = '{
		StzCharQ(@char).IsLetter() AND
		NOT StzCharQ(@Char).IsLatinLetter()
	}'
)
#--> Gives [ "س", "ص" ]

/*---------------

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceAllCharsW(

	:Where = '{
		StzCharQ(@char).IsLetter() AND
		(NOT StzCharQ(@Char).IsLatinLetter())
	}',

	:With = '***'
)

? o1.Content()
#--> "Use these two letters: *** and ***."

/*---------------

? StzCharQ(":").IsPunctuation()	#--> TRUE
? StzCharQ(":").CharType() 	#--> punctuation_other

/*---------------

o1 = new stzString("Use these two letters: س and ص.")

o1.RemoveCharsWhereQ('{

	StzCharQ(@Char).IsArabicLetter() or
	StzCharQ(@char).IsPunctuation()

}')

? o1.Content() #--> "Use these two lettersand "

/*---------------

o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceAllCharsWhere(
	:Where = '{ NOT StzCharQ(@Char).IsLatinLetter() }',
	:With = "-"
)

? o1.Content() #--> "Use-these-two-letters----and---"

/*--------------

o1 = new stzString("SoftAnza Libraray")

? o1.CountCharsWhere('{
	@Char = "a"
}') # --> Gives 3

/*-------------- !!!! ERROR: FIXING IS IN PROGRESS !

o1 = new stzString("SoftAnza Libraray")

? o1.FindAllCharsWhere('{ Q(@Char).Lowercased() = "a" }') # --> Gives [ 5, 8, 14, 16 ]

/*---------------

o1 = new stzString("12")
? o1.Listify()  # Returns [ "12" ]

? o1.ListifyXT([ :NumberInStringIsTransformedToNumber = TRUE ]) # Returns [ 12 ]


/*---------------

o1 = new stzString("abc;123;gafsa;ykj")
? o1.NthSubstringAfterSplittingStringUsing(3, ";") #--> gafsa

return
/*------------------

? StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
	:TextAdjustedTo = :Center # or :Left or :Right or :Justified
])

#--> ╭─────────────────────┐
#    │ SOFTANZA IS AWSOME! │
#    └─────────────────────╯

/*------------------

StzStringQ("RING") {
	? Content()
	? Boxed()
	? BoxedRound()
	? BoxedRoundDashed()

	? EachCharBoxed()
	? VizFindAll("I")
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
#   ┌───┬───┬───┬───┐
#   │ R │ I │ N │ G │
#   └───┴─•─┴───┴───┘


/*------------------

StzStringQ("MY BEAUTIFUL RING") {
	? Content()
	? Boxed()
	? BoxedRound()

	//? BoxedEachChar()
	//? BoxedEachCharRound()

	? VizFindAll("I")

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

#--> MY BEAUTIFUL RING
#   ┌───────────────────┐
#   │ MY BEAUTIFUL RING │
#   └───────────────────┘
#   ╭───────────────────╮
#   │ MY BEAUTIFUL RING │
#   ╰───────────────────╯
#   ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
#   │ M │ Y │   │ B │ E │ A │ U │ T │ I │ F │ U │ L │   │ R │ I │ N │ G │
#   └───┴───┴───┴───┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴───┴─•─┴───┴───┘
#   ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
#   ┊ MY BEAUTIFUL RING ┊
#   └╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
#   ╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
#   ┊ MY BEAUTIFUL RING ┊
#   ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯
#   ╭───────────────────┐
#   │ MY BEAUTIFUL RING │
#   └───────────────────╯

/*---------------

? StzStringQ("ar_TN-tun").ContainsEachCS(["_", "-"],:CS = TRUE)	#--> TRUE
? StzStringQ("ar_TN-tun").ContainsBoth("_", "-") #--> TRUE

/*---------------

o1 = new stzString("a")
o1 * [ "b", "c", "d" ]
? o1.Content()	#--> Gives 'abacad'

/*---------------

o1 = new stzString("abcdefj")
? o1 / 2	#--> [ "abcd", "efj" ]
? o1 % 2	#--> "efj"

/*--------------

o1 = new stzString("ab-ac-ad")
? o1 / "-" # Same as ? o1.Split("-")
#--> [ "ab", "ac", "ad" ]


/*--------------

o1 = new stzString("a")
o1.MultiplyBy([ "b", "c", "d" ])
? o1.Content() #--> "abacad"

/*--------------

o1 = new stzString("a")
o1 * [ "b", "c", "d" ]
? o1.Content() #--> abacad


/*--------------

o1 = new stzString("happy-holidays")
? o1.IsLowercase() #--> TRUE

o1 = new stzString("HOLIDAYS!")
? o1.IsUppercase() #--> TRUE

//////////////////////////////////////////////////////////////////////////////
//////////////////// REACHED THIS LEVEL IN FIXING ERRORS       //////////////
////////////////////////////////////////////////////////////////////////////

/*----------------

StzStringQ(".Very... tutorial interesting. tutorial very tutorial.") {
	? FindNextOccurrenceCS("TUTORIAL", :StartingAt = 40, :CS = false) #--> 45

	? SplitToPartsOfNCharsXT(3, :Direction = :Backward)

	? FindAll("tutorial")
	? NumberOfOccurrence("tutorial") + NL
	? FindAllCS("tutorial", :cs = false)
}

/*------------------

o1 = new stzString('These are some words. Also, these are other words: word, word, and word!')
? o1.Words()
? o1.UniqueWords()
? o1.UniqueWordsCS(:CS = FALSE)

/*-------------------

o1 = new stzString( "Mohammed Ali
Ben Salah" )

? o1.BackToStartOfLine( :StartingAt = 16 ) # --> Ben

/*------------------

str = "   سلام"
o1 = new stzString(str)

? o1.HasRepeatedLeadingChars()
? "'" + o1.RepeatedLeadingChar() + "'"
o1.TrimRight() ? o1.Content()

o1 = new stzString("eeeTUNIS") # 	
? o1.RepeatedLeadingChar() # --> 'e'
? o1.RepeatedLeadingChars() # --> 'eee'

o1 = new stzString("exeeeeeTUNIS") # 	
? o1.RepeatedLeadingChar() # --> '' NULL
? o1.RepeatedLeadingChars() # --> '' NULL

/*-------------------

o1 = new stzString(" same   ")
o1 { TrimStart() ? "'" + Content() + "'" }

/*-------------------

o1 = new stzString( "Sentence one.  Sentence two! Sentence three" )
? o1.BacktoStartOfSentence( :StartingAt = 28 )

/*

o1 = new stzString( "Mohammed Ali Ben Salah" )
? o1.BackwardToStartOfWord( o1.NumberOfChars() )
#? o1.BackwardToStartOfNthWord(3, :StartingAt = :End) # --> Ali

/*--------------------

o1 = new stzString( "Sentence game one. fine two Sentence two! Another one here.
Another one their. It's not so long but this is a real text. Real text is not a joke.
A joke is somthing we can share. Other than joke we can't share!" )


str = "
One pay-as-you-go one Might have thought it was was already exciting enough for our 
Physics Project to model be showing a path to an fundamental theory 
of physics and an fundamental description of how our physical 
universe works. But what I’ve increasingly been realizing is 
that actually it’s showing us something model even bigger and deeper: 
a whole fundamentally new paradigm for making models and in general 
for doing theoretical science. And I fully expect that this new 
paradigm will give us ways to address a remarkable range of 
longstanding central problems in all sorts of areas of science—as 
well as suggesting whole new areas and new directions to pursue.

If one looks at the history of theoretical science, I think one 
can identify just three major modeling paradigms that have been 
developed over the course of model scientific history—each of them 
leading to dramatic progress. The first, originating in antiquity, 
one might call the “structural paradigm”. Its key idea is to think 
of things in the world as being constructed from some kind of 
simple-to-describe elements—say geometrical objects—and then 
to use something like logical reasoning to work out what will 
happen with them. Typically this paradigm has no explicit notion 
of time or dynamical change, though in its modern model forms it often 
involves making model descriptions of structures of relationships, 
usually built from logical or “flowchart-like” elements.
"

/*------------------------ // ERROR: Fix this

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
//? o1.ToSetOfChars()
? o1.Letters()
//? o1.UniqueLetters()
/*
? o1.Scripts()
? o1.ScriptsPerChar()

#? o1.IsLatinScript()

// First solution : takes +7 seconds

	# t0 = clock()

	# ? o1.RemovePunctuationQ().RemoveArabic7araketQ().RemoveNumbersQ().SimplifyQ().Content()

	# ? NL ? (clock() - t0) / clockspersecond()

// Second solution: takes +6 seconds

	# t0 = clock()

	# o1 {
	# 	RemovePunctuation()
	# 	RemoveArabic7araket()
	# 	RemoveNumbers()
	# 	Simplify()
	# 
	# 	? Content()
	# }

	# ? NL ? (clock() - t0) / clockspersecond()


// Third solution: takes less then a second!
 
	# t0 = clock()

	# ? o1.OnlyLettersAndSpacesQ().SimplifyQ().SplitQ(" ").RemoveDuplicatesQ().Content()
	
	# ? (clock() - t0) / clockspersecond()

#? o1.Words()
#? o1.SetOfWords()
# o1.WordsPositions()
#? o1.NumberOfOccurrenceOfWord("model")


#? o1.ForwardToEndOfWord( :StartingAt = 1 )

#? o1.ForwardToEndOfNthWord(3, :StartingAt = 9)

/*---------------

str = "first line
second line
third line"

o1 = new stzString(str)
? o1.UntilEndOfLine( :StartingAt = 14 )

/*---------------

o1 = new stzString(" One. Two! Three?")
? o1.UntilEndOfSentence( :StartingAt = 12 )

/*---------------

o1 = new stzString( "Mohammed Ali Ben Salah" )
? o1.UntilEndOfWord( :StartingAt = 14 )

/*---------------

/* FIX IT!
? o1.Section( -5, -1 )
? o1.Section( -5, :end )
? o1.Section( :end, :start )

/*---------------

o1 = new stzString( "Mohammed Ali Ben Salah Come on" )
#? o1.UntilEndOfWord( :StartingAt = 10 )
# ? o1.Section( :start, :endofword )
#? o1.Section( 10, :endofword )

? o1.Section( :start, :endofsentence)
#? o1.Section( -5, -3 )

/*----------------

o1 = new stzString("eeeeTUNISIAiiiii")

o1 {
	? HasRepeatedLeadingChars()
	? NumberOfRepeatedLeadingChars()
	? RepeatedLeadingchars()
	? RepeatedLeadingCharsQ().Content() + NL
	
	? HasRepeatedTrailingChars()
	? NumberOfRepeatedTrailingChars()
	? RepeatedTrailingChars()
	? RepeatedTrailingCharsQ().Content() + NL	
}

/*-----------------

o1 = new stzString("eeebxeTuniseee")
o1 {

	RemoveNLeftChars(3)
	RemoveNRightChars(3)
	# RemoveFirstNChars(3)
	# RemoveLastNChars(3)

	? Content()
	
}

/*----------------

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveRepeatedLeadingChars()
	RemoveRepeatedTrailingChars()
	
	? Content() # --> Tunis
}


o1 = new stzString("eeeTuniseee")
o1 {
	RemoveRepeatedLeadingAndTrailingChars()
	? Content() # --> Tunis
}

/*-----------------

o1 = new stzString("eeebxeTuniseee")

? o1.Section(:end, :start)
? o1.Section( 7, 4 )

/*-----------------

o1 = new stzString("___VAR---")
o1.ReplaceRepeatedLeadingChar("-")
? o1.Content()

/*----------------- TODO (future)

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

/*----------------

o1 = new stzString("bbxeTuniseee")
? o1.RepeatedLeadingChars()
? o1.HasRepeatedLeadingChars()

/*-----------------

o1 = new stzString("eeebxeTuniseee")
o1 {
	ReplaceLeadingChar(".") # 'eeeTUNIS' --> '...TUNIS'
	//ReplaceLeadingSubstring("</") # 'eeeeeeeTUNIS' --> '</TUNIS'

	? Content()
}

/*-----------------

str = "
SoftanzaLib is made for simplicity, efficiency and beauty.

These are a lot of practical examples. Use them now!

Cheers.
"
? StzStringQ(str).Words()

/*-----------------

? StzStringQ("first sentence. second sentence. third sentence.").Split(".")

/*-----------------

? StzListQ([
	:Line = :Thin,	# or :Dashed

	:AllCorners = :Rectangular, # or :Round or
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	:Width = 17,
	:TextAdjustedTo = :Center # or :Left or :Right
]).IsTextBoxedParamList()

? StzStringQ("PARIS").BoxedXT([ :AllCorners = :Round, :Width = 20, :TextAdjustedTo = :Center ])

StzStringQ("ONE BO TAF") {

#	? BoxedRound()
#	? BoxedEachCharRound()

#	? BoxedEachCharXT([ :AllCorners = :Round, :Numbered = TRUE ])

	? VizFindAll("F")
#	? VizRoundFindAllCS("o", :cs = false)

#	? VizRoundFindAll("B")
#	? VizRoundFindAllCS("b", :cs = false)

#	? VizFindAllXT("o", [
#		:CS = FALSE, :Line = :Dashed, :AllCorners = :Round, :Numbered = TRUE ])

	# ? BoxedEachWord()

}

/*--------------------- //// TODO: fix error!

? StzStringQ("RINGORIALAND").BoxedXT([
	:Line = :Thin,	# or :Dashed
	:AllCorners = :Round, # or :Round or
	:Corners = [ :Round, :Rectangular, :Rectangular, :Round ],

	:TextAdjustedTo = :Center, # or :Left or :Right
	:EachChar = TRUE
])

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,	# or :Dashed

	:AllCorners = :Rectangular, # or :Round or
	//:Corners = [ :Rectangular, :Rectangular, :Round, :Round ],

	:Width = 21, # Adjusting the width manually
	:TextAdjustedTo = :Center # or :Left or :Right
])

/*-------------------

? (StzStringQ("XRingoriaLand") - [ "X", "oria", "Land" ]).Content()	# --> Ring
? (StzStringQ("XRingoriaLand") - [[ :FirstCharIf, :EqualTo, "X" ]]).Content() # --> RingoriaLand

/*-------------------

? StzStringQ("[ 2, 3, 5:7 ]").IsListInString()
? StzStringQ("'A':'F'").IsListInString()

/*-------------------

StzStringQ("Happy Morning People!") {
	ReplaceSectionQ(:From = 7, :To = :EndOfWord, :With = "Life")
	? Content()
}

/*------------------- HERE!!!!

o1 = new stzString( "Tunis is my town. Tunisia is my nation!")
o1.ReplaceAllOccurrencesOfWordCS( "Tunis", "Regube", :CS = FALSE )
? o1.Content()

/*-------------------

o1 = new stzString( "Tunis is my town. Tunisia is my nation!")
o1.ReplaceManyWords( [ "Tunis", "Tunisia" ], :EachChar = "*", :CS = FALSE )
? o1.Content()

/*-------------------


StzStringQ( "Tunis is the container of my memories. Tunis is my dream!") {
	ReplaceAll("Tunis", "Regueb" )
	? Content()
}

/*-------------------

StzStringQ( "Tunis is the container of my memories. Tunis is my dream!") {
	ReplaceAllCS("tunis", "Regueb", :CS = FALSE )
	? Content()
}
/*-------------------

StzStringQ( "Tunis is the container of my memories. Tunis is my dream!") {
	ReplaceAll("Tunis", :EachChar = "*" )
	? Content()
}

/*-------------------

StzStringQ( "Tunis is the container of my memories. Tunis is my dream!") {
	ReplaceAllCS("tunis", :EachChar = "*", :CS = FALSE )
	? Content()
}

/*-------------------

StzStringQ( "a + b - c / d = 0" ) {
	ReplaceMany( [ "+", "-", "/" ], "*" )
	? Content()
}

/*-------------------

? _@("Smart Customs Hackathon").Section(7, :EndOfWord)	# --> Customs
? _@("Smart Customs Hackathon").Section(:From = 7, :To = :EndOfWord)	# --> Customs
? _@("Smart Customs Hackathon").Section(:From = 7, :To = :EndOfString)	# --> Customs Hackathon
? _@("Smart Customs Hackathon").Section(:From = 7, :To = :End)	# --> Customs Hackathon

/*-------------------

StzStringQ("Tunisia is back! People united.") {

	ReplaceAll("People", "Tunisians")
	? Content() + NL	# --> Tunisia is back! Tunisians united.

	? Section(3, 7)		# --> nisia

	? Section(7, 3) + NL	# --> nisia

	? Section(:From = 3, :To = :EndOfWord)	# --> nisia
	? Section(:From = 12, :To = :EndOfWord) + NL	# --> back

	? Section(:From = 9, :To = :EndOfSentence) + NL	# --> is back!

	? Section(:From = :FirstChar, :To = :EndOfString) + NL	# --> Tunisia is back! Tunisians united.

	ReplaceFirst("Tunisia", :With = "Egypt") 
	Replace( "Tunisians", :With = "Egyptians")
	? Content()	# --> Egypt is back! Egyptians united.

}

/*----------------

o1 = new stzString("this text is my text not your text, right?!")
? o1.FindAllCS("text", :casesensitive = false)
? o1.FindNthOccurrence(2, "Text")
? o1.FindNthOccurrenceCS(2, "Text", :casesensitive = true)

/*----------------

o1 = new stzString("this text is my text not your text, right?!")
//? o1.ReplaceNthOccurrenceCSQ(1, "text", "destiny", :Casesensitive = TRUE).Content()
? o1.ReplaceAllCSQ("text", "destiny", :Casesensitive = TRUE).Content()

o1 = new stzString("هذا نصّ قلبي ليس نصّ قلبك ويا له من نصّ يا صديقي")
? o1.FindLastOccurrenceCS("نصّ", :casesensitive = true)

/*---------------

o1 = new stzString("XLandRingoriaLand")
? o1.RemoveLastOccurrenceCSQ("Land", :CS = TRUE).Content()

# or:
o1 - "Land"
? o1.Content()

/*---------------

o1 = new stzString("ring language isسلام  a nice language")
? o1.ContainsHybridOrientation()
o1 = new stzString("سلام عليكم ياأهل مصر الكرام")
? o1.Orientation()

/*----------------

o1 = new stzString("سلام عليكم يا أهل مصر الكرام")
o1.RemoveNLeftChars(5)
? o1.Content()

/*----------------

o1 = new stzString("ring language is nice language")
? o1.NLastCharsRemoved(9) # --> ring language is nice
? o1.SectionQ(1,4).CharsReversed() --> gnir

/*----------------

o1.RemoveNRightChars2(5)
? o1.Content()

/*----------------

o1 = new stzString("سلام عليكم يا أهل مصر الكرام")
? o1.ReplaceLastOccurrenceQ("سلام", "").Content()

o1 = new stzString("ring language is a nice language")
? o1.ReplaceFirstOccurrenceQ("language", "").Simplified()

/*----------------

o1 = new stzString("<<script>>func return :done<<script>>")

#? o1.RemoveLeftOccurrenceQ("<<script>>").Content()
#? o1.RemoveRightOccurrenceQ("<<script>>").Content()
? o1.RemoveAllQ("<<script>>").Content()


//o1.RemoveNLastChars(9)
//? o1.Content()

/*----------------

o1 = new stzString("<<script>>func return :done<<script>>")

//? o1.RemoveNLastCharsQ(9).Content()
o1 = new stzString("softanza loves simplicity")
? o1.ReplaceFirstQ( o1.Section(10, :End), "arrives!").Content()

/*----------------

o1 = new stzString("<script>func return :done<script/>")

? o1.IsBoundedBy("<script>", "<script/>") # returns TRUE

? o1.BoundsUpToNChars(8) # returns [ "<script>", "<script/>" ]

o1.RemoveBoundsQ("<script>", "<script/>")
? o1.Content()

/*----------------

? StzStringQ("{nnnnn}").IsBoundedBy("{","}")

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.IsBoundedBy("بسم", "الرّحيم")

/*----------------

o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceQ("xo", "ng").Content()

/*----------------

o1 = new stzString("Ringos Ringos Ringos")
o1.RemoveAll("os")
? o1.Content()

o1 = new stzString("extrasection")
? o1.RemoveRangeQ(6, :end).Content()

o1 = new stzString("extrasection")
? o1.RemoveSectionQ(6, :end).Content()

/*----------------

? StringAlign("SOFTANZA", 30, ".", :Left)
? StringAlign("SOFTANZA", 30, ".", :Right)
? StringAlign("SOFTANZA", 30, ".", :Center)
? StringAlign("SOFTANZA", 30, ".", :ALong) + NL

# -->
/*
SOFTANZA......................
......................SOFTANZA
...........SOFTANZA...........
S....O...F...T...A...N...Z...A
*/

/*----------------

str = "منصوريّات"
? StringAlign(str, 30, ".", :Left)
? StringAlign(str, 30, ".", :Right)
? StringAlign(str, 30, ".", :Center)
? StringAlign(str, 30, ".", :ALong)

# -->
/*
......................منصوريّات
منصوريّات......................
...........منصوريّات...........
م....ن...ص...و...ر...يّ...ا...ت
*/
/*----------------

aTempList = Arabic7araket() + ArabicShaddah()
? aTempList
o1 = new stzString("مَنْصُورِيَّاتُُ")
? o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ])

/*----------------

// Aligning right-to-left text using Qt
o1 = new QString2()
o1.append("السّلام عليكم")
oChar = new QChar(46)
? o1.leftjustified(30, oChar, FALSE)
? o1.RightJustified(30, oChar, FALSE) + NL

// Aligning right-to-left text using StzLib
cArabicText = "السّلامُ عليكم"
? StringAlign(cArabixText, 30, :Left)
? Stringalign(cArabixText, 30, :Right)

// And if you want to go object-oriented
o1 = new stzString("السّلامُ عليكم")
? o1.Copy().LeftAlignQ(30, ".").Content()
? o1.Copy().RightAlignQ(30, ".").Content()

/*-----------------

o1 = new stzString("منصوريات")
? o1.NFirstCharsQ(3).Uppercased()
? o1.NLastCharsQ(3).Uppercased()

/*------------------

# ABCDEFGH > 10011011 => ADEGH
o1 = new stzString("ABCDEFGH")
? o1.CompressUsingBinary("1001100000")

/*------------------

? StzStringQ("سَلَامُُ").IsMadeOfSome( ListsMerge([ ArabicLetters(), Arabic7araket() ] ) )
# # --> TRUE

/*------------------

o1 = new stzString("aabbcaacccbb")
? o1.IsMadeOf([ "aa", "bb", "c" ])		# --> TRUE
? o1.IsMadeOfSome([ "a", "b", "c", "x" ])	# --> TRUE

/*------------------

o1 = new stzString("سلسبيل")
? o1.IsMadeOf([ "ب", "ل", "س", "ي" ])		# --> TRUE
? o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ])	# --> FALSE
? o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ])	# --> TRUE

/*------------------

o1 = new stzString("In the name of People, I will govern you People, And call you People!")
//o1.InsertBefore("People", "Bad ")
o1.InsertAfter("People", " X")
? o1.Content()

/*------------------ ERROR!!

o1 = new stzString("NoWomanNoCry")
anPos = o1.FindCharsW('Q(@char).IsUppercase()')
? o1.SplitBeforePositions(anPos)
# --> [ "No", "Woman", "No", "Cry" ]

/*------------------

StzStringQ("أهلا بأيّ كانَ، ومرحبا بأيّ كان، ومرحى لأيّ كان، أيّا كان من سمَّاهُ حُسَيْنْ") {

	cSubStr = "أيّ كان"
	cNewSubStr = " اسْمُهُ حُسَيْنْ"

	InsertBefore(cSubStr,cNewSubStr)
	? Content()
}
# -->
/*
أهلا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحبا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحى لأيّ كان اسْمُهُ حُسَيْنْ، أيّا كان من سمَّاهُ حُسَيْنْ
*/

/*-------------------

o1 = new stzString("Hi Dan! Your are Dan, but your work is always not done ;)")
o1.ReplaceNthOccurrence(2, "Dan", "nice")
# --> Hi Dan! Your are nice, but your work is always not done ;)
? o1.Content()

/*-------------------

o1 = new stzString("text this text is written with the text of my scrampy text")
? o1.FindAll("text")	# --> [ 1, 11, 36, 55 ]

? o1.FindNthOccurrence(4, :Of = "text")	# 55

? o1.ContainsNtimes(4, "text") # --> TRUE

/*--------------------

# There are two types of comparison of strings:
#	-> Unicode comparison: strings are compared conforming conforming to Uniocode logic
#	-> Softanza comparison: strings are compared naturally as expected in real worlf

o1 = new stzString("reserve")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Equal

o1 = new stzString("réservé")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Greater

o1 = new stzString("reserv")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Less

/*--------------------

# Strings comparisons are made in a locale-sensitive manner
o1 = new stzString("RÉSERVÉ")
? o1.UnicodeCompareWithInSystemLocale("réservé")	# --> :Greater
# ? o1.UnicodeCompareWithInLocale(""réservé"", "fr-FR")	# TODO

/*--------------------

o1 = new stzString("  lots   of    whitespace  ")
? o1.Trimmed()
? o1.SimplifyQ().UPPERcased()

/*--------------------

o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
o1.ReplaceAll("فلانة", "طيبة")
? o1.Content()

/*--------------------

o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
"Où bien tu n'aimes pas que ce soit Foulèna?")
? o1.ReplaceAll("Foulèna", "Tiba")

/*--------------------

? str2hex("سلام")
? hex2str("d8b3d984d8a7d985")

? dec("0x23DEA298")
? hex(601793176.32)

o1 = new stzNumber("601793176.32")
? o1.ToHexForm()

/*--------------------

o1 = new stzString("0o20723.034")
o1 {
	? RepresentsNumber()
	? RepresentsSignedNumber()
	? RepresentsUnsignedNumber()
	? RepresentsCalculableNumber() 
	
	? RepresentsInteger()
	? RepresentsSignedInteger()
	? RepresentsUnsignedInteger()
	? RepresentsCalculableInteger()
	
	? RepresentsRealNumber()
	? RepresentsSignedRealNumber()
	? RepresentsUnsignedRealNumber()
	? RepresentsCalculableRealNumber()
	
	? RepresentsNumberInDecimalForm()
	? RepresentsNumberInBinaryForm()
	? RepresentsNumberInHexForm()
	? RepresentsNumberInOctalForm()
}

/*------------------

? o1.RepresentsRealNumber() # fix: returns TRUE for "12500543."
? o1.RepresentsCalculableInteger()
? o1.RepresentsCalculableRealNumber()

/*------------------

o1 = new stzString("0b-110001.1001")
? o1.RepresentsNumberInBinaryForm()

/*------------------

o1 = new stzString("0x12_5AB34.123F")
? o1.RepresentsNumber()

/*------------------

? o1.RepresentsNumberInHexForm()

o1 = new stzString("0o-2304.307")
? o1.RepresentsNumberInOctalForm()

/*------------------

o1 = new stzString("me and you and all the others, and even bob!")
? o1.FindAll("and")
? o1.PositionAfterNthOccurrenceOfSubstring(2, "and")

/*------------------

o1 = new stzString("All our software versions must be updated!")

# Defining the position of insertion
nPosition = o1.PositionAfter("versions")

//PositionAfterSubstring

# Inserting the list of string using extended configuration
o1.InsertListOfSubstringsXT(
	[ "V1", "V2", "V3", "V4", "V5" ], nPosition,

	[
	:InsertBeforeOrAfter = :Before,
	:OpeningChar = "{ ",
	:ClosingChar = " }", 

	:MainSeparator = ",",
	:AddSpaceAfterSeparator = TRUE,

	:LastSeparator = "and",
	:AddLastToMainSeparator = TRUE,

	:SpaceOption = :EnsureLeadingSpace + :EnsureTrailingSpace
	])

? o1.Content()
# --> All our software versions { V1, V2, V3, V4, and V5 }  must be updated!

/*------------------

o1 = new stzString("latin")
? o1.IsScriptName()

/*------------------

o1 = new stzString("TN-fr") # tn-fr gives true --> Incorrect!
? o1.IsLocaleAbbreviation()

/*------------------

o1 = new stzString("fr")
? o1.IsLocaleAbbreviation()

/*------------------

o1 = new stzString("105")
? o1.IsLanguageNumber()
? o1.IsLanguageNumberXT()

/*------------------

o1 = new stzString("ara")
? o1.IsLanguageAbbreviation()
? o1.IsShortLanguageAbbreviation()
? o1.IsLongLanguageAbbreviation()
? o1.IsLanguageAbbreviationXT()

/*------------------

o1 = new stzChar("Ⅱ")
? o1.IsMandarinNumber()
? o1.IsANumber()

# TODO:
# 	Should go to stzString class
# 	Homogenize the semantics of ArabicNumber, ArabicNumerals, ArabaicDecimalDigit...

? StringIsNumberFraction("1/2") # arabic
? StringIsArabicNumberFraction("1/2") 

? StringIsNumberFraction("۱/٢") # indian
? StringIsNumberFraction("Ⅰ/Ⅱ") # roman
? StringIsNumberFraction("一/二") # mandarin

//? StringToNumberFractionChar("一/二")

/*----------------

oQStr = new QString()
oQStr.append("salem")
? QStringToString(oQStr)

/*----------------

// Longest substring without repeating characters
str = "ABCEFCGAEBCAF"
o1 = new stzString(str)
? o1.FindAll("A")
? o1.Section(1,3)

/*----------------

// TODO: check this!

// Substrings without repeating characters
substr1 = "ABCEFCG"
substr2 = "BCEFCGAE"
substr3 = "CEF"
substr4 = "EFCGA"
substr5 = "🧢🎓👨‍👧‍👧👒👩‍👩‍👦‍👦🎩"
substr6 = "🎓👨‍👧‍👧👒👩‍👩‍👦‍👦🎩"
substr7 = " 👨‍👧‍👧👒👩‍👩‍👦‍👦🎩🎓"
substr8 = "🎩🎓👒🧢"
substr9 = "🎓👒🧢"
substr10 = "👒🧢"
substr11 = "🧢"

? SubstringsWithoutRepatingChars("ABCEFCG")

func SubstringsWithoutRepatingChars(str)
	aResult = []
	oStr = new stzString(str)
	for i = 1 to oStr.NumberOfChars()
		n = oStr.FindFirstStartingAt(oStr[i],i+1)

		if n = 0 { n = oStr.NumberOfChars() }
		cTempStr = oStr.Section(i,n-1)

		oTempStr = new stzString(cTempStr)
		cResult = ""
		
		aResult + cResult
	next
	return aResult

/*---------------------

c = "number;type;value;description
0001;<control>;review;START OF HEADING
0002;<data>;compensation;START OF TEXT
0003;<action>;compensation;END OF TEXT
0004;<control>;closestream;END OF TRANSMISSION
"

o1 = new stzString(c)
? o1.Split(";",:foreward)

/*----------------------

o1 = new stzString("xxxabcefxxx")
? o1.RemoveFrom("x", :LeftAndRight)

/*---------------------

o1 = new stzString("1234")
? o1.StringIsFormedOfSomeOfTheseChars(DecimalDigits())
? o1.RepresentsNumberInDecimalForm()

/*--------------------

o1 = new stzString("100110001")
? o1.StringIsFormedOfTheseChars([ "1","0" ])

/*--------------------

o1 = new stzString("b100110001")
? o1.RepresentsNumberInBinaryForm()

/*--------------------

o1 = new stzString("01234567")
? o1.StringIsMadeOfSome(OctalChars())

/*-------------------

o1 = new stzString("o01234567")
? o1.RepresentsNumberInOctalForm()

/*-------------------

o1 = new stzString("4E992")
? o1.StringIsMadeOfSome(HexChars())

/*-------------------

o1 = new stzString("x4E992")
? o1.RepresentsNumberInHexForm()

/*-------------------

o1 = new stzString("maan")
? o1.StringIsMadeOf([ "m", "a", "a", "x" ])

/*------------------

# How th get the char content from a char unicode?
# Note: This logic has been implemented in Unicode() function in stzChar class

# First we create the QChar from whatever a decimal unicode could be

oChar = new QChar(40220) # the char "鴜" coded on 3 bytes

# Second, we create a QString from that QChar

oStr = new QString()
oStr.append_2(oChar)

# Third, we use toUtf8() on QString to get a QByteArray as a result,
# and then we call data() method on it to get the string with our "鴜"

? oStr.ToUtf8().data()

/*--------------

o1 = new stzString("abcbbaccbtttx")
? o1.UniqueChars()
? o1.Contains_N_OccurrenceOf(2, "a")

/*---------------

o1 = new stzString("saस्तेb")
? o1.NumberOfChars()

? o1.UnicodeOfCharN(3)
? o1.UnicodesByChar()

/*---------------

o1 = new stzString("number 12500 number 18200")
? o1.OnlyNumbers() # --> 1250018200

/*---------------

o1 = new stzString("12500")
? o1.RepresentsNumberInDecimalForm() # --> TRUE

o1 = new stzString("b100011")
? o1.RepresentsNumberInBinaryForm() # --> TRUE

o1 = new stzString("100011") # Withount the b, it's rather a decimal not binary number!
? o1.RepresentsNumberInBinaryForm() # --> FALSE

o1 = new stzString("100011")
? o1.RepresentsNumberInDecimalForm() # --> TRUE

/*---------------

o1 = new stzString("Приве́т नमस्ते שָׁלוֹם")
? o1.Chars()

/*---------------

o1 = new stzString("🐨")
? o1.NumberOfChars() # returns 2! --> Number of CodeUnits()
? o1.SizeInBytes() # returns 4

// NumberOfChars() is actually NumberOfCodeUnits()

/*---------------

? Q("Приве́тو ب नमस्ते שָׁלוֹם****sd(((").Letters()
# --> П, р, и, в, е, т, و , ب, न, म, स, त, ש, ל, ו, ם, s, d

