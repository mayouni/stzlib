func StzListOfHashListsQ(paList)
	return new stzListOfHashLists(paList)

func StzHashListsQ(paList)
	return new stzListOfHashLists(paList)


class stzHashLists from stzListOfHashLists
class stzListOfAssociativeLists from stzListOfHashLists
class stzAssociativeLists from stzListOfHashLists

# Holds a list of hash lists, such as the rows of a small record set, and wraps or prints them.
#
# Build one with new stzListOfHashLists(aList) or StzListOfHashListsQ(aList); it is a stzList, so
# every list method is available, and init refuses anything but a list of hash lists or an empty
# list. ToListOfStzHashLists wraps each row in a stzHashList to ask its keys and values, and Show
# prints the rows. ToSetOfHashLists is meant to remove repeated rows and does not today.
#
#   receiver   o1 = new stzListOfHashLists([ [ :name = "Ali", :age = 30 ], [ :name = "שלום", :age =
#              5 ] ])
#   example    ? o1.NumberOfItems()
#              #--> 2
#              ? @@( o1.ToListOfStzHashLists()[2].Keys() )
#              #--> [ "name", "age" ]
#   see        stzList, stzHashList
class stzListOfHashLists from stzList
	
	@aContent

	# Builds the object from a list of hash lists, or from an empty list, and raises an error for anything else.
	#
	#   paList     a list whose items are all hash lists, such as [ [ :name = "Ali" ], [ :name =
	#              "Zoe" ] ], or [ ]
	#   returns    nothing; the object is built
	#   warning    any other list or value raises "Can't create stzListOfHashLists object!"
	#   see        Content
	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )

			@aContent = paList

		else
			StzRaise("Can't create stzListOfHashLists object!")
		ok

	# Returns the hash lists the object holds, as they were given.
	#
	#   returns    a list of hash lists
	#   note       Ring stores the keys in lowercase
	#   see        Value, ListOfHashLists
	def Content()
		return @aContent

		# Returns the hash lists the object holds, the same answer as Content.
		#
		#   returns    a list of hash lists
		#   see        Content
		def Value()
			return Content()

	# Returns a new stzListOfHashLists holding the same hash lists.
	#
	#   returns    a new stzListOfHashLists
	#   see        Content
	def Copy()
		return new stzListOfHashLists(This.Content())

	def ListOfHashLists()
		return This.Content()

	# Returns every hash list of the object, repeats included, where a set would drop the repeated ones.
	#
	#   returns    a list of hash lists, the same as Content today
	#   note       ToSet and ToSetOfHashListsQ share the defect
	#   warning    Does not remove repeated hash lists today: [ [ :a = 1 ], [ :a = 1 ] ] answers
	#              both, and three equal ones answer three, because the repeat test compares lists
	#              with Ring's = , which is FALSE for two lists
	#   see        ToListOfStzHashLists
	#@ aka  ToSetOfHashLists: set-style alias returning the deduplicated inner list. For a collection of hash-lists, deep equality is defined as Ring's '=' on the underlying list shapes.
	def ToSetOfHashLists()
		_aRes_ = []
		_nLen_ = len(@aContent)
		for _iSo_ = 1 to _nLen_
			_aHl_ = @aContent[_iSo_]
			_bSeen_ = 0
			_nResLen_ = len(_aRes_)
			for _jSo_ = 1 to _nResLen_
				if _aRes_[_jSo_] = _aHl_
					_bSeen_ = 1
					exit
				ok
			next
			if NOT _bSeen_
				_aRes_ + _aHl_
			ok
		next
		return _aRes_

		def ToSetOfHashListsQ()
			return new stzListOfHashLists( This.ToSetOfHashLists() )

		def ToSet()
			return This.ToSetOfHashLists()

	# Returns each hash list of the object wrapped in a stzHashList, in order.
	#
	#   returns    a list of stzHashList objects; [ ] for an empty object
	#   see        Content
	def ToListOfStzHashLists()
		_aResult_ = []
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_
			_aResult_ + new stzHashList(@aContent[i])
		next

		return _aResult_

	# Prints every hash list, one key : value line per entry, with a blank line between the hash lists.
	#
	#   returns    nothing
	#   note       Shwo is the same method under a misspelling
	#   warning    A value that is itself a list raises error R21 (Using operator with values of
	#              incorrect type) today; only texts and numbers print
	#   see        ToListOfStzHashLists
	def Show()

		_cResult_ = ""
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_

			_aHashList_ = @aContent[i]
			_nLenHash_ = len(_aHashList_)

			for j = 1 to _nLenHash_
				_cLine_ = _aHashList_[j][1] + " : " + _aHashList_[j][2]
				_cResult_ += _cLine_ + char(10)
			next

			_cResult_ += char(10)
		next

		? ring_trim(_cResult_)

		# Prints every hash list, one key : value line per entry, the same as Show under a misspelling.
		#
		#   returns    nothing
		#   warning    A value that is itself a list raises error R21, as in Show
		#   see        Show
		#< @FuntionMisspelledForm
		def Shwo()
			This.Show()

		#>
