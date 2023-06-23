#-------------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - stzListOfStrings			#
#		 An accelerative library for Ring applications	      		#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The core class for managing lists of strings		#
#	Version		: V1.0 (2020-2022)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#										#
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
		StzRaise(stzListOfStringsError(:CanNotTransformQStringListToRingList))
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
			StzRaise("A QStringList Qt object is exepected as a param!")
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
			nLen = len(pList)

			for i = 1 to nLen
				@oQStrList.append(pList[i])	
			next

		but isString(pList)

			try
				aList = StzStringQ(pList).ToList()

				if StzListQ(aList).IsListOfStrings()
					@oQStrList = new QStringList()
					nLen = len(aList)

					for i = 1 to len(aList)
						@oQStrList.append(aList[i])
					next

				else
					StzRaise("The list in the string you provided is not a list of strings!")
				ok
			catch
				StzRaise("Can't transform the string to a list!")
			done
			
		else
			StzRaise([
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
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.StringItems() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItems() )
	
				other
					StzRaise("Unsupported return type!")
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
					
	def StringsW(pcCondition)
		return This.YieldW('This[@i]', pcCondition)

		def StringsWQ(pcCondition)
			return StringsWQR(pcCondition, :stzList)

		def StringsWQR(pcCondition, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringsW(pcCondition) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringsW(pcCondition) )

			other
				StzRaise("Unsupported return type!")
			off

	def UniqueStringsW(pcCondition)
		acResult = This.YieldWQR('This[@i]', pcCondition, :stzListOfStrings).
				DuplicatesRemoved()

		return acResult

		def UniqueStringsWQ(pcCondition)
			return UniqueStringsWQR(pcCondition, :stzList)

		def UniqueStringsWQR(pcCondition, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringsW(pcCondition) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringsW(pcCondition) )

			other
				StzRaise("Unsupported return type!")
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

		def HowManyStrings()
			return This.NumberOfStringItems()

		def HowManyStringItems()
			return This.NumberOfStringItems()

	  #------------------------------------------------------------#
	 #    GETTING THE SIZE IN BYTES OF THE LIST AND ITS ITEMS     #
	#------------------------------------------------------------#

	def SizeInBytes()
		nSizeInBytes = 0
		nLen = This.NumberOfStrings()

		for i = 1 to nLen 
			oBinStr = new stzListOfBytes(This.String(i))
			nSizeInBytes += oBinStr.SizeInBytes()
		next

		return nSizeInBytes

		def NumberOfBytes()
			return This.SizeInBytes()

		def HowManyBytes()
			return This.SizeInBytes()

	def SizeInBytesOfEachStringItem()
		anResult = []
		nLen = This.NumberOfStrings()
	
		for i = 1 to nLen
			oBinStr = new stzListOfBytes(This.String(i))
			anResult + oBinStr.SizeInBytes()
		next

		return anResult

		def SizeInBytesOfEachString()
			return This.SizeInBytesOfEachStringItem()

		def NumberOfBytesInEachStringItem()
			return This.SizeInBytesOfEachStringItem()

		def NumberOfBytesInEachString()
			return This.SizeInBytesOfEachStringItem()

		def HowManyBytesInEachString()
			return This.SizeInBytesOfEachStringItem()

		def HowManyButesInEachStringItem()
			return This.SizeInBytesOfEachStringItem()


	def StringItemsAndTheirSizesInBytes()
		aResult = []
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			str = This.String(i)
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
			StzRaise("Incorrect param! n must be a number.")
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
			( Q(n1).IsFromNamedParam() or
			  Q(n1).IsFromPositionNamedParam()  )

			n1 = n1[2]
		ok

		if isList(n2) and ( Q(n2).IsToNamedParam() or Q(n2).IsToPositionNamedParam() )
			n2 = n2[2]
		ok

		if isString(n1) and ( Q(n1).IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ]) )
			n1 = 1
		ok

		if isString(n2) and ( Q(n2).IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ]) )

			n2 = This.NumberOfStrings()
		ok

		if NOT isNumber(n1) and isNumber(n2)
			StzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		# Doing the job

		return This.ToStzList().Section(n1, n2)

		#< @FunctionFluentForm

		def SectionQ(n1, n2)
			return This.SectionQR(n1, n2, :stzList)

		def SectionQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Unsupported return type!")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Section(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Section(n1, n2) )

			other
				StzRaise("Unsupported return type!")
			off
				
		#>

		#< @FunctionAlternativeForm

		def Slice(n1, n2)
			return This.Section(n1, n2)

			def SliceQ(n1, n2)
				return This.SliceQR(n1, n2, :stzList)
	
			def SliceQR(n1, n2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Unsupported return type!")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Slice(n1, n2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Slice(n1, n2) )
	
				other
					StzRaise("Unsupported return type!")
				off
		#>

	  #----------------------------------#
	 #    GETTING A RANGE OF STRINGS    #
	#----------------------------------#

	def Range(nStart, nRange)
		# Checking the correctness of the pnStart param

		if isList(pnStart) and Q(pnStart).IsFromNamedParam()
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
			StzRaise("Incorrect param! n must be a number.")
		ok

		# Checking the correctness of the pnRange param

		if isList(pnRange) and
		   isString(pnRange[1]) and

		   ( Q(pnRange[1]).IsOneOfTheseCS([ :UpToN, :UpToNStrings, :UpToNStringItems ]) )

		   	pnRange = pnRange[2]
		ok
	
		if NOT isNumber(pnRange)
			StzRaise("Incorrect param type! pnRange must be a number.")
		ok

		# Checking the correctness of the range of the two params

		nLen = This.NumberOfStrings()

		if (pnStart < 1) or (pnStart + pnRange -1 > nLen) or
		   ( pnStart = nLen and pnRange != 1 )
			StzRaise("Out of range!")
		ok

		# Doing the job

		return This.ToStzList().Range(nStart, nRange)

		#< @FunctionFluentForm

		def RangeQ(n1, n2)
			return This.RangeQR(n1, n2, :stzList)

		def RangeQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Unsupported return type!")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Range(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Range(n1, n2) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType mst be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FirstNStrings(n) )

			on :stzListOfStrings
				retutn new stzListOfStrings( This.FirstNStrings(n) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsAtPositions(panPositions) )

			on :stzListOfStrings
				return new stzList( This.StringItemsAtPositions(panPositions) )

			other
				StzRaise("Unsupported return type!")
			off

		def StringItemsAtThesePositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringItemsAtThesePositionsQ(panPositions)
				return This.StringItemsAtThesePositionsQR(panPositions, :stzList)
	
			def StringItemsAtThesePositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsAtThesePositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringItemsAtThesePositions(panPositions) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def StringsAtPositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringsAtPositionsQ(panPositions)
				return This.StringsAtPositionsQR(panPositions, :stzList)
	
			def StringsAtPositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsAtPositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringsAtPositions(panPositions) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def StringsAtThesePositions(panPositions)
			return This.StringItemsAtPositions(panPositions)

			def StringsAtThesePositionsQ(panPositions)
				return This.StringsAtThesePositionsQR(panPositions, :stzList)
	
			def StringsAtThesePositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsAtThesePositions(panPositions) )
	
				on :stzListOfStrings
					return new stzList( This.StringsAtThesePositions(panPositions) )
	
				other
					StzRaise("Unsupported return type!")
				off

	  #-------------------------------------------------------------#
	 #    APPENDING THE LIST WITH A STRING (AT THE END OF LIST)    #
	#-------------------------------------------------------------#

	def AddStringItem(pcStrItem)
		if isString(pcStrItem)
			This.QStringListObject().append(pcStrItem)
		else
			StzRaise( stzListOfStringsError(:CanNotAddNonStringItem) )
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
			StzRaise( stzListOfStringsError(:CanNotAddNonStringItem) )
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

		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			This.ReplaceStringAtPosition(i, This.String(i) + pcSubStr)
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
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			This.ReplaceStringAtPosition(i, pcSubStr + This.String(i))
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

	  #-------------------------------------------------------#
	 #  INSERTING A STRING BEFORE OR AFTER A GIVEN POSITION  #
	#-------------------------------------------------------#

	def Insert(pcStr, pWhere)
		/*
		o1 = new stzListOfStrings([ "A", "C", "D" ])
		o1.Insert("B", :At = 2)		# or you can say: o1.InsertAt(2, "B")
		? o1.Content()
		#--> [ "A", "B", "C", "D" ]
		*/

		if isList(pcStr) and Q(pcStr).IsStringNamedParam()
			pcStr = pcStr[2]
		ok

		if NOT isString(pcStr)
			stzSrring("Incorrect param type! pcStr must be a string.")
		ok

		if isList(pWhere)
			if Q(pWhere).IsOneOfTheseNamedParams([
				:Before, :BeforePosition, :At, :AtPosition ])

				This.InsertBefore(pWhere[2], pcStr)

			but Q(pWhere).IsOneTheseNamedParams([ :After, :AfterPosition ])

				This.InsertAfter(pWhere[2], pcStr)

			else
				StzRaise("Incorrect param format! Allowerd forms are :At = ..., :Before = ..., and :After = ...")
			ok
		else
			This.InsertBefore(pWhere, pcStr)
		ok
		
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
			StzRaise("Incorrect param! n must be a number.")
		ok

		# Doing the job

		if isString(pcStr)
			This.QStringListObject().insert(n-1, pcStr)
		else
			StzRaise( stzListOfStringsError(:CanNotInsertNonStringItem) )
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

		def InsertAt(n, pcStr)
			This.InsertBefore(n, pcStr)

			def InsertAtQ(n, pcStr)
				This.InsertAt(n, pcStr)
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
			StzRaise("Incorrect param! n must be a number.")
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
		
	  #------------------------------------------------------------------------#
	 #    INSERTING A SUBSTRING BEFORE NTH CHAR OF EACH STRING IN THE LIST    #
	#------------------------------------------------------------------------#

	def InsertBeforeInEach(n, pcSubStr)
		acResult = []
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			acResult + ( Q(This.String(i)).InsertBeforeQ(n, pcSubStr).Content() )
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
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			acResult + ( Q(This.String(i)).InsertAfterQ(n, pcSubStr).Content() )
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
		   ( StzListQ(pNewListOfStr).IsWithNamedParam() or StzListQ(pNewListOfStr).IsUsingNamedParam() )

			pNewListOfStr = pNewListOfStr[2]

		ok

		if IsQStringListObject(pNewListOfStr)
			@oQStrList = pNewListOfStr

		but StzListQ(pNewListOfStr).IsListOfStrings()
			This.QStringListObject().clear()
			nLen = len(pNewListOfStr)

			for i = 1 to nLen
				This.QStringListObject().append(pNewListOfStr[i])	
			next

		else
			StzRaise("Param you provided is not a list of strings!")
	
		ok

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

	  #-----------------------------------------------------------------#
	 #  CONCATENATING THE STRINGS USING A GIVEN SEPARATOR -- EXTENDED  #
	#-----------------------------------------------------------------#

	def ConcatenateUsingXT(pStr, paOptions)
		# The only supported option for now is :LastSep = "..."

		if isList(paOptions) and Q(paOptions).IsLastSepNamedParam()
			return This.ConcatenateAndChangeLastSep(pStr, paOptions[2])
		ok

		def ConcatenateUsingXTQ(pStr, paOptions)
			return new stzString( This.ConcatenateUsingXT(pStr, paOptions) )

		def JoinUsingXT(pStr, paOptions)
			return This.ConcatenateUsingXT(pStr, paOptions)

			def JoinUsingXTQ(pStr, paOptions)
				return This.ConcatenateUsingXTQ(pStr, paOptions)

	def ConcatenatedUsingXT(pStr, paOptions)
		return This.ConcatenateUsingXT(pStr, paOptions)

		def JoinedUsingXT(pStr, paOptions)
			return This.ConcatenatedUsingXT(pStr, paOptions)

	  #-------------------------------------------------------------#
	 #  CONCATENATING THE STRINGS AND CHANGING THE LAST SEPARATOR  #
	#-------------------------------------------------------------#

	def ConcatenateAndChangeLastSep(pcStr, pcLast)
		#< @QtBased >

		cResult = This.SectionQR(1, This.Size()-1, :stzListOfStrings).
			       ConcatenatedUsing(pcStr)

		cResult += ( pcLast + This.LastString() )

		return cResult

		def ConcatenateAndChangeLastSepQ(pcStr)
			return new stzString( This.ConcatenateAndChangeLastSep(pcStr) )

		def JoinAndChangeLastSep()
			return This.ConcatenateAndChangeLastSep(pcStr)

			def JoinAndChangeLastSepQ(pcStr)
				return This.ConcatenateAndChangeLastSepQ(pcStr)

	def ConcatenatedAndLastSepChanged(pcStr)
		return This.ConcatenateAndChangeLastSep(pcStr)

		def JoinedAndChangeLastSep(pcStr)
			return This.ConcatenatedAndChangeLastSep(pcStr)

		def ConcatenatedWithLastSepChanged(pcStr)
			return This.ConcatenatedAndLastSepChanged(pcStr)

		def JoinedWithChangeLastSep(pcStr)
			return This.ConcatenatedAndChangeLastSep(pcStr)

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

	  #======================================#
	 #     REVERSING THE LIST OF STRINGS    #
	#======================================#

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

	  #------------------------------------------------------------------#
	 #     MOVING A STRING AT A GIVEN POSITION TO AN OTHER POSITION     #
	#------------------------------------------------------------------#

	def Move(n1, n2)

		# Checking params correctness

		if isList(n1) and
		   Q(n1).IsOneOfTheseNamedParams([
			:From, :FromPosition,
			:At, :AtPosition,
			:String, :StringItem,
			:StringAt, :StringAtPosition,
			:FromStringAt, :FromStringAtPosition,
			:StringFrom, :StringFromPosition,

			:StringItemAt, :StringItemAtPosition,
			:FromStringItemAt, :FromStringItemAtPosition,
			:StringItemFrom, :StringItemFromPosition

		   ])

			n1 = n1[2]
		ok

		if isList(n2) and
		   Q(n2).IsOneOfTheseNamedParams([
			:To, :ToPosition, :ToPositionOfString, :ToPositionOfStringItem,
			:ToString, :ToStringAt, :ToStringAtPosition,
			:ToStringItem, :ToStringItemAt, :ToStringItemPosition
			])

			n2 = n2[2]
		ok

		if isString(n1) and
		   Q(n1).IsOneOfThese([ :First, :FirstPosition, :FirstString, :FirstStringItem ])
				    
			n1 = 1
		ok

		if isString(n2) and
		   Q(n1).IsOneOfThese([ :Last, :LastPosition, :LastString, :LastStringItem ])

			n2 = This.NumberOfStrings()
		ok

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect param type! n1 and n2 must be numbers.")
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

		#>

	  #-------------------------------------------------#
	 #   SWAPPING TWO STRINGS IN THE LSIT OF STRINGS   #
	#-------------------------------------------------#

	def Swap(n1, n2)
		if isList(n1) and
		   Q(n1).IsOneOfTheseNamedParams([
			:Between, :BetweenPosition, :BetweenPositions,
			:BetweenStringAt, :BetweenStringAtPosition, :BetweenStringAtPositions,
			:BetweenStringItemAt, :BetweenStringItemAtPosition, :BetweenStringItemAtPositions,
			:BetweenString, :BetweenStringItem, :BetweenStrings, :BetweenStringItems,
			:Position, :Positions, :StringAt, :StringAtPosition, :StringAtPositions,
			:StringItemAt, :StringItemAtPosition, :StringItemAtPositions,
			:StringsAt, :StringsAtPosition, :StringsAtPositions,
			:StringItemsAt, :StringItemsAtPosition, :StringItemsAtPositions
		   ])

			n1 = n1[2]
		ok

		if isList(n2) and
		   Q(n2).IsOneOfTheseNamedPArams([
			:And, :AndPosition, :AndStringAt, :AndStringAtPosition,
			:AndStringItemAt, :AndStringItemAtPosition, :AndString, :AndStringItem ])

			n2 = n2[2]
		ok

		copy = This[n2]
		This.ReplaceStringAtPosition(n2, :By = This[n1])
		This.ReplaceStringAtPosition(n1, :By = copy)

		#< @FunctionAlternativeForms

		def SwapBetween(n1, n2)
			This.Swap(n1, n2)

		def SwapBetweenPositions(n1, n2)
			This.Swap(n1, n2)

		def SwapStrings(n1, n2)
			if isList(n1) and
			   Q(n1).IsOneOfTheseNamedParams([ :At, :AtPosition, :AtPositions ])
				n1 = n1[2]
			ok
	
			if isList(n2) and
			   Q(n2).IsOneOfTheseNamedParams([ :And, :AndPosition ])
				n2 = n2[2]
			ok
	
			This.Swap(n1, n2)

			def SwapStringItems(n1, n2)
				return This.SwapStrings(n1, n2)

		def SwapString(n1, n2)
			if isList(n1) and
			   Q(n1).IsOneOfTheseNamedParams([ :At, :AtPosition ])
				n1 = n1[2]
			ok
	
			if isList(n2) and
			   Q(n2).IsOneOfTheseNamedParams([
				:And, :AndPosition, :AndStringAt, :AndStringAtPosition ])

				n2 = n2[2]
			ok
	
			This.Swap(n1, n2)

			def SwapStringItem(n1, n2)
				This.SwapString(n1, n2)
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
 
	  #----------------------------------------#
	 #  SORTING THE STRING BY - IN ASCENDING  #
	#----------------------------------------#
 
	def SortInAscendingBy(pcExpr)
		/* EXAMPLE
		o1 = new stzListOfStrings([ "a", "abcde", "abc", "ab", "abcd" ])
		o1.SortBy('len(@item)')
		? o1.Content()

		#--> [ "a", "ab", "abc", "abcd", "abcde" ]

		*/

		if NOT (isString(pcExpr) and Q(pcExpr).ContainsCS("@string", :CS = FALSE))
			StzRaise("Incorrect param! pcExpr must be a string containing @string keyword.")
		ok

		acContent = This.Content()
		nLen = len(acContent)

		cCode = 'value = ' + Q(pcExpr).BoundsRemoved([ "{", "}" ])
		aValues = []
		
		for @i = 1 to nLen
			@string = acContent[@i]
			eval(cCode)
			aValues + value
		next

		
		oTable = new stzTable([ :COL1 = acContent, :COL2 = aValues ])
		acSorted = oTable.SortByQ(:COL2).Col(1)

		This.Update(acSorted)

		#< @FunctionFluentForm

		def SortInAscendingByQ(pcExpr)
			This.SortInAscendingBy(pcExpr)
			return This
		#>

		#< @FunctionAlternativeForms

		def SortBy(pcExpr)
			return This.SortInAscendingBy(pcExpr)

			def SortByQ(pcExpr)
				This.SortBy(pcExpr)
				return This

		#>

	def SortedByInAscendingBy(pcExpr)
		acResult = This.Copy().SortByAscendingByQ(pcExpr).Content()
		return This

		def SortedBy(pcExpr)
			return This.SortedByInAscendingBy(pcExpr)

	  #-----------------------------------------#
	 #  SORTING THE STRING BY - IN DESCENDING  #
	#-----------------------------------------#
 
	def SortInDescendingBy(pcExpr)
		acSorted = This.SortInAscendingQ(pcExpr).SortedInDescending()
		This.Update(acSorted)

		def SortInDescendingByQ(pcExp)
			This.SortInDescendingBy(pcExpr)
			return This

	def SortedInDescendingBy(pcExpr)
		acContent = This.Copy().SortInDescendingByQ(pcExpr).Content()

	  #---------------------------------------#
	 #     ASSOCIATE WITH AN ANOTHER LIST    #
	#---------------------------------------#

	// Returns an Associative List (HashList) from the main list and an other list

	def AssociateWith(paOtherList)
		/* EXAMPLE

		o1 = new stzList([ "Name", "Age", "Job" ])
		o1.AssociateWith([ "Ali", 24, "Programmer" ])
		? o1.Content()

		#--> [ "Name" = "Ali", "Age" = 24, "Job" = "Programmer" ]

		TEST: What idf the first list contains items that are not strings?
		This leads to a ListOfLists but not to a HashList!

		*/

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok

		nLenOtherList = len(paOtherList)
		nLen = This.NumberOfItems()
		aContent = This.Content()

		aResult = []
		for i = 1 to nLen
			otherItem = NULL
			if i <= nLenOtherList
				otherItem = paOtherList[i]
			ok

			aResult + [ aContent[i], otherItem ]
		next

		This.Update( aResult )

		def AssociateWithQ(paOtherList)
			This.AssociateWith(paOtherList)
			return This

	def AssociatedWith(paOtherList)
		aResult = This.Copy().AssociateWithQ(paOtherList).Content()
		return aResult

	  #----------------------------------------------------#
	 #     SORTING THE CHARS OF EACH STRING IN THE LIST   #
	#----------------------------------------------------#

	def CharsSortingOrders()
		acResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			acResult + Q(aCcontent[i]).CharsSortingOrder()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			if Q(acContent[i]).CharsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereCharsAreSortedInDescending()
		nResult = 0
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			if Q(acContent[i]).CharsAreSortedInDescending()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithCharsSortedInAscending()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithCharsSortedInAscending()
		next

		return aResult

	def SortCharsOfEachStringInDescending()
		aResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithCharsSortedInDescending()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithCharsSortedInDescending()
		next

		return aResult

	  #----------------------------------------------------#
	 #     SORTING THE WORDS OF EACH STRING IN THE LIST   #
	#----------------------------------------------------#

	def WordsSortingOrders()
		acResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			acResult + Q(This.StringAtQ(i)).WordsSortingOrder()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			if Q(acContent[i]).WordsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereWordsAreSortedInDescending()
		nResult = 0
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			if Q(acContent[i]).WordsAreSortedInDescending()
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
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithWordsSortedInAscending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInAscendingQ()
			This.SortWordsOfEachStringInAscending()
			return This

	def WordsOfEachStringSortedInAscending()
		aResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithWordsSortedInAscending()
		next

		return aResult

	def SortWordsOfEachStringInDescending()
		aResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithWordsSortedInDescending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInDescendingQ()
			This.SortWordsOfEachStringInDescending()
			return This

	def WordsOfEachStringSortedInDescending()
		aResult = []
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			aResult + Q(acContent[i]).StringWithWordsSortedInDescending()
		next

	  #==============================================================#
	 #     FINDING A STRING OR SUBSTRING IN THE LIST OF STRINGS     #
	#==============================================================#

	def FindCS(pWhat, pCaseSensitive)
		/* EXAMPLE
		o1 = new stsListOfStrings([ "*", "A*B*C", "*" ])
		? o1.Find( :String = "*" )
		#--> [1, 3]

		? o1.Find( :SubString = "*" )
		#--> [ [1, [1]], [2, [2, 4]], [2, [1]] ]
		*/

		if isList(pWhat)
			if Q(pWhat).IsStringOrStringItemNamedParam()
				return This.FindStringCS(pWhat[2], pCaseSensitive)

			but Q(pWhat).IsSubStringNamedParam()
				return This.FindSubStringCS(pWhat[2], pCaseSensitive)

			else
				StzRaise("Incorrect param! Allowed values are :String = ... or :SubString = ...")
			ok
		else
			return This.FindStringCS(pWhat, pCaseSensitive)
		ok

	#-- WITHOUT CASESENSITIVITY

	def Find(pWhat)
		return This.FindCS(pWhat, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A STRING-ITEM IN THE LIST OF STRINGS  #
	#-------------------------------------------------------------------#

	def FindAllCS(pcStrItem, pCaseSensitive)

		# Resolving pCaseSensitive

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isString(pCaseSensitive)
			if Q(pCaseSensitive).IsOneOfThese([
				:CaseSensitive, :IsCaseSensitive , :CS, :IsCS ])

				pCaseSensitive = TRUE
			
			but Q(pCaseSensitive).IsOneOfThese([
				:CaseInSensitive, :NotCaseSensitive, :NotCS,
				:IsCaseInSensitive, :IsNotCaseSensitive, :IsNotCS ])

				pCaseSensitive = FALSE
			ok

		ok

		if NOT IsBoolean(pCaseSensitive)
			stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		# Doing the job

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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllCS(pcStrItem, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllCS(pcStrItem, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
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

	#-- WITHOUT CASESENSITIVITY

	def FindAll(pcStrItem)
		return This.FindallCS(pcStrItem, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindAllQ(pcStrItem)
			return FindAllQR(pcStrItem, :stzList)

		def FindAllQR(pcStrItem, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAll(pcStrItem) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAll(pcStrItem) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptNthCS(pcStr, n, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNthCS(pcStr, n, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptNth(pcStr, n)
		return This.FindAllExceptNthCS(pcStr, n, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindAllExceptNthQ(pcStr, n)
			return This.FindAllExceptNthQR(pcStr, n, :stzList)

		def FindAllExceptNthQR(pcStr, n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptNth(pcStr, n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptNth(pcStr, n) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptFirst(pcStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptFirst(pcStr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptFirst(pcStr)
		return This.FindAllExceptFirstCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindAllExceptFirstQ(pcStr)
			return This.FindAllExceptFirstQR(pcStr, :stzList)

		def FindAllExceptFirstQR(pcStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptFirst(pcStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptFirst(pcStr) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptLast(pcStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptLast(pcStr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllExceptLast(pcStr)
		return This.FindAllExceptLastCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindAllExceptLastQ(pcStr)
			return This.FindAllExceptLastQR(pcStr, :stzList)

		def FindAllExceptLastQR(pcStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturendAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllExceptLast(pcStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptLast(pcStr) )

			other
				StzRaise("Unsupported return type!")
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
			StzRaise("Incorrect param type! pacStrItems mus tbe a list of strings.")
		ok

		pacStrItems = StzListQ(pacStrItems).DuplicatesRemoved()

		anResult = []
		nLen = len(pacStrItems)

		for i = 1 to nLen
			anResult + This.NumberOfOccurrenceOfStringItemCS(pacStrItems[i], pCaseSensitive)
		next

		return anResult

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsCSQ(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, :stzList)

		def NumberOfOccurrenceOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrencesOfManyStringItemsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrencesOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrencesOfManyStringItemsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStringItemsCS(pacStrItems, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrenceOfManyStringsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrenceOfManyStringsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrenceOfManyStringsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, pCaseSensitive)

			def NumberOfOccurrencesOfManyStringsCSQ(pacStrItems, pCaseSensitive)
				return This.NumberOfOccurrencesOfManyStringsCSQR(pacStrItems, pCaseSensitive, :stzList)
	
			def NumberOfOccurrencesOfManyStringsCSQR(pacStrItems, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStringsCS(pacStrItems, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManyStringItems(pacStrItems)
		return This.NumberOfOccurrenceOfManyStringItemsCS(pacStrItems, :CS = TRUE )

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsQ(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, :stzList)

		def NumberOfOccurrenceOfManyStringItemsQR(pacStrItems, pcReturnType)
			return This.NumberOfOccurrenceOfManyStringItemsCSQR(pacStrItems, pcCaseSensitive, pcReturnType)
		#>

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfManyStringItems(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrencesOfManyStringItemsQ(pacStrItems)
				return This.NumberOfOccurrencesOfManyStringItemsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrencesOfManyStringItemsQR(pacStrItems, pcReturnType)
				return This.NumberOfOccurrencesOfManyStringItemsCSQR(pacStrItems, pcCaseSensitive, pcReturnType)

		def NumberOfOccurrenceOfManyStrings(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrenceOfManyStringsQ(pacStrItems)
				return This.NumberOfOccurrenceOfManyStringsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrenceOfManyStringsQR(pacStrItems, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrenceOfManyStrings(pacStrItems) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStrings(pacStrItems) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def NumberOfOccurrencesOfManyStrings(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItems(pacStrItems)

			def NumberOfOccurrencesOfManyStringsQ(pacStrItems)
				return This.NumberOfOccurrencesOfManyStringsQR(pacStrItems, :stzList)
	
			def NumberOfOccurrencesOfManyStringsQR(pacStrItems, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.NumberOfOccurrencesOfManyStrings(pacStrItems) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NumberOfOccurrencesOfManyStrings(pacStrItems) )
	
				other
					StzRaise("Unsupported return type!")
				off

		#>

	  #-------------------------------------------------------------#
	 #    NUMBER OF OCCURRENCE OF MANY STRINGS-ITEMS -- EXTENDED   #
	#-------------------------------------------------------------#

	def NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, pCaseSensitive)
		aResult = []
		nLen = len(pacStrItems)

		for i = 1 to nLen
			anResult + [ str, This.NumberOfOccurrenceOfStringItemCS(pacStrItems[i], pCaseSensitive) ]
		next

		return aResult

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsXTCSQ(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, pCaseSensitive, :stzList)

		def NumberOfOccurrenceOfManyStringItemsXTCSQR(pacStrItems, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrenceOfManyStringsXTCS(pacStrItems, pCaseSensitive)
			return This.NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManyStringItemsXT(pacStrItems)
		This.NumberOfOccurrenceOfManyStringItemsXTCS(pacStrItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def NumberOfOccurrenceOfManyStringItemsXTQ(pacStrItems)
			return This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, :stzList)

		def NumberOfOccurrenceOfManyStringItemsXTQR(pacStrItems, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumberOfOccurrenceOfManyStringItemsXT(pacStrItems, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
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
			StzRaise("Incorrect param type! n must be a number.")
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

		# NOTE: QStringList does not contain a find method!
		# so we do it in pure Ring...

		# Resolving pCaseSensitive

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isString(pCaseSensitive)
			if Q(pCaseSensitive).IsOneOfThese([
				:CaseSensitive, :IsCaseSensitive , :CS, :IsCS ])

				pCaseSensitive = TRUE
			
			but Q(pCaseSensitive).IsOneOfThese([
				:CaseInSensitive, :NotCaseSensitive, :NotCS,
				:IsCaseInSensitive, :IsNotCaseSensitive, :IsNotCS ])

				pCaseSensitive = FALSE
			ok

		ok

		if NOT IsBoolean(pCaseSensitive)
			stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		# Doing the job

		nResult = 0

		if NOT pCaseSensitive
			nResult = ring_find( This.Lowercased(), Q(pcStrItem).Lowercased() )

		else
			nResult = ring_find( This.ListOfStrings(), pcStrItem )

		ok

		return nResult

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
		nLen = len(pacStrItems)

		for i = 1 to nLen
			aResult + This.FindStringItemCS(pacStrItems[i], pCaseSensitive)
		next

		aResult = Q(aResult).FlattenQ().SortInAscendingQ().Content()

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

		if isList(pcStr)
			return This.ContainsManyCS(pcStr, pCaseSensitive)
		ok

		bResult = This.ConcatenateQ().ContainsCS(pcStr, pCaseSensitive)
		return bResult

		#< @FunctionNegativeForm

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

		#< @FunctionNegativeForm

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
			StzRaise("Incorrect param type! paList must be a list.")
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
		nLen = len(paStrings)

		for i = 1 to nLen
			if NOT This.ContainsCS(paStrings[i], pCaseSensitive)
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
		return NOT This.ContainsEachCS(paStrings, pCaseSensitive)

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
			StzRaise("Incorrect param type! paList must be a list.")
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
		
		if NOT isList(paStrings)
			StzRaise("Incorrect param type! paStrings must be a list.")
		ok

		bResult = TRUE
		nLen = len(paStrings)

		for i = 1 to nLen
			if This.ContainsNoCS(paStrings[i], pCaseSensitive)
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
		nLen = len(paStrings)

		for i = 1 to nLen
			if This.ContainsCS(paStrings[i], pCaseSensitive)
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
		nLen = len(paStrings)

		for i = 1 to nLen
			if This.NumberOfOccurrenceCS(paStrings[i]) = This.NumberOfStrings()
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
		nLen = len(paStrings)

		for i = 1 to nLen
			if This.IsMadeOfStringCS(paStrings[i], pCaseSensitive)
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
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
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindNextOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				other
					StzRaise("Unsupported return type!")
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
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindNextOccurrences(pcStrItem, pnStartingAt) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindNextOccurrences(pcStrItem, pnStartingAt) )

				other
					StzRaise("Unsupported return type!")
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

		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindPreviousOccurrencesCS(pcStrItem, pnStartingAt, pCaseSensitive) )

				other
					StzRaise("Unsupported return type!")
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
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindPreviousOccurrences(pcStrItem, pnStartingAt) )

				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindPreviousOccurrences(pcStrItem, pnStartingAt) )

				other
					StzRaise("Unsupported return type!")
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
		nLenPos = len(anPositions)

		for i = 1 to nLen
			nResult += len(anPositions[i][2])
		next

		return nResult

		def NumberOfOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def NumberOfSubStringsCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubString(pcSubStr)
		return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfSubString(pcSubStr)
			return This.NumberOfOccurrenceOfSubString(pcSubStr)

		def NumberOfSubStrings(pcSubStr)
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
		nLen = len(anPositions)

		for i = 1 to nLen
			aResult + [ anPositions[i][1], len(anPositions[i][2]) ]
		next

		return aResult

		def NumberOfOccurrencesOfSubStringXTCS(pcSubStr, pCaseSensitive)
			return This. NumberOfOccurrenceOfSubStringXTCS(pcSubStr, pCaseSensitive)

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
		nLen = len(pacSubStrings)

		for i = 1 to nLen
			anResult + This.NumberOfOccurrenceOfSubStringCS(pacSubStrings[i], pCaseSensitive)
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

	def NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)
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
		nLen = len(pacSubStrings)

		for i = 1 to nLen
			anResult + This.NumberOfOccurrenceOfSubStringXTCS(pacSubStrings[i], pCaseSensitive)
		next

		return anResult

		def NumberOfOccurrencesOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringsXTCS(pacSubStrings, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)
		return This.NumberOfOccurrenceOfManySubStringsXTCS(pacSubStrings, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfManySubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

		def NumberOfOccurrenceOfSubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

		def NumberOfOccurrencesOfSubStringsXT(pacSubStrings)
			return This.NumberOfOccurrenceOfManySubStringsXT(pacSubStrings)

	  #=======================================================================#
	 #     FINDING ALL OCCURRENCES OF A SUBSTRING IN THE LIST OF STRINGS     #
	#=======================================================================#

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
	
		? @@( o1.FindSubstring("name") )
		#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]
		# "name" is found in string 1 at position 13, and
		# in string 2 at positions 6 and 18.

		*/

		aResult = []
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			
			anPos = This.StringQ(i).FindAllCS(pcSubStr, pCaseSensitive)

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

	#-- WITHOUT CASESENSITIVITY

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

		then FindSubStringXTCS() returns the same information but in a
		slightly different form:
		[ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

		This makes it more practical to iterate over the positions and
		do whatever operation needed on them. See an example for using
		this in the ReplaceSubStringByManyCS().

		*/

		aPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		aResult = []
		nLen = len(aPositions)

		for i = 1 to nLen
			
			nLen2 = len(aPositions[i][2])
			for j = 1 to nLen2
				aResult + [ aPositions[i][1], aPositions[i][2][j]]	
			next
			
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringXTCSQ(pcSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringXTCS(pcSubStr, pCaseSensitive) )

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindInStringNSubStringCS(n, pcSubStr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindInStringNSubString(n, pcSubStr) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindInStringNSubString(n, pcSubStr) )

			other
				StzRaise("Unsupported return type!")
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
	 #    FINDING NTH OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS    #
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
			StzRaise("Incorrect param! n must be a number.")
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
	 #   FINDING FIRST OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS   #
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
	 #    FINDING LAST OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS   #
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


	#-- WITHOUT CASESENSITIVITY

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
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		aResult = []
		nLen = len(pacSubStr)

		for i = 1 to nLen
			aResult + This.FindSubStringCS(pacSubStr[i], pCaseSensitive)
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringsCSQ(pacSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringsCS(pacSubStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeForms

		def FindManySubStringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

			def FindManySubStringsCSQ(pacStr, pCaseSensitive)
				return new stzList( This.FindManySubStringsCS(pacStr, pCaseSensitive) )

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
		nLen = len(pacSubStr)

		for i = 1 to nLen
			aResult + [ cSubStr, This.FindSubStringXTCS(pacSubStr[i], pCaseSensitive) ]
		next

		return aResult

		#< @FunctionFluentForm

		def FindSubStringsXTCSQ(pacSubStr, pCaseSensitive)
			return new stzList( This.FindSubStringsXTCS(pacSubStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeForms

		def FindManySubStringsXTCS(pacStr, pCaseSensitive)
			return This.FindSubStringsXTCS(pacStr, pCaseSensitive)

			def FindManySubStringsXTCSQ(pacStr, pCaseSensitive)
				return new stzList( This.FindManySubStringsXTCS(pacStr, pCaseSensitive) )

		def FindTheseSubStringsXTCS(pacStr, pCaseSensitive)
			return This.FindSubStringsXTCS(pacStr, pCaseSensitive)

			def FindTheseSubStringsXTCSQ(pacStr, pCaseSensitive)
				return new stzList( This.FindTheseSubStringsXTCS(pacStr, pCaseSensitive) )

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringsXT(pacSubStr)
		return This.FindSubStringsXTCS(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindSubStringsXTQ(pacSubStr)
			return new stzList( This.FindSubStringsXT(pacSubStr) )

		#>

		#< @FunctionAlternativeForms

		def FindManySubStringsXT(pacStr)
			return This.FindSubStringsXT(pacStr)

			def FindManySubStringsXTQ(pacStr)
				return new stzList( This.FindSubStringsXT(pacStr) )

		def FindTheseSubStringsXT(pacStr)
			return This.FindSubStringsXT(pacStr)

			def FindTheseSubStringsXTQ(pacStr)
				return new stzList( This.FindTheseSubStringsXT(pacStr) )

		#>

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

		def NFirstOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def FindFirstNOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def FirstNOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindFirstNOccurrencesOfSubStringCS(n, pcSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNFirstOccurrencesOfSubString(n, pcSubStr)
		return This.FindNFirstOccurrencesOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def NFirstOccurrencesOfSubString(n, pcSubStr)
			return This.FindNFirstOccurrencesOfSubString(n, pcSubStr)

		def FindFirstNOccurrencesOfSubString(n, pcSubStr)
			return This.FindNFirstOccurrencesOfSubString(n, pcSubStr)

		def FirstNOccurrencesOfSubString(n, pcSubStr)
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
		nLen = len(pacSubStr)

		for i = 1 to nLen
			if NOT This.ContainsSubStringCS(pacSubStr[i], pCaseSensitive)
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
			StzRaise("Incorrect param! n must be a number.")
		ok

		#--

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
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
			StzRaise("Incorrect param! n must be a number.")
		ok

		#--

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
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
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			if NOT This.StringQ(i).ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
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
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			if NOT This.StringQ(i).ContainsCS(pcStr, pCaseSensitive)
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

		# Resolving pCaseSensitive

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isString(pCaseSensitive)
			if Q(pCaseSensitive).IsOneOfThese([
				:CaseSensitive, :IsCaseSensitive , :CS, :IsCS ])

				pCaseSensitive = TRUE
			
			but Q(pCaseSensitive).IsOneOfThese([
				:CaseInSensitive, :NotCaseSensitive, :NotCS,
				:IsCaseInSensitive, :IsNotCaseSensitive, :IsNotCS ])

				pCaseSensitive = FALSE
			ok

		ok

		if NOT IsBoolean(pCaseSensitive)
			stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		# Doing the job
			 
		oQList = This.QStringListObject().filter(pcSubStr, pCaseSensitive)
		bResult = QStringListContent(oQList)

		return bResult

		#< @FunctionfluentForm

		def StringItemsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def StringItemsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def StringsContainingSubStringCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
				return This.StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def StringItemsContainingCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringItemsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.StringItemsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringItemsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def StringsContainingCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.StringsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def FilterStringItemsCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and
			     (  Q(pcSubStr).IsUsingNamedParam() or
				Q(pcSubStr).IsWithNamedParam() or
				Q(pcSubStr).IsOnNamedParam() or
				Q(pcSubStr).IsByNamedParam() )
	
				pcSubStr = pcSubstr[2]
			ok
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterStringItemsCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringItemsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterStringItemsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringItemsCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringItemsCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def FilterStringsCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterStringsCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterStringsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringsCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringsCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def FilterCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringsCSQR(pcSubStr, pCaseSensitive, :stzList)

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

	def StringItemsContainingSubString(pcSubStr)
		return This.StringItemsContainingSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionfluentForm

		def StringItemsContainingSubStringQ(pcSubStr)
			return This.StringItemsContainingSubStringQR(pcSubStr, :stzList)

		def StringItemsContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingSubString(pcSubStr) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def StringsContainingSubString(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringsContainingSubStringQ(pcSubStr)
				return This.StringsContainingSubStringQR(pcSubStr, :stzList)

			def StringsContainingSubStringQR(pcSubStr, pCaseSensitive)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingSubString(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingSubString(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def StringItemsContaining(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringItemsContainingQ(pcSubStr)
				return This.StringItemsContainingQR(pcSubStr, :stzList)

			def StringItemsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContaining(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def StringsContaining(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def StringsContainingQ(pcSubStr)
				return This.StringsContainingQR(pcSubStr, :stzList)

			def StringsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContaining(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def FilterStringItems(pcSubStr)
			if isList(pcSubStr) and
			     (  Q(pcSubStr).IsUsingNamedParam() or
				Q(pcSubStr).IsWithNamedParam() or
				Q(pcSubStr).IsOnNamedParam() or
				Q(pcSubStr).IsByNamedParam() )
	
				pcSubStr = pcSubstr[2]
			ok
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterStringItemsQ(pcSubStr)
				return This.FilterStringItemsQR(pcSubStr, :stzList)

			def FilterStringItemsQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStringItems(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStringItems(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def FilterStrings(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterStringsQ(pcSubStr)
				return This.FilterStringsQR(pcSubStr, :stzList)

			def FilterStringsQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FilterStrings(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FilterStrings(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def Filter(pcSubStr)
			return This.StringItemsContainingSubString(pcSubStr)

			def FilterQ(pcSubStr)
				return This.FilterStringsQR(pcSubStr, :stzList)

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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		def UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingSubStringCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringItemsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringItemsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringItemsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def UniqueStringsContainingCS(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def UniqueStringsContainingCSQ(pcSubStr, pCaseSensitive)
				return This.UniqueStringsContainingCSQR(pcSubStr, pCaseSensitive, :stzList)

			def UniqueStringsContainingCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingCS(pcSubStr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingCS(pcSubStr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

	#-- WITHOUT CASESENSITIVITY

	def UniqueStringItemsContainingSubString(pcSubStr)
		return This.UniqueStringItemsContainingSubStringCS(pcSubStr, :CS = TRUE)

		#< @FunctionfluentForm

		def UniqueStringItemsContainingSubStringQ(pcSubStr)
			return This.UniqueStringItemsContainingSubStringQR(pcSubStr, :stzList)

		def UniqueStringItemsContainingSubStringQR(pcSubStr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingSubString(pcSubStr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingSubString(pcSubStr) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		def UniqueStringsContainingSubString(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringsContainingSubStringQ(pcSubStr)
				return This.UniqueStringsContainingSubStringQR(pcSubStr, :stzList)

			def UniqueStringsContainingSubStringQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingSubString(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingSubString(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def UniqueStringItemsContaining(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringItemsContainingQ(pcSubStr)
				return This.UniqueStringItemsContainingQR(pcSubStr, :stzList)

			def UniqueStringItemsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContaining(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def UniqueStringsContaining(pcSubStr)
			return This.UniqueStringItemsContainingSubString(pcSubStr)

			def UniqueStringsContainingQ(pcSubStr)
				return This.UniqueStringsContainingQR(pcSubStr, :stzList)

			def UniqueStringsContainingQR(pcSubStr, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContaining(pcSubStr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContaining(pcSubStr) )
	
				other
					StzRaise("Unsupported param type!")
				off

  	  #--------------------------------------------------#
	 #   STRINGS CONTAINING N TIMES A GIVEN SUBSTRING   #
	#--------------------------------------------------#

	def StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		acResult = TRUE
		nLen = This.NumberOfStrings()

		for i = 1 to nLen

			if  This.StringQ(i).ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				acResult + str
			ok
		next

		return acResult

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)

		def StringItemsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
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
					StzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def StringItemsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		def StringsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def StringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.StringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstring(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringsContainingNTimesTheSubstringQ(n, pcSubstr)
				return This.StringsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)
	
			def StringsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringCS(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimesTheSubstring(n, pcSubstr) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimes(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringItemsContainingNTimesQ(n, pcSubstr)
				return This.StringItemsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def StringItemsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringItemsContainingNTimes(n, pcSubstr) )
		
				other
					StzRaise("Unsupported return type!")
				off

		def StringsContainingNTimes(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def StringsContainingNTimesQ(n, pcSubstr)
				return This.StringsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def StringsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.StringsContainingNTimes(n, pcSubstr) )
		
				other
					StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringsContainingNTimesTheSubstringCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, :stzList)
	
			def UniqueStringsContainingNTimesTheSubstringCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def UniqueStringItemsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringItemsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def UniqueStringItemsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		def UniqueStringsContainingNTimesCS(n, pcSubStr, pCaseSensitive)
			return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)

			def UniqueStringsContainingNTimesCSQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def UniqueStringsContainingNTimesCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITY

	def UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def UniqueStringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def UniqueStringsContainingNTimesTheSubstring(n, pcSubstr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringsContainingNTimesTheSubstringQ(n, pcSubstr, pCaseSensitive)
				return This.UniqueStringsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)
	
			def UniqueStringsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimesTheSubstringCS(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimesTheSubstring(n, pcSubstr) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def UniqueStringItemsContainingNTimes(n, pcSubStr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringItemsContainingNTimesQ(n, pcSubstr)
				return This.UniqueStringItemsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def UniqueStringItemsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringItemsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringItemsContainingNTimes(n, pcSubstr) )
		
				other
					StzRaise("Unsupported return type!")
				off

		def UniqueStringsContainingNTimes(n, pcSubStr)
			return This.UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)

			def UniqueStringsContainingNTimesQ(n, pcSubstr)
				return This.UniqueStringsContainingNTimesQR(n, pcSubstr, :stzList)
		
			def UniqueStringsContainingNTimesQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.UniqueStringsContainingNTimes(n, pcSubstr) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueStringsContainingNTimes(n, pcSubstr) )
		
				other
					StzRaise("Unsupported return type!")
				off

		#>

  	   #-----------------------------------------------------------------#
	  #    STRINGS CONTAINING N TIMES A GIVEN SUBSTRING -- EXTENDED     #
	 #   (ALONG WITH THE POSITIONS OF THE SUBSTRING IN EACH STRING)    #
	#-----------------------------------------------------------------#

	def StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)
		acResult = TRUE
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			oStr = new StringQ(i)
			if  oStr.StringQ(i).ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				acResult + [ This.String(), oStr.StringQ().FindAllCS(pcSubstr, pCaseSensitive) ]
			ok
		next

		return acResult

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringXTCSQ(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, :stzList)

		def StringItemsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive) )

			on :stzHashlList
				return new stzHashList( This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesTheSubstringXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, :stzList)
	
			def StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def StringItemsContainingNTimesXTCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)

			def StringItemsContainingNTimesXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringItemsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringItemsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringItemsContainingNTimesXTCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringItemsContainingNTimesXTCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		def StringsContainingNTimesXTCS(n, pcSubStr, pCaseSensitive)
			return This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, pCaseSensitive)

			def StringsContainingNTimesXTCSQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, :stzList)
		
			def StringsContainingNTimesXTCSQR(n, pcSubstr, pCaseSensitive, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.StringsContainingNTimesXTCS(n, pcSubstr, pCaseSensitive) )
	
				on :stzHashList
					return new stzHashList( This.StringsContainingNTimesXTCS(n, pcSubstr, pCaseSensitive) )
		
				other
					StzRaise("Unsupported return type!")
				off

		#>

	#-- WITHOUT CASESENSITIVITTY

	def StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringXTCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringXTQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr) )

			on :stzHashList
				return new stzHashList( This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def StringsContainingNTimesTheSubstringXT(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringsContainingNTimesTheSubstringXTQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringXTQR(n, pcSubstr, :stzList)
	
			def StringsContainingNTimesTheSubstringXTQR(n, pcSubstr, pcReturn)
				return This.StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, :CS = TRUE, pcReturn)

		def StringItemsContainingNTimesXT(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringItemsContainingNTimesXTQ(n, pcSubstr)
				return This.StringItemsContainingNTimesXTQR(n, pcSubstr, :stzList)
		
			def StringItemsContainingNTimesXTQR(n, pcSubstr, pcReturn)
				return This.StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, :CS = TRUE, pcReturn)

		def StringsContainingNTimesXT(n, pcSubStr)
			return This.StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)

			def StringsContainingNTimesXTQ(n, pcSubstr)
				return This.StringsContainingNTimesXTQR(n, pcSubstr, :stzList)
		
			def StringsContainingNTimesXTQR(n, pcSubstr, pcReturn)
				return This.StringsContainingNTimesTheSubstringXTCSQR(n, pcSubstr, :CS = TRUE, pcReturn)

		#>

	  #===========================================#
	 #  REPLACING ALL STRINGS WITH A NEW STRING   #
	#============================================#

	def ReplaceAllStrings(pcNewString)

		bDynamic = FALSE

		if isList(pcNewString) and Q(pcNewString).IsWithOrByNamedParam()

			if Q(pcNewString[1]).LastChar() = "@"
				bDynamic = TRUE
			ok

			pcNewString = pcNewString[2]
			
		ok

		if NOT isString(pcNewString)
			StzRaise("Incorrect param! pcNewString must be a string.")
		ok

		if NOT bDynamic
			for i = 1 to This.NumberOfStrings()
				This.ReplaceStringAtPosition(i, pcNewString)
			next
	
		else
			nLen = This.NumberOfChars()

			cDynamicExpr = StzCCodeQ(pcNewString).Transpiled()
			anSection = oCCode.ExecutableSectionXT()
			
			n1 = anSection[1]
			n2 = anSection[2]

			if n1 = :First
				n1 = 1

			but n2 = :Last
				n2 = nLen
			ok

			for @i = n1 to n2

				@string = This.StringAtPosition(@i)
				cCode = 'cNewStr = ' + cDynamicExpr
				eval(cCode)

				This.ReplaceStringAtPosition(@i, cNewStr)
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
		
		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if NOT isString(pcString)
			StzRaise("Incorrect param! pcString must be a string.")
		ok

		anPositions = This.FindAllCS(pcString, pCaseSensitive)
		nLen = len(anPositions)

		for i = 1 to nLen
			This.ReplaceStringAtPosition(anPositions[i], pcNewString)
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
			This.ReplaceAllOccurrencesOfStringCS(pcString, pcNewString, pCaseSensitive)

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
			StzRaise("Incorrect param! pacStrings must be a list of strings.")
		ok

		if isList(pacNewStrings) and Q(pacNewStrings).IsWithOrByNamedParam()
			pacNewStrings = pacNewStrings[2]
		ok

		if NOT Q(pacNewStrings).IsListOfStrings()
			StzRaise("Incorrect param! pacNewStrings must be a list of strings.")
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

		def ReplaceManyByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ReplaceStringsOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ReplaceStringItemsOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ReplaceManyOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		#>

	def StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
		acResult = This.Copy().
				ReplaceStringsByManyCS(pacStrings, pacNewStrings, pCaseSensitive).
				Contnet()

		return acResult

		#< @FunctionAlternativeForms

		def StringItemsReplacedByManyCS(acStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ManyReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ManyStringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ManyStringItemsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ManyStringsReplacedOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		def ManyStringItemsReplacedOneByOneCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This.StringsReplacedByManyCS(pacStrings, pacNewStrings, pCaseSensitive)

		#>

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

		def ReplaceManyByMany(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)

		def ReplaceStringsOneByOne(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)

		def ReplaceStringItemsOneByOne(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)

		def ReplaceManyOneByOne(pacStrings, pacNewStrings)
			This.ReplaceStringsByMany(pacStrings, pacNewStrings)

		#>

	def StringsReplacedByMany(pacStrings, pacNewStrings)
		acResult = This.Copy().
				ReplaceStringsByMany(pacStrings, pacNewStrings).
				Contnet()

		return acResult

		#< @FunctionAlternativeForms

		def StringItemsReplacedByMany(acStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		def ManyReplacedByMany(pacStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		def ManyStringsReplacedByMany(pacStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		def ManyStringItemsReplacedByMany(pacStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		def ManyStringsReplacedOneByOne(pacStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		def ManyStringItemsReplacedOneByOne(pacStrings, pacNewStrings)
			return This.StringsReplacedByMany(pacStrings, pacNewStrings)

		#>

	  #------------------------------------------------------------#
	 #  REPLACING MANY STRINGS BY MANY OTHER STRINGS -- EXTENDED  #
	#------------------------------------------------------------#

	def ReplaceStringsByManyXTCS(pacStrings, pacNewStrings, pCaseSensitive)

		if NOT ( isList(pacStrings) and Q(pacStrings).IsListOfStrings() )
			StzRaise("Incorrect param! pacStrings must be a list of strings.")
		ok

		if isList(pacNewStrings) and Q(pacNewStrings).IsWithOrByNamedParam()
			pacNewStrings = pacNewStrings[2]
		ok

		if NOT Q(pacNewStrings).IsListOfStrings()
			StzRaise("Incorrect param! pacNewStrings must be a list of strings.")
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

		def ReplaceStringsByManyXTCSQ(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyXTCS(pacStrings, pacNewStrings, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStringItemsByManyXTCS(pacStrings, pacNewStrings, pCaseSensitive)
			This.ReplaceStringsByManyXTCS(pacStrings, pacNewStrings, pCaseSensitive)

		#>

	def StringsReplacedByManyXTCS(pacStrings, pacNewStrings, pCaseSensitive)
		acResult = This.Copy().
				This.
				ReplaceStringsByManyXTCSQ(pacStrings, pacNewStrings, pCaseSensitive).
				Content()

		return acResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceStringsByManyXT(pacStrings, pacNewStrings)
		This.ReplaceStringsByManyXTCS(pacStrings, pacNewStrings, :CaseSensitive = TRUE)

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

		if isList(pacNewSubStringItems) and Q(pacNewSubStringItems).IsWithOrByNamedParam()
			pacNewSubStringItems = pacNewSubStringItems[2]
		ok

		if NOT Q(pacNewSubStringItems).IsListOfStrings()
			StzRaise("Incorrect param! pacNewSubStringItems must be a list of strings.")
		ok

		anPositions = This.FindCS(pcStrItem, pCaseSensitive)
		nMin = Min([ len(anPositions), len(pacNewSubStringItems) ])

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

	def ReplaceByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

		/* EXAMPLE

		o1 = new stzListOfStrings([ "ring", "php", "ring", "ruby", "ring", "python", "ring" ])
		o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
	
		? o1.Content() #--> [ "#1", "php", "#2", "ruby", "#1", "python", "#2" ]

		*/

		if isList(pacNewSubStringItems) and Q(pacNewSubStringItems).IsWithOrByNamedParam()
			pacNewSubStringItems = pacNewSubStringItems[2]
		ok

		if NOT Q(pacNewSubStringItems).IsListOfStrings()
			StzRaise("Incorrect param! pacNewSubStringItems must be a list of strings.")
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

		def ReplaceByManyXTCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceStringItemByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringItemByManyXTCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		def ReplaceStringByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			This.ReplaceByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

			def ReplaceStringByManyXTCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				This.ReplaceStringItemByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
				retutn This

		#>

	def StringReplacedByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
		acResult = This.Copy().ReplaceByManyXTCSQ(pcStrItem, pacNewSubStringItems, pCaseSensitive).Content()
		return acResult

		def StringItemRepacedByManyXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)
			return This.StringReplacedXTCS(pcStrItem, pacNewSubStringItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceByManyXT(pcStrItem, pacNewSubStringItems)
		This.ReplaceByManyXTCS(pcStrItem, pacNewSubStringItems, :CaseSensitive = TRUE)

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
		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pcOtherString) and
		   StzListQ(pcOtherString).IsWithOrByNamedParam()
		
			pcOtherString = pcOtherString[2]
		ok

		nStringPosition = This.FindNthOccurrenceCS(n, pcString, pCaseSensitive)

		This.ReplaceStringAtPosition(nStringPosition, pcOtherString)

		def ReplaceNthOccurrenceCSQ(n, pcString, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)
			return This

		#< @FunctionAlternativeForms

		def ReplaceNthCS(n, pcString, pcOtherString, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcString, pcOtherString, pCaseSensitive)

			def ReplaceNthCSQ(n, pcString, pcOtherString, pCaseSensitive)
				This.ReplaceNthCS(n, pcString, pcOtherString, pCaseSensitive)
				return This

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

		def NthReplacedCS(n, pcString, pcOtherString, pCaseSensitive)
			return This.NthOccurrenceReplacedCS(n, pcString, pcOtherString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNthOccurrence(n, pcString, pcOtherString)
		ReplaceNthOccurrenceCS(n, pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceNthOccurrenceQ(n, pcString, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def ReplaceNth(n, pcString, pcOtherString)
			This.ReplaceNthOccurrence(n, pcString, pcOtherString)

			def ReplaceNthQ(n, pcString, pcOtherString)
				This.ReplaceNth(n, pcString, pcOtherString)
				return This

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

		def NthReplaced(n, pcString, pcOtherString)
			return This.NthOccurrenceReplaced(n, pcString, pcOtherString)

	  #---------------------------------------------#
	 #   REPLACING FIRST OCCURRENCE OF A STRING    #
	#---------------------------------------------#

	def ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pcString, pcOtherString, pCaseSensitive)

		def ReplaceFirstOccurrenceCSQ(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)
			return This

		#< @FunctionAlternativeForms

		def RepalceFirstCS(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def RepalceFirstCSQ(pcString, pcOtherString, pCaseSensitive)
				This.RepalceFirstCS(pcString, pcOtherString, pCaseSensitive)
				return This

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

		def FirstReplacedCS(pcString, pcOtherString, pCaseSensitive)
			return This.FirstOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirstOccurrence(pcString, pcOtherString)
		This.ReplaceFirstOccurrenceCS(pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceFirstOccurrenceQ(pcString, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def RepalceFirst(pcString, pcOtherString)
			This.ReplaceFirstOccurrence(pcString, pcOtherString)

			def RepalceFirstQ(pcString, pcOtherString)
				This.RepalceFirst(pcString, pcOtherString)
				return This

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

		def FirstReplaced(pcString, pcOtherString)
			return This.FirstOccurrenceReplaced(pcString, pcOtherString)

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

		def RepalceLastCS(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcString, pcOtherString, pCaseSensitive)

			def RepalceLastCSQ(pcString, pcOtherString, pCaseSensitive)
				This.RepalceLastCS(pcString, pcOtherString, pCaseSensitive)
				return This

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

		def LastReplacedCS(pcString, pcOtherString, pCaseSensitive)
			return This.LastOccurrenceReplacedCS(pcString, pcOtherString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLastOccurrence(pcString, pcOtherString)
		ReplaceLastOccurrenceCS(pcString, pcOtherString, :CaseSensitive = TRUE)

		def ReplaceLastOccurrenceQ(pcString, pcOtherString)
			This.ReplaceLastOccurrence(pcString, pcOtherString)
			return This

		#< @FunctionAlternativeForms

		def RepalceLast(pcString, pcOtherString, pCaseSensitive)
			This.ReplaceLastOccurrence(pcString, pcOtherString)

			def RepalceLastQ(pcString, pcOtherString, pCaseSensitive)
				This.RepalceLast(pcString, pcOtherString)
				return This

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

		def LastReplaced(pcString, pcOtherString)
			return This.LastOccurrenceReplaced(pcString, pcOtherString)

	  #----------------------------------------------------------------------------#
	 #   REPLACING NEXT NTH OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION   #
	#----------------------------------------------------------------------------#

	def ReplaceNextNthOccurrenceCS(n, pcString, pcNewString, pnStartingAt, pCaseSensitive)

		# Checking params correctness

		if NOT isNumber(n)
			StzRaise("Incorrect param! n must be a number.")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if NOT isString(pcString)
			StzRaise("Incorrect param! pcString must be a string.")
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParam()

			pcNewString = pcNewString[2]
		ok

		if NOT isString(pcNewString)
			StzRaise("Incorrect param! pcNewString must be a string.")
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
		ok

		# Doing the job

		oSection    = This.SectionQR(pnStartingAt, This.NumberOfStrings(), :stzListOfStrings)
		anPositions = oSection.FindAllCS(pcString, pCaseSensitive)

		anPositions = StzListOfNumbersQ(anPositions).AddToEachQ(pnStartingAt-1).Content()
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
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " +
				This.NumberOfStrings() + ")") = len(panList) )

			StzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParam()

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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
		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   StzListQ(pcNewString).IsWithOrByNamedParam()

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " +
				This.NumberOfStrings() + ")") = len(panList) )

			StzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pcNewString) and
		   ( StzListQ(pcNewString).IsWithNamedParam() or StzListQ(pcNewString).IsByNamedParam() )

			pcNewString = pcNewString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

		if NOT Q(n).IsNumberOrString()
			StzRaise("Invalid param type! n must be a number.")
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
			StzRaise("Incorrect param! n must be a number.")
		ok

		if NOT (  Q(n).IsBetween(1, This.NumberOfStrings()) )
			StzRaise("Position out of range!")
		ok

		if isList(pcOtherStr) and Q(pcOtherStr).IsWithOrByNamedParam()

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
			StzRaise("Incorrect param! pcOtherStr must be a string.")
		ok

		# Doing the job (Qt-side)

		This.QStringListObject().Replace(n-1, pcOtherStr)

		#< @FunctionFluentForm

		def ReplaceStringAtPositionQ(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthString(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceNthStringQ(n, pcOtherStr)
				This.ReplaceNthString(n, pcOtherStr)
				return This

		def ReplaceNthStringItem(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceNthStringItemQ(n, pcOtherStr)
				This.ReplaceNthStringItem(n, pcOtherStr)
				return This

		def ReplaceStringAtPositionN(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringAtPositionNQ(n, pcOtherStr)
				This.ReplaceStringAtPositionN(n, pcOtherStr)
				return This

		def ReplaceStringItemAtPosition(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringItemAtPositionQ(n, pcOtherStr)
				This.ReplaceStringItemAtPosition(n, pcOtherStr)
				return This

		def ReplaceStringItemAtPositionN(n, pcOtherStr)
			This.ReplaceStringAtPositionN(n, pcOtherStr)

			def ReplaceStringItemAtPositionNQ(n, pcOtherStr)
				This.ReplaceStringItemAtPositionN(n, pcOtherStr)
				return This

		def ReplaceAt(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceAtQ(n, pcOtherStr)
				This.ReplaceAt(n, pcOtherStr)
				return This

		def ReplaceAtPosition(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceAtPositionQ(n, pcOtherStr)
				This.ReplaceAtPosition(n, pcOtherStr)
				return This

		def ReplaceAtPositionN(n, pcOtherStr)
			This.ReplaceStringAtPositionN(n, pcOtherStr)

			def ReplaceAtPositionNQ(n, pcOtherStr)
				This.ReplaceAtPositionN(n, pcOtherStr)
				return This

		def ReplaceStringAt(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringAtQ(n, pcOtherStr)
				This.ReplaceStringAt(n, pcOtherStr)
				return This

		def ReplaceStringItemAt(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringItemAtQ(n, pcOtherStr)
				This.RemoveStringItemAt(n, pcOtherStr)
				return This

		def ReplaceStringN(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringNQ(n, pcOtherStr)
				This.ReplaceStringN(n, pcOtherStr)
				return This

		def ReplaceStringItemN(n, pcOtherStr)
			This.ReplaceStringAtPosition(n, pcOtherStr)

			def ReplaceStringItemNQ(n, pcOtherStr)
				This.ReplaceStringN(n, pcOtherStr)
				return This

		#>
	
	def StringAtPositionNReplacedWith(n, pcOtherStr)
		aResult = This.Copy().ReplaceStringAtPositionQ( n, pcOtherStr ).Content()
		return aResult

		def StringItemAtPositionNReplacedWith(n, pcOtherStr)
			return This.StringAtPositionNReplacedWith(n, pcOtherStr)

		def StringAtPositionReplacedWith(n, pcOtherStr)
			return This.StringAtPositionNReplacedWith(n, pcOtherStr)

		def NthStringReplacedWith(n, pcOtherStr)
			return This.StringAtPositionNReplacedWith(n, pcOtherStr)

		def NthStringItemReplacedWith(n, pcOtherStr)
			return This.StringAtPositionNReplacedWith(n, pcOtherStr)

	  #===========================================#
	 #   REPLACING A GIVEN NTH STRING (IF ANY)   #
	#===========================================#

	def ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)
		if This.NthStringQ(n).IsEqualToCS(pcStr, pCaseSensitive)
			This.RemoveStringAtPosition(n)
		ok

		#< @FunctionFluentForm

		def ReplaceThisNthStringCSQ(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisNthStringItemCS(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthString(n, pcStr, pCaseSensitive)

		def ReplaceThisStringAtCS(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)

		def ReplaceThisStringItemAtCS(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)

		def ReplaceThisStringAtPositionCS(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)

		def ReplaceThisStringItemAtPostionCS(n, pcStr, pCaseSensitive)
			This.ReplaceThisNthStringCS(n, pcStr, pCaseSensitive)

		#>

	def ThisNthStringReplacedCS(n, pcStr, pCaseSensitive)
		acResult = This.Copy().ReplaceThisNthStringCSQ(n, pcStr, pCaseSensitive).Content()

		def ThisNthStringItemReplacedCS(n, pcStr, pCaseSensitive)
			return This.ThisNthStringReplacedCS(n, pcStr, pCaseSensitive)

		def ThisStringAtPositionNReplacedCS(n, pcStr, pCaseSensitive)
			return This.ThisNthStringReplacedCS(n, pcStr, pCaseSensitive)

		def ThisStringItemAtPositionNReplacedCS(n, pcStr, pCaseSensitive)
			return This.ThisNthStringReplacedCS(n, pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceThisNthString(n, pcStr)
		This.ReplaceThisNthStringCS(n, pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceThisNthStringQ(n, pcStr)
			This.ReplaceThisNthString(n, pcStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisNthStringItem(n, pcStr)
			This.ReplaceThisNthString(n, pcStr)

		def ReplaceThisStringAt(n, pcStr)
			This.ReplaceThisNthString(n, pcStr)

		def ReplaceThisStringItemAt(n, pcStr)
			This.ReplaceThisNthString(n, pcStr)

		def ReplaceThisStringAtPosition(n, pcStr)
			This.ReplaceThisNthString(n, pcStr)

		def ReplaceThisStringItemAtPostion(n, pcStr)

		#>

	def ThisNthStringReplaced(n, pcStr)
		acResult = This.Copy().ReplaceThisNthStringQ(n, pcStr).Content()

		def ThisNthStringItemReplaced(n, pcStr)
			return This.ThisNthStringReplaced(n, pcStr)

		def ThisStringAtPositionNReplaced(n, pcStr)
			return This.ThisNthStringReplaced(n, pcStr)

		def ThisStringItemAtPositionNReplaced(n, pcStr)
			return This.ThisNthStringReplaced(n, pcStr)

	  #---------------------------------------------#
	 #   REPLACING A GIVEN FIRST STRING (IF ANY)   #
	#---------------------------------------------#

	def ReplaceThisFirstStringCS(pcStr, pCaseSensitive)
		if This.FirstStringQ(n).IsEqualToCS(pcStr, pCaseSensitive)
			This.RemoveStringAtPosition(n)
		ok

		#< @FunctionFluentForm

		def ReplaceThisFirstStringCSQ(pcStr, pCaseSensitive)
			This.ReplaceThisFirstStringCS(pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceThisFirstStringItemCS(pcStr, pCaseSensitive)
			This.ReplaceThisFirstStringCS(pcStr, pCaseSensitive)

		#>

	def ThisFirstStringReplacedCS(pcStr, pCaseSensitive)
		acResult = This.Copy().ReplaceThisFirstStringCSQ(pcStr, pCaseSensitive).Content()

		def ThisFirstStringItemReplacedCS(pcStr, pCaseSensitive)
			return This.ThisFirstStringReplacedCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceThisFirstString(pcStr)
		This.ReplaceThisFirstStringCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceThisFirstStringQ(pcStr)
			This.ReplaceThisFirstString(pcStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceThisFirstStringItem(pcStr)
			This.ReplaceThisFirstString(pcStr)

		#>

	def ThisFirstStringReplaced(pcStr)
		acResult = This.Copy().ReplaceThisFirstStringQ(pcStr).Content()

		def ThisFirstStringItemReplaced(n, pcStr)
			return This.ThisFirstStringReplaced(n, pcStr)

	  #--------------------------------------------#
	 #   REPLACING A GIVEN LAST STRING (IF ANY)   #
	#--------------------------------------------#

	def ReplaceThisLastStringCS(pcStr, pCaseSensitive)
		if This.LastStringQ(n).IsEqualToCS(pcStr, pCaseSensitive)
			This.RemoveStringAtPosition(n)
		ok

		#< @FunctionFluentForm

		def ReplaceThisLastStringCSQ(pcStr, pCaseSensitive)
			This.ReplaceThisLastStringCS(pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceThisLastStringItemCS(pcStr, pCaseSensitive)
			This.ReplaceThisLastStringCS(pcStr, pCaseSensitive)

		#>

	def ThisLastStringReplacedCS(pcStr, pCaseSensitive)
		acResult = This.Copy().ReplaceThisLastStringCSQ(pcStr, pCaseSensitive).Content()

		def ThisLastStringItemReplacedCS(pcStr, pCaseSensitive)
			return This.ThisLastStringReplacedCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceThisLastString(pcStr)
		This.ReplaceThisLastStringCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceThisLastStringQ(pcStr)
			This.ReplaceThisLastString(pcStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceThisLastStringItem(pcStr)
			This.ReplaceThisLastString(pcStr)

		#>

	def ThisLastStringReplaced(pcStr)
		acResult = This.Copy().ReplaceThisLastStringQ(pcStr).Content()

		def ThisLastStringItemReplaced(pcStr)
			return This.ThisLastStringReplaced(pcStr)

	  #=========================================#
	 #   REPLACING MANY STRINGS BY POSITION    #
	#=========================================#

	def ReplaceStringsAtPositions(panPositions, pcOtherString)

		if isList(pcOtherString) and Q(pcOtherString).IsListOfStrings() and
		   NOT Q(pcOtherString).IsWithOrByNamedParam()

			pcOtherString = pcOtherString[2]
		ok

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )

			StzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		bDynamic = FALSE

		if isList(pcOtherString) and Q(pcOtherString).IsWithOrByNamedParam()
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

			StzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		if StzListOfNumbersQ(panPositions).Max() > This.NumberOfStrings()
			StzRaise("Incorrect value! panPositions contains at least one value out of range.")
		ok

		if NOT ( isList(pacOtherStrings) and
				( Q(pacOtherStrings).IsListOfStrings() or
			 	  Q(pacOtherStrings).IsWithOrByNamedParam()
				) )

			StzRaise("Incorrect param! pacOtherStrings must be a list of strings.")
		ok

		if Q(pacOtherStrings).IsWithOrByNamedParam()
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

			StzRaise("Incorrect param! panPositions must be a list of numbers.")
		ok

		if StzListOfNumbersQ(panPositions).Max() > This.NumberOfStrings()
			StzRaise("Incorrect value! panPositions contains at least one value out of range.")
		ok

		if NOT ( isList(pacOtherStrings) and
				( Q(pacOtherStrings).IsListOfStrings() or
			 	  Q(pacOtherStrings).IsWithOrByNamedParam()
				) )

			StzRaise("Incorrect param! pacOtherStrings must be a list of strings.")
		ok

		if Q(pacOtherStrings).IsWithOrByNamedParam()
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

		if isList(pcNewStr) and Q(pcNewStr).IsWithOrByNamedParam()
			pcNewStr = pcNewStr[2]
		ok

		if NOT isString(pcNewStr)
			StzRaise("Incorrect param! pcNewStr must be a string.")
		ok

		This.RemoveSectionQ(n1, n2)
		This.InsertBefore(n1, pcNewStr)

		def ReplaceSectionQ(n1, n2, pcNewStr)
			This.ReplaceSection(n1, n2, pcNewStr)
			return This

	  #-----------------------------------------------------------#
	 #    REPLACING MANY SECTIONS OF STRINGS BY A GIVEN STRING   #
	#-----------------------------------------------------------#
	
	def ReplaceManySections(paSections, pcNewStr)

		if NOT ( isList(paSections) and StzListQ(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		if isList(pcNewStr) and Q(pcNewStr).IsWithOrByNamedParam()
			pcNewStr = pcNewStr[2]
		ok

		if NOT isString(pcNewStr)
			StzRaise("Incorrect param! pcNewStr must be a string.")
		ok

		anPositions = []
		for anSection in paSections
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

	def ReplaceEachStringInManySections(paSections, pcNewStr)
		for anSection in paSections
			n1 = anSection[1]
			n2 = anSection[2]
			This.ReplaceEachStringInSection(n1, n2, pcNewStr)
		next

		def ReplaceEachStringInManySectionsQ(paSections, pcNewStr)
			This.ReplaceEachStringInManySections(paSections, pcNewStr)
			return This

		def ReplaceEachStringItemInManySections(paSections, pcNewStr)
			This.ReplaceEachStringInManySections(paSections, pcNewStr)

			def ReplaceEachStringItemInManySectionsQ(paSections, pcNewStr)
				This.ReplaceEachStringItemInManySections(paSections, pcNewStr)
				return This

	def EachStringInManySectionsReplaced(paSections, pcNewStr)

		acResult = This.Copy().
				ReplaceEachStringInManySectionsQ(paSections, pcNewStr).
				Content()

		return acResult

		def EachStringItemInManySectionsReplaced(paSections, pcNewStr)
			return This.EachStringInManySectionsRelaced(paSections, pcNewStr)

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
				:Last, :LastPosition, :LastString, :LastStringItem ],
				:CS = FALSE)

				n2 = This.NumberOfStrings()
			ok
		ok

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect params! n1 and n2 must be numbers.")
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

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect params! n1 and n2 must be numbers.")
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

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect params! n1 and n2 must be numbers.")
		ok

		This.ReplaceStringItemsAtPositionsByAlternance(n1 : n2, pacOtherListOfStr)

	   #-------------------------------------------------------#
	  #   REPLACING MANY SECTIONS OF STRINGS BY MANY STRINGS  #
	#--------------------------------------------------------#

	def ReplaceSectionsByMany(paSections, pacOtherListOfStr)

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )

			StzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		if NOT ( isList(pacOtherListOfStr) and Q(pacOtherListOfStr).IsListOfStrings() )

			StzRaise("Incorrect param! paSections must be a list of strings.")
		ok

		anPositions = []

		for anSection in paSections
			n1 = anSection[1]
			n2 = anSection[2]

			if NOT (  Q(n1).IsBetween(1, This.NumberOfStrings()) and
				  Q(n2).IsBetween(1, This.NumberOfStrings()) )
				
				StzRaise("At least one position is out of range!")
			ok

			anPositions + ( n1 : n2 )
		next

		anPositions = StzListQ( anPositions ).
				MergeQ().RemoveDuplicatesQ().
				SortedInAscending()

		This.ReplaceStringsAtPositionsByMany(anPositions, pacOtherListOfStr)

		def ReplaceSectionsByManyQ(paSections, pacOtherListOfStr)
			This.ReplaceSectionsByMany(paSections, pacOtherListOfStr)
			return This

	def SectionsReplacedByMany(paSections, pacOtherListOfStr)
		acResult = This.Copy().
				ReplaceSectionsByManyQ(paSections, pacOtherListOfStr).
				Content()

		return acResult

	  #-------------------------------------------------------------------#
	 #   REPLACING MANY SECTIONS OF STRINGS BY MANY STRINGS -- EXTENDED  #
	#-------------------------------------------------------------------#

	def ReplaceSectionsByManyXT(paSections, pacOtherListOfStr)

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )

			StzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
		ok

		if NOT ( isList(pacOtherListOfStr) and Q(pacOtherListOfStr).IsListOfStrings() )

			StzRaise("Incorrect param! paSections must be a list of strings.")
		ok

		anPositions = []

		for anSection in paSections
			n1 = anSection[1]
			n2 = anSection[2]

			anPositions + ( n1 : n2 )
		next

		anPositions = StzListQ( anPositions ).
				MergeQ().RemoveDuplicatesQ().
				SortedInAscending()

		This.ReplaceStringsAtPositionsByManyXT(anPositions, pacOtherListOfStr)

		def ReplaceSectionsByManyXTQ(paSections, pacOtherListOfStr)
			This.ReplaceSectionsByManyXT(paSections, pacOtherListOfStr)
			return This

	def SectionsReplacedByManyXT(paSections, pacOtherListOfStr)
		acResult = This.Copy().
				ReplaceSectionsByManyXTQ(paSections, pacOtherListOfStr).
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
			StzRaise("Incorrect param type! pCondition must be string or list.")
		ok

		if NOT ( isString(pcOtherString) or isList(pcOtherString) )
			StzRaise("Incorrect param type! pcOtherString must be string or list.")
		ok 

		if isList(pCondition) and StzListQ(pCondition).IsWhereNamedParam()
			cCondition = pCondition[2]
		ok

		# There are two possible forms of replacement: With and With@
		# The first one is used to replace with normal string, while the
		# second one to replace with@ a dynamic code.

		# By default, the first form is used.

		cReplace = :With

		if isList(pcOtherString) and
		   ( StzListQ(pcOtherString).IsByNamedParam() or StzListQ(pcOtherString).IsWithNamedParam() )

			cReplace = pcOtherString[1]
			pcOtherString = pcOtherString[2]
		ok

		if cReplace = :With@
			if NOT isString(pcOtherString)
				StzRaise("Incorrect value! The value provided after :With@ must be a string containing a Ring expression.")
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

		if isList(pcNewSubStr) and Q(pcNewSubStr).IsWithOrByNamedParam()
			if Q(pcNewSubStr[1]).LastChar() = "@"
				bDynamic = TRUE
			ok

			pcNewSubStr = pcNewSubStr[2]

		ok

		if NOT isString(pcNewSubStr)
			StzRaise("Incorrect param! pcNewSubStr must be a string.")
		ok

		cDynamicExpr = NULL

		if bDynamic
			cDynamicExpr = StzStringQ(pcNewSubStr).TrimQ().
					RemoveBoundsQ(["{","}"]).Content()
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

	def ReplaceManySubStringsCS(pacSubStr, pcNewSubStr, pCaseSensitive)

		bDynamic = FALSE

		if isList(pcNewsubStr) and Q(pcNewSubStr).IsWithOrByNamedParam()
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

		for str in pacSubStr
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
				
				cDynamicExpr = StzStringQ(pcNewSubStr).TrimQ().RemoveBoundsQ(["{","}"]).Content()
				cCode = 'cNewStr = ( ' + cDynamicExpr + ' )'

				try
					eval(cCode)
				catch
				done

				This.ReplaceSubStringCS(str, cNewStr, pCaseSensitive)
			ok
		next

		def ReplaceManySubStringsCSQ(pacSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceManySubStringsCS(pacSubStr, pcNewSubStr, pCaseSensitive)
			return This

		def RepalceSubStringsCS(pacSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceManySubStringsCS(pacSubStr, pcNewSubStr, pCaseSensitive)

			def RepalceSubStringsCSQ(pacSubStr, pcNewSubStr, pCaseSensitive)
				This.RepalceSubStringsCS(pacSubStr, pcNewSubStr, pCaseSensitive)
				return This

	def ManySubStringsReplacedCS(pacSubStr, pcNewSubStr, pCaseSensitive)
		acResult = This.Copy().ReplaceManySubStringsCSQ(pacSubStr, pcNewSubStr, pCaseSensitive).Content()
		return acResult

		def SubStringsReplacedCS(pacSubStr, pcNewSubStr, pCaseSensitive)
			return This.ManySubStringsReplacedCS(pacSubStr, pcNewSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManySubStrings(pacSubStr, pcNewSubStr)
		This.ReplaceManySubStringsCS(pacSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceManySubStringsQ(pacSubStr, pcNewSubStr)
			This.ReplaceManySubStrings(pacSubStr, pcNewSubStr)
			return This

		def RepalceSubStrings(pacSubStr, pcNewSubStr)
			This.ReplaceManySubStrings(pacSubStr, pcNewSubStr)

			def RepalceSubStringsQ(pacSubStr, pcNewSubStr)
				This.RepalceSubStrings(pacSubStr, pcNewSubStr)
				return This

	def ManySubStringsReplaced(pacSubStr, pcNewSubStr)
		acResult = This.Copy().ReplaceManySubStringsQ(pacSubStr, pcNewSubStr).Content()
		return acResult

		def SubStringsReplaced(pacSubStr, pcNewSubStr)
			return This.ManySubStringsReplaced(pacSubStr, pcNewSubStr)

	  #-----------------------------------------------#
	 #    REPLACING A SUBSTRING BY MANY SUBSTRINGS	 #
	#-----------------------------------------------#

	def ReplaceSubStringByManyCS(pcSubStr, pacNewSubStr, pCaseSensitive)
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

		pacNewSubStr = IfWith@Eval(pacNewSubStr)

		if NOT ( isList(pacNewSubStr) and Q(pacNewSubStr).IsListOfStrings() )
			StzRaise("Incorrect param! pacNewSubStrings must be a list of strings.")
		ok

		# [ "heart ___ heart", "___ heart ___ heart ___ heart", "heart" ]

		# [ "♥1", "♥2", "♥3" ]
		nLen = len(pacNewSubStr)

		aPositions = This.NFirstOccurrencesOfSubStringCS(nLen, pcSubStr, pCaseSensitive)
		#--> [ [ 1, 1], [ 1, 11 ], [ 2, 5] ]

		for i = nLen to 1 step -1
			This.ReplaceSubStringAtPosition(aPositions[i], pcSubStr, pacNewSubStr[i])
		next

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringByMany(pcSubStr, pacNewSubStr)
		This.ReplaceSubStringByManyCS(pcSubStr, pacNewSubStr, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------------#
	 #    REPLACING A SUBSTRING BY MANY SUBSTRINGS -- EXTENDED (RETURN TO FIST)   #
	#----------------------------------------------------------------------------#

	def ReplaceSubStringByManyXTCS(pcSubStr, pacNewSubStr, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([ "heart ipsum heart", "lorem heart ipsum heart lorem heart", "heart" ])
		o1.ReplaceSubStringByManyXT( "heart", :With = L('{ "♥1" : "♥3" }') )
		
		? @@( o1.Content() ) #--> [ "♥1 ipsum ♥2", "lorem ♥3 ipsum ♥1 lorem ♥2", "♥3" ]
		*/

		pacNewSubStr = IfWith@Eval(pacNewSubStr)

		if NOT ( isList(pacNewSubStr) and Q(pacNewSubStr).IsListOfStrings() )
			StzRaise("Incorrect param! pacNewSubStr must be a list of strings.")
		ok

		anPositions = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		nNumberOfSubStr = This.NumberOfSubStringsCS(pcSubStr, pCaseSensitive)

		acNewSubStr = pacNewSubStr

		if len(acNewSubStr) < nNumberOfSubStr
			acNewSubStr = Q(pacNewSubStr).
					  ExtendToXTQ( nNumberOfSubStr, :With@ = '@items' ).
					  Content()
		ok

		This.ReplaceSubStringByManyCS(pcSubStr, acNewSubStr, pCaseSensitive)

		def ReplaceSubStringByManyXTCSQ(pcSubStr, pacNewSubStr, pCaseSensitive)
			This.ReplaceSubStringByManyXTCS(pcSubStr, pacNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringByManyXT(pcSubStr, pacNewSubStr)
		This.ReplaceSubStringByManyXTCS(pcSubStr, pacNewSubStr, :CaseSensitive = TRUE)

		def ReplaceSubStringByManyXTQ(pcSubStr, pacNewSubStr)
			This.ReplaceSubStringByManyXT(pcSubStr, pacNewSubStr)
			return This

	  #-----------------------------------------#
	 #   REPLACING SUBSTRINGS BY MANY OTHERS   #
	#-----------------------------------------#

	def ReplaceSubStringsByManyCS(pacSubStr, pacNewSubStr, pCaseSensitive)

		/* EXAMPLE

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "three" ])
		o1.ReplaceSubStringsByMany([ "one", "two", "three" ], :With = [ "1", "2", "3" ])

		? @@( o1.Content() ) #--> [ "1 ___ 2", "___ 1 ___ 3", "3" ]
		*/

		pacNewSubStr = IfWith@Eval(pacNewSubStr)

		nMin = Min([ len(pacSubStr), len(pacNewSubStr) ])

		for i = 1 to nMin
			This.ReplaceSubStringCS(pacSubStr[i], pacNewSubStr[i], pCaseSensitive)
		next

		def ReplaceManySubStringsByManyCS(pacSubStr, pacNewSubStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(pacSubStr, pacNewSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringsByMany(pacSubStr, pacNewSubStr)
		return This.ReplaceSubStringsByManyCS(pacSubStr, pacNewSubStr, :CaseSensitive = TRUE)

		def ReplaceManySubStringsByMany(pacSubStr, pacNewSubStr)
			return This.ReplaceSubStringsByMany(pacSubStr, pacNewSubStr)

	  #--------------------------------------------------------------#
	 #   REPLACING SUBSTRINGS BY MANY EXTENDED -- RETRUN TO FIRST   #
	#--------------------------------------------------------------#

	def ReplaceSubStringsByManyXTCS(pacSubStr, pacNewSubStr, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ "one ___ two", "___ one ___ three", "four ___ three" ])
		o1.ReplaceSubStringsByManyXT([ "one", "two", "three", "four" ], :With = [ "1", "2" ])

		? @@( o1.Content() ) #--> [ "1 ___ 2", "___ 1 ___ 1", "2 __ 1" ]

		*/

		pacNewSubStr = IfWith@Eval(pacNewSubStr)

		v = 0
		for i = 1 to len(pacSubStr)
			v++
			if v > len(pacNewSubStr)
				v = 1
			ok

			This.ReplaceSubStringCS(pacSubStr[i], pacNewSubStr[v], pCaseSensitive)

		next


		def ReplaceManySubStringsByManyXTCS(pacSubStrings, pacNewSubStrings, pCaseSensitive)
			This.ReplaceSubStringsByManyXTCS(pacSubStrings, pacNewSubStrings, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringsByManyXT(pacSubStr, pacNewSubStr)
		This.ReplaceSubStringsByManyXTCS(pacSubStr, pacNewSubStr, :CaseSensitive = TRUE)

		def ReplaceManySubStringsByManyXT(pacSubStrings, pacNewSubStrings)
			This.ReplaceSubStringsByManyXT(pacSubStrings, pacNewSubStrings)

	  #------------------------------------------------------------------#
	 #   REPLACING NTH OCCURRENCE OF SUBSTRING IN THE LIST OF STRINGS   #
	#------------------------------------------------------------------#

	def ReplaceNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		anPos = This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		This.ReplaceSubStringAtPosition( anPos, pcSubStr, pcNewSubStr )

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr)
		This.ReplaceNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)
		return This

	  #-----------------------------------------------#
	 #   REPLACING A SUBSTRING AT A GIVEN POSITION   #
	#-----------------------------------------------#

	def ReplaceSubStringAtPositionCS(panPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
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

		if NOT ( isList(panPosition) and Q(panPosition).IsPairOfNumbers() )
			StzRaise("Incorrect param type! panPosition must be a pair of numbers.")
		ok

		pcNewSubStr = IfWith@Eval(pcNewSubStr)

		nStringPos = panPosition[1]
		nSubStrPos = panPosition[2]

		cNewStr = This.StringAtPositionQ(nStringPos).
				ReplaceSubStringAtPositionQ(nSubStrPos, pcSubStr, pcNewSubStr).
				Content()

		This.ReplaceStringAtPosition(nStringPos, cNewStr)

		def ReplaceSubStringAtPositionCSQ(panPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceSubStringAtPositionCS(panPosition, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubstringAtPosition(panPosition, pcSubStr, pcNewSubstr)
		This.ReplaceSubStringAtPositionCS(panPosition, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceSubstringAtPositionQ(panPosition, pcSubStr, pcNewSubStr)
			This.ReplaceSubstringAtPosition(panPosition, pcSubStr, pcNewSubStr)
			return This

	  #---------------------------------------------#
	 #   REPLACING A SUBSTRING AT MANY POSITIONS   #
	#---------------------------------------------#

	def ReplaceSubStringAtPositionsCS(panPositions, pcSubStr, pcNewSubStr, pCaseSensitive)
		
		if NOT ( isList(panPositions) and Q(panPositions).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! panPositions must be a list of pairs of numbers.")
		ok

		for anPos in panPositions
			This.ReplaceSubStringAtPositionCS(anPos, pcSubStr, pcNewSubStr, pCaseSensitive)
		next
		
		def ReplaceSubStringAtThesePositionsCS(panPositions, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceSubStringAtPositionsCS(panPositions, pcSubStr, pcNewSubStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceSubStringAtPositions(panPositions, pcSubStr, pcNewSubStr)
		This.ReplaceSubStringAtPositionsCS(panPositions, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceSubStringAtThesePositions(panPositions, pcSubStr, pcNewSubStr)
			This.ReplaceSubStringAtPositions(panPositions, pcSubStr, pcNewSubStr)

	  #==============================================================================#
	 #  REPLACING, INSIDE A GIVEN STRING, ALL THE OCCURRENCES OF A GIVEN SUBSTRING  #
	#==============================================================================#

	def ReplaceInStringNCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([ "__", "ring __ ring __ ring", "__" ])
		o1.ReplaceInStringN(2, "ring", :With = "♥")
		? o1.Content()
		#--> [ "__", "♥ __ ♥ __ ♥", "__" ]
		*/

		pcNewSubStr = IfWith@Eval(pcNewSubStr)

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

		pcNewSubStr = IfWith@Eval(pcNewSubStr)
		
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
	

	  #----------------------------------------------------------------------------------#
	 #  REPLACING, INSIDE A GIVEN STRING, THE FIRST N OCCURRENCES OF A GIVEN SUBSTRING  #
	#----------------------------------------------------------------------------------#

	def ReplaceInStringNTheFirstNOccurrencesCS(pnStringNumber, n, pcSubStr, pcNewSubStr, pCaseSensitive)
		
		pcNewSubStr = IfWith@Eval(pcNewSubStr)

		cNewStr = This.StringNQ(n).ReplaceFirstNOccurrencesCSQ(n, pcSubStr, pCaseSensitive).Content()
		This.ReplaceStringAtPositionN(n, cNewStr)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceInStringNTheFirstNOccurrences(pnStringNumber, n, pcSubStr, pcNewSubStr)
		This.ReplaceInStringNTheFirstNOccurrencesCS(pnStringNumber, n, pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)

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

		def ReplaceInStringNTheFirstOccurrenceQ(pnStringNumber, pcSubStr, pcNewSubStr)
			This.ReplaceInStringNTheFirstOccurrence(pnStringNumber, pcSubStr, pcNewSubStr)
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

		def ReplaceInStringNTheLastOccurrenceQ(pnStringNumber, pcSubStr, pcNewSubStr)
			This.ReplaceInStringNTheLastOccurrence(pnStringNumber, pcSubStr, pcNewSubStr)
			return This

	  #================================================================#
	 #   REMOVING ALL OCCURRENCE OF A GIVEN STRING-ITEM IN THE LIST   #
	#================================================================#

	def RemoveAllCS(pcString, pCaseSensitive)

		if isList(pcString) and Q(pcString).IsOfNamedParam()
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

	  #==================================================#
	 #   REMOVING THE NTH OCCURRENCE OF A STRING-ITEM   #
	#==================================================#

	def RemoveNthOccurrenceCS(n, pcString, pCaseSensitive)
		n = This.FindNthOccurrenceCS(n, pcString, pCaseSensitive)
		This.RemoveStringAtPosition( n )


		#< @FunctionFluentForm

		def RemoveNthOccurrenceCSQ(n, pcString, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcString, pCaseSensitive)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveOccurrenceCS(n, pcString, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcString, pCaseSensitive)

			def RemoveOccurrenceCSQ(n, pcString, pCaseSensitive)
				This.RemoveOccurrenceCS(n, pcString, pCaseSensitive)
				return This

		def RemoveNthCS(n, pcStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)

			def RemoveNthCSQ(n, pcStr, pCaseSensitive)
				This.RemoveNthCS(n, pcStr, pCaseSensitive)
				return This

		#>

	def NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)
		aResult = This.Copy().RemoveNthOccurrenceCSQ(n, pcString, pCaseSensitive).Content()
		return aResult

		def NthOccurrenceOfThisStringItemRemovedCS(n, pcString, pCaseSensitive)
			return This.NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)

		def NthOccurrenceRemovedCS(n, pcString, pCaseSensitive)
			return This.NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)

		def NthRemovedCS(n, pcString, pCaseSensitive)
			return This.NthOccurrenceOfThisStringRemovedCS(n, pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveNthOccurrence(n, pcString)

		This.RemoveNthOccurrenceCS(n, pcString, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def RemoveOccurrence(n, pcString)
			This.RemoveNthOccurrence(n, pcString)

			def RemoveOccurrenceQ(n, pcString)
				This.RemoveOccurrence(n, pcString)
				return This

		def RemoveNth(n, pcStr)
			This.RemoveNthOccurrence(n, pcStr)

			def RemoveNthQ(n, pcStr)
				This.RemoveNth(n, pcStr)
				return This

		#>

	def NthOccurrenceOfThisStringRemoved(n, pcString)
		aResult = This.Copy().RemoveNthOccurrencesQ(n, pcString).Content()
		return aResult

		#< @FunctionAlternativeForms

		def NthOccurrenceOfThisStringItemRemoved(n, pcString)
			return This.NthOccurrenceOfThisStringRemoved(n, pcString)

		def NthOccurrenceRemoved(n, pcString)
			return This.NthOccurrenceOfThisStringRemoved(n, pcString)

		def NthRemoved(n, pcStr)
			return This.NthOccurrenceOfThisStringRemoved(n, pcString)

		#>

	  #----------------------------------------------------#
	 #   REMOVING THE FIRST OCCURRENCE OF A STRING-ITEM   #
	#----------------------------------------------------#

	def RemoveFirstOccurrenceCS(pcString, pCaseSensitive)
		This.RemoveStringAtPosition( This.FindFirstOccurrenceCS(pcString, pCaseSensitive) )

		def RemoveFirstOccurrenceCSQ(pcString, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(pcString, pCaseSensitive)
			return This
	
		def RemoveFirstCS(pcString, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(pcString, pCaseSensitive)

			def RemoveFirstCSQ(pcString, pCaseSensitive)
				This.RemoveFirstCS(pcString, pCaseSensitive)
				return This

	def FirstOccurrenceRemovedCS(pcString, pCaseSensitive)
		aResult = This.Copy().RemoveFirstOccurrenceCSQ(pcString, pCaseSensitive).Content()
		return aResult

		def FirstRemovedCS(pcString, pCaseSensitive)
			return This.FirstOccurrenceRemovedCS(pcString, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveFirstOccurrence(pcString)
		This.RemoveFirstOccurrenceCS(pcString, :CaseSensitive = TRUE)

		def RemoveFirstOccurrenceQ(pcString)
			This.RemoveFirstOccurrence(pcString)
			return This

		def RemoveFirst(pcString)
			This.RemoveFirstOccurrence(pcString)

			def RemoveFirstQ(pcString)
				This.RemoveFirst(pcString)
				return This

	def FirstOccurrenceRemoved(pcString)
		aResult = This.Copy().RemoveFirstOccurrenceQ(pcString).Content()
		return aResult

		def FirstRemoved(pcString)
			return This.FirstOccurrenceRemoved(pcString)

	  #---------------------------------------------------#
	 #   REMOVING THE LAST OCCURRENCE OF A STRING-ITEM   #
	#---------------------------------------------------#

	def RemoveLastOccurrenceCS(pcString, pCaseSensitive)
		This.RemoveStringAtPosition( This.FindLastOccurrenceCS(pcString, pCaseSensitive) )

		def RemoveLastOccurrenceCSQ(pcString, pCaseSensitive)
			This.RemoveLastOccurrenceCS(pcString, pCaseSensitive)
			return This
	
		def RemoveLastCS(pcString, pCaseSensitive)
			This.RemoveLastOccurrenceCS(pcString, pCaseSensitive)

			def RemoveLastCSQ(pcString, pCaseSensitive)
				This.RemoveLastCS(pcString, pCaseSensitive)
				return This

	def LastOccurrenceRemovedCS(pcString, pCaseSensitive)
		aResult = This.Copy().RemoveLastOccurrenceCSQ(pcString, pCaseSensitive).Content()
		return aResult

		def LastRemovedCS(pcString, pCaseSensitive)
			return This.LastOccurrenceRemovedCS(pcString, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def RemoveLastOccurrence(pcString)
		This.RemoveLastOccurrenceCS(pcString, :CaseSensitive = TRUE)

		def RemoveLastOccurrenceQ(pcString)
			This.RemoveLastOccurrence(pcString)
			return This

		def RemoveLast(pcString)
			This.RemoveLastOccurrence(pcString)

			def RemoveLastQ(pcString)
				This.RemoveLast(pcString)
				return This

	def LastOccurrenceRemoved(pcString)
		aResult = This.Copy().RemoveLastOccurrenceQ(pcString).Content()
		return aResult

		def LastRemoved(pcString)
			return This.LastOccurrenceRemoved(pcString)

	   #===================================================#
	  #   REMOVING NEXT NTH OCCURRENCE OF A STRING-ITEM   #
	 #   STARTING AT A GIVEN POSITION IN THE LIST        #
	#===================================================#

	def RemoveNextNthOccurrenceCS(n, pcString, pnStartingAt, pCaseSensitive)
		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " +
			 This.NumberOfStrings() + ")") = len(panList) )

			StzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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
		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

	#-- WITHOUT CASESENSITIVITY

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
		         StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " +
			 This.NumberOfStrings() + ")") = len(panList) )

			StzRaise("Incorrect param! panList must be a list of numbers between 1 and This.NumberOfStrings().")
		ok

		if isList(pcString) and StzListQ(pcString).IsOfNamedParam()
			pcString = pcString[2]
		ok

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtNamedParam()
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
			StzRaise("Incorrect param! pnStartingAt must be a number.")
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

	  #========================================================#
	 #   REMOVING A STRING-ITEM BY SPECIFYING ITS POSITION    #
	#========================================================#

	def RemoveStringAtPosition(n)
		if isList(n)
			This.RemoveStringsAtThesePositions(n)
			return
		ok

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

		if NOT ( isNumber(n) and n != 0 )
			StzRaise("Incorrect param! n must be a number different from zero.")
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
		return aResult

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

		def RemoveFirstIem()
			This.RemoveFirstString()

			def RemoveFirstItemQ()
				This.RemoveFirstItem()
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


	  #==================================================#
	 #   REMOVING THE GIVEN NTH STRING-ITEM (IF ANY)    #
	#==================================================#

	def RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)
	
		if This.NthStringQ(n).IsEqualToCS(pcStr, pCaseSensitive)
			This.RemoveStringAtPosition(n)
		ok

		#< @FunctionFluentForm

		def RemoveThisStringAtPositionCSQ(n, pcStr, pCaseSensitive)
			This.RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveThisStringItemAtPositionCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisStringItemAtPositionCSQ(n, pcStr, pCaseSensitive)
				This.RemoveThisStringItemAtPositionCS(n, pcStr, pCaseSensitive)
				return This

		#--

		def RemoveThisStringAtCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisStringAtCSQ(n, pcStr, pCaseSensitive)
				RemoveThisStringAtCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveThisStringItemAtCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringItemAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisStringItemAtCSQ(n, pcStr, pCaseSensitive)
				RemoveThisStringItemAtCS(n, pcStr, pCaseSensitive)
				return This

		#--

		def RemoveThisNthStringCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisNthStringCSQ(n, pcStr, pCaseSensitive)
				This.RemoveThisNthStringCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveThisNthStringItemCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringItemAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisNthStringItemCSQ(n, pcStr, pCaseSensitive)
				This.RemoveThisNthStringItemCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveThisNthItemCS(n, pcStr, pCaseSensitive)
			This.RemoveThisStringAtPositionCS(n, pcStr, pCaseSensitive)

			def RemoveThisNthItemCSQ(n, pcStr, pCaseSensitive)
				This.RemoveThisNthItemCS(n, pcStr, pCaseSensitive)
				return This

		#>

	def ThisStringAtPositionNRemovedCS(n, pcStr, pCaseSensitive)
		aResult = This.Copy().RemoveThisStringItemAtPositionCSQ(n, pcStr, pCaseSensitive).Content()
		return aResult

		def ThisStringItemAtPositionNRemovedCS(n, pcStr, pCaseSensitive)
			return This.ThisStringAtPositionNRemovedCS(n, pcStr, pCaseSensitive)

		def ThisNthStringRemovedCS(n, pcStr, pCaseSensitive)
			return This.ThisStringAtPositionNRemovedCS(n, pcStr, pCaseSensitive)

		def ThisNthStringItemRemovedCS(n, pcStr, pCaseSensitive)
			return This.ThisStringAtPositionNRemovedCS(n, pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveThisStringAtPosition(n, pcStr)
		This.RemoveThisStringAtPositionCS(n, pcStr, :CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def RemoveThisStringAtPositionQ(n, pcStr)
			This.RemoveThisStringAtPosition(n, pcStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveThisStringItemAtPosition(n, pcStr)
			This.RemoveThisStringAtPosition(n, pcStr)

			def RemoveThisStringItemAtPositionQ(n, pcStr)
				This.RemoveThisStringItemAtPosition(n, pcStr)
				return This

		#--

		def RemoveThisStringAt(n, pcStr)
			This.RemoveThisStringAtPosition(n, pcStr)

			def RemoveThisStringAtQ(n, pcStr)
				RemoveThisStringAt(n, pcStr)
				return This

		def RemoveThisStringItemAt(n, pcStr)
			This.RemoveThisStringItemAtPosition(n, pcStr)

			def RemoveThisStringItemAtQ(n, pcStr)
				RemoveThisStringItemAt(n, pcStr)
				return This

		#--

		def RemoveThisNthString(n, pcStr)
			This.RemoveThisStringAtPosition(n, pcStr)

			def RemoveThisNthStringQ(n, pcStr)
				This.RemoveThisNthString(n, pcStr)
				return This

		def RemoveThisNthStringItem(n, pcStr)
			This.RemoveThisStringItemAtPosition(n, pcStr)

			def RemoveThisNthStringItemQ(n, pcStr)
				This.RemoveThisNthStringItem(n, pcStr)
				return This

		def RemoveThisNthItem(n, pcStr)
			This.RemoveThisStringAtPosition(n, pcStr)

			def RemoveThisNthItemQ(n, pcStr)
				This.RemoveThisNthItem(n, pcStr)
				return This

		#>

	def ThisStringAtPositionNRemoved(n, pcStr)
		aResult = This.Copy().RemoveThisStringItemAtPositionQ(n, pcStr).Content()
		return aResult

		def ThisStringItemAtPositionNRemoved(n, pcStr)
			return This.ThisStringAtPositionNRemoved(n, pcStr)

		def ThisNthStringRemoved(n, pcStr)
			return This.ThisStringAtPositionNRemoved(n, pcStr)

		def ThisNthStringItemRemoved(n, pcStr)
			return This.ThisStringAtPositionNRemoved(n, pcStr)

	  #----------------------------------------------------------#
	 #    REMOVING THE GIVEN FIRST STRING (IF ANY) IN THE LIST  #
	#----------------------------------------------------------#

	def RemoveThisFirstStringCS(pcStr, pCaseSensitive)
		This.RemoveThisStringAtPositionCS(1, pcStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveThisFirstStringCSQ(pcStr, pCaseSensitive)
			This.RemoveThisFirstStringCS(pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveThisFirstStringItemCS(pcStr, pCaseSensitive)
			This.RemoveThisFirstStringCS(pcStr, pCaseSensitive)

			def RemoveThisFirstStringItemCSQ(pcStr, pCaseSensitive)
				This.RemoveThisFirstStringItemCS(pcStr, pCaseSensitive)
				return This

		#>

	def ThisFirstStringRemovedXTCS(pcStr, pCaseSensitive)
		aResult = This.Copy().RemoveThisFirstStringCSQ(pcStr, pCaseSensitive).Content()
		return aResult

		def ThisFirstStringItemRemovedXTCS(pcStr, pCaseSensitive)
			return This.ThisFirstStringRemovedXTCS(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveThisFirstString(pcStr)
		This.RemoveThisStringAtPosition(1, pcStr)

		#< @FunctionFluentForm

		def RemoveThisFirstStringQ(pcStr)
			This.RemoveThisFirstString(pcStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveThisFirstStringItem(pcStr)
			This.RemoveThisFirstString(pcStr)

			def RemoveThisFirstStringItemQ(pcStr)
				This.RemoveThisFirstStringItem(pcStr)
				return This

		#>

	def ThisFirstStringRemovedXT(pcStr)
		aResult = This.Copy().RemoveThisFirstStringQ(pcStr).Content()
		return aResult

		def ThisFirstStringItemRemovedXT(pcStr)
			return This.ThisFirstStringRemovedXT(pcStr)

	  #----------------------------------------------------------#
	 #    REMOVING THE GIVEN LAST STRING (IF ANY) IN THE LIST   #
	#----------------------------------------------------------#

	def RemoveThisLastStringCS(pcStr, pCaseSensitive)
		This.RemoveThisStringAtPositionCS(This.NumberOfStrings(), pcStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveThisLastStringCSQ(pcStr, pCaseSensitive)
			This.RemoveThisLastStringCS(pcStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveThisLastStringItemCS(pcStr, pCaseSensitive)
			This.RemoveThisLastStringCS(pcStr, pCaseSensitive)

			def RemoveThisLastStringItemCSQ(pcStr, pCaseSensitive)
				This.RemoveThisLastStringItemCS(pcStr, pCaseSensitive)
				return This

		#>

	def ThisLastStringRemovedXTCS(pcStr, pCaseSensitive)
		aResult = This.Copy().RemoveThisLastStringCSQ(pcStr, pCaseSensitive).Content()
		return aResult

		def ThisLastStringItemRemovedXTCS(pcStr, pCaseSensitive)
			return This.ThisLastStringRemovedXT(pcStr, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveThisLastString(pcStr)
		This.RemoveThisStringAtPosition(1, pcStr)

		#< @FunctionFluentForm

		def RemoveThisLastStringQ(pcStr)
			This.RemoveThisLastString(pcStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveThisLastStringItem(pcStr)
			This.RemoveThisLastString(pcStr)

			def RemoveThisLastStringItemQ(pcStr)
				This.RemoveThisLastStringItem(pcStr)
				return This

	def ThisLastStringRemovedXT(pcStr)
		aResult = This.Copy().RemoveThisLastStringQ(pcStr).Content()
		return aResult

		def ThisLastStringItemRemovedXT(pcStr)
			return This.ThisLastStringRemovedXT(pcStr)

	  #=======================================================#
	 #  REMOVING MANY STRINGS BY SPECIFYING THEIR POSITIONS  #
	#=======================================================#

	def RemoveStringsAtPositions(panPositions)
		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			StzRaise("Incorrect param type! panPositions must be a list of numbers.")
		ok

		nLen = len(panPositions)
		if nLen = 0
			return
		ok

		panPositions = ring_sort(panPositions)

		for i = nLen to 1 step -1

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

		if isList(pnStart) and Q(pnStart).IsFromNamedParam()
			pnStart = pnStart[2]
		ok

		if isString(pnStart)
			oStart = Q(pnStart)
			if oStart.IsOneOfThese([
					:First, :FirstPosition,
				      	:FirstString, :FirstStringItem ])
				  
				pnStart = 1

			but oStart.IsOneOfThese([
					:Last, :LastPosition,
				      	:LastString, :LastStringItem ])

				pnStart = This.NumberOfStrings()
			ok
		ok

		if NOT isNumber(pnStart)
			StzRaise("Incorrect param! n must be a number.")
		ok

		# Checking the correctness of the pnRange param

		if isList(pnRange) and
		   isString(pnRange[1]) and

		   ( Q(pnRange[1]).IsOneOfTheseCS([ :UpToN, :UpToNStrings, :UpToNStringItems ]) )

		   	pnRange = pnRange[2]
		ok
	
		if NOT isNumber(pnRange)
			StzRaise("Incorrect param type! pnRange must be a number.")
		ok

		if pnRange < 0
			pnStart = pnStart + pnRange + 1
			pnRange = -pnRange
		ok

		# Checking the correctness of the range of the two params

		n1 = pnStart
		n2 = pnStart + pnRange - 1

		# Doing the job

		This.RemoveSection(n1, n2)		

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
			( Q(n1).IsFromNamedParam() or Q(n1).IsFromNamedParam()  or
			  Q(n1).IsFromPositionNamedParam() )

			n1 = n1[2]
		ok

		if isList(n2) and ( Q(n2).IsToNamedParam() or Q(n2).IsToPositionNamedParam() )
			n2 = n2[2]
		ok

		if isString(n1) and
			( Q(n1).IsOneOfThese([
				:First, :FirstPosition,
				:FirstString, :FirstStringItem ]) )

			n1 = 1
		ok

		if isString(n2) and
			( Q(n2).IsOneOfThese([
				:Last, :LastPosition,
				:LastString, :LastStringItem ]) )
 
			n2 = This.NumberOfStrings()
		ok

		if NOT ( isNumber(n1) and isNumber(n2) )
			StzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT ( StzNumberQ(n1).IsBetween(1, This.NumberOfStrings()) and
		         StzNumberQ(n2).IsBetween(1, This.NumberOfStrings()) )

			StzRaise("Out of range!")
		ok

		# Doing the job (Qt-side)


		This.RemoveStringsAtPositions(n1:n2)

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

			StzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
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

	def IsBoundedByCS(pacBounds, pCaseSensitive)
		bResult = FALSE

		if isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]

		but isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		if This.FirstStringQ().IsEqualToCS(cBound1, pCaseSensitive) and
		   This.FirstStringQ().IsEqualToCS(cBound2, pCaseSensitive)

			bResult = TRUE

		ok

		if This.FirstStringQ().IsEqualToCS(cBound1, pCaseSensitive) and
		   This.FirstStringQ().IsEqualToCS(cBound2, pCaseSensitive)

			bResult = TRUE

		ok

		return bResult

		def IsBoundedByTheseTwoStringsCS(pacBounds, pCaseSensitive)
			return IsBoundedByCS(pacBounds, pCaseSensitive)

		def IsBoundedByTheseTwoStringItemsCS(pacBounds, pCaseSensitive)
			return IsBoundedByCS(pacBounds, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def IsBoundedBy(pacBounds)
		return This.IsBoundedByCS(pacBounds, :CaseSensitive = TRUE)

		def IsBoundedByTheseTwoStrings(pacBounds)
			return This.IsBoundedBy(pacBounds)

		def IsBoundedByTheseTwoStringItems(pacBounds)
			return This.IsBoundedBy(pacBounds)

	  #-------------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST IS MADE OF 2 STRINGS THAT ARE BOUNDS OF A GIVEN STRING  #
	#-------------------------------------------------------------------------------#

	def AreBoundsOfCS(pcStr, pIn, pnUpToNChars, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzListOfStrings([ [ "aa", "aa" ], [ "bb", "bb" ] ])
		? o1.AreBoundsOf("word", :In = "aaWORDbb and bbWORDbb", :UpToNChars = 2)
		#--> TRUE

		*/

		// TODO

	#-- WITHOUT CASESNESITIVITY

	def AreBoundsOf(pcStr, pIn, pnUpToNChars)
		return  This.AreBoundsOfCS(pcStr, pIn, pnUpToNChars, :CS = TRUE)

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

		/* NOTE:

		We could use Qt.ReplaceInStrings() directly when supported
		by RingQt, like this:

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
		
		acContent = This.Content()
		nLen = len(acContent)

		acResult = []

		for i = 1 to nLen
			acResult + Q(acContent[i]).RemoveCSQ(pcSubStr, pCaseSensitive).Content()
		next
		
		This.Update(acResult)

		#< @FunctionFluentForm

		def RemoveSubStringCSQ(pcSubStr, pCaseSensitive)
			This.RemoveSubStringCS(pcSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveAllOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			This.RemoveStringCS(pcSubStr, pCaseSensitive)

			def RemoveAllOccurrencesOfSubStringCSQ(pcSubStr, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringCS(pcSubStr, pCaseSensitive)
				return This

		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveSubString(pcSubStr)
		This.RemoveSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveSubStringQ(pcSubStr)
			This.RemoveSubString(pcSubStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveAllOccurrencesOfSubString(pcSubStr)
			This.RemoveSubStringCS(pcSubStr, pCaseSensitive)

			def RemoveAllOccurrencesOfSubStringQ(pcSubStr)
				This.RemoveAllOccurrencesOfSubString(pcSubStr)
				return This

		#>

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
			StzRaise("Incorrect param! n must be a number.")
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
			This.RemoveNthSubString(n, pcSubStr)

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
			StzRaise("Incorrect param type! You must provide a list of strings.")
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
			StzRaise("Incorrect param! n must be a number.")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
				StzRaise("Unsupported return type!")
		off

		#>

		#< @FunctionAlternativeForms

		def YieldFromEachChar(pcCode)
			return This.Yield(pcCode)

			def YieldFromEachCharQ(pcCode)
				return This.YieldFromEachCharQR(pcCode, :stzList)
		
			def YieldFromEachCharQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
			off

		def Harvest(pcCode)
			return This.Yield(pcCode)

			def HervestQ(pcCode)
				return This.YieldFromEachCharQR(pcCode, :stzList)
		
			def HarvestQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
			off

		def HarvestFromEachChar(pcCode)
			return This.Yield(pcCode)

			def HarvestFromEachCharQ(pcCode)
				return This.HarvestFromEachCharQR(pcCode, :stzList)
		
			def HarvestFromEachCharQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def YieldFromPositions(panPositions, pcCode)
			return This.YieldFrom(panPositions, pcCode)

			def YieldFromPositionsQ(paPositions, pcCode)
				return This.YieldFromPositionsQR(paPositions, pcCode, :stzList)
		
			def YieldFromPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
				off

		def YieldFromCharsAt(panPositions, pcCode)
			return This.YieldFrom(panPositions, pcCode)

			def YieldFromCharsAtQ(paPositions, pcCode)
				return This.YieldFromCharsAtQR(paPositions, pcCode, :stzList)
		
			def YieldFromCharsAtQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
				off

		def YieldFromCharsAtPositions(panPositions, pcCode)
			return This.YieldOn(panPositions, pcCode)

			def YieldFromCharsAtPositionsQ(paPositions, pcCode)
				return This.YieldFromCharsAtPositionsQR(paPositions, pcCode, :stzList)
		
			def YieldFromCharsAtPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
			off

		def HarvestFromPositions(panPositions, pcCode)
			return This.HarvestFrom(panPositions, pcCode)

			def HarvestFromPositionsQ(paPositions, pcCode)
				return This.HarvestFromPositionsQR(paPositions, pcCode, :stzList)
		
			def HarvestFromPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
				off

		def HarvestFromCharsAt(panPositions, pcCode)
			return This.HarvestFrom(panPositions, pcCode)

			def HarvestFromCharsAtQ(paPositions, pcCode)
				return This.HarvestFromCharsAtQR(paPositions, pcCode, :stzList)
		
			def HarvestFromCharsAtQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
				off

		def HarvestFromCharsAtPositions(panPositions, pcCode)
			return This.HarvestOn(panPositions, pcCode)

			def HarvestFromCharsAtPositionsQ(paPositions, pcCode)
				return This.HarvestFromCharsAtPositionsQR(paPositions, pcCode, :stzList)
		
			def HarvestFromCharsAtPositionsQR(paPositions, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromSections(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestFromSections(paSections, pcCode) )
	
				other
					StzRaise("Unsupported param type!")
				off
	
		def HarvestSections(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestSectionsQ(paSections, pcCode)
				return This.HarvestSections(paSections, pcCode, :stzList)

			def HarvestSectionsQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestSections(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestSections(paSections, pcCode) )
	
				other
					StzRaise("Unsupported param type!")
				off
		#>

	def YieldFromSectionsOneByOne(paSections, pcCode)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )

			StzRaise("Incorrect param! paSections must be a list of pairs of numbers.")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.YieldFromSectionsOneByOneQ(paSections, pcCode) )

			on :stzListOfLists
				return new stzListOfLists( This.YieldFromSectionsOneByOneQ(paSections, pcCode) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def HarvestFromSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestFromSectionsOneByOneQ(paSections, pcCode)
				return This.HarvestFromSectionsOneByOne(paSections, pcCode, :stzList)

			def HarvestFromSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestFromSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestFromSectionsOneByOne(paSections, pcCode) )
	
				other
					StzRaise("Unsupported param type!")
				off
				
		def HarvestSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def HarvestSectionsOneByOneQ(paSections, pcCode)
				return This.HarvestSectionsOneByOne(paSections, pcCode, :stzList)

			def HarvestSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestSectionsOneByOne(paSections, pcCode) )
	
				other
					StzRaise("Unsupported param type!")
				off

		def YieldSectionsOneByOne(paSections, pcCode)
			return This.YieldFromSections(paSections, pcCode)

			def YieldSectionsOneByOneQ(paSections, pcCode)
				return This.YieldSectionsOneByOne(paSections, pcCode, :stzList)

			def YieldSectionsOneByOneQR(paSections, pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedTypeNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.YieldSectionsOneByOne(paSections, pcCode) )

				on :stzListOfLists
					return new stzListOfLists( This.YieldSectionsOneByOne(paSections, pcCode) )
	
				other
					StzRaise("Unsupported param type!")
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
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
					StzRaise("Unsupported return type!")
			off

		#>

		#> @FunctionAlternativeForm

		def HarvestW(pcCode, pcCondition)
			return This.YieldW(pcCode, pcCondition)

			def HervestWQ(pcCode, pcCondition)
				return This.HarvestWQR(pcCode, pcCondition, :stzList)

			def HervestWQR(pcCode, pcCondition, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("IncorrectType! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.HarvestW(pcCode, pcCondition) )

				on :stzListOfLists
					return new stzListOfLists( This.HarvestW(pcCode, pcCondition) )

				other
					StzRaise("Unsupported return type!")
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

			StzRaise("Invalid param type! panPositions must be a list of numbers.")
		ok

		if len(panPositions) = 0
			return
		ok

		if NOT isString(pcCode)
			StzRaise("Invalid param type! pcCode must be a string.")
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

			StzRaise("Syntax error! pcCode must begin with '@string ='.")
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
			StzRaise("Incorrect param! pcAction must be a string.")
		ok

		if isList(pcCondition) and Q(pcCondition).IsIfOrWhereNamedParam()
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
			   oCondition.RemoveSpacesQ().ContainsCS("This[@i+1]", :CS = FALSE )

				bEval = FALSE
			ok

			if @i = 1 and
			   oCondition.RemoveSpacesQ().ContainsCS("This[@i-1]", :CS = FALSE )

				bEval = FALSE
			ok

			if bEval
				eval( "bOk = (" + cCondition + ")" )

				if bOk

					if @i = This.NumberOfStrings() and
					   oAction.RemoveSpacesQ().ContainsCS("This[@i+1]", :CS = FALSE)

						bEval = FALSE
					ok

					if @i = 1 and
					   oAction.ContainsCS("This[@i-1]", :CS = FALSE)

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
		nLen = This.NumberOfStrings()

		for i = 1 to nLen
			n = This.NumberOfOccurrenceCS(This.String(i), pCaseSensitive)

			if n > 1
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsDuplicatedStringItemsCS(pCaseSensitive)
			return This.ContainsDuplicatedStringsCS(pCaseSensitive)

		def ContainsDuplicationsCS(pCaseSensitive)
			return This.ContainsDuplicatedStringsCS(pCaseSensitive)

		def ContainsDuplicatesCS(pCaseSensitive)
			return This.ContainsDuplicatedStringsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedStrings()
		return This.ContainsDuplicatedStringsCS(:CaseSensitive = TRUE)
	
		def ContainsDuplicatedStringItems()
			return This.ContainsDuplicatedStrings()

		def ContainsDuplications()
			return This.ContainsDuplicatedStrings()

		def ContainsDuplicates()
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

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicated(pcString)
		return This.ContainsDuplicatedCS(pcString, :CaseSensitive = TRUE)

		def ContainsDuplicatedString(pcString)
			return This.ContainsDuplicated(pcString)

		def ContainsDuplicatedStringItem(pcString)
			return This.ContainsDuplicatedCS(pcString)

	  #------------------------------------------------------#
	 #   CHECHKING IF A STRING-ITEM IS DUPLICATED N-TIMES   #
	#------------------------------------------------------#

	def ContainsDuplicatedNTimesCS(n, pcStr, pCaseSensitive)
		if This.NumberOfDuplicatesOfStringCS(pcStr, pCaseSensitive) = n
			return TRUE
		else
			return FALSE
		ok

		def StringIsDuplicatedNTimesCS(n, pcString, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(n, pcString, pCaseSensitive)

		def StringItemIsDuplicatedNTimesCS(n, pcString, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(n, pcString, pCaseSensitive)
 
	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedNTimes(n, pcString)
		return This.ContainsDuplicatedNTimesCS(n, pcString, :CaseSensitive = TRUE)

		def StringIsDuplicatedNTimes(n, pcString)
			return This.ContainsDuplicatedNTimes(n, pcString)

		def StringItemIsDuplicatedNTimes(n, pcString)
			return This.ContainsDuplicatedNTimes(n, pcString)
 
	  #---------------------------------------------#
	 #   HOW MANY TIMES A STRING IS DUPLICATED ?   #
	#---------------------------------------------#

	def NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)
		nResult = 0

		if This.NumberOfOccurrenceCS(pcString, pCaseSensitive) > 1
			nResult = This.NumberOfOccurrence(pcString) - 1
		ok
		
		return nResult

		#< @FunctionAlternativeForms

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

		#--

		def NumberOfDuplicationsOfStringCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		def NumberOfDuplicationsOfStringItemCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		def NumberOfDuplicationsOfCS(pcString, pCaseSensitive)
			return This.NumberOfTimesStringIsDuplicatedCS(pcString, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfTimesStringIsDuplicated(pcString)
		return This.NumberOfTimesStringIsDuplicatedCS(pcString, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfTimesStringItemIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfTimesThisStringIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfTimesThisStringItemIsDuplicated(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		#--

		def NumberOfDuplicatesOfString(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfDuplicatesOfStringItem(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		#--

		def NumberOfDuplicationsOfString(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfDuplicationsOfStringItem(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		def NumberOfDuplicationsOf(pcString)
			return This.NumberOfTimesStringIsDuplicated(pcString)

		#>

	  #----------------------------------------------------#
	 #  CHECKING THE EXISTENCE OF NON DUPLICATED STRINGS  #
	#====================================================#

	def ContainsNonDuplicatedStringsCS(pCaseSensitive)
		bResult = FALSE

		nLen = This.NumberOfStrings()
		for i = 1 to nLen
			anPos = This.FindCS(This.String(i), pCaseSensitive)
			if len(anPos) = 1
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsNoDuplicationsCS(pCaseSensitive)
			return This.ContainsNonDuplicatedStringsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNonDuplicatedStrings()
		return This.ContainsNonDuplicatedStringsCS(:CaseSensitive = TRUE)

		def ContainsNoDuplications()
			return This.ContainsNonDuplicatedStrings()

	  #----------------------------------------------#
	 #  GETTING THE LIST OF NON DUPLICATED STRINGS  #
	#----------------------------------------------#

	def NonDuplicatedStringsCS(pCaseSensitive)
		acResult = This.Copy().RemoveDuplicatedStringsCSQ(pCaseSensitive).Content()
		return acResult

	#-- WITHOUT CASESENSITIVITY

	def NonDuplicatedStrings()
		return This.NonDuplicatedStringsCS(:CaseSensitive = TRUE)

	  #------------------------------------#
	 #  NUMBER OF NON DUPLICATED STRINGS  #
	#------------------------------------#

	def NumberOfNonDuplicatedStringsCS(pCaseSensitive)
		nResult = len(This.NonDuplicatedStringsCS(pCaseSensitive))
		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfNonDuplicatedStrings()
		return This.NumberOfNonDuplicatedStringsCS(:CaseSensitive = TRUE)

	  #----------------------------------#
	 #  FINDING NON DUPLICATED STRINGS  #
	#----------------------------------#

	def FindNonDuplicatedStringsCS(pCaseSensitive)
		acNonDuplicated = This.NonDuplicatedStringsCS(pCaseSensitive)
		nLen = len(acNonDuplicated)
		anResult = []

		for i = 1 to nLen
			# By defintion, a non duplicated string apprears once
			nPos = This.FindFirstCS(acNonDuplicated[i], pCaseSensitive)
			anResult + nPos
		next

		anResult = Q(anResult).Sorted()
		return anResult

	#-- WITHOUT CASESENSITIVITY

	def FindNonDuplicatedStrings()
		return This.FindNonDuplicatedStringsCS(:CaseSensitive = TRUE)

	  #----------------------------------------------#
	 #  NON DUPLICATED STRINGS AND THEIR POSITIONS  #
	#----------------------------------------------#

	def NonDuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		acNonDuplicated = This.NonDuplicatedStringsCS(pCaseSensitive)
		nLen = len(acNonDuplicated)

		aResult = []
		for i = 1 to nLen
			# By definition, a non duplicated string appears once
			nPos = This.FindFirstCS(acNonDuplicated[i], pCaseSensitive)
			aResult + [ acNonDuplicated[i], nPos ]
		next

		return aResult

		def NonDuplicatedStringsZCS(pCaseSensitive)
			return This.NonDuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NonDuplicatedStringsAndTheirPositions()
		return This.NonDuplicatedStringsAndTheirPositionsCS(:CaseSensitive = TRUE)

		def NonDuplicatedStringsZ()
			return This.NonDuplicatedStringsAndTheirPositions()

	  #--------------------------#
	 #   NUMBER OF DUPLICATES   #
	#==========================#

	def NumberOfDuplicatesCS(pCaseSensitive)

		nResult = len( This.FindDuplicatesCS(pCaseSensitive) )
		return nResult

		def HowManyDuplicatesCS(pCaseSensitive)
			return This.NumberOfDuplicatesCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(:CaseSensitive = TRUE)

		def HowManyDuplicates()
			return This.NumberOfDuplicates()

	  #----------------------#
	 #  FINDING DUPLICATES  #
	#----------------------#

	def FindDuplicatesCS(pCaseSensitive)
		nLen = This.NumberOfStrings()
		aTemp = []

		anResult = []
		for i = 1 to nLen

			if NOT Q(aTemp).ContainsCS(This.String(i), pCaseSensitive)
				aTemp + This.String(i)
			else
				anResult + i
			ok

		next

		return anResult

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicates()
		return This.FindDuplicatesCS(:CaseSensitive = TRUE)

	  #------------------------------------------------#
	 #  DUPLICATES AND THEIR POSITIONS -- Z/Extended  #
	#------------------------------------------------#

	def DuplicatesAndTheirPositionsCS(pCaseSensitive)
		acDuplicates = This.DuplicatesCS(pCaseSensitive)
		anPositions = This.FindDuplicatesCS(pCaseSensitive)

		aResult = Association([ acDuplicates, anPositions ])
		return aResult

		def DuplicatesZCS(pCaseSensitive)
			return This.DuplicatesAndTheirPositionsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def DuplicatesAndTheirPositions()
		return This.DuplicatesAndTheirPositionsCS(:CaseSensitive = TRUE)

		def DuplicatesZ()
			return This.DuplicatesAndTheirPositions()

	  #-------------------------------------------------#
	 #  DUPLICATES AND THEIR POSITIONS -- UZ/Extended  #
	#-------------------------------------------------#

	def DuplicatesAndTheirPositionsUCS(pCaseSensitive)
		acDuplicated = This.DuplicatedStringsCS(pCaseSensitive)
		nLen = len(acDuplicated)

		aResult = []
		for i = 1 to nLen
			anPos = This.FindCSQ(acDuplicated[i], pCaseSensitive).FirstItemRemoved()
			if len(anPos) > 0
				aResult + [ acDuplicated[i], anPos ]
			ok
		next

		return aResult

		def DuplicatesUZCS(pCaseSensitive)
			return This.DuplicatesAndTheirPositionsUCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def DuplicatesAndTheirPositionsU()
		return This.DuplicatesAndTheirPositionsUCS(:CaseSensitive = TRUE)

		def DuplicatesUZ()
			return This.DuplicatesAndTheirPositionsU()

	  #----------------------------------#
	 #   NUMBER OF DUPLICATED STRINGS   #
	#==================================#

	def NumberOfDuplicatedStringsCS(pCaseSensitive)
		nResult = len( This.DuplicatedStringsCS(pCaseSensitive) )
		return nResult

		def NumberOfDuplicatedStringItemsCS(pCaseSensitive)
			return This.NumberOfDuplicatedStringsCS(pCaseSensitive)

		def HowManyDuplicatedStringsCS(pCaseSensitive)
			return This.NumberOfDuplicatedStringsCS(pCaseSensitive)

		def HowManyDuplicatedStringItemsCS(pCaseSensitive)
			return This.NumberOfDuplicatedStringsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfDuplicatedStrings()
		return This.NumberOfDuplicatedStringsCS(:CaseSensitive = TRUE)

		def NumberOfDuplicatedStringItems()
			return This.NumberOfDuplicatedStrings()

		def HowManyDuplicatedStrings()
			return This.NumberOfDuplicatedStrings()

		def HowManyDuplicatedStringItems()
			return This.NumberOfDuplicatedStrings()

	  #------------------------#
	 #   DUPLICATED STRINGS   #
	#------------------------#

	def DuplicatedStringsCS(pCaseSensitive)
		nLen = This.NumberOfStrings()
		aResult = []

		for i = 1 to nLen
			if This.NumberOfOccurrenceCS(This.String(i), pCaseSensitive) > 1 and
			   (NOT Q(aResult).ContainsCS(This.String(i), pCaseSensitive))

				aResult + This.String(i)
			ok
		next
		
		return aResult
		
		#< @FunctionFluentForm

		def DuplicatedStringsCSQ(pCaseSensitive)
			return This.DuplicatedStringsCSQR(pCaseSensitive, :stzList)

		def DuplicatedStringsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.DuplicatedStringsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.DuplicatedStringsCS(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def DuplicatedStringItemsCS(pCaseSensitive)
			return This.DuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringItemsCSQ(pCaseSensitive)
				return This.DuplicatedStringItemsCSQR(pCaseSensitive, :stzList)
	
			def DuplicatedStringItemsCSQR(pCaseSensitive, pcReturnType)
				return This.DuplicatedStringsCSQR(pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def DuplicatedStrings()
		return This.DuplicatedStringsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def DuplicatedStringsQ()
			return This.DuplicatedStringsQR(:stzList)

		def DuplicatedStringsQR(pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.DuplicatedStrings() )

			on :stzListOfStrings
				return new stzListOfStrings( This.DuplicatedStrings() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def DuplicatedStringItems()
			return This.DuplicatedStrings()

			def DuplicatedStringItemsQ()
				return This.DuplicatedStringItemsQR(:stzList)
	
			def DuplicatedStringItemsQR(pcReturntype)
				return This.DuplicatedStringsQR(pcReturntype)

		#>

	  #--------------------------------#
	 #   FINDING DUPLICATED STRINGS   #
	#--------------------------------#

	def FindDuplicatedStringsCS(pCaseSensitive)
		anResult = []

		acDuplicated = This.DuplicatedStringsCS(pCaseSensitive)

		nLen = len(acDuplicated)

		for i = 1 to nLen
			anPos = This.FindCS(acDuplicated[i], pCaseSensitive)
			nLenPos = len(anPos)
			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = Q(anResult).Sorted()
		return anResult

		
		#< @FunctionFluentForm

		def FindDuplicatedStringsCSQ(pCaseSensitive)
			return This.FindDuplicatedStringsCSQR(pCaseSensitive, :stzList)

		def FindDuplicatedStringsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStringsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.FindDuplicatedStringsCS(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindDuplicatedStringItemsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def FindDuplicatedStringItemsCSQ(pCaseSensitive)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, :stzList)
	
			def FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItemsCS(pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItemsCS(pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def PositionsOfDuplicatedStringsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def PositionsOfDuplicatedStringsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def DuplicatedStringsPositionsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringsPositionsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def DuplicatedStringsPositionsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def PositionsOfDuplicatedStringItemsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def PositionsOfDuplicatedStringItemsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		def DuplicatedStringItemsPositionsCS(pCaseSensitive)
			return This.FindDuplicatedStringsCS(pCaseSensitive)

			def DuplicatedStringItemsPositionsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedStringsCSQR(pCaseSensitive, :stzList)

			def DuplicatedStringItemsPositionsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedStringItemsCSQR(pCaseSensitive, pcReturntype)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatedStrings()
		return This.FindDuplicatedStringsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def FindDuplicatedStringsQ()
			return This.FindDuplicatedStringsQR(:stzList)

		def FindDuplicatedStringsQR(pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStrings() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedStrings() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def FindDuplicatedStringItems()
			return This.FindDuplicatedStrings()

			def FindDuplicatedStringItemsQ()
				return This.FindDuplicatedStringItemsQR(:stzList)
	
			def FindDuplicatedStringItemsQR(pcReturntype)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItems() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindDuplicatedStringItems() )
	
				other
					StzRaise("Unsupported return type!")
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

	  #--------------------------------------------#
	 #   DUPLICATED STRINGS AND THEIR POSITIONS   #
	#--------------------------------------------#

	def DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)
		acDuplicatedStrings = This.DuplicatedStringsCS(pCaseSensitive)
		nLen = len(acDuplicatedStrings)

		aResult = []
		for i = 1 to nLen
			str = acDuplicatedStrings[i]
			aResult + [ str, This.FindAllCS(str, pCaseSensitive) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def DuplicatedStringItemsAndTheirPositionsCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedStringsZCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedStringItemsZCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		#-- By nature, duplicated items are unique, so for convenience, we can add
		#-- the U extension to all of these alternatives

		def DuplicatedStringsAndTheirPositionsUCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedStringItemsAndTheirPositionsUCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedStringsUZCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedStringItemsUZCS(pCaseSensitive)
			return This.DuplicatedStringsAndTheirPositionsCS(pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def DuplicatedStringsAndTheirPositions()
		return This.DuplicatedStringsAndTheirPositionsCS(:CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def DuplicatedStringItemsAndTheirPositions()
			return This.DuplicatedStringsAndTheirPositions()

		def DuplicatedStringsZ()
			return This.DuplicatedStringsAndTheirPositions()

		def DuplicatedStringItemsZ()
			return This.DuplicatedStringsAndTheirPositions()

		#-- By nature, duplicated items are unique, so for convenience, we can add
		#-- the U extension to all of these alternatives

		def DuplicatedStringsAndTheirPositionsU()
			return This.DuplicatedStringsAndTheirPositions()

		def DuplicatedStringItemsAndTheirPositionsU()
			return This.DuplicatedStringsAndTheirPositions()

		def DuplicatedStringsUZ()
			return This.DuplicatedStringsAndTheirPositions()

		def DuplicatedStringItemsUZ()
			return This.DuplicatedStringsAndTheirPositions()

		#>

	  #---------------------------------------#
	 #   FINDING A GIVEN DUPLICATED STRING   #
	#---------------------------------------#

	def FindDuplicatedStringCS(pcString, pCaseSensitive)

		anPos = This.FindAllCS(pcString, pCaseSensitive)

		if len(anPos) > 1
			return anPos
		else
			return 0
		ok

		#< @FunctionFluentForm

		def FindDuplicatedStringCSQ(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCSQR(pcString, pCaseSensitive, :stzList)

		def FindDuplicatedStringCSQR(pcString, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedStringCS(pcString, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedStringCS(pcString, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindDuplicatedStringItemCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def FindDuplicatedStringItemCSQ(pcString, pCaseSensitive)
				return This.FindDuplicatedStringItemCSQR(pcString, pCaseSensitive, :stzList)
	
			def FindDuplicatedStringItemCSQR(pcString, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItemCS(pcString, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItemCS(pcString, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def FindDuplicatedCS(pcString, pCaseSensitive)
			return This.FindDuplicatedStringCS(pcString, pCaseSensitive)

			def FindDuplicatedCSQ(pcString, pCaseSensitive)
				return This.FindDuplicatedCSQR(pcString, pCaseSensitive, :stzList)
	
			def FindDuplicatedCSQR(pcString, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedCS(pcString, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedCS(pcString, pCaseSensitive) )
	
				other
					StzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedString(pcString) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedString(pcString) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindDuplicatedStringItem(pcString)
			return This.FindDuplicatedString(pcString)

			def FindDuplicatedStringItemQ(pcString)
				return This.FindDuplicatedStringItemQR(pcString, :stzList)
	
			def FindDuplicatedStringItemQR(pcString, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicatedStringItem(pcString) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicatedStringItem(pcString) )
	
				other
					StzRaise("Unsupported return type!")
				off

		def FindDuplicated(pcString)
			return This.FindDuplicatedString(pcString)

			def FindDuplicatedQ(pcString)
				return This.FindDuplicatedQR(pcString, :stzList)
	
			def FindDuplicatedQR(pcString, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Incorrect param type! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindDuplicated(pcString) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindDuplicated(pcString) )
	
				other
					StzRaise("Unsupported return type!")
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

	  #-----------------------------------------------#
	 #   FINDING DUPLICATES OF A GIVEN STRING-ITEM   #
	#-----------------------------------------------#

	def FindDuplicatesOfStringCS(pcStr, pCaseSensitive)
		anPos = This.FindAllCS(pcStr, pCaseSensitive)
		nLen = len(anPos)

		anResult = []

		if nLen > 1
			anResult = Q(anPos).FirstItemRemoved()
		ok

		return anResult
		

		def FindDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)

		def PositionsOfDuplicatesOfStringItemCS(pcStr, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pcStr, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatesOfString(pcStr)
		return This.FindDuplicatesOfStringCS(pcStr, :CaseSensitive = TRUE)

		def FindDuplicatesOfStringItem(pcStr)
			return This.FindDuplicatesOfString(pcStr)

		def PositionsOfDuplicatesOfStringItem(pcStr)
			return This.FindDuplicatesOfString(pcStr)


	  #----------------------------------------------------#
	 #   REMOVING ALL DUPLICATES IN THE LIST OF STRINGS   #
	#----------------------------------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)

		# Resolving pCaseSensitive

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isString(pCaseSensitive)
			if Q(pCaseSensitive).IsOneOfThese([
				:CaseSensitive, :IsCaseSensitive , :CS, :IsCS ])

				pCaseSensitive = TRUE
			
			but Q(pCaseSensitive).IsOneOfThese([
				:CaseInSensitive, :NotCaseSensitive, :NotCS,
				:IsCaseInSensitive, :IsNotCaseSensitive, :IsNotCS ])

				pCaseSensitive = FALSE
			ok

		ok

		if NOT IsBoolean(pCaseSensitive)
			stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		# Doing the job

		if pCaseSensitive = TRUE
			# If we are lucky, we use directly a Qt-based solution
			QStringListObject().removeDuplicates()

		else
			# Otherwise, we do it by ourselves
			anPos = This.FindDuplicatesCS(pCaseSensitive)
			This.RemoveStringsAtPositions(anPos)

		ok

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def DuplicatesRemovedCS(pCaseSensitive)
		acResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return acResult

		def ToSetCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def ToSetOfStringsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def ToSetOfStringItemsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def UniqueStringsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def UniqueStringItemsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def StringsUCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def StringItemsUCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

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
			return This.DuplicatesRemoved()
	
		def ToSetOfStrings()
			return This.DuplicatesRemoved()

		def ToSetOfStringItems()
			return This.DuplicatesRemoved()

		def UniqueStrings()
			return This.DuplicatesRemoved()

		def UniqueStringItems()
			return This.DuplicatesRemoved()

		def StringsU()
			return This.DuplicatesRemoved()

		def StringItemsU()
			return This.DuplicatesRemoved()

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

			StzRaise("Incorrect param! pacStr must be a list of strings.")
		ok

		nLen = len(pacStr)

		for i = 1 to nLen
			This.RemoveDuplicatesOfStringCS(pacStr[i], pCaseSensitive)
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

	  #-------------------------------#
	 #  REMOVING DUPLICATED STRINGS  #
	#-------------------------------#

	def RemoveDuplicatedStringsCS(pCaseSensitive)
		anPos = This.FindDuplicatedStringsCS(pCaseSensitive)

		if len(anPos) > 0
			This.RemoveStringsAtPositions(anPos)
		ok

		#< @FunctionFluentForm

		def RemoveDuplicatedStringsCSQ(pCaseSensitive)
			This.RemoveDuplicatedStringsCS(pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveDuplicatedStringItemsCS(pCaseSensitive)
			This.RemoveDuplicatedStringsCS(pCaseSensitive)

			def RemoveDuplicatedStringItemsCSQ(pCaseSensitive)
				This.RemoveDuplicatedStringItemsCS(pCaseSensitive)
				return This

		#>

	def DuplicatedStringsRemovedCS(pCaseSensitive)
		acResult = This.Copy().RemoveDuplicatedStringsCSQ(pCaseSensitive).Content()
		return acResult

		def DuplicatedStringItemsRemovedCS(pCaseSensitive)
			return This.DuplicatedStringsRemovedCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatedStrings()
		return This.RemoveDuplicatedStringsCS(:CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveDuplicatedStringsQ()
			This.RemoveDuplicatedStrings()
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveDuplicatedStringItems()
			This.RemoveDuplicatedStrings()

			def RemoveDuplicatedStringItemsQ()
				This.RemoveDuplicatedStringItems()
				return This

		#>

	def DuplicatedStringsRemoved()
		acResult = This.Copy().RemoveDuplicatedStringsQ().Content()
		return acResult

		def DuplicatedStringItemsRemoved()
			return This.DuplicatedStringsRemoved()

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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueCharsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueCharsCS(pCaseSensitive) )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueCharsCS(pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

	#-- WITHOUT CASESENSITIVITY

	def UniqueChars()
		return This.UniqueCharsCS(:CaseSensitive = TRUE)

		def UniqueCharsQ()
			return This.UniqueCharsQR(:stzList)

		def UniqueCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueChars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueChars() )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueChars() )

			other
				StzRaise("Unsupported param type!")
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
			return This.CommonCharsCSQR(pCaseSensitive, :stzList)
	
		def CommonCharsCSQR(pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
				StzRaise("Unsupported return type!")
			off

	#-- WITHOUT CASESENSITIVITY

	def CommonChars()
		return This.CommonCharsCS(:CaseSensitive = TRUE)

		def CommonCharsQ()
			return This.CommonCharsQR(:stzList)
	
		def CommonCharsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
				StzRaise("Unsupported return type!")
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

		def IsAnUppercase()
			return This.Uppercase()

		def IsUppercased()
			return This.Uppercase()

	def AllStringsAreUppercase()
		return This.IsUppercase()

		def AllStringItemsAreUppercase()
			return This.AllStringsAreUppercase()

	  #-----------------------------------#
	 #  LOWERCASING THE LIST OF STRINGS  #
	#-----------------------------------#

	def ApplyLowercase()
		This.Update( :With = This.Lowercased() )

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This
	
		def Lowercase()
			This.ApplyLowercase()
	
			def LowercaseQ()
				This.Lowercase()
				return This
		
	def Lowercased()
		acResult = This.ConcatenateUsingQ(NL).
			LowercaseQ().
			Splitted(:Using = NL)

		return acResult

	  #-----------------------------------#
	 #  UPPERCASING THE LIST OF STRINGS  #
	#-----------------------------------#

	def ApplyUppercase()
		This.Update( :With = This.Uppercased() )

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This
	
		def Uppercase()
			This.ApplyUppercase()
	
			def UppercaseQ()
				This.Uppercase()
				return This
		
	def Uppercased()
		acResult = This.ConcatenateUsingQ(NL).
			UppercaseQ().
			Splitted(:Using = NL)

		return acResult

#---------------

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
				return This.return This.LeftAlignXTQ(pnWidth, pcChar)

		#>

	def LeftAlignedXT(pnWidth, pcChar)
		aResult = This.Copy().LeftAlignXTQ(pnWidth, pcChar).Content()
		return aResult

		#< @FunctionAlternativeForms

		def AlignedToLeftXT(pnWidth, pcChar)
			return This.LeftAlignedXT(pnWidth, pcChar)
	
		def AdjustedToLeftXT(pnWidth, pcChar)
			return LeftAlignedXT(pnWidth, pcChar)

		#>

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

	  #=====================#
	 #     COMBINATIONS    #
	#=====================#

	def NumberOfCombinations()
		return len(This.Combinations()) # TODO: solve it mathematically.
	
	def Combinations()
	
		if This.NumberOfStrings() < 2
			StzRaise("Can't compute combinations for that list!")
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

		def SplitStringItems(cSep)
			return This.Split(cSep)

			def SplitStringItemsQ(cSep)
				return This.SplitQ(cSep)

			def SplitStringItemsQR(cSep, pcReturnType)
				return This.SplitQR(cSep, pcReturnType)

		def SplitEachString(cSep)
			return This.Split(cSep)

			def SplitEachStringQ(cSep)
				return This.SplitQ(cSep)

			def SplitEachStringQR(cSep, pcReturnType)
				return This.SplitQR(cSep, pcReturnType)

		def SplitEachStringItem(cSep)
			return This.Split(cSep)

			def SplitEachStringItemQ(cSep)
				return This.SplitQ(cSep)

			def SplitEachStringItemQR(cSep, pcReturnType)
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

		def StringItemsSplitted(cSep)
			return This.Splitted(cSep)

		def EachStringSplitted(cSep)
			return This.Splitted(cSep)

		def EachStringItemSplitted(cSep)
			return This.Splitted(cSep)

	  #----------------------------------------------------------#
	 #  GETTING EACH NTH SUBSTRING AFTER SPLITTING THE STRINGS  #
	#----------------------------------------------------------#

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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
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
				StzRaise("Unsupported return type!")
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

	#--

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

	  #---------------------------#
	 #   FINDING EMPTY STRINGS   #
	#---------------------------#

	def FindEmptyStrings()
		anResult = []

		for i = 1 to This.NumberOfStrings()
			if This.NthString(i) = NULL
				anResult + i
			ok
		next

		return anResult

		def FindEmptyStringItems()
			return This.FindEmptyStrings()

		def PositionsOfEmptyStrings()
			return This.FindEmptyStrings()

		def PositionsOfEmptyStringItems()
			return This.FindEmptyStrings()

	  #----------------------------#
	 #   REMOVING EMPTY STRINGS   #
	#----------------------------#

	def RemoveEmptyStrings()

		anPos = This.FindEmptyStrings()
		This.RemoveStringsAtPositions(anPos)

		def RemoveEmptyStringsQ()
			This.RemoveEmptyStrings()
			return This

	  #---------------------------------------------------------------#
	 #   COMPARING THE LIST OF STRINGS TO AN OTHER LIST OF STRINGS   # 
	#---------------------------------------------------------------#

	def IsEqualToCS(pcOtherListOfStr, pCaseSensitive)

		# Doublechecking inequality for potential performance gain
		# --> Of the two lists have different sizes, then they'r NOT equal!

		if This.NumberOfStrings() != Q(pcOtherListOfStr).NumberOfStrings()
			return FALSE
		ok

		# Otherwise, compare them the normal way...

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

	  #--------------------------------#
	 #  TRIMMING THE LIST OF STRINGS  #
	#--------------------------------#

	def Trim()
		This.TrimStart()
		This.TrimEnd()

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		acResult = This.Copy().TrimQ().Content()
		return acResult

	  #-----------------------------------------------#
	 #  TRIMMING THE LIST OF STRINGS FROM THE START  #
	#-----------------------------------------------#

	def TrimStart()
		
		if NOT This.FirstStringQ().IsMadeOf(" ")
			return
		ok

		nLen = This.NumberOfStrings()
		i = 0

		while TRUE
			i++
			if i > nLen
				return
			ok

			if NOT This.StringQ(i).IsMadeOf(" ")
				exit
			ok
		end

		This.RemoveSection(1, i-1)

		def TrimStartQ()
			This.TrimStart()
			return This

		def TrimFromStart()
			This.TrimStart()

			def TrimFromStartQ()
				This.TrimFromStart()
				return This

	  #-----------------------------------------------#
	 #  TRIMMING THE LIST OF STRINGS FROM THE END  #
	#-----------------------------------------------#

	def TrimEnd()
		
		if NOT This.LastStringQ().IsMadeOf(" ")
			return
		ok

		nLen = This.NumberOfStrings()
		i = nLen + 1

		while TRUE
			i--
			if i = 0
				return
			ok

			if NOT This.StringQ(i).IsMadeOf(" ")
				exit
			ok
		end

		This.RemoveSection(i + 1, nLen)

		def TrimEndQ()
			This.TrimEnd()
			return This

		def TrimFromEnd()
			This.TrimEnd()

			def TrimFromEndQ()
				This.TrimFromEnd()
				return This

	  #------------------------------------#
	 #  TRIMMING THE STRINGS IN THE LIST  #
	#------------------------------------#

	def TrimStrings()
		acContent = This.Content()
		nLen = This.NumberOfStrings()
		
		for i = 1 to nLen
			this.ReplaceNthString(i, Q(acContent[i]).Trimmed())
		next

		def TrimStringsQ()
			This.TrimStrings()
			return This


		def TrimStringItems()
			This.TrimStrings()

			def TrimStringItemsQ()
				This.TrimStrings()
				return This

		def TrimEach()
			This.TrimStrings()

			def TrimEachQ()
				This.TrimEach()
				return This

	def StringsTrimmed()
		acResult = This.Copy().TrimStringsQ().Content()
		return acResult

		def StringItemsTrimmed()
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

				if StzStringQ(pValue).TrimQ().IsBoundedBy(["{", "}" ])

					pcCondition = StzStringQ(pValue).TrimQ().BoundsRemoved("{","}")
					anResult = []
	
					nLen = This.NumberOfStrings()

					for @i = 1 to nLen

						@string = acContent[@i]

						cCode = 'bOk = ( ' + pcCondition + ' )'
						eval(cCode)
						if bOk
							anResult + @i
						ok

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
		

		but pcOp = "/" and ring_type(pValue) = "NUMBER"
			// Divides the list on pValue sublists (a list of lists)
			return This.ToStzList().SplitToNParts(pValue)

		but pcOp = "-"
			if isNumber(pValue) or isString(pValue)
				This.RemoveNthQ( ring_find(This.ListOfStrings(), pValue) )

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

	  #====================================#
	 #  REMOVING SPACES FROM EACH STRING  #
	#====================================#

	def RempoveSpacesFromEachString()
		nLen = This.NumberOfStrings()
		acContent = This.Content()

		for i = 1 to nLen
			This.ReplaceNthString(i, :With = Q(acContent[i]).WithoutSpaces())
		next

		def RemoveSpacesFromEachStringQ()
			This.RempoveSpacesFromEachString()
			return This

		def RemoveSpacesFromEachStringItem()
			This.RempoveSpacesFromEachString()

			def RemoveSpacesFromEachStringItemQ()
				This.RemoveSpacesFromEachStringItem()
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

		def StringItemsWithoutSpaces()
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
		return This.SubStrongsCS(:CaseSensitive = TRUE)

	  #-----------------------------------------------#
	 #  GETTING THE LIST OF SUBSTREACKS IN THE LIST  #
	#-----------------------------------------------#

	// A substreak is any string containg other strings from the list

	def SubStreaksCS(pCaseSensitive)
		/* EXAMPLE
		o1 = new stzListOfStrings([
			"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
		])
		
		? o1.SubStreaks()
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

	def SubStreaks()
		return This.SubStreaksCS(:CaseSensitive = TRUE)

	  #-----------------------------------#
	 #  SUBSTRONGS AND THEIR SUBSTREAKS  # TODO
	#-----------------------------------#

	def SubStrongsAndTheirSubStreaksCS(pCaseSensitive)
		/* ... */

		def SubStrongsAndSubStreaksCS(pCaseSensitive)
			return This.SubStrongsAndTheirSubStreaksCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStrongsAndTheirSubStreaks()
		return This.SubStrongsAndTheirSubStreaksCS(:CaseSensitive = TRUE)

		def SubStrongsAndSubStreaks()
			return This.SubStrongsAndTheirSubStreaks()

	  #-----------------------------------#
	 #  SUBSTREAKS AND THEIR SUBSTRONGS  # TODO
	#-----------------------------------#

	def SubStreaksAndTheirSubStrongsCS(pCaseSensitive)
		/* ... */

		def SubStreaksAndSubStrongsCS(pCaseSensitive)
			return This.SubStreaksAndTheirSubStrongsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStreaksAndTheirSubStrongs()
		return This.SubStreaksAndTheirSubStrongsCS(:CaseSensitive = TRUE)

		def SubStreaksAndSubStrongs()
			return This.SubStreaksAndTheirSubStrongs()

	  #----------------------------------#
	 #  FINDING SUBSTRONGS IN THE LIST  # TODO
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
	 #  FINDING SUBSTREAKS IN THE LIST  # TODO
	#----------------------------------#

	def FindSubStreaksCS(pCaseSensitive)
		/* ... */

		def FindAllSubStreaksCS(pCaseSensitive)
			return This.FindFindSubStreaksCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubStreaks()
		/* ... */

		def FindAllSubStreaks()
			return This.FindSubStreaks()
