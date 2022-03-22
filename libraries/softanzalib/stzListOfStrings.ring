
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

class stzListOfStrings from stzObject

	@oQStrList	# Qt object holding the content of the list

	  #-----------#
	 #    INIT   #
	#-----------#

	// Initiates the object from a QStringList or a normal list of strings
	def init(pList)
			
		if IsQStringList(pList)
			@oQStrList = pList

		but StzListQ(pList).IsListOfStrings()
			@oQStrList = new QStringList()	
			for str in pList
				@oQStrList.append(str)	
			next

		other
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

		def ListOfStringItems()	
			return This.Content()

		def ListOfStrings()	
			return This.Content()


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

	def StringItem(n)
		if isString(n)
			if n = :First or n = :FirstString or n = :FirstStringItem
				n = 1

			but n = :Last or n = :LastString or n = :LastStringItem
				n = This.NumberOfStringItems()
			ok

		ok

		if isNumber(n)
			return This.QStringListObject().value(n-1)

		ok

		def StringItemQ(n)
			return new stzString( This.StringItem(n) )

		def String(n)
			return new stzString( This.StringItem(n) )

			def StringQ(n)
				return new stzString( This.String(n) )

		def NthStringItem(n)
			return This.StringItem(n)

			def NthStringItemQ(n)
				return new stzString( This.NthStringItem(n) )

		def NthString(n)
			return new stzString( This.StringItem(n) )

			def NthStringQ(n)
				return new stzString( This.NthString(n) )

		def StringItemAtPosition(n)
			return new stzString( This.StringItem(n) )

			def StringItemAtPositionQ(n)
				return new stzString( This.StringItemAtPosition(n) )

		def StringAtPosition(n)
			return new stzString( This.StringItem(n) )

			def StringAtPositionQ(n)
				return new stzString( This.StringAtPosition(n) )

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
			return new stzString( This.FirstLastItem() )

		def LastString()
			return This.LastStringItem()

			def LastStringQ()
				return new stzString( This.LastString() )

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			This.ReplaceStringAtPosition(i, :With = str + pcSubStr)
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
			This.ReplaceStringAtPosition(i, :With = pcSubStr + str)
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
		

	  #----------------#
	 #    INSERTING   #
	#----------------#

	def Insert(n, pcStr)
		This.InsertBefore(n, pcStr)

	def InsertBefore(n, pcStr)
		if isString(pcStr)
			This.QStringListObject().insert(n-1, pcStr)
		else
			stzRaise( stzListOfStringsError(:CanNotInsertNonStringItem) )
		ok

	def InsertBeforeQ(n, pcStr)
		This.InsertBefore(n, pcStr)
		return This
	
	def InsertAfter(n, pcStr)
		if n < This.NumberOfStrings()
			This.InsertBefore(n+1, pcStr)
		ok

	def InsertAfterQ(n, pcStr)
		This.InsertAfter(n, pcStr)
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
		   ( StzListQ(pNewListOfStr).IsWithParamList() or StzListQ(pNewListOfStr).IsUsingParamList() )

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

	  #-----------------#
	 #     SWAPPING    #
	#-----------------#

	def Swap(n1, n2)
		This.QStringListObject().swap(n1-1,n2-1)

		def SwapQ(n1, n2)
			This.Swap(n1, n2)
			return This
	
	  #----------------#
	 #     MOVING     #
	#----------------#

	def Move(n1, n2)
		This.QStringListObject().move(n1-1,n2-1)

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

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
			acResult + This.StringQ(i).CharsSortingOrder()
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
			if This.StringQ(i).CharsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereCharsAreSortedInDescending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringQ(i).CharsAreSortedInDescending()
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
			aResult + This.StringQ(i).CharsSortedInAscending()
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
			aResult + This.StringQ(i).CharsSortedInAscending()
		next

		return aResult

	def SortCharsOfEachStringInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringQ(i).CharsSortedInDescending()
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
			aResult + This.StringQ(i).CharsSortedInDescending()
		next

		return aResult

	  #----------------------------------------------------#
	 #     SORTING THE WORDS OF EACH STRING IN THE LIST   #
	#----------------------------------------------------#

	def WordsSortingOrders()
		acResult = []

		for i = 1 to This.NumberOfStrings()
			acResult + This.StringQ(i).WordsSortingOrder()
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
			if This.StringQ(i).WordsAreSortedInAscending()
				nResult ++
			ok
		next

		return nResult

	def NumberOfStringsWhereWordsAreSortedInDescending()
		nResult = 0

		for i = 1 to This.NumberOfStrings()
			if This.StringQ(i).WordsAreSortedInDescending()
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
			aResult + This.StringQ(i).StringWithWordsSortedInAscending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInAscendingQ()
			This.SortWordsOfEachStringInAscending()
			return This

	def WordsOfEachStringSortedInAscending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringQ(i).StringWithWordsSortedInAscending()
		next

		return aResult

	def SortWordsOfEachStringInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringQ(i).StringWithWordsSortedInDescending()
		next

		This.Update( aResult )

		def SortWordsOfEachStringInDescendingQ()
			This.SortWordsOfEachStringInDescending()
			return This

	def WordsOfEachStringSortedInDescending()
		aResult = []

		for i = 1 to This.NumberOfStrings()
			aResult + This.StringQ(i).StringWithWordsSortedInDescending()
		next

#---------------------------------------------------------------------------------------------
	  #=================================================#
	 #     FINDING A STRING IN THE LIST OF STRINGS     #
	#=================================================#

	/* TODO
		Add these functions in stzListOfStrings and stzString

		FindPositions()
		FindStartPositions()
		FindEndPositions()

		PositionsOf()
		StartPositionsOf()
		EndPositionsOf()

		FindSections()
		SectionsOf()
	
	*/

	def FindStringItemCS(pcStrItem, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	def FindStringItem(pcStrItem)
		return This.FindStringItemCS(pcStrItem, :CaseSensitive = FALSE)

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

	   #-----------------------------------------------#
	  #  FINDING ALL OCCURRENCE OF A STRING-ITEM IN   #
	 #  THE LIST EXCEPT FIRST OR LAST OCCURRENCE     #
	#-----------------------------------------------#
	/*
	NOTE: These functions were made to be used in RemoveDuplicates()
	*/

	def FindAllExceptFirstCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(2, :Last)

		def FindAllExceptFirstCSQ(pcStr, pCaseSensitive)
			return new stzList( This.FindAllExceptFirstCS(pcStr, pCaseSensitive) )
	
	def FindAllExceptLastCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(1, This.NumberOfStrings()-1 )

		def FindAllExceptLastCSQ(pcStr, pCaseSensitive)
			return new stzList( This.FindAllExceptLastCS(pcStr, pCaseSensitive) )
	
	def FindAllExceptNthCS(pcStr, n, pCaseSensitive)
		aResult = []

		if n = :First or n = :FirstString or n = :FirstStringItem
			n = 1

		but n = :Last or n = :LastString or n = :LastStringItem
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

		def FindAllExceptNthCSQ(pcStr, n, pCaseSensitive)
			return new stzList( This.FindAllExceptNhCS(pcStr, n, pCaseSensitive) )
	
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

	#-- CASE-INSENSITIVE

	def NumberOfOccurrenceOfStringItem(pcStrItem)
		return This.NumberOfOccurrenceOfStringItemCS(pcStrItem, :CaseSensitive = FALSE)

		def NumberOfOccurrenceOfString(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

		def NumberOfOccurrence(pcStrItem)
			return This.NumberOfOccurrenceOfStringItem(pcStrItem)

	   #--------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF MANY STRINGS    #
	 #    IN THE LIST OF STRINGS                  #
	#--------------------------------------------#

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	   #--------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS A GIVEN      #
	 #      STRING (AS AN ENTIRE ITEM OF THE LIST)            #
	#--------------------------------------------------------#

	def ContainsStringItemCS(pcStrItem, pCaseSensitive)
		if This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive) > 0
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
			if n = :First or n = :FirstString or n = :FirstStringItem
				n = 1

			but n = :Last or n = :LastString or n = :LastStringItem
				n = This.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
			ok
		ok

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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

	#-- CASE-INSENSITIVE

	def FindNthOccurrenceOfStringItem(n, pcStrItem)
		
		return This.FindNthOccurrenceOfStringItemCS(n, pStrItem, pCaseSensitive)

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

	#-- CASE-INSENSITIVE

	def FindFirstOccurrenceOfStringItem(pcStrItem)
		
		return This.FindFirstOccurrenceOfStringItemCS(pStrItem, pCaseSensitive)

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

	#-- CASE-INSENSITIVE

	def FindLastOccurrenceOfStringItem(pcStrItem)
		
		return This.FindLastOccurrenceOfStringItemCS(pStrItem, pCaseSensitive)

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

	#-- CASE-INSENSITIVE

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

		#--

		def ContainsEachStringItemCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		#--

		def ContainsEachStringItemOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachStringOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		def ContainsEachOfTheseCS(pacStrItems, pCaseSensitive)
			return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		#>

	#-- CASE-INSENSITIVE

	def ContainsStringItems(pacStrItems)

		return This.ContainsStringItemsCS(pacStrItems, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsStrings(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		#--

		def ContainsEachStringItem(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachString(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEach(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		#--

		def ContainsEachStringItemOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachStringOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		def ContainsEachOfThese(pacStrItems)
			return This.ContainsStringItems(pacStrItems)

		#>

	  #--------------------------------------------------------------#
	 #    FINDING STRINGS (AS ITEMS) VERIYING A GIVEN CONDITION     #
	#--------------------------------------------------------------#

	def FindStringItemsWCS(pcCondition, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		acResult = []

		if pCaseSensitive = TRUE

			acResult = This.ToStzList().FindW(pcCondition)

		else
			acList = This.Lowercased()
			cStr = StzStringQ(pcStr).Lowercased()

			acResult = StzListQ(acList).FindW(cStr)
		ok

		return acResult
	
		#< @FunctionAlternativeForms

		def FindStringsWCS(pcCondition, pCaseSensitive)
			return This.FindStringItemsWCS(pcCondition, pCaseSensitive)
	
		def FindWCS(pcCondition, pCaseSensitive)
			return This.FindStringItemsWCS(pcCondition, pCaseSensitive)

		def FindAllWCS(pcCondition, pCaseSensitive)
			return This.FindStringItemsWCS(pcCondition, pCaseSensitive)(pcCondition, pCaseSensitive)

		def FindWhereCS(pcCondition, pCaseSensitive)
			return This.FindStringItemsWCS(pcCondition, pCaseSensitive)(pcCondition, pCaseSensitive)

		def FindAllWhereCS(pcCondition, pValue, pCaseSensitive)
			return This.FindStringItemsWCS(pcCondition, pCaseSensitive)(pcCondition, pCaseSensitive)

		#>

	#-- CASE-INSENSITIVE

	def FindStringItemsW(pcCondition)
		return This.FindStringItemsWCS(pcCondition, :CaseSensitive = TRUE)
	
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

	def FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfStrings)
		nResult = oListOfStr.FindNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNextNthOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthNextOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthNextOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNextNthCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNextNthOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindNextNthStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindNextNthStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindNextNthOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindNextNthOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthNextOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfNextNthStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

			def PositionsOfNthNextStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextNthStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

			def PositionsOfNthNextStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextNthCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
		
		def PositionsOfNextNthOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindNextNthOccurrenceOfStringItem(n, pcStrItem, pStartingAt)

		return This.FindNextNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextNthOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthNextOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthNextOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNextNth(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNext(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNextNthOccurrence(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNextOccurrence(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindNextNthStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNextStringItem(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindNextNthString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNextString(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindNextNthOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNextOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindNextNthOccurrenceOfThisString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthNextOccurrenceOfThisString(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfNextNthStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthNextStringItem(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextNthString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthNextString(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextNth(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNext(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfNextNthOccurrence(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNextOccurrence(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfNextNthOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNextOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfNextNthOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNextOccurrenceOfString(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
		
		def PositionsOfNextNthOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNextOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfNextNthOccurrenceOfThisString(n, pcStrItem, pStartingAt)
			return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthNextOccurrenceOfThisString(n, pcStrItem, pStartingAt)
				return This.FindNextNthOccurrenceOfStringItem(n, pcStrItem)
		
		#>

	   #------------------------------------------------------------#
	  #    FINDING NEXT OCCURRENCE OF A STRING (AS AN ITEM)        #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindNextOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfStrings)
		nResult = oListOfStr.FindOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNextOccurrenceOfStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindNextCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindNextOccurrenceCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindNextStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindNextStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindNextOccurrenceOfThisStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindNextOccurrenceOfThisStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextOccurrenceCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfNextOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfNextOccurrenceOfStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		
		def PositionsOfNextOccurrenceOfThisStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfNextOccurrenceOfThisStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindNextOccurrenceOfStringItem(pcStrItem, pStartingAt)

		return This.FindNextOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextOccurrenceOfString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)

		def FindNext(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)

		def FindNextOccurrence(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)

		def FindNextStringItem(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def FindNextString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def FindNextOccurrenceOfThisStringItem(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def FindNextOccurrenceOfThisString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextStringItem(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNext(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextOccurrence(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfNextOccurrenceOfStringItem(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)

		def PositionsOfNextOccurrenceOfString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
		
		def PositionsOfNextOccurrenceOfThisStringItem(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)

		def PositionsOfNextOccurrenceOfThisString(pcStrItem, pStartingAt)
			return This.FindNextOccurrenceOfStringItem(pcStrItem)
		
		#>

	   #----------------------------------------------------------------#
	  #    FINDING PREVIOUS NTH OCCURRENCE OF A STRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                    #
	#----------------------------------------------------------------#

	def FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfStrings)
		nNumOcc = oListOfStr.NumberOfOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		nResult = oListOfStr.FindNthOccurrenceOfStringItemCS(nNumOcc - n, pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthPreviousOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindNthPreviousOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindPreviousNthCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def FindPreviousNthOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindPreviousNthStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindPreviousNthStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindPreviousNthOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def FindPreviousNthOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousNthStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousNthStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousNthCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousNthOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

		def PositionsOfPreviousNthOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisStringCS(n, pcStrItem, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindPreviousNthOccurrenceOfStringItem(n, pcStrItem, pStartingAt)

		return This.FindPreviousNthOccurrenceOfStringItemCS(n, pcStrItem, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthPreviousOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindNthPreviousOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindPreviousNth(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPrevious(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def FindPreviousNthOccurrence(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrence(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousStringItem(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousString(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def FindPreviousNthOccurrenceOfThisString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def FindNthPreviousOccurrenceOfThisString(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthPreviousStringItem(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousNthString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)

			def PositionsOfNthPreviousString(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousNth(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPrevious(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthOccurrence(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrence(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
	
		def PositionsOfPreviousNthOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfStringItem(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfPreviousNthOccurrenceOfString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfString(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
		
		def PositionsOfPreviousNthOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfThisStringItem(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

		def PositionsOfPreviousNthOccurrenceOfThisString(n, pcStrItem, pStartingAt)
			return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)

			def PositionsOfNthPreviousOccurrenceOfThisString(n, pcStrItem, pStartingAt)
				return This.FindPreviousNthOccurrenceOfStringItem(n, pcStrItem)
		
		#>

	   #------------------------------------------------------------#
	  #    FINDING PREVIOUS OCCURRENCE OF A STRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindPreviousOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfStrings)
		nResult = oListOfStr.FindOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindPreviousOccurrenceOfStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindPreviousCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def FindPreviousOccurrenceCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindPreviousStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindPreviousStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindPreviousOccurrenceOfThisStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def FindPreviousOccurrenceOfThisStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		
		def PositionsOfPreviousOccurrenceOfThisStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)

		def PositionsOfPreviousOccurrenceOfThisStringCS(pcStrItem, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindPreviousOccurrenceOfStringItem(pcStrItem, pStartingAt)

		return This.FindPreviousOccurrenceOfStringItemCS(pcStrItem, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindPreviousOccurrenceOfString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)

		def FindPrevious(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)

		def FindPreviousOccurrence(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)

		def FindPreviousStringItem(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def FindPreviousString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def FindPreviousOccurrenceOfThisStringItem(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def FindPreviousOccurrenceOfThisString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousStringItem(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPrevious(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousOccurrence(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
	
		def PositionsOfPreviousOccurrenceOfStringItem(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)

		def PositionsOfPreviousOccurrenceOfString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
		
		def PositionsOfPreviousOccurrenceOfThisStringItem(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)

		def PositionsOfPreviousOccurrenceOfThisString(pcStrItem, pStartingAt)
			return This.FindPreviousOccurrenceOfStringItem(pcStrItem)
		
		#>

	  #====================================================#
	 #     FINDING A SUBSTRING IN THE LIST OF STRINGS     #
	#====================================================#

	def FindSubStringCS(pcSubStr, pCaseSensitive)
		/* Example

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

	def FindSubString(pcSubStr)
		return This.FindSubStringCS(pcSubStr, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def PositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def AllPositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		#>

	   #-----------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF A SUBSTRING (OR MANY)    #
	 #    INSIDE EACH STRING OF THE LIST OF STRINGS        #
	#-----------------------------------------------------#

	def NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return len( This.FindSubStringCS(pcSubStr, pCaseSensitive) )

	def NumberOfOccurrenceOfSubString(pcStr)
		return This.NumberOfOccurrenceOfSubStringCS(pcStr, :CaseSensitive = FALSE)

	#--

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

	def NumberOfOccurrencesOfManySubstrings(pacSubStr)
		return This.NumberOfOccurrenceOfManySubstringsCS(pacSubStr, :CaseSensitive = TRUE)

	#--

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

	def NumberOfOccurrencesOfManySubstringsXT(pacSubStr)
		return This.NumberOfOccurrenceOfManySubstringsCSXT(pacSubStr, :CaseSensitive = TRUE)


	  #------------------------------------------------------------------#
	 #  CHECKING IF THE LIST CONTAIN A GIVEN SUSBTRING IN ITS STRINGS   #
	#------------------------------------------------------------------#

	def ContainsSubstringCS(pcSubStr, pCaseSensitive)
		if This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------------#
	 #  CHECKING IF EACH STRING-ITEM CONTAINS NTIMES A GIVEN SUSBTRING   #
	#-------------------------------------------------------------------#

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

	#-- CASE-INSENSITIVE

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
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

		def StringsContainingSubStringCS(pcSubStr, pCaseSensitive)
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def StringsContainingSubStringCSQ(pcSubStr, pCaseSensitive)
				return This.StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

			def StringsContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			     (  Q(pcSubStr).IsUsingParamList() or
				Q(pcSubStr).IsWithParamList() or
				Q(pcSubStr).IsOnParamList() or
				Q(pcSubStr).IsByParamList() )
	
				pcSubStr = pcSubstr[2]
			ok
			return This.StringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)

			def FilterStringItemsCSQ(pcSubStr, pCaseSensitive)
				return This.FilterStringItemsCSQR(pcSubStr, pCaseSensitive, :stzList)

			def FilterStringItemsCSQR(pcSubStr, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	  #-----------------------------------------------------#
	 #     UNIQUE STRINGS CONTAINING A GIVEN SUBSTRING     #
	#-----------------------------------------------------#

	def UniqueStringItemsContainingSubStringCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok
			 
		if isNumber(pCaseSensitive) and ( pCaseSensitive = 0 or pCaseSensitive = 1 )

			oQList = This.QStringListObject().filter(pcSubStr, pCaseSensitive)
			aResult = QStringListContent(oQList)
			aResult = StzListQ( aResult ).DuplicatesRemoved()

		else
			stzRaise("Incorrect param! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

		#< @FunctionfluentForm

		def UniqueStringItemssContainingSubStringCSQ(pcSubStr, pCaseSensitive)
			return This.UniqueStringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, :stzList)

		def UniqueStringItemssContainingSubStringCSQR(pcSubStr, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	#-- CASE-INSENSITIVE

	def StringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

			def StringsContainingNTimesTheSubstringQ(n, pcSubstr, pCaseSensitive)
				return This.StringsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)
	
			def StringsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	#-- CASE-INSENSITIVE

	def UniqueStringItemsContainingNTimesTheSubstring(n, pcSubstr)
		return This.UniqueStringItemsContainingNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def UniqueStringItemsContainingNTimesTheSubstringQ(n, pcSubstr)
			return This.UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, :stzList)

		def UniqueStringItemsContainingNTimesTheSubstringQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

  	   #---------------------------------------------------------------#
	  #     STRINGS CONTAINING N TIMES A GIVEN SUBSTRING ALONG WITH   #
	 #    THE POSITIONS OF THE SUBSTRING IN EACH STRING              #
	#---------------------------------------------------------------#

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	#-- CASE-INSENSITIVE

	def StringItemsContainingNTimesTheSubstringXT(n, pcSubstr)
		return This.StringItemsContainingNTimesTheSubstringCSXT(n, pcSubstr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def StringItemsContainingNTimesTheSubstringXTQ(n, pcSubstr)
			return This.StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, :stzList)

		def StringItemsContainingNTimesTheSubstringXTQR(n, pcSubstr, pcReturn)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

		if isString(n)
			if n = :First or n = :FirstString or n = :FirstStringItem
				n = 1

			but n = :Last or n = :LastString or n = :LastStringItem
				n = This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT (isNumber(n) and n <= This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive))
			stzRaise("Incorrect param! n must be a number <= number of occurrences of the substring in all the strings.")
		ok

		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		// The position to search for inside aPositionsXT

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

	def FindNthOccurrenceOfSubString(n, pcSubStr)
		return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindNthSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def FindNthOccurrenceOfThisSubString(n, pcSubStr)
			rreturn This.FindNthOccurrenceOfSubString(n, pcSubStr)
	#--

	def FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(1, pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindFirstOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	def FindFirstOccurrenceOfSubString(pcSubStr)
		return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def FindFirstOccurrenceOfThisSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

	#--
	
	def FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(:Last, pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindLastOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	def FindLastOccurrenceOfSubString(pcSubStr)
		return This.FindLastOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def FindLastOccurrenceOfThisSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

	#----

	def PositionsOfSubstringAsFlatListCS(pcSubStr, pCaseSensitive)
		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		aResult = []

		for aPair in aPositionsXT
			anPos = aPair[2]

			for n in anPos	
				aResult + n
			next
		next

		return aResult

	def PositionsOfSubstringAsFlatList(pcSubStr)
		return This.PositionsOfSubstringAsFlatListCS(pcSubStr, :CaseSensitive = TRUe)

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

	def FindSubStrings(pacStr)
		return This.FindSubStringsCS(pacStr, :CaseSensitive = TRUE)

		def FindManySubStrings(pacStr)
			return This.FindSubStrings(pacStr)

		def FindTheseSubStrings(pacStr)
			return This.FindSubStrings(pacStr)

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

	  #------------------------------------------------------#
	 #    FINDING SUBSTRINGS VERIYING A GIVEN CONDITION     #
	#------------------------------------------------------#

	def FindSubStringsWCS(pcCondition, pCaseSensitive)
		/* Exemple

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

		o1.FindSubStringsWCS('@substr = many' , :CaseSensitive = FALSE)
		# --> [
		#	"1" = [ 5 ],
		#	"3" = [ 5 ],
		#	"5" = [ 9 ]
		#     ]

		 */

		// TODO

		return aResult
	
		#< @FunctionAlternativeForms

		def FindSubStringsCSW(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindAllSubStringsWCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

			def FindAllSubStringsCSW(pcCondition, pCaseSensitive)
				return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindSubStringsWhereWCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

			def FindSubStringsWhereCSW(pcCondition, pCaseSensitive)
				return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindAllSubStringsWhereCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		#>

	def FindSubStringsW(pcCondition)
		return This.FindSubStringsWCS(pcCondition, :CaseSensitive = FALSE)
	
		#< @FunctionAlternativeForms

		def FindAllSubStringsW(pcCondition)
			return This.FindSubStringsW(pcCondition)

		def FindSubStringsWhere(pcCondition)
			return This.FindSubStringsW(pcCondition)

		def FindAllSubStringsWhere(pcCondition)
			return This.FindSubStringsW(pcCondition)

		#>

	   #---------------------------------------------------#
	  #    FINDING NEXT NTH OCCURRENCE OF A SUBSTRING     #
	 #    STARTING AT A GIVEN POSITION [ LEVEL, POS]     #
	#---------------------------------------------------#

	def FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfSubStrings)
		aResult = oListOfStr.FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNthNextOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def FindNextNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthNextSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def FindNextNthOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthNextOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def PositionsOfNextNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def PositionsOfNthNextSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
	
		def PositionsOfNextNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		def PositionsOfNextNthOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthNextOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		#>

	#-- CASE-INSENSITIVE

	def FindNextNthOccurrenceOfSubString(n, pcSubStr, pStartingAt)

		return This.FindNextNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthNextOccurrenceOfSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

		def FindNextNthSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthNextSubString(n, pcSubStr, pStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		def FindNextNthOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthNextOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
		
		def PositionsOfNextNthSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(pcSubStr)

			def PositionsOfNthNextSubString(n, pcSubStr, pStartingAt)
				return This.FindNextNthOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextNthOccurrenceOfSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfSubString(n, pcSubStr, pStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		def PositionsOfNextNthOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
			return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthNextOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
				return This.FindNextNthOccurrenceOfSubString(n, pcSubStr)
	
		#>

	   #------------------------------------------------------------#
	  #    FINDING NEXT OCCURRENCE OF A SUBSTRING (AS AN ITEM)     #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                #
	#------------------------------------------------------------#

	def FindNextOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfSubStrings)
		aResult = oListOfStr.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms
	
		def FindNextSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def FindNextOccurrenceOfThisSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfNextSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfNextOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfNextOccurrenceOfThisSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindNextOccurrenceOfSubString(pcSubStr, pStartingAt)

		return This.FindNextOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextSubString(pcSubStr, pStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def FindNextOccurrenceOfThisSubString(pcSubStr, pStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextSubString(pcSubStr, pStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextOccurrenceOfSubString(pcSubStr, pStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfNextOccurrenceOfThisSubString(pcSubStr, pStartingAt)
			return This.FindNextOccurrenceOfSubString(pcSubStr)
		
		#>

	   #-------------------------------------------------------------------#
	  #    FINDING PREVIOUS NTH OCCURRENCE OF A SUBSTRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                       #
	#-------------------------------------------------------------------#

	def FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfSubStrings)
		nNumOcc = oListOfStr.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		aResult = oListOfStr.FindNthOccurrenceOfSubStringCS(nNumOcc - n, pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms

		def FindNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		def FindPreviousNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthPreviousSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def FindPreviousNthOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def FindNthPreviousOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
	
		def PositionsOfPreviousNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
			
		def PositionsOfPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousNthOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

			def PositionsOfNthPreviousOccurrenceOfThisSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
				return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindPreviousNthOccurrenceOfSubString(n, pcSubStr, pStartingAt)

		return This.FindPreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthPreviousOccurrenceOfSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

		def FindPreviousNthSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthPreviousSubString(n, pcSubStr, pStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
	
		def FindPreviousNthOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def FindNthPreviousOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
	
		def PositionsOfPreviousNthSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(pcSubStr)

			def PositionsOfNthPreviousSubString(n, pcSubStr, pStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(pcSubStr)
	
		def PositionsOfPreviousNthOccurrenceOfSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthPreviousOccurrenceOfSubString(n, pcSubStr, pStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)
		
		def PositionsOfPreviousNthOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
			return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

			def PositionsOfNthPreviousOccurrenceOfThisSubString(n, pcSubStr, pStartingAt)
				return This.FindPreviousNthOccurrenceOfSubString(n, pcSubStr)

		#>

	   #---------------------------------------------------------------#
	  #    FINDING PREVIOUS OCCURRENCE OF A SUBSTRING (AS AN ITEM)    #
	 #    STARTING AT A GIVEN POSITION IN THE LIST                   #
	#---------------------------------------------------------------#

	def FindPreviousOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)

		oListOfStr = This.ToStzList().SectionQR(pStartingAt, :LastItem, :stzListOfSubStrings)
		aResult = oListOfStr.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		return nResult

		#< @FunctionAlternativeForms
	
		def FindPreviousSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def FindPreviousOccurrenceOfThisSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
	
		def PositionsOfPreviousOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		def PositionsOfPreviousOccurrenceOfThisSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		
		#>

	#-- CASE-INSENSITIVE

	def FindPreviousOccurrenceOfSubString(pcSubStr, pStartingAt)

		return This.FindPreviousOccurrenceOfSubStringCS(pcSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindPreviousSubString(pcSubStr, pStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)
		
		def FindPreviousOccurrenceOfThisSubString(pcSubStr, pStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)
		
		def PositionsOfPreviousSubString(pcSubStr, pStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfSubString(pcSubStr, pStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		def PositionsOfPreviousOccurrenceOfThisSubString(pcSubStr, pStartingAt)
			return This.FindPreviousOccurrenceOfSubString(pcSubStr)

		#>

	  #==================================================#
	 #     REPLACING STRINGS IN THE LIST OF STRINGS     #
	#==================================================#

	def ReplaceStringItemCS(pcStr, pcNewStr, pCaseSensitive)
		anPos = This.FindStringItemCS(pcStr, pCaseSensitive)
		This.ReplaceStringItemsAtThesePositions(anPos, :With = pcNewStr)

		def ReplaceStringItemCSQ(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemCS(pcStr, pCaseSensitive)
			return This

		def ReplaceStringCS(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemCS(pcStr, pcNewStr, pCaseSensitive)

		def ReplaceCS(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceCSQ(pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceCS(pcStr, pCaseSensitive)
				return This

		def ReplaceAllCS(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceAllCSQ(pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceAllCS(pcStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesOfStringCS(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceAllOccurrencesOfStringCSQ(pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceAllOccurrencesOfStringCS(pcStr, pcNewStr, pCaseSensitive)
				return This

	#--- CASE-INSENSITIVE

	def ReplaceStringItem(pcStr, pcNewStr)
		This.ReplaceStringItemCS(pcStr, pcNewStr, :CaseSensitive = TRUE)

		def ReplaceStringItemQ(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItem(pcStr, pCaseSensitive)
			return This

		def ReplaceString(pcStr, pcNewStr)
			This.ReplaceStringItem(pcStr, pcNewStr)

		def Replace(pcStr, pcNewStr)
			This.ReplaceStringItem(pcStr, pcNewStr)

			def ReplaceQ(pcStr, pcNewStr)
				This.ReplaceCS(pcStr)
				return This

		def ReplaceAll(pcStr, pcNewStr)
			This.ReplaceStringItem(pcStr, pcNewStr)

			def ReplaceAllQ(pcStr, pcNewStr)
				This.ReplaceAll(pcStr, pcNewStr)
				return This

		def ReplaceAllOccurrencesOfString(pcStr, pcNewStr)
			This.ReplaceStringItem(pcStr, pcNewStr)

			def ReplaceAllOccurrencesOfStringQ(pcStr, pcNewStr)
				This.ReplaceAllOccurrencesOfString(pcStr, pcNewStr)
				return This

	  #-------------------------------------------#
	 #   REPLACING STRING AT A GIVEN POSITION    #
	#-------------------------------------------#

	def ReplaceStringItemAtPosition(n, pcNewStr)
		This.QStringListObject().Replace(n-1, pcNewStr)

		def ReplaceStringItemAtPositionQ(n, pcNewStr)
			This.ReplaceStringItemAtPosition(n, pcNewStr)
			return This

		def ReplaceStringItemAtThisPosition(n, pcNewStr)
			This.ReplaceStringItemAtPosition(n, pcNewStr)

			def ReplaceStringItemAtThisPositionQ(n, pcNewStr)
				This.ReplaceStringItemAtThisPosition(n, pcNewStr)
				return This

		def ReplaceStringAtPosition(n, pcNewStr)
			This.ReplaceStringItemAtPosition(n, pcNewStr)

			def ReplaceStringAtPositionQ(n, pcNewStr)
				This.ReplaceStringAtPosition(n, pcNewStr)
				return This

		def ReplaceStringAtThisPosition(n, pcNewStr)
			This.ReplaceStringItemAtPosition(n, pcNewStr)

			def ReplaceStringAtThisPositionQ(n, pcNewStr)
				This.ReplaceStringAtThisPosition(n, pcNewStr)
				return This

		def ReplaceNth(n, pcNewStr)
			This.ReplaceStringItemAtPosition(n, pcNewStr)

			def ReplaceNthQ(n, pcNewStr)
				This.ReplaceNth(n, pcNewStr)
				return This

	  #------------------------------------------#
	 #   REPLACING STRINGS AT GIVEN POSITIONS   #
	#------------------------------------------#

	def ReplaceStringItemsAtPositions(panPositions, pcNewStr)
		anPos = sort(panPositions)

		for i = len(anPos) to 1 step -1
			This.ReplaceStringItemAtPosition(anPos[i], pcNewStr)
		next

		def ReplaceStringItemsAtPositionsQ(panPositions, pcNewStr)
			This.ReplaceStringItemsAtPositions(panPositions, pcNewStr)
			return This

		def ReplaceStringItemsAtThesePositions(panPositions, pcNewStr)
			This.ReplaceStringItemsAtPositions(panPositions, pcNewStr)

			def ReplaceStringItemssAtThesePositionsQ(panPositions, pcNewStr)
				This.ReplaceStringsAtThesePositions(panPositions, pcNewStr)
				return This

		def ReplaceStringAtPositions(panPositions, pcNewStr)
			This.ReplaceStringItemsAtPositions(panPositions, pcNewStr)

			def ReplaceStringAtPositionsQ(panPositions, pcNewStr)
				This.ReplaceStringAtPositions(panPositions, pcNewStr)
				return This

		def ReplaceStringAtThesePositions(panPositions, pcNewStr)
			This.ReplaceStringItemsAtPositions(panPositions, pcNewStr)

			def ReplaceStringAtThesePositionsQ(panPositions, pcNewStr)
				This.ReplaceStringAtThesePositions(panPositions, pcNewStr)
				return This

	  #-----------------------------------------------------------------#
	 #    REPLACING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS  #
	#-----------------------------------------------------------------#
	
	def ReplaceNthStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)

		anPos = This.FindStringItemCS(pcStr, pCaseSensitive)
		nPos = anPos[n]

		This.ReplaceStringItemAtPosition(nPos, pcNewStr)

		#< @FunctionFluentForm

		def ReplaceNthStringItemCSQ(n, pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceNthStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceNthOccurrenceCS(n, pcStr, pcNewStr, pcNewStrpCaseSensitive)
			This.ReplaceNthStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)

			def ReplaceNthOccurrenceCSQ(n, pcStr, pcNewStr, pcNewStrpCaseSensitive)
				This.ReplaceNthOccurrenceCS(n, pcStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceNthOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pcNewStrpCaseSensitive)
			This.ReplaceNthStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)

			def ReplaceNthOccurrenceOfStringItemCSQ(n, pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceNthOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceNthOccurrenceOfThisStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceNthStringItemCS(n, pcStr, pcNewStr, pCaseSensitive)

			def ReplaceNthOccurrenceOfThisStringItemCSQ(n, pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceNthOccurrenceOfThisStringItemCS(n, pcStr, pCaseSensitive)
				return This
		#>

	#--- CASE-INSENSITIVE

	def ReplaceNthStringItem(n, pcStr, pcNewStr)

		This.ReplaceNthStringItemCS(n, pcStr, pcNewStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNthStringItemQ(n, pcStr, pcNewStr)
			This.ReplaceNthStringItem(n, pcStr, pcNewStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceNthOccurrence(n, pcStr, pcNewStr)
			This.ReplaceNthStringItem(n, pcStr, pcNewStr)

			def ReplaceNthOccurrenceQ(n, pcStr, pcNewStr)
				This.ReplaceNthOccurrence(n, pcStr, pcNewStr)
				return This

		def ReplaceNthOccurrenceOfStringItem(n, pcStr, pcNewStr)
			This.ReplaceNthStringItem(n, pcStr, pcNewStr)

			def ReplaceNthOccurrenceOfStringItemQ(n, pcStr, pcNewStr)
				This.ReplaceNthOccurrenceOfStringItem(n, pcStr, pcNewStr)
				return This

		def ReplaceNthOccurrenceOfThisStringItem(n, pcStr, pcNewStr)
			This.ReplaceNthStringItem(n, pcStr, pcNewStr)

			def ReplaceNthOccurrenceOfThisStringItemQ(n, pcStr, pcNewStr)
				This.ReplaceNthOccurrenceOfThisStringItem(n, pcStr)
				return This
		#>

	#----

	def ReplaceFirstStringItemCS(pcStr, pcNewStr, pCaseSensitive)

		This.ReplaceNthStringItemCS(1, pcStr, pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceFirstStringItemCSQ(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceFirstStringItemCS(pcStr, pcNewStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceFirstOccurrenceCS(pcStr, pcNewStr, pcNewStrpCaseSensitive)
			This.ReplaceFirstStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceFirstOccurrenceCSQ(pcStr, pcNewStr, pcNewStrpCaseSensitive)
				This.ReplaceFirstOccurrenceCS(pcStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceFirstOccurrenceOfStringItemCS(pcStr, pcNewStr, pcNewStrpCaseSensitive)
			This.ReplaceFirstStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceFirstOccurrenceOfStringItemCSQ(pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfStringItemCS(pcStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceFirstOccurrenceOfThisStringItemCS(pcStr, pcNewStr, pCaseSensitive)
			This.ReplaceFirstStringItemCS(pcStr, pcNewStr, pCaseSensitive)

			def ReplaceFirstOccurrenceOfThisStringItemCSQ(pcStr, pcNewStr, pCaseSensitive)
				This.ReplaceFirstOccurrenceOfThisStringItemCS(npcStr, pCaseSensitive)
				return This
		#>

	#--- CASE-INSENSITIVE

	def ReplaceFirstStringItem(pcStr, pcNewStr)

		This.ReplaceFirstStringItemCS(npcStr, pcNewStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceFirstStringItemQ(pcStr, pcNewStr)
			This.ReplaceFirstStringItem(pcStr, pcNewStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceFirstOccurrence(pcStr, pcNewStr)
			This.ReplaceFirstStringItem(pcStr, pcNewStr)

			def ReplaceFirstOccurrenceQ(pcStr, pcNewStr)
				This.ReplaceFirstOccurrence(pcStr, pcNewStr)
				return This

		def ReplaceFirstOccurrenceOfStringItem(pcStr, pcNewStr)
			This.ReplaceFirstStringItem(pcStr, pcNewStr)

			def ReplaceFirstOccurrenceOfStringItemQ(pcStr, pcNewStr)
				This.ReplaceFirstOccurrenceOfStringItem(pcStr, pcNewStr)
				return This

		def ReplaceFirstOccurrenceOfThisStringItem(pcStr, pcNewStr)
			This.ReplaceFirstStringItem(pcStr, pcNewStr)

			def ReplaceFirstOccurrenceOfThisStringItemQ(pcStr, pcNewStr)
				This.ReplaceFirstOccurrenceOfThisStringItem(pcStr)
				return This
		#>

	#----

	def ReplaceLastStringItem(pcStr, pcNewStr)

		This.ReplaceLastStringItemCS(n, pcStr, pcNewStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceLastStringItemQ(pcStr, pcNewStr)
			This.ReplaceLastStringItem(pcStr, pcNewStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceLastOccurrence(pcStr, pcNewStr)
			This.ReplaceLastStringItem(pcStr, pcNewStr)

			def ReplaceLastOccurrenceQ(pcStr, pcNewStr)
				This.ReplaceLastOccurrence(pcStr, pcNewStr)
				return This

		def ReplaceLastOccurrenceOfStringItem(pcStr, pcNewStr)
			This.ReplaceLastStringItem(pcStr, pcNewStr)

			def ReplaceLastOccurrenceOfStringItemQ(pcStr, pcNewStr)
				This.ReplaceLasttOccurrenceOfStringItem(pcStr, pcNewStr)
				return This

		def ReplaceLastOccurrenceOfThisStringItem(pcStr, pcNewStr)
			This.ReplaceLastStringItem(pcStr, pcNewStr)

			def ReplaceLastOccurrenceOfThisStringItemQ(pcStr, pcNewStr)
				This.ReplaceLastOccurrenceOfThisStringItem(pcStr)
				return This
		#>

	  #---------------------------------------------#
	 #   REPLACING MANY STRINGS AT THE SAME TIME   #
	#---------------------------------------------#

	def ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)
		if NOT IsListOfStrings(paStr)
			stzRaise("Incorrect param type! You must provide a list of strings.")
		ok

		for str in paStr
			This.ReplaceStringItemCS(str, pcNewStr, pCaseSensitive)
		next

		#< @FuntionFluentForm

		def ReplaceStringItemsCSQ(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceStringsCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceStringsCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceStringsCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceManyStringItemsCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceManyStringsCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceManyStringsCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceManyCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceManyCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceManyCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceTheseStringItemsCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceTheseStringItemsCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceTheseStringItemsCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceTheseStringsCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceTheseStringsCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceTheseStringItemsCS(paStr, pcNewStr, pCaseSensitive)
				return This

		def ReplaceTheseCS(paStr, pcNewStr, pCaseSensitive)
			This.ReplaceManyStringItemsCS(paStr, pcNewStr, pCaseSensitive)

			def ReplaceTheseCSQ(paStr, pcNewStr, pCaseSensitive)
				This.ReplaceTheseCS(paStr, pcNewStr, pCaseSensitive)
				return This

		#>

	#--

	def ReplaceStringItems(paStr, pcNewStr)
		This.ReplaceStringItemsCS(paStr, pcNewStr, pCaseSensitive)

		#< @FuntionFluentForm

		def ReplaceStringItemsQ(paStr, pcNewStr)
			This.ReplaceStringItems(paStr, pcNewStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceStrings(paStr, pcNewStr)
			This.ReplaceStringItems(paStr, pcNewStr)

			def ReplaceStringsQ(paStr, pcNewStr)
				This.ReplaceStrings(paStr, pcNewStr)
				return This

		def ReplaceManyStringItems(paStr, pcNewStr)
			This.ReplaceStringItems(paStr, pcNewStr)

			def ReplaceManyStringItemsQ(paStr, pcNewStr)
				This.ReplaceManyStringItems(paStr, pcNewStr)
				return This

		def ReplaceManyStrings(paStr, pcNewStr)
			This.ReplaceStringItems(paStr, pcNewStr)

			def ReplaceManyStringsQ(paStr, pcNewStr)
				This.ReplaceManyStringItems(paStr, pcNewStr)
				return This

		def ReplaceMany(paStr)
			This.ReplaceStringItems(paStr, pcNewStr, pCaseSensitive)

			def ReplaceManyQ(paStr)
				This.ReplaceMany(paStr)
				return This

		def ReplaceTheseStringItems(paStr, pcNewStr)
			This.ReplaceManyStringItems(paStr, pcNewStr)

			def ReplaceTheseStringItemsQ(paStr, pcNewStr)
				This.ReplaceTheseStringItems(paStr, pcNewStr)
				return This

		def ReplaceTheseStrings(paStr, pcNewStr)
			This.ReplaceManyStringItems(paStr, pcNewStr)

			def ReplaceTheseStringsQ(paStr, pcNewStr)
				This.ReplaceTheseStringItems(paStr, pcNewStr)
				return This

		def ReplaceThese(paStr, pcNewStr)
			This.ReplaceManyStringItems(paStr, pcNewStr)

			def ReplaceTheseQ(paStr, pcNewStr)
				This.ReplaceThese(paStr, pcNewStr)
				return This

		#>

	  #------------------------------------------------------#
	 #   REPLACING MANY STRINGS BY MANY OTHERS ONE BY ONE   #
	#------------------------------------------------------#

	def ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)
		if NOT IsListOfStrings(paStr)
			stzRaise("Incorrect param type! You must provide a list of strings.")
		ok

		i = 0
		for str in paStr
			i++
			if i <= len(pacNewStr)
				This.ReplaceStringItemCS(str, pacNewStr[i], pCaseSensitive)
			ok
		next

		#< @FuntionFluentForm

		def ReplaceStringItemsByManyCSQ(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceStringsByManyCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByManyCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByManyCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringItemsByOthersCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringItemsByOthersCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByOthersCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringsByOthersCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByOthersCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByOthersCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringItemsByManyOthersCS(paStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringItemsByManyOthersCSQ(paStr, pCaseSensitive)
				This.ReplaceStringsByManyOthersCS(paStr, pCaseSensitive)
				return This

		def ReplaceStringsByManyOthersCS(paStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByManyOthersCSQ(paStr, pCaseSensitive)
				This.ReplaceStringsByManyOthersCS(paStr, pCaseSensitive)
				return This

		def ReplaceStringItemsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringItemsByManyOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByManyOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringItemsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringItemsByOthersOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByOthersOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceStringsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceStringItemsByManyOthersOneByOneCS(paStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringItemsByManyOthersOneByOneCSQ(paStr, pCaseSensitive)
				This.ReplaceStringsByManyOthersOneByOneCS(paStr, pCaseSensitive)
				return This

		def ReplaceStringsByManyOthersOneByOneCS(paStr, pCaseSensitive)
			This.ReplaceStringItemsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceStringsByManyOthersOneByOneCSQ(paStr, pCaseSensitive)
				This.ReplaceStringsByManyOthersOneByOneCS(paStr, pCaseSensitive)
				return This
		#>

	#--- CASE-INSENSITIVE

	def ReplaceStringItemsByMany(paStr, pacNewStr)
		This.ReplaceStringItemsByManyCS(paStr, pacNewStr, :CaseSensitive = TRUE)

		#< @FuntionFluentForm

		def ReplaceStringItemsByManyQ(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceStringsByMany(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByManyQ(paStr, pacNewStr)
				This.ReplaceStringsByMany(paStr, pacNewStr)
				return This

		def ReplaceStringItemsByOthers(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringItemsByOthersQ(paStr, pacNewStr)
				This.ReplaceStringsByOthers(paStr, pacNewStr)
				return This

		def ReplaceStringsByOthers(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByOthersQ(paStr, pacNewStr)
				This.ReplaceStringsByOthers(paStr, pacNewStr)
				return This

		def ReplaceStringItemsByManyOthers(paStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringItemsByManyOthersQ(paStr)
				This.ReplaceStringsByManyOthers(paStr)
				return This

		def ReplaceStringsByManyOthers(paStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByManyOthersQ(paStr)
				This.ReplaceStringsByManyOthers(paStr)
				return This

		def ReplaceStringItemsByManyOneByOne(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringItemsByManyOneByOneQ(paStr, pacNewStr)
				This.ReplaceStringsByManyOneByOne(paStr, pacNewStr)
				return This

		def ReplaceStringsByManyOneByOne(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByManyOneByOneQ(paStr, pacNewStr)
				This.ReplaceStringsByManyOneByOne(paStr, pacNewStr)
				return This

		def ReplaceStringItemsByOthersOneByOne(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringItemsByOthersOneByOneQ(paStr, pacNewStr)
				This.ReplaceStringsByOthersOneByOne(paStr, pacNewStr)
				return This

		def ReplaceStringsByOthersOneByOne(paStr, pacNewStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByOthersOneByOneQ(paStr, pacNewStr)
				This.ReplaceStringsByOthersOneByOne(paStr, pacNewStr)
				return This

		def ReplaceStringItemsByManyOthersOneByOne(paStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringItemsByManyOthersOneByOneQ(paStr)
				This.ReplaceStringsByManyOthersOneByOne(paStr)
				return This

		def ReplaceStringsByManyOthersOneByOne(paStr)
			This.ReplaceStringItemsByMany(paStr, pacNewStr)

			def ReplaceStringsByManyOthersOneByOneQ(paStr)
				This.ReplaceStringsByManyOthersOneByOne(paStr)
				return This
		#>

	  #----------------------------------------------------------------------------------#
	 #  REPLACING NEXT NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#----------------------------------------------------------------------------------#

	def ReplaceNextNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.ReplaceStringItemAtThisPosition(n, pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextNthStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextNthStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextNthOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextNthOccurrenceOfStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextNthOccurrenceOfStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrenceOfStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrenceOfStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextNthOccurrenceCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextNthOccurrenceCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextOccurrenceCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrenceCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplaceNextNthStringItem(n, pcStr, pcNewStr, pStartingAt)
		This.ReplaceNextNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextNthStringItemQ(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthStringItem(n, pcStr, pcNewStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthStringItem(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNextNthStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextNthStringItem(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthNextStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthNextStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthNextString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthNextString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthNextStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthNextString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextNthOccurrenceOfStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNextNthOccurrenceOfStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNextNthOccurrenceOfStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthNextOccurrenceOfStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthNextOccurrenceOfStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthNextOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthNextOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthNextOccurrenceOfStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthNextOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextNthOccurrence(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNextNthOccurrenceQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthNextOccurrence(n, pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthNextOccurrenceQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthNextOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		#>

	  #---------------------------------------------------------------------------#
	 #   REPLACING NEXT OCCURRENCE OF STRING-ITEM STARTING AT A GIVEN POSITION   #
	#---------------------------------------------------------------------------#

	def ReplaceNextStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)
		This.ReplaceStringItemAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextStringItemCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNextStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextStringCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextOccurrenceOfStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextOccurrenceOfStringItemCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextOccurrenceOfStringCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextOccurrenceCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNextOccurrenceCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplaceNextStringItem(pcStr, pcNewStr, pStartingAt)
		This.ReplaceNextStringItemCS(pcStr, pcNewStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextStringItemQ(pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextStringItem(pcStr, pcNewStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNextString(pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextStringItem(pcStr, pcNewStr, pStartingAt)

			def ReplaceNextStringQ(pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextStringItem(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextOccurrenceOfStringItem(pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextString(pcStr, pcNewStr, pStartingAt)

			def ReplaceNextOccurrenceOfStringItemQ(pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextString(pcStr, pcNewStr, pStartingAt)

			def ReplaceNextOccurrenceOfStringQ(pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNextOccurrence(pcStr, pcNewStr, pStartingAt)
			This.ReplaceNextString(pcStr, pcNewStr, pStartingAt)

			def ReplaceNextOccurrenceQ(pcStr, pcNewStr, pStartingAt)
				This.ReplaceNextOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		#>

	  #----------------------------------------------------------------------------------#
	 #  REPLACING PREVIOUS NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#----------------------------------------------------------------------------------#

	def ReplacePreviousNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
		nPos = This.FindPreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.ReplaceStringItemAtThisPosition(n, pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplacePreviousNthStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousNthStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousNthOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousNthOccurrenceOfStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousNthOccurrenceOfStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousOccurrenceOfStringItemCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceOfStringItemCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceOfStringCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousNthOccurrenceCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousNthOccurrenceCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousNthOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousOccurrenceCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceCSQ(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceOfStringCS(n, pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplacePreviousNthStringItem(n, pcStr, pcNewStr, pStartingAt)
		This.ReplacePreviousNthStringItemCS(n, pcStr, pcNewStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousNthStringItemQ(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthStringItem(n, pcStr, pcNewStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthStringItem(n, pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousNthStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousNthStringItem(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthPreviousStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthPreviousStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthPreviousString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthPreviousString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthPreviousStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthPreviousString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousNthOccurrenceOfStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousNthOccurrenceOfStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousNthOccurrenceOfStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthPreviousOccurrenceOfStringItem(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthPreviousOccurrenceOfStringItemQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthPreviousOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthPreviousOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthPreviousOccurrenceOfStringQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthPreviousOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousNthOccurrence(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousNthOccurrenceQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousNthOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		def ReplaceNthPreviousOccurrence(n, pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousNthString(n, pcStr, pcNewStr, pStartingAt)

			def ReplaceNthPreviousOccurrenceQ(n, pcStr, pcNewStr, pStartingAt)
				This.ReplaceNthPreviousOccurrenceOfString(n, pcStr, pcNewStr, pStartingAt)
				return This

		#>

	  #---------------------------------------------------------------------------#
	 #   REPLACING PREVIOUS OCCURRENCE OF STRING-ITEM STARTING AT A GIVEN POSITION   #
	#---------------------------------------------------------------------------#

	def ReplacePreviousStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
		nPos = This.FindPreviousStringItemCS(pcStr, pStartingAt, pCaseSensitive)
		This.ReplaceStringItemAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplacePreviousStringItemCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousStringCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousOccurrenceOfStringItemCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousOccurrenceOfStringItemCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousOccurrenceOfStringCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousOccurrenceCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousOccurrenceCSQ(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousOccurrenceOfStringCS(pcStr, pcNewStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplacePreviousStringItem(pcStr, pcNewStr, pStartingAt)
		This.ReplacePreviousStringItemCS(pcStr, pcNewStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousStringItemQ(pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousStringItem(pcStr, pcNewStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousString(pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousStringItem(pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousStringQ(pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousStringItem(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousOccurrenceOfStringItem(pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousString(pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousOccurrenceOfStringItemQ(pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousString(pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousOccurrenceOfStringQ(pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		def ReplacePreviousOccurrence(pcStr, pcNewStr, pStartingAt)
			This.ReplacePreviousString(pcStr, pcNewStr, pStartingAt)

			def ReplacePreviousOccurrenceQ(pcStr, pcNewStr, pStartingAt)
				This.ReplacePreviousOccurrenceOfString(pcStr, pcNewStr, pStartingAt)
				return This

		#>

	  #----------------------------------------------------------------#
	 #    REPLACING STRINGS (AS ITEMS) VERIYING A GIVEN CONDITION     #
	#----------------------------------------------------------------#

	def ReplaceStringItemsWCS(pcCondition, pcNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		anPositions = This.FindStringItemsWCS(pcCondition, pCaseSensitive)
		This.ReplaceStringItemsAtThesePositions(anPositions, :With = pcNewStr)
	
		#< @FunctionAlternativeForms

		def ReplaceStringsWCS(pcCondition, pcNewStr, pCaseSensitive)
			return This.ReplaceStringItemsWCS(pcCondition, pcNewStr, pCaseSensitive)
	
		def ReplaceWCS(pcCondition, pcNewStr, pCaseSensitive)
			return This.ReplaceStringItemsWCS(pcCondition, pcNewStr, pCaseSensitive)

		def ReplaceAllWCS(pcCondition, pcNewStr, pCaseSensitive)
			return This.ReplaceStringItemsWCS(pcCondition, pcNewStr, pCaseSensitive)(pcCondition, pCaseSensitive)

		def ReplaceWhereCS(pcCondition, pcNewStr, pCaseSensitive)
			return This.ReplaceStringItemsWCS(pcCondition, pCaseSensitive)(pcCondition, pCaseSensitive)

		def ReplaceAllWhereCS(pcCondition, pcNewStr, pCaseSensitive)
			return This.ReplaceStringItemsWCS(pcCondition, pCaseSensitive)(pcCondition, pCaseSensitive)

		#>

	#-- CASE-INSENSITIVE

	def ReplaceStringItemsW(pcCondition, pcNewStr)
		This.ReplaceStringItemsWCS(pcCondition, pcNewStr, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms

		def ReplaceStringsW(pcCondition, pcNewStr)
			return This.ReplaceStringItemsW(pcCondition, pcNewStr)
	
		def ReplaceW(pcCondition, pcNewStr)
			return This.ReplaceStringItemsW(pcCondition, pcNewStr)

		def ReplaceAllW(pcCondition, pcNewStr)
			return This.ReplaceStringItemsW(pcCondition, pcNewStr)

		def ReplaceWhere(pcCondition, pcNewStr)
			return This.ReplaceStringItemsW(pcCondition, pcNewStr)

		def ReplaceAllWhere(pcCondition, pcNewStr)
			return This.ReplaceStringItemsW(pcCondition, pcNewStr)

		#>

	  #===============================================================#
	 #  REPLACING SUBSTRINGS IN EACH STRING IN THE LIST OF STRINGS   #
	#===============================================================#

	def ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
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

	#-- CASE-INSENSITIVE

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
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
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

	#-- CASE-INSENSITIVE

	def ReplaceSubStrings(pacSubStr, pcNewStr)
		This.ReplaceSubStringsCS(pacSubStr, pcNewStr, :CaseSensitive = TRUE)

		def ReplaceSubStringsQ(pacSubStr, pcNewStr)
			This.ReplaceSubStrings(pcSubStr, pcNewStr)
			return This

	  #---------------------------------------------------------#
	 #   REPLACING MANY SUBSTRINGS BY MANY OTHERS ONE BY ONE   #
	#---------------------------------------------------------#

	def ReplaceSubStringsByManyCS(pacSubStr, pacNewStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		i = 0
		for str in pacSubStr
			i++
			if i <= len(pacNewStr)
				This.ReplaceSubStringsCS( pacSubStr[i], pacNewStr[i], pCaseSensitive )
			ok
		next

		def ReplaceSubStringsByManyCSQ(pacSubStr, pacNewStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(pacSubStr, pacNewStr, pCaseSensitive)
			return This

		def ReplaceSubStringsByOthersCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByOthersCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceSubStringsByOthersCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceSubStringsByManyOthersCS(paStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByManyOthersCSQ(paStr, pCaseSensitive)
				This.ReplaceSubStringsByManyOthersCS(paStr, pCaseSensitive)
				return This

		def ReplaceSubStringsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByManyOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceSubStringsByManyOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceSubStringsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByOthersOneByOneCSQ(paStr, pacNewStr, pCaseSensitive)
				This.ReplaceSubStringsByOthersOneByOneCS(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceSubStringsByManyOthersOneByOneCS(paStr, pCaseSensitive)
			This.ReplaceSubStringsByManyCS(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByManyOthersOneByOneCSQ(paStr, pCaseSensitive)
				This.ReplaceSubStringsByManyOthersOneByOneCS(paStr, pCaseSensitive)
				return This
		#>

	#-- CASE-INSENSITIVE

	def ReplaceSubStringsByMany(pacSubStr, pacNewStr)
		This.RepalceSubStringsByManyCS(pacSubStr, pacNewStr, pCaseSensitive)

		def ReplaceSubStringsByOthers(paStr, pacNewStr)
			This.ReplaceSubStringsByMany(paStr, pacNewStr)

			def ReplaceSubStringsByOthersQ(paStr, pacNewStr)
				This.ReplaceSubStringsByMany(paStr, pacNewStr, pCaseSensitive)
				return This

		def ReplaceSubStringsByManyOthers(paStr, pCaseSensitive)
			This.ReplaceSubStringsByMany(paStr, pacNewStr, pCaseSensitive)

			def ReplaceSubStringsByManyOthersQ(paStr)
				This.ReplaceSubStringsByManyOthers(paStr)
				return This

		def ReplaceSubStringsByManyOneByOne(paStr, pacNewStr)
			This.ReplaceSubStringsByMany(paStr, pacNewStr)

			def ReplaceSubStringsByManyOneByOneQ(paStr, pacNewStr)
				This.ReplaceSubStringsByManyOneByOne(paStr, pacNewStr)
				return This

		def ReplaceSubStringsByOthersOneByOne(paStr, pacNewStr)
			This.ReplaceSubStringsByMany(paStr, pacNewStr)

			def ReplaceSubStringsByOthersOneByOneQ(paStr, pacNewStr)
				This.ReplaceSubStringsByOthersOneByOne(paStr, pacNewStr)
				return This

		def ReplaceSubStringsByManyOthersOneByOne(paStr)
			This.ReplaceSubStringsByMany(paStr, pacNewStr)

			def ReplaceSubStringsByManyOthersOneByOneQ(paStr)
				This.ReplaceSubStringsByManyOthersOneByOne(paStr)
				return This
		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING NEXT NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------#

	def ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
		anPos = This.FindNextNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
		This.ReplaceSubStringAtThisPosition(anPos, pcNewSubStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextNthSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthNextSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNextNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNextNthOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthNextOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNthNextOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthNextOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
		This.ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextNthSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthNextSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNthNextSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNthNextSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		def ReplaceNextNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNextNthOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNextNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		def ReplaceNthNextOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNthNextOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNthNextOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		#>

	  #-------------------------------------------------------------------------#
	 #   REPLACING NEXT OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION   #
	#-------------------------------------------------------------------------#

	def ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
		This.ReplaceNextNthSubStringCS(1, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceNextSubStringCSQ(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplaceNextOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNextOccurrenceOfSubStringCSQ(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNextOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplaceNextSubString(pcSubStr, pcNewSubStr, pStartingAt)
		This.ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNextSubStringQ(pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextSubString(pcSubStr, pcNewSubStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplaceNextOccurrenceOfSubString(pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplaceNextSubString(pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNextOccurrenceOfSubStringQ(pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNextOccurrenceOfSubString(pcSubStr, pcNewSubStr, pStartingAt)
				return This

		#>

	  #---------------------------------------------------------------------------------#
	 #  REPLACING PREVIOUS NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------#

	def ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
		anPos = This.FindPreviousNthSubStringCS(n, pcSubStr, pStartingAt, pCaseSensitive)
		This.ReplaceSubStringAtPosition( anPos, pcNewSubStr)

		#< @FunctionFluentForm

		def ReplacePreviousNthSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthPreviousSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		def ReplacePreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousNthOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousNthOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		def ReplaceNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceOfSubStringCSQ(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceOfSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
		This.ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousNthSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceNthPreviousSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNthPreviousSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNthPreviousSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		def ReplacePreviousNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplacePreviousNthOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplacePreviousNthOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		def ReplaceNthPreviousOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousNthSubString(n, pcSubStr, pcNewSubStr, pStartingAt)

			def ReplaceNthPreviousOccurrenceOfSubStringQ(n, pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplaceNthPreviousOccurrenceOfSubString(n, pcSubStr, pcNewSubStr, pStartingAt)
				return This

		#>

	  #-----------------------------------------------------------------------------#
	 #   REPLACING PREVIOUS OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION   #
	#-----------------------------------------------------------------------------#

	def ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
		This.ReplacePreviousNthSubStringCS(1, pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplacePreviousSubStringCSQ(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForm

		def ReplacePreviousOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
			This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)

			def ReplacePreviousOccurrenceOfSubStringCSQ(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				This.ReplacePreviousOccurrenceOfSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def ReplacePreviousSubString(pcSubStr, pcNewSubStr, pStartingAt)
		This.ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplacePreviousSubStringQ(pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousSubString(pcSubStr, pcNewSubStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplacePreviousOccurrenceOfSubString(pcSubStr, pcNewSubStr, pStartingAt)
			This.ReplacePreviousSubString(pcSubStr, pcNewSubStr, pStartingAt)

			def ReplacePreviousOccurrenceOfSubStringQ(pcSubStr, pcNewSubStr, pStartingAt)
				This.ReplacePreviousOccurrenceOfSubString(pcSubStr, pcNewSubStr, pStartingAt)
				return This

		#>

	  #------------------------------------------------------#
	 #    REPLACING SUBSTRINGS VERIYING A GIVEN CONDITION    #
	#------------------------------------------------------#

	def ReplaceSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)
		anPositions = This.FindSubStringsW(pcCondition, pCaseSensitive)
		This.ReplaceSubStringsAtThesePositions(anPositions, pcNewStr)

		#< @FunctionFluentForm

		def ReplaceSubStringsWCSQ(pcCondition, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def ReplaceAllSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)

			def ReplaceAllSubStringsWCSQ(pcCondition, pcNewStr, pCaseSensitive)
				This.ReplaceAllSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)
				return This

		def ReplaceSubStringsWhereCS(pcCondition, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)

			def ReplaceSubStringsWhereCSQ(pcCondition, pcNewStr, pCaseSensitive)
				This.ReplaceSubStringsWhereCS(pcCondition, pcNewStr, pCaseSensitive)
				return This

		def ReplaceAllSubStringsWhereCS(pcCondition, pcNewStr, pCaseSensitive)
			This.ReplaceSubStringsWCS(pcCondition, pcNewStr, pCaseSensitive)

			def ReplaceAllSubStringsWhereCSQ(pcCondition, pcNewStr, pCaseSensitive)
				This.ReplaceAllSubStringsWhereCS(pcCondition, pcNewStr, pCaseSensitive)
				return This

		#>

	#-- CASE-INSENSITIVE

	def ReplaceSubStringsW(pcCondition)
		This.ReplaceSubStringsWCS(pcCondition, :CaseSensitive = TRUE)

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

	  #===================================================#
	 #     REMOVING STRINGS FROM THE LIST OF STRINGS     #
	#===================================================#

	def RemoveStringItemCS(pcStr, pCaseSensitive)
		anPos = This.FindStringItemCS(pcStr, pCaseSensitive)
		This.RemoveStringItemsAtThesePositions(anPos)

		def RemoveStringItemCSQ(pcStr, pCaseSensitive)
			This.RemoveStringItemCS(pcStr, pCaseSensitive)
			return This

		def RemoveStringCS(pcStr, pCaseSensitive)
			This.RemoveStringItemCS(pcStr, pCaseSensitive)

			def RemoveStringCSQ(pcStr, pCaseSensitive)
				This.RemoveStringCS(pcStr, pCaseSensitive)
				return This

		def RemoveCS(pcStr, pCaseSensitive)
			This.RemoveStringItemCS(pcStr, pCaseSensitive)

			def RemoveCSQ(pcStr, pCaseSensitive)
				This.RemoveCS(pcStr, pCaseSensitive)
				return This

		def RemoveAllCS(pcStr, pCaseSensitive)
			This.RemoveStringItemCS(pcStr, pCaseSensitive)

			def RemoveAllCSQ(pcStr, pCaseSensitive)
				This.RemoveAllCS(pcStr, pCaseSensitive)
				return This

		def RemoveAllOccurrencesOfStringItemCS(pcStr, pCaseSensitive)
			This.RemoveStringCS(pcStr, pCaseSensitive)

			def RemoveAllOccurrencesOfStringItemCSQ(pcStr, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringCS(pcStr, pCaseSensitive)
				return This

		def RemoveAllOccurrencesOfStringCS(pcStr, pCaseSensitive)
			This.RemoveStringCS(pcStr, pCaseSensitive)

			def RemoveAllOccurrencesOfStringCSQ(pcStr, pCaseSensitive)
				This.RemoveAllOccurrencesOfStringCS(pcStr, pCaseSensitive)
				return This

	def RemoveStringItem(pcStr)
		This.RemoveStringCS(pcStr, :CaseSensitive = TRUE)

		def RemoveStringItemQ(pcStr)
			This.RemoveStringItem(pcStr)
			return This

		def RemoveString(pcStr)
			This.RemoveStringItem(pcStr)

			def RemoveStringQ(pcStr)
				This.RemoveString(pcStr)
				return This

		def Remove(pcStr)
			This.RemoveStringItem(pcStr)

			def RemoveQ(pcStr)
				This.Remove(pcStr)
				return This

		def RemoveAll(pcStr)
			This.RemoveStringItem(pcStr)

			def RemoveAllQ(pcStr)
				This.RemoveAll(pcStr)
				return This

		def RemoveAllOccurrencesOfStringItem(pcStr)
			This.RemoveStringItem(pcStr)

			def RemoveAllOccurrencesOfStringItemQ(pcStr)
				This.RemoveAllOccurrencesOfStringItem(pcStr)
				return This

		def RemoveAllOccurrencesOfString(pcStr)
			This.RemoveStringItem(pcStr)

			def RemoveAllOccurrencesOfStringQ(pcStr)
				This.RemoveAllOccurrencesOfString(pcStr)
				return This

	  #------------------------------------------#
	 #   REMOVING STRING AT A GIVEN POSITION    #
	#------------------------------------------#

	def RemoveStringItemAtPosition(n)
		This.QStringListObject().removeAt(n-1)

		def RemoveStringItemAtPositionQ(n)
			This.RemoveStringItemAtPosition(n)
			return This

		def RemoveStringAtPosition(n)
			This.RemoveStringItemAtPosition(n)

			def RemoveStringAtPositionQ(n)
				This.RemoveStringAtPosition(n)
				return This

		def RemoveStringItemAtThisPosition(n)
			This.RemoveStringItemAtPosition(n)

			def RemoveStringItemAtThisPositionQ(n)
				This.RemoveStringItemAtThisPosition(n)
				return This

		def RemoveStringAtThisPosition(n)
			This.RemoveStringItemAtPosition(n)

			def RemoveStringAtThisPositionQ(n)
				This.RemoveStringAtThisPosition(n)
				return This

		def RemoveNth(n)
			This.RemoveStringItemAtPosition(n)

			def RemoveNthQ(n)
				This.RemoveNth(n)
				return This

	  #------------------------------------------#
	 #   REMOVING STRINGS AT GIVEN POSITIONS    #
	#------------------------------------------#

	def RemoveStringItemsAtPositions(panPositions)
		anPos = sort(panPositions)

		for i = len(anPos) to 1 step -1
			This.RemoveStringAtPosition(anPos[i])
		next

		def RemoveStringItemsAtPositionsQ(panPositions)
			This.RemoveStringItemsAtPositions(panPositions)
			return This

		def RemoveStringsAtPositions(panPositions)
			This.RemoveStringItemsAtPositions(panPositions)

			def RemoveStringsAtPositionsQ(panPositions)
				This.RemoveStringsAtPositions(panPositions)
				return This

		def RemoveStringItemsAtThesePositions(panPositions)
			This.RemoveStringItemsAtPositions(panPositions)

			def RemoveStringItemsAtThesePositionsQ(panPositions)
				This.RemoveStringItemsAtThesePositions(panPositions)
				return This

		def RemoveStringsAtThesePositions(panPositions)
			This.RemoveStringItemsAtPositions(panPositions)

			def RemoveStringsAtThesePositionsQ(panPositions)
				This.RemoveStringsAtThesePositions(panPositions)
				return This

	  #-----------------------------------------------------------------#
	 #    REMOVING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
	#-----------------------------------------------------------------#
	
	def RemoveNthStringItemCS(n, pcStr, pCaseSensitive)

		anPos = This.FindStringCS(pcStr, pCaseSensitive)
		nPos = anPos[n]

		This.RemoveStringAtPosition(nPos)

		def RemoveNthStringItemCSQ(n, pcStr, pCaseSensitive)
			This.RemoveNthStringItemCS(n, pcStr, pCaseSensitive)
			return This

		def RemoveNthStringCS(n, pcStr, pCaseSensitive)
			This.RemoveNthStringItemCS(n, pcStr, pCaseSensitive)

			def RemoveNthStringCSQ(n, pcStr, pCaseSensitive)
				This.RemoveNthStringCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)
			This.RemoveNthStringItemCS(n, pcStr, pCaseSensitive)

			def RemoveNthOccurrenceCSQ(n, pcStr, pCaseSensitive)
				This.RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveNthOccurrenceOfStringItemCS(n, pcStr, pCaseSensitive)
			This.RemoveNthStringItemCS(n, pcStr, pCaseSensitive)

			def RemoveNthOccurrenceOfStringItemCSQ(n, pcStr, pCaseSensitive)
				This.RemoveNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)
				return This

		def RemoveNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)
			This.RemoveNthStringItemCS(n, pcStr, pCaseSensitive)

			def RemoveNthOccurrenceOfStringCSQ(n, pcStr, pCaseSensitive)
				This.RemoveNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)
				return This

	#--- CASE-INSENSITIVE

	def RemoveNthStringItem(n, pcStr)

		This.RemoveNthStringItemCS(n, pcStr, :CaseSensitive = TRUE)

		def RemoveNthStringItemQ(n, pcStr)
			This.RemoveNthStringItem(n, pcStr)
			return This

		def RemoveNthString(n, pcStr)
			This.RemoveNthStringItem(n, pcStr)

			def RemoveNthStringQ(n, pcStr)
				This.RemoveNthString(n, pcStr)
				return This

		def RemoveNthOccurrence(n, pcStr)
			This.RemoveNthStringItem(n, pcStr)

			def RemoveNthOccurrenceQ(n, pcStr)
				This.RemoveNthOccurrence(n, pcStr)
				return This

		def RemoveNthOccurrenceOfStringItem(n, pcStr)
			This.RemoveNthStringItem(n, pcStr)

			def RemoveNthOccurrenceOfStringItemQ(n, pcStr)
				This.RemoveNthOccurrenceOfString(n, pcStr)
				return This

		def RemoveNthOccurrenceOfString(n, pcStr)
			This.RemoveNthStringItem(n, pcStr)

			def RemoveNthOccurrenceOfStringQ(n, pcStr)
				This.RemoveNthOccurrenceOfString(n, pcStr)
				return This

	  #-------------------------------------------------------------------#
	 #    REMOVING FIRST OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
	#-------------------------------------------------------------------#

	def RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

		bCaseSensitive = TRUE

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			bCaseSensitive = pCaseSensitive[2]
		ok

		if bCaseSensitive
			This.QStringListObject().removeOne(pcStrItem)

		else
			nPos = This.FindFirstStringItemCS(pcStrItem, :CaseSensitive = FALSE)
			This.RemoveStringItemAtPosition(nPos)
		ok

		#< @FunctionFluentForm

		def RemoveFirstStringItemCSQ(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveFirstStringCS(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveFirstStringCSQ(pcStrItem, pCaseSensitive)
				This.RemoveFirstStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveFirstOccurrenceCS(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveFirstOccurrenceCSQ(pcStrItem, pCaseSensitive)
				This.RemoveFirstOccurrenceCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveFirstOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveFirstOccurrenceOfStringItemCSQ(pcStrItem, pCaseSensitive)
				This.RemoveFirstOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveFirstOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveFirstOccurrenceOfStringCSQ(pcStrItem, pCaseSensitive)
				This.RemoveFirstOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveFirstCS(pcStrItem, pCaseSensitive)
			This.RemoveFirstStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveFirstCSQ(pcStrItem, pCaseSensitive)
				This.RemoveFirstCS(pcStrItem, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveFirstStringItem(pcStrItem)

		This.RemoveFirstStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		#< @FunctionFleuntForm

		def RemoveFirstStringItemQ(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveFirstString(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)

			def RemoveFirstStringQ(pcStrItem)
				This.RemoveFirstString(pcStrItem)
				return This

		def RemoveFirstOccurrence(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)

			def RemoveFirstOccurrenceQ(pcStrItem)
				This.RemoveFirstOccurrence(pcStrItem)
				return This

		def RemoveFirstOccurrenceOfStringItem(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)

			def RemoveFirstOccurrenceOfStringItemQ(pcStrItem)
				This.RemoveFirstOccurrenceOfString(pcStrItem)
				return This

		def RemoveFirstOccurrenceOfString(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)

			def RemoveFirstOccurrenceOfStringQ(pcStrItem)
				This.RemoveFirstOccurrenceOfString(pcStrItem)
				return This

		def RemoveFirst(pcStrItem)
			This.RemoveFirstStringItem(pcStrItem)

			def RemoveFirstQ(pcStrItem)
				This.RemoveFirst(pcStrItem)
				return This

		#>

	  #------------------------------------------------------------------#
	 #    REMOVING LAST OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
    	#------------------------------------------------------------------#

	def RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

		bCaseSensitive = TRUE

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			bCaseSensitive = pCaseSensitive[2]
		ok

		if bCaseSensitive
			This.QStringListObject().removeLast(pcStrItem)

		else
			nPos = This.FindLastStringItemCS(pcStrItem, :CaseSensitive = FALSE)
			This.RemoveStringItemAtPosition(nPos)
		ok

		#< @FunctionFluentForm

		def RemoveLastStringItemCSQ(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveLastStringCS(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveLastStringCSQ(pcStrItem, pCaseSensitive)
				This.RemoveLastStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveLastOccurrenceCS(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveLastOccurrenceCSQ(pcStrItem, pCaseSensitive)
				This.RemoveLastOccurrenceCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveLastOccurrenceOfStringItemCS(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveLastOccurrenceOfStringItemCSQ(pcStrItem, pCaseSensitive)
				This.RemoveLastOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveLastOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveLastOccurrenceOfStringCSQ(pcStrItem, pCaseSensitive)
				This.RemoveLastOccurrenceOfStringCS(pcStrItem, pCaseSensitive)
				return This

		def RemoveLastCS(pcStrItem, pCaseSensitive)
			This.RemoveLastStringItemCS(pcStrItem, pCaseSensitive)

			def RemoveLastCSQ(pcStrItem, pCaseSensitive)
				This.RemoveLastCS(pcStrItem, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveLastStringItem(pcStrItem)

		This.RemoveLastStringItemCS(pcStrItem, :CaseSensitive = TRUE)

		#< @FunctionFleuntForm

		def RemoveLastStringItemQ(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveLastString(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)

			def RemoveLastStringQ(pcStrItem)
				This.RemoveLastString(pcStrItem)
				return This

		def RemoveLastOccurrence(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)

			def RemoveLastOccurrenceQ(pcStrItem)
				This.RemoveLastOccurrence(pcStrItem)
				return This

		def RemoveLastOccurrenceOfStringItem(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)

			def RemoveLastOccurrenceOfStringItemQ(pcStrItem)
				This.RemoveLastOccurrenceOfString(pcStrItem)
				return This

		def RemoveLastOccurrenceOfString(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)

			def RemoveLastOccurrenceOfStringQ(pcStrItem)
				This.RemoveLastOccurrenceOfString(pcStrItem)
				return This

		def RemoveLast(pcStrItem)
			This.RemoveLastStringItem(pcStrItem)

			def RemoveLastQ(pcStrItem)
				This.RemoveLast(pcStrItem)
				return This

		#>

	  #---------------------------------------------#
	 #   REMOVING MANY STRINGS AT THE SAME TIME    #
	#---------------------------------------------#

	def RemoveStringItemsCS(paStrItems, pCaseSensitive)

		if NOT IsListOfStrings(paStrItems)
			stzRaise("Incorrect param type! You must provide a list of strings.")
		ok

		for str in paStrItems
			This.RemoveStringCS(str, pCaseSensitive)
		next

		#< @FunctionFluentForm

		def RemoveStringItemsCSQ(paStrItems, pCaseSensitive)
			This.RemoveStringItemsCS(paStrItems, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveStringsCS(paStrItems, pCaseSensitive)
			This.RemoveStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveStringsCSQ(paStrItems, pCaseSensitive)
				This.RemoveStringsCS(paStrItems, pCaseSensitive)
				return This
		#--

		def RemoveManyStringItemsCS(paStrItems, pCaseSensitive)
			This.RemoveStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveManyStringItemsCSQ(paStrItems, pCaseSensitive)
				This.RemoveManyStringItemsCS(paStrItems, pCaseSensitive)
				return This

		def RemoveManyStringsCS(paStrItems, pCaseSensitive)
			This.RemoveStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveManyStringsCSQ(paStrItems, pCaseSensitive)
				This.RemoveManyStringsCS(paStrItems, pCaseSensitive)
				return This

		def RemoveManyCS(paStrItems, pCaseSensitive)
			This.RemoveStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveManyCSQ(paStrItems, pCaseSensitive)
				This.RemoveManyCS(paStrItems, pCaseSensitive)
				return This
	
		#--

		def RemoveTheseStringItemsCS(paStrItems, pCaseSensitive)
			This.RemoveManyStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveTheseStringItemsCSQ(paStrItems, pCaseSensitive)
				This.RemoveTheseStringItems(paStrItems, pCaseSensitive)
				return This

		def RemoveTheseStringsCS(paStrItems, pCaseSensitive)
			This.RemoveManyStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveTheseStringsCSQ(paStrItems, pCaseSensitive)
				This.RemoveTheseStringsCS(paStrItems, pCaseSensitive)
				return This

		def RemoveTheseCS(paStrItems, pCaseSensitive)
			This.RemoveManyStringItemsCS(paStrItems, pCaseSensitive)

			def RemoveTheseCSQ(paStrItems, pCaseSensitive)
				This.RemoveTheseCS(paStrItems, pCaseSensitive)
				return This

		#>

	#-- CASE-INSENSITIVE

	def RemoveStringItems(paStrItems)
		This.RemoveStringItemsCS(paStrItems, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveStringItemsQ(paStrItems)
			This.RemoveStringItems(paStrItems)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveStrings(paStrItems)
			This.RemoveStringItems(paStrItems)

			def RemoveStringsQ(paStrItems)
				This.RemoveStrings(paStrItems)
				return This
		#--

		def RemoveManyStringItems(paStrItems)
			This.RemoveStringItems(paStrItems)

			def RemoveManyStringItemsQ(paStrItems)
				This.RemoveManyStringItems(paStrItems)
				return This

		def RemoveManyStrings(paStrItems)
			This.RemoveStringItems(paStrItems)

			def RemoveManyStringsQ(paStrItems)
				This.RemoveManyStrings(paStrItems)
				return This

		def RemoveMany(paStrItems)
			This.RemoveStringItems(paStrItems)

			def RemoveManyQ(paStrItems)
				This.RemoveMany(paStrItems)
				return This
	
		#--

		def RemoveTheseStringItems(paStrItems)
			This.RemoveManyStringItems(paStrItems)

			def RemoveTheseStringItemsQ(paStrItems)
				This.RemoveTheseStringItems(paStrItems)
				return This

		def RemoveTheseStrings(paStrItems)
			This.RemoveManyStringItems(paStrItems)

			def RemoveTheseStringsQ(paStrItems)
				This.RemoveTheseStrings(paStrItems)
				return This

		def RemoveThese(paStrItems)
			This.RemoveManyStringItems(paStrItems)

			def RemoveTheseQ(paStrItems)
				This.RemoveThese(paStrItems)
				return This

		#>

	  #----------------------------------------------------#
	 #    REMOVING STRINGS VERIYING A GIVEN CONDITION     #
	#----------------------------------------------------#

	def RemoveStringItemsWCS(pcCondition, pCaseSensitive)
		anPositions = This.FindW(pcCondition, pCaseSensitive)
		This.RemoveStringItemsAtThesePositions()

		#< @FunctionFluentForm

		def RemoveStringItemsWCSQ(pcCondition, pCaseSensitive)
			This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveStringsWCS(pcCondition, pCaseSensitive)
			This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)

			def RemoveStringsWCSQ(pcCondition, pCaseSensitive)
				This.RemoveStringsWCS(pcCondition, pCaseSensitive)
				return This

		def RemoveAllWCS(pcCondition, pCaseSensitive)
			This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)

			def RemoveAllWCSQ(pcCondition, pCaseSensitive)
				This.RemoveAllWCS(pcCondition, pCaseSensitive)
				return This

		def RemoveWhereCS(pcCondition, pCaseSensitive)
			This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)

			def RemoveWhereCSQ(pcCondition, pCaseSensitive)
				This.RemoveWhereCS(pcCondition, pCaseSensitive)
				return This

		def RemoveAllWhereCS(pcCondition, pCaseSensitive)
			This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)

			def RemoveAllWhereCSQ(pcCondition, pCaseSensitive)
				This.RemoveAllWhereCS(pcCondition, pCaseSensitive)
				return This

		#>

	#-- CASE-INSENSITIVE

	def RemoveStringItemsW(pcCondition)
		This.RemoveStringItemsWCS(pcCondition, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveStringItemsWQ(pcCondition)
			This.RemoveStringItemsW(pcCondition)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveStringsW(pcCondition)
			This.RemoveStringItemsW(pcCondition)

			def RemoveStringsWQ(pcCondition)
				This.RemoveStringsW(pcCondition)
				return This

		def RemoveAllW(pcCondition)
			This.RemoveStringItemsW(pcCondition)

			def RemoveAllWQ(pcCondition)
				This.RemoveAllW(pcCondition)
				return This

		def RemoveWhere(pcCondition)
			This.RemoveStringItemsW(pcCondition)

			def RemoveWhereQ(pcCondition)
				This.RemoveWhere(pcCondition)
				return This

		def RemoveAllWhere(pcCondition)
			This.RemoveStringItemsW(pcCondition)

			def RemoveAllWhereQ(pcCondition)
				This.RemoveAllWhere(pcCondition)
				return This

		#>

	  #------------------------------------------------------------------------------#
	 #  REMOVING NEXT NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#------------------------------------------------------------------------------#

	def RemoveNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.RemoveStringItemAtThisPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextNthStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextNthStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextNthOccurrenceOfStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextNthOccurrenceOfStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextNthOccurrenceOfStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextOccurrenceOfStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceOfStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceOfStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextNthOccurrenceCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextNthOccurrenceCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextOccurrenceCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveNextNthStringItem(n, pcStr, pStartingAt)
		This.RemoveNextNthStringItemCS(n, pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextNthStringItemQ(n, pcStr, pStartingAt)
			This.RemoveNextNthStringItem(n, pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextNthString(n, pcStr, pStartingAt)
			This.RemoveNextNthStringItem(n, pcStr, pStartingAt)

			def RemoveNextNthStringQ(n, pcStr, pStartingAt)
				This.RemoveNextNthStringItem(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextStringItem(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNthNextStringItemQ(n, pcStr, pStartingAt)
				This.RemoveNthNextString(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextString(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNthNextStringQ(n, pcStr, pStartingAt)
				This.RemoveNthNextString(n, pcStr, pStartingAt)
				return This

		def RemoveNextNthOccurrenceOfStringItem(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNextNthOccurrenceOfStringItemQ(n, pcStr, pStartingAt)
				This.RemoveNextNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNextNthOccurrenceOfString(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNextNthOccurrenceOfStringQ(n, pcStr, pStartingAt)
				This.RemoveNextNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextOccurrenceOfStringItem(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNthNextOccurrenceOfStringItemQ(n, pcStr, pStartingAt)
				This.RemoveNthNextOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextOccurrenceOfString(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNthNextOccurrenceOfStringQ(n, pcStr, pStartingAt)
				This.RemoveNthNextOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNextNthOccurrence(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNextNthOccurrenceQ(n, pcStr, pStartingAt)
				This.RemoveNextNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextOccurrence(n, pcStr, pStartingAt)
			This.RemoveNextNthString(n, pcStr, pStartingAt)

			def RemoveNthNextOccurrenceQ(n, pcStr, pStartingAt)
				This.RemoveNthNextOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		#>

	  #---------------------------------------------------------------------------#
	 #   REMOVING NEXT OCCURRENCE OF STRING-ITEM STARTING AT A GIVEN POSITION    #
	#---------------------------------------------------------------------------#

	def RemoveNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)
		This.RemoveStringItemAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextStringItemCSQ(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextStringCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextStringCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextStringItemCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextOccurrenceOfStringItemCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextStringCS(pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextOccurrenceOfStringItemCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextOccurrenceOfStringCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextOccurrenceOfStringCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextStringCS(pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextOccurrenceOfStringCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextOccurrenceOfStringCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextOccurrenceCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextStringCS(pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextOccurrenceCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextOccurrenceOfStringCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveNextStringItem(pcStr, pStartingAt)
		This.RemoveNextStringItemCS(pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextStringItemQ(pcStr, pStartingAt)
			This.RemoveNextStringItem(pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextString(pcStr, pStartingAt)
			This.RemoveNextStringItem(pcStr, pStartingAt)

			def RemoveNextStringQ(pcStr, pStartingAt)
				This.RemoveNextStringItem(pcStr, pStartingAt)
				return This

		def RemoveNextOccurrenceOfStringItem(pcStr, pStartingAt)
			This.RemoveNextString(pcStr, pStartingAt)

			def RemoveNextOccurrenceOfStringItemQ(pcStr, pStartingAt)
				This.RemoveNextOccurrenceOfString(pcStr, pStartingAt)
				return This

		def RemoveNextOccurrenceOfString(pcStr, pStartingAt)
			This.RemoveNextString(pcStr, pStartingAt)

			def RemoveNextOccurrenceOfStringQ(pcStr, pStartingAt)
				This.RemoveNextOccurrenceOfString(pcStr, pStartingAt)
				return This

		def RemoveNextOccurrence(pcStr, pStartingAt)
			This.RemoveNextString(pcStr, pStartingAt)

			def RemoveNextOccurrenceQ(pcStr, pStartingAt)
				This.RemoveNextOccurrenceOfString(pcStr, pStartingAt)
				return This

		#>

	  #----------------------------------------------------------------------------------#
	 #  REMOVING PREVIOUS NTH OCCURRENCE OF A STRING-ITEM STARTING AT A GIVEN POSITION  #
	#----------------------------------------------------------------------------------#

	def RemovePreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindPreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.RemoveStringItemAtThisPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemovePreviousNthStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousNthStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousNthStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemovePreviousNthOccurrenceOfStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousNthOccurrenceOfStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemovePreviousNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousNthOccurrenceOfStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousOccurrenceOfStringItemCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceOfStringItemCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceOfStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemovePreviousNthOccurrenceCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousNthOccurrenceCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousNthOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousOccurrenceCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceOfStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemovePreviousNthStringItem(n, pcStr, pStartingAt)
		This.RemovePreviousNthStringItemCS(n, pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousNthStringItemQ(n, pcStr, pStartingAt)
			This.RemovePreviousNthStringItem(n, pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemovePreviousNthString(n, pcStr, pStartingAt)
			This.RemovePreviousNthStringItem(n, pcStr, pStartingAt)

			def RemovePreviousNthStringQ(n, pcStr, pStartingAt)
				This.RemovePreviousNthStringItem(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousStringItem(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemoveNthPreviousStringItemQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousString(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousString(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemoveNthPreviousStringQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousString(n, pcStr, pStartingAt)
				return This

		def RemovePreviousNthOccurrenceOfStringItem(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemovePreviousNthOccurrenceOfStringItemQ(n, pcStr, pStartingAt)
				This.RemovePreviousNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemovePreviousNthOccurrenceOfString(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemovePreviousNthOccurrenceOfStringQ(n, pcStr, pStartingAt)
				This.RemovePreviousNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousOccurrenceOfStringItem(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemoveNthPreviousOccurrenceOfStringItemQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousOccurrenceOfString(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemoveNthPreviousOccurrenceOfStringQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemovePreviousNthOccurrence(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemovePreviousNthOccurrenceQ(n, pcStr, pStartingAt)
				This.RemovePreviousNthOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousOccurrence(n, pcStr, pStartingAt)
			This.RemovePreviousNthString(n, pcStr, pStartingAt)

			def RemoveNthPreviousOccurrenceQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousOccurrenceOfString(n, pcStr, pStartingAt)
				return This

		#>

	  #-----------------------------------------#
	 #   REMOVING ALL STRINGS FROM THE LIST    #
	#-----------------------------------------#

	def RemoveAllStringItems()
		This.QStringListObject().clear()

		def RemoveAllStringItemsQ()
			This.Clear()
			return This

		def RemoveAllStrings()
			This.RemoveAllStringItems()

			def RemoveAllStringsQ()
				This.RemoveAllStrings()
				return This

	  #=====================================================#
	 #  REMOVING SUBSTRINGS FROM EACH STRING IN THE LIST   #
	#=====================================================#

	def RemoveSubStringCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
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

	#-- CASE-INSENSITIVE

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

	#-- CASE-INSENSITIVE

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

	#-- CASE-INSENSITIVE

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

	#-- CASE-INSENSITIVE

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
		if NOT IsListOfStrings(paSubStr)
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

	#-- CASE-INSENSITIVE

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

	def RemoveNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextNthSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthNextSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNextNthOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextNthOccurrenceOfSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextNthOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthNextOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthNextOccurrenceOfSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthNextOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveNextNthSubString(n, pcStr, pStartingAt)
		This.RemoveNextNthSubStringCS(n, pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextNthSubStringQ(n, pcStr, pStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthNextSubString(n, pcStr, pStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pStartingAt)

			def RemoveNthNextSubStringQ(n, pcStr, pStartingAt)
				This.RemoveNthNextSubString(n, pcStr, pStartingAt)
				return This

		def RemoveNextNthOccurrenceOfSubString(n, pcStr, pStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pStartingAt)

			def RemoveNextNthOccurrenceOfSubStringQ(n, pcStr, pStartingAt)
				This.RemoveNextNthOccurrenceOfSubString(n, pcStr, pStartingAt)
				return This

		def RemoveNthNextOccurrenceOfSubString(n, pcStr, pStartingAt)
			This.RemoveNextNthSubString(n, pcStr, pStartingAt)

			def RemoveNthNextOccurrenceOfSubStringQ(n, pcStr, pStartingAt)
				This.RemoveNthNextOccurrenceOfSubString(n, pcStr, pStartingAt)
				return This

		#>

	  #-------------------------------------------------------------------------#
	 #   REMOVING NEXT OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION    #
	#-------------------------------------------------------------------------#

	def RemoveNextSubStringCS(pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindNextSubStringCS(pcStr, pStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemoveNextSubStringCSQ(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextSubStringCS(pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemoveNextOccurrenceOfSubStringCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemoveNextSubStringCS(pcStr, pStartingAt, pCaseSensitive)

			def RemoveNextOccurrenceOfSubStringCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNextOccurrenceOfSubStringCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemoveNextSubString(pcStr, pStartingAt)
		This.RemoveNextSubStringCS(pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNextSubStringQ(pcStr, pStartingAt)
			This.RemoveNextSubString(pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNextOccurrenceOfSubString(pcStr, pStartingAt)
			This.RemoveNextSubString(pcStr, pStartingAt)

			def RemoveNextOccurrenceOfSubStringQ(pcStr, pStartingAt)
				This.RemoveNextOccurrenceOfSubString(pcStr, pStartingAt)
				return This

		#>

	  #----------------------------------------------------------------------------------#
	 #  REMOVING PREVIOUS NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION    #
	#----------------------------------------------------------------------------------#

	def RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindPreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(n, pCaseSensitive)

		#< @FunctionFluentForm

		def RemovePreviousNthSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemoveNthPreviousSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemovePreviousNthOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousNthOccurrenceOfSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousNthOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		def RemoveNthPreviousOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)

			def RemoveNthPreviousOccurrenceOfSubStringCSQ(n, pcStr, pStartingAt, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceOfSubStringCS(n, pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemovePreviousNthSubString(n, pcStr, pStartingAt)
		This.RemovePreviousNthSubStringCS(n, pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousNthSubStringQ(n, pcStr, pStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveNthPreviousSubString(n, pcStr, pStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pStartingAt)

			def RemoveNthPreviousSubStringQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousSubString(n, pcStr, pStartingAt)
				return This

		def RemovePreviousNthOccurrenceOfSubString(n, pcStr, pStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pStartingAt)

			def RemovePreviousNthOccurrenceOfSubStringQ(n, pcStr, pStartingAt)
				This.RemovePreviousNthOccurrenceOfSubString(n, pcStr, pStartingAt)
				return This

		def RemoveNthPreviousOccurrenceOfSubString(n, pcStr, pStartingAt)
			This.RemovePreviousNthSubString(n, pcStr, pStartingAt)

			def RemoveNthPreviousOccurrenceOfSubStringQ(n, pcStr, pStartingAt)
				This.RemoveNthPreviousOccurrenceOfSubString(n, pcStr, pStartingAt)
				return This

		#>

	  #-------------------------------------------------------------------------#
	 #   REMOVING Previous OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION    #
	#-------------------------------------------------------------------------#

	def RemovePreviousSubStringCS(pcStr, pStartingAt, pCaseSensitive)
		nPos = This.FindPreviousSubStringCS(pcStr, pStartingAt, pCaseSensitive)
		This.RemoveSubStringAtThisPosition(pcNewStr, pCaseSensitive)

		#< @FunctionFluentForm

		def RemovePreviousSubStringCSQ(pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousSubStringCS(pcStr, pStartingAt, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms


		def RemovePreviousOccurrenceOfSubStringCS(pcStr, pStartingAt, pCaseSensitive)
			This.RemovePreviousSubStringCS(pcStr, pStartingAt, pCaseSensitive)

			def RemovePreviousOccurrenceOfSubStringCSQ(pcStr, pStartingAt, pCaseSensitive)
				This.RemovePreviousOccurrenceOfSubStringCS(pcStr, pStartingAt, pCaseSensitive)
				return This

		#>

	#--- CASE-INSENSITIVE

	def RemovePreviousSubString(pcStr, pStartingAt)
		This.RemovePreviousSubStringCS(pcStr, pStartingAt, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemovePreviousSubStringQ(pcStr, pStartingAt)
			This.RemovePreviousSubString(pcStr, pStartingAt)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemovePreviousOccurrenceOfSubString(pcStr, pStartingAt)
			This.RemovePreviousSubString(pcStr, pStartingAt)

			def RemovePreviousOccurrenceOfSubStringQ(pcStr, pStartingAt)
				This.RemovePreviousOccurrenceOfSubString(pcStr, pStartingAt)
				return This

		#>

	  #------------------------------------------------------#
	 #    REMOVING SUBSTRINGS VERIYING A GIVEN CONDITION    #
	#------------------------------------------------------#

	def RemoveSubStringsWCS(pcCondition, pCaseSensitive)
		anPositions = This.FindSubStringsW(pcCondition, pCaseSensitive)
		This.RemoveSubStringsAtThesePositions(anPositions)

		#< @FunctionFluentForm

		def RemoveSubStringsWCSQ(pcCondition, pCaseSensitive)
			This.RemoveSubStringsWCS(pcCondition, pCaseSensitive)
			return This
		#>

		#< @FunctionAlternativeForms

		def RemoveAllSubStringsWCS(pcCondition, pCaseSensitive)
			This.RemoveSubStringsWCS(pcCondition, pCaseSensitive)

			def RemoveAllSubStringsWCSQ(pcCondition, pCaseSensitive)
				This.RemoveAllSubStringsWCS(pcCondition, pCaseSensitive)
				return This

		def RemoveSubStringsWhereCS(pcCondition, pCaseSensitive)
			This.RemoveSubStringsWCS(pcCondition, pCaseSensitive)

			def RemoveSubStringsWhereCSQ(pcCondition, pCaseSensitive)
				This.RemoveSubStringsWhereCS(pcCondition, pCaseSensitive)
				return This

		def RemoveAllSubStringsWhereCS(pcCondition, pCaseSensitive)
			This.RemoveSubStringsWCS(pcCondition, pCaseSensitive)

			def RemoveAllSubStringsWhereCSQ(pcCondition, pCaseSensitive)
				This.RemoveAllSubStringsWhereCS(pcCondition, pCaseSensitive)
				return This

		#>

	#-- CASE-INSENSITIVE

	def RemoveSubStringsW(pcCondition)
		This.RemoveSubStringsWCS(pcCondition, :CaseSensitive = TRUE)

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

	  #=========================================#
	 #   PERFORMING AN ACTION ON EACH STRING   #
	#=========================================#

	def ForEachStringItemPerform(pcCode)
		# Must begin with '@str =" or '@string ='
		/* Example

		o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])
		o1.ForEachStringPerform('{ Q(@str).RemoveQ(".txt").Content() }')

		o1.Content() # ---> [ "village", "town", "country" ]

		*/

		if NOT isString(pcCode)
			stzRaise("Invalid param type! Condition must be a string.")
		ok

		oCode = new stzString(pcCode)
		oCode.ReplaceAllCS("@string", "@str", :CaseSensitive = FALSE)

		if NOT oCode.ContainsCS("@str", :CS = FALSE)
			stzRaise("Incorrect parm! Condition should contain '@str' or '@string'.")
		ok

		cCode = oCode.RemoveBoundsQ("{","}").Trimmed()
		oCode = new stzString(cCode)
		/* TODO - ERROR: check why when we do

		oCode.RemoveBoundsQ("{","}").SimplifyQ()

		and get the object content using

		? oCode.Content()

		we find that the object is not affectd by SimplifyQ()!
		*/

		if NOT oCode.BeginsWithOneOfTheseCS( [ "@str =", "@str=" ], :CaseSensitive = FALSE )

			stzRaise("Syntax error! Condition should begin with '@str =' or '@string ='.")
		ok

		@i = 0
		for @str in This.ListOfStrings()
			@i++
			eval(cCode)

			This.ReplaceStringAtPosition(@i, :With = @str )	
		next

		#< @FunctionFluentForm

		def ForEachStringItemPerformQ(pcCode)
			This.ForEachStringItemPerform(pcCode)
			return This

		#>

		#< @FunctionAlternativeForm

		def ForEachStringPerform(pcCode)
			This.ForEachStringItemPerform(pcCode)

			def ForEachStringPerformQ(pcCode)
				This.ForEachStringPerform(pcCode)
				return This

		def ForEachStringItemDo(pcCode)
			This.ForEachStringItemPerform(pcCode)

			def ForEachStringItemDoQ(pcCode)
				This.ForEachStringDo(pcCode)
				return This

		def ForEachStringDo(pcCode)
			This.ForEachStringItemPerform(pcCode)

			def ForEachStringDoQ(pcCode)
				This.ForEachStringDo(pcCode)
				return This

		def Perform(cCode)
			This.ForEachStringItemPerform(pcCode)

			def PerformQ(cCode)
				This.Perform(cCode)
				return This
		#>

	   #----------------------------------------------#
	  #   PERFORMING AN ACTION ON EACH STRING WHEN   #
	 #    A CONDTION IS VERIFIED                    #
	#----------------------------------------------#

	def ForEachStringItemPerformW(pcCode, pcConsition)
		if isList(pcCondition) and Q(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]
		ok

		acStrings = This.StringsW(pcCondition)
		oListOfStrings = new stzListOfStrings(acStrings)

		oListOfStrings.ForEachStringItemPerform(pcCode)

		def ForEachStringPerformW(pcCode, pcCondition)
			This.ForEachStringItemPerformW(pcCode, pcConsition)

		def PerformW(pcCode, pcCondition)
			This.ForEachStringItemPerformW(pcCode, pcConsition)

	def StringsW(pCondition)
		return This.StringsWCS(pCondition, :CaseSensitive = TRUE)

	def StringsWCS(pcCondition, pCaseSensitive)
		pcCondition = StzStringQ(pcCondition).ReplaceManyCSQ(
			[ "@str", "@string" ],
			:With = "@item", pCaseSensitive ).Content()
		
		if pCaseSensitive = TRUE
			acResult = This.ToStzList().ItemsW(pcCondition)

		else
			oCopy = This.Copy().LowercaseQ()
			anPos = oCopy.ToStzList().ItemsPositionsW(pcCondition)

			acResult = This.StringsAtPositions(anPos)

		ok

		return acResult

	def StringsPositionsW(pcCondition)
		acStrings = This.StringsW(pcCondition)
		anPos = This.FindMany(acStrings)

		return anPos

	def StringsPositionsWCS(pcCondition, pCaseSensitive)
		acStrings = This.StringsWCS(pcCondition, pCaseSensitive)
		anPos = This.FindManyCS(acStrings, pCaseSensitive)

		return anPos

	  #----------------------------------------------#
	 #   YIELDING AN INFORMATION FROM EACH STRING   #
	#----------------------------------------------#

	def ForEachStringItemYield(pcCode)
		/* Example

		o1 = new stzListOfStrings([ "village", "town", "country" ])
		o1.FromEachStringYield('[ @str, Q(@str).NumberOfChars()' ])

		o1.Content()
		# ---> [ [ "village", 6 ], [ "town", 4 ], [ "country", 7 ] ]

		*/

		if NOT isString(pcCode)
			stzRaise("Invalid param type! Condition must be a string.")
		ok

		oCode = new stzString(pcCode)
		oCode.ReplaceAllCS("@string", "@str", :CaseSensitive = FALSE)

		if NOT oCode.ContainsCS("@str", :CS = FALSE)
			stzRaise("Incorrect parm! Condition should contain '@str' or '@string'.")
		ok

		aResult = []

		cCode = oCode.SimplifyQ().BoundsRemoved("{","}")
		cCode = 'aResult + ( ' + cCode + ' )'

		for @str in This.ListOfStrings()
			eval(cCode)
		next

		return aResult


		#< @FunctionFluentForm

		def ForEachStringItemYieldQ(pcCode)
			return This.ForEachStringYieldQR(pcCode, :stzList)

		def ForEachStringItemYieldQR(pcCode, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ForEachStringItemYield(pcCode) )

			on :stzListOfStrings
				return new stzListOfStrings( This.ForEachStringItemYield(pcCode) )
			
			on :stzListOfNumbers
				return new stzListOfNumbers( This.ForEachStringItemYield(pcCode) )
	
		other
				stzRaise("Unsupported return type!")
		off

		#>

		#< @FunctionAlternativeForms

		def ForEachStringYield(pcCode)
			return This.ForEachStringItemYield(pcCode)

			def ForEachStringYieldQ(pcCode)
				return This.ForEachStringYieldQR(pcCode, :stzList)
	
			def ForEachStringYieldQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.ForEachStringYield(pcCode) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.ForEachStringYield(pcCode) )
				
				on :stzListOfNumbers
					return new stzListOfNumbers( This.ForEachStringYield(pcCode) )
		
			other
					stzRaise("Unsupported return type!")
			off

		def Yield(pcCode)
			return This.ForEachStringItemYield(pcCode)

			def YieldQ(pcCode)
				return This.YieldQR(pcCode, :stzList)
	
			def YieldQR(pcCode, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Yield(pcCode) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Yield(pcCode) )
				
				on :stzListOfNumbers
					return new stzListOfNumbers( This.Yield(pcCode) )
		
			other
					stzRaise("Unsupported return type!")
			off

		#>

	   #===============================================#
	  #    CHECKING IF A STRING-ITEM IS DUPLICATED    #
	 #   (APPEARS MORE THAN ONCE IN THE LIST)        #
	#===============================================#

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

	#-- CASE-INSENSITIVE

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
		
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
		
		if StzListQ(paBoxOptions).IsTextBoxedParamList()

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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

	  #------------------------------#
	 #     OPERATORS OVERLOADING    # 
	#------------------------------#

	/*
		TODO: Operators should carry same semantics in all classes...
	*/

	def operator(pcOp, pValue)
		
		if pcOp = "[]"

			if isNumber(pValue)
				return This.String(pValue)

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

			ok

			if isList(pValue) and Q(pValue).IsListOfLists() and
			   len(pValue) = 1
				
				/*
				Example:

				o1 = new stzListOfStrings([ "X5", "X7", "X3", "X0" ])
				o1 - [[ :LastStringIf, :EqualTo, 0 ]]

				Gives -> [ "X5", "X7", "X3" ]

				NB: We use the two brackets here to differenciate
				the syntax from when we use only one bracket:

					 o1 - [ "X0", "X3", "X7" ] --> [ "X5" ]

				which means : remove these strings from the main list
				*/

				aListOfConditions = [
					:EqualTo, :LesserThan, :GreaterThan,
					:LesserThanOrEqual, :GreaterThanOrEqual,
					:DifferentThan ]

				cFirstOrLast = pValue[1][1]
				cCondition = pValue[1][2]
				value = pValue[1][3]

				oCondition = new stzString(cCondition)

				if NOT ( len(pValue[1]) = 3 AND
				   (cFirstOrLast = :FirstItemIf or cFirstOrLast = :LastItemIf) AND
				   oCondition.ExistsInList(aListOfConditions) )

					stzRaise(stzListError(:UnsupportedExpressionInOverloadedMinusOperator))
				ok
					
				if cFirstOrLast = :FirstStringIf

					if cCondition = :EqualTo
						if IsNumberOrString(value)
							if This.FirstString() = value
								This.RemoveFirstString()
							ok

						but isList(value)
							oList = value
							if oList.IsEqualTo(cFirstOrLast)
								This.RemoveFirstString()
							ok
						ok

					but cCondition = :LesserThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :LesserOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :DifferentThan
						stzRaise(:UnsupportedFeatureInThisVersion)
					
					ok

				but cFirstOrLast = :LastStringIf

					if cCondition = :EqualTo
						if IsNumberOrString(value)
							if This.LastItem() = value
								This.RemoveLastString()
							ok

						but isList(value)
							oList = value
							if value.IsEqualTo(cFirstOrLast)
								This.RemoveLastString()
							ok
						ok

					but cCondition = :LesserThan
						stzRaise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :GreaterThan
						stzRaise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :LesserOrEqualThan
						stzRaise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :GreaterOrEqualThan
						stzRaise(stzListError(:UnsupportedFeattureInThisVersion))
					
					ok

				ok
				
			ok

			# if we whave this syntax: o1 - [ "X5", "X3" ]

			if isList(pValue)
				if len(pValue) > 0
					anPositions = This.FindMany(pValue)
					This.RemoveManyAtPositions(anPositions)
				ok
			ok

		but pcOp = "*"
			This.MultiplyBy(pValue)

		but pcOp = "+"
			This.AddString(pValue)
		ok
