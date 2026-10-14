
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

# Holds a section, the start and end positions of a stretch of a list or a string, checked against the size of that host.
#
# Build one with new stzSection(n1, n2, nSize) or StzSectionQ(n1, n2, nSize); the global Section(n1,
# n2, nSize) answers just the [ start, end ] list and IsSection(n1, n2, nSize) tells whether the
# three numbers make a valid section. The positions may be keywords (:First, :Last) or named places
# ([ :From, 3 ], [ :To, 6 ]). Positions count from 1 and negative ones are refused. The check is
# incomplete: a start past the size is accepted when the end is inside, and nothing orders the two
# positions.
#
#   receiver   o1 = new stzSection(2, 5, 10)
#   example    ? @@( o1.Content() )
#              #--> [ 2, 5 ]
#              ? o1.StartPosition()
#              #--> 2
#              ? o1.EndPosition()
#              #--> 5
#              ? IsSection(1, 11, 10)
#              #--> 0
#   see        stzSetOfSections, stzListSections, stzList
class stzSection from stzObject
	@aContent

	# Builds a section, a pair of start and end positions, checked against the size of the list or string it is meant for.
	#
	#   _n1_       the start position, from 1, or a keyword such as :First, :Start or a named place
	#              such as [ :From, 3 ]
	#   _n2_       the end position, from 1, or :Last, :End or [ :To, 6 ]
	#   _nSize_    the number of items or chars of the host, or [ :Size, 10 ]
	#   returns    nothing; the object is built
	#   note       negative positions that count from the end are refused here, unlike
	#              stzList.Section
	#   warning    A start or end of 0, or not a number, raises "Incorrect params! n1 and n2 must be
	#              numbers different from zero"; an end past the size, or a negative position,
	#              raises "Out of range! nSize must between n1 and n2"; a start past the size is
	#              accepted when the end is inside it: new stzSection(12, 3, 10) answers [ 12, 3 ],
	#              and a start after the end is kept as given
	#   see        Content, IsSection
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

				if StzFindFirst(_n1_, [
					:Start, :First, :FirstChar,
					:FromFirst, :FromFirstChar,
					:FirstItem, :FromFirstItem]) > 0

					_n1_ = 1
	
				but StzFindFirst(_n1_, [
					:Last, :LastChar, :ToLast, :ToLastChar,
					:LastItem, :ToLastItem ]) > 0

					_n1_ = _nSize_
	
				but _n1_ = :@
					_n1_ = _n2_

				ok
			ok
		
			if isString(_n2_)

				if StzFindFirst(_n2_, [
					:End, :Last, :LastChar, :EndOfString,
					:ToEnd, :ToLast, :ToLastChar, :ToEndOfString,

					#--

					:LastItem, :EndOfList, :ToLastItem, :ToEndOfList

				]) > 0

					_n2_ = _nSize_
	
				but StzFindFirst(_n2_, [
					:First, :FirstChar,
					:FromFirst, :FromFirstChar,

					#--

					:FirstItem, :FromFirstItem

				]) > 0

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

	# Returns the section as a list of its start and end positions.
	#
	#   returns    a list of two numbers, [ start, end ]
	#   see        StartPosition, EndPosition
		#TODO // do same behavior in stzList.Section()
		#TODO : Add SectionXT() that allows using out of index params and return accurate results
	def Content()
		return @aContent

	# Returns the first position of the section, as given.
	#
	#   returns    a number
	#   note       a section built as (5, 2, 10) is not reordered: its start is 5
	#   see        EndPosition, StartPos
	def StartPosition()
		return @aContent[1]

		# Returns the first position of the section, the same as StartPosition.
		#
		#   returns    a number
		#   see        StartPosition
		def StartPos()
			return @aContent[1]

	# Returns the last position of the section, as given.
	#
	#   returns    a number
	#   see        StartPosition, EndPos
	def EndPosition()
		return @aContent[2]

		# Returns the last position of the section, the same as EndPosition.
		#
		#   returns    a number
		#   see        EndPosition
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

	# Returns the kind of object this is, in lowercase.
	#
	#   returns    the text "stzsection"
	def StzType()
		return :stzSection
