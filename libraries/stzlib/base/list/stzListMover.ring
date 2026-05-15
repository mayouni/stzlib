#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTMOVER               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List mover subclass -- moving and swapping #
#                  items by position. For aliases, use         #
#                  stzListMoverXT.                              #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListMover from stzList

	def Move(n1, n2)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:From, :FromPosition, :At, :AtPosition])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:To, :ToPosition])
				n2 = n2[2]
			ok
		ok
		item = This.List()[n1]
		ring_remove(This.List(), n1)
		if n2 > n1
			n2 = n2 - 1
		ok
		ring_insert(This.List(), n2 - 1, item)

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

	def Swap(n1, n2)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:Between, :BetweenPosition, :Position, :ItemAt])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:And, :AndPosition, :Position])
				n2 = n2[2]
			ok
		ok
		temp = This.List()[n1]
		This.List()[n1] = This.List()[n2]
		This.List()[n2] = temp

		def SwapQ(n1, n2)
			This.Swap(n1, n2)
			return This

	def MoveToStart(n)
		This.Move(n, 1)

	def MoveToEnd(n)
		This.Move(n, This.NumberOfItems())
