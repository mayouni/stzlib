
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

# Is meant to hold named objects and fetch one by name or position; it can not be built with a list today.
#
# Building it with a list raises R14, because init calls IsListOfNamedObjects on a stzList and that
# method does not exist, so Copy raises as well. A holder built without parentheses is empty;
# Content and Value return its empty list. NamedObject looks a name up and raises for an unknown
# one; its number branch tests the wrong variable and raises. stzNamedObjects is another name of it.
#
#   receiver   o1 = new stzListOfNamedObjects
#   example    ? len(o1.Content())
#              #--> 0
#   see        stzListOfObjects, stzNamedObjects, stzNamedObject
class stzListOfNamedObjects from stzList
	@aContent

	# Raises error R14 today instead of building a list of named objects from the given list.
	#
	#   paNamedObjects   the list of named objects meant to be held
	#   returns          nothing; it raises
	#   note             new stzListOfNamedObjects without parentheses skips init and builds an
	#                    empty holder
	#   warning          the check calls IsListOfNamedObjects on a stzList, a method that does not
	#                    exist, so every list raises R14 Calling Method without definition:
	#                    islistofnamedobjects (tried with an empty list and with one object); a
	#                    value that is not a list raises Incorrect param type
	#   see              Content, NamedObject
	def init(paNamedObjects)
		if NOT (isList(paNamedObjects) and Q(paNamedObjects).IsListOfNamedObjects())
			StzRaise("Incorrect param type! paNamedObjects must be a list of named objects.")
		ok

		_nLen_ = len(paNamedObjects)

		for i = 1 to _nLen_
			@aContent + new stzNamedObject(paNamedObjects[i])
		next

	# Returns the list of named objects, which is empty for a holder built without init.
	#
	#   returns    a list
	#   see        Value, NamedObject
	def Content()
		return @aContent

		# Returns the same list as Content.
		#
		#   returns    a list
		#   see        Content
		def Value()
			return Content()

	# Raises error R14 today instead of returning a copy of the list: it builds a new one through init, which raises.
	#
	#   returns    nothing; it raises
	#   see        Content, init
	def Copy()
		return new stzListOfNamedObjects(This.Content())

	# Returns the named object of that name, but raises for a name that is not there and for a number.
	#
	#   p          the name of the object, a text
	#   returns    the named object; it raises Named Object Inexistant! for an unknown name
	#   note       the name lookup is the only branch that can answer
	#   warning    a number or a list raises Incorrect param type! p must be a string or number,
	#              because the number branch tests an undefined variable n instead of p (checked
	#              with 1 and with [ 1 ])
	#   see        Content
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
