#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSUBSTRING          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Substring-in-parent -- tracks a substring   #
#                  within a parent string for positional ops.   #
#                  Delegates to stzString (engine-backed).     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringSubStringQ(pcSubStr, pcStr)
	return new stzStringSubString(pcSubStr, pcStr)

func StzStringSubStringCSQ(pcSubStr, pcStr, pCaseSensitive)
	return new stzStringSubStringCS(pcSubStr, pcStr, pCaseSensitive)


  /////////////////
 ///   CLASS   ///
/////////////////

# Studies one fragment inside a text with comparisons that always respect case.
#
# It is stzStringSubStringCS with the case flag fixed at 1, so it takes the fragment and the text
# and nothing else; every method is inherited and described on stzStringSubStringCS. Build one with
# StzStringSubStringQ(fragment, text).
#
#   receiver   o1 = new stzStringSubString("an", "Banana bandana")
#   example    ? o1.NumberOfOccurrence()
#              #--> 4
#              ? o1.LastPosition()
#              #--> 12
#   see        stzStringSubStringCS, stzString
class stzStringSubString from stzStringSubStringCS

	# Builds a case-sensitive view of a fragment inside a text.
	#
	#   pcSubStr   the fragment to study
	#   pcStr      the text it is looked for in, or a pair [ :in, text ]
	#   returns    nothing; the object is built
	#   note       the same class as stzStringSubStringCS with the case flag fixed at 1; build one
	#              with StzStringSubStringQ(fragment, text)
	#   warning    a value that is not text raises Can't create stzStringSubStringCS
	#   see        stzStringSubStringCS, Sections
	def init(pcSubStr, pcStr)
		super.init(pcSubStr, pcStr, 1)

# Studies one fragment inside a text: where it occurs, how often, what the text becomes without it, and how it sits among other fragments.
#
# Built with a fragment, a text and a flag that says whether comparisons respect case (1) or ignore
# it (0); stzStringSubString is the same class with the flag fixed at 1. Nothing here changes either
# text: the Replaced, Removed, Uppercased and Lowercased forms return a new text. Positions count
# characters, so Hebrew, Arabic and emoji text is located where you expect. Found today: Positions
# and Occurrences raise R14 because they call a finder method that does not exist;
# NumberOfOccurrence and Replaced do not count overlapping occurrences while Sections and
# NthPosition do; and IsBoundedBy compares the enclosed stretch with the fragment exactly, so the
# flag 0 does not reach that last step.
#
#   receiver   o1 = new stzStringSubStringCS("an", "Banana bandana", 1)
#   example    ? o1.FirstPosition()
#              #--> 2
#              ? @@( o1.Sections() )
#              #--> [ [ 2, 3 ], [ 4, 5 ], [ 9, 10 ], [ 12, 13 ] ]
#              ? o1.Removed()
#              #--> Ba bda
#              o2 = new stzStringSubStringCS("AN", "Banana bandana", 0)
#              ? o2.NumberOfOccurrence()
#              #--> 4
#              o3 = new stzStringSubStringCS("ל", "שלום עולם", 1)
#              ? o3.LastPosition()
#              #--> 8
#              o4 = new stzStringSubStringCS("😀", "a😀b😀", 1)
#              ? @@( o4.Sections() )
#              #--> [ [ 2, 2 ], [ 4, 4 ] ]
#   see        stzStringSubString, stzString, stzStringFinder
class stzStringSubStringCS from stzObject

	@cSubStr
	@cStr
	@bCaseSensitive

	# Builds a view of a fragment inside a text, with a flag saying whether comparisons respect case.
	#
	#   pcSubStr         the fragment to study
	#   pcStr            the text it is looked for in, or a pair [ :in, text ]
	#   pCaseSensitive   1 to respect case or 0 to ignore it
	#   returns          nothing; the object is built
	#   note             build one with StzStringSubStringCSQ(fragment, text, flag);
	#                    stzStringSubString is the same class with the flag fixed at 1; the object
	#                    keeps both texts and never changes them
	#   warning          a value that is not text raises Can't create stzStringSubStringCS
	#   see              SubString, Positions
	def init(pcSubStr, pcStr, pCaseSensitive)
		if isList(pcStr) and len(pcStr) = 2 and isString(pcStr[1])
			_cPN_ = StzCaseFold(pcStr[1])
			if _cPN_ = "in" or _cPN_ = "instring"
				pcStr = pcStr[2]
			ok
		ok

		if NOT (isString(pcSubStr) and isString(pcStr))
			StzRaise("Can't create stzStringSubStringCS! Both parameters must be strings.")
		ok

		@cSubStr = pcSubStr
		@cStr = pcStr
		@bCaseSensitive = @CaseSensitive(pCaseSensitive)

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the fragment this object studies.
	#
	#   returns    a text
	#   note       Content is the same call
	#   see        String, NumberOfChars
	def SubString()
		return @cSubStr

		# Returns the fragment this object studies.
		#
		#   returns    a text
		#   see        String, SubString
		def Content()
			return @cSubStr

	# Returns the text the fragment is looked for in.
	#
	#   returns    a text
	#   see        SubString
	def String()
		return @cStr

	# Returns the flag the object was built with.
	#
	#   returns    1 when comparisons respect case, 0 when they ignore it
	#   see        SubString
	def CaseSensitive()
		return @bCaseSensitive

	# Returns how many characters the fragment holds, a Hebrew letter or an emoji counting as one.
	#
	#   returns    a number
	#   note       an gives 2; the Hebrew fragment ום gives 2 and an emoji gives 1
	#   see        SubString
	def NumberOfChars()
		_oSub_ = new stzString(@cSubStr)
		return _oSub_.NumberOfChars()

	  #===============================#
	 #     FINDING                   #
	#===============================#

	# Returns how many times the fragment occurs in the text, never counting two occurrences that overlap.
	#
	#   returns    a number; 0 when absent or when the fragment is empty
	#   note       an in Banana bandana gives 4; the flag 0 counts AN as 4 and the flag 1 as 0
	#   warning    the overlapping count of Sections and NthPosition differs: ana in banana gives 1
	#              here and two sections there
	#   see        Sections, NthPosition
	def NumberOfOccurrence()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.NumberOfOccurrenceCS(@cSubStr, @bCaseSensitive)

	# Raises error R14 today instead of returning the position of every occurrence.
	#
	#   returns    nothing; the call raises R14
	#   note       use Sections for [ start, end ] pairs or NthPosition one by one
	#   warning    it calls FindAllCS on the finder, a method that does not exist, so Positions and
	#              Occurrences raise for every input; confirmed with Banana bandana and with banana
	#   see        Sections, NthPosition, FirstPosition
	def Positions()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindAllCS(@cSubStr, @bCaseSensitive)

		def Occurrences()
			return This.Positions()

	# Returns the 1-based position where the nth occurrence starts, counting occurrences that overlap.
	#
	#   n          which occurrence, counting from 1
	#   returns    a number; 0 when the fragment is absent, -1 when n is 0, negative or beyond the
	#              last occurrence
	#   note       an in Banana bandana: n=2 gives 4; ana in banana: n=2 gives 4 although the
	#              occurrences overlap
	#   see        FirstPosition, LastPosition, Sections
	def NthPosition(n)
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindNthCS(n, @cSubStr, @bCaseSensitive)

	# Returns the 1-based position where the first occurrence starts.
	#
	#   returns    a number; 0 when the fragment is absent
	#   note       an in Banana bandana gives 2; ל in שלום עולם gives 2
	#   see        LastPosition, NthPosition
	def FirstPosition()
		return This.NthPosition(1)

	# Returns the 1-based position where the last occurrence starts.
	#
	#   returns    a number; 0 when the fragment is absent
	#   note       an in Banana bandana gives 12; ל in שלום עולם gives 8
	#   warning    the last occurrence is found from the non-overlapping count, so it can be one
	#              occurrence short for a fragment that overlaps itself
	#   see        FirstPosition, NthPosition
	def LastPosition()
		return This.NthPosition(This.NumberOfOccurrence())

	# Returns each occurrence of the fragment as a [ start, end ] pair of 1-based positions, overlapping ones included.
	#
	#   returns    a list of pairs; [ ] when the fragment is absent
	#   note       an in Banana bandana gives [2,3], [4,5], [9,10], [12,13]; with an emoji a😀b😀
	#              gives [2,2], [4,4]; positions count characters
	#   see        NthPosition, NumberOfOccurrence
	def Sections()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindAsSectionsCS(@cSubStr, @bCaseSensitive)

	  #===============================#
	 #     REPLACE / REMOVE          #
	#===============================#

	# Returns the text with every occurrence of the fragment replaced by another text.
	#
	#   pcNewSubStr   the text that takes the place of each occurrence
	#   returns       a text; the object is not changed
	#   note          Replaced is the same call; the flag 0 replaces AN as well as an: Banana
	#                 bandana with - gives B--a b-d-a; occurrences are non-overlapping, so ana in
	#                 banana gives b-na
	#   see           Removed, Uppercased
	def ReplacedWith(pcNewSubStr)
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, pcNewSubStr, @bCaseSensitive)
		return _oReplacer_.Content()

		def Replaced(pcNewSubStr)
			return This.ReplacedWith(pcNewSubStr)

	# Returns the text with every occurrence of the fragment deleted.
	#
	#   returns    a text; the object is not changed
	#   note       an in Banana bandana gives Ba bda; an empty text stays empty
	#   see        ReplacedWith
	def Removed()
		return This.ReplacedWith("")

	  #===============================#
	 #     CASE                      #
	#===============================#

	# TRUE if the fragment itself is in lower case.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       looks at the fragment only, not at the text; Ab is neither lower nor upper case
	#   see        IsUppercased, Lowercased
	def IsLowercased()
		_oSub_ = new stzString(@cSubStr)
		return StzEngineStringIsLowercase(_oSub_.Engine())

	# TRUE if the fragment itself is in capitals.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       looks at the fragment only; AB gives 1, Ab gives 0
	#   see        IsLowercased, Uppercased
	def IsUppercased()
		_oSub_ = new stzString(@cSubStr)
		return StzEngineStringIsUppercase(_oSub_.Engine())

	# Returns the text with every occurrence of the fragment turned into capitals.
	#
	#   returns    a text; the object is not changed
	#   note       an in Banana bandana gives BANANa bANdANa; with the flag 0 the capital AN is
	#              found too; é in café É gives cafÉ É; an emoji has no capital and stays as it is
	#   see        Lowercased, ReplacedWith
	def Uppercased()
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, StzUpper(@cSubStr), @bCaseSensitive)
		return _oReplacer_.Content()

	# Returns the text with every occurrence of the fragment turned into small letters.
	#
	#   returns    a text; the object is not changed
	#   note       with the flag 0 the fragment É lowers the É of café É as well; the Greek Δ in αΔβ
	#              gives αδβ
	#   see        Uppercased, ReplacedWith
	def Lowercased()
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, StzLower(@cSubStr), @bCaseSensitive)
		return _oReplacer_.Content()

	  #===============================#
	 #     POSITION CHECKS           #
	#===============================#

	# TRUE if the first occurrence of the fragment comes before the first occurrence of another fragment.
	#
	#   pcOtherSubStr   the other fragment to compare positions with
	#   returns         TRUE or FALSE, as 1 or 0; FALSE when either is absent
	#   note            ComesBefore is the same call; an before dana in Banana bandana gives 1
	#   see             IsAfter, IsBetween
	def IsBefore(pcOtherSubStr)
		_nMyPos_ = This.FirstPosition()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nOtherPos_ = _oFinder_.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if _nMyPos_ = 0 or _nOtherPos_ = 0
			return 0
		ok
		return _nMyPos_ < _nOtherPos_

		def ComesBefore(pcOtherSubStr)
			return This.IsBefore(pcOtherSubStr)

	# TRUE if the first occurrence of the fragment comes after the first occurrence of another fragment.
	#
	#   pcOtherSubStr   the other fragment to compare positions with
	#   returns         TRUE or FALSE, as 1 or 0; FALSE when either is absent
	#   note            ComesAfter is the same call; an after B in Banana bandana gives 1
	#   see             IsBefore, IsBetween
	def IsAfter(pcOtherSubStr)
		_nMyPos_ = This.FirstPosition()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nOtherPos_ = _oFinder_.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if _nMyPos_ = 0 or _nOtherPos_ = 0
			return 0
		ok
		return _nMyPos_ > _nOtherPos_

		def ComesAfter(pcOtherSubStr)
			return This.IsAfter(pcOtherSubStr)

	# TRUE if the first occurrence of the fragment lies between the first occurrences of two bounds, given in either order.
	#
	#   pcBound1   the first bound
	#   pcBound2   the second bound
	#   returns    TRUE or FALSE, as 1 or 0; FALSE when a bound or the fragment is absent
	#   note       ComesBetween is the same call; an between B and d gives 1 and so does d then B;
	#              the Hebrew ום between ש and ע gives 1
	#   see        IsBefore, IsBoundedBy
	def IsBetween(pcBound1, pcBound2)
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nPos1_ = _oFinder_.FindFirstCS(pcBound1, @bCaseSensitive)
		_nPos2_ = _oFinder_.FindFirstCS(pcBound2, @bCaseSensitive)
		_nMyPos_ = This.FirstPosition()
		if _nPos1_ = 0 or _nPos2_ = 0 or _nMyPos_ = 0
			return 0
		ok
		if _nPos1_ > _nPos2_
			_nTemp_ = _nPos1_
			_nPos1_ = _nPos2_
			_nPos2_ = _nTemp_
		ok
		return _nMyPos_ > _nPos1_ and _nMyPos_ < _nPos2_

		def ComesBetween(pcBound1, pcBound2)
			return This.IsBetween(pcBound1, pcBound2)

	  #===============================#
	 #     BOUNDED BY                #
	#===============================#

	# TRUE if some stretch of the text enclosed by the pair of bounds is exactly the fragment.
	#
	#   pacBounds   the pair [ open, close ]
	#   returns     TRUE or FALSE, as 1 or 0; FALSE when the bounds are not a list of two
	#   note        abc in x(abc)y(abd) with ( and ) gives 1, the pair reversed gives 0; the Hebrew
	#               שלום in [שלום] [עולם] with [ and ] gives 1
	#   warning     the final comparison of the enclosed stretch with the fragment ignores the flag:
	#               ab is not found in x(AB)y with the flag 0, although the flag 0 finds the stretch
	#               itself; a list that is not a pair gives FALSE, not an error
	#   see         IsBetween, IsBefore
	def IsBoundedBy(pacBounds)
		if NOT (isList(pacBounds) and len(pacBounds) = 2)
			return 0
		ok
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_aSections_ = _oFinder_.FindAnyBoundedByAsSectionsCS(pacBounds, @bCaseSensitive)
		_nLen_ = len(_aSections_)
		for i = 1 to _nLen_
			_cFound_ = _oStr_.Section(_aSections_[i][1], _aSections_[i][2])
			if _cFound_ = @cSubStr
				return 1
			ok
		next
		return 0
