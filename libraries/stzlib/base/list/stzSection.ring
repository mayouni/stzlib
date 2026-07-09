
func IsSection(_n1_, _n2_, _nSize_)
	try
		new stzSection(_n1_, _n2_, _nSize_)
		return 1
	catch
		return 0
	done

	func @IsSection(_n1_, _n2_, _nSize_)

func Section(_n1_, _n2_, _nSize_)
	_oSection_ = new stzSection(_n1_, _n2_, _nSize_)
	
	_aResult_ = _oSection_.Content()
	return _aResult_

	#TODO //
	# Bug in Ring: see with Mahmoud why returning the object directly
	# does nt work :return oSection.Content()

func StzSectionQ(_n1_, _n2_, _nSize_)
	return new stzSection(_n1_, _n2_, _nSize_)

class stzSection from stzObject
	@aContent

	def init(_n1_, _n2_, _nSize_)
		if CheckingParams()

			if isList(_nSize_) and IsOneOfTheseNamedParamsList(_nSize_, [
				:Size, :ListSize, :StringSize,
				:NumberOfItems, :NumberOfChars,

				:InAListOfNItems, :InAListOfSize, :InAListOfSizeN, :InAListOfN, :InAListOf,
				:InAStringOfNChars, :InAStringOfSizeN,

				:InListOfNItems, :InListOfSize, :InListOfSizeN, :InListOfN, :InListOf,
				:InStringOfNChars, :InStringOfSizeN

				])

				_nSize_ = _nSize_[2]

				if NOT isNumber(_nSize_)
					StzRaise("Incorrect param type! nSize must be a number.")
				ok
			ok

			# Managing the use of :From and :To named params
	
			if isList(_n1_) and
			   IsOneOfTheseNamedParamsList(_n1_, [
				:From, :FromPosition, :FromCharAt, :FromCharAtPosition,

				:Start, :FromStart,
				:StartingAt, :StartingAtPosition,
				:StartingAtCharAt, :StartingAtCharAtPosition,

				:Between, :BetweenPosition, :BetweenCharAt,
				:BetweenCharAtPosition,

				:BetweenPositions, :BetweenCharsAtPosition,

				#-- Item instead of Char

				:FromItemAt, :FromItemAtPosition,
				:StartingAtItemAt, :StartingAtItemAtPosition,
				:BetweenItemAtPosition, :BetweeItemsAtPosition,

				#==

				:End, :FromEnd

				])
	
				_n1_ = _n1_[2]
			ok
	
			if isList(_n2_) and
			   IsOneOfTheseNamedParamsList(_n2_, [
				:To, :ToPosition, :ToCharAt, :ToCharAtPosition,

				:End, :ToEnd,
				:Until, :UntilPosition, :UntilCharAt, :UntilCharAtPosition,
				:UpTo, :UpToPosition, :UpToCharAt, :UpToCharAtPosition,

				:And,

				#-- Item instead of Char

				:ToItemAt, :ToItemAtPosition,
				:UntilItemAt, :UntilItemAtPosition,
				:UpToItemAt, :UpToItemAtPosition,

				#==

				:Start, :ToStart,
				:DownTo, :DownToItemAt, :DownToItemAtPosition,

				#-- Item instead of Char

				:DowntoCharAt, :DownToCharAtPosition
				])
	
				_n2_ = _n2_[2]
			ok
	
			# Managing the use of :NthToFirst named param
	
			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [
						:NthToFirst, :NthToFirstChar, :NthToFirstItem ])
	
				_n1_ = _n1_[2] + 1
			ok
	
			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [
						:NthToFirst, :NthToFirstChar, :NthToFirstItem ])
	
				_n2_ = _n2_[2] + 1
			ok
	
			# Managing the use of :NthToLast named param
	
			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [
						:NthToLast, :NthToLastChar, :NthToLastItem ])
	
				_n1_ = _nSize_ - _n1_[2]
			ok
	
			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [
						:NthToLast, :NthToLastChar, :NthToLastItem ])
	
				_n2_ = _nSize_ - _n2_[2]
	
			but isList(_n2_) and Q(_n2_).IsStoppingAtNamedParam()
	
				_n2_ = _n2_[2]
			ok
	
			# Managing the case of :First and :Last keywords
	
			if isString(_n1_)

				if StzFindFirst([
					:Start, :First, :FirstChar,
					:FromFirst, :FromFirstChar,
					:FirstItem, :FromFirstItem], _n1_) > 0

					_n1_ = 1
	
				but StzFindFirst([
					:Last, :LastChar, :ToLast, :ToLastChar,
					:LastItem, :ToLastItem ], _n1_) > 0

					_n1_ = _nSize_
	
				but _n1_ = :@
					_n1_ = _n2_

				ok
			ok
		
			if isString(_n2_)

				if StzFindFirst([
					:End, :Last, :LastChar, :EndOfString,
					:ToEnd, :ToLast, :ToLastChar, :ToEndOfString,

					#--

					:LastItem, :EndOfList, :ToLastItem, :ToEndOfList

				], _n2_) > 0

					_n2_ = _nSize_
	
				but StzFindFirst([
					:First, :FirstChar,
					:FromFirst, :FromFirstChar,

					#--

					:FirstItem, :FromFirstItem

				], _n2_) > 0

					_n2_ = 1
	
				but _n2_ = :@
					_n2_ = _n1_

				ok
			ok

			if _n1_ = :@ and _n2_ = :@
				_n1_ = 1
				_n2_ = _nSize_
			ok

		ok

		# Now, params must be numbers


		if NOT (isNumber(_n1_) and _n1_ != 0 and isNumber(_n2_) and _n2_ != 0)
			StzRaise("Incorrect params! n1 and n2 must be numbers different from zero.")
		ok

		if NOT ( _n1_ >= 1 and _n2_ <= _nSize_ )
			StzRaise("Out of range! nSize must between n1 and n2")
		ok

		# Creating the object content

		@aContent = [_n1_, _n2_]

		#TODO // do same behavior in stzList.Section()
		#TODO : Add SectionXT() that allows using out of index params and return accurate results


	def Content()
		return @aContent

	def StartPosition()
		return @aContent[1]

		def StartPos()
			return @aContent[1]

	def EndPosition()
		return @aContent[2]

		def EndPos()
			return @aContent[2]

	#TODO // Add these methods

//	def AddSection(n1, n2)

//	def RemoveSection(n1, n2)
		
//	def AddSections(paSections)

//	def RemoveSections(paSections)

//	def Extend()

//	def ExtendStart()

//		def ExtendFromStart()
//			This.ExtendStart()

//	def ExtendEnd()

//		def ExtendFromEnd()
//			This.ExtendEnd()

//	def Shrink()

//	def ShringStart()

//	def ShringEnd()

//	def Section()
//		return This.Content()

//	def AntiSection()

	def StzType()
		return :stzSection
