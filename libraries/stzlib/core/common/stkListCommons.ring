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

# Deep value-equality for list items: Ring's `=` does NOT compare two
# lists by content, so membership/contains on lists needs this.
func ListsDeepEqual(pA, pB)
	if isList(pA) and isList(pB)
		if len(pA) != len(pB) return FALSE ok
		_nLde_ = len(pA)
		for _ilde_ = 1 to _nLde_
			if NOT ListsDeepEqual(pA[_ilde_], pB[_ilde_]) return FALSE ok
		next
		return TRUE
	but isList(pA) or isList(pB)
		return FALSE
	ok
	return pA = pB

func ListContains(aList, pItem)
	nLen = len(aList)
	for i = 1 to nLen
		if ListsDeepEqual(aList[i], pItem)
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
