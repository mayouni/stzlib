
func StzListOfNamedObject(paoObjects)
	return new stzListOfNamedObjects(paoObjects)

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

# Is another name of stzListOfNamedObjects: a list of named objects, with every method of it.
#
# The class adds nothing: it is built, read and copied exactly as a stzListOfNamedObjects, and Copy
# answers a stzListOfNamedObjects.
#
#   receiver   o1 = new stzString("ab")
#   example    o1.SetName("oFirst")
#              o2 = new stzNamedObjects([ o1 ])
#              ? len(o2.Content())
#              #--> 1
#   see        stzListOfNamedObjects
class stzNamedObjects from stzListOfNamedObjects

# Holds a list of named objects, which are library objects carrying a variable name, and fetches one by name or position.
#
# A named object is an object of a library class that has been given a name with SetName (or
# StzNamedObject): an object with no name, a number, a text, a list and an object of a class of your
# own are not named objects, and init refuses a list holding one. The empty list is a valid holder.
# The names must be distinct, and case does not count, as with the variable names of Ring: oFirst
# and OFIRST are one name, so a list holding both is refused. NamedObject finds an object by that
# name, in any case, or by its position. The holder keeps its own objects. Ring copies an object when
# it is assigned, so the list given to init is copied in, and an object taken from NamedObject or
# from Content into a variable is a copy: renaming it leaves the holder as it was. The objects added
# afterwards with the inherited list methods, as AddItem, are not checked, and neither is a call
# chained on an element of Content, which acts on the holder's own object. A holder built without
# parentheses is empty. The other methods are those of stzList.
#
#   receiver   o1 = new stzListOfNamedObjects
#   example    ? len(o1.Content())
#              #--> 0
#              o2 = new stzString("ab")
#              o2.SetName("oFirst")
#              o3 = new stzListOfNamedObjects([ o2 ])
#              ? o3.NamedObject("OFIRST").Content()
#              #--> ab
#   see        stzListOfObjects, stzNamedObjects, StzIsListOfNamedObjects
class stzListOfNamedObjects from stzList
	@aContent = []

	# Builds the holder from a list of named objects, and raises an error for anything else.
	#
	#   paNamedObjects   the list of objects to hold, each carrying a variable name; the empty list is accepted
	#   returns          nothing; the holder is built
	#   note             a list holding one item that is not a named object (an object with no name,
	#                    a number, a text, a list, an object of your own class) is refused, and so is
	#                    a value that is not a list, with one message; two objects whose names differ
	#                    only by case, or not at all, are refused with another message; the holder
	#                    keeps copies, so changing the caller's list afterwards leaves it alone; new
	#                    stzListOfNamedObjects without parentheses skips this method and builds an
	#                    empty holder
	#   see              Content, Copy, NamedObject
	def init(paNamedObjects)
		if NOT (isList(paNamedObjects) and StzIsListOfNamedObjects(paNamedObjects))
			StzRaise("Incorrect param type! paNamedObjects must be a list of named objects.")
		ok

		_nLen_ = len(paNamedObjects)
		_acNames_ = []
		for i = 1 to _nLen_
			_acNames_ + StzLower(paNamedObjects[i].Name())
		next

		if len(StzU(_acNames_)) != _nLen_
			StzRaise("Incorrect param value! The objects must have distinct names, case does not count.")
		ok

		@aContent = paNamedObjects

	# Returns the held objects as a plain Ring list, which a variable takes as copies of them.
	#
	#   returns    a list of objects, empty for an empty holder
	#   note       Ring copies an object when it is assigned: a list taken into a variable holds
	#              copies, so renaming one of them or growing the list leaves the holder as it was
	#   see        Value, NamedObject
	def Content()
		return @aContent

		# Returns the same list as Content.
		#
		#   returns    a list of objects
		#   see        Content
		def Value()
			return Content()

	# Returns a new holder of the same objects, which changing leaves this one alone.
	#
	#   returns    a stzListOfNamedObjects
	#   note       the copy holds its own copies of the objects; a copy of a stzNamedObjects is a
	#              stzListOfNamedObjects; it is built through init, so it raises if objects added
	#              afterwards with AddItem made the content stop being a valid list
	#   see        Content, init
	#   example    o2 = new stzString("ab")
	#              o2.SetName("oFirst")
	#              o3 = new stzListOfNamedObjects([ o2 ])
	#              ? len(o3.Copy().Content())
	#              #--> 1
	def Copy()
		return new stzListOfNamedObjects(This.Content())

	# Returns the object that carries a name or sits at a position, and raises when there is none.
	#
	#   p          the name of the object, a text in any case, or its position from 1, a whole number
	#   returns    the object, a copy of the one held
	#   note       the first of two objects added with the same name wins; a copy renamed leaves the
	#              held object as it was
	#   warning    an unknown name, a position below 1 or past the last, and a position that is not a
	#              whole number raise Named Object Inexistant!; a value that is neither a text nor a
	#              number raises Incorrect param type!
	#   see        Content, init
	#   example    o2 = new stzString("ab")
	#              o2.SetName("oFirst")
	#              o3 = new stzListOfNamedObjects([ o2 ])
	#              ? o3.NamedObject("OFIRST").Content()
	#              #--> ab
	#              ? o3.NamedObject(1).Content()
	#              #--> ab
	def NamedObject(p)
		if isString(p)
			_cName_ = StzLower(p)
			_nLen_ = len(@aContent)
			for i = 1 to _nLen_
				if StzLower(@aContent[i].Name()) = _cName_
					return @aContent[i]
				ok
			next

			StzRaise("Named Object Inexistant!")

		but isNumber(p)
			if p < 1 or p > len(@aContent) or p != floor(p)
				StzRaise("Named Object Inexistant!")
			ok

			_nPos_ = floor(p)
			return @aContent[_nPos_]

		else
			StzRaise("Incorrect param type! p must be a string or number.")
		ok
