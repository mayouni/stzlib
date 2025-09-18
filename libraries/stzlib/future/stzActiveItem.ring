load "../stzlib.ring"
/*
Example:

oLetters = new stzDynamicList([ "A", "B", @("C"), "D" ,@("E") ])

oLetters {
	? "" ? Content()
	AddItem("Z")
	AddActiveItem("W") { aDoWhenAdded = [ :Say, ["I'm added now!"] ]}
	? ""
	ReplaceItem(3, @("X") { aDoWhenAssigned = [ :Say, ["Ho! Assigned."] ]} )
	? "" ? Content()	
}
*/

// Functions used by the stzDynamicList
	
	func IsActiveItem(pItem)
		if isObject(pItem) and classname(pItem) = lower("stzActiveItem")
			return 1
		else
			return 0
		ok
	
		func @IsActiveItem(pItem)
			return IsActiveItem(pItem)

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

		def Value()
			return This.Content()

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
			Execute(Item(n), Item(n).DoWhenReplaced())
		ok

		if IsActiveItem(pValue)
			Execute( pValue, pValue.DoWhenAssigned())
		ok

		aContent[ n ] = pValue

	def RemoveItem(n)
		if IsActiveItem( Item(n) )
			Execute(Item(n), Item(n).DoWhenRemoved())
		ok

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

		def Value()
			return This.Content()

	def DoWhenAdded()
		return aDoWhenAdded

	def DoWhenReplaced()
		return aDoWhenReplaced

	def DoWhenAssigned()
		return aDoWhenAssigned

	def DoWhenListCreated()
		return aDoWhenListCreated



	
