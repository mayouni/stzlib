
#~~~~~~~~~~~~~#
#  FUNCTIONS  #
#~~~~~~~~~~~~~#


func FindMin(anNumbers)

	if NOT isList(anNumbers)
		stzraise("Incorrect param type! anNumbers must be a list.")
	ok

	_nLen_ = len(anNumbers)

	# Early check

	if _nLen_ = 0
		return 0

	but _nLen_ = 1
		return 1
	ok

	_nResult_ = 1
	_nTempNumber_ = anNumbers[1]

	for _i_ = 2 to _nLen_
		if anNumbers[_i_] < _nTempNumber_
			_nResult_ = _i_
			_nTempNumber_ = anNumbers[_i_]
		ok
	next

	return _nResult_

	func @FindMin(anNumbers)
		return FindMin(anNumbers)

func FindMax(anNumbers)

	if NOT isList(anNumbers)
		stzraise("Incorrect param type! anNumbers must be a list.")
	ok

	_nLen_ = len(anNumbers)

	# Early check

	if _nLen_ = 0
		return 0

	but _nLen_ = 1
		return 1
	ok

	_nResult_ = 1
	_nTempNumber_ = anNumbers[1]

	for _i_ = 2 to _nLen_
		if anNumbers[_i_] > _nTempNumber_
			_nResult_ = _i_
			_nTempNumber_ = anNumbers[_i_]
		ok
	next

	return _nResult_

	func @FindMax(anNumbers)
		return FindMax(anNumbers)

func Max(panNumbers)
	return panNumbers[ FindMax(panNumbers) ]

	func @Max(panNumbers)
		return Max(panNumbers)

func Min(panNumbers)
	return panNumbers[ FindMin(panNumbers) ]

	func @Min(panNumbers)
		return Min(panNumbers)

#~~~~~~~~~#
#  CLASS  #
#~~~~~~~~~#

class stzCoreListOfNumbers from stkListOfNumbers

class stkListOfNumbers
