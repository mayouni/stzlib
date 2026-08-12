func @IsPpointer(p)
	return isPointer(p) # A Ring standard function

func ArePointers(paPointers)
	if NOT isList(paPointers)

		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paPointers)

	for i = 1 to _nLen_
		if NOT isPointer(paPointers[i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func @ArePointers(paPointers)
		return ArePointers(paPointers)
