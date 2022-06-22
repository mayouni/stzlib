#-------------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - stzListOfStrings			#
#		 An accelerative library for Ring applications	      		#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The core class for managing lists of strings		#
#	Version		: V1.0 (2020-2022)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#-------------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzListOfStringsQ(paList)
	return new stzListOfStrings(paList)

func LS(p)
	if isList(p)
		return StzListOfNumbersQ(p).OnlyStrings()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyStrings()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LSQ(p)
		return Q(LS(p))

		func QLS(p)
			return LSQ(p)

	func LoS(p)
		return LS(p)

		func LoSQ(p)
			return LSQ(p)

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

	func QStringListObjectToList(oQStrList)
		return QStringListToList(oQStrList)

func QStringListToStzListOfStrings(oQStrList)
	return new stzListOfStrings(QStringListToList(oQStrList))

	func QStringListObjectToStzListOfStrings(oQStrList)
		return QStringListToStzListOfStrings(oQStrList)

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

	func QStringListObjectContent(poQStrList)
		return QStringListContent(poQStrList)

	func QStringListToRingList(poQStrList)
		return QStringListContent(poQStrList)

	func QStringListObjectToRingList(poQStrList)
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

		but isString(pList)

			try
				aList = StzStringQ(pList).ToList()

				if StzListQ(aList).IsListOfStrings()
					@oQStrList = new QStringList()
					for str in aList
						@oQStrList.append(str)
					next

				else
					stzRaise("The list in the string you provided is not a list of strings!")
				ok
			catch
				stzRaise("Can't transform the string to a list!")
			done
			
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

			def StringItemsQ()
				return This.StringItemsQR(:stzList)
	
			def StringItemsQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.StringItems() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItems() )
	
				other
					stzRaise("Unsupported return type!")
				off
					
		def ListOfStringItems()	
			return This.Content()
		
		def ListOfStrings()	
			return This.Content()

		def Items()
			return This.StringItems()

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

		def Size()
			return This.NumberOfStringItems()

		def SizeInStrings()
			return This.NumberOfStringItems()

		def SizeInStringItems()
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

		def StringItemAtPositionN(n)
			return This.StringItemAt(n)

			def StringItemAtPositionNQ(n)
				return new stzString( This.StringItemAtPositionN(n) )

		def StringAtPosition(n)
			return This.StringItemAt(n)

			def StringAtPositionQ(n)
				return new stzString( This.StringAtPosition(n) )

		def StringAtPositionN(n)
			return This.StringItemAt(n)

			def StringAtPositionNQ(n)
				return new stzString( This.StringAtPositionN(n) )

		def String(n)
			return This.StringItemAt(n)

			def StringQ(n)
				return new stzString( This.String(n) )

		def StringN(n)
			return This.StringItemAt(n)

			def StringNQ(n)
				return new stzString( This.StringN(n) )

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

		if NOT  ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings()) and
			StzNumberQ(n2).IsBetween(1, This.NumberOfStrings())
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

		def Join()
			return This.Concatenate()

			def JoinQ()
				return This.Join()
				return This
	
	def Concatenated()
		return This.ConcatenateQ().Content()

		def Joined()
			return Thhis.Content()
	
	def ConcatenateUsing(pcSep)
		return This.QStringListObject().join(pcSep)

		def ConcatenateUsingQ(pcSep)
			return new stzString( This.ConcatenateUsing(pcSep) )

		def JoinUsing()
			return This.ConcatenateUsing(pcSep)
	
	def ConcatenatedUsing(pcSep)
		aResult = This.Copy().ConcatenateUsingQ(pcSep).Content()
		return aResult

		def JoinedUsing(pcSep)
			aResult = This.ConcatenatedUsing(pcSep)

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

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT  ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings()) and
			StzNumberQ(n2).IsBetween(1, This.NumberOfStrings())
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
			aResult + This.StringAtQ(i).StringWithCharsSortedInAscending()
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
			aResult + This.StringAtQ(i).StringWithCharsSortedInAscending()
		next

		return aResult

	def SortCharsOfEachStringInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringAtQ(i).StringWithCharsSortedInDescending()
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
			aResult + This.StringatQ(i).StringWithCharsSortedInDescending()
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

	def FindAllCS(pcStrItem, pCaseSensitive)

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

		#< @FunctionFluentForm

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
		#>

		#< @FunctionAlternativeForms

		def FindStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def FindStringItemCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def FindStringItemCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def FindStringCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def FindStringCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def FindStringCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def FindCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def FindCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def FindCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def FindAllOccurrencesOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def FindAllOccurrencesOfStringItemCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def FindAllOccurrencesOfStringItemCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def FindAllOccurrencesOfStringCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def FindAllOccurrencesOfStringCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def FindAllOccurrencesOfStringCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def PositionsOfCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def PositionsOfCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def PositionsOfCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def PositionsOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def PositionsOfStringItemCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def PositionsOfStringItemCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def StringItemPositionsCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def StringItemPositionsCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def StringItemPositionsCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def PositionsOfStringCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def PositionsOfStringCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def PositionsOfStringCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def StringPositionsCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def StringPositionsCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def StringPositionsCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def AllPositionsOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def AllPositionsOfStringItemCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def AllPositionsOfStringItemCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def AllStringItemPositionsCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def AllStringItemPositionsCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def AllStringItemPositionsCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def AllPositionsOfStringCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def AllPositionsOfStringCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def AllPositionsOfStringCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		def AllStringPositionsCS(pcStrItem, pCaseSensitive)
			return This.FindAllCS(pcStrItem, pCaseSensitive)

			def AllStringPositionsCSQ(pcStrItem, pCaseSensitive)
				return This.FindAllCSQ(pcStrItem, pCaseSensitive)

			def AllStringPositionsCSQR(pcStrItem, pCaseSensitive, pcReturnType)
				return This.FindAllCSQR(pcStrItem, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindAll(pcStrItem)
		return This.FindallCS(pcStrItem, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindAllQ(pcStrItem)
			return FindAllQR(pcStrItem, :stzList)

		def FindAllQR(pcStrItem, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAll(pcStrItem) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAll(pcStrItem) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindStringItem(pcStrItem)
			return This.FindAll(pcStrItem)

			def FindStringItemQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def FindStringItemQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def FindString(pcStrItem)
			return This.FindAll(pcStrItem)

			def FindStringQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def FindStringQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def FindAllOccurrencesOfStringItem(pcStrItem)
			return This.FindAll(pcStrItem)

			def FindAllOccurrencesOfStringItemQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def FindAllOccurrencesOfStringItemQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def FindAllOccurrencesOfString(pcStrItem)
			return This.FindAll(pcStrItem)

			def FindAllOccurrencesOfStringQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def FindAllOccurrencesOfStringQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def PositionsOf(pcStrItem)
			return This.FindAll(pcStrItem)

			def PositionsOfQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def PositionsOfQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def PositionsOfStringItem(pcStrItem)
			return This.FindAll(pcStrItem)

			def PositionsOfStringItemQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def PositionsOfStringItemQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def StringItemPositions(pcStrItem)
			return This.FindAll(pcStrItem)

			def StringItemPositionsQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def StringItemPositionsQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def PositionsOfString(pcStrItem)
			return This.FindAll(pcStrItem)

			def PositionsOfStringQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def PositionsOfStringQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def StringPositions(pcStrItem)
			return This.FindAll(pcStrItem)

			def StringPositionsQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def StringPositionsQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def AllPositionsOfStringItem(pcStrItem)
			return This.FindAll(pcStrItem)

			def AllPositionsOfStringItemQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def AllPositionsOfStringItemQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def AllStringItemPositions(pcStrItem)
			return This.FindAll(pcStrItem)

			def AllStringItemPositionsQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def AllStringItemPositionsQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def AllPositionsOfString(pcStrItem)
			return This.FindAll(pcStrItem)

			def AllPositionsOfStringQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def AllPositionsOfStringQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		def AllStringPositions(pcStrItem)
			return This.FindAll(pcStrItem)

			def AllStringPositionsQ(pcStrItem)
				return This.FindAllQ(pcStrItem)

			def AllStringPositionsQR(pcStrItem, pcReturnType)
				return This.FindAllQR(pcStrItem, pcReturnType)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A STRING-ITEM EXCEPT NTH OCCURRENCE  #
	#-----------------------------------------------------------------#
	/*
	NOTE: These functions were made to be used in RemoveDuplicates()
	TODO: Generalise the ...Except() extension in all stz functions
	*/

	def FindAllExceptNthCS(pcStr, n, pCaseSensitive)
		aResult = []

		if n = :First or n = :FirstOccurrence 

			n = 1

		but n = :Last or n = :LastOccurrence

			n = This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)
		ok

		anPositions = This.FindAllCS(pcStr, pCaseSensitive)

		del( anPositions, n)

		return anPositions

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
				return new stzList( This.FindAllExceptNthCS(pcStr, n, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNthCS(pcStr, n, pCaseSensitive) )

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
				return new stzList( This.FindAllExceptNth(pcStr, n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNth(pcStr, n) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A STRING-ITEM EXCEPT FIRST OCCURRENCE  #
	#--------------------------------------------------------------------#

	def FindAllExceptFirstCS(pcStr, pCaseSensitive)
		Return This.FindAllExceptNthCS(pcStr, 1, pCaseSensitive)

		#< @FunctionFluentForm

		def FindAllExceptFirstCSQ(pcStr, pCaseSensitive)
			return This.FindAllExceptFirstCSQR(pcStr, pCaseSensitive, :stzList)

		def FindAllExceptFirstCSQR(pcStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptFirst(pcStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptFirst(pcStr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptFirst(pcStr)
		return This.FindAllExceptFirstCS(pcStr, :CaseSensitive)

		#< @FunctionFluentForm

		def FindAllExceptFirstQ(pcStr)
			return This.FindAllExceptFirstQR(pcStr, :stzList)

		def FindAllExceptFirstQR(pcStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptFirst(pcStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptFirst(pcStr) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	  #-------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A STRING-ITEM EXCEPT LAST OCCURRENCE  #
	#-------------------------------------------------------------------#

	def FindAllExceptLastCS(pcStr, pCaseSensitive)
		Return This.FindAllExceptNthCS(pcStr, :LastOccurrence, pCaseSensitive)

		#< @FunctionFluentForm

		def FindAllExceptLastCSQ(pcStr, pCaseSensitive)
			return This.FindAllExceptLastCSQR(pcStr, pCaseSensitive, :stzList)

		def FindAllExceptLastCSQR(pcStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptLast(pcStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptLast(pcStr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptLast(pcStr)
		return This.FindAllExceptLastCS(pcStr, :CaseSensitive)

		#< @FunctionFluentForm

		def FindAllExceptLastQ(pcStr)
			return This.FindAllExceptLastQR(pcStr, :stzList)

		def FindAllExceptLastQR(pcStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptLast(pcStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptLast(pcStr) )

			other
				stzRaise("Unsupported return type!")
			off

		#>
		
	  #----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A STRING-ITEM IN THE LIST OF STRINGS  #
	#----------------------------------------------------------------#

	def NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		return len( This.FindStringItemCS(pcStrItem, pCaseSensitive) )

		def NumberOfOccurrencesOfStringItemCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def NumberOfOccurrencesOfStringCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#--

		def NumberOfOccurrenceCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def NumberOfOccurrencesCS(pcStrItem, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfStringItem(pcStrItem)
		return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfStringItem(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		#--

		def NumberOfOccurrenceOfString(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		def NumberOfOccurrencesOfString(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		#--

		def NumberOfOccurrence(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		def NumberOfOccurrences(pcStrItem)
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

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrencesOfManyStringItemsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrencesOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrencesOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrenceOfManyStringsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrenceOfManyStringsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrenceOfManyStringsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrencesOfManyStringsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrencesOfManyStringsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrencesOfManyStringsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManyStringItems(pacStrItems)
		return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, :CS = TRUE )

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsQ(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, :stzList)

		def NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, pcReturnType)
			return This.NumberOfOccurrenceOfManyStringItemsQRCS(pacStrItems, pcCaseSensitive, pcReturnType)
		#>

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfManyStringItems(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrencesOfManyStringItemsQ(pacStrItems)
				return This.NumberOfOccurrencesOfManyStringItemsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrencesOfManyStringItemsQR(pacStrItems, pcReturnType)
				return This.NumberOfOccurrencesOfManyStringItemsQRCS(pacStrItems, pcCaseSensitive, pcReturnType)

		def NumberOfOccurrenceOfManyStrings(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrenceOfManyStringsQ(pacStrItems)
				return This.NumberOfOccurrenceOfManyStringsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrenceOfManyStringsQR(pacStrItems, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrenceOfManyStrings(pacStrItems) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStrings(pacStrItems) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def NumberOfOccurrencesOfManyStrings(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrencesOfManyStringsQ(pacStrItems)
				return This.NumberOfOccurrencesOfManyStringsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrencesOfManyStringsQR(pacStrItems, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStrings(pacStrItems) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStrings(pacStrItems) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #-------------------------------------------------------------#
	 #    NUMBER OF OCCURRENCE OF MANY STRINGS-ITEMS -- EXTENDED   #
	#-------------------------------------------------------------#

	/*
	TODO: The ...CSXT() extension should also be provided in a sipmler form:
			...XT( ..., [ :CS = ... ])

	*/

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

	  #-----------------------------------------------------------------#
	 #    FINDING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS    #
	#-----------------------------------------------------------------#
	
	def FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		if isString(n)
			if n = :First or n = :FirstOccurrence
				n = 1

			but n = :Last or n = :LastOccurrence
				n = This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param type! n must be a number.")
		ok

		anPos = This.FindStringItemCS(pcStrItem, pCaseSensitive)

		nResult = 0

		if n <= len(anPos)
			nResult = anPos[n]
		ok

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

		def FindNthCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def NthOccurrenceCS(n, pcStrItem, pCaseSensitive)
			return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceOfStringItem(n, pcStrItem)
		
		return This.FindNthOccurrenceOfStringItemCS(n, pcStrItem, :CaseSensitive = TRUE)

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

		def FindNth(n, pcStrItem)
			return This.FindNthOccurrenceOfStringItem(n, pcStrItem)

		def NthOccurrence(n, pcStrItem)
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

		def FindFirstOccurrenceCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceOfThisStringItemCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstOccurrenceOfThisStringCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstStringCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindFirstCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FirstOccurrenceCS(pcStrItem, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceOfStringItem(pcStrItem)
		
		return This.FindFirstOccurrenceOfStringItemCS(pcStrItem, :CaseSensitive = TRUE)

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

		def FirstOccurrence(pcStrItem)
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

		def FindLastOccurrenceCS(pcStrItem, pCaseSensitive)
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

		def LastOccurrenceCS(pcStrItem, pCaseSensitive)
			return This.FindLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindLastOccurrenceOfStringItem(pcStrItem)
		
		return This.FindLastOccurrenceOfStringItemCS(pcStrItem, :CaseSensitive = TRUE)

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

		def LastOccurrence(pcStrItem)
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
		This.FindStringItemsCS(pacStrItems, :CaseSensitive = TRUE)

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


	  #=========================================================#
	 #    CHECKING IF THE LIST CONTAINS A GIVEN STRING-ITEM    #
	#=========================================================#

	def ContainsCS(pcStr, pCaseSensitive)

		bResult = 0

		if This.FindFirstCS(pcStr, pCaseSensitive) > 0
			bResult = TRUE
		ok

		return bResult

		#< @FunctionNegationForm

		def ContainsNoCS(pcStr, pCaseSensitive)
			return NOT This.ContainsCS(pcStr, pCaseSensitive)

		#>

		def ContainsStringCS(pcStr, pCaseSensitive)
			return This.ContainsCS(pcStr, pCaseSensitive)

		def ContainsStringItemCS(pcStr, pCaseSensitive)
			return This.ContainsCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Contains(pcStr)
		return This.ContainsCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionNegationForm

		def ContainsNo(pcStr)
			return NOT This.Contains(pcStr)

		#>

		def ContainsString(pcStr)
			return This.Contains(pcStr)

		def ContainsStringItem(pcStr)
			return This.Contains(pcStr)
	
	  #--------------------------------------------------------------------#
	 #    CHECKING IF THE LIST-OF-STRINGS IS CONTAINED IN A GIVEN LIST    #
	#--------------------------------------------------------------------#

	def IsContainedInCS(paList, pCaseSensitive)
		
		if NOT isList(paList)
			stzRaise("Incorrect param type! paList must be a list.")
		ok

		bResult = FALSE

		if Q(paList).IsListOfStrings()
			bResult = StzListOfStringsQ(paList).ContainsCS( This.Content(), pCaseSensitive )
		else
			if pCaseSensitive = TRUE
				bResult = StzListQ(paList).Contains( This.Content() )
			else
				paList = StzListQ(paList).ListsOfStringsLowercased()
				bResult = StzListQ(paList).Contains( This.Lowercased() )
			ok
		ok

		return bResult


		#< @FunctionAlternativeForm

		def ExistsInCS(paList, pCaseSensitive)
			return This.IsContainedInCS(paList, pCaseSensitive)

		def IsIncludedInCS(paList, pCaseSensitive)
			return This.IsContainedInCS(paList, pCaseSensitive)

		def IsOneOfTheseCS(paList, pCaseSensitive)
			return This.IsContainedInCS(paList, pCaseSensitive)

			def IsNotOneOfTheseCS(paList, pCaseSensitive)
				return NOT This.IsOneOfTheseCS(paList, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def IsContainedIn(paList)
		return This.IsContainedInCS(paList, :CaseSensitive = TRUE)

		def ExistIn(paList)
			return This.IsContainedIn(paList)

		def IsIncludedIn(paList)
			return This.IsContainedIn(paList)

		def IsOneOfThese(paList, pCaseSensitive)
			return This.IsContainedIn(paList)

			def IsNotOneOfThese(paList)
				return NOT This.IsOneOfThese(paList)

	  #-------------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS EACH ONE OF THE GIVEN STRINGS    #
	#-------------------------------------------------------------------#

	def ContainsEachCS(paStrings, pCaseSensitive)
		bResult = TRUE

		for str in paStrings
			if NOT This.ContainsCS(str, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def ContainsEachOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsEachCS(paStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsEach(paStrings)
		return This.ContainsEachCS(paStrings, :CaseSensitive = TRUE)

		def ContainsEachOneOfThese(paStrings)
			return This.ContainsEach(paStrings)

	  #-----------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS NO ONE OF THE GIVEN STRINGS    #
	#-----------------------------------------------------------------#

	def ContainsNoOneCS(paStrings, pCaseSensitive)
		return NOT This.ContainsEachCS(paStrings, :CaseSensitive = TRUE)

		def ContainsNoOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsNoOneCS(paStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNoOne(paStrings)
		return This.ContainsNoOneCS(paStrings, :CaseSensitive = TRUE)

		def ContainsNoOneOfThese(paStrings, pCaseSensitive)
			return This.ContainsNoOne(paStrings)

	  #--------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS BOTH GIVEN STRINGS    #
	#--------------------------------------------------------#

	def ContainsBothCS(pcStr1, pcStr2, pCaseSensitive)
		return This.ContainsEachCS( [ pcStr1, pcStr2 ], pCaseSensitive )

	#-- WITHOUT CASESENSITIVITY

	def ContainsBoth(pcStr1, pcStr2, pCaseSensitive)
		return This.ContainsBoth(pcStr1, pcStr2)
	
	  #--------------------------------------------------------------------#
	 #    CHECKING IF EACH STRING OF THE LIST EXISTS In THE GIVEN LIST    #
	#--------------------------------------------------------------------#

	def EachStringExistsInCS(paList, pCaseSensitive)
		if NOT isList(paList)
			stzRaise("Incorrect param type! paList must be a list.")
		ok

		bResult = FALSE
		
		if Q(paList).IsListOfStrings(paList)
			bResult = StzListOfStringsQ(paList).ContainsEachCS(This.Content(), pCaseSensitive)

		else
			bResult = StzListQ(paList).ContainsEach(This.Content())
		ok

		result bResult

		def EachStringItemExistsInCS(paList, pCaseSensitive)
			return This.EachStringExistsIn(paList)

	#-- WITHOUT CASESENSITIVITY

	def EachStringExistsIn(paList)
		return This.EachStringExistsInCS(paList, :CaseSensitive = TRUE)

		def EachStringItemExistsIn(paList)
			return This.EachStringExistsIn(paList)

	  #------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS ALL THE GIVEN STRINGS     #
	#------------------------------------------------------------#

	def ContainsManyCS(paStrings, pCaseSensitive)
		
		if IsNotList(paStrings)
			stzRaise("Incorrect param type! paStrings must be a list.")
		ok

		bResult = TRUE

		for str in paStrings
			if This.ContainsNoCS(str, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		end

		return bResult

		def IsMadeOfCS(paStrings, pCaseSensitive)
			return This.ContainsManyCS(paStrings, pCaseSensitive)

		#--

		def IsMadeOfTheseCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def IsMadeOfTheseStringsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def IsMadeOfTheseStringItemsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)
		#--

		def ContainsAllTheseCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def ContainsAllTheseStringsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def ContainsAllTheseStringItemsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		#--

		def ContainsAllOfTheseCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def ContainsAllOfTheseStringsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		def ContainsAllOfTheseStringItemsCS(paStrings, pCaseSensitive)
			return ContainsManyCS(paStrings, pCaseSensitive)

		
	#-- WITHOUT CASESENSITIVITY

	def ContainsMany(paStrings)
		return This.ContainsManyCS(paStrings, :CaseSensitive = TRUE)

		def IsMadeOf(paStrings)
			return This.ContainsMany(paStrings)

		#--

		def IsMadeOfThese(paStrings)
			return This.ContainsMany(paStrings)

		def IsMadeOfTheseStrings(paStrings)
			return This.ContainsMany(paStrings)

		def IsMadeOfTheseStringItems(paStrings)
			return This.ContainsMany(paStrings)
		#--

		def ContainsAllThese(paStrings)
			return This.ContainsMany(paStrings)

		def ContainsAllTheseStrings(paStrings)
			return This.ContainsMany(paStrings)

		def ContainsAllTheseStringItems(paStrings)
			return This.ContainsMany(paStrings)

		#--

		def ContainsAllOfThese(paStrings)
			return This.ContainsMany(paStrings)

		def ContainsAllOfTheseStrings(paStrings)
			return This.ContainsMany(paStrings)

		def ContainsAllOfTheseStringItems(paStrings)
			return This.ContainsMany(paStrings)

	  #----------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS SOME OF THE GIVEN STRINGS     #
	#----------------------------------------------------------------#

	def ContainsSomeCS(paStrings, pCaseSensitive)

		bResult = FALSE

		for str in paStrings
			if This.ContainsCS(str, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def IsMadeOfSomeCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		#--

		def IsMadeOfSomeOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def IsMadeOfSomeOfTheseStringsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def IsMadeOfSomeOfTheseStringItemsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		#--

		def IsMadeOfOneOrMoreOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def IsMadeOfOneOrMoreOfTheseStringsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def IsMadeOfOneOrMoreOfTheseStringItemsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		#--

		def ContainsAtLeastOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def ContainsAtLeastOneOfTheseStringsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		def ContainsAtLeastOneOfTheseStringItemsCS(paStrings, pCaseSensitive)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsSome(paStrings)
		return This.ContainsSomeCS(paStrings, :CaseSensitive = TRUE)

		def IsMadeOfSome(paStrings)
			return This.ContainsSomeCS(paStrings, pCaseSensitive)

		#--

		def IsMadeOfSomeOfThese(paStrings)
			return This.ContainsSome(paStrings)

		def IsMadeOfSomeOfTheseStrings(paStrings)
			return This.ContainsSome(paStrings)

		def IsMadeOfSomeOfTheseStringItems(paStrings)
			return ThisContainsSome(paStrings)

		#--

		def IsMadeOfOneOrMoreOfThese(paStrings)
			return This.ContainsSome(paStrings)

		def IsMadeOfOneOrMoreOfTheseStrings(paStrings)
			return This.ContainsSome(paStrings)

		def IsMadeOfOneOrMoreOfTheseStringItems(paStrings)
			return This.ContainsSome(paStrings)

		#--

		def ContainsAtLeastOneOfThese(paStrings)
			return This.ContainsSome(paStrings)

		def ContainsAtLeastOneOfTheseStrings(paStrings)
			return This.ContainsSome(paStrings)

		def ContainsAtLeastOneOfTheseStringItems(paStrings)
			return This.ContainsSome(paStrings)

	  #-------------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS ANY ONE OF THE GIVEN STRINGS     #
	#-------------------------------------------------------------------#

	def ContainsAnyCS(paStrings, pCaseSensitive)
		/*
		Example:

		o1 = new stzList([ :monday, :monday, :monday ])
		? o1.ContainsAny([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
		
		*/

		bResult = FALSE

		for str in paStrings
			if This.NumberOfOccurrenceCS(str) = This.NumberOfStrings()
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsAnyCS(paStrings, pCaseSensitive)

		def ContainsAnyOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsAnyCS(paStrings, pCaseSensitive)

		def IsMadeOfOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsAnyCS(paStrings, pCaseSensitive)

		def ContainsOneCS(paStrings, pCaseSensitive)
			return This.ContainsAnyCS(paStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsAny(paStrings)
		return This.ContainsAnyCS(paStrings, :CaseSensitive = TRUE)

		def ContainsOneOfThese(paStrings)
			return This.ContainsAny(paStrings)

		def ContainsAnyOneOfThese(paStrings)
			return This.ContainsAny(paStrings)

		def IsMadeOfOneOfThese(paStrings)
			return This.ContainsAny(paStrings)

		def ContainsOne(paStrings)
			return This.ContainsAny(paStrings)

	  #----------------------------------------------------------------#
	 #    CHECKING IF THE LIST CONTAINS SOME OF THE GIVEN STRINGS     #
	#----------------------------------------------------------------#

	def ContainsOnlyOneCS(paStrings, pCaseSensitive)
		bResult = FALSE
		for item in paItems
			if This.IsMadeOfStringCS(str, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next
		return bResult

		def ContainsOnlyOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

		def IsMadeOfOnlyOneOfTheseCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

		def ContainsAStringFromCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

		def ContainsAStringFromTheseCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

		def ContainsAStringItemFromCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

		def ContainsAStringItemFromTheseCS(paStrings, pCaseSensitive)
			return This.ContainsOnlyOneCS(paStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsOnlyOne(paStrings)
		return This.ContainsOnlyOneCS(paStrings, :CaseSensitive = TRUE)

		def ContainsOnlyOneOfThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def IsMadeOfOnlyOneOfThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

		#--

		def ContainsAStringFrom(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsAStringFromThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsAStringItemFrom(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsAStringItemFromThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

		#--

		def ContainsOneStringFrom(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsOneStringFromThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsOneStringItemFrom(paStrings)
			return This.ContainsOnlyOne(paStrings)

		def ContainsOneStringItemFromThese(paStrings)
			return This.ContainsOnlyOne(paStrings)

	  #--------------------------------------------------------#
	 #    FINDING STRING-ITEMS VERIYING A GIVEN CONDITION     #
	#--------------------------------------------------------#

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

		def StringsPositionsW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def PositionsOfStringsW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def StringsPositionsWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def PositionsOfStringsWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def StringItemsPositionsW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def PositionsOfStringItemsW(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def StringItemsPositionsWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		def PositionsOfStringItemsWhere(pcCondition)
			return This.FindStringItemsW(pcCondition)

		#>

	  #-----------------------------------------------------------------------------#
	 #  FINDING NEXT NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #           #
	#-----------------------------------------------------------------------------#

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
	
		def NextNthStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def NextNthStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def NextNthPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
	
		def NextNthOccurrencePositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextOccurrencePositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def NextNthOccurrenceOfStringItemPosistionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextOccurrenceOfStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		def NextNthOccurrenceOfStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextOccurrenceOfStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def NextNthOccurrenceOfThisStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextOccurrenceOfThisStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def NextNthOccurrenceOfThisStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthNextOccurrenceOfThisStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		#>

	#--- WITHOUT CASESENSITIVITY

	def FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNextNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNthNextOccurrenceOfStringItem(n, pcStrItem, pnStartingAt, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNthNextOccurrenceOfString(n, pcStrItem, pnStartingAt, pnStartingAt)
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
	
		def NextNthStringItemPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def NextNthStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNth(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNext(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def NextNthPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def NextNthOccurrencePositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextOccurrencePositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def NextNthOccurrenceOfStringItemPosistions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextOccurrenceOfStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		def NextNthOccurrenceOfStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextOccurrenceOfStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def NextNthOccurrenceOfThisStringItemPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextOccurrenceOfThisStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfNextNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthNextOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def NextNthOccurrenceOfThisStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthNextOccurrenceOfThisStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		#>

	  #-------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------#

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
	
		def NextStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def NextStringPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfNextOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrencePositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrenceOfStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextOccurrenceOfStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrenceOfStringPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfNextOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrenceOfThisStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNextOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrenceOfThisStringPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
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
	
		def NextStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def NextStringPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNext(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfNextOccurrence(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def NextOccurrencePositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def NextOccurrenceOfStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextOccurrenceOfString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def NextOccurrenceOfStringPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		def PositionsOfNextOccurrenceOfThisStringItem(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def NextOccurrenceOfThisStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfNextOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def NextOccurrenceOfThisStringPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem, pnStartingAt)
		
		#>

	  #---------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------#

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

		def PreviousNthStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PreviousNthStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousNthOccurrencePositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousOccurrencePositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousNthOccurrenceOfStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousOccurrenceOfStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousNthOccurrenceOfStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousOccurrenceOfStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousNthOccurrenceOfThisStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousOccurrenceOfThisStringItemPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousNthOccurrenceOfThisStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

			def NthPreviousOccurrenceOfThisStringPositionsCS(n, pcStrItem, pnStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthPreviousOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindNthPreviousOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindPreviousNth(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPrevious(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def FindPreviousNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPreviousOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindPreviousNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPreviousStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindPreviousNthString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPreviousString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def FindPreviousNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def FindNthPreviousOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousNthStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousNthStringItemPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

			def NthPreviousStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousNthString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PreviousNthStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

			def NthPreviousStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousNth(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPrevious(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfPreviousNthOccurrence(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousOccurrence(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PreviousNthOccurrencePositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthPreviousOccurrencePositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PreviousNthOccurrenceOfStringItemPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthPreviousOccurrenceOfStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfPreviousNthOccurrenceOfString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousOccurrenceOfString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PreviousNthOccurrenceOfStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthPreviousOccurrenceOfStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PreviousNthOccurrenceOfThisStringItemPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthPreviousOccurrenceOfThisStringItemPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PositionsOfPreviousNthOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def PositionsOfNthPreviousOccurrenceOfThisString(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

		def PreviousNthOccurrenceOfThisStringPositions(n, pcStrItem, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)

			def NthPreviousOccurrenceOfThisStringPositions(n, pcStrItem, pnStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pnStartingAt)
		
		#>

	  #-----------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------#

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
	
		def PreviousStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousStringPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrencePositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrenceOfStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfStringCS(pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrenceOfStringPositionsCS(pcStrItem, pnStartingAt, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfThisStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrenceOfThisStringItemPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfThisStringCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrenceOfThisStringPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pnStartingAt, pCaseSensitive)
	
		#>

	#--- WITHOUT CASESENSITIVITY

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
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def FindPreviousOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousStringItemC(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PreviousStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousStringPositions(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPrevious(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousOccurrence(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousOccurrencePositions(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousOccurrenceOfStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousOccurrenceOfString(pcStrItem, pnStartingAt, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousOccurrenceOfStringPositions(pcStrItem, pnStartingAt, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)
	
		def PositionsOfPreviousOccurrenceOfThisStringItem(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousOccurrenceOfThisStringItemPositions(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PositionsOfPreviousOccurrenceOfThisString(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem, pnStartingAt)

		def PreviousOccurrenceOfThisStringPositions(pcStrItem, pnStartingAt)
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

		def PositionsOfNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def NextOccurrencesPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
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

		def PositionsOfNextOccurrences(pcStrItem, pnStartingAt)
			return This.FindNextOccurrences(pcStrItem, pnStartingAt)

		def NextOccurrencesPositions(pcStrItem, pnStartingAt)
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

		def PositionsOfPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

		def PreviousOccurrencesPositionsCS(pcStrItem, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive)

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

		def PositionsOfPreviousOccurrences(pcStrItem, pnStartingAt)
			return This.FindPreviousOccurrences(pcStrItem, pnStartingAt)

		def PreviousOccurrencesPositions(pcStrItem, pnStartingAt)
			return This.FindNextOccurrences(pcStrItem, pnStartingAt)

		#>

	  #=================================================================#
	 #   NUMBER OF OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS    #
	#=================================================================#

	def NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "ring php", "ring php ring", "ring" ])
		? o1.NumberOfOccurrenceOfSubString("ring")
		#--> 4

		*/

		anPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)
		#--> [ [ 1, [ 1 ] ], [ 3, [ 1, 10 ] ] ]
		#           --v--         ----v----
		#             1               2
		
		nResult = 0

		for aList in anPositions
			nResult += len(aList[2])
		next

		return nResult

		def NumberOfOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubString(pcSubStr)
		return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfSubString(pcSubStr)
			return This.NumberOfOccurrenceOfSubString(pcSubStr)

	  #----------------------------------------------------#
	 #   NUMBER OF OCCURRENCE OF A SUBSTRING -- EXTENDED  #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfSubStringXTCS(pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])
		? o1.NumberOfOccurrenceOfSubStringXT("ring")
		#--> [ [ 1, 1 ], [ 3, 2 ] ]

		*/

		anPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)
		#--> [ [ 1, [ 1 ] ], [ 3, [ 1, 10 ] ] ]
		#           --v--         ----v----
		#             1               2
		
		aResult = []

		for aList in anPositions
			aResult + [ aList[1], len(aList[2]) ]
		next

		return aResult

		def NumberOfOccurrencesOfSubStringXTCS(pcSubStr, pCaseSensitive)
			return This. NumberOfOccurrenceOfSubStringXTCS(pcSubStr, pCaseSensitive)

		#-- ..XTCS() or CSXT(): both will work ;)

		def NumberOfOccurrenceOfSubStringCSXT(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubStringXTCS(pcSubStr, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringCSXT(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubStringXTCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubStringXT(pcSubStr)
		return This.NumberOfOccurrenceOfSubStringXTCS(pcSubStr, :CaseSensitive = TRUe)

		def NumberOfOccurrencesOfSubStringXT(pcSubStr)
			return This.NumberOfOccurrenceOfSubStringXT(pcSubStr)

	  #-------------------------------------------------------------------#
	 #   NUMBER OF OCCURRENCE OF MANY SUBSTRINGS IN THE LIST OF STRINGS  #
	#-------------------------------------------------------------------#

	def NumberOfOccurrenceOfManySubStringsCS(pacSubStrings, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___",
			"___ ring ___ ring",
			"___ ruby ___ ring",
			"___ ring ___ ruby ___ ring"
		])

		? o1.NumberOfOccurrenceOfManySubStrings([ "ring", "ruby", "python" ])
		#--> [ 6, 2, 0 ]

		*/

		anResult = []

		for cSubStr in pacSubStrings
			anResult + This.NumberOfOccurrenceOfSubStringCS(cSubStr, pCaseSensitive)
		next

		return anResult

		def NumberOfOccurrencesOfManySubStringsCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCS(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringsCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCS(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringsCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCS(pacSubStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManySubStrings(pacSubStrings)
		return This.NumberOfOccurrenceOfManySubStringsCS(pacSubStrings, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfManySubStrings(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStrings(pacSubStrings)

		def NumberOfOccurrenceOfSubStrings(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStrings(pacSubStrings)

		def NumberOfOccurrencesOfSubStrings(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStrings(pacSubStrings)

	  #---------------------------------------------------------#
	 #   NUMBER OF OCCURRENCE OF MANY SUBSTRINGS -- EXTENDED   #
	#---------------------------------------------------------#

	def NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___",
			"___ ring ___ ring",
			"___ ruby ___ ring",
			"___ ring ___ ruby ___ ring"
		])

		? o1.NumberOfOccurrenceOfManySubStringsXT([ "ring", "ruby", "python" ])
		#--> [
		#	[ [ 1, 1], [2, 2], [3, 1], [4, 2] ], 	#<<< Occurrence of "ring"
		#	[ [ 3, 1 ], [ 4, 1 ] ], 				#<<< Occurrences of "ruby"
		#	[  ] 					#<<< No occurrences at all for "pyhthon"
		#   ]
		*/

		anResult = []

		for cSubStr in pacSubStrings
			anResult + This.NumberOfOccurrenceOfSubStringXTCS(cSubStr, pCaseSensitive)
		next

		return anResult

		def NumberOfOccurrencesOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringsCSXT(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringsCSXT(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		#-- ...CSXT or ...XTCS, no problem at all ;)

		def NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrencesOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)
		return This.NumberOfOccurrenceOfManySubStringsCSXT(pacSubStrings, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfManySubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

		def NumberOfOccurrenceOfSubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

		def NumberOfOccurrencesOfSubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

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
	
		? @@( o1.FindSubstringCS("name") )
		#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]
		# "name" is found in string 1 at position 13, and
		# in string 2 at positions 6 and 18.

		*/

		aResult = []
		
		i = 0
		for str in This.ListOfStrings()
			i++
			
			anPos = StzStringQ(str).FindAllCS(pcSubStr, pCaseSensitive)
			if len(anPos) > 0
				aResult + [ i, anPos ]
			ok

		next

		return aResult

		#< @FunctionAlternativeForms

		def FindAllSubstringsCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		def FindAllOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubstringCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		def SubstringPositionsCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		def AllPositionsOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		def AllSubstringPositionsCS(pcSubStr, pCaseSensitive)
			return This.FindSubStringCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubString(pcSubStr)
		return This.FindSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllSubstrings(pcSubStr)
			return This.FindSubString(pcSubStr)

		def FindAllOccurrencesOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def PositionsOfSubstring(pcSubStr)
			return This.FindSubString(pcSubStr)

		def SubstringPositions(pcSubStr)
			return This.FindSubString(pcSubStr)

		def AllPositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def AllSubstringPositions(pcSubStr)
			return This.FindSubString(pcSubStr)

		#>

	  #----------------------------------------------------------#
	 #  FINDING A SUBSTRING IN THE LIST OF STRINGS -- EXTENDED  #
	#----------------------------------------------------------#

	def FindSubStringXTCS(pcSubStr, pCaseSensitive)
		/* RATIONALE

		Like FindSubString(), this function returns the positions of
		a given substring in the list of strings, but expands the result.

		Hence, if the first returns [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ] for
		example (see sample in the FindSubStringCS() function above),

		then FindSubStringCSXT() returns the same information but in a
		slightly different form:
		[ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

		This makes it more practical to iterate over the positions and
		do whatever operation needed on them. See an example for using
		this in the ReplaceSubStringByManyCS().

		*/

		aPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		aResult = []
		i = 0

		for aList in aPositions
			
			for nPos in aList[2]
				i++
				aResult + [ aList[1], nPos ]	
			next
			
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringXTCSQ(pcSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringXTCS(pcSubStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeForm

		def FindSubStringCSXT(pcSubStr, pCaseSensitive)
			return This.FindSubStringXTCS(pcSubStr, pCaseSensitive)

			def FindSubStringCSXTQ(pcSubStr, pCaseSensitive)
				return new stzList( This.FindSubStringCSXT(pcSubStr, pCaseSensitive) )

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringXT(pcSubStr)
		return This.FindSubStringXTCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSubStringXTQ(pcSubStr)
			return new stzList( This.FindSubStringXT(pcSubStr) )

	  #============================================================================#
	 #   FINDING THE POSITIONS OF A GIVEN SUBSTRING IN THE STRING AT POSITION N   #
	#============================================================================#

	def FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive)
		anResult = This.StringAtPositionNQ(n).FindCS(pcSubStr, pCaseSensitive)
		return anResult

		#< @FunctionFluentForm

		def FindInStringNSubStringCSQ(n, pcSubStr, pCaseSensitive)
			return This.FindInStringNSubStringCSQR(n, pcSubStr, pCaseSensitive, :stzList)

		def FindInStringNSubStringCSQR(n, pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindSubStringInStringAtPositionNCS(n, pcSubStr, pCaseSensitive)
			return This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindSubStringInStringAtPositionNCSQ(n, pcSubStr, pCaseSensitive)
				return This.FindSubStringInStringAtPositionNCSQR(n, pcSubStr, pCaseSensitive, :stzList)

			def FindSubStringInStringAtPositionNCSQR(n, pcSubStr, pCaseSensitive, pcReturnType)
				return This.FindInStringNSubStringCSQR(n, pcSubStr, pCaseSensitive, pcReturnType)

		def FindSubStringInStringAtPosotionCS(n, pcSubStr, pCaseSensitive)
			return This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindSubStringInStringAtPosotionCSQ(n, pcSubStr, pCaseSensitive)
				return This.FindSubStringInStringAtPositionCSQR(n, pcSubStr, pCaseSensitive, :stzList)

			def FindSubStringInStringAtPositionCSQR(n, pcSubStr, pCaseSensitive, pcReturnType)
				return This.FindSubStringAtPositionNCSQR(n, pcSubStr, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInStringNSubString(n, pcSubStr)
		return This.FindInStringNSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindInStringNSubStringQ(n, pcSubStr)
			return This.FindInStringNSubStringQR(n, pcSubStr, :stzList)

		def FindInStringNSubStringQR(n, pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindInStringNSubString(n, pcSubStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindInStringNSubString(n, pcSubStr) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindSubStringInStringAtPositionN(n, pcSubStr)
			return This.FindInStringNSubString(n, pcSubStr)

			def FindSubStringInStringAtPositionNQ(n, pcSubStr)
				return This.FindSubStringInStringAtPositionNQR(n, pcSubStr, :stzList)

			def FindSubStringInStringAtPositionNQR(n, pcSubStr, pcReturnType)
				return This.FindSubStringAtPositionNQR(n, pcSubStr, pcReturnType)

		def FindSubStringInStringAtPosition(n, pcSubStr)
			return This.FindInStringNSubString(n, pcSubStr)

			def FindSubStringInStringAtPosotionQ(n, pcSubStr)
				return This.FindInStringNSubStringQR(n, pcSubStr, :stzList)

			def FindSubStringInStringAtPositionQR(n, pcSubStr, pcReturnType)
				return This.FFindInStringNSubStringQR(n, pcSubStr, pcReturnType)

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

		? o1.FindNthOccurrenceOfSubString(2, "name")
		#--> [ 3, 6 ]
		# The substring "name" is found in string 2, at position 6

		REMINDER

		? o1.FindSubStringXT("name")
		#--> [
		#	[ 1, 13 ], [ 3, 6 ], [ 3, 18 ], [ 6, 18 ]
		#    ]

		*/

		# Checking param correctness

		if isString(n)
			if Q(n).IsOneOfThese([ :First, :FirstOccurrence ]) 
				n = 1

			but Q(n).IsOneOfThese([ :Last, :LastOccurrence ])
				n = This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		anResult = This.FindSubStringXTCS(pcSubStr, pCaseSensitive)[n]

		return anResult

		def FindNthSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def FindNthOccurrenceOfThisSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionOfNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionOfNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionOfNthOccurrenceOfThisSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceOfSubString(n, pcSubStr)
		return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindNthSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def FindNthOccurrenceOfThisSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def PositionOfNthOccurrenceOfSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSng(n, pcSubStr)

		def PositionOfNthOccurrence(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def PositionOfNthOccurrenceOfThisSubString(n, pcSubStr)
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

		def PositionOfFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def PositionOfFirstSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def PositionOfFirstOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstOccurrenceOfSubString(pcSubStr)
		return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def FindFirstOccurrenceOfThisSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def PositionOfFirstOccurrenceOfSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def PositionOfFirstSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def PositionOfFirstOccurrenceOfThisSubString(pcSubStr)
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

		def PositionOfLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def PositionOfLastSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def PositionOfLastOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)


	#-- WITHOUT CASESENSITIVE

	def FindLastOccurrenceOfSubString(pcSubStr)
		return This.FindLastOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def FindLastOccurrenceOfThisSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def PositionOfLastOccurrenceOfSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def PositionOfLastSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def PositionOfLastOccurrenceOfThisSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

	  #------------------------------------------------#
	 #   FINDING MANY SUBSTRINGS AT THE SAME TIME     #
	#------------------------------------------------#

	def FindSubStringsCS(pacSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		#-->
		#  [
		#	# "name" is found here
		#	[
		#		[ 1, [ 13 ] ], [ 3, [ 6, 18 ] ]
		#	],
		#
		#	# and "mabrooka" is found here
		#	[
		#		[ 2, [ 1 ] ], [ 6, [ 1 ] ]
		#	]
		# ]

		*/

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			stzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		aResult = []

		for cSubStr in pacSubStr
			aResult + This.FindSubStringCS(cSubStr, pCaseSensitive)
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringsCSQ(pacSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringsCS(pacSubStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeForms

		def FindManySubtringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

			def FindManySubtringsCSQ(pacStr, pCaseSensitive)
				return new stzList( This.FindManySubtringsCS(pacStr, pCaseSensitive) )

		def FindTheseSubStringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

			def FindTheseSubStringsCSQ(pacStr, pCaseSensitive)
				return new stzList( This.FindTheseSubStringsCS(pacStr, pCaseSensitive) )

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStrings(pacStr)
		return This.FindSubStringsCS(pacStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindSubStringsQ(pacStr)
			return new stzList( This.FindsubStrings(pacStr) )

		#>

		#< @FunctionAlternativeForms

		def FindManySubStrings(pacStr)
			return This.FindSubStrings(pacStr)

			def FindManySubStringsQ(pacStr)
				return new stzList( This.FindSubStrings(pacStr) )

		def FindTheseSubStrings(pacStr)
			return This.FindSubStrings(pacStr)

			def FindTheseSubStringsQ(pacStr)
				return new stzList( This.FindTheseSubStrings(pacStr) )

		#>

	  #-----------------------------------------------------------#
	 #   FINDING MANY SUBSTRINGS AT THE SAME TIME -- EXTENDED    #
	#-----------------------------------------------------------#

	def FindSubStringsXTCS(pacSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		? o1.FindSubStringsXT([ "name", "mabrooka"])
		#-->
		#  [
		#	# "name" is found here
		#	[
		#		[ 1, 13 ], [ 3, 6 ], [ 3, 18 ]
		#	],
		#
		#	# and "mabrooka" is found here
		#	[
		#		[ 2, 1 ], [ 6, 1 ]
		#	]
		#  ]

		*/

		aResult = []

		for cSubStr in pacSubStr
			aResult + This.FindSubStringXTCS(cSubStr, pCaseSensitive)
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringsXTCSQ(pacSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringsXTCS(pacSubStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeForm

		def FindSubStringsCSXT(pacSubStr, pCaseSensitive)
			return This.FindSubStringsXTCS(pacSubStr, pCaseSensitive)

			def FindSubStringsCSXTQ(pacSubStr, pCaseSensitive)
				return new stzList( This.FindSubStringsCSXT(pacSubStr, pCaseSensitive) )

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsXT(pacSubStr)
		return This.FindSubStringsXTCS(pacSubStr, :CaseSensitive = TRUE)

		def FindSubStringsXTQ(pacSubStr)
			return new stzList( This.FindSubStringsXT(pacSubStr) )

	  #------------------------------------------------#
	 #   FINDING N FIRST OCCURRENCES OF A SUBSTRING   #
	#------------------------------------------------#

	def FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___ ring",
			"ring ___ ring ___ ring",
			"___ ring"
		])

		? o1.FindNFirstOccurrencesOfSubString(4, "ring")
		#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1], [ 2, 10 ] ]

		*/

		aResult = This.FindSubStringXTCSQ(pcSubStr, pCaseSensitive).FirstNItems(n)
		return aResult

		def FindFirstNOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNFirstOccurrencesOfSubString(n, pcSubStr)
		return This.FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindFirstNOccurrencesOfSubString(n, pcSubStr)
			return This.FindNFirstOccurrencesOfSubString(n, pcSubStr)

	  #----------------------------------------------#
	 #   FINDING GIVEN OCCURRENCES OF A SUBSTRING   #
	#----------------------------------------------#

	def FindTheseOccurrencesOfSubStringCS(panOccurrences, pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___ ring",
			"ring ___ ring ___ ring",
			"___ ring"
		])

		? o1.FindTheseOccurrencesOfSubString([1, 3, 5 ], "ring")
		#--> 

		*/

		anPositions = This.FindSubStringXTCS(pcSubStr, pCaseSensitive)

		aResult = Q(anPositions).ItemsAtPositions(panOccurrences)

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def FindTheseOccurrencesOfSubString(panOccurrences, pcSubStr)
		return This.FindTheseOccurrencesOfSubStringCS(panOccurrences, pcSubStr, :CaseSensitive = TRUE)

	  #------------------------------------------------#
	 #   FINDING N LAST OCCURRENCES OF A SUBSTRING   #
	#------------------------------------------------#

	def FindNLastOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___ ring",
			"ring ___ ring ___ ring",
			"___ ring"
		])

		? o1.FindNLastOccurrencesOfSubString(3, "ring")
		#--> [ [ 2, 10 ], [ 2, 19], [ 3, 5 ] ]

		*/

		aResult = This.FindSubStringXTCSQ(pcSubStr, pCaseSensitive).LastNItems(n)
		return aResult

		def FindLastNOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNLastOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNLastOccurrencesOfSubString(n, pcSubStr)
		return This.FindNLastOccurrencesOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindLastNOccurrencesOfSubString(n, pcSubStr)
			return This.FindNLastOccurrencesOfSubString(n, pcSubStr)

	   #---------------------------------------------------------#
	  #      CHECKING IF EACH STRING OF THE LIST OF STRINGS     #
	 #      CONTAINS EACH ONE OF THE PROVIDED SUBSTRINGS       #
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

		def NextNthSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def NthNextSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def NthOccurrenceOfSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def NthNextOccurrenceOfSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisSubStringCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def NextNthOccurrenceOfThisSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def NthNextOccurrenceOfThisSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
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

		def NextNthSubStringPositions(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(pcSubStr)

			def NthNextSubStringPositions(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(pcSubStr)

		def PositionsOfNextNthOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

		def NthOccurrenceOfSubStringPosition(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def NthNextOccurrenceOfSubStringPositions(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

		def PositionsOfNextNthOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfThisSubString(n, pcSubStr, pnStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

		def NextNthOccurrenceOfThisSubStringPositions(n, pcSubStr, pnStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def NthNextOccurrenceOfThisSubStringPositions(n, pcSubStr, pnStartingAt)
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

		def NextSubStringPositionsCS(pcSubStr, pnStartingAt, pCaseSensitive)
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

		def NextSubStringPositions(pcSubStr, pnStartingAt)
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

		def PreviousNthSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def NthPreviousSubStringPositionsCS(n, pcSubStr, pnStartingAt, pCaseSensitive)
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

		def PreviousNthSubStringPositions(n, pcSubStr, pnStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(pcSubStr)

			def NthPreviousSubStringPositions(n, pcSubStr, pnStartingAt)
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

		def PreviousSubStringPositionsCS(pcSubStr, pnStartingAt, pCaseSensitive)
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

		def PreviousSubStringPositions(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfThisSubString(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		#>

	  #===================================================================#
	 #  CHECKING IF THE LIST CONTAINS A GIVEN SUSBTRING IN ITS STRINGS   #
	#===================================================================#

	def ContainsSubstringCS(pcSubStr, pCaseSensitive)
		if This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	  #------------------------------------------------------------#
	 #  CHECKING IF THE LIST CONTAINS N TIMES A GIVEN SUSBTRING   #
	#------------------------------------------------------------#

	def ContainsNTimesSubStringCS(n, pcSubStr, pCaseSensitive)
		nOccurr = This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return nOccurr = n

	#-- WITHOUT CASESENSITIVITY

	def ContainsNTimesSubString(n, pcSubStr)
		return This.ContainsNTimesSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

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

 	  #-------------------------------------------------------------------#
	 #  CHECKING IF THE LIST CONTAINS A GIVEN SUSBTRING IN EACH STRING   #
	#-------------------------------------------------------------------#

	def ContainsSubStringInEachStringCS(pcStr, pCaseSensitive)
		bResult = TRUE
		for str in This.ListOfStrings()
			if NOT StzStringQ(str).ContainsCS(pcStr, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def ContainsSubStringInEachStringItemCS(pcStr, pCaseSensitive)
			return This.ContainsSubStringInEachStringCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStringInEachString(pcStr)
		return This.ContainsSubStringInEachStringCS(pcStr, :CaseSensitive = TRUE)

		def ContainsSubStringInEachStringItem(pcStr)
			return This.ContainsSubStringInEachString(pcStr)
	
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

		def StringItemsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def StringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

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

		def StringItemsContainingSubStringQ(pcSubStr)
			return This.StringItemsContainingSubStringQR(pcSubStr, :stzList)

		def StringItemsContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingSubString(pcSubStr) )

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
			   StringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzListOfStrings).
			   DuplicatesRemovedCS(pCaseSensitive)

		return acResult

		#< @FunctionfluentForm

		def UniqueStringItemsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def UniqueStringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

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

		def UniqueStringItemsContainingSubStringQ(pcSubStr)
			return This.UniqueStringItemsContainingSubStringQR(pcSubStr, :stzList)

		def UniqueStringItemsContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingSubString(pcSubStr) )

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

  	  #--------------------------------------------------#
	 #   STRINGS CONTAINING N TIMES A GIVEN SUBSTRING   #
	#--------------------------------------------------#

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

		acResult = This.
			   StringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzListOfStrings).
		           DuplicatesRemovedCS(pCaseSensitive)

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

	#-- WITHOUT CASESENSITIVITY

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

		#-- ..CSXT or XTCS? You can use them both ;)

		def StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)
			return This. StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)

			def StringItemsContainingNTimesTheSubstringXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive, :stzList)
	
			def StringItemsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				return This.StringItemsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)

		def StringsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)
			return This.StringsContainingNTimesTheSubstringCSXT(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesTheSubstringXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringCSXTQ(n, pcSubstr, pCaseSensitive)
	
			def StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				return This.StringsContainingNTimesTheSubstringCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)

		def StringItemsContainingNTimesXTCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesCSXT(n, pcSubStr, pCaseSensitive)

			def StringItemsContainingNTimesXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesCSXTQ(n, pcSubstr, pCaseSensitive)
		
			def StringItemsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				return This.StringItemsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)

		def StringsContainingNTimesXTCS(n, pcSubStr, pCaseSensitive)
			return This.StringsContainingNTimesCSXT(n, pcSubStr, pCaseSensitive)

			def StringsContainingNTimesXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesCSXTQ(n, pcSubstr, pCaseSensitive)
		
			def StringsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				return This.StringsContainingNTimesCSXTQR(n, pcSubstr, pCaseSensitive, pcReturn)

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

	  #=============================================#
	 #   REPLACING ALL STRINGS WITH A NEW STRING   #
	#=============================================#

	def ReplaceAllStrings(pcNewString)

		bDynamic = FALSE

		if isList(pcNewString) and Q(pcNewString).IsWithOrByNamedParamList()

			if Q(pcNewString[1]).LastChar() = "@"
				bDynamic = TRUE
			ok

			pcNewString = pcNewString[2]
			
		ok

		if NOT isString(pcNewString)
			stzRaise("Incorrect param! pcNewString must be a string.")
		ok

		if NOT bDynamic
			for i = 1 to This.NumberOfStrings()
				This.ReplaceStringAtPosition(i, pcNewString)
			next
	
		else
			
			cDynamicExpr = StzCCodeQ(pcNewString).UnifiedFor(:stzListOfStrings)

			for i = 1 to This.NumberOfStrings()

				@string = This.StringAtPosition(i)
				cCode = 'cNewStr = ' + cDynamicExpr
				eval(cCode)

				This.ReplaceStringAtPosition(i, cNewStr)
			next

		ok

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

		def ReplaceStrings(pcNewString)
			This.ReplaceAllStrings(pcNewString)

			def ReplaceStringsQ(pcNewString)
				This.ReplaceStrings(pcNewString)
				return This

		def ReplaceStringItems(pcNewString)
			This.ReplaceAllStrings(pcNewString)

			def ReplaceStringItemsQ(pcNewString)
				This.ReplaceStringItems(pcNewString)
				return This

		#>

	  #-------------------------------------------#
	 #   REPLACING ALL OCCURRENCES OF A STRING   #
	#-------------------------------------------#

	def ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)
			
		if isList(pcString) and StzListQ(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		if NOT isString(pcString)
			stzRaise("Incorrect param! pcString must be a string.")
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

	  #-------------------------------------------------------------------#
	 #  REPLACING MANY STRINGS AT THE SAME TIME BY A GIVEN OTHER STRING  #
	#-------------------------------------------------------------------#

	def ReplaceManyStringsCS(pacStrings, pcNewString, pCaseSensitive)

		for str in pacStrings
			This.ReplaceAllOccurrencesCS(str, pcNewString, pCaseSensitive)
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

	  #------------------------------------------------#
	 #  REPLACING MANY STRINGS BY MANY OTHER STRINGS  #
	#------------------------------------------------#

	def ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		if NOT ( isList(pacStrings) and Q(pacStrings).IsListOfStrings() )
			stzRaise("Incorrect param! pacStrings must be a list of strings.")
		ok

		if isList(pacNewStrings) and Q(pacNewStrings).IsWithOrByNamedParamList()
			pacNewStrings = pacNewStrings[2]
		ok

		if NOT Q(pacNewStrings).IsListOfStrings()
			stzRaise("Incorrect param! pacNewStrings must be a list of strings.")
		ok

		i = 0
		for cStr in pacStrings
			i++
			if i <= len(pacNewStrings)
				cNewStr = pacNewStrings[i]
				This.ReplaceStringCS(cStr, cNewStr, pCaseSensitive)
			ok
		next

		#< @FunctionFluentForm

		def ReplaceStringsByManyCSQ(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		#>

	def StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
		acResult = This.Copy().
				ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive).
				Contnet()

		return acResult

		def StringItemsReplacedByManyCS(acStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceStringsByMany(pacStrings, pacNewStrings)
		This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, :CaseSensitivity = TRUE)

		#< @FunctionFluentForm

		def ReplaceStringsByManyQ(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsByMany(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)

		#>

	def StringsReplacedByMany(pacStrings, pacNewStrings)
		acResult = This.Copy().
				ReplaceStringsByMany(pacStrings, pacNewStrings).
				Contnet()

		return acResult

		def StringItemsReplacedByMany(acStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

	  #------------------------------------------------------------#
	 #  REPLACING MANY STRINGS BY MANY OTHER STRINGS -- EXTENDED  #
	#------------------------------------------------------------#

	def ReplaceStringsByManyCSXT(pacStrings, pacNewStrings, pCaseSensitive)

		if NOT ( isList(pacStrings) and Q(pacStrings).IsListOfStrings() )
			stzRaise("Incorrect param! pacStrings must be a list of strings.")
		ok

		if isList(pacNewStrings) and Q(pacNewStrings).IsWithOrByNamedParamList()
			pacNewStrings = pacNewStrings[2]
		ok

		if NOT Q(pacNewStrings).IsListOfStrings()
			stzRaise("Incorrect param! pacNewStrings must be a list of strings.")
		ok

		i = 0
		for cStr in pacStrings
			i++
			if i > len(pacNewStrings)
				i = 1
			ok

			cNewStr = pacNewStrings[i]
			This.ReplaceStringCS(cStr, cNewStr, pCaseSensitive)

		next

		#< @FunctionFluentForm

		def ReplaceStringsByManyCSXTQ(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCSXT(pacStrings, pacNewStrings, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsByManyCSXT(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCSXT(pacStrings, pacNewStrings, pCaseSensitive)

	def StringsReplacedByManyCSXT(pacStrings, pacNewStrings, pCaseSensitive)
		acResult = This.Copy().
				This.
				ReplaceStringsByManyCSXTQ(pacStrings, pacNewStrings, pCaseSensitive).
				Content()

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceStringsByManyXT(pacStrings, pacNewStrings)
		This.ReplaceStringsByManyCSXT(pacStrings, pacNewStrings, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceStringsByManyXTQ(pacStrings, pacNewStrings)
			This.ReplaceStringsByManyXT(pacStrings, pacNewStrings)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsByManyXT(pacStrings, pacNewStrings)
			This.ReplaceStringsByManyXT(pacStrings, pacNewStrings)

		#>

	def StringsReplacedByManyXT(pacStrings, pacNewStrings)
		acResult = This.Copy().
				This.
				ReplaceStringsByManyXTQ(pacStrings, pacNewStrings).
				Content()

		return acResult

		def StringItemsReplacedByManyXT(pacStrings, pacNewStrings)
			return This.StringsReplacedByManyXT(pacStrings, pacNewStrings)

	  #----------------------------------------------#
	 #    REPLACING A STRING-ITEM BY MANY OTHERS    #
	#----------------------------------------------#

	def ReplaceByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

		/* EXAMPLE

		o1 = new stzListOfStrings([ "ring", "php", "ruby", "ring", "python", "ring" ])
		o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
	
		? o1.Content() #--> [ "♥", "php", "ruby", "♥♥", "python", "♥♥♥" ]

		*/

		if isList(pacNewSubStringItems) and Q(pacNewSubStringItems).IsWithOrByNamedParamList()
			pacNewSubStringItems = pacNewSubStringItems[2]
		ok

		if NOT Q(pacNewSubStringItems).IsListOfStrings()
			stzRaise("Incorrect param! pacNewSubStringItems must be a list of strings.")
		ok

		anPositions = This.FindCS(pcStrItem, pCaseSensitive)
		nMin = Min( len(anPositions), len(pacNewSubStringItems) )

		for i = nMin to 1 step -1
			n = anPositions[i]
			cNewStrItem = pacNewSubStringItems[i]
			This.ReplaceStringItemAtPositionN(n, cNewStrItem)
		next

		#< @FunctionFluentForm

		def ReplaceByManyCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringItemByManyCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		def ReplaceStringByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringByManyCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		#>

	def StringReplacedByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
		acResult = This.Copy().ReplaceByManyCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive).Content()
		return acResult

		def StringItemRepacedByManyCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This.StringReplacedCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceByMany(pcStrItem, pacNewSubStringItems)
		This.ReplaceByManyCS(pcStrItem, pacNewSubStringItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceByManyQ(pcStrItem, pacNewSubStringItems)
			This.ReplaceByMany(pcStrItem, pacNewSubStringItems)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByMany(pcStrItem, pacNewSubStringItems)
			This.ReplaceByMany(pcStrItem, pacNewSubStringItems)

			def ReplaceStringItemByManyQ(pcStrItem, pacNewSubStringItems)
				This.ReplaceStringItemByMany(pcStrItem, pacNewSubStringItems)
				retutn This

		def ReplaceStringByMany(pcStrItem, pacNewSubStringItems)
			This.ReplaceByMany(pcStrItem, pacNewSubStringItems)

			def ReplaceStringByManyQ(pcStrItem, pacNewSubStringItems)
				This.ReplaceStringItemByMany(pcStrItem, pacNewSubStringItems)
				retutn This

		#>

	def StringReplacedByMany(pcStrItem, pacNewSubStringItems)
		acResult = This.Copy().ReplaceByManyQ(pcStrItem, pacNewSubStringItems).Content()
		return acResult

		def StringItemRepacedByMany(pcStrItem, pacNewSubStringItems)
			return This.StringReplaced(pcStrItem, pacNewSubStringItems)

	  #-------------------------------------------------------#
	 #  REPLACING A STRING-ITEM BY MANY OTHERS -- EXTENDED   #
	#-------------------------------------------------------#

	def ReplaceByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)

		/* EXAMPLE

		o1 = new stzListOfStrings([ "ring", "php", "ring", "ruby", "ring", "python", "ring" ])
		o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
	
		? o1.Content() #--> [ "#1", "php", "#2", "ruby", "#1", "python", "#2" ]

		*/

		if isList(pacNewSubStringItems) and Q(pacNewSubStringItems).IsWithOrByNamedParamList()
			pacNewSubStringItems = pacNewSubStringItems[2]
		ok

		if NOT Q(pacNewSubStringItems).IsListOfStrings()
			stzRaise("Incorrect param! pacNewSubStringItems must be a list of strings.")
		ok

		anPositions = This.FindAllCS(pcStrItem, pCaseSensitive)

		i = 0
		for nPos in anPositions
			i++
			if i > len(pacNewSubStringItems)
				i = 1
			ok

			This.ReplaceStringAtPosition(nPos, pacNewSubStringItems[i])
			
		next

		#< @FunctionFluentForm

		def ReplaceByManyCSXTQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringItemByManyCSXTQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		def ReplaceStringByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringByManyCSXTQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		#>

	def StringReplacedByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
		acResult = This.Copy().ReplaceByManyCSXTQ(pcStrItem, pacNewSubStringItems, pCaseSensitive).Content()
		return acResult

		def StringItemRepacedByManyCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This.StringReplacedCSXT(pcStrItem, pacNewSubStringItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceByManyXT(pcStrItem, pacNewSubStringItems)
		This.ReplaceByManyCSXT(pcStrItem, pacNewSubStringItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceByManyXTQ(pcStrItem, pacNewSubStringItems)
			This.ReplaceByManyXT(pcStrItem, pacNewSubStringItems)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByManyXT(pcStrItem, pacNewSubStringItems)
			This.ReplaceByManyXT(pcStrItem, pacNewSubStringItems)

			def ReplaceStringItemByManyXTQ(pcStrItem, pacNewSubStringItems)
				This.ReplaceStringItemByManyXT(pcStrItem, pacNewSubStringItems)
				retutn This

		def ReplaceStringByManyXT(pcStrItem, pacNewSubStringItems)
			This.ReplaceByManyXT(pcStrItem, pacNewSubStringItems)

			def ReplaceStringByManyXTQ(pcStrItem, pacNewSubStringItems)
				This.ReplaceStringItemByManyXT(pcStrItem, pacNewSubStringItems)
				retutn This

		#>

	def StringReplacedByManyXT(pcStrItem, pacNewSubStringItems)
		acResult = This.Copy().ReplaceByManyXTQ(pcStrItem, pacNewSubStringItems).Content()
		return acResult

		def StringItemRepacedByManyXT(pcStrItem, pacNewSubStringItems)
			return This.StringReplacedXT(pcStrItem, pacNewSubStringItems)

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
		This.ReplaceNextOccurrencesCS(pcString, pcOtherString, pnStartingAt, :CS = TRUE)

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

	  #--------------------------------------------------------------------------------#
	 #  REPLACING PREVIOUS OCCURRENCES OF A STRING-ITEM STARTING AT A GIVEN POSITION  #                        #
	#--------------------------------------------------------------------------------#

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

	  #------------------------------------------------#
	 #   REPLACING NTH OCCURRENCE OF A STRING-ITEM    #
	#------------------------------------------------#

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

		def ReplaceNthOccurrenceCSQ(n, pcString, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)
			return This

		#< @FunctionAlternativeForms

		def ReplaceNthOccurrenceOfStringCS(n, pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthOccurrenceOfStringCSQ(n, pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceNthOccurrenceOfStringCS(n, pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceNthOccurrenceOfStringItemCS(n, pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthOccurrenceOfStringItemCSQ(n, pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceNthOccurrenceOfStringItemCS(n, pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceNthOccurrenceOfThisStringItemCS(n, pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthOccurrenceOfThisStringItemCSQ(n, pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceNthOccurrenceOfThisStringItemCS(n, pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceNthOccurrenceOfThisStringCS(n, pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthOccurrenceOfThisStringCSQ(n, pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceNthOccurrenceOfThisStringCS(n, pcStrItem, pcOtherString, pCaseSensitive)
				return This
			
		#>

	def NthOccurrenceReplacedCS(n, pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceNthOccurrenceCSQ(n, pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNthOccurrence(n, pcString, pcOtherString)
		ReplaceNthOccurrenceCS(n, pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceNthOccurrenceQ(n, pcString, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def ReplaceNthOccurrenceOfString(n, pcStrItem, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthOccurrenceOfStringQ(n, pcStrItem, pcOtherString)
				This.ReplaceNthOccurrenceOfString(n, pcStrItem, pcOtherString)
				return This

		def ReplaceNthOccurrenceOfStringItem(pcStrItem, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthOccurrenceOfStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceNthOccurrenceOfStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceNthOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthOccurrenceOfThisStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceNthOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceNthOccurrenceOfThisString(n, pcStrItem, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthOccurrenceOfThisStringQ(n, pcStrItem, pcOtherString)
				This.ReplaceNthOccurrenceOfThisString(n, pcStrItem, pcOtherString)
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

		#< @FunctionAlternativeForms

		def ReplaceFirstOccurrenceOfStringCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceFirstOccurrenceOfStringCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfStringCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceFirstOccurrenceOfStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceFirstOccurrenceOfStringItemCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceFirstOccurrenceOfThisStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceFirstOccurrenceOfThisStringItemCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfThisStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceFirstOccurrenceOfThisStringCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceFirstOccurrenceOfThisStringCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfThisStringCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This
			
		#>

	def FirstOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceFirstOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirstOccurrence(pcString, pcOtherString)
		This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceFirstOccurrenceQ(pcString, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def ReplaceFirstOccurrenceOfString(pcStrItem, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def ReplaceFirstOccurrenceOfStringQ(pcStrItem, pcOtherString)
				This.ReplaceFirstOccurrenceOfString(pcStrItem, pcOtherString)
				return This

		def ReplaceFirstOccurrenceOfStringItem(pcStrItem, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def ReplaceFirstOccurrenceOfStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceFirstOccurrenceOfStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceFirstOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def ReplaceFirstOccurrenceOfThisStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceFirstOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceFirstOccurrenceOfThisString(pcStrItem, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def ReplaceFirstOccurrenceOfThisStringQ(pcStrItem, pcOtherString)
				This.ReplaceFirstOccurrenceOfThisString(pcStrItem, pcOtherString)
				return This

		#>

	def FirstOccurrenceReplaced(pcString, pcOtherString)

		aResult  = This.Copy().
				ReplaceFirstOccurrenceQ(pcString, pcOtherString).
				Content()

		return aResult

	  #---------------------------------------------#
	 #   REPLACING LAST OCCURRENCE OF A STRING     #
	#---------------------------------------------#

	def ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
		n = This.FindLastOccurrenceCS(pcString, pCaseSensitive)

		This.ReplaceStringAtPosition(n, pcOtherString)

		def ReplaceLastOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
			return This

		#< @FunctionAlternativeForms

		def ReplaceLastOccurrenceOfStringCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceLastOccurrenceOfStringCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceLastOccurrenceOfStringCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceLastOccurrenceOfStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceLastOccurrenceOfStringItemCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceLastOccurrenceOfStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceLastOccurrenceOfThisStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceLastOccurrenceOfThisStringItemCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceLastOccurrenceOfThisStringItemCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		def ReplaceLastOccurrenceOfThisStringCS(pcStrItem, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def ReplaceLastOccurrenceOfThisStringCSQ(pcStrItem, pcOtherString, pCaseSensitive)
				This.ReplaceLastOccurrenceOfThisStringCS(pcStrItem, pcOtherString, pCaseSensitive)
				return This

		#>

	def LastOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

		aResult  = This.Copy().
				ReplaceLastOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive).
				Content()

		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLastOccurrence(pcString, pcOtherString)
		ReplaceLastOccurrenceCS(pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceLastOccurrenceQ(pcString, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def ReplaceLastOccurrenceOfString(pcStrItem, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def ReplaceLastOccurrenceOfStringQ(pcStrItem, pcOtherString)
				This.ReplaceLastOccurrenceOfString(pcStrItem, pcOtherString)
				return This

		def ReplaceLastOccurrenceOfStringItem(pcStrItem, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def ReplaceLastOccurrenceOfStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceLastOccurrenceOfStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceLastOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def ReplaceLastOccurrenceOfThisStringItemQ(pcStrItem, pcOtherString)
				This.ReplaceLastOccurrenceOfThisStringItem(pcStrItem, pcOtherString)
				return This

		def ReplaceLastOccurrenceOfThisString(pcStrItem, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def ReplaceLastOccurrenceOfThisStringQ(pcStrItem, pcOtherString)
				This.ReplaceLastOccurrenceOfThisString(pcStrItem, pcOtherString)
				return This

		#>

	def LastOccurrenceReplaced(pcString, pcOtherString)

		aResult  = This.Copy().
				ReplaceLastOccurrenceQ(pcString, pcOtherString).
				Content()

		return aResult

	  #----------------------------------------------------------------------------#
	 #   REPLACING NEXT NTH OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION   #
	#----------------------------------------------------------------------------#

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

		oSection    = This.SectionQR(pnStartingAt, This.NumberOfStrings(), :stzListOfStrings)
		anPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		anPositions = StzListOfNumbersQ(anPositions).AddToEachQ(pnStartingAt).Content()
		nPosition   = anPositions[n]

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

	  #---------------------------------------------------------------------------#
	 #  REPLACING NEXT OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------#

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

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING MANY NEXT NTH OCCURRENCES OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------------------#

	def ReplaceNextNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
			? Content() # !--> [ "A" , "B", "A", "C", "*", "D", "*" ]
		}		

		*/

		if NOT ( isList(panList) and StzListQ(panList).IsListOfNumbers() and
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList)
		       )

			stzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
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
			
		oSection = This.SectionQR(pnStartingAt, :LastString, :stzListOfStrings)

		anPositions = oSection.
			      FindAllCSQR(pcString, pCaseSensitive, :stzListOfNumbers).
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

	  #------------------------------------------------------------------------------#
	 #  REPLACING PREVIOUS NTH OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION  #
	#------------------------------------------------------------------------------#

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

	   #--------------------------------------------------------------------------#
	  #  REPLACING PREVIOUS OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------#

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

	  #---------------------------------------------------------------------------------------#
	 #     REPLACING MANY PREVIOUS NTH OCCURRENCES OF A STRING STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------------#

	def ReplacePreviousNthOccurrencesCS(panList, pcString, pcNewString, pnStartingAt, pCaseSensitive)
		/* Example

		StzListOfStringsQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplacePreviousNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 5)
			? Content() # !--> [ "A" , "B", "*", "C", "*", "D", "A" ]
		}		

		*/

		if NOT ( isList(panList) and StzListQ(panList).IsListOfNumbers() and
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList)
		       )

			stzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
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
			
		oSection = This.SectionQR(1, pnStartingAt, :stzListOfStrings)

		anPositions = oSection.FindAllCSQ(pcString, pCaseSensitive).Reversed()

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

	  #==================================#
	 #   REPLACING STRING BY POSITION   #
	#==================================#

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

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		if NOT (  Q(n).IsBetween(1, This.NumberOfStrings()) )
			stzRaise("Position out of range!")
		ok

		if isList(pcOtherStr) and Q(pcOtherStr).IsWithOrByNamedParamList()

			if Q(pcOtherStr[1]).LastChar() = "@"

				cCode = StzCCodeQ(pcOtherStr[2]).UnifiedFor(:stzListOfStrings)
				cCode = "pcOtherStr = " + cCode
	
				@string = This.StringAtPosition(n)
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

		def ReplaceStringAtPositionN(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringAtPositionNQ(n, pcOtherString)
				This.ReplaceStringAtPositionN(n, pcOtherString)
				return This

		def ReplaceStringItemAtPosition(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringItemAtPositionQ(n, pcOtherString)
				This.ReplaceStringItemAtPosition(n, pcOtherString)
				return This

		def ReplaceStringItemAtPositionN(n, pcOtherString)
			This.ReplaceStringAtPositionN(n, pcOtherString)

			def ReplaceStringItemAtPositionNQ(n, pcOtherString)
				This.ReplaceStringItemAtPositionN(n, pcOtherString)
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

		def ReplaceAtPositionN(n, pcOtherString)
			This.ReplaceStringAtPositionN(n, pcOtherString)

			def ReplaceAtPositionNQ(n, pcOtherString)
				This.ReplaceAtPositionN(n, pcOtherString)
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

		def ReplaceStringN(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringNQ(n, pcOtherString)
				This.ReplaceStringN(n, pcOtherString)
				return This

		def ReplaceStringItemN(n, pcOtherString)
			This.ReplaceStringAtPosition(n, pcOtherString)

			def ReplaceStringItemNQ(n, pcOtherString)
				This.ReplaceStringN(n, pcOtherString)
				return This

		#>
	
	def StringAtPositionNReplacedWith(n, pcOtherString)
		aResult = This.Copy().ReplaceStringAtPositionQ( n, pcOtherString ).Content()
		return aResult

		def StringItemAtPositionNReplacedWith(n, pcOtherString)
			return This.StringAtPositionNReplacedWith(n, pcOtherString)

		def NthStringReplacedWith(n, pcOtherString)
			return This.StringAtPositionNReplacedWith(n, pcOtherString)

		def StringAtPositionReplacedWith(n, pcOtherString)
			return This.StringAtPositionNReplacedWith(n, pcOtherString)

	  #-----------------------------------------#
	 #   REPLACING MANY STRINGS BY POSITION    #
	#-----------------------------------------#

	def ReplaceStringsAtPositions(panPositions, pcOtherString)

		if isList(pcOtherString) and Q(pcOtherString).IsListOfStrings() and
		   NOT Q(pcOtherString).IsWithOrByNamedParamList()

			pcOtherString = pcOtherString[2]
		ok

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )

			stzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		bDynamic = FALSE

		if isList(pcOtherString) and Q(pcOtherString).IsWithOrByNamedParamList()
			if StzStringQ(pcOtherString[1]).LastChar() = "@"
				bDynamic = TRUE
			ok
		ok

		if bDynamic
			acStrings = []
			for n in panPositions
				@string = This.StringAtPosition(n)
				cCode = 'str = ' + StzCCodeQ(pcOtherString[2]).UnifiedFor(:stzListOfStrings)
				eval(cCode)
				acStrings + str
			next

			This.ReplaceStringsAtPositions1B1(panPositions, acStrings)
		else

			anPositions = StzListQ(panPositions).SortedInDescending()
			
			for n in anPositions
				This.ReplaceStringAtPosition(n, pcOtherString)
			next
		ok
			

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
				This.ReplaceManyStringItemsAt(panPositions, pcOtherString)
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

	def StringsAtThesePositionsReplaced(panPositions, pcOtherString)
		aResult = This.Copy().ReplaceStringsAtPositionsQ(panPositions, pcOtherString).Content()
		return aResult

		def StringItemsAtThesePositionsReplaced(panPositions, pcOtherString)
			return This.StringsAtThesePositionsReplaced(panPositions, pcOtherString)

	  #----------------------------------------------------------------#
	 #  REPLACING STRINGS AT GIVEN POSITIONS BY OTHER GIVEN STRINGS   #
	#----------------------------------------------------------------#

	def ReplaceStringsByManyAtPositions(panPositions, pacOtherStrings)
		/*
		EXAMPLE
		o1 = new stzListOfStrings([ "Heart", "_", "Star", "_", "Sun", "_" ])
		o1.ReplaceStringsAtPositionsByMany([ 2, 4, 6], :With = [ "♥", "★", "🌞" ])
	
		? @@( o1.Content() ) #--> [ "Heart", "♥", "Star", "★", "Sun", "🌞" ]
		*/

		# Checking params correctness

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )

			stzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		if StzListOfNumbersQ(panPositions).Max() > This.NumberOfStrings()
			stzRaise("Incorrect value! panPositions contains at least one value out of range.")
		ok

		if NOT ( isList(pacOtherStrings) and
				( Q(pacOtherStrings).IsListOfStrings() or
			 	  Q(pacOtherStrings).IsWithOrByNamedParamList()
				)
			)

			stzRaise("Incorrect param! pacOtherStrings must be a list of strings.")
		ok

		if Q(pacOtherStrings).IsWithOrByNamedParamList()
			pacOtherStrings = pacOtherStrings[2]
		ok

		# Doing the job

		nLen = len(panPositions)
		i = 0
		for n in panPositions
			i++
			if i <= nLen
				This.ReplaceStringAtPosition(n, pacOtherStrings[i])
			ok
		next

		#< @FunctionFluentForm

		def ReplaceStringsByManyAtPositionsQ(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositions(panPositions, pacOtherStrings)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringsAtPositionsByMany(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositions(panPositions, pacOtherStrings)

			def ReplaceStringsAtPositionsByManyQ(panPositions, pacOtherStrings)
				This.ReplaceStringsAtPositionsByMany(panPositions, pacOtherStrings)
				return This

		def ReplaceStringItemsByManyAtPositions(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositions(panPositions, pacOtherStrings)

			def ReplaceStringItemsByManyAtPositionsQ(panPositions, pacOtherStrings)
				This.ReplaceStringItemsByManyAtPositions(panPositions, pacOtherStrings)
				return This
		#>

	def StringsAtPositionsReplacedByMany(panPositions, pacOtherStrings)
		acResult = This.Copy().RepalceStringsByManyAtPositionsQ(panPositions, pacOtherStrings).Content()
		return acResult

		def StringItemsAtPositionsReplacedByMany(panPositions, pacOtherStrings)
			return This.StringsAtPositionsReplacedByMany(panPositions, pacOtherStrings)

	  #---------------------------------------------------------------------------#
	 #  REPLACING STRINGS AT GIVEN POSITIONS BY OTHER GIVEN STRINGS -- EXTENDED  #
	#---------------------------------------------------------------------------#

	def ReplaceStringsByManyAtPositionsXT(panPositions, pacOtherStrings)
		/*
		EXAMPLE
		o1 = new stzListOfStrings([ "A", "_", "B", "_", "C", "_", "D" ])
		o1.ReplaceStringsAtPositionsByManyXT([ 2, 4, 6], :With = [ "#1", "#2" ])
	
		? @@( o1.Content() ) #--> [ "A", "#1", "B", "#2", "C", "#1", "D" ]		*/

		# Checking params correctness

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )

			stzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		if StzListOfNumbersQ(panPositions).Max() > This.NumberOfStrings()
			stzRaise("Incorrect value! panPositions contains at least one value out of range.")
		ok

		if NOT ( isList(pacOtherStrings) and
				( Q(pacOtherStrings).IsListOfStrings() or
			 	  Q(pacOtherStrings).IsWithOrByNamedParamList()
				)
			)

			stzRaise("Incorrect param! pacOtherStrings must be a list of strings.")
		ok

		if Q(pacOtherStrings).IsWithOrByNamedParamList()
			pacOtherStrings = pacOtherStrings[2]
		ok

		# Doing the job

		nLen = len(pacOtherStrings)
		i = 0
		for n in panPositions
			i++
			if i > nLen
				i = 1
			ok

			This.ReplaceStringAtPosition(n, pacOtherStrings[i])
		next

		#< @FunctionFluentForm

		def ReplaceStringsByManyAtPositionsXTQ(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositionsXT(panPositions, pacOtherStrings)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringsAtPositionsByManyXT(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositionsXT(panPositions, pacOtherStrings)

			def ReplaceStringsAtPositionsByManyXTQ(panPositions, pacOtherStrings)
				This.ReplaceStringsAtPositionsByManyXT(panPositions, pacOtherStrings)
				return This

		def ReplaceStringItemsByManyAtPositionsXT(panPositions, pacOtherStrings)
			This.ReplaceStringsByManyAtPositionsXT(panPositions, pacOtherStrings)

			def ReplaceStringItemsByManyAtPositionsXTQ(panPositions, pacOtherStrings)
				This.ReplaceStringItemsByManyAtPositionsXT(panPositions, pacOtherStrings)
				return This
	
		#>

	def StringsAtPositionsReplacedByManyXT(panPositions, pacOtherStrings)
		acResult = This.Copy().RepalceStringsByManyAtPositionsXTQ(panPositions, pacOtherStrings).Content()
		return acResult

		def StringItemsAtPositionsReplacedByManyXT(panPositions, pacOtherStrings)
			return This.StringsAtPositionsReplacedByManyXT(panPositions, pacOtherStrings)

	  #-------------------------------------------------------#
	 #    REPLACING A SECTION OF STRINGS BY A GIVEN STRING   #
	#-------------------------------------------------------#

	def ReplaceSection(n1, n2, pcNewStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
		o1.ReplaceSection(3, 5, "C")
		? o1.Content() #--> [ "A", "B", "C", "D" ]

		*/

		if isList(pcNewStr) and Q(pcNewStr).IsWithOrByNamedParamList()
			pcNewStr = pcNewStr[2]
		ok

		if NOT isString(pcNewStr)
			stzRaise("Incorrect param! pcNewStr must be a string.")
		ok

		This.RemoveSectionQ(n1, n2)
		This.InsertBefore(n1, pcNewStr)

		def ReplaceSectionQ(n1, n2, pcNewStr)
			This.ReplaceSection(n1, n2, pcNewStr)
			return This

	  #-----------------------------------------------------------#
	 #    REPLACING MANY SECTIONS OF STRINGS BY A GIVEN STRING   #
	#-----------------------------------------------------------#
	
	def ReplaceManySections(panSections, pcNewStr)

		if NOT ( isList(panSections) and StzListQ(panSections).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param! panSections must be a list of pairs of numbers.")
		ok

		if isList(pcNewStr) and Q(pcNewStr).IsWithOrByNamedParamList()
			pcNewStr = pcNewStr[2]
		ok

		if NOT isString(pcNewStr)
			stzRaise("Incorrect param! pcNewStr must be a string.")
		ok

		anPositions = []
		for anSection in panSections
			n1 = anSection[1]
			n2 = anSection[2]
			anTemp = n1:n2
			for n in anTemp
				anPositions + n
			next
		next

		anPositions = StzListQ(anPositions).RemoveDuplicatesQ().SortedInAscending()

		This.ReplaceStringsAtPositions(anPositions, pcNewStr)

	  #----------------------------------------------------------#
	 #   REPLACING EACH STRING IN SECTION BY ONE GIVEN STRING   #
	#----------------------------------------------------------#

	def ReplaceEachStringInSection(n1, n2, pcNewStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
		o1.ReplaceEachStringInSection(3, 5, "C")
		? o1.Content() #--> [ "A", "B", "C", "C", "C", "D" ]

		*/

		This.ReplaceStringsAtThesePositions(n1 : n2, pcNewStr)

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
	
	  #--------------------------------------------------------------#
	 #   REPLACING EACH STRING IN MANY SECTIONS BY A GIVEN STRING   #
	#--------------------------------------------------------------#

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

	   #----------------------------------------------------#
	  #   REPLACING A SECTION OF STRINGS BY MANY STRINGS   #
	#-----------------------------------------------------#

	def ReplaceSectionByMany(n1, n2, pacOtherListOfStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_" ])
		o1.ReplaceSectionByMany(3, 5, [ "C", "D", "F" ])
		? o1.Content() #--> [ "A", "B", "C", "D", "E", "F" ]

		*/

		if isString(n1)

			if Q(n1).IsOnOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ]
				, :CS = FALSE)

				n1 = 1
			ok

		ok

		if isString(n2)

			if Q(n2).IsOnOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ]
				, :CS = FALSE)

				n2 = This.NumberOfStrings()
			ok
		ok

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect params! n1 and n2 must be numbers.")
		ok

		This.ReplaceStringsAtPositionsByMany(n1 : n2, pacOtherListOfStr)

		def ReplaceSectionByManyQ(n1, n2, pacOtherListOfStr)
			This.ReplaceSectionByMany(n1, n2, pacOtherListOfStr)
			return This

	def SectionReplacedByMany(n1, n2, pacOtherListOfStr)
		aResult = This.ReplaceSectionByManyQ(n1, n2, pacOtherListOfStr).Content()
		return aResult

	   #----------------------------------------------------------------#
	  #   REPLACING A SECTION OF STRINGS BY MANY STRINGS  -- EXTENDED  #
	#-----------------------------------------------------------------#

	def ReplaceSectionByManyXT(n1, n2, pacOtherListOfStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_" ])
		o1.ReplaceSectionByManyXT(3, 5, [ "#1", "#2"])
		? o1.Content() #--> [ "A", "B", "C", "#1", "#2", "#1" ]

		*/

		if isString(n1)

			if Q(n1).IsOnOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ]
				, :CS = FALSE)

				n1 = 1
			ok

		ok

		if isString(n2)

			if Q(n2).IsOnOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ]
				, :CS = FALSE)

				n2 = This.NumberOfStrings()
			ok
		ok

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect params! n1 and n2 must be numbers.")
		ok

		This.ReplaceStringsAtPositionsByManyXT(n1 : n2, pacOtherListOfStr)

		def ReplaceSectionByManyXTQ(n1, n2, pacOtherListOfStr)
			This.ReplaceSectionByManyXT(n1, n2, pacOtherListOfStr)
			return This

	def SectionReplacedByManyXT(n1, n2, pacOtherListOfStr)
		aResult = This.ReplaceSectionByManyXTQ(n1, n2, pacOtherListOfStr).Content()
		return aResult

	   #-------------------------------------------------#
	  #   REPLACING A SECTION OF STRINGS IN THE LIST    #
	 #   BY MANY STRINGS BY ALTERNANCE    	           #
	#-------------------------------------------------#

	def ReplaceSectionByAlternance(n1, n2, pacOtherListOfStr)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "_", "_", "C" ])
		o1.ReplaceSectionByAlternance(3, 7, [ "#1", "#2", "#3" ])

		? @@( o1.Content() ) #--> [ "A", "B", "#1", "#2", "#3", "#1", "#2", "C" ]
		*/

		if isString(n1)

			if Q(n1).IsOnOfTheseCS([
				:First, :FirstPosition, :FirstString, :FirstStringItem ]
				, :CS = FALSE)

				n1 = 1
			ok

		ok

		if isString(n2)

			if Q(n2).IsOnOfTheseCS([
				:Last, :LastPosition, :LastString, :LastStringItem ]
				, :CS = FALSE)

				n2 = This.NumberOfStrings()
			ok
		ok

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect params! n1 and n2 must be numbers.")
		ok

		This.ReplaceStringItemsAtPositionsByAlternance(n1 : n2, pacOtherListOfStr)

	   #-------------------------------------------------------#
	  #   REPLACING MANY SECTIONS OF STRINGS BY MANY STRINGS  #
	#--------------------------------------------------------#

	def ReplaceSectionsByMany(panSections, pacOtherListOfStr)

		if NOT ( isList(panSections) and Q(panSections).IsListOfPairsOfNumbers() )

			stzRaise("Incorrect param! panSections must be a list of pairs of numbers.")
		ok

		if NOT ( isList(pacOtherListOfStr) and Q(pacOtherListOfStr).IsListOfStrings() )

			stzRaise("Incorrect param! panSections must be a list of strings.")
		ok

		anPositions = []

		for anSection in panSections
			n1 = anSection[1]
			n2 = anSection[2]

			if NOT (  Q(n1).IsBetween(1, This.NumberOfStrings()) and
				  Q(n2).IsBetween(1, This.NumberOfStrings())
			       )
				
				stzRaise("At least one position is out of range!")
			ok

			anPositions + ( n1 : n2 )
		next

		anPositions = StzListQ( anPositions ).
				MergeQ().RemoveDuplicatesQ().
				SortedInAscending()

		This.ReplaceStringsAtPositionsByMany(anPositions, pacOtherListOfStr)

		def ReplaceSectionsByManyQ(panSections, pacOtherListOfStr)
			This.ReplaceSectionsByMany(panSections, pacOtherListOfStr)
			return This

	def SectionsReplacedByMany(panSections, pacOtherListOfStr)
		acResult = This.Copy().
				ReplaceSectionsByManyQ(panSections, pacOtherListOfStr).
				Content()

		return acResult

	  #-------------------------------------------------------------------#
	 #   REPLACING MANY SECTIONS OF STRINGS BY MANY STRINGS -- EXTENDED  #
	#-------------------------------------------------------------------#

	def ReplaceSectionsByManyXT(panSections, pacOtherListOfStr)

		if NOT ( isList(panSections) and Q(panSections).IsListOfPairsOfNumbers() )

			stzRaise("Incorrect param! panSections must be a list of pairs of numbers.")
		ok

		if NOT ( isList(pacOtherListOfStr) and Q(pacOtherListOfStr).IsListOfStrings() )

			stzRaise("Incorrect param! panSections must be a list of strings.")
		ok

		anPositions = []

		for anSection in panSections
			n1 = anSection[1]
			n2 = anSection[2]

			anPositions + ( n1 : n2 )
		next

		anPositions = StzListQ( anPositions ).
				MergeQ().RemoveDuplicatesQ().
				SortedInAscending()

		This.ReplaceStringsAtPositionsByManyXT(anPositions, pacOtherListOfStr)

		def ReplaceSectionsByManyXTQ(panSections, pacOtherListOfStr)
			This.ReplaceSectionsByManyXT(panSections, pacOtherListOfStr)
			return This

	def SectionsReplacedByManyXT(panSections, pacOtherListOfStr)
		acResult = This.Copy().
				ReplaceSectionsByManyXTQ(panSections, pacOtherListOfStr).
				Content()

		return acResult

	  #----------------------------------------------#
	 #   REPLACING A RANGE OF STRINGS IN THE LIST   #
	#----------------------------------------------#

	def ReplaceRange(n, nRange, pcNewStr)

		anSection = RangeToSection([ n, nRange ])

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

		anSections = RangesToSections(panRanges)

		This.ReplaceManySections(anSections, pcNewStr)

		def ReplaceManyRangesQ(panRanges, pcNewStr)
			This.ReplaceManyRanges(panRanges, pcNewStr)
			return This

	def ManyRangesReplaced(panRanges, pcNewStr)
		acResult = This.Copy().ReplaceManyRangesQ(panRanges, pcNewStr).Content()
		return acResult

	  #-----------------------------------------------------------------#
	 #   REPLACING MANY RANGES OF STRINGS BY MANY STRINGS -- EXTENDED  #
	#------------------------------------------------------------------#

	def ReplaceManyRangesXT(panRanges, pcNewStr)

		anSections = RangesToSections(panRanges)

		This.ReplaceManySectionsXT(anSections, pcNewStr)

		def ReplaceManyRangesXTQ(panRanges, pcNewStr)
			This.ReplaceManyRangesXT(panRanges, pcNewStr)
			return This

	def ManyRangesReplacedXT(panRanges, pcNewStr)
		acResult = This.Copy().ReplaceManyRangesXTQ(panRanges, pcNewStr).Content()
		return acResult

	  #---------------------------------------------------------------#		
	 #   REPLACING EACH STRING IN A RANGE BY THE SAME GIVEN STRING   #
	#---------------------------------------------------------------#

	def ReplaceEachStringInRange(n, nRange, pcNewStr)

		anSection = RangeToSection([ n, nRange ])

		n1 = anSection[1]
		n2 = anSection[2]

		This.ReplaceEachStringInSection(n1, n2, pcNewStr)

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
			n = anRange[1]
			nRange = anRange[2]
			This.ReplaceEachStringInRange(n, nRange, pcNewStr)
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
	
	  #----------------------------------------------------#
	 #   REPLACING A RANGE OF STRINGS WITH MANY STRINGS   #
	#----------------------------------------------------#

	def ReplaceRangeByMany(n, nRange, pacOtherListOfStr)

		anSection = RangeToSection([ n, nRange ])
		n1 = anSection[1]
		n2 = anSection[2]

		This.ReplaceSectionByMany(n1, n2, pacOtherListOfStr)

		def ReplaceRangeByManyQ(n, nRange, pacOtherListOfStr)
			This.ReplaceRange(n, nRange, pacOtherListOfStr)
			return This

	def RangeReplacedByMany(n, nRange, pacOtherListOfStr)
		aResult = This.ReplaceRangeByManyQ(n, nRange, pacOtherListOfStr).Content()
		return aResult

	  #----------------------------------------------------------------#
	 #   REPLACING A RANGE OF STRINGS WITH MANY STRINGS -- EXTENDED   #
	#----------------------------------------------------------------#

	def ReplaceRangeByManyXT(n, nRange, pacOtherListOfStr)

		anSection = RangeToSection([ n, nRange ])
		n1 = anSection[1]
		n2 = anSection[2]

		This.ReplaceSectionByManyXT(n1, n2, pacOtherListOfStr)

		def ReplaceRangeByManyXTQ(n, nRange, pacOtherListOfStr)
			This.ReplaceRangeByManyXT(n, nRange, pacOtherListOfStr)
			return This

	def RangeReplacedByManyXT(n, nRange, pacOtherListOfStr)
		aResult = This.ReplaceRangeByManyXTQ(n, nRange, pacOtherListOfStr).Content()
		return aResult

	  #-----------------------------------------------------#
	 #   REPLACING MANY RANGES OF STRINGS BY MANY STRINGS  #
	#------------------------------------------------------#

	def ReplaceRangesByMany(panRanges, pacOtherListOfStr)
		
		anSections = []
		for anRange in panRanges
			anSections + RangeToSection(anRange)
		next

		This.ReplaceSectionsByMany(anSections, pacOtherListOfStr)

		def ReplaceRangesByManyQ(panRanges, pacOtherListOfStr)
			This.ReplaceRangesByMany(panRanges, pacOtherListOfStr)
			return This

	def RangesReplacedByMany(panRanges, pacOtherListOfStr)
		
		acResult = This.Copy().
				ReplaceRangesByManyQ(panRanges, pacOtherListOfStr).
				Content()

		return acResult

	  #-----------------------------------------------------------------#
	 #   REPLACING MANY RANGES OF STRINGS BY MANY STRINGS -- EXTENDED  #
	#-----------------------------------------------------------------#

	def ReplaceRangesByManyXT(panRanges, pacOtherListOfStr)
		
		anSections = []
		for anRange in panRanges
			anSections + RangeToSection(anRange)
		next

		This.ReplaceSectionsByManyXT(anSections, pacOtherListOfStr)

		def ReplaceRangesByManyXTQ(panRanges, pacOtherListOfStr)
			This.ReplaceRangesByManyXT(panRanges, pacOtherListOfStr)
			return This

	def RangesReplacedByManyXT(panRanges, pacOtherListOfStr)
		
		acResult = This.Copy().
				ReplaceRangesByManyXTQ(panRanges, pacOtherListOfStr).
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

	  #==============================================================================#
	 #  REPLACING ALL OCCURRENCES OF A SUBSTRING IN THE LIST WITH A NEW SUBSTRING   #
	#==============================================================================#

	def ReplaceSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			
		bDynamic = FALSE

		if isList(pcNewSubStr) and Q(pcNewSubStr).IsWithOrByNamedParamList()
			if Q(pcNewSubStr[1]).LastChar() = "@"
				bDynamic = TRUE
			ok

			pcNewSubStr = pcNewSubStr[2]

		ok

		if NOT isString(pcNewSubStr)
			stzRaise("Incorrect param! pcNewSubStr must be a string.")
		ok

		cDynamicExpr = NULL

		if bDynamic
			cDynamicExpr = StzStringQ(pcNewSubStr).SimplifyQ().
					RemoveBoundsQ("{","}").Content()
		ok

		@SubString = pcSubStr
		@i = 0
		for str in This.ListOfStrings()
			@i++
			@StringPosition = @i
			
			if bDynamic
				cCode = 'pcNewSubStr = ' + cDynamicExpr
				eval(cCode)
			ok

			@NewSubString = pcNewSubStr

			cNewSubStr = StzStringQ(str).ReplaceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).Content()
			This.ReplaceStringAtPosition(@i, cNewSubStr)
		next

		def ReplaceSubStringCSQ(pcSubStr, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
			return This

	def SubStringReplacedCS(pcSubStr, pcNewStr, pCaseSensitive)
		acResult = This.Copy().ReplaceSubStringCSQ(pcSubStr, pcNewStr, pCaseSensitive).Content()
		return acResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubString(pcSubStr, pcNewStr)
		This.ReplaceSubStringCS(pcSubStr, pcNewStr, :CaseSensitive = TRUE)

		def ReplaceSubStringQ(pcSubStr, pcNewStr)
			This.ReplaceSubString(pcSubStr, pcNewStr)
			return This

	def SubStringReplaced(pcSubStr, pcNewStr)
		acResult = This.Copy().ReplaceSubStringQ(pcSubStr, pcNewStr).Content()
		return acResult

	  #------------------------------------------------#
	 #  REPLACING MANY SUBSTRINGS BY A GIVEN STRING   #
	#------------------------------------------------#

	def ReplaceManySubStringsCS(pacSubStrings, pcNewSubStr, pCaseSensitive)

		bDynamic = FALSE
		if isList(pcNewsubStr) and Q(pcNewSubStr).IsWithOrByParamList()
			if Q(pcNewSubStr[1]).LastChar() = "@"
				bDynamic = TRUE
				pcNewSubStr = pcNewSubStr[2]
			ok
		ok

		@i = 0
		@Position = 0
		@SubStringPosition = 0
		@NextPosition = 0
		@PreviousPosition = 0
		@NextI = 0
		@PreviousI = 0

		for str in pacSubStrings
			if NOT bDynamic
				This.ReplaceSubStringCS(str, pcNewSubStr, pCaseSensitive)
			else
				@i++
				@Position = @i
				@SubStringPosition = @i

				@NextPosition = @Position++
				@NextI = @NextPosition

				@PreviousPosition = @Position--
				@PreviousI = @PreviousPosition
				
				cDynamicExpr = StzStringQ(pcNewSubStr).SimplifyQ().RemoveBoundsQ("{","}").Content()
				cCode = 'cNewStr = ( ' + cDynamicExpr + ' )'

				try
					eval(cCode)
				catch
				done

				This.ReplaceSubStringCS(str, cNewStr, pCaseSensitive)
			ok
		next

		def ReplaceManySubStringsCSQ(pacSubStrings, pcNewSubStr, pCaseSensitive)
			This.ReplaceManySubStringsCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
			return This

		def RepalceSubStringsCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
			This.ReplaceManySubStringsCS(pacSubStrings, pcNewSubStr, pCaseSensitive)

			def RepalceSubStringsCSQ(pacSubStrings, pcNewSubStr, pCaseSensitive)
				This.RepalceSubStringsCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
				return This

	def ManySubStringsReplacedCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		acResult = This.Copy().ReplaceManySubStringsCSQ(pacSubStrings, pcNewSubStr, pCaseSensitive).Content()
		return acResult

		def SubStringsReplacedCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
			return This.ManySubStringsReplacedCS(pacSubStrings, pcNewSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManySubStrings(pacSubStrings, pcNewSubStr)
		This.ReplaceManySubStringsCS(pacSubStrings, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceManySubStringsQ(pacSubStrings, pcNewSubStr)
			This.ReplaceManySubStrings(pacSubStrings, pcNewSubStr)
			return This

		def RepalceSubStrings(pacSubStrings, pcNewSubStr)
			This.ReplaceManySubStrings(pacSubStrings, pcNewSubStr)

			def RepalceSubStringsQ(pacSubStrings, pcNewSubStr)
				This.RepalceSubStrings(pacSubStrings, pcNewSubStr)
				return This

	def ManySubStringsReplaced(pacSubStrings, pcNewSubStr)
		acResult = This.Copy().ReplaceManySubStringsQ(pacSubStrings, pcNewSubStr).Content()
		return acResult

		def SubStringsReplaced(pacSubStrings, pcNewSubStr)
			return This.ManySubStringsReplaced(pacSubStrings, pcNewSubStr)

	  #-----------------------------------------------#
	 #    REPLACING SUBSTRINGS BY MANY SUBSTRINGS	 #
	#-----------------------------------------------#

	def ReplaceSubStringByManyCS(pcSubStr, pacNewSubStrings, pCaseSensitive)
		/* EXAMPLE 1

		o1 = new stzListOfStrings([ "heart ___ heart", "___ heart ___ heart ___ heart", "heart" ])
		o1.ReplaceSubStringByMany( "heart", :With = L('{ "♥1" : "♥6" }') )
		
		? @@( o1.Content() )
		#--> [ "♥1 ___ ♥2", "___ ♥3 ___ ♥4 ___ ♥5", "♥6" ]

		EXAMPLE 2

		o1 = new stzListOfStrings([ "heart ___ heart", "___ heart ___ heart ___ heart", "heart" ])
		o1.ReplaceSubStringByMany( "heart", :With = [ "♥1", "♥2", "♥3" ]') )
		
		? @@( o1.Content() )
		#--> [ "♥1 ___ ♥2", "___ ♥3 ___ heart ___ heart", "heart" ]

		*/

		if isList(pacNewSubStrings) and Q(pacNewSubStrings).IsWithOrByNamedPAramList()
			pacNewSubStrings = pacNewSubStrings[2]
		ok

		if NOT ( isList(pacNewSubStrings) and Q(pacNewSubStrings).IsListOfStrings() )
			stzRaise("Incorrect param! pacNewSubStrings must be a list of strings.")
		ok

		# [ "heart ___ heart", "___ heart ___ heart ___ heart", "heart" ]

		# [ "♥1", "♥2", "♥3" ]
		nLen = len(pacNewSubStrings)

		aPositions = This.NFirstOccurrencesOfSubStringXTCS(nLen, pcSubStr, pCaseSensitive)
		#--> [ [ 1, 1], [ 1, 11 ], [ 2, 5] ]

		This.ReplaceSubStringAtPositions(aPositions, pcSubStr)
			
	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringByMany(pcSubStr, pacNewSubStrings)
		This.ReplaceSubStringByManyCS(pcSubStr, pacNewSubStrings, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------------#
	 #    REPLACING A SUBSTRING BY MANY SUBSTRINGS -- EXTENDED (REETURN TO FIST)   #
	#----------------------------------------------------------------------------#

	def ReplaceSubStringByManyCSXT(pcSubStr, pacNewSubStrings, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([ "heart ipsum heart", "lorem heart ipsum heart lorem heart", "heart" ])
		o1.ReplaceSubStringByManyXT( "heart", :With = L('{ "♥1" : "♥3" }') )
		
		? @@( o1.Content() ) #--> [ "♥1 ipsum ♥2", "lorem ♥3 ipsum ♥1 lorem ♥2", "♥3" ]
		*/

		if isList(pacNewSubStrings) and Q(pacNewSubStrings).IsWithOrByNamedPAramList()
			pacNewSubStrings = pacNewSubStrings[2]
		ok

		if NOT ( isList(pacNewSubStrings) and Q(pacNewSubStrings).IsListOfStrings() )
			stzRaise("Incorrect param! pacNewSubStrings must be a list of strings.")
		ok

		anPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		nNumberOfSubStrings = This.NumberOfSubStringsCS(pcSubStr, pCaseSensitive)

		acNewSubStrings = pacNewSubStrings

		if len(acNewSubStrings) < nNumberOfSubStrings
			acNewSubStrings = Q(pacNewSubStrings).
					  ExtendToXTQ( nNumberOfSubStrings, :With@ = '@items' ).
					  Content()
		ok

		This.ReplaceSubStringByManyCS(pcSubStr, acNewSubStrings, pCaseSensitive)

		def ReplaceSubStringByManyCSXTQ(pcSubStr, pacNewSubStrings, pCaseSensitive)
			This.ReplaceSubStringByManyCSXT(pcSubStr, pacNewSubStrings, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringByManyXT(pcSubStr, pacNewSubStrings)
		This.ReplaceSubStringByManyCSXT(pcSubStr, pacNewSubStrings, :CaseSensitive = TRUE)

		def ReplaceSubStringByManyXTQ(pcSubStr, pacNewSubStrings)
			This.ReplaceSubStringByManyXT(pcSubStr, pacNewSubStrings)
			return This

	  #-----------------------------------------------#
	 #   REPLACING A SUBSTRING AT A GIVEN POSITION   #
	#-----------------------------------------------#

	def ReplaceSubStringAtPositionCS(panPosition, pcSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([
			"___ ring ___ ring",
			"ring ___ ring ___ ring",
			"___ ring"
		])

		o1.ReplaceSubStringAtPosition([2, 10 ], :With = "♥♥♥")
		? o1.Content()
		#--> [
		#	"___ ring ___ ring",
		#	"ring ___ ♥♥♥ ___ ring",
		#	"___ ring"
		#    ]

		*/

		if NOT ( isList(panPositions) and Q(panPositions).IsPairOfNumbers() )
			stzRaise("Incorrect param type! panPositions must be a pair of numbers.")
		ok

		anPositions = This.FindSubSstringXTCS(pcSubStr, pCaseSensitive)
		#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1 ], [ 2, 10 ], [ 2, 19 ], [ 3, 5 ] ]

		n = Q(anPositions).Find(panPosition)
		This.ReplaceNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def ReplaceSubStringAtPositionCSQ(panPosition, pcSubStr, pCaseSensitive)
			This.ReplaceSubStringAtPositionCS(panPosition, pcSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubstringAtPosition(panPosition, pcSubStr)
		return This.ReplaceSubStringAtPositionCS(panPosition, pcSubStr, :CaseSensitive = TRUE)

		def ReplaceSubstringAtPositionQ(panPosition, pcSubStr)
			This.ReplaceSubstringAtPosition(panPosition, pcSubStr)
			return This

	  #----------------------------------------------#
	 #   REPLACING A SUBSTRING AT GIVEN POSITIONS   #
	#----------------------------------------------#

	def ReplaceSubStringAtPositions(panPositions, pcSubStr, pCaseSensitive)
		
		if NOT ( isList(panPosistions) and Q(panPositions).IsListOfPairsOfNumbers() )
			stzRaise("Incorrect param type! panPositions must be a list of pairs of numbers.")
		ok

		// TODO
		
	  #==============================================================================#
	 #  REPLACING, INSIDE A GIVEN STRING, ALL THE OCCURRENCES OF A GIVEN SUBSTRING  #
	#==============================================================================#

	def ReplaceInStringNCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
		o1.ReplaceInStringN(2, "ring", :With = "♥")
		? o1.Content()
		#--> [ "php", "♥ php ♥ python ♥", "python" ]
		*/

		cNewStr = This.StringQ(n).
				ReplaceAllCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).
				Content()

		This.ReplaceStringN(n, cNewStr)

		def ReplaceInStringNCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceInStringN(n, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNCS(n, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)
		
		def ReplaceInStringNQ(n, pcSubStr, pcNewSubStr)
			This.ReplaceInStringN(n, pcSubStr, pcNewSubStr)
			return This

	  #---------------------------------------------------------------------#
	 #  REPLACING, INSIDE A GIVEN STRING, A SUBSTRING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------#

	def ReplaceInStringNSubStringAtPositionNCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
		o1.ReplaceInStringNSubstringAtPositionN(2, 5, "ring", "♥" )
		? o1.Content()
		#--> [ "php", "php ♥ python", "python" ]
	
		*/

		cNewStr = This.StringQ(pnStringNumber).
				ReplaceSubStringAtPositionCSQ(pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive).
				Content()

		This.ReplaceStringAt(pnStringNumber, cNewStr)

		def ReplaceInStringNSubStringAtPositionNCSQ(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNSubStringAtPositionNCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

		#< @FunctionAlternativeForm

		def ReplaceInStringNSubStringAtPositionCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNSubStringAtPositionNCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceInStringNSubStringAtPositionCSQ(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceInStringNSubStringAtPositionCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
				return This
		#>


	#-- WITHOUT CASESENSITIVTY

	def ReplaceInStringNSubStringAtPositionN(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNSubStringAtPositionNCS(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceInStringNSubStringAtPositionNQ(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
			This.ReplaceInStringNSubStringAtPositionN(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
			return This
	
		#< @FunctionAlternativeForm

		def ReplaceInStringNSubStringAtPosition(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
			This.ReplaceInStringNSubStringAtPositionN(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)

			def ReplaceInStringNSubStringAtPositionQ(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
				This.ReplaceInStringNSubStringAtPosition(pnStringNumber, pnSubStringPosition, pcSubStr, pcNewSubStr)
				return This
		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING, INSIDE A GIVEN STRING, THE NTH OCCURRENCE OF A GIVEN SUBSTRING  #
	#-----------------------------------------------------------------------------#

	def ReplaceInStringNTheNthOccurrenceCS(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
		o1.ReplaceInStringNTheNthOccurrence(2, 3, "ring", "♥" )
		? o1.Content()
		#--> [ "php", "ring php ring python ♥", "python" ]
	
		*/

		cNewStr = This.StringQ(pnStringNumber).
				ReplaceNthOccurrenceCSQ(pnOccurrence, pcSubStr, pcNewSubStr, pCaseSensitive).
				Content()

		This.ReplaceStringAt(pnStringNumber, cNewStr)

		def ReplaceInStringNTheNthOccurrenceCSQ(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNTheNthOccurrenceCS(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVTY

	def ReplaceInStringNTheNthOccurrence(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNTheNthOccurrenceCS(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceInStringNTheNthOccurrenceQ(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr)
			This.ReplaceInStringNTheNthOccurrence(pnStringNumber, pnOccurrence, pcSubStr, pcNewSubStr)
			return This
	
	  #-------------------------------------------------------------------------------#
	 #  REPLACING, INSIDE A GIVEN STRING, THE FIRST OCCURRENCE OF A GIVEN SUBSTRING  #
	#-------------------------------------------------------------------------------#

	def ReplaceInStringNTheFirstOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
		This.ReplaceInStringNTheNthOccurrenceCS(pnStringNumber, 1, pcSubStr, pcNewSubStr, pCaseSensitive)

		def ReplaceInStringNTheFirstOccurrenceCSQ(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNTheFirstOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceInStringNTheFirstOccurrence(pnStringNumber, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNTheFirstOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceInStringNTheFirstOccurrenceQ(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNTheFirstOccurrence(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	  #------------------------------------------------------------------------------#
	 #  REPLACING, INSIDE A GIVEN STRING, THE LAST OCCURRENCE OF A GIVEN SUBSTRING  #
	#------------------------------------------------------------------------------#

	def ReplaceInStringNTheLastOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
		This.ReplaceInStringNTheNthOccurrenceCS(pnStringNumber, :Last, pcSubStr, pcNewSubStr, pCaseSensitive)

		def ReplaceInStringNTheLastOccurrenceCSQ(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNTheLastOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceInStringNTheLastOccurrence(pnStringNumber, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNTheLastOccurrenceCS(pnStringNumber, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceInStringNTheLastOccurrenceQ(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceInStringNTheLastOccurrence(pnStringNumber, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This


	  #================================================================#
	 #   REMOVING ALL OCCURRENCE OF A GIVEN STRING-ITEM IN THE LIST   #
	#================================================================#

	def RemoveAllCS(pcString, pCaseSensitive)

		if isList(pcString) and Q(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		anPositions = This.FindAllCS(pcString, pCaseSensitive)

		for i = len(anPositions) to 1 step -1
			n = anPositions[i]
			This.RemoveStringAtPosition(n)
		next


		#< @FunctionFluentForm

		def RemoveAllCSQ(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveAllOccurrencesCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveAllOccurrencesCSQ(pcString, pCaseSensitive)
				This.RemoveAllOccurrencesCS(pcString, pCaseSensitive)
				return This

		#--

		def RemoveAllOccurrencesOfStringCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveAllOccurrencesOfStringCSQ(pcString, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringCS(pcString, pCaseSensitive)
				return This

		def RemoveAllOccurrencesOfStringItemCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveAllOccurrencesOfStringItemCSQ(pcString, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringItemCS(pcString, pCaseSensitive)
				return This

		#--

		def RemoveCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveCSQ(pcString, pCaseSensitive)
				This.RemoveCS(pcString, pCaseSensitive)
				return This

		#--

		def RemoveStringCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveStringCSQ(pcString, pCaseSensitive)
				This.RemoveStringCS(pcString, pCaseSensitive)
				return This

		def RemoveStringItemCS(pcString, pCaseSensitive)
			This.RemoveAllCS(pcString, pCaseSensitive)

			def RemoveStringItemCSQ(pcString, pCaseSensitive)
				This.RemoveStringItemCS(pcString, pCaseSensitive)
				return This

		#--

	def AllOccurrencesOfThisStringRemovedCS(pcString, pCaseSensitive)
		aResult = This.Copy().RemoveAllOccurrencesOfCSQ(pcString, pCaseSensitive).Content()
		return aResult

		def AllOccurrencesOfThisStringItemRemovedCS(pcString, pCaseSensitive)
			return This.AllOccurrencesOfThisStringRemovedCS(pcString, pCaseSensitive)

		def AllOccurrencesRemovedCS(pcString, pCaseSensitive)
			return This.AllOccurrencesOfThisStringRemovedCS(pcString, pCaseSensitive)

		def StringRemovedCS(pcString, pCaseSensitive)
			return This.AllOccurrencesOfThisStringRemovedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveAll(pcString)

		This.RemoveAllCS(pcString, :CaseSensitive = TRUE)

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
		aResult = This.Copy().RemoveAllOccurrencesQ(pcString).Content()
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

		def RemoveManyOccurrences(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveManyOccurrencesQ(paOccurrences, pcString)
				This.RemoveOccurrencesOfString(paOccurrences, pcString)
				return This

		#--

		def RemoveOccurrencesOfString(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveOccurrencesOfStringQ(paOccurrences, pcString)
				This.RemoveOccurrencesOfString(paOccurrences, pcString)
				return This

		def RemoveManyOccurrencesOfString(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveManyOccurrencesOfStringQ(paOccurrences, pcString)
				This.RemoveManyOccurrencesOfString(paOccurrences, pcString)
				return This

		#--

		def RemoveOccurrencesOfStringItem(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveOccurrencesOfStringItemQ(paOccurrences, pcString)
				This.RemoveOccurrencesOfStringItem(paOccurrences, pcString)
				return This

		def RemoveManyOccurrencesOfStringItem(paOccurrences, pcString)
			This.RemoveOccurrences(panOccurrences, pcString)

			def RemoveManyOccurrencesOfStringItemQ(paOccurrences, pcString)
				This.RemoveManyOccurrencesOfStringItem(paOccurrences, pcString)
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

		def ManyOccurrencesRemoved(panOccurrences, pcString)
			return This.OccurrencesRemoved(panOccurrences, pcString)

		def ManyOccurrencesOfThisStringRemoved(panOccurrences, pcString)
			return This.OccurrencesRemoved(panOccurrences, pcString)

		def ManyOccurrencesOfThisStringItemRemoved(panOccurrences, pcString)
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

	def RemoveNthCS(n, pcString, pCaseSensitive)
		n = This.FindNthOccurrenceCS(n, pcString, pCaseSensitive)
		This.RemoveStringAtPosition( n )


		#< @FunctionFluentForm

		def RemoveNthCSQ(n, pcString, pCaseSensitive)
			This.RemoveNthCS(n, pcString, pCaseSensitive)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveNthOccurrenceCS(n, pcString, pCaseSensitive)
			This.RemoveNthCS(n, pcString, pCaseSensitive)

			def RemoveNthOccurrenceCSQ(n, pcString, pCaseSensitive)
				This.RemoveNthOccurrenceCS(n, pcString, pCaseSensitive)
				return This

		#--

		def RemoveNthOccurrenceOfStringCS(n, pcString, pCaseSensitive)
			This.RemoveNthCS(n, pcString, pCaseSensitive)

			def RemoveNthOccurrenceOfStringCSQ(n, pcString, pCaseSensitive)
				This.RemoveNthOccurrenceOfStringCS(n, pcString, pCaseSensitive)
				return This

		def RemoveNthOccurrenceOfStringItemCS(n, pcString, pCaseSensitive)
			This.RemoveNthCS(n, pcString, pCaseSensitive)

			def RemoveNthOccurrenceOfStringItemCSQ(n, pcString, pCaseSensitive)
				This.RemoveNthOccurrenceOfStringItemCS(n, pcString, pCaseSensitive)
				return This

		#--

		def RemoveOccurrenceCS(n, pcString, pCaseSensitive)
			This.RemoveNthCS(n, pcString, pCaseSensitive)

			def RemoveOccurrenceCSQ(n, pcString, pCaseSensitive)
				This.RemoveOccurrenceCS(n, pcString, pCaseSensitive)
				return This

	def NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)
		aResult = This.Copy().RemoveNthOccurrenceCSQ(n, pcString, pCaseSensitive).Content()
		return aResult

		def NthOccurrenceOfThisStringItemRemovedCS(n, pcString, pCaseSensitive)
			return This.NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveNth(n, pcString)

		This.RemoveNthCS(n, pcString, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def RemoveNthOccurrence(n, pcString)
			This.RemoveNth(n, pcString)

			def RemoveNthOccurrenceQ(n, pcString)
				This.RemoveNthOccurrence(n, pcString)
				return This

		#--

		def RemoveNthOccurrenceOfString(n, pcString)
			This.RemoveNth(n, pcString)

			def RemoveNthOccurrenceOfStringQ(n, pcString)
				This.RemoveNthOccurrencesOfString(n, pcString)
				return This

		def RemoveNthOccurrenceOfStringItem(n, pcString)
			This.RemoveNthCS(n, pcString)

			def RemoveNthOccurrenceOfStringItemQ(n, pcString)
				This.RemoveNthOccurrenceOfStringItem(n, pcString)
				return This

		#--

		def RemoveOccurrence(n, pcString)
			This.RemoveNth(n, pcString)

			def RemoveOccurrenceQ(n, pcString)
				This.RemoveOccurrence(n, pcString)
				return This

	def NthOccurrenceOfThisStringRemoved(n, pcString)
		aResult = This.Copy().RemoveNthOccurrencesQ(n, pcString).Content()
		return aResult

		def NthOccurrenceOfThisStringItemRemoved(n, pcString)
			return This.NthOccurrenceOfThisStringRemoved(n, pcString)

		def NthOccurrenceRemoved(n, pcString)
			return This.NthOccurrenceOfThisStringRemoved(n, pcString)

	  #----------------------------------------------------#
	 #   REMOVING THE FIRST OCCURRENCE OF A STRING-ITEM   #
	#----------------------------------------------------#

	def RemoveFirstCS(pcString, pCaseSensitive)

		This.RemoveStringAtPosition( This.FindFirstOccurrence(pcString) )


		#< @FunctionFluentForm

		def RemoveFirstCSQ(pcString, pCaseSensitive)
			This.RemoveFirstCS(pcString, pCaseSensitive)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveFirstOccurrencesCS(pcString, pCaseSensitive)
			This.RemoveFirstCS(pcString, pCaseSensitive)

			def RemoveFirstOccurrencesCSQ(pcString, pCaseSensitive)
				This.RemoveFirstOccurrencesCS(pcString, pCaseSensitive)
				return This

		#--

		def RemoveFirstOccurrencesOfStringCS(pcString, pCaseSensitive)
			This.RemoveFirstCS(pcString, pCaseSensitive)

			def RemoveFirstOccurrencesOfStringCSQ(pcString, pCaseSensitive)
				This.RemoveFirstOccurrencesOfStringCS(pcString, pCaseSensitive)
				return This

		def RemoveFirstOccurrencesOfStringItemCS(pcString, pCaseSensitive)
			This.RemoveFirstCS(pcString, pCaseSensitive)

			def RemoveFirstOccurrencesOfStringItemCSQ(pcString, pCaseSensitive)
				This.RemoveFirstOccurrencesOfStringItemCS(pcString, pCaseSensitive)
				return This

		#--

	def FirstOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)
		aResult = This.Copy().RemoveFirstOccurrencesCSQ(pcString, pCaseSensitive).Content()
		return aResult

		def FirstOccurrenceOfThisStringItemRemovedCS(pcString, pCaseSensitive)
			return This.FirstOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)

		def FirstOccurrenceRemovedCS(pcString, pCaseSensitive)
			return This.FirstOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveFirst(pcString)

		This.RemoveFirstCS(pcString, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def RemoveFirstOccurrences(pcString)
			This.RemoveFirst(pcString)

			def RemoveFirstOccurrencesQ(pcString)
				This.RemoveFirstOccurrences(pcString)
				return This

		#--

		def RemoveFirstOccurrencesOfString(pcString)
			This.RemoveFirst(pcString)

			def RemoveFirstOccurrencesOfStringQ(pcString)
				This.RemoveFirstOccurrencesOfString(pcString)
				return This

		def RemoveFirstOccurrencesOfStringItem(pcString)
			This.RemoveFirst(pcString)

			def RemoveFirstOccurrencesOfStringItemQ(pcString)
				This.RemoveFirstOccurrencesOfStringItem(pcString)
				return This

		#--

	def FirstOccurrenceOfThisStringRemoved(pcString)
		aResult = This.Copy().RemoveFirstOccurrencesQ(pcString).Content()
		return aResult

		def FirstOccurrenceOfThisStringItemRemoved(pcString)
			return This.FirstOccurrenceOfThisStringRemoved(pcString)

		def FirstOccurrenceRemoved(pcString)
			return This.FirstOccurrenceOfThisStringRemoved(pcString)

	  #---------------------------------------------------#
	 #   REMOVING THE LAST OCCURRENCE OF A STRING-ITEM   #
	#---------------------------------------------------#

	def RemoveLastCS(pcString, pCaseSensitive)

		n = This.FindLastOccurrenceCS(pcString, pCaseSensitive)

		if n <= This.NumberOfItems()
			This.RemoveStringAtPosition( n )
		ok

		#< @FunctionFluentForm

		def RemoveLastCSQ(pcString, pCaseSensitive)
			This.RemoveLastCS(pcString, pCaseSensitive)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveLastOccurrencesCS(pcString, pCaseSensitive)
			This.RemoveLastCS(pcString, pCaseSensitive)

			def RemoveLastOccurrencesCSQ(pcString, pCaseSensitive)
				This.RemoveLastOccurrencesCS(pcString, pCaseSensitive)
				return This

		#--

		def RemoveLastOccurrencesOfStringCS(pcString, pCaseSensitive)
			This.RemoveLastCS(pcString, pCaseSensitive)

			def RemoveLastOccurrencesOfStringCSQ(pcString, pCaseSensitive)
				This.RemoveLastOccurrencesOfStringCS(pcString, pCaseSensitive)
				return This

		def RemoveLastOccurrencesOfStringItemCS(pcString, pCaseSensitive)
			This.RemoveLastCS(pcString, pCaseSensitive)

			def RemoveLastOccurrencesOfStringItemCSQ(pcString, pCaseSensitive)
				This.RemoveLastOccurrencesOfStringItemCS(pcString, pCaseSensitive)
				return This

		#--

	def LastOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)
		aResult = This.Copy().RemoveLastOccurrencesCSQ(pcString, pCaseSensitive).Content()
		return aResult

		def LastOccurrenceOfThisStringItemRemovedCS(pcString, pCaseSensitive)
			return This.LastOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)

		def LastOccurrenceRemovedCS(pcString, pCaseSensitive)
			return This.LastOccurrenceOfThisStringRemovedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveLast(pcString)

		This.RemoveLastCS(pcString, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def RemoveLastOccurrences(pcString)
			This.RemoveLast(pcString)

			def RemoveLastOccurrencesQ(pcString)
				This.RemoveLastOccurrences(pcString)
				return This

		#--

		def RemoveLastOccurrencesOfString(pcString)
			This.RemoveLast(pcString)

			def RemoveLastOccurrencesOfStringQ(pcString)
				This.RemoveLastOccurrencesOfString(pcString)
				return This

		def RemoveLastOccurrencesOfStringItem(pcString)
			This.RemoveLast(pcString)

			def RemoveLastOccurrencesOfStringItemQ(pcString)
				This.RemoveLastOccurrencesOfStringItem(pcString)
				return This

		#--

	def LastOccurrenceOfThisStringRemoved(pcString)
		aResult = This.Copy().RemoveLastOccurrencesQ(pcString).Content()
		return aResult

		def LastOccurrenceOfThisStringItemRemoved(pcString)
			return This.LastOccurrenceOfThisStringRemoved(pcString)

		def LastOccurrenceRemoved(pcString)
			return This.LastOccurrenceOfThisStringRemoved(pcString)

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

		oSection   = This.SectionQR(pnStartingAt, :LastString, :stzListOfStrings)
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

		if NOT ( isList(panList) and StzListQ(panList).IsListOfNumbers() and
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList)
		       )

			stzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
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
			
		oSection = This.SectionQR(pnStartingAt, :LastString, :stzListOfStrings)

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

		This.RemoveStringsAtThesePositions(anPositionsToBeRemoved)

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

		def RemoveNextOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemoveNextNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)

			def RemoveNextOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
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

		oSection   = This.SectionQR(1, pnStartingAt, :stzListOfStrings)
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

		if NOT ( isList(panList) and StzListQ(panList).IsListOfNumbers() and
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfStrings() + ")") = len(panList)
		       )

			stzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
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
			
		oSection = This.SectionQR(1, pnStartingAt, :stzListOfStrings)

		anPositions = oSection.FindAllCSQ(pcString, pCaseSensitive).Reversed()

		anPositionsToBeRemoved = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeRemoved + anPositions[n]
			ok
		next

		This.RemoveStringsAtThesePositions(anPositionsToBeRemoved)

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

		def RemovePreviousOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)
			This.RemovePreviousNthOccurrencesCS(panList, pcString, pnStartingAt, pCaseSensitive)

			def RemovePreviousOccurrencesCSQ(panList, pcString, pnStartingAt, pCaseSensitive)
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

		if n <= This.NumberOfStrings()
			This.QStringListObject().removeAt(n-1)
		ok

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

		def RemoveAtPositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

			def RemoveAtPositionsQ(panPositions)
				This.RemoveAtPositions(panPositions)
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
				This.RemoveManyStringItemsAt(panPositions)
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
			aResult + str
		next		
		  
		This.Update( aResult )

		#< @FunctionFluentForm

		def RemoveRangeQ(pnStart, pnRange)
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

		if NOT ( isNumber(n1) and isNumber(n2) )
			stzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings()) and
		         StzNumberQ(n2).IsBetween(1, This.NumberOfStrings())
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

		if NOT ( isList(paSections) and
			 Q(paSections).IsListOfPairs() and
			 Q(paSections).MergeQ().AllItemsAreNumbers() )

			stzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		anPositions = StzListOfPairsQ(paSections).
				ExpandedIfPairsOfNumbersQ().
				MergeQ().RemoveDuplicatesQ().Content()


		This.RemoveStringsAtPositions(anPositions)

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
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )

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
				This.ReplaceStringAtPosition(@i, @string)
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
						This.ReplaceStringAtPosition(@i, @string )
					ok

				ok
			ok
		next

		#--

		def PerformWQ(paParams)
			This.PerformW(paParams)
			return This

	  #======================================================#
	 #   CHECKING IF THE LIST CONTAINS DUPLICATED STRINGS   #
	#======================================================#

	def ContainsDuplicatedStringsCS(pCaseSensitive)
		bResult = FALSE

		for str in This.ListOfStrings()
			n = This.NumberOfOccurrenceCS(str, pCaseSensitive)

			if n > 1
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsDuplicatedStringItemsCS(pCaseSensitive)
			return This.ContainsDuplicatedStringsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedStrings()
		return This.ContainsDuplicatedStringsCS(:CaseSensitive = TRUE)
	
		def ContainsDuplicatedStringItems()
			return This.ContainsDuplicatedStrings()

	  #----------------------------------------------#
	 #   CHECHKING IF A STRING-ITEM IS DUPLICATED   #
	#----------------------------------------------#

	def ContainsDuplicatedCS(pcString, pCaseSensitive)
		if This.NumberOfOccurrencesCS(pcString, pCaseSensitive) > 1
			return TRUE
		else
			return FALSE
		ok

		def ContainsDuplicatedStringCS(pcString, pCaseSensitive)
			return This.ContainsDuplicatedCS(pcString, pCaseSensitive)

		def ContainsDuplicatedStringItemCS(pcString, pCaseSensitive)
			return This.ContainsDuplicatedCS(pcString, pCaseSensitive)

		def ContainsThisDuplicatedStringCS(pcString, pCaseSensitive)
			return This.ContainsDuplicatedCS(pcString, pCaseSensitive)

		def ContainsThisDuplicatedStringItemCS(pcString, pCaseSensitive)
			return This.ContainsDuplicatedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicated(pcString)
		return This.ContainsDuplicatedCS(pcString, :CaseSensitive = TRUE)

		def ContainsDuplicatedString(pcString)
			return This.ContainsDuplicated(pcString)

		def ContainsDuplicatedStringItem(pcString)
			return This.ContainsDuplicatedCS(pcString)

		def ContainsThisDuplicatedString(pcString)
			return This.ContainsDuplicated(pcString)

		def ContainsThisDuplicatedStringItem(pcString)
			return This.ContainsDuplicated(pcString)

	  #------------------------------------------------------#
	 #   CHECHKING IF A STRING-ITEM IS DUPLICATED N-TIMES   #
	#------------------------------------------------------#

	def ContainsDuplicatedNTimesCS(pcStr, n, pCaseSensitive)
		if This.NumberOfDuplicatesOfStringCS(pcStr, pCaseSensitive) = n
			return TRUE
		else
			return FALSE
		ok

		def ContainsThisDuplicatedStringNTimesCS(pcString, n, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(pcString, n, pCaseSensitive)

		def ContainsThisDuplicatedStringItemNTimesCS(pcString, n, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(pcString, n, pCaseSensitive)

		def StringIsDuplicatedNTimesCS(pcString, n, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(pcString, n, pCaseSensitive)

		def StringItemIsDuplicatedNTimesCS(pcString, n, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(pcString, n, pCaseSensitive)
 
	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedNTimes(pcString, n)
		return This.ContainsDuplicatedNTimesCS(pcString, n, :CaseSensitive = TRUE)

		def ContainsThisDuplicatedStringNTimes(pcString, n)
			return This.ContainsDuplicatedNTimes(pcString, n)

		def ContainsThisDuplicatedStringItemNTimes(pcString, n)
			return This.ContainsDuplicatedNTimes(pcString, n)

		def StringIsDuplicatedNTimes(pcString, n)
			return This.ContainsDuplicatedNTimes(pcString, n)

		def StringItemIsDuplicatedNTimes(pcString, n)
			return This.ContainsDuplicatedNTimes(pcString, n)
 
	  #---------------------------------------------#
	 #   HOW MANY TIMES A STRING IS DUPLICATED ?   #
	#---------------------------------------------#

	def NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)
		nResult = 0

		if This.NumberOfOccurrenceCS(pcString, pCaseSensitive) > 1
			nResult = This.NumberOfOccurrence(pcString) - 1
		ok
		
		return nResult

		def NumberOfTimesStringItemIsDuplicatedCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		def NumberOfTimesThisStringIsDuplicatedCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		def NumberOfTimesThisStringItemIsDuplicatedCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		#--

		def NumberOfDuplicatesOfStringCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		def NumberOfDuplicatesOfStringItemCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfTimesStringIsDuplicated(pcString)
		return This.NumberOfTimesStringIsDuplicatedCS(pcString, :CaseSensitive = TRUE)

		def NumberOfTimesStringItemIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		#--

		def NumberOfTimesThisStringIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfTimesThisStringItemIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		#--

		def NumberOfDuplicatesOfString(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfDuplicatesOfStringItem(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

	  #------------------------------#
	 #   NUMBER OF ALL DUPLICATES   #
	#------------------------------#

	def NumberOfDuplicatesCS(pCaseSensitive)
		nResult = 0

		for str in This.DuplicatedStringsCS(pCaseSensitive)
			nResult += ( This.NumberOfOccurrenceCS(str, pCaseSensitive) - 1 )
		next

		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(:CaseSensitive = TRUE)

	  #------------------------#
	 #   DUPLICATED STRINGS   #
	#------------------------#

	def DuplicatedStringsCS(pCaseSensitive)
		aResult = []
		for str in This.ListOfStrings()
			if This.ContainsDuplicatedStringCS(str, pCaseSensitive) and 
			   StzListOfStringsQ( aResult ).ContainsNoCS( str, pCaseSensitive )
			
				aResult + str
			ok
		next
		return aResult
		
		#< @FunctionFluentForm

		def DuplicatedStringsCSQ(pCaseSensitive)
			return This.DuplicatedStringsCSQR(pCaseSensitive, :stzList)

		def DuplicatedStringsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.DuplicatedStringsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.DuplicatedStringsCS(pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def DuplicatedStringItemsCS(pCaseSensitive)
			return This.DuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringItemsCSQ(pCaseSensitive)
				return This.DuplicatedStringItemsCSQR(pCaseSensitive, :stzList)
	
			def DuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.DuplicatedStringItemsCS(pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.DuplicatedStringItemsCS(pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def DuplicatedStrings()
		return This.DuplicatedStringsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def DuplicatedStringsQ()
			return This.DuplicatedStringsQR(:stzList)

		def DuplicatedStringsQR(pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.DuplicatedStrings() )

			on :stzListOfStrings
				return new stzListOfStrings( This.DuplicatedStrings() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def DuplicatedStringItems()
			return This.DuplicatedStrings()

			def DuplicatedStringItemsQ()
				return This.DuplicatedStringItemsQR(:stzList)
	
			def DuplicatedStringItemsQR(pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.DuplicatedStringItems() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.DuplicatedStringItems() )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #--------------------------------#
	 #   FINDING DUPLICATED STRINGS   #
	#--------------------------------#

	def FindDuplicatedStringsCS(pCaseSensitive)
		anResult = []

		acDuplicated = This.DuplicatedStringsCS(pCaseSensitive)

		for str in acDuplicated
			anResult + This.FindFirstCS(str, pCaseSensitive)
		next

		return sort( anResult )

		
		#< @FunctionFluentForm

		def FindDuplicatedStringsCSQ(pCaseSensitive)
			return This.FindDuplicatedStringsCSQR(pCaseSensitive, :stzList)

		def FindDuplicatedStringsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStringsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.FindDuplicatedStringsCS(pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindDuplicatedStringItemsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def FindDuplicatedStringItemsCSQ(pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, :stzList)
	
			def FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItemsCS(pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItemsCS(pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def PositionsOfDuplicatedStringsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def PositionsOfDuplicatedStringsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringsCSQR(pCaseSensitive, pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def DuplicatedStringsPositionsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringsPositionsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def DuplicatedStringsPositionsCSQR(pCaseSensitive, pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def PositionsOfDuplicatedStringItemsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def PositionsOfDuplicatedStringItemsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringItemsCSQR(pCaseSensitive, pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def DuplicatedStringItemsPositionsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringItemsPositionsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def DuplicatedStringItemsPositionsCSQR(pCaseSensitive, pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatedStrings()
		return This.FindDuplicatedStringsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def FindDuplicatedStringsQ()
			return This.FindDuplicatedStringsQR(:stzList)

		def FindDuplicatedStringsQR(pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStrings() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedStrings() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindDuplicatedStringItems()
			return This.FindDuplicatedStrings()

			def FindDuplicatedStringItemsQ()
				return This.FindDuplicatedStringItemsQR(:stzList)
	
			def FindDuplicatedStringItemsQR(pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItems() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindDuplicatedStringItems() )
	
				other
					stzRaise("Unsupported return type!")
				off

		def PositionsOfDuplicatedStrings()
			return This.FindDuplicatedStrings()

			def PositionsOfDuplicatedStringsQ()
				return This.PositionsOfDuplicatedStringsQR(:stzList)

			def PositionsOfDuplicatedStringsQR(pCaseSensitive)
				return This.FindDuplicatedStringItemsQR(pcReturntype)

		def DuplicatedStringsPositions()
			return This.FindDuplicatedStrings()

			def DuplicatedStringsPositionsQ()
				return This.PositionsOfDuplicatedStringsQR(:stzList)

			def DuplicatedStringsPositionsQR(pCaseSensitive)
				return This.FindDuplicatedStringItemsQR(pcReturntype)

		def PositionsOfDuplicatedStringItems()
			return This.FindDuplicatedStrings()

			def PositionsOfDuplicatedStringItemsQ()
				return This.PositionsOfDuplicatedStringsQR(:stzList)

			def PositionsOfDuplicatedStringItemsQR(pCaseSensitive)
				return This.FindDuplicatedStringItemsQR(pcReturntype)

		def DuplicatedStringItemsPositions()
			return This.FindDuplicatedStrings()

			def DuplicatedStringItemsPositionsQ()
				return This.PositionsOfDuplicatedStringsQR(:stzList)

			def DuplicatedStringItemsPositionsQR(pCaseSensitive)
				return This.FindDuplicatedStringItemsQR(pcReturntype)

		#>

	  #---------------------------------------#
	 #   FINDING A GIVEN DUPLICATED STRING   #
	#---------------------------------------#

	def FindDuplicatedStringCS(pcString, pCaseSensitive)

		if isList(pcString) and Q(pcString).IsOfNamedParamList()
			pcString = pcString[2]
		ok

		n = This.DuplicatedStringsCSQR(pCaseSensitive, :stzListOfStrings).
			  FindFirstCS(pcString, pCaseSensitive)

		nResult = This.FindDuplicatedStringsCS(pCaseSensitive)[n]

		return nResult

		#< @FunctionFluentForm

		def FindDuplicatedStringCSQ(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCSQR(pcString, pCaseSensitive, :stzList)

		def FindDuplicatedStringCSQR(pcString, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStringCS(pcString, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedStringCS(pcString, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindDuplicatedStringItemCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def FindDuplicatedStringItemCSQ(pcString, pCaseSensitive)
				return This.FindDuplicatedStringItemCSQR(pcString, pCaseSensitive, :stzList)
	
			def FindDuplicatedStringItemCSQR(pcString, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItemCS(pcString, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItemCS(pcString, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindDuplicatedCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def FindDuplicatedCSQ(pcString, pCaseSensitive)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, :stzList)
	
			def FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedCS(pcString, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedCS(pcString, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def PositionsOfDuplicatedStringCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def PositionsOfDuplicatedStringCSQ(pcString, pCaseSensitive)
				return This.PositionsOfDuplicatedStringCSQR(pcString, pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringCSQR(pcString, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)

		def DuplicatedStringPositionsCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def DuplicatedStringPositionsCSQ(pcString, pCaseSensitive)
				return This.PositionsOfDuplicatedStringCSQR(pcString, pCaseSensitive, :stzList)

			def DuplicatedStringPositionsCSQR(pcString, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)

		def PositionsOfDuplicatedStringItemCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringItemCS(pcString, pCaseSensitive)

			def PositionsOfDuplicatedStringItemCSQ(pcString, pCaseSensitive)
				return This.PositionsOfDuplicatedStringItemCSQR(pcString, pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringItemCSQR(pcString, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)

		def DuplicatedStringItemPositionsCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def DuplicatedStringItemPositionsCSQ(pcString, pCaseSensitive)
				return This.PositionsOfDuplicatedStringCSQR(pcString, pCaseSensitive, :stzList)

			def DuplicatedStringItemPositionsCSQR(pcString, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatedString(pcString)

		return This.FindDuplicatedStringCS(pcString, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindDuplicatedStringQ(pcString)
			return This.FindDuplicatedStringQR(pcString, :stzList)

		def FindDuplicatedStringQR(pcString, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedString(pcString) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedString(pcString) )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindDuplicatedStringItem(pcString)
			return This.FindDuplicatedString(pcString)

			def FindDuplicatedStringItemQ(pcString)
				return This.FindDuplicatedStringItemQR(pcString, :stzList)
	
			def FindDuplicatedStringItemQR(pcString, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItem(pcString) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItem(pcString) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindDuplicated(pcString)
			return This.FindDuplicatedString(pcString)

			def FindDuplicatedQ(pcString)
				return This.FindDuplicatedQR(pcString, :stzList)
	
			def FindDuplicatedQR(pcString, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicated(pcString) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicated(pcString) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def PositionsOfDuplicatedString(pcString)
			return This.FindDuplicatedString(pcString)

			def PositionsOfDuplicatedStringQ(pcString)
				return This.PositionsOfDuplicatedStringQR(pcString, :stzList)

			def PositionsOfDuplicatedStringQR(pcString, pcReturnType)
				return This.FindDuplicatedQR(pcString, pcReturnType)

		def DuplicatedStringPositions(pcString)
			return This.FindDuplicatedString(pcString)

			def DuplicatedStringPositionsQ(pcString)
				return This.PositionsOfDuplicatedStringQR(pcString, :stzList)

			def DuplicatedStringPositionsQR(pcString, pcReturnType)
				return This.FindDuplicatedQR(pcString, pcReturnType)

		def PositionsOfDuplicatedStringItem(pcString)
			return This.FindDuplicatedStringItem(pcString)

			def PositionsOfDuplicatedStringItemQ(pcString)
				return This.PositionsOfDuplicatedStringItemQR(pcString, :stzList)

			def PositionsOfDuplicatedStringItemQR(pcString, pcReturnType)
				return This.FindDuplicatedQR(pcString, pcReturnType)

		def DuplicatedStringItemPositions(pcString)
			return This.FindDuplicatedString(pcString)

			def DuplicatedStringItemPositionsQ(pcString)
				return This.PositionsOfDuplicatedStringQR(pcString, :stzList)

			def DuplicatedStringItemPositionsQR(pcString, pcReturnType)
				return This.FindDuplicatedQR(pcString, pcReturnType)

		#>

	  #----------------------------#
	 #   FINDING ALL DUPLICATES   #
	#----------------------------#

	def FindDuplicatesCS(pCaseSensitive)
				
		anPositions = []
		for str in This.DuplicatedStringsCS(pCaseSensitive)
			anPositions + This.FindAllExceptFirstCS(str, pCaseSensitive)
		next

		anResult = sort( ListsMerge( anPositions ) )

		return anResult

		#< @FunctionFluentForm

		def FindDuplicatesCSQ(pCaseSensitive)
			return This.FindDuplicatesCSQR(pCaseSensitive, :stzList)

		def FindDuplicatesCSQR(pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatesCS(pCaseSensitive) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatesCS(pCaseSensitive) )
	
			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def PositionsOfDuplicatesCS(pCaseSensitive)
			return This.FindDuplicatesCS(pCaseSensitive)

			def PositionsOfDuplicatesCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatesCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatesCSQR(pCaseSensitive, pcReturnType)
				return This.FindDuplicatesCSQR(pCaseSensitive, pcReturnType)

		def DuplicatesPositionsCS(pCaseSensitive)
			return THis.FindDuplicatesCS(pCaseSensitive)

			def DuplicatesPositionsCSQ(pCaseSensitive)
				return This.DuplicatesPositionsCSQR(pCaseSensitive, :stzList)

			def DuplicatesPositionsCSQR(pCaseSensitive, pcReturnType)
				return This.FindDuplicatesCSQR(pCaseSensitive, pcReturnType)

		#>

	##-- WITHOUT CASESENSITIVITY

	def FindDuplicates()
				
		return This.FindDuplicatesCS( :CaseSensitive = TRUE )

		#< @FunctionFluentForm

		def FindDuplicatesQ()
			return This.FindDuplicatesQR(:stzList)

		def FindDuplicatesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicates() )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicates() )
	
			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def PositionsOfDuplicates()
			return This.FindDuplicates()

			def PositionsOfDuplicatesQ()
				return This.PositionsOfDuplicatesQR(:stzList)

			def PositionsOfDuplicatesQR(pCaseSensitive, pcReturnType)
				return This.FindDuplicatesQR(pcReturnType)

		def DuplicatesPositions()
			return THis.FindDuplicates()

			def DuplicatesPositionsCQ()
				return This.DuplicatesPositionsQR(:stzList)

			def DuplicatesPositionsQR(pcReturnType)
				return This.FindDuplicatesQR(pcReturnType)

		#>

	  #-----------------------------------------------#
	 #   FINDING DUPLICATES OF A GIVEN STRING-ITEM   #
	#-----------------------------------------------#

	def FindDuplicatesOfStringCS(pcStr, pCaseSensitive)

		aResult = This.FindAllExceptFirstCS(pcStr, pCaseSensitive)
		return aResult

		def FindDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)

		def PositionsOfDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)

		def DuplicatesOfStringItemPositionsCS(pcStr, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatesOfString(pcStr)
		return This.FindDuplicatesOfStringCS(pcStr, :CaseSensitive = TRUE)

		def FindDuplicatesOfStringItem(pcStr)
			return This.FindDuplicatesOfString(pcStr)

		def PositionsOfDuplicatesOfStringItem(pcStr)
			return This.FindDuplicatesOfString(pcStr)

		def DuplicatesOfStringItemPositions(pcStr)
			return This.FindDuplicatesOfString(pcStr)

	  #------------------------------------#
	 #   FINDING DUPLICATES -- EXTENDED   #
	#------------------------------------#

	def FindDuplicatesXTCS(pCaseSensitive)
		aResult = []
		
		for str in This.DuplicatedStringsCS(pCaseSensitive)
			aResult + [ str, This.FindDuplicatesOfStringCS(str, pCaseSensitive) ]
		next

		return aResult

		#< @FunctionFluentForm

		def FindDuplicatesXTCSQ(pCaseSensitive)
			return This.FindDuplicatesXTCSQR(pCaseSensitive, :stzList)

		def FindDuplicatesXTCSQR(pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatesXTCS(pCaseSensitive) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatesXTCS(pCaseSensitive) )
	
			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FuntionAlternativeForms

		def PositionsOfDuplicatesXTCS(pCaseSensitive)
			return This.FindDuplicatesXTCS(pCaseSensitive)

		def DuplicatesPositionsXTCS(pCaseSensitive)
			return This.FindDuplicatesXTCS(pCaseSensitive)

		#-- ...XTCS or ...CSXT? No problem at all ;)

		def FindDuplicatesCSXT(pCaseSensitive)
			return This.FindDuplicatesXTCS(pCaseSensitive)

		def PositionsOfDuplicatesCSXT(pCaseSensitive)
			return This.FindDuplicatesXTCS(pCaseSensitive)

		def DuplicatesPositionsCSXT(pCaseSensitive)
			return This.FindDuplicatesXTCS(pCaseSensitive)


		#>

	##-- WITHOUT CASESENSITIVITY

	def FindDuplicatesXT()
		return This.FindDuplicatesXTCS( :CaseSensitive = TRUE )

		#< @functionFluentForm

		def FindDuplicatesXTQ()
			return This.FindDuplicatesXTQR(:stzList)

		def FindDuplicatesXTQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			if NOT isString(pcReturnType)
				stzRaise("Incorrect param type! pcReturnType must be a string.")
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatesXT() )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatesXT() )
	
			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FuntionAlternativeForms

		def PositionsOfDuplicatesXT()
			return This.FindDuplicatesXT()

		def DuplicatesPositionsXT()
			return This.FindDuplicatesXT()

		#>

	  #----------------------------------------------------#
	 #   REMOVING ALL DUPLICATES IN THE LIST of STRINGS   #
	#----------------------------------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)
		anPositions = This.FindDuplicatesCS(pCaseSensitive)
		This.RemoveStringsAtPositions(anPositions)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This
		
	def DuplicatesRemovedCS(pCaseSensitive)
		acResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return acResult

		def ToSetCS(pCaseSensitive)
			return This.RemoveDuplicatesCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(:CaseSensitive = TRUE)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This
		
	def DuplicatesRemoved()
		acResult = This.Copy().RemoveDuplicatesQ().Content()
		return acResult

		def ToSet()
			return This.RemoveDuplicates()
	
  	  #------------------------------------------------#
	 #   REMOVING DUPLICATES OF A GIVEN STRING-ITEM   #
	#------------------------------------------------#

	def RemoveDuplicatesOfStringCS(pcStr, pCaseSensitive)
		anPositions = This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)
		This.RemoveStringsAtPositions(anPositions)

		#< @FunctionFluentForm

		def RemoveDuplicatesOfStringCSQ(pcStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringCS(pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveDuplicatesOfThisStringCS(pcStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringCS(pcStr, pCaseSensitive)

			def RemoveDuplicatesOfThisStringCSQ(pcStr, pCaseSensitive)
				This.RemoveDuplicatesOfThisStringCS(pcStr, pCaseSensitive)
				return This

		def RemoveDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringCS(pcStr, pCaseSensitive)

			def RemoveDuplicatesOfStringItemCSQ(pcStr, pCaseSensitive)
				This.RemoveDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
				return This

		def RemoveDuplicatesOfThisStringItemCS(pcStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringCS(pcStr, pCaseSensitive)

			def RemoveDuplicatesOfThisStringItemCSQ(pcStr, pCaseSensitive)
				This.RemoveDuplicatesOfThisStringItemCS(pcStr, pCaseSensitive)
				return This

		#>

	def DuplicatesOfStringRemovedCS(pcStr, pCaseSensitive)

		acResult = This.Copy().
				RemoveDuplicatesOfStringCSQ(pcStr, pCaseSensitive).
				Content()

		return acResult

		#< @FunctionAlternativeForms

		def DuplicatesOfThisStringRemovedCS(pcStr, pCaseSensitive)
			return This.DuplicatesOfStringRemovedCS(pcStr, pCaseSensitive)

		def DuplicatesOfStringItemRemovedCS(pcStr, pCaseSensitive)
			return This.DuplicatesOfStringRemovedCS(pcStr, pCaseSensitive)
 
		def DuplicatesOfThisStringItemRemovedCS(pcStr, pCaseSensitive)
			return This.DuplicatesOfStringRemovedCS(pcStr, pCaseSensitive)
 
		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatesOfString(pcStr)
		This.RemoveDuplicatesOfStringCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveDuplicatesOfStringQ(pcStr)
			This.RemoveDuplicatesOfString(pcStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveDuplicatesOfThisString(pcStr)
			This.RemoveDuplicatesOfString(pcStr)

			def RemoveDuplicatesOfThisStringQ(pcStr)
				This.RemoveDuplicatesOfThisString(pcStr)
				return This

		def RemoveDuplicatesOfStringItem(pcStr)
			This.RemoveDuplicatesOfString(pcStr)

			def RemoveDuplicatesOfStringItemQ(pcStr)
				This.RemoveDuplicatesOfStringItem(pcStr)
				return This

		def RemoveDuplicatesOfThisStringItem(pcStr)
			This.RemoveDuplicatesOfString(pcStr)

			def RemoveDuplicatesOfThisStringItemQ(pcStr)
				This.RemoveDuplicatesOfThisStringItem(pcStr)
				return This

		#>

	def DuplicatesOfStringRemoved(pcStr)
		return This.DuplicatesOfStringRemovedCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def DuplicatesOfThisStringRemoved(pcStr)
			return This.DuplicatesOfStringRemoved(pcStr)

		def DuplicatesOfStringItemRemoved(pcStr)
			return This.DuplicatesOfStringRemoved(pcStr)
 
		def DuplicatesOfThisStringItemRemoved(pcStr)
			return This.DuplicatesOfStringRemoved(pcStr)
 
		#>

	  #----------------------------------------------------#
	 #   REMOVING DUPLICATES OF MANY GIVEN STRING-ITEMS   #
	#----------------------------------------------------#

	def RemoveDuplicatesOfStringsCS(pacStr, pCaseSensitive)
		if NOT (isList(pacStr) and Q(pacStr).IsListOfStrings() )

			stzRaise("Incorrect param! pacStr must be a list of strings.")
		ok

		for str in pacStr
			This.RemoveDuplicatesOfStringCS(str, pCaseSensitive)
		next

		#< @FuntionFluentForm

		def RemoveDuplicatesOfStringsCSQ(pacStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringsCS(pacStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def  RemoveDuplicatesOfTheseStringsCS(pacStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringsCS(pacStr, pCaseSensitive)

			def RemoveDuplicatesOfTheseStringsCSQ(pacStr, pCaseSensitive)
				This.RemoveDuplicatesOfTheseStringsCS(pacStr, pCaseSensitive)
				return This

		def  RemoveDuplicatesOfStringItemsCS(pacStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringsCS(pacStr, pCaseSensitive)

			def RemoveDuplicatesOfStringItemsCSQ(pacStr, pCaseSensitive)
				This.RemoveDuplicatesOfStringItemsCS(pacStr, pCaseSensitive)
				return This

		def  RemoveDuplicatesOfTheseStringItemsCS(pacStr, pCaseSensitive)
			This.RemoveDuplicatesOfStringsCS(pacStr, pCaseSensitive)

			def RemoveDuplicatesOfTheseStringItemsCSQ(pacStr, pCaseSensitive)
				This.RemoveDuplicatesOfTheseStringItemsCS(pacStr, pCaseSensitive)
				return This

		#>
		
	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatesOfStrings(pacStr)
		This.RemoveDuplicatesOfStringsCS(pacStr, :CaseSensitive = TRUE)

		#< @FuntionFluentForm

		def RemoveDuplicatesOfStringsQ(pacStr)
			This.RemoveDuplicatesOfStrings(pacStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def  RemoveDuplicatesOfTheseStrings(pacStr)
			This.RemoveDuplicatesOfStrings(pacStr)

			def RemoveDuplicatesOfTheseStringsQ(pacStr)
				This.RemoveDuplicatesOfTheseStrings(pacStr)
				return This

		def  RemoveDuplicatesOfStringItems(pacStr)
			This.RemoveDuplicatesOfStrings(pacStr)

			def RemoveDuplicatesOfStringItemsQ(pacStr)
				This.RemoveDuplicatesOfStringItems(pacStr)
				return This

		def  RemoveDuplicatesOfTheseStringItems(pacStr)
			This.RemoveDuplicatesOfStrings(pacStr)

			def RemoveDuplicatesOfTheseStringItemsQ(pacStr)
				This.RemoveDuplicatesOfTheseStringItems(pacStr)
				return This

		#>

	  #============================================================#
	 #   UNIQUE CHARS APPEARING IN ALL THE STRINGS OF THE LIST    #
	#============================================================#

	def UniqueCharsCS(pCaseSensitive)
		aChars = []

		for str in This.ListOfStrings()
			aChars + StzStringQ(str).Chars()
		next

		aResult = StzListQ(aChars).MergeQ().ToStzListOfStrings().DuplicatesRemovedCS(pCaseSensitive)

		return aResult

		def UniqueCharsCSQ(pCaseSensitive)
			return This.UniqueCharsCSQR(pCaseSensitive, :stzList)

		def UniqueCharsCSQR(pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueCharsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueCharsCS(pCaseSensitive) )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueCharsCS(pCaseSensitive) )

			other
				stzRaise("Unsupported param type!")
			off

	#-- WITHOUT CASESENSITIVITY

	def UniqueChars()
		return This.UniqueCharsCS(:CaseSensitive = TRUE)

		def UniqueCharsQ()
			return This.UniqueCharsQR(:stzList)

		def UniqueCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueChars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueChars() )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueChars() )

			other
				stzRaise("Unsupported param type!")
			off

	  #------------------------------------------------------------#
	 #   COMMON CHARS APPEARING IN ALL THE STRINGS OF THE LIST    #
	#------------------------------------------------------------#

	def CommonCharsCS(pCaseSensitive)
		aResult = []

		for str in This.ListOfStrings()
			for c in str
				if This.ContainsSubStringInEachStringCS(c, pCaseSensitive) and
				   StzListOfStringsQ(aResult).ContainsNoCS(c, pCaseSensitive)
					aResult + c
				ok
			next	
		next

		return aResult


		def CommonCharsCSQ(pCaseSensitive)
			return This.CommonCharsCSQR(:stzList, pCaseSensitive)
	
		def CommonCharsCSQR(pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.CommonCharsCS() )
			on :stzListOfChars
				return new stzListOfChars( This.CommonCharsCS() )
			on :stzListOfStrings
				return new stzListOfStrings( This.CommonCharsCS() )
			other
				stzRaise("Unsupported return type!")
			off

	#-- WITHOUT CASESENSITIVITY

	def CommonChars()
		return This.CommonCharsCS(:CaseSensitive = TRUE)

		def CommonCharsQ()
			return This.CommonCharsQR(:stzList)
	
		def CommonCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.CommonChars() )
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

		def AllStringItemsAreLowercase()
			return This.AllStringsAreLowercase()

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

		def AllStringItemsAreUppercase()
			return This.AllStringsAreUppercase()

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
			This.BoxXT(paBoxOptions)
			return This

	def BoxedXT(paBoxOptions)

		acResult = This.Copy().BoxXTQ(paBoxOptions).Content()
		return acResult

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
			This.ReplaceStringAtPosition(i, cStrAligned )
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

	def IsStzListOfStrings()
		return TRUE

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
		but pcOp = "<<"
			This.Prepend(value)

		// Add an item at the end of the list
		but pcOp = ">>"
			This.Append(value)

		but pcOp = "="
			return This.ToStzList().IsEqualTo(value)

		but pcOp = "=="
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
