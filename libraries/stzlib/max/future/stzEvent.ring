
/*
o1 = new stzList(1:3)
o1 {
	evtOnItemAdded = "? NumberOfItems()"
	AddItem("5")
}


class stzList from stzObject
	aContent = []

	evtOnItemAdded 		= NULL
	evtOnItemRemoved 	= NULL
	evtOnItemUpdated 	= NULL
	evtOnItemInserted 	= NULL
	evtOnItemCopied 	= NULL

	evtListInitiated	= NULL
	evtListBecomingEmpty	= NULL

	def init(paList)
		aContent = paList

	def AddItem(pItem)
		if evtOnItemAdded != NULL
			eval(evtOnItemAdded)
		ok
		
	def NumberOfItems()
		return len(aContent)

