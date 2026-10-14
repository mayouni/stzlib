#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGALIGNER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String aligner -- alignment and padding     #
#                  operations.                                 #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringAlignerXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Aligns a text in a field of a given width: pads it on the left, on the right or on both sides with a chosen character.
#
# It is the alignment helper behind the padding methods of stzString. Build one with new
# stzStringAligner("abc") over a text. Each in-place verb (AlignLeft, AlignRight, AlignCenter,
# PadLeft, PadRight, PadBoth) changes the text it holds and has a passive twin that returns the
# padded text (AlignedLeft, AlignedRight, AlignedCenter, PaddedLeft ...). Widths count characters,
# not bytes, so Hebrew, Arabic and emoji align like any other text, and a width smaller than the
# text changes nothing. Do not pass a stzString object you still need: the first in-place edit
# empties it.
#
#   receiver   o1 = new stzStringAligner("abc")
#   example    ? o1.AlignedLeft(6, ".")
#              #--> abc...
#              ? o1.AlignedRight(6, ".")
#              #--> ...abc
#              ? o1.AlignedCenter(7, "-")
#              #--> --abc--
#              o2 = new stzStringAligner("שלום")
#              ? o2.AlignedLeft(6, "😀")
#              #--> שלום😀😀
#   see        stzString, stzStringTrimmer
class stzStringAligner from stzObject

	@oString

	# Builds an aligner over a text or over a stzString object, to pad it on the left, on the right or on both sides.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to align
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringAligner! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit (AlignLeft, AlignRight,
	#                     AlignCenter, PadLeft ...) leaves that stzString EMPTY: after
	#                     oa.AlignRight(8, ".") on a stzString "hello", oa holds "...hello" and the
	#                     stzString holds ""; the passive forms (AlignedLeft ...) do not do it. Pass
	#                     the text, os.Content(), to be safe
	#   see               AlignLeft, AlignedLeft
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringAligner! Parameter must be a string or stzString object.")
		ok

	# Returns the text the aligner holds, after any edit made through it.
	#
	#   returns    a text
	#   see        NumberOfChars
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   note       "שלום" counts 4, and with two * on each side 8
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
	 #   ALIGN LEFT                                         #
	#======================================================#

	# Pads the text on its right with a character up to a width, so the text sits at the left, in place.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :Using, "*" ]
	#   returns    nothing; use AlignLeftQ to chain
	#   note       a width not larger than the text changes nothing; an empty padding character
	#              changes nothing; a padding text of 2 characters is repeated once per missing
	#              character, so "abc" to 6 with ".." gives 9 characters
	#   see        AlignedLeft, AlignRight, PadRight
	def AlignLeft(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringLjust(_pH_, n, pcChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def AlignLeftQ(n, pcChar)
			This.AlignLeft(n, pcChar)
			return This

	# Returns the text padded on its right up to a width, leaving the aligner unchanged.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :Using, "*" ]
	#   returns    a text
	#   note       "abc" to 6 with "." gives "abc..."; it works with Hebrew and emoji padding too
	#   see        AlignLeft
	def AlignedLeft(n, pcChar)
		_oCopy_ = new stzStringAligner(@oString.Content())
		_oCopy_.AlignLeft(n, pcChar)
		return _oCopy_.Content()

	  #======================================================#
	 #   ALIGN RIGHT                                        #
	#======================================================#

	# Pads the text on its left with a character up to a width, so the text sits at the right, in place.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :With, "*" ]
	#   returns    nothing; use AlignRightQ to chain
	#   note       a width not larger than the text changes nothing
	#   see        AlignedRight, AlignLeft, PadLeft
	def AlignRight(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRjust(_pH_, n, pcChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def AlignRightQ(n, pcChar)
			This.AlignRight(n, pcChar)
			return This

	# Returns the text padded on its left up to a width, leaving the aligner unchanged.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :With, "*" ]
	#   returns    a text
	#   note       "abc" to 6 with "." gives "...abc"
	#   see        AlignRight
	def AlignedRight(n, pcChar)
		_oCopy_ = new stzStringAligner(@oString.Content())
		_oCopy_.AlignRight(n, pcChar)
		return _oCopy_.Content()

	  #======================================================#
	 #   ALIGN CENTER                                       #
	#======================================================#

	# Pads the text on both sides up to a width, so the text sits in the middle, in place.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :Char, "*" ]
	#   returns    nothing; use AlignCenterQ to chain
	#   note       when the padding is odd the extra character goes to the right: "abc" to 6 gives
	#              ".abc.."
	#   see        AlignedCenter, PadBoth
	def AlignCenter(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCenterPad(_pH_, n, pcChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def AlignCenterQ(n, pcChar)
			This.AlignCenter(n, pcChar)
			return This

	# Returns the text padded on both sides up to a width, leaving the aligner unchanged.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character, or [ :Char, "*" ]
	#   returns    a text
	#   note       "abc" to 7 with "." gives "..abc.."
	#   see        AlignCenter
	def AlignedCenter(n, pcChar)
		_oCopy_ = new stzStringAligner(@oString.Content())
		_oCopy_.AlignCenter(n, pcChar)
		return _oCopy_.Content()

	  #======================================================#
	 #   PAD LEFT / RIGHT                                   #
	#======================================================#

	# Pads the text on its left up to a width, in place, exactly as AlignRight does.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character
	#   returns    nothing; use PadLeftQ to chain
	#   note       "5" padded left to 3 with "0" gives "005"
	#   see        AlignRight, PaddedLeft
	def PadLeft(n, pcChar)
		This.AlignRight(n, pcChar)

		def PadLeftQ(n, pcChar)
			This.PadLeft(n, pcChar)
			return This

	def PaddedLeft(n, pcChar)
		return This.AlignedRight(n, pcChar)

	# Pads the text on its right up to a width, in place, exactly as AlignLeft does.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character
	#   returns    nothing; use PadRightQ to chain
	#   see        AlignLeft, PaddedRight
	def PadRight(n, pcChar)
		This.AlignLeft(n, pcChar)

		def PadRightQ(n, pcChar)
			This.PadRight(n, pcChar)
			return This

	def PaddedRight(n, pcChar)
		return This.AlignedLeft(n, pcChar)

	  #======================================================#
	 #   PAD BOTH SIDES                                     #
	#======================================================#

	# Pads the text on both sides up to a width, in place, exactly as AlignCenter does.
	#
	#   n          the width wanted, in characters
	#   pcChar     the padding character
	#   returns    nothing; use PadBothQ to chain
	#   see        AlignCenter, PaddedBoth
	def PadBoth(n, pcChar)
		This.AlignCenter(n, pcChar)

		def PadBothQ(n, pcChar)
			This.PadBoth(n, pcChar)
			return This

	def PaddedBoth(n, pcChar)
		return This.AlignedCenter(n, pcChar)

	  #======================================================#
	 #   ALIGNMENT CHECKING                                 #
	#======================================================#

	# TRUE if the text is padded on its right with the character up to the width, or is already that wide or wider.
	#
	#   n          the width
	#   pcChar     the padding character expected
	#   returns    TRUE or FALSE
	#   note       it also answers TRUE for a text already n characters long, whichever side it was
	#              padded: "abc..." is aligned left and right at width 6
	#   see        IsAlignedRight, AlignLeft
	def IsAlignedLeft(n, pcChar)
		_cStr_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ >= n
			return 1
		ok
		_cPad_ = ""
		for i = 1 to n - _nLen_
			_cPad_ += pcChar
		next
		return StzRight(_cStr_, n - _nLen_) = _cPad_

	# TRUE if the text is padded on its left with the character up to the width, or is already that wide or wider.
	#
	#   n          the width
	#   pcChar     the padding character expected
	#   returns    TRUE or FALSE
	#   note       it also answers TRUE for a text already n characters long, whichever side it was
	#              padded
	#   see        IsAlignedLeft, AlignRight
	def IsAlignedRight(n, pcChar)
		_cStr_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ >= n
			return 1
		ok
		_cPad_ = ""
		for i = 1 to n - _nLen_
			_cPad_ += pcChar
		next
		return StzLeft(_cStr_, n - _nLen_) = _cPad_
