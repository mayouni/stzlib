#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCODE              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String code subclass -- detecting and        #
#                  working with code snippets in strings         #
#                  (Ring code, functions, classes).               #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCode from stzString

	  #===============================#
	 #     RING CODE DETECTION       #
	#===============================#

	def IsRingCode()
		cContent = lower(This.Content())
		acKeywords = [
			"func", "class", "def", "if", "but", "else", "ok",
			"for", "next", "while", "end", "switch", "off",
			"return", "load", "see", "give", "new", "try",
			"catch", "done"
		]

		nLen = len(acKeywords)
		for i = 1 to nLen
			oFinder = StzStringFinderQ(cContent)
			if oFinder.Contains(acKeywords[i])
				return 1
			ok
		next
		return 0

	def IsRingFunction()
		cTrimmed = trim(This.Content())
		return left(lower(cTrimmed), 5) = "func "

	def IsRingClass()
		cTrimmed = trim(This.Content())
		return left(lower(cTrimmed), 6) = "class "

	  #===============================#
	 #     CODE EXECUTION            #
	#===============================#

	def Execute()
		eval(This.Content())

	def ExecuteAndReturn()
		cCode = "_result_ = " + This.Content()
		eval(cCode)
		return _result_

	  #===============================#
	 #     CODE STRUCTURE            #
	#===============================#

	def ContainsFunctions()
		oFinder = StzStringFinderQ(lower(This.Content()))
		return oFinder.Contains("func ")

	def ContainsClasses()
		oFinder = StzStringFinderQ(lower(This.Content()))
		return oFinder.Contains("class ")

