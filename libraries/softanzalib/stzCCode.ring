
/*
	Inside a conditional code you can use these keywords:
	@item
	@EachItem (...Char, ...String, ...List, ...Pair, ...Section, ...Number, ...Object)
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
				:Where = "stzCCode > Init()",
				:What  = "Can't create the stzConditionalCode object.",
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

	#----

	def Update(cNewCode)
		if isList(cNewCode) and Q(cNewCode).IsWithOrByOrUsingNamedParam()
			cNewCode = cNewCode[2]
		ok

		@cContent = cNewCode

		#< @FunctionFluentForm

		def UpdateQ(cNewCode)
			This.Update(cNewCode)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(cNewCode)
			This.Update(cNewCode)

			def UpdateWithQ(cNewCode)
				return This.UpdateQ(cNewCode)
	
		def UpdateBy(cNewCode)
			This.Update(cNewCode)

			def UpdateByQ(cNewCode)
				return This.UpdateQ(cNewCode)

		def UpdateUsing(cNewCode)
			This.Update(cNewCode)

			def UpdateUsingQ(cNewCode)
				return This.UpdateQ(cNewCode)

		#>

	def Updated(cNewCode)
		return cNewCode

		#< @FunctionAlternativeForms

		def UpdatedWith(cNewCode)
			return This.Updated(cNewCode)

		def UpdatedBy(cNewCode)
			return This.Updated(cNewCode)

		def UpdatedUsing(cNewCode)
			return This.Updated(cNewCode)

		#>

	#---

	def Copy()
		return new stzCCode( This.Content() )

	def Transpiled()

		cCode = StzStringQ(This.Code()).
			TrimQ().
			RemoveBoundsQ([ "{","}" ]).

			ReplaceAllQ("(", :By = "( ").
			ReplaceAllQ(")", :By = " )").

			ReplaceAllQ("[", :By = "[ ").
			ReplaceAllQ("]", :By = " ]").

			Content()

		cCode = Q(cCode).TheseSubstringsSpacifiedCS([

				"@items", "@allItems", "@item",
			
				"@chars", "@allChars", "@char",
				"@strings", "@allStrings", "@string",
				"@strinItems", "@allStringItems", "@StringItem",

				
				"@numbers","@allNumbers", "@number",
				
				"@lists", "@allLists", "@list",
				"@pairs", "@allPairs", "@pair",
				
				"@objects", "@allObjects", "@object",

				"@positions", "@position", "@CurrentPosition",
				"@EachPosition",

				"-@Number",

				"@NextItem",
				"@NextChar","@NextString","@NextStringItem",
				"@NextNumber",
				
				"@NextList","@NextPair",
				"@NextObject",

				"@PreviousPosition",

				"@PreviousItem",
				"@PreviousChar",
				"@PreviousString","@PreviousStringItem",
				"@PreviousNumber",

				"@PreviousList","@PreviousPair",
				"@PreviousObject"
				
		], :CaseSensitive = FALSE)

		cResult = StzStringQ(" " + cCode + " ").

			ReplaceManyCSQ([
				" @items ","@allItems",
								
				" @chars ","@allChars",
				" @strings ","@allStrings",
				
				" @numbers ","@allNumbers",
				
				" @lists ","@allLists",
				" @pairs ","@allPairs",
				
				" @objects ","@allObjects" ],

				:By = " This.Content() ", :CS = FALSE).

			ReplaceManyCSQ([
				" @position ", " @CurrentPosition ",
				" @Current@i ", " @CurrentI ",
				" @EachPosition ", " @EachI " ],

				:By = " @i ", :CS = FALSE).

			ReplaceManyCSQ([				
				" @item ", " @EachItem ", " @CurrentItem ",
				" @char ", " @EachChar ", " @CurrentChar ",
				" @string", " @EachString ", " @CurrentString ",
				" @line", " @EachLine ", " @CurrentLine ",

				" @number ", " @EachNumber ", " @CurrentNumber ",

				" @list ", " @EachList ", " @CurrentList ",
				" @pair ", " @EachPair ", " @CurrentPair ",
				" @section ", " @EachSection ", " @CurrentSection ",

				" @object ", " @EachObject ", " @CurrentObject " ],

				:By = " This[@i] ", :CS = FALSE ).
				
			ReplaceCSQ(" -@Number ", :By = " - This[@i] ", :CS = FALSE).

			ReplaceManyCSQ([
				" @NextPosition ", " @NextI "],

				:By = " @i + 1 ", :CS = FALSE).
				
			ReplaceManyCSQ([
				" @NextItem ",
				" @NextChar ", " @NextString ", " @NextStringItem ",
				" @NextNumber ",
				
				" @NextList ", " @NextPair ",
				" @NextObject " ],

				:By = " This[@i + 1] ", :CS = FALSE).

			ReplaceManyCSQ([
				" @PreviousPosition ", " @PreviousI "],

				:By = " @i - 1 ", :CS = FALSE).

			ReplaceManyCSQ([
				" @PreviousItem ",
				" @PreviousChar ",
				" @PreviousString ", " @PreviousStringItem ",
				" @PreviousNumber ",

				" @PreviousList ", " @PreviousPair ",
				" @PreviousObject "
				],

				:By = " This[@i - 1] ", :CS = FALSE).

			Trimmed()

		return cResult

	def ExecutableSection()
		# This version of the function assumes that the conditional
		# code uses only This[@i] like code. No @NextItem, @PreviousI,
		# and other keywords can be use here.

		# You can always repalce them by a This[@i] like alternative.
		# For example @NewtItem can be written as This[@i + 1], and
		# @PreviousItem can be written as This[@i - 1], and so on.

		# This will lead to a better speed. But if expressivenes is
		# a priority over performance, then you can use them and call
		# the extended version of the function insetead: ExecutableSectionXT()

		acSubStrings = This.CodeQ().Between("[","]")
		nLenSubStr = len(acSubStrings)

		acNumbersAfter = []
		for i = 1 to nLenSubStr
			acNumbers = Q(acSubStrings[i]).NumbersAfter("@i")
			if len(acNumbers) > 0
				acNumbersAfter + acNumbers[1]
			ok
		next

		nLenAfter = len(acNumbersAfter)

		if len(acNumbersAfter) = 0
			return [ 1, :Last ]
		ok

		anNumbers = []
		for i = 1 to nLenAfter
			cNumber = acNumbersAfter[i]
			if cNumber[1] = "+" or cNumber[1] = "-"
				anNumbers + (0+ cNumber)
			ok
		next
		oNumbers = new stzList(anNumbers)

		anResult = [ 1, :Last ]

		if nLenAfter = 1
			n =  anNumbers[1]

			if n > 0
				anResult = [ 1, -n ]

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
				nMax = - nMax

			but nMin < 0 and nMax > 0
				nMin = Abs(nMin) + 1
				nMax = - nMax
	
			else
				nMin = 1
				nMax = :Last
			ok
	
			anResult = [ nMin, nMax ]
		ok

		return anResult

	def ExecutableSectionXT()
		# A less performant version with less chekcs.
		# Only This[ @i + ... ] like syntaw is possible.

		# Use it when you want to be more expressive
		# in your conditional code and use @NextItem,
		# @PreviousItem and alike keywords, instead
		# of This[@i+1] and This[@i-1], @EachItem,
		# @EachItemQ and etc.

		# In this case, there is a performance tax
		# you should pay for. Hence, if you need to
		# be efficient, then you should use
		# ExecutableSection(), without ...XT(), instead.

		/* EXAMPLE

		o1 = new stzCCode('{ This[ @i ] = This[ @i + 3 ] }')
		? o1.ExecutableSection()
		#--> [ 1, -4 ]

		*/

		oCode = new stzString( This.Transpiled() )
	
		acSubStrings = oCode.Between("[","]")
		nLenSubStr = len(acSubStrings)

		acNumbersAfter = []
		for i = 1 to nLenSubStr
			acNumbers = Q(acSubStrings[i]).NumbersAfter("@i")
			if len(acNumbers) > 0
				acNumbersAfter + acNumbers[1]
			ok
		next

		nLenAfter = len(acNumbersAfter)

		if len(acNumbersAfter) = 0
			return [ 1, :Last ]
		ok

		anNumbers = []
		for i = 1 to nLenAfter
			cNumber = acNumbersAfter[i]
			if cNumber[1] = "+" or cNumber[1] = "-"
				anNumbers + (0+ cNumber)
			ok
		next
		oNumbers = new stzList(anNumbers)

		anResult = [ 1, :Last ]

		if nLenAfter = 1
			n =  anNumbers[1]

			if n > 0
				anResult = [ 1, -n ]

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
				nMax = - nMax
	
			but nMin < 0 and nMax > 0
				nMin = Abs(nMin) + 1
				nMax = - nMax
	
			else
				nMin = 1
				nMax = :Last
			ok
	
			anResult = [ nMin, nMax ]
		ok

		return anResult
