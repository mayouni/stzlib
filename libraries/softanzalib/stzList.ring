# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing softanza lists        #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzListQ(paList)
	return new stzList(paList)

func IsNotList(paList)
	return NOT isList(paList)

func ListIsListOfStzNumbers(paList)
	return StzListQ(paList).IsListOfStzNumbers()

func ListIsListOfStzStrings(paList)
	return StzListQ(paList).IsListOfStzStrings()

func ListIsListOfStzLists(paList)
	return StzListQ(paList).IsListOfStzLists()

func ListIsListOfStzObjects(paList)
	return StzListQ(paList).IsListOfStzObjects()

func ListReverse(paList)
	return reverse(paList) # Here we rely on the native Ring reverse() function

func ListFirstItem(paList)
	return paList[1]

	#< @AlternativeFunctionNames

	func FirstItemInList(paList)
		return ListFirstItem(paList)

	#>

func ListLastItem(paList)
	return paList[ len(paList) ]

	#< @AlternativeFunctionNames

	func LastItemInList(paList)
		return ListLastItem(paList)

	#>

func UpdateLastItem(paList, pValue)
	oTempList = new stzList(paList)
	return oTempList.UpdateLastItem(pValue)

func LastItemIn(paList)
	return paList( len(paList) )

func FirstListIn(paList)
	oTempList = new stzList(paList)
	return LastItemIn( oTempList.WalkUntilItemIsList() )

func GenerateListAccessCode_FromNameAndPath(pcListName, paPath)
	// Warining: aPath must contain only numbers!!!
	cCode = pcListName
	for n in paPath
		cCode += ("["+ n + ']')
	next

	return cCode
		
func ListIsSet(paList)
	oList = new stzList(paList)
	return oList.IsSet()

func ListIsListOfNumbers(paList)
	return StzListQ(paList).IsListOfNumbers()

func ListItemsAreAllStrings(paList)
	oTempList = new stzList(paList)
	return oTempList.ItemsAreAllStrings()

func ListIsHashList(paList)
	oTempList = new stzList(paList)
	return oTempList.IsHashList()

func ListIsListOfLists(paList)
	return StzListQ(paList).IsListOfLists()

func ListIsListOfSets(paList)
	return StzListQ(paList).IsListOfSets()



func ListIsListOfLetters(paList)
	return StzListQ(paList).IsListOfLetters()

func ListIsListOfHashLists(paList)
	return StzListQ(paList).IsListOfHashLists()

func ListIsListOfZerosAndOnes(paList)
	return StzListQ(paList).IsListOfZerosAndOnes()

func ListIsLocaleList(paList)
	return StzListQ(paList).IsLocaleList()

func CallMethod( pcMethod, paOnObjects )

	if NOT ( paOnObjects[1] = "on" and StzListQ(paOnObjects[2]).IsListOfStrings() )
		stzRaise(stzObjectError(:CanNotProcessMethodCall))
	ok

	aResult = []
	for cObjName in paOnObjects[2]
		cCode = "aResult + " + cObjName + "." + pcMethod
		eval(cCode)
	next
	return aResult

def AreChars(paChars)
	bResult = TRUE
	for c in paChars
		if NOT isString(c) and StringIsChar(c)
			bResult = FALSE
			exit
		ok
	next
	return bResult

func AreBothChars(p1, p2)
	return AreChars([ p1, p2 ])

	func BothAreChars(p1, p2)
		return AreBothChars(p1, p2)
	
func AreBothAsciiChars(p1, p2)
	if IsAsciiChar(p1) and IsAsciiChar(p2)
		return TRUE
	else
		return FALSE
	ok

	func BothAreAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

func AreBothEqual(p1, p2)
	return AreEqual([ p1, p2 ])

	func BothAreEqual(p1, p2)
		return AreEqual([ p1, p2 ])
	
		def BothAreNotEqual(p1, p2)
			return NOT BothAreEqual(p1, p2)

func AreEqual(paItems)
	return StzListQ(paItems).NumberOfOccurrence(paItems[1]) = len(paItems)

func HaveSameType(paItems)
	bResult = TRUE
	for i = 2 to len(paItems)
		if type( paItems[i] ) != type( paItems[i] )
			bResult = FALSE
			exit
		ok
	next
	return bResult

func BothHaveSameType(p1, p2)
	return type(p1) = type(p2)

func HaveSameContent(paItems) // TODO
	/* Two items have same content when:
	 if they are stringified they are equal strings.

	Stringifying number 12 generate string "12"
	

	*/

func HaveBothSameType(p1, p2)
	return type(p1) = type(p2)

func IsEmptyList(paList)
	return StzListQ(paList).IsEmpty()
		

func ListShow(paList)
	StzListQ(paList).Show()

func AreNumbers(paList)
	return StzListQ(paList).ContainsOnlyNumbers()

func AreStrings(paList)
	return StzListQ(paList).ContainsOnlyStrings()

func AreLists(paList)
	return StzListQ(paList).ContainsOnlyLists()

func AreObjects(paList)
	return StzListQ(paList).ContainsOnlyObjects()

func ListIsListOfStrings(paList)
	return StzListQ(paList).IsListOfStrings()

	func IsListOfStrings(paList)
		return ListIsListOfStrings(paList)

func IsRangeParamList(paList)
	return StzListQ(paList).IsRangeParamList()

	func ListIsRangeParamList(paList)
		return This.IsRangeParamList(paList)

func ListToCode(paList)
	return StzListQ( paList ).ToCode()

func List(paList)
	if isList(paList)
		return paList
	ok

func AllTheseAreNull(paList)
	return StzListQ(paList).AllItemsAreNull()

	func AllOfTheseAreNull(paList)
		return AllTheseAreNull(paList)

	func TheseAreNull(paList)
		return AllTheseAreNull(paList)

func AllOfTheseAreNotNull(paList)
	bResult = TRUE
	for item in paList
		if isString(item) and isNull(item)
			bResult = FALSE
			exit
		ok
	next

	return bResult

	func NoOneOfTheseIsNull(paList)
		return AllOfTheseAreNotNull(paList)

	func TheseAreNotNull(paList)
		return AllOfTheseAreNotNull(paList)

func BothAreNull(p1, p2)
	return TheseAreNull([ p1, p2 ])

func BothAreNotNull(p1, p2)
	return TheseAreNotNull([ p1, p2 ])

func AllTheseAreStrings(paList)
	return StzListQ(paList).AllItemsAreStrings()

	func AllOfTheseAreStrings(paList)
		return AllTheseAreStrings(paList)

	func TheseAreStrings(paList)
		return AllTheseAreStrings(paList)

func NoOneOfTheseIsAString(paList)
	bResult = TRUE
	for item in paList
		if isString(item)
			bResult = FALSE
			exit
		ok
	next
	
	return bResult


func List@(paList)
	if isList(paList)
		return ComputableForm(paList)
	ok

func ListFindAll(paList, p)
	return StzListQ(paList).FindAll(p)

func ListOfNTimes(n, pItem)
	aResult = []
	for i = 1 to n
		aResult + pItem
	next
	return aResult

func ContiguousListOfChars(cChar1, cChar2)
	anUnicodes = []
	for i = CharUnicode(cChar1) to CharUnicode(cChar2)
		anUnicodes + i
	next

	aResult = []

	if StzListOfNumbersQ(anUnicodes).IsContiguous()

		for n in anUnicodes
			aResult + StzCharQ(n).Content()
		next
	
		return aResult

	else
		stzRaise( "The chars you privided don't form a contiguous list!")
	ok

	func ContiguousList(cChar1, cChar2)
		return ContinuousListOfChars(cChar1, cChar2)

	func ContinuousListOfChars(cChar1, cChar2)
		return ContiguousListOfChars(cChar1, cChar2)

	func ContinuousList(cChar1, cChar2)
		return ContiguousList(cChar1, cChar2)

func @C(pList)

	if isString(pList) and StzStringQ(pList).IsListInShortForm()
		aResult = StzStringQ(pList).ToList()
		return aResult

	else
		stzRaise("Can't process the param you provided! It must be list in string in _:_ form.")
	ok

  /////////////////
 ///   CLASS   ///
/////////////////

class stzList from stzObject
	@aContent = []

	@aWalkers = []

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(paList)
		if isList(paList)
			@aContent = paList

		but isString(paList) and StzStringQ(paList).IsListInString()
			@aContent = StzStringQ(paList).ToList()

		else
			stzRaise("Can't create the stzList object!")
		ok

	def IsAList()
		return TRUE

	  #---------------------#
	 #     CONSTRAINTS     #
	#---------------------#
	// TODO: Finish stzConstraint --> Finsh Constraints section here and
	// in other classes (StzString...)
/*
	def MustBe(pcIsMethod)


	def CanNotBe(pcIsMethod)
*/

	  #-----------------#
	 #     GENERAL     #
	#-----------------#

	def Content()
		return @aContent

	def List()
		return Content()

	def Copy()
		return new stzList( This.List() )

	def ReversedCopy()
		return This.ReverseQ()

	def NumberOfItems()
		return len(This.Content())

		def NumberOfItemsQ()
			return new stzNumber(This.NumberOfItems())

		def Size()
			return This.NumberOfItems()
	
	def Items()
		return This.Content()

		#< @FunctionFluentForm

		def ItemsQ()
			return This

		#>

	def Item(n)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[n]

		def ItemQ(n)
			return Q(This.Item(n))

		#< @AlternativeFunctionNames

		def NthItem(n)
			return This.Item(n)

			def NthItemQ(n)
				return Q(This.NthItem(n))

		def ItemAtPosition(n)
			return This.Item(n)

		def ItemAt(n)
			return This.Item(n)

		#>

	def FirstItem()
		return This.NthItem(1)

		def FirstItemQ()
			return Q(This.FirstItem())

	def LastItem()
		return This.NthItem( This.NumberOfItems() )

		def LastItemQ()
			return Q(This.LastItem())
		
	def CentralPosition()
		oTemp = new stzNumber( (This.NumberOfItems()/2) )
		n = oTemp.IntegerPartValue()
		return n

		def CentralItemPosition()
			return This.CentralPosition()

	def CentralItem()
		return This[CentralPosition()]

		def CentralItemQ()
			return Q(This.CentralItem())

	def HasCentralItem()
		return This.NumberOfItemsQ().IsNotEven()

	def NfirstItems(n)
		return This.Section(1, n)
		
		def NFirstItemsQ(n)
			return new stzList( This.NLastItems(n) )

		def FirstNItems(n)
			return This.NFirstItems(n)

			def FirstNItemsQ(n)
				return This.NFirstItemsQ(n)

	def NLastItems(n)
		return This.Section( This.NumberOfItems() - n + 1, :LastItem)

		def NLastItemsQ(n)
			return new stzList( This.NLastItems(n) )

		def LastNItems(n)
			return This.NLastItems(n)

			def LastNItemsQ(n)
				return This.NLastItemsQ(n)


	  #--------------------#
	 #      UPDATING      #
	#--------------------#

	/*
	Semantic Note:
		Update	-> Assigning a hole new list to the list
		Replace	-> Replacing items or sections of items
	*/

	def Update(paNewList)
		if isList(paNewList) and
		   ( StzListQ(paNewList).IsWithParamList() or StzListQ(paNewList).IsUsingParamList() )

			paNewList = paNewList[2]

		ok

		@aContent = paNewList

		#< @FunctionAlternativeForm

		def UpdateWith(paNewList)
			This.Update(paNewList)

		#>

	def UpdateQ(paNewList)
		This.Update(paNewList)
		return This

		#< @FunctionAlternativeForm

		def UpdateWithQ(paNewList)
			return This.UpdateQ(paNewList)

		#>

	  #----------------------#
	 #     ADDING ITEMS     #
	#----------------------#

	def SetNumberOfItems(n)
		nCurrentLen = This.NumberOfItems()
		nNewLen = n

		aResult = []
		if nNewLen = nCurrentLen
			// Do nothing

		but nNewLen > nCurrentLen
			This.AddItemAt(n)

		but nNewLen < nCurrentLen
			This.Section(1, nNewLen)
		ok

		#< @FunctionFluentForm

		def SetNumberOfItemsQ(n)
			This.SetNumberOfItems(n)
			return This

		#>

	def AddItem(pItem)
		@aContent + pItem

		#< @FunctionAlternativeForm

		def Add(pItem)
			This.AddItem(pItem)

		#>

	def AddItemQ(pItem)
		This.AddItem(pItem)
		return This

		#< @FunctionFluentForm

		def AddQ(pItem)
			This.Add(pItem)
			return This

		#>

	def AddItemAt(n, pItem)

		aResult = []
		// Items can be added only at a position bigger then NumberOfItems()
		if n < This.NumberOfItems() + 1
			stzRaise("Can't add the item at this position! n must be bigger than NumberOfItems()")
		else
			/*
			If we want to add an item at a position bigger then NumberOfItems()
			then the list is extended and the positions in between are filled
			with NULL or 0s, depending on wether the list IsHybrid() or it
			ContainsOnlyNumbers()
			*/
			aResult = This.ExtendtoPositionQ(n).Content()
			aResult + pItem
		ok

		This.Update( aResult )

		#< @FunctionFluentForm

		def AddItemAtQ(n, pItem)
			This.AddItem(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForms

		def AddItemAtPosition(n, pItem)
			This.AddItemAt(n, pItem)

			def AddItemAtPositionQ(n, pItem)
				This.AddItemAtPosition(n, pItem)
				return This

		def AddAt(n, pItem)
			This.AddItem(n, pItem)

			def AddAtQ(n, pItem)
				This.AddAt(n, pItem)
				return This
	
		def AddAnNthItem(n, pItem)
			This.AddItem(n, pItem)

			def AddAnNthItemQ(n, pItem)
				This.AddAnNthItem(n, pItem)
				return This

		#>

	  #----------------------------------------------------#
	 #     INSERTING AN ITEM BEFORE A GIVEN POSITION      #
	#----------------------------------------------------#

	def InsertBeforePosition(n, pItem)
		if n >= 1 and n <= This.NumberOfItems()
			insert(This.List(), n-1, pItem)

		but n > This.NumberofItems()
			This.ExtendToN(n)
			insert(This.List(), n-1, pItem) # Using Ring native insert function here
		ok

		#< @FunctionFluentForm

		def InsertBeforePositionQ(n, pItem)
			This.InsertBeforePosition(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertBefore(n, pItem)
			This.InsertBeforePosition(n, pItem)

			def InsertBeforeQ(n, pItem)
				This.InsertBefore(n, pItem)
				return This
		#>
		
	  #----------------------------------------------------#
	 #     INSERTING AN ITEM BEFORE A GIVEN POSITION      #
	#----------------------------------------------------#

	def InsertAfterPosition(n, pItem)

		if n > 0 and n < This.NumberOfItems()
			insert(This.List(), n, pItem)

		ok

		#< @FunctionFluentForm

		def InserAfterPositionQ(n, pItem)
			This.InsertAfterPosition(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertAfter(n, pItem)
			This.InsertAfterPosition(n, pItem)

			def InsertAfterQ(n, pItem)
				This.InsertAfter(n, pItem)
				return This

		#>

	#---------------------------------------#
	# TODO: Add same functions as stzString #
	#---------------------------------------#
	
	/*
	INSERTING BEFORE/AFTER THE NTH OCCURRENCE OF AN ITEM
		INSERTING BEFORE/AFTER THE FIRST OCCURRENCE OF AN ITEM
		INSERTING BEFORE/AFTER THE LAST OCCURRENCE OF AN ITEM
	
	INSERTING BEFORE THE NEXT NTH OCCURRENCE OF AN ITEM STARTING AT
		INSERTING BEFORE/AFTER THE NEXT OCCURRENCE OF AN ITEM STARTING AT
	
	INSERTING BEFORE THE PREVIOUS NTH OCCURRENCE OF AN ITEM STARTING AT
		INSERTING BEFORE/AFTER THE PREVIOUS OCCURRENCE OF AN ITEM STARTING AT
	*/

	  #--------------------------------#
	 #     OTHER INSERTING FORMS      # TODO
	#--------------------------------#

	def InsertAfterEachNumberOfSteps(n, pcStr) // TODO
		/* Example : InsertAfterEachNumberOfSteps(2, "*")
		a = [ "A" , "B" , "C"  , "D" , "E" , "F" , "G" ]
		-->
		a = [ "A" , "B" , "*" , "D" , "E" , "*" , "F" , "G" ]
		*/

	def InsertAfterEachSequenceOfSteps(paSteps, pcStr) // TODO
		/* Example : InsertAfterEachSequenceOfSteps([2,1], pcStr)
		a = [ "A" , "B" , "C"  , "D" , "E" , "F" , "G" ]
		-->
		a = [ "A" , "B" , "*" , "D" , "*" "E" , "F" , "*" , "G" , "*" ]
		*/

	def InsertRandomlyBefore(pcSubStr)
		n = random( This.NumberOfChars() )
		This.InsertBefore(n, pcSubStr)

		#< @FunctionFluentForm

		def InsertRandomlyBeforeQ(pcSubStr)
			This.InsertRandomlyBefore(pcSubStr)
			return This

		#>

	def InsertRandomlyAfter(pcSubStr)
		n = random( This.NumberOfChars() )
		This.InsertAfter(n, pcSubStr)

		#< @FunctionFluentForm

		def InsertRandomlyAfterQ(pcSubStr)
			This.InsertRandomlyAfter(pcSubStr)
			return This

		#>

	  #---------------------------#
	 #      REPLACING ITEMS      #
	#---------------------------#

	/* TODO: content of this section should be reorganized to
	   reflect this structure (same should be done in Remove section):

	REPLACING AN ITEM (OR MANY ITEMS)
		BY SPECIFYING ITS (OR THEIR) VALUE(S)
	
		BY SPECIFYING ITS (OR THEIR) POSITION(S) IN THE LIST
	
	REPLACING NTH OCCURRENCE (OR MANY NTH OCCURRENCES) OF AN ITEM
		BY SPECIFYING THIS NTH OCCURRENCE (OR THESE NTH OCCURRENCES)
		AND THE VALUE OF THAT ITEM
	
	REPLACING A SECTION (OR MANY SECTIONS) OF THE LIST
		BY SPECIFYING ITS (OR THEIR) START AND END POSITIONS
	
	REPLACING A RANGE (OR MANY RANGES OF THE LIST)
		BY SPECIFYING ITS (OR THEIR) START AND RANGE
	
	REPLACING ITEMS UNDER A GIVEN CONDITION
	
	REMOVING ALL ITEMS OF THE LIST (--> EMPTY LIST)

	*/

	//>>>>>>> REPLACING ALL ITEMS OR SOME OCCURRENCES OF AN ITEM

	def ReplaceAllItems(pNewItem)
		if isList(pNewItem) and
		   ( StzListQ(pNewItem).IsWithParamList() or StzListQ(pNewItem).IsByParamList() )
			pNewItem = pNewItem[2]
		ok

		for item in This.List()
			item = pItem
		next

	def ReplaceAllOccurrencesOfItem(pItem, pNewItem)
			
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		anPositions = This.FindAll(pItem)

		for n in anPositions
			This.ReplaceItemAtPosition(n, pNewItem)
		next

		def ReplaceAllOccurrencesOfItemQ(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)
			return This

		def ReplaceItem(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)

			def ReplaceItemQ(pItem, pNewItem)
				This.ReplaceItem(pItem, pNewItem)
				return This

		def ReplaceOccurrences(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)

			def ReplaceOccurrencesQ(pItem, pNewItem)
				This.ReplaceOccurrences(pItem, pNewItem)
				return This

		def ReplaceAllOccurrences(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)

			def ReplaceAllOccurrencesQ(pItem, pNewItem)
				This.ReplaceAllOccurrences(pItem, pNewItem)
				return This

		def ReplaceAll(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)

			def ReplaceAllQ(pItem, pNewItem)
				This.ReplaceAll(pItem, pNewItem)
				return This

		def Replace(pItem, pNewItem)
			This.ReplaceAllOccurrencesOfItem(pItem, pNewItem)

			def ReplaceQ(pItem, pNewItem)
				This.Replace(pItem, pNewItem)
				return This

	def ItemReplacedBy(pItem, pNewItem)
		aResult = This.Copy().ReplaceItemQ(pItem, pNewItem).Content()
		return aResult

		def AllOccurrencesOfItemReplacedBy(pItem, pNewItem)
			return ItemReplacedBy(pItem, pNewItem)

	//>>>>>>> REPLACING MANY ITEMS AT THE SAME TIME

	def ReplaceManyItems(paItems, pNewItem)

		for item in paItems
			This.ReplaceAllOccurrences(:Of = item, :With = pNewItem)
		next

		def ReplaceManyItemsQ(paItems, pNewItem)
			This.ReplaceManyItems(paItems, pNewItem)
			return This

		def ReplaceMany(paItems, pNewItem)
			This.ReplaceManyItems(paItems, pNewItem)

			def ReplaceManyQ(paItems, pNewItem)
				This.ReplaceMany(paItems, pNewItem)
				return This

		def ReplaceAllOfThese(paItems, pNewItem)
			This.ReplaceManyItems(paItems, pNewItem)

			def ReplaceAllOfTheseQ(paItems, pNewItem)
				This.ReplaceAllOfThese(paItems, pNewItem)
				return This

		def ReplaceTheseItems(paItems, pNewItem)
			This.ReplaceManyItems(paItems, pNewItem)

			def ReplaceTheseItemsQ(paItems, pNewItem)
				This.ReplaceTheseItems(paItems, pNewItem)
				return This

	def ManyItemsReplaced(paItems, pNewItem)
		aResult = This.Copy().ReplaceTheseItemsQ(paItems, pNewItem).Content()
		return aResult

		def TheseItemsReplaced(paItems, pNewItem)
			return This.ManyItemsReplaced(paItems, pNewItem)
		
	def ReplaceManyItemsXT(paItems, paListOfNewItems)
		
		if isList(paItems) and StzListQ(paItems).IsOfParamList()
			paItems = paItems[2]
		ok

		if isList(paListOfNewItems) and
		   ( StzListQ(paListOfNewItems).IsWithParamList() OR
		     StzListQ(paListOfNewItems).IsByParamList() )

			paListOfNewItems = paListOfNewItems[2]
		ok

		if IsNotList(paItems) and isList(paListOfNewItems)
			This.ReplaceItemByAlternance(paItems, paListOfNewItems)

		else
			for i = 1 to len(paItems)
				if i <= len(paListOfNewItems)
					This.ReplaceAllOccurrences(paItems[i], paListOfNewItems[i])
				ok
			next
		ok

		def ReplaceManyItemsXTQ(paItems, paListOfNewItems)
			This.ReplaceManyXT(paItems, paListOfNewItems)
			return This

		def ReplaceManyXT(paItems, paListOfNewItems)
			This.ReplaceManyItemsXT(paItems, paListOfNewItems)

			def ReplaceManyXTQ(paItems, paListOfNewItems)
				This.ReplaceManyXT(paItems, paListOfNewItems)
				return This

		def ReplaceAllOfTheseXT(paItems, paListOfNewItems)
			This.ReplaceManyItemsXT(paItems, paListOfNewItems)

			def ReplaceAllOfTheseXTQ(paItems, paListOfNewItems)
				This.ReplaceAllOfTheseXT(paItems, paListOfNewItems)
				return This

		def ReplaceTheseItemsXT(paItems, paListOfNewItems)
			This.ReplaceManyItemsXT(paItems, paListOfNewItems)

			def ReplaceTheseItemsXTQ(paItems, paListOfNewItems)
				This.ReplaceTheseItemsXT(paItems, paListOfNewItems)
				return This

	def ManyItemsReplacedXT(paItems, paListOfNewItems)
		aResult = This.Copy().ReplaceManyItemsXTQ(paItems, paListOfNewItems).Content()
		return aResult

		def TheseItemsReplacedXT(paItems, paListOfNewItems)
			return This.ManyItemsReplacedXT(paItems, paListOfNewItems)

	//>>>>>>> REPLACING AN ITEM BY ALTERNANCE

	def ReplaceItemByAlternance(pItem, paOtherItems)
		/*
		StzListQ([ "A", "A", "َََA", "A", "A" ]) {
			ReplaceItemByAlternance("A", :With = [ "#1", "#2" ])
			? Content()

		}
		# --> [ "#1", "#2", "#1", "#2", "#1" ]
		*/

		if isList(paOtherItems) and
		   ( StzListQ(paOtherItems).IsWithParamList() OR
		     StzListQ(paOtherItems).IsByParamList() )
		
			paOtherItems = paOtherItems[2]
		ok

		if IsNotList(paOtherItems)
			stzRaise("Incorrect param type! paOtherItems must be a list.")
		ok

		anPositions = This.FindAll(pItem)

		i = 0
		for nPos in anPositions
			i++
			if i > len(paOtherItems)
				i = 1
			ok
			This.ReplaceItemAtPosition(nPos, :With = paOtherItems[i])
			
		next

		def ReplaceItemByALternanceQ(pItem, paOtherItems)
			This.ReplaceItemByALternance(pItem, paOtherItems)
			return This

	def ItemReplacedByAlternance(pItem, paOtherItems)
		aResult = This.Copy().ReplaceItemByALternanceQ(pItem, paOtherItems).Content()
		return aResult

	//>>>>>>> REPLACING NTH OCCURRENCE OF AN ITEM

	def ReplaceNthOccurrence(n, pItem, pValue)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pValue) and
		   ( StzListQ(pValue).IsWithParamList() OR
		     StzListQ(pValue).IsByParamList() )
		
			pValue = pValue[2]
		ok

		nItemPosition = This.FindNthOccurrence(n, pItem)

		This.ReplaceItemAtPosition(nItemPosition, pValue)

		def ReplaceNthOccurrenceQ(n, pItem, pValue)
			This.ReplaceNthOccurrence(n, pItem, pValue)
			return This

		def ReplaceNth(n, pItem, pValue)
			This.ReplaceNthOccurrence(n, pItem, pValue)

			def ReplaceNthQ(n, pItem, pValue)
				This.ReplaceNth(n, pItem, pValue)
				return This

	def NthOccurrenceReplaced(n, pItem, pValue)
		aResult = This.Copy().ReplaceNthOccurrenceQ(n, pItem, pValue).Content()
		return aResult

	def ReplaceFirstOccurrence(pItem, pValue)
		This.ReplaceNthOccurrence(1, pItem, pValue)

		def ReplaceFirstOccurrenceQ(pItem, pValue)
			This.ReplaceFirstOccurrence(pItem, pValue)
			return This

		def ReplaceFirst(pItem, pValue)
			This.ReplaceFirstOccurrence(pItem, pValue)

			def ReplaceFirstQ(pItem, pValue)
				This.Replacefirst(pItem, pValue)
				return This

	def FirstOccurrenceReplaced(pItem, pValue)
		aResult = This.Copy().ReplaceFirstOccurrenceQ(pItem, pValue).Content()
		return aResult

	def ReplaceLastOccurrence(pItem, pValue)
		This.ReplaceNthOccurrence(:Last, pItem, pValue)

		def ReplaceLastOccurrenceQ(pItem, pValue)
			This.ReplaceLastOccurrence(pItem, pValue)
			return This

		def ReplaceLast(pItem, pValue)
			This.ReplaceLastOccurrence(pItem, pValue)

			def ReplaceLastQ(pItem, pValue)
				This.ReplaceLast(pItem, pValue)
				return This

	def LastOccurrenceReplaced(pItem, pValue)
		aResult = This.Copy().ReplaceLastOccurrenceQ(pItem, pValue).Content()
		return aResult

	//>>>>>>>  REPLACING NEXT NTH OCCURRENCE OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def ReplaceNextNthOccurrence(n, pItem, pNewItem, pStartingAt)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pNewItem) and
		   ( StzListQ(pNewItem).IsWithParamList() OR
		     StzListQ(pNewItem).IsByParamList() )

			pNewItem = pNewItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok

		oSection   = This.SectionQ(pStartingAt, :LastItem)
		aPositions = oSection.FindAll(pItem)

		aPositions = StzListOfNumbersQ(aPositions).AddToEachQ(pStartingAt - 1).Content()
		nPosition = aPositions[n]

		This.ReplaceItemAtPosition(nPosition, pNewItem)

		def ReplaceNextNthOccurrenceQ(n, pItem, pNewItem, pStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pStartingAt)
			return This

		def ReplaceNthNextOccurrence(n, pItem, pNewItem, pStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pStartingAt)

			def ReplaceNthNextOccurrenceQ(n, pItem, pNewItem, pStartingAt)
				This.ReplaceNthNextOccurrence(n, pItem, pNewItem, pStartingAt)
				return This

	def NthNextOccurrenceReplaced(n, pItem, pNewItem, pStartingAt)
		aResult = This.Copy().ReplaceNthNextOccurrenceQ(n, pItem, pNewItem, pStartingAt).Content()
		return aResult

		def NextNthOccurrenceReplaced(n, pItem, pNewItem, pStartingAt)
			return This.NthNextOccurrenceReplaced(n, pItem, pNEwItem, pStartingAt)

	def ReplaceNextOccurence(pItem, pNewItem, pStartingAt)
		This.ReplaceNextNthOccurence(1, pItem, pNewItem, pStartingAt)

		def ReplaceNextOccurenceQ(pItem, pNewItem, pStartingAt)
			This.ReplaceNextOccurence(pItem, pNewItem, pStartingAt)
			return This

	def NextOccurenceReplaced(pItem, pNewItem, pStartingAt)
		aResult = This.Copy().ReplaceNextOccurenceQ(pItem, pNewItem, pStartingAt).Content()
		return aResult

	//>>>>>>>  REPLACING MANY NEXT NTH OCCURRENCES OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def ReplaceNextNthOccurrences(panList, pItem, pNewItem, pStartingAt)
		/* Example

		StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplaceNexNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
			? Content() # !--> [ "A" , "B", "A", "C", "*", "D", "*" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfItems() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfItems().")
		ok

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pNewItem) and
		   ( StzListQ(pNewItem).IsWithParamList() or StzListQ(pNewItem).IsByParamList() )

			pNewItem = pNewItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok
			
		oSection = This.SectionQ(pStartingAt, :LastItem)

		anPositions = oSection.FindAllQR(pItem, :stzListOfNumbers).AddToEachQ(pStartingAt-1).Content()

		anPositionsToBeReplaced = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeReplaced +  anPositions[n]
			ok
		next

		This.ReplaceAllItemsAtThesePositions(anPositionsToBeReplaced, :With = pNewItem)

		#< @FunctionFluentForm

		def ReplaceNextNthOccurrencesQ(panList, pItem, pNewItem, pStartingAt)
			This.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthNextOccurrences(panList, pItem, pNewItem, pStartingAt)
			This.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pStartingAt)

			def ReplaceNthNextOccurrencesQ(panList, pItem, pNewItem, pStartingAt)
				This.ReplaceNthNextOccurrences(panList, pItem, pNewItem, pStartingAt)
				return This
		#>

	def NextNthOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)
		aResult = This.ReplaceNextNthOccurrencesQ(panList, pItem, pNewItem, pStartingAt).Content()
		return aResult

		def NthNextOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)
			return This.NextNthOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)

	//>>>>>>>  REPLACING PREVIOUS NTH OCCURRENCE OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def ReplacePreviousNthOccurrence(n, pItem, pNewItem, pStartingAt)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pNewItem) and
		   ( StzListQ(pNewItem).IsWithParamList() OR
		     StzListQ(pNewItem).IsByParamList() )

			pNewItem = pNewItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok

		oSection   = This.SectionQ(1, pStartingAt)
		aPositions = oSection.FindAll(pItem)

		nPosition = aPositions[ len(aPositions) - n + 1 ]

		This.ReplaceItemAtPosition(nPosition, pNewItem)

		def ReplacePreviousNthOccurrenceQ(n, pItem, pNewItem, pStartingAt)
			This.ReplacePreviousNthOccurrence(n, pItem, pNewItem, pStartingAt)
			return This

		def ReplaceNthPreviousOccurrence(n, pItem, pNewItem, pStartingAt)
			This.ReplacePreviousNthOccurrence(n, pItem, pNewItem, pStartingAt)

			def ReplaceNthPreviousOccurrenceQ(n, pItem, pNewItem, pStartingAt)
				This.ReplaceNthPreviousOccurrence(n, pItem, pNewItem, pStartingAt)
				return This

	def NthPreviousOccurrenceReplaced(n, pItem, pNewItem, pStartingAt)
		aResult = This.Copy().ReplaceNthPreviousOccurrenceQ(n, pItem, pNewItem, pStartingAt).Content()
		return aResult

		def PreviousNthOccurrenceReplaced(n, pItem, pNewItem, pStartingAt)
			return This.NthPreviousOccurrenceReplaced(n, pItem, pStartingAt)

	def ReplacePreviousOccurence(pItem, pNewItem, pStartingAt)
		This.ReplacePreviousNthOccurence(1, pItem, pNewItem, pStartingAt)

		def ReplacePreviousOccurenceQ(pItem, pNewItem, pStartingAt)
			This.ReplacePreviousOccurence(pItem, pNewItem, pStartingAt)
			return This

	def PreviousOccurenceReplaced(pItem, pNewItem, pStartingAt)
		aResult = This.Copy().ReplacePreviousOccurenceQ(pItem, pNewItem, pStartingAt).Content()
		return aResult

	//>>>>>>>  REPLACING MANY PREVIOUS NTH OCCURRENCES OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pStartingAt)
		/* Example

		StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			ReplacePreviousNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 5)
			? Content() # !--> [ "A" , "B", "*", "C", "*", "D", "A" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfItems() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfItems().")
		ok

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pNewItem) and
		   ( StzListQ(pNewItem).IsWithParamList() or StzListQ(pNewItem).IsByParamList() )

			pNewItem = pNewItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok
			
		oSection = This.SectionQ(1, pStartingAt)

		anPositions = oSection.FindAllQ(pItem).ItemsReversed()

		anPositionsToBeReplaced = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeReplaced +  anPositions[n]
			ok
		next

		This.ReplaceAllItemsAtThesePositions(anPositionsToBeReplaced, :With = pNewItem)

		#< @FunctionFluentForm

		def ReplacePreviousNthOccurrencesQ(panList, pItem, pNewItem, pStartingAt)
			This.ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceNthPreviousOccurrences(panList, pItem, pNewItem, pStartingAt)
			This.ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pStartingAt)

			def ReplaceNthPreviousOccurrencesQ(panList, pItem, pNewItem, pStartingAt)
				This.ReplaceNthPreviousOccurrences(panList, pItem, pNewItem, pStartingAt)
				return This
		#>

	def PreviousNthOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)
		aResult = This.ReplacePreviousNthOccurrencesQ(panList, pItem, pNewItem, pStartingAt).Content()
		return aResult

		def NthPreviousOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)
			return This.PreviousNthOccurrencesReplaced(panList, pItem, pNewItem, pStartingAt)

	//>>>>>>>   REPLACING ITEM BY POSITION

	def ReplaceItemAtPosition(n, pValue)
		/* Example 1:

			o1 = new stzList([ "ONE", "two" ])
			o1.ReplaceItemAtPosition(2, :With = "TWO")
			? o1.Content	# --> [ "ONE", "TWO" ]

		Example 2:

			o1 = new stzList([ "A", "b", "C" ])
			o1.ReplaceItemAtPosition(2, :With@ = "_(@item).Q.Uppercased()")
			? o1.Content()	# --> [ "A", "B", "C" ]
		*/

		if NOT IsNumberOrString(n)
			stzRaise("Invalid param type! n must be a number.")
		ok

		if n = :Last or n = :LastItem
			n = This.NumberOfItems()

		but n = :First or n = :FirstItem
			n = 1
		ok

		if n < 1 or n > This.NumberOfItems()
			stzRaise("the Nth position you provided is out of range!")
		ok

		cValue = ""

		if isList(pValue) and
		   ( StzListQ(pValue).IsWithParamList() or
		     StzListQ(pValue).IsByParamList() )

			cValue = pValue[2]
			
			if pValue[1] = :With@ or pValue[1] = :By@

				cCode = 'cValue = ' + Q(cValue).LowercaseQ().SimplifyQ().RemoveBoundsQ("{","}").ReplaceQ("@item","This[n]").Content()

				try
					eval(cCode)
				catch
					stzRaise("Syntax error in the replacement code!")
				done
			ok
		ok

		if n < 1 or n > This.NumberOfItems()
			stzRaise("Out of range!") # TODO: change with stzListError
		ok

		This.List()[n] = cValue

		#< @FunctionFluentForm

		def ReplaceItemAtPositionQ(n, pValue)
			This.ReplaceItemAtPosition(n, pValue)
			return This

		#>
	
	def ItemAtPositionNReplacedWith(n, pValue)
		aResult = This.Copy().ReplaceItemAtPositionQ( n, :With = pValue ).Content()
		return aResult

		def NthItemReplacedWith(n, pValue)
			return This.ItemAtPositionNReplacedWith(n, pValue)

	def ReplaceFirstItem(pValue)
		This.ReplaceItemAtPosition(1, :With = pValue)

		#< @FunctionFluentForm

		def ReplaceFirstItemQ(pValue)
			This.ReplaceFirstItemWith(pValue)
			return This

		#>

		def ReplaceFirstItemWith(pValue)
			This.ReplaceItemAtPosition(pValue)
			
			def ReplaceFirstItemWithQ(pValue)
				This.ReplaceFirstItemWith(pValue)
				return This
		
	def FirstItemReplacedWith(pValue)
		aResult = This.Copy().ReplaceFirstItemWithQ( pValue ).Content()
		return aResult

	def ReplaceLastItem(pValue)
		This.ReplaceItemAtPosition( This.NumberOfItems(), :With = pValue)

		#< @FunctionFluentForm	

		def ReplaceLastItemQ(pValue)
			This.ReplaceLastItem(pValue)
			return This

		#>

		def ReplaceLastItemWith(pValue)
			This.ReplaceLastItem(pValue)

			def ReplaceLastItemWithQ(pValue)
				This.ReplaceLastItemWith(pValue)
				return This

	def LastItemReplacedWith(pValue)
		aResult = This.Copy().ReplaceLastItemWithQ( pValue ).Content()
		return aResult

	//>>>>>>>   REPLACING MANY ITEMS BY POSITION

	def ReplaceItemsAtPositions(panPositions, pValue)
		for n in panPositions
			This.ReplaceItemAtPosition(n, pValue)
		next

		def ReplaceItemsAtPositionsQ(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)
			return This

		def ReplaceItemsAtThesePositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)
		
			def ReplaceItemsAtThesePositionsQ(panPositions, pValue)
				This.ReplaceItemsAtThesePositions(panPositions, pValue)
				return This

		def ReplaceAllItemsAtPositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)
		
			def ReplaceAllItemsAtPositionsQ(panPositions, pValue)
				This.ReplaceAllItemsAtPositions(panPositions, pValue)
				return This

		def ReplaceAllItemsAtThesePositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)
		
			def ReplaceAllItemsAtThesePositionsQ(panPositions, pValue)
				This.ReplaceAllItemsAtThesePositions(panPositions, pValue)
				return This

		def ReplaceTheseItemsAtPositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)

			def ReplaceTheseItemsAtPositionsQ(panPositions, pValue)
				This.ReplaceTheseItemsAtPositions(panPositions, pValue)
				return This

		def ReplaceTheseItemsAtThesePositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)

			def ReplaceTheseItemsAtThesePositionsQ(panPositions, pValue)
				This.ReplaceTheseItemsAtThesePositions(panPositions, pValue)
				return This

		def ReplaceAllTheseItemsAtPositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)

			def ReplaceAllTheseItemsAtPositionsQ(panPositions, pValue)
				This.ReplaceAllTheseItemsAtPositions(panPositions, pValue)
				return This

		def ReplaceAllTheseItemsAtThesePositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)

			def ReplaceAllTheseItemsAtThesePositionsQ(panPositions, pValue)
				This.ReplaceAllTheseItemsAtThesePositions(panPositions, pValue)
				return This

		def ReplaceManyAtPositions(panPositions, pValue)
			This.ReplaceItemsAtPositions(panPositions, pValue)
			
			def ReplaceManyAtPositionsQ(panPositions, pValue)
				This.ReplaceManyAtPositions(panPositions, pValue)
				return This

	def ItemsAtThesePositionsRplaced(panPositions, pValue)
		aResult = This.Copy().ReplaceItemsAtPositionsQ(panPositions, pValue).Content()
		return aResult

	//>>>>>>> REPLACING A RANGE (OR MORE) OF THE LIST

	def ReplaceRange(nStart, nRange, paOtherList)
		This.ReplaceSection(nStart, nStart + nRange - 1)

		def ReplaceRangeQ(nStart, nRange, paOtherList)
			This.ReplaceRangeQ(nStart, nRange, paOtherList)

	def RangeReplaced(nStart, nRange, paOtherList)
		aResult = This.Copy().ReplaceRangeQ(nStart, nRange, paOtherList).Content()
		return aResult

	def ReplaceManyRanges(panRanges, paOtherList)
		// TODO

		def ReplaceManyRangesQ(panRanges, paOtherList)
			This.ReplaceManyRanges(panRanges, paOtherList)
			return This

	def ManyRangesReplaced(panRanges, paOtherList)
		aResult = This.Copy().ReplaceManyRangesQ(panRanges, paOtherList).Content()
		return aResult

	//>>>>>>> REPLACING A SECTION (OR MORE) OF THE LIST

	def ReplaceSection(n1, n2, paOtherList)

		This.RemoveSection(n1, n2)
	
		n = n1 - 1
		for i = 1 to len(paOtherList)
			This.InsertAfter(n, paOtherList[i])
			n++
		next

		def ReplaceSectionQ(n1, n2, paOtherList)
			This.ReplaceSection(n1, n2, paOtherList)
			return This

	def SectionReplaced(n1, n2, paOtherList)
		aResult = This.ReplaceSectionQ(n1, n2, paOtherList).Content()
		return aResult

	def ReplaceManySections(paSections, paOtherLists)
		// TODO

		def ReplaceManySectionsQ(paSections, paOtherLists)
			This.ReplaceManySections(paSections, paOtherLists)
			return This

	def ManySectionsReplaced(paSections)
		aResult = This.Copy().ReplaceManySectionsQ(paSections, paOtherLists).Content()
		return aResult

	//>>>>>>> REPLACING ALL ITEMS IN THE LIST WITH A GIVEN VALUE

	def ReplaceAllItemsWith(pValue)
		aResult = []
		for i = 1 to This.NumberOfItems()
			aResult + pValue
		next

		This.Update( aResult )

		#< @FunctionFluentForm

		def ReplaceAllItemsWithQ(pValue)
			This.ReplaceAllItemsWith(pValue)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceAllWith(pValue)
			This.ReplaceAllItemsWith(pValue)

			#< @FunctionFluentForm

			def ReplaceAllWithQ(pValue)
				This.ReplaceAll(pValue)
				return This
			#>

		def ReplaceWith(pValue)
			This.ReplaceAllItemsWith(pValue)

			#< @FunctionFluentForm

			def ReplaceWithQ(pValue)
				This.ReplaceWith(pValue)
				return This
			#>

		#>

	def AllItemsReplacedWith(pValue)
		aResult = This.Copy().ReplaceAllItemsWith(pValue)
		return aResult

	//>>>>>>> REPLACING ITEMS UNDER A GIVEN CONDITION

	def ReplaceAllItemsW(pCondition, pValue) # TODO: Made change, test this!

		if NOT ( isString(pCondition) or isList(pCondition) )
			stzRaise("Incorrect param type! pCondition must be string or list.")
		ok

		if NOT ( isString(pValue) or isList(pValue) )
			stzRaise("Incorrect param type! pValue must be string or list.")
		ok 

		if isList(pCondition) and StzListQ(pCondition).IsWhereParamList()
			cCondition = pCondition[2]
		ok

		# There are two possible forms of replacement: With and With@
		# The first one is used to replace with normal string, while the
		# second one to replace with@ a dynamic code.

		# By default, the first form is used.

		cReplace = :With

		if isList(pValue) and
		   ( StzListQ(pValue).IsByParamList() or StzListQ(pValue).IsWithParamList() )

			cReplace = pValue[1]
			cValue = pValue[2]
		ok

		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()

		# NOTE: Don't change the name of var @i

		Previous@i = 0
		Next@i = 0

		for @i = 1 to This.NumberOfItems()

			@item = This[@i]

			if @i <= This.NumberOfItems()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			cCode = 'bReplaceIt = ( ' + cCondition + ' )'

			eval(cCode)

			if bReplaceIt
				if cReplace = :With
					This.ReplaceItemAtPosition(@i, cValue)
	
				but cReplace = :With@
					cValue = StzStringQ(cValue).RemoveBoundsQ("{","}").Simplified()
					cCode = "value = " + cValue
					eval(cCode)
					This.ReplaceItemAtPosition(@i, value)	
	
				ok
			ok

		next
	
		#< @FunctionFluentForm

		def ReplaceAllItemsWQ(pCondition, pValue)
			This.ReplaceAllItemsW(pCondition, pValue)
			return This

		#>

		#< @FunctionAlternativeForm

		def ReplaceAllW(pCondition, pValue)
			This.ReplaceAllItemsW(pCondition, pValue)

			#< @FunctionFluentForm

			def ReplaceAllWQ(pCondition, pValue)
				This.ReplaceAllWithW(pCondition, pValue)
				return This

			#>

		def ReplaceW(pCondition, pValue)
			This.ReplaceAllItemsW(pCondition, pValue)

			#< @FunctionFluentForm

			def ReplaceWQ(pCondition, pValue)
				This.ReplaceW(pValue, pCondition)
				return This

			#>

		#>

	def AllItemsReplacedW(pCondition, pValue)
		aResult = This.Copy().ReplaceAllItemsW(pCondition, pValue)
		return aResult

		def ItemsReplacedW(pcCondition, pValue)
			return This.AllItemsReplacedW(pcCondition, pValue)

	  #-------------------------#
	 #     REMOVING ITEMS      #
	#-------------------------#

	/* TODO: content of this section should be reorganized to
	   reflect this structure (same should be done in Replace section):

	REMOVING AN ITEM (OR MANY ITEMS)
		BY SPECIFYING ITS (OR THEIR) VALUE(S)
	
		BY SPECIFYING ITS (OR THEIR) POSITION(S) IN THE LIST
	
	REMOVING NTH OCCURRENCE (OR MANY NTH OCCURRENCES) OF AN ITEM
		BY SPECIFYING THIS NTH OCCURRENCE (OR THESE NTH OCCURRENCES)
		AND THE VALUE OF THAT ITEM
	
	REMOVING A SECTION (OR MANY SECTIONS) OF THE LIST
		BY SPECIFYING ITS (OR THEIR) START AND END POSITIONS
	
	REMOVING A RANGE (OR MANY RANGES OF THE LIST)
		BY SPECIFYING ITS (OR THEIR) START AND RANGE
	
	REMOVING ITEMS UNDER A GIVEN CONDITION
	
	REMOVING ALL ITEMS OF THE LIST (--> EMPTY LIST)
	*/

	//>>>>>>> RREMOVING ALL OR SOME OCCURRENCES OF AN ITEM

	def RemoveAll(pItem)

		aPositions = This.FindAll(pItem)
		nLen = len(aPositions)

		if nLen > 0
			for i = nLen to 1 step -1
				This.RemoveItemAtPosition(i)
			next
		ok

		#< @FunctionFluentForm

		def RemoveAllQ(pItem)
			This.RemoveAll(pItem)
			return This
	
		#>

		#< @FunctionAlternativeForms

		def RemoveAllOccurrences(pItem)
			This.RemoveAll(pItem)

			#< @FunctionFluentForm

			def RemoveAllOccurrencesQ(pItem)
				This.RemoveAllOccurrences(pItem)
				return This

			#>

		def RemoveAllOccurrencesOfItem(pItem)
			This.RemoveAll(pItem)

			#< @FunctionFluentForm

			def RemoveAllOccurrencesOfItemQ(pItem)
				This.RemoveAllOccurrencesOfItem(pItem)
				return This

			#>

		def Remove(pItem)
			This.RemoveAll(pItem)

			def RemoveQ(pItem)
				This.Remove(pItem)
				return This

		def RemoveItem(pItem)
			This.RemoveAll(pItem)

			def RemoveItemQ(pItem)
				This.RemoveItem(pItem)
				return This

	def AllOccurrencesOfThisItemRemoved(pItem)
		aResult = This.Copy().RemoveAllOccurrencesOfQ(pItem).Content()
		return aResult

		def AllOccurrencesRemoved(pItem)
			return This.AllOccurrencesOfThisItemRemoved(pItem)

		def ItemRemoved(pItem)
			return This.AllOccurrencesOfThisItemRemoved(pItem)

	def RemoveOccurrences(panOccurrences, pItem)
		for n in panOccurrences
			This.RemoveOccurrence(n, pItem)
		next

		#< @FunctionFluentForm

		def RemoveOccurrencesQ(panOccurrences, pItem)
			This.RemoveOccurrences(panOccurrences, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveOccurrencesOfItem(paOccurrences, pItem)
			This.RemoveOccurrences(panOccurrences, pItem)

			def RemoveOccurrencesOfItemQ(paOccurrences, pItem)
				This.RemoveOccurrencesOfItem(paOccurrences, pItem)
				return This

		def RemoveTheseOccurrences(panOccurrences, pItem)
			This.RemoveOccurrences(panOccurrences, pItem)

			def RemoveTheseOccurrencesQ(panOccurrences, pItem)
				This.RemoveTheseOccurrences(panOccurrences, pItem)
				return This

		def RemoveTheseOccurrencesOfItem(panOccurrences, pItem)
			This.RemoveOccurrences(panOccurrences, pItem)

			def RemoveTheseOccurrencesOfItemQ(panOccurrences, pItem)
				This.RemoveTheseOccurrencesOfItem(panOccurrences, pItem)
				return This

		#>

	def OccurrencesRemoved(panOccurrences, pItem)
		aResult = This.Copy.RemoveOccurrencesQ(panOccurrences, pItem).Content()
		return aResult

		def TheseOccurrencesRemoved(panOccurrences, pItem)
			return This.OccurrencesRemoved(panOccurrences, pItem)

		def TheseOccurrencesOfThisItemRemoved(panOccurrences, pItem)
			return This.OccurrencesRemoved(panOccurrences, pItem)

	//>>>>>>> REMOVING MANY ITEMS AT THE SAME TIME

	def RemoveMany(paItems)
		for item in paItems
			This.RemoveAll(item)
		next

		#< @FunctionFluentForm

		def RemoveManyQ(paItems)
			This.RemoveMany(paItems)
			return This

		#>

		def RemoveAllOfThese(paItems)
			This.RemoveMany(paItems)

			def RemoveAllOfTheseQ(paItems)
				This.RemoveAllOfThese(paItems)
				return This

		def RemoveThese(paItems)
			This.RemoveMany(paItems)

			def RemoveTheseQ(paItems)
				This.RemoveThese(paItems)
				return This

		def RemoveTheseItems(paItems)
			This.RemoveMany(paItems)

			def RemoveTheseItemsQ(paItems)
				This.RemoveTheseItems(paItems)
				return This
		#>

	def TheseItemsRemoved(paItems)
		aResult = This.Copy().RemoveTheseItemsQ(paItems).Content()
		return aResult

		def AllOfTheseItemsRemoved(paItems)
			return This.TheseItemsRemoved(paItems)

		def ManyItemsRemoved(paItems)
			return This.TheseItemsRemoved(paItems)

	//>>>>>>> REMOVING NTH OCCURRENCE OF AN ITEM

	def RemoveNthOccurrence(n, pItem)
		if This.NumberOfOccurrence(pItem) >= n
			del( This.List(), This.FindNthOccurrence(n, pItem) )
		ok

		#< @FunctionFluentForm

		def RemoveNthOccurrenceQ(n, pItem)
			This.RemoveNthOccurrence(n, pItem)
			return This

		#>

		def RemoveNth(n, pItem)
			This.RemoveNthOccurrence(n, pItem)

			def RemoveNthQ(n, pItem)
				This.RemoveNth(n, pItem)
				return This

	def NthOccurrenceRemoved(n, pItem)
		aResult = This.Copy().RemoveNthOccurrenceQ(n, pItem)
		return This

	def RemoveFirstOccurrence(pItem)
		This.RemoveNthOccurrence(1, pItem)

		#< @FunctionFluentForm

		def RemoveFirstOccurrenceQ(pItem)
			This.RemoveFirstOccurrence(pItem)
			return This

		#>

	def FirstOccurrenceRemoved(pItem)
		aResult = This.Copy().RemoveFirstOccurrenceQ(pItem).Content()
		return aResult

	def RemoveLastOccurrence(pItem)
		This.RemoveItemAtPosition( This.FindLastOccurrence(pItem) )

		#< @FunctionFluentForm

		def RemoveLastOccurrenceQ(pItem)
			This.RemoveLastOccurrence(pItem)
			return This

		#>

	def LastOccurrenceRemoved(pItem)
		aResult = This.Copy().RemoveLastOccurrenceQ(pItem).Content()
		return This

	//>>>>>>>  REMOVING NEXT NTH OCCURRENCE OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def RemoveNextNthOccurrence(n, pItem, pStartingAt)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok

		oSection   = This.SectionQ(pStartingAt, :LastItem)
		aPositions = oSection.FindAll(pItem)

		aPositions = StzListOfNumbersQ(aPositions).AddToEachQ(pStartingAt - 1).Content()
		nPosition = aPositions[n]

		This.RemoveItemAtPosition(nPosition)

		def RemoveNextNthOccurrenceQ(n, pItem, pStartingAt)
			This.RemoveNextNthOccurrence(n, pItem, pStartingAt)
			return This

		def RemoveNthNextOccurrence(n, pItem, pStartingAt)
			This.RemoveNextNthOccurrence(n, pItem, pStartingAt)

			def RemoveNthNextOccurrenceQ(n, pItem, pStartingAt)
				This.RemoveNthNextOccurrence(n, pItem, pStartingAt)
				return This

	def NthNextOccurrenceRemoved(n, pItem, pStartingAt)
		aResult = This.Copy().RemoveNthNextOccurrenceQ(n, pItem, pStartingAt).Content()
		return aResult

		def NextNthOccurrenceRemoved(n, pItem, pStartingAt)
			return This.NthNextOccurrenceRemoved(n, pItem, pStartingAt)

	def RemoveNextOccurence(pItem, pStartingAt)
		This.RemoveNextNthOccurence(1, pItem, pStartingAt)

		def RemoveNextOccurenceQ(pItem, pStartingAt)
			This.RemoveNextOccurence(pItem, pStartingAt)
			return This

	def NextOccurenceRemoved(pItem, pStartingAt)
		aRrsult = This.Copy().RemoveNextOccurenceQ(pItem, pStartingAt).Content()
		return This

	//>>>>>>>  REMOVING MANY NEXT NTH OCCURRENCES OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def RemoveNextNthOccurrences(panList, pItem, pStartingAt)
		/* Example

		StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			RemoveNexNthOccurrences([2, 3], :of = "A", :StartingAt = 3)
			? Content() # !--> [ "A" , "B", "A", "C", "D" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfItems() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfItems().")
		ok

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok
			
		oSection = This.SectionQ(pStartingAt, :LastItem)

		anPositions = oSection.FindAllQR(pItem, :stzListOfNumbers).AddToEachQ(pStartingAt-1).Content()

		anPositionsToBeRemoved = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeRemoved +  anPositions[n]
			ok
		next

		This.RemoveAllItemsAtThesePositions(anPositionsToBeRemoved)

		#< @FunctionFluentForm

		def RemoveNextNthOccurrencesQ(panList, pItem, pStartingAt)
			This.RemoveNextNthOccurrences(panList, pItem, pStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthNextOccurrences(panList, pItem, pStartingAt)
			This.RemoveNextNthOccurrences(panList, pItem, pStartingAt)

			def RemoveNthNextOccurrencesQ(panList, pItem, pStartingAt)
				This.RemoveNthNextOccurrences(panList, pItem, pStartingAt)
				return This
		#>

	def NextNthOccurrencesRemoved(panList, pItem, pStartingAt)
		aResult = This.RemoveNextNthOccurrencesQ(panList, pItem, pStartingAt).Content()
		return aResult

		def NthNextOccurrencesRemoved(panList, pItem, pStartingAt)
			return This.NextNthOccurrencesRemoved(panList, pItem, pStartingAt)

	//>>>>>>>  REMOVING PREVIOUS NTH OCCURRENCE OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def RemovePreviousNthOccurrence(n, pItem, pStartingAt)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok

		oSection   = This.SectionQ(1, pStartingAt)
		aPositions = oSection.FindAll(pItem)

		nPosition = aPositions[ len(aPositions) - n + 1 ]

		This.RemoveItemAtPosition(nPosition)

		def RemovePreviousNthOccurrenceQ(n, pItem, pStartingAt)
			This.RemovePreviousNthOccurrence(n, pItem, pStartingAt)
			return This

		def RemoveNthPreviousOccurrence(n, pItem, pStartingAt)
			This.RemovePreviousNthOccurrence(n, pItem, pStartingAt)

			def RemoveNthPreviousOccurrenceQ(n, pItem, pStartingAt)
				This.RemoveNthPreviousOccurrence(n, pItem, pStartingAt)
				return This

	def NthPreviousOccurrenceRemoved(n, pItem, pStartingAt)
		aResult = This.Copy().RemoveNthPreviousOccurrenceQ(n, pItem, pStartingAt).Content()
		return This

		def PreviousNthOccurrenceRemoved(n, pItem, pStartingAt)
			return This.NthPreviousOccurrenceRemoved(n, pItem, pStartingAt)

	def RemovePreviousOccurence(pItem, pStartingAt)
		This.RemovePreviousNthOccurence(1, pItem, pStartingAt)

		def RemovePreviousOccurenceQ(pItem, pStartingAt)
			This.RemovePreviousOccurence(pItem, pStartingAt)
			return This

	def PreviousOccurenceRemoved(pItem, pStartingAt)
		aResult = This.Copy().RemovePreviousOccurenceQ(pItem, pStartingAt).Content()
		return This

	//>>>>>>>  REMOVING MANY PREVIOUS NTH OCCURRENCES OF AN ITEM
	//>>>>>>>  STARTING AT A GIVEN POSITION IN THE LIST

	def RemovePreviousNthOccurrences(panList, pItem, pStartingAt)
		/* Example

		StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
			RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 5)
			? Content() # --> [ "A" , "B", "C", "D", "A" ]
		}		

		*/

		if NOT (isList(panList) and StzListQ(panList).IsListOfNumbers() and
		        StzListQ(panList).NumberOfItemsW("StzNumberQ(@item).IsBetween(1, " + This.NumberOfItems() + ")") = len(panList) )

			stzRaise("Incorrect param! panList must a list of numbers between 1 and This.NumberOfItems().")
		ok

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(pStartingAt) and StzListQ(pStartingAt).IsStartingAtParamList()
			pStartingAt = pStartingAt[2]
		ok
			
		oSection = This.SectionQ(1, pStartingAt)

		anPositions = oSection.FindAllQ(pItem).ItemsReversed()

		anPositionsToBeRemoved = []
		i = 0
		for n in panList
			i++
			if i <= len(anPositions)
				anPositionsToBeRemoved + anPositions[n]
			ok
		next

		This.RemoveAllItemsAtThesePositions(anPositionsToBeRemoved)

		#< @FunctionFluentForm

		def RemovePreviousNthOccurrencesQ(panList, pItem, pStartingAt)
			This.RemovePreviousNthOccurrences(panList, pItem, pStartingAt)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthPreviousOccurrences(panList, pItem, pStartingAt)
			This.RemovePreviousNthOccurrences(panList, pItem, pStartingAt)

			def RemoveNthPreviousOccurrencesQ(panList, pItem, pStartingAt)
				This.RemoveNthPreviousOccurrences(panList, pItem, pStartingAt)
				return This
		#>

	def PreviousNthOccurrencesRemoved(panList, pItem, pStartingAt)
		aResult = This.RemovePreviousNthOccurrencesQ(panList, pItem, pStartingAt).Content()
		return aResult

		def NthPreviousOccurrencesRemoved(panList, pItem, pStartingAt)
			return This.PreviousNthOccurrencesRemoved(panList, pItem, pStartingAt)

	//>>>>>>>  REMOVING AN ITEM BY SPECIFYING ITS POSITION

	def RemoveItemAtPosition(n)
		if n = :First or n = :FirstItem
			n = 1
		but n = :Last or n = :LastItem
			n = This.NumberOfItems()
		ok

		del(This.List(), n)

		#< @FunctionFluentForm

		def RemoveItemAtPositionQ(n)
			This.RemoveItemAtPosition(n)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveNthItem(n)
			This.RemoveItemAtPosition(n)

			def RemoveNthItemQ(n)
				This.RemoveNthItem(n)
				return This

		#>

	def ItemAtPositionNRemoved(n)
		aResult = This.Copy().RemoveItemAtPositionQ(n).Content()
		return This

		def NthItemRemoved(n)
			return This.ItemAtPositionNRemoved(n)

	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		#< @FunctionFluentForm

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

		#>

	def FirstItemRemoved()
		aResult = This.Copy().RemoveFirstItemQ(n).Content()
		return aResult

	def RemoveLastItem()
		This.RemoveItemAtPosition( This.NumberOfItems() )

		#< @FunctionFluentForm

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

		#>

	def LastItemRemoved()
		aResult = This.Copy().RemoveLastItemQ(n).Content()
		return aResult

	//>>>>>>>  REMOVING MANY ITEMS BY SPECIFYING THEIR POSITIONS

	def RemoveItemsAtPositions(panPositions)
		panPositions = sort(panPositions)

		for i = len(panPositions) to 1 step -1
			del(This.List(), panPositions[i])

		next

		#< @FunctionFluentForm

		def RemoveItemsAtPositionsQ(panPositions)
			This.RemoveItemsAtPositions(panPositions)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveItemsAtThesePositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

			def RemoveItemsAtThesePositionsQ(panPositions)
				This.RemoveItemsAtThesePositions(panPositions)
				return This

		def RemoveAllItemsAtPositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

			def RemoveAllItemsAtPositionsQ(panPositions)
				This.RemoveAllItemsAtPositions(panPositions)
				return This

		def RemoveAllItemsAtThesePositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

			def RemoveAllItemsAtThesePositionsQ(panPositions)
				This.RemoveAllItemsAtThesePositions(panPositions)
				return This

		def RemoveManyAtPositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

			def RemoveManyAtPositionsQ(panPositions)
				This.RemoveManyAtPositions(panPositions)
				return This
		#>
		
	def ItemsAtThesePositionsRemoved(panPositions)
		aResult = This.Copy().RemoveItemsAtThesePositionsQ(panPositions).Content()
		return aResult

	//>>>>>>> REMOVING A RANGE OF ITEMS

	def RemoveRange(pnStart, pnRange)
	
		nLen = This.NumberOfItems()

		if (pnstart < 1) or (pnStart + pnRange -1 > nLen) or
		   ( pnStart = nLen and pnRange != 1 )
			stzRaise("Out of range!")
		ok

		if pnStart = 1
			aResult = This[1]
		else
			aResult = This.Section(1, pnstart-1)
		ok

		for item in This.Section(pnStart + pnRange, nLen)
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

	//>>>>>>> REMOVING MANY RANGES OF ITEMS

	def RemoveManyRanges(paRanges)
		// TODO

		def RemoveManyRangesQ(paRanges)
			This.RemoveManyRanges(paRanges)
			return This

	def ManyRangesRemoved(paRanges)
		aResult = This.Copy().RemoveManyRangesQ(paRanges).Content()
		return aResult

	//>>>>>>> REMOVING A SECTION OF ITEMS

	def RemoveSection(n1, n2)
		if isList(n1) and StzListQ(n1).IsFromParamList()
			n1 = n1[2]
		ok

		if isList(n2) and StzListQ(n2).IsToParamList()
			n2 = n2[2]
		ok

		This.RemoveRange( n1, n2 - n1 + 1 )

		#< @FunctionFluentForm

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

		#>

	def SectionRemoved(n1, n2)
		aResult = This.Copy().RemoveSectionQ(n1, n2)
		return aResult

	//>>>>>>> REMOVING MANY SECTIONS OF ITEMS

	def RemoveManySections(paRanges)
		// TODO

		def RemoveManySectionsQ(paRanges)
			This.RemoveManySections(paRanges)
			return This

	def ManySectionsRemoved(paRanges)
		aResult = This.Copy().RemoveManySectionsQ(paRanges).Content()
		return aResult

	//>>>>>>> REMOVING ALL ITEMS IN THE LIST
	
	def RemoveAllItems()
		This.Update( [] )

		#< @FunctionFluentForm

		def RemoveAllItemsQ()
			This.RemoveAllItems()
			return This

		#>

	def AllItemsRemoved()
		return []

	//>>>>>>> REMOVING ITEMS UNDER A GIVEN CONDITION

	def RemoveAllW(pCondition)
		/*
		Example:

		o1 = new stzList([ 1, "a", 2, "b", 3, "c" ])
		o1.RemoveAllItemsW(:Where = '{ isNumber(@item) }')
		? o1.Content()

		# --> Gives: [ "a", "b", "c" ]
		*/

		# Checking the provided param for the pCondition
	
		anPos = This.FindW(pCondition)
		This.RemoveItemsAtThesePositions(anPos)

		#< @FunctionFluentForm

		def RemoveAllWQ(pCondition)
			This.RemoveItemsW(pCondition)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveItemsWhere(pCondition)
			This.RemoveAllW(pCondition)

			def RemoveItemsWhereQ(pCondition)
				This.RemoveItemsWhere(pCondition)
				return This

		def RemoveItemsW(pCondition)
			This.RemoveItemsWhere(pCondition)

			def RemoveItemsWQ(pCondition)
				This.RemoveItemsW(pCondition)
				return This

		def RemoveW(pCondition)
			This.RemoveItemsWhere(pCondition)

	def AllItemsRemovedW(pCondition)
		aResult = This.Copy().RemoveItemsWQ(pCondition).Content()
		return aResult

		def ItemsRemovedW(pcondition)
			return This.AllItemsRemovedW(pCondition)

	  #----------------------------#
	 #     BOUNDS OF THE LIST     #
	#----------------------------#

	def IsBoundedBy(pItem1, pItem2)
		if This.FirstItem() = pItem1 and This.LastItem() = pItem2
			return TRUE
		else
			return FALSE
		ok

	def BoundsUpToNItems(n)
		return [ This.NFirstItems(n), This.NLastItems(n) ] # TODO add them

		#< @FunctionFluentForm
	
		def BoundsUpToNItemsQ(n)
			return new stzList( This.BoundsUpToNItems(n) )

		#>

	def IsBoundedManyTimesBy(paPairsOfBounds)
		/*
		o1 = new stzList([ "|", "<", "-", "Scope of Life", "-", ">", "|" ])
		? o1.IsBoundedManyTimesBy([ ["|","|"], ["<",">"], ["-","-"] ])

		!--> TRUE
		*/

		bResult = TRUE
	
		oCopy = This.Copy()
	
		for aPair in paPairsOfBounds
	
			if NOT oCopy.IsBoundedBy(aPair[1], aPair[2])
				bResult = FALSE
				exit
			else
				oCopy.RemoveBounds(aPair[1], aPair[2])
			ok
		next
	
		return bResult

	  #--------------------------#
	 #     REMOVING BOUNDS      #
	#-------------------------#

	def RemoveBounds(pItem1, pItem2)
		if This.IsBoundedBy(pItem1, pItem2)
			This.RemoveFirstItem()
			This.RemoveLastItem()
		ok

		def RemoveBoundsQ(pItem1, pItem2)
			This.RemoveBounds(pItem1, pItem2)
			return This

	def BoundsRemoved(pItem1, pItem2)

		aResult = This.Copy().RemoveBoundsQ(pItem1, pItem2).Content()
		return aResult

		/* WARNING: Subtle bug in Ring (Show to Mahmoud)

		In the function above, if we write the expression that returns
		the result directly after the keyword 'return', like this:

		return This.Copy().RemoveBoundsQ(pItem1, pItem2).Content()

		Then nothing is returned, altough the result should be a list!

		I don't know why this happens. But I found that the solution is
		to avoid writing any expression after return. Instead, let's always
		compute the result in a variable, and then return it (see code above).

		--> TODO: Check the occurrence this pattern all over the library!
		*/
		
	def RemoveManyBounds(paPairsOfBounds)
		for aPair in paPairsOfBounds
			This.RemoveBounds(aPair[1], aPair[2])
		next

		def RemoveManyBoundsQ(paPairsOfBounds)
			This.RemoveManyBounds(paPairsOfBounds)
			return This

	def ManyBoundsRemoved(paPairsOfBounds)
		aResult = This.Copy().RemoveManyBoundsQ(paPairsOfBounds).Content()
		return aResult

	  #-------------------------------------#
	 #    CHECKINK LIST CHARACTERISTICS    #
	#-------------------------------------#

	def IsUnaryList()
		if This.NumberOfItems() = 1
			return TRUE
		else
			return FALSE
		ok

	def IsEmpty()
		if len(This.List()) = 0
			return TRUE
		else
			return FALSE
		ok

	def IsDeepList()	// Contains at least an inner list
		If This.Depth() > 1
			return TRUE
		else
			return FALSE
		ok

	def IsHybridList()	// Contains items of different types
		if NOT This.ContainsOnlyNumbers() or
		   NOT This.ContainsOnlyStrings() or
		   NOT This.ContainsOnlyLists() or
		   NOT This.ContainsOnlyObjects()
			return TRUE
		else
			return FALSE
		ok

	def IsPureList()	// Contains items of the same type
		if This.ContainsOnlyNumbers() or
		   This.ContainsOnlyStrings() or
		   This.ContainsOnlyLists() or
		   This.ContainsOnlyObjects()
			return TRUE
		else
			return FALSE
		ok

	def IsOddList()
		oTempNumber = new stzNumber( This.NumberOfItems() )
		if oTempNumber.IsOdd()
			return TRUE
		else
			return FALSE
		ok

	def IsEvenList()
		if NOT This.IsOddList()
			return TRUE
		else
			return FALSE
		ok

	// TODO: Maybe we should design a stzListOfBits class...
	def IsListOfBits()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		if This.IsListOfNumbers()
			for n in This.List()
				if NOT IsBit(n)
					return FALSE
				ok
			end
		ok

		return TRUE

	def IsListOfZerosAndOnes()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		return This.IsListOfBits()

	def IsGrid()
		return This.AllItemsAre('{ isList(@item) and len(@item) = len(This[1]) }')

	def IsHashList()
		/*
		A hash list is a grid of 2 vlines.

		The items of the 1st vline are all strings.
		And they are all unique (form a Set).

		When stzGrid class is fully tested we can use this code:	
		
		oTempGrid = new stzGrid( This.List() )
		bResult = FALSE

		if oTempGrid.NumberOfVLines() = 2

			aFirstVLine = oTempGrid.VLine(1)

			if ListIsSet(aFirstVLine) and ListItemsAreAllStrings(aFirstVLine)
				bResult = TRUE
			ok
		ok
		return bResult
		*/

		# All items are list of 2 items, where the 1st beeing string
		# TODO: The strings in the 1st column (keys of the hashlist) must be unique

		bResult = TRUE
		aTempKeys = []

		for i = 1 to len(This.List())

			if NOT ( isList(This[i]) and len(This[i]) = 2 and
				 isString(This[i][1]) )

				bResult = FALSE
				exit
			else
				if find(aTempKeys, This[i][1]) > 0
					bResult = FALSE
					exit
				ok

				aTempKeys + This[i][1]
			ok
		next

		return bResult

	def AllItemsAreHashLists()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = TRUE
		for item in This.List()
			if NOT isList(item)
				bResult = FALSE
				exit
			ok

			if NOT StzListQ(item).IsHashList()
				bResult = FALSE
				exit
			ok
		next
		return bResult

		#< @FunctionAlternativeForms

		def ContainsOnlyHashLists()
			return This.AllItemsAreHashLists()
	
		def IsListOfHashLists()
			return This.AllItemsAreHashLists()

		#>

	def AllItemsAreListsHavingSameNumberOfItems()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = FALSE

		if This.AllItemsAreLists()
			bSame = TRUE
			for i = 2 to This.NumberOfItems()
				if len(Item(i)) != len(Item(i-1))
					bSame = FALSE
				ok
			next
			if bSame
				bResult = TRUE
			ok
		ok

		return bResult

	def AllItemsAreSets()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = TRUE

		for item in This.List()
			if NOT ListIsSet(item)
				bResult = FALSE
				exit
			ok
		end

		return bResult

	def IsListOfStrings()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = TRUE

		for item in This.List()
			if NOT isString(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsListOfChars()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = TRUE

		for item in This.List()
			if NOT ( isString(item) and
			   	 StzStringQ(item).NumberOfChars() = 1 )

				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsListOfLetters()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		bResult = TRUE

		for item in This.List()
			if NOT ( isString(item) and
				 StzStringQ(item).IsLetter() )

				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsListOfNumbers()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		return This.AllItemsAreNumbers()

	def IsListOfLists()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		return This.AllItemsAreLists()

	def IsListOfSets()
		if This.NumberOfItems() = 0
			return FALSE
		ok

		return This.AllItemsAreSets()

	def Transform( pcWhat, pcCondition, pcTo )
		/*
		For the meantime, this function works only for:
		Transform( :AllItems, :ThatAreLists, :ToSets )

		TODO: Generalize this method to support more cases.
		*/
		aResult = []

		if pcWhat = :AllItems and
		   pcCondition = :ThatAreLists and
		   pcTo = :ToSets

			for item in This.List()
				if isList(item)
					oTempList = new stzList(item)
					aResult + oTempList.ToSet()
				ok
			end
		ok

		return aResult

	def IsPair()
		return This.NumberOfItems() = 2

	def IsPairOfStrings()
		return This.IsPair() and This.IsListOfStrings()

	def IsPairOfNumbers()
		return This.IsPair() and This.IsListOfNumbers()

	def IsPairOfLists()
		return This.IsPair() and This.IsListOfLists()

	def IsPairOfObjects()
		return This.IsPair() and This.IsListOfObjects()

	def IsPairAndKeyIsString()
		return This.IsPair() and isString(This[1])

	def IsListOfObjects()
		bResult = TRUE
		for item in This.List()
			if NOT isObjet(item)
				bREsult = FALSE
				exit
			ok
		next

		return bResult

	def IsPairStzObjects()
		return This.IsPair() and This.IsListOfStzObjects()

	def IsListOfStzObjects()
		bResult = TRUE
		for item in This.List()
			if NOT IsStzObjet(item)
				bREsult = FALSE
				exit
			ok
		next

		return bResult

	def IsPairOfStzNumbers()
		return This.IsPair() and This.IsListOfStzNumbers()

	def IsListOfStzNumbers()
		bResult = TRUE
		for item in This.List()
			if NOT IsStzNumber(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsPairOfStzStrings()
		return This.IsPair() and This.IsListOfStzStrings()

	def IsListOfStzStrings()
		bResult = TRUE
		for item in This.List()
			if NOT IsStzString(item)
				bREsult = FALSE
				exit
			ok
		next

		return bResult

	def IsPairOfStzLists()
		return This.IsPair() and This.IsListOfStzLists()

	def IsListOfStzLists()
		bResult = TRUE
		for item in This.List()
			if NOT IsStzList(item)
				bREsult = FALSE
				exit
			ok
		next

		return bResult

	def IsPairOfStzObjects()
		return This.IsPair() and This.IsListOfStzObjects()

	def IsPairOfChars()
		return This.IsPair() and This.IsListOf(:Chars)

	def IsPairOf(pcDataType)
		return This.IsPair() and This.IsListOf(pcDataType)

	def IsListOf(pcType)
		/*
			_([ 1, 2, 3 ]).IsListOf(:Number)	# --> TRUE

			pcType should be a string containing the name of:
				- a ring datatype ( given by RingDataTypes() )
				- a Softanza datatype ( given by StzDataTypes() )

			For the sake of expressiveness, pcType can be in plural form:

			_([ 1, 2, 3 ]).IsListOf(:Numbers)

		*/

		pcType = InfereDataTypeFromString(pcType)

		if This.NumberOfItemsW('_(@item).Q.DataType() = "' + pcType + '"') = This.NumberOfItems() or
		   This.AllItemsAreW('isList(@item) and _(@item).Q.Is' + pcType + '()') or
		   This.AllItemsAreW('isObject(@item) and Is' + pcType + '(@item)')

			return TRUE

		else
			return FALSE

		ok
		
	def IsListOfPairs()
		bResult = This.AllItemsAreW('Q(@item).IsPair()')
		return bResult

	def IsListOfPairsOfNumbers()
		bResult = This.IsListOfPairs() and This.AllItemsAreNumbers()
		return bResult

	def IsListOfPairsOfStrings()
		bResult = This.IsListOfPairs() and This.AllItemsAreStrings()
		return bResult

	def IsListOfPairsOfObjects()
		bResult = This.IsListOfPairs() and This.AllItemsAreObjects()
		return bResult

	def IsTree()
		if NOT This.IsEmpty()
			return TRUE

		else
			return FALSE
		ok

	def IsStzTree()
		// TODO

	def IsTable() # TODO

	def IsPivotTable() # TODO

	def IsGraph() # TODO

	  #----------------------------#
	 #   SAME TYPE & SAME VALUE   #
	#----------------------------#

	def ItemsHaveSameType()
		return This.IsPureList()

	def ItemsHaveSameValue()
		bResult = TRUE
		if This.ItemsHaveSameType()
			if This.ItemsAreAllNumbers() or This.ItemsAreAllStrings()
				for i = 2 to This.NumberOfItems()		
					if This.Item(i) != This.Item(i-1)
						bResult = FALSE
						exit
					ok
				next

			but This.ItemsAreAllLists()
				for i=2 to This.NumberOfItems()
					oTempList = new stzList(Item(i))
					if oTempList.IsEqualTo(Item(i-1))
						bResult = FALSE
						exit
					ok
				next

			but ItemsAreAllObjects()
				stzRaise("Can't compare between objects!")
			
			else
				stzRaise("Unsupported type!")
			ok
		else
			bResult = FALSE
		ok

		return bResult

	   #-----------------------------------------#
	  #    TODO: CHANGE WITH ...W(pExpression)  #
	#-----------------------------------------#

	def ItemsAreAll(pcDesc) # Replace with an evalated code alternative
		switch pcDescription
		on :Numbers
			return This.ItemsAreAllNumbers()
		on :Digits
			return This.ItemsAreAllDigits()
		on :Zeros
			return This.ItemsAreAllZeros()

		on :Strings
			return This.ItemsAreAllStrings()

		on :NullStrings
			return This.ItemsAreAllNullStrings()

		on :NumbersOrStringsHostingNumbers or
		   :NumbersOrNumbersInStrings
			return This.ItemsAreAllNumbersOrNumbersInStrings()

		on :NumbersHostedInStrings or
		   :NumbersInStrings or
		   :StringsHostingNumbers
			return This.ItemsAreAllNumbersInStrings()

		on :Lists
			return This.ItemsAreAllLists()

		on :EmptyLists
			return This.ItemsAreAllEmptyLists()

		on :UnaryLists
			return This.ItemsAreAllUnaryLists()

		on :DeepLists
			return This.ItemsAreAllDeepLists()

		on :PureLists
			return This.ItemsAreAllPureLists()

		on :HybridLists
			return This.ItemsAreAllHybridLists()

		on :OddLists
			return This.ItemsAreAllOddLists()

		on :EvenLists
			return This.ItemsAreAllEvenLists()

		on :OddLists
			return This.ItemsAreAllOddLists()

		on :SortedLists
			return This.ItemsAreAllSortedLists()

		on :SortedInAscendingLists
			return This.ItemsAreAllSortedInAscendingOrder()

		on :SortedInDescendingLists
			return This.ItemsAreAllSortedInDescendingOrder()

		on :NumberOnlyLists
			return This.ItemsAreAllNumberOnlyLists()

		on :NumberAndNumberInStringLists
			return This.ItemsAreAllNumberAndNumberInStringLists()

		on :StringOnlyLists
			return This.ItemsAreAllStrings()

		on :ObjectOnlyLists
			return This.ItemsAreAllObjects()

		on :RingObjectOnlyLists
			return This.ItemsAreAllRingObjects()

		on :SoftanzaObjectLists
			return This.ItemsAreAllSoftanzaObjects()

		on :Objects
			return This.ItemsAreAllObjects()

		on :SoftanzaObjects
			return This.ItemsAreAllSoftanzaObjects()

		other
			stzRaise("Unsupported parameter!")
		off

	def ItemsAre(pcDesc)
		switch pcDesc
		on :AllNumbers

			return This.ItemsAreAllNumbers()

		on :NumbersAndStringsHostingNumbers or
		   :NumbersAndNumbersInStrings

			return This.ItemsAreNumbersOrNumbersInStrings()

		on :NumbersHostedInStrings or
		   :NumbersInStrings or
		   :StringsHostingNumbers
			// TODO

		on :AllStrings
			// TODO

		on :AllNullStrings
			// TODO

		on :StringsAndHaveSameNumberOfChars
			// TODO

		on :AllLists
			// TODO

		on :ListsAndHaveSameNumberOfItems
			// TODO

		on :AllObjects
			// TODO

		on :AllRingObjects
			// TODO

		on :AllSoftanzaObjects
			// TODO

		off

	def ItemsHaveSame(pcDesc)
		switch pcDesc
		on :Type
			return This.ItemsHaveSameType()

		on :Value
			return Thi.ItemsHaveSameValue()

		on :NumberOfItems
			return This.ItemsAreLists_And_HaveSameNumberOfItems()

		on :NumberOfChars
			return This.ItemsAreStrings_And_HaveSameNumberOfChars()
		off

	def ItemsAreAllNumbers()
		return This.ContainsOnlyNumbers()

	def ItemsAreAllStrings()
		return This.ContainsOnlyStrings()

	def ItemsAreAllLists()
		return This.ContainsOnlyLists()

	def ItemsAreAllEmptyLists()
		return This.ContainsOnlyEmptyLists()

	def ItemsAreAllUnaryLists()
		return This.ContainsInlyUnaryLists() //***

	def ItemsAreAllDeepLists()
		return This.ContainsOnlyDeepLists() // ***

	def ItemsAreAllPureLists()
		return This.ContainsOnlyPureLists() // ***

	def ItemsAreAllHybridLists()
		return This.ContainsOnlyHybridLists() // ***

	def ItemsAreAllOddLists()
		return This.ContainsOnlyOddLists() // ***

	def ItemsAreAllEvenLists()
		return This.ContainsOnlyEvenLists() // ***

	def ItemsAreAllSortedLists()
		return This.ContainsOnlySortedLists() // ***

	def ItemsAreAllSortedInAscendingLists()
		return This.ContainsOnlySortedInAscendingLists() // ***

	def ItemsAreAllSortedInDescendingLists()
		return This.ContainsOnlySortedInDescendingLists() // ***

	def ItemsAreLists_And_HaveSameNumberOfItems()
		return This.ContainsOnlyLists_That_HaveSameNumberOfItems()
	
	def ItemsAreNumbers_And_StringsHostingNumbers()
		// TODO

	def ItemsAreNumbersHostedInStrings()
		// TODO

	def ItemsAreStringsHostingNumbers()
		return ItemsAreNumbersHostedInStrings()

	def ItemsAreAllObjects()
		return This.ContainsOnlyObjects()

	def ItemsAreAllSoftanzaObjects()
		return This.ContainsOnlySoftanzaObjects()

	  #----------------------#
	 #     LIST CONTENT     #
	#----------------------#

	def ContainsOnlyNumbers()
		if len(This.OnlyNumbers()) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyTRUEItems()
		return This.OnlyOnes()

	def ContainsOnlyFALSEItems()
		return This.ContainsOnlyZeros()

	def ContainsOnlyOddNumbers()
		/*
		Should be rather implemented like this:
		if len(This.OddNumbers()) = This.NumberOfItems() // Todo: OddNumbers()
			return TRUE
		else
			return FALSE
		ok
		*/

		bResult = TRUE
		for item in This.Content()
			oTempNumber = new stzNumber(item)
			if NOT oTempNumber.IsOdd()
				bResult = FALSE
				exit
			ok
		next
		return bResult	

	def ContainsOnlyEvenNumbers()
		/*
		Should be rather implemented like this:
		if len(This.OnlyEvenNumbers()) = This.NumberOfItems() // Todo: OnlyEvenNumbers()
			return TRUE
		else
			return FALSE
		ok
		*/

		bResult = TRUE
		for item in This.Content()
			oTempNumber = new stzNumber(item)
			if NOT oTempNumber.IsEven()
				bResult = FALSE
				exit
			ok
		next
		return bResult	

	def ContainsOnlyDigits()
		/*
		Should be rather implemented like this:
		if len(This.OnlyDigits()) = This.NumberOfItems() // Todo: OnlyDigits()
			return TRUE
		else
			return FALSE
		ok
		*/

		aDigits = 0:9
		oTempList = new stzList(aDigits)

		bResult = TRUE
		
		for item in This.Content()
			if NOT oTempList.Contains(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsOnlyPositiveNumbers()
		if len(This.OnlyPositiveNumbers()) = This.NumberOfItems() // Todo: OnlyPositiveNumbers()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyNegativeNumbers()
		if len(This.OnlyNegativeNumbers()) = This.NumberOfItems() // Todo: OnlyNegativeNumbers()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyZeros()
		if len(This.OnlyZeros()) = This.NumberOfItems() // Todo: OnlyZeros()
			return TRUE
		else
			return FALSE
		ok
			
	def ContainsOnlyOnes()
		if len(This.OnlyOnes()) = This.NumberOfItems() // Todo: OnlyOnes()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyStrings()
		if len(This.OnlyStrings()) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	def BothAreNumbers()
		if This.NumberOfItems() = 2 and isNumber(This[1]) and isNumber(This[2])
			return TRUE
		else
			return FALSE
		ok

	def AllItemsAreEqualTo(pValue)
		bResult = TRUE
		for item in This.List()
			if item != pValue
				bResult = FALSE
				exit
			ok
		next
		return bResult

	def ContainsOnlyNullStrings()
		bResult = TRUE
		for item in This.Content()
			if NOT (isString(item) and item = NULL)
				bResult = FALSE
				exit
			ok
		next
		return bResult

	def ContainsOnlyLists()
		if len(This.OnlyLists()) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyEmptyLists()
		bResult = TRUE
		for item in This.Content()
			if NOT (isList(item) and len(item) = 0)
				bResult = FALSE
				exit
			ok
		next
		return bResult

	def ContainsOnlyLists_That_HaveSameNumberOfItems()
		bResult = TRUE
		if This.ContainsOnlyLists()
			for i=2 to This.NumberOfItems()
				if len(This[i-1]) != len(This[i])
					bResult = FALSE
					exit
				ok
			next
		else
			bResult = FALSE
		ok
		return bResult

	def ContainsOnlyObjects()
		if len(This.OnlyObjects()) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	def ContainsOnlyRingObjects()
		if len(This.OnlyRingObjects()) = This.NumberOfItems() // Todo: OnlyObjects()
			return TRUE
		else
			return FALSE
		ok


	def ContainsOnlyStzObjects()
		if len(This.OnlyStzObjects()) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	  #---------------#
	 #    WALKERS    #
	#---------------#

	def AddWalker(pcName, pnStart, pnEnd, panStepping)

		if NOT ( StzNumberQ(pnStart).IsBetween(1, This.NumberOfItems()) and
			 StzNumberQ(pnEnd).IsBetween(1, This.NumberOfItems()) )

			stzRaise("Start or end of walker outside list range!")
		ok

		//oWalkers = new stzHashList(This.Walkers())
		bNewName = TRUE
		for aWalk in This.Walkers()
			if aWalk[1] = pcName
				bNewName = FALSE
				exit
			ok
		next

		// If oWalkers.ContainsKey(pcName)
		if NOT bNewName
			stzRaise(stzListError(:CanNotAddWalkerAlreadyExistant))
		else
			oWalk = new stzWalker(pnStart, pnEnd, panStepping)
			@aWalkers + [ pcName, oWalk.Content() ]
		ok

	def Walkers()
		return @aWalkers

	def Walker(pcWalker)
		return This.Walkers()[pcWalker]

	  #---------------#
	 #    WALKERS    #
	#---------------#

	def WalkUntil(pcCondition )
		return This.WalkUntilXT(pcCondition, :Return = :LastPosition)

	def WalkUntilXT(pcCondition, pReturn)
		/*
		[ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]

		WalkUntil("@item = 'D'", :Return = :WalkedPositions  )  # --> 1:5
		WalkUntil("@item = 'D'", :Return = :LastPosition )  # --> 5

		WalkUntil("@item = 'D'", :Return = :WalkedItems )
		# --> [ "A", "B", 12, "C", "D" ]

		WalkUntil("@item = 'D'", :Return = :LastItem ) # --> "D"


		WalkUntil("isNumber(@item)") # --> 1:3
		WalkUntil("isNumber(@item) and @item > 20") # --> 1:9
		*/

		if isString(pcCondition)
			oStzString = new stzString(pcCondition)

			oStzString.RemoveBounds("{","}")

			bFound = FALSE

			if oStzString.ContainsCS( "@item", :CaseSensitive = FALSE )
				i = 0			
				cCode =
				"for @item in This.List()" + NL +
					tab + "i++" + NL +
					tab + "if " + pcCondition + NL +
					tab + tab + "bFound = TRUE" + NL +
					tab + tab + "exit" + NL +
					tab + "ok" + NL +
				"next"

				eval(cCode)
				
				if bFound and i > 0
					return 1 : i

				else
					return 0
				ok
			else
				stzRaise("Syntax error! Your persocode must contain the keyword '@item'.")
			ok
		ok

	def WalkWhile(pcCondition)
		return WalkWhileCondition(pcCondition)

	def WalkWhileCondition(pcCondition)
		/*
		[ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]

		aWalk6 = WalkWhile("isNumber(Item) and NumberIsDividableBy(Item,12)")
		? aWalk6 # --> 1:3
		*/
		if isString(pcCondition)
			oStzString = new stzString(pcCondition)

			oStzString.RemoveBounds("{","}")

			if oStzString.ContainsCS( "@item", :CaseSensitive = FALSE )
				i = 0	
				cCode =
				"for @item in This.List()" + NL +
					tab + "if " + pcCondition + NL +
					tab + tab + "i++" + NL +
					tab + "else" + NL +
					tab + tab + "exit" + NL +
					tab + "ok" + NL +
				"next"

				eval(cCode)
				
				if i > 0
					return 1 : i
				ok
			else
				stzRaise("Syntax error! Your persocode must contain the keyword 'Item'.")
			ok
		ok

	def WalkUntilItemIsNumber()
		return This.WalkUntilItemTypeIs(:Number)

	def WalkUntilItemIsString()
		return This.WalkUntilItemTypeIs(:String)

	def WalkUntilItemIsList()
		return This.WalkUntilItemTypeIs(:List)

	def WalkUntilItemIsObject()
		return This.WalkUntilItemTypeIs(:Object)

	def WalkUntilItemIsStzObject()
		return This.WalkUntilItemTypeIs(:StzObject)

	def WalkUntilItemTypeIs(pcType)
		if IsType(pcType)
			for i=1 to NumberOfItems()
				if type(Item(i)) = pcType
					return 1 : i
				ok
			next
		else
			stzRaise("Unsupported type!")
		ok

	def WalkEachW(pcCondition)
		oStzString = new stzString(pcCondition)
		if oStzString.ContainsCS( "@item", :CaseSensitive = FALSE )
			aResult = []
			i = 0
			cCode =
			"for @item in This.List()" + NL +
				tab + "i++" + NL +
				tab + "if " + pcCondition + NL +
				tab + tab + "aResult + i" + NL +
				tab + "ok" + NL +
			"next"

			eval(cCode)
				
			if i > 0
				return aResult
			ok
		else
			stzRaise("Syntax error! Your persocode must contain the keyword 'Item'.")
		ok

	def WalkNForwardNBackward(pnForward, pnBackward)
		return This.WalkNStepsForwardNStepsBackward(pnForward, pnBackward)

	def WalkNStepsForwardNStepsBackward(pnForward, pnBackward)	
		if pnForward < 0 or pnBackward < 0
			stzRaise("Can't proceed. nForward and nBackward must not be negative!")

		but pnForward > This.NumberOfItems() or pnBackward > This.NumberOfItems()
			stzRaise("Can't proceed. nForward and nBackward must not exceed the number of items!")

		but pnBackward > pnForward
			stzRaise("Can't proceed. nBackward must not be greater then nForward!")

		but pnForward = pnBackward
			return [1]

		but pnForward > 0 and pnBackward = 0
			aResult = []
			for i = 1 to This.NumberOfItems() step pnForward
				aResult + i
			next
			return aResult

		else
			aResult = [1]
			n = 1
			while n + pnForward <= This.NumberOfItems()
				// n steps forward
				n += pnForward
				if n <= This.NumberOfItems()
					aResult + n
				ok
	
				// n steps backward
				n -= pnBackward
				if n > 0
					aResult + n
				ok	
			end
			return aResult
		ok

	def WalkNFromStartNFromEnd(pnFormStart, pnFromEnd)
		return This.WalkNStepsFromStartAndNStepsFromEnd(pnFromStart, pnFromEnd)

	def WalkNStepsFromStartNStepsFromEnd(pnFromStart, pnFromEnd)
		aResult = []
		m = This.NumberOfItems() + pnFromEnd
		for n = 1 to This.NumberOfItems() step pnFromStart
			// adding one step forward
			if n != m and find(aResult, n) = 0
				aResult + n
			ok

			// adding one step backward
			m -= pnFromEnd
			if m != n and find(aResult, m) = 0 and m > 0
				aResult + m
			ok	
		next
		return aResult

	def WalkForthAndBack()
		aResult = 1 : This.NumberOfItems()
		for i = This.NumberOfItems()-1 to 1 step -1
			aResult + i
		next
		return aResult

	def WalkBackAndForth()
		aResult = This.NumberOfItems() : 1
		for i = 2 to This.NumberOfItems()
			aResult + i
		next
		return aResult

	def WalkNStepsForward(n)
		aResult = []
		for i = 1 to This.NumberOfItems() step n
			aResult + i
		next
		return aResult

	def WalkNStepsBackward(n)
		aResult = []
		for i = This.NumberOfItems() to 1 step -n
			aResult + i
		next
		return aResult

	def WalkNProgressiveStepsForward(n)
		if n < 0
			stzRaise("Can't proceed. n must be positive!")
		but n = 0
			return [1]
		else
			aResult = [1]
			nstep = 1
			i = 0
			
			while nStep <= This.NumberOfItems()
				i++
				nStep += (n * i)
				if nStep <= This.NumberOfItems()
					aResult + nStep
				ok
			end
	
			return aResult
		ok

	def WalkNProgressiveStepsBackward(n)
		if n < 0
			stzRaise("Can't proceed. n must be positive!")
		but n = 0
			return [ This.NumberOfItems() ]
		else
			aResult = [ This.NumberOfItems() ]
			nStep = This.NumberOfItems()
			i = 0
			
			while nStep > 0
				i++
				nStep -= (n * i)
				if nStep > 0
					aResult + nStep
				ok
			end
	
			return aResult
		ok

	  #-----------------#
	 #     YIELDERS    #
	#-----------------#

	def Yield(cExpression, pcWalker)
		cExpression = StzStringQ(cExpression).RemoveBoundsQ("{","}").Content()
		aResult = []

		for nStep in This.Walker(pcWalker)

			try
				cCode = "aResult + " + cExpression
				cCode = StzStringQ(cCode).ReplaceAllCSQ( "Item", "This.Item("+ nStep + ")", :CS = FALSE ).Content()

				eval( cCode )
			catch
				aResult + NULL
			done

		next

		return aResult

	  #-------------------#
	 #     PERFORMERS    #
	#-------------------#

	def Perform(pcFunc, pcWalker)
		try
			for nStep in This.Walker(pcWalker)
				cCode = "This.ReplaceItem(" + i + ", " + pcFunc + "( This.Item(" + nStep + ") )"
				eval( cCode )
			next i
			return TRUE
		catch

			return FALSE
		done

	  #-----------------------------------#
	 #     COMPARISON TO ANOTHER LIST    #
	#-----------------------------------#

	def IsEqualTo(paOtherList)
		/*
		Two lists are equal when they have:
			1. same type
			2. same number of items AND
			3. same content
		*/

		if isList(paOtherList) and
		   len(paOtherList) = len(This.List()) and
		   This.HasSameContentAs(paOtherList)

			return TRUE
		else
			return FALSE
		ok

		def IsEqual(paOtherList)
			return This.IsEqualTo(paOtherList)

		def IsNotEqualTo(paOtherList)
			return NOT This.IsEqualTo(paOtherList)

	def IsStrictlyEqualTo(paOtherList)

		/*
		Tow lists are striclty equal when:
			1. they are equal (in the sense of IsEqualTo() method)
			2. they have same order of items (ItemsHaveSameOrder())
		*/

		
		if This.IsEqualTo(paOtherList) and
		   This.HasSameSortingOrderAs(paOtherList)
			return TRUE
		else
			return FALSE
		ok

		def IsStrictlyEqual(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

	def IsQuietEqualTo(paOtherList)

		if This.IsEqualTo(paOtherList)
			return TRUE
		ok

		nDif = abs(This.NumberOfItems() - StzListQ(paOtherList).NumberOfItems())
		n = nDif / This.NumberOfItems()
		
		if n < QuietEqualityRatio() # 0.09 by default, can be changed with SetQuietEqualityRatio(n)
			return TRUE
		ok

		return FALSE

		def IsQuietEqual(paOtherList)
			return This.IsQuietEqualTo(paOtherList)

	def ItemsHaveSameOrderAs(paOtherList)
		bResult = TRUE

		for i = 1 to min( len(This.List()), len(paOtherList) )
			if Q(This[i]).IsNotEqualTo(paOtherList[i])
				bResult = FALSE
				exit
			ok
		next

		return bResult
	
		def ItemsHaveSameOrder(paOtherList)
			return This.ItemsHaveSameOrderAs(paOtherList)

	def AllItemsAreNumbersOrStrings()
		bResult = TRUE
		for item in This.List()
			if NOT (isNumber(item) or isString(item))
				bResult = FALSE
				exit
			ok
		next
		return bResult

	def IsReverseOf(paOtherList)
		bResult = TRUE
		if This.NumberOfItems() != len(paOtherList)
			return FALSE
		ok

		for i = 1 to This.NumberOfItems()
			if _(This[i]).@.IsDifferentFrom( paOtherList[ len(paOtherList) - i + 1 ] )
				bResult = FALSE
				exit
			ok
		next i

		return bResult

		def IsReverse(paOtherList)
			return This.IsReverseOf(paOtherList)


	def ReverseItems()	# NOTE: we can't use REVERSE() because
				# it is reserved by Ring
		aResult = []
		
		for i = This.NumberOfItems() to 1 step -1
			aResult + This[i]
		next

		This.Update( aResult )

		def ReverseItemsQ()
			This.ReverseItems()
			return This

	def ReversedItems()
		aResult = This.Copy().ReverseItemsQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def ItemsReversed()
			return This.ReversedItems()

		def Reversed()
			return This.ReversedItems()

		#>

	def HasMoreNumberOfItemsThen(paOtherList)
		if This.NumberOfItems() > len(paOtherList)
			return TRUE
		else
			return FALSE
		ok

		def HasMoreNumberOfItems(paOtherList)
			return This.HasMoreNumberOfItemsThen(paOtherList)

	def IsLargerThen(paOtherList)
		return This.HasMoreNumberOfItemsThen(paOtherList)

		def IsLarger(paOtherList)
			return This.IsLargerThen(paOtherList)

	def HasLessNumberOfItemsThen(paOtherList)
		if This.NumberOfItems() < len(paOtherList)
			return TRUE
		else
			return FALSE
		ok

		def HasLessNumberOfItems(paOtherList)
			return This.HasLessNumberOfItemsThen(paOtherList)


	def IsShorterThen(paOtherList)
		return This.HasLessNumberOfItemsThen(paOtherList)

		def IsShorter(paOtherList)
			return This.IsShorterThen(paOtherList)

	def HasSameTypeAs(p)
		return isList(p)

		def HasSameType(p)
			return This.HasSameTypeAs(p)

	def HasSameContentAs(paOtherList)

		if NOT isList(paOtherList)
			stzRaise("Invalid param type! paOtherList should be a list.")
		ok

		# The two lists must have same number of items

		If  This.NumberOfItems() != len(paOtherList)
			return FALSE
		ok

		oCopy = This.Copy()
		oCopy - paOtherList

		if oCopy.IsEmpty()
			return TRUE
		else
			return FALSE
		ok
				
		def HasSameContent(paOtherList)
			return This.HasSameContentAs(paOtherList)

	def Positions(pItem)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		return This.FindAll(pItem)

		#< @FunctionFluentForm

		def PositionsQR(pItem, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Positions(pItem) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Positions(pItem) )

			other
				stzRaise("Unsupported return type!")
			off

		def PositionsQ(pItem)
			return This.PositionsQR(pItem, :stzListOfNumbers)

		#>

		#< @FunctionAlternativeForms

		def Occurrences(pItem)
			return This.Positions(pItem)

			def OccurrencesQR(pItem, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.PositionsQR(pItem, pcReturnType)

			def OccurrencesQ(pItem)
				return ThiS.OccurrencesQR(pItem, :stzListOfNumbers)
		#>

	  #=====================================#
	 #    CLASSIFYING (OR CATEGORIZING)    #
	#=====================================#

	def AllItemsAreContiguousLists()
		bResult = TRUE

		for item in This.List()
			if NOT ( isList(item) and StzListQ(item).IsContiguous() )
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def AllItemsAreContinuousLists()
			return This.AllItemsAreContiguousLists()

	def Classify()

		/* EXAMPLE

		aList = [
			:Arabic,
			:Arabic,
			:French,
			:English,
			:Spanish,
			:Spanish,
			:English,
			:Arabic
		]
		
		StzListQ(aList) {
		 	? Classify()
			#--> [
			# 	:Arabic  = [ 1, 2, 8 ],
			# 	:French  = [ 3 ],
			# 	:Enslish = [ 4, 7 ],
			#    	:Spanish = [ 5, 6 ]
			#    ]
		}
		*/

		aClasses = This.UniqueItems()

		cClass   = ""
		aResult  = []

		for pClass in aCLasses
			anPositions = This.FindAll(pClass)

			cClass = Q(pClass).Stringified()

			aResult + [ cClass, anPositions ]

		next

		return aResult

		#< @FunctionFluentForm

		def ClassifyQ()
			return This.ClassifyQR(:stzList)

		def ClassifyQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classify() )

			on :stzHashList
				return new stzHashList( This.Classify() )

			other
				stzRaise("Unssupported return type!")

			off
		#>

		#< @FunctionAlternativeForms

		def Categorize()
			return This.Classify()

			def CategorizeQ()
				return This.CategorizeQR(:stzList)
	
			def CategorizeQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Categorize() )
	
				on :stzHashList
					return new stzHashList( This.Categorize() )
	
				other
					stzRaise("Unssupported return type!")
	
				off

		def Categorise()
			return This.Classify()

			def CategoriseQ()
				return This.CategoriseQR(:stzList)
	
			def CategoriseQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Categorise() )
	
				on :stzHashList
					return new stzHashList( This.Categorise() )
	
				other
					stzRaise("Unssupported return type!")
	
				off

		#>

	#--

	def Classes()

		aClasses = StzHashListQ( This.Classify() ).Keys()
		return aClasses


		#< @FunctionFluentForm

		def ClassesQ()
			return This.ClassesQR(:stzList)

		def ClassesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classes() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Classes() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		@< @FunctionAlternativeForm

		def Categories()
			return This.Classes()

			def CategoriesQ()
				return This.ClassesQR(:stzList)
	
			def CategoriesQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Categories() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Categories() )
	
				other
					stzRaise("Unsupported return type!")
				off

	#--

	def NumberOfClasses()
		return len( This.Classes() )

		def NumberOfClassesQ()
			return new stzNumber( This.NumberOfClasses() )

		def NumberOfCategories()
			return This.NumberOfClasses()

			def NumberOfCategoriesQ()
				return new stzNumber( This.NumberOfCategories() )

	def Klass(pcClass)
		return This.Classify()[pcClass]

		def KlassQ(pcClass)
			return new stzString(This.Klass(pcClass))

		def Category(pcClass)
			return This.Klass(pcClass)

			def CategoryQ(pcClass)
				return new stzString(This.Category(pcClass))

	def NumberOfOccurrenceOfClass(pcClass)
		nResult = StzListQ( This.Classes() ).NumberOfOccurrence( pcClass )
		return nResult

	def ClassFrequency(pcClass)
		nResult = This.NumberOfOccurrenceOfClass(pcClass) / This.NumberOfClasses()

		def ClassFreq(pcClass)

	def ClassesFrequencies()
		anResult = []
		for cClass in This.Classes()
			anResult + This.ClassFrequency(pcClass)
		next
		return anResult

		def ClassesFreq()
			return This.ClassesFrequencies()

	def ClassesAndTheirFrequencies()
		acClasses 	= This.Classes()
		anFrequencies 	= This.ClassesFrequencies()

		aResult = StzLisQ( acClasses ).AssociatedWith( anFrequencies )

		return aResult

		def ClassesAndTheirFreq()
			return This.ClassesAndTheirFrequencies()

		def ClassesXT()
			return This.ClassesAndTheirFrequencies()

	   #--------------------------------------------------------#
	  #   CLASSIFYING: SPECIEFIC CASE OF LISTS MADE OF LISTS   #
	 #   OF NUMBERS IN WHICH THE _:_ SYNTAX IS PREFERRED      #
	#--------------------------------------------------------#

	# @C prefix is used to say this function returns its
	# result with list of numbers in the _:_ Contiguous
	# List syntax provided by Ring. See example hereafter.

	def Classify@C()	# Specific for lists of lists of numbers
				# Returs classes in the "_:_" syntax
				# @C for Continuous lists
	
		/* EXAMPLE
		o1 = new stzList([
			1:5, 3:9, 1:5, 10:15, 3:9, 12:20, 10:15, 1:5, 12:20
		])
		
		? o1.Classify@C()	# Same as Categorize()
		#--> [
		#	[ "1:5",   [1, 3, 8 ] ],	
		#	[ "3:9",   [2, 5 ] ],
		#	[ "10:15", [4, 7 ] ],
		#	[ "12:20", [6, 9 ]
		#    ]

		*/

		acClasses@C = This.Classes@C()

		aPositions = StzHashListQ( This.Classify() ).Values()

		aResult = StzListQ(acClasses@C).AssociatedWith(aPositions)

		return aResult

		#< @FunctionFluentForm

		def Classify@CQ()
			return This.Classify@CQR(:stzList)

		def Classify@CQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classify@C() )

			on :stzHashList
				return new stzHashList( This.Classify@C() )

			other
				stzRaise("Unssupported return type!")

			off
		#>

		#< @FunctionAlternativeForms

		def Categorize@C()
			return This.Classify@C()

			def Categorize@CQ()
				return This.Categorize@CQR(:stzList)
	
			def Categorize@CQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Categorize@C() )
	
				on :stzHashList
					return new stzHashList( This.Categorize@C() )
	
				other
					stzRaise("Unssupported return type!")
	
				off

		def Categorise@C()
			return This.Classify@C()

			def Categorise@CQ()
				return This.Categorise@CQR(:stzList)
	
			def Categorise@CQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Categorise@C() )
	
				on :stzHashList
					return new stzHashList( This.Categorise@C() )
	
				other
					stzRaise("Unssupported return type!")
	
				off

		#>

	def Classes@C()
		acClasses = This.Classes()

		for cClass in acClasses

			cClass = StzStringQ(cClass).ToListInShortForm()
		next

		return acClasses

		#< @FunctionFluentForm

		def Classes@CQ()
			return This.Classes@CQR(:stzList)

		def Classes@CQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classes@C() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Classes@C() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		@< @FunctionAlternativeForm

		def Categories@C()
			return This.Classes@C()

			def Categories@CQ()
				return This.Classes@CQR(:stzList)
	
			def Categories@CQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Categories@C() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Categories@C() )
	
				other
					stzRaise("Unsupported return type!")
				off

	def Klass@C(pcClass)
		if isString(pcClass) and StzStringQ(pcClass).IsListInShortForm()
			aMembers = StzStringQ(pcClass).SplitQ(":").FirstAndLastItems()

			cMember1 = StzStringQ(aMembers[1]).WithoutSpaces()
			cMember2 = StzStringQ(aMembers[2]).WithoutSpaces()

			cClass = cMember1 + " : " + cMember2

			return This.Classify@C()[cClass]

		ok

		def Klass@CQ(pcClass)
			return new stzString( This.Klass@C(pcClass) )

		def Category@C(pcClass)
			return This.Klass@C(pcClass)

			def Category@CQ(pcClass)
				return new stzString( This.Category@C(pcClass) )

	def NumberOfOccurrenceOfClass@C(pcClass)
		nResult = StzListQ( This.Classes@C() ).NumberOfOccurrence( pcClass )
		return nResult

	def ClassFrequency@C(pcClass)
		nResult = This.NumberOfOccurrenceOfClass@C(pcClass) / This.NumberOfClasses()
		return nResult

		def ClassFreq@C(pcClass)
			return This.ClassFrequency@C(pcClass)

	def ClassesFrequencies@C()
		anResult = []
		for cClass in This.Classes@C()
			anResult + This.ClassFrequency@C(pcClass)
		next
		return anResult

		def ClassesFreq@C()
			return This.ClassesFrequencies@C()

	def ClassesAndTheirFrequencies@C()
		acClasses 	= This.Classes@C()
		anFrequencies 	= This.ClassesFrequencies()

		aResult = StzLisQ( acClasses ).AssociatedWith( anFrequencies )

		return aResult

		def ClassesAndTheirFreq@C()
			return This.ClassesAndTheirFrequencies@C()

		def ClassesXT@C()
			return This.ClassesAndTheirFrequencies@C()

	  #-----------------------------------------------------#
	 #   THE LIST IS MADE OF CONTIGUOUS CHARS OR NUMBERS   #
	#-----------------------------------------------------#

	def IsContiguous()
		bResult = FALSE

		if This.IsListOfNumbers()

			bResult = This.ToStzListOfNumbers().IsContiguous()

		but This.IsListOfChars()
			bResult = This.ToStzListOfChars().IsContiguous()

		ok

		return bResult

		def IsContinuous()
			return IsContiguous()

	  #------------------#
	 #     INDEXING     #
	#------------------#

	def IndexOn(pcOn)
		aResult = []
		if pcOn = :Position

			for item in This.RemoveDuplicates()
				aResult + [ item, This.Positions(item) ]
			next
	
		but pcOn = :NumberOfOccurrence or pcOn = :NumberOfOccurrences
			/* Index( [ "A", "A", "B", "C" ] --> [ :A = 2, :B = 1, :C = 1 ] */
			for item in This.RemoveDuplicates()
				aResult + [ item, This.NumberOfOccurrence(item) ]
			next	
		else
			stzRaise("Unsupported indexing paramater!")
		ok

		return aResult
	
	def Index()
		return IndexOn(:Position)

	def IndexOnPosition()
		return IndexOn(:Position)

	def IndexOnNumberOfOccurrence()
		return IndexOn(:NumberOfOccurrence)

		def IndexOnNumberOfOccurrences()
			return This.IndexOnNumberOfOccurrence()

	  #----------------------------------------#
	 #     COMPARAISON WITH AN OTHER LIST     #
	#----------------------------------------#

	def ContainsSameItemsAs(paOtherList)
		if len( This.DifferentItemsWith(paOtherList) ) = 0
			return TRUE
		else
			return FALSE
		ok

	def DifferenceWith(paOtherList)
		/*
		Returns a list composed of two hashlists:
			[
			:SURPLUS = [ "A", "B", ... ],
			:LACKING = [ "X", "Y", ... ]
			]
		*/
		aResult = [
				:SURPLUS = This.OverItemsComparedTo(paOtherList),
				:LACKING = This.LackingItemsComparedTo(paOtherList)
			  ]

		return aResult

	def DifferentItemsWith(paOtherList)
		aResult = This.OverItemsComparedTo(paOtherList)
		for item in This.LackingItemsComparedTo(paOtherList)
			aResult + item
		next
	
		return aResult

		def DifferentItemsWithQ(paOtherList)
			return new stzList( This.DifferentItemsWith(paOtherList) )

	def OverItemsComparedTo(paOtherList)
		aResult = []

		oOtherList = new stzList(paOtherList)
		for item in This.Content()
			if NOT oOtherList.Contains(item)
				aResult + item
			ok
		next

		return aResult

		def OverItemsComparedToQ(paOtherList)
			return new stzList( This.OverItemsComparedTo(paOtherList) )

	def LackingItemsComparedTo(paOtherList)
		aResult = []

		for item in paOtherList
			if not This.Contains(item)
				aResult + item
			ok
		next item

		return aResult

		def LackingItemsComparedToQ(paOtherList)
			return new stzList( This.LackingItemsComparedTo(paOtherList) )	

	def HasSameNumberOfItemsAs(paOtherList)
		If len(paOtherList) = This.NumberOfItems()
			return TRUE
		else
			return FALSE
		ok

	def CommonItemsWith(paOtherList)
		oTempSet = new stzSet(This.List())
		return oTempSet.IntersectionWith(paOtherList)

		def CommonItemsWithQ(paOtherList)
			return new stzlist( This.CommonItemsWith(paOtherList) )

	def IntersectionWith(paOtherList)
		return This.CommonItemsWith()

		def IntersectionWithQ(paOtherList)
			return new stzlist( This.IntersectionWith(paOtherList) )

	def IntersectionWithMany(paListOfLists)
		oListOfLists = new stzListOfLists( paListOfLists + This.List() )
		return oListOfLists.Intersection()

		def IntersectionWithManyQ(paOtherList)
			return new stzlist( This.IntersectionWithMany(paOtherList) )

	def HasSameWidthAs(paOtherList)
		return HasSameNumberOfItemsAs(paOtherList)

	  #-------------------------#
	 #     SORTING THE LIST    #
	#-------------------------#

	def SortingOrder()
		cResult = :Unsorted

		if This.IsSorted()
			if This.IsSortedInAscending()
				cResult = :Ascending
			else
				cResult = :Descending
			ok
		ok

		return cResult

	def HasSameSortingOrderAs(paOtherList)

		oTemp = new stzList(paOtherList)
		if oTemp.SortingOrder() = This.SortingOrder()
			return TRUE
		else
			return FALSE
		ok

		def HasSameOrderAs(paOtherList)
			return This.HasSameSortingOrderAs(paOtherList)

	def IsSorted()
		if This.IsSortedInAscending() or
		   This.IsSortedInDescending()
			return TRUE
		else
			return FALSE
		ok

		def ItemsAreSorted()
			return This.IsSorted()

	def IsSortedInAscending()
		/*
		The idea is to sort a copy of the list in ascending order
		and then compare the copy to the original list...
		If they are identical, then the list is sorted in ascending order!
		*/

		oSortedInAscending = This.Copy().SortInAscendingQ()

		for i = 1 to This.NumberOfItems()
			if NOT AreEqual([ oSortedInAscending[i] , This[i] ])
				return FALSE
			ok
		next

		return TRUE

		def ItemsAreSortedInAscending()
			return This.IsSortedInAscending()

	def IsSortedInDescending()
		/*
		The idea is to reverse the list, and check if its reversed
		copy is sorted in ASCENDING order. If so, then the list itself
		is actually sorted in DESCENDING order!
		*/
		oTemp = new stzlist( This.ReversedItems() )
		if oTemp.IsSortedInAscending()
			return TRUE
		else
			return FALSE
		ok

		def ItemsAreSortedInDescending()
			return This.IsSortedInDescending()

	def IsUnsorted()
		return NOT This.IsSorted()

		def ItemsAreUnSorted()
			return This.IsUnsorted()

		def IsNotSorted()
			return NOT This.IsUnsorted()

		def ItemsAreNotSorted()
			return NOT This.IsUnsorted()


	def SortableItems()
		/*
		Only numbers, strings, stzNumbers, and stzStrings are sortable.

		Means that lists and objects (other then stzNumber and stzString objects)
		are not sortable!

		NB: This may change in the future and other types become sortable.

		*/
		aResult = []
		for item in Content()
			if isNumber(item) or isString(item) or
			   isStzNumber(item) or isStzString(item)
				aResult + item
			ok
		next
		return aResult

	def UnsortableItems()
		/* Should be resolved by saying:
			return (This - SortableItems()).Content()

		   but this yields an error (check it!)

		  That's why, we used a more secure code, in anology to
		  the code of SortableItems()
		*/
		aResult = []
		for item in Content()
			if isNumber(item) or isString(item) or
			   isStzNumber(item) or isStzString(item)
				// do nothing, skip!
			else
				aResult + item
			ok
		next
		return aResult

	def SortInAscending()
		/*
		Ring native sort() function can sort a list made:
			- only of numbers
			- or only of strings.

		In sofanza a list is sorted by applying 4 steps:
			1- numbers are sorted first and put at the beginning
			2- then strings are sorted and put after numbers
			3- then lists are added after strings (if any) in
			  their order of appearance
			4- then objects are added after lists (if any) in
			  their order of appearance

			NOTE: 3 and 4 steps could change in the future when
			Softanza becomes able to sort even lists  and objects!
		*/

		aNumbers = sort( This.OnlyNumbers() )

		aStrings = sort( This.OnlyStrings() )

		aLists = This.OnlyLists()

		aObjects = This.OnlyObjects()

		aResult = ListsMerge([ aNumbers, aStrings, aLists, aObjects ])

		This.Update( aResult )

		def SortInAscendingQ()
			This.SortInAscending()
			return This
			
	def SortedInAscending()
		aResult = This.Copy().SortInAscendingQ().Content()
		return aResult

		def Sorted()
			return This.SortedInAscending()

	def SortInDescending()
 		aResult = This.SortInAscendingQ().Content()
		This.Update( ListReverse(aResult) )

		def SortInDescendingQ()
			This.SortInDescending()
			return This
			
	def SortedInDescending()
		aResult = This.Copy().SortInDescendingQ().Content()
		return aResult

	  #---------------------------------------#
	 #     ASSOCIATE WITH AN ANOTHER LIST    #
	#---------------------------------------#

	// Returns an Associative List (HashList) from the main list and an other list

	def AssociateWith(paOtherList)
		aResult = []
		for i = 1 to This.NumberOfItems()
			OtherItem = NULL
			if i <= len(paOtherList)
				OtherItem = paOtherList[i]
			ok

			aResult + [ This[i], OtherItem ]
		next

		This.Update( aResult )

		/*
			Example:
			o1 = new stzList([ "Name", "Age", "Job" ])
			o1.AssociateWith([ "Ali", 24, "Programmer" ])
			? o1.Content()

			Returns:
			[ "Name" = "Ali", "Age" = 24, "Job" = "Programmer" ]

			TEST: What idf the first list contains items that are not strings?
			This leads to a ListOfLists but not to a HashList!
		*/

		def AssociateWithQ(paOtherList)
			This.AssociateWith(paOtherList)
			return This

	def AssociatedWith(paOtherList)
		aResult = This.Copy().AssociateWithQ(paOtherList).Content()
		return aResult

	  #----------------------------#
	 #   REPEATED LEADING ITEMS   #
	#----------------------------#

	def HasRepeatedLeadingItems()
		if StzListQ(This.RepeatedLeadingItems()).IsEmpty()
			return FALSE
		else
			return TRUE
		ok

		def HasLeadingRepeatedItems()
			return This.HasRepeatedLeadingItems()

		def HasLeadingItems()
			return This.HasRepeatedLeadingItems()
	
	def HasRepeatedTrailingItems()
		if StzListQ(This.RepeatedTrailingItems()).IsEmpty()
			return FALSE
		else
			return TRUE
		ok

		def HasTrailingRepeatedItems()
			return This.HasRepeatedTrailingItems()

		def HasTrailingItems()
			return This.HasRepeatedTrailingItems()
	
	def RepeatedLeadingItems() # Same item is repeated at the start of the list

		/* Example:
			[ 'e', 'e', 'e', 'T', 'U', 'N', 'I', 'S' ]
			--> ['e','e','e']

			[ 'e', 'x', 'e', 'e', 'e', 'T', 'U', 'N', 'I', 'S' ]
			--> []
		*/

		if NOT This.IsEmpty()
			cResult = ""
	
			i = 1
			while This[i] = This[1] and i <= This.NumberOfItems()
				i++
			end

			if i > 2
				return This.NFirstItems(i-1)
			ok
		ok

		def RepeatedLeadingItemsQ()
			return new stzList( This.RepeatedLeadingItems() )
	
		def LeadingRepeatedItems()
			return This.RepeatedLeadingItems()

			def LeadingRepeatedItemsQ()
				return new stzList( This.LeadingRepeatedItems() )
	
		def LeadingItems()
			return This.RepeatedLeadingItems()

			def LeadingItemsQ()
				return new stzList( This.LeadingItems() )
	
	def RepeatedLeadingItem()
		if This.HasRepeatedLeadingItems()
			return This[1]
		ok

		def RepeatedLeadingItemQ()
			return Q(This.RepeatedLeadingItem())
	
		def LeadingRepeatedItem()
			return This.RepeatedLeadingItem()

			def LeadingRepeatedItemQ()
				return Q(This.LeadingRepeatedItem())
	
		def LeadingItem()
			return This.RepeatedLeadingItem()

			def LeadingItemQ()
				return Q(This.LeadingItem())
	
	def NumberOfRepeatedLeadingItems()
		if This.HasRepeatedLeadingItems()
			return StzListQ( This.RepeatedLeadingItems() ).NumberOfItems()
		else
			return 0
		ok

		def NumberOfLeadingRepeatedItems()
			return This.NumberOfRepeatedLeadingItems()

		def NumberOfLeadingItems()
			return This.NumberOfRepeatedLeadingItems()
	
	def RepeatedLeadingItemIs(pItem)
		if This.HasRepeatedLeadingItems() and This.FirstItemQ().IsEqualTo(pItem)
			return TRUE
		else
			return FALSE
		ok

		def LeadingRepeatedItemIs(pItem)
			return This.RepeatedLeadingItemIs(pItem)

		def LeadingItemIs(pItem)
			return This.RepeatedLeadingItemIs(pItem)
	
	  #-----------------------------#
	 #   REPEATED TRAILING ITEMS   #
	#-----------------------------#

	def RepeatedTrailingItem()
		if This.HasRepeatedTrailingItems()
			return This.LastItem()
		ok

		def RepeatedTrailingItemQ()
			return Q(This.RepeatedTrailingItem())

		def TrailingRepeadtedItem()
			return This.RepeatedTrailingItem()

			def TrailingRepeatedItemQ()
				return Q(This.TrailingRepeadtedItem())

		def TrailingItem()
			return This.RepeatedTrailingItem()

			def TrailingItemQ()
				return Q(This.TrailingItem())
	
	def RepeatedTrailingItems()
		aResult = This.Copy().ReverseItemsQ().RepeatedLeadingItems()
		return aResult

		def RepeatedTrailingItemsQ()
			return new stzList(This.RepeatedTrailingItems())
	
		def TrailingRepeatedItems()
			return This.RepeatedTrailingItems()

			def TrailingRepeatedItemsQ()
				return new stzList(This.TrailingRepeatedItems())
	
		def TrailingItems()
			return This.RepeatedTrailingItems()

			def TrailingItemsQ()
				return new stzList(This.TrailingItems())

	def NumberOfRepeatedTrailingItems()
		if This.HasRepeatedTrailingItems()
			return stzListQ( This.RepeatedTrailingItems() ).NumberOfItems()
		else
			return 0
		ok

		def NumberOfTrailingRepeatedItems()
			return This.NumberOfRepeatedTrailingItems()

		def NumberOfTrailingItems()
			return This.NumberOfRepeatedTrailingItems()
	
	def RepeatedTrailingItemIs(pItem)
		if This.HasRepeatedLeadingItems() and This.LastItemQ().IsEqualTo(pItem)
			return TRUE
		else
			return FALSE
		ok

		def TrailingRepeatedItemIs(pItem)
			return This.RepeatedTrailingItemIs(pItem)

		def TrailingItemIs(pItem)
			return This.RepeatedTrailingItemIs(pItem)
	
	  #-------------------------------------#
	 #   REMOVING REPEATED LEADING ITEMS   #
	#-------------------------------------#

	def RemoveRepeatedLeadingItems()
		if This.HasRepeatedLeadingItems()
			This.RemoveFirstNItems( This.NumberOfRepeatedLeadingItems() )
		ok

		def RemoveRepeatedLeadingItemsQ()
			This.RemoveRepeatedLeadingItems()
			return This

		def RemoveLeadingRepeatedItems()
			This.RemoveRepeatedLeadingItems()

			def RemoveLeadingRepeatedItemsQ()
				This.RemoveLeadingRepeatedItems()
				return This
	
		def RemoveLeadingItems()
			This.RemoveRepeatedLeadingItems()

			def RemoveLeadingItemsQ()
				This.RemoveLeadingItems()
				return This
	
	def RepeatedLeadingItemsRemoved()
		aResult = This.Copy().RemoveRepeatedLeadingItemsQ().Content()
		return aResult

		def LeadingRepeatedItemsRemoved()
			return This.RepeatedLeadingItemsRemoved()

		def LeadingItemsRemoved()
			return This.RepeatedLeadingItemsRemoved()
	
	def RemoveRepeatedLeadingItem(pItem)
		if This.RepeatedLeadingItemQ().IsEqualTo(pItem)
			return This.RemoveRepeatedLeadingItems()
		ok

		def RemoveRepeatedLeadingItemQ(pItem)
			This.RemoveRepeatedLeadingItem(pItem)
			return This

		def RemoveLeadingRepeatedItem(pItem)
			This.RemoveRepeatedLeadingItem(pItem)

			def RemoveLeadingRepeatedItemQ(pItem)
				This.RemoveLeadingRepeatedItem(pItem)
				return This
	
		def RemoveLeadingItem(pItem)
			This.RemoveRepeatedLeadingItem(pItem)

			def RemoveLeadingItemQ(pItem)
				This.RemoveLeadingItem(pItem)
				return This
	
	def RepeatedLeadingItemRemoved(pItem)
		aResult = This.Copy().RemoveRepeatedLeadingItemQ(pItem).Content()
		return aResult

		def LeadingRepeatedItemRemoved(pItem)
			return This.RepeatedLeadingItemRemoved(pItem)

		def LeadingItemRemoved(pItem)
			return This.RepeatedLeadingItemRemoved(pItem)

	  #--------------------------------------#
	 #   REMOVING REPEATED TRAILING ITEMS   #
	#--------------------------------------#

	def RemoveRepeatedTrailingItems()
		if This.HasRepeatedTrailingItems()
			This.RemoveLastNItems( This.NumberOfRepeatedTrailingItems() )
		ok

		def RemoveRepeatedTrailingItemsQ()
			This.RemoveRepeatedTrailingItems()
			return This
	
		def RemoveTrailingRepeatedItems()
			This.RemoveRepeatedTrailingItems()

			def RemoveTrailingRepeatedItemsQ()
				This.RemoveTrailingRepeatedItems()
				return This
	
		def RemoveTrailingItems()
			This.RemoveRepeatedTrailingItems()

			def RemoveTrailingItemsQ()
				This.RemoveTrailingItems()
				return This
	
	def RepeatedTrailingItemsRemoved()
		aResult = This.Copy().RemoveRepeatedTrailingItemsQ().Content()
		return aResult

		def TrailingRepeatedItemsRemoved()
			This.RepeatedTrailingItemsRemoved()

		def TrailingItemsRemoved()
			This.RepeatedTrailingItemsRemoved()
	
	def RemoveRepeatedTrailingItem(pItem)
		if This.RepeatedTrailingItemQ().IsEqualTo(pItem)
			This.RemoveRepeatedTrailingItems()
		ok

		def RemoveRepeatedTrailingItemQ(pItem)
			This.RemoveRepeatedTrailingItem(pItem)
			return This
	
		def RemoveTrailingRepeatedItem(pItem)
			This.RemoveRepeatedTrailingItem(pItem)

			def RemoveTrailingRepeatedItemQ(pItem)
				This.RemoveTrailingRepeatedItem(pItem)
				return This
	
		def RemoveTrailingItem(pItem)
			This.RemoveRepeatedTrailingItem(pItem)

			def RemoveTrailingItemQ(pItem)
				This.RemoveTrailingItem(pItem)
				return This
	
	def RepeatedTrailingItemRemoved(pItem)
		aResult = This.Copy().RemoveRepeatedTrailingItemQ(pItem).Content()
		return aResult

		def TrailingRepeatedItemRemoved(pItem)
			return This.RepeatedTrailingItemRemoved(pItem)

		def TrailingItemRemoved(pItem)
			return This.RepeatedTrailingItemRemoved(pItem)
	
	  #--------------------------------------------------#
	 #   REMOVING REPEATED LEADING AND TRAILING ITEMS   #
	#--------------------------------------------------#

	def RemoveRepeatedLeadingItemAndTrailingItem(pItem1, pItem2)
		This.RemoveRepeatedLeadingItem(pItem1)
		This.RemoveRepeatedTrailingItem(pItem2)

		def RemoveRepeatedLeadingcharAndTrailingItemQ(pItem1, pItem2)
			This.RemoveRepeatedLeadingItemAndTrailingItem(pItem1, pItem2)
			return This

		def RemoveLeadingItemAndTrailingItem(pItem1, pItem2)
			This.RemoveRepeatedLeadingItemAndTrailingItem(pItem1, pItem2)

			def RemoveLeadingItemAndTrailingItemQ(pItem1, pItem2)
				This.RemoveLeadingItemAndTrailingItem(pItem1, pItem2)
				return This
	
		def RemoveTrailingItemAndLeadingItem(pItem1, pItem2)
			This.RemoveRepeatedLeadingItemAndTrailingItem(pItem1, pItem2)

			def RemoveTrailingItemAndLeadingItemQ(pItem1, pItem2)
				This.RemoveTrailingItemAndLeadingItem(pItem1, pItem2)
				return This
	
	def RepeatedLeadingItemAndTrailingItemRemoved(pItem1, pItem2)
		aResult = This.Copy().RemoveRepeatedLeadingItemAndTrailingItemQ(pItem1, pItem2).Content()
		return aResult

		def RepeatedTrailingItemAndLeadingItemRemoved(pItem1, pItem2)
			return This.RepeatedLeadingItemAndTrailingItemRemoved(pItem1, pItem2)

		def LeadingItemAndTrailingItemRemoved(pItem1, pItem2)
			return This.RepeatedLeadingItemAndTrailingItemRemoved(pItem1, pItem2)

		def TrailingItemAndLeadingItemRemoved(pItem1, pItem2)
			return This.RepeatedLeadingItemAndTrailingItemRemoved(pItem1, pItem2)
	
	def RemoveRepeatedLeadingAndTrailingItems()
		This.RemoveRepeatedLeadingItems()
		This.RemoveRepeatedTrailingItems()

		def RemoveRepeatedLeadingAndTrailingItemsQ()
			This.RemoveRepeatedLeadingAndTrailingItems()
			return This
	
		def RemoveLeadingAndTrailingRepeatedItems()
			This.RemoveRepeatedLeadingAndTrailingItems()

			def RemoveLeadingAndTrailingRepeatedItemsQ()
				This.RemoveLeadingAndTrailingRepeatedItems()
				return This
	
	def RepeadtedLeadingAndTrailingItemsRemoved()
		aResult = This.Copy().RemoveRepeatedLEadingAndTrailingItems()
		return aResult

		def RepeadtedTrailingAndLeadingItemsRemoved()
			return This.RepeadtedLeadingAndTrailingItemsRemoved()

		def LeadingAndTrailingItemsRemoved()
			return This.RepeadtedLeadingAndTrailingItemsRemoved()

		def TrailingAndLeadingItemsRemoved()
			return This.RepeadtedLeadingAndTrailingItemsRemoved()
	
	  #-----------------------------#
	 #   REPLACING LEADING ITEMS   #
	#-----------------------------#

	def ReplaceRepeatedLeadingItemWith(pItem)
		/* Example:

		StzListQ([ '_', '_', '_', 'V', 'A', 'R', '-', '-', '-' ]).ReplaceRepeatedLeadingItemWith("-")

		--> Gives: [ '-', '-', '-', 'V', 'A', 'R', '-', '-', '-' ]
		*/

		if This.HasRepeatedLeadingItems()
			n = This.NumberOfRepeatedLeadingItems()

			for i = 1 to n
				This.ReplaceItemAtPosition(i, :With = pItem)
			next

		ok

		def ReplaceRepeatedLeadingItemWithQ(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)
			return This

		def ReplaceRepeatedLeadingItemBy(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceRepeatedLeadingItemByQ(pItem)
				This.ReplaceRepeatedLeadingItemBy(pItem)
				return This
					
		def ReplaceLeadingRepeatedItemWith(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceLeadingRepeatedItemWithQ(pItem)
				This.ReplaceLeadingRepeatedItemWith(pItem)
				return This

			def ReplaceLeadingRepeatedItemBy(pItem)
				This.ReplaceLeadingRepeatedItemWith(pItem)

				def ReplaceLeadingRepeatedItemByQ(pItem)
					This.ReplaceLeadingRepeatedItemBy(pItem)
					return This
						
		def ReplaceLeadingRepeatedItemsWith(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceLeadingRepeatedItemsWithQ(pItem)
				This.ReplaceLeadingRepeatedItemsWith(pItem)
				return This
		
			def ReplaceLeadingRepeatedItemsBy(pItem)
				This.ReplaceLeadingRepeatedItemsWith(pItem)

				def ReplaceLeadingRepeatedItemsByQ(pItem)
					This.ReplaceLeadingRepeatedItemsBy(pItem)
					return This
	
		def ReplaceLeadingItemWith(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceLeadingItemWithQ(pItem)
				This.ReplaceLeadingItemWith(pItem)
				return This
		
			def ReplaceLeadingItemBy(pItem)
				This.ReplaceLeadingItemWith(pItem)

				def ReplaceLeadingItemByQ(pItem)
					This.ReplaceLeadingItemBy(pItem)
					return This
	
		def ReplaceRepeatedLeadingItemsWith(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceRepeatedLeadingcharsWithQ(pItem)
				This.ReplaceRepeatedLeadingItemsWith(pItem)
				return This
		
			def ReplaceRepeatedLeadingItemsBy(pItem)
				This.ReplaceRepeatedLeadingItemsWith(pItem)

				def ReplaceRepeatedLeadingcharsByQ(pItem)
					This.ReplaceRepeatedLeadingItemsBy(pItem)
					return This
		
		def ReplaceLeadingItemsWith(pItem)
			This.ReplaceRepeatedLeadingItemWith(pItem)

			def ReplaceLeadingItemsWithQ(pItem)
				This.ReplaceLeadingItemsWith(pItem)
				return This
		
			def ReplaceLeadingItemsBy(pItem)
				This.ReplaceLeadingItemsWith(pItem)

				def ReplaceLeadingItemsByQ(pItem)
					This.ReplaceLeadingItemsWith(pItem)
					return This
	
	def RepeatedLeadingItemReplacedWith(pItem)
		aRresult = This.Copy().ReplaceRepeatedLeadingItemWithQ(pItem).Content()
		return aResult

		def RepeatedLeadingItemReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)

		def LeadingRepeatedItemReplacedWith(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingRepeatedItemReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingItemReplacedWith(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingItemReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
			
		def RepeatedLeadingItemsReplacedWith(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def RepeatedLeadingItemsReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingRepeatedItemsReplacedWith(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingRepeatedItemsReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingItemsReplacedWith(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
		
		def LeadingItemsReplacedBy(pItem)
			return This.RepeatedLeadingItemReplacedWith(pItem)
				
	  #------------------------------#
	 #   REPLACING TRAILING ITEMS   #
	#------------------------------#

	def ReplaceRepeatedTrailingItemWith(pItem)
		/* Example:

		stzListQ([ "_","_","_","V","A","R","-","-","-" ]).ReplaceRepeatedTrailingItemBy("_")

		Give --> [ "_","_","_","V","A","R","_","_","_" ]
		*/

		if This.HasRepeatedTrailingItems()
			n = This.NumberOfRepeatedTrailingItems()

			n = This.NumberOfItems() - n + 1
			for i = n to This.NumberOfItems()
				This.ReplaceItemAtPosition(i, :With = pItem)
			next

		ok

		def ReplaceRepeatedTrailingItemWithQ(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)
			return This
	
		def ReplaceRepeatedTrailingItemBy(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceRepeatedTrailingItemByQ(pItem)
				This.ReplaceRepeatedTrailingItemBy(pItem)
				return This
	
		def ReplaceTrailingRepeatedItemWith(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceTrailingRepeatedItemWithQ(pItem)
				This.ReplaceTrailingRepeatedItemWith(pItem)
				return This
	
		def ReplaceTrailingRepeatedItemBy(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceTrailingRepeatedItemByQ(pItem)
				This.ReplaceTrailingRepeatedItemBy(pItem)
				return This				
	
		def ReplaceTrailingItemWith(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceTrailingItemWithQ(pItem)
				This.ReplaceTrailingItemWith(pItem)
				return This
	
		def ReplaceTrailingItemBy(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceTrailingItemByQ(pItem)
				This.ReplaceTrailingItemBy(pItem)
				return This
	
		def ReplaceRepeatedTrailingItemsWith(pItem)
			This.ReplaceRepeatedTrailingItemWith(pItem)

			def ReplaceRepeatedTrailingItemsWithQ(pItem)
				This.ReplaceRepeatedTrailingItemsWith(pItem)
				return This
		
			def ReplaceRepeatedTrailingItemsBy(pItem)
				This.ReplaceRepeatedTrailingItemsWith(pItem)

				def ReplaceRepeatedTrailingItemsByQ(pItem)
					This.ReplaceRepeatedTrailingItemsBy(pItem)
					return This
		
			def ReplaceTrailingRepeatedItemsWith(pItem)
				This.ReplaceRepeatedTrailingItemsWith(pItem)

				def ReplaceTrailingRepeatedItemsWithQ(pItem)
					This.ReplaceTrailingRepeatedItemsWith(pItem)
					return This
		
			def ReplaceTrailingRepeatedItemsBy(pItem)
				This.ReplaceRepeatedTrailingItemsWith(pItem)

				def ReplaceTrailingRepeatedItemsByQ(pItem)
					This.ReplaceTrailingRepeatedItemsBy(pItem)
					return This
	
	def RepeatedTrailingItemReplacedWith(pItem)
		aResult = This.Copy().ReplaceRepeatedTrailingItemWithQ(pItem).Content()
		return aResult

		def RepeatedTrailingItemReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingRepeatedItemReplacedWith(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingRepeatedItemReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingItemReplacedWith(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingItemReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)
	
		def RepeatedTrailingItemsReplacedWith(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def RepeatedTrailingItemsReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingRepeatedItemsReplacedWith(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingRepeatedItemsReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingItemsReplacedWith(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)

		def TrailingItemsReplacedBy(pItem)
			return This.RepeatedTrailingItemReplacedWith(pItem)
	
	  #---------------------------------------------------#
	 #   REPLACING REPEATED LEADING AND TRAILING ITEMS   #
	#---------------------------------------------------#

	def ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)
		This.ReplaceRepeatedLeadingItemWith(pItem1)
		This.ReplaceRepeatedTrailingItemWith(pItem2)

		def ReplaceRepeatedLeadingItemAndTrailingItemWithQ(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)
			return This
	
		def ReplaceRepeatedLeadingItemAndTrailingItemBy(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceRepeatedLeadingItemAndTrailingItemByQ(pItem1, pItem2)
				This.ReplaceRepeatedLeadingItemAndTrailingItemBy(pItem1, pItem2)
				return This

		def ReplaceRepeatedTrailingItemAndLeadingItemWith(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceRepeatedTrailingItemAndLeadingItemWithQ(pItem1, pItem2)
				This.ReplaceRepeatedTrailingItemAndLeadingItemWith(pItem1, pItem2)
				return This

		def ReplaceRepeatedTrailingItemAndLeadingItemBy(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceRepeatedTrailingItemAndLeadingItemByQ(pItem1, pItem2)
				This.ReplaceRepeatedTrailingItemAndLeadingItemBy(pItem1, pItem2)
				return This
	
		def ReplaceLeadingItemAndTrailingItemWith(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceLeadingItemAndTrailingItemWithQ(pItem1, pItem2)
				This.ReplaceLeadingItemAndTrailingItemWith(pItem1, pItem2)
				return This
	
		def ReplaceLeadingItemAndTrailingItemBy(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceLeadingItemAndTrailingItemByQ(pItem1, pItem2)
				This.ReplaceLeadingItemAndTrailingItemBy(pItem1, pItem2)
				return This
	
		def ReplaceTrailingItemAndLeadingItemWith(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceTrailingItemAndLeadingItemWithQ(pItem1, pItem2)
				This.ReplaceTrailingItemAndLeadingItemWith(pItem1, pItem2)
				return This
	
		def ReplaceTrailingItemAndLeadingItemBy(pItem1, pItem2)
			This.ReplaceRepeatedLeadingItemAndTrailingItemWith(pItem1, pItem2)

			def ReplaceTrailingItemAndLeadingItemByQ(pItem1, pItem2)
				This.ReplaceTrailingItemAndLeadingItemBy(pItem1, pItem2)
				return This
	
	def RepeatedLeadingcharAndTrailingItemReplacedWith(pItem1, pItem2)
		aResult = This.Copy().ReplaceRepeatedLeadingItemAndTrailingItemWithQ(pItem1, pItem2).Content()
		return aResult

		def RepeatedLeadingItemAndTrailingItemReplacedBy(pItem1, pItem2)
			return This.RepeatedLeadingcharAndTrailingItemReplacedWith(pItem1, pItem2)
	
		def LeadingItemAndTrailingItemReplacedWith(pItem1, pItem2)
			return This.RepeatedLeadingcharAndTrailingItemReplacedWith(pItem1, pItem2)

			def LeadingItemAndTrailingItemReplacedBy(pItem1, pItem2)
				return This.LeadingItemAndTrailingItemReplacedWith(pItem1, pItem2)
	
		def RepeadtedTrailingItemAndLeadingItemReplacedWith(pItem1, pItem2)
			This.RepeatedLeadingcharAndTrailingItemReplacedWith(pItem1, pItem2)

			def RepeadtedTrailingItemAndLeadingItemReplacedBy(pItem1, pItem2)
				return This.RepeadtedTrailingItemAndLeadingItemReplacedWith(pItem1, pItem2)
	
		def TrailingItemAndLeadingItemReplacedWith(pItem1, pItem2)
			This.RepeatedLeadingcharAndTrailingItemReplacedWith(pItem1, pItem2)

			def TrailingItemAndLeadingItemReplacedBy(pItem1, pItem2)
				return This.TrailingItemAndLeadingItemReplacedWith(pItem1, pItem2)
	
	def ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)
		This.ReplaceRepeatedLeadingItemWith(pItem)
		This.ReplaceRepeatedTrailingItemWith(pItem)

		def ReplaceRepeatedLeadingAndTrailingItemsWithQ(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)
			return This
	
		def ReplaceRepeatedLeadingAndTrailingItemsBy(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)

			def ReplaceRepeatedLeadingAndTrailingItemsByQ(pItem)
				This.ReplaceRepeatedLeadingAndTrailingItemsBy(pItem)
				return This
	
		def ReplaceLeadingAndTrailingItemsWith(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)

			def ReplaceLeadingAndTrailingItemsWithQ(pItem)
				This.ReplaceLeadingAndTrailingItemsWith(pItem)
				return This
	
		def ReplaceRepeatedTrailingAndLeadingItemsWith(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)

			def ReplaceRepeatedTrailingAndLeadingItemsWithQ(pItem)
				This.ReplaceRepeatedTrailingAndLeadingItemsWith(pItem)
				return This
	
		def ReplaceLeadingAndTrailingItemsBy(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)

			def ReplaceLeadingAndTrailingItemsByQ(pItem)
				This.ReplaceLeadingAndTrailingItemsBy(pItem)
				return This
	
		def ReplaceTrailingAndLeadingItemsWith(pItem)
			This.ReplaceRepeatedLeadingAndTrailingItemsWith(pItem)

			def ReplaceTrailingAndLeadingItemsWithQ(pItem)
				This.ReplaceTrailingAndLeadingItemsWith(pItem)
				return This
	
	def RepeatedLeadingAndTrailingItemsReplacedWith(pItem)
		aResult = This.Copy().ReplaceRepeatedLeadingAndTrailingItemsWithQ(pItem).Content()
		return aRresult

		def RepeatedLeadingAndTrailingItemsReplacedBy(pItem)
			return This.RepeatedLeadingAndTrailingItemsReplacedWith(pItem)

		def RepeatedTrailingAndLeadingItemsReplacedWith(pItem)
			return This.RepeatedLeadingAndTrailingItemsReplacedWith(pItem)

			def RepeatedTrailingAndLeadingItemsReplacedBy(pItem)
				return This.RepeatedTrailingAndLeadingItemsReplacedWith(pItem)
	
		def LeadingAndTrailingItemsReplacedWith(pItem)
			return This.RepeatedLeadingAndTrailingItemsReplacedWith(pItem)

			def LeadingAndTrailingItemsReplacedBy(pItem)
				return This.LeadingAndTrailingItemsReplacedWith(pItem)
	
		def TrailingAndLeadingItemsReplacedWith(pItem)
			return This.RepeatedLeadingAndTrailingItemsReplacedWith(pItem)

			def TrailingAndLeadingItemsReplacedBy(pItem)
				return This.TrailingAndLeadingItemsReplacedWith(pItem)

	  #------------------------------#
	 #     OPERATORS OVERLOADING    #
	#------------------------------#

	/*
		TODO: Operators should carry same semantics in all classes...
	*/

	def operator(pcOp, pValue)
		
		if pcOp = "[]"

			if isNumber(pValue)
				return Item(pValue)

			but isString(pValue) and
			    StzStringQ(pValue).SimplifyQ().IsBoundedBy("{","}")

				pcCondition = StzStringQ(pValue).SimplifyQ().BoundsRemoved("{","}")
				anResult = []

				@i = 0
				for @item in This.List()
					@i++
					cCode = 'if ( ' + pcCondition + ' )' + NL +
						'	anResult + @i' + NL +
						'ok'
					eval(cCode)
				next

				return anResult
			else
				return This.FindAll(pValue)
			ok	
			
		// Add an item at the beginning of the list
		but pcOp = "<<"
			This.InsertBeforePosition(1)

		// Add an item at the end of the list
		but pcOp = ">>"
			This.Add(value)

		but pcOp = "="
			return This.IsEqualTo(value)

		but pcOp = "=="
			return This.IsStrictlyEqualTo(value)

		but pcOp = "/" and type(pValue) = "NUMBER"
			// Divides the list on pValue sublists (a list of lists)
			return This.SplitToNParts(pValue)

		but pcOp = "-"
			if isNumber(pValue) or isString(pValue)
				This.RemoveItemAtPositionQ( find(This.List(), pValue) )

			ok

			if StzListQ(pValue).IsListOfLists() and len(pValue) = 1
				
				/*
				Example:

				o1 = new stzList([ 5, 7, 3, 0 ])
				o1 - [[ :LastItemIf, :EqualTo, 0 ]]

				Gives -> [ 5, 7, 3 ]

				NB: We use the two brackets here to differenciate
				the syntax from when we use only one bracket:

					 o1 - [ 0, 3, 7 ] --> [ 5 ]

				which means : remove these items from the main list
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
					
				if cFirstOrLast = :FirstItemIf

					if cCondition = :EqualTo
						if IsNumberOrString(value)
							if This.FirstItem() = value
								This.RemoveFirstItem()
							ok

						but isList(value)
							oList = value
							if oList.IsEqualTo(cFirstOrLast)
								This.RemoveFirstItem()
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

				but cFirstOrLast = :LastItemIf

					if cCondition = :EqualTo
						if IsNumberOrString(value)
							if This.LastItem() = value
								This.RemoveLastItem()
							ok

						but isList(value)
							oList = value
							if value.IsEqualTo(cFirstOrLast)
								This.RemoveLastItem()
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

			# if we whave this syntax: o1 - [ 5, 3 ]

			if isList(pValue)
				if len(pValue) > 0
					anPositions = This.FindMany(pValue)
					This.RemoveManyAtPositions(anPositions)
				ok
			ok

		but pcOp = "*"
			This.MultiplyBy(pValue)

		but pcOp = "+"
			This.AddItem(pValue)
		ok

	  #------------------------------#
	 #     CALCULATION OPERATORS    #
	#------------------------------#

	def MultiplyBy(p)	// TODO
		switch type(p)
		on "NUMBER"
			aResult = []

			for i = 1 to p
				aResult + This.List()
			next

			This.Update( aResult )

		on "STRING"
			for item in This.List()
				if isString(item)
					item += p

				but isNumber(item)
					for i = 1 to p-1
						item += item
					next

				but isList(item)
					item = StzListQ(item) * p
				ok
			next

		on "LIST"
			// TODO

		other
			// TODO
		off

		#< @FunctionFluentForm

		def MultiplyByQ(p)
			This.MultiplyBy(p)
			return This

		#>

		#< @FunctionAlternativeForm

		def Multiply(p)
			This.MultiplyWith(p)

		#>

	def ItemsInPositions(panPositions)
		aResult = []
		for n in panPositions
			aResult + This.Item(n)
		next

		return aResult

		def ItemsInPositionsQ(panPositions)
			return new stzList( This.ItemsInPositions(panPositions) ) 

	def Minus(paOtherList)
		/*
		Example:
		o1 = new stzList([ "a", "b", "b", "b", "c" ])
		? o1 - [ "b", "b" ] -->  [ "a", "b", "c" ]
		*/
		aTempList = This.List()
		for item in paOtherList
			del(aTempList, find(aTempList, item))
		next

		This.Update( aTempList )

		def MinusQ(paOtherList)
			This.Minus(paOtherList)
			return This

	  #---------------------------#
	 #     EXTENDING THE LIST    #
	#---------------------------#

	def ExtendToPosition(n)
		if This.ContainsOnlyNumbers()
			This.ExtendToPositionNWith(n,0)
		else
			This.ExtendToPositionNWith(n,NULL)
		ok

		def ExtendToPositionQ(n)
			This.ExtendToPosition(n)
			return This
	
	def ExtendToN(n)
		This.ExtendToPosition(n)

		def ExtendToNQ(n)
			This.ExtendToN(n)
			return This
	
	def ExtendToPositionNWith(n, pItem)

		if n <= This.NumberOfItems()
			stzRaise(stzListError(:CanNotExtendTheList))

		else
			for i = This.NumberOfItems()+1 to n
				This + pItem
			next
		ok

		def ExtendToPositionNWithQ(n, pItem)
			This.ExtendToPositionNWith(n, pItem)
			return This
	
	def ExtendToNWith(n, pItem)
		This.ExtendToPositionNWith(n, pItem)

		def ExtendToNWithQ(n, pItem)
			This.ExtendToNWith(n, pItem)
			return This
	
	// Extending a list with the items of an other list
	def ExtendWithOtherList(paOtherList)
		// The main list is extended with the other list

		if type(paOtherList) = "LIST"
			
			for item in paOtherList
				This.AddItem(item)
			next

		else
			stzRaise("paOtherList must be of type LIST!")
		ok

		def ExtendWithOtherListQ(paOtherList)
			This.ExtendWithOtherList(paOtherList)
			return This
	
	def ExtendWith(paOtherList)
		This.ExtendWithOtherList(paOtherList)

		def ExtendWithQ(paOtherList)
			This.ExtendWith(paOtherList)
			return This
	
	def ExtendWithMany(paManyOtherLists)
		for aList in paManyOtherLists
			for item in aList
				This.Add(item)
			next
		next

		def ExtendWithManyQ(paManyOtherLists)
			This.ExtendWithMany(paManyOtherLists)
			return This
	
	  #-------------------------#
	 #     MERGING THE LIST    #
	#-------------------------#

	def Merge()
		if This.IsListOfLists()

			This.Update( StzListOfListsQ( This.List() ).MergeQ().Content() )
		ok

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		aResult = This.Copy().MergeQ().Content()
		return This

	  #----------------------------#
	 #     FLATTENING THE LIST    #
	#----------------------------#
	
	# Works if items are numbers, strings and lists (not for objects!)
	# --> TODO: make it for objects also after making equality
	def Flatten() 

	aResult = []

	cListInString = ""

	StzStringQ( listtocode(This.Content()) ) {
		Simplify()
		ReplaceMany([ "[]", "[ ]" ], :With = "#!9#!7#EMPTYLIST#!3#!#4")
		RemoveMany([ "[", "]" ])
		ReplaceAll("#!9#!7#EMPTYLIST#!3#!#4", :With = "[]")

		cListInString = Content()
	}

	cCode = "aResult = [" + cListInString + "]"
	eval(cCode)

	This.Update( aResult )


		def FlattenQ()
			This.Flatten()
			return This
	
	def Flattened()
		aResult = This.Copy().FlattenQ().Content()
		return aResult

	  #-----------------------------------#
	 #     REPEATING THE LIST N TIMES    #
	#-----------------------------------#

	def RepeatNTimes(n)
		aResult = []
		for i = 1 to n
			for q = 1 to This.NumberOfItems()
				aResult + This[q]
			next
		next

		This.Update( aResult )

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	  #----------------------#
	 #     UNIQUE ITEMS     #
	#----------------------#

	def UniqueItems()
		return This.ToSet()

		def UniqueItemsQ()
			return new stzList( This.UniqueItems() )

	  #----------------------#
	 #     FROM/TO LIST     #
	#----------------------#
		
	def ToSet()
		aResult = []
		for item in This.List()
			if NOT StzListQ(aResult).Contains(item)
				aResult + item
			ok
		next

		return aResult

		def ToSetQ()
			return new stzSet( This.ToSet() )
	
		def ToSetQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.ToSet() )
			on :stzSet
				return new stzSet( This.ToSet() )
			other
				stzRaise("Unsupported return type!")
			off
	
	def ToStzSet()
		return new stzSet( This.ToSet() )

	def ToStzListOfNumbers()
		return new stzListOfNumbers( This.Content() )

	def ToStzListOfLists()
		if This.IsListOfLists()
			return new stzListOfLists(This.Content())
		ok

		def ToListOfListsQ()
			return This.ToStzListOfLists()
	
	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

		def ToListOfStringsQ()
			return This.ToStzListOfStrings()
	
	def ToStzHashList()
		return new stzHashList( This.List() )
	
		def ToHashListQ()
			return This.ToStzHashList()
	
	def ToCode()
		/*
		This function relies on Ring native list2code() function that
		 translates only number, string, and list items of a list to code.

		It just embellifies its output.

		TODO: In the futur, we need to make it possible the identification
		of objects items also and the transliteration of their names in
		the output (now, they are just generated as empty chras).
		*/
		
		cResult = StzStringQ( list2code( This.List() ) ).Simplified()

		return cResult

		def ToCodeQ()
			return new stzString( This.ToCode() )

	def ToString()

		return This.ToCode()
		
		#< @FunctionAlternativeForm

		def Stringify()
			return This.ToString()

			def StringifyQ()
				return new stzString( This.ToString() )

		def Stringified()
			return This.ToString()
	
		#< @FunctionFluentForm

		def ToStringQ()
			return new stzString( This.ToString() )

			def ToStzString()
				return This.ToStringQ()

		#>

	def IsSet()
		bIsSet = TRUE

		for item in This.Content()
			if This.NumberOfOccurrence(item) > 1
				bIsSet = FALSE
			ok
		next

		return bIsSet

	  #-----------------------------------------------------#
	 #     NUMBER OF OCCURRENCE OF AN ITEM IN THE LIST     #
	#-----------------------------------------------------#

	def NumberOfOccurrence(pItem)
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		return len(This.FindAll(pItem))

		def NumberOfOccurrences(pItem)
			return This.NumberOfOccurrence(pItem)
	
	  #--------------------#
	 #     DUPLICATES     #
	#--------------------#

	def RemoveDuplicates()

		aResult = []

		# If we are lucky, the list contains only strings so we
		# can rely on Qt to remove its duplicates

		if This.IsListOfStrings()
			aResult = StzListOfStringsQ( This.List() ).DuplicatesRemoved()

		else
			# Otherwise we do the job manually in Ring

			acStrList = []
			for i = 1 to This.NumberOfItems()
				cItemInStr = @@( This[i] )

				if find(acStrList, cItemInStr) = 0
					acStrList + cItemInStr
				ok
			next

			acStrList = StzListOfStringsQ( acStrList ).DuplicatesRemoved()
	
			for str in acStrList
				cCode = "aResult + " + str
				eval(cCode)
			next
		ok

		This.Update( aResult )

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This
	
	def DuplicatesRemoved()
		aResult = This.Copy().RemoveDuplicatesQ().Content()
		return aResult

	def Duplicates()
		aResult = []
		for item in This.DuplicatedItems()
			
			for i in This.FindAllExceptFirst(item)
				aResult + i
			next i
			
		next
		return sort(aResult)

		def DuplicatesQ()
			return new stzList( This.Duplicates() )
	
	def DuplicatedItems()
		aResult = []
		for item in This.Content()
			if IsDuplicated(item) and 
			   StzListQ( aResult ).ContainsNo( item )
			
				aResult + item
			ok
		next
		return aResult

		def DuplicatedItemsQ()
			return new stzList( This.DuplicatedItems() )
	
	def DuplicatesOfItem(pItem)
		aResult = []
		if NOT This.IsDuplicated(pItem)
			stzRaise("This item ("+ pItem + ") is not duplicated!")
		else
			aResult = This.FindAllExceptFirst(pItem)
		ok

		return aResult

		def DuplicatesOfItemQ(pItem)
			return new stzList( This.DuplicatesOfItem(pItem) )
	
	def DuplicatedItemsAndTheirDuplicates()
		aResult = []
		/* aResult will take the form:
		[
			[ "A", [ 5, 8, 10] ],	=> A is duplicated at positions 5, 8, and 10
			[ "B", [ 3 ] ],	=> B is duplicated at position 3
		 	[ ... ]
		]
		*/
		
		for item in This.DuplicatedItems()
			aResult + [ item, This.DuplicatesOfItem(item) ]
		next

		return aResult

	def IsDuplicated(pItem)
		if len(This.FindAll(pItem)) > 1
			return TRUE
		else
			return FALSE
		ok

	def IsDuplicateItem(pItem)
		return This.IsDuplicated(pItem)

	def IsDuplicatedNTimes(pItem, n)
		if This.NumberOfDuplicates(pItem) = n
			return TRUE

		else
			return FALSE
		ok

	def IsDuplicatedItemNTimes(pItem, n)
		return This.IsDuplicatedNTimes(pItem, n)

	def NumberOfDuplicatesOfItem(pItem)
		if This.Contains(pItem)
			return This.NumberOfOccurrence(pItem) - 1
		else
			return 0
		ok

	def NumberOfDuplicates(pItem)
		return This.NumberOfDuplicatesOfItem(pItem)

	  #--------------------#
	 #     CONTAINMENT    #
	#--------------------#
	/*
		Review the function namings and make the same semantics
		here and in stzString class.
	*/

	def Contains(pItem)

		if This.FindFirstOccurrence(pItem) > 0
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionNegationForm

		def ContainsNo(pItem)
			return NOT This.Contains(pItem)

		#>

		def ContainsItem(pItem)
			return This.Contains(pItem)
	
	def IsContainedIn(p)
		switch type(p)
		
		on "LIST"
			bResult = TRUE
			for item in This.List()
				if NOT StzListQ(p).Contains(item)
					bResult = FALSE
					exit
				ok
			next
			return bResult

		on "STRING"
			cListStringified = This.ToCode()
			bResult = StzStringQ(p).Contains(cListStringified)
			return bResult
		other
			# For now, number and object type are not concerned
			stzRaise("Unsupported type!")
		off

		#< @FunctionAlternativeForm

		def ExistsIn(p)
			return This.IsContainedIn(p)

		def IsIncludedIn(p)
			return This.IsContainedIn(p)

		#>

		def IsNotContainedIn(p)
			return NOT This.IsContainedIn(p)
	
	def IsContainedInOneOfThese(paList)
		bResult = TRUE

		for item in paList
			if isList(item)
				if NOT StzListQ(item).IsContainedIn( This.List() )
					bResult = FALSE
					exit
				ok

			but isString(item)
				if NOT StzStringQ(item).IsContainedIn( This.List() )
					bResult = FALSE
					exit
				ok

			else
				# Object and number types are not managed
				stzRaise("Unsupported type!")
			ok
		next

		return bResult

		#< @FunctionNegationForm

		def IsNotContainedInOneOfThese(paList)
			return NOT This.IsContainedInOneOfThese(paList)

		#>

	#--

	def ContainsEach(paItems)
		bResult = TRUE

		for item in paItems
			if NOT This.Contains(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def ContainsEachOneOfThese(paItems)
			return This.ContainsEach(paItems)

			def ContainsNoOne(paItem)
				return NOT This.ContainsEach(paItems)

			def ContainsNoOneOfThese(paItems)
				return NOT This.ContainsEach(paItems)

	def ContainsBoth(pItem1, pItem2)
		return This.ContainsEach( [pItem1, pItem2] )
	
	def EachItemExistsIn(paList)
		return StzListQ(paList).ContainsEach(This.List())

		def NoOneExistsIn(paList)
			return NOT This.EachItemExistsIn(paList)

		def NoItemExistsIn(paList)
			return NOT This.EachItemExistsIn(paList)

	def IsOneOfThese(paList)
		return StzListQ(paList).Contains( This.List() )

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)

	#--

	def ContainsMany(paSetOfItems)
		
		if IsNotList(paSetOfItems)
			stzRaise("Incorrect param type! You must provide a list.")
		ok

		bResult = TRUE

		for item in paSetOfItems
			if This.ContainsNo(item)
				bResult = FALSE
				exit
			ok
		end

		return bResult

		def IsMadeOf(paSetOfItems)
			return This.ContainsMany(paSetOfItems)

		def IsMadeOfThese(paSetOfItems)
			return This.ContainsMany(paSetOfItems)

		def IsMadeOfEachOneOfThese(paSetOfItems)
			return This.ContainsMany(paSetOfItems)

	def ContainsSome(paSetOfItems)
		return This.ToSetQR( :stzList ).ExistsIn( paSetOfItems )

		def IsMadeOfSome(paSetOfItems)
			return This.ContainsSome(paSetOfItems)

		def IsMadeOfSomeOfThese(paSetOfItems)
			return This.ContainsSome(paSetOfItems)

		def IsMadeOfOneOrMoreOfThese(paSetOfItems)
			return This.ContainsSome(paSetOfItems)

		def IsMadeOfOneOrMoreOf(paSetOfItems)
			return This.ContainsSome(paSetOfItems)

	#--

	def ContainsAny(pSetOfItems)
		/*
		Example:

		o1 = new stzList([ :monday, :monday, :monday ])
		? o1.ContainsAny([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
		
		*/

		bResult = FALSE

		for item in pSetOfItems
			if This.NumberOfOccurrence(item) = This.NumberOfItems()
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsOneOfThese(pSetOfItems)
			return This.ContainsAny(pSetOfItems)

		def ContainsAnyOneOfThese(pSetOfItems)
			return This.ContainsAny(pSetOfItems)

		def IsMadeOfOneOfThese(pSetOfItems)
			return This.ContainsAny(pSetOfItems)

		def ContainsOne(pSetOItems)
			return This.ContainsAny(pSetOfItems)

	def ContainsOnlyOne(paItems)
		bResult = FALSE
		for item in paItems
			if This.IsMadeOfItem(item)
				bResult = TRUE
				exit
			ok
		next
		return bResult

		def ContainsOnlyOneOfThese(paItems)
			return This.ContainsOnlyOne(paItems)

		def IsMadeOfOnlyOneOfThese(paItems)
			return This.ContainsOnlyOne(paItems)

	#--

	def ContainsNumbers()
		bResult = FALSE

		for item in This.List()
			if isNumber(item)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsNoNumbers()
			return NOT This.ContainsNumbers()

	def ContainsNumbersAtSameLevel()
		// TODO

		def ContainsNoNumbersAtAnyLevel()
			return NOT This.ContainsContainsNumbersAtSameLevel()

	#--

	def ContainsStrings()
		bResult = FALSE

		for item in This.List()
			if isString(item)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsNoStrings()
			return NOT This.ContainsStrings()

	def ContainsStringsAtSameLevel()
		// TODO

		def ContainsNoStringsAtAnyLevel()
			return NOT This.ContainsStringsAtSameLevel()

#--------------

	def ContainsLists()
		bResult = FALSE

		for item in This.List()
			if isList(item)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsNoLists()
			return NOT This.ContainsLists()

	def ContainsListsAtSameLevel()
		// TODO

		def ContainsNoListsAtAnyLevel()
			return NOT This.ContainsListsAtSameLevel()

#--------------

	def ContainsObjects()
		for item in This.List()
			if isObject(item)
				return TRUE
			ok
		next

	def ContainsNoObjects()
		return NOT This.ContainsObjects()

	def ContainsObjectsAtSomeLevel() // TODO: Review this risky implementation!
		/*
		This solution is build upon the observation that
		list2code() Ring functions generates empty string
		for objects.

		Hence, list2Code([ 1, 2, "C"]) generates '[1,2,"C"]'
		but:
			o1 = new stzString("C")
			? list2code([ 1, 2, o1, "C"]) generates:

			'[1,2,,"C"]'

		As you can see, we can know that an object exists by
		analyzing list2code() for any generated empty string!

		WARNING: if Ring enhances this function to generate the
		name of the object, for example, then the logic used
		here must change accordingly...
		*/

		oCode = StzStringQ( list2code( This.List() ) )

		if oCode[4] = "," or
		   oCode[ oCode.NumberOfChars()-3 ] = "," or
		   oCode.Contains(",,") or
		   oCode.Contains("[,") or
		   oCode.Contains(",]")

			return TRUE
		else
			return FALSE
		ok
	
	def ContainsNoObjectsAtAnyLevel()
		return NOT This.ContainsObjectsAtSomeLevel()

	def ContainsAtAnyLevel(pItem) # TODO
		// TODO

	  #----------------------#
	 #    LIST STRUCTURE    #
	#----------------------#

	/*
	TODO:

	- Reveiew this section (its functions and its semantics)
	- Avoid using _ in names of functions

	- Merge with the next sections:
		LEVELS OF THE LIST, and
		SUBLISTS OF THE LIST --> LISTS IN LEVEL 1 OF THE LIST

	- Insure they are all consistent and correct

	*/

	def ContainsOneOrMoreLists()
		if This.WalkUntilItemIsList() != NULL
			return TRUE
		else
			return FALSE
		ok

	def FirstList()
		If This.WalkUntilItemIsList() != NULL
			return This.LastItemIn( This.WalkUntilItemIsList() )
		ok

		def FirstListQ()
			return new stzList( This.FirstList() )

	def ListsPaths()
		return This.ItemsThatAreLists_AtAnyLevel_TheirPaths()

		def ListsPathsQ()
			return new stzList( This.ListsPaths() )

	def ItemsThatAreLists_AtAnyLevel_TheirPaths()
		aResult = []
		aInfo = This.ItemsThatAreLists_AtAnyLevel_XT()
		for info in aInfo
			aResult + info[1][2]	// GetItemByPath(x,y) : Generalize!!!
		next
		
		return aResult

		def ItemsThatAreLists_AtAnyLevel_TheirPathsQ()
			return new stzList( This.ItemsThatAreLists_AtAnyLevel_TheirPaths() )

	def ItemByPath(panPath)
		if This.ContainsItemOnPath(panPath)
			cCode = "Result = "
			cCode += GenerateListAccessCode_FromNameAndPath("This.Content()", panPath)
			eval(cCode)
			return Result
		ok

		def ItemByPathQ(panPath)
			item = This.ItemByPath(panPath)
			switch type( item )
			on "NUMBER"
				return new stzNumer(""+ item)

			on "STRING"
				return new stzString(item)

			on "LIST"
				return new stzList(item)

			on "OBJECT"
				return new stzObject(item)

			other
				stzRaise("Unsupported type!")
			off

	def Paths()
		// TODO

	def ItemsAndTheirPaths()
		// TODO

	def IncludesPath(panPath)
		return StzListQ( This.Paths() ).Contains(panPath)

	def ContainsItemOnPath(panPath)
		# TODO

	def ContainsListOnPath(panPath)
		try
			cCode = "TempItem = "
			cCode += GenerateListAccessCode_FromNameAndPath("This.Content()",panPath)
	
			eval(cCode)
			if isList(TempItem)
				return TRUE
			else
				return FALSE
			ok
		catch
			return FALSE
			// Report Ring bug: catch region does not consider more then 1 line!
		done

		
	def NumberOfLists_AtAnyLevel()
		return len( This.ItemsThatAreLists_AtAnyLevel_XT() )

	def ItemsThatAreLists_AtAnyLevel()
		aResult = []
		
		for anPath in This.ItemsThatAreLists_AtAnyLevel_TheirPaths()
			
			cPath = "aTempList = "
			cPath += GenerateListAccessCode_FromNameAndPath("This.Content()", anPath)

			eval(cPath)
			aResult + aTempList
		next
		return aResult


	def ItemsThatAreLists_InLevel(n)
		// TODO

	def ItemsThatAreLists_InPositionN_AtAnyLevel(n)
		// TODO

	def ItemsInLevel(n)
		// TODO

	def ItemsInPositionN_AtAnyLevel(n)
		// TODO

	// Returns a stzListOfHashlists:
	// for each list: its path, level and position.
	def ItemsThatAreLists_AtAnyLevel_XT()
		
		aResult = []	aPath = []
		nLevel = -1 nPosition = -1
		for c in list2code(This.Content())
			if c = "["
				nLevel++
				if nPosition > -1
					aPath + (nPosition+1)
				else
					aPath = []
				ok
				aResult + [ :Path = aPath, :Level = nLevel, :Position = nPosition+1 ]
				
				nPosition = 0

			but c = "]"
				nLevel--
				if len(aPath) > 0
					del(aPath,len(aPath))
				ok

			but c = ","
				nPosition++
				
			ok
			
		next
		oResult = new stzList(aResult)
		return oResult.Section(2, oResult.NumberOfItems())

		def ItemsThatAreLists_AtAnyLevel_XTQ()
			return new stzList( This.ItemsThatAreLists_AtAnyLevel_XT() )

	def NumberOfLevels()
		aResult = []
		n = 0
		for c in list2code(This.Content())
			if c = "["
				n++
				aResult + n
			but c = "]"
				n--
			ok
			
		next

		oTempNumberList = new stzListOfNumbers(aResult)
		return oTempNumberList.Max()

	def Depth()
		return This.NumberOfLevels()

	def ItemsThatAre_Lists_AtAnyLevel()
		aResult = []
		n = 0
		n1 = 0
		n2 = 0

		oListInString = StzStringQ( list2code(This.Content()) )

		bInsideList = FALSE
		for i = 2 to oListInString.NumberOfChars() - 1

			c = oListInString[i]

			if c = "["
				bInsideList = TRUE
				n1 = i
			ok

			if c = "]" and bInsideList = TRUE
				n2 = i
				cCode = oListInString.Section(n1, n2)
				eval("aTempList = " + cCode)

				aResult + aTempList
				bInsideList = FALSE
			ok
			
		next

		return aResult

		def ItemsThatAre_Lists_AtAnyLevelQ()
			return new stzListOfLists( This.ItemsThatAre_Lists_AtAnyLevel() )
			
	def ListsAtAnyLevel()
		return This.ItemsThatAre_Lists_AtAnyLevel()

		def ListsAtAnyLevelQ()
			return new stzListOfLists( This.ListsAtAnyLevel() )
	
	def SublistsAtAnyLevel()
		return ListsAtAnyLevel()

		def SublistsAtAnyLevelQ()
			return This.ListsAtAnyLevelQ()
	
	def Structure()
		// TODO
		
	def ShowStructure()
		/* Generates a treeview like this:
			LIST[]
			|
			+-- cItem1
			|
			+-- Item2[]
			| |
			| +-- nItem2.1
			| |
                        | +-- oItem2.2
			|
			+-- nItem3
		*/

	def Show()
		// TODO
		if This.IsHashList()
			StzHashListQ( This.List() ).Show()

		but This.IsListOfHashLists()
			StzListOfHashListsQ( This.List() ).Show()

		other
			// TODO
		ok

	  #---------------------------#
	 #     LEVELS OF THE LIST    #
	#---------------------------#

	def Levels()

	def NthLevel(n)

	def ContentOfLevel(n)

		def ItemsOfLevel(n)
			return This.ContentOfLevel(n)

	def LevelsAndTheirItems()

	  #-----------------------------------------------------------#
	 #   SUBLISTS OF THE LIST --> LISTS IN LEVEL 1 OF THE LIST   #
	#-----------------------------------------------------------#

	def Sublists()
		aResult = []
		for item in This.List()
			if isList(item)
				aResult + item
			ok
		next
		return aResult

		#< @FunctionFluentForm

		def SubListsQ()
			return new stzList( This.Sublists() )

		#>

	def SublistsNumberOfItems()
		aResult = []
		for item in This.List()
			if isList(item)
				aResult + len(item)
			ok
		next
		return aResult
		
	def SublistsHaveSameNumberOfItems()
		bResult = TRUE
		for i=2 to len( This.Sublists() )
			if len( This.Sublists()[i] ) != len( This.Sublists()[i-1] )
				bResult = FALSE
			ok
		next
		return bResult

	def SublistsAtAnyLevelHaveSameNumberOfItems()
		bResult = TRUE
		for i=2 to len( This.SublistsAtAnyLevel() )
			if len( This.SublistsAtAnyLevel()[i] ) != len( This.SublistsAtAnyLevel()[i-1] )
				bResult = FALSE
			ok
		next
		return bResult

	  #-------------------------------------#
	 #     SWAPPING AND INVERSING ITEMS    #
	#-------------------------------------#

	def SwapItems(n1,n2)
		if n1 < 1 or n1 > This.NumberOfItems() or
		   n2 < 1 or n2 > This.NumberOfItems()
			stzRaise("Out of range!")
		ok

		aResult = This.Content()
		if n1 != n2
			nTemp = This[n1]
			This[n1] = This[n2]
			This[n2] = nTemp
		ok

		def SwapItemsQ(n1,n2)
			This.SwapItems(n1,n2)
			return This
	
	  #-----------------------------------------------------#
	 #    FINDING OCCURRENCES OF AN ITEM INSIDE THE LIST   #
	#-----------------------------------------------------#

	# Finding works only for numbers and strings

	# TODO : Lists and objects will become findable after
	# designing an overall solution of the Equality problem
	# in SoftanzaLib

	# UPDATE: Lists are now findable (only objects are left)

	def FindNthOccurrence(n, pItem) 
		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if len(This.FindAll(pitem)) > 0
			return This.FindAll(pItem)[n]
		ok

	def FindFirstOccurrence(pItem)
		/*
		WARNING:	
		
		The Ring find() function, used partially here, works only for
		numbers and strings. And it returns only the first occurrence of the
		item in the list.

		EXPLANATION OF THE SOLUTION:

		Here, we can solve ithe FindFirstOccurrence() method like this:
		 	return This.FindNthOccurrence(1, pItem)

		or like this:
		 	return This.FindAll(pItem)[1]

		But these two options find all the occurrences of the item,
		and then reads the first one to return it.

		Therefore, it's better for performance, when items are findable by Ring,
		to rely on the Ring find() function, which returns only the 1st occurrence
		(and this is what we need here). Otherwise (in case of finding lists and
		(onjects), we make our own implementation that stops when the first
		occurrence of the item is found!
		*/

		nResult = 0	# Eventual position of the 1st occurrence of pItem

		if isNumber(pItem) or isString(pItem)

			# Delegate the finding operation to Ring find() function
			nResult = find( This.List(), pItem)
		else
			# Some items of the list, or/and the provided pItem itself,
			# are not Ring findable (they are lists or objects):
			# so let's do the job by our selves!

			n = 0
			for item in This.List()
				n++	
			
				if isNumber(pItem) or isString(pItem)

					if item = pItem
						nResult = n
						exit
					ok
			
				else
					if Q(item).IsStrictlyEqualTo(pItem)
						nResult = n
						exit
					ok
						
				ok

			next
			
		ok

		return nResult

		#< @FunctionAlternativeForm

		def FindFirst(pItem)
			return This.FindFirstOccurrence(pItem)
	
		#>

	def FindLastOccurrence(pItem)
		return This.FindNthOccurrence( This.NumberOfOccurrence(pItem), n )

		#< @FunctionAlternativeForm

		def FindLast(pItem)
			return This.FindLastOccurrence(pItem)

		#>
	
	def FindAllOccurrences(pItem)
		/* NOTE
		We don't use the Ring find() function here because it works
		only for finding numbers and strings (and not lists and objects).

		Also, it only returns the first occurrence and stops there.

		This function finds numbers, strings, and lists.
		Objects will be managed in the future.

		*/

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		anResult = []

		aStrList = []
		for i = 1 to This.NumberOfItems()
			aStrList + @@( This[i] )
		next

		i = 0
		for str in aStrList
			i++
			if str = @@(pItem)
				anResult + i
			ok
		next

		return anResult

		#< @FunctionFluentForm

		def FindAllOccurrencesQ(pItem)
			return This.FindAllOccurrencesQR(pItem, :stzList)

		def FindAllOccurrencesQR(pItem, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAll(pItem) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAll(pItem) )
			other
				stzRaise("Unsupported type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FindAll(pItem)
			return This.FindAllOccurrences(pItem)

			#< @FunctionFluentForm

			def FindAllQ(pItem)
				return This.FindAllQR(pItem, :stzList)
	
			def FindAllQR(pItem, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAll(pItem) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAll(pItem) )
				other
					stzRaise("Unsupported type!")
				off
	
			#>

		# WARNING: We can not add an alternative name calle Find() because this is
		# is reservd name of the native Ring function find()!
		#>
	
	def FindMany(paItems)
		/*
		o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
		? o1.FindMany([ :one, :two, :four ])
		# --> [ 1, 2, 3, 5, 6 ]
		*/

		aResult = []

		for item in paItems
			anPositions = This.FindAll(item)
			if len(anPositions) > 0
				aResult + anPositions
			ok
		next

		aResult = StzListQ(aResult).FlattenQ().SortedInAscending()

		return aResult

		#< @FunctionFluentForm

		def FindManyQR(paItems, pcType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if pcType = :stzList
				return new stzList( This.FindMany(paItems) )

			but pcType = :stzListOfNumbers
				return new stzListOfNumbers( This.FindMany(paItems) )

			else
				stzRaise("Unsupported type!")
			ok

		def FindManyQ(paItems)
			return This.FindManyQR(paItems, :stzListOfNumbers)

		#

	def FindManyXT(paItems)
		/*
		o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
		? o1.FindManyXT([ :one, :two, :four ])
		# --> [ :one = [1, 3, 5], :two = [2], :three = [6] ]
		*/

		aResult = []

		for item in paItems
			aResult + [ item, This.FindAll(item) ]
		next

		return aResult

		#< @FunctionFluentForm

		def FindManyXTQ(paItems)
			return new stzList( This.FindManyXT(paItems) )

		#

	def FindAllExceptFirst(pItem)
		oTemp = new stzList( This.FindAll(pItem) )
		return oTemp.Section( 2, oTemp.NumberOfItems() )

		#< @FunctionFluentForm

		def FindAllExceptFirstQR(pItem, pcType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if pcType = :stzList
				return new stzList( This.FindAllExceptFirst(pItem) )
			but pcType = :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptFirst(pItem) )
			else
				stzRaise("Unsupported type!")
			ok

		def FindAllExceptFirstQ(pItem)
			return This.FindAllExceptFirstQR(pItem, :stzListOfNumbers)

		#

		#< @FunctionAlternativeForm

		def FindExceptFirst(pItem)
			return This.FindAllExceptFirst(pItem)

			#< @FunctionFluentForm
	
			def FindExceptFirstQR(pItem, pcType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				if pcType = :stzList
					return new stzList( This.FindExceptFirst(pItem) )
				but pcType = :stzListOfNumbers
					return new stzListOfNumbers( This.FindExceptFirst(pItem) )
				else
					stzRaise("Unsupported type!")
				ok
	
			def FindExceptFirstQ(pItem)
				return This.FindAllExceptFirstQR(pItem, :stzListOfNumbers)
	
			#
		#>
	
	def FindAllExceptLast(pItem)
		oTemp = new stzList( This.FindAll(pItem) )
		return oTemp.Section( 1, oTemp.NumberOfItems()-1 )

		#< @FunctionFluentForm

		def FindAllExceptLastQR(pItem, pcType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if pcType = :stzList
				return new stzList( This.FindAllExceptLast(pItem) )
			but pcType = :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllExceptLast(pItem) )
			else
				stzRaise("Unsupported type!")
			ok

		def FindAllExceptLastQ(pItem)
			return This.FindAllExceptLastQR(pItem, :stzListOfNumbers)

		#

		#< @FunctionAlternativeForm

		def FindExceptLast(pItem)
			return This.FindAllExceptLast(pItem)

			#< @FunctionFluentForm
	
			def FindExceptLastQR(pItem, pcType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				if pcType = :stzList
					return new stzList( This.FindExceptLast(pItem) )
				but pcType = :stzListOfNumbers
					return new stzListOfNumbers( This.FindExceptLast(pItem) )
				else
					stzRaise("Unsupported type!")
				ok
	
			def FindExceptLastQ(pItem)
				return This.FindAllExceptLastQR(pItem, :stzListOfNumbers)
	
			#>
		#>
		
	  #-------------------------------------------------------#
	 #    VISUALLY FINDING ALL OCCURRENCES OF A GIVEN ITEM   #
	#-------------------------------------------------------#

	# NOTE: Works only if items are chars (string of 1 char each)
	# TODO: Implement a more general solution for longer items

	def VizFindAllOccurrences(pItem) # TODO: Made some changes, retest it!
		
		cResult = @@( This.Content() ) # @@() or ComputableForm() or CF()
		anPositions = Q(cResult).FindAll( @@(pItem) )

		nLen = StzStringQ(cResult).NumberOfChars()

		cViz = " "
		for i = 1 to nLen - 2
			
			if StzNumberQ(i).IsOneOfThese(anPositions)
				cViz += "^"
			else
				cViz += "-"
			ok

		next

		cResult += (NL + cViz)

		return cResult

		#< @FunctionFluentForm

		def VizFindAllOccurrencesQ(pItem)
			return new stzString( This.VizFindAllOccurrencesO(pItem) )

		#>

		#< @FunctionAlternativeForms

		def VizFindAll(pItem)
			return This.VizFindAllOccurrences(pItem)

			def VizFindAllQ(pItem)
				return new stzString(This.VizFindAll(pItem))
	

		def VizFind(pItem)
			return This.VizFindAllOccurrences(pItem)

			def VizFindQ(pItem)
				return new stzString(This.VizFind(pItem))
		#>

	   #-------------------------------------------------#
	  #      FINDING NTH NEXT OCCURRENCE OF AN ITEM     #
	 #      STARTING AT A GIVEN POSITION               #
	#-------------------------------------------------#

	def FindNthNextOccurrence( n, pItem, nStart )
		if isList(pItem) and Q(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(nStart) and Q(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		oSection = StzListQ( This.Section(nStart, :LastItem) )

		nNumberOfOccurrences = oSection.NumberOfOccurrence( pItem )

		try
			return oSection.FindNthOccurrence(n, pItem) + nStart - 1
		catch
			return 0
		end

		def FindNextNthOccurrence( n, pItem, nStart )
			return This.FindNthNextOccurrence( n, pItem, nStart )

		def NthNextOccurrence( n, pItem, nStart )
			return This.FindNthNextOccurrence( n, pItem, nStart )

		def NextNthOccurrence( n, pItem, nStart )
			return This.FindNthNextOccurrence( n, pItem, nStart )

	   #-----------------------------------------------------#
	  #      FINDING NTH PREVIOUS OCCURRENCE OF AN ITEM     #
	 #      STARTING AT A GIVEN POSITION                   #
	#-----------------------------------------------------#

	def FindNthPreviousOccurrence(n, pItem, nStart)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		if n < 1 or n > This.NumberOfItems()
			stzRaise("Out of range! n should be between 1 and This.NumberOfItems().")
		ok

		if isList(pItem) and StzListQ(pItem).IsOfParamList()
			pItem = pItem[2]
		ok

		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()

			if isString(nStart[2])
				if nStart[2] = :First or nStart[2] = :FirstItem
					nStart = 1

				but nStart[2] = :Last or nStart[2] = :LastItem
					nStart = This.NumberOfItems()

				else
					nStart = 1
				ok

			but isNumber(nStart[2])

				nStart = nStart[2]

			else
				nStart = 1
			ok
		ok

		if nStart < 1 or nStart > This.NumberOfItems()
			stzRaise("Out of range! nStart should be between 1 and This.NumberOfItems().")
		ok

		if nStart = 1
			oSection = This
		else
			oSection = This.SectionQ(1, nStart - 1)
		ok

		anPositions = oSection.FindAll(pItem)
		nNumberOfOccurrences = len(anPositions)

		try
			return anPositions[ nNumberOfOccurrences - n + 1 ]
		catch
			return 0
		end

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrence( n, pItem, nStart )
			return This.FindNthPreviousOccurrence( n, pItem, nStart )
	
		def PreviousNthOccurrence( n, pItem, nStart )
			return This.FindNthPreviousOccurrence( n, pItem, nStart )
	
		def NthPreviousOccurrence( n, pItem, nStart )
			return This.FindNthPreviousOccurrence( n, pItem, nStart )

		#>

	   #---------------------------------------------#
	  #      FINDING NEXT OCCURRENCE OF AN ITEM     #
	 #      STARTING AT A GIVEN POSITION           #
	#---------------------------------------------#

	def FindNextOccurrence(pItem, nStart)
		return This.FindNextNthOccurrence(1, pItem, nStart)
	
		def NextOccurrence( pItem, nStart )
			return This.FindNextOccurrence(pItem, nStart)

	   #-------------------------------------------------#
	  #      FINDING PREVIOUS OCCURRENCE OF AN ITEM     #
	 #      STARTING FROM A GIVEN POSITION N           #
	#-------------------------------------------------#

	def FindPreviousOccurrence(pItem, nStart)
		return This.FindPreviousNthOccurrence(1, pItem, nStart)
	
		def PreviousOccurrence( pItem, nStart )
			return This.FindPreviousOccurrence(pItem, nStart)

	   #-----------------------------------------#
	  #   FINDING NEXT OCCURRENCES OF AN ITEM   #
	 #   STARTING AT A GIVEN POSITION          #
	#-----------------------------------------#

	def FindNextOccurrences(pItem, pnStartingAt)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oSection = This.SectionQ(pnStartingAt, :LastItem)

		anPositions = oSection.FindAll(pItem)
		
		anResult = StzListOfNumbersQ(anPositions).AddToEachQ(pnStartingAt - 1 ).Content()

		return anResult

		#< @FunctionAlternativeForms

		def FindNext(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

		def NextOccurrences(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

		#>
		
	   #---------------------------------------------#
	  #   FINDING PREVIOUS OCCURRENCES OF AN ITEM   #
	 #   STARTING AT A GIVEN POSITION              #
	#---------------------------------------------#

	def FindPreviousOccurrences(pcSubStr, pnStartingAt)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oSection = This.SectionQ(1, pnStartingAt)

		anPositions = oSection.FindAll(pcSubStr)
		
		return anPositions

	   #---------------------------------------------------#
	  #   FINDING ALL ITEMS VERIFYING A GIVEN CONDITION   #
	#---------------------------------------------------#

	def FindAllItemsW(pCondition)
	
		# Checking the provided param
	
		if isString(pCondition)
			cCondition = pCondition
	
		but isList(pCondition) and StzListQ(pCondition).IsWhereParamList()
	
			cCondition = pCondition[2]
	
		else
			stzRaise("Invalid param format!")
		ok
	
		# Performing the finding
	
		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()

		aResult = []

		@i = 0
		Previous@i = 0
		Next@i = 0
	
		for @item in This.List()

			@i++

			if @i <= This.NumberOfItems()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			cCode = "if (" + cCondition + ")" + NL +
				tab + "aResult + @i" + NL +
				"ok"
	
			eval(cCode)
	
		next
	
		return aResult
			
		#< @FunctionFluentForm
	
		def FindAllItemsWQ(pCondition)
			return This.FindAllItemsWQR(pCondition, :stzList)
	
		def FindAllItemsWQR(pCondition, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllItemsW(pCondition) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllItemsW(pCondition) )
	
			other
				stzRaise("Unsupported type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindAllW(pCondition)
			return This.FindAllItemsW(pCondition)

			#< @FunctionFluentForm

			def FindAllWQ(pCondition)
				return This.FindAllWQR(pCondition, :stzList)

			def FindAllWQR(pCondition, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllW(pCondition) )
		
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllW(pCondition) )
		
				other
					stzRaise("Unsupported type!")
				off
			#>

		def FindW(pCondition)
			return This.FindAllItemsW(pCondition)

			#< @FunctionFluentForm

			def FindWQ(pCondition)
				return This.FindWQR(pCondition, :stzList)

			def FindWQR(pCondition, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindW(pCondition) )
		
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindW(pCondition) )
		
				other
					stzRaise("Unsupported type!")
				off
			#>

		def FindWhere(pCondition)
			return This.FindAllItemsW(pCondition)

			#< @FunctionFluentForm

			def FindWhereQ(pCondition)
				return This.FindWhereQR(pCondition, :stzList)

			def FindWhereQR(pCondition, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindWhere(pCondition) )
		
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindWhere(pCondition) )
		
				other
					stzRaise("Unsupported type!")
				off
			#>

		def FindAllWhere(pCondition)
			return This.FindAllItemsW(pCondition)

			#< @FunctionFluentForm

			def FindAllWhereQ(pCondition)
				return This.FindAllWhereQR(pCondition, :stzList)

			def FindAllWhereQR(pCondition, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllWhere(pCondition) )
		
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllWhere(pCondition) )
		
				other
					stzRaise("Unsupported type!")
				off
			#>

		def FindAllItemsWhere(pCondition)
			return This.FindAllItemsW(pCondition)

			#< @FunctionFluentForm

			def FindAllItemsWhereQ(pCondition)
				return This.FindAllItemsWhereQR(pCondition, :stzList)

			def FindAllItemsWhereQR(pCondition, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllItemsWhere(pCondition) )
		
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllItemsWhere(pCondition) )
		
				other
					stzRaise("Unsupported type!")
				off
			#>

		def FindItemsW(pCondition)
			return This.FindAllItemsW(pCondition)

		def FindItemsWhere(pCondition)
			return This.FindAllItemsW(pCondition)

		def ItemsPositionsW(pCondition)
			return This.FindAllItemsW(pCondition)

		def ItemsPositionsWhere(pCondition)
			return This.FindAllItemsW(pCondition)

	#>

  	  #--------------------------------------#
	 #   GETTING ITEMS AT GIVEN POSITIONS   #
	#--------------------------------------#

	def ItemsAtPositions(panPositions)
		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			stzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		aResult = []

		for n in panPositions
			aResult + This.ItemAtPosition(n)
		next

		return aResult

		def ItemsAtThesePositions(panPositions)
			return This.ItemsAtPositions(panPositions)


	  #-----------------------------------------------#
	 #   GETTING ITEMS VERIFYING A GIVEN CONDITION   #
	#-----------------------------------------------#

	/*
	Note the semantic difference between "Getting" items, and "Finding" items.
		-> Getting items return the items themselves, while
		-> Finding items return their positions as numbers
	*/

	def ItemsW(pCondition)

		/*
		Example:
		StzListQ([ 1, "a", 2, "b", 3, "c" ]).ItemsW('{ isString(@item) }')
		
		Gives : [ "a", "b", "c" ]
		*/

		# Checking the provided param for the pCondition
	
		if isString(pCondition)
			cCondition = pCondition
	
		but isList(pCondition) and len(pCondition) = 2 and
		    isString(pCondition[2])
	
			if pCondition[1] = :Where 
				cCondition = pCondition[2]
	
			else
				stzRaise('Syntax error! Enter :Where and not "' + pCondition[1]+'"')
			ok
		ok
	
		# Performing the required job
	
		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()
		aResult = []

		@i = 0
		Previous@i = 0
		Next@i = 0

		for @item in This.List()
			@i++
			if @i <= This.NumberOfItems()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			cCode = "if (" + cCondition + ")" + NL +
				tab + "aResult + @Item" + NL +
				"ok"

			eval(cCode)
		next

		return aResult

		#< @FunctionFluentForm

		def ItemsWQ(pCondition)
			return new stzList( This.ItemsW(pCondition) )

		#>

		#< @FunctionAlternativeForms

		def ItemsWhere(pCondition)
			return This.ItemsW(pCondition)

			#< @FunctionFluentForm

			def ItemsWhereQ(pCondition)
				return new stzList( This.ItemsW(pCondition) )

			#>

		def AllItemsW(pCondition)
			return This.ItemsW(pCondition)

			#< @FunctionFluentForm

			def AllItemsWQ(pCondition)
				return new stzList( This.AllItemsW(pCondition) )

			#>

		def AllItemsWhere(pCondition)
			return This.ItemsW(pCondition)

			#< @FunctionFluentForm

			def AllItemsWhereQ(pCondition)
				return new stzList( This.AllItemsWhere(pCondition) )

			#>
		
		#>

	def UniqueItemsW(pCondition)

		aResult = This.ItemsWQ(pCondition).ToSet()
		return aResult

		def UniqueItemsWQ(pCondition)
			return new stzList( This.UniqueItemsW(pCondition) )

		def UniqueItemsWhere(pCondition)
			return This.UniqueItemsW(pCondition)

			def UniqueItemsWhereQ(pCondition)
				return new stzList( This.UniqueItemsWhere(pcCondition) )

	def NumberOfItemsW(pCondition)
		return len( This.ItemsW(pCondition) )

		def NumberOfUniqueItemsW(pCondition)
			return len( This.UniqueItemsW(pCondition) )

	def AllItemsExcept(pItem)
		aResult = This.ItemsW('{ NOT BothAreEqual(@item, ' + ComputableForm(pItem) + ') }')
		return aResult

	def NthItemW(n, pCondition)

		if NOT ( isNumber(n) and StzNumberQ(n).IsBetween(1, This.NumberOfItems() ) )
			stzRaise("Out of range! n must be between 1 and This.NumberOfItems()" )
		ok

		# Checking the provided param for the pCondition, by retriving
		# its value depending on the format used:
		# 	- NthItemW(2, '{ isNumber(@item) }"), or
		# 	- NthItemW(2, :Where = '{ isNumber(@item) }")
		# Note the use of :Where in the second case (more expressive syntax)	
	
		if isString(pCondition)
			cCondition = pCondition
		
		but isList(pCondition) and StzListQ(pCondition).IsWhereParamList()
			cCondition = pCondition[2]

		else
			stzRaise("Incorrect pCondition param!")
		ok
	
		# Performing the required job
	
		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()
		aResult = []

		@i = 0
		Previous@i = 0
		Next@i = 0

		for @item in This.List()
			@i++
			if @i <= This.NumberOfItems()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			cCode = "bFound = (@i = n) and (" + cCondition + ")"

			eval(cCode)

			if bFound
				return @item
			ok
		next

		#< @FunctionFluentForm

		def NthItemWQ(n, pCondition)
			item = This.NthItemW(n, pCondition)

			switch type(item)
			on "NUMBER"
				return new stzNumber(item)

			on "STRING"
				return new stzString(item)

			on "LIST"
				return new stzList(item)

			on "OBJECT"
				return new stzObject(item)

			other
				stzRaise("Unsupported type!")
			off

		#>

		#< @FunctionAlternativeForm

		def NthItemWhere(n, pcCondition)
			return This.NthItemW(n, pcCondition)

			def NthItemWhereQ(n, pcCondition)
				return This.NthItemWQ(n, pCondition)

		#>
		
	def FirstItemW(pCondition)
		return This.NthItemWhere(1, pCondition)

		#< @FunctionFluentForm

		def FirstItemWQ(pCondition)
			item = This.FirstItemW(pCondition)

			switch type(item)

			on "NUMBER"
				return new stzNumber(item)

			on "STRING"
				return new stzString(item)

			on "LIST"
				return new stzList(item)

			on "OBJECT"
				return new stzObject(item)

			other
				stzRaise("Unsupported type!")
			off

		#>

	def LastItemW(pCondition)
		return This.AllItemsW(pCondition)[ len(This.AllItemsW(pCondition)) ]

		#< @FunctionFluentForm

		def LastItemWQ(pCondition)
			item = This.LastItemW(pCondition)

			switch type(item)

			on "NUMBER"
				return new stzNumber(item)

			on "STRING"
				return new stzString(item)

			on "LIST"
				return new stzList(item)

			on "OBJECT"
				return new stzObject(item)

			other
				stzRaise("Unsupported type!")
			off

		#>

	def ItemsAndTheirPositionsW(pcCondition)
		/* Example
		o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])
		
		? o1.ItemsW('Q(@item).IsUppercase()')
		# --> [ "A", "B", "A", "C", "B" ]
		
		? o1.ItemsPositionsW('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...)
		# --> [ 1, 4, 5, 7, 9 ]
		
		? o1.ItemsAndTheirPositionsW('Q(@item).IsUppercase()')
		# --> [ "A" = [1, 5], "B" = [4, 9], "C" = [7] ]
		*/

		aItems      = This.ItemsW(pcCondition)

		anPositions = This.FindItemsW(pcCondition)

		aPairs = StzListQ( aItems ).AssociatedWith( anPositions )
	
		aUniqueItems = StzListQ(aItems).ToSet()

		aResult = []
		anItemPositions = []

		for pItem in aUniqueItems

			for aPair in aPairs
				if IsNumberOrString(pItem) and IsNumberOrString(aPair[1])

					if aPair[1] = pItem
						anItemPositions + aPair[2]
					ok

				else
					if Q(aPair[1]).IsStrictlyEqualTo(pItem)
						anItemPositions + aPair[2]
					ok
				ok
			next
			
			aResult + [ pItem, anItemPositions ]
			anItemPositions = []

		next

		return aResult

		def ItemsAndTheirPositionsWhere()
			return This.ItemsAndTheirPositionsW(pcCondition)

		def ItemsWXT()
			return This.ItemsAndTheirPositionsW(pcCondition)

		def ItemsWhereXT()
			return This.ItemsAndTheirPositionsW(pcCondition)

	  #------------------------------------------------#
	 #     GETTING & REMOVING ITEMS OF GIVEN TYPE     #
	#------------------------------------------------#

	def Numbers()
		return This.ItemsW('isNumber(@item)')

		#< @FunctionFluentForm

		def NumbersQ()
			return This.NumbersQR(:stzList)

		def NumbersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Numbers() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Numbers() )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def OnlyNumbers()
			return This.Numbers()

			def OnlyNumbersQ()
				return This.OnlyNumbersQR(:stzList)
	
			def OnlyNumbersQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyNumbers() )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.OnmlyNumbers() )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	def RemoveNumbers()
		This.RemoveItemsW('isNumber(@item)')

		def RemoveNumbersQ()
			This.RemoveNumbers()
			return This

		def RemoveOnlyNumbers()
			This.RemoveNumbers()

			def RemoveOnlyNumbersQ()
				This.RemoveOnlyNumbers()
				return This

	def NonNumbers()
		return This.ItemsW('NOT isNumber(@item)')

		def NonNumbersQ()
			return This.NonNumbersQR(:stzList)

		def NonNumbersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NonNumbers() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NonNumbers() )

			other
				stzRaise("Unsupported return type!")
			off

		def OnlyNonNumbers()
			return This.NonNumbers()

			def OnlyNonNumbersQ()
				return This.OnlyNonNumbersQR(:stzList)
	
			def OnlyNonNumbersQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyNonNumbers() )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.OnlyNonNumbers() )
	
				other
					stzRaise("Unsupported return type!")
				off

	def RemoveNonNumbers()
		This - This.NonNumbers()

		def RemoveNonNumbersQ()
			This.RemoveNonNumbers()
			return This

		def RemoveOnlyNonNumbers()
			This.RemoveNonNumbers()

			def RemoveOnlyNonNumbersQ()
				This.RemoveOnlyNonNumbers()
				return This

		def RemoveAllExceptNumbers()
			This.RemoveNonNumbers()

			def RemoveAllExceptNumbersQ()
				This.RemoveAllExceptNumbers()
				return This
		
	#-----

	def Strings()
		return This.ItemsW('isString(@item)')

		#< @FunctionFluentForm

		def StringsQ()
			return This.StringsQR(:stzList)

		def StringsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Strings() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Strings() )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def OnlyStrings()
			return This.Strings()

			def OnlyStringsQ()
				return This.OnlyStringsQR(:stzList)
	
			def OnlyStringsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyStrings() )
	
				on :stzListOfStrings
					return new stzListOfNumbers( This.OnmlyStrings() )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	def RemoveStrings()
		This.RemoveItemsW('isString(@item)')

		def RemoveStringsQ()
			This.RemoveStrings()
			return This

		def RemoveOnlyStrings()
			This.RemoveStrings()

			def RemoveOnlyStringsQ()
				This.RemoveOnlyStrings()
				return This

	def NonStrings()
		return This.ItemsW('NOT isString(@item)')

		def NonStringsQ()
			return This.NonStringsQR(:stzList)

		def NonStringsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NonStrings() )

			on :stzListOfNumbers
				return new stzListOfStrings( This.NonStrings() )

			other
				stzRaise("Unsupported return type!")
			off

		def OnlyNonStrings()
			return This.NonStrings()

			def OnlyNonStringsQ()
				return This.OnlyNonStringsQR(:stzList)
	
			def OnlyNonStringsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyNonStrings() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.OnlyNonStrings() )
	
				other
					stzRaise("Unsupported return type!")
				off

	def RemoveNonStrings()
		This - This.NonStrings()

		def RemoveNonStringsQ()
			This.RemoveNonStrings()
			return This

		def RemoveOnlyNonStrings()
			This.RemoveNonStrings()

			def RemoveOnlyNonStringsQ()
				This.RemoveOnlyNonStrings()
				return This

		def RemoveAllExceptStrings()
			This.RemoveNonStrings()

			def RemoveAllExceptStringsQ()
				This.RemoveAllExceptStrings()
				return This

	#----

	def Lists()
		return This.ItemsW('isList(@item)')

		#< @FunctionFluentForm

		def ListsQ()
			return This.ListsQR(:stzList)

		def ListsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Lists() )

			on :stzListOfLists
				return new stzListOfLists( This.Lists() )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def OnlyLists()
			return This.Lists()

			def OnlyListsQ()
				return This.OnlyListsQR(:stzList)
	
			def OnlyListsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyLists() )
	
				on :stzListOfLists
					return new stzListOfLists( This.OnmlyLists() )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	def RemoveLists()
		This.RemoveItemsW('isList(@item)')

		def RemoveListsQ()
			This.RemoveLists()
			return This

		def RemoveOnlyLists()
			This.RemoveLists()

			def RemoveOnlyListsQ()
				This.RemoveOnlyLists()
				return This

	def NonLists()
		return This.ItemsW('NOT isList(@item)')

		def NonListsQ()
			return This.NonListsQR(:stzList)

		def NonListsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NonLists() )

			on :stzListOfLists
				return new stzListOfLists( This.NonLists() )

			other
				stzRaise("Unsupported return type!")
			off

		def OnlyNonLists()
			return This.NonLists()

			def OnlyNonListsQ()
				return This.OnlyNonListsQR(:stzList)
	
			def OnlyNonListsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyNonLists() )
	
				on :stzListOfLists
					return new stzListOfLists( This.OnlyNonLists() )
	
				other
					stzRaise("Unsupported return type!")
				off

	def RemoveNonLists()
		This - This.NonLists()

		def RemoveNonListsQ()
			This.RemoveNonLists()
			return This

		def RemoveOnlyNonLists()
			This.RemoveNonLists()

			def RemoveOnlyNonListsQ()
				This.RemoveOnlyNonLists()
				return This

		def RemoveAllExceptLists()
			This.RemoveNonLists()

			def RemoveAllExceptListsQ()
				This.RemoveAllExceptLists()
				return This

	#---

	def Objects()
		return This.ItemsW('isObject(@item)')

		#< @FunctionFluentForm

		def ObjectsQ()
			return This.ObjectsQR(:stzList)

		def ObjectsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Objects() )

			on :stzListOfObjects
				return new stzListOfObjects( This.Objects() )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def OnlyObjects()
			return This.Objects()

			def OnlyObjectsQ()
				return This.OnlyObjectsQR(:stzList)
	
			def OnlyObjectsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyObjects() )
	
				on :stzListOfObjects
					return new stzListOfNumbers( This.OnmlyNumbers() )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	def RemoveObjects()
		This.RemoveItemsW('isObject(@item)')

		def RemoveObjectsQ()
			This.RemoveObjects()
			return This

		def RemoveOnlyObjects()
			This.RemoveObjects()

			def RemoveOnlyObjectsQ()
				This.RemoveOnlyObjects()
				return This

	def NonObjects()
		return This.ItemsW('NOT isObject(@item)')

		def NonObjectsQ()
			return This.NonObjectsQR(:stzList)

		def NonObjectsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NonObjects() )

			on :stzListOfObjects
				return new stzListOfObjects( This.NonObjects() )

			other
				stzRaise("Unsupported return type!")
			off

		def OnlyNonObjects()
			return This.NonObjects()

			def OnlyNonObjectsQ()
				return This.OnlyNonObjectsQR(:stzList)
	
			def OnlyNonObjectsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyNonObjects() )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.OnlyNonObjects() )
	
				other
					stzRaise("Unsupported return type!")
				off

	def RemoveNonObjects()
		This - This.NonObjects()

		def RemoveNonObjectsQ()
			This.RemoveNonObjects()
			return This

		def RemoveOnlyNonObjects()
			This.RemoveNonObjects()

			def RemoveOnlyNonObjectsQ()
				This.RemoveOnlyNonObjects()
				return This

		def RemoveAllExceptObjects()
			This.RemoveNonObjects()

			def RemoveAllExceptObjectsQ()
				This.RemoveAllExceptObjects()
				return This

	  #-----------------------------------#
	 #     CHECKING IF ALL ITEMS ARE     #
	#-----------------------------------#

	def AllItemsVerifyW(pcCondition)
		/* Examples
			o1 = new stzList([ "one", "two", "three" ])
			? o1.AllItemsVerifyW('isString()') # --> TRUE
		*/

		pcCondition = StzStringQ(pcCondition).SimplifyQ().RemoveBoundsQ("{","}").Content()

		bResult = TRUE

		@i = 0
		Previous@i = 0
		Next@i = 0

		for @item in This.List()
			@i++

			if @i <= This.NumberOfItems()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			cCode = 'if NOT ( ' + pcCondition + ' )' + NL +
				'	bResult = FALSE' + NL +
				'ok'

			eval(cCode)

			if bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def AllItemsVerify(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def ContainsOnly(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def ContainsOnlyW(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def AllItemsVerifyThisCondition(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def AllItemsVerifyThisConditionW(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def AllItemsAre(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def AllItemsAreW(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		#>

	def AllItemsAreNull()
		return This.AllItemsAreW('{ isString(@item) and @item = NULL }')

	def AllItemsAreStrings()
		return This.AllItemsAreW('{ isString(@item) }')

	def AllItemsAreNonNullStrings()
		return This.AllItemsAreW('{ isString(@item) and @item != NULL }')

	def AllItemsAreValidRingCodes()
		return This.AllItemsAreW('{ isString(@item) and Q(@item).IsValidRingCode() }')

	def AllItemsAreNumbers()
		return This.AllItemsAreW('{ isNumber(@item) }')

	def AllItemsAreLists()
		return This.AllItemsAreW('{ isList(@item) }')

	def AllItemsAreObjects()
		return This.AllItemsAreW('{ isObject(@item) }')

	def AllItemsAreStzObjects()
		return This.AllItemsAreW('{ IsStzObject(@item) }')

	def AllItemsAreStzClassNames()
		return This.AllItemsAreW('{ isString(@item) and StringIsStzClassName(@item) }')

	def AllItemsAreQObjects()
		return This.AllItemsAreW('{ IsQObject(@item) }')

	  #--------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION   #
	#--------------------------------------------------#

	def CountItemsW(pCondition)	# TODO: check if it is same as NumberOfItemsW()

		# Checking the pCondition param

		if isString(pCondition)
			cCondition = pCondition
	
		but isList(pCondition) and len(pCondition) = 2 and
		    isString(pCondition[2])
	
			if pCondition[1] = :Where 
				cCondition = pCondition[2]
	
			else
				stzRaise('Syntax error! Enter :Where and not "' + pCondition[1]+'"')
			ok
		ok
	
		# Performing the required job

		return len(This.ItemsW(pCondition))
		
		#< @AlternativeFunctionNames

		def CountW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfOccurrenceW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)

		#>
		
	  #--------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION  #
	#--------------------------------------------------------------------#

	def InsertAfterW( pCondition, pNewItem )
		/*
		o1.InsertAfterW( "*", :Where = '{ StzStringQ(item).IsUppercase() }' )
		*/

		# Checking the provided param for the Expression
	
		if isString(pCondition)
			cCondition = pCondition
	
		but isList(pCondition) and len(pCondition) = 2 and
		    isString(pCondition[2])
	
			if pCondition[1] = :Where 
				cCondition = pCondition[2]
	
			else
				stzRaise('Syntax error! Enter :Where and not "' + pCondition[1]+'"')
			ok
		ok
	
		# Performing the required job

		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()

		This.InsertAfterAtManyPositions( This.FindAllItemsW(cCondition), pNewItem )

		#< @FunctionFluentForm

		def InsertAfterWQ( pCondition, pNewItem )
			This.InsertAfterW( pCondition, pNewItem )
			return This

		#>

		def InsertAfterWhere(pCondition, pNewItem)
			This.InsertAfterW(pCondition, pNewItem)

			def InsertAfterWhereQ(pCondition, pNewItem)
				This.InsertAfterWhere(pCondition, pNewItem)
				return This

	def InsertBeforeW( pCondition, pNewItem )
		/*
		o1.InsertBeforeW( :Where = '{ StzStringQ(item).IsUppercase() }', "*" )
		*/

		# Checking the provided param for the pCondition
	
		if isString(pCondition)
			cCondition = pCondition
	
		but isList(pCondition) and len(pCondition) = 2 and
		    isString(pCondition[2])
	
			if pCondition[1] = :Where 
				cCondition = pCondition[2]
	
			else
				stzRaise('Syntax error! Enter :Where and not "' + pCondition[1]+'"')
			ok
		ok
	
		# Performing the required job

		cCondition = StzStringQ(cCondition).RemoveBoundsQ("{","}").Simplified()

		This.InsertBeforeAtManyPositions(This.FindAllItemsW(cCondition), pNewItem )

		#< @FunctionFluentForm

		def InsertBeforeWQ( pCondition, pNewItem )
			This.InsertBeforeW( pCondition, pNewItem )
			return This

		#>

		def InsertBeforeWhere(pCondition, pNewItem)
			This.InsertBeforeW(pCondition, pNewItem)

			def InsertBeforeWhereQ(pCondition, pNewItem)
				This.InsertBeforeWhere(pCondition, pNewItem)
				return This

	  #-----------------------------------------------------------------#
	 #  INSERTING MANY ITEMS AFTER OR BEFORE A GIVEN SET OF POSITIONS  #
	#-----------------------------------------------------------------#

	def InsertAfterAtManyPositions(panPositions, pItem)

		for i = 1 to len(panPositions)
			n = panPositions[i] + i - 1
			This.InsertAfter(n, pItem)
		next

		#< @FunctionFluentForm

		def InsertAfterAtManyPositionsQ(panPositions, pItem)
			This.InsertAfterAtManyPositions(panPositions, pItem)
			return This

		#>

	def InsertBeforeAtManyPositions(panPositions, pItem)
	
		for i = 1 to len(panPositions)
			n = panPositions[i] + i - 1
			This.InsertBefore(n, pItem)
		next

		#< @FunctionFluentForm

		def InsertBeforeAtManyPositionsQ(panPositions, pItem)
			This.InsertBeforeAtManyPositions(panPositions, pItem)
			return This

		#>

	  #----------------------------------------------#
	 #    SPLITTING THE LIST USING THE GIVEN ITEM   #
	#----------------------------------------------#

	def Split(pItem)
		if isList(pItem) and StzList(pItem).IsUsingParamList()
			pItem = pItem[2]
		ok

		anPos = This.FindAll(pItem)
		aResult = This.SplitAtPositions(anPos)

		return aResult

		#< @FunctionFluentForm

		def SplitQ(pItem)
			return This.SplitQR(pItem, :stzList)

		def SplitQR(pItem, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Split(pItem) )

			on :stzListOfLists
				return new stzListOfLists( This.Split(pItem) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Split(pItem) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Split(pItem) )
 
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Split(pItem) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeNames

		def SplitUsing(pItem)
			This.Split(pItem)

			def SplitUsingQ(pItem)
				return This.SplitUsingQR(pItem, pcReturnType)
	
			def SplitUsingQR(pItem, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.SplitUsing(pItem) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitUsing(pItem) )
	
				on :stzListOfPairs
					return new stzListOfPairs( This.SplitUsing(pItem) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitUsing(pItem) )
	 
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitUsing(pItem) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #------------------------------------#
	 #    SPLITTING TO PARTS OF N ITEMS   #
	#------------------------------------#
	
	def SplitToPartsOfNItemsEach(n)

		oSplitter = new stzSplitter(This.List())
		aSplitted = oSplitter.SplitToPartsOfNItemsEach(n)

		if isString(aSplitted) and aSplitted = NULL
			return NULL

		but len(aSplitted) = 1
			aResult = []
			aResult + This.List()

		but len(aSplitted) = This.NumberOfItems()
			aResult = []

			for item in This.List()
				aResult + [ item ]
			next

		else
			# Tranforming the sections of positions contained in aSplitted
			# to sublists of the actual items corresponding to those sections
	
			aResult = []
	
			for aSection in aSplitted
				aResult + This.Section( aSection[1], aSection[2] )
			next
		ok

		return aResult

		#< @FunctionFluentForm
		
		def SplitToPartsOfNItemsEachQ(n)
			This.SplitToPartsOfNItemsEachQR(n, :stzList)

		def SplitToPartsOfNItemsEachQR(n, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToPartsOfNItemsEach(n) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitToPartsOfNItemsEach(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SplitToPartsOfNItemsEach(n) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToPartsOfNItemsEach(n) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.SplitToPartsOfNItemsEach(n) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

	def SplitToPartsOfNItems(n)
		oSplitter = new stzSplitter(This.List())
		aSplitted = oSplitter.SplitToPartsOfNItems(n)

		if isString(aSplitted) and aSplitted = NULL
			return NULL

		but len(aSplitted) = 1
			aResult = []
			aResult + This.List()

		but len(aSplitted) = This.NumberOfItems()
			aResult = []

			for item in This.List()
				aResult + [ item ]
			next

		else
			# Tranforming the sections of positions contained in aSplitted
			# to sublists of the actual items corresponding to those sections
	
			aResult = []
	
			for aSection in aSplitted
				aResult + This.Section( aSection[1], aSection[2] )
			next
		ok

		return aResult

		#< @FunctionFluentForm

		def SplitToPartsOfNItemsQR(n, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToPartsOfNItems(n) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitToPartsOfNItems(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SplitToPartsOfNItems(n) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToPartsOfNItems(n) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.SplitToPartsOfNItems(n) )

			other
				stzRaise("Unsupported return type!")
			off


		def SplitToPartsOfNItemsQ(n)
			return This.SplitToPartsOfNItemsQR(n, :stzList)
	
		#< @FunctionAlternativeForms

		def SplitToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

			#< @FunctionFluentForm

			def SplitToPartsOfNQ(n)
				return This.SplitToPartsOfNItemsQR(n, :stzList)
	
			def SplitToPartsOfNQR(n, pcType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.SplitToPartsOfNItemsQR(n, pcType)

			#>

		def SplitToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

			#< @FunctionFluentForm

			def SplitToPartsOfQ(n)
				return This.SplitToPartsOfNItemsQR(n, :stzList)
	
			def SplitToPartsOfQR(n, pcType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.SplitToPartsOfNItemsQR(n, pcType)

			#>

		def SplitToParts(n)
			if isList(n) and StzListQ(n).IsOfParamList()
				n = n[2]
			ok

			return This.SplitToPartsOf(n)

			def SplitToPartsQ(n)
				return This.SplitToPartsQR(n, :stzList)
	
			def SplitToPartsQR(n, pcType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.SplitToPartsOfNItemsQR(n, pcType)
		#>

	  #---------------------------------------#
	 #    SPLITTING BEFORE GIVEN POSITIONS   #
	#---------------------------------------#

	def SplitBeforePositions(panPositions)

		oSplitter = new stzSplitter(This.List())
		aSplitted = oSplitter.SplitBeforePositions(panPositions)

		# Tranforming the sections of positions contained in aSplitted
		# to sublists of the actual items corresponding to those sections

		aResult = []

		for aSection in aSplitted
			aResult + This.Section( aSection[1], aSection[2] )
		next

		return aResult

		#< @FunctionFluentForm

		def SplitBeforePositionsQ(panPositions)
			return new stzListOfLists( This.SplitBeforePositions(panPositions) )

		#>

	def SplitBeforePosition(n)
		return This.SplitBeforePositions([n])		

		#< @FunctionFluentForm

		def SplitBeforePositionQ(n)
			return new stzListOfLists( This.SplitBeforePosition(n) )

		#>

		#< @FunctionAlternativeForm

		def SplitBefore(n)
			return  This.SplitBeforePosition(n)

			#< @FunctionFluentForm

			def SplitBeforeQ(n)
				return new stzListOfLists( This.SplitBefore(n) )

			#>

		#>

	  #--------------------------------------#
	 #    SPLITTING AFTER GIVEN POSITIONS   #
	#--------------------------------------#

	def SplitAfterPositions(panPositions)
		oSplitter = new stzSplitter(This.List())
		aSplitted = oSplitter.SplitAfterPositions(panPositions)

		# Tranforming the sections of positions contained in aSplitted
		# to sublists of the actual items corresponding to those sections

		aResult = []

		for aSection in aSplitted
			aResult + This.Section( aSection[1], aSection[2] )
		next

		return aResult

		#< @FunctionFluentForm

		def SplitAfterPositionsQ(panPositions)
			return new stzListOfLists( This.SplitAfterPositions(panPositions) )

		#>

	def SplitAfterPosition(n)
		return This.SplitAfterPosistions([n])

		#< @FunctionFluentForm

		def SplitAfterPositionQ(n)
			return new stzList( This.SplitAfterPosition(n) )

		#>

		#< @FunctionAlternativeForm

		def SplitAfter(n)
			return  This.SplitAfterPositions(n)

		#>

	  #---------------------------#
	 #    SPLITTING TO N PARTS   #
	#---------------------------#

	def SplitToNParts(n)

		aResult = []
	
		nParts = ceil( This.NumberOfItems() / n )

		for i = 1 to This.NumberOfItems() step nParts
			
			aTemp = This.Range(i, nParts)
			aResult + aTemp	
		next

		return aResult

		#< @FunctionFluentForm

		def SplitToNPartsQ(n)
			return new stzList( This.SplitToNParts(n) )

		#>

	  #-----------------------------------------------------------#
	 #    SPLITTING BEFORE AN ITEM VERIFYING A GIVEN CONDITION   #
	#-----------------------------------------------------------#

	def SplitBeforeW(pCondition)
		anPositions = This.FindW(pcCondition)
		aResult = This.SplitBeforePositions(anPositions)

		return aResult	

		def SplitBeforeWQ(pCondition)
			return new stzList( This.SplitBeforeW(pCondition) )

		def SplittedBeforeW(pcCondition)
			return This.SplitBeforeW(pCondition)

		def SplitBeforeWhere(pCondition)
			return This.SplitBeforeW(pCondition)

		def SplittedBeforeWhere(pcCondition)
			return This.SplitBeforeW(pCondition)

	  #-----------------------------------------------------------#
	 #    SPLITTING AFTER AN ITEM VERIFYING A GIVEN CONDITION    #
	#-----------------------------------------------------------#

	def SplitAfterW(pCondition)
		anPositions = This.FindW(pcCondition)
		aResult = This.SplitAfterPositions(anPositions)

		return aResult	

		def SplitAfterWQ(pCondition)
			return new stzList( This.SplitAfterW(pCondition) )

		def SplittedAfterW(pcCondition)
			return This.SplitAfterW(pCondition)

		def SplitAfterWhere(pCondition)
			return This.SplitAfterW(pCondition)

		def SplittedAfterWhere(pcCondition)
			return This.SplitAfterW(pCondition)

	  #-------------------------#
	 #     Section & RANGE     #
	#-------------------------#

	def Section(n1,n2)

		if n1 = :First or n1 = :FirstItem { n1 = 1 }

		if n2 = :Last or n2 = :LastItem { n2 = This.NumberOfItems() }

		if n1 = 0 or n2 = 0
			stzRaise("Zeros are not allowed!")
		ok
	
		if n1 < 1 or n2 > This.NumberOfItems()
			stzRaise("Out of range! Acceptable values [1.."+
	                       this.NumberOfItems() + "]")
		ok
	
		if n1 > n2
			stzRaise("Can't proceed! n1 must be smaller then n2")
		ok
	
		aResult = []
		for i = n1 to n2
			aResult + This.Content()[i]
		next i
		
		return aResult	

		def SectionQ(n1, n2)
			return This.SectionQR(n1, n2, :stzList)

		def SectionQR(n1, n2, pcReturntype)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Section(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Section(n1, n2) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Section(n1, n2) )

			on :stzListOfLists
				return new stzListOfLists( This.Section(n1, n2) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Section(n1, n2) )

			other
				stzRaise("Unsupported return type!")
			off

	def Range(pnStart, pnRange)
		return This.Section( pnStart, pnStart + pnRange-1)

		def RangeQ(pnStart, pnRange)
			return This.RangeQR(pnStart, pnRange, :stzList)

		def RangeQR(pnStart, pnRange, pcReturntype)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Range(pnStart, pnRange) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Range(pnStart, pnRange) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Range(pnStart, pnRange) )

			on :stzListOfLists
				return new stzListOfLists( This.Range(pnStart, pnRange) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Range(pnStart, pnRange) )

			other
				stzRaise("Unsupported return type!")
			off

	  #-------------------#
	 #     MULTINGUAL    #
	#-------------------#

	def AllItemsAreLanguageAbbreviations()
		bResult = TRUE
		for item in This.List()
			if NOT StringIsLanguageAbbreviation(item)
				bResult = FALSE
				exit
			ok
		next
		return bResult

	func IsMultilingualString()
	     
		/* A multilingual string is a hashlist of the form:
			[
			:en = "house",
			:fr = "maison",
			:ar = "منزل"
		     	]

		The keys of the hashlit must be language abbreviations as
		defined by LocaleLanguageAbbreviations() in stzLocale
		*/

		# The MultilingualString must be a hashlist!
		if NOT This.IsHashlist()
			return FALSE
		ok

		# And the translations provided mus be all strings
		oHash = new stzHashList(This.List())
		aValues = oHash.Values()
		oList = new stzList(aValues)
		if NOT oList.AllItemsAre_Strings()
			return FALSE
		ok

		# The keys of the hashlist are the language names or abbreviations
		# Let's check that they are well-formed
		aKeys = oHash.Keys()

		for str in aKeys
			oStr = new stzString(str)
			if NOT (oStr.IsLanguageName() or
				oStr.IsLanguageAbbreviation())
				
				return FALSE
			ok
		next
			
		# Otherwise, the list is a well-formed multilingual string
		return TRUE

	def IsLocaleList()

		if This.NumberOfItems() = 1 and isString(This[1]) and
		   (	This[1] = :Default or This[1] = :DefaultLocale or
			This[1] = :System or This[1] = :SystemLocale or
			This[1] = "C" or This[1] = :CLocale	)

			return TRUE
		ok

		# The list should not exceed 3 items

		if This.NumberOfItems() > 3
			return FALSE
		ok

		# It must be a hashlist

		if NOT This.IsHashList()
			return FALSE
		ok

		# The Hashlist must take the form:
		# 	[ :Language = "...", :Country = "...", ":Script = "..." ]
		# At least one item must be provided. And one, two, or three can
		# can be provided.

		oHash = new stzHashList(This.List())
		oKeys = new stzList(oHash.Keys())

		if NOT (oKeys.IsMadeOfSome([ :Language, :Script, :Country ]) ) 
				return FALSE
		ok

		cLanguage = This.List()[ :Language ]
		cScript   = This.List()[ :Script   ]
		cCountry  = This.List()[ :Country  ]

		if AllTheseAreNull([ cLanguage, cScript, cCountry ])
			return FALSE
		ok

		if NOT AllTheseAreStrings([ cLanguage, cScript, cCountry ])
			return FALSE
		ok
		
		if oKeys.Contains(:Language) and _(cLanguage).@.IsNotLanguageName()
			return FALSE
		ok

		if oKeys.Contains(:Script) and _(cScript).@.IsNotScriptName()
			return FALSE
		ok

		if oKeys.Contains(:Country) and _(cCountry).@.IsNotCountryName()
			return FALSE
		ok

		# At this level we are sure it is a language identification list
		return TRUE

	  #---------------------------------------------#
	 #     NUMBER OF COMMON AND DIFFERENT ITEMS    #
	#---------------------------------------------#

	def NumberOfCommonItemsWith(paItems)
		return len(This.CommonItemsWith(paItems))

	def NumberOfDifferentItemsWith(paItems)
		return len(This.DifferentItmesWith(paItems))

	  #---------------------------------------------#
	 #    DISTRIBUTING THE ITEMS OF THE LIST     #
	#---------------------------------------------#

	def DistributeOver( acBeneficiaryItems, anShareOfEachItem )

		/* Explanation
	
		Distributes the items of the main list over the items of the
		provided list (called metaphorically 'acBeneficiaryItems' here
		as they benfit from that distribution).
		
		The distribution is defined by the share of each item.
		
		The share of each item, defined by anShareOfEachItem, determines
		how many items should be given to the beneficiaries.
		
		--> Returns a hashlist as demonstrated by the following example:
		
		Example:
	
		o1 = new stzList([ :water, :coca, :milk, :spice, :cofee, :tea, :honey ] )
		? o1.DistributeOver([ :arem, :mohsen, :hamma ], :Using = [ 2, 3, 2 ] )
	
		Gives:
	
		[
			:arem   = [ :water, :coca ],
			:mohsen = [ :milk, :spice, :cofee ],
			:hamma  = [ :tea, honey ]
		]
	
		*/

		# The acBeneficiaryItems param should be a list of strings

		if NOT StzListQ(acBeneficiaryItems).IsListOfStrings()     
			stzRaise(stzListError(:CanNoteDistributeItemsOverTheList1))
		ok

		# Controlling the validity of the syntax of anShareOfEachItem param

		if NOT isList(anShareOfEachItem)
			stzRaise("Incorrect param types!")
		ok

		if NOT ( len(anShareOfEachItem) = 2 and
			anShareOfEachItem[1] = :Using and
			ListIsListOfNumbers(anShareOfEachItem[2]) )

				stzRaise("Incorrect param form!")

		ok

		# The sum of numbers in anShareOfEachItem should be equal to the
		# number of items of the main list

		if NOT 	( StzListQ(anShareOfEachItem[2]).IsListOfNumbers() AND
		   	  ListOfNumbersSum(anShareOfEachItem[2]) = This.NumberOfItems()
			)

			stzRaise(stzListError(:CanNoteDistributeItemsOverTheList2))
		ok

		# Now, we can perform the distribution

		anShareOfEachItem = anShareOfEachItem[2]

		aResult = []
		i = 0
		n = 1
		for cBenef in acBeneficiaryItems
			i++
			aResult + [ cBenef, This.Range(n, anShareOfEachItem[i]) ]
			n += anShareOfEachItem[i]
		next

		return aResult
	
	   #-----------------------------------#
	  #   CHECKING PARAM & OPTION LISTS   #
	#------------------------------------#

	def IsCaseSensitiveParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and (This[1] = :Casesensitive or This[1] = :CS) ) and
		   IsBoolean(This[2])

			return TRUE
		else
			return FALSE
		ok

	def IsCounterParamList()  # --> TODO: Move it to stzCounter class
		if StzNumberQ(This.NumberOfItems()).IsBetween(1, 4) and
		   This.IsHashList() and
		   StzHashListQ(This.Content()).KeysListQ().IsMadeOfSome([ :StartAt, :AfterYouSkip, :RestartAt, :Step ])
	
			return TRUE
		else
			return FALSE
		ok	

	def IsTextBoxedParamList() # --> TODO: Move it to TextBoxed() function
		/*
		Example:

		? StzStringQ("TEXT1").BoxedXT([
			:Line = :Thin,	# or :Dashed
		
			:AllCorners = :Round # can also be :Rectangualr
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
			:Width = 17,
			:TextAdjustedTo = :Center # or :Left or :Right or :Justified,
			
			:EachChar = FALSE # TRUE,
			:Hilighted = [ 1, 3 ] # Hilight the 1st and 3rd chars,

			:Numbered = TRUE
		])
		*/
		if This.IsEmpty()
			return TRUE
		ok

		aListOfBoxOptions = [
			:Line,
			:AllCorners,
			:Corners,
			:Width,
			:TextAdjustedTo,
			:EachChar,
			:EachWord,
			:Hilighted,
			:HilightedIf,
			:Numbered
		]

		if StzNumberQ(This.NumberOfItems()).IsBetween(1, len(aListOfBoxOptions)) and
		   This.IsHashList() and
		   StzHashListQ(This.Content()).KeysQ().IsMadeOfSome(aListOfBoxOptions)
		
			return TRUE

		else
			return FALSE
		ok

	def IsBoxParamList()

		if This.IsEmpty()
			return TRUE
		ok

		aListOfBoxOptions = [
			:Line,
			:AllCorners,
			:Corners,
			:Width,
			:TextAdjustedTo,
			:EachChar,

			:Casesensitive,
			:CS,

			:Numbered,
			:Spacified,

			:Shadowed,
			:ShadowChar,
			:ShadowOrientation
			
		]

		if StzNumberQ(This.NumberOfItems()).IsBetween(1, len(aListOfBoxOptions)) and
		   This.IsHashList() and
		   StzHashListQ(This.Content()).KeysQ().IsMadeOfSome(aListOfBoxOptions)
		
			return TRUE

		else
			return FALSE
		ok
	 
	def IsSplitParamList()  # --> TODO: Move it to Split() function

		oKeys = StzListQ(This.ToStzHashList().KeysQ())

		if This.IsHashList() and
		   ( oKeys.IsMadeOfSome([ :CaseSensitive, :Direction ])  OR
		     oKeys.IsMadeOfSome([ :CS, :Direction ]) )

			if This.List()[ :CaseSensitive ] != NULL
				if NOT ( This.List()[ :CaseSensitive ] = TRUE or
				   	 This.List()[ :CaseSensitive ] = FALSE )
	
					return FALSE
				ok
			ok
			
			if This.List()[ :CS ] != NULL

				if NOT ( This.List()[ :CS ] = TRUE or
				         This.List()[ :CS ] = FALSE )
	
					return FALSE
				ok
			ok

			if This.List()[ :Direction ] != NULL

				if NOT ( This.List()[ :Direction ] = :Forward or
				   	 This.List()[ :Direction ] = :Backward )

					return FALSE
				ok
			ok

		ok

		return TRUE

	def IsNumberListifyParamList() # --> TODO: Move it to NumberListify() function
		if This.IsEmpty()
			return TRUE
		ok

		aListOfOptions = [
			:NumberIsContainedInString
		] 

		if This.IsHashList() and
		   StzHashListQ( This.List() ).KeysQ().ExistsIn(aListOfOptions)

				return TRUE   
		else
			return FALSE
		ok

	def IsStringListifyParamList() # --> Move it to StringListify() function
		if This.IsEmpty()
			return TRUE
		ok

		aListOfOptions = [
			:NumberInStringIsTransformedToNumber,
			:ListInstringIsTransformedToList
		] 

		if This.IsHashList() and
		   StzHashListQ( This.List() ).KeysQ().IsIncludedIn(aListOfOptions)

				return TRUE   
		else
			return FALSE
		ok

	def IsRangeParamList()

		if This.IsEmpty()
			return TRUE
		ok

		if NOT (This.IsHashList() and This.NumberOfItems() <= 2)
			return FALSE
		ok

		if This.NumberOfItems() = 1

			if This[1][1] = :Start or This[1][1] = :Range
				return TRUE
			ok
		ok

		if This.NumberOfItems() = 2

			if StzHashListQ( This.List() ).KeysQ().IsEqualTo([ :Start, :Range ]) and
			   StzHashListQ( This.List() ).ValuesQ().BothAreNumbers()

				return TRUE

			else

				return FALSE
			ok
		ok

	def IsStartingAtParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and This[1] = :StartingAt ) and

		   ( isNumber(This[2]) or
		     ( isString(This[2]) and StzStringQ(This[2]).IsOneOfThese([
					:First, :FirstItem, :Last, :LastItem ]) ) )

			return TRUE

		else
			return FALSE
		ok

	def IsExceptParamList()
		# Used initially by ReplaceWordsWithMarquersExceptXT(pcByOption, paExcept)
		# TODO: generalize to all the functions we want to provide exceptions to it

		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and This[1] = :Except ) and

		   ( isString(This[2]) or ( isList(This[2]) and ListIsListOfStrings(This[2])) )

			return TRUE

		else
			return FALSE
		ok

	def IsFromParamList()
		if This.NumberOfItems() = 2 and

		   ( isString(This[1]) and  This[1] = :From ) and

		     ( 	isNumber(This[2] or

			( isString(This[2]) and

		       	  Q(This[2]).IsOneOfThese([
				:StartOfList, :StartOfString, :StartOfSubString, :StartOfWord,
				:StartOfSentence, :StartOfLine, :StartOfParagraph,

				:EndOfList, :EndOfString, :EndOfSubString, :EndOfWord,
				:EndOfSentence, :EndOfLine, :EndOfParagraph ]) ) ) )

			return TRUE

		else
			return FALSE
		ok

	def IsToParamList()
		if This.NumberOfItems() = 2 and

		   ( isString(This[1]) and  This[1] = :To ) and

		     ( 	isNumber(This[2] or

			( isString(This[2]) and

		       	  Q(This[2]).IsOneOfThese([
				:StartOfList, :StartOfString, :StartOfSubString, :StartOfWord,
				:StartOfSentence, :StartOfLine, :StartOfParagraph,

				:EndOfList, :EndOfString, :EndOfSubString, :EndOfWord,
				:EndOfSentence, :EndOfLine, :EndOfParagraph,

				:Foreward, :BackWard ]) ) ) ) # TODO: check if these two are necessary!

			return TRUE

		else
			return FALSE
		ok

	
	def IsOfParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :Of )

			return TRUE

		else
			return FALSE
		ok

	def IsOnParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :On )

			return TRUE

		else
			return FALSE
		ok


	def IsWhereParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :Where ) and
		   isString( This[2] )

			return TRUE

		else
			return FALSE
		ok

	def IsWithParamList()
		if This.NumberOfItems() = 2 and

		   ( isString(This[1]) and  Q(This[1]).IsOneOfThese([ :With, :With@ ]) )

			return TRUE

		else
			return FALSE
		ok

	def IsByParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  Q(This[1]).IsOneOfThese([ :By, :By@ ]) )
		  
			return TRUE

		else
			return FALSE
		ok

	def IsWithOrByParamList()
		return This.IsWithParamList() OR This.IsByParamList()

		def IsByOrWithParamList()
			return This.IsWithOrByParamList()

	def IsUsingParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :Using )

			return TRUE

		else
			return FALSE
		ok

	def IsAtParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :At ) and

		
		   ( isNumber(This[2]) or
		     ( isString(This[2]) and Q(This[2].IsOneOfThese([
				:First, :Last,
				:FirstPosition, :LastPosition,
				:FirstItem, :LastItem ]) ) ) )

			return TRUE

		else
			return FALSE
		ok

	def IsAtPositionParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :AtPosition ) and

		   ( isNumber(This[2]) or
		     ( isString(This[2]) and Q(This[2].IsOneOfThese([
				:First, :Last,
				:FirstPosition, :LastPosition ]) ) ) )


			return TRUE

		else
			return FALSE
		ok

	def IsStepParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  Q(This[1]).IsOneOfThese([ :Step, :Steps ]) ) and
		   isNumber( This[2] )
		  
			return TRUE

		else
			return FALSE
		ok

		def IsStepsParamList()
			return This.IsStepParamList()

	def IsNameParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :Name ) and
		   isString(This[2])
		  
			return TRUE

		else
			return FALSE
		ok

	def IsRaiseParamList()
		if This.NumberOfItems() <= 4 and
		   This.IsHashList() and
		   This.ToStzHashList().KeysQ().IsMadeOfSome([ :Where, :What, :Why, :Todo ]) and
		   This.ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL")

			return TRUE

		else
			return FALSE
		ok
		
	def IsConstraintsParamList()
		/* EXAMPLE
		[
			:OnStzString = [
				:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
				:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
				:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = FALSE) }'
			],
		
			:OnStzNumber = [
				:MustBeStrictlyPositive = '{ @number > 0 }'
			],
		
			:OnStzList = [
				:MustBeAHashList = '{ Q(@list).IsHashList() }'
			]
		]
		*/
		
		try
			VerifyConstraints([
				:MustBeAHashList,
				:KeysMustBeOnStzTypes,
				:ValuesMustBeRingCodeInStrings
			])

			return TRUE

		catch
			return FALSE
		done

	def IsReturnedAsParamList()

		if This.NumberOfItems() = 2 and
		   This.AllItemsAreStrings() and
		   This[1] = :ReturnedAs and
		   StzStringQ(This[2]).IsStzClassName()

			return TRUE

		else
			return FALSE
		ok

	def IsDirectionParamList()
		if This.NumberOfItems() = 2 and
		   ( isString(This[1]) and  This[1] = :Direction ) and
		   ( isString( This[2] ) and Q(This[2]).IsOneOfThese([ :Forward, :Backward ]) )
		  
			return TRUE

		else
			return FALSE
		ok
	  #--------------------------------#
	 #     GETTING TYPES OF ITEMS     #
	#--------------------------------#

	/*
		NOTE: Ring returns types in UPPERCASEn using the type) function.
		While Softanza returns it in LOWERCASE using DataType(), so we
		can usedesignmetrics() the syntax: DataType(p) = :List for example.
	*/

	def Types()
		aResult = []
		for item in This.List()
			aResult + type(item)
		next
		return aResult

		#< @FunctionFluentForm

		def TypesQ()
			return new stzList( This.Types() )

		#>

	def DataTypes()
		aResult = []
		for item in This.List()
			aResult + This.DataType()
		next
		return aResult

		#< @FunctionFluentForm

		def DataTypesQ()
			return new stzList( This.DataTypes() )

		#>

		

	def UniqueTypes()
		aResult = []
		for item in This.List()
			if NOT StzListQ(aResult).Contains( type(item) )
				aResult + type(item)
			ok
		next
		return aResult

		#< @FunctionFluentForm

		def UniqueTypesQ()
			return new stzList( This.UniqueTypes() )

		#>

	  #---------------------------------------------------#
	 #    STARTS / ENDS WITH A GIVEN SUBLIST OF ITEMS    #
	#---------------------------------------------------#

	def StartsWith(paItems)
		if len(paItems) > This.NumberOfItems()
			return FALSE
		ok

		if This.IsStrictlyEqualTo(paItems)
			return TRUE
		ok

		bResult = TRUE

		i = 0
		for item in paItems
			i++
			if _(This[i]).Q.IsNotEqualTo(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def BeginsWith(paItems)
			return This.StartsWith()

	def EndsWith(paItems)
		if len(paItems) > This.NumberOfItems()
			return FALSE
		ok

		if This.IsStrictlyEqualTo(paItems)
			return TRUE
		ok

		bResult = TRUE

		i = 0
		for item in This.NLastItems( len(paItems) )
			i++
			if _(This[i]).Q.IsNotEqualTo(item)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FinishesWith(paItems)
			return This.EndsWith(paItems)

/////////////////////////////////////////////////////////
	  #--------------------------------------------------#
	 #   PERFORMING AN ACTION ON EACH ITEM OF THE LSIT  #
	#--------------------------------------------------#

	def ForEacItemPerform(pcCode)
		# Must begin with '@item ="
		/* Example

		o1 = new stzList([ "village.txt", "town.txt", "country.txt" ])
		o1.ForEachItemPerform('{ Q(@item).RemoveQ(".txt").Content() }')

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
			stzRaise("Invalid param type! Condition must be a string.")
		ok

		oCode = new stzString(pcCode)
		oCode.ReplaceAllCS("@string", "@str", :CaseSensitive = FALSE)

		if NOT oCode.ContainsCS("@str", :CS = FALSE)
			stzRaise("Incorrect parm! Condition should contain '@str' or '@string'.")
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
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ForEachStringYield(pcCode) )

			on :stzListOfStrings
				return new stzListOfStrings( This.ForEachStringYield(pcCode) )
			
			other
				stzRaise("Unsupported return type!")
			off

		def ForEachStringReturn(pcCode)
			This.ForEachStringYield(pcCode)

			def ForEachStringReturnQ(pcCode)
				return This.ForEachStringYieldQ(pcCode)

				def ForEachStringReturnQR(pcCode, pcReturnType)
					if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
						pcReturnType = pcReturnType[2]
					ok

					return This.ForEachStringYieldQR(pcCode, pcReturnType)

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzListOfChars()
		if NOT This.IsListOfChars()
			stzRaise("Can't cast the list into a stzListOfChars!")
		ok

		return new stzListOfChars( This.Content() )

	def FirstAndLastItems()
		aResult = [ This.FirstItem(), This.LastItem() ]
		return aResult

	def LastAndFirstItems()
		aResult = [ This.LastItem(), FirstItem() ]
		return aResult

	  #--------------------------------#
	 #    USUED FOR NATURAL-CODING    #
	#--------------------------------#

	def DataType()
		return :List

	#--- ITEM

	def IsItem()
		return TRUE

	def IsItemOf(paList)
		return StzListQ(paList).Contains(This.Content())
	
		def AsAnItemOf(paList)
			return This.IsItemOf(paList)
	
	def IsItemIn(paList)
		return This.IsItemOf(paList)
	
		def IsAnItemIn(paList)
			return This.IsItemOf(paList)

	# 
	def IsMember()
		return TRUE

	def IsMemberOf(paList)
		return StzListQ(paList).Contains(This.Content())
	
		def AsAMemberOf(paList)
			return This.IsMemberOf(paList)
	
	def IsMemberIn(paList)
		return This.IsMemberOf(paList)
	
		def IsAMemberIn(paList)
			return This.IsMemberOf(paList)


	#--- NUMBER

	def IsANumber()
		return FALSE

	def IsNumberOf(paList)
		return FALSE

		def IsANumberOf(paList)
			return FALSE
	
	def IsNumberIn(paList)
		return FALSE
	
		def IsANumberIn(paList)
			return FALSE

	#--- STRING

	def IsAString()
		return FALSE

	def IsLetter()
		return FALSE

	def IsALetter()
		return FALSE

	def IsLetterOf(pStrOrListOfChars)
		return FALSE

		def IsALetterOf(pcStr)
			return FALSE
	
	def IsLetterIn(pcStr)
		return FALSE

		def IsALetterIn(pcStr)
			FALSE

	def IsCharOf(pStrOrListOfChars)
		return FALSE

		def IsACharOf(pcStr)
			return FALSE

	def IsCharIn(pcStr)
		return FALSE

		def IsACharIn(pcStr)
			return FALSE
