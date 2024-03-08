

class stzSection
	@aContent

	def init(n1, n2, nSize)
		if CheckParams()

			if isList(nSize) and Q(nSize).IsOneOfTheseNamedParams([
				:Size, :ListSize, :StringSize,
				:NumberOfItems, :NumberOfChars,

				:InAListOfNItems, :InAListOfSizeN, :InAListOfN, :InAListOf,
				:InAStringOfNChars, :InAStringOfSizeN,

				:InListOfNItems, :InListOfSizeN, :InListOfN, :InListOf,
				:InStringOfNChars, :InStringOfSizeN

				])

				nSize = nSize[2]

				if NOT isNumber(nSize)
					StzRaise("Incorrect param type! nSize must be a number.")
				ok
			ok

			# Managing the use of :From and :To named params
	
			if isList(n1) and
			   StzListQ(n1).IsOneOfTheseNamedParams([
				:From, :FromPosition, :FromCharAt, :FromCharAtPosition,

				:Start, :FromStart,
				:StartingAt, :StartingAtPosition,
				:StartingAtCharAt, :StartingAtCharAtPosition,

				:Between, :BetweenPosition, :BetweenCharAt,
				:BetweenCharAtPosition,

				:BetweenPositions, :BetweeCharsAtPosition,

				#--

				:FromItemAt, :FromItemAtPosition,
				:StartingAtItemAt, :StartingAtItemAtPosition,
				:BetweenItemAtPosition, :BetweeItemsAtPosition

				])
	
				n1 = n1[2]
			ok
	
			if isList(n2) and
			   StzListQ(n2).IsOneOfTheseNamedParams([
				:To, :ToPosition, :ToCharAt, :ToCharAtPosition,

				:End, :ToEnd,
				:Until, :UntilPosition, :UntilCharAt, :UntilCharAtPosition,
				:UpTo, :UpToPosition, :UpToCharAt, :UpToCharAtPosition,

				:And,

				:StartingAt, :StartingAtPosition, :StartingAtCharAt,
				:StartingAtCharAtPosition,

				#--

				:ToItemAt, :ToItemAtPosition,
				:UntilItemAt, :UntilItemAtPosition,
				:UpToItemAt, :UpToItemAtPosition,
				:StartingAtItemAt, :StartingAtItemAtPosition

				])
	
				n2 = n2[2]
			ok
	
			# Managing the use of :NthToFirst named param
	
			if isList(n1) and Q(n1).IsOneOfTheseNamedParams([
						:NthToFirst, :NthToFirstChar, :NthToFirstItem ])
	
				n1 = n1[2] + 1
			ok
	
			if isList(n2) and Q(n2).IsOneOfTheseNamedParams([
						:NthToFirst, :NthToFirstChar, :NthToFirstItem ])
	
				n2 = n2[2] + 1
			ok
	
			# Managing the use of :NthToLast named param
	
			if isList(n1) and Q(n1).IsOneOfTheseNamedParams([
						:NthToLast, :NthToLastChar, :NthToLastItem ])
	
				n1 = nLen - n1[2]
			ok
	
			if isList(n2) and Q(n2).IsOneOfTheseNamedParams([
						:NthToLast, :NthToLastChar, :NthToLastItem ])
	
				n2 = nLen - n2[2]
	
			but isList(n2) and Q(n2).IsStoppingAtNamedParam()
	
				n2 = n2[2]
			ok
	
			# Managing the case of :First and :Last keywords
	
			if isString(n1)
				if Q(n1).IsOneOfThese([
					:First, :FirstChar,
					:FromFirst, :FromFirstChar,

					#--

					:FirstItem, :FromFirstItem

				])

					n1 = 1
	
				but Q(n1).IsOneOfThese([
					:Last, :LastChar,
					:ToLast, :ToLastChar,

					#--

					:LastItem, :ToLastItem
				])

					n1 = nLen
	
				but n1 = :@
					n1 = n2

				else
					n1 = This.FindFirstCS(n1, pCaseSensitive)
				ok
			ok
		
			if isString(n2)
				if Q(n2).IsOneOfThese([
					:End, :Last, :LastChar, :EndOfString,
					:ToEnd, :ToLast, :ToLastChar, :ToEndOfString,

					#--

					:LastItem, :EndOfList, :ToLastItem, :ToEndOfList

				])

					n2 = nLen
	
				but Q(n2).IsOneOfThese([
					:First, :FirstChar,
					:FromFirst, :FromFirstChar,

					#--

					:FirstItem, :FromFirstItem

				])

					n2 = 1
	
				but n2 = :@
					n2 = n1

				else
					nLen2 = StzStringQ(n2).NumberOfChars()
					n2 = This.FindLastCS(n2, pCaseSensitive) + nLen2 - 1
				ok
			ok

			if n1 = :@ and n2 = :@
				n1 = 1
				n2 = nLen
			ok
	
			# Managing the case of :EndOfSentence, :EndOfLine, and :EndOfWord keywords
	
			if n1 > 0 and n2 = :EndOfSentence
				return This.ToStzText().ForwardToEndOfSentence( :StartingAt = n1 )
			ok
	
			if n1 > 0 and n2 = :EndOfLine
				return This.ForwardToEndOfLine( :StartingAt = n1 )
			ok
	
			if n1 > 0 and n2 = :EndOfWord #TODO: should move to stzText?
				return This.ToStzText().ForwardToEndOfWord( :StartingAt = n1 )
			ok

			# Now, params must be numbers
	

			if NOT (isNumber(n1) and n != 0 and isNumber(n2) and n2 != 0)
				StzRaise("Incorrect params! n1 and n2 must be numbers different from zero.")
			ok
	
			if NOT ( n1 <= nSize and nSize <= n2 )
				StzRaise("Out of range! nSize must between n1 and n2")
			ok

		ok

		# Creating the object content

		@aContent = [n1, n2]

		#TODO: do same behavior in stzList.Section()
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
