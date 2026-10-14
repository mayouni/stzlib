#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOMPARATOR         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String comparator -- Wraps stzString via    #
#                 composition. Comparing strings for equality, #
#                 order, and diff.                             #
#                 For aliases, use stzStringComparatorXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Compares a text with another: equality, order, shared beginnings and endings, edit distance, phonetic codes and similarity scores.
#
# It is the comparison helper of stzString, which builds one over itself for its comparison methods;
# build one with StzStringComparatorQ (or new stzStringComparator) when you only need the
# comparisons. It never edits the text, so a stzString passed in stays intact. The other text must
# be a text: a number ends the Ring process without a message. Comparison is by code point and case
# counts unless you call the CS form with 0; the CS flag is honoured by the equality, order,
# contains, prefix and suffix families. Positions and lengths count characters, so Hebrew, Arabic
# and emoji text is measured as you read it, with three exceptions found today: the case-sensitive
# CommonCharsWith, CommonalityWith, DiffCharsWith and LongestCommonPrefixWith work on bytes and
# break such text (the CS 0 forms are right), and Soundex and Metaphone only code Latin letters. The
# Jaro scores are similarities scaled to 1000, and JaroDistanceWith is the same call.
#
#   receiver   o1 = StzStringComparatorQ("banana")
#   example    ? o1.CommonPrefixWith("bandit")
#              #--> ban
#              ? o1.LevenshteinDistanceWith("bandana")
#              #--> 1
#              o2 = new stzStringComparator("שלום עולם")
#              ? o2.CommonPrefixWith("שלום יפה")
#              #--> שלום 
#              o3 = new stzStringComparator("a😀b😀")
#              ? @@( o3.DiffWith("a😀c😀") )
#              #--> [ 3 ]
#   see        stzString, stzStringFinder, stzStringChecker
class stzStringComparator from stzObject

	@oString

	# Builds a comparator over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to compare, or a stzString to wrap
	#   returns           nothing; the object is built
	#   note              comparing never edits the text, so a stzString passed in stays intact
	#                     (checked with keep me)
	#   see               Content, IsEqualTo
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringComparator! Parameter must be a string or stzString object.")
		ok

	# Returns the text being compared.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting a Hebrew letter or an emoji as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   EQUALITY                                           #
	#======================================================#

	def IsEqualToCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_nResult_ = StzEngineStringEqualsCS(_pH_, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _nResult_

	# TRUE if the other text is identical to this one, character for character, case included.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         IsEqualToCS(other, 0) ignores case: Apple equals apple
	#   warning      a number instead of a text ends the Ring process without any message
	#                (IsEqualTo(5) and Compare(5), exit code 1)
	#   see          IsNotEqualTo, IsEqualToOneOfThese, Compare
	def IsEqualTo(pcOtherStr)
		return This.IsEqualToCS(pcOtherStr, 1)

	def IsNotEqualToCS(pcOtherStr, pCaseSensitive)
		return NOT This.IsEqualToCS(pcOtherStr, pCaseSensitive)

	# TRUE if the other text differs from this one in at least one character, case included.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         IsNotEqualToCS(other, 0) ignores case
	#   see          IsEqualTo
	def IsNotEqualTo(pcOtherStr)
		return NOT This.IsEqualTo(pcOtherStr)

	  #======================================================#
	 #   EQUALITY WITH MULTIPLE STRINGS                     #
	#======================================================#

	def IsEqualToOneOfTheseCS(pacOtherStr, pCaseSensitive)
		_nLen_ = len(pacOtherStr)
		for i = 1 to _nLen_
			if This.IsEqualToCS(pacOtherStr[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# TRUE if the text is identical to at least one text of the list.
	#
	#   pacOtherStr   the list of texts to compare with
	#   returns       TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note          IsEqualToOneOfTheseCS(list, 0) ignores case
	#   see           IsEqualTo, ContainsOneOfThese
	def IsEqualToOneOfThese(pacOtherStr)
		return This.IsEqualToOneOfTheseCS(pacOtherStr, 1)

	  #======================================================#
	 #   ORDERING                                           #
	#======================================================#

	# TRUE if the text sorts before the other one, comparing code points from the first character.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         case counts: an upper-case letter sorts before every lower-case one, so Bandana
	#                is less than banana
	#   see          IsGreaterThan, Compare, IsBetween
	#@ aka  TRUE if the string sorts BEFORE the given one.
	def IsLessThan(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1) < 0

	# TRUE if the text sorts after the other one, comparing code points from the first character.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         Hebrew sorts by code point, so עולם is greater than יפה
	#   see          IsLessThan, Compare
	#@ aka  TRUE if the string sorts AFTER the given one.
	def IsGreaterThan(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1) > 0

	def IsBetweenCS(pcStr1, pcStr2, pCaseSensitive)
		return This.CompareCS(pcStr1, pCaseSensitive) >= 0 and
		       This.CompareCS(pcStr2, pCaseSensitive) <= 0

	# TRUE if the text sorts at or after the first bound and at or before the second.
	#
	#   pcStr1     the lower bound, included
	#   pcStr2     the upper bound, included
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       IsBetweenCS(a, z, 0) ignores case, so M is between a and z
	#   warning    the bounds are not reordered: asking for z then a is FALSE for every text
	#   see        IsLessThan, IsGreaterThan
	def IsBetween(pcStr1, pcStr2)
		return This.IsBetweenCS(pcStr1, pcStr2, 1)

	  #======================================================#
	 #   COMPARE (RETURNS -1, 0, 1)                         #
	#======================================================#

	def CompareCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_nResult_ = StzEngineStringCompareCS(_pH_, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _nResult_

	# Returns -1, 0 or 1 according to whether the text sorts before, equal to or after the other one.
	#
	#   pcOtherStr   the text to compare with
	#   returns      -1, 0 or 1
	#   note         CompareCS(other, 0) ignores case: Apple against apple gives 0, while Compare
	#                gives -1
	#   warning      a number instead of a text ends the Ring process without any message
	#   see          IsLessThan, IsGreaterThan, IsEqualTo
	def Compare(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1)

	  #======================================================#
	 #   DIFF                                               #
	#======================================================#

	# Returns the positions at which the two texts differ, position by position, including the tail of the longer one.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a list of numbers, 1-based; [ ] for identical texts
	#   note         banana against Bandana gives [ 1, 4, 5, 6, 7 ]; positions count characters, not
	#                bytes
	#   warning      always case-sensitive; there is no case flag
	#   see          CommonCharsWith, LevenshteinDistanceWith
	#@ aka  The differences between the string and the given one.
	def DiffWith(pcOtherStr)
		_aResult_ = []
		_nLen_ = @oString.NumberOfChars()
		_oOther_ = new stzString(pcOtherStr)
		_nOtherLen_ = _oOther_.NumberOfChars()
		_nMax_ = _nLen_
		if _nOtherLen_ > _nMax_
			_nMax_ = _nOtherLen_
		ok
		_acThisChars_ = @oString.Chars()
		_acOtherChars_ = _oOther_.Chars()
		for i = 1 to _nMax_
			if i > _nLen_ or i > _nOtherLen_
				_aResult_ + i
			but _acThisChars_[i] != _acOtherChars_[i]
				_aResult_ + i
			ok
		next
		return _aResult_

	  #======================================================#
	 #   CONTAINS CHECKS                                    #
	#======================================================#

	def ContainsCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringContainsCS(@oString.Engine(), pcSubStr, _bCase_)

	# TRUE if the text holds the given fragment anywhere.
	#
	#   pcSubStr   the fragment to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       ContainsCS(sub, 0) ignores case
	#   warning    an empty fragment answers FALSE
	#   see        ContainsOneOfThese, ContainsAllOfThese
	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

	def ContainsOneOfTheseCS(pacSubStr, pCaseSensitive)
		_nLen_ = len(pacSubStr)
		for i = 1 to _nLen_
			if This.ContainsCS(pacSubStr[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# TRUE if the text holds at least one fragment of the list.
	#
	#   pacSubStr   the list of fragments
	#   returns     TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note        ContainsOneOfTheseCS(list, 0) ignores case
	#   see         Contains, ContainsAllOfThese
	def ContainsOneOfThese(pacSubStr)
		return This.ContainsOneOfTheseCS(pacSubStr, 1)

	def ContainsAllOfTheseCS(pacSubStr, pCaseSensitive)
		_nLen_ = len(pacSubStr)
		for i = 1 to _nLen_
			if NOT This.ContainsCS(pacSubStr[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	# TRUE if the text holds every fragment of the list.
	#
	#   pacSubStr   the list of fragments
	#   returns     TRUE or FALSE, as 1 or 0; TRUE for an empty list
	#   note        ContainsAllOfTheseCS(list, 0) ignores case
	#   see         Contains, ContainsOneOfThese
	def ContainsAllOfThese(pacSubStr)
		return This.ContainsAllOfTheseCS(pacSubStr, 1)

	  #======================================================#
	 #   COMMON PREFIX / SUFFIX                             #
	#======================================================#

	def CommonPrefixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringCommonPrefixCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the beginning that the text shares with the other one, as text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text; an empty text when the first characters differ
	#   note         hello against help gives hel; CommonPrefixWithCS(other, 0) ignores case; the
	#                result is a whole number of characters in Hebrew, Arabic and emoji text
	#   see          LongestCommonPrefixWith, CommonSuffixWith, PrefixCountWith
	def CommonPrefixWith(pcOtherStr)
		return This.CommonPrefixWithCS(pcOtherStr, 1)

	def CommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringCommonSuffixCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the ending that the text shares with the other one, as text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text; an empty text when the last characters differ
	#   note         banana against Bandana gives ana
	#   see          LongestCommonSuffixWith, CommonPrefixWith
	def CommonSuffixWith(pcOtherStr)
		return This.CommonSuffixWithCS(pcOtherStr, 1)

	def CommonCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringCommonCharsCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the distinct characters of the text that also occur in the other one, in the order they first appear here, as one text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text
	#   note         banana against Bandana gives an
	#   warning      on Hebrew, Arabic and emoji text the case-sensitive form cuts characters into
	#                bytes and loses them: עולם against עיר gives an empty text, and a😀b😀 against
	#                a😀c😀 gives a instead of a😀; the case-ignoring form CommonCharsWithCS(other, 0)
	#                is right (ע, and a😀)
	#   see          DiffCharsWith, CommonalityWith
	def CommonCharsWith(pcOtherStr)
		return This.CommonCharsWithCS(pcOtherStr, 1)

	def CommonalityWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringCommonalityCS(_pH_, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _n_

	# Returns how many distinct characters the text shares with the other one.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a number
	#   note         banana against Bandana gives 2 (a and n), and 3 when case is ignored
	#   warning      on Hebrew, Arabic and emoji text the case-sensitive form counts bytes: עולם
	#                against עיר gives 2 where CommonalityWithCS(other, 0) gives 1
	#   see          CommonCharsWith, JaroSimilarityWith
	def CommonalityWith(pcOtherStr)
		return This.CommonalityWithCS(pcOtherStr, 1)

	def DiffCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringDiffCharsCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the distinct characters of the text that do not occur in the other one, as one text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text; an empty text when every character is shared
	#   note         banana against Bandana gives b
	#   warning      on Hebrew, Arabic and emoji text the case-sensitive form returns cut bytes that
	#                are not valid text (עולם against עיר gives three broken characters);
	#                DiffCharsWithCS(other, 0) gives ולם
	#   see          CommonCharsWith
	def DiffCharsWith(pcOtherStr)
		return This.DiffCharsWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   LEVENSHTEIN DISTANCE                               #
	#======================================================#

	# Returns the least number of single-character insertions, deletions and replacements that turn the text into the other one.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a number
	#   note         kitten against sitting gives 3; always case-sensitive; EditDistanceWith is the
	#                same call; counts characters, so Hebrew and emoji text is measured exactly
	#                (עולם against יפה gives 4)
	#   see          JaroSimilarityWith, DiffWith
	#@ aka  The Levenshtein edit distance to the given string.
	def LevenshteinDistanceWith(pcOtherStr)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringLevenshteinDistance(_pH_, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def EditDistanceWith(pcOtherStr)
			return This.LevenshteinDistanceWith(pcOtherStr)

	  #======================================================#
	 #   PREFIX / SUFFIX COUNT                              #
	#======================================================#

	def PrefixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_n_ = StzEngineStringPrefixCountCS(_pH_, pcOtherStr, _bCase_)
		return _n_

	# Returns how many times the other text repeats back to back at the start of the text.
	#
	#   pcOtherStr   the text that is repeated
	#   returns      a number; 0 when the text does not begin with it
	#   note         ababab against ab gives 3, xxabab against ab gives 0; PrefixCountWithCS(other,
	#                0) ignores case
	#   see          SuffixCountWith, CommonPrefixWith
	def PrefixCountWith(pcOtherStr)
		return This.PrefixCountWithCS(pcOtherStr, 1)

	def SuffixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_n_ = StzEngineStringSuffixCountCS(_pH_, pcOtherStr, _bCase_)
		return _n_

	# Returns how many times the other text repeats back to back at the end of the text.
	#
	#   pcOtherStr   the text that is repeated
	#   returns      a number; 0 when the text does not end with it
	#   note         ababab against ab gives 3, xxabab gives 2; SuffixCountWithCS(other, 0) ignores
	#                case
	#   see          PrefixCountWith, CommonSuffixWith
	def SuffixCountWith(pcOtherStr)
		return This.SuffixCountWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   LONGEST COMMON PREFIX / SUFFIX                     #
	#======================================================#

	def LongestCommonPrefixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringLongestCommonPrefixCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the longest beginning that the text shares with the other one, as text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text; an empty text when the first characters differ
	#   note         hello against help gives hel
	#   warning      on Hebrew text it can end with half a character: עולם against עיר gives ע
	#                followed by a broken byte, where CommonPrefixWith gives ע (the case-ignoring
	#                form is right)
	#   see          CommonPrefixWith, LongestCommonSuffixWith
	def LongestCommonPrefixWith(pcOtherStr)
		return This.LongestCommonPrefixWithCS(pcOtherStr, 1)

	def LongestCommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_pR_ = StzEngineStringLongestCommonSuffixCS(_pH_, pH2, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pH2)
		return _c_

	# Returns the longest ending that the text shares with the other one, as text.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a text; an empty text when the last characters differ
	#   note         banana against Bandana gives ana
	#   see          LongestCommonPrefixWith, CommonSuffixWith
	def LongestCommonSuffixWith(pcOtherStr)
		return This.LongestCommonSuffixWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   SOUNDEX / METAPHONE                                #
	#======================================================#

	# Returns the four-character Soundex code of the text, a letter and three digits that match for similar English sounds.
	#
	#   returns    a text such as R163
	#   note       Robert and Rupert both give R163; Tymczak gives T520
	#   warning    only Latin letters are coded: Hebrew and Arabic text give a broken first
	#              character followed by 000 (שלום gives 4 bytes ending in 000), and an empty text
	#              gives an empty text
	#   see        Metaphone, JaroSimilarityWith
	#@ aka  The Soundex phonetic code of the string.
	def Soundex()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSoundex(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the Metaphone phonetic code of the text, the consonant skeleton of its English sound.
	#
	#   returns    a text such as BNN
	#   note       banana gives BNN, hello gives HL, Thompson gives 0MPSN
	#   warning    only Latin letters are coded: Hebrew and Arabic text give an empty text
	#   see        Soundex
	#@ aka  The Metaphone phonetic code of the string.
	def Metaphone()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringMetaphone(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #======================================================#
	 #   JARO / JARO-WINKLER SIMILARITY                     #
	#======================================================#

	# Returns the Jaro similarity of the two texts, scaled to 1000 for identical texts.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a number from 0 to 1000
	#   note         MARTHA against MARHTA gives 944, the published 0.944 times 1000; hello against
	#                help gives 783
	#   warning      JaroDistanceWith is the same call and is a similarity, not a distance: 1000
	#                means identical
	#   see          JaroWinklerSimilarityWith, LevenshteinDistanceWith
	def JaroSimilarityWith(pcOtherStr)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringJaro(_pH_, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def JaroDistanceWith(pcOtherStr)
			return This.JaroSimilarityWith(pcOtherStr)

	# Returns the Jaro-Winkler similarity of the two texts, which favours a shared beginning, scaled to 1000.
	#
	#   pcOtherStr   the text to compare with
	#   returns      a number from 0 to 1000
	#   note         MARTHA against MARHTA gives 960 where the published value is 0.961; hello
	#                against help gives 848
	#   warning      JaroWinklerDistanceWith is the same call and is a similarity, not a distance
	#   see          JaroSimilarityWith
	def JaroWinklerSimilarityWith(pcOtherStr)
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringJaroWinkler(_pH_, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def JaroWinklerDistanceWith(pcOtherStr)
			return This.JaroWinklerSimilarityWith(pcOtherStr)
