#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTGETTERXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List getter extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListGetterXT from stzListGetter

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:ItemAt,		:NthItem],
				[:ItemAtPosition,	:NthItem],
				[:First,		:FirstItem],
				[:Last,			:LastItem],
				[:Central,		:CentralItem],
				[:Middle,		:CentralItem],
				[:TopN,			:NFirstItems],
				[:HeadItems,		:NFirstItems],
				[:BottomN,		:NLastItems],
				[:TailItems,		:NLastItems],
				[:ItemsAt,		:ItemsAtPositions],
				[:DistinctItems,	:UniqueItems],
				[:DistinctItemsCS,	:UniqueItemsCS],
				[:AnyItem,		:RandomItem],
				[:PickRandom,		:RandomItem],
				[:PickNRandom,		:NRandomItems]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
