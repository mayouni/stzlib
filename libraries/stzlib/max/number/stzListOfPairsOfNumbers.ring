
func StzListOfPairsOfNumbersQ(paList)
	return new stzListOfPairsOfNumbers(paList)

func AbsDiff(paList)
	return StzListOfPairsOfNumbersQ(paList).AbsDiff()

class stzListOfPairsOfNumbers from stzListOfPairs
	@content = []

	def init(paListOfPairsOfNumbers)

		if NOT @IsListOfPairsOfNumbers(paListOfPairsOfNumbers)
			StzRaise("Incorrect param type! paListOfPairsOfNumbers must be, well, a list of pairs of numbers ;).")
		ok

		@content = paListOfPairsOfNumbers


	def Content()
		return @content

	def Copy()
		return new stzListOfPairsOfNumbers(@content)


	#--

	def Retrive1From2()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anResult_ = []

		for @i = 1 to _nLen_
			_nDiff_ = _aContent_[@i][1] - _aContent_[@i][2]
			_anResult_ + _nDiff_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def Retrieve12()
			return This.Retrieve1From2()

		def 1RetrievedFrom2()
			return This.Retrieve1From2()

		def Retrieved1From2()
			return This.1RetrievedFrom2()

		def Retrieved12()
			return This.1RetrievedFrom2()

		def Diff12()
			This.Retrieve1From2()

		#>

	#---

	def Retrive2From1()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anResult_ = []

		for @i = 1 to _nLen_
			_nDiff_ = _aContent_[@i][2] - _aContent_[@i][1]
			_anResult_ + _nDiff_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def Retrieve21()
			return This.Retrieve2From1()

		def 2RetrievedFrom1()
			return This.Retrieve2From1()

		def Retrieved2From1()
			return This.Retrieve2From1()

		def Retrieved21()
			return This.Retrieve2From1()

		def Diff21()
			This.Retrieve2From1()

		#>

	#---

	def AbsDiff()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anResult_ = []

		for @i = 1 to _nLen_
			_nDiff_ = Abs(_aContent_[@i][1] - _aContent_[@i][2])
			_anResult_ + _nDiff_
		next

		return _anResult_
