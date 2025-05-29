func @IsPpointer(p)
	return isPointer(p) # A Ring standard function

func ArePointers(paPointers)
	if NOT isList(paPointers)

		return FALSE
	ok

	bResult = TRUE
	nLen = len(paPointers)

	for i = 1 to nLen
		if NOT isPointer(paPointers[i])
			bResult = FALSE
			exit
		ok
	next

	return bResult

	func @ArePointers(paPointers)
		return ArePointers(paPointers)
