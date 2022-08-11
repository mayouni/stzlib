func StzCCodeQ(cCode)
	return new stzCCode(cCode)

func StzConditionalCodeQ(cCode)
	return new stzConditionalCode(cCode)

class stzConditionalCode from stzCCode 

class stzCCode
	@cContent

	def init(cCode)
		if NOT isString(cCode)
			
			stzRaise([
				:Where = "stzCCodeUnifier > Init()",
				:What  = "Can't create the stzConditionalCodeUnifier object.",
				:Why   = "The parameter you provided is not in a correct type.",
				:Todo  = "Provide a conditional code as a Ring expression inside a string."
			])

		ok

		@cContent = cCode

	def Content()
		return @cContent

	def Code()
		return This.Content()

	def UnifyFor(cStzClass)

		if NOT ( isString(cStzClass) and
			 	Q(cStzClass).IsOneOfTheseCS([
					:stzString, 
					:stzList, :stzListOfLists, :stzListOfStrings,
					:stzListOfNumbers, :stzListOfPairs, :stzListOfObjects
				], :CS = FALSE)
			)

			stzRaise("Unsupported type in conditional code!")
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
				"@numbers","@allNumbers",
				
				"@lists","@allLists",
				"@pairs","@allPairs",
				
				"@objects","@allObjects",
				
				"@position", "@CurrentPosition",
				
				"@item", "@EachItem", "@CurrentItem",
				"@char", "@EachChar", "@CurrentChar",
				"@string", "@EachString", "@CurrentString",
				"@number", "@EachNumber", "@CurrentNumber",
				"@list", "@EachList", "@CurrentList",
				"@pair", "@EachPair", "@CurrentPair",
				"@object", "@EachObject", "@CurrentObject",
				
				"@NextPosition",
				"@PreviousPosition",
				
				"@NextItem", "@NextChar",
				"@NextString", "@NextNumber",
				"@NextList", "@NextPair",
				"@NextObject",
				
				"@PreviousItem", "@PreviousChar",
				"@PreviousString", "@PreviousNumber",
				"@PreviousList", "@PreviousPair",
				"@PreviousObject"
				],

				:CaseSensitive = FALSE
			).

		#--

			# 4) Unifying all kewords referring to the current position
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

			# 5) Unifying all kewords referring to the current item
			#    by repalcing them all by @item

			ReplaceManyCSQ([		
				" @EachItem ", " @CurrentItem ",

				" @char ", " @EachChar ",
				" @CurrentChar ",

				" @string ", " @EachString ",
				" @CurrentString ",

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

			# 6) Unifying all kewords referring to the next position
			#    by replacing them all by (@i + 1)

			ReplaceManyCSQ([ " @NextPosition " ],

				:By = " ( @i+1 ) ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				"(@NextPosition)", "( @NextPosition)", "(@NextPosition )"
				],

				:By = "( @i+1 )", :CS = FALSE
			).
			ReplaceManyCSQ([
			
				"[@NextPosition]", "[ @NextPosition]", "[@NextPosition ]"
				],

				:By = "[ @i+1 ]", :CS = FALSE
			).

			# 7) Unifying all kewords referring to the previous position
			#    by replacing them all by (@i - 1)

			ReplaceManyCSQ([ " @PreviousPosition " ],

				:By = " ( @i-1 ) ", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"(@PreviousPosition)", "( @PreviousPosition)", "(@PreviousPosition )"
				],

				:By = "( @i-1 )", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"[@PreviousPosition]", "[ @PreviousPosition]", "[@PreviousPosition ]"
				],

				:By = "[ @i-1 ]", :CS = FALSE
			).

			# 8) Unifying all kewords referring to the next item
			#    by replacing them all by This[@i+1]

			ReplaceManyCSQ([
				" @NextItem ",
				" @NextChar ",

				" @NextString ",

				" @NextNumber ",

				" @NextList ",
				" @NextPair ",

				" @NextSection ",

				" @NextObject "
				],

				:By = " This[ @i+1 ] ", :CS = FALSE
			).
			#--
			ReplaceManyCSQ([
				
				"(@NextChar)", "( @NextChar)", "(@NextChar )",

				"(@NextString)", "( @NextString)", "(@NextString )",

				"(@NextNumber)", "( @NextNumber)", "(@NextNumber )",

				"(@NextList)", "( @NextList)", "(@NextList )",
				"(@NextPair)", "( @NextPair)", "(@NextPair )",

				"(@NextSection)", "( @NextSection)", "(@NextSection )",

				"(@NextObject)", "( @NextObject)", "(@NextObject )"
				],

				:By = "( This[ @i+1 ] )", :CS = FALSE
			).
			ReplaceManyCSQ([

				"[@NextChar]", "[ @NextChar]", "[@NextChar ]",

				"[@NextString]", "[ @NextString]", "[@NextString ]",

				"[@NextNumber]", "[ @NextNumber]", "[@NextNumber ]",

				"[@NextList]", "[ @NextList]", "[@NextList ]",
				"[@NextPair]", "[ @NextPair]", "[@NextPair ]",

				"[@NextSection]", "[ @NextSection]", "[@NextSection ]",

				"[@NextObject]", "[ @NextObject]", "[@NextObject ]"
				],

				:By = "[ This[ @i+1 ] ]", :CS = FALSE
			).

			# 9) Unifying all kewords referring to the previous item 
			#    by replacing them all by This[ @i-1 ]

			ReplaceManyCSQ([
				" @PreviousItem ",
				" @PreviousItem ",
				" @PreviousChar ",
				" @PreviousString ",
				" @PreviousNumber ",
				" @PreviousList ",
				" @PreviousPair ",
				" @PreviousSection ",
				" @PreviousObject "
				],

				:By = " This[ @i-1 ] ", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"(@PreviousItem)", "( @PreviousItem)", "(@PreviousItem )",
				
				"(@PreviousChar)", "( @PreviousChar)", "(@PreviousChar )",

				"(@PreviousString)", "( @PreviousString)", "(@PreviousString )",
				
				"(@PreviousNumber)", "( @PreviousNumber)", "(@PreviousNumber )",

				"(@PreviousList)", "( @PreviousList)", "(@PreviousList )",

				"(@PreviousPair)", "( @PreviousPair)", "(@PreviousPair )",

				"(@PreviousSection)", "( @PreviousSection)", "(@PreviousSection )",
				
				"(@PreviousObject)", "( @PreviousObject)", "(@PreviousObject )"
				],

				:By = "(This[ @i-1 ])", :CS = FALSE
			).
			ReplaceManyCSQ([
				
				"[@PreviousItem]", "[ @PreviousItem]", "[@PreviousItem ]",
				
				"[@PreviousChar]", "[ @PreviousChar]", "[@PreviousChar ]",
				
				"[@PreviousString]", "[ @PreviousString]", "[@PreviousString ]",
				
				"[@PreviousNumber]", "[ @PreviousNumber]", "[@PreviousNumber ]",
		
				"[@PreviousList]", "[ @PreviousList]", "[@PreviousList ]",
				"[@PrevList]", "[ @PrevList]", "[@PrevList ]",

				"[@PreviousPair]", "[ @PreviousPair]", "[@PreviousPair ]",
				
				"[@PreviousSection]", "[ @PreviousSection]", "[@PreviousSection ]",
				
				"[@PreviousObject]", "[ @PreviousObject]", "[@PreviousObject ]"
				],
				
				:By = "(This[ @i-1 ])", :CS = FALSE
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

				:With = "This[ @i+1 ]", :CS = FALSE
			).

			ReplaceManyCSQ([
				"ItemAt( ( @i-1 ) )", "ItemAt( @i-1 )"
				],

				:With = "This[ @i-1 ]", :CS = FALSE
			).

			ReplaceCSQ("@item", :With = cKeyWord, :CS = FALSE).
			
			Trimmed()

			This.Update(cResult)

			#< @FunctionFluentForm

			def UnifyForQ(cStzClass)
				This.UnifyFor(cStzClass)
				return This

			#>

	def UnifiedFor(cStzClass)
		cResult = This.Copy().UnifyForQ(cStzClass).Content()
		return cResult

	def Update(cNewCode)
		@cContent = cNewCode

	def Copy()
		return new stzCCode( This.Content() )
