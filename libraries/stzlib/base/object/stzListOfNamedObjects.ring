
func StzListOfNamedObject(paoObjects)

func StzIsListOfNamedObjects(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	_bResult_ = 1
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if NOT IsNamedObject(paList[i])
			_bResult_ = 0
			exit
		ok
	next i

	return _bResult_

	#< @FunctionAlternativeForms

	func IsListOfNamedObjects(paList)
		return StzIsListOfNamedObjects(paList)

	func @IsListOfNamedObjects(paList)
		return StzIsListOfNamedObjects(paList)

	#--

	func IsAListOfNamedObjects(paList)
		return StzIsListOfNamedObjects(paList)

	func @IsAListOfNamedObjects(paList)
		return StzIsListOfNamedObjects(paList)

	#>
 
class stzNamedObjects from stzListOfNamedObjects

class stzListOfNamedObjects from stzList
	@aContent

	def init(paNamedObjects)
		if NOT (isList(paNamedObjects) and Q(paNamedObjects).IsListOfNamedObjects())
			StzRaise("Incorrect param type! paNamedObjects must be a list of named objects.")
		ok

		_nLen_ = len(paNamedObjects)

		for i = 1 to _nLen_
			@aContent + new stzNamedObject(paNamedObjects[i])
		next

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfNamedObjects(This.Content())

	def NamedObject(p)
		if isString(p)
			_result_ = This.Content()[p]
			if _result_ = ""
				StzRaise("Named Object Inexistant!")
			ok

			return _result_

		but isNumber(n)
			return This.Content()[n]

		else
			StzRaise("Incorrect param type! p must be a string or number.")
		ok
