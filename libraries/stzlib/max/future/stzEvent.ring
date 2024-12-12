
/*
o1 = new stzList(1:3)
o1 {
	evtOnItemAdded = "? NumberOfItems()"
	AddItem("5")
}


class stzList from stzObject
	aContent = []

	evtOnItemAdded 		= _NULL_
	evtOnItemRemoved 	= _NULL_
	evtOnItemUpdated 	= _NULL_
	evtOnItemInserted 	= _NULL_
	evtOnItemCopied 	= _NULL_

	evtListInitiated	= _NULL_
	evtListBecomingEmpty	= _NULL_

	def init(paList)
		aContent = paList

	def AddItem(pItem)
		if evtOnItemAdded != _NULL_
			eval(evtOnItemAdded)
		ok
		
	def NumberOfItems()
		return len(aContent)

