#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCASECHANGER        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String case changer -- case                 #
#                  transformations (upper, lower, toggle).     #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringCaseChangerXT     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Changes the case of a text: capitals, small letters, first letter only, each word, or swapped, with Unicode rules.
#
# It is the case helper behind the case methods of stzString. Build one with new
# stzStringCaseChanger("text"). Each in-place verb (Uppercase, Lowercase, Capitalize,
# CapitalizeEachWord, ToggleCase, DecapitalizeFirst, SetCase) changes the text it holds and has a
# passive twin that returns the changed text (Uppercased, Lowercased, Capitalized,
# EachWordCapitalized, CaseToggled, FirstDecapitalized). Accents follow the letter, the German ß
# uppercases to SS, and scripts without case (Hebrew, Arabic, emoji) are left alone. Do not pass a
# stzString object you still need: the first in-place edit empties it. IsCapitalized only checks the
# first character.
#
#   receiver   o1 = new stzStringCaseChanger("ça va ÉTÉ")
#   example    ? o1.Uppercased()
#              #--> ÇA VA ÉTÉ
#              ? o1.Capitalized()
#              #--> Ça va été
#              ? o1.EachWordCapitalized()
#              #--> Ça Va Été
#              ? o1.CaseToggled()
#              #--> ÇA VA été
#              o2 = new stzStringCaseChanger("שלום")
#              ? o2.Uppercased()
#              #--> שלום
#   see        stzString, stzStringAligner
class stzStringCaseChanger from stzObject

	@oString

	# Builds a case changer over a text or over a stzString object.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose letters change case
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringCaseChanger!
	#                     Parameter must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit (Uppercase, Lowercase,
	#                     Capitalize, CapitalizeEachWord, ToggleCase, DecapitalizeFirst, SetCase)
	#                     leaves that stzString EMPTY while the changer holds the result; the
	#                     passive forms (Uppercased ...) do not. Pass the text, os.Content(), to be
	#                     safe
	#   see               Uppercased, Uppercase
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCaseChanger! Parameter must be a string or stzString object.")
		ok

	# Returns the text the changer holds, after any in-place change made through it.
	#
	#   returns    a text
	#   see        Uppercased
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   UPPERCASE                                          #
	#======================================================#

	# Changes every letter of the text to capitals, in place, with Unicode rules.
	#
	#   returns    nothing; use UppercaseQ to chain
	#   note       the German ß becomes SS, so the text can grow; scripts without case, such as
	#              Hebrew, Arabic and emoji, are left as they are
	#   see        Uppercased, Lowercase
	def Uppercase()
		@oString.Update(StzUpper(@oString.Content()))

		def UppercaseQ()
			This.Uppercase()
			return This

	# Returns the text with every letter in capitals, leaving the changer unchanged.
	#
	#   returns    a text
	#   note       "ça va été" gives "ÇA VA ÉTÉ"
	#   see        Uppercase
	def Uppercased()
		return StzUpper(@oString.Content())

	  #======================================================#
	 #   LOWERCASE                                          #
	#======================================================#

	# Changes every letter of the text to small letters, in place, with Unicode rules.
	#
	#   returns    nothing; use LowercaseQ to chain
	#   see        Lowercased, Uppercase
	def Lowercase()
		@oString.Update(StzLower(@oString.Content()))

		def LowercaseQ()
			This.Lowercase()
			return This

	# Returns the text with every letter in small letters, leaving the changer unchanged.
	#
	#   returns    a text
	#   note       "ÉCOLE" gives "école"
	#   see        Lowercase
	def Lowercased()
		return StzLower(@oString.Content())

	  #======================================================#
	 #   CAPITALIZE                                         #
	#======================================================#

	# Changes the text so that its first letter is a capital and all the others small, in place.
	#
	#   returns    nothing; use CapitalizeQ to chain
	#   note       the rest of the text is lowered: "hello World" becomes "Hello world"
	#   see        Capitalized, CapitalizeEachWord
	def Capitalize()
		_cStr_ = @oString.Content()
		if StzLen(_cStr_) > 0
			# Engine-backed: first char uppercase, rest lowercase
			_cFirst_ = StzUpper(StzLeft(_cStr_, 1))
			if StzLen(_cStr_) > 1
				_pH_ = StzEngineString(_cStr_)
				pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cStr_) - 1)
				_cRest_ = StzLower(StzEngineStringData(pRest))
				StzEngineStringFree(pRest)
				StzEngineStringFree(_pH_)
				@oString.Update(_cFirst_ + _cRest_)
			else
				@oString.Update(_cFirst_)
			ok
		ok

		def CapitalizeQ()
			This.Capitalize()
			return This

	# Returns the text with its first letter capitalised and the others lowered, leaving the changer unchanged.
	#
	#   returns    a text
	#   see        Capitalize
	def Capitalized()
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.Capitalize()
		return _oCopy_.Content()

	  #======================================================#
	 #   CAPITALIZE EACH WORD                               #
	#======================================================#

	# Changes the text so that each word begins with a capital, in place, with Unicode title case.
	#
	#   returns    nothing; use CapitalizeEachWordQ to chain
	#   note       "ça va été" becomes "Ça Va Été"
	#   see        EachWordCapitalized, Capitalize
	def CapitalizeEachWord()
		# Engine-backed: use StzTitle for Unicode-aware title case
		@oString.Update(StzTitle(@oString.Content()))

		def CapitalizeEachWordQ()
			This.CapitalizeEachWord()
			return This

	# Returns the text with each word beginning with a capital, leaving the changer unchanged.
	#
	#   returns    a text
	#   see        CapitalizeEachWord
	def EachWordCapitalized()
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.CapitalizeEachWord()
		return _oCopy_.Content()

	  #======================================================#
	 #   CASE CHECKING                                      #
	#======================================================#

	# TRUE if the text has letters and all of them are capitals.
	#
	#   returns    TRUE or FALSE
	#   note       text without letters, such as "123" or Hebrew, answers FALSE; digits and spaces
	#              are ignored
	#   see        IsLowercase, IsCapitalized
	def IsUppercase()
		return StzIsUpper(@oString.Content())

	# TRUE if the text has letters and all of them are small.
	#
	#   returns    TRUE or FALSE
	#   note       "abc 123" is lowercase; text without cased letters answers FALSE
	#   see        IsUppercase
	def IsLowercase()
		return StzIsLower(@oString.Content())

	# TRUE if the first character of the text is its own capital form, which is all it looks at.
	#
	#   returns    TRUE or FALSE
	#   note       use it for "begins with a capital letter or an uncased character", not for "is in
	#              capitalised form"
	#   warning    Looks only at the first character, so it answers TRUE for "ABC", for "123", for a
	#              Hebrew text and for "😀 abc", where nothing is capitalised; "abc" is FALSE and an
	#              empty text is FALSE
	#   see        Capitalize, IsUppercase
	def IsCapitalized()
		_cStr_ = @oString.Content()
		if StzLen(_cStr_) = 0
			return 0
		ok
		_cFirst_ = StzLeft(_cStr_, 1)
		return _cFirst_ = StzUpper(_cFirst_)

	  #======================================================#
	 #   TOGGLE CASE                                        #
	#======================================================#

	# Swaps the case of every letter, capitals to small and small to capitals, in place.
	#
	#   returns    nothing; use ToggleCaseQ to chain
	#   note       "Abc Def" becomes "aBC dEF"; ß becomes SS
	#   see        CaseToggled
	def ToggleCase()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringSwapCase(_pH_)
		@oString.Update(StzEngineStringData(_pR_))
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)

		def ToggleCaseQ()
			This.ToggleCase()
			return This

	# Returns the text with the case of every letter swapped, leaving the changer unchanged.
	#
	#   returns    a text
	#   see        ToggleCase
	def CaseToggled()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringSwapCase(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	  #======================================================#
	 #   FORCE CASE                                         #
	#======================================================#

	# Forces the text into one case, :Upper, :Lower or :Capitalized, in place.
	#
	#   pcCase     :Upper or :Uppercase, :Lower or :Lowercase, :Capitalized or :Capital
	#   returns    nothing; use SetCaseQ to chain
	#   note       any other value is ignored without a message and the text stays as it was
	#   see        Uppercase, Lowercase, Capitalize
	def SetCase(pcCase)
		if pcCase = :Upper or pcCase = :Uppercase
			This.Uppercase()
		but pcCase = :Lower or pcCase = :Lowercase
			This.Lowercase()
		but pcCase = :Capitalized or pcCase = :Capital
			This.Capitalize()
		ok

		def SetCaseQ(pcCase)
			This.SetCase(pcCase)
			return This

	  #======================================================#
	 #   DECAPITALIZE FIRST                                 #
	#======================================================#

	# Changes the first letter of the text to a small letter and leaves the rest, in place.
	#
	#   returns    nothing; use DecapitalizeFirstQ to chain
	#   note       "Mixed" becomes "mixed"; a text already starting small is unchanged
	#   see        FirstDecapitalized, Capitalize
	def DecapitalizeFirst()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringDecapitalizeFirst(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def DecapitalizeFirstQ()
			This.DecapitalizeFirst()
			return This

	# Returns the text with its first letter in small form, leaving the changer unchanged.
	#
	#   returns    a text
	#   see        DecapitalizeFirst
	def FirstDecapitalized()
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.DecapitalizeFirst()
		return _oCopy_.Content()
