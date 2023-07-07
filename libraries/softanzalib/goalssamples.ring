load "stzlib.ring"

#------------------------------#
#   Goal 1 : EXPRESSIVENESS    #
#------------------------------#

	#-- Feature 1: Fluent Design
	/*
		# Suppose I need to solve this: Uppercasing and then spacifying
		# the word "softanza", so we get "S O F T A N Z A".
	
		# In Programmer thinking, I’ll solve it by undertaking these steps:
		# 	1. I take "softanza" string as input
		# 	2. I turn it to uppercase
		# 	3. I get the list of chars out of it
		# 	4. I concatenate those chars using " "
	
		# In S♥ftanza code, it's actually one line of code!
	
		? StzStringQ("softanza").
			UppercaseQ().
			CharsQR(:stzListOfStrings).
			ConcatenatedUsing(" ")


	#-- Feature 2: Semantic Precision

		# In everyday language, it’s straighforward to underline the difference
		# between wether a list of things contains ALL the things of another
		# list, or just SOME of them!
	
		# And so it is in S♥ftanza!
	
		MyAfricanNations = [ "Tunisia", "Egypt", "Niger", "Togo", "Ghana" ]
		
		? Q("Niger").IsOneOf(MyAfricanNations)			  #--> TRUE
		? Q("France").IsOneOf(MyAfricanNations)			  #--> FALSE
		
		? Q(MyAfricanNations).Contains("Egypt")			  #--> TRUE
		? Q(MyAfricanNations).ContainsBoth("Egypt", "Tunisia")	  #--> TRUE
		
		NorthAfricanNations = [
		   "Egypt", "Libya", "Tunisia", "Algeria", "Morroco", "Mauritania" ]
		
		? Q(MyAfricanNations).ContainsAll(NorthAfricanNations)	  #--> FALSE
		? Q(MyAfricanNations).ContainsSome(NorthAfricanNations)	  #--> TRUE
		? Q(MyAfricanNations).ContainsN(2, NorthAfricanNations)	  #--> TRUE

	#-- Feature 3: Named Params

		o1 = new stzString("I love Ring!")	
		o1.Replace("love", "♥")

		? o1.Content() #--> I ♥ Ring!

		o1 = new stzString("I love Ring!")
		o1.Replace("love", :with = "♥")

		? o1.Content() #--> I ♥ Ring!

		#--

		o1 = new stzString("love I love Ring! love")
		o1.ReplaceNextOccurrence("love", 5, "♥")

		? o1.Content() #--> love I ♥ Ring! love

		o1 = new stzString("love I love Ring! love")

		o1.ReplaceNextOccurrence(
			:Of = "love",
			:StartingAt = 5,
			:With = "♥"
		)

		? o1.Content() #--> love I ♥ Ring! love

	#-- Feature 4: Named Params

		# In Softanza, we can remove leading chars from a string like this:
		? Q("aaaaaaI ♥ Ring!").LeadingCharsRemoved() #--> "I ♥ Ring!"
	
		# And trailing chars like this:
		? Q("I ♥ Ring!bbbbbb").TrailingCharsRemoved() #--> "I ♥ Ring!"
	
		# And both leading and trailing chars like this:
		? Q("aaaaaI ♥ Ring!bbbbbb").LeadingAndTrailingCharsRemoved() #--> "I ♥ Ring!"
	
		# If you forget and put Trailing before leading, it will also work:
		? Q("aaaaaI ♥ Ring!bbbbbb").TrailingAndLeadingCharsRemoved() #--> "I ♥ Ring!"
	
		# Or better then this, you can simply say:
		? Q("aaaaaI ♥ Ring!bbbbbb").RepeatedCharsRemoved() #--> "I ♥ Ring!"
	
	#-- Feature 5: Mutlilanigual forms (TODO)

		# You can talk to Softanza in any language, and use many
		# languages in the same code:

		StzStringQ("SOFTANZA") {
			# Get the first char in english code
			? FirstChar() 	 #--> "S"

			# Get the last char in french

			? DernierCaractère() #--> "A"

			# Get the last char in arabic code
			? الحرف_الأخير() #--> "َA"
			# English form: LastChar()

			# Get the number of chars in chineese code
			? 字符数()	#--> 8
			# English form: NumberOfChars()
		}

#---------------------------#
#   Goal 2 : FLEXIBILITY    #
#---------------------------#

	#-- Feature 1: Function Suffixes

		# The most used suffix in Softanza is CS() suffix for string Case Sensitivity:
		Q("ring php RING ruby Ring") {
			? NumberOfOccurrence(:Of = "ring") 		  #--> Gives 1, but...
			? NumberOfOccurrenceCS(:Of = "ring", :CS = FALSE) #--> Gives 3!
		}

		# An other use case of suffixes is when you create a box around a string:
		? Q("CAIRO").Boxed()
		#    ┌───────┐
		#--> │ CAIRO │
		#    └───────┘

		# And want to configure the box appearance, so you use the XT suffix like this:
		? Q("CAIRO").BoxedXT([ :AllCorners = :Round, :EachChar = TRUE ])
		#    ╭───┬───┬───┬───┬───╮
		#--> │ C │ A │ I │ R │ O │
		#    ╰───┴───┴───┴───┴───╯

	#-- Feature 2: Function Prefixes

		# In Softanza, this returns the positions of a char inside a string:

		? Q("RINGORIALAND").FindAll("I")
		#--> [2, 7]

		# If you want to see those positions visually, use the "viz" prefix:

		? Q("RINGORIALAND").vizFindAll("I")
		#--> RINGORIALAND
		#    -^----^-----

		# Feature 3: Function FreeForm
/*
		# In Softanza, you can get a section from a string like this:
		? Q("I love Ring").Section(8, 11) 			#--> "Ring"
		# Or, more expressively, using named params:
		? Q("I love Ring").Section(:From = 8, :To = 11) 	#--> "Ring"

		# But what if you forgot the params, or don't know them? Use the FF FreeForm:
		? Q("I love Ring").SectionFF([]) 			#--> "I love Ring"
		# Softanza returns, by default, all the string, from 1 to 11, as a section!

		# And if you want to specify only one param and leave the other as a default:
		? Q("I love Ring").SectionFF([ :From = 8 ]) 		#--> "Ring"
		# Or when you invert the params order altogether:
		? Q("I love Ring").SectionFF([ :To = 11, :From = 8 ]) 	#--> "Ring"

		#--

		# Let's define the following Softanza string:
		o1 = new stzString("ring php ring ruby ring")

		# In its normal form, the following function requires 3 params:
		o1.ReplaceNextOccurrence(:Of = "ring", :StartingAt = 1, :With = "♥")
		? Content() #--> ♥ php ring ruby ring

		# In Softanza, due to an FF suffix you add to the function, you
		# can provide only two params and still get the same result:
		o1.ReplaceNextOccurrenceFF([ "ring", :With = "♥" ]) #--> By default :StartingAt = 1
	
		# Or you can provide params in any order comes first to your head
		# and also get the same result:
		o1.ReplaceNextOccurrenceFF([ :Of = "ring", :With = "♥", :StartingAt = 1 ])

		# Or provide no params at all and let Softanza infere same result for you:  
		o1.ReplaceNextOccurrenceFF([]) #--> ♥ php ring ruby ring
		# Here, Softanza takes the first substring it sees in the string ("ring" in
		# our case) as a default value for the :Of = "..." param!

		
	# Feature 4: Function DefaultForm
/*
		# In Softanza, if you want to use a function with its default values,
		# you can use the FF suffix with [] (feature 3) or use "dft" prefix like this:
	
		? Q("I love Ring").dftRange() #--> "I love Ring"

		# If you want to get an information about the params and their default values,
		# then you can use the "inf" prefix like this:

		? Q("I love Ring").infRange()
		#--> [ [ :Param = "pnStart", :Name = "from", :Type = "NUMBER", :Default = 1 ],
		#      [ :Param = "pnRange", :Name = "to",   :Type = "NUMBER", :Default = 11 ] ]

	# Feature 5: Params Free Order

		# In Softanza, when a function contains two params of different types,
		# you can enter these params in any order:

		Q("ring php ring python ring") {
			# You can put the number of occurrence before th substring
			? FindNthOccurrence(2, "ring") #--> 10

			# Or the substring before the number of occurrence
			? FindNthOccurrence("ring", 2) #--> 10
		}

		# And still get the same result.

#------------------------#
#  Goal 3: RELIABILITY   #
#------------------------#

	# Feature 1: Augmentation of Basic Ring Types

		# Ring Standard Library offers a set of functions and classes that extend the basic
		# Ring types, and that you should opt for in all your simple to medium programs:
		o1 = new String("SOFTANZA")
		? o1.left(3).println()	#--> SOF
	
		# In case of multiligual or multinational programs, then Softanza is the way to go.
		# In fact, using the code above with an arabic text gives an unexpected result:
		o1 = new String("صوفطانزا")
		? o1.left(3).println()	#--> ص�
	
		# When you use Softanza, which is UNICODE-aware, you are covered: 
		? Q("صوفطانزا").NFirstChars(3)	#--> صوف
		
		# [ 


	# Feature 2: New functions across 9 domains


	# Feature 3: On-The-Shelf Advanced Functions

		# If you ever tried to develop a text processer, then you know it is a heavy task.
		# In particular, replacing portions of text, raises some complex cases you should
		# take care of.

		#-- 1. REPLACING ALL OCCURRENCES OF A SUBSTRING

		o1 = new stzListOfStrings([ "heart ipsum heart", "lorem heart", "heart" ])
		o1.ReplaceSubString("heart", :With = "♥")
	
		? o1.Content() #--> [ "♥ ipsum", "lorem ♥", "♥" ]

		#-- CASE OF DYNAMIC VALUE

		IconOf = [ :Heart = "♥" ]

		o1 = new stzListOfStrings([ "heart ipsum", "lorem heart", "heart" ])
		o1.ReplaceSubString("heart", :With@ = 'IconOf[@SubString]')
		
		? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]
/*

		#-- 2. REPLACING SUBSTRING BY MANY SUBSTRINGS

		o1 = new stzListOfStrings(["heart ipsum heart", "lorem heart ipsum heart lorem heart", "heart"])
		o1.ReplaceSubStringByMany("heart", :With = L('{ "♥1" : "♥6" }'))
		? o1.Content() #--> [ "♥1 ipsum ♥2", "lorem ♥3 ipsum ♥4 lorem ♥5", "♥6" ]

		#-- 3 SAME AS ABOVE BUT EXTENDED: ENUMARATION RESTARTS AT 1 AFTER REACHING 3
		o1 = new stzListOfStrings(["heart ipsum heart", "lorem heart ipsum heart lorem heart", "heart"])
		o1.ReplaceSubStringByManyXT("heart", :With = L('{ "♥1" : "♥3" }'))
		? o1.Content() #--> [ "♥1 ipsum ♥2", "lorem ♥3 ipsum ♥1 lorem ♥2", "♥3" ] 

		#-- 4. REPLACING MANY SUBSTRINGS BY A GIVEN VALUE

		o1 = new stzListOfStrings([ "one ipsum two", "lorem one ipsum three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With = "♥" )

		? @@( o1.Content() ) #--> [ "♥ ipsum ♥", "lorem ♥ ipsum ♥", "♥" ]

		#--> Todo: Dynamic Value

		Numbers = [ "1", "2", "3"]

		o1 = new stzListOfStrings([ "one ipsum two", "lorem one ipsum three", "three" ])
		o1.ReplaceManySubStrings([ "one", "two", "three" ], :With@ = 'Numbers[@i]' )

		? @@( o1.Content() ) #--> [ "1 ipsum 2", "lorem 1 ipsum 3", "3" ]


	# Feature 4: Large support of UNICODE
/*
*/
		? UnicodeToChar(65021) #--> ﷽
		? Unicode("ↈ") #--> 8584
	
		StzCharQ(12500) { ? Content() + " : " + Name() } #--> ピ : KATAKANA LETTER PI
	
		? StzCharQ("س").Name() #--> "ARABIC LETTER SEEN"
		? StzCharQ("ARABIC LETTER SEEN").Content() #--> "س"
		
		? Q("⛅⛱☕").CharsNames()
		#--> [ "SUN BEHIND CLOUD", "UMBRELLA ON GROUND", "HOT BEVERAGE" ]
	
		? StzCharQ(" ").CharType() #--> separator_space
	
		? StzCharQ("Ŵ").DiacriticRemoved() #--> W
		? StzCharQ("ſ").DiacriticRemoved() #--> s
	
		? "LIFE"
		? @("LIFE").Inverted() #--> ƎℲI⅂

	# Feature 5: Large Support of ISO Locales

		# Your customer
		StzLocaleQ([ :Country = :Iran ]) {
			? Abbreviation()			 #--> fa_IR
			? NthDayOfWeek(1)			 #--> saturday
			? NativeNthDayOfWeek(1) + NL		 #--> شنبه
		
			? NthDayOfWeekAbbreviation(1)		 #--> Sat
			? NativeNthDayOfWeekAbbreviation(1) + NL #--> دوشنبه
		
			? NthDayOfWeekSymbol(1)			 #--> S
			? NativeNthDayOfWeekSymbol(1)		 #--> د
		}

#-------------------------------#
#  Design Goal 4: CONSISTENCY   #
#-------------------------------#

	#-- 1. Consistency With Ring Type System
/*
	Softanza is designed to be consistent with the Ring type system. In fact, the
	library provides four advanced types that extend the four main types of Ring:
	stzNumber, stzString, stzList, and stzObject.

	The following are some samples of advanced cases in using them: 
*/
	? StzStringQ("Hello أهلا 你好").UniqueParts(:Using = 'StzCharQ(@char).Script()')
	#--> [ "Hello" = :Latin, " " = :Common, "أهلا" = :Arabic, "你好" = :Han ]

	StzNumberQ(715) { ? Units()   ? Dozens()   ? Hundreds() }
	 	          #--> 5      #--> 1       #--> 7

	StzListQ([ "A", 1:3, "B", 1:3, "C", 1:3 ]).FindAll( 1:3 ) #--> [2, 4, 6]
	# Note that, in pure Ring, the find() function can't find the position of
	# a list like Softanza does in the example above.

	#-- 2. Consistent Experience Over RingQt
/*
	QStringList class, from RingQt, provides fast index-based access to a list
	of strings,  as well as fast insertions and removals. Passing a list of
	strings as value parameters is both fast and safe (from Qt documentation).

	To create a QStringList in RinQt, you need to create the object and then
	loop over it to populate it with list of strings, like this:

*/		oQStrList = new QStringList()	
		for str in [ "Ring", "Python", "Ruby" ]
			oQStrList.append(str)	
		next

/*	To get the content of the QStringList object, you need to loop over it,
	and read each string it contains using the at() method, and add it to a
	Ring list that hosts the result:
*/
		acContent = []
		for i = 0 to oQStrList.size() - 1
			acContent + oQStrList.at(i)	
		next
		return acContent #--> [ "Ring", "Python", "Ruby" ]

/*	In Softanza, all what you need to do, is the same thing you shoud do with
	any list in Softanza, being a stzListOfStrings, a stzListOfNumbers, or
	even a stzListOfLists.

	Hence, you solve it in two simple steps:

		# First, you create the list of strings

*/		o1 = new stzListOfStrings([
			 "Ring", "Python", "Ruby" ])

		# Second, you read its content:
		? o1.Content() #--> [ "Ring", "Python", "Ruby" ]

/*	And you can do it in one instruction like this:
*/		? StzListOfStrings([ "Ring", "Python", "Ruby" ]).Content()		

	#-- 3. Consistent Experience Over SoftanzaLib

/*
	In programming, polymorphism is the provision of a single interface to entities of
	different types or the use of a single symbol to represent multiple different
	types (Wikipedia).

	In Softanza, you can take the same functions you write for stzString, and use it as-is,
	with few adaptations, with stzList or stzListOfStrings: polymorphism, made simple!

*/	? StzStringQ("HELLO").Size() # and
	? StzListQ([ "H", "E", "L", "L", "O" ]).Size() # both return 5

	? StzStringQ("hello").FindAllCS("L", :CaseSensitive = FALSE) # and
	? StzListOfStringsQ([ "h", "e", "l", "l", "o" ]).FindAllCS("L", :CaseSensitive = FALSE)
	# both return [3, 4 ]

	? StzStringQ("hello").Uppercased() #--> returns the uppercased string "HELLO"
	? StzListOfStringsQ([ "h", "e", "l", "l", "o"]).Uppercased()
	#--> returns the uppercased list of strings [ "H", "E", "L", "L", "O" ]

	? Q("").IsEmpty() 

	# and

	? Q([]).IsEmpty()	

	# both return TRUE

	#-- 4. Semantic Consistency in Softanza Vocaulary
/*
	In Softanza you can use the keyword "Item" with any enumerable type:
*/	? StzListQ([ "A", "B", "C" ]).NumberOfItems() #--> 3
	? StzStringQ("ABC").NumberOfItems() #--> 3

/*	Well, it's more prcise to use the "Char" keyword specifically for stzString:
*/	? StzStringQ("ABC").NumberOfChars() # because the item of a string is actually a char!

/*	But, in some situations, the generality of the keyword "Item" allows more flexibility.
	To show that, let's consider using Q() that inferes type from value, and elevates
	the value to an object, so we can work on it:
*/	? Q("ABC").NumberOfChars() #--> 3
	? Q(["A", "B", "C"]).NumberOfItems() #--> 3

/*	Now, when we have the value in a variable that we don't necessarily know in advance,
	whether it contains a string or a list, then it's better to use "item" form like this:
*/	value = "ABC" # or
	value = ["A", "B", "C"]
	? Q(value).NumberOfItems() #--> 3

#------------------------------------------#
#  Design Goal 5: HUMAN-CENTRIC METAPHORS  #
#------------------------------------------#

	#-- 1. Walker Metahor

/*		A Walker walks on a list, in a given direction, from start to end position, in a given
		number of steps, and then returns either the walked positions or the walked items:
*/		o1 = new stzList([ :Water, :Cofee, :Sugar, :Tea, :Milk, :Honey ])
		? o1.WalkFF([ :StartingAt = 3 ]) #--> [ 3, 4, 5, 6 ]
		? o1.WalkFF([ :StartingAt = 3, :Direction = :Backward ]) #--> [ 3, 2, 1 ]
		? o1.WalkFF([ :Step = 2, :Return = :WalkedItems ]) #--> [ :Water, :Sugar, :Milk ]
		? o1.WalkFF([ :Step = 2, :Return = :LastPosition ]) #--> 5

/*		Also, a Walker can walk on a list until a condition on the walked item is verified:
*/		? o1.WalkUntil('@item = :Milk') #--> [ 1, 2, 3, 4, 5 ]
/*		Or while a condition on the walked item is verified:
*/		? o1.WalkWhile('len(@item) = 5') #--> [ 1, 2, 3 ]
		? o1.WalkWhileXT('len(@item)=5', [:Return = :WalkedItems]) #--> [:Water, :Cofee, :Sugar]
/*		Or for each item a condition is verified:
*/		? o1.WalkEach('len(@item) = 5') #--> [ 1, 2, 3, 6 ]

/*		Many Walkers can be defined on the same list, and Walkers can be passed by their
		names to other functions via the named param :UsingWalker:
*/		o2 = new stzList( '♥1 : ♥9' )
		o2.AddWalkerFF( :Name = :Accelerator, :Step@ = '@Step++' )
		? o2.ItemsAtPositionsXT( :UsingWalker = :Accelerator ) #--> [ "♥1", "♥2", "♥4", "♥7" ]

	#-- 2. Checker Metaphor

/*		A Checker walks on a list, evaluates a given expression on each item, and tells
		us wether each evaluation leads to TRUE or FALSE:
*/		o1 = new stzList([ :Water, :Cofee, :Sugar, :Tea, :Milk, :Honey ])
		? o1.Check( :That = 'len(@item) = 5' ) #--> [ 1, 1, 1, 0, 0, 1 ]

/*		A Checker can be used in collaboration with a Walker. Here, we walk on the positions
		of all items made of 5 chars:
*/		o1.AddWalkerFF([ :Name = :WalkerFive, :ForEach = 'len(@item) = 5' ])
		#--> returns internally [ 1, 2, 3, 6 ]
/*		Then we use the Walker named :WalkerFive and check it against a given expression
		(wether the walked items contain the letter "o" or not):
*/		? o1.CheckXT( :That = 'Q(@item).Contains("o")', [ :UsingWalker = :WalkerFive ])
/*		#--> [ 0, 1, 0, 1 ]. In fact, :Water conains no "o", :Cofee contains an "o",
		:Sugar contains no "o", and also :Honey contains an "o"!
	
		Checker can carry on the values of TRUE and FALSE using an AND or OR operator:
*/		o1.CheckXT( :That = 'Q(@item).Contains("o")', [ :CarryUsing = :AND ] ) #--> Leads
/*		internally to { FALSE AND TRUE AND FALSE AND TRUE } --> FALSE.
		Moreover, nothing prevents us from defining any combination of :AND and :OR sutch as:
*/		o1.CheckXT( :That = 'Q(@item).Contains("o")', [ :UsingWalker = :WalkerFive,
			    :CarryUsing@ = '(@1 OR @2) AND (@3 OR @4)' ] )
		#--> Leads internally to { (FALSE OR TRUE) AND ( FALSE OR TRUE ) } --> TRUE
	
	#-- 3. Yielder Metaphor
/*
		Yielder walks on a list, applies an expression on each item, and returns its result:

*/		o1 = new stzList([ :Water, :Cofee, :Sugar, :Tea, :Milk, :Honey ])
		? o1.Yield( 'len(@item)' ) #--> [ 5, 5, 5, 3, 4, 5 ]
		? o1.Yield( '[ @item, len(@item) ]' )
		#--> [:Water = 5, :Cofee = 5, :Sugar = 5, :Tea = 3, :Milk = 4, :Honey = 5 ]
		
/*		Yielding data from a substet of items is possible in collaboration with a Walker:
	
*/		Liquids = [ :Water, :Cofee, :Tea ]
		o1.AddWalkerFF([ :Name = :WalkerLiquid, :ForEach = 'Q(@item).IsOneOfThese(:Liquids)' ])
		#--> Gives internally [1, 2, 4]
		? o1.YieldXT( 'T(@item).NumberOfVoyalsXT()', [ :UsingWalker = :WalkerLiquid ])
		#--> [ :Water = 2, :Cofee = 3, :Tea = 2 ]
	
/*		Finally, a Yielder can carry on its yielding operation from item to item by applying
		a given yielding expression like this one that accumulates the yieled values above:
	
	*/	? o1.YieldXT( 'T(@item).NumberOfVoyals()', [ :UsingWalker = :WalkerLiquid,
			      :CarryUsing@ = '@YieldedValue + @PreviousYieldedValue' ] #--> [ 2, 5, 7 ]
	
	#-- 4. Performer Metaphor

/*		Performer walks on a list and performs a given action on each item, like this:
*/		o1 = new stzList([ "water", "cofee", "sugar", "tea", "milk" ])
		o1.Perform( '@item = upper(@item)' )
		? o1.Content() #--> [ "WATER", "COFEE", "SUGAR", "TEA", "MILK" ])

/*		Or like this:
*/		o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])
		o1.Perform('{ @string = Q(@string).SubStringRemoved(".txt") }')
		? o1.Content() #--> [ "village", "town", "country" ]

/*		Or like this:
*/		TypeOf = [ :Ring = "programming language", :Softanza = "Ring library",
			   :Qt = "C++ framework" ]

		o1 = new stzList([ :Ring, :Softanza, :Qt ])
		o1.Perform('@item += " is a " + TypeOf[@item]')
		? o1.Content()
		#--> [ "Ring is a programming language", "Softanza is a Ring library",
			  "Qt is a C++ framework" ]

/*		In addition to other features like using walkers, conditional code, and	
		carrying on values from item to other (see samples in Yielder Metaphor).

#-----------------------------------#
#   Goal 6: Practical Innovations   #
#-----------------------------------#

	#-- 1. Conditional Functions
	
/*		Many functions in Softanza have an extended form suffixed by ...W()
		and using the named param :Where = '{...}' like this:
*/		o1 = new stzString("SooooOFTAaaaaNZA!")
		? o1.FindW( :Where = '{ Q(@char).IsUppercase() }')
		#--> [ 1, 6, 7, 8, 13, 14, 15 ]

/*		Or like this:
*/		o1.RemoveW( :Where = '{ Q(@char).IsOneOfThese(["o", "a"]) }')
		? o1.Content() #--> SOFTANZA!

/*		Or like this:
*/		o1.ReplaceW( '{ @char = "o" or @char = "a"', :With@ = 'Q(@char).Uppercased() }' )
		? o1.Content() #--> SOOOOOFTAAAAANZA!
	
	#-- 2. Visual Orientation

/*		In the future, every Softanza function will be provided with a ready-to-use
		RingQt window for manipulating its params, interactively, and including it
		to your programs. Still, some visually-oriented features already exist:
*/		? Q("CAIRO").vizFindXT("I", [:Boxed = TRUE, :Rounded = TRUE, :VisualSign = "♥"])
			#    ╭───┬───┬───┬───┬───╮
			#--> │ C │ A │ I │ R │ O │
			#    ╰───┴───┴─♥─┴───┴───╯
	
/*		Also, some classes contain the function Show() to visualize their content:
*/		StzGridQ( [ 5, 5 ] ) { 	
			SetNode(1, 1, :With = "1") SetNode(5, 1, :With = "2")
			SetNode(5, 5, :With = "3") SetNode(1, 5, :With = "4")
			ShowFF([ :CenterChar = "♥", :ShowCenter = TRUE ]) }
			# 	1 . . . 2
			# 	. . . . .
			#-->	. . ♥ . .
			# 	. . . . .
			# 	4 . . . 3 

	#-- 3. Constraint Programming

/*	A constraint is a conditional statement applied to a given object that
	resrticts the change of its content.

	Say you have a StzString object containing the string "hello!", and that
	you want to avoid updating it with any capital letters (i.e. you want it
	to stay always in lowercase!), then you add a constraint to that object
	using EnforceConstraint() function, like this:
*/		StzStringQ("hello!") {
			EnforceConstraint('@.IsLowercase')
			# Try to break the law:
			Update(:With = "HELLO!")
			#--> Softanza complains and raises an error!
		}

/*	As you see, if one tries to break the law and update it with an uppercase,
	the self-protection mechanism of the constrained object won't let him do so.

		PRPOSAL OF MAHMOUD:

		Two important features are required here:

		(1) A method to ask if the update is possible or not (without raising an error)
		(2) Setting a function to be called if an error happened during update (instead of raising an error)

	#-- 4. Natural Language Programming
	
		In Softanza you can beautify your if statements with such natural expressions:

*/		v = 8 	   if _(v).Is('DoubleOf(4)')._ { ? "Ok!" }		#--> Ok!
		v = "ring" if _(v).Is('Lowercase()')._ { ? "Ok!" }		#--> Ok!

/*		Also you can say:

*/		? _(8).IsA(:Number).ThatIs('DoubleOf(4)')._			#--> TRUE
		? _("ring").IsA(:String).ThatIs('Lowercase()')._		#--> TRUE

		? _("ring").Is('Lowercase()').Containing("in")._		#--> TRUE
		? _("ring").Is('Lowercase()').Having('NumberOfchars() = 4')._	#--> TRUE
		? _("ring").IsNotA(:String).That('Contains("x")')._		#--> TRUE
	
/*		And you can replace the classic style of doing loops by this more natural style:

*/		v = "♥"	 DoThis('{ ? "Hi" + v + "!" }')._(3).Times 	    #--> Hi♥! Hi♥! Hi♥!
		v = 0 	 DoThis('{ v++ ? v }').While('{ v <= 3 }')	    #--> 1 2 3
		v = "12" Until('{ v = "1200" }').DoThis('{ v += "0" ? v }') #--> "12" "120" "1200"

/*		In addition to many other constructs that mimic the natural language and turn
		into a fluid computational thinking experience!
	
	#-- 5. Knwoledge Programming

	If you instruct Softanza something, it recognizes it as an internal piece of wizdom
	inside you program. Look at this knowledge-oriented dialog with Softanza:

*/	_("Apple").IsA(:Fruit)_
		? WhatIs(:Apple) #--> :Fruit
		? WhatIs(:Fruit) #--> :Undefined
	_(:Fruit).Is("the means by which flowering plants disseminate their seeds")
		? WhatIs(:Fruit) #--> the means by which flowering plants disseminate their seeds
	_("Apple").IsA(:Company)_
		? WhatIs(:Apple) #--> [ :Fruit, :Company ]

	_("Steve Jobs").IsThe(:Owner).Of(:Apple)_
		? WhoIs("Steve Jobs") #--> _('Steve Jobs").IsThe(:Owner).Of(:Apple)
		? WhatIs("Steve Jobs") #--> :Undefined
	_(:Owner).IsA(:Person)_
		? WhatIs("Steve Jobs") #--> :Person

	_(:Person).And(:Fruit).CanBeRelatedBy(:Eats).AndAskedUsing(:What)_
	_(:Person).And(:Company).CanBeRelatedBy(:WorksAt).AndAskedUsing(:Where)_
	_("Steve Jobs").Eats(:Apple)_
	_("Steve Jobs").WorksAt(:Apple)_
		? What("Steve Jobs").Eats() 	#--> :Apple
		? Where("Steve Jobs").WorksAt() #--> :Apple

	
#---------------------------------#
#  Design Goal 7: MANAGEABILITY   #
#---------------------------------#

	#-- 1. Informative Error Messages
		
/*		You can use StzRaise() function for informative error messages:

*/		StzRaise([
			:Where = "@Place",  :What = "@Issue",
			:Why   = "@Reason", :Todo = "@Action" ])
		
/*		To show it in action, consider this list of items from ♥1 to ♥9:

*/		StzListQ(' "♥1" : "♥9" ') {

			# Let's add two walkers to the list :Walker1 and :Walker2

			AddWalkerFF([ :Name = :Walker1, :Direction = :Forward  ])
			AddWalkerFF([ :Name = :Walker2, :Direction = :Backward ])

			# The walkers are created and we can check them
			? Walkers() #--> [ :Walker1, :Walker2 ]
		
			# Now, let's try to add a Walker with an existant name:

			AddWalkerFF([ :Name = :Walker1, :Step = 3 ])
			#--> An error is raised: look at it in the right... 
		}
	
		#--> ERROR MESSAGE:
/*
		[ :Walker1, :Walker2 ]
		
*/		Line 889 > stzList.ring > AddWalkerFF():
			What	: Can't add a walker!
			Why	: Because the name 	
				  you provided 
			       (:Walker1) already 
				  exists.
			Todo	: Give a different 
				  new name and 		  
				  it'll be fine ;) 
		
/*		In StzRaise() in method AddWalkerFF() in file \Ring116\Projects\SoftanzaLib\
		stzList.ring

	#-- 2. Visualised CallStack

/*	o1.SortInAscending("aaCCyIIffAAbb").SortInAscending()
	
*/			o1.SortInAscending()			[ 5, "stzTempo25.ring" ]
			         |
				 v
		+----------------+────────────────+
		:				  |
		v				  v
	 SortableItems()		  UnsortableItems()	[ 1095, "stzList.ring" ]
						  |
						  V
					      Contains()	[ 1308, "stzList.ring" ]
						  |
						  V
					      FindFirst()	[ 1321, "stzList.ring" ]
						  |
						  V
					   HasSameContentAs()	[ 939, "stzList.ring" ]
						  |
						  X
				ERROR: Array Access (Index Out of Range)!

	#-- 3. Measurable Performance

/*		As a programmer, you should give users the best experience
		possible. To do so, Softanza helps in finding and eliminating
		performance bottelnecks before you ship them in your software!

		All you need is to decorate the functions you want to profile
		for performance with the #< @Profilable > decorator, like this:
*/			func FindSubString(pcSubStr)
				#< @Profilable >
				...

/*		And then, delimitate the part of your code you want to profile
		with the two functions:
*/			StartProfiler()
			...
			StopProfiler()

/*		A profiling report is then generated in the background. To see
		it instantly, use, instead of StopProfiler(), this extended form:
*/		StopProfilerXT([ :ShowReportIn = :Console, :Order = :CallStack ])
/*		And so you get the result you see in the right...
	
		Softanza Profiler Performance Report
		-> Started at 12:03:34, in line 834,
		in file stzList.ring
		-> Stopped at 12:05:08, in line 1214,
		in file stzList.ring
*/		 STEPS: 4  CALLS: 12  TIME: 2.34ms
		───────────────────────────────────

		 SortInAscending()  : 0.12ms
			|
			V
		   Contains()	    : 0.08ms
			|
			V
		   FindFirst()	    : 2.12ms (+90%!)
			|
			V
		 HasSameContent()   : 0.01ms

		──────────────────────────────────
/*		Function FindFirst() may need to
		be checked for performance!

	#-- 4. Cachable Dat in Functions and Objects

		Softanza comes with a RingQt-based cache system that you can
		activate for any object or function, by decorating them by:
*/			func FindNthOccurrence(n, pcSubStr)
				#< @ActivateCache = TRUE >

/*		If your function takes considerable amount of time to perform
		its job, then it is generally a good idea to make it cachable.

		Once you call the function above, for the first time, like this:
*/			o1.FindNthOccurrence(12, "♥")

/*		A cahe file (stzString.findNthOccurrence.cache.txt) is then
		created, and filled with the following line:
*/		[ :Time = 10:13:44:01, :n = 12, :pcSubStr = "♥", :Result = 34 ]

/*		In the future, every time the function is called with the same
		params, Softanza won't execute it again, but retrives the result
		instantly from the cache file (34 in our example)!
			
	#-- 5. Loggable Functions

		Logging is a master piece in debugging your code and analyzing
		your application activity in production. Softanza comes with a
		centralized and easy-to-use logging system, that traces your
		program at the function level.

		Hence, each function called is traced in the log store with an
		information about when it is called, from which other
		function, and with which context: data about the params value,
		the returned result, the underlining system information (like
		machine IP, OS, browser type, etc.) and even the identification
		if logged user who called it!

		Logs are stored in an organized file system, central database,
		or in a cloud storage you define by yourself, all managed for
		you by Softanza in the background.

		Anytime you need it, you can request elementary data from the
		log or generate advanced analytics to better understand the
		behaviour of your system and detect patterns for fixing complex
		errors, or buidling facts-based marketing strategies.

