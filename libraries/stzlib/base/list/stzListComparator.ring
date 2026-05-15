#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOMPARATOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List comparator subclass -- equality,      #
#                  diff, common items, union, intersection.    #
#                  For aliases, use stzListComparatorXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListComparator from stzList

	def IsEqualToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			return 0
		ok
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		if This.HasSameContentAsCS(paOtherList, pCaseSensitive)
			return 1
		else
			return 0
		ok

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	def CommonItemsCS(paOtherList, pCaseSensitive)
		aResult = []
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen
			item = aContent[i]
			if StzListQ(paOtherList).ContainsCS(item, pCaseSensitive) and
			   NOT StzListQ(aResult).ContainsCS(item, pCaseSensitive)
				aResult + item
			ok
		next
		return aResult

	def CommonItems(paOtherList)
		return This.CommonItemsCS(paOtherList, 1)

	def UnionCS(paOtherList, pCaseSensitive)
		aResult = This.Content()
		nLen = len(paOtherList)
		for i = 1 to nLen
			if NOT StzListQ(aResult).ContainsCS(paOtherList[i], pCaseSensitive)
				aResult + paOtherList[i]
			ok
		next
		return aResult

	def Union(paOtherList)
		return This.UnionCS(paOtherList, 1)

	def DifferenceCS(paOtherList, pCaseSensitive)
		aResult = []
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT StzListQ(paOtherList).ContainsCS(aContent[i], pCaseSensitive)
				aResult + aContent[i]
			ok
		next
		return aResult

	def Difference(paOtherList)
		return This.DifferenceCS(paOtherList, 1)

	def IsReverseOfCS(paOtherList, pCaseSensitive)
		return This.IsEqualToCS(StzListQ(paOtherList).ReversedQ().Content(), pCaseSensitive)

	def IsReverseOf(paOtherList)
		return This.IsReverseOfCS(paOtherList, 1)
