
/*
	Inside a conditional code you can use these keywords:
	@item
	@EachItem
	@CurrentItem
	@NextItem
	@PreviousItem
	
	@i
	@CurrentI
	@NextI
	@PreviousI
	
	This[ @i ] # Instead of ItemAt()
*/

func StzCCodeQ(cCode)
	return new stzCCode(cCode)

func StzConditionalCodeQ(cCode)
	return new stzConditionalCode(cCode)

class stzConditionalCode from stzCCode 

class stzCCode
	@cContent

	def init(cCode)
		if NOT isString(cCode)
			
			StzRaise([
				:Where = "stzCCodeUnifier > Init()",
				:What  = "Can't create the stzConditionalCodeUnifier object.",
				:Why   = "The parameter you provided is not in a correct type.",
				:Todo  = "Provide a conditional code as a Ring expression inside a string."
			])

		ok

		@cContent = cCode

	def Content()
		return @cContent

		def ContentQ()
			return new stzString( This.Content() )

	def CCode()
		return This.Content()

		def CCodeQ()
			return This.ContentQ()

	def Code()
		return This.Content()

		def CodeQ()
			return This.ContentQ()

	def UnifyFor(cStzClass)

		if NOT ( isString(cStzClass) and
			 	Q(cStzClass).IsOneOfTheseCS([
					:stzString, 
					:stzList, :stzListOfLists, :stzListOfStrings,
					:stzListOfNumbers, :stzListOfPairs, :stzListOfObjects
				], :CS = FALSE) )

			StzRaise("Unsupported type in conditional code!")
		ok

		cKeyWord = "@item"

		switch cStzClass
		on :stzString		cKeyWord = "@char"
		on :stzList		cKeyWord = "@item"
		on :stzListOfStrings	cKeyWord = "@string"
		on :stzListOfNumbers	cKeyWord = "@number"
		on :stzListOfLists	cKeyWord = "@list"
		on :stzListOfPairs	cKeyWord = "@pair"
		on :stzListOfObjects	cKeyWord = "@object"	
		off

		cCode = StzStringQ(This.Code()).TrimQ().BoundsRemoved([ "{","}" ])

		cCode = " " + cCode + " "	# DO NOT REMOVE THIS LINE! NOR THE LEADING
						# AND TRAILING SPACE YOU SEE INSIDE THE CODE

		cResult = StzStringQ(cCode).

			# 1) Spacifying keywords

			SpacifyTheseSubstringsCSQ([
				"@items","@allItems",
								
				"@chars","@allChars",
				"@strings","@allStrings",
				"@substrings","@allSubStrings",

				"@numbers","@allNumbers",
				
				"@lists","@allLists",
				"@pairs","@allPairs",
				
				"@objects","@allObjects",
				
				"@position", "@CurrentPosition",
				
				"@item", "@EachItem", "@CurrentItem",
				"@char", "@EachChar", "@CurrentChar",
				"@string", "@EachString", "@CurrentString",
				"@substring", "@EachSubString", "@CurrentSubString",

				"@number", "@EachNumber", "@CurrentNumber",
				"@list", "@EachList", "@CurrentList",
				"@pair", "@EachPair", "@CurrentPair",
				"@object", "@EachObject", "@CurrentObject",
				
				"@NextPosition",
				"@PreviousPosition",
				
				"@NextItem",
				"@NextChar", "@NextString", "@NextSubString",
				"@NextNumber",
				
				"@NextList", "@NextPair",
				"@NextObject",
				
				"@PreviousItem",
				"@PreviousChar", "@PreviousString", "@PreviousSubString",

				"@PreviousNumber",
				"@PreviousList", "@PreviousPair",
				"@PreviousObject"
				],

				:CaseSensitive = FALSE
			).

		#--

			# 2) Unifying all kewords referring to the current position
			#    by rpalacing them all by @i

			ReplaceManyCSQ([ " @position ", " @CurrentPosition " ],

				:By = " @i ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				
				"(@position)", "( @position)", "(@position )",
				
				"(@CurrentPosition)", "( @CurrentPosition)", "(@CurrentPosition )"
				],

				:By = "( @i )", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"[@position]", "[ @position]", "[@position ]",
				
				"[@CurrentPosition]", "[ @CurrentPosition]", "[@CurrentPosition ]"
				],

				:By = "[ @i ]", :CS = FALSE
			).

			# 3) Unifying all kewords referring to the current item
			#    by replacing them all by @item

			ReplaceManyCSQ([		
				" @EachItem ", " @CurrentItem ",

				" @char ", " @EachChar ",
				" @CurrentChar ",

				" @string ", " @EachString ",
				" @CurrentString ",

				" @substring ", " @EachSubString ",
				" @CurrentSubString ",

				" @number ", " @EachNumber ",
				" @CurrentNumber ",

				" @list ", " @EachList ",
				" @CurrentList ",

				" @pair ", "@EachPair ",
				" @CurrentPair ",

				" @section ", " @EachSection ",
				" @CurrentSection ",

				" @object ", " @EachObject ",
				" @CurrentObject "
				],

				:By = " @item ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				"(@EachItem)", "( @EachItem)", "(@EachItem )",
				"(@CurrentItem)", "( @CurrentItem)", "(@CurrentItem )",

				"(@char)", "( @char)", "(@char )",
				"(@EachChar)", "( @EachChar)", "(@EachChar )",
				
				"(@CurrentChar)", "( @CurrentChar)", "(@CurrentChar )",

				"(@string)", "( @string)", "(@string )",
				"(@EachString)", "( @EachString)", "(@EachString )",
				
				"(@CurrentString)", "( @CurrentString)", "(@CurrentString )",

				"(@substring)", "( @substring)", "(@substring )",
				"(@EachSubString)", "( @EachSubString)", "(@EachSubString )",
				
				"(@CurrentSubString)", "( @CurrentSubString)", "(@CurrentSubString )",

				"(@number)", "( @number)", "(@number )",
				
				"(@EachNumber)", "( @EachNumber)", "(@EachNumber )",
				
				"(@CurrentNumber)", "( @CurrentNumber)", "(@CurrentNumber )",

				"(@list)", "( @list)", "(@list )",
				
				"(@EachList)", "( @EachList)", "(@EachList )",
				
				"(@CurrentList)", "( @CurrentList)", "(@CurrentList )",

				"(@pair)", "( @pair)", "(@pair )",
				
				"(@EachPair)", "( @EachPair)", "(@EachPair )",
				
				"(@CurrentPair)", "( @CurrentPair)", "(@CurrentPair )",

				"(@section)", "( @section)", "(@section )",
				
				"(@EachSection)", "( @EachSection)", "(@EachSection )",
				
				"(@CurrentSection)", "( @CurrentSection)", "(@CurrentSection )",

				"(@object)", "( @object)", "(@object )",
				
				"(@EachObject)", "( @EachObject)", "(@EachObject )",
				
				"(@CurrentObject)", "( @CurrentObject)", "(@CurrentObject )"
				],
	
				:By = "( @item )", :CS = FALSE
			).
			ReplaceManyCSQ([
			
				"[@EachItem]", "[ @EachItem]", "[@EachItem ]",
				"[@CurrentItem]", "[ @CurrentItem]", "[@CurrentItem ]",

				"[@char]", "[ @char]", "[@char ]",
				"[@EachChar]", "[ @EachChar]", "[@EachChar ]",
				"[@CurrentChar]", "[ @CurrentChar]", "[@CurrentChar ]",

				"[@string]", "[ @string]", "[@string ]",
				"[@EachString]", "[ @EachString]", "[@EachString ]",
				"[@CurrentString]", "[ @CurrentString]", "[@CurrentString ]",
		
				"[@substring]", "[ @substring]", "[@substring ]",
				"[@EachSubString]", "[ @EachSubString]", "[@EachSubString ]",
				"[@CurrentSubString]", "[ @CurrentSubString]", "[@CurrentSubString ]",

				"[@number]", "[ @number]", "[@number ]",
				"[@EachNumber]", "[ @EachNumber]", "[@EachNumber ]",
				"[@CurrentNumber]", "[ @CurrentNumber]", "[@CurrentNumber ]",

				"[@list]", "[ @list]", "[@list ]",
				"[@EachList]", "[ @EachList]", "[@EachList ]",
				"[@CurrentList]", "[ @CurrentList]", "[@CurrentList ]",

				"[@pair]", "[ @pair]", "[@pair ]",
				"[@EachPair]", "[ @EachPair]", "[@EachPair ]",
				"[@CurrentPair]", "[ @CurrentPair]", "[@CurrentPair ]",

				"[@section]", "[ @section]", "[@section ]",
				"[@EachSection]", "[ @EachSection]", "[@EachSection ]",
				"[@CurrentSection]", "[ @CurrentSection]", "[@CurrentSection ]",

				"[@object]", "[ @object]", "[@object ]",
				"[@EachObject]", "[ @EachObject]", "[@EachObject ]",
				"[@CurrentObject]", "[ @CurrentObject]", "[@CurrentObject ]" 
				],
	
				:By = "[ @item ]", :CS = FALSE
			).

			# 4) Unifying all kewords referring to the next position
			#    by replacing them all by (@i + 1)

			ReplaceManyCSQ([ " @NextPosition " ],

				:By = " ( @i + 1 ) ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				"(@NextPosition)", "( @NextPosition)", "(@NextPosition )"
				],

				:By = "( @i + 1 )", :CS = FALSE
			).
			ReplaceManyCSQ([
			
				"[@NextPosition]", "[ @NextPosition]", "[@NextPosition ]"
				],

				:By = "[ @i + 1 ]", :CS = FALSE
			).

			# 5) Unifying all kewords referring to the previous position
			#    by replacing them all by (@i - 1)

			ReplaceManyCSQ([ " @PreviousPosition " ],

				:By = " ( @i - 1 ) ", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"(@PreviousPosition)", "( @PreviousPosition)", "(@PreviousPosition )"
				],

				:By = "( @i - 1 )", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"[@PreviousPosition]", "[ @PreviousPosition]", "[@PreviousPosition ]"
				],

				:By = "[ @i - 1 ]", :CS = FALSE
			).

			# 6) Unifying all keywords referring to the next item
			#    by replacing them all by This[@i+1]

			ReplaceManyCSQ([
				" @NextItem ",

				" @NextChar ",
				" @NextString ",
				" @NextSubString ",

				" @NextNumber ",

				" @NextList ",
				" @NextPair ",
				" @NextSection ",

				" @NextObject "
				],

				:By = " This[ @i + 1 ] ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				
				"(@NextChar)", "( @NextChar)", "(@NextChar )",
				"(@NextString)", "( @NextString)", "(@NextString )",
				"(@NextSubString)", "( @NextSubString)", "(@NextSubString )",

				"(@NextNumber)", "( @NextNumber)", "(@NextNumber )",

				"(@NextList)", "( @NextList)", "(@NextList )",
				"(@NextPair)", "( @NextPair)", "(@NextPair )",
				"(@NextSection)", "( @NextSection)", "(@NextSection )",

				"(@NextObject)", "( @NextObject)", "(@NextObject )"
				],

				:By = "( This[ @i + 1 ] )", :CS = FALSE
			).
			ReplaceManyCSQ([

				"[@NextChar]", "[ @NextChar]", "[@NextChar ]",
				"[@NextString]", "[ @NextString]", "[@NextString ]",
				"[@NextSubString]", "[ @NextSubString]", "[@NextSubString ]",

				"[@NextNumber]", "[ @NextNumber]", "[@NextNumber ]",

				"[@NextList]", "[ @NextList]", "[@NextList ]",
				"[@NextPair]", "[ @NextPair]", "[@NextPair ]",
				"[@NextSection]", "[ @NextSection]", "[@NextSection ]",

				"[@NextObject]", "[ @NextObject]", "[@NextObject ]"
				],

				:By = "[ This[ @i + 1 ] ]", :CS = FALSE
			).

			# 7) Unifying all keywords referring to the previous item 
			#    by replacing them all by This[ @i-1 ]

			ReplaceManyCSQ([
				" @PreviousItem ",
				" @PreviousItem ",

				" @PreviousChar ",
				" @PreviousString ",
				" @PreviousSubString ",

				" @PreviousNumber ",
				" @PreviousList ",
				" @PreviousPair ",
				" @PreviousSection ",

				" @PreviousObject "
				],

				:By = " This[ @i - 1 ] ", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"(@PreviousItem)", "( @PreviousItem)", "(@PreviousItem )",
				
				"(@PreviousChar)", "( @PreviousChar)", "(@PreviousChar )",
				"(@PreviousString)", "( @PreviousString)", "(@PreviousString )",
				"(@PreviousSubString)", "( @PreviousSubString)", "(@PreviousSubString )",

				"(@PreviousNumber)", "( @PreviousNumber)", "(@PreviousNumber )",

				"(@PreviousList)", "( @PreviousList)", "(@PreviousList )",
				"(@PreviousPair)", "( @PreviousPair)", "(@PreviousPair )",
				"(@PreviousSection)", "( @PreviousSection)", "(@PreviousSection )",

				"(@PreviousObject)", "( @PreviousObject)", "(@PreviousObject )"
				],

				:By = "(This[ @i - 1 ])", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"[@PreviousItem]", "[ @PreviousItem]", "[@PreviousItem ]",
				
				"[@PreviousChar]", "[ @PreviousChar]", "[@PreviousChar ]",
				"[@PreviousString]", "[ @PreviousString]", "[@PreviousString ]",
				"[@PreviousSubString]", "[ @PreviousSubString]", "[@PreviousSubString ]",

				"[@PreviousNumber]", "[ @PreviousNumber]", "[@PreviousNumber ]",

				"[@PreviousList]", "[ @PreviousList]", "[@PreviousList ]",
				"[@PrevList]", "[ @PrevList]", "[@PrevList ]",
				"[@PreviousPair]", "[ @PreviousPair]", "[@PreviousPair ]",
				"[@PreviousSection]", "[ @PreviousSection]", "[@PreviousSection ]",
				
				"[@PreviousObject]", "[ @PreviousObject]", "[@PreviousObject ]"
				],
				
				:By = "(This[ @i - 1 ])", :CS = FALSE
			).

			ReplaceManyCSQ([
				"CharAt(", "StringAt(",
				"ListAt(", "NumberAt(", "PairAt("
				],
				:With = "ItemAt(", :CS = FALSE
			).

			ReplaceManyCSQ([
				"ItemAt( ( @i ) )", "ItemAt( @i )"
				],

				:With = "This[ @i ]", :CS = FALSE
			).

			ReplaceManyCSQ([
				"ItemAt( ( @i+1 ) )", "ItemAt( @i+1 )"
				],

				:With = "This[ @i + 1 ]", :CS = FALSE
			).

			ReplaceManyCSQ([
				"ItemAt( ( @i-1 ) )", "ItemAt( @i-1 )"
				],

				:With = "This[ @i - 1 ]", :CS = FALSE
			).

			ReplaceCSQ("@item", :With = cKeyWord, :CS = FALSE).

			ReplaceCSQ("This.This[", :With = "This[", :CS = FALSE).
			
			Trimmed()

			This.Update(cResult)

			#< @FunctionFluentForm

			def UnifyForQ(cStzClass)
				This.UnifyFor(cStzClass)
				return This

			#>

			#< @FunctionAlternativeForm

			def PrepareFor(cStzClass)
				This.UnifyFor(cStzClass)

			def TranspileFor(cStzClass)
				This.UnifyFor(cStzClass)

			#>

	def UnifiedFor(cStzClass)
		cResult = This.Copy().UnifyForQ(cStzClass).Content()
		return cResult

		def PreparedFor(cStzClass)
			return This.UnifiedFor(cStzClass)

		def TranspiledFor(cStzClass)
			return This.UnifiedFor(cStzClass)

	def Update(cNewCode)
		@cContent = cNewCode

	def Copy()
		return new stzCCode( This.Content() )

	def ExecutableSection()
		/* EXAMPLE

		o1 = new stzCCode('{ This[ @i ] = This[ @i + 3 ] }')
		? o1.ExecutableSection()
		#--> [ 1, -4 ]

		*/

		oCode = This.CCodeQ().
			ReplaceManyCSQ([
				"@CurrentItem", "@CurrentString", "@CurrentStringItem",
				"@CurrentChar", "@CurrentList", "@CurrentPair",
				"@CurrentHashList", "@CurrentObject" ],

				:By = "This[@i]", :CS = FALSE).

				ReplaceManyCSQ([
				"@NextItem", "@NextString", "@NextStringItem",
				"@NextChar", "@NextList", "@NextPair",
				"@NextHashList", "@NextObject" ],

				:By = "This[@i+1]", :CS = FALSE).

				ReplaceManyCSQ([
				"@PrevisItem", "@PreviousString", "@PreviousStringItem",
				"@PreviousChar", "@PreviousList", "@PreviousPair",
				"@PreviousHashList", "@PreviousObject" ],

				:By = "This[@i-1]", :CS = FALSE)
	
		acNumbersAfter = oCode.NumbersComingAfter("@i")
		# NOTE: Takes most time!
		# TODO: Has been optimised once but try more!

		nLenAfter = len(acNumbersAfter)

		if len(acNumbersAfter) = 0
			return [ 1, :Last ]
		ok

		anNumbers = []
		for i = 1 to nLenAfter
			anNumbers + (0+ acNumbersAfter[i])
		next
		oNumbers = new stzList(anNumbers)

		anResult = [ 1, :Last ]

		if nLenAfter = 1
			n =  anNumbers[1]

			if n > 0
				anResult = [ 1, (-n -1) ]

			but n < 0
				anResult = [ Abs(n) + 1, :Last ]

			ok
		else
			nMin = 0+ oNumbers.Smallest()
			nMax = 0+ oNumbers.Greatest()
	
			if BothAreNegative( nMin, nMax )
				nMin = Abs( nMin )
				nMax = :Last
	
			but BothArePositive( nMin, nMax )
				nMin = 1
				nMax = - nMax -1
	
			but nMin < 0 and nMax > 0
				nMin = Abs(nMin) + 1
				nMax = - nMax -1
	
			else
				nMin = 1
				nMax = :Last
			ok
	
			anResult = [ nMin, nMax ]
		ok

		return anResult
