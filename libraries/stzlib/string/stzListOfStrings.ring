#-------------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - stzListOfStrings			#
#		 An accelerative library for Ring applications	      		#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The class for managing lists of stringss		#
#	Version		: V1.0 (2020-2024)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#										#
#-------------------------------------------------------------------------------#

#TODO Simplify this class to just retain the supplementary features
# that are not available in stzList

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzListOfStringsQ(paList)
	return new stzListOfStrings(paList)

	func StzStringsQ(paList)
		return StzListOfStringsQ(paList)

# Some functions

func Concatenate(acListOfStr)
	return ConcatenateXT(acListOfStr, "")

	#< @FunctionAlternativeForms

	func Concat(acListOfStr)
		return Concatenate(acListOfStr)

	func @Concatenate(acListOfStr)
		return Concatenate(acListOfStr)

	func @Concat(acListOfStr)
		return Concatenate(acListOfStr)

	#>

func ConcatenateXT(acListOfStr, cSep)
	if CheckingParams()
		if NOT ( isList(acListOfStr) and IsListOfStrings(acListOfStr) )
			StzRaise("Incorrect param type! acListOfStr must be a list of strings.")
		ok

		if NOT isString(cSep)
			StzRaise("Incorrect param type! cSep must be a string.")
		ok
	ok

	nLen = len(acListOfStr)
	oQStrList = new QStringList()
	for i = 1 to 1_000_000
		oQStrList.append(acListOfStr[i])
	next
	
	cResult = oQStrList.join(cSep)
	return cResult

	#< @FunctionAlternativeForms

	func ConcatXT(acListOfStr, cSep)
		return ConcatenateXT(acListOfStr, cSep)

	func @ConcatenateXT(acListOfStr, cSep)
		return ConcatenateXT(acListOfStr, cSep)

	func @ConcatXT(acListOfStr, cSep)
		return ConcatenateXT(acListOfStr, cSep)

	#>

# Used for natural-coding

func ListOfStrings(paList)
	if @IsListOfStrings(paList)
		return paList
	ok

  /////////////////
 ///   CLASS   ///
/////////////////

class stzStrings from stzListOfStrings

class stzListOfStrings from stzList

	@oQStrList	# Qt object holding the content of the list

	  #-----------#
	 #    INIT   #
	#-----------#

	// Initiates the object from a QStringList or a normal list of strings

	def init(pList)

		if IsQStringList(pList)
			@oQStrList = pList

		else
			try
				@oQStrList = new QStringList()	
				nLen = len(pList)
	
				for i = 1 to nLen
					@oQStrList.append(pList[i])	
				next
	
			catch
				StzRaise([
					:Where = "stzListOfStrings > Init()",
					:What = "Can't create the list of strings",
					:Why  = "Incorrect param type",
					:Todo = "Provide a QStringList object or a list of strings."
				])
			done
		ok

		if KeepingHistory() = TRUE
			This.AddHistoricValue(This.Content())
		ok

	  #---------------#
	 #    GENENRAL   #
	#---------------#

	def QStringListObject()
		return @oQStrList

	def Content()

		acResult = []
		nLen = @oQStrList.count()

		for i = 0 to nLen - 1
			acResult + This.@oQStrList.at(i)	
		next

		return acResult

		def Strings()
			return This.Content()
	
			def StringsQ()
				return This.StringsQR(:stzList)
	
			def StringsQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Strings() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Strings() )
	
				other
					StzRaise("Unsupported return type!")
				off
			
	def Copy()
		return new stzListOfStrings( This.Content() )

	def String(n)
		return @oQStrList.at(n-1)


	  #---------------------------------------------#
	 #  GETTING THE NUMBER OF STRINGS IN THE LIST  #
	#---------------------------------------------#

	def NumberOfStrings()
		nResult = len(This.Content())
		return nResult

		def NumberOfItems()
			return This.NumberOfStrings()

		def Size()
			return This.NumberOfStrings()

		def HowManyStrings()
			return This.NumberOfStrings()

		def HowManyItems()
			return This.NumberOfStrings()

	  #--------------------------------------#
	 #  GETTING THE NTH STRING IN THE LIST  #
	#--------------------------------------#

	def NthString(n)
		return @oQStrList.at(n-1)

		def NthStringQ(n)
			return new stzString(This.NthString(n))

		def NthItem(n)
			return This.NthString(n)

			def NthItemQ(n)
				return This.NthStringQ(n)

	def FirstString()
		return This.NthString(1)

		def FirstStringQ()
			return This.NthStringQ(1)

		def FirstItem()
			return This.FirstString()

			def FirstItemQ()
				return This.FirstStringQ()

	def LastString()
		return This.NthString(This.NumberOfStrings())

		def LastStringQ()
			return This.NthStringQ(This.NumberOfStrings())

		def LastItem()
			return This.LastString()

			def LastItemQ()
				return This.LastStringQ()

	  #-------------------------------------------#
	 #    CONVERTING THE LIST OF STRINGS TO...   #
	#-------------------------------------------#

	def ToString()
		cResult = This.ConcatenatedUsing(NL)
		return cResult

		def ToStringQ()
			return new stzString( This.ToString() )

		def ToStzString()
			return This.ToStringQ()

	def ToListOfStzStrings()
		aResult = []
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			aResult + new stzString(This.String(i))
		next
		return aResult

	def ToListOfStzStringsQ()
		return new stzList( This.ToListOfStzStrings() )

	def ToStzList()
		return new stzList( This.Content() )

		def ToListQ()
			return This.ToStzList()


	  #-------------------------------------------------------------#
	 #    APPENDING THE LIST WITH A STRING (AT THE END OF LIST)    #
	#-------------------------------------------------------------#

	def AddString(pcstr)
		if NOT isString(pcstr)
			StzRaise("Incorrect param type! pcstr must be string.")
		ok

		This.QStringListObject().append(pcstr)


		def AddStringQ(pcstr)
			This.AddString(pcstr)
			return This

		def Append(pcstr)
			This.AddString(pcstr)

			def AppendQ(pcstr)
				This.Append(pcstr)
				return This

		def AppendWith(pcstr)
			This.AddString(pcstr)

			def AppendWithQ(pcstr)
				This.AppendWith(pcstr)
				return This

		def Add(pcstr)
			This.AddString(pcstr)

			def AddQ(pcstr)
				This.Add(pcstr)
				return This

	  #--------------------------------------------------------------------#
	 #    PREPENDING THE LIST WITH A STRING (AT THE BEGINNING OF LIST)    #
	#--------------------------------------------------------------------#
			
	def Prepend(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcstr must be a string.")
		ok

		This.QStringListObject().prepend(pcstr)

		
		def PrependQ(pcstr)
			This.Prepend(pcstr)
			return This

		def PrependWith(pcstr)
			This.Prepend(pcstr)

			def PrependWithQ(pcstr)
				This.PrependWith(pcstr)
				return This

	  #--------------------------------#
	 #  UPDATING THE LIST OF STRINGS  #
	#--------------------------------#

	def Update(pNewListOfStr)
		if CheckParams()
			if isList(pNewListOfStr) and Q(pNewListOfStr).IsWithOrByOrUsingNamedParam()
				pNewListOfStr = pNewListOfStr[2]
			ok
		ok

		if IsQStringListObject(pNewListOfStr)
			@oQStrList = pNewListOfStr

		but @IsListOfString(pNewListOfStr)
			This.QStringListObject().clear()
			nLen = len(pNewListOfStr)

			for i = 1 to nLen
				This.QStringListObject().append(pNewListOfStr[i])	
			next

		else
			StzRaise("Param you provided is not a list of strings!")
	
		ok

		if KeepingHistory() = TRUE
			This.AddHistoricValue(This.Content())
		ok

		#< @FunctionFluentForm

		def UpdateQ(pNewListOfStr)
			This.Update(pNewListOfStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(pNewListOfStr)
			This.Update(pNewListOfStr)

			def UpdateWithQ(pNewListOfStr)
				return This.UpdateQ(pNewListOfStr)

		#>

	  #====================================================#
	 #  CONCATENATING THE STRINGS OF THE LIST OF STRINGS  #
	#====================================================#

	def Concatenate()
		#< @QtBased >

		acResult = This.QStringListObject().join("")
		return acResult

		def ConcatenateQ()
			return new stzString( This.Concatenate() )

		def Join()
			return This.Concatenate()

			def JoinQ()
				return This.ConcatenateQ()

	def Concatenated()
		return This.Concatenate()

		def Joined()
			return This.Concatenated()

	  #-----------------------------------------------------#
	 #  CONCATENATING THE STRINGS USING A GIVEN SEPARATOR  #
	#-----------------------------------------------------#

	def ConcatenateUsing(pcStr)
		#< @QtBased >

		acResult = This.QStringListObject().join(pcStr)
		return acResult

		def ConcatenateUsingQ(pcStr)
			return new stzString( This.ConcatenateUsing(pcStr) )

		def JoinUsing()
			return This.ConcatenateUsing(pcStr)

			def JoinUsingQ(pcStr)
				return This.ConcatenateUsingQ(pcStr)

	def ConcatenatedUsing(pcStr)
		return This.ConcatenateUsing(pcStr)

		def JoinedUsing(pcStr)
			return This.ConcatenatedUsing(pcStr)

	  #----------------------------------------------------------------#
	 #  CONCATENATING THE STRINGS OF THE LIST OF STRINGS -- EXTENDED  #
	#----------------------------------------------------------------#

	def ConcatenateXT(p)
		#< @QtBased >

		if isString(p)
			return This.ConcatenateUsing(p)

		but isList(p)
			oList = new stzList(p)
			if oList.IsUsingNamedParam()
				return This.ConcatenateUsing(p[2])

			but len(p) = 2 and

			    Q(p[1]).IsUsingNamedParam() and
			    Q(p[2]).IsLastSepNamedParam()

				return This.ConcatenateAndChangeLastSep(p[1][2], p[2][2])
			ok

		else
			return This.Concatenate()
		ok

		def ConcatenateXTQ(p)
			return new stzString( This.ConcatenateXT(p) )

		def JoinXT(p)
			return This.ConcatenateXT(p)

			def JoinXTQ(p)
				return This.ConcatenateXTQ(p)

	def ConcatenatedXT(p)
		return This.ConcatenateXT(p)

		def JoinedXT(p)
			return This.ConcatenatedXT(p)

	  #====================================#
	 #  SORTING THE STRINGS IN ASCENDING  #
	#====================================#

	def SortInAscending()
		This.QStringListObject().sort()

		#< @FunctionAlternativeForms

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def SortUp()
			This.SortInAscending()

			def SortUpQ()
				return This.SortInAscendingQ()

		#>

	def SortedInAscending()
		oQCopy = This.QStringListObject()
		oQCopy.sort()

		return QStringListContent(oQCopy)

		def SortedUp()
			return This.SortedInAscending()

	  #-------------------------------------#
	 #  SORTING THE STRINGS IN DESCENDING  #
	#-------------------------------------#

	def SortInDescending()
		This.Update( This.QStringListObject().sort() )

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

			def SortDownQ()
				return This.SortInDescendingQ()

	def SortedInDescending()
		acResult = This.QStringListObject().sort()
		return acResult

		def SortedDown()
			return This.SortedInDescending()


	  #---------------------------------------------------------#
	 #     STRINGS CONTAINING A GIVEN SUBSTRING (FILTERING)    #
	#---------------------------------------------------------#

	def FilterCS(pcSubStr, pCaseSensitive)

		if CheckingParams()

			if isList(pcSubStr) and Q(pcSubStr).IsUsingOrByNamedParam()
				pcSubStr = pcSubStr[2]
			ok
	
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		# Resolving pCaseSensitive value

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		# Doing the job
			 
		oQList = This.QStringListObject().filter(pcSubStr, pCaseSensitive)
		bResult = QStringListContent(oQList)

		return bResult

		#< @FunctionfluentForm

		def FilterCSQ(pcSubStr, pCaseSensitive)
			This.FilterCS(pcSubStr, pCaseSensitive)
			return This

		def FilterCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FilterCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.FilterCS(pcSubStr, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def Filter(pcSubStr)
		return This.FilterCS(pcSubStr, TRUE)

		#< @FunctionfluentForm

		def FilterQ(pcSubStr)
			This.Filter(pcSubStr)
			return This

		def FilterQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Filter(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Filter(pcSubStr) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	  #--------------------------------------------------#
	 #     BOXING THE STRINGS IN THE LIST OF STRINGS    #
	#--------------------------------------------------#
	
	def Box() # Understand it as a verb : boxing each string in the list of strings!
		return This.BoxXT([])

		def BoxQ()
			return new stzListOfStrings( This.Box() )

		def Boxed()
			return This.BoxQ().Content()
	
	def BoxDashed()
		return This.BoxXT([ :Line = :Dashed ])

		def BoxDashedQ()
			return new stzListOfStrings( This.BoxDashed() )

		def BoxedDashed()
			return This.BoxDashedQ().Content()
	
	def BoxRound()
		return This.BoxXT([ :AllCorners = :Round ])

		def BoxRoundQ()
			return new stzListOfStrings( This.BoxRound() )

		def BoxedRound()
			return This.BoxRoundQ().Content()

	def BoxRoundDashed()
		return This.BoxXT([ :Line = :Dashed, :AllCorners = :Round ])

		def BoxRoundDashedQ()
			return new stzListOfStrings( This.BoxRoundDashed() )

		def BoxedRoundDashed()
			return This.BoxRoundDashedQ().Content()
	
	def BoxDashedRound()
		return This.BoxRoundDashed()

		def BoxDashedRoundQ()
			return new stzListOfStrings( This.BoxDashedRound() )

		def BoxedDashedRound()
			return This.BoxDashedRoundQ().Content()

	def BoxXT(paBoxOptions)

		/*
		Example:

		? StzListOfStringsQ([ "CAIRO", "TUNIS", "PARIS" ]).BoxXT([

			:Line = :Solid,	# or :Dashed
		
			:AllCorners = :Round # can also be :Rectangualr

			# Or you can specify evey corner like this:
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ]

		]).Content()

		--> Gives:
			╭───┬───┬───┬───┬───╮
			│ C │ A │ I │ R │ O │
			╰───┴───┴───┴───┴───╯
			╭───┬───┬───┬───┬───╮
			│ T │ U │ N │ I │ S │
			╰───┴───┴───┴───┴───╯
			╭───┬───┬───┬───┬───╮
			│ P │ A │ R │ I │ S │
			╰───┴───┴───┴───┴───╯	
			*/
		
		if StzListQ(paBoxOptions).IsTextBoxedOptionsNamedParam()

			aResult = []

			if paBoxOptions[ :EachChar ] = TRUE

				for str in This.ListOfStrings()
					aResult + StzListOfCharsQ(str).BoxXT(paBoxOptions)
				next

			else

				for str in This.ListOfStrings()
					aResult + StzStringQ(str).BoxXT(paBoxOptions)
				next

			ok

			return aResult

		else

			StzRaise(stzListOfStringsError(:paBoxOptions))
		ok		

		def BoxXTQ(paBoxOptions)
			This.BoxXT(paBoxOptions)
			return This

	def BoxedXT(paBoxOptions)

		acResult = This.Copy().BoxXTQ(paBoxOptions).Content()
		return acResult

	  #===============================================#
	 #    ALIGNING THE STRINGS TO A GIVEN DIRECTION   #
	#===============================================#

	def Align( pcDirection )
		if isList(pcDirection) and ( Q(pcDirection).IsOneOfTheseNamedParams([ :Direction, :Going ]) or
			Q(pcDirection).IsToNamedParam() )

			pcDirection = pcDirection[2]
		ok

		if NOT isString(pcDirection)
			StzRaise("Incorrect param type! pcDirection must be a string")
		ok		

		switch pcDirection
		on :Left
			This.AlignToLeft()

		on :Right
			This.AlignToRight()

		on :Center // or :Centered     (TODO: report bug)
			This.AlignToCenter()

		on :Centered
			This.AlignToCenter()

		on :Justify or :Justified
			This.Justify()

		other
			StzRaise("Unsupported direction type!")
		off

		# @functionFluentForms

		def AlignQ( pcDirection )
			This.Align( pcDirection )
			return This

		def AlignQC(pcDirection)
			oResult = This.Copy().Align(pcDirection)
			return oResult

		#>

		#< @FuntionAlternativeForms

		def AlignTo(pcDirection)
			This.Align( pcDirection )

			def AlignToQ(pcDirection)
				This.AlignTo(pcDirection)
				return This

			def AlignToQC(pcDirection)
				return This.AlignQC(pcDirection)

		def Adjust(pcDirection)
			This.Align( pcDirection )

			def AdjustQ(pcDirection)
				This.AlignTo(pcDirection)
				return This

			def AdjustQC(pcDirection)
				return This.AlignQC(pcDirection)

		def AdjustTo(pcDirection)
			This.Align( pcDirection )

			def AdjustToQ(pcDirection)
				This.AlignTo(pcDirection)
				return This

			def AdjustToQC(pcDirection)
				return This.AlignQC(pcDirection)

		#>

	def Aligned(pcDirection)
		acResult = This.Copy().AlignQ(pcDirection).Content()
		return acResult

		def AlignedTo(pcDirection)
			return This.Aligned(pcDirection)

		def Adjusted(pcDirection)
			return This.Aligned(pcDirection)

		def AdjustedTo(pcDirection)
			return This.Aligned(pcDirection)

	  #---------------------------------------#
	 #    ALIGNING THE STRINGS -- EXTENDED   #
	#---------------------------------------#

	def AlignXT(pnWidth, pcChar, pcDirection)
		# cChar is the char to fill the 'blanks" with
		# cDirection --> :Left, :Right, :Center, :Justified
		
		if isList(pnWidth) and Q(pnWidth).IsWidthNamedParam()
			pnWidth = pnWidth[2]
		ok
		
		if isList(pcChar) and ( Q(pcChar).IsUsingNamedParam() or
			Q(pcChar).IsCharNamedParam() )

			pcChar = pcChar[2]
		ok

		if isList(pcDirection) and ( Q(pcDirection).IsOneOfTheseNamedParams([ :Direction, :Going ]) or
			Q(pcDirection).IsToNamedParam() )

			pcDirection = pcDirection[2]
		ok

		# Doing the job

		acContent = This.Content()
		nLen = len(acContent)

		if pnWidth = :Max
			pnWidth = 0
			anWidths = []
			for i = 1 to nLen
				anWidths + StzStringQ(acContent[i]).NumberOfChars()
			next

			pnWidth = Max(anWidths)
		ok

		for i = 1 to nLen
			cStrAligned = StzStringQ(acContent[i]).AlignXTQ(pnWidth, pcChar, pcDirection).Content()
			This.ReplaceStringAtPosition(i, cStrAligned )
		next

		#< @FunctionFluentForm

		def AlignXTQ(pnWidth, pcChar, pcDirection)
			This.AlignXT(pnWidth, pcChar, pcDirection)
			return This

		#>

		#< @FunctionAlternativeForm

		def AdjustXT(pnWidth, pcChar, pcDirection)
			This.AlignXT(pnWidth, pcChar, pcDirection)

			def AdjustXTQ(pnWidth, pcChar, pcDirection)
				return This.AlignXTQ(pnWidth, pcChar, pcDirection)

		#>

	def AlignedXT(pnWidth, pcChar, pcDirection)
		aResult = This.Copy().AlignXTQ(pnWidth, pcChar, pcDirection).Content()
		return aResult
	
		def AdjustedXT(pnWidth, pcChar, pcDirection)
			return This.AlignedXT(pnWidth, pcChar, pcDirection)

	  #====================================#
	 #  ALIGNING THE STRINGS TO THE LEFT  #
	#====================================#

	def LeftAlign()
		This.LeftAlignXT( :Max, " " )

		#< @FunctionFluentForm

		def LeftAlignQ()
			This.LeftAlign()
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignToLeft()
			This.LeftAlign()

		def LeftAdjust()
			This.LeftAlign()
	
			def LeftAdjustQ()
				return This.LeftAlignQ()
	
		def AdjustToLeft()
			This.LeftAlign()

			def AdjustToLeftQ()
				return This.LeftAlignQ()

		#>

	def LeftAligned()
		acResult = This.Copy().LeftAlignQ().Content()
		return acResult

		#< @FunctionAlternativeForms

		def AlignedToLeft()
			return This.LeftAligned()

		def LeftAdjusted()
			return This.LeftAligned()
	
		def AdjustedToLeft()
			return This.LeftAligned()

		#>

	  #------------------------------------------------#
	 #  ALIGNING THE STRINGS TO THE LEFT -- EXTENDED  #
	#------------------------------------------------#

	def LeftAlignXT(pnWidth, pcChar)
		This.AlignXT(pnWidth, pcChar, :Left)

		#< @FunctionFluentForm

		def LeftAlignXTQ(pnWidth, pcChar)
			This.LeftAlignXT(pnWidth, pcChar)
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignLeftXT(pnWidth, pcChar)
			This.LeftAlignXT(pnWidth, pcChar)

			def AlignLeftXTQ(pnWidth, pcChar)
				return This.LeftAlignXTQ(pnWidth, pcChar)

		def AlignToLeftXT(pnWidth, pcChar)
			This.LeftAlignXT(pnWidth, pcChar)

			def AlignToLeftXTQ(pnWidth, pcChar)
				return This.LeftAlignXTQ(pnWidth, pcChar)

		#>

	def LeftAlignedXT(pnWidth, pcChar)
		aResult = This.Copy().LeftAlignXTQ(pnWidth, pcChar).Content()
		return aResult

		#< @FunctionAlternativeForms

		def AlignedToLeftXT(pnWidth, pcChar)
			return This.LeftAlignedXT(pnWidth, pcChar)
	
		def AdjustedToLeftXT(pnWidth, pcChar)
			return This.LeftAlignedXT(pnWidth, pcChar)

		#>

	  #---------------------------------------#
	 #    ALIGNING THE STRINGS TO THE LEFT   #
	#---------------------------------------#

	def AlignToLeftUsing(pcChar)
		AlignXT(:Max, pcChar, :Left)

		def AlignToLeftUsingQ(pcChar)
			This.AlignToLeftUsing(pcChar)
			return This

		def AdjustToLeftUsing(pcChar)
			This.AlignToLeftUsing(pcChar)

			def AdjustToLeftUsingQ(pcChar)
				return This.AlignToLeftUsingQ(pcChar)

	def AlignedToLeftUsing(pcChar)
		cResult = This.Copy().AlignToLeftUsingQ(pcChar).Content()
		return cResult

		def AdjustedToLeftUsing(pcChar)
			return This.AlignedToLeftUsing(pcChar)

	  #=====================================#
	 #  ALIGNING THE STRINGS TO THE RIGHT  #
	#=====================================#

	def RightAlign()
		This.RightAlignXT( :Max, " " )

		#< @FunctionFluentForm

		def RightAlignQ()
			This.RightAlign()
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignToRight()
			This.RightAlign()

			def AlignToRightQ()
				return This.RightAlignQ()

		def AdjustToRight()
			This.RightAlign()

			def AdjustToRightQ()
				return This.RightAlignQ()

		#>

	def RightAligned()
		acResult = This.Copy().RightAlignQ().Content()
		return acResult

		#< @FunctionAlternativeForms

		def AlignedToRight()
			return This.RightAligned()

		def RightAdjusted()
			return This.RightAligned()

		def AdjustedToRight()
			return This.RightAligned()

		#>

	  #-------------------------------------------------#
	 #  ALIGNING THE STRINGS TO THE RIGHT -- EXTENDED  #
	#-------------------------------------------------#

	def RightAlignXT(pnWidth, pcChar)
		This.AlignXT(pnWidth, pcChar, :Right)

		#< @FunctionFluentForm

		def RightAlignXTQ(pnWidth, pcChar)
			This.RightAlignXT(pnWidth, pcChar)
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignRightXT(pnWidth, pcChar)
			This.RightAlignXT(pnWidth, pcChar)

			def AlignRightXTQ(pnWidth, pcChar)
				return This.RightAlignXTQ(pnWidth, pcChar)

		def AlignToRightXT(pnWidth, pcChar)
			This.RightAlignXT(pnWidth, pcChar)

			def AlignToRightXTQ(pnWidth, pcChar)
				return This.RightAlignXTQ(pnWidth, pcChar)

		def RightAdjustXT(pnWidth, pcChar)
			This.RightAlignXT(pnWidth, pcChar)

			def RightAdjustXTQ(pnWidth, pcChar)
				return This.RightAlignXTQ(pnWidth, pcChar)

		#>

	def RightAlignedXT(pnWidth, pcChar)
		aResult = This.Copy().RightAlignXTQ(pnWidth, pcChar).Content()
		return aResult

		#< @FunctionAlternativeForms

		def AlignedToRightXT(pnWidth, pcChar)
			return This.RightAlignedXT(pnWidth, pcChar)

		def RightAdjustedXT(pnWidth, pcChar)
			return This.RightAlignedXT(pnWidth, pcChar)

		def  AdjustedToRightXT(pnWidth, pcChar)
			return This.RightAlignedXT(pnWidth, pcChar)

	  #----------------------------------------#
	 #    ALIGNING THE STRINGS TO THE RIGHT   #
	#----------------------------------------#

	def AlignToRightUsing(pcChar)
		AlignXT(:Max, pcChar, :Right)

		def AlignToRightUsingQ(pcChar)
			This.AlignToRightUsing(pcChar)
			return This

		def AdjustToRightUsing(pcChar)
			This.AlignToRightUsing(pcChar)

			def AdjustToRightUsingQ(pcChar)
				return This.AlignToRightUsingQ(pcChar)

	def AlignedToRightUsing(pcChar)
		cResult = This.Copy().AlignToRightUsingQ(pcChar).Content()
		return cResult

		def AdjustedToRightUsing(pcChar)
			return This.AlignedToRightUsing(pcChar)

	  #======================================#
	 #  ALIGNING THE STRINGS TO THE CENTER  #
	#======================================#

	def CenterAlign()
		This.CenterAlignXT( :Max, " " )

		#< @FunctionFluentForm

		def CenterAlignQ()
			This.CenterAlign()
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignToCenter()
			This.CenterAlign()

		def CenterAdjust()
			return This.CenterAlign()

		def AdjustToCenter()
			This.CenterAlign()

		def Center()
			This.CenterAlign()

		#>

	def CenterAligned()
		acResult = This.Copy().CenterAlignQ().Content()
		return acResult

		#< @FunctionAlternativeForms

		def AlignedToCenter()
			return This.CenterAligned()

		def CenterAdjusted()
			return This.CenterAligned()

		def Centered()
			return This.CenterAligned()

		#>

	  #--------------------------------------------------#
	 #  ALIGNING THE STRINGS TO THE CENTER -- EXTENDED  #
	#--------------------------------------------------#

	def CenterAlignXT(pnWidth, pcChar)
		This.AlignXT(pnWidth, pcChar, :Center)

		#< @FunctionFluentForm

		def CenterAlignXTQ(pnWidth, pcChar)
			This.CenterAlignXT(pnWidth, pcChar)
			return This

		#>

		#< @FunctionAlternativeForms

		def AlignCenterXT(pnWidth, pcChar)
			This.CenterAlignXT(pnWidth, pcChar)

			def AlignCenterXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		def AlignToCenterXT(pnWidth, pcChar)
			This.RightCenterXT(pnWidth, pcChar)

			def AlignToCenterXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		def CenterAdjustXT(pnWidth, pcChar)
			return This.CenterAlignXT(pnWidth, pcChar)

			def CenterAdjustXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		def AdjustCenterXT(pnWidth, pcChar)
			This.CenterAlignXT(pnWidth, pcChar)

			def AdjustCenterXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		def AdjustToCenterXT(pnWidth, pcChar)
			This.RightCenterXT(pnWidth, pcChar)

			def AdjustToCenterXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		def CenterXT(pnWidth, pcChar)
			This.RightCenterXT(pnWidth, pcChar)

			def CenterXTQ(pnWidth, pcChar)
				return This.CenterAlignXTQ(pnWidth, pcChar)

		#>

	def CenterAlignedXT(pnWidth, pcChar)
		aResult = This.Copy().CenterAlignXTQ(pnWidth, pcChar).Content()
		return aResult

		#< @FunctionAlternativeForms

		def AlignedToCenterXT(pnWidth, pcChar)
			return This.CenterAlignedXT(pnWidth, pcChar)

		def CenteredXT(pnWodth, pcChar)
			return This.CenterAlignedXT(pnWidth, pcChar)

		#>

	  #==========================#
	 #  JUSTIFYING THE STRINGS  #
	#==========================#

	def Justify()
		This.JustifyXT(:Max, " ")

		def JustifyQ()
			This.Justify()
			return This

	def Justified()
		aResult = This.Copy().JustifyQ().Content()
		return aResult

	  #--------------------------------------#
	 #  JUSTIFYING THE STRINGS -- EXTENDED  #
	#--------------------------------------#

	def JustifyXT(pnWidth, pcChar)
		This.AlignXT(pnWidth, pcChar, :Justified)

		def JustifyXTQ(pnWidth, pcChar)
			This.JustifyXT(pnWidth, pcChar)
			return This

	def JustifiedXT(pnWidth, pcChar)
		aResult = This.Copy().JustifyXTQ(pnWidth, pcChar).Content()
		return aResult

	  #=========================#
	 #  SPLITTING EACH STRING  #
	#=========================#

	/*
	NOTE: After adding Perform() and Yield() function to this class,
	it becomes very easy to use any methdod from stzString and apply
	to the strings of this list.

	For example, the following function Split(), that splits all the
	strings using a given separator (was written before Yield() was
	created), can be rewritten in one line like this:

	This.Yield('{ Q(@str).Split(cSep) }')

	NOTE: This version is more expressive but a bit less performant
	because Yield() uses eval() in the runtime. So, please, use it
	responsibly, by profiling your code for performance.

	*/

	def Split(cSep)
		/* Example

		o1 = new stzListOfStrings([
			"abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp"
		])
		
		? o1.Split(";")	   #--> [
				   # 		[ "abc", "123", "tunis", "rgs" ],
				   # 		[ "jhd", "343", "gafsa", "ghj" ],
				   # 		[ "lki", "112", "beja" , "okp" ]
				   #     ]
		*/

		if isList(cSep) and StzListQ(cSep).IsUsingOrWithOrByNamedParam()
			cSep = cSep[2]
		ok

		aStzStr = This.ToListOfStzStrings()

		nLen = len(aStzStr)

		aResult = []
	
		for i = 1 to nLen
			aResult + aStzStr[i].Split(cSep)
		next

		return aResult

		#< @FunctionFluentForm

		def SplitQ(cSep)
			return new stzListOfLists( This.Split(cSep) )

		def SplitQR(cSep, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Split(cSep) )

			on :stzListOfLists
				return new stzListOfLists( This.Split(cSep) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Split(cSep) )

			other
				StzRaise([
					:Where = "stzListOfStrings (8611) > SplitQR()",
					:What  = "Can't cast the object to the type you requested!",
					:Why   = "The type you required is not supported",
					:Todo  = "Opt for an other type, implement it by yourself, or create the type of object uisng new."
				])
			off

		#>

		#< @FunctionAlternativeForm

		def SplitStrings(cSep)
			return This.Split(cSep)

			def SplitStringsQ(cSep)
				return This.SplitQ(cSep)

			def SplitStringsQR(cSep, pcReturnType)
				return This.SplitQR(cSep, pcReturnType)

		def SplitEachString(cSep)
			return This.Split(cSep)

			def SplitEachStringQ(cSep)
				return This.SplitQ(cSep)

			def SplitEachStringQR(cSep, pcReturnType)
				return This.SplitQR(cSep, pcReturnType)

		def SplitEach(cSep)
			return This.Split(cSep)

			def SplitEachQ(cSep)
				return This.SplitQ(cSep)

			def SplitEachQR(cSep, pcReturnType)
				return This.SplitQR(cSep, pcReturnType)

		#>

	def Splitted(cSep)
		aResult = This.Copy().SplitQ(cSep).Content()
		return aResult

		def StringsSplitted(cSep)
			return This.Splitted(cSep)

		def EachStringSplitted(cSep)
			return This.Splitted(cSep)

	  #----------------------------------------------------------#
	 #  GETTING EACH NTH SUBSTRING AFTER SPLITTING THE STRINGS  #
	#----------------------------------------------------------#

	def NthSubstringsAfterSplittingStringsUsing(n, cSep)
		/* Example

		o1 = new stzListOfStrings([
			"abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp"
		])
		
		? o1.Split(";")	   #--> [
				   # 		[ "abc", "123", "tunis", "rgs" ],
				   # 		[ "jhd", "343", "gafsa", "ghj" ],
				   # 		[ "lki", "112", "beja" , "okp" ]
				   #     ]
		
		? o1.Split(";")[1] #--> [ "abc", "123", "tunis", "rgs" ]
		? o1.Split(";")[2] #--> [ "jhd", "343", "gafsa", "ghj" ]
		? o1.Split(";")[3] #--> [ "lki", "112", "beja" , "okp" ]
		
		? o1.NthSubstringsAfterSplittingStringsUsing(3, ";")
		#--> [ "tunis", "gafsa", "beja" ]
		
		# The same function can be expressed like this
		? o1.NthSubstrings(3, :AfterSplittingStringsUsing = ";") #--> [ "tunis", "gafsa", "beja" ]

		*/

		aStzStr = This.ToListOfStzStrings()
		nLen = len(aStzStr)

		aResult = []

		for i = 1 to nLen
			aResult + aStzStr[i].NthSubstringAfterSplittingStringUsing(n, cSep)
		next

		return aResult

		#< @FunctionFluentForm

		def NthSubstringsAfterSplittingStringsUsingQ(n, cSep)
			return new stzListOfStrings( This.NthSubstringsAfterSplittingStringsUsing(n, cSep) )

		#>

	def NthSubstrings(n, acSep)

		if isNumber(n) and
		   @IsListOfStrings(acSep) and
		   len(acSep) = 2 and
		   acSep[1] = :AfterSplittingStringsUsing

			return This.NthSubstringsAfterSplittingStringsUsing(n, acSep[2])
		else
			StzRaise("Incorrect param types!")
		ok

		#< @FunctionFluentForm

		def NthSubstringsQ(n, acSep)
			return new stzListOfStrings( This.NthSubstrings(n, acSep) )

		#>

	  #------------------------------#
	 #    SIMPLIFYING EACH STRING   #
	#------------------------------#
	/* NOTE

	  Could be rewritten in one line like this:

	  This.Peroform(' @str = Q(@str).Simplified() ')

	*/

	def Simplify()

		aStzStr = This.ListOfStrings()
		nLen = len(aStzStr)

		acResult = []

		for i = 1 to nLen
			acResult + aStzStr[i].Simplified()
		next

		This.Update( acResult )

		#< @FunctionFluentForm

		def SimplifyQ()
			This.Simplify()
			return This
		
		#>

	def Simplified()
		aResult = This.Copy().SimplifyQ().Content()

	  #-----------------------------#
	 #    SCRIPTS OF ALL STRINGS   #
	#-----------------------------#

	/* TODO: Move to stzListOfTexts when created.
		--> stzString and stzListOfStrings should not be aware of
		    things like script, language, and so on.

		    But stzText and (future) stzListOfTexts should.
	*/

	def Scripts()
		acResult = []

		acContent = This.ListOfStrings()
		nLen = len(acContent)

		for i = 1 to nLen
			acResult + StzTextQ(acContent[i]).Script()
		next

		return acResult

		def ScriptsQ()
			return This.ScriptsQR(:stzList)

		def ScriptsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Scripts() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Scripts() )

			other
				StzRaise("Unsupported return type!")
			off

	  #------------#
	 #    MISC.   #
	#------------#

	def IsStzListOfStrings()
		return TRUE

	def stzType()
		return :stzListOfStrings

		def ClassName()
			return This.stzType()

	  #------------------------------------#
	 #  TRIMMING THE STRINGS IN THE LIST  #
	#------------------------------------#

	def TrimStrings()
		oastzStr = This.ToListOfStzStrings()
		nLen = len(oastzStr)
		
		for i = 1 to nLen
			This.@oQStrList.replace(i-1, oastzStr[i].Trimmed())
		next

		#< @FunctionFluentForm

		def TrimStringsQ()
			This.TrimStrings()
			return This

		#>

		#< @FunctionAlternativeForms

		def Trim()
			This.TrimStrings()

			def TrimQ()
				return This.TrimStringsQ()

		def TrimEach()
			This.TrimStrings()

			def TrimEachQ()
				return This.TrimStringsQ()

		#--

		def StripStrings()
			This.TrimStrings()

			def StripStringsQ()
				return This.TrimStringsQ()

		def StripEach()
			This.TrimStrings()

			def StripEachQ()
				return This.TrimStringsQ()

		#>

	def StringsTrimmed()
		acResult = This.Copy().TrimStringsQ().Content()
		return acResult

		def StringsStripped()
			return This.Trimmed()

	  #------------------------------------#
	 #  INFEREING TYPES FROM THE STRINGS  #
	#------------------------------------#

	def InfereTypes()
		aResult = []
		acContent = This.Content()
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			aResult + Q(acContent[i]).InfereType()
		next
	
		return aResult

	  #====================================#
	 #  REMOVING SPACES FROM EACH STRING  #
	#====================================#

	def RempoveSpacesFromEachString()

		aoStzStr = This.ToListOfStzStrings()
		nLen = len(aoStzStr)

		acResult = []

		for i = 1 to nLen
			acResult + aoStzStr[i].SpacesRemoved()
		next

		This.Update(acResult)

		def RemoveSpacesFromEachStringQ()
			This.RempoveSpacesFromEachString()
			return This

		def RemoveSpaces()
			This.RempoveSpacesFromEachString()

			def RemoveSpacesQ()
				This.RemoveSpaces()
				return This

	def SpacesRemovedFromEachString()
		acResult = This.Copy().RemoveSpacesFromEachStringQ().Content()
		return acResult

		def SpacesRemoved()
			return This.SpacesRemovedFromEachString()

		def StringsWithoutSpace()
			return This.SpacesRemovedFromEachString()

		def WithoutSpaces()
			return This.SpacesRemovedFromEachString()

			#< @FunctionMisspelledForm

			def withoutSapces()
				return This.SpacesRemovedFromEachString()

			#>

	  #==============================================#
	 #  GETTING THE LIST OF SUBSTRONGS IN THE LIST  #
	#==============================================#

	// A substrOng is any string containg other strings from the list
	
	def SubStrongsCS(pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([
			"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
		])
		
		? o1.SubStrongs()
		#--> [ "Ring" ]
		# In fact, "Ring" contains "in", and "in" is an item among the list

		*/

		acResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			for j = 1 to nLen
				if j = i
					loop
				ok

				if Q(acContent[i]).ContainsCS(acContent[j], pCaseSensitive)
					acResult + acContent[i]
				ok
			next

		next

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def SubStrongs()
		return This.SubStrongsCS(TRUE)

	  #-----------------------------------------------#
	 #  GETTING THE LIST OF SUBSTREACKS IN THE LIST  #
	#-----------------------------------------------#

	// A SubStrink is any string contained IN other strings from the list

	def SubStrinksCS(pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([
			"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
		])
		
		? o1.SubStrinks()
		#--> [ "in" ]
		# In fact "in" is contained in "Ring" and "Ring" is an item from the list
		*/

		acResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			for j = 1 to nLen
				if j = i
					loop
				ok

				if Q(acContent[i]).IsContainedInCS(acContent[j], pCaseSensitive)
					acResult + acContent[i]
				ok

			next

		next

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def SubStrinks()
		return This.SubStrinksCS(TRUE)

	  #-----------------------------------#
	 #  SUBSTRONGS AND THEIR SubStrinkS  #TODO
	#-----------------------------------#

	def SubStrongsAndTheirSubStrinksCS(pCaseSensitive)
		/* ... */

		def SubStrongsAndSubStrinksCS(pCaseSensitive)
			return This.SubStrongsAndTheirSubStrinksCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStrongsAndTheirSubStrinks()
		return This.SubStrongsAndTheirSubStrinksCS(TRUE)

		def SubStrongsAndSubStrinks()
			return This.SubStrongsAndTheirSubStrinks()

	  #-----------------------------------#
	 #  SubStrinkS AND THEIR SUBSTRONGS  #TODO
	#-----------------------------------#

	def SubStrinksAndTheirSubStrongsCS(pCaseSensitive)
		/* ... */

		def SubStrinksAndSubStrongsCS(pCaseSensitive)
			return This.SubStrinksAndTheirSubStrongsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStrinksAndTheirSubStrongs()
		return This.SubStrinksAndTheirSubStrongsCS(TRUE)

		def SubStrinksAndSubStrongs()
			return This.SubStrinksAndTheirSubStrongs()

	  #----------------------------------#
	 #  FINDING SUBSTRONGS IN THE LIST  #TODO
	#----------------------------------#

	def FindSubStrongsCS(pCaseSensitive)
		/* ... */

		def FindAllSubStrongsCS(pCaseSensitive)
			return This.FindSubStrongsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStrongs()
		/* ... */

		def FindAllSubStrongs()
			return This.FindSubStrongs()

	  #----------------------------------#
	 #  FINDING SubStrinkS IN THE LIST  #TODO
	#----------------------------------#

	def FindSubStrinksCS(pCaseSensitive)
		/* ... */

		def FindAllSubStrinksCS(pCaseSensitive)
			return This.FindFindSubStrinksCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStrinks()
		/* ... */

		def FindAllSubStrinks()
			return This.FindSubStrinks()


	#==

	# A special function that works for a list of strings, and
	# returns their first char if all the strings have the same
	# char ~> made in the exploration of natural-coding semantics

	# TODO: Think a more general solution for calling any method
	# on any item of the list whatever type it has!

	def FirstCharCS(pCaseSensitive)
		/* EXAMPLE

		o1 = new stzList([ "Ring", "Ruby", "Rust", "Red" ])
		? o1.FirstChar()
		#-> "R"

		*/

		acContent = This.ToListOfStzStrings()
		nLen = len(acContent)

		cResult = acContent[1].FirstChar()

		for i = 2 to nLen
			if NOT acContent[i].FirstCharQ().IsEqualToCS(cResult, pCaseSensitive)
				return NULL
			ok 
		next

		return cResult

		def FirstCharCSQ(pCaseSensitive)
			
			if This.FirstCharCS(pCaseSensitive) = ""
				return AFalseObject()
			else
				return new stzString(This.FirstCharCS(pCaseSensitive))
			ok

		def FirstCharCSQM(pCaseSensitive)
			return @MainObject()

	def FirstChar()
		return This.FirstCharCS(TRUE)

		def FirstCharQ()
			return This.FirstCharCSQ(TRUE)

		def FirstCharQM()
			return @MainObject()

	#===

	def LastCharCS(pCaseSensitive)
		/* EXAMPLE

		o1 = new stzList([ "Ring", "Bing", "Wong" ])
		? o1.LastChar()
		#-> "g"

		*/

		acContent = This.ToListOfStzStrings()
		nLen = len(acContent)

		cResult = acContent[1].LastChar()

		for i = 2 to nLen
			if NOT acContent[i].LastCharQ().IsEqualToCS(cResult, pCaseSensitive)
				return NULL
			ok 
		next

		return cResult

		def LastCharCSQ(pCaseSensitive)
			
			if This.LastCharCS(pCaseSensitive) = ""
				return AFalseObject()
			else
				return new stzString(This.LastCharCS(pCaseSensitive))
			ok

		def LastCharCSQM(pCaseSensitive)
			return @MainObject()

	def LastChar()
		return This.LastCharCS(TRUE)

		def LastCharQ()
			return This.LastCharCSQ(TRUE)

		def LastCharQM()
			return @MainObject()

	#==

	def FirstChars()
		acContent = This.ToListOfStzStrings()
		nLen = len(acContent)

		acResult = []
		
		for i = 1 to nLen
			acResult + acContent[i].FirstChar()
		next

		return acResult

		def FirstCharsQ()
			return new stzList(This.FirstChars())

		def FirstCharsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.FirstChars())

			on :stzListOfChars
				return new stzListOrChars(This.FirstChars())

			on :stzListOfStrings
				return new stzListOfStrings(This.FirstChars())

			other
				StzRaise("Unsupported return type!")
			off

		def FirstCharsQM()
			return @MainObject()

	def LastChars()
		acContent = This.ToListOfStzStrings()
		nLen = len(acContent)

		acResult = []
		
		for i = 1 to nLen
			acResult + acContent[i].LastChar()
		next

		return acResult

		def LastCharsQ()
			return new stzList(This.LastChars())

		def LastCharsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.LastChars())

			on :stzListOfChars
				return new stzListOrChars(This.LastChars())

			on :stzListOfStrings
				return new stzListOfStrings(This.LastChars())

			other
				StzRaise("Unsupported return type!")
			off

		def LastCharsQM()
			return @MainObject()

	  #==================================#
	 #  REPLACING A STRING IN THE LIST  #
	#==================================#

	def ReplaceAt(n, pcNewStr)
		@oQStrList.replace(n-1, pcNewStr)

		def ReplaceAtQ(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)
			return This

		def ReplaceAtPosition(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)
	
			def ReplaceAtPositionQ(n, pcNewStr)
				return This.ReplaceAtQ(n, pcNewStr)

		def ReplaceStringAt(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)

			def ReplaceStringAtQ(n, pcNewStr)
				return This.ReplaceAtQ(n, pcNewStr)

		def ReplaceStringAtPosition(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)

			def ReplaceStringAtPositionQ(n, pcNewStr)
				return This.ReplaceAtQ(n, pcNewStr)

	def ReplacedAt(n, pcNewStr)
		acResult = This.Copy().ReplaceAtQ(n, pcNewStr).Content()
		return acResult

		def StringReplaceAt(n, pcNewStr)
			return This.ReplacedAt(n, pcNewStr)

		def ReplacedAtPosition(n, pcNewStr)
			return This.ReplacedAt(n, pcNewStr)

		def StringReplacedAtPosition(n, pcNewStr)
			return This.ReplacedAt(n, pcNewStr)
