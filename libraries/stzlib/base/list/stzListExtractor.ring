#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTEXTRACTOR           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List extractor subclass -- extract (remove #
#                  and return) items by value, position, or   #
#                  condition. For aliases, use                 #
#                  stzListExtractorXT.                          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListExtractor from stzList

	def ExtractCS(pItem, pCaseSensitive)
		if NOT This.ContainsCS(pItem, pCaseSensitive)
			StzRaise("Can't extract the item! It does not exist in the list.")
		ok
		This.RemoveCS(pItem, pCaseSensitive)
		return pItem

	def Extract(pItem)
		return This.ExtractCS(pItem, 1)

	def ExtractManyCS(paItems, pCaseSensitive)
		anPos = This.FindManyCS(paItems, pCaseSensitive)
		This.RemoveItemsAtPositions(anPos)
		return paItems

	def ExtractMany(paItems)
		return This.ExtractManyCS(paItems, 1)

	def ExtractAll()
		aResult = This.Content()
		This.RemoveAllItems()
		return aResult

	def ExtractNth(n)
		pItem = This.NthItem(n)
		ring_remove(This.List(), n)
		return pItem

	def ExtractFirst()
		return This.ExtractNth(1)

	def ExtractLast()
		return This.ExtractNth(This.NumberOfItems())

	def ExtractSection(n1, n2)
		aResult = This.Section(n1, n2)
		This.RemoveSection(n1, n2)
		return aResult

	def ExtractRange(pnStart, pnRange)
		aResult = This.Range(pnStart, pnRange)
		This.RemoveRange(pnStart, pnRange)
		return aResult

	def ExtractW(pcCondition)
		anPos = This.FindW(pcCondition)
		aResult = This.ItemsAtPositions(anPos)
		This.RemoveItemsAtPositions(anPos)
		return aResult
