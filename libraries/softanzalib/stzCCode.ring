
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

	def Update(cNewCode)
		@cContent = cNewCode

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
				" @EachPosition ", " @Each@i ", " @EachI " ],

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
				" @NextPosition ", " @Next@i ", " @NextI "],

				:By = " @i + 1 ", :CS = FALSE).
				
			ReplaceManyCSQ([
				" @NextItem ",
				" @NextChar ", " @NextString ", " @NextStringItem ",
				" @NextNumber ",
				
				" @NextList ", " @NextPair ",
				" @NextObject " ],

				:By = " This[@i + 1] ", :CS = FALSE).

			ReplaceManyCSQ([
				" @PreviousPosition ", " @Previous@i ", " @PreviousI "],

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

			ReplaceManyCSQ([

				"@CharQ", "@StringQ", "@LineQ",

				"@NumberQ",

				"@ItemQ", "@ListQ",
				"@PairQ", "@SectionQ",

				"@ObjectQ" ],

				:By = "Q(This[@i])", :CS = FALSE).

			ReplaceManyCSQ([

				"@EachCharQ", "@EachStringQ", "@EachLineQ",

				"@EachNumberQ",

				"@EachItemQ", "@EachListQ",
				"@EachPairQ", "@EachSectionQ",

				"@EachObjectQ" ],

				:By = "Q(This[@i])", :CS = FALSE).

			ReplaceManyCSQ([

				"@PreviousCharQ", "@PreviousStringQ",
				"@PreviousLineQ",

				"@PreviousNumberQ",

				"@PreviousItemQ", "@PreviousListQ",
				"@PreviousPairQ", "@PreviousSectionQ",

				"@PreviousObjectQ" ],

				:By = "Q(This[@i-1])", :CS = FALSE).

			ReplaceManyCSQ([

				"@NextCharQ", "@NextStringQ",
				"@NextLineQ",

				"@NextNumberQ",

				"@NextItemQ", "@NextListQ",
				"@NextPairQ", "@NextSectionQ",

				"@NextObjectQ" ],

				:By = "Q(This[@i+1])", :CS = FALSE).

			Trimmed()

		return cResult


	def ExecutableSection()
		/* EXAMPLE

		o1 = new stzCCode('{ This[ @i ] = This[ @i + 3 ] }')
		? o1.ExecutableSection()
		#--> [ 1, -4 ]

		*/

		oCode = new stzString( This.Transpiled() )
	
		acNumbersAfter = oCode.NumbersComingAfter("@i")
		# NOTE: Takes most time!
		# TODO: Has been optimised once but try more!
? @@S(acNumbersAfter)

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
