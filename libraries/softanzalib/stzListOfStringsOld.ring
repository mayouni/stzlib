
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
		raise(stzListOfStringsError(:CanNotTransformQStringListToRingList))
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
			raise("A QStringList Qt object is exepected as a param!")
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
			raise(stzListOfStringsError(:CanNotCreateListOfStrings))
		ok
		
	def Content()
		acResult = []

		for i = 0 to This.QStringListObject().size()-1
			acResult + This.QStringListObject().at(i)	
		next

		return acResult

	def Copy()
		oCopy = new stzListOfStrings( This.Content() )
		return oCopy

	def ListOfStrings()	
		return This.Content()

	def Strings()
		return This.Content()

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

	def QStringListObject()
		return @oQStrList

	def String(n)
		if isNumber(n)
			return This.QStringListObject().value(n-1)

		ok

		def StringQ(n)
			return new stzString( This.String(n) )

		def NthString(n)
			return This.String(n)

			def NthStringQ(n)
				return new stzString( This.NthString(n) )

		def StringN(n)
			return This.String(n)

			def StringNQ(n)
				return new stzString( This.StringN(n) )
	
	def FirstString()
		return This.String(1)

		def First()
			return This.FirstString()

	def LastString()
		return This.String( This.NumberOfStrings() )

		def Last()
			return This.LastString()

	def NumberOfStrings()
		return This.QStringListObject().size()

	def SizeInBytes()
		nSizeInBytes = 0
		for str in This.ListOfStrings()
			oBinStr = new stzListOfBytes(str)
			nSizeInBytes += oBinStr.SizeInBytes()
		next
		return nSizeInBytes

	  #----------------------------#
	 #    APPENDING & PREPENDING  #
	#----------------------------#

	def Append(pcStr)
		if isString(pcStr)
			This.QStringListObject().append(pcStr)
		else
			raise( stzListOfStringsError(:CanNotAddNonStringItem) )
		ok

		def AppendQ(pcStr)
			This.Append(pcStr)
			return This

		def Add(pcStr)
			This.Append(pcStr)

			def AddQ(pcStr)
				This.Add(pcStr)
				return This

		def AddString(pcStr)
			This.Append(pcStr)

			def AddStringQ(pcStr)
				This.AddString(pcString)
				return This
			
	def Prepend(pcStr)
		if isString(pcStr)
			This.QStringListObject().prepend(pcStr)
		else
			raise( stzListOfStringsError(:CanNotAddNonStringItem) )
		ok
		
	def PrependQ(pcStr)
		This.Prepend(pcStr)
		return This

	  #------------------------------------------#
	 #    APPENDING EACH STRING IN THE LIST     #
	#------------------------------------------#

	def AppendEach(pcSubStr)
		if isList(pcSubStr) and _@(pcSubStr).IsWithParamList()
			pcSubStr = pcSubStr[2]
		ok

		acResult = []
		for str in This.ListOfStrings()
			acResult + (str + pcSubStr)
		next

		This.Update( acResult )

		def AppendEachQ(pcSubStr)
			This.AppendEach(pcSubStr)
			return This

		def AppendEachString(pcSubStr)
			This.AppendEach(pcSubStr)

			def AppendEachStringQ(pcSubStr)
				This.AppendEachString(pcSubStr)
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
			raise( stzListOfStringsError(:CanNotInsertNonStringItem) )
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
			raise("Param you provided is not a list of strings!")
	
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
		return This

/*	   #--------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS A GIVEN      #
	 #      STRING (AS AN ENTIRE ITEM OF THE LIST)            #
	#--------------------------------------------------------#

	// TODO: support locales

	def ContainsStringCS(pcStr, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		# t0 = clock()

		if pCaseSensitive = TRUE
			bResult = This.QStringListObject().contains(pcStr)
			return bResult

		else
			# pCaseSensitive = FALSE

			cStr = StzStringQ(pcStr).Lowercased()

			oQStrList = This.Copy().ApplyLowercaseQ().QStringListObject()

			bResult = This.QStringListObject().Contains(cStr)
			return bResult
		ok

		# ? ( clock() - t0 ) / clockspersecond()

		#< @FunctionAlternativeForms

		def ContainsCS(pcStr)
			return This.ContainsStringCS(pcStr, pCaseSensitive)

		def ContainsThisStringCS(pcStr)
			return This.ContainsStringCS(pcStr, pCaseSensitive)

		#>

	def ContainsNoStringCS(pcStr, pCaseSensitive)
		return NOT This.ContainsStringCS(pcStr, pCaseSensitive)

		def ContainsNo(pcStr)
			return NOT This.Contains(pcStr)

	  #-------------------------------------------------------------#
	 #  CHECKING IF STRINGS OF THE LIST CONTAIN A GIVEN SUSBTRING  #
	#-------------------------------------------------------------#

	def ContainsSubstringCS( pacStr, pCaseSensitive )

		# t0 = clock()

		bResult = TRUE

		for str in pacStr
			if NOT This.ContainsCS(str, pCaseSensitive )
				bResult = FALSE
				exit
			ok
		next

		# ? ( clock() - t0 ) / clockspersecond()

		return bResult

	def ContainsEach(pacStr)
		return This.ContainsEachCS(pacStr, :CaseSensitive = TRUE)

	def ContainsBothCS( pcStr1, pcStr2, pCaseSensitive )
		return This.ContainsEachCS( [pcStr1, pcStr2], pCaseSensitive )

	def ContainsBoth(pcStr1, pcStr2)
		return This.ContainsBothCS(pcStr1, pcStr2, :CaseSensitive = TRUE)

	  #--------------------------------------------------------#
	 #   CONTAINEMENT of A SUBSTRING IN THE LIST OF STRINGS   #
	#--------------------------------------------------------#

	def ContainsSubstringInEachStringCS(pcSubStr, pCaseSensitive)
		bResult = TRUE

		aTempList = This.ToListOfStzStrings()
		for oStzStr in aTempList
			if NOT oStzStr.ContainsCS(pcSubStr, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsSubstringInEachString(pcSubStr)
		return This.ContainsSubstringInEachStringCS(pcSubStr, :CaseSensitive = TRUE)

	def ContainsSubstringCS(pcSubStr, pCaseSensitive)
		// TODO
		// --> At least one string of the list of strings contains pcSubStr

	def ContainsSubstring(pcSubStr)
		return This.ContainsSubstringCS(pcSubStr, :CaseSensitive = TRUE)
*/
	  #--------------------------------------#
	 #     REVERSING THE LIST OF STRINGS    #
	#--------------------------------------#

	def ReverseStrings()
		aTemp = StzListQ( This.ListOfStrings() ).ItemsReversed()
		This.Update( aTemp )
		
		def ReverseStringQ()
			This.ReverseStrings()
			return This

	def StringsReversed()
		aResult = This.Copy().ReverseStringsQ().Content()
		return aResult

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

		return aResult

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

/*	  #-------------------#
	 #     REPLACING     # TODO: Review this section and make same as REMOVING
	#-------------------#

	def ReplaceStringAtPosition(n, pcStr)
		if isList(pcStr) and
		   ( Q(pcStr).IsWithParamList() or
		     Q(pcStr).IsByParamList() )

			pcStr = pcStr[2]
		ok

		This.QStringListObject().replace(n-1,pcStr)

		def ReplaceStringAtPositionQ(n, pcStr)
			This.ReplaceStringAtPosition(n, pcStr)
			return This

	def ReplaceAll(pcStr)
		anPos = This.FindAll(pcStr)

		This.ReplaceStringsAtThesePositions(anPos)

	def ReplaceAllQ(pcStr)
		This.ReplaceAll(pcStr)
		return This
	
	  #---------------------------------------------------#
	 #     REMOVING STRINGS FROM THE LIST OF STRINGS     #
	#---------------------------------------------------#

	def RemoveAllCS(pcStr, pCaseSensitive)
		anPos = This.FindAllCS(pcStr, pCaseSensitive)
		This.RemoveStringsAtThesePositions(anPos)

		def RemoveAllCSQ(pcStr, pCaseSensitive)
			This.RemoveAllCS(pcStr, pCaseSensitive)
			return This

		def RemoveCS(pcStr, pCaseSensitive)
			This.RemoveAllCS(pcStr, pCaseSensitive)

		def RemoveStringCS(pcStr, pCaseSensitive)
			This.RemoveAllCS(pcStr, pCaseSensitive)

		def RemoveAllOccurrencesOfStringCS(pcStr, pCaseSensitive)
			This.RemoveAllCS(pcStr, pCaseSensitive)

	def RemoveAll(pcStr)
		This.RemoveAllCS(pcStr, :CaseSensitive = TRUE)

		def RemoveAllQ(pcStr)
			This.RemoveAll(pcStr)
			return This

		def Remove(pcStr)
			This.RemoveAll(pcStr)

		def RemoveString(pcStr)
			This.RemoveAll(pcStr)

		def RemoveAllOccurrencesOfString(pcStr)
			This.RemoveAll(pcStr)

	  #------------------------------------------#
	 #   REMOVING STRING AT A GIVEN POSITION    #
	#------------------------------------------#

	def RemoveStringAtPosition(n)
		This.QStringListObject().removeAt(n-1)

		def RemoveStringAtPositionQ(n)
			This.RemoveStringAtPosition(n)
			return This

		def RemoveStringAtThisPosition(n)
			This.RemoveStringAtPosition(n)

			def RemoveStringAtThisPositionQ(n)
				This.RemoveStringAtThisPosition(n)
				return This

		def RemoveNth(n)
			This.RemoveStringAtPosition(n)

			def RemoveNthQ(n)(n)
				This.RemoveNth(n)
				return This

	def RemoveFirst()
		This.RemoveStringAtPosition(1)
	
		def RemoveFirstQ()
			This.RemoveFirstString()
			return This

		def RemoveStringAtFirstPosition()
			This.RemoveFirst()

			def RemoveStringAtFirstPositionQ()
				This.RemoveStringAtFirstPosition()
				return This

	def RemoveLast()
		This.QStringListObject().removeLast()

		def RemoveLastQ()
			This.RemoveLastString()
			return This

		def RemoveStringAtLastPosition()
			This.RemoveLast()

			def RemoveStringAtLastPositionQ()
				This.RemoveStringAtLastPosition()
				return This

	  #------------------------------------------#
	 #   REMOVING STRINGS AT GIVEN POSITIONS    #
	#------------------------------------------#

	def RemoveStringsAtPositions(panPositions)
		anPos = sort(panPositions)

		for i = len(anPos) to 1 step -1
			This.RemoveStringAtPosition(anPos[i])
		next

		def RemoveStringsAtThesePositions(panPositions)
			This.RemoveStringsAtPositions(panPositions)

	  #-----------------------------------------------------------------#
	 #    REMOVING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS   #
	#-----------------------------------------------------------------#
	
	def RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)

		anPos = This.FindAllCS(pcStr, pCaseSensitive)
		nPos = anPos[n]

		This.RemoveStringAtPosition(nPos)

		def RemoveNthStringCS(n, pcStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)

		def RemoveNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)

	def RemoveNthOccurrence(n, pcStr)
		This.RemoveNthOccurrenceCS(n, pcStr, :CaseSensitive = TRUE)

		def RemoveNthString(n, pcStr)
			This.RemoveNthOccurrence(n, pcStr)

		def RemoveNthOccurrenceOfString(n, pcStr)
			This.RemoveNthOccurrence(n, pcStr)

	#----

	def RemoveFirstOccurrenceCS(cString, pCaseSensitive)

		bCaseSensitive = TRUE

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			bCaseSensitive = pCaseSensitive[2]
		ok

		if bCaseSensitive
			This.QStringListObject().removeOne(cString)

		else
			nPos = This.FindFirstCS(cString, :CaseSensitive = FALSE)
			This.RemoveStringsAtPosition(nPos)
		ok
		
		def RemoveFirstOccurrenceCSQ(cString, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(cString, pCaseSensitive)
			return This

		def RemoveFirstStringCS(cString, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(cString, pCaseSensitive)

			def RemoveFirstStringCSQ(cString, pCaseSensitive)
				This.RemoveFirstStringCS(cString, pCaseSensitive)
				return This

		def RemoveFirstOccurrenceOfThisStringCS(cString, pCaseSensitive)
			This.RemoveFirstStringCS(cString, pCaseSensitive)

			def RemoveFirstOccurrenceOfThisStringCSQ(cString, pCaseSensitive)
				This.RemoveFirstOccurrenceOfThisStringCS(cString, pCaseSensitive)
				return This

	#----

	def RemoveFirstOccurrence(cString)
		This.RemoveFirstOccurrenceCS(cString, pCaseSensitive)
		
		def RemoveFirstOccurrenceQ(cString)
			This.RemoveFirstOccurrence(cString)
			return This

		def RemoveFirstString(cString)
			This.RemoveFirstOccurrence(cString)

			def RemoveFirstStringQ(cString)
				This.RemoveFirstString(cString)
				return This

		def RemoveFirstOccurrenceOfThisString(cString)
			This.RemoveFirstOccurrence(cString)

			def RemoveFirstOccurrenceOfThisStringQ(cString)
				This.RemoveFirstOccurrenceOfThisString(cString)
				return This

	#----

	def RemoveLastOccurrenceCS(cString, pCaseSensitive)

		bCaseSensitive = TRUE

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			bCaseSensitive = pCaseSensitive[2]
		ok

		if bCaseSensitive
			This.QStringListObject().removeLast(cString)

		else
			nPos = This.FindLastCS(cString, :CaseSensitive = FALSE)
			This.RemoveStringsAtPosition(nPos)
		ok
		
		def RemoveLastOccurrenceCSQ(cString, pCaseSensitive)
			This.RemoveLastOccurrenceCS(cString, pCaseSensitive)
			return This

		def RemoveLastStringCS(cString, pCaseSensitive)
			This.RemoveLastOccurrenceCS(cString, pCaseSensitive)

			def RemoveLastStringCSQ(cString, pCaseSensitive)
				This.RemoveLastStringCS(cString, pCaseSensitive)
				return This

		def RemoveLastOccurrenceOfThisStringCS(cString, pCaseSensitive)
			This.RemoveLastStringCS(cString, pCaseSensitive)

			def RemoveLastOccurrenceOfThisStringCSQ(cString, pCaseSensitive)
				This.RemoveLastOccurrenceOfThisStringCS(cString, pCaseSensitive)
				return This

	#----

	def RemoveLasttOccurrence(cString)
		This.RemoveLastOccurrenceCS(cString, pCaseSensitive)
		
		def RemoveLastOccurrenceQ(cString)
			This.RemoveLastOccurrence(cString)
			return This

		def RemoveLastString(cString)
			This.RemoveLastOccurrence(cString)

			def RemoveLastStringQ(cString)
				This.RemoveLastString(cString)
				return This

		def RemoveLastOccurrenceOfThisString(cString)
			This.RemoveLastOccurrence(cString)

			def RemoveLastOccurrenceOfThisStringQ(cString)
				This.RemoveLastOccurrenceOfThisString(cString)
				return This

	  #---------------------------------------------#
	 #   REMOVING MANY STRINGS AT THE SAME TIME    #
	#---------------------------------------------#

	def RemoveManyStringsCS(paStr, pCaseSensitive)
		if NOT IsListOfStrings(paStr)
			raise("Incorrect param type! You must provide a list of strings.")
		ok

		for str in paStr
			This.RemoveStringCS(str, pCaseSensitive)
		next

		def RemoveManyCS(paStr, pCaseSensitive)
			This.RemoveManyStringsCS(paStr, pCaseSensitive)

		def RemoveTheseStringsCS(paStr, pCaseSensitive)
			This.RemoveManyStringsCS(paStr, pCaseSensitive)

		def RemoveTheseCS(paStr, pCaseSensitive)
			This.RemoveManyStringsCS(paStr, pCaseSensitive)

	def RemoveManyStrings(paStr)
		This.RemoveManyStringsCS(paStr, :CaseSensitive = TRUE)

		def RemoveMany(paStr)
			This.RemoveManyStrings(paStr)

		def RemoveTheseStrings(paStr)
			This.RemoveManyStrings(paStr)

		def RemoveThese(paStr)
			This.RemoveManyStrings(paStr)
*/
	  #-----------------------------------------#
	 #   PERFORMING AN ACTION ON EACH STRING   #
	#-----------------------------------------#

	def ForEachStringPerform(pcCode)
		# Must begin with '@str =" or '@string ='
		/* Example

		o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])
		o1.ForEachStringPerform('{ Q(@str).RemoveQ(".txt").Content() }')

		o1.Content() # ---> [ "village", "town", "country" ]

		*/

		if NOT isString(pcCode)
			raise("Invalid param type! Condition must be a string.")
		ok

		oCode = new stzString(pcCode)
		oCode.ReplaceAllCS("@string", "@str", :CaseSensitive = FALSE)

		if NOT oCode.ContainsCS("@str", :CS = FALSE)
			raise("Incorrect parm! Condition should contain '@str' or '@string'.")
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

			raise("Syntax error! Condition should begin with '@str =' or '@string ='.")
		ok

		@i = 0
		for @str in This.ListOfStrings()
			@i++
			eval(cCode)

			This.ReplaceStringAtPosition(@i, :With = @str )	
		next

		#< @FunctionFluentForm

		def ForEachStringPerformQ(pcCode)
			This.ForEachStringPerform(pcCode)
			return This

		#>

		#< @FunctionAlternativeForm

		def ForEachStringDo(pcCode)
			This.ForEachStringPerform(pcCode)

			def ForEachStringDoQ(pcCode)
				This.ForEachStringDo(pcCode)
				return This

		#>

	def ForEachStringPerformW(pcCode, pcConsition)
		if isList(pcCondition) and Q(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]
		ok

		acStrings = This.StringsW(pcCondition)
		oListOfStrings = new stzListOfStrings(acStrings)

		oListOfStrings.ForEachStringPerform(pcCode)


	def StringsAtPositions(panPositions)
		acResult = This.ToStzList().ItemsAtThesePositions(panPositions)
		return acResult

		def StringsAtThesePositions(panPositions)

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

	def ForEachStringYield(pcCode)
		/* Example

		o1 = new stzListOfStrings([ "village", "town", "country" ])
		o1.ForEachStringYield('[ @str, Q(@str).NumberOfChars()' ])

		o1.Content()
		# ---> [ [ "village", 6 ], [ "town", 4 ], [ "country", 7 ] ]

		*/

		if NOT isString(pcCode)
			raise("Invalid param type! Condition must be a string.")
		ok

		oCode = new stzString(pcCode)
		oCode.ReplaceAllCS("@string", "@str", :CaseSensitive = FALSE)

		if NOT oCode.ContainsCS("@str", :CS = FALSE)
			raise("Incorrect parm! Condition should contain '@str' or '@string'.")
		ok


		cCode = oCode.SimplifyQ().BoundsRemoved("{","}")
		cCode = 'aResult + ( ' + cCode + ' )'

		aResult = []

		for @str in This.ListOfStrings()
			@string = @str
			
			eval(cCode)
		next

		return aResult

		def ForEachStringYieldQ(pcCode)
			return This.ForEachStringYieldQR(pcCode, :stzList)

		def ForEachStringYieldQR(pcCode, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ForEachStringYield(pcCode) )

			on :stzListOfStrings
				return new stzListOfStrings( This.ForEachStringYield(pcCode) )
			
			other
				raise("Unsupported return type!")
			off

		def ForEachStringReturn(pcCode)
			This.ForEachStringYield(pcCode)

			def ForEachStringReturnQ(pcCode)
				return This.ForEachStringYieldQ(pcCode)

				def ForEachStringReturnQR(pcCode, pcReturnType)
					return This.ForEachStringYieldQR(pcCode, pcReturnType)

	  #----------------------------------------------------------#
	 #    REMOVING A SUBSTRING FROM EACH STRING IN THE LIST     #
/*	#----------------------------------------------------------#

	def RemoveFromEach(pcSubStr)
		acResult = []
		for str in This.ListOfStrings()
			acResult + ( Q(str).Remove(n, pcSubStr) )
		next
	
		This.Update( acResult )

		def RemoveFromEachQ(pcSubStr)
			This.RemoveFromEach(pcSubStr)
			return This

		def RemoveAllFromEach(pcSubStr)
			return This.RemoveFromEach(pcSubStr)

			def RemoveAllFromEachQ(pcSubStr)
				This.RemoveAllFromEach(pcSubStr)
				return This

	def RemoveNthFromEach(n, pcSubStr)
		acResult = []
		for str in This.ListOfStrings()
			acResult + ( _@(str).RemoveNth(n, pcSubStr) )
		next
	
		This.Update( acResult )

		def RemoveNthFromEachQ(n, pcSubStr)
			This.RemoveNthFromEach(n, pcSubStr)
			return This

		def RemoveNthOccurrenceFromEach(n, pcSubStr)
			return This.RemoveNthFromEach(n, pcSubStr)

			def RemoveNthOccurrenceFromEachQ(n, pcSubStr)
				This.RemoveNthOccurrenceFromEach(n, pcSubStr)
				return This

	def RemoveFirstFromEach(pcSubStr)
		This.RemoveNthFromEach(1, pcSubStr)

		def RemoveFirstFromEachQ(pcSubStr)
			This.RemoveFirstFromEach(pcSubStr)
			return This

	def RemoveLastFromEach(pcSubStr)
		This.RemoveNthFromEach(:Last, pcSubStr)

		def RemoveLastFromEachQ(pcSubStr)
			This.RemoveLastFromEach(pcSubStr)
			return This
*/
	  #----------------------------------------------------#
	 #    REMOVING STRINGS VERIYING A GIVEN CONDITION     #
	#----------------------------------------------------#

	def RemoveWCS(pcCondition, pValue, pCaseSensitive)
		anPositions = This.FindW(pcCondition, pValue, pCaseSensitive)
		This.RemoveStringsAtThesePositions()

		#< @FunctionAlternativeForms

		def RemoveAllWCS(pcCondition, pValue, pCaseSensitive)
			This.RemoveWCS(pcCondition, pValue, pCaseSensitive)

		def RemoveWhereCS(pcCondition, pValue, pCaseSensitive)
			This.RemoveWCS(pcCondition, pValue, pCaseSensitive)

		def RemoveAllWhereCS(pcCondition, pValue, pCaseSensitive)
			This.RemoveWCS(pcCondition, pValue, pCaseSensitive)

		#>

	def RemoveW(pcCondition, pValue)
		This.RemoveWCS(pcCondition, pValue, :CaseSensitive = TRUE)

		def RemoveAllW(pcCondition, pValue)
			This.RemoveW(pcCondition, pValue)

		def RemoveWhere(pcCondition, pValue)
			This.RemoveW(pcCondition, pValue)

		def RemoveAllWhere(pcCondition, pValue)
			This.RemoveW(pcCondition, pValue)

	  #-----------------#
	 #    DUPLICATES   #
	#-----------------#

	def IsDuplicatedStringCS(pcString, pCaseSensitive)

		if This.NumberOfOccurrenceCS(pcString, pCaseSensitive) > 1
			return TRUE
		else
			return FALSE
		ok

	def IsDuplicatedString(pcString)
		return This.IsDuplicatedStringCS(pcString, :CaseSensitive = TRUE)

	def IsDuplicatedCS(pcString, pCaseSensitive)
		return This.IsDuplicatedStringCS(pcString, pCaseSensitive)

	def IsDuplicated(pcString)
		return This.IsDuplicatedString(pcString)

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

	  #------------------#
	 #     CLEARING     #
	#------------------#

	def Clear()
		This.QStringListObject().clear()

	def ClearQ()
		This.Clear()
		return This

	  #------------------------------#
	 #     NUMBER OF OCCURRENCE     #
	#------------------------------#

	def NumberOfOccurrenceOfString(pcStr)
		return len(This.FindAll(pcStr))

		def NumberOfOccurrencesOfString(pcStr)
			return This.NumberOfOccurrenceOfString(pcStr)

		def NumberOfOccurrence(pcStr)
			return This.NumberOfOccurrenceOfString(pcStr)
	
			def NumberOfOccurrences(pcStr)
				return This.NumberOfOccurrence(pcStr)

	def NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)
		return len(This.FindAllCS(pcStr, pCaseSensitive))

		def NumberOfOccurrencesOfStringCS(pcStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)

		def NumberOfOccurrenceCS(pcStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)
			
			def NumberOfOccurrencesCS(pcStr, pCaseSensitive)
				return This.NumberOfOccurrenceCS(pcStr, pCaseSensitive)

	  #---------------------------------------------------#
	 #     FINDING A SUBSTRING IN THE LIST OF STRINGS    #
	#---------------------------------------------------#

	def FindSubstringCS(pcSubStr, pCaseSensitive)
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

	def FindSubString(pcSubStr)
		return This.FindSubStringCS(pcSubstr, :CaseSensitive = TRUE)

	def FindNthSubstringCS(n, pcSubStr, pCaseSensitive)
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

		if NOT (isNumber(n) and n <= This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive))
			raise("Incorrect param! n must be a number <= number of occurrences of the substring in all the strings.")
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
		

	def PositionsOfSubstringPeleMeleCS(pcSubStr, pCaseSensitive)
		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		aResult = []

		for aPair in aPositionsXT
			anPos = aPair[2]

			for n in anPos	
				aResult + n
			next
		next

		return aResult

	  #-------------------------------------------------------#
	 #     FINDING MANY SUBSTRINGS IN THE LIST OF STRINGS    #
	#-------------------------------------------------------#

	def FindManySubstringsCS(pacSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindAllSubstringsCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 16, 21 ] ]
		*/

		// TODO

	def FindManySubstringsCSXT(pacSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindAllSubstringsCSXT("name", :CaseSensitive = TRUE)
		#--> [
		#	:name = [ "1" = [ 13 ], "3" = [ 6, 21 ] ],
		#	:nice = [ "3" = [ 16 ]
		#    ]
		*/

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			raise("Incorrect param type! You must provide a list of strings.")
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

		#< @FunctionAlternativeForm

		def FindManySubstringsXTCS(pacSubStr, pCaseSensitive)
			return This.FindManySubstringsXTCS(pacSubStr, pCaseSensitive)
		#>

	  #-----------------------------------------------#
	 #     FINDING STRINGS IN THE LIST OF STRINGS    #
	#-----------------------------------------------#

	/*
		BE CAREEFUL: This finds strings as items in the list of strings,
		and not AS SUBSTRINGS inside those items.

		If you want to find substrings that are contained in each string
		of the list, use FindAllSubstrings() instead.
	*/

	def FindNthOccurrence(n, pcString)
		return This.FindNthOccurrenceCS(n, pcString, :CaseSensitive = TRUE)

		def FindNthOccurrenceOfString(n, pcString)
			return This.FindNthOccurrence(n, pcString)

	def FindNthOccurrenceCS(n, pcString, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		nResult = 0

		anPos = This.FindAllCS(pcString, pCaseSensitive)
		return anPos[n]

		return nResult

		def FindNthOccurrenceOfStringCS(n, pcString, pCaseSensitive)
			return This.FindNthOccurrenceCS(n, pcString, pCaseSensitive)

	def FindFirstOccurrence(pcStr)
		return This.FindNthOccurrence(1, pcStr)

		def FindFirstOccurrenceOfString(pcStr)
			return This.FindFirstOccurrence(pcStr)

		def FindFirst(pcStr)
			return This.FindFirstOccurrence(pcStr)

	def FindFirstOccurrenceCS(pcStr, pCaseSensitive)
		return This.FindNthOccurrenceCS(1, pcStr, pCaseSensitive)

		def FindFirstOccurrenceOfStringCS(pcStr, pCaseSensitive)
			return This.FindFirstOccurrenceCS(pcStr, pCaseSensitive)

		def FindFirstCS(pcStr, pCaseSensitive)
			return This.FindFirstOccurrenceCs(pcStr, pCaseSensitive)
	
	def FindLastOccurrence(pcStr)
		return This.FindLastOccurrenceCS(pcStr, :CaseSensitive = TRUE)

		def FindLastOccurrenceOfString(pcStr)
			return This.FindLastOccurrence(pcStr)

		def FindLast(pcStr)
			return This.FindLastOccurrence(pcStr)

	def FindLastOccurrenceCS(pcStr, pCaseSensitive)
		aPos = This.FindAllCS(pcStr, pCaseSensitive)
		return aPos[ len(aPos) ]

		def FindLastOccurrenceOfStringCS(pcStr, pCaseSensitive)
			return This.FindLastOccurrenceCS(pcStr, pCaseSensitive)

		def FindLastCS(pcStr, pCaseSensitive)
			return This.FindLastOccurrenceCS(pcStr, pCaseSensitive)
	
	def FindAll(pcStr)
		return This.FindAllCS(pcStr, :CaseSensitive = TRUE)

		def FindAllOccurrences(pcStr)
			if isList(pcStr) and StzListQ(pcStr).IsOfParamList()
				pcStr = pcStr[2]
			ok

			return This.FindAllCS(pcStr, :CaseSensitive = TRUE)

		def FindAllOccurrencesOfString(pcStr)
			return This.FindAllCS(pcStr, :CaseSensitive = TRUE)

		def FindAllOccurrencesOf(pcStr)
			return This.FindAllCS(pcStr, :CaseSensitive = TRUE)

		def FindString(pcStr)
			return This.FindAllCS(pcStr, :CaseSensitive = TRUE)

	def FindAllCS(pcStr, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		anResult = []

		if pCaseSensitive = TRUE

			anResult = This.ToStzList().FindAll(pcStr)

		else
			acList = This.Lowercased()
			cStr = StzStringQ(pcStr).Lowercased()

			anResult = StzListQ(acList).FindAll(cStr)
		ok

		return anResult

		#< @FunctionFluentForm

		def FindAllCSQ(pcStr, pCaseSensitive)
			return new stzList( This.FindAllCS(pcStr, pCaseSensitive) )

		#>

		#< @FunctionAlternativeFormForms

		def FindAllOccurrencesCS(pcStr, pCaseSensitive)
			return This.FindAllCS(pcStr, pCaseSensitive)

		def FindAllOccurrencesOfCS(pcStr)
			return This.FindAllCS(pcStr, pCaseSensitive)

		def FindAllOccurrencesOfStringCS(pcStr)
			return This.FindAllCS(pcStr, pCaseSensitive)

		def FindStringCS(pcStr, pCaseSensitive)
			return This.FindAllCS(pcStr, pCaseSensitive)
		#>
################################""
	def FindAllExceptFirstCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(2, :End)

	def FindAllExceptFirstCSQ(pcStr, pCaseSensitive)
		return new stzList( This.FindAllExceptFirstCS(pcStr, pCaseSensitive) )

	def FindAllExceptLastCS(pcStr, pCaseSensitive)
		return This.FindAllCSQ(pcStr, pCaseSensitive).Section(1, This.NumberOfStrings()-1 )

	def FindAllExceptLastCSQ(pcStr, pCaseSensitive)
		return new stzList( This.FindAllExceptLastCS(pcStr, pCaseSensitive) )

	def FindAllExceptNthCS(pcStr, n, pCaseSensitive)
		aResult = []

		if n = :First
			n = 1

		but n = :Last
			n = This.NumberOfOccurrenceCS(pcStr, pCaseSensitive)
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
########################
	  #------------------------------------------------#
	 #      FINDING MANY STRINGS IN THE SAME TIME     # 
	#------------------------------------------------#

	def FindManyStringsCS(pacStrings, pCaseSensitive)
		/*
		o1 = new stzListOfStrings([
			"My name is Mansour. What's your name please?",
			"Your name and my name are not the same.",
			"Please feel free to call me with any name!"
		])

		? o1.FindManyStringsCS( [ "name", "your", "please" ], :CS = TRUE )

		# --> [ 4, 33, 28, 38 ]
		*/

		aResult = []

		for str in pacStrings
			aResult + This.FindStringCS(str, pCaseSensitive)
		next

		aResult = StzListQ(aResult).FlattenQ().SortInAscendingQ().Content()

		return aResult

	def FindManyStrings(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindMany( [ "name", "your", "please" ] )

		# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

		*/

		return This.FindManyStringsCS(pacSubStr, :CaseSensitive = TRUE)

	def FindManyStringsCSXT(pacSubStr, pCaseSensitive)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyCSXT( [ "name", "your", "please" ], :CS = TRUE )

		--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

		*/

		aResult = []

		for str in pacSubStr
			aResult + [ str, This.FindStringCS(str, pCaseSensitive) ]
		next

		return aResult

	def FindManyStringsXT(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyXT( [ "name", "your", "please" ] )

		--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

		*/

		return This.FindManyStringsCSXT(pacSubStr, :CaseSensitive = TRUE)

	#---------------------------------------#
	# TODO: Add same functions as stzString # Support Case sensisitivity!
	#---------------------------------------#
	
	/*
	
	FINDING THE "NTH" OCCURRENCE OF A STRING IN THE LIST
		FINDDING FIRST OCCURRENCE OF A STRING IN THE LIST
		FINDING LAST OCCURRENCE OF A STRING IN THE LIST
	
	FINDNING NEXT "NTH" OCCURRENCE A STRING IN THE LIST STARTING AT
		FINDNING NEXT OCCURRENCE A STRING IN THE LIST STARTING AT
	
	FINDING PREVIOUS "NTH" OCCURRENCE A STRING IN THE LIST STARTING AT
		FINDING PREVIOUS OCCURRENCE A STRING IN THE LIST STARTING AT
	*/

	  #----------------------------------------#
	 #     STRINGS CONTAINING A SUBSTRING     #
	#----------------------------------------#

	def StringsContaining(pcSubStr)
		oQList = This.QStringListObject().filter(pcSubStr, 0)
		return QStringListContent(oQList)

	def StringsContainingCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok
			 
		if isNumber(pCaseSensitive) and ( pCaseSensitive = 0 or pCaseSensitive = 1 )

			oQList = This.QStringListObject().filter(pcSubStr, pCaseSensitive)
			return QStringListContent(oQList)

		else
			raise("Incorrect param! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
		ok

	  #------------------#
	 #     INDEXING     # TODO: CaseSensitivity!
	#------------------#

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

	  #-------------------------------#
	 #     UNIQUE & COMMON CHARS     #
	#-------------------------------#

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
		return new stzListOfChars( This.UniqueChars() )

	def CommonChars()
		aResult = []

		for c in This.UniqueChars()
			if This.ContainsSubstring_InEachString(c)
				aResult + c
			ok
		next

		return aResult

	def CommonCharsQ()
		return new stzListOfChars( This.CommonChars() )

	def CommonCharsQR(pcReturnType)
		switch pcReturnType
		on :stzList
			return new stzList( This.Commonchars() )
		on :stzListOfChars
			return new stzListOfChars( This.CommonChars() )
		on :stzListOfStrings
			return new stzListOfStrings( This.CommonChars() )
		other
			raise("Unsupported return type!")
		off

	  #----------------------------------------------------------------#
	 #   NUMBER OF OCCURRENCE OF A SUBSTRING IN THE LIST OF STRINGS   #
	#----------------------------------------------------------------#

	def NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
		n = 0

		for oStzStr in This.ToListOfStzStrings()
			n += oStzStr.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		next

		return n

		def NumberOfOccurrencesOfSubstringCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)

	def NumberOfOccurrenceOfSubstring(pcSubStr)
		return This.NumberOfOccurrenceOfSubstringCS(pcSubStr, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfSubstring(pcSubStr)
			return This.NumberOfOccurrenceOfSubstring(pcSubStr)

	def NumberOfOccurrenceOfManySubstringsCS(pacSubStr, pCaseSensitive)

		if NOT StzListQ(paSubStr).IsListOfStrings()
			raise("Syntax Error: 1st param must be a list of strings!")
		ok

		aResult = []

		for cSubStr in pacSubstr

			aResult + [ cSubStr,
			This.NumberOfOccurrenceOfSubstringCS(cSubStr, pCaseSensitive) ]
		next

		return aResult

		def NumberOfOccurrencesOfManySubstringsCS(pacSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceOfManySubstringsCS(pacSubStr, pCaseSensitive)

	def EachStringContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
		bResult = TRUE

		for oStr in This.ToListOfStzStrings()

			if NOT oStr.ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def EachStringContainsNTimesTheSubstring(n, pcSubStr)
		return This.EachStringContainsNTimesTheSubstringCS(n, pcSubstr, :CaseSensitive = TRUE)

	  #--------------------------#
	 #     CONTAINING CHARS     #
	#--------------------------#

	def ContainsCharInEachString(pcChar)
		if NOT StringIsChar(pcChar)
			raise("The value you provided is not a char!")
		ok

		bResult = TRUE

		aTempList = This.ToListOfStzStrings()
		for oStzStr in aTempList
			if NOT oStzStr.Contains(pcChar)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsChar(pcChar)
		return This.ContainsCharInEachString(pcChar)

	def NumberOfOccurrenceOfChar(pcChar)
		if NOT StringIsChar(pcChar)
			raise("The value you provided is not a char!")
		ok

		n = 0

		for oStzStr in This.ToListOfStzStrings()
			n += oStzStr.NumberOfOccurrence(pcChar)
		next

		return n

	def NumberOfOccurrenceOfManyChars(pacChars)
		if NOT ListIsListOfChars(pacChars)
			raise("The list you provided is not a list of chars!")
		ok

		aResult = []

		for cChar in pacChars

			aResult + [ cChar,
			This.NumberOfOccurrenceOfChar(cChar) ]
		next

		return aResult

	def EachStringContainsNTimesTheChar(n, pcChar)
		bResult = TRUE

		for oStr in This.ToListOfStzStrings()

			if NOT oStr.ContainsNTimes(n, pcChar)
				bResult = FALSE
				exit
			ok
		next

		return bResult
	
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

			raise(stzListOfStringsError(:paBoxOptions))
		ok		

		def BoxXTQ(paBoxOptions)
			return new stzListOfStrings(This.BoxXT(paBoxOptions))

		def BoxedXT(paBoxOptions)
			return This.BoxXTQ(paBoxOptions).Content()
	
	  #-------------------#
	 #     JUSTIFYING    #
	#-------------------#

	// TODO

	def Jusify()

	  #---------------------#
	 #     COMBINATIONS    #
	#---------------------#

	def NumberOfCombinations()
		return len(This.Combinations()) # TODO: solve it mathematically.
	
	def Combinations()
	
		if This.NumberOfStrings() < 2
			raise("Can't compute combinations for that list!")
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
	TODO: Add SplitXT() and other staff available in stzString
	*/

	def Split(cSep)
		aResult = []
	
		for oStr in This.ToListOfStzStrings()
			aResult + oStr.Split(cSep)
		next

		return aResult

		#< @FunctionFluentForm

		def SplitQ(cSep)
			return new stzListOfLists( This.Split(cSep) )

		def SplitQR(cSep, pcReturnType)
			switch pcReturnType
			on :stzListOfLists
				return new stzListOfLists( This.Split(cSep) )

			on :stzList
				return new stzList( This.Split(cSep) )

			other
				raise("Unsupported type!")
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
			raise("Incorrect param types!")
		ok

		#< @FunctionFluentForm

		def NthSubstringsQ(n, acSep)
			return new stzListOfStrings( This.NthSubstrings(n, acSep) )

		#>

	  #------------------------------#
	 #    SIMPLIFYING EACH STRING   #
	#------------------------------#

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
			switch pcReturnType
			on :stzListOfUnicodes
				return new stzListOfUnicodes( This.Unicodes() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Unicodes() )
			on :stzListOfLists
				return new stzListOfLists( This.Unicodes() )
			other
				raise("Unsupported return type!")
			off
				
		def UnicodesQ()
			return This.UnicodesQR(:stzListOfUnicodes)

		#>

	  #-----------------------------#
	 #    SCRIPTS OF ALL STRINGS   #
	#-----------------------------#

	def Scripts()
		acResult = []

		for str in This.ListOfStrings()
			acResult + StzStringQ(str).Script()
		next

		return acResult


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

	  #------------------------------#
	 #     OPERATORS OVERLOADING    # TODO: Test it!
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

					raise(stzListError(:UnsupportedExpressionInOverloadedMinusOperator))
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
						raise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterThan
						raise(:UnsupportedFeatureInThisVersion)

					but cCondition = :LesserOrEqualThan
						raise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterOrEqualThan
						raise(:UnsupportedFeatureInThisVersion)

					but cCondition = :DifferentThan
						raise(:UnsupportedFeatureInThisVersion)
					
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
						raise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :GreaterThan
						raise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :LesserOrEqualThan
						raise(stzListError(:UnsupportedFeattureInThisVersion))

					but cCondition = :GreaterOrEqualThan
						raise(stzListError(:UnsupportedFeattureInThisVersion))
					
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

	  #----------------------------------------#
	 #    FILTERING THE STRINGS Of THE LIST   #
	#----------------------------------------#

	def Filter(pcSubStr)
		if isList(pcSubStr) and
		     (  Q(pcSubStr).IsUsingParamList() or
			Q(pcSubStr).IsWithParamList() or
			Q(pcSubStr).IsOnParamList() or
			Q(pcSubStr).IsByParamList() )

			pcSubStr = pcSubstr[2]
		ok

		acResult = This.QStringListObject().filer(pcSubStr, pCaseSensitive)


