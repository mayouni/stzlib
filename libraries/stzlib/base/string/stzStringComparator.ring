#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOMPARATOR         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String comparator subclass -- comparing     #
#                  strings for equality, order, and diff.       #
#                  For aliases, use stzStringComparatorXT.      #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringComparator from stzString

	  #======================================================#
	 #   EQUALITY                                           #
	#======================================================#

	def IsEqualToCS(pcOtherStr, pCaseSensitive)
		if pCaseSensitive = 1
			return This.Content() = pcOtherStr
		else
			return lower(This.Content()) = lower(pcOtherStr)
		ok

	def IsEqualTo(pcOtherStr)
		return This.IsEqualToCS(pcOtherStr, 1)

	  #======================================================#
	 #   ORDERING                                           #
	#======================================================#

	def IsLessThan(pcOtherStr)
		return strcmp(This.Content(), pcOtherStr) < 0

	def IsGreaterThan(pcOtherStr)
		return strcmp(This.Content(), pcOtherStr) > 0

	  #======================================================#
	 #   DIFF                                               #
	#======================================================#

	def DiffWith(pcOtherStr)
		aResult = []
		nLen = This.NumberOfChars()
		nOtherLen = StzStringQ(pcOtherStr).NumberOfChars()
		nMax = nLen
		if nOtherLen > nMax
			nMax = nOtherLen
		ok
		for i = 1 to nMax
			if i > nLen or i > nOtherLen
				aResult + i
			but This.Content()[i] != pcOtherStr[i]
				aResult + i
			ok
		next
		return aResult
