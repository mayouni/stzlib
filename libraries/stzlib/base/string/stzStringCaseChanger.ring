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

	def Capitalized()
		return This.Copy().UppercaseQ().Content()

	  #======================================================#
	 #   CASE CHECKING                                      #
	#======================================================#

	def IsUppercase()
		return This.Content() = upper(This.Content())

	def IsLowercase()
		return This.Content() = lower(This.Content())

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
