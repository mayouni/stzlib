#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCONCAT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String concat subclass -- concatenation     #
#                  and repetition operations.                   #
#                  For aliases, use stzStringConcatXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringConcat from stzString

	  #======================================================#
	 #   CONCATENATION                                      #
	#======================================================#

	def Concat(pcStr)
		This.Update(This.Content() + pcStr)

		def ConcatQ(pcStr)
			This.Concat(pcStr)
			return This

	def Concatenated(pcStr)
		return This.Content() + pcStr

	  #======================================================#
	 #   CONCATENATING MANY STRINGS                         #
	#======================================================#

	def ConcatMany(pacStrings)
		cResult = This.Content()
		nLen = len(pacStrings)
		for i = 1 to nLen
			cResult += pacStrings[i]
		next
		This.Update(cResult)

		def ConcatManyQ(pacStrings)
			This.ConcatMany(pacStrings)
			return This

	def ConcatenatedWithMany(pacStrings)
		return This.Copy().ConcatManyQ(pacStrings).Content()

	  #======================================================#
	 #   PREPEND / APPEND                                   #
	#======================================================#

	def Prepend(pcStr)
		This.Update(pcStr + This.Content())

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	def Prepended(pcStr)
		return pcStr + This.Content()

	def Append(pcStr)
		This.Concat(pcStr)

		def AppendQ(pcStr)
			This.Append(pcStr)
			return This

	def Appended(pcStr)
		return This.Concatenated(pcStr)

	  #======================================================#
	 #   REPETITION                                         #
	#======================================================#

	def RepeatNTimes(n)
		cStr = This.Content()
		cResult = ""
		for i = 1 to n
			cResult += cStr
		next
		This.Update(cResult)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

		def Repeat(n)
			This.RepeatNTimes(n)

	def RepeatedNTimes(n)
		return This.Copy().RepeatNTimesQ(n).Content()

		def Repeated(n)
			return This.RepeatedNTimes(n)

	  #======================================================#
	 #   JOIN WITH SEPARATOR                                #
	#======================================================#

	def JoinWith(pcSep)
		aChars = This.Chars()
		cResult = ""
		nLen = len(aChars)
		for i = 1 to nLen
			cResult += aChars[i]
			if i < nLen
				cResult += pcSep
			ok
		next
		This.Update(cResult)

		def JoinWithQ(pcSep)
			This.JoinWith(pcSep)
			return This

	def JoinedWith(pcSep)
		return This.Copy().JoinWithQ(pcSep).Content()
