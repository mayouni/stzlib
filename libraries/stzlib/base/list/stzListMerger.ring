#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTMERGER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List merger subclass -- merge and          #
#                  associate operations.                        #
#                  For aliases, use stzListMergerXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListMerger from stzList

	def Merge()
		aContent = This.Content()
		nLen = This.NumberOfItems()
		aResult = []
		for i = 1 to nLen
			if isList(aContent[i])
				nLenList = len(aContent[i])
				for j = 1 to nLenList
					aResult + aContent[i][j]
				next
			else
				aResult + aContent[i]
			ok
		next
		This.Update(aResult)

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		aResult = This.Copy().MergeQ().Content()
		return aResult

	def MergeWith(paOtherList)
		nLen = len(paOtherList)
		for i = 1 to nLen
			This.Add(paOtherList[i])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	def MergedWith(paOtherList)
		aResult = This.Copy().MergeWithQ(paOtherList).Content()
		return aResult

	def AssociateWith(paOtherList)
		aContent = This.Content()
		nLen = This.NumberOfItems()
		nLenOther = len(paOtherList)
		aResult = []
		for i = 1 to nLen
			if i <= nLenOther
				aResult + [aContent[i], paOtherList[i]]
			else
				aResult + [aContent[i], ""]
			ok
		next
		return aResult

		def AssociateWithQ(paOtherList)
			return new stzList(This.AssociateWith(paOtherList))

	def AssociatedWith(paOtherList)
		return This.AssociateWith(paOtherList)
