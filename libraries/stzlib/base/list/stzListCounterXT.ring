#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOUNTERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List counter extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListCounterXT from stzListCounter

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# CountW aliases
				[:NumberOfOccurrenceW,		:CountItemsW],
				[:HowManyItemW,			:CountItemsW],
				[:NumberOfItemsUW,		:NumberOfUniqueItemsW],
				[:HowManyItemUW,		:NumberOfUniqueItemsW],
				[:NumberOfItemsWithoutDuplicationW, :NumberOfUniqueItemsW],

				# CountWXT aliases
				[:NumberOfOccurrenceWXT,		:CountItemsWXT],
				[:HowManyItemWXT,		:CountItemsWXT],
				[:NumberOfItemsUWXT,		:NumberOfUniqueItemsWXT],
				[:HowManyItemUWXT,		:NumberOfUniqueItemsWXT],
				[:NumberOfItemsWithoutDuplicationWXT, :NumberOfUniqueItemsWXT],

				# InsertW aliases
				[:InsertAfterWhereQ,		:InsertAfterWQ],
				[:InsertAtWQ,			:InsertBeforeWQ],

				# InsertWXT aliases
				[:InsertAfterWhereXTQ,		:InsertAfterWXTQ],
				[:InsertAtWXTQ,			:InsertBeforeWXTQ]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
