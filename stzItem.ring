
// Functions used by the stzDynamicList
	func @(pItem)
		return new stzActiveItem(pItem)
	
	func IsActiveItem(pItem)
		if isObject(pItem) and classname(pItem) = lower("stzActiveItem")
			return TRUE
		else
			return FALSE
		ok
	
	func ComposeFunction( pcFuncName, paFuncParam )
		cResult = pcFuncName + "( '@'+ pItem.Content() + ' >> ' + "
	
		for i=1 to len(paFuncParam)
			if isString(paFuncParam[i]) { cResult += '"' }
			cResult += paFuncParam[i]
			if isString(paFuncParam[i]) { cResult += '"' }
			if i < len(paFuncParam)
				cResult += ", "
			ok
		next
		cResult += ")"

		return cResult

// The main class

class stzDynamicList from stzObject
	aContent = []

	aEvents = []

	stz	// hosts stzList services used by this class

	def init(paList)
		for item in paList
			AddItem(item)
		next

		stz = new stzList(paList)

	def Content()
		for item in aContent
			if isActiveItem(item)
				cStr = "@"+ item.Content()
			else
				cStr = item
			ok
			? cStr
		next

	def AddItem(pItem)
		aContent + pItem

		if IsActiveItem(pItem)	
			Execute(pItem, pItem.DoWhenAdded())
		ok

	def AddActiveItem(pItem)
		 AddItem(@(pItem))

	def Item(n)
		return stz.Item(n) //aContent[n]

	def ReplaceItem(n, pValue)
		if IsActiveItem( Item(n) )
			Execute(Item(n), Item(n).DoWhenUpdated())
		ok

		if IsActiveItem(pValue)
			Execute( pValue, pValue.DoWhenAssigned())
		ok

		aContent[ n ] = pValue

	def Execute( pItem, paFunc )
		// Note : pItem param is used inside the dynamaic code
		// of ComposeFunction, so don't delete it!
		cFunc = paFunc[1]
		aParam = paFunc[2]
		eval(ComposeFunction(cFunc, aParam))
		
	def Say(pcSomthing)
		? pcSomthing


class stzActiveItem from stzObject
	Content
	evtOnItemAdded
	aDoWhenAdded = [ :Say, ["is added!"] ]
	aDoWhenReplaced = [ :Say, ["is replaced!"] ]
	aDoWhenRemoved = [ :Say, ["is removed!"] ]
	aDoWhenCopied = [ :Say, ["is copied!"] ]

	aDoWhenAssigned = [ :Say, ["is assigned!"] ]

	aDoWhenVisited = [ :Say, ["is visited!"] ]
	aDoWhenSkipped = [ :Say, ["is skipped!"] ]

	def init(pItem)	# pItem can be anything. pContainer can be List or String.
		Content = pItem

	def Content()
		return Content

	def Type()
		return type(pItem)

	def DoWhenAdded()
		return aDoWhenAdded

	def DoWhenUpdated()
		return aDoWhenUpdated

	def DoWhenAssigned()
		return aDoWhenAssigned

	def DoWhenListCreated()
		return aDoWhenListCreated



	
