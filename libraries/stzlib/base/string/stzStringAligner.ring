#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGALIGNER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String aligner subclass -- alignment        #
#                  and padding operations.                      #
#                  For aliases, use stzStringAlignerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringAligner from stzString

	  #======================================================#
	 #   ALIGN LEFT                                         #
	#======================================================#

	def AlignLeft(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen >= n
			return
		ok
		nPad = n - nLen
		This.Update(cStr + ring_copy(pcChar, nPad))

		def AlignLeftQ(n, pcChar)
			This.AlignLeft(n, pcChar)
			return This

	def AlignedLeft(n, pcChar)
		return This.Copy().AlignLeftQ(n, pcChar).Content()

	  #======================================================#
	 #   ALIGN RIGHT                                        #
	#======================================================#

	def AlignRight(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen >= n
			return
		ok
		nPad = n - nLen
		This.Update(ring_copy(pcChar, nPad) + cStr)

		def AlignRightQ(n, pcChar)
			This.AlignRight(n, pcChar)
			return This

	def AlignedRight(n, pcChar)
		return This.Copy().AlignRightQ(n, pcChar).Content()

	  #======================================================#
	 #   ALIGN CENTER                                       #
	#======================================================#

	def AlignCenter(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen >= n
			return
		ok
		nTotal = n - nLen
		nLeft = floor(nTotal / 2)
		nRight = nTotal - nLeft
		This.Update(ring_copy(pcChar, nLeft) + cStr + ring_copy(pcChar, nRight))

		def AlignCenterQ(n, pcChar)
			This.AlignCenter(n, pcChar)
			return This

	def AlignedCenter(n, pcChar)
		return This.Copy().AlignCenterQ(n, pcChar).Content()

	  #======================================================#
	 #   PAD LEFT / RIGHT                                   #
	#======================================================#

	def PadLeft(n, pcChar)
		This.AlignRight(n, pcChar)

		def PadLeftQ(n, pcChar)
			This.PadLeft(n, pcChar)
			return This

	def PaddedLeft(n, pcChar)
		return This.AlignedRight(n, pcChar)

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

	def IsAlignedLeft(n, pcChar)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen >= n
			return 1
		ok
		return right(cStr, n - nLen) = ring_copy(pcChar, n - nLen)

	def IsAlignedRight(n, pcChar)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen >= n
			return 1
		ok
		return left(cStr, n - nLen) = ring_copy(pcChar, n - nLen)
