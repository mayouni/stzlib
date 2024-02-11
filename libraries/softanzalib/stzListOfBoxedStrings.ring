
func IsListOfBoxedStrings(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsBoxedString(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfBoxedStrings(paList)
		return IsListOfBoxedStrings(paList)

	func ListIsListOfBoxedStrings(paList)
		return IsListOfBoxedStrings(paList)

	#--

	func IsAListOfBoxedStrings(paList)
		return IsListOfBoxedStrings(paList)

	func @IsAListOfBoxedStrings(paList)
		return IsListOfBoxedStrings(paList)

	func ListIsAListOfBoxedStrings(paList)
		return IsListOfBoxedStrings(paList)

	#>

class stzListOfBoxedStrings from stzListOfStrings

	@aListOfStrings
	@aListOfBoxedStrings

	func init(paListOfStrings, paBoxOptions)
		if isList(paListOfStrings) and
		   ( Q(paListOfStrings).IsEmpty() or Q(paListOfStrings).IsListOfNumbers() )

			@aListOfStrings = paListOfStrings
			@aListOfBoxedStrings = This.pvtBoxedXT(paBoxOptions)

		else
			StzRaise(stzListOfBoxedStringsError(:CanNotCreateStzListOfBoxedStringsObject))
		ok

	def Content()
		return @aListOfStrings

		def Value()
			return Content()

	def Copy()
		return new stzListOfBoxedStrings(This.Content())

	def ToStzListOfStrings()
		return new stzListOfStrings(@aListOfBoxedStrings)

	PRIVATE

	def pvtBoxedXT(paBoxOptions)
? @aListOfStrings
? paBoxOptions
		/*
		Example:

		? StzListOfCharsQ("TEXT").BoxedXT([
			:Line = :Thin,	# or :Dashed
		
			:AllCorners = :Round # can also be :Rectangualr

			# Or you can specify evey corner like this:
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

			# :Hilighted = [ 3 ] # The 3rd char is hilighted
		
		])

		--> Gives:
		╭───┬───┬───┬───╮
		│ T │ E │ X │ T │
		╰───┴───┴─•─┴───╯	
		*/
		
		if StzListQ(paBoxOptions).IsTextBoxedOptionsNamedParam()

			# Reading the type of line (thin or dashed)

			cLine = :Thin # By default

			if paBoxOptions[ :Line ] = :Dashed
				cLine = :Dashed
			ok

			# Reading the type of corners (rectangualr or round)

			cAllCorners = :Rectangular # By default

			if paBoxOptions[ :AllCorners ] = :Round

				cAllCorners = :Round
			ok

			aCorners = []

			if cAllCorners = :Rectangular
				 # By default
				aCorners = [ :Rectangular, :Rectangular, :Rectangular, :Rectangular ]

			but cAllCorners = :Round
				aCorners = [ :Round, :Round, :Round, :Round ]

			ok

			if len(paBoxOptions[:Corners]) = 4 and
			   StzListQ( paBoxOptions[:Corners] ).IsMadeOfSome([ :Rectangular, :Round ])
	
				aCorners = paBoxOptions[:Corners]

			ok

			# Reading the hilightening option
			
			aHilighted = NULL

			if isList(paBoxOptions[ :Hilighted ]) and
			   # len( paBoxOptions[ :Hilighted ] ) <= This.NumberOfItems() and
			   StzListQ(paBoxOptions[ :Hilighted ]).IsListOfNumbers() and
			   ListIsSet( paBoxOptions[ :Hilighted ] )

				if StzListQ( paBoxOptions[ :Hilighted ] ).IsMadeOfSome( 1:This.NumberOfItems() )
					aHilighted = paBoxOptions[ :Hilighted ]

				else

					aHilighted = []
					for n in paBoxOptions[ :Hilighted ]
						if n <= This.NumberOfItems()
							aHilighted + n
						ok
					next

				ok
			ok

			# Reading the hilightening condition

			cHilightIf = NULL
		
			if paBoxOptions[ :HilightedIf ] != NULL
				cHilightIf = paBoxOptions[ :HilightedIf ]
			ok

			# Reading the numbering option

			bNumbered = FALSE

			if paBoxOptions[ :Numbered ] != NULL and
			   paBoxOptions[ :Numbered ] = TRUE

				bNumbered = TRUE
			ok

			# Preparing the visual assets

			cVTrait  = "│"		cUpSep   = "┬"

			cHTrait  = "───"	cDownSep = "┴"

			cHilight = "─" + HilightChar() + "─"

			if cLine = :Dashed
				cHTrait = "╌╌╌"
				cVTrait = "┊"
			ok
			
			
			cCorner1 = "┌"
			cCorner2 = "┐"
			cCorner3 = "┘"
			cCorner4 = "└"

			if  aCorners[1] = :Round
				cCorner1 = "╭"
			ok

			if aCorners[2] = :Round
				cCorner2 = "╮"
			ok

			if aCorners[3] = :Round
				cCorner3 = "╯"
			ok

			if aCorners[4] = :Round
				cCorner4 = "╰"
			ok

			// Painting the boxes around all the strings of the list

			cResult = ""

			for str in @aListOfStrings
				cBoxedStr = ""

				nWidth = StzStringQ(str).NumberOfChars()
	
				cUpLine = cCorner1 +
					  StzStringQ(cHTrait + cUpSep).RepeatedNTimes(nWidth-1) +
					  cHTrait + cCorner2 
	
				
				cMidLine = cVTrait
	
	
				for c in str
					cMidLine += " " + c + " " + cVTrait
				next
	
				if NOT isList(aHilighted)
					cDownLine = cCorner4 +
						  StzStringQ(cHTrait + cDownSep).RepeatedNTimes(nWidth-1) +
						  cHTrait + cCorner3
	
				else
					# Hilight some chars
	
					cDownLine = cCorner4
					cTrait = ""
	
					for i = 1 to nWidth - 1
	
						if StzListQ(aHilighted).Contains(i) 
							cTrait = cHilight
	
						else
							cTrait = cHTrait
						ok
	
						cDownLine += cTrait + cDownSep				
	
					next
	
					# Speciefic case of the last char
	
					if StzListQ(aHilighted).Contains(nWidth)
						cDownLine += cHilight + cCorner3
					else
						cDownLine += cHTrait + cCorner3
					ok
	
				ok
	
				cBoxedStr = cUpLine + NL + cMidLine + NL + cDownLine
	
				cNumberLine = ""
	
				if bNumbered
					oCounter = new stzCounter([
						:StartAt = 1,
						:WhenYouSkip = 9,
						:RestartAt = 0,
						:Step = 1
					])
	
					aNumbers = oCounter.CountingTo( nWidth )
	
					for i = 1 to nWidth
						cNumberLine += "  " + aNumbers[i] + " "
					next
					cBoxedStr += NL + cNumberLine
				ok
	
				return cBoxedStr

			next
			
		else
			StzRaise(stzListOfBoxedStringsError(:CanNotBoxTheListOfStrings))
		ok
	
