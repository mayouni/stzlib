#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCASECHANGER        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String case changer subclass -- case        #
#                  transformations (upper, lower, toggle).      #
#                  For aliases, use stzStringCaseChangerXT.     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCaseChanger from stzString

	  #======================================================#
	 #   UPPERCASE                                          #
	#======================================================#

	def Uppercase()
		This.Update(upper(This.Content()))

		def UppercaseQ()
			This.Uppercase()
			return This

	def Uppercased()
		return upper(This.Content())

	  #======================================================#
	 #   LOWERCASE                                          #
	#======================================================#

	def Lowercase()
		This.Update(lower(This.Content()))

		def LowercaseQ()
			This.Lowercase()
			return This

	def Lowercased()
		return lower(This.Content())

	  #======================================================#
	 #   CAPITALIZE                                         #
	#======================================================#

	def Capitalize()
		cStr = This.Lowercased()
		if len(cStr) > 0
			cStr[1] = upper(cStr[1])
		ok
		This.Update(cStr)

		def CapitalizeQ()
			This.Capitalize()
			return This

	def Capitalized()
		return This.Copy().CapitalizeQ().Content()

	  #======================================================#
	 #   CAPITALIZE EACH WORD                               #
	#======================================================#

	def CapitalizeEachWord()
		cStr = This.Lowercased()
		nLen = len(cStr)
		if nLen = 0
			return
		ok
		cResult = upper(cStr[1])
		for i = 2 to nLen
			if i > 1 and cStr[i-1] = " "
				cResult += upper(cStr[i])
			else
				cResult += cStr[i]
			ok
		next
		This.Update(cResult)

		def CapitalizeEachWordQ()
			This.CapitalizeEachWord()
			return This

	def EachWordCapitalized()
		return This.Copy().CapitalizeEachWordQ().Content()

	  #======================================================#
	 #   CASE CHECKING                                      #
	#======================================================#

	def IsUppercase()
		return This.Content() = upper(This.Content())

	def IsLowercase()
		return This.Content() = lower(This.Content())

	def IsCapitalized()
		cStr = This.Content()
		if len(cStr) = 0
			return 0
		ok
		return cStr[1] = upper(cStr[1])

	  #======================================================#
	 #   TOGGLE CASE                                        #
	#======================================================#

	def ToggleCase()
		cStr = This.Content()
		nLen = This.NumberOfChars()
		cResult = ""
		for i = 1 to nLen
			c = cStr[i]
			if c = upper(c)
				cResult += lower(c)
			else
				cResult += upper(c)
			ok
		next
		This.Update(cResult)

		def ToggleCaseQ()
			This.ToggleCase()
			return This

	def CaseToggled()
		return This.Copy().ToggleCaseQ().Content()

	  #======================================================#
	 #   FORCE CASE                                         #
	#======================================================#

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
