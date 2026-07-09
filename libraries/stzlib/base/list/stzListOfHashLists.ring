func StzListOfHashListsQ(paList)
	return new stzListOfHashLists(paList)

func StzHashListsQ(paList)
	return new stzListOfHashLists(paList)


class stzHashLists from stzListOfHashLists
class stzListOfAssociativeLists from stzListOfHashLists
class stzAssociativeLists from stzListOfHashLists

class stzListOfHashLists from stzList
	
	@aContent

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )

			@aContent = paList

		else
			StzRaise("Can't create stzListOfHashLists object!")
		ok

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfHashLists(This.Content())

	def ListOfHashLists()
		return This.Content()

	# ToSetOfHashLists: set-style alias returning the deduplicated
	# inner list. For a collection of hash-lists, deep equality is
	# defined as Ring's '=' on the underlying list shapes.
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

	def ToListOfStzHashLists()
		_aResult_ = []
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_
			_aResult_ + new stzHashList(@aContent[i])
		next

		return _aResult_

	def Show()

		_cResult_ = ""
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_

			_aHashList_ = @aContent[i]
			_nLenHash_ = len(_aHashList_)

			for j = 1 to _nLenHash_
				_cLine_ = _aHashList_[j][1] + " : " + _aHashList_[j][2]
				_cResult_ += _cLine_ + NL
			next

			_cResult_ += NL
		next

		? ring_trim(_cResult_)

		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>
