#-------------------------------#
#  COMMON FOR ALL LIST CLASSES  #
#-------------------------------#

func ListReverse(aList)
	aResult = []
	for i = len(aList) to 1 step -1
		add(aResult, aList[i])
	next
	return aResult

	func @ListReverse(aList)
		return ListReverse(aList)

func ListContains(aList, pItem)
	nLen = len(aList)
	for i = 1 to nLen
		if aList[i] = pItem
			return TRUE
		ok
	next
	return FALSE

	func @ListContains(aList, pItem)
		return ListContains(aList, pItem)

func ListFlatten(aList)
	aResult = []
	nLen = len(aList)
	for i = 1 to nLen
		if isList(aList[i])
			aFlat = ListFlatten(aList[i])
			for item in aFlat
				add(aResult, item)
			next
		else
			add(aResult, aList[i])
		ok
	next
	return aResult

	func @ListFlatten(aList)
		return ListFlatten(aList)

func ListUnique(aList)
	aResult = []
	nLen = len(aList)
	for i = 1 to nLen
		if NOT ListContains(aResult, aList[i])
			add(aResult, aList[i])
		ok
	next
	return aResult

	func @ListUnique(aList)
		return ListUnique(aList)

func ListSection(aList, n1, n2)
	aResult = []
	if n1 < 1 n1 = 1 ok
	if n2 > len(aList) n2 = len(aList) ok
	for i = n1 to n2
		add(aResult, aList[i])
	next
	return aResult

	func @ListSection(aList, n1, n2)
		return ListSection(aList, n1, n2)
