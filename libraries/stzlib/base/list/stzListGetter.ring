#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTGETTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List getter subclass -- content access,    #
#                  nth/first/last items, N-first/N-last.      #
#                  For aliases, use stzListGetterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListGetter from stzList

	def ContentCS(pCaseSensitive)
		return This.List()

	def Content()
		return This.ContentCS(1)

	def NthItem(n)
		if CheckingParams()
			if isList(n) and IsOneOfTheseNamedParamsList(n, [:At, :AtPosition, :ItemAt])
				n = n[2]
			ok
		ok
		return This.List()[n]

	def FirstItem()
		return This.NthItem(1)

	def LastItem()
		return This.NthItem(This.NumberOfItems())

	def CentralItem()
		n = ceil(This.NumberOfItems() / 2)
		return This.NthItem(n)

	def NFirstItems(n)
		aResult = []
		for i = 1 to n
			aResult + This.List()[i]
		next
		return aResult

	def NLastItems(n)
		nLen = This.NumberOfItems()
		aResult = []
		for i = nLen - n + 1 to nLen
			aResult + This.List()[i]
		next
		return aResult
