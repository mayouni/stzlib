#-------------------------------#
#  COMMON FOR ALL LIST CLASSES  #
#-------------------------------#

func ListReverse(aList)
	_aResult_ = []
	for i = len(aList) to 1 step -1
		add(_aResult_, aList[i])
	next
	return _aResult_

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
	_nLen_ = len(aList)
	for i = 1 to _nLen_
		if ListsDeepEqual(aList[i], pItem)
			return TRUE
		ok
	next
	return FALSE

	func @ListContains(aList, pItem)
		return ListContains(aList, pItem)

func ListFlatten(aList)
	_aResult_ = []
	_nLen_ = len(aList)
	for i = 1 to _nLen_
		if isList(aList[i])
			_aFlat_ = ListFlatten(aList[i])
			for item in _aFlat_
				add(_aResult_, item)
			next
		else
			add(_aResult_, aList[i])
		ok
	next
	return _aResult_

	func @ListFlatten(aList)
		return ListFlatten(aList)

func ListUnique(aList)
	_aResult_ = []
	_nLen_ = len(aList)
	for i = 1 to _nLen_
		if NOT ListContains(_aResult_, aList[i])
			add(_aResult_, aList[i])
		ok
	next
	return _aResult_

	func @ListUnique(aList)
		return ListUnique(aList)

func ListSection(aList, n1, n2)
	_aResult_ = []
	if n1 < 1 n1 = 1 ok
	if n2 > len(aList) n2 = len(aList) ok
	for i = n1 to n2
		add(_aResult_, aList[i])
	next
	return _aResult_

	func @ListSection(aList, n1, n2)
		return ListSection(aList, n1, n2)
