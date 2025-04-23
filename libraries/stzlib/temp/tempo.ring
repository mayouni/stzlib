
load "../max/stzmax.ring"

/*---
*/
pr()

? @@( Walk2D([2, 2], [5, 5], 2)) + NL
#--> [
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]

# Visual representation:

#   1 2 3 4 5
# 1 . . . . .
# 2 . S . o .
# 3 o . o . o
# 4 . o . o .
# 5 o . o . E

? @@( Walk2D([2, 2], [5, 5], [2, 2 ]) ) + NL
#--> [
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]

# Visual representation:

#   1 2 3 4 5
# 1 . . . . .
# 2 . S . o .
# 3 o . o . o
# 4 . o . o .
# 5 o . o . E

? @@( Walk2D([2, 2], [5, 5], [1, 2, 3]) )
#--> [
#	[ 2, 2 ], [ 3, 2 ], [ 5, 2 ],
#	[ 3, 3 ], [ 4, 3 ],
#	[ 1, 4 ], [ 4, 4 ], [ 5, 4 ],
#	[ 2, 5 ], [ 5, 5 ]
# ]

# Visual representation:

#   1 2 3 4 5
# 1 . . . . .
# 2 . E o . o
# 3 . . o o .
# 4 o . . o o
# 5 . o . . o

pf()
# Executed in 0.01 second(s) in Ring 1.22

func Walk2D(paPairStart, paPairEnd, pSteps)
    aResult = []
    nX1 = paPairStart[1]
    nY1 = paPairStart[2]
    nX2 = paPairEnd[1]
    nY2 = paPairEnd[2]
    
    # Generate all positions in the grid
    aAllPos = []
    for j = 1 to nY2
        for i = 1 to nX2
            aAllPos + [i,j]
        next
    next
    
    oStzList = new stzList(aAllPos)
    n1 = oStzList.FindFirst(paPairStart)
    n2 = len(aAllPos)
    
    # Check if pSteps is a number or a list
    if isNumber(pSteps)
        # Use fixed step size
        for i = n1 to n2 step pSteps
            aResult + aAllPos[i]
        next
    else
        # Use cyclic list of steps
        currentStep = 1
        i = n1
        
        while i <= n2
            aResult + aAllPos[i]
            
            # Get the current step from the list
            stepSize = pSteps[currentStep]
            
            # Move to next position
            i += stepSize
            
            # Move to next step in the cycle
            currentStep++
            if currentStep > len(pSteps)
                currentStep = 1
            ok
        end
    ok
    
    return aResult
/*
# Define the Walk2D function
func Walk2D(paPairStart, paPairEnd, pnStep)

	aResult = []

	nX1 = paPairStart[1]
	nY1 = paPairStart[2]

	nX2 = paPairEnd[1]
	nY2 = paPairEnd[2]

	# Walking the first horizontal line
	n = 0

	aAllPos = []

	for j = 1 to nY2
		for i = 1 to nX2
			aAllPos + [i,j]
		next
	next

	oStzList = new stzList(aAllPos)
	n1 = oStzList.FindFirst(paPairStart)
	n2 = len(aAllPos)

	n = 0
	for i = n1 to n2 step pnStep
		aResult + aAllPos[i]
	next

	return aResult

/*----------- #narration Conditional Code()

# Any function in Ring can be turned Conditional by adding the W()
# suffix to it. Which enables us to solve various algorithmic problems
# in an interesting and flexible way.

# Let's take an example of the SubStrings() function:

pr()

Q("Ali 12500 Tony 24800 Claude 12340") {

	? @@S(  SubStrings() ) + NL	# @@S() ~> ShowShort()
	#--> [ "A", "Al", "Ali", "...", "3", "34", "4" ]

	? HowManySubStrings() + NL
	#--> 561

	? SubStringsWXT('
		IsNumberInString(@SubString) and
		ring_substr1(@SubString, " ") = 0 and
		len(@SubString) = 5 '
	)
	#--> [ "12500", "24800", "12340" ]
}

# The code shows the SubStrings() function in stzString class (returned
# by the small Q() function at the first line).

# The function returns a large number of possible substrings (561 exactly!).
# To filter them and get only the numbers that we have after each person's
# name, we can do it by adding ...W() to the function and feeding
# it with the necessary conditions.

pf()
# Executed in 5.46 second(s).

/*-----

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 3)
	? Content()

	#--> [ "A" , "B", "A", "C", "D" ]
}		

pf()
# Executed in 0.03 second(s).

/*=====

pr()

o1 = new stzString("--<<one>>---<<two>>---")
? @@( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [ 5, 7 ], [ 15, 17 ] ]

pf()
# Executed in 0.01 second(s).


/*-----

pr()

Q("Hello MAX!") {

	LowercaseXT("AX")
	? Content()
	#--> Hello Max!

	InsertXT(" dear ", :Between = [ "Hello", :And = "Max" ])
	? Content()
	#--> "Hello dear Max!"

}

pf()
# Executed in 0.07 second(s).

/*====

pr()

? @@( Q(1:3) + 4 )
#--> [ 1, 2, 3, 4 ]

? StzType( Q(1:3) + Q(4) )
#--> stzlist

? @@( ( Q(1:3) + Q(4) ).Content() )
#--> [ 1, 2, 3, 4 ]

? ( Q(1:3) + Q(4) ).ToStzListOfNumbers().Sum() + _NULL_
#--> 10

? StzType( QQ(1:3) )
#--> stzListOfNumbers

? @@( QQ(1:3) + 4 )
#--> [ 5, 6, 7 ]

? ( QQ(1:3) + Q(4) ).Sum()
#--> 18

pf()
# Executed in 0.08 second(s).

/*----

pr()

# Q() elevates 1:3 to a StzList object.me()

# The "-" operator seeks for a value inside the
# list, and if found, # it will remove it

? @@( Q(1:5) - 5 )
#--> [ 1, 2, 3, 4 ]

# We can retrieve the item and return, not the list content
# like in the example above, but a stzList object

? StzType( Q(1:5) - Q(5) )
#--> stzlist

# Check its content, you will see that 5 has been removed

? @@( ( Q(1:5) - Q(5) ).Content() )
#--> [ 1, 2, 3, 4 ]

# We can chain other actions on the stzList object

? ( Q(1:5) - Q(5) ).ToStzListofNumbers().Sum()
#--> 10

# We can deel directly with a stzListOfNumbers object,
# by using the QQ() elevator instead of Q():

? @@( QQ(1:5) - 5 )
#--> [ -4, -3, -2, -1, 0 ]

# In this case, the "-" operator takes a different meaning:
# retrieving the value 5 from to each number in the
# stzListOfNumbers object.

# And because we used - 5, the output was a normal
# list [ -4, -3, -2, -1, 0 ]

# So if we want the output to be a stzListOfNumbers object,
# we elevate 5 to Q(5), like this:

? StzType( QQ(1:5) - Q(5) )
#--> stzListOfNumbers

# And hence we can take further actions on it:

? ( QQ(1:5) - Q(5) ).Sum()
#--> -10

pf()
# Executed in 0.07 second(s).

/*---- #narration Using Q() * n , Q() * Q(n), QQ() * n, and QQ() * Q(n)

pr()

# Q() elevates 1:3 to a StzList object
# The * operator duplicates the list 3 times

? @@( Q(1:3) * 3 )
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]

# We do the same and return not a list but a
# stzList object by using Q(3) instead of 3

? StzType( Q(1:3) * Q(3) )
#--> stzlist

# Let's check the content of the returned object:

? @@( ( Q(1:3) * Q(3) ).Content() )
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]

# We can chain other actions on the stzList object

? ( Q(1:3) * Q(3) ).FlattenQ().ToStzListofNumbers().Sum()
#--> 18

# If we need to deel with a stzListOfNumbers object directly,
# then we use QQ() instead of Q():

? StzType( QQ(1:3) * Q(5) )
#--> stzListOfNumbers

# In this case, the * operatir changes its behaviour and
# no longer duplicates the list 3 times!

# Let's see what it does then, when applied to a stzListOfNumbers

? @@( ( QQ(1:3) * Q(5) ).Content() )
#--> [ 5, 10, 15 ]

# As you see, * operator multipled each number of the list of
# numbers by 3, which is logical.

# And hence we can do the Sum() on it directly:

? ( QQ(1:3) * Q(5) ).Sum()
#--> 30

pf()
# Executed in 0.07 second(s).

/*---- #narration semantics of Q() / n

pr()

# Q() elevates 1:9 to a stzList. Divided by 3, the list
# is actually splitted into 3 parts

? @@( Q(1:9) / 3 ) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

# Using QQ(), the 1:9 is now elevated to a stzListOfNumbers.
# Dividing those numbers by 3, divides each number by 3

? @@( QQ(1:9) / 3 ) + NL
#--> [ 0.33, 0.67, 1, 1.33, 1.67, 2, 2.33, 2.67, 3 ]

# Using Q(3) as the divisor (and not only 3) ensures the output
# is a Softanza object, allowing for further method chaining...

# Let's check this by getting the return type

? StzType( Q(1:9) / Q(3) )
#--> stzList

# Hence, chaining actions becomes possible:

? @@( ( Q(1:9) / Q(3) ).Content() ) + NL
#-> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? ( Q(1:9) / Q(3) ).FlattenQ().ToStzListOfNumbers().Sum()
#--> 45

? ( Q("A":"I") / Q(3) ).FlattenQ().ToStzListOfStrings().LowerCaseQ().Joined()
#--> abcdefghi

pf()
# Executed in 0.15 second(s).

/*====

pr()

o1 = new stzList(1:8)
? o1.Cumulate() # Or Reduce()
#--> 36

? @@( o1.CumulateXT() ) + NL
#--> [ 1, 3, 6, 10, 15, 21, 28, 36 ]

#--

o1 = new stzList("A":"C")
? o1.Cumulate()
#--> ABC

? @@( o1.CumulateXT() ) + NL
#--> [ "A", "AB", "ABC" ]

#--

o1 = new stzList([ 1:2, 3, 4 ])
? @@( o1.Cumulate() )
#--> [ 1, 2, 3, 4 ]

? @@( o1.CumulateXT() )
#--> [ [ 1, 2 ], [ 1, 2, 3 ], [ 1, 2, 3, 4 ] ]

pf()
# Executed in 0.02 second(s).

/*----

pr()

o1 = new stzGrid( "A" : "M" )

? @@NL(o1.Content())
#--> [
#	[ "A", "B", "C", "D", "E" ],
#	[ "F", "G", "H", "I", "J" ],
#	[ "K", "L", "M", ".", "." ]
# ]

? o1.CountHLines()

pf()
# Executed in 0.02 second(s).

/*----- #TODO fix error

pr()

? MostSquareLikeFactors(12)
#--> [ 3, 4 ]

? MostSquareLikeFactors(13)
#--> [ 3, 5 ]

#--

? @@NL( StzGridQ(13).Content() ) + NL
#--> [
#	[ ".", ".", "." ],
#	[ ".", ".", "." ],
#	[ ".", ".", "." ],
#	[ ".", ".", "." ],
#	[ ".", ".", "." ]
# ]

StzGridQ( "A" : "M" ) { ? @@NL(Content()) } + NL
#--> [
#	[ "A", "B", "C", "D", "E" ],
#	[ "F", "G", "H", "I", "J" ],
#	[ "K", "L", "M", ".", "." ]
# ]


? StzGridQ( "A" : "M" ).Show() #TODO fix it!

pf()

/*=======

pr()

#                   ...4...8...2..
o1 = new stzString("---*---*---*---")
? o1.split("*")
#--> [ "---", "---", "---", "---" ])

? @@( o1.FindMany([ "---", "---", "---", "---" ]) ) + NL
#--> [ 1, 5, 9, 13 ]

? @@( o1.FindSplits("*") ) + NL	# Same as FindSeparatedBy("*")
#--> [ 1, 5, 9, 13 ]

? @@( o1.FindSplitsZZ("*") )
#--> [ [ 1, 3 ], [ 5, 7 ], [ 9, 11 ], [ 13, 15 ] ]

pf()
# Executed in 0.07 second(s).

/*==== CONDITIONAL SPLITTING ON CHARS AND SUBSTRINGS

pr()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitAtCharsW( 'Q(This[@i]).IsLowercase()' ) )
	#--> [ "MMM", "AA", "NN" ]
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitAtCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMM", "AA", "NN" ]
	# Executed in 0.24 second(s)

pf()
# Executed in 0.34 second(s)

/*-----

pr()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitAfterCharsW( 'Q(This[@i]).IsLowerCase()' ) ) + NL
	#--> [ "MMMi", "AAi", "NN" ]
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitAfterCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMMi", "AAi", "NN" ]
	# Executed in 0.24 second(s)

pf()
# Executed in 0.33 second(s)

/*-----

pr()

o1 = new stzString( "MMMiAAiNN" )

# More performant

	? @@( o1.SplitBeforeCharsW( 'Q(This[@i]).IsLowerCase()' ) ) + NL
	#--> v
	# Executed in 0.16 second(s)

# More expressive

	? @@( o1.SplitBeforeCharsWXT( :Where = 'Q(@Char).IsLowercase()' ) )
	#--> [ "MMM", "iAA", "iNN" ]
	# Executed in 0.24 second(s)

pf()
# Executed in 0.33 second(s)

/*====

pr()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive : you can use the QSubString keyword

	//? @@( o1.PartsWXT('Q(@SubString).IsLowercase()'))
	#--> [ "iii", "mmm", "ee" ]
	# Takes 0.29 second(s)

# More performant : you use only This[@i]-like keywords

	? @@( o1.PartsW(' Q(This[@i]).IsLowercase() ') )
	# Takes 0.22 second(s)

pf()
# Executed in 0.49 second(s)

/*------

pr()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive (takes 0.82 seconds)

	? @@( o1.PartsWXT('Q(@SubString).IsLowercase()') ) + NL
	#--> [ "iii", "mmm", "ee" ]
	
	? @@( o1.FindPartsWXT('Q(@SubString).IsLowercase()')) + NL
	#--> [ 4, 10, 16 ]
	
	? @@( o1.FindPartsWXTZZ('Q(@SubString).IsLowercase()')) + NL
	#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 17 ] ]

# More performant (takes 0.65 seconds)

	? @@( o1.PartsW('Q(This[@i]).IsLowercase()') ) + NL
	#--> [ "iii", "mmm", "ee" ]
	
	? @@( o1.FindPartsW('Q(This[@i]).IsLowercase()')) + NL
	#--> [ 4, 10, 16 ]
	
	? @@( o1.FindPartsWZZ('Q(This[@i]).IsLowercase()'))
	#--> [ [ 4, 6 ], [ 10, 12 ], [ 16, 17 ] ]

pf()
# Executed in 1.35 second(s)

/*------

pr()

o1 = new stzString( "IIIiiiMMMmmmAAAee" )

# More expressive #NOTE the use of natural keyword ~> @SubString
# ~> requires transpiling of @SubString (and others like @NextSubString,
# @PreviousSubString, etc) in the background to This[@i] keyword

	? @@( o1.SplitAtSubStringsWXT( :where = 'Q(@SubString).IsLowercase()' ) ) + NL
	#--> [ "III", "MMM", "AAA" ]
	# Executed in 0.35 second(s)

# More performant (takes 0.36 second) #NOTE difference will be more relevant with large data
# You can use only This[@i] keyword to express the conditional expression

	? @@( o1.SplitAtSubStringsW( :where = 'Q(This[@i]).IsLowercase()' ) )
	#--> [ "III", "MMM", "AAA" ]
	# Executed in 0.31 second(s)

pf()
# Executed in 0.54 second(s)

/*------

pr()
                   
#                     ✁|   ✁|
o1 = new stzString( "ABCabcEFGijHI" )
#                    \_/\____/\__/

# More expressive

	? o1.SplitBeforeSubStringsWXT( 'Q(@SubString).IsLowercase()' )
	#--> [ "ABC", "abcEFG", "ijHI" ]
	# Executed in 0.35 second(s)

# More performant (in large strings and comlex split conditions)

	? o1.SplitBeforeSubStringsW( 'Q(This[@i]).IsLowercase()' )
	#--> [ "ABC", "abcEFG", "ijHI" ]
	# Executed in 0.26 second(s)

pf()
# Executed in 0.48 second(s)

/*-----

pr()
                   
#                        ✁|  ✁|
o1 = new stzString( "ABCabcEFGijHI" )
#                    \____/\___/\/

# More expressive

	? o1.SplitAfterSubStringsWXT( 'Q(@SubString).IsLowercase()' )
	#--> [ "ABCabc", "EFGij", "HI" ]
	# Executed in 0.39 second(s)

# More performant (in large strings and comlex split conditions)

	? o1.SplitAfterSubStringsW( 'Q(This[@i]).IsLowercase()' )
	#--> [ "ABCabc", "EFGij", "HI" ]
	# Executed in 0.26 second(s)

pf()
# Executed in 0.49 second(s)

/*======= #ring-sort #arabic

pr()

aList = [ "جمل", "أخ", "ذهب", "بيت", "أب" ]

? sort(aList)

? @sort(aList)

pf()
# Executed in 0.02 second(s)

/*---- #ring

pr()

? @@( reverse([ "M", "A", "D", "A", "M" ]) )
#--> [ "M", "A", "D", "A", "M" ]

? @@( reverse([ "ب", "ا", "ب" ]) )
#o--> [ "ب", "ا", "ب" ]

pf()
# Executed in 0.02 second(s)

/*---- #ring #fix

pr()

? reverse("MADAM") # Ring function
#--> MADAM

? reverse("باب")
#o!-->  اب 

# Softanza fixes it:
? ""

? @Reverse("MADAM") # Softanza function
#--> MADAM

? @Reverse("باب")
#o--> باب

pf()
# Executed in 0.02 second(s)

/*---- #ring fix

pr()

? isPalindrome("MADAM") # Ring function
#--> _TRUE_

? isPalindrome("باب")
#!--> _FALSE_
# Should be _TRUE_

# Softanza fixes it:

? @IsPalindrome("MADAM")
#--> _TRUE_

? @IsPalindrome("باب")
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*---- #ring fix

pr()

? isPalindrome("MADAM") # ring function working only for strings
#--> _TRUE_

? isPalindrome([ "M", "A", "D", "A", "M" ])
#!--> _FALSE_
#--> Slhould return _TRUE_

# Softanza fixes it:

? @IsPalindrome("MADAM")
#--> _TRUE_

? @IsPalindrome([ "M", "A", "D", "A", "M" ])
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*---

pr()


? Q("madam").IsPalindrome()
#--> _TRUE_

? Q([ "M", "A", "D", "A", "M" ]).IsPalindrome()

#--

? Q("باب").IsPalindrome()
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*----

pr()

o1 = new stzString("Ri**ng program*ming lan*guage")
o1.RemoveCharsAt([ 3, 4, 15, 24 ])
? o1.Content()
#--> Ring programming language

pf()
# Executed in 0.02 second(s)

/*---- #ring-fix

pr()


? ispunct("?")
#--> _TRUE_

? isPunct("!?,;a")

? isPunct("※")
#!--> _FALSE_
# Should be _TRUE_

? Name("※") # A punctuation char in Unicode
#--> REFERENCE MARK

#NOTE
# ※ is an East Asian Typography often used in
# Japanese and Chinese texts to indicate notes,
# similar to how an asterisk (*) or dagger (†)
# might be used in English texts.

# Softanza can check it:

? @IsPunct("※")
#--> _TRUE_

? @IsPunct(";:'※!?")
#--> _TRUE_

pf()
# Executed in 0.08 second(s)

/*=====

pr()

? WordsIdentificationMode()
#--> :Quick

? StopWordsStatus()
#--> :MustNotBeRemoved

? ""

o1 = new stzText("A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam.")

? @@( o1.FindPunctuations() )
#--> [ 28, 55, 73, 80, 89, 92, 99 ]

o1.RemovePunctuations()
? o1.Content()
#--> A man a plan a canal Panama Able was I ere I saw Elba Do geese see God Madam in Eden Im Adam

pf()
# Executed in 0.71 second(s)

/*-----


o1 = new stzString("A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam.")

? @@( o1.FindPunctuations() )
#--> [ 28, 55, 73, 80, 89, 92, 99 ]

o1.RemovePunctuations()
? o1.Content()
#--> A man a plan a canal Panama Able was I ere I saw Elba Do geese see God Madam in Eden Im Adam

pf()
# Executed in 0.19 second(s)

/*=====

pr()

o1 = new stzText("A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam.")

? o1.WordsQ().YieldWXT('@item', :Where = 'Q(@item).IsPalindrome()')
#--> [ "ere", "madam" ])

pf()
# Executed in 1.53 second(s)

/*------

pr()

o1 = new stzString("A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam.")

? o1.WordsQ().YieldWXT('@item', :Where = 'Q(@item).IsPalindromeCS(_FALSE_)')
#--> [ "ere", "madam" ])

pf()
# Executed in 0.54 second(s)

/*--- #narration #semantic-precision

pr()

# In Softanza ContainsLetters() is different from ContainsOnlyLetters()

o1 = new stzString("123 ABCDEF")
	? o1.ContainsLetters() # Coudd contains non letters
	#--> _TRUE_
	
	? o1.ContainsOnlyLetters() # same as IsAlphabetic()
	#--> _FALSE_

o2 = new stzString("ABCDEF")
	? o2.ContainsLetters()
	#--> _TRUE_
	
	? o2.ContainsOnlyLetters()
	#--> _TRUE_

#TODO add sample on ContainsNumbersAndLetters() vs ContainsNumbersOrLetters()

pf()
# Executed in 0.07 second(s)

/*-- # ring

pr()

? isAlpha("Ring")
#--> _TRUE_

? isAlnum("Ring120")
#--> _TRUE_

pf()

/*====== #ring #fix #stz-complements-ring

pr()

# these Ring standard functions are wrappers of C functions
# and can not manage Unicode non-ascii strings

? isAlpha("محمود")
#!--> _FALSE_
#~> Should be _TRUE_
	
? isAlnum("محمود2024")
#!--> _FALSE_
#~> Should be _TRUE_

# Softanza quivalent functions fix the issue:

? @IsAlpha("محمود") # or @IsAlphabetical()
#--> _TRUE_

? @IsAlnum("محمود2024") # or @IsAlphanum()
#--> _TRUE_

pf()
# Executed in 0.04 second(s)

/*=========

pr()

? Language("محمود")
#--> arabic

# When the text contains COMMON chars and ARABIC chars:

? Langauge("ˇˇˇمحمودˇˇˇ") #NOTE // Langauge() is misspelled but works ;)
#--> arabic

#~> Common chars do not influence the langauge detection in Softanza.

pf()
# Executed in 0.11 second(s)

/*-----

pr()

? Unicode("ˇ")
#--> 711

? CharName("ˇ")
#--> CARON

? Script("ˇ")
#--> common

? language("ˇ")
#--> undefined

? Q("ˇ").IsLetter()
#--> _TRUE_

? @IsAlpha("ˇringˇ")
#--> _TRUE_

pf()
# Executed in 0.10 second(s)
/*======

pr()

o1 = new stzString("The quick brown fox")

? @@(  o1.SubStringsWCSXTZZ('len(@SubString) = 5 and Q(@SubString).IsAlphabetic()', _TRUE_) )
#--> [ [ "quick", [ 5, 9 ] ], [ "brown", [ 11, 15 ] ] ]

pf()
# Executed in 2.12 second(s)

/*======

pr()

o1 = new stzList([
	"",
	"ABCDEF", "GHIJKL", "123346",
	"MNOPQU", "RSTUVW", "984332",
	""
])

? o1.FindW('  Q(This[@i]).IsMadeOfNumbers()  ')
#--> [ 4, 7 ]

pf()
# Executed in 0.12 second(s)

/*=======

pr()

o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

o1.RemoveLinesW(' Q(This[@i]).IsMadeOfNumbers() ')

? o1.Content()
#--> "
# ABCDEF
# GHIJKL
# MNOPQU
# RSTUVW"

pf()
# Executed in 0.12 second(s)

/*-------

pr()

o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

o1.RemoveLinesWXT(' Q(@Line).IsMadeOfNumbers() ')

? o1.Content()
#--> "
# ABCDEF
# GHIJKL
# MNOPQU
# RSTUVW"

pf()
# Executed in 0.16 second(s)

/*=====

pr()

o1 = new stzList([ "A", "b", 2, "C", 3, "♥" ])

? o1.ContainsW(' isNumber(This[@i]) ')
#--> _TRUE_
# Executed in 0.06 second(s)

? o1.ContainsWXT(' isNumber(@CurrentItem) ')
#--> _TRUE_
# Executed in 0.10 second(s)

pf()
# Executed in 0.12 second(s)

/*=====

pr()

o1 = new stzString("---3--")
? o1.ContainsNumbers()

pf()

/*--------

pr()

? Q("984332").IsMadeOfNumbers()
#--> _TRUE_

? Q("").IsMadeOfNumbers()

pf()

/*=====

pr()

#  FIND >>              5  8   13  16   21  26
#                       v--v    v--v    v----v
o1 = new stzString("----ring----ruby----python---")
#  ANTIFIND >>      ^--^    ^--^    ^--^
#                   1  4    9  12  17  30
            
? @@( o1.FindAsSections([ "ring", "ruby", "python" ]) ) + NL
#--> [ [ 4, 7 ], [ 11, 14 ], [ 18, 23 ] ]

? @@( o1.AntiFindAsSections([ "ring", "ruby", "python" ]) )
#--> [ [ 1, 4 ], [ 9, 12 ], [ 17, 20 ], [ 27, 29 ] ]

pf()
# Executed in 0.08 second(s)

/*=====

pr()

o1 = new stzString("---<<ring>>---<<ruby>>---<<python>>---")

? @@( o1.SplitAtMany([ "<<", ">>" ]) ) + NL # Or simply SplitAt([ "<<", ">>" ])
#--> [ "---", "ring", "---", "ruby", "---", "python", "---" ]


pf()
#--> Executed in 0.10 second(s)

/*==== #ring
pr()

aList = [ "python", [ "ring", "good", "thing" ],"ruby"]
? aList[ "ring" ]

pf()

/*------ #ring

pr()

# Pair starting with the keystring not found, a _NULL_ is returned
aList = [ "python", "ring", "ruby"]
? @@( aList[ "ring" ] )
#--> ""

# Keystring not found, a pair is added
aList[ "ring" ] = "good"
? @@(aList)
#--> [ "python", "ring", "ruby", [ "ring", "good" ] ]

# Keystring exists in a pair, second item of the pair is returned
? aList[ "ring" ] + NL
#--> "good"

# Adding the same pair again
aList + [ "ring", "fluen" ]
? @@(aList)
#--> [ "python", "ring", "ruby", [ "ring", "good", "mm" ], [ "ring", "fluen" ] ]

# If a keystring exists in many pairs, only the first pair is concerned
? aList[ "ring" ]
#--> "good"

# Adding a pair with a keystring in a different case
aList + [ "RING", "nice" ]
? @@(aList)
#--> [ "python", "ring", "ruby", [ "ring", "good" ], [ "RING", "nice" ] ]

? aList[ "RING" ] + NL
#--> "good"

pf()

/*=======

pr()

	@ForEach( :Item, :In = [ "a", "b", "c" ] ) { X('
		? v(:Item)
	') }
	#--> "a"
	#--> "b"
	#--> "c"

	? ""

	@ForEach( :Char, :In = "ABC" ) { X('
		? v(:Char)
	') }
	#--> "A"
	#--> "B"
	#--> "C"

	? ""

	@ForEach( [ :Char, :Number ], :In = [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ] ) { X('
		? v(:Char) + v(:Number)
	') }
	#--> "A1"
	#--> "B2"
	#--> "C3'

pf()
#--> Executed in 0.08 second(s)

/*========== #narration

pr()

# The function Size() has a generic meaning in Softanza.
# Hence, it can be used with all types of objects.

# Let's take the case of a stzNumber object.

? Q(12602).Size()
#--> 5

# Means that 12605 is made of 5 chars.

? Q(12.602).Size()
#--> 5

# Here we get 5 but normally we should count the "." char and get 6!

# In fact, the value of number 12.602 (as any number in Ring) is
# influenced by the current round active in Ring...

? CurrentRound()
#--> 2

# Son 12.602 is'n actually 12.602 but is rounded by default de 2 decimals

? 12.602
#--> 12.60

# Tou fet all the chars forming  the number 12.602, including the "." char,
# we should set the round to 3 using this function:

SetRound(3)

# And now, we get the 6 we wait for:

? Q(12.602).Size()
#--> 6

pf()
# Executed in 0.13 second(s)

/*==========

pr()

? Q([]).IsListOfLists()
#--> _FALSE_

? Q([ 1:3, 4:7, 8:10 ]).IsListOfLists()
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*========== PARTS ON STZLISTS

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.Parts() )
#--> [
#	[ "m", "m", "m" ],
#	[ "M", "M", "M" ],
#	[ "a", "a" ],
#	[ "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

? @@NL( o1.PartsCS(_FALSE_) )
#--> [
#	[ "m", "m", "m", "M", "M", "M" ],
#	[ "a", "a", "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

pf()
# Executed in 0.02 second(s)

/*---------------

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@( o1.FindParts() ) + NL
#--> [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsAsSections() ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsCS(_FALSE_) ) + NL
#--> [ 1, 7, 12 ]

? @@( o1.FindPartsAsSectionsCS(_FALSE_) )
#--> [ [ 1, 6 ], [ 7, 11 ], [ 12, 14 ] ]

pf()
# Executed in 0.03 second(s)

/*---------------

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.PartsZ() ) + NL
#--> [
#	[ [ "m", "m", "m" ], 1 ],
#	[ [ "M", "M", "M" ], 4 ],
#	[ [ "a", "a" ], 7 ],
#	[ [ "A", "A", "A" ], 9 ],
#	[ [ "i", "i", "i" ], 12 ]
# ]

? @@NL( o1.PartsCSZ(_FALSE_) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M" ], 1 ],
#	[ [ "a", "a", "A", "A", "A" ], 7 ],
#	[ [ "i", "i", "i" ], 12 ]
# ]

? @@NL( o1.PartsZZ() ) + NL
#--> [
#	[ [ "m", "m", "m" ], [ 1, 3 ] ],
#	[ [ "M", "M", "M" ], [ 4, 6 ] ],
#	[ [ "a", "a" ], [ 7, 8 ] ],
#	[ [ "A", "A", "A" ], [ 9, 11 ] ],
#	[ [ "i", "i", "i" ], [ 12, 14 ] ]
# ]

? @@NL( o1.PartsCSZZ(_FALSE_) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M" ], [ 1, 6 ] ],
#	[ [ "a", "a", "A", "A", "A" ], [ 7, 11 ] ],
#	[ [ "i", "i", "i" ], [ 12, 14 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*---------------

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.PartsUsing('Q(@item).CharCase()') ) + NL
#--> [
#	[ "m", "m", "m" ],
#	[ "M", "M", "M" ],
#	[ "a", "a" ],
#	[ "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

? @@NL( o1.PartsUsingXT('Q(@item).CharCase()') ) + NL
#--> [
#	[ [ "m", "m", "m" ], "lowercase" ],
#	[ [ "M", "M", "M" ], "uppercase" ],
#	[ [ "a", "a" ], "lowercase" ],
#	[ [ "A", "A", "A" ], "uppercase" ],
#	[ [ "i", "i", "i" ], "lowercase" ]
# ]

pf()
# Executed in 0.19 second(s)

/*---------------

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@( o1.FindPartsUsing('Q(@item).CharCase()') )
#--> [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsAsSectionsUsing('Q(@item).CharCase()') ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

pf()
# Executed in 0.20 second(s)

/*---------------

pr()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

# If you deactivate CaseSensitivity with CS = _FALSE_ and
# try to partition the list using CharCase(), then
# Softanza detects it and return the hole list as one part

? @@( o1.FindPartsUsingCS('Q(@item).CharCase()', _FALSE_) )
#--> [ 1 ]

? @@( o1.FindPartsAsSectionsUsingCS('Q(@item).CharCase()', _FALSE_) )
#--> [ [ 1, 14 ] ]

? @@( o1.PartsUsingCS('Q(@item).CharCase()', _FALSE_) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ] ]
# ]

? @@( o1.PartsUsingCSZZ('Q(@item).CharCase()', _FALSE_) ) + NL
#--> [
#	[
#	[ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ],
#	[ 1, 14 ]
#	]
# ]

pf()
# Executed in 0.02 second(s)

/*======== PARTS ON STZSTRING

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.FindParts() ) + NL
# [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsCS(_FALSE_) ) + NL
# [ 1, 7, 12 ]

? @@( o1.FindPartsAsSections() ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsAsSectionsCS(_FALSE_) )
#--> [ [ 1, 6 ], [ 7, 11 ], [ 12, 14 ] ]

pf()
# Executed in 0.02 second(s)

/*--------

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.Parts() )
#--> [ "mmm", "MMM", "aa", "AAA", "iii" ]

? @@( o1.PartsCS(_FALSE_) )
#--> [ "mmmmmm", "aaaaa", "iii" ]

pf()
# Executed in 0.02 second(s)

/*--------

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@NL( o1.PartsZ() ) + NL
#--> [
#	[ "mmm", 1 ],
#	[ "MMM", 4 ],
#	[ "aa", 7 ],
#	[ "AAA", 9 ],
#	[ "iii", 12 ]
# ]

? @@NL( o1.PartsCSZ(_FALSE_) ) + NL
#--> [
#	[ "mmmmmm", 1 ],
#	[ "aaaaa", 7 ],
#	[ "iii", 12 ]
# ]

? @@NL( o1.PartsZZ() ) + NL
#--> [
#	[ "mmm", [ 1, 3 ] ],
#	[ "MMM", [ 4, 6 ] ],
#	[ "aa", [ 7, 8 ] ],
#	[ "AAA", [ 9, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

? @@NL( o1.PartsCSZZ(_FALSE_) )
#--> [
#	[ "mmmmmm", [ 1, 6 ] ],
#	[ "aaaaa", [ 7, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

pf()
# Executed in 0.02 second(s)

/*===-----

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.FindPartsUsing('Q(@Char).CharCase()') ) + NL
# [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsUsingCS('Q(@Char).CharCase()', _FALSE_) ) + NL
# [ 1 ]

? @@( o1.FindPartsAsSectionsUsing('Q(@Char).CharCase()') ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsAsSectionsUsingCS('Q(@Char).CharCase()', _FALSE_) )
#--> [ [ 1, 14 ] ]

pf()
# Executed in 0.18 second(s)

/*--------

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.PartsUsing('Q(@Char).CharCase()') ) + NL
#--> [ "mmm", "MMM", "aa", "AAA", "iii" ]

? @@( o1.PartsUsingCS('Q(@Char).CharCase()', _FALSE_) ) + NL
#--> [ [ "mmmMMMaaAAAiii" ] ]

? @@NL( o1.PartsUsingXT('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", "lowercase" ],
#	[ "MMM", "uppercase" ],
#	[ "aa", "lowercase" ],
#	[ "AAA", "uppercase" ],
#	[ "iii", "lowercase" ]
# ]

? @@( o1.PartsUsingCSXT('Q(@Char).CharCase()', _FALSE_) )
#--> [ [ "mmmMMMaaAAAiii", "" ] ]

pf()
# Executed in 0.18 second(s)

/*--------

pr()

o1 = new stzString("mmmMMMaaAAAiii")

? @@NL( o1.PartsUsingZ('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", 1 ],
#	[ "MMM", 4 ],
#	[ "aa", 7 ],
#	[ "AAA", 9 ],
#	[ "iii", 12 ]
# ]

? @@( o1.PartsUsingCSZ('Q(@Char).CharCase()', _FALSE_) ) + NL
#--> [[ "mmmMMMaaAAAiii", 1 ] ]

? @@NL( o1.PartsUsingZZ('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", [ 1, 3 ] ],
#	[ "MMM", [ 4, 6 ] ],
#	[ "aa", [ 7, 8 ] ],
#	[ "AAA", [ 9, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

? @@NL( o1.PartsUsingCSZZ('Q(@Char).CharCase()', _FALSE_) )
#--> [ [ "mmmMMMaaAAAiii", [ 1, 14 ] ] ]

pf()
# Executed in 0.18 second(s)

/*=======

pr()

o1 = new stzString("Abc285XY&من")
		
? @@( o1.PartsUsing( 'Q(@char).IsLetter()' ) ) + NL
#--> [ "Abc", "285", "XY", "&", "من" ]

? @@NL( o1.PartsUsingXT( 'Q(@char).IsLetter()' ) ) + NL
#--> [
#	[ "Abc", _TRUE_ ],
#	[ "285", _FALSE_ ],
#	[ "XY", _TRUE_ ],
#	[ "&", _FALSE_ ],
#o	[ "من", _TRUE_ ]
# ]

? @@( o1.PartsUsing('Q(@char).Orientation()' ) ) + NL
#--> [ "Abc285XY&", "من" ]
		
? @@( o1.PartsUsing( 'Q(@char).IsUppercase()' ) ) + NL
#--> [ "A", "bc", "285", "XY", "&من" ]

? @@( o1.PartsUsingXT( 'Q(@char).IsUppercase()' ) ) + NL
#--> [
#	[ "A", _TRUE_ ],
#	[ "bc", _FALSE_ ],
#	[ "285", _NULL_ ],
#	[ "XY", _TRUE_],
#o	[ "&من", _NULL_ ]
# ]

? @@( o1.PartsUsing( 'Q(@char).CharCase()' ) ) + NL
#--> [ "A", "bc", "285", "XY", "&من" ]

? @@( o1.PartsUsingXT( 'Q(@char).CharCase()' ) )
#--> [
#	[ "A", "uppercase" ],
#	[ "bc", "lowercase" ],
#	[ "285", _NULL_ ],
#	[ "XY", "uppercase" ],
#o	[ "&من", _NULL_ ]
# ]

pf()
# Executed in 0.31 second(s)

/*----- #perf #todo #error

pr()

cLargeStr = ""
for i = 1 to 1_000
	cLargeStr += "mmMMMaaAA"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)

o1.PartsUsingXT('Q(@Char).CharCase()')
#--> [ "mm", "MMM", "aa", "...", "MMM", "aa", "AA" ]

#NOTE: to show a part of the output, use ShowShortXT( )
         
pf()
# Executed in 51.81 second(s)

/*========

pr()

? @@( Q("285").IsLowercase() )
#--> _NULL_

? Q("a285").IsLowercase()
#--> _TRUE_

? @@( Q("@&#!").IsUppercase() )
#--> _NULL_

? Q("@&#!ABC").IsUppercase()
#--> _TRUE_

? @@( Q("محمود").IsLowercase() )
#--> _NULL_

pf()
# Executed in 0.05 second(s)

/*-----

pr()

? Q("mmm").CharsCase() # Or StringCase() or Kase() (Case() is reserved!)
#--> lowercase

? Q("Amm").CharsCase()
#--> capitalcase

? Q("MMM").CharsCase()
#--> uppercase

? Q("mmmAAA").CharsCase()
#--> hybridcase

pf()
# Executed in 0.12 second(s)

/*=====

pr()

o1 = new stzString("ring")
? o1.NthChar(3)
#--> "n"

? @@( o1.NthChar(0) )
#--> _NULL_

? @@( o1.NthChar(77) )
#--> _NULL_

? @@( o1.Chars() )
#--> [ "r", "i", "n", "g" ]

pf()
# Executed in 0.01 second(s)

/*-----

pr()

o1 = new stzString("mmmMMMaaAAAiii")
? @@( o1.Chars() )
#--> [ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ]

? @@( o1.CharsCS(_FALSE_) )
#--> [ "m", "a", "i" ]

? @@( o1.CharsU() ) # Or UniqueChars() or CharsWithoutDupplication()
#--> [ "m", "M", "a", "A", "i" ]

pf()
# Executed in 0.02 second(s)

/*----- #perf

pr()

cLargeStr = ""
for i = 1 to 100_000
	cLargeStr += "mmmMMMaaAAAiii"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)
o1.Chars()
#NOTE: to show the output use ShowShort()

pf()
# Executed in 4.78 second(s) on Ring 1.21
# Executed in 8.50 second(s) on Ring 1.20

/*----- #perf

pr()

cLargeStr = ""
for i = 1 to 100_000
	cLargeStr += "mmmMMMaaAAAiii"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)
o1.CharsU() # Or UniqueChars()
#NOTE: to show the output use ShowShort()

pf()
# Executed in  8.44 second(s) on Ring 1.21
# Executed in 12.58 second(s) on Ring 1.20

/*=======================

pr()

o1 = new stzString("abc")
? o1.CharCase() # Same as StringCase()
#--? "lowercase"

pf()
# Executed in 0.03 second(s)

/*============

pr()

o1 = new stzList([ "Hello", "there!", ANullObject(), Q("9") ])

o1.StringifyObjects()
#--> [ "Hello", "there!", "@nullobject", "@noname" ]

? o1.Content()

pf()
# Executed in 0.02 second(s)

/*=========== CLASSIFYING A LIST

pr()

o1 = new stzList([
	:Arabic,
	:Arabic,
	:French,
	:English,

	[ 1, 2, 3 ],
 	Q("Hello!"),
	AFalseObject(),
	ATrueObject(),

	:Spanish,
	:Spanish,
	:English,
	:Arabic,

	Q(12),
	12,
	110,

	StzNamedObjectQ( :Italian = Q("Gracia!") ),
	"PERSIAN",

	ANullObject()
])

? @@NL( o1.Classify() )
#--> [
#	[ "arabic", 	[ 1, 2, 12 ] ],
#	[ "french", 	[ 3 ] ],
#	[ "english", 	[ 4, 11 ] ],
#	[ "spanish", 	[ 9, 10 ] ],
#	[ "italian", 	[ 16 ] ],
#	[ "persian", 	[ 17 ] ],
#	[ "@undefined", [ 5, 6, 7, 8, 13, 14, 15, 18 ] ]
# ]


pf()
# Executed in 0.03 second(s)

/*====== #ring

pr()

aList = [ "m", "mmm", "mm" ]
swap(aList, 2, 3)
? @@(aList)

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.MoveCol(3, 2)

? @@NL( o1.Content() )
#--> [
#	[ "A", 11, 1 ],
#	[ "B", 22, 2 ],
#	[ "C", 33, 3 ]
# ]
pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.MoveCol(3, 1)

? @@NL( o1.Content() )
#--> [
#	[ 11, "A", 1 ],
#	[ 22, "B", 2 ],
#	[ 33, "C", 3 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.ReplaceCol(2, [ "a", "b", "c" ])

? @@NL( o1.Content() )
#--> [
#	[ "A", "a", 11 ],
#	[ "B", "b", 22 ],
#	[ "C", "c", 33 ]
# ]

pf()
# Executed in 0.04 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.ReplaceCol(3, [ "a", "b", "c" ])

? @@NL( o1.Content() )
#--> [
#	[ "A", 1, "a" ],
#	[ "B", 2 ],
#	[ "C", 3, "c" ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzList([ ".", ".", "*", ".", ".", "." ])
o1.Move(3, 5)
? @@( o1.Content() )

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzList([ "one", "four", "two", "three", "five" ])

o1.MoveItem("four", :ToPosition = 4)

? @@( o1.Content() )
#--> [ "one", "two", "three", "four", "five" ]

pf()
# Executed in 0.02 second(s)

/*------

pr()

aList = [ "one", "four", "two", "three", "five" ]
Move(aList, 2, 4) # Move() is a Softanza function
? @@(aList)
#--> [ "one", "two", "three", "four", "five" ]

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.MoveCol(1, 3)

? @@NL( o1.Content() )
#--> [
#	[ 1, 11, "A" ],
#	[ 2, 22, "B" ],
#	[ 3, 33, "C" ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.MoveCol(3, 1)

? @@NL( o1.Content() )
#--> [
#	[ 11, "A", 1 ],
#	[ 22, "B", 2 ],
#	[ 33, "C", 3 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.MoveCol(3, 1)

? @@NL( o1.Content() )
#--> [
#	[ 11, "A", 1 ],
#	[ "B", 2 ],
#	[ 33, "C", 3 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.SwapCols(3, 1) # Or SwapNthItems()

? @@NL( o1.Content() )
#--> [
#	[ 11, 1, "A" ],
#	[ 22, 2, "B" ],
#	[ 33, 3, "C" ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.SwapCols(3, 1) # Or SwapNthItems()

? @@NL( o1.Content() )
#--> [
#	[ 11, 1, "A" ],
#	[ "B", 2 ],
#	[ 33, 3, "C" ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCol(3) # Or RemoveNthItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", 1 ],
#	[ "B", 2 ],
#	[ "C", 3 ]
# ]

pf()
# Executed in 0.04 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCol(2) # Or RemoveNthItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", 11 ],
#	[ "B" ],
#	[ "C", 33 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCols([ 2, 3 ])

? @@NL( o1.Content() )
#--> [
#	[ "A" ],
#	[ "B" ],
#	[ "C" ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.InsertCol(2, [ "a", "b", "c" ]) # Or InsertItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", "a", 1, 11 ],
#	[ "B", "b", 2 ],
#	[ "C", "c", 3, 33 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B" ],
	[ "C", 3, 33 ]
])

? o1.NthCol(2) # Or NthItems(2)
#--> [ 1, 3 ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B" ],
	[ "C", 3, 33 ]
])

o1.InsertCol(2, [ "a", "b", "c" ])

? @@NL( o1.Content() )
#--> [
#	[ "A", "a", 1, 11 ],
#	[ "B" ],
#	[ "C", "c", 3, 33 ]
# ]

pf()
# Executed in 0.03 second(s)

/*======

pr()

o1 = new stzListOfLists([
	[ :Arabic, "arb1", "A100" ],
	[ :Arabic, "arb2", "A200" ],
	[ :French, "frn1", "F100" ],
	[ :English, "eng1", "E100" ],

	[ [ 1, 2, 3 ], "lst1", "L100" ],
	[ ANullObject(), "nul1", "N100" ],
 
	[ :Spanish, "spn1", "S100" ],
	[ :Spanish, "spn2", "S200" ],
	[ :English, "eng2", "E200" ],
	[ :Arabic, "arb3", "A300" ],

	[ 12, "num1", "N100" ],
	[ 110, "num2", "N200" ],
	[ Q("hi!"), "non1", "X100" ],

	[ "PERSIAN", "per1", "P100" ]
])

? @@NL( o1.Classify() )
#--> [
#	[ "arabic", 	[ "arb1", "A100", "arb2", "A200", "arb3", "A300" ] ],
#	[ "french", 	[ "frn1", "F100" ] ],
#	[ "english", 	[ "eng1", "E100", "eng2", "E200" ] ],
#	[ "spanish", 	[ "spn1", "S100", "spn2", "S200" ] ],
#	[ "persian", 	[ "per1", "P100" ] ],
#	[ "@undefined", [ "lst1", "L100", "nul1", "N100", "num1", "N100", "num2", "N200", "non1", "X100" ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*--------

pr()

o1 = new stzListOfLists([
	[ "arb1", :Arabic, "A100" ],
	[ "arb2", :Arabic, "A200" ],
	[ "frn1", :French, "F100" ],
	[ "eng1", :English, "E100" ],

	[ "lst1", [ 1, 2, 3 ], "L100" ],
	[ "nul1", ANullObject(), "N100" ],
 
	[ "spn1", :Spanish, "S100" ],
	[ "spn2", :Spanish, "S200" ],
	[ "eng2", :English, "E200" ],
	[ "arb3", :Arabic, "A300" ],

	[ "num1", 12, "N100" ],
	[ "num2", 110, "N200" ],
	[ "non1", Q("hi!"), "X100" ],

	[ "per1", "PERSIAN", "P100" ]
])

? @@NL( o1.ClassifyOnCol(2) )
#--> [
#	[ "arabic", 	[ "arb1", "A100", "arb2", "A200", "arb3", "A300" ] ],
#	[ "french", 	[ "frn1", "F100" ] ],
#	[ "english", 	[ "eng1", "E100", "eng2", "E200" ] ],
#	[ "spanish", 	[ "spn1", "S100", "spn2", "S200" ] ],
#	[ "persian", 	[ "per1", "P100" ] ],
#	[ "@undefined", [ "lst1", "L100", "nul1", "N100", "num1", "N100", "num2", "N200", "non1", "X100" ] ]
# ]


pf()
# Executed in 0.03 second(s)

/*========

pr()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])
aClasses = o1.ClassifyBy(' Q(@item).HowMany(0) ')

? @@NL( aClasses )
#--> [
#	[ 2, [ 3007, 2100 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 0, [ 8, 2 ] ],
#	[ 3, [ 10001 ] ]
# ]

# If you want the first column to be sorted  you can do it like this

? @@NL( @SortLists( aClasses ) ) # or direcly @SortLists(aClasses)
#--> [
#	[ 0, [ 8, 2 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 2, [ 3007, 2100 ] ],
#	[ 3, [ 10001 ] ]
# ]

# It's also possible to pass throw stzListOfLists like this:

? @@NL( StzListOfListsQ(aClasses).SortedOn(1) ) # or directly .Sorted()
#--> [
#	[ 0, [ 8, 2 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 2, [ 3007, 2100 ] ],
#	[ 3, [ 10001 ] ]
# ]

pf()
# Executed in 0.05 second(s)

/*-----------

pr()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])
? @@NL( o1.ClassifyByQRT(' Q(@item).HowMany(0) ', :stzListOflists).SortedOn(1) )
#--> [
# 	[ "0", [ 8, 2 ] ],
#	[ "1", [ 170, 0, 150 ] ],
#	[ "2", [ 3007, 2100, 2100 ] ],
#	[ "3", [ 10001 ] ]
# ]

pf()
#--> Executed in 0.05 second(s)

/*---

pr()

? CountryAbbreviation(:libya)
#--> "LY"

? CountryName("TN")
#--> "tunisia"

? CountryPhoneCode("TN")
#--> "+216"

pf()
# Executed in 0.02 second(s)

/*==----

pr()

o1 = new stzListOfLists([
	[ "adel",  "TN", "tunis" ],
	[ "salah", "DZ", "alger" ],
	[ "saber", "LY", "tripoli" ],
	[ "amr",   "TN", "sfax" ],
	[ "mahdi", "LY", "benghazi" ],
	[ "ahmed", "EG", "cairo" ],
	[ "tamer", "EG", "nabatia" ]
])

? @@NL( o1.ClassifyOnBy(2, "CountryName(@item)") )
#--> [
#	[ "tunisia", [ "adel", "tunis", "amr", "sfax" ] ],
#	[ "algeria", [ "salah", "alger" ] ],
#	[ "libya", [ "saber", "tripoli", "mahdi", "benghazi" ] ],
#	[ "egypt", [ "ahmed", "cairo", "tamer", "nabatia" ] ]
# ]

pf()
# Executed in 0.07 second(s)

/*==----

pr()

o1 = new stzListOfLists([
	[ "+216", "tunis", "sfax", "gabes" ],
	[ "+227", "niamey", "maradi" ],
	[ "+218", "tripoli", "misrata", "benghazi" ],
	[ "+20", "cairo", "nabatia" ]
])

? @@NL( o1.ClassifyBy("CountryName(@item)") ) # or ClassifyOnBy(1, "CountryName(@item)")
#--> [
#	[ "tunisia", [ "tunis", "sfax", "gabes" ] ],
#	[ "niger", [ "niamey", "maradi" ] ],
#	[ "libya", [ "tripoli", "misrata", "benghazi" ] ],
#	[ "egypt", [ "cair", "nabatia" ] ]
# ]

pf()
# Executed in 0.09 second(s)

/*====== #ring

pr()

# Some Ring standard functions make the action in place and does not
# return anything. Others do the action and return the result.

#~>
# The ring_...() functions always do the action and return
# the result. So you are free to say:

	aList = [ 2, 3 ]
	ring_insert(aList, 1, 1)
	? aList
	#--> [ 1, 2, 3 ]

# Or directly:

	? ring_insert([ 2, 3 ], 1, 1)
	#--> [ 1, 2, 3 ]

pf()
# Executed in 0.01 second(s)

/*====== #ring

pr()

# ring_insert() corrects the behaviour of the standard insert()
# function, since the standard function, as is, meanse actually
# InsertAfter() and not insert (before, which what we expect)

? ring_insert(2:3, 1, 1)
#--> [ 1, 2, 3 ]

# In fact, if we use the standart function

alist = 2:3
insert(aList, 1, 1)
? aList
#--> [ 2, 1, 3 ]

pf()
# Executed in 0.01 second(s)

/*======

pr()

? @@SP( SortLists([
	[ "Dog", 	370 ],
	[ "Fox", 	120 ],
	[ "Charlie", 	1:3 ],
	[ "Baker",	493 ],
	[ "Easy", 	5:8 ]	 
]) )
#--> [
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ] ],
#	[ "Dog", 370 ],
#	[ "Easy", [ 5, 6, 7, 8 ] ],
#	[ "Fox", 120 ]
# ]

pf()
# Executed in 0.04 second(s)

#------

pr()

? @@SP( SortListsBySize([ 1:7, 1:3, 1:5 ]) )
#--> [
#	[ 2, 3, 4, 5, 6, 1, 7 ],
#	[ 2, 1, 3 ],
#	[ 2, 3, 4, 1, 5 ]
# ]

pf()
# Executed in 0.03 second(s)

#------

pr()

# This function is used internally by ListsSortOn()

? @@NL( ListStringifyXT([ 370, 120, 1:3, 493, 5:8, 45, _NULL_ ]) )
#--> [
#	'"370."',
#	'"120."',
#	"[ 1, 2, 3 ]",
#	'"493."',
#	"[ 5, 6, 7, 8 ]",
#	'"045."',
#	'""'
# ]

pf()
# Executed in 0.02 second(s)

/*-----

pr()
		o1 = new stzListOfLists([
			[ 1 ],
			[ "one", "two" ],
			[ ]
		])
		
		o1.AddCol([ 2, "three", 0 ])
		? @@NL( o1.Content() )
		#--> [
		#	[ 1, 2 ],
		#	[ "one", "two", "three" ],
		#	[ 0 ]
		# ]
pf()

/*----

pr()

o1 = new stzListOfLists([])
? @@( o1.Content() ) + NL

o1.AddCol(1:3)

? @@NL( o1.Content() )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 3 ]
# ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

aLists = [
	[ 370,	"Dog", 	"white", _TRUE_ ],
	[ 120,	"Fox", 	"blue",	FALSE ],
	[ 1:3,	"Charlie", "white" ],
	[ 493, "Baker" ],
	[ 5:8, "Easy" ],
	[ 45,	"Alpha", "green" ],
	[ _NULL_, "King" ],
	[ 0,	"Zero"  ],
	[ [ ], "EmptyL" ]
]

? @@SP( SortListsOn(aLists, 1) )
#--> [
#	[ "", "King" ],
#	[ 0, "Zero" ],
#	[ 45, "Alpha", "green" ],
#	[ 120, "Fox", "blue", 0 ],
#	[ 370, "Dog", "white", 1 ],
#	[ 493, "Baker" ],
#	[ [ ], "EmptyL" ],
#	[ [ 1, 2, 3 ], "Charlie", "white" ],
#	[ [ 5, 6, 7, 8 ], "Easy" ]
# ]

pf()
# Executed in 0.04 second(s)

/*------

pr()

aLists = [
	[ "Dog", 	370,	"white",	TRUE	],
	[ "Fox", 	120,	"blue",		FALSE	],
	[ "Charlie", 	1:3,	"white" 		],
	[ "Baker",	493 				],
	[ "Easy", 	5:8 				],
	[ "Alpha",	 45,	"green" 		],
	[ "King",	_NULL_				],
	[ "Zero",	0 ],
	[ "EmptyL",	[ ] ]
]

? @@SP( SortListsOn(aLists, 2) )
#--> [
#	[ "King", "" ], #Note that _NULL_ figures always on top of the sort
#	[ "Zero", 0 ],
#	[ "Alpha", 45, "green" ],
#	[ "Fox", 120, "blue", 0 ],
#	[ "Dog", 370, "white", 1 ],
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ], "white" ],
#	[ "Easy", [ 5, 6, 7, 8 ] ]
# ]

pf()
# Executed in 0.04 second(s)

/*----------

pr()

aList = [
	[ 4, 5, 6, 7 ],
	[ 7 ],
	[ 1, 2, 3 ]
]

? IsRingSortableOn(aList, 2)
#--> _FALSE_

# If you try you get an error

? @@NL( ring_sort2(aList, 2) )
#--> Bad parameter type! 

pf()

/*--------

pr()

# If the list of lists contains an empty list,
# then it can't be sorted by Ring

aList = [
	[ 4, 5, 6, 7 ],
	[ ],
	[ 1, 2, 3 ]
]

? IsRingSortable(aList)
#--> _FALSE_

? @@NL( @Sort(aList) )
#--> [
#	[ ],
#	[ 1, 2, 3 ],
#	[ 4, 5, 6, 7 ]
# ]

pf()
# Executed in 0.03 second(s)

/*--------

pr()

aList = [
	[ 4, 5, 6, 7 ],
	[ ],
	[ 1, 2, 3 ]
]

? IsRingSortableOn(aList, 1)
#--> _FALSE_

? @@NL( @SortOn(aList, 1 ) )
#--> [
#	[ ],
#	[ 1, 2, 3 ],
#	[ 4, 5, 6, 7 ]
# ]

pf()
# Executed in 0.03 second(s)

/*--------

pr()

aList = [
	[ 4, 5, 6, 7 ],
	[ ],
	[ 1, 2, 3 ]
]

? @@NL( @SortList(aList) )
#--> [
#	[ ],
#	[ 1, 2, 3 ],
#	[ 4, 5, 6, 7 ]
# ]

pf()
# Executed in 0.03 second(s)

/*----------

pr()

aList = [ "charlie", _NULL_, 17, 10, 4:7, [], "fox", 1:3, "aplha" ]

# The list can't be sorted by Ring because it contains an []

? IsRingSortable(aList)
#--> _FALSE_

# Softanza can sort it and places the [] before all other lists

? @@NL( SortList(aList) )
#--> [
#	"",
#	10,
#	17,
#	"aplha",
#	"charlie",
#	"fox",
#	[ ],
#	[ 1, 2, 3 ],
#	[ 4, 5, 6, 7 ]
# ]

pf()
# Executed in 0.03 second(s)

/*---------

pr()

? SortBy([ "a", "abcde", "abc", "ab", "abcd" ], 'len(@item)')
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

pf()
# Executed in 0.09 second(s)

/*===

pr()

? @IsHashList([ [ "uppercase", [ ] ] ])
#--> _TRUE_

pf()
# Executed in 0.01 second(s)

/*=====

pr()

aList = [ [1,2,3], [4,5,6], 7:9 ]

? "List content: " + NL + @@(aList) # Or ListToCode()
#--> List content: 
# [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

pf()
# Executed in 0.01 second(s)

/*=========

pr()

o1 = new stzString("the last mile")

o1.InsertAfterPosition(8, ">>")
o1.InsertBeforePosition(5, "<<")

? o1.Content()
#--> the <<last>> mile

pf()
# Executed in 0.02 second(s)

#=====

pr()

o1 = new stzString("the last mile")

o1.BoundSection(5, 8, [ "<<", ">>" ])
? o1.Content()
#--> the <<last>> mile

pf()
# Executed in 0.01 second(s)

#---

pr()

o1 = new stzString("the last mile now")
o1.BoundSections([ [5, 8], [15, 17] ], "_")
? o1.Content()
#--> the _last_ mile _now_

pf()
# Executed in 0.04 second(s)

/*--

pr()

? Q([ "str1", [ "str2", "str3" ], "str4" ]).IsListOfStringsOrPairsOfStrings()
#--> _TRUE_

? Q([ "str1", "str2", "str3", "str4" ]).IsListOfStringsOrPairsOfStrings()
#--> _TRUE_

? Q([ [ "str1", "str2" ], [ "str3", "str4" ] ]).IsListOfStringsOrPairsOfStrings()
#--> _TRUE_

? NL

? IsListOfStringsOrPairsOfStrings([ "str1", [ "str2", "str3" ], "str4" ])
#--> _TRUE_

? IsListOfStringsOrPairsOfStrings([ "str1", "str2", "str3", "str4" ])
#--> _TRUE_

? IsListOfStringsOrPairsOfStrings([ [ "str1", "str2" ], [ "str3", "str4" ] ])

pf()
# Executed in almost 0 second(s).

/*===========

pr()

o1 = new stzString("the last softanza mile now")

o1.BoundSectionsByMany(
	[ [5, 8], 	[19, 22]   ],
	[ ["<<", ">>"], ["(", ")"] ]
)

? o1.Content()
#--> the <<last>> softanza (mile) now

pf()
# Executed in 0.01 second(s).

#---

pr()

o1 = new stzString("its the last mile now")
o1.Bound("last", :By = [ "<<", :and = ">>" ]) # or BoundSubString() or InsertAroundSubString()
? o1.Content() + NL
#--> its the <<last>> mile now

o1.Bound([ "the", "mile" ], :By = [ "<<", ">>" ]) # or BoundSubStrings()
? o1.Content()
#--> its <<the>> <<last>> <<mile>> now

pf()
# Executed in 0.06 second(s)

/*-----------------

pr()

o1 = new stzString("IbelieveinRingfutureandengageforit!")

o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()
#--> I believe in Ring future and engage for it!

pf()
# Executed in 0.07 second(s)

/*========

pr()

o1 = new stzHashList([
	[ "#1", [ 12, 66 ] ],
	[ "#2", [ 26 ] ],
	[ "#3", [ 44, 66 ] ]
])

? @@( o1.FindKeysByValue(66) )
#--> [ 1, 3 ]

? @@( o1.KeysByValue(66) )
#--> [ "#1", "#3" ]

? o1.KeyByValue(66)
#--> #1

pf()
# Executed in 0.02 second(s)

/*========

pr()

o1 = new stzString("{{ring}}")
? o1.Bounds()

? @@( o1.FindTheseBoundsAsSections("{{","}") )
#--> [ [ 1, 2 ], [ 8, 8 ] ]

? @@( o1.FindTheseBounds("{{", "}") )
#--> [ 1, 8 ]

o1.RemoveTheseBounds("{{","}")
? o1.Content()
#--> ring}

pf()
# Executed in 0.04 second(s)

/*------------

pr()

o1 = new stzList([ "A", "B", "A", "A", "B", "B", "C" ])

? o1.NumberOfItemsU() # Or NumberOfUniqueItems()
#--> 3

? o1.ItemsU()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.02 second(s)

/*------------

pr()

o1 = new stzString("ABCAAB")

? o1.CharsQ().WithoutDuplicates()
#--> [ "A", "B", "C" ]

? o1.CharsU()
#--> [ "A", "B", "C" ]

? U( o1.Chars() )
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.02 second(s)

/*------- TODO: fix it

? StzCharQ("🔻")
#!--> ERROR MESSAGE: Can't create the char object

/*-------- TODO: erronous char name

pr()

? StzCharQ(63).Content()
#--> ?

? Q("🔻").Unicode()
#--> 53

? StzStringQ("🔻").CharName() #TODO // Correct this
#!--> QUESTION MARK

pf()
# Executed in 0.11 second(s)

/*================

pr()

o1 = new stzString("---,---;---[---]---:---")

? @@( o1.SplitAt([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", "---", "---", "---", "---", "---" ]

? @@( o1.SplitBefore([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", ",---", ";---", "[---", "]---", ":---" ]

? @@( o1.SplitAfter([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---,", "---;", "---[", "---]", "---:", "---" ]

pf()
# Executed in 0.08 second(s)

/*================

pr()

#     2    7
? Q("^^♥♥♥^^").ContainsSubStringBetween("♥♥♥", :Position = 2, :AndPosition = 7)
#--> _TRUE_

#     2   6
? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenPositions = [ 2, :And = 6])
#--> _TRUE_

pf()
# Executed in 0.03 second(s)

/*--------------

pr()

? Q("^^♥♥♥^^").ContainsInSection("♥♥♥", 3, 5)
#--> _TRUE_

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :InSection = [3, 5])
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", "^^", "^^")
#--> _TRUE_

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :SubString = "^^", :AndSubString = "^^")
#--> _TRUE_

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.49 second(s) in Ring 1.17

/*--------------

pr()

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :Between = [ "^^", "^^" ] )

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenSubStrings = [ "^^", :And = "^^" ] )
#--> _TRUE_

pf()
#--> Executed in 0.02 second(s) in Ring 1.20
#--> Executed in 0.48 second(s) in Ring 1.17

/*==================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")
? o1.FindNthAsSection(2, "♥♥♥")
#--> [9, 11]

StopProfiler()
# Executed in 0.01 second(s) on Ring 1.20
# Executed in 0.02 second(s) on Ring 1.20

/*================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")

? o1.Sit(
	:InSection = o1.FindNthAsSection(2, "♥♥♥"),

	:AndYield = [
		:NCharsBefore = 3,
		:NCharsAfter  = 3
	]
)
#--> [ "__/", "\__" ]

StopProfiler()
# Executed in 0.03

/*========= CHECKING BOUNDS - XT

StartProfiler()
		
	o1 = new stzString("♥")
	? o1.IsBoundedByXT("-", :In = "...-♥-...") # You can use :Inside instead of :In
	#--> _TRUE_
	
	? o1.IsBoundedByXT(["/", "\"], :InSide = "__/♥\__")
	#--> _TRUE_
		
	? o1.IsBetweenXT(["/", "\"], :InSide = "__/♥\__")
	#--> _TRUE_
	
	? o1.IsBetweenXT(["/", :And = "\"], :InSide = "__/♥\__")
	#--> _TRUE_
	
StopProfiler()
# Executed in 0.12 second(s)

/*====  FINDING SUBSTRING, BASIC & EXTENDED

StartProfiler()

	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])
	
	? @@( o1.FindSubString("name") )
	#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

	? @@( o1.FindSubstringXT("name") )
	#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

StopProfiler()
# Executed in 0.04 second(s)

/*========== CHECKING CONTAINMENT

StartProfiler()
	
	? Q("\__♥__/").Contains("♥")
	#--> _TRUE_
	
	? Q("\__♥__/").ContainsMany("_") # Or .ContainsMoreThenOne("_")
	#--> _TRUE_
	
	? Q("\__♥__/").ContainsThese(["_","♥"])
	#--> _TRUE_
	
	? Q("\__♥__/").IsMadeOf(["\", "_", "♥", "/" ])
	#--> _TRUE_
	
StopProfiler()
# Executed in 0.02 second(s)

/*======== CHECKING CONTAINMENT - EXTENDED

StartProfiler()

	? Q("__♥__").ContainsXT("♥", "_")
	#--> _TRUE_

	? Q("__♥__♥__").ContainsXT(2, "♥")
	#--> _TRUE_

	? Q("__♥__").ContainsXT("♥", [])
	#--> _TRUE_

	? Q("__-♥-__").ContainsXT(["_", "-", "♥"], [])
	#--> _TRUE_

	? Q("__♥__").ContainsXT([], "♥")
	#--> _TRUE_

StopProfiler()
# Executed in 0.02 second(s)

/*----------

pr()

	? Q("_-♥-_").ContainsXT("♥", :BoundedBy = "-")
	#--> _TRUE_

	? Q("_/♥\_").ContainsXT("♥", :BoundedBy = ["/", :And = "\"])
	#--> _TRUE_

	? Q("__-♥-__-•-__").ContainsXT(["♥", "•"], :BoundedBy = "-")
	#--> _TRUE_
	
	? Q("__/♥\__/•\__").ContainsXT(["♥", "•"], :BoundedBy = ["/", :And = "\"])
	#--> _TRUE_

	? Q("__/♥\__/^^^\__").ContainsXT( [], :BoundedBy = ["/", :And = "\"] )
	#--> _TRUE_

	? Q("__/♥\__/^^\__").ContainsXT( [], :BoundedBy = ["/", "\"] )	
	#--> _TRUE_

pf()
# Executed in 0.05 second(s)

/*----------

StartProfiler()

	? Q("").ContainsXT(:Chars, []) # You can use _NULL_ or _FALSE_ instead of []
	#--> _FALSE_
	? Q("").ContainsXT([], :Chars) # You can use _NULL_ or _FALSE_ instead of []
	#--> _FALSE_

	? Q("__-♥-__").ContainsXT(:Chars, ["_", "-"])
	#--> _TRUE_
	? Q("__-♥-__").ContainsXT(:TheseChars, ["♥", "-"])
	#--> _TRUE_

	? Q("__-♥-__").ContainsXT(:SomeOfTheseChars, ["_", "-", "_"])
	#--> _TRUE_

	? Q("__-♥-__").ContainsXT(:OneOfTheseChars, ["A", "♥", "B"])
	#--> _TRUE_
	? Q("__-♥-__").ContainsXT(:NoneOfTheseChars, ["A", "*", "B"])
	#--> _TRUE_

	? Q("__---_^_").ContainsXT(:CharsWhere, 'Q(@Char).IsEither("A", :Or = "^")' )
	#--> _TRUE_
	? Q("__---__").ContainsXT(:CharsW, 'Q(@Char).IsEither("_", :Or = "-")')
	#--> _TRUE_
	? Q("__---__").ContainsXT(:Chars, :Where = 'Q(@Char).IsEither("_", :Or = "-")')
	#--> _TRUE_
	? Q("__---__").ContainsXT(:Chars, Where(' Q(@Char).IsEither("_", :Or = "-") ') )
	#--> _TRUE_
	? Q("__---__").ContainsXT(:Chars, W('Q(@Char).IsEither("_", :Or = "-")'))
	#--> _TRUE_

StopProfiler()
# Executed in 0.46 second(s)

/*------

StartProfiler()
	
pr()

	? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, ["softanza", "ring"])
	#--> _TRUE_
	? Q("_softanza_loves_ring_").ContainsXT(:TheseSubStrings, ["softanza", "ring"])
	#--> _TRUE_

	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfTheseSubStrings, ["ring", "php", "softanza"])
	#--> _TRUE_
	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfThese, ["ring", "php", "softanza"])
	#--> _TRUE_

	? Q("_softanza_loves_ring_").ContainsXT(:OneOfTheseSubStrings, ["python", "php", "ring"])
	#--> _TRUE_
	? Q("_softanza_loves_ring_").ContainsXT(:OneOfThese, ["python", "php", "ring"])
	#--> _TRUE_

	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfTheseSubStrings, ["python", "php", "ruby"])
	#--> _TRUE_
	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfThese, ["python", "php", "ruby"])
	#--> _TRUE_
pf()
# Executed in 0.04 second(s)

/*------------ #perf

#TODO // Check performance! Rethink the subStrings() design
#UPDATE: done! After redesigning SubStrings() function,
# performance of the following sample went down
# from 144.36 seconds to 12.75 seconds!

StartProfiler()

	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsWhere, 'Q(@SubString).IsUppercase()')
	#--> _TRUE_
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, 'Q(@SubString).IsUppercase()')
	#--> _TRUE_
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, :Where = 'Q(@SubString).IsUppercase()')
	#--> _TRUE_
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, Where('Q(@SubString).IsUppercase()') )
	#--> _TRUE_
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, W('Q(@SubString).IsUppercase()') )
	#--> _TRUE_

StopProfiler()
# Executed in 12.75 second(s)

/*======== USING ADDXT() - EXTENDED

StartProfiler()
	
	Q("Ring programmin language.") {
	
		AddXT("g", :After = "programmin") # You can use :To instead of :After
		? Content()
		#--> Ring programming language.
	
	}

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()
	
	Q("__(♥__(♥__(♥__") {
	
		AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.05 second(s) in Ring 1.19

/*-----------

StartProfiler()
	
	Q("__♥__(♥__♥__") {
	
		AddXT( ")", :AfterNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.10 second(s) in Ring 1.19

/*-----------------

StartProfiler()
	
	Q("__(♥__♥__♥__") {
	
		AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
		? Content()
		#-->__(♥)__♥__♥__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19
	
/*-----------------

StartProfiler()
	
	Q("__♥__♥__(♥__") {
	
		AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
		? Content()
		#--> __♥__♥__(♥)__
	}
	
StopProfiler()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.19

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
# Executed in 0.04 second(s)

/*---------

StartProfiler()
	
	Q("__♥__♥)__♥__") {
	
		AddXT( "(", :BeforeNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

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
# Executed in 0.04 second(s)

/*-----------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/", "\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	
StopProfiler()
# # Executed in 0.25 second(s)

/*-----------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/","\" ], :AroundNth = [2, "♥"])
		? Content()
		#--> __♥__/♥\__♥__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

/*-----------------

StartProfiler()
	
	Q("__♥__/♥\__/♥\__") {
	
		AddXT( [ "/","\" ], :AroundFirst = "♥" )
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

/*-----------------

StartProfiler()
	
	Q("__/♥\__/♥\__♥__") {
	
		AddXT( [ "/","\" ], :AroundLast = "♥" )
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

#=======

pr()

o1 = new stzList(1:8)
? @@( o1.SplitToListsOfNItems(2) )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ] ]

pf()
# Executed in 0.03 second(s)

/*--------

pr()

o1 = new stzList([ [ 1, 3 ], [ 8, 10 ], [ 12, 13 ], [ 18, 19 ], [ 21, 21 ], [ 26, 26 ] ])
? @@SP( o1.SplitToListsOfNItems(2) )
#--> [ 
#	[ [ 1, 3 ], [ 8, 10 ] ],
#	[ [ 12, 13 ], [ 18, 19 ] ],
#	[ [ 21, 21 ], [ 26, 26 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*========

pr()

o1 = new stzString("<<<word>>>")

? @@( o1.StringBounds() ) # Or simply Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.StringBoundsZZ() ) # Or simply BoundsZZ()
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

? @@( o1.FindStringBoundsAsSections() )  + NL # Or Simply FindBoundsAsSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBoundsAsSections("***", "***") )
#--> [ [ ], [ ] ]

? @@( o1.FindTheseBoundsAsSections("<<<", "***") )
#--> [ [ 1, 3 ], [ ] ]

? @@( o1.FindTheseBoundsAsSections("***", ">>>") )
#--> [ [ ], [ 8, 10 ] ]

? @@( o1.FindTheseBoundsAsSections("<<<", ">>>") ) + NL
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBounds("***", "***") )
#--> [ ]

? @@( o1.FindTheseBounds("<<<", "***") )
#--> [ 1, 0 ]

? @@( o1.FindTheseBounds("***", ">>>") )
#--> [ 0, 8 ]

? @@( o1.FindTheseBounds("<<<", ">>>") ) + NL
#--> [ 1, 8 ]

#--

? @@( o1.TheseBoundsZ("***", "***") )
#--> [ [ '', 0 ], [ "", 0 ] ]

? @@( o1.TheseBoundsZ("<<<", "***") )
#--> [ [ "<<<", 1 ], [ "", 0 ] ]

? @@( o1.TheseBoundsZ("***", ">>>") )
#--> [ [ "", 0 ], [ '>>>', 8 ] ]

? @@( o1.TheseBoundsZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

#--

? @@( o1.TheseBoundsZZ("***", "***") )
#--> [ [ "", [ ] ], [ "", [ ] ] ]

? @@( o1.TheseBoundsZZ("<<<", "***") )
#--> [ [ "<<<", [ 1, 3 ] ], [ "", [ ] ] ]

? @@( o1.TheseBoundsZZ("***", ">>>") )
#--> [ [ "", [ ] ], [ '>>>', [ 8, 10 ] ] ]

? @@( o1.TheseBoundsZZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

pf()
# Executed in 0.05 second(s)

/*============

pr()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([ [8,10], [1,3] ])
? o1.Content()
#--> word

pf()
# Executed in 0.03 second(s)

/*---------

pr()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([])
? o1.Content()
#--> <<<word>>>

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzString("word>>>")
? o1.FindLeadingChars()
#--> 0

? @@( o1.FindLeadingCharsAsSection() )
#--> [ ]

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([ [ ], [ 5, 7 ] ])
? o1.IsListOfPairsOfNumbers()
#--> _FALSE_

pf()
# Executed in 0.01 second(s)

/*--------- TODO/FUTURE: add _ for more readable numbers

pr()

? @@(1587345327)
#--> '1_587_345_327'

? @@([ 1, 2, 999997, 999998, 1000000 ])
#--> [ 1, 2, 999_997, 999_998, 1_000_000 ]

pf()
# Executed in 0.02 second(s)

/*--------- #perf

pr()	

o1 = new stzList( 1 : 1_000_000 )
o1.RemoveSection(5, 999_996)
? ShowShortXT( o1.Content(), 7 )
#--> [ 1, 2, 3, 4, 999_997, 999_998, 999_999, 1_000_000 ]

pf()
# Executed in 0.30 second(s)

/*--------- #perf

pr()	

o1 = new stzList( 1 : 1_000_000 )
o1.RemoveSection(1, 1_000_000)
? @@( o1.Content() )
#--> [ ]

pf()
# Executed in 0.30 second(s)

/*---------

pr()

o1 = new stzList([ "w", "o", "r", "d", ">", ">", ">" ])
o1.RemoveSection(1, 4)
? @@( o1.Content() )
#--> [ ">", ">", ">" ]

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([ "<", "<", "w", "o", "r", "d", ">", ">", ">" ])

o1.RemoveSections([ [ 1, 2 ], [ 7, 9 ] ])
? @@( o1.Content() )
#--> [ "w", "o", "r", "d" ]

pf()
# Executed in 0.07 second(s)

/*---------

pr()

o1 = new stzString("word>>>")
o1.RemoveSections([ [ ], [ 5, 7 ] ])
? o1.Content()
#--> word

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzString("word>>>")
o1.RemoveSection(5, 7)
? o1.Content()
#--> word

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzString("<<<word")
o1.RemoveSections([ [ 1, 3 ], [ ] ])
? o1.Content()
#--> word

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzString("<<<word")
o1.RemoveSection(1, 3)
? o1.Content()
#--> word

pf()
# Executed in 0.05 second(s)

/*===== #narration

pr()

# Each string is bounded by default by its first and last chars

o1 = new stzString("word>>>")
? @@( o1.Bounds() )
#--> [ "w", ">" ]

? o1.ContainsBounds() # Or ? o1.IsBounded()
#--> _TRUE_

# When the string contains some leading and trailing repeated chars,
# then they are considered to be the bounds of that string

o1 = new stzString("<<<word>>>")
? @@( o1.Bounds() )
#--> [ "<<<", ">>>" ]

# And when there's no leading and trailing chars (both), so
# the first and last chars are considered bounds ~> removed

o1 = new stzString("word>>>")
o1.RemoveBounds() # T
? o1.Content()
#--> ord>>

pf()
# Executed in 0.08 second(s)

/*--------

pr()

o1 = new stzString("<<<word>>>")

o1.RemoveTheseBounds("***", "***") # Nothing happens
? o1.Content()
#--> <<<word>>>

o1.RemoveTheseBounds("<<<", "***") # Nothing happens
? o1.Content()
#--> <<<word>>>

o1.RemoveBounds()
? o1.Content()
#--> word

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--------
*
pr()

o1 = new stzString("ring")
? o1.Bounds()
#--> [ "r", "g" ]

#--

o1 = new stzString("rringgg")
? o1.Bounds()
#--> [ "rr", "ggg" ]

o1.RemoveBounds()
? o1.Content() + NL
#--> "in"

#--

o1 = new stzString("rrRingGG")
? o1.Bounds()
#--> [ "rr", "GG" ]

o1.RemoveBounds()
? o1.Content()
#--> "Ring"

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*--------

pr()

o1 = new stzString("<<<word>>>")
o1.RemoveFirstBound()
? o1.Content()
#--> word>>>

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*--------

pr()

o1 = new stzString("<<<word>>>")
o1.RemoveLastBound() # Or o1.RemoveSecondBound()
? o1.Content()
#--> <<<word

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*--------

pr()

o1 = new stzString("<<<word>>> <<word>> <word>")

? @@( o1.FirstBounds(:Of = "word") )
#--> [ "<<<", "<<", "<" ]

? @@( o1.SecondBounds(:Of = "word") )
#--> [ ">>>", ">>", ">" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21s

/*------

pr()

o1 = new stzString("[word] <word> (word)")

? @@( o1.BoundsOf("word") )
#--> [ "[", "]", "<", ">", "(", ")" ]

o1.RemoveBoundsOf("word")
? o1.Content()
#--> word word word

pf()
# Executed in 0.05 second(s) in Ring 1.21

/*------

pr()

o1 = new stzString("<<<word>>> <<word>> <word>")
o1.RemoveBoundsOf("word")
? o1.Content()
#--> word word word

pf()
# Executed in 0.06 second(s) in Ring 1.21

/*---------

pr()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveFirstBounds(:Of = "word") # Or o1.RemoveLeftBounds(:Of = "word")

? o1.Content()
#--> word>>> word>> word>

pf()
# Executed in 0.05 second(s)

/*---------

pr()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveLastBounds(:Of = "word") # Or o1.RemoveRightBounds(:Of = "word")
? o1.Content()
#--> <<<word <<word <word

pf()
# Executed in 0.05 second(s) in Ring 1.21

/*========= SWAPPING TWO SECTIONS

pr()

o1 = new stzString(">>>word<<<")
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? o1.Content()
#--> <<<word>>>

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ ">", ">", ">", "w", "o", "r", "d", "<", "<", "<" ])
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? @@( o1.Content() )
#--> [ "<", "<", "<", "w", "o", "r", "d", ">", ">", ">" ]

pf()
# Executed in 0.04 second(s)

/*---------

pr()
#                   12345678901234567
o1 = new stzString("...>>>word<<<....")

? o1.Section(4, 6)
#--> >>>

? o1.Section(11, 13)
#--> <<<

o1.SwapSections([4, 6], [11, 13])
? o1.Content()
#--> ...<<<word>>>....

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzString(">>>word<<< >>word<< >word<")
o1.SwapBoundsOf("word")
? o1.Content()
#--> <<<word>>> <<word>> <word>

pf()
# Executed in 0.05 second(s)

/*=========

pr()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")

? o1.NumberOfOccurrenceOfSubStringBoundedBy("word", [ "<<", ">>" ])
#--> 3
	
? @@( o1.FindSubStringBoundedByAsSections("word", [ "<<", ">>" ]) )
#--> [ [11, 14], [28, 31], [41, 44] ]
	
? @@( o1.FindNthBoundedByAsSection(2, "word", [ "<<", ">>" ]) )
#--> [28, 31]
	
? @@( o1.FindFirstBoundedByAsSection("word", [ "<<", ">>" ]) )
#--> [11, 14]
	
? @@( o1.FindLastBoundedByAsSection("word", [ "<<", ">>" ]) )
#--> [41, 44]

pf()
# Executed in 0.06 second(s)

/*---------

pr()

o1 = new stzString("123 ABC 901 DEF")
o1.ReplaceSections([ [1, 3], [9, 11] ], "***")
? o1.Content()
#--> *** ABC *** DEF

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzString("12345 ABC 1234 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 14] ],

	:With = '***'
)

? o1.Content()
#--> *** ABC *** DEF

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.FirstItems()
#--> [ 4, 3, 8 ]

? o1.SecondItems()
#--> [ 7, 1, 9 ]

pf()
# Executed in 0.03 second(s)

/*=============

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [9, 8] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [ 3, 1 ], [ 4, 7 ], [ 9, 8 ] ]

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@( o1.Content() )
#--> [ [ 8, 9 ], [ 4, 7 ], [ 3, 1 ] ]

pf()
# Executed in 0.05 second(s)

/*---------------- #perf

pr()

# Let's construct a list of pairs of 20_000 items
# Softanza takes 30 seconds to sort it

aList = [ [4, 7], [3, 1], [8, 9], [6, 7 ] ]
aLarge = []
for i = 1 to 5_000
	for j = 1 to 4
		aLarge + aList[j]
	next
next


@SortList(aLarge)

pf()
# Executed in 30.36 second(s)

/*---------------- #perf

pr()

# Softanza check if a list of lists made of 20_000 items
# is sorted or not in 29 second(s)

aList = [ [4, 7], [3, 1], [8, 9], [6, 7 ] ]
aLarge = []
for i = 1 to 5_000
	for j = 1 to 4
		aLarge + aList[j]
	next
next

o1 = new stzList(aLarge)
? o1.IsSortedUp()

pf()
# Executed in 26.46 second(s)

/*-----------------

pr()

o1 = new stzListOfPairs([ [1,3], [4, 7], [8, 9] ])
? o1.IsSortedInAscending()
#--> _TRUE_

pf()
# Executed in 0.03 second(s)

/*-----------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.IsSortedInAscending()
#--> _FALSE_

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.IsSortedInDescending()
#--> _FALSE_

o1 = new stzListOfPairs([ [9,8], [7,4], [3,1] ])
? o1.IsSortedInDescending()
#--> _TRUE_

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.FindPair([3, 1])
#--> 2

pf()
# Executed in 0.03 second(s)

/*======================

pr()

o1 = new stzList("A":"J")

? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ [ "C", "D", "E" ], [ "G", "H" ] ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "F" ], [ "I", "J" ] ]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "C", "D", "E" ], [ "F" ], [ "G", "H" ], [ "I", "J" ] ]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ "CDE", "GH" ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "F", "IJ"]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "CDE", "F", "GH", "IJ"]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

pf()
# Executed in 0.04 second(s)

/*=================

pr()

? @@( SectionToRange(3, 4) )
#--> [3, 2]

? @@( RangeToSection(3, 2) )
#--> [3, 4]

? @@( SectionsToRanges([ [3, 4], [8, 10] ]) )
#--> [ [3, 2], [8, 3] ]

? @@( RangesToSections([ [3, 2], [8, 3] ]) )
#--> [ [3, 4], [8, 10] ]

pf()
# Executed in 0.02 second(s)

/*=================

pr()

o1 = new stzList([ [ "ONE", "TWO" ], [ "THREE", "FOUR" ], [ "FIVE", "SIX" ] ])
? o1.IsListOfLists()
#--> _TRUE_

? o1.IsListOfPairs()
#--> _TRUE_

? o1.IsListOfPairsOfStrings()
#--> _TRUE_

pf()
# Executed in almost 0 second(s) on Ring 1.21
# Executed in 0.02 second(s) on Ring 1.20

/*----------------

pr()

o1 = new stzList([ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ])
? o1.IsListOfLists()
#--> _TRUE_

? o1.IsListOfPairs()
#--> _TRUE_

? o1.IsListOfPairsOfNumbers()
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*=================

pr()

o1 = new stzString("AB♥CD♥EF♥GH")

? @@( o1.SplitAt("♥") )
#--> [ "AA", "CD", "EF", "GH" ]

? @@( o1.SplitAfter("♥") )
#--> [ "AB♥", "CD♥", "EF♥", "GH" ]

? @@( o1.SplitBefore("♥") )
#--> [ "AB", "♥CD", "♥EF", "♥GH" ]

pf()
# Executed in 0.05 second(s)

/*----------------

pr()

o1 = new stzString("AB♥♥C♥♥D♥♥E")

? o1.SplitToPartsOfNChars(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥", "E" ]

? o1.SplitToPartsOfExactlyNChars(2) # OR SplitToPartsOfNCHarsXT(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

pf()
# Executed in 0.03 second(s)

/*=================

pr()

o1 = new stzString("ABCDE")
? @@( o1.SubStrings() )
#--> [
#	"A", "AB", "ABC", "ABCD", "ABCDE", "B",
#	"BC", "BCD", "BCDE", "C", "CD", "CDE",
#	"D", "DE", "E"
# ]

pf()
# Executed in 0.01 second(s)

/*================ REPEATED LEADING AND TRAILING CHARS

pr()

o1 = new stzString("<<<word>>>")

? o1.ContainsLeadingChars()
#--> _TRUE_

? o1.NumberOfLeadingChars()
#--> 3

? o1.LeadingChars()
#--> [ "<", "<", "<" ]

? o1.LeadingCharsAsString()
#--> "<<<"

#--

? o1.ContainsTrailingChars()
#--> _TRUE_

? o1.NumberOfTrailingChars()
#--> 3

? o1.TrailingChars()
#--> [ ">", ">", ">" ]

? o1.TrailingCharsAsString()
#--> ">>>"

pf()
# Executed in 0.03 second(s)

/*================ WORKING WITH BOUNDS OF THE STRING

pr()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.FindBounds() )
#--> [ 1, 8 ]

? @@( o1.FindBoundsAsSections() )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

pf()
# Executed in 0.03 second(s)

/*------------------

pr()

o1 = new stzString("<<<word>>>")

? o1.LeftBound()
#--> <<<

? o1.FindLeftBound()
#--> 1

? @@( o1.FindLeftBoundAsSection() )
#--> [ 1, 3 ]

? @@( o1.LeftBoundZ() )
#--> [ "<<<", 1 ]

? @@( o1.LeftBoundZZ() ) + NL
#--> [ "<<<", [ 1, 3 ] ]

#--

? o1.RightBound()
#--> >>>

? o1.FindRightBound()
#--> 8

? @@( o1.FindRightBoundAsSection() )
#--> [ 8, 10 ]

? @@( o1.RightBoundZ() )
#--> [ ">>>", 8 ]

? @@( o1.RightBoundZZ() ) + NL
#--> [ ">>>", [ 8, 10 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.18

/*------------------

pr()

o1 = new stzString("<<<word>>>")

? @@( o1.FindBounds() ) # Same as o1.FindFirstAndLastBounds()
			# You can also use Riht and Left instead of First and Last
#--> [ 1, 8 ]

	? @@( o1.FindLastAndFirstBounds() )
	#--> [ 8, 1 ]

? @@( o1.FindBoundsAsSections() ) # Same as o1.FindFirstAndLastBoundsSasSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

	? @@( o1.FindLastAndFirstBoundsAsSections() )
	#--> [ [ 8, 10 ], [ 1, 3 ] ]

pf()
# Executed in 0.04 second(s)

/*------------------

pr()

o1 = new stzString("<<<word>>>")

? @@( o1.Bounds() )
#--> [ "<<<", ">>>" ]

	? @@( o1.FirstAndLastBounds() )
	#--> [ "<<<", ">>>" ]

	? @@( o1.LastAndFirstBounds() ) + NL
	#--> [ ">>>", "<<<" ]

#--

? @@( o1.BoundsZ() )
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.FirstAndLastBoundsZ() )
	#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.LastAndFirstBoundsZ() ) + NL
	#--> [ [ ">>>", 8 ], [ "<<<", 1 ] ]

#--

? @@( o1.BoundsZZ() )
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

	? @@( o1.FirstAndLastBoundsZZ() )
	#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

	? @@( o1.LastAndFirstBoundsZZ() )
	#--> [ [ ">>>", [ 8, 10 ] ], [ "<<<", [ 1, 3 ] ] ]

pf()
# Executed in 0.09 second(s)

/*================ WORKING WITH BOUNDS INSIDE THE STRING

pr()

o1 = new stzString(">>word<<")
o1.SwapBounds()
? o1.Content()
#--> <<word>>

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")
? @@( o1.FindSubStringBoundsAsSections("word") ) # Or FindSubStringBoundsZZ()
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindSubStringBounds("word") )
#--> [ 1, 8, 13, 20, 28, 35 ]

pf()
# Executed in 0.06 second(s)

/*------------------

pr()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Bounds of the entire string

? @@( o1.FindStringBoundsAsSections() ) + NL # Or FindStringBoundsZZ()
#--> [ [ 1, 3 ], [ 35, 37 ] ]

# Bounds of a particular substring inside the string

? @@( o1.FindSubStringBoundsAsSections("word") ) + NL # Or FindSubStringBoundsZZ()
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindFirstBoundsOfAsSections("word") ) + NL # Or FindFirstBoundsOfZZ()
#--> [ [ 1, 3 ], [ 13, 15 ], [ 28, 30 ] ]

? @@( o1.FindFirstBoundsOf("word") ) + NL
#--> [ 1, 13, 28 ]

pf()
# Executed in 0.07 second(s)

/*------------------

pr()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

? @@( o1.FindSubStringSecondBoundsAsSections("word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

? @@( o1.FindSubStringSecondBounds("word") )
#--> [ 8, 20, 35 ]

pf()
# Executed in 0.07 second(s)

/*=============

pr()

o1 = new stzString("123♥^♥789")

? o1.Sit( :OnSection = [4, 6], :AndYield = [ 20, 30 ] )
#--> [ "123", "789" ]

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")
		
? o1.SubStringIsBoundedBy("♥♥", "aa")
#--> _TRUE_

? o1.SubStringIsBoundedBy("♥♥", "bb")
#--> _TRUE_
	
? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] )
#--> _TRUE_

pf()
# Executed in 0.54 second(s)

/*================

pr()

o1 = new stzList([ Q(4), Q("Ring"), Q(1:3) ])
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

pf()
# Executed in 0.02 second(s)

/*---------------

pr()

o1 = new stzList([ 6, "hi!", 1:3 ])
o1.Objectify()
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

pf()
# Executed in 0.02 second(s)

/*---------------

pr()

o1 = new stzList([ 5, "12", 1:3, "Ring" ])
o1.Numberify()
? @@(o1.Content())
#--> [ 5, 12, 3, 4 ]

pf()
# Executed in 0.04 second(s)

/*---------------

pr()

o1 = new stzList([ 1, "hi", [], _NULL_ ])
o1.Listify()
? @@( o1.Content() )
#--> [ [ 1 ], [ "hi" ], [ ], [ "" ] ]

pf()
# Executed in 0.02 second(s)

/*---------------

# Personal note :This sample has been porposed by Teeba (my daughther). She helped me
# identify the [] case and solve it.

pr()
#			vv
o1 = new stzList([ 957, [], [ 1:3, 4:5, 9:12 ], "Hussein", ["Haneen"] ])
o1.Pairify()
? @@( o1.Content() )
#--> [
#	[ 957, "" ],
#	[ "", "" ],
#	[ [ 1, 2, 3 ], [ 4, 5 ] ],
#	[ "Hussein", "" ],
#	[ "Haneen", "" ]
# ]

pf()
# Executed in 0.02 second(s)

/*----------------

pr()

o1 = new stzList([ [ "<<", ">>" ], "__", [ "--", "--", "--" ] ])
o1.Pairify() # transform all items to pairs
? @@( o1.Content() )
#--> [
#	[ "<<", ">>" ],
#	[ "__", "" ],
#	[ "--", "--" ]
# ]

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzList(["<<", ">>"])
o1.Pairify()
#--> [ [ "<<", "" ], [ ">>", "" ] ]

? @@( o1.Content() )

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzList([ ["<<", ">>"] ])
o1.Pairify()
? @@( o1.Content() )
#--> [ [ "<<", ">>" ] ]

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

? @@( Q([ ["<<", ">>"], "__" ]).Pairified() )
#--> [ [ "<<", ">>" ], [ "__", "" ] ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzString("<<word>> and __word__")

? o1.SubStringIsBoundedBy("word", ["<<", ">>"])
#--> _TRUE_

? o1.SubStringIsBoundedBy("word", "__")
#--> _TRUE_

? o1.SubStringIsBoundedByMany("word", [ ["<<", ">>"], "__" ])
#--> _TRUE_

pf()
# Executed in 0.12 second(s)

/*------

pr()

o1 = new stzString("<<word>> and __word__")
? o1.SubStringQ( "word" ).IsBoundedBy(["<<", ">>"])
#--> _TRUE_

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.27 second(s) in Ring 1.17

/*----------------

pr()

	o1 = new stzList([ "<<", ">>" ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> _TRUE_

	o1 = new stzList([ [ "<<", ">>" ], [ "__", "__" ] ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> _TRUE_

pf()
# Executed in 0.10 second(s)

/*----------------

pr()

o1 = new stzList([ "<<", ">>" ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> _TRUE_

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> __word__ @word@")
#--> _TRUE_

pf()
# Executed in 0.11 second(s)

/*----------------

pr()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> _FALSE_

pf()
# Executed in 0.11 second(s)

/*----------------

pr()

? Q("_").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> _TRUE_

? Q("<").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> _FALSE_

? Q([ "<", ">" ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> _TRUE_

? Q([ ["<",">"], ["_","_"] ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> _TRUE_

pf()
# Executed in 0.10 second(s)

/*----------------

pr()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")

? o1.SubStringIsBoundedBy("♥♥", "aa")
#--> _TRUE_
? o1.SubStringIsBoundedBy("♥♥", "bb")
#--> _TRUE_

? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] )
#--> _TRUE_
? o1.SubStringIsBoundedBy("♥♥", [ [ "aa","aaa" ], [ "bb","bbb" ] ])
#--> _TRUE_

pf()
# Executed in 0.14 second(s)

/*================= POSSIBLE SUBSTRINGS IN THE STRING

pr()

o1 = Q("ABAAC")
? @@NL( o1.SubStrings() ) + NL
#--> [
# 	"A", "AB", "ABA", "ABAA",
# 	"ABAAC", "B", "BA", "BAA",
# 	"BAAC", "A", "AA", "AAC", "A", "AC", "C"
# ]

? @@NL( o1.SubStringsZ() ) + NL
#--> [
# 	[ "A", [ 1, 3, 4 ] ],
# 	[ "AB", [ 1 ] ],
# 	[ "ABA", [ 1 ] ],
#	[ "ABAA", [ 1 ] ],
#	[ "ABAAC", [ 1 ] ],
#	[ "B", [ 2 ] ],
#	[ "BA", [ 2 ] ],
#	[ "BAA", [ 2 ] ],
#	[ "BAAC", [ 2 ] ],
#	[ "AA", [ 3 ] ],
#	[ "AAC", [ 3 ] ],
#	[ "AC", [ 4 ] ],
#	[ "C", [ 5 ] ]
# ]

? @@NL( o1.SubStringsZZ() )
#--> [
#	[ "A", [ [ 1, 1 ], [ 3, 3 ], [ 4, 4 ] ] ],
#	[ "AB", [ [ 1, 2 ] ] ],
#	[ "ABA", [ [ 1, 3 ] ] ],
#	[ "ABAA", [ [ 1, 4 ] ] ],
#	[ "ABAAC", [ [ 1, 5 ] ] ],
#	[ "B", [ [ 2, 2 ] ] ],
#	[ "BA", [ [ 2, 3 ] ] ],
#	[ "BAA", [ [ 2, 4 ] ] ],
#	[ "BAAC", [ [ 2, 5 ] ] ],
#	[ "AA", [ [ 3, 4 ] ] ],
#	[ "AAC", [ [ 3, 5 ] ] ],
#	[ "AC", [ [ 4, 5 ] ] ],
#	[ "C", [ [ 5, 5 ] ] ]
# ]

pf()
# Executed in 0.02 second(s)

/*=================

pr()

? Q([ "abc", 120, "cdef", 14, "opjn", 988 ]).ToString()

#-->
#	"abc
#	120
#	cdef
#	14
#	opjn
#	988"

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

? Q(["abc","cdef","opjn"]).ToString() + NL # Q() creates a stzList object
#-->
#	abc
#	cdef
#	opjn

pf()
# Executed in 0.03 second(s)

/*=================

pr()

o1 = new stzList(["A", "AA", "B", "BB", "C", "CC", "CC" ])
? o1.ItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC", "CC" ])

? o1.UniqueItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC" ]

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzListOfStrings([
	"A", "v", "♥", "c",
	"Av", "♥♥", "c♥", "Av♥",
	"♥c♥",
	"Av♥♥", "Av♥♥c",
	"Av♥♥c♥",
	"Av♥♥c♥♥"
])

? o1.StringsW(' Q(@String).NumberOfChars() = 2 ')
#--> [ "Av", "♥♥", "c♥" ]

? o1.StringsW('
	Q(@String).BeginsWith("A") and Q(@String).NumberOfChars() > 4
')
#--> [ "Av♥♥c", "Av♥♥c♥", "Av♥♥c♥♥" ]

pf()
# Executed in 0.40 second(s)

/*================ #TODO check it!

pr()

? Q("#1 : #3").ToList()
#--> Sould produce [ "#1", "#2", "#3" ])

pf()

/*-----------

pr()

o1 = new stzString("Av♥♥c♥♥")
? @@NL( o1.SubStringsU() )
#--> [
#	"A",
#	"Av",
#	"Av♥",
#	"Av♥♥",
#	"Av♥♥c",
#	"Av♥♥c♥",
#	"Av♥♥c♥♥",
#	"v",
#	"v♥",
#	"v♥♥",
#	"v♥♥c",
#	"v♥♥c♥",
#	"v♥♥c♥♥",
#	"♥",
#	"♥♥",
#	"♥♥c",
#	"♥♥c♥",
#	"♥♥c♥♥",
#	"♥",
#	"♥c",
#	"♥c♥",
#	"♥c♥♥",
#	"c",
#	"c♥",
#	"c♥♥",
#	"♥",
#	"♥♥",
#	"♥"
# ]

# If you want the list of uniques substrings, use: SubStringsU()

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzString("Av♥♥c♥♥")

? o1.FindAll("♥♥")
#--> [ 3, 6 ]

? @@( o1.FindSubStringsW('{ @SubString = "♥♥" }') )
#--> [ 3, 6 ]

pf()
# Executed in 0.08 second(s)

/*===============

pr()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBoundedBy([ "<<", ">>" ])
#--> [ "word1", "word2" ]

o2 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? @@( o2.SubstringsBoundedBy('"') )
#--> [ "    value ", "  and var2 =  ", " 12   " ]

pf()
# Executed in 0.02 second(s)

/*----------------

pr()

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')

? @@( o1.SubStringsBoundedBy('"') ) + NL
#--> [ "    value ", "  and var2 =  ", " 12   " ]

? @@( o1.SubStringsBoundedByIB('"') ) + NL
#--> [[ '"    value "', '"  and var2 =  "', '" 12   "' ]

? @@( o1.FindSubStringsBoundedBy('"') )
#--> [ 16, 27, 42 ]

? @@( o1.FindSubStringsBoundedByIB('"') )
#--> [ 15, 26, 41 ]

pf()
# Executed in 0.02 second(s)

/*================

pr()

o1 = new stzString("blabla bla <<word>> bla bla <<word>>")
? @@( o1.FindAsSections("word") ) # Or FindSubStringAsSections() or FindZZ()
#--> [ [14, 17], [31, 34] ]

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? @@( o1.FindAnyBoundedBy([ "<<", ">>" ]) ) + NL
#--> [ 14, 32 ]

o2 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? @@( o2.FindAnyBoundedByAsSections([ "<<", ">>" ]) )
#--> [ [14, 18], [32, 36] ]

pf()

/*---------------

pr()

? Q(" this code:   txt1  = ").Simplified()
#--> "this code: txt1 ="

pf()
# Executed in 0.04 second(s)

/*==============

pr()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***THREE")
#--> _TRUE_

? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***THREE")
#--> _FALSE_

pf()
# Executed in 0.02 second(s)

/*----------------

pr()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> _TRUE_

? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> _FALSE_

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new stzNumber(10)
? o1.Occures( :Before = "TEN", :In = [ 2, "TWO", 10, "TEN" ] ) # NOTE: OccurEs is misspelled!
#--> _TRUE_

o1 = new stzList(1:3)
? o1.Occurs( :Before = 1:7, :In = [ 1:2, "TWO", 1:3, 1:7, "THREE" ] )
#--> _TRUE_

o1 = new stzObject(ANullObject())
? o1.Comes( :Before = "_NULL_", :In = [ 1, 2, ANullObject(), "_NULL_" ] )
#--> _TRUE_

o1 = new stzString("one")
? o1.Happens( :Before = "two", :In = [ "one", "two", "three" ] )
#--> _TRUE_

pf()
# Executed in 0.06 second(s)

/*----------------

pr()

? Q("*").OccursNTimes(3, :In = "a*b*c*d")
#--> _TRUE_

? Q("*").OccursNTimes(3, :In = [ "a", "*", "b", "*", "c", "*", "d" ])
#--> _TRUE_

pf()
# Executed in 0.06 second(s)

/*----------------

pr()

? Q("*").OccursForTheFirstTime( :In = "a*b*c*d", :AtPosition = 2 )
#--> _TRUE_

? Q("*").OccursForTheLastTime( :In = "a*b*c*d", :AtPosition = 6 )
#--> _TRUE_

? Q("*").OccursForTheLastTime( :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 ) #--> _TRUE_
#--> _TRUE_

? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 )
#--> _TRUE_

? Q("*").OccursForTheNthTime( 2, :In = "a*b*c*d", :AtPosition = 4 )
#--> _TRUE_

? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 )
#--> _TRUE_

? Q("*").OccursForTheNthTime( 1, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 2 )
#--> _TRUE_

? Q("*").OccursForTheNthTime( 2, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 4 )
#--> _TRUE_

? Q("*").OccursForTheNthTime( 3, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 )
#--> _TRUE_

pf()
# Executed in 0.06 second(s)

/*----------------

pr()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 1 )
#--> _TRUE_

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 2 )
#--> _TRUE_

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 3 )
#--> _FALSE_

? Q("bag").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 4 )
#--> _TRUE_

? Q("hat").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 5 )
#--> _TRUE_

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 6 )
#--> _FALSE_

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q(aShoppingCart).FindW('{
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )
}')
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in 0.19 second(s)

/*================ #narration #todo check after including yieldw()

pr()

  # Suppose a customer added all these items to his shopping cart in an
  # ecommerce website:

  aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

  # You are asked, as a programmer of the website, to extract the number of times
  # each item has been added...

  # In natural thinking, you yould resolve it like this:

  # 	- In the shopping cart,

  # 	- yield each item and how many times the item exists in the cart

  # 	- but, of course, do it only when the item occures for the first time in the cart
  #       (because you don't need to yield  its occurrences again and again!)

  # In Softanza, using the Yielder Metaphor, you express the same thinking in code:


  ? Q(aShoppingCart).YieldW('

	[ @item, This.HowMany( @item ) ]',

	:Where = '
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )'
  )

  #--> [ [ "Shirt", 2 ], [ "shoes", 2 ], [ "bag", 1 ], [ "hat", 1 ] ]

pf()
# Executed in 0.28 second(s)

/*=========

pr()

? ComputableForm('len    var1 = "    value "  and var2 =  " 12   " ') + NL
#--> 'len var1 = "    value " and var2 = " 12   "'

? ComputableForm("len    var1 = '    value '  and var2 =  ' 12   ' ")
#--> "len    var1 = '    value '  and var2 =  ' 12   ' "

pf()
# Executed in 0.01 second(s)

/*=================

pr()

o1 = new stzString("Av♥♥c♥♥")

? @@NL( o1.SubStringsWXTZ('{
	Q(@SubString).NumberOfChars() = 2	
}') )
#--> [
#	[ "Av", [ 1 ] ],
#	[ "v♥", [ 2 ] ],
#	[ "♥♥", [ 3, 6 ] ],
#	[ "♥c", [ 4 ] ],
#	[ "c♥", [ 5 ] ]
# ]

pf()
# Executed in 0.27 second(s) on Ring 1.21
# Executed in 0.50 second(s) on Ring 1.20

/*-------------

pr()

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.SubStringsWXTZZ('{
	Q(@SubString).NumberOfChars() = 2 and NOT Q(@SubString).Contains("♥")
}') )

#--> [ [ "Av", [ [ 1, 2 ] ] ] ]

pf()
# Executed in 0.27 second(s).

/*=================

pr()

o1 = new stzString("I love ")
o1.AddSubString("Ring")
? o1.Content()
#--> I love Ring

pf()
# Executed in 0.01 second(s)

#-----------------

pr()

o1 = new stzString("Ring")
o1.ExtendToNCharsXT(10, :Using = ".")
? o1.Content()
#--> "Ring.........."

pf()
# Executed in 0.01 second(s)

/*=================

pr()

? Q("-♥-").IsBoundedBy("-")
#--> _TRUE_

? Q("♥").IsBoundedByIB("-", :In = "... -♥- ...")
#--> _TRUE_

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

? StzCharQ(1049).Content() + NL
#--> Й

? @@( StzListOfCharsQ(1000 : 1009).Content() ) + NL
#--> [ "Ϩ", "ϩ", "Ϫ", "ϫ", "Ϭ", "ϭ", "Ϯ", "ϯ", "ϰ", "ϱ" ]

Q("℺℻ℚ") {

	? Unicodes() 	#--> [ 8506, 8507, 8474 ]
	? UnicodesXT() 	// Or alternatively UnicodesAndChars()
	#--> [ [ 8506, "℺" ], [ 8507, "℻" ], [ 8474, "ℚ" ] ]

	? CharsAndUnicodes()
	#--> [ [ "℺", 8506 ], [ "℻", 8507 ], [ "ℚ", 8474 ] ]

	? CharsNames()
	#--> [ "ROTATED CAPITAL Q", "FACSIMILE SIGN", "DOUBLE-STRUCK CAPITAL Q" ]

}

pf()
# Executed in 0.16 second(s)

/*-------------- #TODO // Use the normal way (ExecutableSection) and check for perf
#todo check after including yield() function

pr()

? @@( Q("℺℻ℚ").Yield('[ @char, Q(@char).Unicode(), Q(@char).CharName() ]') )
#--> [
# 	[ "℺", 8506, "ROTATED CAPITAL Q" ],
# 	[ "℻", 8507, "FACSIMILE SIGN" ],
# 	[ "ℚ", 8474, "DOUBLE-STRUCK CAPITAL Q" ]
#    ]

pf()
# Executed in 0.14 second(s)

/*==============
$
pr()

# What are the unique letters in this sentence?
# "sun is hot but fun"

# To solve it, you can use stzString and say:

? @@( Q("sun is hot but fun").RemoveSpacesQ().UniqueChars() ) + NL
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# Or you can use stzList and say:

? @@( Q([ "sun", "is", "hot", "but", "fun" ]).UniqueItems() ) + NL
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

pf()
# Executed in 0.01 second(s)

/*----------------

pr()

? len("طيبة")
#--> 8

? StzStringQ("طيبة").NumberOfChars()
#--> 4

? StzStringQ("طيبة").NumberOfBytes()
#--> 378

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = Q("TAYOUBAAOOAA")
? o1.LastAndFirstChars()
#--> [ "A", "T" ]

pf()
# Executed in 0.01 second(s)

/*========================= #AI #claude-ai #narration ...WXT() vs ...W()
# Narraion enhanced by ClaudeAI, both from structural and linsguistic stand points.

pr()

# This narration demonstrates an advanced feature of SoftanzaLib 
# called Conditional Code. We will explain what Conditional Code is,
# and then We'll explore two main forms of conditional functions:
# `..W()` and `..WXT()`, comparing their expressiveness, performance,
# and use cases.

# This comparison will help you understand when to use each
# function for optimal results in your code.

# 1. Conditional code, by example:

	# To each fucntion in Softanza, ther is a ..W() extension that
	# runs the same function but with a conditional code (W ~> Where).

	# Conditional code is a en expression you provide to the function
	# to be evaluated against each element in the data set.

	# This opens endless possibilities for you to tackle your
	# algorithmic problems without the obligation of using rather
	# complex, less readable, and error prone, if-then-else constructs.
	
	# Let's take the example of Find() function, that we use like this:
	
	? Q([ "♥", "A", "♥", "B", "♥", "C" ]).Find("A")
	#--> [ 3, 6, 9 ]

	# We can achieve the same result using the W() eXTended form:

	? Q([ "♥", "A", "♥", "B", "♥", "C" ]).FindWXT(' Q(@item).IsLetter() ') # Ignore the XT() for now.
	#--> [ 3, 6, 9 ]

	# In this case, the condition ' Q(@item).IsLetter() ' is evaluated against
	# each character of the string, returning the positions of all letters.
	
	# Next we delve on the diffrence betwenn `W()` and `W()` forms.

	# Todo so, let's initiate a stzList object with the fellwong items:

	o1 = new stzList([ "A", "B", "♥", "♥", "C", "♥", "♥", "D", "♥","♥" ])

	? "---" + NL + NL

# 2. The `..WXT()` Form: Expressive but Less Performant

	# The `WXT()` function is designed for use when the condition
	# expression contains sophisticated keywords beyond the basic
	# "@i" and "This[@i]"-like keywords.

	# This option offers greater expressiveness but at the
	# cost of performance.

	# When you use the `..WXT()` form, SoftanzaLib performs an
	# internal process called 'transpiling'.

	# This process translates the provided conditional code by
	# replacing sophisticated keywords (like @CurrentItem,
	# @NextItem, etc.) with their basic equivalents using only
	# @i and This[@i]. For example:

	# 	- @CurrentItem becomes This[@i]
	# 	- @NextItem becomes This[@i+1]
	# 	- @PreviousItem becomes This[@i-1]

	# Hence, this transpiling step allows `..WXT()` to be more
	# expressive, but it also introduces a performance overhead.

	# Examples using `WXT()`:

	? @@( o1.FindWXT('{ @CurrentItem = @NextItem }') ) + NL
	#--> [ 3, 6, 9 ]
	
	? o1.FindFirstWXT(' @CurrentItem = @NextItem ')
	#--> 3
	
	? o1.FindFirstWXT(' @CurrentItem = @PreviousItem ')
	#--> 4
	
	? o1.FindLastWXT(' @CurrentItem = @NextItem ')
	#--> 9
	
	? o1.FindNthWXT(2, ' @CurrentItem = @NextItem ') + NL
	#--> 6

	# Executed in 1.20 second(s)

	? "---" + NL + NL

# 3. The `..W()` Form: Restrictive but More Performant

	# The `..W()` form restricts you to expressing your conditions
	# using only "@i" and "This[@i]", regardless of their complexity.
	# This limitation makes `W()` less expressive but more performant.

	# Examples using `W()`:

	? @@( o1.FindW(' This[@i] = This[@i+1] ') ) + NL
	#--> [ 3, 6, 9 ]
	
	? o1.FindFirstW(' This[@i] = This[@i+1] ')
	#--> 3
	
	? o1.FindFirstW(' This[@i] = This[@i-1] ')
	#--> 4
	
	? o1.FindLastW(' This[@i] = This[@i+1] ')
	#--> 9
	
	? o1.FindNthW(2, ' This[@i] = This[@i+1] ') + NL
	#--> 6

	# Executed in 0.82 second(s)
	
	? "---" + NL + NL

	#NOTE # on Performance Comparison

	# The performance gain from using `W()` instead of `WXT()`
	# (1.24 seconds vs 0.90 seconds in our example) becomes more
	# significant when running complex conditional codes on
	# large datasets.

# 4. When choosing the wrong form, what should you expect?

	# When using just basic keywords (i.e., @i and This[@i]-like) with
	# the `WXT()` function, your code will work, but you'll incur an
	# unnecessary performance cost due to the transpiling process:

	? o1.FindNthWXT(2, ' This[@i] = This[@i+1] ')
	#--> 6
	# Executed in 0.20 second(s)
	
	? o1.FindNthW(2, ' This[@i] = This[@i+1] ') #--> 6
	# Executed in 0.15 second(s)

	# Conversely, using sophisticated keywords with the `W()` function
	# will result in an error:

	//? o1.FindFirstW(' This[@i] = @PreviousItem ')
	#--> Error message: Using uninitialized variable: @previousitem

	? "---" + NL + NL

# 5. An Additional small syntax difference

	# In `WXT()`, you can bound the conditional code with curly braces { and }.
	# This syntactic sugar is used to mimic real Ring code and provide programmers
	# coming to Ring from other languages with a familiar experience. Like This:

	? o1.FindWXT('{
		len(@Char) = 1 and
		@IsLetter(@Char) and
		@Char != "X"
	}')
	#--> [ 1, 2, 5, 8 ]
	# Executed in 0.26 second(s)

	# However, this isn't possible in the `W()` form.

	# This difference aligns with the general trade-off between
	# expressiveness and performance.

# 6. Key Takeaways

	# 1. Use `WXT()` when you need to express complex conditions with
	#    sophisticated keywords.

	# 2. Use `W()` for better performance and write your condition
	#    using only @i and This[@i].

	# 3. Be aware of the performance implications when choosing between
	#    `WXT()` and `W()`, especially for large datasets or complex operations.

	# 4. Alwas remember that `WXT()` allows for more flexible syntax (like using
	#    sophisticaded keywords and curly braces), while `W()` form is more
	#    restrictive but faster.
	
# By understanding these differences, you can make informed decisions about
# which function form to use in your conditional code, balancing expressiveness
# and performance based on your specific needs.

pf()
# Executed in 1.09 second(s) on Ring 1.20
# Executed in 2.76 second(s) on Ring 1.20

/*----------------

pr()

o1 = new stzList("A":"E")
? @@( o1 / 3 )
#--> [ [ "A", "B" ], [ "C", "D" ], [ "E" ] ]

pf()
# Executed in 0.04 second(s)

/*------- #ring

pr()

aList = []
for i = 1 to 5
	aList + [1]
next

? @@(aList)
#--> [ [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]

pf()

/*=======

pr()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(0) ) + NL
#--> [ ]

? @@( o1.SplitToNParts(1) ) + NL
#--> [ [ 1, 12 ] ]

? @@( o1.SplitToNParts(2) ) + NL
#--> [ [ 1, 6 ], [ 7, 12 ] ]

? @@( o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 12 ] 

? @@( o1.SplitToNParts(4) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 12 ] ]

? @@( o1.SplitToNParts(5) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(6) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(7) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(8) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(9) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(10) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(11) ) + NL
#--> [ [ 1, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(12) ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

pf()
# Executed in 0.04 second(s)

/*---------

pr()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(13) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

? @@( o1.SplitToNParts(-2) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

pf()

/*---------

pr()

o1 = new stzSplitter(10)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 7 ], [ 8, 10 ] ]

o1 = new stzSplitter(11)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ] ]

o1 = new stzSplitter(17)
? @@(o1.SplitToNParts(5) ) + NL
# [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ], [ 12, 14 ], [ 15, 17 ] ]

o1 = new stzSplitter(78)
? @@(o1.SplitToNParts(12) )
#--> [
# 	[  1,  7 ], [  8, 14 ], [ 15, 21 ],
# 	[ 22, 28 ], [ 29, 35 ], [ 36, 42 ],
#	[ 43, 48 ], [ 49, 54 ], [ 55, 60 ],
#	[ 61, 66 ], [ 67, 72 ], [ 73, 78 ]
# ]

o1 = new stzSplitter(0)
? @@(o1.SplitToNParts(5) )
#--> []

pf()
# Executed in 0.03 second(s)

/*---------

pr()

o1 = new stzString("ABCDEFGHIJ")

? @@( o1 / 10 ) + NL
#--> [ "A" ,"B", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 9 ) + NL
#--> [ "AB", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 8 ) + NL
#--> [ "AB", "CD", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 7 ) + NL
#--> [ "AB", "CD", "EF", "G", "H", "I", "J" ]

? @@( o1 / 6 ) + NL
#--> [ "AB", "CD", "EF", "GH", "I", "J" ]

? @@( o1 / 5 ) + NL
#--> [ "AB", "CD", "EF", "GH", "IJ" ]

? @@( o1 / 4 ) + NL
#--> [ "ABC", "DEF", "GH", "IJ" ]

? @@( o1 / 3 ) + NL
#--> [ "ABCD", "EFG", "HIJ" ]

? @@( o1 / 2 ) + NL
#--> [ "ABCDE", "FGHIJ" ]

? @@( o1 / 1 ) + NL
#--> [ "ABCDEFGHIJ" ]

? @@( o1 / 0 )
#--> [ ]

pf()
# Executed in 0.06 second(s) on Ring 1.21
# Executed in 0.12 second(s) on Ring 1.20

/*---------

pr()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1 / 89 )
#--> Error message: Incorrect value! n must be between 0 and 10 (the size of the list).

pf()

/*=============

pr()

o1 = Q("AB♥♥C♥♥D♥♥")
? o1.FindCharsW(' @Char = "♥" ')
#--> [ 3, 4, 6, 7, 9, 10 ]

? o1.FindCharsW(' @CurrentChar = @NextChar ')
#--> [ 3, 6, 9 ] 

? o1.FindNthCharW(2, '@CurrentChar = @NextChar') + NL
#--> 6

? o1.FindFirstCharW('@CurrentChar = @NextChar') + NL
#--> 3

? o1.FindLastCharW('@CurrentChar = @NextChar')	 #--> 9
#--> 9

pf()
# Executed in 0.99 second(s) in Ring 1.20
# Executed in 1.38 second(s) in Ring 1.18

/*----------------

pr()

@T = Q("TAYOUBA")
? @T.Section( :From = "A", :To = "B" )
#--> AYOUB

? @T.Section( :From = :FirstChar, :To = @T.First("A") )
#--> TA

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

o1 = new stzString("SOFTANZA")

? o1.Section( :From = o1.PositionOfFirst("A"), :To = :LastChar )
#--> ANZA

? o1.Section( :From = o1.First("A"), :To = :LastChar )
#--> ANZA

pf()
# Executed in 0.02 second(s)


/*----------------

pr()

o1 = new stzList([ "T","A","Y","T","O", "A", "U", "B", "T", "A" ])
? @@( o1.Section(:From = "A", :To = "T") ) + NL
#--< [ "A", "Y", "T", "O", "A", "U", "B", "T" ]

? @@SP( o1.SectionsBetween( "T", :And = "A" ) )
#--> [
#	[ "T", "A" ],
#	[ "T", "A", "Y", "T", "O", "A" ],
#	[ "T", "A", "Y", "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "O", "A" ],
#	[ "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "A" ]
# ]

pf()
# Executed in 0.02 second(s)

/*---------------- #TODO/FUTURE: Implement these functions

pr()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])
? o1.ContainsInEachList("♥")

? o1.ContainsInJustOneList("♥")

? o1.ContainsInNLists(3, "♥")
? o1.ContainsNOccurrencesInAllLists(3, "♥")
? o1.ConatinsNOccurrencesInEachList(1, "♥")
? o1.ContainsNOccurrencesInNLists(1, 3, "♥")
? o1.ContainsNOccurrencesInTheseLists([ [1, 1], [3, 2] ])

pf()

/*---------------- #todo/future: add these functions

pr()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])

aListOfLists = [ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ]
? Q("♥").ExistsIn( aListOfLists  )
? Q("♥").ExistsInLists( aListOfLists  )
? Q("♥").ExistsInOnlyOneList( aListOfLists )
? Q("♥").ExistsInNLists(2, aListOfLists )
? Q("♥").ExistsNTimesInAllLists(3, aListOFLists )
? Q("♥").ExistsNTimesInEachList(3, aListOFLists )
? Q("♥").ExistsNTimesInNLists(3, 2, aListOFLists )
? Q("♥").ExistsNTimesInTheseLists([ [1, 1], [3, 2] ])

pf()

/*----------

pr()

? 3Hearts() #--> ♥♥♥
? 5Stars()  #--> ★★★★★

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindFirstNOccurrences(2, :Of = "ring")
#--> [ 2, 4 ]

? o1.FindLastNOccurrences(2, :Of = "ring")
#--> [ 4, 6 ]

? o1.FindTheseOccurrences([2, 3], :Of = "ring")
#--> [ 4, 6 ]

pf()
# Executed in 0.04 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindNthOccurrence(3, "ring")
#--> 5

pf()
# Executed in 0.01 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
#--> [ 1, 7 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 7 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

anPos = o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
? anPos
#--> [ 1, 7 ]

o1.RemoveItemsAtPositions(anPos)
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindTheseOccurrences([1, 4], "ring")
#--> [ 1, 7 ]

o1.RemoveItemsAtPositions([1, 7])
? @@( o1.content() )
#--> [ "__", "ring", "__", "ring", "__" ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.RemoveOccurrences([ :First, :Last ], :Of = "ring" )
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceOccurrences([ :First, :And = :Last ], :Of = "ring", :With = 3Hearts() )
? @@( o1.Content() )
#--> [ "♥♥♥", "__", "ring", "__", "ring", "__", "♥♥♥" ]

pf()
# Executed in 0.09 second(s)

/*----------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceFirstNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() )
#--> [ "★★", "__", "★★", "__", "ring", "__", "ring" ]

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceLastNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() )
#--> [ "ring", "__", "ring", "__", "★★", "__", "★★" ]

pf()
# Executed in 0.11 second(s)

/*==============

pr()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.FindTheseOccurrences([ :First, :And = :Last ], "ring")
#--> [ 1, 25 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 25 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # or FindNthOccurrence(2, "ring")
#--> 9

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
? anPos
#--> [ 1, 9, 17 ]

o1.ReplaceSubStringAtPositions(anPos, "ring", Heart())

? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

pf()
# Executed in 0.03 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.ReplaceFirstNOccurrences(3, "ring", Heart())
? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

pf()
# Executed in 0.03 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveSubStringAtPosition(1, "ring")
? o1.Content()
#-->  __ ring __ ring __ ring

pf()
# Executed in 0.01 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
? @@( anPos )
#--> [ 1, 9, 17 ]

o1.RemoveSubStringAtPositions(anPos, "ring")
? o1.Content()
#--> " __  __  __ ring"

pf()
# Executed in 0.03 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.FindOccurrences([ 2, 3 ], "ring")
#--> [ 9, 17 ]

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveOccurrences([2, 3], "ring")
? o1.Content() + NL
#--> ring __  __  __ ring

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveFirstNOccurrences(3, "ring")
? o1.Content() + NL
#--> " __  __  __ ring"

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveLastNOccurrences(3, "ring")
? o1.Content()
#--> "ring __  __  __ "

pf()
# Executed in 0.04 second(s)

/*----------

pr()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # o1.FindNthOccurrence(2, "ring")
#--> 9

pf()
# Executed in 0.02 second(s)

/*========

pr()

o1 = new stzHashList([ [ "hussein", 3 ], [ "haneen", 1 ], [ "teeba", 3 ] ])
? o1.ValuesQRT(:stzListOfNumbers).Sum()
#--> 7

pf()
# Executed in 0.03 second(s)

/*----

pr()

? sum(1:10)
#--> 55

pf()
# Executed in 0.02 second(s)

/*================ #narration

pr()

# In Softanza, you can divide the content of a string into 3 parts
cLetters = "ABCDEFG"

? Q(cLetters) / 3
#--> [ "ABC", "DE", "FG" ]

# Those 3 parts can be "named" parts:

? Q(cLetters) / [ "Hussein", "Haneen", "Teeba" ]
#--> [ :Hussein = "ABC", :Haneen = "DE", :Teeba = "FG" ]

# And you can configure the share of each part at your will:
? Q(cLetters) / [ :Hussein = 3, :Haneen = 1, :Teeba = 3 ]
#--> [ :Hussein = "ABC", :Haneen = "D", :Teeba = "EFG" ]

pf()
#--> Executed in 0.07 second(s)

/*====================

pr()

o1 = new stzSplitter(10)

? @@( o1.SplitBeforePositions([3,7]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

pf()
# Executed in 0.03 second(s)

/*------

pr()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :atPosition = 15) ) # Note that position 15 is out of the string
#-->[ "1234567890" ]

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ "1234", "67890" ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ "12", "456", "890" ]

? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ "1234", "567890" ]

? @@( o1.SplitXT( :before = [3, 7] ) ) + NL
#--> [ "12", "3456", "7890" ]

? @@( o1.SplitXT( :after = 5 ) ) + NL
#--> [ "12345", "67890" ]

? @@( o1.SplitXT( :after = [3, 7] ) ) + NL
#--> [ "123", "4567", "890" ]

? @@( o1.SplitXT( :ToPartsOfNChars = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ "123", "456", "789" ]

? @@( o1.SplitXT( :ToPartsOfNCharsXT = 3 ) ) + NL # remaining part is added
#--> [ "123", "456", "789", "0" ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ "123", "456", "78", "90" ]

pf()
# Executed in 0.39 second(s)

/*------

pr()

o1 = new stzList(1:10)

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
# List is returned as-is (no split) because the item [3, 7] does not exist in 1:10

# If you want to say by [3, 7] the positions 3 and 7, be explicit and write:
? @@( o1.SplitXT( :atPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 4, 5, 6 ], [ 8, 9, 10 ] ]


? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :beforePositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 3, 4, 5, 6 ], [ 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPosition = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6, 7 ], [ 8, 9, 10 ] ]

? @@( o1.SplitXT( :ToPartsOfNItems = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? @@( o1.SplitXT( :ToPartsOfNItemsXT = 3 ) ) + NL # remaining part is added
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

pf()
# Executed in 0.42 second(s)

/*================

pr()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAt(4) )	# or SplitAtPosition(4)
#--> [ "ONE", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAt([ 4, 8 ]) ) # or SplitAtPositions([4, 8])
#--> [ "ONE", "TWO", "THREE" ]

pf()
# Executed in 0.03 second(s)

/*------------------

pr()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitBefore(4) ) # or SplitBeforePosition(4)
#--> [ "ONE", "_TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitBefore([ 4, 8 ]) ) # or SplitBeforePositions([ 4, 8 ])
#--> [ "ONE", "_TWO", "_THREE" ]

pf()
# Executed in 0.03 second(s)

/*------------------

pr()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAfter(4) ) # or SplitAfterPosition(4)
#--> [ "ONE_", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAfter([ 4, 8 ]) ) # or SplitAfterPositions([ 4, 8 ])
#--> [ "ONE_", "TWO_", "THREE" ]

pf()
# Executed in 0.06 second(s)

/*==================

pr()

o1 = new stzString("ABCDE")
? @@( o1.SplitToNParts(5) ) + NL
#--> [ "A", "B", "C", "D", "E" ]

o1 = new stzString("AB12CD34")
? @@( o1.SplitToPartsOfNChars(2) ) + NL
#--> [ "AB", "12", "CD", "34" ]

o1 = new stzString("ABC123DEF456")
? @@( o1.SplitToPartsOfNChars(3)) + NL
#--> [ "ABC", "123", "DEF", "456" ]

o1 = new stzString("ABCD1234EF")
? @@( o1.SplitToPartsOfNChars(4)) + NL # SplitToPartsOfExactlyNChars
#--> [ "ABCD", "1234" ]

? @@( o1.SplitToPartsOfNCharsXT(4)) # The remaining part is also returned
#--> [ "ABCD", "1234", "EF" ]

pf()
# Executed in 0.04 second(s)

/*===================

pr()

? Q(0).IsMultipleOf(3) #--> _FALSE_

pf()
# Executed in 0.02 second(s)

/*------------------

pr()

o1 = new stzString("123456789012")
? @@( o1.SplitAtCharWXT( 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SpliAtCharWXT( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtCharWXT( :At = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtCharWXT( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtCharWXT( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

pf()
# Executed in 0.85 second(s)

/*==================)

pr()

? Q("12_500").IsNumberInString()
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*------------------

pr()

o1 = new stzString("one = 12_500 two = 17_500 three = 88")
? o1.Numbers()
#--> [ "12_500", "17_500", "88" ]

pf()
# Executed in 0.06 second(s)

/*------------------

pr()

? StringToNumber(5) # or ToNumber()
#--> 5

? StringToNumber("12.5")
#--> 12.50

? StringToNumber("12_500")
#--> 12500

pf()
# Executed in 0.02 second(s)

/*------------------

pr()

? Numberify(5)
#--> 5

? Numberify("12.5")
#--> 12.50

? Numberify("12_550")
#--> 12550

? Numberify([ "5", "12.5", "12_550" ])
#--> [ 5, 12.50, 12550 ]

pf()
# Executed in 0.04

/*------------------

pr()

o1 = new stzString("12_500")
? o1.ToNumber()
#--> 12500

pf()
# Executed in 0.02 second(s)

/*------------------

pr()

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :Before = 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeCharsWXT( 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeCharsWXT( :Where = 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

pf()
# Executed in 0.69 second(s)

/*------------------

pr()

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :After = 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( :Where = 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

pf()
# Executed in 0.66 second(s)

/*------------------

pr()

o1 = new stzList([ "__", 3, "__", 6, "__", 9, "__" ])

? @@( o1.SplitWXT( :After = 'Q(@item).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterWXT( 'Q(@item).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterWXT( :Where = 'Q(@item).IsMultipleOf(3)' ) )
#--> [ [ "__", 3 ], [ "__", 6 ], [ "__", 9 ], [ "__" ] ]

pf()
# Executed in 0.40 second(s)

/*==================

pr()

o1 = new stzList([ "a", "abcade", "abc", "ab", "b", "aaa", "abcdaaa" ])

o1.SortByUp('len(@item)') + NL
? @@( o1.Content() )
#--> [ "a", "b", "ab", "aaa", "abc", "abcade", "abcdaaa" ]

? o1.SortByDown('Q(@item).HowMany("a")') # or SortByInDescending()
? @@( o1.Content() )
#--> [ "abcdaaa", "aaa", "abcade", "abc", "ab", "a", "b" ]

pf()
# Executed in 0.08 second(s)

/*------------------

pr()

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortByDown('len(@item)')
? o1.Content()
#--> [ "abcde", "abcd", "abc", "ab", "a" ]

pf()
# Executed in 0.10 second(s)

/*==================

pr()

o1 = new stzString("TUNISiiiGAFSAIIIBEJAiiiSFAXIIIGBELLI")
? @@( o1.SplitCS("iii", :CS = _FALSE_) )
#--> [ "TUNIS", "GAFSA", "BEJA", "SFAX", "GBELLI" ]

pf()
# Executed in 0.02 second(s)

/*------------------

pr()

o1 = new stzString("TUNIS tunis GAFSA gafsa NABEUL nabeul BEJA beja")

? @@( o1.Words() ) + NL
#--> [ "TUNIS", "tunis", "GAFSA", "gafsa", "NABEUL", "nabeul", "BEJA", "beja" ]

? @@( o1.WordsCS(_FALSE_) ) + NL
#--< [ "TUNIS", "GAFSA", "NABEUL", "BEJA" ]

pf()
# Executed in 0.03 second(s)

/*------------ #ring #sort #narration

#NOTE: read this discussion with Mahmoud
# https://groups.google.com/g/ring-lang/c/bwWg4Qy6_e4

pr()

# Ring provides a powerful function for sorting a list of lists
# based on a given column. Here is an example:

aList = [
	[ "a", 1 ], [ "b", 1 ], [ "c", 1 ], [ "d", 1 ],
	[ "ab", 2 ], [ "cd", 2 ],
	[ "abc", 3 ],
	[ "abcd", 4 ],
	[ "bccd", 4 ],
	[ "bc", 2 ],
	[ "bcd", 3 ],
	[ "dda", 3 ]
]

? @@SP( sort(aList, 2) ) + NL
#--> [
#	[ "c", 1 ],
#	[ "d", 1 ],
#	[ "a", 1 ],
#	[ "b", 1 ],
#
#	[ "bc", 2 ],
#	[ "cd", 2 ],
#	[ "ab", 2 ],
#
#	[ "bcd", 3 ],
#	[ "abc", 3 ],
#	[ "dda", 3 ],
#
#	[ "abcd", 4 ],
#	[ "bccd", 4 ]
# ]

# Unfortunately, the lists with the same value in the nth column
# are not sorted. Not only that, but even their initial order
# (is not preserved! Softanza proposes a corrective function
# to deal with that:

? @@SP( SortOn(aList, 2) )
#--> [
#	[ "a", 1 ],
#	[ "b", 1 ],
#	[ "c", 1 ],
#	[ "d", 1 ],

#	[ "ab", 2 ],
#	[ "bc", 2 ],
#	[ "cd", 2 ],

#	[ "abc", 3 ],
#	[ "bcd", 3 ],
#	[ "dda", 3 ],

#	[ "abcd", 4 ],
#	[ "bccd", 4 ]
# ]

# This function is used in the background for sorting
# tables and lists of lists.

pf()
# Executed in 0.04 second(s)

/*------------

pr()

aList = [ "a", "b", "c", "d", "ab", "cd", "abc", "abcd", "bc", "bcd" ]
? SortOn(aList, 2)
#--> Error message: Incorrect param type! paList must be a list of lists.

pf()

/*------------

pr()

? @@SP(
	StzListQ([ "D", "B", "A", "C", "B", "B" ]).ItemsZ()
)

#--> [
#	[ "D", [ 1 ] ],
#	[ "B", [ 2, 5, 6 ] ],
#	[ "A", [ 3 ] ],
#	[ "C", [ 4 ] ]
# ]

pf()
# Executed in 0.02 second(s)

/*------------

pr()

myObjName = StzNamedObjectQ(:myobjname = ANullObject())

aList = [
	[ "a", 1, "_" ], myObjName, 
	[ "f", 1, "_" ], [ "a", 1, "_" ], [ "b", 1, "_" ], [ "c", 1, "_" ], [ "d", 1, "_" ],
	[ "cd", 2, "_" ], [ "bc", 2, "_" ], [ "ab", 2, "_" ], 
	[ "bcd", 3, "_" ], [ "abc", 3, "_" ], myObjName,
	[ 5.7, 0, "_" ], [ "", 0, "_" ],
	[ "abcd", 4, "_" ], myObjName
]

? @@NL( StzListQ(aList).ItemsZ() )
#--> [
#	[ [ "a", 1, "_" ], [ 1, 4 ] ],
#	[ myobjname, [ 2, 13, 17 ] ],
#	[ [ "f", 1, "_" ], [ 3 ] ],
#	[ [ "b", 1, "_" ], [ 5 ] ],
#	[ [ "c", 1, "_" ], [ 6 ] ],
#	[ [ "d", 1, "_" ], [ 7 ] ],
#	[ [ "cd", 2, "_" ], [ 8 ] ],
#	[ [ "bc", 2, "_" ], [ 9 ] ],
#	[ [ "ab", 2, "_" ], [ 10 ] ],
#	[ [ "bcd", 3, "_" ], [ 11 ] ],
#	[ [ "abc", 3, "_" ], [ 12 ] ],
#	[ [ 5.70, 0, "_" ], [ 14 ] ],
#	[ [ "", 0, "_" ], [ 15 ] ],
#	[ [ "abcd", 4, "_" ], [ 16 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*==========

pr()

o1 = new stzListOfLists([
	[ 1 ],
	[ "one", "two" ],
	[ ]
])

o1.AddCol([ 2, "three", 0 ])
? @@NL( o1.Content() )
#--> [
#	[ 1, 2 ],
#	[ "one", "two", "three" ],
#	[ 0 ]
# ]

pf()
# Executed in 0.03 second(s)

/*----------

pr()

o1 = new stzListOfLists([
	[ 1 ],
	[ "one", "two" ],
	[ ]
])

o1.AddColXT([ 2, "three", 0 ])
? @@NL( o1.Content() )
#--> [[
	[ 1, 	 "", 	2 	],
	[ "one", "two", "three" ],
	[ "", 	 "", 	 0 	]
]

pf()
# Executed in 0.03 second(s)

/*----------

pr()

aList = [
	[ "a", 1, "_" ],
	[ "f", 1, "_" ], [ "a", 1, "_" ], [ "b", 1, "_" ], [ "c", 0 ], [ "d", 1, "_" ],
	[ "cd", 2, "_" ], [ "bc", 2, "_" ], [ "ab", 2 ], 
	[ "bcd", 3, "_" ], [ "abc", 3 ], 
	[ 5.7, 0, "_" ], [ "", 0, "_" ],
	[ "abcd", 4, "_" ]
]

? @@NL( @SortOn2(aList, 2) ) + NL
#--> [
#	[ "", 		0, 	'_'  	],
#	[ 5.70, 	0, 	"_"  	],
#	[ "c", 		0 		],
#
#	[ "a", 		1, 	"_"  	],
#	[ "a", 		1, 	"_"  	],
#	[ "b", 		1, 	"_"  	],
#	[ "d", 		1, 	"_"  	],
#	[ "f", 		1, 	"_"  	],
#
#	[ "ab", 	2 		],
#	[ "bc", 	2, 	"_"  	],
#	[ "cd", 	2, 	"_"  	],
#
#	[ "abc", 	3 		],
#	[ "bcd", 	3, 	"_"  	],
#
#	[ "abcd", 	4, 	"_"  	]
# ]

? @@NL( @sorton2(aList, 1) )
#--> [
#	[     "", 	0, "_" ],
#	[   5.70, 	0, "_" ],
#
#	[    "a", 	1, "_" ],
#	[    "a", 	1, "_" ],
#	[   "ab", 	2 ],
#	[  "abc", 	3 ],
#	[ "abcd",  	4, "_" ],
#
#	[    "b",  	1, "_" ],
#	[   "bc", 	2, "_" ],
#	[  "bcd", 	3, "_" ],
#
#	[    "c", 	0 ],
#	[   "cd", 	2, "_" ],
#
#	[    "d", 	1, "_" ],
#
#	[    "f", 	1, "_" ]
# ]
# Takes 0.02 second(s)

pf()
# Executed in 0.02 second(s)

/*------------

pr()

o1 = new stzList([ "f", "a", "b", "c", "d", "ab", "cd", "abc", "abcd", "bc", "bcd" ])
? o1.SortedBy(' Q(@item).NumberOfChars() ')
#--> [ 
#	a
#	b
#	c
#	d
#	f
#
#	ab
#	bc
#	cd
#
#	abc
#	bcd
#	abcd
# ]

pf()
# Executed in 0.04 second(s)

/*----------- #ring

pr()


? @@NL( ring_sort2([
	[ [ 2100, 3007 ], 2 ],
	[ [ 0, 150, 170 ], 1 ],
	[ [ 2, 8 ], 0 ],
	[ [ 10001 ], 3 ]
], 2) )

#--> [
#	[ [ 2, 8 ], 		0 ],
#	[ [ 0, 150, 170 ], 	1 ],
#	[ [ 2100, 3007 ], 	2 ],
#	[ [ 10001 ], 		3 ]
# ]

pf()
# Executed in 0.02 second(s)

/*------------

pr()

? @IsListOfPairsOfNumbers([ [ 1, 2 ], [ 8, 10 ], [ 16, 17 ], [ 23, 25 ] ])
#--> _TRUE_

pf()
# Executed in 0.02 second(s)

/*------------ #ring

pr()

? @@( ring_sort([]) )
#--> []

? @@( ring_sort2([], 3) )
#--> []

pf()
# Executed in 0.02 second(s)

/*------------

pr()

? @@( SortBy([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ], ' Q(@item).HowMany(0) ') )
#--> [
#	2,
#	8,
#	10001,
#	2100,
#	3007,
#	150,
#	170,
#	0
# ]

pf()
# Executed in 0.04 second(s)

/*------------

pr()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])

? @@( o1.SortedBy(' Q(@item).HowMany(0) ') )
#--> [
#	2,
#	8,
#	10001,
#	2100,
#	3007,
#	150,
#	170,
#	0
# ]

pf()
# Executed in 0.04 second(s)

/*------------

pr()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])

? @@( o1.SortedByDown( ' Q(@item).HowMany(0) ') )
#--> [ 10001, 3007, 2100, 170, 150, 0, 8, 2 ]

pf()
#--> Executed in 0.05 second(s)

/*------------

pr()

o1 = new stzList([ 1:3, "tunis", [], 1:2, "t", "" ])
? @@( o1.SortedBy(' Q(@item).Size() ') )

#--> [ "", [ ], 't', [ 1, 2 ], [ 1, 2, 3 ], 'tunis' ]

pf()
# Executed in 0.03 second(s)

/*---------------- #ring sort multi-list #narration #chatgpt

pr()

# The Ring sort() function can sort multi-lists (lists of lists)
# based on a specified column (using sort(aList, n)), subject to
# two conditions:

# Firstly, the column should only contain numbers and strings,
# as lists and objects cannot be sorted in Ring.

# Secondly, as a requirement set by Softanza at a higher level than Ring,
# the column must not contain any duplicated items (we will explain it).

# To comprehend the various aspects of this feature, let's start with a
# functional multi-list sample:

aList = [
	[ "emm", 3 ],
	[ 1:3, 1 ],
	[ ANullObject(), 2 ]
]

# We employ a Softanza function to check if the list is sortable by
# the standard Ring function sort(aList, nCol)

? IsRingSortable(aList)
#--> _TRUE_

# Hence, Ring will sort it correctly:

? @@NL( sort( aList, 2 ) )
#--> [
#	[ [ 1, 2, 3 ], 1 ],
#	[ @nullobject, 2 ],
#	[ "emm", 3 ]
# ]

# Now let's consider a multi-list example where sorting fails 
# (due to a column containing a data type other than numbers or strings):

aList = [
	[ "emm", 3 ],
	[ 1:3, 1:3 ], # Note that column 2 contains a list
	[ ANullObject(), 2 ]
]

# Softanza detects that the list cannot be directly sorted by the
# native sort() function in Ring

? IsRingSortable(aList)
#--> _FALSE_

# Consequently, attempting to sort it usng Ring sort() function
# triggers an error:

//? @@NL( sort( aList, 2 ) )
#--> Error message (Ring-side): Bad parameter type!

# Now, there's an important detail to be aware of...
# To illustrate this, let's consider the following list:

aList = [
	[ "b", 	 2 ],
	[ "a", 	 2 ],
	[ "abc", 3 ],
	[ "",    1 ],
	[ "c", 2 ]
]

# When sorting it based on the second column, we expect the
# following result:
#--> [
#	[ "",    1 ],
#	[ "a", 	 2 ],
#	[ "b", 	 2 ],
#	[ "c", 	 2 ],
#	[ "abc", 3 ]	
# ]

# However, when using Ring to sort it, we obtain:

? @@NL( sort(aList, 2) ) + NL
#--> [
#	[ "", 1 ],
#	[ "c", 2 ],
#	[ "b", 2 ],
#	[ "a", 2 ],
#	[ "abc", 3 ]
# ]

# As observed, the Ring sort() native function, designed for
# efficiency, sorts the multi-list based on the given column
# (2 in our case) without considering sorting the values of
# the first column accordingly!

# To address this at the Softanza level, we provide the
# SortOn() function, utilized as follows:

? @@NL( SortOn(aList, 2) ) + NL
#--> [
#	[ "", 1 ],
#	[ "a", 2 ],
#	[ "b", 2 ],
#	[ "c", 2 ],
#	[ "abc", 3 ]
# ]

# Internally, the Softanza SortOn() function verifies if
# the provided multi-list can be sorted by Ring in the
# first place; otherwise, it performs the necessary
# sorting itself!

# This is why IsRingSortableOn() has been implemented!
# It indicates that the current multi-list cannot be
# sorted (accurately) by Ring:

? IsRingSortableOn(aList, 2)
#--> _FALSE_

# Note that using IsRingSortable() without the On()
# suffix yields a different result:

? IsRingSortable(aList)
#--> _TRUE_

# This is because the first column comprises only
# strings without duplicates:
# [ '', "c", "b", "a", "abc" ]

# Thus, if you rely on the Ring sort() function,
# it will sort it accordingly:

? @@NL( sort(aList, 1) )
#--> [
#	[ "", 1 ],
#	[ "a", 2 ],
#	[ "abc", 3 ],
#	[ "b", 2 ],
#	[ "c", 2 ]
# ]

# It was quite lengthy, but I included the necessary
# details for future reference and for your understanding
# of another enhancement by Softanza. A summary!

# NOTE: The english of this narration has been enhanced by ChatGPT

pf()
# Executed in 0.04 second(s)

/*----------------

pr()

aList = [
	[ "a", 1 ],
	[ "ab", 2 ],
	[ "abc", 3 ],
	[ "abcd", 4 ],
	[ "b", 1 ],
	[ "bc", 2 ],
	[ "bcd", 3 ],
	[ "c", 1 ],
	[ "cd", 2 ],
	[ "d", 1 ]
]

? @@NL( SortOn(aList, 2) )
#--> [
#	[ "a", 1 ],
#	[ "b", 1 ],
#	[ "c", 1 ],
#	[ "d", 1 ],
#	[ "ab", 2 ],
#	[ "bc", 2 ],
#	[ "cd", 2 ],
#	[ "abc", 3 ],
#	[ "bcd", 3 ],
#	[ "abcd", 4 ]
# ]

pf()
# Executed in 0.03 second(s)

/*----------------

pr()

o1 = new stzString("abcd")
acSubStrings = o1.SubStrings()
//? @@( acSubStrings )
#--> [ "a", "ab", "abc", "abcd", "b", "bc", "bcd", "c", "cd", "d" ]

# If you want, you can sort them :

? sort(acSubStrings) # Ring standar function is used here
#--> [
#	"a",
#	"ab",
#	"abc",
#	"abcd",
#
#	"b",
#	"bc",
#	"bcd",
#
#	"c",
#	"cd",
#
#	"d"
# ]

# If you want to sort them by the number of chars :

? SortBy( acSubStrings, 'Q(@item).NumberOfChars()' ) # It's a Softanza function
#--> [
#	"a",
#	"b",
#	"c",
#	"d",
#
#	"ab",
#	"bc",
#	"cd",
#
#	"abc",
#	"bcd",
#
#	"abcd"
# ]

pf()
# Executed in 0.05 second(s)

/*================

pr()

o1 = new stzString( "ABCabcEFGijHI" )

? @@( o1.SubStringsW('Q(@SubString).IsUppercase()') ) + NL
#--> [
#	"A", "AB", "ABC", "B", "BC",
#	"C", "E", "EF", "EFG", "F",
#	"FG", "G", "H", "HI", "I"
# ]

? @@SP( o1.PartsUsing('Q(@char).CharCase()') ) + NL
#--> [
#	"ABC",
#	"abc",
#	"EFG",
#	"ij",
#	"HI"
# ]

? @@SP( o1.PartsUsingXT('Q(@char).CharCase()') )
#--> [
#	[ "ABC", "uppercase" ],
#	[ "abc", "lowercase" ],
#	[ "EFG", "uppercase" ],
#	[ "ij", "lowercase" ],
#	[ "HI", "uppercase" ]
# ]

pf()
#--> Executed in 0.70 second(s)

/*----------------

pr()

o1 = new stzString( "ABCabcEFGijHI" )
? o1.SplitAtSubStringWXT( 'Q(@SubString).IsLowercase()' )
#--> [ "ABC", "EFG", "HI" ]

pf()
#--> Executed in 0.59 second(s)

#NOTE
# This function was impossible to implement without implementing
# the MergeIncusive() in stzListOfPairs

#===========

pr()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.SectionCS( :From = "RING", :To = :LastChar, :CaseSensitive = _FALSE_ )
#--> Ring programming language

pf()
# Executed in 0.04 second(s)

/*-----------

pr()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.Section(:From = "Ring", :To = "language")
#--> Ring programming language

pf()
# Executed in 0.06 second(s)

/*----------- #narration

pr()

# Softanza makes programming in Ring even more expressive.

# To showcase this, let's consider how substr() function is used in Ring,
# and how Softanza offers it's way of making the same thing.

# In Ring, the substr() function does many things:
#	--> Finding a substring
#	--> Getting the substring starting at a given position
#	--> Getting the substring made of n given chars starting at a given position
#	--> Replacing a sbstring by an other substring (with or without casesensitivity)

# We are going to perform all these actions, using substr() and then Softanza,
# side by side, so you can make sense of the differences...

# Finding a substring

	cStr = "Welcome to the Ring programming language"
	? substr(cStr,"Ring")
	#--> 16

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.FindFirst("Ring")
	#--> 16

	# In Softanza, we can also return all the occurrences of cSubStr

	? oStr.Find("Ring") # or FindAll("Ring")
	#--> [ 16 ]

# Getting the substring starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr, "Ring") # gives 16
	? substr(cStr, nPos)
	#--> Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Section(:From = "Ring", :To = :LastChar) + NL # Or simply Section("Ring", :End)
	#--> Ring programming language

# Getting the substring made of n given chars starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr,"Ring") # Gives nPos = 16
	? substr(cStr, nPos, 4)
	#--> Ring

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Range("Ring", 4) + NL
	#--> Ring

# Replacing a sbstring by an other substring

	cStr = "Welcome to Python programming language"
	? substr(cStr, "Python", "Ring") # Replaces 'Python' with 'Ring'
	#--> Welcome to the Ring programming language

	# In Softanza we say:
	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content() + NL
	#--> Welcome to Ring programming language

# Replacing a sbstring by an other substring with Case Sensitivity

	cStr = "Welcome to the Python programming language"
	? substr(cStr,"PYTHON", "Ring", 0) #WARNING: This is should be 1 and not 0!
	#--> Welcome to the Python programming language
	
	cStr = "Welcome to the Python programming language"
	? substr(cStr, "PYTHON", "Ring", 1) #WARNING: This is should be 0 and not 1!
	#--> Welcome to the Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", :CaseSensitive = _FALSE_)
	? oStr.Content()
	#--> Welcome to Ring programming language

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", _TRUE_)
	? oStr.Content() + NL
	#--> Welcome to Python programming language

	# Or without specifying case sensitivty like this:

	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content()
	#--> Welcome to Ring programming language
	
pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.11 second(s) in Ring 1.17

/*--------- #perf

#NOTE
# Performance of stzString (using QString2 in background,
# and not QString ) is astonishing!

pr()

# Let's compose a large string

str = "1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

for i = 1 to 1_000_000
	str += "SomeStringHereAndThere"
next

# Takes 11.40 second(s) in Ring 1.20
# Executed in 13.31 second(s) in Ring 1.17

str += "|1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

# Overall, we have a string with more then 30 million chars
# ~> 30 to 40 books of 500 pages each

o1 = new stzString(str)
# The construction of the Softanza object takes 0.12 second(s)

? @@NL(o1.FindSubStringBoundedByZZ("1", "|"))
#--> [
# 	[ 5, 5 ],
# 	[ 32, 32 ],
#	[ 22000071, 22000071 ],
#	[ 22000075, 22000075 ],
# 	[ 22000102, 22000102 ]
# ]

#TODO // Try to compose the string by pushing the first part in the middle or a the end,
# and if stzString is still as performant!

pf()
# Executed in 11.29 second(s).

/*=======

pr()

? IsRingSortable("ring")
#--> _TRUE_

? IsRingSortable(1:3)
#--> _TRUE_

? IsRingSortable("A":"C")
#--> _TRUE_

? IsRingSortable([ "Q", "t", 6 ])
#--> _TRUE_

? IsRingSortable([ "A", 1:3 ])
#--> _FALSE_

aList = [
	[ "mahmoud", 15000],
	[ "ahmed", 14000 ],
	[ "samir", 16000 ] ,
	[ "mohammed", 12000 ],
	[ "ibrahim", 11000 ]
]
? IsRingSortable(aList)
#--> _TRUE_

aList = [
	[ "mahmoud", 	15000],
	[ "ahmed", 	14000 ],
	[ "samir", 	16000 ] ,
	[ "mohammed", 	12000 ],
	[ "ibrahim", 	[], 	11000 ]
]
? IsRingSortableOn(aList, 2)
#--> _FALSE_

aList = [
	[ "mahmoud", 15000],
	[ "ahmed", 14000 ],
	[ "samir", 16000 ] ,
	[" mohammed", 12000 ],
	"gary",
	[ "ibrahim" , 11000 ]
]
? IsRingSortable(aList)
#--> _FALSE_

pf()
# Executed in 0.03 second(s)

/*-------

pr()

aList = [
	[ "ali", 12 ],
	[ "jed", 10 ],
	[ "sam",  8 ]
]
? IsRingSortableOn(aList, 2)
#--> _TRUE_

aList = [
	"kim",
	[ "ali", 12 ],
	[ "jed", 10 ],
	[ "sam",  8 ]
]
? IsRingSortableOn(aList, 2)
#--> _FALSE_

aList = [
	[ "ali", 12 	],
	[ "jed", 10, 22 ],
	[ "sam",  8 	]
]
? IsRingSortableOn(aList, 2)
#--> _TRUE_

aList = [
	[ "ali", 12 	],
	[ "jed", 10, 22 ],
	[ "sam",  8 	]
]
? IsRingSortableOn(aList, 3) # column 2 should contain 3 items
#--> _FALSE_

pf()
# Executed in 0.02 second(s)

/*-------

pr()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

o1 = new stzListOfPairs(aList) # Or stzListOfLists() if you want

? @@NL( o1.Sorted() ) + NL
#--> [
#	[ "ahmed", 14000 ],
#	[ "ibrahim", 11000 ],
#	[ "mahmoud", 15000 ],
#	[ "mohammed", 12000 ],
#	[ "samir", 16000 ]
# ]

? @@NL( o1.SortedOn(2) )
#--> [
#	[ "ibrahim", 11000 ],
#	[ "mohammed", 12000 ],
#	[ "ahmed", 14000 ],
#	[ "mahmoud", 15000 ],
#	[ "samir", 16000 ]
# ]

pf()

#--> Executed in 0.04 second(s)

/*====== #todo check perf #update done!

pr()

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

o1 = new stzList(aList)
? o1.FindPrevious("*", :startingat = 1_900_008)
#--> 1900007

pf()
#--> Executed in 19.15 second(s)

/*====== #todo check perf #update done!

pr()

# Constructing the large list

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

? ElapsedTime()
#--> 0.92 second(s)

# Using the optimised @FindNthST() function (based on native Ring find())

? @FindNthST(aList, 3, "*", 1_000_000)
#--> 1900007

? @FindNext(aList, "*", 1_000_000)
#--> 1900002

? @@( @FindAll(aList, "*") )
#--> [ 1900002, 1900005, 1900007 ]

? ElpasedTime()
#--> 3.88 second(s)

# Creating the stzList object

o1 = new stzList(aList)
	
	? @@( o1.FindFirst("*") )
	#--> 1900002

	? o1.Findnext("*", :startingat = 1_000_000)
	#--> 1900002
	
	? o1.FindNextNthST(3, "*", 1_000_000)
	#--> 1900007

	? o1.FindAll("*")
	#--> [ 1900002, 1900005, 1900007 ]

pf()
#--> Executed in 10.60 second(s)

/*========== #perf

# Comparing two implementations of the concatenation of a large lists of strings:
# one with native Ring (list and += "") and one with Qt QStringList().join
# see the next 2 examples...

# NOTE: before Ring 1.19, the Ring-based implementation was faster, now the
# Qt-based one is faster.

# TODO: do the necessary to adopt it in all relevant places in the library.
# UpDATE done!

pr()

# Concatenating a large list of numbers and strings (1.9M items)
# takes about 10 seconds in Ring 1.19

# Preparing the large list to work on

	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 0.83 seconds in Ring 1.19
	# Took 1.20 seconds in Ring 1.17

	# Creating the stzList object

	o1 = new stzList(aList) # Takes 1.04 second(s)
	
	# Concatenating the items of the list
	
	aContent = aList
	nLen = len(aList)

	cSep = " "
	cResult = ""

	for i = 1 to nLen - 1
		cResult += aContent[i] + cSep
	next

pf()
# Executed in 10.78 second(s) in Ring 1.20
# Executed in 11.16 second(s) in Ring 1.19

/*-------------------- #perf

#NOTE
# Before Ring 1.19, adding large data inside a qstringlist() object was very slow.
# That's why I avoided it in concatenating lists of strings. In Ring 1.19, as we
# can see by running this example, this is done quicly.

#TODO
# Revist the places in Softanza where concatneation of list of strings is done
# and see if there will be performance gain by using QStringList().joint
#~> Look especially at Stringify() which is used in many finding algorithms!

#UPDATE done!

pr()

# Initializing the large list of strings

	o1 = new QStringList()
	for i = 1 to 1_900_000
		o1.append("sometext")
	next
	aList = [ "A", "*", "B", "C", "*", "D", "*", "E" ]
	nLen = len(aList)
	for i = 1 to nLen
		o1.append(aList[i])
	next
	
	# Takes 4.09 seconds in Ring 1.19
	# Took 11.87 seconds in Ring 1.17

# Concatenating the strings in one string

	str = o1.join("") # Take 0.32 seconds!

	//? ShowShortXT(str, 8)
pf()
# Executed in 4.07 second(s) 

/*--------- #perf

pr()

	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzListOfStrings(aList)

	str = o1.Concatenate()

	# To show a part of the large concatenated string
	# ? ShowShortXT(str, 7)

pf()
# Executed in 9.92 second(s)

/*--------- #perf

pr()

	aList = []
	for i = 1 to 1_900_000
		aList + i
	next
	for i = 1 to 400
		aList + 1:3
	next

	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzList(aList)
	o1.Stringify()

pf()
# Executed in 8.81 second(s)

/*--------- #perf

pr()

	aList = []
	for i = 1 to 1_900_000
		aList + i
	next
	for i = 1 to 400
		aList + 1:3
	next

	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzList(aList)
	o1.ToCode()

pf()
# Executed in 9.28 second(s)

/*======

pr()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
? @@( o1.FindXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ 6, 14 ]

? @@( o1.FindXT( "*", :BoundedBy = [ "<<", ">>" ]) )
#--> [ 6, 14 ]

pf()
# Executed in 0.06 second(s).

/*----------

pr()

o1 = new stzString('..."*"..."*"...')
? o1.FindXT( "*", :BoundedBy = '"' )
#--> [ 5, 11 ]

pf()
# Executed in 0.05 second(s)

/*----------

pr()

o1 = new stzString('..."*"..."*"...')

? o1.FindXT( "*", :InSection = [4 , 14 ] )
#--> [ 5, 11 ]

? o1.FindInSection("*", 4, 14)
#--> [ 5, 11 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString("~*~~*--*-")

? o1.FindBefore("*", "--")
#--> [ 2, 5 ]

? o1.FindXT("*", :Before = "--")
#--> [ 2, 5 ]

? o1.FindAfter("*", "~")
#--> [ 5, 8 ]

? o1.FindXT("*", :After = "~")
#--> [ 5, 8 ]

? o1.FindInSection("*", 2, :lastchar)
#--> [ 2, 5, 8 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString("~*~~*--")
? o1.FindXT( "*", :BeforePosition = 6)
#--> [ 2, 5 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString("~--*~~*~~")

? o1.FindXT( "*", :After = "--")
#--> [ 4, 7 ]

? o1.FindXT( "*", :AfterPosition = 3)
#--> [ 4, 7 ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzList([ "~", "*", "~", "~", "*", "--", "*", "-" ])

? o1.FindBefore("*", "--")
#--> [ 2, 5 ]

? o1.FindXT("*", :Before = "--")
#--> [ 2, 5 ]

? o1.FindAfter("*", "~")
#--> [ 5, 7 ]

? o1.FindXT("*", :After = "~")
#--> [ 5, 7 ]

? o1.FindInSection("*", 2, :LastItem)
#--> [ 2, 5, 7 ]

pf()
# Executed in 0.02 second(s)

/*======

pr()

#                   1    6   0 2  15     22
o1 = new stzString("♥....♥...YOU..♥......♥")

? o1.FindNearestToPosition("♥", 10)
#--> 6

? o1.FindNearestToPositionXT("♥", 10)
#--> [ 6, 15 ]

? o1.FindNearestToSection("♥", 10, 12)
#--> 15

? o1.FindNearestToSectionXT("♥", 10, 12)
#--> [ 6, 15 ]

pf()
# Executed in 0.02 second(s)

/*---------

pr()

#                   1    6   0 2  15    21  25
o1 = new stzString("♥....♥...YOU..♥.....YOU.♥")

? o1.FindNearestToSections("♥", [ [ 10, 12 ], [ 21, 23 ] ])
#--> 25

pf()
# Executed in 0.02 second(s)

/*---------

pr()

#                   1    6   0 2  15    21  25
o1 = new stzString("♥....♥...YOU..♥.....YOU.♥")

? o1.FindNearest("♥", :To = 17 )
#--> 15

? o1.FindNearest("♥", :ToPosition = 17 )
#--> 15

? o1.FindNearest("♥", :To = [10, 12] )
#--> 15

? o1.FindNearest("♥", :ToSection = [10, 12] )
#--> 15

? o1.FindNearest("♥", :To = [ [ 10, 12 ], [ 21, 23 ] ] )
#--> 25

? o1.FindNearest("♥", :ToSections = [ [ 10, 12 ], [ 21, 23 ] ] )
#--> 25

? o1.FindNearest("♥", :To = "YOU")
#--> 25

? o1.FindNearest("♥", :ToSubString = "YOU")
#--> 25

pf()
# Executed in 0.08 second(s)

/*---------

pr()
#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestZZ("♥♥♥", :To = 14 )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :ToPosition = 14 )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :To = [14, 16] )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :ToSection = [14, 16] )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :To = [ [ 14, 16 ], [ 27, 29 ] ] )
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :ToSections = [ [ 14, 16 ], [ 27, 29 ] ] )
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :To = "YOU")
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :ToSubString = "YOU")
#--> [ 31, 33 ]

pf()
# Executed in 0.08 second(s)

/*---------

pr()

#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestToSubString("♥♥♥", "YOU")
#--> 31

? o1.FindNearestToSubStringZZ("♥♥♥", "YOU")
#--> [ 31, 33 ]

pf()
# Executed in 0.04 second(s)

#=========

pr()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])

? o1.FindNearestToPosition("♥", 8)
#--> 10

? o1.FindNearestToPositionXT("♥", 8)
#--> [ 5, 10 ]

? o1.FindNearestToSection("♥", 8, 10)
#--> 10

? o1.FindNearestToSectionXT("♥", 5, 10)
#--> [ 6, 15 ]

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearestToSections("♥", [ [ 4, 7 ], [ 10, 12 ] ])
#--> 10

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearestToPosition("♥", 7)
#--> 5

? o1.FindNearestToPositions("♥", [ 3, 13 ])
#--> 14

? o1.FindNearestToItem("♥", "YOU")
#--> 10

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearest("♥", :To = "YOU" )
#--> 10

? o1.FindNearest("♥", :ToItem = "YOU" )
#--> 10

? o1.FindNearest("♥", :ToPosition = 7 )
#--> 5

? o1.FindNearest("♥", :ToPositions = [7, 11] )
#--> 10

? o1.FindNearest("♥", :ToSection = [7, 10] )
#--> 10

? o1.FindNearest("♥", :ToSections =  [ [ 4, 7 ], [ 9, 12 ] ] )
#--> 14

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzList([
	"♥", ".", ".", "ME", "♥", ".", ".", "YOU", ".", "♥" ,".", "ME", ".", "♥"
])

? o1.FindNearest("♥", :ToItems = [ "YOU", "ME" ])
#--> 5

pf()

/*---------

pr()

#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestToSubString("♥♥♥", "YOU")
#--> 31

? o1.FindNearestToSubStringZZ("♥♥♥", "YOU")
#--> [ 31, 33 ]

pf()
# Executed in 0.03 second(s)

/*----

pr()

o1 = new stzString("...*...*...*...")
? o1.FindXT( "*", :InSection = [5, 10] )
#--> 8

pf()
# Executed in 0.02 second(s)

/*-----------

pr()

o1 = new stzString("...<<*>>...<<*>>...<<*>>...")

? o1.FindXT( "*", :Between = ["<<", ">>"] )
#--> [ 6, 4, 22 ]

? o1.FindXT( "*", :BoundedBy = ["<<", ">>"] )
#--> [ 6, 4, 22 ]

pf()
# Executed in 0.05 second(s).

/*======== #TODO/FUTURE: add the :3rd syntax to these functions

pr()

o1 = new stzString("...<<*>>...<<*>>...<<*>>...")

? o1.FindXT( :3rd = "*", :Between = [ "<<", ">>" ])

# ? o1.FindXT( :3rd = "*", :BoundedBy = '"' ])

# ? o1.FindXT( :3rd = "*", :InSection = [5, 24] ])

# ? o1.FindXT( :3rd = "*", :Before = '!' ])

# ? o1.FindXT( :3rd = "*", :BeforePosition = 12 ])

# ? o1.FindXT( :3rd = "*", :After = '!' ])

# ? o1.FindXT( :3rd = "*", :AfterPosition = 12 ])

pf()
