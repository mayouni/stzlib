
func StzListOfNamedObject(paoObjects)

func IsListOfNamedObjects(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult _TRUE_
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsNamedObject(paList[i])
			bResult _FALSE_
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfNamedObjects(paList)
		return IsListOfObjects(paList)

	#--

	func IsAListOfNamedObjects(paList)
		return IsListOfObjects(paList)

	func @IsAListOfNamedObjects(paList)
		return IsListOfObjects(paList)

	#>
 
class stzNamedObjects from stzListOfNamedObjects

class stzListOfNamedObjects from stzList
	@aContent

	def init(paNamedObjects)
		if NOT (isList(paNamedObjects) and Q(paNamedObjects).IsListOfNamedObjects())
			StzRaise("Incorrect param type! paNamedObjects must be a list of named objects.")
		ok

		nLen = len(paNamedObjects)

		for i = 1 to nLen
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
			result = This.Content()[p]
			if result = ""
				StzRaise("Named Object Inexistant!")
			ok

			return result

		but isNumber(n)
			return This.Content()[n]

		else
			StzRaise("Incorrect param type! p must be a string or number.")
		ok
