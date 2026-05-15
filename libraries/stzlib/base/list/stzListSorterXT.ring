#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSORTERXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sorter extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSorterXT from stzListSorter

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# IsSorted aliases
				[:ItemsAreSorted,		:IsSorted],
				[:ItemsAreSortedInAscending,	:IsSortedInAscending],
				[:ItemsAreSortedUp,		:IsSortedInAscending],
				[:ItemsAreSortedInDescending,	:IsSortedInDescending],
				[:ItemsAreSortedDown,		:IsSortedInDescending],

				# Sort misspelled
				[:SortInAsending,		:SortInAscending],
				[:SortInAssending,		:SortInAscending],
				[:SortedInAsending,		:SortedInAscending],
				[:SortedInAssending,		:SortedInAscending],

				# Reverse aliases
				[:ReverseOrder,			:Reverse],
				[:ReverseItems,			:Reverse],
				[:ReverseItemsOrder,		:Reverse],
				[:ItemsOrderReversed,		:Reversed],
				[:OrderReversed,		:Reversed],

				# Classify aliases
				[:Categorize,			:Classify],
				[:Categorise,			:Classify]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
