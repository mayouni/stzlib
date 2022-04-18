# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing lists of strings      #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzListOfStringsQ(paList)
	return new stzListOfStrings(paList)

func IsQStringList(p)
	if isObject(p) and classname(p) = "qstringlist"
		return TRUE
	else
		return FALSE
	ok

func IsQStringListObject(p)
	return IsQStringList(p)

func QStringListToList(oQStrList)
	if NOT IsQStringList(oQStrList)
		stzRaise(stzListOfStringsError(:CanNotTransformQStringListToRingList))
	ok

	aResult = []
	for i=0 to oQStrList.size()-1
		aResult + oQStrList.at(i)	
	next

	return aResult

func QStringListToStzListOfStrings(oQStrList)
	return new stzListOfStrings(QStringListToList(oQStrList))

func QStringListContent(poQStrList)
		if IsQStringListObject(poQStrList)
			aResult = []
			for i = 0 to poQStrList.size() - 1
				aResult + poQStrList.at(i)	
			next
			return aResult
		else
			stzRaise("A QStringList Qt object is exepected as a param!")
		ok

	func QStringListToRingList(poQStrList)
		return QStringListContent(poQStrList)

func ListOfStringsToUnicodes(pacListStr)
	return StzListOfStringsQ( pacListStr ).Unicodes()

	#< @FunctionAlternativeForms

	func StringsToUnicodes(pacListStr)
		return ListOfStringsToUnicodes(pacListStr)

	func StringsUnicodes(paListStr)
		return ListOfStringsToUnicodes(pacListStr)

	#>

func ListOfStringsScripts(pacListStr)
	return StzListOfStringsQ( pacListStr ).Scripts()

	#< @FunctionAlternativeForm

	func StringsScripts(pacListStr)
		return ListOfStringsScripts(pacListStr)

	#>

# Used for natural-coding

func ListOfStrings(paList)
	if ListIsListOfStrings(paList)
		return paList
	ok

  /////////////////
 ///   CLASS   ///
/////////////////

class stzListOfStrings from stzList
	
	@oQStrList	# Qt object holding the content of the list

	  #-----------#
	 #    INIT   #
	#-----------#

	// Initiates the object from a QStringList or a normal list of strings
	def init(pList)
	
		if IsQStringList(pList)
			@oQStrList = pList

		but isList(pList) and
		   ( Q(pList).IsEmpty() or Q(pList).IsListOfStrings() )

			@oQStrList = new QStringList()	
			for str in pList
				@oQStrList.append(str)	
			next

		else
			stzRaise([
				:Where = "stzListOfStrings (104) > Init()",
				:What = "Can't create the list of strings.",
				:Why  = "Items of the list you provided are not all strings.",
				:Todo = "Provide a list formed exclusively from strings."
			])
		ok
		
	  #---------------#
	 #    GENENRAL   #
	#---------------#

	def QStringListObject()
		return @oQStrList

	def Content()

		acResult = []

		for i = 0 to This.QStringListObject().size()-1
			acResult + This.QStringListObject().at(i)	
		next

		return acResult

		def StringItems()
			return This.Content()

	def Strings()
		return This.Content()

		def StringsQ()
			return This.StringsQR(:stzList)

		def StringsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Strings() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Strings() )

			other
				stzRaise("Unsupported return type!")
			off
				
			def ListOfStringItems()	
				return This.Content()
	
			def ListOfStrings()	
				return This.Content()

	def StringsW(pcCondition)
		return This.YieldW('@string', pcCondition)

		def StringsWQ(pcCondition)
			return StringsWQR(pcCondition, :stzList)

		def StringsWQR(pcCondition, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringsW(pcCondition) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringsW(pcCondition) )

			other
				stzRaise("Unsupported return type!")
			off

	def Copy()
		oCopy = new stzListOfStrings( This.Content() )
		return oCopy

	  #--------------------------------------------------#
	 #    GETTING THE NUMBER OF STRINGS IN THE LIST     #
	#--------------------------------------------------#

	def NumberOfStringItems()
		return len( This.Content() )

		def NumberOfStrings()
			return This.NumberOfStringItems()


	  #------------------------------------------------------------#
	 #    GETTING THE SIZE IN BYTES OF THE LIST AND ITS ITEMS     #
	#------------------------------------------------------------#

	def SizeInBytes()
		nSizeInBytes = 0
		for str in This.ListOfStrings()
			oBinStr = new stzListOfBytes(str)
			nSizeInBytes += oBinStr.SizeInBytes()
		next
		return nSizeInBytes

		def NumberOfBytes()
			return This.SizeInBytes()

	def SizeInBytesOfEachStringItem()
		anResult = []
		for str in This.ListOfStrings()
			oBinStr = new stzListOfBytes(str)
			anResult + oBinStr.SizeInBytes()
		next
		return anResult

		def SizeInBytesOfEachString()
			return This.SizeInBytesOfEachStringItem()

		def NumberOfBytesInEachStringItem()
			return This.SizeInBytesOfEachStringItem()

		def NumberOfBytesInEachString()
			return This.SizeInBytesOfEachStringItem()

	def StringItemsAndTheirSizesInBytes()
		aResult = []
		for str in This.ListOfStrings()
			oBinStr = new stzListOfBytes(str)
			aResult + [ str, oBinStr.SizeInBytes() ]
		next
		return anResult

		def StringsAndTheirSizesInBytes()
			return This.StringItemsAndTheirSizesInBytes()

		def StringItemsAndTheirNumberOfBytes()
			return This.StringItemsAndTheirSizesInBytes()

		def StringsAndTheirNumberOfBytes()
			return This.StringItemsAndTheirSizesInBytes()

		def StringItemsAndTheirNumbersOfBytes()
			return This.StringItemsAndTheirSizesInBytes()

		def StringsAndTheirNumbersOfBytes()
			return This.StringItemsAndTheirSizesInBytes()

	  #-------------------------------------------#
	 #    CONVERTING THE LIST OF STRINGS TO...   #
	#-------------------------------------------#

	def ToListOfStzStrings()
		aResult = []
		for str in This.ListOfStrings()
			aResult + new stzString(str)
		next
		return aResult

	def ToListOfStzStringsQ()
		return new stzList( This.ToListOfStzStrings() )

	def ToStzList()
		return new stzList( This.Content() )

	  #------------------------------------------#
	 #    GETTING STRING AT A GIVEN POSITION    #
	#------------------------------------------#

	def StringItemAt(n)

		if isString(n)
			if Q(n).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		return This.QStringListObject().value(n-1)

		#< @FunctionFluentForm

		def StringItemAtQ(n)
			return new stzString( This.StringItemAt(n) )

		#>

		#< @FunctionAlternativeForms

		def StringAt(n)
			return This.StringItemAt(n)

			def StringAtQ(n)
				return new stzString( This.StringAt(n) )

		def NthStringItem(n)
			return This.StringItemAt(n)

			def NthStringItemQ(n)
				return new stzString( This.NthStringItem(n) )

		def NthString(n)
			return This.StringItemAt(n)

			def NthStringQ(n)
				return new stzString( This.NthString(n) )

		def StringItemAtPosition(n)
			return This.StringItemAt(n)

			def StringItemAtPositionQ(n)
				return new stzString( This.StringItemAtPosition(n) )

		def StringAtPosition(n)
			return This.StringItemAt(n)

			def StringAtPositionQ(n)
				return new stzString( This.StringAtPosition(n) )
		#>

	  #----------------------------------------------------------#
	 #    GETTING FIRST & LAST STRINGS OF THE LIST OF STRINGS   #
	#----------------------------------------------------------#

	def FirstStringItem()
		return This.NthStringItem(1)

		def FirstStringItemQ()
			return new stzString( This.FirstStringItem() )

		def FirstString()
			return This.FirstStringItem()

			def FirstStringQ()
				return new stzString( This.FirstString() )

	#--

	def LastStringItem()
		return This.NthStringItem(:Last)

		def LastStringItemQ()
			return new stzString( This.LastStringItem() )

		def LastString()
			return This.LastStringItem()

			def LastStringQ()
				return new stzString( This.LastString() )

	  #------------------------------------#
	 #    GETTING A SECTION OF STRINGS    #
	#------------------------------------#

	def Section(n1, n2)

		# Checking params correctness

		if isList(n1) and
			( Q(n1).IsFromNamedParamList() or
			  Q(n1).IsFromPositionNamedParamList()  )

			n1 = n1[2]
		ok

		if isList(n2) and ( Q(n2).IsToNamedParamList() or Q(n2).IsToPositionNamedParamList() )
			n2 = n2[2]
		ok

		if isString(n1) and ( Q(n1).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				    )
			n1 = 1
		ok

		if isString(n2) and ( Q(n2).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])
				    )

			n2 = This.NumberOfStrings()
		ok

		if NOT isNumber(n1) and isNumber(n2)
			stzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT  ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings() ) and
			  StzNumberQ(n2).IsBetween(1, This.NumberOfStrings() )
			)

			stzRaise("Out of range!")
		ok

		# Doing the job

		return This.ToStzList().Section(n1, n2)

		#< @FunctionFluentForm

		def SectionQ(n1, n2)
			return This.SectionQR(n1, n2, :stzList)

		def SectionQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Unsupported return type!")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Section(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Section(n1, n2) )

			other
				stzRaise("Unsupported return type!")
			off
				
		#>

		#< @FunctionAlternativeForm

		def Slice(n1, n2)
			return This.Section(n1, n2)

			def SliceQ(n1, n2)
				return This.SliceQR(n1, n2, :stzList)
	
			def SliceQR(n1, n2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Unsupported return type!")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Slice(n1, n2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Slice(n1, n2) )
	
				other
					stzRaise("Unsupported return type!")
				off
		#>

	  #----------------------------------#
	 #    GETTING A RANGE OF STRINGS    #
	#----------------------------------#

	def Range(nStart, nRange)
		# Checking the correctness of the pnStart param

		if isList(pnStart) and Q(pnStart).IsFromNamedParamList()
			pnStart = pnStart[2]
		ok

		if isString(pnStart)
			if Q(pnStart).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				pnStart = 1

			but Q(pnStart).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStart)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Checking the correctness of the pnRange param

		if isList(pnRange) and
		   isString(pnRange[1]) and

		   ( Q(pnRange[1]).IsOneOfTheseCS([ :UpToN, :UpToNStrings, :UpToNStringItems ]) )

		   	pnRange = pnRange[2]
		ok
	
		if NOT isNumber(pnRange)
			stzRaise("Incorrect param type! pnRange must be a number.")
		ok

		# Checking the correctness of the range of the two params

		nLen = This.NumberOfStrings()

		if (pnStart < 1) or (pnStart + pnRange -1 > nLen) or
		   ( pnStart = nLen and pnRange != 1 )
			stzRaise("Out of range!")
		ok

		# Doing the job

		return This.ToStzList().Range(nStart, nRange)

		#< @FunctionFluentForm

		def RangeQ(n1, n2)
			return This.RangeQR(n1, n2, :stzList)

		def RangeQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Unsupported return type!")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Range(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Range(n1, n2) )

			other
				stzRaise("Unsupported return type!")
			off
				
		#>

	  #------------------------------------------------------------#
	 #    GETTING FIRST & LAST N STRINGS OF THE LIST OF STRINGS   #
	#------------------------------------------------------------#

	def FirstNStrings(n)
		return This.Section(1,n)

		#< @FunctionFluentForm

		def FirstNStringsQ(n)
			return This.FirstNStringsQR(n, :stzList)

		def FirstNStringsQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType mst be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FirstNStrings(n) )

			on :stzListOfStrings
				retutn new stzListOfStrings( This.FirstNStrings(n) )

			other
				stzRaise("Unsupported return type!")
			off

		#> @FunctionAlternativeForms

		def NFirstStrings(n)
			return This.FirstNStrings()

			def NFirstStringsQ(n)
				return This.NFirstStringsQR(n, :stzList)

			def NFirstStringsQR(n, pcReturnType)
				return This.FirstNStringsQR(n, pcReturnType)

		def FirstNStringItems(n)
			return This.FirstNStrings()

			def FirstNStringItemsQ(n)
				return This.FirstNStringItemsQR(n, :stzList)

			def FirstNStringItemsQR(n, pcReturnType)
				return This.FirstNStringsQR(n, pcReturnType)

		def NFirstStringItems(n)
			return This.FirstNStrings()

			def NFirstStringItemsQ(n)
				return This.NFirstStringItemsQR(n, :stzList)

			def NFirstStringItemsQR(n, pcReturnType)
				return This.FirstNStringsQR(n, pcReturnType)

		#>

	def LastNStrings(n)
		return This.Section( This.NumberOfStrings() - n + 1, n )

		def NLastStrings(n)
			return This.LastNStrings(n)

		def LastNStringItems(n)
			return This.LastNStrings(n)

		def NLastStringItems(n)
			return This.LastNStrings(n)

	   #--------------------------------------------#
	  #    GETTING THE LIST OF STRING-ITEMS BY     #
	 #    THEIR POSITIONS IN THE LIST             #
	#--------------------------------------------#

	def StringItemsAtPositions(panPositions)
		acResult = This.ToStzList().ItemsAtThesePositions(panPositions)
		return acResult

		def StringItemsAtPositionsQ(panPositions)
			return This.StringItemsAtPositionsQR(panPositions, :stzList)

		def StringItemsAtPositionsQR(panPositions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsAtPositions(panPositions) )

			on :stzListOfStrings
				return new stzList( This.StringItemsAtPositions(panPositions) )

			other
				stzRaise("Unsupported return type!")
			off

		def StringItemsAtThesePositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringItemsAtThesePositionsQ(panPositions)
				return This.StringItemsAtThesePositionsQR(panPositions, :stzList)
	
			def StringItemsAtThesePositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsAtThesePositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringItemsAtThesePositions(panPositions) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringsAtPositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringsAtPositionsQ(panPositions)
				return This.StringsAtPositionsQR(panPositions, :stzList)
	
			def StringsAtPositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsAtPositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringsAtPositions(panPositions) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringsAtThesePositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringsAtThesePositionsQ(panPositions)
				return This.StringsAtThesePositionsQR(panPositions, :stzList)
	
			def StringsAtThesePositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsAtThesePositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringsAtThesePositions(panPositions) )
	
				other
					stzRaise("Unsupported return type!")
				off

	  #-------------------------------------------------------------#
	 #    APPENDING THE LIST WITH A STRING (AT THE END OF LIST)    #
	#-------------------------------------------------------------#

	def AddStringItem(pcStrItem)
		if isString(pcStrItem)
			This.QStringListObject().append(pcStrItem)
		else
			stzRaise( stzListOfStringsError(:CanNotAddNonStringItem) )
		ok

		def AddStringItemQ(pcStrItem)
			This.AddStringItem(pcStrItem)
			return This

		def AddString(pcStrItem)
			This.AddStringItem(pcStrItem)
			
			def AddStringQ(pcStrItem)
				This.AddString(pcStrItem)
				return This

		def Append(pcStrItem)
			This.AddStringItem(pcStrItem)

			def AppendQ(pcStrItem)
				This.Append(pcStrItem)
				return This

		def AppendWith(pcStrItem)
			This.AddStringItem(pcStrItem)

			def AppendWithQ(pcStrItem)
				This.AppendWith(pcStrItem)
				return This

		def AppendListOfStringsWith(pcStrItem)
			This.AddStringItem(pcStrItem)

			def AppendListOfStringsWithQ(pcStrItem)
				This.AppendListOfStringsWith(pcStrItem)
				return This

		def Add(pcStrItem)
			This.AddStringItem(pcStrItem)

			def AddQ(pcStrItem)
				This.Add(pcStrItem)
				return This

	  #--------------------------------------------------------------------#
	 #    PREPENDING THE LIST WITH A STRING (AT THE BEGINNING OF LIST)    #
	#--------------------------------------------------------------------#
			
	def Prepend(pcStrItem)
		if isString(pcStrItem)
			This.QStringListObject().prepend(pcStrItem)
		else
			stzRaise( stzListOfStringsError(:CanNotAddNonStringItem) )
		ok
		
		def PrependQ(pcStrItem)
			This.Prepend(pcStrItem)
			return This

		def PrependWith(pcStrItem)
			This.Prepend(pcStrItem)

			def PrependWithQ(pcStrItem)
				This.PrependWith(pcStrItem)
				return This

		def PrependListOfStringsWith(pcStrItem)
			This.Prepend(pcStrItem)

			def PrependListOfStringsWithQ(pcStrItem)
				This.PrependListOfStringsWith(pcStrItem)
				return This

	  #----------------------------------------------------#
	 #    APPENDING EACH STRING WITH A GIVEN SUSBTRING    #
	#----------------------------------------------------#

	def AppendEachStringItem(pcSubStr)

		i = 0
		for str in This.ListOfStrings()
			i++
			This.ReplaceStringAtPosition(i, str + pcSubStr)
		next


		def AppendEachStringItemQ(pcSubStr)
			This.AppendEachStringItem(pcSubStr)
			return This

		def AppendEachString(pcSubStr)
			This.AppendEachStringItem(pcSubStr)

			def AppendEachStringQ(pcSubStr)
				This.AppendEachString(pcSubStr)
				return This

		def AppendEach(pcSubStr)
			This.AppendEachStringItem(pcSubStr)

			def AppendEachQ(pcSubStr)
				This.AppendEach(pcSubStr)
				return This
		
	  #----------------------------------------------------#
	 #    PREPENDING EACH STRING WITH A GIVEN SUSBTRING    #
	#----------------------------------------------------#

	def PrependEachStringItem(pcSubStr)

		i = 0
		for str in This.ListOfStrings()
			i++
			This.ReplaceStringAtPosition(i, pcSubStr + str)
		next

		def PrependEachStringItemQ(pcSubStr)
			This.PrependEachStringItem(pcSubStr)
			return This

		def PrependEachString(pcSubStr)
			This.PrependEachStringItem(pcSubStr)

			def PrependEachStringQ(pcSubStr)
				This.PrependEachString(pcSubStr)
				return This

		def PrependEach(pcSubStr)
			This.PrependEachStringItem(pcSubStr)

			def PrependEachQ(pcSubStr)
				This.AppendEach(pcSubStr)
				return This
		
	  #---------------------------------------------------#
	 #    INSERTING A STRING BEFORE A GIVEN POSITION     #
	#---------------------------------------------------#

	def InsertBefore(n, pcStr)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		if isString(pcStr)
			This.QStringListObject().insert(n-1, pcStr)
		else
			stzRaise( stzListOfStringsError(:CanNotInsertNonStringItem) )
		ok

		#--

		def InsertBeforeQ(n, pcStr)
			This.InsertBefore(n, pcStr)
			return This

		#--

		def InsertBeforePosition(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertBeforePositionQ(n, pcStr)
				This.InsertBeforePosition(n, pcStr)
				return This

		def InsertStringBeforePosition(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertStringBeforePositionQ(n, pcStr)
				This.InsertStringBeforePosition(n, pcStr)
				return This

		def InsertStringItemBeforePosition(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertStringItemBeforePositionQ(n, pcStr)
				This.InsertStringItemBeforePosition(n, pcStr)
				return This

		def InsertStringBefore(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertStringBeforeQ(n, pcStr)
				This.InsertStringBefore(n, pcStr)
				return This

		def InsertStringItemBefore(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertStringItemBeforeQ(n, pcStr)
				This.InsertStringItemBefore(n, pcStr)
				return This

		def Insert(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertQ(n, pcStr)
				This.Insert(n, pcStr)
				return This

	  #--------------------------------------------------#
	 #    INSERTING A STRING AFTER A GIVEN POSITION     #
	#--------------------------------------------------#

	def InsertAfter(n, pcStr)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		if n < This.NumberOfStrings()
			This.InsertBefore(n+1, pcStr)
		ok

		#--

		def InsertAfterQ(n, pcStr)
			This.InsertAfter(n, pcStr)
			return This

		#--

		def InsertAfterPosition(n, pcStr)
			This.InsertAfter(n, pcStr)

			def InsertAfterPositionQ(n, pcStr)
				This.InsertAfterPosition(n, pcStr)
				return This

		def InsertStringAfterPosition(n, pcStr)
			This.InsertAfter(n, pcStr)

			def InsertStringAfterPositionQ(n, pcStr)
				This.InsertStringAfterPosition(n, pcStr)
				return This

		def InsertStringItemAfterPosition(n, pcStr)
			This.InsertAfter(n, pcStr)

			def InsertStringItemAfterPositionQ(n, pcStr)
				This.InsertStringItemAfterPosition(n, pcStr)
				return This

		def InsertStringAfter(n, pcStr)
			This.InsertAfter(n, pcStr)

			def InsertStringAfterQ(n, pcStr)
				This.InsertStringAfter(n, pcStr)
				return This

		def InsertStringItemAfter(n, pcStr)
			This.InsertAfter(n, pcStr)

			def InsertStringItemAfterQ(n, pcStr)
				This.InsertStringItemAfter(n, pcStr)
				return This

	  #-----------------------------------------------#
	 #    INSERTING A STRING AT A GIVEN POSITION     #
	#-----------------------------------------------#

	def InsertAt(n, pcStr)
		# Removes the current string at position n
		# and then inserts pcStr before the next one

		/* EXAMPLE

		o1 = new stzListOfStrings([ "ONE", "TWO", 3, "FOUR", "FIVE" ])
		o1.InsertAt(3, "THREE")
		? o1.Content()	     #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]
		
		*/

		This.RemoveAt(n)

		if n = This.NumberOfStrings() + 1
			This.AddString(pcStr)
		else
			This.InsertAfter(n-1, pcStr)
		ok

		#--

		def InsertAtQ(n, pcStr)
			This.InsertAt(n, pcStr)
			return This

		#--

		def InsertAtPosition(n, pcStr)
			This.InsertAt(n, pcStr)

			def InsertAtPositionQ(n, pcStr)
				This.InsertAtPosition(n, pcStr)
				return This

		def InsertStringAtPosition(n, pcStr)
			This.InsertAt(n, pcStr)

			def InsertStringAtPositionQ(n, pcStr)
				This.InsertStringAtPosition(n, pcStr)
				return This

		def InsertStringItemAtPosition(n, pcStr)
			This.InsertAt(n, pcStr)

			def InsertStringItemAtPositionQ(n, pcStr)
				This.InsertStringItemAtPosition(n, pcStr)
				return This

		def InsertStringAt(n, pcStr)
			This.InsertAt(n, pcStr)

			def InsertStringAtQ(n, pcStr)
				This.InsertStringAt(n, pcStr)
				return This

		def InsertStringItemAt(n, pcStr)
			This.InsertAt(n, pcStr)

			def InsertStringItemAtQ(n, pcStr)
				This.InsertStringItemAt(n, pcStr)
				return This
		
	  #------------------------------------------------------------------------#
	 #    INSERTING A SUBSTRING BEFORE NTH CHAR OF EACH STRING IN THE LIST    #
	#------------------------------------------------------------------------#

	def InsertBeforeInEach(n, pcSubStr)
		acResult = []
		for str in This.ListOfStrings()
			acResult + ( StzStringQ(str).InsertBefore(n, pcSubStr) )
		next
	
		This.Update( acResult )

		def InsertBeforeInEachQ(n, pcSubStr)
			This.InsertBeforeInEach(n, pcSubStr)
			return This

		def InsertInEachBefore(n, pcSubStr)
			return This.InsertBeforeInEach(n, pcSubStr)

			def InsertInEachBeforeQ(n, pcSubStr)
				This.InsertInEachBefore(n, pcSubStr)
				return This

	  #-----------------------------------------------------------------------#
	 #    INSERTING A SUBSTRING AFTER NTH CHAR OF EACH STRING IN THE LIST    #
	#-----------------------------------------------------------------------#

	def InsertAfterInEach(n, pcSubStr)
		acResult = []
		for str in This.ListOfStrings()
			acResult + ( StzStringQ(str).InsertAfter(n, pcSubStr) )
		next
	
		This.Update( acResult )

		def InsertAfterInEachQ(n, pcSubStr)
			This.InsertAfterInEach(n, pcSubStr)
			return This

		def InsertInEachAfter(n, pcSubStr)
			return This.InsertAfterInEach(n, pcSubStr)

			def InsertInEachAfterQ(n, pcSubStr)
				return This.InsertInEachAfter(n, pcSubStr)

	  #---------------#
	 #    UPDATING   #
	#---------------#

	def Update(pNewListOfStr)
		if isList(pNewListOfStr) and
		   ( StzListQ(pNewListOfStr).IsWithNamedParamList() or StzListQ(pNewListOfStr).IsUsingNamedParamList() )

			pNewListOfStr = pNewListOfStr[2]

		ok

		if IsQStringListObject(pNewListOfStr)
			@oQStrList = pNewListOfStr

		but StzListQ(pNewListOfStr).IsListOfStrings()
			This.QStringListObject().clear()
	
			for str in pNewListOfStr
				This.QStringListObject().append(str)	
			next

		else
			stzRaise("Param you provided is not a list of strings!")
	
		ok

	  #---------------------------------------------------#
	 #      CONCATENATING THE STRINGS OF THE LIST        #
	#---------------------------------------------------#

	def Concatenate()
		return This.ConcatenateUsing("")

		def ConcatenateQ()
			return new stzString( This.Concatenate() )
	
	def Concatenated()
		return This.ConcatenateQ().Content()
	
	def ConcatenateUsing(pcSep)
		return This.QStringListObject().join(pcSep)

		def ConcatenateUsingQ(pcSep)
			return new stzString( This.ConcatenateUsing(pcSep) )
	
	def ConcatenatedUsing(pcSep)
		aResult = This.Copy().ConcatenateUsingQ(pcSep).Content()
		return aResult

	  #--------------------------------------#
	 #     REVERSING THE LIST OF STRINGS    #
	#--------------------------------------#

	def ReverseStringItems()
		aTemp = StzListQ( This.ListOfStrings() ).ItemsReversed()
		This.Update( aTemp )
		
		def ReverseStringItemsQ()
			This.ReverseStringItems()
			return This

		def ReverseStrings()
			This.ReverseStringItems()
			
			def ReverseStringsQ()
				This.ReverseStrings()
				return This

		def ReverseListOfStrings()
			This.ReverseStringItems()

			def ReverseListOfStringsQ()
				This.ReverseListOfStrings()
				return This

	def StringItemsReversed()
		aResult = This.Copy().ReverseStringItemsQ().Content()
		return aResult

		def StringsReversed()
			return This.StringItemsReversed()

		def ListOfStringsReversed()
			return This.StringItemsReversed()

	  #-----------------------------------------------------#
	 #     SWAPPING TWO STRINGS AT TWO GIVEN POSITIONS     #
	#-----------------------------------------------------#

	def SwapBetween(n1, n2)

		/* EXAMPLE

		o1 = stzListOfStrings([ "A1", "A2", "A3", "A4", "A5" ])
		o1.SwapBetween(2, 4)
		? o1.Content() #--> [ "A1", "A4", "A3", "A2", "A5" ]

		*/
		
		if isString(n1)
			if n1 = :First or n1 = :FirstPosition or
			   n1 = :FirstString or n1 = :FirstStringItem

				n1 = 1

			but n1 = :Last or n1 = :LastPosition or
			    n1 = :LastString or n1 = :LastStringItem

				n1 = This.NumberOfStringItems()
			ok

		ok

		if NOT isNumber(n1)
			stzRaise("Incorrect param type! n1 must be a number.")
		ok

		if isString(n2)
			if n2 = :First or n2 = :FirstPosition or
			   n2 = :FirstString or n2 = :FirstStringItem

				n2 = 1

			but n2 = :Last or n2 = :LastPosition or
			    n2 = :LastString or n2 = :LastStringItem

				n2 = This.NumberOfStringItems()
			ok
		ok

		if NOT isNumber(n2)
			stzRaise("Incorrect param type! n2 must be a number.")
		ok

		This.MoveString( :AtPosition = n1, :ToPosition = n2)
		#--> [ "A1", "A3", "A4", "A2", "A5" ]

		This.MoveString( :AtPosition = n2 - 1, :ToPosition = n1 )
		#--> [ "A1", "A4", "A3", "A2", "A5" ]

		def SwapBetweenQ(n1, n2)
			This.SwapBetween(n1, n2)
			return This
	
		def SwapBetweenPositions(n1, n2)
			This.SwapBetween(n1, n2)

			def SwapBetweenPositionsQ(n1, n2)
				This.SwapBetween(n1, n2)
				return This

		def SwapStringsBetweenPositions(n1, n2)
			This.SwapBetween(n1, n2)

			def SwapStringsBetweenPositionsQ(n1, n2)
				This.SwapBetween(n1, n2)
				return This

		def SwapStringItemsBetweenPositions(n1, n2)
			This.SwapBetween(n1, n2)

			def SwapStringItemsBetweenPositionsQ(n1, n2)
				This.SwapBetween(n1, n2)
				return This

	  #------------------------------------------------------------------#
	 #     MOVING A STRING AT A GIVEN POSITION TO AN OTHER POSITION     #
	#------------------------------------------------------------------#

	def Move(n1, n2)

		# Checking params correctness

		if isList(n1) and
			( Q(n1).IsFromNamedParamList() or Q(n1).IsAtNamedParamList()  or
			Q(n1).IsFromPositionNamedParamList() or Q(n1).IsAtPositionNamedParamList() )

			n1 = n1[2]
		ok

		if isList(n2) and ( Q(n2).IsToNamedParamList() or Q(n2).IsToPositionNamedParamList() )
			n2 = n2[2]
		ok

		if isString(n1) and ( Q(n1).IsOneOfThese([
						:First, :FirstPosition,
				      		:FirstString, :FirstStringItem ])
				    )
			n1 = 1
		ok

		if isString(n2) and ( Q(n2).IsOneOfThese([
						:Last, :LastPosition,
				      		:LastString, :LastStringItem ])
				    )

			n2 = This.NumberOfStrings()
		ok

		if NOT isNumber(n1) and isNumber(n2)
			stzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT  ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings() ) and
			  StzNumberQ(n2).IsBetween(1, This.NumberOfStrings() )
			)

			stzRaise("Out of range!")
		ok

		# Doing the job (Qt-side)

		This.QStringListObject().move(n1-1, n2-1)

		#< @FunctionFluentForm

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

		#>

		#< @FunctionAlternativeForms

		def MoveString(n1, n2)
			This.Move(n1, n2)

			def MoveStringQ(n1, n2)
				This.MoveString(n1, n2)
				return This

		def MoveStringItem(n1, n2)
			This.Move(n1, n2)

			def MoveStringItemQ(n1, n2)
				This.MoveStringItem(n1, n2)
				return This

		def MoveStringAtPositionNTo(n1, n2)
			This.Move(n1, n2)

			def MoveStringAtPositionNToQ(n1, n2)
				This.MoveStringAtPositionNTo(n1, n2)
				return This

		#>

	  #----------------------------#
	 #     SORTING THE STRINGS    #
	#----------------------------#

	def IsSorted()
		return This.IsSortedInAscending() or This.IsSortedInDescending()

		def StringsAreSorted()
			return This.IsSorted()

	def IsUnsorted()
		return NOT This.IsSorted()

		def StringsAreUnsorted()
			return This.IsUnsorted()

	def IsNotSorted()
		return NOT This.IsSorted()

		def StringsAreNotSorted()
			return This.IsNotSorted()

	def IsSortedInAscending()
		bResult = This.Copy().SortInAscendingQ().ToStzList().IsStrictlyEqualTo( This.ListOfStrings() )
		return bResult

		def StringsAreSortedInAscending()
			return This.IsSortedInAscending()

	def IsSortedInDescending()
		bResult = This.Copy().SortInDescendingQ().ToStzList().IsStrictlyEqualTo( This.ListOfStrings() )
		return bResult

		def StringsAreSortedInDescending()
			return This.IsSortedInDescending()

	def SortInAscending()
		This.QStringListObject().sort()

		def SortInAscendingQ()
			This.SortInAscending()
			return This
	
		def SortStringsInAscending()
			This.SortInascending()

			def SortStringsInAscendingQ()
				This.SortStringsInAscending()
				return This

	def SortedInAscending()
		oQCopy = This.QStringListObject()
		oQCopy.sort()

		return QStringListContent(oQCopy)

		def StringsSortedInAscending()
			return This.SortedInAscending()

	def SortInDescending()
		This.Update( ListReverse( This.Copy().SortedInAscending() ) )

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortStringsInDescending()
			This.SortInDescending()

			def SortStringsInDescendingQ()
				This.SortStringsInDescending()
				return This

	def SortedInDescending()
		oQCopy = This.QStringListObject()
		oQCopy.sort()

		return ListReverse( QStringListContent(oQCopy) )

		def StringsSortedInDescending()
			return This.SortedInDescending()
		
	def SortingOrder()

		cResult = :Unsorted

		if This.IsSortedInAscending()
			cResult = :Ascending

		but This.IsSortedInDescending()
			cResult = :Descending

		ok
		
		return cResult
 
	  #----------------------------------------------------#
	 #     SORTING THE CHARS OF EACH STRING IN THE LIST   #
	#----------------------------------------------------#

	def CharsSortingOrders()
		acResult = []

		for i = 1 to This.NumberOfStrings()
			acResult + This.StringAtQ(i).CharsSortingOrder()
		next

		return acResult

	def CharsOfEachStringAreSortedInAscending()
		return This.NumberOfStringsWhereCharsAreSortedInAscending() = This.NumberOfStrings()

	def CharsOfEachStringAreSortedInDescending()
		return This.NumberOfStringsWhereCharsAreSortedInDescending() = This.NumberOfStrings()

	def CharsOfSomeStringsAreSortedInAscending()
		return This.NumberOfStringsWhereCharsAreSortedInAscending() > 0

	def CharsOfSomeStringsAreSortedInDescending()
		return This.NumberOfStringsWhereCharsAreSortedInDescending() > 0

	def NumberOfStringsWhereCharsAreSortedInAscending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringAtQ(i).CharsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereCharsAreSortedInDescending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringAtQ(i).CharsAreSortedInDescending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereCharsAreSorted()
		return  This.NumberOfStringsWhereCharsAreSortedInAscending() +
			This.NumberOfStringsWhereCharsAreSortedInDescending()

	def NumberOfStringsWhereCharsAreUnsorted()
		return This.NumberOfStrings() - This.NumberOfStringsWhereCharsAreSorted()

		def NumberOfStringsWhereCharsAreNotSorted()
			return This.NumberOfStringsWhereCharsAreUnsorted()

	def SortCharsOfEachStringInAscending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).CharsSortedInAscending()
		next

		This.Update( aResult )

		def SortCharsOfEachStringInAscendingQ()
			This.SortCharsOfEachStringInAscending()
			return This

		def SortEachInAscending()
			This.SortCharsOfEachStringInAscending()
	
			def SortEachInAscendingQ()
				This.SortEachInAscending()
				return This

	def CharsOfEachStringSortedInAscending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).CharsSortedInAscending()
		next

		return aResult

	def SortCharsOfEachStringInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).CharsSortedInDescending()
		next

		This.Update( aResult )

		def SortCharsOfEachStringInDescendingQ()
			This.SortCharsOfEachStringInDescending()
			return This

		def SortEachInDescending()
			This.SortCharsOfEachStringInDescending()
	
			def SortEachInDescendingQ()
				This.SortEachInDescending()
				return This

	def CharsOfEachStringSortedInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringatQ(i).CharsSortedInDescending()
		next

		return aResult

	  #----------------------------------------------------#
	 #     SORTING THE WORDS OF EACH STRING IN THE LIST   #
	#----------------------------------------------------#

	def WordsSortingOrders()
		acResult = []

		for i = 1 to This.NumberOfStrings()
			acResult + This.StringAtQ(i).WordsSortingOrder()
		next

		return acResult

	def WordsOfEachStringAreSortedInAscending()
		return This.NumberOfStringsWhereWordsAreSortedInAscending() = This.NumberOfStrings()

	def WordsOfEachStringAreSortedInDescending()
		return This.NumberOfStringsWhereWordsAreSortedInDescending() = This.NumberOfStrings()

	def WordsOfSomeStringsAreSortedInAscending()
		return This.NumberOfStringsWhereWordsAreSortedInAscending() > 0

	def WordsOfSomeStringsAreSortedInDescending()
		return This.NumberOfStringsWhereWordsAreSortedInDescending() > 0

	def NumberOfStringsWhereWordsAreSortedInAscending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringAtQ(i).WordsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereWordsAreSortedInDescending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringAtQ(i).WordsAreSortedInDescending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereWordsAreSorted()
		return  This.NumberOfStringsWhereWordsAreSortedInAscending() +
			This.NumberOfStringsWhereWordsAreSortedInDescending()

	def NumberOfStringsWhereWordsAreUnsorted()
		return This.NumberOfStrings() - This.NumberOfStringsWhereWordsAreSorted()

		def NumberOfStringsWhereWordsAreNotSorted()
			return This.NumberOfStringsWhereWordsAreUnsorted()

	def SortWordsOfEachStringInAscending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).StringWithWordsSortedInAscending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInAscendingQ()
			This.SortWordsOfEachStringInAscending()
			return This

	def WordsOfEachStringSortedInAscending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).StringWithWordsSortedInAscending()
		next

		return aResult

	def SortWordsOfEachStringInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).StringWithWordsSortedInDescending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInDescendingQ()
			This.SortWordsOfEachStringInDescending()
			return This

	def WordsOfEachStringSortedInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).StringWithWordsSortedInDescending()
		next

	  #=================================================#
	 #     FINDING A STRING IN THE LIST OF STRINGS     #
	#=================================================#

	/* TODO
		Add these functions in stzListOfStrings and stzString

		FindPositions() #done
		FindStartPositions()
		FindEndPositions()

		PositionsOf() #done
		StartPositionsOf()
		EndPositionsOf()

		FindSections() #done
		SectionsOf()
	
	*/

	def FindStringItemCS(pcStrItem, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		anResult = []

		if pCaseSensitive = TRUE

			anResult = This.ToStzList().FindAll(pcStrItem)

		else
			acList = This.Lowercased()
			cStr = StzStringQ(pcStrItem).Lowercased()

			anResult = StzListQ(acList).FindAll(cStr)
		ok


		return anResult

		#< @FunctionAlternativeForms

		def FindStringCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		def FindCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		def FindAllCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

			def FindAllCSQ(pcStrItem, pCaseSensitive)
				return FindAllCSQR(pcStrItem, pCaseSensitive, :stzList)

			def FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllCS(pcStrItem, pCaseSensitive) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllCS(pcStrItem, pCaseSensitive) )

				other
					stzRaise("Unsupported return type!")
				off

		def FindAllOccurrencesOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		def AllPositionsOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindStringItem(pcStrItem)
		return This.FindStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindString(pcStrItem)
			return This.FindStringItem(pcStrItem)

		def FindAll(pcStrItem)
			return This.FindStringItem(pcStrItem)

		def FindAllOccurrencesOfStringItem(pcStrItem)
			return This.FindStringItem(pcStrItem)

		def PositionsOf(pcStrItem)
			return This.FindStringItem(pcStrItem)

		def PositionsOfStringItem(pcStr)
			return This.FindStringItem(pcStrItem)

		def AllPositionsOfStringItem(pcStrItem)
			return This.FindStringItem(pcStrItem)

		#>

	  #-------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCE OF A STRING-ITEM EXCEPT NTH OCCURRENCE  #
	#-------------------------------------------------------------------#
	/*
	NOTE: These functions were made to be used in RemoveDuplicates()
	TODO: Generalise the ...Except() extension in all stz functions
	*/

	def FindAllExceptNthCS(pcStr, n, pCaseSensitive)
		aResult = []

		if n = :First or n = :FirstPosition or
		   n = :FirstString or n = :FirstStringItem

			n = 1

		but n = :Last or n = :LastPosition or
		    n = :LastString or n = :LastStringItem

			n = This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)
		ok

		if n = 1
			aResult = This.FindAllExceptFirstCS(pcStr, pCaseSensitive)

		but n = This.NumberOfOccurrenceCS(pcStr, pCaseSensitive)
			aResult = This.FindAllCSQ(pcStr, pCaseSensitive).Section(1, n-1 )
		
		but n > 1 and n < This.NumberOfOccurrenceCS(pcStr, pCaseSensitive)
			aResult + This.FindAllCSQ(pcStr, pCaseSensitive).Section( 1, n - 1)
			aResult + This.FindAllCSQ(pcStr, pCaseSensitive).Section( n + 1, This.NumberOfOccurrenceCS(pcStr, pCaseSensitive))
		ok

		return aResult

		#< @FunctionFluentForm

		def FindAllExceptNthCSQ(pcStr, n, pCaseSensitive)
			return This.FindAllExceptNthCSQR(pcStr, n, pCaseSensitive, :stzList)

		def FindAllExceptNthCSQR(pcStr, n, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptNhCS(pcStr, n, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNhCS(pcStr, n, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptNth(pcStr, n)
		return This.FindAllExceptNthCS(pcStr, n, :CaseSensitive)

		#< @FunctionFluentForm

		def FindAllExceptNthQ(pcStr, n)
			return This.FindAllExceptNthQR(pcStr, n, :stzList)

		def FindAllExceptNthQR(pcStr, n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptNh(pcStr, n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNh(pcStr, n) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	  #-------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCE OF A STRING-ITEM EXCEPT FIRST OCCURRENCE  #
	#-------------------------------------------------------------------#

	def FindAllExceptFirstCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(2, :Last)

		def FindAllExceptFirstCSQ(pcStr, pCaseSensitive)
			return new stzList( This.FindAllExceptFirstCS(pcStr, pCaseSensitive) )
	
	#

	  #-------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCE OF A STRING-ITEM EXCEPT LAST OCCURRENCE  #
	#-------------------------------------------------------------------#

	def FindAllExceptLastCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(1, This.NumberOfStrings()-1 )

		def FindAllExceptLastCSQ(pcStr, pCaseSensitive)
			return new stzList( This.FindAllExceptLastCS(pcStr, pCaseSensitive) )
		
	   #----------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF A STRING (AS AN ITEM)   #
	 #    IN THE LIST OF STRINGS                          #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		return len( This.FindStringItemCS(pcStrItem, pCaseSensitive) )

		def NumberOfOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def NumberOfOccurrenceCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfStringItem(pcStrItem)
		return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		def NumberOfOccurrenceOfString(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		def NumberOfOccurrence(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

	  #--------------------------------------------------#
	 #    NUMBER OF OCCURRENCE OF MANY STRINGS-ITEMS    #
	#--------------------------------------------------#

	def NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)
		if NOT ListIsListOfStrings(pacStrItems)
			stzRaise("Incorrect param type! pacStrItems mus tbe a list of strings.")
		ok

		pacStrItems = StzListQ(pacStrItems).DuplicatesRemoved()

		anResult = []

		for str in pacStrItems
			anResult + This.NumberOfOccurrenceOfStringItemCS(str, pCaseSensitive)
		next

		return anResult

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsCSQ(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, :stzList)

		def NumberOfOccurrenceOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManyStringItems(pacStrItems)
		return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsQ(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, :stzList)

		def NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItems(pacStrItems) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItems(pacStrItems) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrenceOfManyStrings(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

		#>

	  #-------------------------------------------------------------#
	 #    NUMBER OF OCCURRENCE OF MANY STRINGS-ITEMS -- EXTENDED   #
	#-------------------------------------------------------------#

	def NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, pCaseSensitive)
		aResult = []

		for str in pacStrItems
			anResult + [ str, This.NumberOfOccurrenceOfStringItemCS(str, pCaseSensitive) ]
		next

		return aResult

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsCSXTQ(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, pCaseSensitive, :stzList)

		def NumberOfOccurrenceOfManyStringItemsCSXTQR(pacStrItems, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrenceOfManyStringsCSXT(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManyStringItemsXT(pacStrItems)
		This.NumberOfOccurrenceOfManyStringItemsCSXT(pacStrItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsXTQ(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, :stzList)

		def NumberOfOccurrenceOfManyStringItemsXTQR(pacStrItems, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrenceOfManyStringsXT(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems)

		#>

	   #--------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS A GIVEN      #
	 #      STRING (AS AN ENTIRE ITEM OF THE LIST)            #
	#--------------------------------------------------------#

	def ContainsStringItemCS(pcStrItem, pCaseSensitive)
		if This.NumberOfOccurrenceOfStringCS(pcStrItem, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def ContainsStringCS(pcStrItem, pCaseSensitive)
			return This.ContainsStringitemCS(pcStrItem, pCaseSensitive)

		def ContainsCS(pcStr)
			return This.ContainsStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsStringItem(pcStrItem)
		return This.ContainsStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		def ContainsString(pcStrItem)
			return This.ContainsStringItem(pcStrItem)

		def Contains(pcStrItem)
			return This.ContainsStringItem(pcStrItem)

	  #-----------------------------------------------------------------#
	 #    FINDING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS    #
	#-----------------------------------------------------------------#
	
	def FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		if isString(n)
			if n = :First or n = :FirstPosition or
			   n = :FirstString or n = :FirstStringItem

				n = 1

			but n = :Last or n = :LastPosition or
			    n = :LastString or n = :LastStringItem

				n = This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
			ok
		ok

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		nResult = 0

		anPos = This.FindStringItemCS(pcStrItem, pCaseSensitive)
		return anPos[n]

		return nResult

		#< @FunctionAlternativeForms

		def FindNthStringItemCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthOccurrenceOfStringCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthOccurrenceCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthOccurrenceOfThisStringItemCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthOccurrenceOfThisStringCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceOfStringItem(n, pcStrItem)
		
		return This.FindNthOccurrenceOfStringItemCS(n, pStrItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthStringItem(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthOccurrenceOfString(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthOccurrence(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthOccurrenceOfThisStringItem(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthOccurrenceOfThisString(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		#>

	  #-----------------------------------------------------------------#
	 #   FINDING FIRST OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
	#-----------------------------------------------------------------#
	
	def FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		return This.FindNthOccurrenceOfStringItemCS(1, pcStrItem, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceCS(n, pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceOfThisStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceOfThisStringCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstStringCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceOfStringItem(pcStrItem)
		
		return This.FindFirstOccurrenceOfStringItemCS(pStrItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstStringItem(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirstOccurrenceOfString(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirstOccurrence(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirstOccurrenceOfThisStringItem(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirstOccurrenceOfThisString(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirstString(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		def FindFirst(pcStrItem)
			return This.FindFirstOccurrenceOfStringItem(pcStrItem)

		#>

	  #----------------------------------------------------------------#
	 #   FINDING LAST OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
	#----------------------------------------------------------------#

	def FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		return This.FindNthOccurrenceOfStringItemCS(:Last, pcStrItem, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindLastOccurrenceCS(n, pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#--

		def FindLastOccurrenceOfThisStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindLastOccurrenceOfThisStringCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#--

		def FindLastStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindLastStringCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindLastCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceOfStringItem(pcStrItem)
		
		return This.FindLastOccurrenceOfStringItemCS(pStrItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastOccurrenceOfString(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		def FindLastOccurrence(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		#--

		def FindLastOccurrenceOfThisStringItem(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		def FindLastOccurrenceOfThisString(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		#--

		def FindLastStringItem(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		def FindLastString(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		def FindLast(pcStrItem)
			return This.FindLastOccurrenceOfStringItem(pcStrItem)

		#>

	  #--------------------------------------------------------#
	 #   FINDING MANY STRINGS (AS ITEMS) AT THE SAME TIME     #
	#--------------------------------------------------------#

	def FindStringItemsCS(pacStrItems, pCaseSensitive)	
		/* EXAMPLE
		o1 = new stzListOfStrings([
			"My name is Moudour. What's your name please?",
			"Your name and my name are not the same.",
			"Please feel free to call me with any name!"
		])

		? o1.FindStringItemsCS( [ "name", "your", "please" ], :CS = TRUE )

		# --> [ 4, 33, 28, 38 ]
		*/

		aResult = []

		for str in pacStrItems
			aResult + This.FindStringItemCS(str, pCaseSensitive)
		next

		aResult = StzListQ(aResult).FlattenQ().SortInAscendingQ().Content()

		return aResult	

		#< @FunctionAlternativeForms

		def FindStringsCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		#--

		def FindManyStringItemsCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		def FindManyStringsCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		def FindManyCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		#--

		def FindTheseStringItemsCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		def FindTheseStringsCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)


		def FindTheseCS(pacStrItems, pCaseSensitive)
			return This.FindStringItemsCS(pacStrItems, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindStringItems(pacStrItems)	
		This.FindStringItems(pacStrItems, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindStrings(pacStrItems)
			return This.FindStringItems(pacStrItems)

		#--

		def FindManyStringItems(pacStrItems)
			return This.FindStringItems(pacStrItems)

		def FindManyStrings(pacStrItems)
			return This.FindStringItems(pacStrItems)

		def FindMany(pacStrItems)
			return This.FindStringItems(pacStrItems)

		#--

		def FindTheseStringItems(pacStrItems)
			return This.FindStringItems(pacStrItems)

		def FindTheseStrings(pacStrItems)
			return This.FindStringItems(pacStrItems)

		def FindThese(pacStrItems)
			return This.FindStringItems(pacStrItems)

		#>

	   #--------------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS EACH ONE           #
	 #      OF THE PROVIDED STRINGS (AS ENTIRE ITEMS OF THE LIST)   #
	#--------------------------------------------------------------#

	def ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		bResult = TRUE

		for str in pacStrItems
			if NOT This.ContainsStringItemCS(str, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForm

		def ContainsStringsCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringItemCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringItemOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachOfTheseStringItemsCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachOneOfTheseStringItemsCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachOneOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def ContainsStringItems(pacStrItems)

		return This.ContainsStringItemsCS(pacStrItems, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def ContainsStrings(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachStringItem(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachString(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEach(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachStringItemOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachOfTheseStringItems(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachOneOfTheseStringItems(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachStringOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachOneOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		#>

	   #--------------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS BOTH OF THE        #
	 #      PROVIDED STRINGS (AS ENTIRE ITEMS OF THE LIST)          #
	#--------------------------------------------------------------#

	# Just a speciefic case of ContainsEachCS(paStrItems, pCaseSensitive)

	def ContainsBothStringItemsCS(pcStrItem1, pcStrItem2, pCaseSensitive)
		if NOT BothAreStrings(pcStrItem1, pcStrItem2)
			stzRaise("Incorrect param! pcStrItem1 and pcStrItem2 must be strings.")
		ok

		return This.ContainsEachOfTheseStringItemsCS([ pcStrItem1, pcStrItem2 ], pCaseSensitive)

		#--

		def ContainsBothStringsCS(pcStrItem1, pcStrItem2, pCaseSensitive)
			return This.ContainsBothStringItemsCS(pcStrItem1, pcStrItem2, pCaseSensitive)

		def ContainsBothCS(pcStrItem1, pcStrItem2, pCaseSensitive)
			return This.ContainsBothStringItemsCS(pcStrItem1, pcStrItem2, pCaseSensitive)

	#--- WITHOUT CASESENSITIVITY

	def ContainsBothStringItems(pcStrItem1, pcStrItem2)
		
		return This.ContainsBothStringItemsCS(pcStrItem1, pcStrItem2, :CaseSensitive = TRUE)

		def ContainsBothStrings(pcStrItem1, pcStrItem2)
			return This.ContainsBothStringItems(pcStrItem1, pcStrItem2)

		def ContainsBoth(pcStrItem1, pcStrItem2)
			return This.ContainsBothStringItems(pcStrItem1, pcStrItem2)

	  #--------------------------------------------------------------#
	 #    FINDING STRINGS (AS ITEMS) VERIYING A GIVEN CONDITION     #
	#--------------------------------------------------------------#

	def FindStringItemsW(pcCondition)

		acResult = This.ToStzList().FindW(pcCondition)

		return acResult

		#< @FunctionAlternativeForms

		def FindStringsW(pcCondition)
			return This.FindStringItemsW(pcCondition)
	
		def FindW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def FindAllW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def FindWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def FindAllWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		#>

	   #------------------------------------------------------------#
	  #    FINDING NEXT NTH OCCURRENCE OF A STRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		oListOfStr = This.ToStzList().SectionQR(pnStartingAt, :LastItem, :stzListOfStrings)
		nResult = oListOfStr.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNextNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNthNextOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNthNextOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNextNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNextNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextNthStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthNextOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextNthStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfNextNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		#>

	#--- WITHOUT CASESENSITIVITY

	def FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNextNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNthNextOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNthNextOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNextNth(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNext(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNextNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNextOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindNextNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNextStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindNextNthString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNextString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindNextNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNextOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindNextNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthNextOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfNextNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfNextNthString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfNextNth(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNext(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfNextNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		def PositionsOfNextNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		#>

	   #------------------------------------------------------------#
	  #    FINDING NEXT OCCURRENCE OF A STRING (AS AN ITEM)        #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		nResult = This.SectionQR(pnStartingAt, This.NumberOfStrings(), :stzListOfStrings).
			       FindFirstCS(pcStrItem, pCaseSensitive) +
			       pnStartingAt

		return nResult

		#< @FunctionAlternativeForms

		def FindNextOccurrenceOfStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNextCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNextOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindNextOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextOccurrenceOfStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfNextOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
		
		#>

	#--- WITHOUT CASESENSITIVITY

	def FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNextOccurrenceOfString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindNext(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindNextOccurrence(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindNextStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindNextString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindNextOccurrenceOfThisStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindNextOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNextStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNextString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNext(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNextOccurrence(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextOccurrenceOfString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		def PositionsOfNextOccurrenceOfThisStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		#>

	   #----------------------------------------------------------------#
	  #    FINDING PREVIOUS NTH OCCURRENCE OF A STRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                    #
	#----------------------------------------------------------------#

	def FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		nResult = This.SectionQR(1, pnStartingAt, :stzListOfStrings).
			       FindPreviousCS(pcStrItem, pnStartingAt, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthPreviousOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindNthPreviousOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindPreviousNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def FindPreviousNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousNthStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousNthStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthPreviousOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthPreviousOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindPreviousNth(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPrevious(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindPreviousNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthPreviousStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousNthString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthPreviousString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousNth(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPrevious(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfPreviousNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfPreviousNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
		
		#>

	   #------------------------------------------------------------#
	  #    FINDING PREVIOUS OCCURRENCE OF A STRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		nResult = This.SectionQR(1, pnStartingAt, :stzListOfStrings).
			       FindLastCS(pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindPreviousOccurrenceOfStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def FindPreviousCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def FindPreviousOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def FindPreviousOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfStringCS(pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfPreviousOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
		
		#>

	#---

	def FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, :CS = TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousOccurrenceOfString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindPrevious(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindPreviousOccurrence(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def FindPreviousStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindPreviousString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindPreviousOccurrenceOfThisStringItem(pcStrItem, pnStartingAt, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def FindPreviousOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPrevious(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousOccurrence(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousOccurrenceOfString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		def PositionsOfPreviousOccurrenceOfThisStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		#>

	  #------------------------------------------------------------------------------#
	 #    FINDING NEXT OCCURRENCES OF A STRING-ITEM STARTING AT A GIVEN POSITION    #
	#------------------------------------------------------------------------------#

	def FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		anResult = This.
			   SectionQR( pnStartingAt, This.NumberOfStrings(), :stzListOfStrings ).
			   FindAllCSQR(pcStrItem, pCaseSensitive, :stzListOfNumbers).
			   AddedToEach(pnStartingAt - 1)

		return anResult

		#< @FunctionFluentForm

		def FindNextOccurrencesCSQ(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrencesCSQR(pcStrItem, pnStartingAt, pCaseSensitive, :stzList)

			def FindNextOccurrencesCSQR(pcStrItem, pnStartingAt, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				other
					stzRaise("Unsupported return type!")
				off
		#>

		#< @FunctionAlternativeForms

			def FindAllNextCS(pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def FindNextAllCS(pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)


		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextOccurrences(pcStrItem, pnStartingAt)
		return This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def FindNextOccurrencesQ(pcStrItem, pnStartingAt)
			return This.FindNextOccurrencesQR(pcStrItem, pnStartingAt, :stzList)

			def FindNextOccurrencesQR(pcStrItem, pnStartingAt, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindNextOccurrences(pcStrItem, pnStartingAt) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindNextOccurrences(pcStrItem, pnStartingAt) )

				other
					stzRaise("Unsupported return type!")
				off
		#>

		#< @FunctionAlternativeForms

			def FindAllNext(pcStrItem, pnStartingAt)
				return This.FindNextOccurrences(pcStrItem, pnStartingAt)

			def FindNextAll(pcStrItem, pnStartingAt)
				return This.FindNextOccurrences(pcStrItem, pnStartingAt)

		#>

	  #------------------------------------------------------------------------------#
	 #    FINDING PREVIOUS OCCURRENCES OF A STRING-ITEM STARTING AT A GIVEN POSITION    #
	#------------------------------------------------------------------------------#

	def FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)

			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)


				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		anResult = This.
			   SectionQR( 1, pnStartingAt, :stzListOfStrings ).
			   FindAllCSQ(pcStrItem, pCaseSensitive).
			   Content()

		return anResult

		#< @FunctionFluentForm

		def FindPReviousOccurrencesCSQ(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrencesCSQR(pcStrItem, pnStartingAt, pCaseSensitive, :stzList)

			def FindPreviousOccurrencesCSQR(pcStrItem, pnStartingAt, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				other
					stzRaise("Unsupported return type!")
				off
		#>

		#< @FunctionAlternativeForms

			def FindAllPreviousCS(pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def FindPreviousAllCS(pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousOccurrences(pcStrItem, pnStartingAt)
		return This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def FindPreviousOccurrencesQ(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrencesQR(pcStrItem, pnStartingAt, :stzList)

			def FindPreviousOccurrencesQR(pcStrItem, pnStartingAt, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindPreviousOccurrences(pcStrItem, pnStartingAt) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindPreviousOccurrences(pcStrItem, pnStartingAt) )

				other
					stzRaise("Unsupported return type!")
				off
		#>

		#< @FunctionAlternativeForms

			def FindAllPrevious(pcStrItem, pnStartingAt)
				return This.FindPreviousOccurrences(pcStrItem, pnStartingAt)

			def FindPreviousAll(pcStrItem, pnStartingAt)
				return This.FindPreviousOccurrences(pcStrItem, pnStartingAt)

		#>

	  #====================================================#
	 #     FINDING A SUBSTRING IN THE LIST OF STRINGS     #
	#====================================================#

	def FindSubStringCS(pcSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please?",
			"Mabrooka!",
			"Your name and my name are not the same...",
			"I see.",
			"Nice to meet you,",
			"Mabrooka!"
		])
	
		? @@( o1.FindSubstringCS("name", :CaseSensitive = TRUE) )
			#--> [ "1" = [ 13 ], "3" = [ 6, 18 ] ]
		*/

		aResult = []
		
		i = 0
		for str in This.ListOfStrings()
			i++
			
			anPos = StzStringQ(str).FindAllCS(pcSubStr, pCaseSensitive)
			if len(anPos) > 0
				aResult + [ ""+ i, anPos ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindAllSubstringsCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def FindAllOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubstringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def AllPositionsOfSubStringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubString(pcSubStr)
		return This.FindSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def PositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def AllPositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		#>

	   #-------------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF A SUBSTRING  INSIDE EACH   #
	 #    STRING OF THE LIST OF STRINGS                      #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		/* REMINDER

		o1 = new stzListOfStrings([
			"How many roads must a man walk down",
			"Before you call him a man?",
			"How many seas must a white dove sail",
			"Before she sleeps in the sand?",
			"And how many times must the cannonballs fly",
			"Before they're forever banned?",
			"The answer, my friend, is blowin' in the wind",
			"The answer is blowin' in the wind"
		]

		o1.NumberOfOccurrencesCS("man", :CS = FALSE)
		# --> [
		#	"1" = [ 5, 23 ],
		#	"2" = [ 23 ],
		#	"3" = [ 5 ],
		#	"5" = [ 9 ]
		#     ]

		--> the substring is found in positions 5 and 23 in 1st string,
		in position 23 in 2nd string, and in position 9 in 3rd string.

		*/

		aTemp = This.FindSubStringCS(pcSubStr, pCaseSensitive)
		nResult = 0

		for aPair in aTemp
			nResult += len(aPair[2])
		next

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubString(pcStr)
		return This.NumberOfOccurrenceOfSubStringCS(pcStr, :CaseSensitive = TRUE)

	   #----------------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF MANY SUBSTRINGS INSIDE EACH   #
	 #    STRING OF THE LIST OF STRINGS                         #
	#----------------------------------------------------------#

	def NumberOfOccurrenceOfManySubstringsCS(pacSubStr, pCaseSensitive)

		if NOT StzListQ(paSubStr).IsListOfStrings()
			stzRaise("Syntax Error: 1st param must be a list of strings!")
		ok

		pacSubStr = StzListQ(pacSubStr).DuplicatesRemoved()

		aResult = []

		for cSubStr in pacSubstr

			aResult + This.NumberOfOccurrenceOfSubstringCS(cSubStr, pCaseSensitive)
		next

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfManySubstrings(pacSubStr)
		return This.NumberOfOccurrenceOfManySubstringsCS(pacSubStr, :CaseSensitive = TRUE)

	   #----------------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF MANY SUBSTRINGS INSIDE EACH   #
	 #    STRING OF THE LIST OF STRINGS -- EXTENDED             #
	#----------------------------------------------------------#

	def NumberOfOccurrenceOfManySubstringsCSXT(pacSubStr, pCaseSensitive)

		if NOT StzListQ(paSubStr).IsListOfStrings()
			stzRaise("Syntax Error: 1st param must be a list of strings!")
		ok

		pacSubStr = StzListQ(pacSubStr).DuplicatesRemoved()

		aResult = []

		for cSubStr in pacSubstr

			aResult + [ cSubStr, This.NumberOfOccurrenceOfSubstringCS(cSubStr, pCaseSensitive) ]
		next

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfManySubstringsXT(pacSubStr)
		return This.NumberOfOccurrenceOfManySubstringsCSXT(pacSubStr, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------------#
	 #  CHECKING IF THE LIST CONTAINS A GIVEN SUSBTRING IN ITS STRINGS   #
	#-------------------------------------------------------------------#

	def ContainsSubstringCS(pcSubStr, pCaseSensitive)
		if This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  CHECKING IF EACH STRING-ITEM CONTAINS N TIMES A GIVEN SUSBTRING   #
	#--------------------------------------------------------------------#

	def EachStringItemContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		bResult = TRUE

		for oStr in This.ToListOfStzStrings()

			if NOT oStr.ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def EachStringContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
			return This.EachStringItemContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

		def EachStringItemContainsNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.EachStringItemContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

		def EachStringContainsNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.EachStringItemContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def EachStringItemContainsNTimesTheSubstring(n, pcSubstr)
		return This.EachStringItemContainsNTimesTheSubstringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def EachStringContainsNTimesTheSubstring(n, pcSubstr)
			return This.EachStringItemContainsNTimesTheSubstring(n, pcSubstr)

		def EachStringItemContainsNTimes(n, pcSubStr)
			return This.EachStringItemContainsNTimesTheSubstring(n, pcSubstr)

		def EachStringContainsNTimes(n, pcSubStr)
			return This.EachStringItemContainsNTimesTheSubstring(n, pcSubstr)

	  #---------------------------------------------------------#
	 #     STRINGS CONTAINING A GIVEN SUBSTRING (FILTERING)    #
	#---------------------------------------------------------#

	def StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok
			 
		if isNumber(pCaseSensitive) and ( pCaseSensitive = 0 or pCaseSensitive = 1 )

			oQList = This.QStringListObject().filter(pcSubStr, pCaseSensitive)
			return QStringListContent(oQList)

		else
			stzRaise("Incorrect param! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		#< @FunctionfluentForm

		def StringItemssContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.StringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def StringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemssContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemssContainingSubStringCS(pcSubStr, pCaseSensitive) )

			other
				stzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def StringsContainingSubStringCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
				return This.StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def StringItemsContainingCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringItemsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.StringItemsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringItemsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def StringsContainingCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.StringsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def FilterStringItemsCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and
			     (  Q(pcSubStr).IsUsingNamedParamList() or
				Q(pcSubStr).IsWithNamedParamList() or
				Q(pcSubStr).IsOnNamedParamList() or
				Q(pcSubStr).IsByNamedParamList() )
	
				pcSubStr = pcSubstr[2]
			ok
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterStringItemsCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringItemsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterStringItemsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringItemsCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringItemsCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def FilterStringsCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterStringsCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterStringsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringsCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringsCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def FilterCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off
		#>

	#-- WITHOUT CASESENSITIVITY

	def StringItemsContainingSubString(pcSubStr)
		return This.StringItemsContainingSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionfluentForm

		def StringItemssContainingSubStringQ(pcSubStr)
			return This.StringItemssContainingSubStringQR(pcSubStr, :stzList)

		def StringItemssContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemssContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemssContainingSubString(pcSubStr) )

			other
				stzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def StringsContainingSubString(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringsContainingSubStringQ(pcSubStr)
				return This.StringsContainingSubStringQR(pcSubStr, :stzList)

			def StringsContainingSubStringQR(pcSubStr, pCaseSensitive)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingSubString(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingSubString(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def StringItemsContaining(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringItemsContainingQ(pcSubStr)
				return This.StringItemsContainingQR(pcSubStr, :stzList)

			def StringItemsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContaining(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def StringsContaining(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringsContainingQ(pcSubStr)
				return This.StringsContainingQR(pcSubStr, :stzList)

			def StringsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContaining(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def FilterStringItems(pcSubStr)
			if isList(pcSubStr) and
			     (  Q(pcSubStr).IsUsingNamedParamList() or
				Q(pcSubStr).IsWithNamedParamList() or
				Q(pcSubStr).IsOnNamedParamList() or
				Q(pcSubStr).IsByNamedParamList() )
	
				pcSubStr = pcSubstr[2]
			ok
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterStringItemsQ(pcSubStr)
				return This.FilterStringItemsQR(pcSubStr, :stzList)

			def FilterStringItemsQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringItems(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringItems(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def FilterStrings(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterStringsQ(pcSubStr)
				return This.FilterStringsQR(pcSubStr, :stzList)

			def FilterStringsQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStrings(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStrings(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def Filter(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterQ(pcSubStr)
				return This.FilterStringsQR(pcSubStr, :stzList)

			def FilterQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Filter(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Filter(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off
		#>

	  #-----------------------------------------------------#
	 #     UNIQUE STRINGS CONTAINING A GIVEN SUBSTRING     #
	#-----------------------------------------------------#

	def UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

		acResult =  This.
			   StringItemsContainingSubStringCSQ(pcSubStr, pCaseSensitive).
			   DuplicatesRemoved()

		return acResult

		#< @FunctionfluentForm

		def UniqueStringItemssContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def UniqueStringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemssContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemssContainingSubStringCS(pcSubStr, pCaseSensitive) )

			other
				stzRaise("Unsupported param type!")
			off

		#>

		def UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringItemsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringItemsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringItemsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def UniqueStringsContainingCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported param type!")
				off

	#-- WITHOUT CASESENSITIVITY

	def UniqueStringItemsContainingSubString(pcSubStr)
		return This.UniqueStringItemsContainingSubStringCS(pcSubStr, :CS = TRUE)

		#< @FunctionfluentForm

		def UniqueStringItemssContainingSubStringQ(pcSubStr)
			return This.UniqueStringItemssContainingSubStringQR(pcSubStr, :stzList)

		def UniqueStringItemssContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemssContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemssContainingSubString(pcSubStr) )

			other
				stzRaise("Unsupported param type!")
			off

		#>

		def UniqueStringsContainingSubString(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringsContainingSubStringQ(pcSubStr)
				return This.UniqueStringsContainingSubStringQR(pcSubStr, :stzList)

			def UniqueStringsContainingSubStringQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingSubString(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingSubString(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def UniqueStringItemsContaining(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringItemsContainingQ(pcSubStr)
				return This.UniqueStringItemsContainingQR(pcSubStr, :stzList)

			def UniqueStringItemsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContaining(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def UniqueStringsContaining(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringsContainingQ(pcSubStr)
				return This.UniqueStringsContainingQR(pcSubStr, :stzList)

			def UniqueStringsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContaining(pcSubStr) )
	
				other
					stzRaise("Unsupported param type!")
				off

  	  #-----------------------------------------------------#
	 #     STRINGS CONTAINING N TIMES A GIVEN SUBSTRING    #
	#-----------------------------------------------------#

	def StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		acResult = TRUE
		aListOfStzStrings = This.ToListOfStzStrings()

		for oStr in aListOfStzStrings

			if  oStr.ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				acResult + str
			ok
		next

		return acResult

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)

		def StringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)
	
			def StringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def StringItemsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def StringsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def StringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstring(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringsContainingNTimesTheSubstringQ(n, pcSubstr)
				return This.StringsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)
	
			def StringsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringCS(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimesTheSubstring(n, pcSubstr) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimes(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringItemsContainingNTimesQ(n, pcSubstr)
				return This.StringItemsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def StringItemsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingNTimes(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def StringsContainingNTimes(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringsContainingNTimesQ(n, pcSubstr)
				return This.StringsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def StringsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimes(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

  	  #------------------------------------------------------------#
	 #     UNIQUE STRINGS CONTAINING N TIMES A GIVEN SUBSTRING    #
	#------------------------------------------------------------#

	def UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		acResult = This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		acResult = StzListQ(acResult).DuplicatesRemoved()

		return acResult

		#< @FunctionFluentForm

		def UniqueStringItemsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)

		def UniqueStringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)
	
			def UniqueStringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def UniqueStringItemsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringItemsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def UniqueStringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def UniqueStringsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def UniqueStringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#---

	def UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def UniqueStringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def UniqueStringsContainingNTimesTheSubstring(n, pcSubstr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringsContainingNTimesTheSubstringQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)
	
			def UniqueStringsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesTheSubstring(n, pcSubstr) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def UniqueStringItemsContainingNTimes(n, pcSubStr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringItemsContainingNTimesQ(n, pcSubstr)
				return This.UniqueStringItemsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def UniqueStringItemsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingNTimes(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def UniqueStringsContainingNTimes(n, pcSubStr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringsContainingNTimesQ(n, pcSubstr)
				return This.UniqueStringsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def UniqueStringsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimes(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

  	   #-----------------------------------------------------------------#
	  #    STRINGS CONTAINING N TIMES A GIVEN SUBSTRING -- EXTENDED     #
	 #   (ALONG WITH THE POSITIONS OF THE SUBSTRING IN EACH STRING)    #
	#-----------------------------------------------------------------#

	def StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)
		acResult = TRUE
		aListOfStzStrings = This.ToListOfStzStrings()

		for oStr in aListOfStzStrings

			if  oStr.ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				acResult + [ str, oStr.FindAllCS(pcSubstr, pCaseSensitive) ]
			ok
		next

		return acResult

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringCSXTQ(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, :stzList)

		def StringItemsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive) )

			on :stzHashlList
				return new stzHashList( This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesTheSubstringCSXTQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, :stzList)
	
			def StringsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimesCSXT(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)

			def StringItemsContainingNTimesCSXTQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringItemsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimesCSXT(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringItemsContainingNTimesCSXT(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def StringsContainingNTimesCSXT(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesCSXTQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesCSXT(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringsContainingNTimesCSXT(n, pcSubstr, pCaseSensitive) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITTY

	def StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringXTQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr) )

			on :stzHashList
				return new stzHashList( This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstringXT(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringsContainingNTimesTheSubstringXTQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringXTQR(n, pcSubstr, :stzList)
	
			def StringsContainingNTimesTheSubstringXTQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringCSXT(n, pcSubstr) )
	
				on :stzHashlList
					return new stzHashList( This.StringsContainingNTimesTheSubstringXT(n, pcSubstr) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimesXT(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringItemsContainingNTimesXTQ(n, pcSubstr)
				return This.StringItemsContainingNTimesXTQR(n, pcSubstr, :stzList)
		
			def StringItemsContainingNTimesXTQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimesXT(n, pcSubstr) )
	
				on :stzHashlList
					return new stzHashList( This.StringItemsContainingNTimesXT(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		def StringsContainingNTimesXT(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringsContainingNTimesXTQ(n, pcSubstr)
				return This.StringsContainingNTimesXTQR(n, pcSubstr, :stzList)
		
			def StringsContainingNTimesXTQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesXT(n, pcSubstr) )
	
				on :stzHashlList
					return new stzHashList( This.StringsContainingNTimesXT(n, pcSubstr) )
		
				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #-------------------------------------------------------------------#
	 #    FINDING NTH OCCURRENCE OF A SUBTRING IN THE LIST OF STRINGS    #
	#-------------------------------------------------------------------#
	
	def FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindNthOccurrenceOfSubStringCS(2, "name", :CaseSensitive = TRUE)
		#--> [ "3" = 6 ]
		*/

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		if NOT n <= This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			stzRaise("Incorrect value! n must be a number <= number of occurrences of the substring in all the strings.")
		ok

		# Doing the job

		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		# position is searched for inside aPositionsXT

		anResult = []
		i = 0
		for aPair in aPositionsXT
			cLevel = aPair[1]
			anPositions = aPair[2]
			q = 0

			for nPos in anPositions
				i++
				q++
				if i = n
					anResult = [ cLevel, anPositions[q] ]
					exit 2
				ok
			next
		next

		return anResult

		def FindNthSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcSubStr, pCaseSensitive)

		def FindNthOccurrenceOfThisSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceOfSubString(n, pcSubStr)
		return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindNthSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def FindNthOccurrenceOfThisSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

	  #-------------------------------------------------------------------#
	 #   FINDING FIRST OCCURRENCE OF A SUBTRING IN THE LIST OF STRINGS   #
	#-------------------------------------------------------------------#
	
	def FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(1, pcSubStr, pCaseSensitive)

		def FindFirstSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindFirstOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceOfSubString(pcSubStr)
		return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def FindFirstOccurrenceOfThisSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

	  #-------------------------------------------------------------------#
	 #    FINDING LAST OCCURRENCE OF A SUBTRING IN THE LIST OF STRINGS   #
	#-------------------------------------------------------------------#
		
	def FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(:Last, pcSubStr, pCaseSensitive)

		def FindLastSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindLastOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def FindLastOccurrenceOfSubString(pcSubStr)
		return This.FindLastOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def FindLastOccurrenceOfThisSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

	  #------------------------------------------------#
	 #   FINDING MANY SUBSTRINGS AT THE SAME TIME     #
	#------------------------------------------------#

	def FindSubStringsCS(pacStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindSubStringsCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 16, 21 ] ]
		*/

		/* ... */

		def FindManySubtringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

		def FindTheseSubStringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStrings(pacStr)
		return This.FindSubStringsCS(pacStr, :CaseSensitive = TRUE)

		def FindManySubStrings(pacStr)
			return This.FindSubStrings(pacStr)

		def FindTheseSubStrings(pacStr)
			return This.FindSubStrings(pacStr)

	  #----------------------------------------------------------#
	 #   FINDING MANY SUBSTRINGS AT THE SAME TIME -- EXTENDED   #
	#----------------------------------------------------------#

	def FindSubstringsCSXT(pacSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindManySubstringsCSXT("name", :CaseSensitive = TRUE)
		#--> [
		#	:name = [ "1" = [ 13 ], "3" = [ 6, 21 ] ],
		#	:nice = [ "3" = [ 16 ]
		#    ]
		*/

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			stzRaise("Incorrect param type! You must provide a list of strings.")
		ok

		if len(pacSubStr) = 0
			return []
		ok

		pacSubStr = StzListQ(pacSubStr).ToSet()
		aResult = []

		for cSubStr in pacSubStr
			anPos = This.FindSubstringCS(cSubStr, pCaseSensitive)
			if len(anPos) > 0
				aResult + [ cSubStr, anPos ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindSubStringsXTCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		def FindManySubStringsCSXT(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

			def FindManySubStringsXTCS(pacStr, pCaseSensitive)
				return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		def FindTheseSubStringsCSXT(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

			def FindTheseSubStringsXTCS(pacStr, pCaseSensitive)
				return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubstringsXT(pacSubStr)
		return This.FindSubstringsCSXT(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindManySubStringsXT(pacStr)
			return This.FindSubStringsXT(pacStr)

		def FindTheseSubStringsXT(pacStr)
			return This.FindSubStringsXT(pacStr)

		#>

	   #---------------------------------------------------------#
	  #      CHECKING IF EACH STRING OF THE LIST OF STRINGS     #
	 #      CONTAINS EACH THE PROVIDED SUBSTRINGS              #
	#---------------------------------------------------------#

	def ContainsSubStringsCS(pacSubStr, pCaseSensitive)

		bResult = TRUE

		for str in pacStr
			if NOT This.ContainsSubStringCS(str, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForm

		def ContainsEachSubstringCS(pacSubStr, pCaseSensitive)
			return This.ContainsSubStringsCS(pacSubStr, pCaseSensitive)

		def ContainsEachSubStringOfTheseCS(pacSubStr, pCaseSensitive)
			return This.ContainsStringsCS(pacSubStr, pCaseSensitive)

		def ContainsEachSubStringOfTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.ContainsStringsCS(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStrings(pacSubStr)

		return This.ContainsSubStrings(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def ContainsEachSubstring(pacSubStr)
			return This.ContainsSubStrings(pacSubStr)

		def ContainsEachSubStringOfThese(pacSubStr)
			return This.ContainsSubStrings(pacSubStr)

		def ContainsEachSubStringOfTheseSubStrings(pacSubStr)
			return This.ContainsSubStrings(pacSubStr)

		#>

	   #---------------------------------------------------#
	  #    FINDING NEXT NTH OCCURRENCE OF A SUBSTRING     #
	 #    STARTING AT A GIVEN POSITION [ LEVEL, POS]     #
	#---------------------------------------------------#

	def FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstSubString ])
				  
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastSubString ])

				This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		#--

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		# Doing the job

		oListOfStr = This.SectionQR(pnStartingAt, :LastItem, :stzListOfStrings)
		aResult = oListOfStr.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNthNextOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def FindNextNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthNextSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def FindNextNthOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthNextOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def PositionsOfNextNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def PositionsOfNthNextSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextNthOccurrenceOfSubString(n, pcSubStr, pnStartingAt)

		return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, :CS = TRUE)

		#< @FunctionAlternativeForms

		def FindNthNextOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

		def FindNextNthSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthNextSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		def FindNextNthOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthNextOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
		
		def PositionsOfNextNthSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(pcSubStr)

			def PositionsOfNthNextSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextNthOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		def PositionsOfNextNthOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		#>

	   #------------------------------------------------------------#
	  #    FINDING NEXT OCCURRENCE OF A SUBSTRING (AS AN ITEM)     #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindNextOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		oListOfStr = This.SectionQR(pnStartingAt, :LastItem, :stzListOfSubStrings)
		aResult = oListOfStr.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms
	
		def FindNextSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def FindNextOccurrenceOfThisSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfNextSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfNextOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfNextOccurrenceOfThisSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextOccurrenceOfSubString(pcSubStr, pnStartingAt)

		return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, :CS = TRUE)

		#< @FunctionAlternativeForms

		def FindNextSubString(pcSubStr, pnStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def FindNextOccurrenceOfThisSubString(pcSubStr, pnStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextSubString(pcSubStr, pnStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextOccurrenceOfSubString(pcSubStr, pnStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextOccurrenceOfThisSubString(pcSubStr, pnStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		#>

	   #-------------------------------------------------------------------#
	  #    FINDING PREVIOUS NTH OCCURRENCE OF A SUBSTRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                       #
	#-------------------------------------------------------------------#

	def FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstSubString ])
				  
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastSubString ])

				This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		#--

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		# Doing the job

		oListOfStr = This.SectionQR(pnStartingAt, :LastItem, :stzListOfSubStrings)
		nNumOcc = oListOfStr.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		aResult = oListOfStr.FindNthOccurrenceOfSubStringCS(nNumOcc - n, pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		def FindPreviousNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthPreviousSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def FindPreviousNthOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		def PositionsOfPreviousNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousNthOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthOccurrenceOfSubString(n, pcSubStr, pnStartingAt)

		return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, :CS = TRUE)

		#< @FunctionAlternativeForms

		def FindNthPreviousOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

		def FindPreviousNthSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthPreviousSubString(n, pcSubStr, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
	
		def FindPreviousNthOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthPreviousOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
	
		def PositionsOfPreviousNthSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(pcSubStr)

			def PositionsOfNthPreviousSubString(n, pcSubStr, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(pcSubStr)
	
		def PositionsOfPreviousNthOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthPreviousOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
		
		def PositionsOfPreviousNthOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthPreviousOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

		#>

	   #---------------------------------------------------------------#
	  #    FINDING PREVIOUS OCCURRENCE OF A SUBSTRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                   #
	#---------------------------------------------------------------#

	def FindPreviousOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		oListOfStr = This.SectionQR(pnStartingAt, :LastString, :stzListOfSubStrings)
		aResult = oListOfStr.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms
	
		def FindPreviousSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def FindPreviousOccurrenceOfThisSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousOccurrenceOfThisSubStringCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousOccurrenceOfSubString(pcSubStr, pnStartingAt)

		return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)
		
		def FindPreviousOccurrenceOfThisSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfPreviousSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfThisSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		#>

	  #=============================================#
	 #   REPLACING ALL STRINGS WITH A NEW STRING   #
	#=============================================#

	def ReplaceAllStrings(pcNewString)

		for i = 1 to This.NumberOfStrings()
			This.ReplaceStringAtPosition(i, pcNewString)
		next

		#< @FunctionFluentForm

		def ReplaceAllStringsQ(pcNewString)
			This.ReplaceAllStrings(pcNewString)
			return THis
		#>

		#< @FunctionAlternativeForm

		def ReplaceAllStringItems(pcNewString)
			This.ReplaceAllStrings(pcNewString)

			def ReplaceAllStringItemsQ(pcNewString)
				This.ReplaceAllStringItems(pcNewString)
				return This

		#>

	  #-------------------------------------------#
	 #   REPLACING ALL OCCURRENCES OF A STRING   #
	#-------------------------------------------#

	def ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)
			
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		anPositions = This.FindAllCS(pcString, pCaseSensitive)

		for n in anPositions
			This.ReplaceStringAtPosition(n, pcNewString)
		next

		#< @FunctionFluentForm

		def ReplaceAllOccurrencesOfStringCSQ(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceAllOccurrencesOfStringItemCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceAllOccurrencesOfStringItemCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceAllOccurrencesOfStringItemCS(pcString, pcNewString, pCaseSensitive)
				return This

		#--

		def ReplaceStringCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, :CaseSensitive = TRUE)

			def ReplaceStringCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceStringCS(pcString, pcNewString, pCaseSensitive)
				return This

		def ReplaceStringItemCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceStringItemCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceStringItemCS(pcString, pcNewString, pCaseSensitive)
				return This	
		#--

		def ReplaceOccurrencesCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceOccurrencesCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceOccurrencesCS(pcString, pcNewString, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceAllOccurrencesCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceAllOccurrencesCS(pcString, pcNewString, pCaseSensitive)
				return This

		def ReplaceAllCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceAllCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceAllCS(pcString, pcNewString, pCaseSensitive)
				return This

		def ReplaceCS(pcString, pcNewString, pCaseSensitive)
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

			def ReplaceCSQ(pcString, pcNewString, pCaseSensitive)
				This.ReplaceCS(pcString, pcNewString, pCaseSensitive)
				return This

		#>

	def StringReplacedByCS(pcString, pcNewString, pCaseSensitive)

		aResult =  This.Copy().
				ReplaceStringCSQ(pcString, pcNewString, pCaseSensitive).
				Content()

		return aResult

		def StringItemReplacedCSBy(pcString, pcNewString, pCaseSensitive)
			return StringReplacedByCS(pcString, pcNewString, pCaseSensitive)

		def AllOccurrencesOfStringReplacedByCS(pcString, pcNewString, pCaseSensitive)
			return StringReplacedByCS(pcString, pcNewString, pCaseSensitive)

		def AllOccurrencesOfStringItemReplacedByCS(pcString, pcNewString, pCaseSensitive)
			return StringReplacedByCS(pcString, pcNewString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAllOccurrencesOfString(pcString, pcNewString)
		This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, :CS = TRUE)

		#< @FunctionFluentForm

		def ReplaceAllOccurrencesOfStringQ(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceAllOccurrencesOfStringItem(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceAllOccurrencesOfStringItemQ(pcString, pcNewString)
				This.ReplaceAllOccurrencesOfStringItem(pcString, pcNewString)
				return This

		#--

		def ReplaceString(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceStringQ(pcString, pcNewString)
				This.ReplaceString(pcString, pcNewString)
				return This

		def ReplaceStringItem(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceStringItemQ(pcString, pcNewString)
				This.ReplaceStringItem(pcString, pcNewString)
				return This	
		#--

		def ReplaceOccurrences(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceOccurrencesQ(pcString, pcNewString)
				This.ReplaceOccurrences(pcString, pcNewString)
				return This

		def ReplaceAllOccurrences(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceAllOccurrencesQ(pcString, pcNewString)
				This.ReplaceAllOccurrences(pcString, pcNewString)
				return This

		def ReplaceAll(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceAllQ(pcString, pcNewString)
				This.ReplaceAll(pcString, pcNewString)
				return This

		def Replace(pcString, pcNewString)
			This.ReplaceAllOccurrencesOfString(pcString, pcNewString)

			def ReplaceQ(pcString, pcNewString)
				This.Replace(pcString, pcNewString)
				return This

		#>

	def StringReplacedBy(pcString, pcNewString)

		aResult =  This.Copy().
				ReplaceStringQ(pcString, pcNewString).
				Content()

		return aResult

		def StringItemReplacedBy(pcString, pcNewString)
			return StringReplacedBy(pcString, pcNewString)

		def AllOccurrencesOfStringReplacedBy(pcString, pcNewString)
			return StringReplacedBy(pcString, pcNewString)

		def AllOccurrencesOfStringItemReplacedBy(pcString, pcNewString)
			return StringReplacedBy(pcString, pcNewString)

	  #-----------------------------------------------#
	 #    REPLACING MANY STRINGS AT THE SAME TIME    #
	#-----------------------------------------------#

	def ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

		for str in pacStrings
			This.ReplaceAllOccurrencesCS(:Of = str, pcNewString, pCaseSensitive)
		next

		#< @FunctionFluentForm

		def ReplaceManyStringsCSQ(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceManyStringItemsCS(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

			def ReplaceManyStringItemsCSQ(pacStrings, pcNewString, pCaseSensitive)
				This.ReplaceManyStringItemsCS(pacStrings, pcNewString, pCaseSensitive)
				return This

		def ReplaceManyCS(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

			def ReplaceManyCSQ(pacStrings, pcNewString, pCaseSensitive)
				This.ReplaceManyCS(pacStrings, pcNewString, pCaseSensitive)
				return This

		def ReplaceAllOfTheseCS(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

			def ReplaceAllOfTheseCSQ(pacStrings, pcNewString, pCaseSensitive)
				This.ReplaceAllOfTheseCS(pacStrings, pcNewString, pCaseSensitive)
				return This

		#--

		def ReplaceTheseStringsCS(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

			def ReplaceTheseStringsCSQ(pacStrings, pcNewString, pCaseSensitive)
				This.ReplaceTheseStringsCS(pacStrings, pcNewString, pCaseSensitive)
				return This

		def ReplaceTheseStringItemsCS(pacStrings, pcNewString, pCaseSensitive)
			This.ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

			def ReplaceTheseStringItemsCSQ(pacStrings, pcNewString, pCaseSensitive)
				This.ReplaceTheseStringsCS(pacStrings, pcNewString, pCaseSensitive)
				return This

		#>

	def ManyStringsReplacedCS(pacStrings, pcNewString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceTheseStringsCSQ(pacStrings, pcNewString, pCaseSensitive).
				Content()

		return aResult

		def ManyStringItemsReplacedCS(pacStrings, pcNewString, pCaseSensitive)
			return This.ManyStringsReplacedCS(pacStrings, pcNewString, pCaseSensitive)

		def TheseStringsReplacedCS(pacStrings, pcNewString, pCaseSensitive)
			return This.ManyStringsReplacedCS(pacStrings, pcNewString, pCaseSensitive)

		def TheseStringItemsReplacedCS(pacStrings, pcNewString, pCaseSensitive)
			return This.ManyStringsReplacedCS(pacStrings, pcNewString, pCaseSensitive)
	
	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyStrings(pacStrings, pcNewString)
		This.ReplaceManyStringsCS(pacStrings, pcNewString, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceManyStringsQ(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceManyStringItems(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)

			def ReplaceManyStringItemsQ(pacStrings, pcNewString)
				This.ReplaceManyStringItems(pacStrings, pcNewString)
				return This

		def ReplaceMany(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)

			def ReplaceManyQ(pacStrings, pcNewString)
				This.ReplaceMany(pacStrings, pcNewString)
				return This

		def ReplaceAllOfThese(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)

			def ReplaceAllOfTheseQ(pacStrings, pcNewString)
				This.ReplaceAllOfThese(pacStrings, pcNewString)
				return This

		#--

		def ReplaceTheseStrings(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)

			def ReplaceTheseStringsQ(pacStrings, pcNewString)
				This.ReplaceTheseStrings(pacStrings, pcNewString)
				return This

		def ReplaceTheseStringItems(pacStrings, pcNewString)
			This.ReplaceManyStrings(pacStrings, pcNewString)

			def ReplaceTheseStringItemsQ(pacStrings, pcNewString)
				This.ReplaceTheseStrings(pacStrings, pcNewString)
				return This

		#>

	def ManyStringsReplaced(pacStrings, pcNewString)

		aResult  = This.Copy().
				ReplaceTheseStringsQ(pacStrings, pcNewString).
				Content()

		return aResult

		def ManyStringItemsReplaced(pacStrings, pcNewString)
			return This.ManyStringsReplaced(pacStrings, pcNewString)

		def TheseStringsReplaced(pacStrings, pcNewString)
			return This.ManyStringsReplaced(pacStrings, pcNewString)

		def TheseStringItemsReplaced(pacStrings, pcNewString)
			return This.ManyStringsReplaced(pacStrings, pcNewString)

	  #--------------------------------------------------------#
	 #    REPLACING MANY STRINGS BY MANY OTHERS ONE BY ONE    #
	#--------------------------------------------------------#

	def ReplaceManyOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
		if NOT isList(pacStrings) and Q(pacStrings).IsListOfStrings()
			stzRaise("Uncorrect param! pacStrings must be a list of strings.")
		ok

		if isList(pacNewStrings) and Q(pacNewStrings).IsWithOrByNamedParamList()
			pacNewStrings = pacNewStrings[2]
		ok

		if NOT isList(pacNewStrings) and Q(pacNewStrings).IsListOfStrings()
			stzRaise("Uncorrect param! pacNewStrings must be a list of strings.")
		ok

		i = 0
		for str in pacStrings

			i++
			cNewStr = NULL

			if i <= len(pacNewStrings)
				cNewStr = pacNewStrings[i]
			ok

			This.ReplaceCS(str, cNewStr, pCaseSensitive)

		next

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyOneByOne(pacStrings, pacNewStrings)
		This.ReplaceManyOneByOneCS(pacStrings, pacNewStrings, :CS = TRUE)

	  #--------------------------------------#
	 #   REPLACING A STRING BY ALTERNANCE   #
	#--------------------------------------#

	def ReplaceStringByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)
		/*
		StzListOfStringsQ([ "A", "A", "A", "A", "A" ]) {
			ReplaceStringByAlternance("A", :With = [ "#1", "#2" ])
			? Content()

		}
		# --> [ "#1", "#2", "#1", "#2", "#1" ]
		*/

		if isList(pacOtherStrings) and
		   StzListQ(pacOtherStrings).IsWithOrByNamedParamList()
		
			pacOtherStrings = pacOtherStrings[2]
		ok

		if IsNotList(pacOtherStrings)
			stzRaise("Incorrect param type! paOtherStrings must be a list.")
		ok

		anPositions = This.FindAllCS(pcString, pCaseSensitive)

		i = 0
		for nPos in anPositions
			i++
			if i > len(pacOtherStrings)
				i = 1
			ok
			This.ReplaceStringAtPosition(nPos, pacOtherStrings[i])
			
		next

		#< @FunctionFluentForm

		def ReplaceStringByALternanceCSQ(pcString, pacOtherStrings, pCaseSensitive)
			This.ReplaceStringByALternanceCS(pcString, pacOtherStrings, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)
			This.ReplaceStringByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)

			def ReplaceStringItemByAlternanceCSQ(pcString, pacOtherStrings, pCaseSensitive)
				This.ReplaceStringItemByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)
				return This
		#>

	def StringReplacedByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceStringByALternanceCSQ(pcString, pacOtherStrings, pCaseSensitive).
				Content()

		return aResult

		def StringItemReplaceByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)
			return This.StringReplacedByAlternanceCS(pcString, pacOtherStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceStringByAlternance(pcString, pacOtherStrings)
		This.ReplaceStringByAlternanceCS(pcString, pacOtherStrings, :CS = TRUE)

		#< @FunctionFluentForm

		def ReplaceStringByALternanceQ(pcString, pacOtherStrings)
			This.ReplaceStringByALternance(pcString, pacOtherStrings)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByAlternance(pcString, pacOtherStrings)
			This.ReplaceStringByAlternance(pcString, pacOtherStrings)

			def ReplaceStringItemByAlternanceQ(pcString, pacOtherStrings)
				This.ReplaceStringItemByAlternance(pcString, pacOtherStrings)
				return This
		#>

	def StringReplacedByAlternance(pcString, pacOtherStrings)

		aResult  = This.Copy().
				ReplaceStringByALternanceQ(pcString, pacOtherStrings).
				Content()

		return aResult

		def StringItemReplaceByAlternance(pcString, pacOtherStrings)
			return This.StringReplacedByAlternance(pcString, pacOtherStrings)

	   #-----------------------------------------------------#
	  #   REPLACING THE NEXT OCCURRENCES OF A STRING-ITEM   #
         #   STARTING AT A GIVEN POSITION                      #
	#-----------------------------------------------------#

	def ReplaceNextOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

		anPositions = This.FindNextOccurrencesCS(pcString, pnStartingAt, pCaseSensitive)

		This.ReplaceStringsAtPositions(anPositions, pcOtherString)

		def ReplaceNextOccurrencesCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
			This.ReplaceNextOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
			return This

		def ReplaceNextCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
			This.ReplaceNextOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

			def ReplaceNextCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
				This.ReplaceNextCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
				return This

	def NextOccurrencesReplacedCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

		acResult = This.Copy().
				ReplaceNextOccurrencesCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive).
				Content()

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNextOccurrences(pcString, pcOtherString, pnStartingAt)
		ReplaceNextOccurrencesCS(pcString, pcOtherString, pnStartingAt, :CS = TRUE)

		def ReplaceNextOccurrencesQ(pcString, pcOtherString, pnStartingAt)
			This.ReplaceNextOccurrences(pcString, pcOtherString, pnStartingAt)
			return This

		def ReplaceNext(pcString, pcOtherString, pnStartingAt)
			This.ReplaceNextOccurrences(pcString, pcOtherString, pnStartingAt)

			def ReplaceNextQ(pcString, pcOtherString, pnStartingAt)
				This.ReplaceNext(pcString, pcOtherString, pnStartingAt)
				return This

	def NextOccurrencesReplacedQ(pcString, pcOtherString, pnStartingAt)

		acResult = This.Copy().
				ReplaceNextOccurrencesQ(pcString, pcOtherString, pnStartingAt).
				Content()

		return acResult

	   #---------------------------------------------------------#
	  #   REPLACING THE PREVIOUS OCCURRENCES OF A STRING-ITEM   #
         #   STARTING AT A GIVEN POSITION                          #
	#---------------------------------------------------------#

	def ReplacePreviousOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

		anPositions = This.FindPreviousOccurrencesCS(pcString, pnStartingAt, pCaseSensitive)

		This.ReplaceStringsAtPositions(anPositions, pcOtherString)

		def ReplacePreviousOccurrencesCSQ(pcString, pcOtherString, pStartingAt, pCaseSensitive)
			This.ReplacePreviousOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
			return This

		def ReplacePreviousCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousOccurrencesCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

			def ReplacePreviousCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
				This.ReplacePreviousCS(pcString, pcOtherString, pnStartingAt, pCaseSensitive)
				return This

	def PreviousOccurrencesReplacedCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive)

		acResult = This.Copy().
				ReplacePreviousOccurrencesCSQ(pcString, pcOtherString, pnStartingAt, pCaseSensitive).
				Content()

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def ReplacePreviousOccurrences(pcString, pcOtherString, pnStartingAt)
		ReplacePreviousOccurrencesCS(pcString, pcOtherString, pnStartingAt, :CS = TRUE)

		def ReplacePreviousOccurrencesQ(pcString, pcOtherString, pnStartingAt)
			This.ReplacePreviousOccurrences(pcString, pcOtherString, pnStartingAt)
			return This

		def ReplacePrevious(pcString, pcOtherString, pnStartingAt)
			This.ReplacePreviousOccurrences(pcString, pcOtherString, pnStartingAt)

			def ReplacePreviousQ(pcString, pcOtherString, pnStartingAt)
				This.ReplacePrevious(pcString, pcOtherString, pnStartingAt)
				return This

	def PreviousOccurrencesReplacedQ(pcString, pcOtherString, pnStartingAt)

		acResult = This.Copy().
				ReplacePreviousOccurrencesQ(pcString, pcOtherString, pnStartingAt).
				Content()

		return acResult

	  #-------------------------------------------#
	 #   REPLACING NTH OCCURRENCE OF A STRING    #
	#-------------------------------------------#

	def ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pcOtherString) and
		   StzListQ(pcOtherString).IsWithOrByNamedParamList()
		
			pcOtherString = pcOtherString[2]
		ok

		nStringPosition = This.FindNthOccurrenceCS(n, pcString, pCaseSensitive)

		This.ReplaceStringAtPosition(nStringPosition, pcOtherString)

		#< @FunctionFluentForm

		def ReplaceNthOccurrenceCSQ(n, pcString, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthCS(n, pcString, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthCSQ(n, pcString, pcOtherString, pCaseSensitive)
				This.ReplaceNthCS(n, pcString, pcOtherString, pCaseSensitive)
				return This

		#>

	def NthOccurrenceReplacedCS(n, pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceNthOccurrenceCSQ(n, pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNthOccurrence(n, pcString, pcOtherString)
		This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, :CS = TRUE)

		#< @FunctionFluentForm

		def ReplaceNthOccurrenceQ(n, pcString, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNth(n, pcString, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthQ(n, pcString, pcOtherString)
				This.ReplaceNth(n, pcString, pcOtherString)
				return This

		#>

	def NthOccurrenceReplaced(n, pcString, pcOtherString)

		aResult  = This.Copy().
				ReplaceNthOccurrenceQ(n, pcString, pcOtherString).
				Content()

		return aResult

	  #---------------------------------------------#
	 #   REPLACING FIRST OCCURRENCE OF A STRING    #
	#---------------------------------------------#

	def ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pcString, pcOtherString, pCaseSensitive)

		def ReplaceFirstOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
			return This

		def ReplaceFirstCS(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceFirstCSQ(pcString, pcOtherString, pCaseSensitive)
				This.ReplaceFirstCS(pcString, pcOtherString, pCaseSensitive)
				return This

	def FirstOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceFirstOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirstOccurrence(pcString, pcOtherString)
		This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, :CS = TRUE)

		def ReplaceFirstOccurrenceQ(pcString, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)
			return This

		def ReplaceFirst(pcString, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def ReplaceFirstQ(pcString, pcOtherString)
				This.ReplaceFirst(pcString, pcOtherString)
				return This

	def FirstOccurrenceReplaced(pcString, pcOtherString)

		aResult  = This.Copy().
				ReplaceFirstOccurrenceQ(pcString, pcOtherString).
				Content()

		return aResult

	  #---------------------------------------------#
	 #   REPLACING LAST OCCURRENCE OF A STRING     #
	#---------------------------------------------#

	def ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(:Last, pcString, pcOtherString, pCaseSensitive)

		def ReplaceLastOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
			return This

		def ReplaceLastCS(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceLastCSQ(pcString, pcOtherString, pCaseSensitive)
				This.ReplaceLastCS(pcString, pcOtherString, pCaseSensitive)
				return This

	def LastOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceLastOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOOUT CASESENSITIVE

	def ReplaceLastOccurrence(pcString, pcOtherString)
		This.ReplaceLastOccurrenceCS(pcString, pcOtherString, :CS = TRUE)

		def ReplaceLastOccurrenceQ(pcString, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)
			return This

		def ReplaceLast(pcString, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def ReplaceLastQ(pcString, pcOtherString)
				This.ReplaceLast(pcString, pcOtherString)
				return This

	def LastOccurrenceReplaced(pcString, pcOtherString)

		aResult  = This.Copy().
				ReplaceLastOccurrenceQ(pcString, pcOtherString).
				Content()

		return aResult

	   #-------------------------------------------------#
	  #    REPLACING NEXT NTH OCCURRENCE OF A STRING    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST     #
	#-------------------------------------------------#

	def ReplaceNextNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		# Checking params correctness

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if NOT isString(pcString)
			stzRaise("Incorrect param! pcString must be a string.")
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParamList()

			pcNewString = pcNewString[2]
		ok

		if NOT isString(pcNewString)
			stzRaise("Incorrect param! pcNewString must be a string.")
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		# Doing the job

		oSection   = This.SectionQR(pnStartingAt, This.NumberOfStrings(), :stzListOfStrings)
		anPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		anPositions = StzListOfNumbersQ(anPositions).AddToEachQ(pnStartingAt - 1).Content()
		nPosition = anPositions[n]

		This.ReplaceStringAtPosition(nPosition, pcNewString)

		def ReplaceNextNthOccurrenceCSQ(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
			This.ReplaceNextNthOccurrenceCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
			return This

		def ReplaceNthNextOccurrenceCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
			This.ReplaceNextNthOccurrenceCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)

			def ReplaceNthNextOccurrenceCSQ(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
				This.ReplaceNthNextOccurrenceCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
				return This

	def NextNthOccurrenceReplacedCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceNthNextOccurrenceCSQ(n, pcString, pnStartingAt, pcNewString, pCaseSensitive).
				Content()

		return aResult

		def NthNextOccurrenceReplacedCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)
			return This.NextNthOccurrenceReplacedCS(n, pcString, pnStartingAt, pcNewString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNextNthOccurrence(n, pcString, pnStartingAt, pcNewString)
		This.ReplaceNextNthOccurrenceCS(n, pcString, pnStartingAt, pcNewString, :CaseSensitive = TRUE)

		def ReplaceNextNthOccurrenceQ(n, pcString, pnStartingAt, pcNewString)
			This.ReplaceNextNthOccurrence(n, pcString, pnStartingAt, pcNewString)
			return This

		def ReplaceNthNextOccurrence(n, pcString, pnStartingAt, pcNewString)
			This.ReplaceNextNthOccurrence(n, pcString, pnStartingAt, pcNewString)

			def ReplaceNthNextOccurrenceQ(n, pcString, pnStartingAt, pcNewString)
				This.ReplaceNthNextOccurrence(n, pcString, pnStartingAt, pcNewString)
				return This

	def NextNthOccurrenceReplaced(n, pcString, pnStartingAt, pcNewString)

		aResult  = This.Copy().
				ReplaceNthNextOccurrenceQ(n, pcString, pnStartingAt, pcNewString).
				Content()

		return aResult

		def NthNextOccurrenceReplaced(n, pcString, pnStartingAt, pcNewString)
			return This.NextNthOccurrenceReplaced(n, pcString, pnStartingAt, pcNewString)

	   #------------------------------------------------#
	  #    REPLACING NEXT OCCURRENCE OF A STRING       #
	 #    STARTING AT A GIVEN POSITION IN THE LIST    #
	#------------------------------------------------#

	def ReplaceNextOccurrenceCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)
		This.ReplaceNextNthOccurrenceCS(1, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		def ReplaceNextOccurrenceCSQ(pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplaceNextOccurrenceCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This

	def NextOccurrenceReplacedCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceNextOccurrenceCSQ(pcString, pcNewString, pnStartingAt, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNextOccurrence(pcString, pcNewString, pnStartingAt)
		This.ReplaceNextOccurrenceCS(pcString, pcNewString, pnStartingAt, :CS = TRUE)

		def ReplaceNextOccurrenceQ(pcString, pcNewString, pnStartingAt)
			This.ReplaceNextOccurrence(pcString, pcNewString, pnStartingAt)
			return This

	def NextOccurrenceReplaced(pcString, pcNewString, pnStartingAt)

		aResult  = This.Copy().
				ReplaceNextOccurrenceQ(pcString, pcNewString, pnStartingAt).
				Content()

		return aResult

	   #-------------------------------------------------------#
	  #    REPLACING MANY NEXT NTH OCCURRENCES OF A STRING    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST           #
	#-------------------------------------------------------#

	def ReplaceNextNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
			? Content() # !--> [ "A" , "B", "A", "C", "*", "D", "*" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfStringsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParamList()

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok
			
		oSection = This.SectionQ(pnStartingAt, :LastString)

		anPositions = oSection.
			      FindAllCSQR(pcString, pCaseSensitiev, :stzListOfNumbers).
			      AddToEachQ(pnStartingAt-1).
			      Content()

		anPositionsToBeReplaced = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeReplaced +  anPositions[n]
			ok
		next

		This.ReplaceAllStringsAtThesePositions(anPositionsToBeReplaced, pcNewString)

		#< @FunctionFluentForm

		def ReplaceNextNthOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthNextOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				return This
		#>

	def NextNthOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		aResult = This.
			  ReplaceNextNthOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive).
			  Content()

		return aResult

		def NthNextOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This.NextNthOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNextNthOccurrences(panList, pcString, pcNewString, pnStartingAt)

		This.ReplaceNextNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextNthOccurrencesQ(panList, pcString, pcNewString, pnStartingAt)
			This.ReplaceNextNthOccurrences(panList, pcString, pcNewString, pnStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthNextOccurrences(panList, pcString, pcNewString, pnStartingAt)
			This.ReplaceNextNthOccurrences(panList, pcString, pcNewString, pnStartingAt)

			def ReplaceNthNextOccurrencesQ(panList, pcString, pcNewString, pnStartingAt)
				This.ReplaceNthNextOccurrences(panList, pcString, pcNewString, pnStartingAt)
				return This
		#>

	def NextNthOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)

		aResult = This.
			  ReplaceNextNthOccurrencesQ(panList, pcString, pcNewString, pnStartingAt).
			  Content()

		return aResult

		def NthNextOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)
			return This.NextNthOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)

	   #-----------------------------------------------------#
	  #    REPLACING PREVIOUS NTH OCCURRENCE OF A STRING    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST         #
	#-----------------------------------------------------#

	def ReplacePreviousNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParamList()

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		oSection   = This.SectionQR(1, pnStartingAt, :stzListOfStrings)
		aPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		nPosition = aPositions[ len(aPositions) - n + 1 ]

		This.ReplaceStringAtPosition(nPosition, pcNewString)

		def ReplacePreviousNthOccurrenceCSQ(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This

		def ReplaceNthPreviousOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceCSQ(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				return This

	def NthPreviousOccurrenceReplacedCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		aResult =  This.Copy().
				ReplaceNthPreviousOccurrenceCSQ(n, pcString, pcNewString, pnStartingAt, pCaseSensitive).
				Content()

		return aResult

		def PreviousNthOccurrenceReplacedCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This.NthPreviousOccurrenceReplacedCS(n, pcString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplacePreviousNthOccurrence(n, pcString, pcNewString, pnStartingAt)
		This.ReplacePreviousNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, :CS = TRUE)

		def ReplacePreviousNthOccurrenceQ(n, pcString, pcNewString, pnStartingAt)
			This.ReplacePreviousNthOccurrence(n, pcString, pcNewString, pnStartingAt)
			return This

		def ReplaceNthPreviousOccurrence(n, pcString, pcNewString, pnStartingAt)
			This.ReplacePreviousNthOccurrence(n, pcString, pcNewString, pnStartingAt)

			def ReplaceNthPreviousOccurrenceQ(n, pcString, pcNewString, pnStartingAt)
				This.ReplaceNthPreviousOccurrence(n, pcString, pcNewString, pnStartingAt)
				return This

	def NthPreviousOccurrenceReplaced(n, pcString, pcNewString, pnStartingAt)

		aResult =  This.Copy().
				ReplaceNthPreviousOccurrenceQ(n, pcString, pcNewString, pnStartingAt).
				Content()

		return aResult

		def PreviousNthOccurrenceReplaced(n, pcString, pcNewString, pnStartingAt)
			return This.NthPreviousOccurrenceReplaced(n, pcString, pnStartingAt)

	   #-------------------------------------------------#
	  #    REPLACING PREVIOUS OCCURRENCE OF A STRING    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST     #
	#-------------------------------------------------#

	def ReplacePreviousOccurrenceCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)
		This.ReplacePreviousNthOccurrenceCS(1, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		def ReplacePreviousOccurrenceCSQ(pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousOccurrenceCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This

	def PreviousOccurrenceReplacedCS(pcString, pcNewString, pnStartingAt, pCaseSensitive)

		aResult =  This.Copy().
				ReplacePreviousOccurrenceCSQ(pcString, pcNewString, pnStartingAt, pCaseSensitive).
				Content()
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplacePreviousOccurrence(pcString, pcNewString, pnStartingAt)
		This.ReplacePreviousOccurrenceCS(pcString, pcNewString, pnStartingAt, :CS = TRUE)

		def ReplacePreviousOccurrenceQ(pcString, pcNewString, pnStartingAt)
			This.ReplacePreviousOccurrence(pcString, pcNewString, pnStartingAt)
			return This

	def PreviousOccurrenceReplaced(pcString, pcNewString, pnStartingAt)

		aResult =  This.Copy().
				ReplacePreviousOccurrenceQ(pcString, pcNewString, pnStartingAt).
				Content()
		return aResult

	   #-----------------------------------------------------------#
	  #     REPLACING MANY PREVIOUS NTH OCCURRENCES OF A STRING   #
	 #    STARTING AT A GIVEN POSITION IN THE LIST               #
	#-----------------------------------------------------------#

	def ReplacePreviousNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplacePreviousNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 5)
			? Content() # !--> [ "A" , "B", "*", "C", "*", "D", "A" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfStringsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   ( StzListQ(pcNewString).IsWithNamedParamList() or StzListQ(pcNewString).IsByNamedParamList() )

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok
			
		oSection = This.SectionQ(1, pnStartingAt)

		anPositions = oSection.FindAllCSQ(pcString, pCaseSensitive).StringsReversed()

		anPositionsToBeReplaced = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeReplaced +  anPositions[n]
			ok
		next

		This.ReplaceAllStringsAtThesePositions(anPositionsToBeReplaced, pcNewString)

		#< @FunctionFluentForm

		def ReplacePreviousNthOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthPreviousOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
				return This
		#>

	def PreviousNthOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		aResult =  This.
			   ReplacePreviousNthOccurrencesCSQ(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive).
			   Content()

		return aResult

		def NthPreviousOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
			return This.PreviousNthOccurrencesReplacedCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplacePreviousNthOccurrences(panList, pcString, pcNewString, pnStartingAt)
		This.ReplacePreviousNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousNthOccurrencesQ(panList, pcString, pcNewString, pnStartingAt)
			This.ReplacePreviousNthOccurrences(panList, pcString, pcNewString, pnStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthPreviousOccurrences(panList, pcString, pcNewString, pnStartingAt)
			This.ReplacePreviousNthOccurrences(panList, pcString, pcNewString, pnStartingAt)

			def ReplaceNthPreviousOccurrencesQ(panList, pcString, pcNewString, pnStartingAt)
				This.ReplaceNthPreviousOccurrences(panList, pcString, pcNewString, pnStartingAt)
				return This
		#>

	def PreviousNthOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)

		aResult =  This.
			   ReplacePreviousNthOccurrencesQ(panList, pcString, pcNewString, pnStartingAt).
			   Content()

		return aResult

		def NthPreviousOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)
			return This.PreviousNthOccurrencesReplaced(panList, pcString, pcNewString, pnStartingAt)

	  #----------------------------------#
	 #   REPLACING STRING BY POSITION   #
	#----------------------------------#

	def ReplaceStringAtPosition(n, pcOtherStr)
		/* Example 1:

			o1 = new stzListOfStrings([ "ONE", "two" ])
			o1.ReplaceStringAtPosition(2, :With = "TWO")
			? o1.Content	# --> [ "ONE", "TWO" ]

		Example 2:

			o1 = new stzListOfStrings([ "A", "b", "C" ])
			o1.ReplaceStringAtPosition(2, :With@ = "upper(@string)")
			? o1.Content()	# --> [ "A", "B", "C" ]
		*/

		if NOT IsNumberOrString(n)
			stzRaise("Invalid param type! n must be a number.")
		ok

		if isString(n)
			if Q(n).IsOneOfThese([
				:First, :FirstPosition,
				:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
				:Last, :LastPosition,
				:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if n < 1 or n > This.NumberOfStrings()
			stzRaise("the Nth position you provided is out of range!")
		ok

		if isList(pcOtherStr) and Q(pcOtherStr).IsWithOrByNamedParamList()

			if Q(pcOtherStr[1]).LastChar() = "@"

				cCode = StzCCodeQ(pcOtherStr[2]).UnifiedFor(:stzListOfStrings)
				cCode = "pcOtherStr = " + cCode
	
				eval(cCode)

			else
				pcOtherStr = pcOtherStr[2]
			ok

		ok

		if NOT isString(pcOtherStr)
			stzRaise("Incorrect param! pcOtherStr must be a string.")
		ok

		# Doing the job (Qt-side)

		This.QStringListObject().Replace(n-1, pcOtherStr)

		#< @FunctionFluentForm

		def ReplaceStringAtPositionQ(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemAtPosition(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringItemAtPositionQ(n, pcOtherString)
				This.ReplaceStringItemAtPosition(n, pcOtherString)
				return This

		def ReplaceAt(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceAtQ(n, pcOtherString)
				This.ReplaceAt(n, pcOtherString)
				return This

		def ReplaceAtPosition(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceAtPositionQ(n, pcOtherString)
				This.ReplaceAtPosition(n, pcOtherString)
				return This

		def ReplaceStringAt(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringAtQ(n, pcOtherString)
				This.ReplaceStringAt(n, pcOtherString)
				return This

		def ReplaceStringItemAt(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringItemAtQ(n, pcOtherString)
				This.RemoveStringItemAt(n, pcOtherString)
				return This

		#>
	
	def StringAtPositionNReplacedWith(n, pcOtherString)
		aResult = This.Copy().ReplaceStringAtPositionQ( n, pcOtherString ).Content()
		return aResult

		def StringItemAtPositionNReplacedWith(n, pcOtherString)
			return This.StringAtPositionNReplacedWith(n, pcOtherString)

		def NthStringReplacedWith(n, pcOtherString)
			return This.StringAtPositionNReplacedWith(n, pcOtherString)

	  #-----------------------------#
	 #   REPLACING FIRST STRING    #
	#-----------------------------#

	def ReplaceFirstStringWith(pcOtherString)
		This.ReplaceStringAtPosition(1, pcOtherString)

		#< @FunctionFluentForm

		def ReplaceFirstStringWithQ(pcOtherString)
			This.ReplaceFirstStringWith(pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceFirstString(pcOtherString)
			This.ReplaceFirstStringWith(pcOtherString)
			
			def ReplaceFirstStringQ(pcOtherString)
				This.ReplaceFirstString(pcOtherString)
				return This

		def ReplaceFirstStringItem(pcOtherString)
			This.ReplaceFirstStringWith(pcOtherString)
			
			def ReplaceFirstStringItemQ(pcOtherString)
				This.ReplaceFirstStringItem(pcOtherString)
				return This

		def ReplaceFirstStringItemWith(pcOtherString)
			This.ReplaceFirstStringWith(pcOtherString)
			
			def ReplaceFirstStringItemWithQ(pcOtherString)
				This.ReplaceFirstStringItemWith(pcOtherString)
				return This

		#>
		
	def FirstStringReplacedWith(pcOtherString)
		aResult = This.Copy().ReplaceFirstStringWithQ( pcOtherString ).Content()
		return aResult

		def FirstStringItemReplacedWith(pcOtherString)
			return This.FirstStringReplacedWith(pcOtherString)

	  #----------------------------#
	 #   REPLACING LAST STRING    #
	#----------------------------#

	def ReplaceLastStringWith(pcOtherString)
		This.ReplaceStringAtPosition(This.NumberOfStrings(), pcOtherString)

		#< @FunctionFluentForm

		def ReplaceLastStringWithQ(pcOtherString)
			This.ReplaceLastStringWith(pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceLastString(pcOtherString)
			This.ReplaceLastStringWith(pcOtherString)
			
			def ReplaceLastStringQ(pcOtherString)
				This.ReplaceLastString(pcOtherString)
				return This

		def ReplaceLastStringItem(pcOtherString)
			This.ReplaceLastStringWith(pcOtherString)
			
			def ReplaceLastStringItemQ(pcOtherString)
				This.ReplaceLastStringItem(pcOtherString)
				return This

		def ReplaceLastStringItemWith(pcOtherString)
			This.ReplaceLastStringWith(pcOtherString)
			
			def ReplaceLastStringItemWithQ(pcOtherString)
				This.ReplaceLastStringItemWith(pcOtherString)
				return This

		#>
		
	def LastStringReplacedWith(pcOtherString)
		aResult = This.Copy().ReplaceLastStringWithQ( pcOtherString ).Content()
		return aResult

		def LastStringItemReplacedWith(pcOtherString)
			return This.FirstStringReplacedWith(pcOtherString)

	  #-----------------------------------------#
	 #   REPLACING MANY STRINGS BY POSITION    #
	#-----------------------------------------#

	def ReplaceStringsAtPositions(panPositions, pcOtherString)

		for n in panPositions
			This.ReplaceStringAtPosition(n, pcOtherString)
		next

		#< @FunctionFluentForm

		def ReplaceStringsAtPositionsQ(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
			return This

			def ReplaceStringItemsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceStringItemsAtPositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceManyAt(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyAtQ(panPositions, pcOtherString)
				This.ReplaceManyAt(panPositions, pcOtherString)
				return This

		def ReplaceManyAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceManyAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceManyStringsAt(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringsAtQ(panPositions, pcOtherString)
				This.ReplaceManyStringsAt(panPositions, pcOtherString)
				return This

		def ReplaceManyStringsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceManyStringsAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceManyAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceManyAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceManyStringsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceManyStringsAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceManyStringItemsAt(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringItemsAtQ(panPositions, pcOtherString)
				This.ReplaceManyStringItemssAt(panPositions, pcOtherString)
				return This

		def ReplaceManyStringItemsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringItemsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceManyStringItemsAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceManyStringItemsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceManyStringItemsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceManyStringItemsAtThesePositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceStringsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceStringsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceStringsAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceStringItemsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceStringItemsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceStringItemsAtThesePositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceAllStringsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceAllStringsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceAllStringsAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceAllStringItemsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceAllStringItemsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceAllStringItemsAtPositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceAllStringsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceAllStringsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceAllStringsAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceAllStringItemsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)
		
			def ReplaceAllStringItemsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceAllStringItemsAtThesePositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceTheseStringsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceTheseStringsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceTheseStringsAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceTheseStringItemsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceTheseStringItemsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceTheseStringItemsAtPositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceTheseStringsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceTheseStringsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceTheseStringsAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceTheseStringItemsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceTheseStringItemsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceTheseStringItemsAtThesePositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceAllTheseStringsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceAllTheseStringsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceAllTheseStringsAtPositions(panPositions, pcOtherString)
				return This

		def ReplaceAllTheseStringItemsAtPositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceAllTheseStringItemsAtPositionsQ(panPositions, pcOtherString)
				This.ReplaceAllTheseStringItemsAtPositions(panPositions, pcOtherString)
				return This

		#--

		def ReplaceAllTheseStringsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceAllTheseStringsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceAllTheseStringsAtThesePositions(panPositions, pcOtherString)
				return This

		def ReplaceAllTheseStringItemsAtThesePositions(panPositions, pcOtherString)
			This.ReplaceStringsAtPositions(panPositions, pcOtherString)

			def ReplaceAllTheseStringItemsAtThesePositionsQ(panPositions, pcOtherString)
				This.ReplaceAllTheseStringsAtThesePositions(panPositions, pcOtherString)
				return This

		#>

	def StringsAtThesePositionsRplaced(panPositions, pcOtherString)
		aResult = This.Copy().ReplaceStringsAtPositionsQ(panPositions, pcOtherString).Content()
		return aResult

		def StringItemsAtThesePositionsReplaced(panPositions, pcOtherString)
			return This.StringsAtThesePositionsReplaced(panPositions, pcOtherString)

	  #-------------------------------------------------------#
	 #    REPLACING A SECTION OF STRINGS BY A GIVEN STRING   #
	#-------------------------------------------------------#

	def ReplaceSection(n1, n2, pcNewStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ]
		o1.ReplaceSection(3, 5, "C")
		? o1.Content() #--> [ "A", "B", "C", "D" ]

		*/

		This.RemoveSectionQ(n1, n2).InsertBefore(n1, pcNewStr)

		def ReplaceSectionQ(n1, n2, pcNewStr)
			This.ReplaceSection(n1, n2, pcNewStr)
			return This

	def ReplaceManySections(panSections, pcNewString)
		for anSection in panSections
			This.ReplaceSection(anSection, pcNewString)
		next

		def ReplaceManySectionsQ(panSections, pcNewString)
			This.ReplaceManySections(panSections, pcNewString)
			return This
		
	  #----------------------------------------------------------#
	 #   REPLACING EACH STRING IN SECTION BY ONE GIVEN STRING   #
	#----------------------------------------------------------#

	def ReplaceEachStringInSection(n1, n2, pcNewStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ]
		o1.ReplaceEachStringInSection(3, 5, "C")
		? o1.Content() #--> [ "A", "B", "C", "C", "C", "D" ]

		*/

		anPositions = sort( StzListOfPairsQ([n1, n2]).ExpandedIfPairsOfNumbers() )

		This.ReplaceStringsAtThesePositions(anPositions, pcNewStr)

		def ReplaceEachStringInSectionQ(n1, n2, pcNewStr)
			This.ReplaceEachStringInSection(n1, n2, pcNewStr)
			return This

		def ReplaceEachStringItemInSection(n1, n2, pcNewStr)
			This.ReplaceEachStringInSection(n1, n2, pcNewStr)

			def ReplaceEachStringItemInSectionQ(n1, n2, pcNewStr)
				This.ReplaceEachStringItemInSection(n1, n2, pcNewStr)
				return This

	def EachStringInSectionReplaced(n1, n2, pcNewStr)
		acResult = This.Copy().ReplaceEachStringInSectionQ(n1, n2, pcNewStr).Content()
		return acResult

		def EachStringReplacedInSection(n1, n2, pcNewStr)
			return This.EachStringInSectionReplaced(n1, n2, pcNewStr)

		def EachStringItemInSectionReplaced(n1, n2, pcNewStr)
			return This.EachStringInSectionReplaced(n1, n2, pcNewStr)

		def EachStringItemReplacedInSection(n1, n2, pcNewStr)
			return This.EachStringInSectionReplaced(n1, n2, pcNewStr)
	
	  #----------------------------------------------------------------#
	 #   REPLACING EACH STRING IN MANY SECTIONS BY A GIVEN STRING   #
	#----------------------------------------------------------------#

	def ReplaceEachStringInManySections(panSections, pcNewStr)
		for anSection in panSections
			n1 = anSection[1]
			n2 = anSection[2]
			This.ReplaceEachStringInSection(n1, n2, pcNewStr)
		next

		def ReplaceEachStringInManySectionsQ(panSections, pcNewStr)
			This.ReplaceEachStringInManySections(panSections, pcNewStr)
			return This

		def ReplaceEachStringItemInManySections(panSections, pcNewStr)
			This.ReplaceEachStringInManySections(panSections, pcNewStr)

			def ReplaceEachStringItemInManySectionsQ(panSections, pcNewStr)
				This.ReplaceEachStringItemInManySections(panSections, pcNewStr)
				return This

	def EachStringInManySectionsReplaced(panSections, pcNewStr)

		acResult = This.Copy().
				ReplaceEachStringInManySectionsQ(panSections, pcNewStr).
				Content()

		return acResult

		def EachStringItemInManySectionsReplaced(panSections, pcNewStr)
			return This.EachStringInManySectionsRelaced(panSections, pcNewStr)

	   #-------------------------------------------------#
	  #   REPLACING A SECTION OF STRINGS IN THE LIST    #
	 #   BY MANY STRINGS ONE BY ONE    	           #
	#-------------------------------------------------#

	def ReplaceSectionOneByOne(n1, n2, pacOtherListOfStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "F" ]
		o1.ReplaceSectionOneByOne(3, 5, [ "C", "D", "F" )
		? o1.Content() #--> [ "A", "B", "C", "D", "E", "F" ]

		*/
	
		for i = n1 to n2
			if i <= len(pacOtherListOfStr)
				str = pacOtherListOfStr[i]
			else
				str = NULL
			ok

			This.ReplaceStringAtPosition(i, str)
		next

		def ReplaceSectionOneByOneQ(n1, n2, pacOtherListOfStr)
			This.ReplaceSectionOneByOne(n1, n2, pacOtherListOfStr)
			return This

	def SectionReplacedOneByOne(n1, n2, pacOtherListOfStr)
		aResult = This.ReplaceSectionOneByOneQ(n1, n2, pacOtherListOfStr).Content()
		return aResult

	   #-----------------------------------------------------#
	  #   REPLACING MANY SECTIONS OF STRINGS IN THE LIST    #
	 #   BY MANY STRINGS ONE BY ONE                        #
	#-----------------------------------------------------#

	def ReplaceManySectionsOneOnyOne(panSections, pacOtherListOfStr)
		for anSection in panSections
			n1 = panSections[1]
			n2 = panSections[2]
			This.ReplaceSectionOneByOne(n1, n2, pacOtherListOfStr)
		next

		def ReplaceManySectionsOneOnyOneQ(panSections, pacOtherListOfStr)
			This.ReplaceManySectionsOneOnyOne(panSections, pacOtherListOfStr)
			return This

	def ManySectionsReplacedOneByOne(panSections, pacOtherListOfStr)
		acResult = This.Copy().
				ReplaceManySectionsOneOnyOneQ(panSections, pacOtherListOfStr).
				Content()

		return acResult

	  #----------------------------------------------#
	 #   REPLACING A RANGE OF STRINGS IN THE LIST   #
	#----------------------------------------------#

	def ReplaceRange(n, nRange, pcNewStr)

		anSection = RangeToSection(n, nRange)
		n1 = anSection[1]
		n2 = anSection[2]

		This.ReplaceSection(n1, n2, pcNewStr)

		def ReplaceRangeQ(n, nRange, pcNewStr)
			This.ReplaceRange(n, nRange, pcNewStr)
			return This

	def RangeReplaced(n, nRange, pcNewStr)
		acResult = This.Copy().ReplaceRangeQ(n, nRange, pcNewStr).Content()
		return acResult

	  #--------------------------------------------------#
	 #   REPLACING MANY RANGES OF STRINGS IN THE LIST   #
	#--------------------------------------------------#

	def ReplaceManyRanges(panRanges, pcNewStr)
		for anRange in panRanges
			n = anRange[1]
			nRange = anRange[2]
			This.ReplaceRange(n, nRange, pcNewStr)
		next

		def ReplaceManyRangesQ(panRanges, pcNewStr)
			This.ReplaceManyRanges(panRanges, pcNewStr)
			return This

	def ManyRangesReplaced(panRanges, pcNewStr)
		acResult = This.Copy().ReplaceManyRangesQ(panRanges, pcNewStr).Content()
		return acResult

	  #---------------------------------------------------------------#		
	 #   REPLACING EACH STRING IN A RANGE BY THE SAME GIVEN STRING   #
	#---------------------------------------------------------------#

	def ReplaceEachStringInRange(n, nRange, pcNewStr)

		anSection = RangeToSection([n, nRange])
		anPositions = sort( StzListOfPairsQ(anSection).ExpandedIfPairsOfNumbers() )

		This.ReplaceStringsAtThesePositions(anPositions, pcNewStr)

		def ReplaceEachStringInRangeQ(n, nRange, pcNewStr)
			This.ReplaceEachStringInRange(n, nRange, pcNewStr)
			return This

		def ReplaceEachStringItemInRange(n, nRange, pcNewStr)
			This.ReplaceEachStringInRange(n, nRange, pcNewStr)

			def ReplaceEachStringItemInRangeQ(n, nRange, pcNewStr)
				This.ReplaceEachStringItemInRange(n, nRange, pcNewStr)
				return This

	def EachStringInRangeReplaced(n, nRange, pcNewStr)

		acResult = This.Copy().ReplaceEachStringInRangeQ(n, nRange, pcNewStr).Content()
		return acResult

		def EachStringReplacedInRange(n, nRange, pcNewStr)
			return This.EachStringInRangeReplaced(n, nRange, pcNewStr)

		def EachStringItemInRangeReplaced(n, nRange, pcNewStr)
			return This.EachStringInRangeReplaced(n, nRange, pcNewStr)

		def EachStringItemReplacedInRange(n, nRange, pcNewStr)
			return This.EachStringInRangeReplaced(n, nRange, pcNewStr)
		
	  #-------------------------------------------------------------------#		
	 #   REPLACING EACH STRING IN MANY RANGES BY THE SAME GIVEN STRING   #
	#-------------------------------------------------------------------#

	def ReplaceEachStringInManyRanges(panRanges, pcNewStr)

		for anRange in panRanges
			anSection = RangeToSection(anRange)
			n1 = anSection[1]
			n2 = anSection[2]
			This.ReplaceEachStringInSection(n1, n2, pcNewStr)
		next

		def ReplaceEachStringInManyRangesQ(panRanges, pcNewStr)
			This.ReplaceEachStringInManyRanges(panRanges, pcNewStr)
			return This

		def ReplaceEachStringItemInManyRanges(panRanges, pcNewStr)
			This.ReplaceEachStringInManyRangess(panRanges, pcNewStr)

			def ReplaceEachStringItemInManyRangesQ(panRanges, pcNewStr)
				This.ReplaceEachStringItemInManyRanges(panRanges, pcNewStr)
				return This

	def EachStringInManyRangesReplaced(panRanges, pcNewStr)

		acResult =  This.Copy().
				ReplaceEachStringInManyRangesQ(panRanges, pcNewStr).
				Content()

		return acResult

		def EachStringReplacedInManyRanges(panRanges, pcNewStr)
			return This.EachStringInManyRangesReplaced(panRanges, pcNewStr)

		def EachStringItemInManyRangesReplaced(panRanges, pcNewStr)
			return This.EachStringInManyRangesReplaced(panRanges, pcNewStr)

		def EachStringItemReplacedInManyRanges(panRanges, pcNewStr)
			return This.EachStringInManyRangesReplaced(panRanges, pcNewStr)
	
	   #----------------------------------------------#
	  #   REPLACING A RANGE OF STRINGS IN THE LIST   #
	 #   WITH MANY STRINGS ONE BY ONE               #
	#----------------------------------------------#

	def ReplaceRangeOneByOne(n, nRange, pacOtherListOfStr)

		anSection = RangeToSection([n, nRange])
		n1 = anSection[1]
		n2 = anSection[2]

		for i = n1 to n2
			if i <= len(pacOtherListOfStr)
				str = pacOtherListOfStr[i]
			else
				str = NULL
			ok

			This.ReplaceStringAtPosition(i, str)
		next

		def ReplaceRangeOneByOneQ(n, nRange, pacOtherListOfStr)
			This.ReplaceRangeOneByOne(n, nRange, pacOtherListOfStr)
			return This

	def RangeReplacedOneByOne(n, nRange, pacOtherListOfStr)
		aResult = This.ReplaceRangeOneByOneQ(n, nRange, pacOtherListOfStr).Content()
		return aResult

	   #--------------------------------------------------#
	  #   REPLACING MANY RANGES OF STRINGS IN THE LIST   #
	 #   WITH MANY STRINGS ONE BY ONE                   #
	#--------------------------------------------------#

	def ReplaceManyRangesOneOnyOne(panRanges, pacOtherListOfStr)
		for anRange in panRanges
			anSection = RangeToSection(anRange)
			n1 = anSections[1]
			n2 = anSections[2]
			This.ReplaceRangeOneByOne(n, nRange, pacOtherListOfStr)
		next

		def ReplaceManyRangesOneOnyOneQ(panRanges, pacOtherListOfStr)
			This.ReplaceManyRangesOneOnyOne(panRanges, pacOtherListOfStr)
			return This

	def ManyRangesReplacedOneByOne(panRanges, pacOtherListOfStr)
		
		acResult = This.Copy().
				ReplaceManyRangesOneOnyOneQ(panRanges, pacOtherListOfStr).
				Content()

		return acResult

	  #-------------------------------------------------------------#
	 #  REPLACING ALL STRINGS IN THE LIST WITH A GIVEN NEW STRING  #
	#-------------------------------------------------------------#

	def ReplaceAllStringsWith(pcOtherString)
		aResult = []
		for i = 1 to This.NumberOfStrings()
			aResult + pcOtherString
		next

		This.Update( aResult )

		#< @FunctionFluentForm

		def ReplaceAllStringsWithQ(pcOtherString)
			This.ReplaceAllStringsWith(pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceAllStringItemsWith(pcOtherString)
			This.ReplaceAllStringsWith(pcOtherString)

			def ReplaceAllStringItemsWithQ(pcOtherString)
				This.ReplaceAllStringItemsWith(pcOtherString)

		def ReplaceAllWith(pcOtherString)
			This.ReplaceAllStringsWith(pcOtherString)

			def ReplaceAllWithQ(pcOtherString)
				This.ReplaceAll(pcOtherString)
				return This

		def ReplaceWith(pcOtherString)
			This.ReplaceAllStringsWith(pcOtherString)

			def ReplaceWithQ(pcOtherString)
				This.ReplaceWith(pcOtherString)
				return This

		#>

	def AllStringsReplacedWith(pcOtherString)
		aResult = This.Copy().ReplaceAllStringsWith(pcOtherString)
		return aResult

		def AllStringItemsReplacedWith(pcOtherString)
			return This.AllStringsReplacedWith(pcOtherString)

	  #------------------------------------------------#
	 #   REPLACING STRINGS UNDER A GIVEN CONDITION    #
	#------------------------------------------------#

	def ReplaceStringsW(pCondition, pcOtherString)

		if NOT ( isString(pCondition) or isList(pCondition) )
			stzRaise("Incorrect param type! pCondition must be string or list.")
		ok

		if NOT ( isString(pcOtherString) or isList(pcOtherString) )
			stzRaise("Incorrect param type! pcOtherString must be string or list.")
		ok 

		if isList(pCondition) and StzListQ(pCondition).IsWhereNamedParamList()
			cCondition = pCondition[2]
		ok

		# There are two possible forms of replacement: With and With@
		# The first one is used to replace with normal string, while the
		# second one to replace with@ a dynamic code.

		# By default, the first form is used.

		cReplace = :With

		if isList(pcOtherString) and
		   ( StzListQ(pcOtherString).IsByNamedParamList() or StzListQ(pcOtherString).IsWithNamedParamList() )

			cReplace = pcOtherString[1]
			pcOtherString = pcOtherString[2]
		ok

		if cReplace = :With@
			if NOT isString(pcOtherString)
				stzRaise("Uncorrect value! The value provided after :With@ must be a string containing a Ring expression.")
			ok
		ok

		cCondition = StzCCodeQ(cCondition).UnifiedFor(:stzList)
		oCondition = new stzString(cCondition)

		# NOTE: Don't change the name of vars @i and @item
		# because they'r used by the evaluated conditional-code.

		for @i = 1 to This.NumberOfStrings()

			@item = This[@i]
			bEval = TRUE

			if @i = This.NumberOfStrings() and
			   oCondition.Copy().RemoveSpacesQ().ContainsCS("This[i+1]", :CS = FALSE)

				bEval = FALSE
			ok

			if @i = 1 and
			   oCondition.Copy().RemoveSpacesQ().ContainsCS("This[i-1]", :CS = FALSE)

				bEval = FALSE
			ok

			if bEval
				cCode = 'bOk = ( ' + cCondition + ' )'
				eval(cCode)
			
				if bOk
					if cReplace = :With
						This.ReplaceStringAtPosition(@i, pcOtherString)
		
					but cReplace = :With@
						cValue = StzCCodeQ(pcOtherString).UnifiedFor(:stzList)
						cCode = "value = " + cValue
						eval(cCode)
						This.ReplaceStringAtPosition(@i, value)	
		
					ok
				ok
			ok

		next
	
		#< @FunctionFluentForm

		def ReplaceStringsWQ(pCondition, pcOtherString)
			This.ReplaceStringsW(pCondition, pcOtherString)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemsW(pCondition, pcOtherString)
			This.ReplaceStringsW(pCondition, pcOtherString)

			def ReplaceStringItemsWQ(pCondition, pcOtherString)
				This.ReplaceStringItemsW(pCondition, pcOtherString)
				return This

		def ReplaceW(pCondition, pcOtherString)
			This.ReplaceStringsW(pCondition, pcOtherString)

			def ReplaceWQ(pCondition, pcOtherString)
				This.ReplaceW(pCondition, pcOtherString)
				return This

		#>

	def StringsReplacedW(pCondition, pcOtherString)
		aResult = This.Copy().ReplaceStringsW(pCondition, pcOtherString)
		return aResult

		def StringItemsReplacedW(pcCondition, pcOtherString)
			return This.StringsReplacedW(pcCondition, pcOtherString)

	  #===============================================================#
	 #  REPLACING SUBSTRINGS IN EACH STRING IN THE LIST OF STRINGS   #
	#===============================================================#

	def ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		/* NOTE: When suported in RingQt, use this Qt function:

		This.QStringListObject().replaceInStrings(pcSubStr, pcNewSubStr, pCaseSensitive)
		*/

		acResult = []

		for str in This.ListOfStrings()
			cString = StzStringQ(str).ReplaceCSQ(pcSubStr, pcNewStr, pCaseSensitive).Content()
			acResult + cString
		next

		This.Update( acResult)

		def ReplaceSubStringCSQ(pcSubStr, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
			return This

		def ReplaceAllOccurrencesOfSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)

			def ReplaceAllOccurrencesOfSubStringCSQ(pcSubStr, pcNewStr, pCaseSensitive)
				This.ReplaceAllOccurrencesOfSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
				return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubString(pcSubStr, pcNewStr)
		This.ReplaceSubstringCS(pcSubStr, pcNewStr, :CaseSensitive = TRUE)

		def ReplaceSubStringQ(pcSubStr, pcNewStr)
			This.ReplaceSubString(pcSubStr, pcNewStr)
			return This

		def ReplaceAllOccurrencesOfSubString(pcSubStr, pcNewStr)
			This.ReplaceSubString(pcSubStr, pcNewStr)

			def ReplaceAllOccurrencesOfSubStringQ(pcSubStr, pcNewStr)
				This.ReplaceAllOccurrencesOfSubString(pcSubStr, pcNewStr)
				return This

	  #---------------------------------------------------------------------#
	 #  REPLACING MANY SUBSTRINGS FROM EACH STRING IN THE LIST OF STRINGS  #
	#---------------------------------------------------------------------#

	def ReplaceSubStringsCS(pacSubStr, pcNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		/* NOTE: When suported in RingQt, use this Qt function:

		This.QStringListObject().replaceInStrings(pcSubStr, pcNewSubStr, pCaseSensitive)
		*/

		acResult = []

		for str in This.ListOfStrings()
			cString = StzStringQ(str).ReplaceSubStringCSQ(pcSubStr, pcNewStr, pCaseSensitive).Content()
			acResult + cString
		next

		This.Update( acResult)

		def ReplaceSubStringsCSQ(pacSubStr, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringsCS(pcSubStr, pcNewStr, pCaseSensitive)
			return This

	#-- WITOUT CASESENSITIVITY

	def ReplaceSubStrings(pacSubStr, pcNewStr)
		This.ReplaceSubStringsCS(pacSubStr, pcNewStr, :CaseSensitive = TRUE)

		def ReplaceSubStringsQ(pacSubStr, pcNewStr)
			This.ReplaceSubStrings(pcSubStr, pcNewStr)
			return This

	  #---------------------------------------------------------#
	 #   REPLACING MANY SUBSTRINGS BY MANY OTHERS ONE BY ONE   #
	#---------------------------------------------------------#

	def ReplaceManySubStringsOneByOneCS(pacSubStr, pacNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		i = 0
		for str in pacSubStr
			i++
			if i <= len(pacNewStr)
				This.ReplaceSubStringsCS( pacSubStr[i], pacNewStr[i], pCaseSensitive )
			ok
		next

		def ReplaceManySubStringsOneByOneCSQ(pacSubStr, pacNewStr, pCaseSensitive)
			This.ReplaceManySubStringsOneByOneCS(pacSubStr, pacNewStr, pCaseSensitive)
			return This

		def ReplaceSubStringsOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceManySubStringsOneByOneCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceSubStringsOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

	#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManySubStringsOneByOne(pacSubStr, pacNewStr)
		This.ReplaceManySubStringsOneByOneCS(pacSubStr, pacNewStr, :CS = TRUE)

		def ReplaceManySubStringsOneByOneQ(pacSubStr, pacNewStr)
			This.ReplaceManySubStringsOneByOne(pacSubStr, pacNewStr)
			return This

		def ReplaceSubStringsOneByOne(paStr, pacNewStr)
			This.ReplaceManySubStringsOneByOne(paStr, pacNewStr)

			def ReplaceSubStringsOneByOneQ(paStr, pacNewStr)
				This.ReplaceSubStringsOneByOne(paStr, pacNewStr)
				return This

	#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING NEXT NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------#

	def ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
		anPos = This.FindNextNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
		This.ReplaceSubStringAtThisPosition(anPos, pcNewSubStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextNthSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthNextSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNthNextSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNthNextSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		def ReplaceNextNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNextNthOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNextNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
		This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextNthSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthNextSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNthNextSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNthNextSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		def ReplaceNextNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNextNthOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNextNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		def ReplaceNthNextOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNthNextOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNthNextOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		#>

	  #-------------------------------------------------------------------------#
	 #   REPLACING NEXT OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION   #
	#-------------------------------------------------------------------------#

	def ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
		This.ReplaceNextNthSubStringCS(1, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextSubStringCSQ(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplaceNextOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNextOccurrenceOfSubStringCSQ(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNextOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def ReplaceNextSubString(pcSubStr, pcNewSubStr, pnStartingAt)
		This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextSubStringQ(pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextSubString(pcSubStr, pcNewSubStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplaceNextOccurrenceOfSubString(pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplaceNextSubString(pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNextOccurrenceOfSubStringQ(pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNextOccurrenceOfSubString(pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		#>

	  #---------------------------------------------------------------------------------#
	 #  REPLACING PREVIOUS NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------#

	def ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
		anPos = This.FindPreviousNthSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
		This.ReplaceSubStringAtPosition( anPos, pcNewSubStr)

		#< @FunctionFluentForm

		def ReplacePreviousNthSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthPreviousSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNthPreviousSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplacePreviousNthOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplacePreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
		This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousNthSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthPreviousSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNthPreviousSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNthPreviousSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		def ReplacePreviousNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplacePreviousNthOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplacePreviousNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		def ReplaceNthPreviousOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplaceNthPreviousOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplaceNthPreviousOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		#>

	  #-----------------------------------------------------------------------------#
	 #   REPLACING PREVIOUS OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION   #
	#-----------------------------------------------------------------------------#

	def ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
		This.ReplacePreviousNthSubStringCS(1, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplacePreviousSubStringCSQ(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplacePreviousOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
			This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

			def ReplacePreviousOccurrenceOfSubStringCSQ(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				This.ReplacePreviousOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def ReplacePreviousSubString(pcSubStr, pcNewSubStr, pnStartingAt)
		This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousSubStringQ(pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousSubString(pcSubStr, pcNewSubStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousOccurrenceOfSubString(pcSubStr, pcNewSubStr, pnStartingAt)
			This.ReplacePreviousSubString(pcSubStr, pcNewSubStr, pnStartingAt)

			def ReplacePreviousOccurrenceOfSubStringQ(pcSubStr, pcNewSubStr, pnStartingAt)
				This.ReplacePreviousOccurrenceOfSubString(pcSubStr, pcNewSubStr, pnStartingAt)
				return This

		#>

	  #------------------------------------------------------#
	 #    REPLACING SUBSTRINGS VERIYING A GIVEN CONDITION   #
	#------------------------------------------------------#

	def ReplaceSubStringsW(pcCondition, pcNewStr)
		anPositions = This.FindSubStringsW(pcCondition)
		This.ReplaceSubStringsAtThesePositions(anPositions, pcNewStr)

		#< @FunctionFluentForm

		def ReplaceSubStringsWQ(pcCondition)
			This.ReplaceSubStringsW(pcCondition)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceAllSubStringsW(pcCondition)
			This.ReplaceSubStringsW(pcCondition)

			def ReplaceAllSubStringsWQ(pcCondition)
				This.ReplaceAllSubStringsW(pcCondition)
				return This

		def ReplaceSubStringsWhere(pcCondition)
			This.ReplaceSubStringsW(pcCondition)

			def ReplaceSubStringsWhereQ(pcCondition)
				This.ReplaceSubStringsWhere(pcCondition)
				return This

		def ReplaceAllSubStringsWhere(pcCondition)
			This.ReplaceSubStringsW(pcCondition)

			def ReplaceAllSubStringsWhereQ(pcCondition)
				This.ReplaceAllSubStringsWhere(pcCondition)
				return This

		#>

	  #================================================================#
	 #   REMOVING ALL OCCURRENCE OF A GIVEN STRING-ITEM IN THE LIST   #
	#================================================================#

	def RemoveAll(pcString)

		aPositions = This.FindAll(pcString)
		nLen = len(aPositions)

		if nLen > 0
			for i = nLen to 1 step -1
				This.RemoveStringAtPosition(i)
			next
		ok

		#< @FunctionFluentForm

		def RemoveAllQ(pcString)
			This.RemoveAll(pcString)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveAllOccurrences(pcString)
			This.RemoveAll(pcString)

			def RemoveAllOccurrencesQ(pcString)
				This.RemoveAllOccurrences(pcString)
				return This

		#--

		def RemoveAllOccurrencesOfString(pcString)
			This.RemoveAll(pcString)

			def RemoveAllOccurrencesOfStringQ(pcString)
				This.RemoveAllOccurrencesOfString(pcString)
				return This

		def RemoveAllOccurrencesOfStringItem(pcString)
			This.RemoveAllOccurrencesOfString(pcString)

		#--

		def Remove(pcString)
			This.RemoveAll(pcString)

			def RemoveQ(pcString)
				This.Remove(pcString)
				return This

		#--

		def RemoveString(pcString)
			This.RemoveAll(pcString)

			def RemoveStringQ(pcString)
				This.RemoveString(pcString)
				return This

		def RemoveStringItem(pcString)
			This.RemoveAll(pcString)

			def RemoveStringItemQ(pcString)
				This.RemoveStringItem(pcString)
				return This

		#--

	def AllOccurrencesOfThisStringRemoved(pcString)
		aResult = This.Copy().RemoveAllOccurrencesOfQ(pcString).Content()
		return aResult

		def AllOccurrencesOfThisStringItemRemoved(pcString)
			return This.AllOccurrencesOfThisStringRemoved(pcString)

		def AllOccurrencesRemoved(pcString)
			return This.AllOccurrencesOfThisStringRemoved(pcString)

		def StringRemoved(pcString)
			return This.AllOccurrencesOfThisStringRemoved(pcString)

	  #-------------------------------------------------------------#
	 #   REMOVING GIVEN OCCURRENCES OF A STRING-ITEM IN THE LIST   #
	#-------------------------------------------------------------#

	def RemoveOccurrences(panOccurrences, pcString)
		for n in panOccurrences
			This.RemoveOccurrence(n, pcString)
		next

		#< @FunctionFluentForm

		def RemoveOccurrencesQ(panOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveOccurrencesOfString(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveOccurrencesOfStringQ(paOccurrences, pcString)
				This.RemoveOccurrencesOfString(paOccurrences, pcString)
				return This

		def RemoveOccurrencesOfStringItem(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveOccurrencesOfStringItemQ(paOccurrences, pcString)
				This.RemoveOccurrencesOfStringItem(paOccurrences, pcString)
				return This

		#--

		def RemoveTheseOccurrences(panOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveTheseOccurrencesQ(panOccurrences, pcString)
				This.RemoveTheseOccurrences(panOccurrences, pcString)
				return This

		#--

		def RemoveTheseOccurrencesOfString(panOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveTheseOccurrencesOfStringQ(panOccurrences, pcString)
				This.RemoveTheseOccurrencesOfString(panOccurrences, pcString)
				return This

		def RemoveTheseOccurrencesOfStringItem(panOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveTheseOccurrencesOfStringItemQ(panOccurrences, pcString)
				This.RemoveTheseOccurrencesOfStringItem(panOccurrences, pcString)
				return This

		#>

	def OccurrencesRemoved(panOccurrences, pcString)
		aResult = This.Copy.RemoveOccurrencesQ(panOccurrences, pcString).Content()
		return aResult

		def TheseOccurrencesRemoved(panOccurrences, pcString)
			return This.OccurrencesRemoved(panOccurrences, pcString)

		def TheseOccurrencesOfThisStringRemoved(panOccurrences, pcString)
			return This.OccurrencesRemoved(panOccurrences, pcString)

		def TheseOccurrencesOfThisStringItemRemoved(panOccurrences, pcString)
			return This.OccurrencesRemoved(panOccurrences, pcString)

	  #-------------------------------------------------#
	 #   REMOVING MANY STRING-ITEMS AT THE SAME TIME   #
	#-------------------------------------------------#

	def RemoveManyCS(pacStrings, pCaseSensitive)
		for str in pacStrings
			This.RemoveAllCS(str, pCaseSensitive)
		next

		#< @FunctionFluentForm

		def RemoveManyCSQ(pacStrings, pCaseSensitive)
			This.RemoveManyCS(pacStrings, pCaseSensitive)
			return This

		#>

		def RemoveAllOfTheseCS(pacStrings, pCaseSensitive)
			This.RemoveManyCS(pacStrings, pCaseSensitive)

			def RemoveAllOfTheseCSQ(pacStrings, pCaseSensitive)
				This.RemoveAllOfTheseCS(pacStrings, pCaseSensitive)
				return This

		def RemoveTheseCS(pacStrings, pCaseSensitive)
			This.RemoveManyCS(pacStrings, pCaseSensitive)

			def RemoveTheseCSQ(pacStrings, pCaseSensitive)
				This.RemoveTheseCS(pacStrings, pCaseSensitive)
				return This

		#--

		def RemoveTheseStringsCS(pacStrings, pCaseSensitive)
			This.RemoveManyCS(pacStrings, pCaseSensitive)

			def RemoveTheseStringsCSQ(pacStrings, pCaseSensitive)
				This.RemoveTheseStringsCS(pacStrings, pCaseSensitive)
				return This

		def RemoveTheseStringItemsCS(pacStrings, pCaseSensitive)
			This.RemoveManyCS(pacStrings, pCaseSensitive)

			def RemoveTheseStringItemsCSQ(pacStrings, pCaseSensitive)
				This.RemoveTheseStringItemsCS(pacStrings, pCaseSensitive)
				return This

		#>

	def TheseStringsRemovedCS(pacStrings, pCaseSensitive)

		aResult =  This.Copy().
				RemoveTheseStringsCSQ(pacStrings, pCaseSensitive).
				Content()

		return aResult

		def TheseStringItemsRemovedCS(pacStrings, pCaseSensitive)
			return This.TheseStringsRemovedCS(pacStrings, pCaseSensitive)

		#--

		def AllOfTheseStringsRemovedCS(pacStrings, pCaseSensitive)
			return This.TheseStringsRemovedCS(pacStrings, pCaseSensitive)

		def AllOfTheseStringItemsRemovedCS(pacStrings, pCaseSensitive)
			return This.TheseStringsRemovedCS(pacStrings, pCaseSensitive)

		#--

		def ManyStringsRemovedCS(pacStrings, pCaseSensitive)
			return This.TheseStringsRemovedCS(pacStrings, pCaseSensitive)

		def ManyStringItemsRemovedCS(pacStrings, pCaseSensitive)
			return This.TheseStringsRemovedCS(pacStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveMany(pacStrings)
		This.RemoveManyCS(pacStrings, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveManyQ(pacStrings)
			This.RemoveMany(pacStrings)
			return This

		#>

		def RemoveAllOfThese(pacStrings)
			This.RemoveMany(pacStrings)

			def RemoveAllOfTheseQ(pacStrings)
				This.RemoveAllOfThese(pacStrings)
				return This

		def RemoveThese(pacStrings)
			This.RemoveMany(pacStrings)

			def RemoveTheseQ(pacStrings)
				This.RemoveThese(pacStrings)
				return This

		#--

		def RemoveTheseStrings(pacStrings)
			This.RemoveMany(pacStrings)

			def RemoveTheseStringsQ(pacStrings)
				This.RemoveTheseStrings(pacStrings)
				return This

		def RemoveTheseStringItems(pacStrings)
			This.RemoveMany(pacStrings)

			def RemoveTheseStringItemsQ(pacStrings)
				This.RemoveTheseStringItems(pacStrings)
				return This

		#>

	def TheseStringsRemoved(pacStrings)

		aResult =  This.Copy().
				RemoveTheseStringsQ(pacStrings).
				Content()

		return aResult

		def TheseStringItemsRemoved(pacStrings)
			return This.TheseStringsRemoved(pacStrings)

		#--

		def AllOfTheseStringsRemoved(pacStrings)
			return This.TheseStringsRemoved(pacStrings)

		def AllOfTheseStringItemsRemoved(pacStrings)
			return This.TheseStringsRemoved(pacStrings)

		#--

		def ManyStringsRemoved(pacStrings)
			return This.TheseStringsRemoved(pacStrings)

		def ManyStringItemsRemoved(pacStrings)
			return This.TheseStringsRemoved(pacStrings)

	  #--------------------------------------------------#
	 #   REMOVING THE NTH OCCURRENCE OF A STRING-ITEM   #
	#--------------------------------------------------#

	def RemoveNthOccurrence(n, pcString)
		if This.NumberOfOccurrence(pcString) >= n
			This.RemoveStringAtPosition( This.FindNthOccurrence(n, pcString) )
		ok

		#< @FunctionFluentForm

		def RemoveNthOccurrenceQ(n, pcString)
			This.RemoveNthOccurrence(n, pcString)
			return This

		#>

		def RemoveNth(n, pcString)
			This.RemoveNthOccurrence(n, pcString)

			def RemoveNthQ(n, pcString)
				This.RemoveNth(n, pcString)
				return This

	def NthOccurrenceRemoved(n, pcString)
		aResult = This.Copy().RemoveNthOccurrenceQ(n, pcString)
		return This

	  #----------------------------------------------------#
	 #   REMOVING THE FIRST OCCURRENCE OF A STRING-ITEM   #
	#----------------------------------------------------#

	def RemoveFirstOccurrence(pcString)
		This.RemoveNthOccurrence(1, pcString)

		#< @FunctionFluentForm

		def RemoveFirstOccurrenceQ(pcString)
			This.RemoveFirstOccurrence(pcString)
			return This

		#>

	def FirstOccurrenceRemoved(pcString)
		aResult = This.Copy().RemoveFirstOccurrenceQ(pcString).Content()
		return aResult

	  #---------------------------------------------------#
	 #   REMOVING THE LAST OCCURRENCE OF A STRING-ITEM   #
	#---------------------------------------------------#

	def RemoveLastOccurrence(pcString)
		This.RemoveStringAtPosition( This.FindLastOccurrence(pcString) )

		#< @FunctionFluentForm

		def RemoveLastOccurrenceQ(pcString)
			This.RemoveLastOccurrence(pcString)
			return This

		#>

	def LastOccurrenceRemoved(pcString)
		aResult = This.Copy().RemoveLastOccurrenceQ(pcString).Content()
		return This

	   #---------------------------------------------------#
	  #   REMOVING NEXT NTH OCCURRENCE OF A STRING-ITEM   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST        #
	#---------------------------------------------------#

	def RemoveNextNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		oSection   = This.SectionQ(pnStartingAt, :LastString)
		aPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		aPositions = StzListOfNumbersQ(aPositions).AddToEachQ(pnStartingAt - 1).Content()
		nPosition = aPositions[n]

		This.RemoveStringAtPosition(nPosition)

		def RemoveNextNthOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
			return This

		def RemoveNthNextOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
				return This

	def NthNextOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)

		aResult  = This.Copy().
				RemoveNthNextOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive).
				Content()

		return aResult

		def NextNthOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)
			return This.NthNextOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveNextNthOccurrence(n, pcString, pnStartingAt)
		This.RemoveNextNthOccurrenceCS(n, pcString, pnStartingAt, :CS = TRUE)

		def RemoveNextNthOccurrenceQ(n, pcString, pnStartingAt)
			This.RemoveNextNthOccurrence(n, pcString, pnStartingAt)
			return This

		def RemoveNthNextOccurrence(n, pcString, pnStartingAt)
			This.RemoveNextNthOccurrence(n, pcString, pnStartingAt)

			def RemoveNthNextOccurrenceQ(n, pcString, pnStartingAt)
				This.RemoveNthNextOccurrence(n, pcString, pnStartingAt)
				return This

	def NthNextOccurrenceRemoved(n, pcString, pnStartingAt)

		aResult  = This.Copy().
				RemoveNthNextOccurrenceQ(n, pcString, pnStartingAt).
				Content()

		return aResult

		def NextNthOccurrenceRemoved(n, pcString, pnStartingAt)
			return This.NthNextOccurrenceRemoved(n, pcString, pnStartingAt)

	   #-----------------------------------------------#
	  #   REMOVING NEXT OCCURRENCE OF A STRING-ITEM   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST    #
	#-----------------------------------------------#

	def RemoveNextOccurrenceCS(pcString, pnStartingAt, pCaseSensitive)
		This.RemoveNextNthOccurrenceCS(1, pcString, pnStartingAt, pCaseSensitive)

		def RemoveNextOccurrenceCSQ(pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextOccurrenceCS(pcString, pnStartingAt, pCaseSensitive)
			return This

	def NextOccurrenceRemovedCS(pcString, pnStartingAt, pCaseSensitive)

		aRrsult =  This.Copy().
				RemoveNextOccurrenceCSQ(pcString, pnStartingAt, pCaseSensitive).
				Content()

		return This

	#-- WITHOUT CASESENSITIVITY

	def RemoveNextOccurrence(pcString, pnStartingAt)
		This.RemoveNextOccurrenceCS(pcString, pnStartingAt, :CS = TRUE)

		def RemoveNextOccurrenceQ(pcString, pnStartingAt)
			This.RemoveNextOccurrence(pcString, pnStartingAt)
			return This

	def NextOccurrenceRemoved(pcString, pnStartingAt)

		aRrsult =  This.Copy().
				RemoveNextOccurrenceQ(pcString, pnStartingAt).
				Content()

		return This

	   #----------------------------------------------------#
	  #   REMOVING MANY NEXT NTH OCCURRENCES OF A STRING   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST         #
	#----------------------------------------------------#

	def RemoveNextNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			RemoveNexNthOccurrences([2, 3], :of = "A", :StartingAt = 3)
			? Content() # !--> [ "A" , "B", "A", "C", "D" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfStringsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok
			
		oSection = This.SectionQ(pnStartingAt, :LastString)

		anPositions  = 	oSection.
				FindAllCSQR(pcString, pCaseSensitive, :stzListOfNumbers).
				AddToEachQ(pnStartingAt-1).
				Content()

		anPositionsToBeRemoved = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeRemoved +  anPositions[n]
			ok
		next

		This.RemoveAllStringsAtThesePositions(anPositionsToBeRemoved)

		#< @FunctionFluentForm

		def RemoveNextNthOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthNextOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
				return This
		#>

	def NextNthOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)

		aResult =  This.
			   RemoveNextNthOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive).
			   Content()

		return aResult

		def NthNextOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)
			return This.NextNthOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveNextNthOccurrences(panList, pcString, pnStartingAt)
		This.RemoveNextNthOccurrencesCS(panList, pcString, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def RemoveNextNthOccurrencesQ(panList, pcString, pnStartingAt)
			This.RemoveNextNthOccurrences(panList, pcString, pnStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthNextOccurrences(panList, pcString, pnStartingAt)
			This.RemoveNextNthOccurrences(panList, pcString, pnStartingAt)

			def RemoveNthNextOccurrencesQ(panList, pcString, pnStartingAt)
				This.RemoveNthNextOccurrences(panList, pcString, pnStartingAt)
				return This
		#>

	def NextNthOccurrencesRemoved(panList, pcString, pnStartingAt)

		aResult =  This.
			   RemoveNextNthOccurrencesQ(panList, pcString, pnStartingAt).
			   Content()

		return aResult

		def NthNextOccurrencesRemoved(panList, pcString, pnStartingAt)
			return This.NextNthOccurrencesRemoved(panList, pcString, pnStartingAt)

	   #--------------------------------------------------#
	  #   REMOVING PREVIOUS NTH OCCURRENCE OF A STRING   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST       #
	#--------------------------------------------------#

	def RemovePreviousNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		oSection   = This.SectionQ(1, pnStartingAt)
		aPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		nPosition = aPositions[ len(aPositions) - n + 1 ]

		This.RemoveStringAtPosition(nPosition)

		def RemovePreviousNthOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
			return This

		def RemoveNthPreviousOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
				return This

	def NthPreviousOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)

		aResult =  This.Copy().
				RemoveNthPreviousOccurrenceCSQ(n, pcString, pnStartingAt, pCaseSensitive).
				Content()

		return This

		def PreviousNthOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)
			return This.NthPreviousOccurrenceRemovedCS(n, pcString, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def RemovePreviousNthOccurrence(n, pcString, pnStartingAt)
		This.RemovePreviousNthOccurrenceCS(n, pcString, pnStartingAt, :Cs = TRUe)

		def RemovePreviousNthOccurrenceQ(n, pcString, pnStartingAt)
			This.RemovePreviousNthOccurrence(n, pcString, pnStartingAt)
			return This

		def RemoveNthPreviousOccurrence(n, pcString, pnStartingAt)
			This.RemovePreviousNthOccurrence(n, pcString, pnStartingAt)

			def RemoveNthPreviousOccurrenceQ(n, pcString, pnStartingAt)
				This.RemoveNthPreviousOccurrence(n, pcString, pnStartingAt)
				return This

	def NthPreviousOccurrenceRemoved(n, pcString, pnStartingAt)

		aResult =  This.Copy().
				RemoveNthPreviousOccurrenceQ(n, pcString, pnStartingAt).
				Content()

		return This

		def PreviousNthOccurrenceRemoved(n, pcString, pnStartingAt)
			return This.NthPreviousOccurrenceRemoved(n, pcString, pnStartingAt)

	   #---------------------------------------------------#
	  #   REMOVING PREVIOUS OCCURRENCE OF A STRING-ITEM   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST        #
	#---------------------------------------------------#

	def RemovePreviousOccurrenceCS(pcString, pnStartingAt, pCaseSensitive)
		This.RemovePreviousNthOccurrenceCS(1, pcString, pnStartingAt, pCaseSensitive)

		def RemovePreviousOccurrenceCSQ(pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousOccurrenceCS(pcString, pnStartingAt, pCaseSensitive)
			return This

	def PreviousOccurrenceRemovedCS(pcString, pnStartingAt, pCaseSensitive)

		aResult =  This.Copy().
				RemovePreviousOccurrenceCSQ(pcString, pnStartingAt, pCaseSensitive).
				Content()

		return This

	#-- WITHOUT CASESENSITIVITY

	def RemovePreviousOccurrence(pcString, pnStartingAt)
		This.RemovePreviousNthOccurrence(1, pcString, pnStartingAt)

		def RemovePreviousOccurrenceQ(pcString, pnStartingAt)
			This.RemovePreviousOccurrence(pcString, pnStartingAt)
			return This

	def PreviousOccurrenceRemoved(pcString, pnStartingAt)
		aResult = This.Copy().RemovePreviousOccurrenceQ(pcString, pnStartingAt).Content()
		return This

	   #--------------------------------------------------------#
	  #   REMOVING MANY PREVIOUS NTH OCCURRENCES OF A STRING   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST             #
	#--------------------------------------------------------#

	def RemovePreviousNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 5)
			? Content() # --> [ "A" , "B", "C", "D", "A" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfStringsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if Q(pnStartingAt).IsOneOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ], :CS = FALSE)

				pnStartingAt = 1
			
			but Q(pnStartingAt).IsOneOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ], :CS = FALSE)

				pnStartingAt = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			stzRaise("Incorrect param! pnStartingAt must be a number.")
		ok
			
		oSection = This.SectionQ(1, pnStartingAt)

		anPositions = oSection.FindAllCSQ(pcString, pCaseSensitive).StringsReversed()

		anPositionsToBeRemoved = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeRemoved + anPositions[n]
			ok
		next

		This.RemoveAllStringsAtThesePositions(anPositionsToBeRemoved)

		#< @FunctionFluentForm

		def RemovePreviousNthOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthPreviousOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
				return This
		#>

	def PreviousNthOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)

		aResult = This.
			  RemovePreviousNthOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive).
			  Content()

		return aResult

		def NthPreviousOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)
			return This.PreviousNthOccurrencesRemovedCS(panList, pcString, pnStartingAt, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def RemovePreviousNthOccurrences(panList, pcString, pnStartingAt)
		This.RemovePreviousNthOccurrencesCS(panList, pcString, pnStartingAt, :CS = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousNthOccurrencesQ(panList, pcString, pnStartingAt)
			This.RemovePreviousNthOccurrences(panList, pcString, pnStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthPreviousOccurrences(panList, pcString, pnStartingAt)
			This.RemovePreviousNthOccurrences(panList, pcString, pnStartingAt)

			def RemoveNthPreviousOccurrencesQ(panList, pcString, pnStartingAt)
				This.RemoveNthPreviousOccurrences(panList, pcString, pnStartingAt)
				return This
		#>

	def PreviousNthOccurrencesRemoved(panList, pcString, pnStartingAt)
		aResult = This.RemovePreviousNthOccurrencesQ(panList, pcString, pnStartingAt).Content()
		return aResult

		def NthPreviousOccurrencesRemoved(panList, pcString, pnStartingAt)
			return This.PreviousNthOccurrencesRemoved(panList, pcString, pnStartingAt)

	  #--------------------------------------------------------#
	 #   REMOVING A STRING-ITEM BY SPECIFYING ITS POSITION    #
	#--------------------------------------------------------#

	def RemoveStringAtPosition(n)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([
				:First, :FirstPosition,
			      	:FirstString, :FirstStringItem ])
				  
				n = 1

			but Q(n).IsOneOfThese([
				:Last, :LastPosition,
			     	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job (Qt-side)

		This.QStringListObject().removeAt(n-1)

		#< @FunctionFluentForm

		def RemoveStringAtPositionQ(n)
			This.RemoveStringAtPosition(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveStringItemAtPosition(n)
			This.RemoveStringAtPosition(n)

			def RemoveStringItemAtPositionQ(n)
				This.RemoveStringItemAtPosition(n)
				return This

		#--

		def RemoveAt(n)
			This.RemoveStringAtPosition(n)

			def RemoveAtQ(n)
				This.RemoveAt(n)
				return This

		def RemoveAtPosition(n)
			This.RemoveStringAtPosition(n)

			def RemoveAtPositionQ(n)
				This.RemoveAtPosition(n)
				return This

		def RemoveStringAt(n)
			This.RemoveStringAtPosition(n)

			def RemoveStringAtQ(n)
				This.RemoveStringAt(n)
				return This

		def RemoveStringItemAt(n)
			This.RemoveStringAtPosition(n)

			def RemoveStringItemAtQ(n)
				This.RemoveStringItemAt(n)
				return This

		#--

		def RemoveNthString(n)
			This.RemoveStringAtPosition(n)

			def RemoveNthStringQ(n)
				This.RemoveNthString(n)
				return This

		def RemoveNthStringItem(n)
			This.RemoveStringAtPosition(n)

			def RemoveNthStringItemQ(n)
				This.RemoveNthStringItem(n)
				return This

		#>

	def StringAtPositionNRemoved(n)
		aResult = This.Copy().RemoveStringAtPositionQ(n).Content()
		return This

		def StringItemAtPositionNRemoved(n)
			return This.StringAtPositionNRemoved(n)

		def NthStringRemoved(n)
			return This.StringAtPositionNRemoved(n)

		def NthStringItemRemoved(n)
			return This.StringAtPositionNRemoved(n)

	  #----------------------------------------#
	 #    REMOVING FIRST STRING IN THE LIST   #
	#----------------------------------------#

	def RemoveFirstString()
		This.RemoveStringAtPosition(1)

		#< @FunctionFluentForm

		def RemoveFirstStringQ()
			This.RemoveFirstString()
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveFirstStringItem()
			This.RemoveFirstString()

			def RemoveFirstStringItemQ()
				This.RemoveFirstStringItem()
				return This

		#>

	def FirstStringRemoved()
		aResult = This.Copy().RemoveFirstStringQ(n).Content()
		return aResult

		def FirstStringItemRemoved()
			return This.FirstStringRemoved()

	  #---------------------------------------#
	 #    REMOVING LAST STRING IN THE LIST   #
	#---------------------------------------#

	def RemoveLastString()
		This.RemoveStringAtPosition( This.NumberOfStrings() )

		#< @FunctionFluentForm

		def RemoveLastStringQ()
			This.RemoveLastString()
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveLastStringItem()
			This.RemoveLastString()

			def RemoveLastStringItemQ()
				This.RemoveLastStringItem()
				return This

		#>

	def LastStringRemoved()
		aResult = This.Copy().RemoveLastStringQ(n).Content()
		return aResult

		def LastStringItemRemoved()
			return This.LastStringRemoved()

	  #-------------------------------------------------------#
	 #  REMOVING MANY STRINGS BY SPECIFYING THEIR POSITIONS  #
	#-------------------------------------------------------#

	def RemoveStringsAtPositions(panPositions)
		panPositions = sort(panPositions)

		for i = len(panPositions) to 1 step -1
			This.RemoveStringAtPosition(panPositions[i])

		next

		#< @FunctionFluentForm

		def RemoveStringsAtPositionsQ(panPositions)
			This.RemoveStringsAtPositions(panPositions)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveStringItemsAtPositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveStringItemsAtPositionsQ(panPositions)
				This.RemoveStringItemsAtPositions(panPositions)
				return This

		#--

		def RemoveManyAt(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyAtQ(panPositions)
				This.RemoveManyAt(panPositions)
				return This

		def RemoveManyAtPositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyAtPositionsQ(panPositions)
				This.RemoveManyAtPositions(panPositions)
				return This

		def RemoveManyStringsAt(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringsAtQ(panPositions)
				This.RemoveManyStringsAt(panPositions)
				return This

		def RemoveManyStringsAtPositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringsAtPositionsQ(panPositions)
				This.RemoveManyStringsAtPositions(panPositions)
				return This

		def RemoveManyAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyAtThesePositionsQ(panPositions)
				This.RemoveManyAtThesePositions(panPositions)
				return This

		def RemoveManyStringsAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringsAtThesePositionsQ(panPositions)
				This.RemoveManyStringsAtThesePositions(panPositions)
				return This

		def RemoveManyStringItemsAt(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringItemsAtQ(panPositions)
				This.RemoveManyStringItemssAt(panPositions)
				return This

		def RemoveManyStringItemsAtPositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringItemsAtPositionsQ(panPositions)
				This.RemoveManyStringItemsAtPositions(panPositions)
				return This

		def RemoveManyStringItemsAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveManyStringItemsAtThesePositionsQ(panPositions)
				This.RemoveManyStringItemsAtThesePositions(panPositions)
				return This

		#--

		def RemoveStringsAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveStringsAtThesePositionsQ(panPositions)
				This.RemoveStringsAtThesePositions(panPositions)
				return This

		def RemoveStringItemsAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveStringItemsAtThesePositionsQ(panPositions)
				This.RemoveStringsAtThesePositions(panPositions)
				return This

		#>
		
	def StringsAtThesePositionsRemoved(panPositions)
		aResult = This.Copy().RemoveStringsAtThesePositionsQ(panPositions).Content()
		return aResult

		def StringItemsAtThesePositionsRemoved(panPositions)
			return This.StringsAtThesePositionsRemoved(panPositions)

	  #---------------------------------#
	 #   REMOVING A RANGE OF STRINGS   #
	#---------------------------------#

	def RemoveRange(pnStart, pnRange)
	
		# Checking the correctness of the pnStart param

		if isList(pnStart) and Q(pnStart).IsFromNamedParamList()
			pnStart = pnStart[2]
		ok

		if isString(pnStart)
			if Q(pnStart).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				pnStart = 1

			but Q(pnStart).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				n = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStart)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Checking the correctness of the pnRange param

		if isList(pnRange) and
		   isString(pnRange[1]) and

		   ( Q(pnRange[1]).IsOneOfTheseCS([ :UpToN, :UpToNStrings, :UpToNStringItems ]) )

		   	pnRange = pnRange[2]
		ok
	
		if NOT isNumber(pnRange)
			stzRaise("Incorrect param type! pnRange must be a number.")
		ok

		# Checking the correctness of the range of the two params

		nLen = This.NumberOfStrings()

		if (pnStart < 1) or (pnStart + pnRange -1 > nLen) or
		   ( pnStart = nLen and pnRange != 1 )
			stzRaise("Out of range!")
		ok

		# Doing the job

		if pnStart = 1
			aResult = This[1]
		else
			aResult = This.Section(1, pnstart-1)
		ok

		for str in This.Section(pnStart + pnRange, nLen)
			aResult + item
		next		
		  
		This.Update( aResult )

		#< @FunctionFluentForm

		def RemoveRangeQ(pcStart, pnRange)
			This.RemoveRange(pnStart, pnRange)

		#>

	def RangeRemoved(pnStart, pnRange)
		aResult = This.Copy().RemoveRangeQ(pnStart, pnRange)
		return aResult

	  #-------------------------------------#
	 #   REMOVING MANY RANGES OF STRINGS   #
	#-------------------------------------#

	def RemoveManyRanges(panRanges)

		for anRange in panRanges
			anRange = RangeToSection(anRange)
		next

		anSections = panRanges

		This.RemoveManySections(anSections)

		def RemoveManyRangesQ(paRanges)
			This.RemoveManyRanges(paRanges)
			return This

	def ManyRangesRemoved(paRanges)
		aResult = This.Copy().RemoveManyRangesQ(paRanges).Content()
		return aResult

	  #-----------------------------------#
	 #   REMOVING A SECTION OF STRINGS   #
	#-----------------------------------#

	def RemoveSection(n1, n2)

		# Checking params correctness

		if isList(n1) and
			( Q(n1).IsFromNamedParamList() or Q(n1).IsFromNamedParamList()  or
			  Q(n1).IsFromPositionNamedParamList() )

			n1 = n1[2]
		ok

		if isList(n2) and ( Q(n2).IsToNamedParamList() or Q(n2).IsToPositionNamedParamList() )
			n2 = n2[2]
		ok

		if isString(n1) and
			( Q(n1).IsOneOfThese([
				:First, :FirstPosition,
				:FirstString, :FirstStringItem ])
			)

			n1 = 1
		ok

		if isString(n2) and
			( Q(n2).IsOneOfThese([
				:Last, :LastPosition,
				:LastString, :LastStringItem ])
			)
 
			n2 = This.NumberOfStrings()
		ok

		if NOT isNumber(n1) and isNumber(n2)
			stzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT  ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings() ) and
			  StzNumberQ(n2).IsBetween(1, This.NumberOfStrings() )
			)

			stzRaise("Out of range!")
		ok

		# Doing the job (Qt-side)


		This.RemoveRange( n1, n2 - n1 + 1 )

		#< @FunctionFluentForm

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

		#>

	def SectionRemoved(n1, n2)
		aResult = This.Copy().RemoveSectionQ(n1, n2)
		return aResult

	  #---------------------------------------#
	 #   REMOVING MANY SECTIONS OF STRINGS   #
	#---------------------------------------#

	def RemoveManySections(paSections)

		/* NOTE
		See explanation of this sokution in the same function in
		stzList class (stzList.ring file)
		*/

		if NOT ( isList(paSections) and
			 Q(paSections).IsListOfPairs() and
			 Q(paSections).MergeQ().AllItemsAreNumbers() )

			stzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		anPositions = ListsMergeQ(paSections).DuplicatesRemoved()

		for i = 1 to This.NumberOfStrings()
			if find(anPositions, i) = 0
				aResult + This[i]
			ok
		next

		return aResult

		def RemoveManySectionsQ(paRanges)
			This.RemoveManySections(paRanges)
			return This

	def ManySectionsRemoved(paRanges)
		aResult = This.Copy().RemoveManySectionsQ(paRanges).Content()
		return aResult

	  #--------------------------------------#
	 #   REMOVING ALL STRINGS IN THE LIST   #
	#--------------------------------------#
	
	def RemoveAllStrings()
		This.QStringListObject().clear()

		#< @FunctionFluentForm

		def RemoveAllStringsQ()
			This.RemoveAllStrings()
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveAllStringItems()
			This.RemoveAllStrings()

			def RemoveAllStringItemsQ()
				This.RemoveAllStringItems()
				return This

		def Clear()
			This.RemoveAllStrings()

			def ClearQ()
				This.Clear()
				return This

		#>

	def AllStringsRemoved()
		return []

		def AllStringItemsRemoved()
			return This.AllStringsRemoved()

	  #----------------------------------------------#
	 #   REMOVING STRINGS UNDER A GIVEN CONDITION   #
	#----------------------------------------------#

	def RemoveW(pCondition)
		/*
		Example:

		o1 = new stzListOfStrings([ "1", "a", "2", "b", "3", "c" ])
		o1.RemoveAllStringsW(:Where = '{ StzCharQ(@string).IsANumber() }')
		? o1.Content()

		# --> Gives: [ "a", "b", "c" ]
		*/

		# Checking the provided param for the pCondition
	
		anPos = This.FindW(pCondition)
		This.RemoveStringsAtThesePositions(anPos)

		#< @FunctionFluentForm

		def RemoveWQ(pCondition)
			This.RemoveW(pCondition)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveStringsW(pCondition)
			This.RemoveW(pCondition)

			def RemoveStringsWQ(pCondition)
				This.RemoveStringsW(pCondition)
				return This

		def RemoveStringItemsW(pCondition)
			This.RemoveW(pCondition)

			def RemoveStringItemsWQ(pCondition)
				This.RemoveStringItemsW(pCondition)
				return This

		#>

	def StringsRemovedW(pCondition)
		aResult = This.Copy().RemoveStringsWQ(pCondition).Content()
		return aResult

		def StringItemsRemovedW(pCondition)
			return This.StringsRemovedW(pCondition)

	  #================================================================#
	 #     CHECKING IF THE LIST IS "BOUNDED' BY TWO GIVEN STRINGS     #
	#================================================================#

	def IsBoundedByCS(pcString1, pcString2, pCaseSensitive)
		bResult = FALSE

		if This.FirstStringQ().IsEqualToCS(pcString1, pCaseSensitive) and
		   This.FirstStringQ().IsEqualToCS(pcString2, pCaseSensitive)

			bResult = TRUE

		ok

		if This.FirstStringQ().IsEqualToCS(pcString2, pCaseSensitive) and
		   This.FirstStringQ().IsEqualToCS(pcString1, pCaseSensitive)

			bResult = TRUE

		ok

		return bResult

		def IsBoundedByTheseTwoStringsCS(pcString1, pcString2, pCaseSensitive)
			return IsBoundedByCS(pcString1, pcString2, pCaseSensitive)

		def IsBoundedByTheseTwoStringItemsCS(pcString1, pcString2, pCaseSensitive)
			return IsBoundedByCS(pcString1, pcString2, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def IsBoundedBy(pcString1, pcString2)
		return This.IsBoundedByCS(pcString1, pcString2, :CaseSensitive = TRUE)

		def IsBoundedByTheseTwoStrings(pcString1, pcString2)
			return This.IsBoundedBy(pcString1, pcString2)

		def IsBoundedByTheseTwoStringItems(pcString1, pcString2)
			return This.IsBoundedBy(pcString1, pcString2)

	  #------------------------------------------------------------#
	 #     GETTING THE N STRINGS BOUNDING THE LIST OF STRINGS     #
	#------------------------------------------------------------#

	def BoundsUpToNStrings(n)
		return [ This.NFirstStrings(n), This.NLastStrings(n) ]

		#< @FunctionFluentForm
	
		def BoundsUpToNStringsQ(n)
			return new stzList( This.BoundsUpToNStrings(n) )

		#>

		#< @FunctionAlternativeForms

		def BoundsUpToNStringItems(n)
			return This.BoundsUpToNStrings(n)

		def BoundingStringsUpToN(n)
			return This.BoundsUpToNStrings(n)

		def BoundingStringItemsUpToN(n)
			return This.BoundsUpToNStrings(n)

		def BoundingStringsUpTN(n)
			return This.BoundsUpToNStrings(n)

		def BoundingStringItemsUpTo(n)
			return This.BoundsUpToNStrings(n)

		#>

	  #-----------------------------------------------------------------------------#
	 #     CHECKING IF THE LIST IS "BOUNDED' SUCCSESSIVELY BY THE GIVEN STRINGS    #
	#-----------------------------------------------------------------------------#

	def IsBoundedSuccsessivelyByCS(paPairsOfBounds, pCaseSensitive)
		/*
		o1 = new stzListOfStrings([ "|", "<", "-", "Scope of Life", "-", ">", "|" ])
		? o1.IsBoundedSuccsessivelyBy([ ["|","|"], ["<",">"], ["-","-"] ])

		!--> TRUE
		*/

		bResult = TRUE
	
		oCopy = This.Copy()
	
		for aPair in paPairsOfBounds
	
			if NOT oCopy.IsBoundedByCS(aPair[1], aPair[2], pCaseSensitive)
				bResult = FALSE
				exit
			else
				oCopy.RemoveBoundsCS(aPair[1], aPair[2], pCaseSensitive)
			ok
		next
	
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def IsBoundedSuccsessivelyBy(paPairsOfBounds)
		return This.IsBoundedSuccsessivelyByCS(paPairsOfBounds, :CaseSensitive = TRUE)

	  #------------------------------------#
	 #     REMOVING BOUNDING STRINGS      #
	#------------------------------------#

	def RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)
		if This.IsBoundedByCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveFirstString()
			This.RemoveLastString()
		ok

		def RemoveBoundsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This

		#--

		def RemoveBoundingStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveBoundingStringsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveBoundingStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseBoundingStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseBoundingStringsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseBoundingStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseFirstAndLastStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseFirstAndLastStringsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseFirstAndLastStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseLastAndFirstStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseLastAndFirstStringsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseLastAndFirstStringsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		#--

		def RemoveBoundingStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveBoundingStringItemsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveBoundingStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseBoundingStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseBoundingStringItemsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseBoundingStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseFirstAndLastStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseFirstAndLastStringItemsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseFirstAndLastStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

		def RemoveTheseLastAndFirstStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
			This.RemoveBoundsCS(pcFirstStr, pcLastStr, pCaseSensitive)

			def RemoveTheseLastAndFirstStringItemsCSQ(pcFirstStr, pcLastStr, pCaseSensitive)
				This.RemoveTheseLastAndFirstStringItemsCS(pcFirstStr, pcLastStr, pCaseSensitive)
				return This

	def BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		aResult = This.Copy().
			  RemoveBoundsCSQ(pcString1, pcString2, pCaseSensitive).
			  Content()

		return aResult

		#< @FunctionAlternativeForms

		def BoundingStringsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def TheseBoundingStringsRemoveCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def BoundingStringItemsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def TheseBoundingStringItemsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
		
		def TheseFirstAndLastStringsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def TheseLastAndFirstStringsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def TheseFirstAndLastStringItemsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		def TheseLastAndFirstStringItemsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveBounds(pcFirstStr, pcLastStr)
		This.RemoveBoundsCS(pcFirstStr, pcLastStr, :CaseSensitive = TRUE)

		def RemoveBoundsQ(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)
			return This

		#--

		def RemoveBoundingStrings(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveBoundingStringsQ(pcFirstStr, pcLastStr)
				This.RemoveBoundingStrings(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseBoundingStrings(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseBoundingStringsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseBoundingStrings(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseFirstAndLastStrings(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseFirstAndLastStringsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseFirstAndLastStrings(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseLastAndFirstStrings(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseLastAndFirstStringsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseLastAndFirstStrings(pcFirstStr, pcLastStr)
				return This

		#--

		def RemoveBoundingStringItems(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveBoundingStringItemsQ(pcFirstStr, pcLastStr)
				This.RemoveBoundingStringItems(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseBoundingStringItems(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseBoundingStringItemsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseBoundingStringItems(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseFirstAndLastStringItems(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseFirstAndLastStringItemsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseFirstAndLastStringItems(pcFirstStr, pcLastStr)
				return This

		def RemoveTheseLastAndFirstStringItems(pcFirstStr, pcLastStr)
			This.RemoveBounds(pcFirstStr, pcLastStr)

			def RemoveTheseLastAndFirstStringItemsQ(pcFirstStr, pcLastStr)
				This.RemoveTheseLastAndFirstStringItems(pcFirstStr, pcLastStr)
				return This

	def BoundsRemoved(pcFirstStr, pcLastStr)

		aResult = This.Copy().RemoveBoundsQ(pcString1, pcString2).Content()
		return aResult

		#< @FunctionAlternativeForms

		def BoundingStringsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemovedCS(pcFirstStr, pcLastStr)

		def TheseBoundingStringsRemove(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		def BoundingStringItemsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		def TheseBoundingStringItemsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)
		
		def TheseFirstAndLastStringsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		def TheseLastAndFirstStringsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		def TheseFirstAndLastStringItemsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		def TheseLastAndFirstStringItemsRemoved(pcFirstStr, pcLastStr)
			return This.BoundsRemoved(pcFirstStr, pcLastStr)

		#>

	  #------------------------------------#
	 #   REMOVING MANY BOUNDING STRINGS   #
	#------------------------------------#

	def RemoveManyBoundsCS(pacPairsOfBounds, pCaseSensitive)
		for acPair in pacPairsOfBounds
			This.RemoveBoundsCS(acPair[1], acPair[2], pCaseSensitive)
		next

		#< @FunctionFluentForm

		def RemoveManyBoundsCSQ(pacPairsOfBounds, pCaseSensitive)
			This.RemoveManyBoundsCS(pacPairsOfBounds, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveManyBoundingStringsCS(pacPairsOfBounds, pCaseSensitive)
			This.RemoveManyBoundsCS(pacPairsOfBounds, pCaseSensitive)

			def RemoveManyBoundingStringsCSQ(pacPairsOfBounds, pCaseSensitive)
				This.RemoveManyBoundingStringsCS(pacPairsOfBounds, pCaseSensitive)
				return This

		def RemoveManyBoundingStringItemsCS(pacPairsOfBounds, pCaseSensitive)
			This.RemoveManyBoundsCS(pacPairsOfBounds, pCaseSensitive)

			def RemoveManyBoundingStringItemsCSQ(pacPairsOfBounds, pCaseSensitive)
				This.RemoveManyBoundingStringItemsCS(pacPairsOfBounds, pCaseSensitive)
				return This

		#>
			
	def ManyBoundsRemovedCS(pacPairsOfBounds, pCaseSensitive)

		aResult =  This.Copy().
				RemoveManyBoundsCSQ(pacPairsOfBounds, pCaseSensitive).
				Content()

		return aResult

		def ManyBoundingStringsRemovedCS(pacPairsOfBounds, pCaseSensitive)
			return This.ManyBoundsRemovedCS(pacPairsOfBounds, pCaseSensitive)


		def ManyBoundingStringItemsRemovedCS(pacPairsOfBounds, pCaseSensitive)
			return This.ManyBoundsRemovedCS(pacPairsOfBounds, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveManyBounds(pacPairsOfBounds)
		This.RemoveManyBoundsCS(pacPairsOfBounds, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveManyBoundsQ(pacPairsOfBounds)
			This.RemoveManyBounds(pacPairsOfBounds)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveManyBoundingStrings(pacPairsOfBounds)
			This.RemoveManyBounds(pacPairsOfBounds)

			def RemoveManyBoundingStringsQ(pacPairsOfBounds)
				This.RemoveManyBoundingStrings(pacPairsOfBounds)
				return This

		def RemoveManyBoundingStringItems(pacPairsOfBounds)
			This.RemoveManyBounds(pacPairsOfBounds)

			def RemoveManyBoundingStringItemsQ(pacPairsOfBounds)
				This.RemoveManyBoundingStringItems(pacPairsOfBounds)
				return This

		#>
			
	def ManyBoundsRemoved(pacPairsOfBounds)

		aResult =  This.Copy().
				RemoveManyBoundsQ(pacPairsOfBounds).
				Content()

		return aResult

		def ManyBoundingStringsRemoved(pacPairsOfBounds)
			return This.ManyBoundsRemoved(pacPairsOfBounds)


		def ManyBoundingStringItemsRemoved(pacPairsOfBounds)
			return This.ManyBoundsRemoved(pacPairsOfBounds)

	  #======================================================#
	 #    REMOVING BLANK-SPACES STRINGS (MADE OF SPACES)    #
	#======================================================#

	def RemoveBlankSpaceStrings()

		for i = This.NumberOfStrings() to 1 step -1

			if This.StringAtPositionQ(i).IsMadeOfSpaces()

				This.RemoveStringAtPosition(i)
			ok

		next

		def RemoveBlankSpacesStrings()
			This.RemoveBlankSpaceStrings()

			def RemoveBlankSpacesStringsQ()
				This.RemoveBlankSpacesStrings()
				return This

		def RemoveBlankStrings()
			This.RemoveBlankSpacesStrings()

			def RemoveBlankStringsQ()
				This.RemoveBlankStrings()
				return This

		def RemoveStringsMadeOfSpaces()
			This.RemoveBlankSpacesStrings()

			def RemoveStringsMadeOfSpacesQ()
				This.RemoveStringsMadeOfSpaces()
				return This

		def RemoveStringsMadeOfBlankSpaces()
			This.RemoveBlankSpacesStrings()

			def RemoveStringsMadeOfBlankSpacesQ()
				This.RemoveStringsMadeOfBlankSpaces()
				return This


	  #=====================================================#
	 #  REMOVING SUBSTRINGS FROM EACH STRING IN THE LIST   #
	#=====================================================#

	def RemoveSubStringCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		/* NOTE: replace with Qt.ReplaceInStrings() when supported by RingQt

		This.QStringListObject().replaceInStrings( pcSubStr, "", pCaseSensitive)

		*/

		aPos = This.FindSubStringCS(pcSubStr, pCaseSensitive)
		/* Reminder

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindSubstringCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 21 ] ]
		*/
		
	
		acResult = []
		for str in This.ListOfStrings()
			cString = StzStringQ(str).RemoveCS(pcSubStr, pCaseSensitive)
			acResult + cString
		next

		This.Update( acResult )


		def RemoveSubStringCSQ(pcSubStr, pCaseSensitive)
			This.RemoveSubStringCS(pcSubStr, pCaseSensitive)
			return This

		def RemoveAllOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			This.RemoveStringCS(pcSubStr, pCaseSensitive)

			def RemoveAllOccurrencesOfSubStringCSQ(pcSubStr, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringCS(pcSubStr, pCaseSensitive)
				return This

	#---

	def RemoveSubString(pcSubStr)
		This.RemoveSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveSubStringQ(pcSubStr)
			This.RemoveSubString(pcSubStr)
			return This

		def RemoveAllOccurrencesOfSubString(pcSubStr)
			This.RemoveSubStringCS(pcSubStr, pCaseSensitive)

			def RemoveAllOccurrencesOfSubStringQ(pcSubStr)
				This.RemoveAllOccurrencesOfSubString(pcSubStr)
				return This

	  #------------------------------------------------------------------#
	 #   REMOVING NTH OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS  #
	#------------------------------------------------------------------#
	
	def RemoveNthSubstringCS(n, pcSubStr, pCaseSensitive)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstSubString ])
				  
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastSubString ])

				n = This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		anPos = This.FindNthOccurrenceOfSubString(pcSubStr, pCaseSensitive)
		nPos = anPos[n]

		This.RemoveSubStringAtPosition(nPos)

		def RemoveNthSubStringCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNthSubStringCS(n, pcSubStr, pCaseSensitive)
			return This

		def RemoveNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
			This.RemoveNthSubStringCS(n, pcSubStr, pCaseSensitive)

			def RemoveNthOccurrenceOfSubStringCSQ(n, pcSubStr, pCaseSensitive)
				This.RemoveNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
				return This

	#---

	def RemoveNthSubString(n, pcSubStr)
		This.RemoveNthSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def RemoveNthSubStringQ(n, pcSubStr)
			This.RemoveNthSubString(n, pcSubStr)
			return This

		def RemoveNthOccurrenceOfSubString(n, pcSubStr)
			This.RemoveNthSubtring(n, pcSubStr)

			def RemoveNthOccurrenceOfSubStringQ(n, pcSubStr)
				This.RemoveNthOccurrenceOfSubString(n, pcSubStr)
				return This

	  #--------------------------------------------------------------------#
	 #   REMOVING FIRST OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS  #
	#--------------------------------------------------------------------#

	def RemoveFirstSubstringCS(pcSubStr, pCaseSensitive)

		This.RemoveNthSubStringCS(1, pcSubStr, pCaseSensitive)

		def RemoveFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			This.RemoveFirstSubStringCS(pcSubStr, pCaseSensitive)

			def RemoveFirstOccurrenceOfSubStringCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
				return This

	#---

	def RemoveFirstSubString(pcSubStr)
		This.RemoveFirstSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveFirstSubStringQ(pcSubStr)
			This.RemoveFirstSubString(pcSubStr)
			return This

		def RemoveFirstOccurrenceOfSubString(pcSubStr)
			This.RemoveFirstSubString(pcSubStr)

			def RemoveFirstOccurrenceOfSubStringQ(pcSubStr)
				This.RemoveFirstOccurrenceOfSubString(pcSubStr)
				return This

	  #-------------------------------------------------------------------#
	 #   REMOVING LAST OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS  #
	#-------------------------------------------------------------------#

	def RemoveLastSubstringCS(pcSubStr, pCaseSensitive)

		This.RemoveNthSubStringCS(:Last, pcSubStr, pCaseSensitive)

		def RemoveLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			This.RemoveLastSubStringCS(pcSubStr, pCaseSensitive)

			def RemoveLastOccurrenceOfSubStringCSQ(pcSubStr, pCaseSensitive)
				This.RemoveLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
				return This

	#---

	def RemoveLastSubString(pcSubStr)
		This.RemoveLastSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveLastSubStringQ(pcSubStr)
			This.RemoveLastSubString(pcSubStr)
			return This

		def RemoveLastOccurrenceOfSubString(pcSubStr)
			This.RemoveFirstSubString(pcSubStr)

			def RemoveLastOccurrenceOfSubStringQ(pcSubStr)
				This.RemoveLastOccurrenceOfSubString(pcSubStr)
				return This

	  #------------------------------------------------#
	 #   REMOVING MANY SUBSTRINGS AT THE SAME TIME    #
	#------------------------------------------------#

	def RemoveSubStringsCS(paSubStr, pCaseSensitive)

		if NOT ( isList(paSubStr) and Q(paSubStr).IsListOfStrings() )
			stzRaise("Incorrect param type! You must provide a list of strings.")
		ok

		for str in paSubStr
			This.RemoveSubStringCS(str, pCaseSensitive)
		next

		#< @FunctionFluentForm

		def RemoveSubStringsCSQ(paSubStr, pCaseSensitive)
			This.RemoveSubStringsCS(paSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveManySubStringsCS(paSubStr, pCaseSensitive)
			This.RemoveSubStringsCS(paSubStr, pCaseSensitive)

			def RemoveManySubStringsCSQ(paSubStr, pCaseSensitive)
				This.RemoveManySubStringsCS(paSubStr, pCaseSensitive)
				return This

		def RemoveTheseSubStringsCS(paSubStr, pCaseSensitive)
			This.RemoveSubStringsCS(paSubStr, pCaseSensitive)

			def RemoveTheseSubStringsCSQ(paSubStr, pCaseSensitive)
				This.RemoveTheseSubStringsCS(paSubStr, pCaseSensitive)
				return This

		#>

	#---

	def RemoveSubStrings(paSubStr)
		This.RemoveSubStrings(paSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveSubStringsQ(paSubStr)
			This.RemoveSubStrings(paSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveManySubStrings(paSubStr)
			This.RemoveSubStrings(paSubStr)

			def RemoveManySubStringsQ(paSubStr)
				This.RemoveManySubStrings(paSubStr)
				return This

		def RemoveTheseSubStrings(paSubStr)
			This.RemoveSubStrings(paSubStr)

			def RemoveTheseSubStringsQ(paSubStr)
				This.RemoveTheseSubStrings(paSubStr)
				return This

		#>

	  #----------------------------------------------------------------------------#
	 #  REMOVING NEXT NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #
	#----------------------------------------------------------------------------#

	def RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstSubString ])
				  
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastSubString ])

				This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		nPos = This.FindNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextNthSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthNextSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNthNextSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNthNextSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		def RemoveNextNthOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNextNthOccurrenceOfSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNextNthOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceOfSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def RemoveNextNthSubString(n, pcStr, pnStartingAt)
		This.RemoveNextNthSubStringCS(n, pcStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextNthSubStringQ(n, pcStr, pnStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthNextSubString(n, pcStr, pnStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pnStartingAt)

			def RemoveNthNextSubStringQ(n, pcStr, pnStartingAt)
				This.RemoveNthNextSubString(n, pcStr, pnStartingAt)
				return This

		def RemoveNextNthOccurrenceOfSubString(n, pcStr, pnStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pnStartingAt)

			def RemoveNextNthOccurrenceOfSubStringQ(n, pcStr, pnStartingAt)
				This.RemoveNextNthOccurrenceOfSubString(n, pcStr, pnStartingAt)
				return This

		def RemoveNthNextOccurrenceOfSubString(n, pcStr, pnStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pnStartingAt)

			def RemoveNthNextOccurrenceOfSubStringQ(n, pcStr, pnStartingAt)
				This.RemoveNthNextOccurrenceOfSubString(n, pcStr, pnStartingAt)
				return This

		#>

	  #-------------------------------------------------------------------------#
	 #   REMOVING NEXT OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION    #
	#-------------------------------------------------------------------------#

	def RemoveNextSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
		anPos = This.FindNextSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextSubStringCSQ(pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemoveNextOccurrenceOfSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
			This.RemoveNextSubStringCS(pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNextOccurrenceOfSubStringCSQ(pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNextOccurrenceOfSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def RemoveNextSubString(pcStr, pnStartingAt)
		This.RemoveNextSubStringCS(pcStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextSubStringQ(pcStr, pnStartingAt)
			This.RemoveNextSubString(pcStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextOccurrenceOfSubString(pcStr, pnStartingAt)
			This.RemoveNextSubString(pcStr, pnStartingAt)

			def RemoveNextOccurrenceOfSubStringQ(pcStr, pnStartingAt)
				This.RemoveNextOccurrenceOfSubString(pcStr, pnStartingAt)
				return This

		#>

	  #----------------------------------------------------------------------------------#
	 #  REMOVING PREVIOUS NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION    #
	#----------------------------------------------------------------------------------#

	def RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
		nPos = This.FindPreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
		This.RemoveSubStringAtPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemovePreviousNthSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemoveNthPreviousSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNthPreviousSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNthPreviousSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		def RemovePreviousNthOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemovePreviousNthOccurrenceOfSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemovePreviousNthOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceOfSubStringCSQ(n, pcStr, pnStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceOfSubStringCS(n, pcStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def RemovePreviousNthSubString(n, pcStr, pnStartingAt)
		This.RemovePreviousNthSubStringCS(n, pcStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousNthSubStringQ(n, pcStr, pnStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthPreviousSubString(n, pcStr, pnStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pnStartingAt)

			def RemoveNthPreviousSubStringQ(n, pcStr, pnStartingAt)
				This.RemoveNthPreviousSubString(n, pcStr, pnStartingAt)
				return This

		def RemovePreviousNthOccurrenceOfSubString(n, pcStr, pnStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pnStartingAt)

			def RemovePreviousNthOccurrenceOfSubStringQ(n, pcStr, pnStartingAt)
				This.RemovePreviousNthOccurrenceOfSubString(n, pcStr, pnStartingAt)
				return This

		def RemoveNthPreviousOccurrenceOfSubString(n, pcStr, pnStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pnStartingAt)

			def RemoveNthPreviousOccurrenceOfSubStringQ(n, pcStr, pnStartingAt)
				This.RemoveNthPreviousOccurrenceOfSubString(n, pcStr, pnStartingAt)
				return This

		#>

	  #-----------------------------------------------------------------------------#
	 #   REMOVING Previous OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION    #
	#-----------------------------------------------------------------------------#

	def RemovePreviousSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
		nPos = This.FindPreviousSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemovePreviousSubStringCSQ(pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemovePreviousOccurrenceOfSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
			This.RemovePreviousSubStringCS(pcStr, pnStartingAt, pCaseSensitive)

			def RemovePreviousOccurrenceOfSubStringCSQ(pcStr, pnStartingAt, pCaseSensitive)
				This.RemovePreviousOccurrenceOfSubStringCS(pcStr, pnStartingAt, pCaseSensitive)
				return This

		#>

	#--- WITHOUT CASESENSITIVITY

	def RemovePreviousSubString(pcStr, pnStartingAt)
		This.RemovePreviousSubStringCS(pcStr, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousSubStringQ(pcStr, pnStartingAt)
			This.RemovePreviousSubString(pcStr, pnStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemovePreviousOccurrenceOfSubString(pcStr, pnStartingAt)
			This.RemovePreviousSubString(pcStr, pnStartingAt)

			def RemovePreviousOccurrenceOfSubStringQ(pcStr, pnStartingAt)
				This.RemovePreviousOccurrenceOfSubString(pcStr, pnStartingAt)
				return This

		#>

	  #--------------------------------------------------------------------#
	 #   REMOVING A SUBSTRING AT A GIVEN POSITION IN THE LIST OF STRING   #
	#--------------------------------------------------------------------#
		/* REMINDER

		o1 = new stzListOfStrings([
			"What's your name please?",
			"Mabrooka!",
			"Your name and my name are not the same...",
			"I see.",
			"Nice to meet you,",
			"Mabrooka!"
		])
	
		? @@( o1.FindSubstringCS("name", :CaseSensitive = TRUE) )
			#--> [ "1" = [ 13 ], "3" = [ 6, 18 ] ]

		*/

	def ContainsSubStringInPositionCS(aSubStrPosition, pcSubStr, pCaseSensitive)
		/*
		Position of a SUBSTRING inside the list of strings is given by
		the pair [ nLevel, nPosition ].

		Where nLevel is the number of the string in the list.
		And nPosition is the position of the substring inside the string.

		EXAMPLE

		o1 = new stzListOfStrings([ "aa_aaa", "bb_b_bbb", "ccc", "d_d" ])
		? o1.SubStringExistsAt([ 2, 3 ]) #--> TRUE
		? o1.SubStringExistsAt([ 3, 1 ]) #--> FALSE

		*/

		n = aSubStrPosition[1]
		This.StringAtPositionQ(n).ContainsSubStringAtPosition(n, pcSubStr, pCaseSensitive)

		#< @FunctionAlternativeForm

		def SubStringExistsInPositionCS(aSubStrPosition, pcSubStr, pCaseSensitive)
			return This.ContainsSubStringInPositionCS(aSubStrPosition, pcSubStr, pCaseSensitive)
		#>

	def RemoveSubStringAtThisPositionCS(aSubStrPosition, pcSubStr, pCaseSensitive)

		If This.SubStringExistsInPositionCS(aSubStrPosition, pcSubStr, pCaseSensitive)

		ok

		
	  #------------------------------------------------------#
	 #    REMOVING SUBSTRINGS VERIYING A GIVEN CONDITION    #
	#------------------------------------------------------#

	def RemoveSubStringsW(pcCondition)
		anPositions = This.FindSubStringsW(pcCondition)
		This.RemoveSubStringsAtThesePositions(anPositions)
		#< @FunctionFluentForm

		def RemoveSubStringsWQ(pcCondition)
			This.RemoveSubStringsW(pcCondition)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveAllSubStringsW(pcCondition)
			This.RemoveSubStringsW(pcCondition)

			def RemoveAllSubStringsWQ(pcCondition)
				This.RemoveAllSubStringsW(pcCondition)
				return This

		def RemoveSubStringsWhere(pcCondition)
			This.RemoveSubStringsW(pcCondition)

			def RemoveSubStringsWhereQ(pcCondition)
				This.RemoveSubStringsWhere(pcCondition)
				return This

		def RemoveAllSubStringsWhere(pcCondition)
			This.RemoveSubStringsW(pcCondition)

			def RemoveAllSubStringsWhereQ(pcCondition)
				This.RemoveAllSubStringsWhere(pcCondition)
				return This

		#>

  	  #==========================================================#
	 #   CHECKING IF ALL THE STRINGS VERIFY A GIVEN CONDITION   #
	#==========================================================#

	def CheckW(pcCondition)
		return This.StringsQ().CheckW(pcCondition)

		#< @FunctionAlternativeForms

		def Check(pcCondition)
			return This.CheckW(pcCondition)

		def Verify(pcCondition)
			return This.CheckW(pcCondition)

		def EachStringVerifyW(pcCondition)
			return This.CheckW(pcCondition)

		def EachStringVerify(pcCondition)
			return This.CheckW(pcCondition)

		def EachStringItemVerifyW(pcCondition)
			return This.CheckW(pcCondition)

		def EachStringItemVerify(pcCondition)
			return This.CheckW(pcCondition)

		#>

	  #-------------------------------------------------------------------#
	 #   CHECKING IF STRINGS AT GIVEN POSITIONS VERIFY A GIVEN CONDITION   #
	#-------------------------------------------------------------------#

	def CheckOnW(panPositions, pcCondition)

		return This.StringsQ().CheckOnW(panPositions, pcCondition)

		#< @FunctionAlternativeForms

		def VerifyOnW(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def CheckOn(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def VerifyOn(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def CheckOnPositionsW(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def VerifiyOnPositionsW(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def CheckOnThesePositionsW(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def VerifyThesePositionsW(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def CheckOnPositions(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)

		def VerifyOnPositions(panPositions, pcCondition)
			return This.CheckOnW(panPositions, pcCondition)
		#>

	  #------------------------------------------------------------------#
	 #   CHECKING IF STRINGS AT GIVEN SECTIONS VERIFY A GIVEN CONDITION   #
	#------------------------------------------------------------------#

	def CheckOnSectionsW(paSections, pcCondition)
		return This.StringsQ().CheckOnSectionsW(paSections, pcCondition)

		#< @FunctionAlternativeForm

		def VerifyOnSectionsW(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def CheckOnSections(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def VerifyOnSections(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def CheckOnTheseSectionsW(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def VerifyOnTheseSectionsW(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def CheckOnTheseSections(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		def VerifyOnTheseSections(paSections, pcCondition)
			return This.CheckOnSectionsW(paSections, pcCondition)

		#>

	  #===========================================#
	 #   YIELDING INFORMATION FROM EACH STRING   #
	#===========================================#

	def Yield(pcCode)
		return This.StringsQ().YieldFrom( 1:This.NumberOfStrings(), pcCode )

		#< @FunctionFluentForm

		def YieldQ(pcCode)
			return This.YieldQR(pcCode, :stzList)
	
		def YieldQR(pcCode, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Yield(pcCode) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.Yield(pcCode) )
				
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Yield(pcCode) )

			on :stzHashList
				return new stzHashList( This.Yield(pcCode) )
		
		other
				stzRaise("Unsupported return type!")
		off

		#>

		#< @FunctionAlternativeForms

		def YieldFromEachChar(pcCode)
			return This.Yield(pcCode)

			def YieldFromEachCharQ(pcCode)
				return This.YieldFromEachCharQR(pcCode, :stzList)
		
			def YieldFromEachCharQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.YieldFromEachChar(pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.YieldFromEachChar(pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.YieldFromEachChar(pcCode) )
	
				on :stzHashList
					return new stzHashList( This.YieldFromEachChar(pcCode) )
			
			other
					stzRaise("Unsupported return type!")
			off

		def Harvest(pcCode)
			return This.Yield(pcCode)

			def HervestQ(pcCode)
				return This.YieldFromEachCharQR(pcCode, :stzList)
		
			def HarvestQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Harvest(pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.Harvest(pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.Harvest(pcCode) )
	
				on :stzHashList
					return new stzHashList( This.Harvest(pcCode) )
			
			other
					stzRaise("Unsupported return type!")
			off

		def HarvestFromEachChar(pcCode)
			return This.Yield(pcCode)

			def HarvestFromEachCharQ(pcCode)
				return This.HarvestFromEachCharQR(pcCode, :stzList)
		
			def HarvestFromEachCharQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromEachChar(pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.HarvestFromEachChar(pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.HarvestFromEachChar(pcCode) )
	
				on :stzHashList
					return new stzHashList( This.HarvestFromEachChar(pcCode) )
			
			other
					stzRaise("Unsupported return type!")
			off
		#>

	  #----------------------------------------------------------#
	 #   YIELDING INFORMATION FROM STRINGS AT GIVEN POSITIONS   #
	#----------------------------------------------------------#

	def YieldFrom(panPositions, pcCode)
		return This.StringsQ().YieldFrom(panPositions, pcCode)

		#< @FunctionFluentForm

		def YieldFromQ(paPositions, pcCode)
			return This.YieldFromQR(paPositions, pcCode, :stzList)
	
		def YieldFromQR(paPositions, pcCode, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.YieldFrom(paPositions, pcCode) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.YieldFrom(paPositions, pcCode) )
				
			on :stzListOfNumbers
				return new stzListOfNumbers( This.YieldFrom(paPositions, pcCode) )
		
			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def YieldFromPositions(panPositions, pcCode)
			return This.YieldFrom(panPositions, pcCode)

			def YieldFromPositionsQ(paPositions, pcCode)
				return This.YieldFromPositionsQR(paPositions, pcCode, :stzList)
		
			def YieldFromPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.YieldFromPositions(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.YieldFromPositions(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.YieldFromPositions(paPositions, pcCode) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def YieldFromCharsAt(panPositions, pcCode)
			return This.YieldFrom(panPositions, pcCode)

			def YieldFromCharsAtQ(paPositions, pcCode)
				return This.YieldFromCharsAtQR(paPositions, pcCode, :stzList)
		
			def YieldFromCharsAtQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.YieldFromCharsAt(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.YieldFromCharsAt(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.YieldFromCharsAt(paPositions, pcCode) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def YieldFromCharsAtPositions(panPositions, pcCode)
			return This.YieldOn(panPositions, pcCode)

			def YieldFromCharsAtPositionsQ(paPositions, pcCode)
				return This.YieldFromCharsAtPositionsQR(paPositions, pcCode, :stzList)
		
			def YieldFromCharsAtPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.YieldFromCharsAtPositions(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.YieldFromCharsAtPositions(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.YieldFromCharsAtPositions(paPositions, pcCode) )
	
				on :stzHashList
					return new stzHashList( This.YieldFromCharsAtPositions(paPositions, pcCode) )
			
			other
					stzRaise("Unsupported return type!")
			off

		def HarvestFromPositions(panPositions, pcCode)
			return This.HarvestFrom(panPositions, pcCode)

			def HarvestFromPositionsQ(paPositions, pcCode)
				return This.HarvestFromPositionsQR(paPositions, pcCode, :stzList)
		
			def HarvestFromPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromPositions(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.HarvestFromPositions(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.HarvestFromPositions(paPositions, pcCode) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def HarvestFromCharsAt(panPositions, pcCode)
			return This.HarvestFrom(panPositions, pcCode)

			def HarvestFromCharsAtQ(paPositions, pcCode)
				return This.HarvestFromCharsAtQR(paPositions, pcCode, :stzList)
		
			def HarvestFromCharsAtQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromCharsAt(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.HarvestFromCharsAt(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.HarvestFromCharsAt(paPositions, pcCode) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def HarvestFromCharsAtPositions(panPositions, pcCode)
			return This.HarvestOn(panPositions, pcCode)

			def HarvestFromCharsAtPositionsQ(paPositions, pcCode)
				return This.HarvestFromCharsAtPositionsQR(paPositions, pcCode, :stzList)
		
			def HarvestFromCharsAtPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromCharsAtPositions(paPositions, pcCode) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.HarvestFromCharsAtPositions(paPositions, pcCode) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.HarvestFromCharsAtPositions(paPositions, pcCode) )
	
				other
					stzRaise("Unsupported return type!")
				off
		#>

	  #--------------------------------------------------------#
	 #   YIELDING INFORMATION ON STRINGS IN GIVEN SECTIONS    #
	#--------------------------------------------------------#

	def YieldFromSections(paSections, pcCode)
		return This.StringsQ().YieldFromSections(paSections, pcCode)

		#< @FunctionFluentForm

		def YieldFromSectionsQ(paSections, pcCode)
			return new stzList( This.YieldFromSections(paSections, pcCode) )

		def YieldSections(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

		#>

		#< @FunctionAlternativeForms

		def HarvestFromSections(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestFromSectionsQ(paSections, pcCode)
				return This.HarvestFromSections(paSections, pcCode, :stzList)

			def HarvestFromSectionsQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromSections(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestFromSections(paSections, pcCode) )
	
				other
					stzRaise("Unsupported param type!")
				off
	
		def HarvestSections(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestSectionsQ(paSections, pcCode)
				return This.HarvestSections(paSections, pcCode, :stzList)

			def HarvestSectionsQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestSections(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestSections(paSections, pcCode) )
	
				other
					stzRaise("Unsupported param type!")
				off
		#>

	def YieldFromSectionsOneByOne(paSections, pcCode)
		if NOT isList(paSections) and Q(paSections).IsListOfPairsOfNumbers()
			stzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		aResult = []

		anSectionsExpanded = []
		for aSection in paSections
			anSectionsExpanded + Q(aSection).ExpandedIfPairOfNumbers()
		next

		for anPositions in anSectionsExpanded
			aResult + This.YieldFromPositions(anPositions, pcCode)
		next

		return aResult

		#< @FunctionFluentForm

		def YieldFromSectionsOneByOneQ(paSections, pcCode)
			return This.YieldFromSectionsOneByOneQR(paSections, pcCode, :stzList)

		def YieldFromSectionsOneByOneQR(paSections, pcCode, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.YieldFromSectionsOneByOneQ(paSections, pcCode) )

			on :stzListOfLists
				return new stzListOfLists( This.YieldFromSectionsOneByOneQ(paSections, pcCode) )

			other
				stzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def HarvestFromSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestFromSectionsOneByOneQ(paSections, pcCode)
				return This.HarvestFromSectionsOneByOne(paSections, pcCode, :stzList)

			def HarvestFromSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestFromSectionsOneByOne(paSections, pcCode) )
	
				other
					stzRaise("Unsupported param type!")
				off
				
		def HarvestSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestSectionsOneByOneQ(paSections, pcCode)
				return This.HarvestSectionsOneByOne(paSections, pcCode, :stzList)

			def HarvestSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestSectionsOneByOne(paSections, pcCode) )
	
				other
					stzRaise("Unsupported param type!")
				off

		def YieldSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def YieldSectionsOneByOneQ(paSections, pcCode)
				return This.YieldSectionsOneByOne(paSections, pcCode, :stzList)

			def YieldSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.YieldSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.YieldSectionsOneByOne(paSections, pcCode) )
	
				other
					stzRaise("Unsupported param type!")
				off

		#>

	  #------------------------------------------------------------------#
	 #   YIELDING INFORMATION ON STRINGS VERIFYiNG A GIVEN CONDITION    #
	#------------------------------------------------------------------#

	def YieldW(pcCode, pcCondition)

		return This.StringsQR(:stzList).YieldW(pcCode, pcCondition)

		#< @FunctionFluentForm

		def YieldWQ(pcCode, pcCondition)
				return This.YieldWQR(paPositions, pcCode, :stzList)
		
			def YieldWQR(pcCode, pcCondition, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.YieldW(pcCode, pcCondition) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.YieldW(pcCode, pcCondition) )
					
				on :stzListOfNumbers
					return new stzListOfNumbers( This.YieldW(pcCode, pcCondition) )
	
				on :stzHashList
					return new stzHashList( This.YieldW(pcCode, pcCondition) )
			
			other
					stzRaise("Unsupported return type!")
			off

		#>

		#> @FunctionAlternativeForm

		def HarvestW(pcCode, pcCondition)
			return This.YieldW(pcCode, pcCondition)

			def HervestWQ(pcCode, pcCondition)
				return This.HarvestWQR(pcCode, pcCondition, :stzList)

			def HervestWQR(pcCode, pcCondition, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					stzRaise("IncorrectType! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestW(pcCode, pcCondition) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestW(pcCode, pcCondition) )

				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #=========================================#
	 #   PERFORMING AN ACTION ON EACH STRING   #
	#=========================================#

	def Perform(pcCode)

		/*
		Must begin with '@string ='

		 Example

		o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])
		o1.ForEachStringPerform('{ Q(@str).RemoveQ(".txt").Content() }')

		o1.Content() # ---> [ "village", "town", "country" ]
		*/
		 
		This.PerformOnThesePositions(1:This.NumberOfStrings(), pcCode)

		#--

		def PerformQ(pcCode)
			This.Perform(pcCode)
			return This

	  #------------------------------------------------------#
	 #   PERFORMING ACTIONS ON STRINGS IN GIVEN POSITIONS   #
	#------------------------------------------------------#

	def PerformOn(panPositions, pcCode)

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			stzRaise("Invalid param type! panPositions must be a list of numbers.")
		ok

		if len(panPositions) = 0
			return
		ok

		if NOT isString(pcCode)
			stzRaise("Invalid param type! pcCode must be a string.")
		ok

		oCode = new stzString( StzCCodeQ(pcCode).UnifiedFor(:stzListOfStrings) )
		if oCode.WithoutSpaces() = ''
			return
		ok

		if NOT oCode.BeginsWithOneOfTheseCS(
			[ "@string =", "@string=",
			  "@string +=", "@string+=",
			  "@string -=", "@string-=",
			  "@string *=", "@string*=",
			  "@string /=", "@string/="
			],

			:CaseSensitive = FALSE )

			stzRaise("Syntax error! pcCode must begin with '@string ='.")
		ok

		cCode = oCode.Content()
	
		for @i in panPositions

			@string = This[ @i ]
			bEval = TRUE

			if @i = This.NumberOfStrings() and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i+1]", :CS=FALSE )

				bEval = FALSE

			but @i = 1 and
			    oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i-1]", :CS=FALSE )

				bEval = FALSE
			
			ok

			if bEval

				eval(cCode)
				This.ReplaceStringAtPosition(@i, :With = @string)
			ok

		next

		#--

		def PerformOnQ(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)
			return This

		def PerformOnPositions(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)

			def PerformOnPositionsQ(panPositions, pcCode)
				This.PerformOnPositions(panPositions, pcCode)
				return This

		def PerformOnThesePositions(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)

			def PerformOnThesePositionsQ(panPositions, pcCode)
				This.PerformOnThesePositions(panPositions, pcCode)
				return This

	  #--------------------------------------------------------#
	 #   PERFORMING AN ACTION ON STRINGS IN GIVEN SECTIONS    #
	#--------------------------------------------------------#

	def PerformOnSections(paSections, pcCode)

		anPositions = StzListOfPairsQ(paSections).
				ExpandedIfPairsOfNumbersQ().MergeQ().
				RemoveDuplicatesQ().SortedInAscending()

		This.PerformOnPositions(anPositions, pcCode)

		#--

		def PerformOnSectionsQ(paSections, pcCode)
			This.PerformOnSections(paSections, pcCode)
			return This

		def PerformOnTheseSections(paSections, pcCode)
			This.PerformOnSections(paSections, pcCode)

			def PerformOnTheseSectionsQ(paSections, pcCode)
				This.PerformOnTheseSections(paSections, pcCode)
				return This

	  #-----------------------------------------------------------------#
	 #   PERFORMING AN ACTION ON STRINGS VERIFYING A GIVEN CONDITION   #
	#-----------------------------------------------------------------#

	def PerformW(pcAction, pcCondition)
		/* EXAMPLE

		o1 = new stzListOfStrings(["a","b", "C", "D", "e"])
		o1.PerformW( '@string = upper(@string)', :If = 'islower(@string)' )

		? @@(o1.Content()) #--> [ "A", "B", "C", "D", "E" ]

		*/

		if NOT isString(pcAction)
			stzRaise("Incorrect param! pcAction must be a string.")
		ok

		if isList(pcCondition) and Q(pcCondition).IsIfOrWhereNamedParamList()
			pcCondition = pcCondition[2]
		ok

		cAction    = StzCCodeQ(pcAction).UnifiedFor(:stzListOfStrings)
		cCondition = StzCCodeQ(pcCondition).UnifiedFor(:stzListOfStrings)

		oAction    = new stzString(cAction)
		oCondition = new stzString(cCondition)

		if oAction.WithoutSpaces() = '' or
		   oCondition.WithoutSpaces() = ''

			return
		ok

		@i = 0
		for @string in This.ListOfStrings()
			@i++
			bEval = TRUE

			if @i = This.NumberOfStrings() and
			   oCondition.ContainsCS("@NextString", :CS = FALSE )

				bEval = FALSE
			ok

			if @i = 1 and
			   oCondition.ContainsCS("@PreviousString", :CS = FALSE )

				bEval = FALSE
			ok

			if bEval
				eval( "bOk = (" + cCondition + ")" )

				if bOk

					if @i = This.NumberOfStrings() and
					   oAction.ContainsCS("@NextString", :CS = FALSE)

						bEval = FALSE
					ok

					if @i = 1 and
					   oAction.ContainsCS("@PreviousString", :CS = FALSE)

						bEval = FALSE
					ok

					if bEval

						eval(cAction)
						This.ReplaceStringAtPosition(@i, :With = @string )
					ok

				ok
			ok
		next

		#--

		def PerformWQ(paParams)
			This.PerformW(paParams)
			return This

	   #===============================================#
	  #    CHECKING IF A STRING-ITEM IS DUPLICATED    #
	 #   (APPEARS MORE THAN ONCE IN THE LIST)        #
	#===============================================#

	/*
	Can be solved nicely, using conditional code, like this:

	o1 = new stzListOfStrings([ :green, :white, :green, :yellow, :red, :green ])
	? o1.Verify( :That = ' NumberOfOccurrence( :Of = :green ) > 2 ' ) #--> TRUE

	*/

	def IsDuplicatedStringItemCS(pcStr, pCaseSensitive)

		if This.NumberOfOccurrenceOfStringItemCS(pcStr, pCaseSensitive) > 1
			return TRUE
		else
			return FALSE
		ok

		def IsDuplicatedStringCS(pcStr, pCaseSensitive)
			return This.IsDuplicatedStringItemCS(pcStr, pCaseSensitive)

		def IsDuplicatedCS(pcStr, pCaseSensitive)
			return This.IsDuplicatedStringItemCS(pcStr, pCaseSensitive)

	#---

	def IsDuplicatedStringItem(pcStr)

		if This.NumberOfOccurrenceOfStringItem(pcStr) > 1
			return TRUE
		else
			return FALSE
		ok

		def IsDuplicatedString(pcStr)
			return This.IsDuplicatedStringItem(pcStr)

		def IsDuplicated(pcStr)
			return This.IsDuplicatedStringItem(pcStrg)

	  #--------------------------------#
	 #   LIST OF DUPLICATED STRINGS   #
	#--------------------------------#

	def DuplicatedStringsCS(pCaseSensitive)
		
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		aResult = []

		if pCaseSensitive = TRUE

			for str in This.ListOfStrings()

				if This.IsDuplicatedCS(str, :CS = TRUE) and 
			   	StzListQ( aResult ).ContainsNo( str )
			
					aResult + str
				ok
			next

		else
			for str in This.ListOfStrings()

				str = StzStringQ(str).Content()
				oResult = StzListOfStringsQ( aResult ).LowercaseQ()
				
				if This.IsDuplicatedCS(str, :CS = FALSE) and 
			   	   oResult.ContainsNo( str )
			
					aResult + str
				ok
			next

		ok		

		return aResult

		def DuplicatedStringsCSQ(pCaseSensitive)
			return new stzListOfStrings( This.DuplicatedStringsCS(pCaseSensitive) )

	def DuplicatedStrings()
		return This.DuplicatedStringsCS(:CaseSensitive = TRUE)

		def DuplicatedStringsQ()
			return new stzListOfStrings( This.DuplicatedStrings() )

 	  #--------------------------------#
	 #   LIST OF DUPLICATES STRINGS   #
	#--------------------------------#

	# TODO: Difference between duplicates and duplicated is not clear --> Rename it

	def DuplicatesCS(pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		aResult = []

		if pCaseSensitive = TRUE
			
			for str in This.DuplicatedStringsCS(:CaseSensitive = TRUE)
				
				for i in This.FindAllExceptFirstCS(str, :CaseSensitive = TRUE)
					aResult + i
				next i
				
			next

		else
			for str in This.DuplicatedStringsCS(:CaseSensitive = FALSE)
				
				for i in This.FindAllExceptFirstCS(str, :CaseSensitive = FALSE)
					aResult + i
				next i
				
			next

		ok	

		return sort(aResult) # TODO: Check why sort()?

		def DuplicatesCSQ(pCaseSensitive)
			return new stzListOfStrings( This.DuplicatesCS(pCaseSensitive) )

	def Duplicates()
		return This.DuplicatesCS( :CaseSensitive = TRUE )

		def DuplicatesQ()
			return new stzListOfStrings( This.DuplicatesQ() )

	  #---------------------------#
	 #    REMOVING DUPLICATES    #
	#---------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if pCaseSensitive = TRUE
			/*
			oQStrList = This.QStringListObject()
			oQStrList.removeDuplicates()

			This.Update( QStringListContent(oQStrList) )
			*/

			This.QStringListObject().removeDuplicates()

		else
			oQStrList = This.Copy().LowercaseQ().QStringListObject()
			oQStrList.removeDuplicates()

			This.Update( QStringListContent(oQStrList) )
		ok

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

		def DuplicatesRemovedCS(pCaseSensitive)
			aResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
			return aResult

	def RemoveDuplicates()
		This.RemoveDuplicatesCS( :CaseSensitive = TRUE )

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	def DuplicatesRemoved()
		aResult = This.Copy().RemoveDuplicatesQ().Content()
		return aResult

	  #============================================================#
	 #   UNIQUE CHARS APPEARING IN ALL THE STRINGS OF THE LIST    #
	#============================================================#

	def UniqueChars()
		aListOfUniqueChars = []

		for oStr in This.ToListOfStzStrings()
			aListOfUniqueChars + oStr.UniqueChars()
		next

		aResult = []

		StzListQ(aListOfUniqueChars) {
			Flatten()
			RemoveDuplicates()
			aResult = Content()
		}

		return aResult

		/*
		We could also solve it like this:
		aResult = StzListQ(aListOfUniqueChars).FlattenQ().RemoveDuplicatesQ().Content()
	
		*/

		def UniqueCharsQ()
			return This.UniqueCharsQR(:stzList)

		def UniqueCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzListLists( This.UniqueChars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueChars() )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueChars() )

			other
				stzRaise("Unsupported return type!")
			off

	  #------------------------------------------------------------#
	 #   COMMON CHARS APPEARING IN ALL THE STRINGS OF THE LIST    #
	#------------------------------------------------------------#

	# TODO: Unique VS Common may be confusing! Think of a better naming!

	def CommonChars()
		aResult = []

		for c in This.UniqueChars()
			if This.ContainsSubstring_InEachString(c)
				aResult + c
			ok
		next

		return aResult

		def CommonCharsQ()
			return This.CommonCharsQR(:stzList)
	
		def CommonCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Commonchars() )
			on :stzListOfChars
				return new stzListOfChars( This.CommonChars() )
			on :stzListOfStrings
				return new stzListOfStrings( This.CommonChars() )
			other
				stzRaise("Unsupported return type!")
			off

	  #==================#
	 #     INDEXING     #
	#==================#

	/* TODO

	Move this part to a new class called stzListOfTexts
	because stzStrings and ListOfStrings should not
	be aware of the concept of Words.

	*/

	def IndexWordsOnPosition()
		return This.WordsQ().IndexOnPosition()

		def IndexWordsOnPositions()
			return This.IndexWordsOnPosition()

	def IndexWordsOnPositionQ()
		return new stzList( This.IndexWordsOnPosition() )

		def IndexWordsOnPositionsQ()
			return This.IndexWordsOnPositionQ()

	def IndexWordsOnNumberOfOccurrence()
		return This.WordsQ().IndexOnNumberOfOccurrence()

		def IndexWordsOnNumberOfOccurrences()
			return This.IndexWordsOnNumberOfOccurrence()

	def IndexWordsOnNumberOfOccurrenceQ()
		return new stzList( This.IndexWordsOnNumberOfOccurrence() )

		def IndexWordsOnNumberOfOccurrencesQ()
			return This.IndexWordsOnNumberOfOccurrenceQ()

	def IndexWordsOn(pcOn)
		if pcOn = :Position
			This.IndexWordsOnPosition()

		but pcOn = :NumberOfOccurrence
			This.IndexWordsOnNumberOfOccurrence()
		ok

	def IndexWordsOnQ(pcOn)
		return new stzList( This.IndexWords(pcOn))

	  #---------------#
	 #     WORDS     #
	#---------------#

	def Words()
		aResult = []
		for cString in This.ListOfStrings()
			aResult + StzStringQ(cString).Words()
		next

	  #---------------------------------#
	 #     LOWER, UPPER & Foldcase     #
	#---------------------------------#

	def IsLowercase()
		bResult = TRUE
		for str in This.ListOfStrings()
			if NOT StzStringQ(str).IsLowercase()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def AllStringsAreLowercase()
		return This.IsLowercase()

	def IsUppercase()
		bResult = TRUE

		for str in This.ListOfStrings()
			if NOT StzStringQ(str).IsUppercase()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def AllStringsAreUppercase()
		return This.IsUppercase()

	def ApplyLowercase()
		for i = 1 to This.NumberOfStrings()
			This.ReplaceStringAtPosition(i, StzStringQ(This.Content()[i]).Lowercased())
		next

	def ApplyLowercaseQ()
		This.ApplyLowercase()
		return This

	def Lowercase()
		This.ApplyLowercase()

	def LowercaseQ()
		This.Lowercase()
		return This

	def lowercased()
		aResult = []
		for str in This.ListOfStrings()
			aResult + StzStringQ(str).Lowercased()
		next
		return aResult

	def ApplyUppercase()
		for i = 1 to This.NumberOfStrings()
			This.ReplaceStringAtPosition( i, StzStringQ( This.Content()[i]).Uppercased() )
		next

	def ApplyUppercaseQ()
		This.ApplyUpperCase()
		return This

	def Uppercase()
		This.ApplyUppercase()

	def UppercaseQ()
		This.Uppercase()
		return This

	def Uppercased()
		aResult = []
		for str in This.ListOfStrings()
			aResult + StzStringQ(str).Uppercased()
		next
		return aResult

	def ApplyFoldcase()
		for i = 1 to This.NumberOfStrings()
			This.ReplaceStringAtPosition(i, StzStringQ(This.Content()[i]).Foldcased())
		next

	def ApplyFoldcaseQ()
		This.Foldcase()
		return This

	def Foldcase()
		This.ApplyFoldcase()

	def FoldcaseQ()
		This.Foldcase()
		return This

	def Foldcased()
		aResult = []
		for str in This.ListOfStrings()
			aResult + StzStringQ(str).Foldcased()
		next
		return aResult

	def ApplyTitlecase()
		for i = 1 to This.NumberOfStrings()
			This.ReplaceStringAtPosition(i, StzStringQ(This.Content()[i]).Titlecased())
		next

	def ApplytitlecaseQ()
		This.ApplyTitlecase()
		return This

	def Titlecase()
		This.ApplyTitlecase()

	def TitlecaseQ()
		This.Titlecase()
		return This

	def Titlecased()
		aResult = []
		for str in This.ListOfStrings()
			aResult + StzStringQ(str).Titlecased()
		next
		return aResult

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

			:Line = :Thin,	# or :Dashed
		
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
		
		if StzListQ(paBoxOptions).IsTextBoxedOptionsParamList()

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

			stzRaise(stzListOfStringsError(:paBoxOptions))
		ok		

		def BoxXTQ(paBoxOptions)
			return new stzListOfStrings(This.BoxXT(paBoxOptions))

		def BoxedXT(paBoxOptions)
			return This.BoxXTQ(paBoxOptions).Content()
	
	  #----------------------------------------------------#
	 #    ALIGNING THE STRING IN A CONTAINER OF N CHARS   #
	#----------------------------------------------------#

	// Aligns the text to the left of the container of width nWidth
	// Note: if the width is smaller then the string, nothing is done!

	def Align(nWidth, cChar, cDirection)
		# cChar is the char to fill the 'blanks" with
		# cDirection --> :Left, :Right, :Center, :Justified
		
		if nWidth = :Max
			nWidth = This.YieldQR('Q(@str).NumberOfChars()', :stzListOfNumbers).Max()
		ok

		i = 0
		for str in This.ListOfStrings()
			i++
			cStrAligned = StzStringQ(str).AlignQ(nWidth, " ", pcDirection).Content()
			This.ReplaceStringAtPosition(i, :With = cStrAligned )
		next

		def AlignQ(nWidth, cChar, cDirection)
			This.Align(nWidth, cChar, cDirection)
			return This

	def Aligned(nWidth, cChar, cDirection)
		aResult = This.Copy().AlignQ(nWidth, cChar, cDirection).Content()
		return aResult
	
	def LeftAlign(nWidth, cChar)
		This.Align(nWidth, cChar, :Left)

		def LeftAlignQ(nWidth, cChar)
			This.LeftAlign(nWidth, cChar)
			return This

		def AlignLeft(nWidth, cChar)
			This.LeftAlign(nWidth, cChar)

			def AlignLeftQ(nWidth, cChar)
				This.AlignLeft(nWidth, cChar)
				return This

	def LeftAligned(nWidth, cChar, cDirection)
		aResult = This.Copy().LeftAlignQ(nWidth, cChar, cDirection).Content()
		return aResult

	def RightAlign(nWidth, cChar)
		This.Align(nWidth, cChar, :Right)

		def RightAlignQ(nWidth, cChar)
			This.RightAlign(nWidth, cChar)
			return This

		def AlignRight(nWidth, cChar)
			This.RightAlign(nWidth, cChar)

			def AlignRightQ(nWidth, cChar)
				This.AlignRight(nWidth, cChar)
				return This

	def RightAligned(nWidth, cChar, cDirection)
		aResult = This.Copy().RightAlignQ(nWidth, cChar, cDirection).Content()
		return aResult

	def CenterAlign(nWidth, cChar)
		This.Align(nWidth, cChar, :Center)

		def CenterAlignQ(nWidth, cChar)
			This.CenterAlign(nWidth, cChar)
			return This

		def AlignCenter(nWidth, cChar)
			This.CenterAlign(nWidth, cChar)

			def AlignCenterQ(nWidth, cChar)
				This.AlignCenter(nWidth, cChar)
				return This

	def CenterAligned(nWidth, cChar, cDirection)
		aResult = This.Copy().CenterAlignQ(nWidth, cChar, cDirection).Content()
		return aResult

	def Justify(nWidth, cChar)
		This.Align(nWidth, cChar, :Justified)

		def JustifyQ(nWidth, cChar)
			This.Justify(nWidth, cChar)
			return This

	def Justified(nWidth, cChar, cDirection)
		aResult = This.Copy().JustifyQ(nWidth, cChar, cDirection).Content()
		return aResult

	  #---------------------#
	 #     COMBINATIONS    #
	#---------------------#

	def NumberOfCombinations()
		return len(This.Combinations()) # TODO: solve it mathematically.
	
	def Combinations()
	
		if This.NumberOfStrings() < 2
			stzRaise("Can't compute combinations for that list!")
		ok
	
		# t0 = clock()
	
		aResult = []
	
		aOtherItems = []
			
		for item in This.ListOfStrings()
			
			oList = This.ToStzList()
			oList - item
	
			aOtherItems = oList.Content()
			
			stage = [ item, aOtherItems ]
			
			oStr = new stzString( stage[1] )
			oStr * stage[2]
				
			aCombinations = oStr / ( This.NumberOfStrings()-1 )
		
			for str in aCombinations
				aResult + StzStringQ(str) / 2
			next
		
		next
	
		# ? (clock() - t0 ) / clockspersecond()
	
		return aResult

	  #-------------------------------#
	 #     SPLITTING EACH STRING     #
	#-------------------------------#

	/*
	NOTE: After adding Perform() and Yield() function to this class,
	it becomes very easy to using any methdod from stzString and apply
	it the strings of this list.

	For example, the following function Split(), that splits all the
	strings using a given separators (was written before Yield() was
	created), can be rewritten in one line like this:

	This.Yield('{ Q(@str).Split(cSep) }')

	*/

	def Split(cSep)
		/* Example

		o1 = new stzListOfStrings([
			"abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp"
		])
		
		? o1.Split(";")	   # --> [
				   # 		[ "abc", "123", "tunis", "rgs" ],
				   # 		[ "jhd", "343", "gafsa", "ghj" ],
				   # 		[ "lki", "112", "beja" , "okp" ]
				   #     ]
		*/

		aResult = []
	
		for oStr in This.ToListOfStzStrings()
			aResult + oStr.Split(cSep)
		next

		return aResult

		#< @FunctionFluentForm

		def SplitQ(cSep)
			return new stzListOfLists( This.Split(cSep) )

		def SplitQR(cSep, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				stzRaise([
					:Where = "stzListOfStrings (8611) > SplitQR()",
					:What  = "Can't cast the object to the type you requested!",
					:Why   = "The type you required is not supported",
					:Todo  = "Opt for an other type, implement it by yourself, or create the type of object uisng new."
				])
			off

		#>

	def NthSubstringsAfterSplittingStringsUsing(n, cSep)
		/* Example

		o1 = new stzListOfStrings([
			"abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp"
		])
		
		? o1.Split(";")	   # --> [
				   # 		[ "abc", "123", "tunis", "rgs" ],
				   # 		[ "jhd", "343", "gafsa", "ghj" ],
				   # 		[ "lki", "112", "beja" , "okp" ]
				   #     ]
		
		? o1.Split(";")[1] # --> [ "abc", "123", "tunis", "rgs" ]
		? o1.Split(";")[2] # --> [ "jhd", "343", "gafsa", "ghj" ]
		? o1.Split(";")[3] # --> [ "lki", "112", "beja" , "okp" ]
		
		? o1.NthSubstringsAfterSplittingStringsUsing(3, ";")
		# --> [ "tunis", "gafsa", "beja" ]
		
		# The same function can be expressed like this
		? o1.NthSubstrings(3, :AfterSplittingStringsUsing = ";") # --> [ "tunis", "gafsa", "beja" ]

		*/

		aResult = []

		for oStr in This.ToListOfStzStrings()
			aResult + oStr.NthSubstringAfterSplittingStringUsing(n, cSep)
		next

		return aResult

		#< @FunctionFluentForm

		def NthSubstringsAfterSplittingStringsUsingQ(n, cSep)
			return new stzListOfStrings( This.NthSubstringsAfterSplittingStringsUsing(n, cSep) )

		#>

	def NthSubstrings(n, acSep)

		if isNumber(n) and
		   ListIsListOfStrings(acSep) and
		   len(acSep) = 2 and
		   acSep[1] = :AfterSplittingStringsUsing

			return This.NthSubstringsAfterSplittingStringsUsing(n, acSep[2])
		else
			stzRaise("Incorrect param types!")
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
		acResult = []

		for str in This.ListOfStrings()
			acResult + StzStringQ(str).Simplified()
		next

		This.Update( acResult )

		#< @FunctionFluentForm

		def SimplifyQ()
			This.Simplify()
			return This
		
		#>

	def Simplified()
		aResult = This.Copy().SimplifyQ().Content()

	  #------------------------------#
	 #    UNICODES OF ALL STRINGS   #
	#------------------------------#

	def Unicodes()
		aResult = []

		for str in This.ListOfStrings()
			aResult + StzStringQ(str).Unicodes()
		next

		return aResult

		#< @FunctionFluentForm

		def UnicodesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzListOfUnicodes
				return new stzListOfUnicodes( This.Unicodes() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Unicodes() )
			on :stzListOfLists
				return new stzListOfLists( This.Unicodes() )
			other
				stzRaise("Unsupported return type!")
			off
				
		def UnicodesQ()
			return This.UnicodesQR(:stzListOfUnicodes)

		#>

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

		for str in This.ListOfStrings()
			acResult + StzTextQ(str).Script()
		next

		return acResult

		def ScriptsQ()
			return This.ScriptsQR(:stzList)

		def ScriptsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Scripts() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Scripts() )

			other
				stzRaise("Unsupported return type!")
			off

	  #------------#
	 #    MISC.   #
	#------------#

	def AreAnagrams()
		bResult = TRUE
		for str1 in This.ListOfStrings()
			for str2 in This.ListOfStrings()
				if NOT StzStringQ(str1).IsAnagramOf(str2)
					bResult = FALSE
					exit 2
				ok
			next
		next

		return bResult

		def IsListOfAnagrams()
			return This.AreAnagrams()

	def MultiplyBy(pcStr)
		if isString(pcStr)
			This.ReplaceW('{ @string += pcStr }')

		ok

		def MultiplyByQ(pcStr)
			This.MultiplyBy(pcStr)
			return This

	def MultipliedBy(pcStr)
		aResult = This.Copy().MultiplyByQ(pcStr).Content()
		return aResult

	def ContainsNoEmptyStrings()
		bResult = TRUE

		for str in This.ListOfStrings()
			if str = NULL
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def RemoveEmptyStrings()

		for i = This.NumberOfStrings() to 1 step -1
			if This.StringAtPosition(i) = NULL
				This.RemoveStringAtPosition(i)
			ok
		next

		def RemoveEmptyStringsQ()
			This.RemoveEmptyStrings()
			return This

	  #---------------------------------------------------------------#
	 #   COMPARING THE LIST OF STRINGS TO AN OTHER LIST OF STRINGS   # 
	#---------------------------------------------------------------#

	def IsEqualToCS(pcOtherListOfStr, pCaseSensitive)
		acThisSorted = This.SortedInAscending()
		acOtherSorted = StzListOfStringsQ(pcOtherListOfStr).SortedInAscending()

		bResult = TRUE
		
		i = 0
		for str in acThisSorted
			i++
			if NOT StzStringQ(str).IsEqualToCS(acOtherSorted[i], pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsEqualTo(pcOtherListOfStr)
		return This.IsEqualToCS(pcOtherListOfStr)

	  #------------------------------#
	 #     OPERATORS OVERLOADING    # 
	#------------------------------#

	/*
		TODO: Operators should carry same semantics in all classes...
	*/

	def operator(pcOp, pValue)
		
		if pcOp = "[]"

			if isNumber(pValue)
				return This.StringAt(pValue)

			but isString(pValue)

				if StzStringQ(pValue).SimplifyQ().IsBoundedBy("{","}")

					pcCondition = StzStringQ(pValue).SimplifyQ().BoundsRemoved("{","}")
					anResult = []
	
					@i = 0
					for @string in This.ListOfStrings()
						@i++
						cCode = 'if ( ' + pcCondition + ' )' + NL +
							'	anResult + @i' + NL +
							'ok'
						eval(cCode)
					next
	
					return anResult

				else
					return This.FindFirstOccurrence(value)	
				ok
			else
				return This.FindAll(pValue)
			ok	
			
		// Add an item at the beginning of the list
		but pOp = "<<"
			This.Prepend(value)

		// Add an item at the end of the list
		but pOp = ">>"
			This.Append(value)

		but pOp = "="
			return This.ToStzList().IsEqualTo(value)

		but pOp = "=="
			return This.ToStzList().IsStrictlyEqualTo(value)
		

		but pcOp = "/" and type(pValue) = "NUMBER"
			// Divides the list on pValue sublists (a list of lists)
			return This.ToStzList().SplitToNParts(pValue)

		but pcOp = "-"
			if isNumber(pValue) or isString(pValue)
				This.RemoveNthQ( find(This.ListOfStrings(), pValue) )

			but isList(pValue)
				if len(pValue) > 0
					anPositions = This.FindMany(pValue)
					This.RemoveItemsAtPositions(anPositions)
				ok
			ok

		but pcOp = "*"
			This.MultiplyBy(pValue)

		but pcOp = "+"
			This.AddString(pValue)
		ok
