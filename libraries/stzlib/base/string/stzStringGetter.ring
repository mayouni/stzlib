#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGGETTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String getter subclass -- accessing         #
#                  individual chars and char groups.            #
#                  For aliases, use stzStringGetterXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringGetter from stzString

	  #======================================================#
	 #   ACCESSING NTH CHAR                                 #
	#======================================================#

	def NthChar(n)
		return This.Content()[n]

	  #======================================================#
	 #   FIRST / LAST / MIDDLE CHAR                         #
	#======================================================#

	def FirstChar()
		return This.NthChar(1)

	def LastChar()
		return This.NthChar(This.NumberOfChars())

	def MiddleChar()
		n = ceil(This.NumberOfChars() / 2)
		return This.NthChar(n)

	  #======================================================#
	 #   N FIRST / N LAST CHARS                             #
	#======================================================#

	def NFirstChars(n)
		return This.Section(1, n)

	def NLastChars(n)
		nLen = This.NumberOfChars()
		return This.Section(nLen - n + 1, nLen)

	  #======================================================#
	 #   ALL CHARS AS LIST                                  #
	#======================================================#

	def Chars()
		aResult = []
		cStr = This.Content()
		nLen = This.NumberOfChars()
		for i = 1 to nLen
			aResult + cStr[i]
		next
		return aResult
