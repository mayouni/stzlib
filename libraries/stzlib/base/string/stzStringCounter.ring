#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOUNTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String counter -- counting occurrences      #
#                  of substrings and chars.                    #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringCounterXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Counts things in a text: a fragment, overlapping fragments, regex matches, graphemes, marks and the characters of one script.
#
# It is the counting helper of stzString, which builds one over itself for its Count family; build
# one with new stzStringCounter("text") when you only need to count. Every count is by characters,
# so Hebrew, Arabic and emoji text counts as you expect, and every method answers a number and
# leaves the text alone. The script counts (CountHebrew, CountCyrillic, CountCjk, CountDevanagari,
# CountThai) and CountMarks, CountControls and GraphemeCount look at the whole text. Found today:
# CountBetween and CountBetweenCS raise R3 because they call a function that does not exist;
# CountOverlappingCS ignores its case flag; NumberOfCharsCS with 0 counts distinct letters;
# CountLeadingChar and CountTrailingChar stop the Ring process on an empty text; and a counter built
# from a stzString object reads an empty text once that string is appended to or replaced.
#
#   receiver   o1 = new stzStringCounter("Banana banana")
#   example    ? o1.Count("an")
#              #--> 4
#              ? o1.CountOverlapping("ana")
#              #--> 4
#              o2 = new stzStringCounter("שלום עולם abc")
#              ? o2.CountHebrew()
#              #--> 8
#              o3 = new stzStringCounter("a😀b😀😀")
#              ? o3.Count("😀")
#              #--> 3
#   see        stzString, stzStringFinder
class stzStringCounter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a counter over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to count in, or a stzString whose engine handle is shared
	#   returns           nothing; the object is built
	#   note              stzString builds one over itself for its Count family; build one yourself
	#                     with new stzStringCounter("text")
	#   warning           a counter built from a stzString object keeps the engine handle of that
	#                     object: after the original is edited with Append or Replace the counter
	#                     reads an empty text, and after Insert it still reads the old text, so
	#                     build the counter after the edits
	#   see               Content, NumberOfOccurrence
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCounter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text being counted in.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, a Hebrew letter or an emoji counting as one.
	#
	#   returns    a number
	#   note       the text שלום עולם abc gives 13
	#   warning    NumberOfCharsCS with the flag 0 does not count characters: it counts the distinct
	#              letters without regard to case, so aAa gives 1 against 3
	#   see        GraphemeCount, Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   COUNTING OCCURRENCES OF A SUBSTRING                #
	#======================================================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringCountOfCS(@oString.Engine(), pcSubStr, _bCase_)

		def NumberOfOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

	# Returns how many times a fragment occurs in the text, never counting two occurrences that overlap.
	#
	#   pcSubStr   the fragment to count
	#   returns    a number; 0 when absent or when the fragment is empty
	#   note       NumberOfOccurrences is the same call; case-sensitive, and NumberOfOccurrenceCS
	#              with 0 ignores case: an in Banana banana is 4, AN is 0 and AN with the flag 0 is
	#              4
	#   see        CountOverlapping, Count
	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

		def NumberOfOccurrences(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

	  #======================================================#
	 #   COUNT (SHORT FORM)                                 #
	#======================================================#

	# How many times the given substring occurs.
	def CountCS(pcSubStr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def CountSubStringCS(pcSubStr, pCaseSensitive)
			return This.CountCS(pcSubStr, pCaseSensitive)

	# Returns how many times a fragment occurs in the text, never counting two occurrences that overlap.
	#
	#   pcSubStr   the fragment to count
	#   returns    a number; 0 when absent or when the fragment is empty
	#   note       CountSubString is the same call; aa in aaaa gives 2, and CountCS with the flag 0
	#              ignores case
	#   see        CountOverlapping, CountRegex
	def Count(pcSubStr)
		return This.CountCS(pcSubStr, 1)

		def CountSubString(pcSubStr)
			return This.Count(pcSubStr)

	  #======================================================#
	 #   NUMBER OF CHARS                                    #
	#======================================================#

	def NumberOfCharsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			return StzEngineStringCount(@oString.Engine())
		else
			_oGetter_ = new stzStringGetter(@oString)
			return len(_oGetter_.UniqueCharsCS(0))
		ok

	  #======================================================#
	 #   NUMBER OF SUBSTRINGS                               #
	#======================================================#

	def NumberOfSubStringsCS(pCaseSensitive)
		if @oString.IsEmpty()
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			_n_ = @oString.NumberOfChars()
			return _n_ * (_n_ + 1) / 2
		else
			# Case-insensitive count via engine
			return StzEngineStringSubstringsCount(@oString.Engine())
		ok

		def HowManySubStringsCS(pCaseSensitive)
			return This.NumberOfSubStringsCS(pCaseSensitive)

	# Returns how many substrings the text has when every pair of start and end positions counts, repeats included.
	#
	#   returns    a number; 0 for an empty text
	#   note       HowManySubStrings is the same call; n characters give n*(n+1)/2, so abc gives 6
	#              and a 13 character text 91
	#   warning    NumberOfSubStringsCS with the flag 0 gives the same number: the flag changes
	#              nothing today
	#   see        NumberOfChars
	def NumberOfSubStrings()
		return This.NumberOfSubStringsCS(1)

		def HowManySubStrings()
			return This.NumberOfSubStrings()

	  #======================================================#
	 #   COUNT BETWEEN TWO POSITIONS                        #
	#======================================================#

	def CountBetweenCS(pcSubStr, n1, n2, pCaseSensitive)
		_cSection_ = @oString.Section(n1, n2)
		return StringNumberOfOccurrenceCS(_cSection_, pcSubStr, pCaseSensitive)

	# Raises an error today instead of counting a fragment inside a section of the text.
	#
	#   pcSubStr   the fragment meant to be counted
	#   n1         the first position of the section
	#   n2         the last position of the section
	#   returns    nothing; the call raises R3
	#   note       cut the section with stzString.Section, then Count it, until this is repaired
	#   warning    it calls the function StringNumberOfOccurrenceCS, which does not exist, so
	#              CountBetween and CountBetweenCS raise R3 for every input; confirmed with Banana
	#              banana and with xyzxyz
	#   see        Count, CountOverlapping
	def CountBetween(pcSubStr, n1, n2)
		return This.CountBetweenCS(pcSubStr, n1, n2, 1)

	  #======================================================#
	 #   COUNT ANY CHAR (count occurrences of any char       #
	 #   in a given set)                                     #
	#======================================================#

	# Returns how many characters of the text are one of the characters of a set.
	#
	#   pcChars    the characters of the set, given as one text
	#   returns    a number
	#   note       an in Banana banana gives 10 and an empty set gives 0; Hebrew works: the letters
	#              shin lamed and final mem count 5 in שלום עולם abc
	#   see        CountLeadingChar, Count
	def CountAnyChar(pcChars)
		_pH_ = @oString.Engine()
		return StzEngineStringCountAnyChar(_pH_, pcChars)

	  #======================================================#
	 #   COUNT LEADING / TRAILING CHAR                      #
	#======================================================#

	# Returns how many times a character repeats at the very start of the text.
	#
	#   pcChar     the character
	#   returns    a number; 0 when the text starts with another character
	#   note       two spaces then hello gives 2; case-sensitive: xxabcxx with X gives 0
	#   warning    an empty text stops the Ring process with a panic in stz_string.dll instead of
	#              returning 0
	#   see        CountTrailingChar
	def CountLeadingChar(pcChar)
		_pH_ = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringCountLeadingChar(_pH_, _nCp_)

	# Returns how many times a character repeats at the very end of the text.
	#
	#   pcChar     the character
	#   returns    a number; 0 when the text ends with another character
	#   note       xxabcxx with x gives 2
	#   warning    an empty text stops the Ring process with a panic in stz_string.dll instead of
	#              returning 0
	#   see        CountLeadingChar
	def CountTrailingChar(pcChar)
		_pH_ = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringCountTrailingChar(_pH_, _nCp_)

	  #======================================================#
	 #   COUNT BETWEEN MARKERS                              #
	#======================================================#

	# Returns how many pairs of an opening and a closing marker the text holds.
	#
	#   pcOpenMarker    the text that opens a pair
	#   pcCloseMarker   the text that closes it
	#   returns         a number
	#   note            a(b) c(d) (e with ( and ) gives 2 because the unclosed marker is not
	#                   counted; longer markers such as <b> and </b> work
	#   see             CountAnyChar, Count
	def CountBetweenMarkers(pcOpenMarker, pcCloseMarker)
		_pH_ = @oString.Engine()
		return StzEngineStringCountBetween(_pH_, pcOpenMarker, pcCloseMarker)

	  #======================================================#
	 #   GRAPHEME COUNT                                     #
	#======================================================#

	# Returns how many user-perceived characters the text holds, a base letter with its accents counting as one.
	#
	#   returns    a number
	#   note       e followed by the combining acute accent is 1 grapheme and 2 characters
	#   see        NumberOfChars, CountMarks
	def GraphemeCount()
		_pH_ = @oString.Engine()
		return StzEngineStringGraphemeCount(_pH_)

	  #======================================================#
	 #   SCRIPT-SPECIFIC COUNTS                             #
	#======================================================#

	# Returns how many combining marks the text holds: accents, vowel signs and similar.
	#
	#   returns    a number
	#   note       a base letter with an accent gives 1; the Thai and Devanagari vowel signs count
	#              too
	#   see        GraphemeCount
	def CountMarks()
		_pH_ = @oString.Engine()
		return StzEngineStringCountMarks(_pH_)

	# Returns how many control characters the text holds, such as tab and line feed.
	#
	#   returns    a number
	#   note       a tab followed by a line feed gives 2
	#   see        CountMarks
	def CountControls()
		_pH_ = @oString.Engine()
		return StzEngineStringCountControls(_pH_)

	# Returns how many Chinese, Japanese or Korean ideographs the text holds.
	#
	#   returns    a number
	#   note       the four ideographs 你好世界 give 4
	#   see        CountHebrew, CountCyrillic
	def CountCjk()
		_pH_ = @oString.Engine()
		return StzEngineStringCountCjk(_pH_)

	# Returns how many Cyrillic letters the text holds.
	#
	#   returns    a number
	#   note       Привет мир gives 9
	#   see        CountHebrew, CountCjk
	def CountCyrillic()
		_pH_ = @oString.Engine()
		return StzEngineStringCountCyrillic(_pH_)

	# Returns how many Hebrew letters the text holds.
	#
	#   returns    a number
	#   note       שלום עולם abc gives 8
	#   see        CountCyrillic, CountDevanagari
	def CountHebrew()
		_pH_ = @oString.Engine()
		return StzEngineStringCountHebrew(_pH_)

	# Returns how many Devanagari characters the text holds, signs and vowel marks included.
	#
	#   returns    a number
	#   note       the six characters of नमस्ते give 6
	#   see        CountThai, CountHebrew
	def CountDevanagari()
		_pH_ = @oString.Engine()
		return StzEngineStringCountDevanagari(_pH_)

	# Returns how many Thai characters the text holds, vowel marks included.
	#
	#   returns    a number
	#   note       the six characters of สวัสดี give 6
	#   see        CountDevanagari, CountCjk
	def CountThai()
		_pH_ = @oString.Engine()
		return StzEngineStringCountThai(_pH_)

	  #======================================================#
	 #   OVERLAPPING OCCURRENCES                             #
	#======================================================#

	# How many times it occurs, counting OVERLAPPING matches.
	def CountOverlappingCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringCountOverlapping(_pH_, pcSubStr)

	# Returns how many times a fragment occurs in the text, counting occurrences that overlap.
	#
	#   pcSubStr   the fragment to count
	#   returns    a number
	#   note       aa in aaaa gives 3 where Count gives 2
	#   warning    CountOverlappingCS ignores its flag and always compares with case: aa in AAaa
	#              gives 1 with the flag 0 and with 1, where ignoring case would give 3
	#   see        Count, NumberOfOccurrence
	def CountOverlapping(pcSubStr)
		return This.CountOverlappingCS(pcSubStr, 1)

	  #======================================================#
	 #   REGEX MATCH COUNT                                  #
	#======================================================#

	# Returns how many matches a regular expression has in the text.
	#
	#   pcPattern   the regular expression
	#   returns     a number; 0 when nothing matches or the pattern is invalid
	#   note        NumberOfRegexMatches is the same call; [0-9]+ in Ab1 cD22 e3 gives 3 and [0-9]
	#               gives 4; CountRegexCS with the flag 0 ignores case, so [a-c] gives 3 against 2;
	#               the Hebrew class [א-ת]+ gives 2 words in שלום עולם abc
	#   warning     an invalid pattern such as [ gives 0 and no error
	#   see         CountCharsW, Count
	#@ aka  How many matches of the given regex pattern.
	def CountRegex(pcPattern)
		_pH_ = @oString.Engine()
		return StzEngineStringRegexCount(_pH_, pcPattern, 0)

		def NumberOfRegexMatches(pcPattern)
			return This.CountRegex(pcPattern)

	def CountRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		_pH_ = @oString.Engine()
		return StzEngineStringRegexCount(_pH_, pcPattern, _nFlags_)

		def NumberOfRegexMatchesCS(pcPattern, pCaseSensitive)
			return This.CountRegexCS(pcPattern, pCaseSensitive)

	  #======================================================#
	 #   COUNT CHARS MATCHING EXPRESSION                    #
	#======================================================#

	# Returns how many characters satisfy a condition written in the W syntax.
	#
	#   pcExpr     the condition, comparing @char with a quoted character
	#   returns    a number
	#   note       CountCharsWhere and NumberOfCharsW are the same call; @char = "2" in Ab1 cD22 e3
	#              gives 2; @char = "ל" in שלום שלום gives 2
	#   warning    a Q(@char).IsLowercase() or isDigit expression counts 0 and raises no error;
	#              compare @char with a quoted character
	#   see        CountRegex, CountAnyChar
	def CountCharsW(pcExpr)
		return StzEngineStringCountCharsW(@oString.Content(), pcExpr)

		def CountCharsWhere(pcExpr)
			return This.CountCharsW(pcExpr)

		def NumberOfCharsW(pcExpr)
			return This.CountCharsW(pcExpr)

