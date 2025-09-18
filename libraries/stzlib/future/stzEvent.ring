
/*
o1 = new stzList(1:3)
o1 {
	evtOnItemAdded = "? NumberOfItems()"
	AddItem("5")
}


class stzList from stzObject
	aContent = []

	evtOnItemAdded 		= ""
	evtOnItemRemoved 	= ""
	evtOnItemUpdated 	= ""
	evtOnItemInserted 	= ""
	evtOnItemCopied 	= ""

	evtListInitiated	= ""
	evtListBecomingEmpty	= ""

	def init(paList)
		aContent = paList

	def AddItem(pItem)
		if evtOnItemAdded != ""
			eval(evtOnItemAdded)
		ok
		
	def NumberOfItems()
		return len(aContent)

