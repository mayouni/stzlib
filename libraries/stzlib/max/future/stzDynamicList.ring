
//@C = @("C") { OnItemAdded = 'dyn.Content() + "V"' }
/*
@C = new stzActiveItem("C") 
@C {
	OnItemAdded = 'dyn.Content() + "V"'
	OnItemUpdated = 'dyn.Content() + "W"'
}
*/

dyn = new stzDynamicList([ "X","A", "B", @("C") ])

dyn {
	
/*
	? Show()
	ReplaceItem(5,"X")
	? Show()
*/
	

	? Show()
	
	? ItemPosition(@("C"))
}

// Functions used by the stzDynamicList
	
	func  StzDynamicListQ(paList)
		return new stzDynamicList(paList)
	
	func StzActiveItem(pItem)
		return new stzActiveItem(pItem)
	
	func StzActiveItemQ(pItem)
		return new stzActiveItem(pItem)

	func @(pItem)
		if NOT IsActiveItem(pItem)
			@ = new stzActiveItem(pItem)
			return @
			/*
			Then we ceate it and give it a name (value decorated by @)
				@C = new stzActiveItem("C")
				return @C
			
			cObjectName = "@" + pItem 
			cCode =
			cObjectName + ' = new stzActiveItem("' + pItem + '")' + NL +
			'return ' + cObjectName

			eval(cCode)
			*/
		else
			// Returning the ActiveItem object by content
			return GetActiveObjectByContent(pItem)
			/*
				ActiveItem must be Unique but can appear in many places in the list
			*/ 
		ok
	
	func IsActiveItem(pItem)
		if isObject(pItem) and classname(pItem) = lower("stzActiveItem")
			return _TRUE_
		else
			return _FALSE_
		ok

		func @IsActiveItem(pItem)
			return IsActiveItem(pItem)
	
// The main class

class stzDynamicList from stzObject
	aContent = []

	def init(paList)
		
		for item in paList
			AddItem(item)
		next

		stz = new stzList(paList)

	def Show()
		for item in aContent
			if isActiveItem(item)
				cStr = "@"+ item.Content()
			else
				cStr = item
			ok
			? cStr
		next

		#< @FunctionMisspelledForm

		def Shwo()
			This.Show()

		#>

	def AddItem(pItem)
		aContent + pItem

		if IsActiveItem(pItem)
			pItem.SetPosition( len(aContent) )
			if pItem.OnItemAdded != _NULL_
				eval(pItem.OnItemAdded)
			ok
		ok

	def ReplaceItem(n, pValue)

		if IsActiveItem(aContent[n])
			if aContent[n].OnItemUpdated != _NULL_
				eval(aContent[n].OnItemUpdated)
			ok
		ok

		aContent[ n ] = pValue

	def AddActiveItem(pItem)
		 AddItem(@(pItem))

	def Item(n)
		return aContent[n]

	def Content()
		return aContent

		def Value()
			return This.Content()

	def LastItem()
		return Content()[ len(Content()) ]

	def ActiveItems()
		aResult = []
		for item in Content()
			if isActiveItem(item)
				aResult + item
			ok
		next
		return aResult

	def GetActiveItemByContent(pContent)
		for oActiveItem in ActiveItems()
			if oActiveItem.Content = pContent
				return oActiveItem
			ok
		next
		
	def ItemPosition(pItem)
		if NOT IsActiveItem(pItem)
			return ring_find( Content(), pItem )
		else
 			pObj = GetActiveItemByContent(pItem.Content())
			oTempList = new stzList( Content() )
			return oTempList.FindFirst( pObj )
			#TODO // Shouldn't we use FindAll() to catch all the
			# position of pItem in that list?
		ok

class stzActiveItem from stzObject
	Content
	nPosition

	OnItemAdded 	= _NULL_	// '? "@" + pItem.Content() + " is added"'

	OnItemRemoved 	= _NULL_
	OnItemUpdated 	= _NULL_
	OnItemInserted 	= _NULL_

	def init(pItem)	# pItem can be anything. pContainer can be List or String.
		Content = pItem

	def Content()
		return Content

		def Value()
			return This.Content()

	def SetPosition(n)

		nPosition = n

	def Position()
		return nPosition




	
