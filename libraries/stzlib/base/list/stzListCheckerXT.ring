#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCHECKERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List checker extended class -- aliases      #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListCheckerXT from stzListChecker

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# IsListOf* aliases
				[:IsMadeOfNumbers,		:IsListOfNumbers],
				[:ContainsOnlyNumbers,		:IsListOfNumbers],
				[:IsMadeOfStrings,		:IsListOfStrings],
				[:ContainsOnlyStrings,		:IsListOfStrings],
				[:IsMadeOfLists,		:IsListOfLists],
				[:ContainsOnlyLists,		:IsListOfLists],
				[:IsMadeOfObjects,		:IsListOfObjects],
				[:ContainsOnlyObjects,		:IsListOfObjects],

				# IsEqualTo aliases
				[:HasSameContentAs,		:IsEqualTo],
				[:HasSameContentAsCS,		:IsEqualToCS],

				# Comparison aliases
				[:HasMoreItemsThan,		:HasMoreNumberOfItems],
				[:HasLessItemsThan,		:HasLessNumberOfItems],
				[:HasSameNumberOfItemsAs,	:HasSameNumberOfItems],

				# Named param aliases
				[:IsWithNamedParam,		:IsWithOrByOrUsingNamedParam],
				[:IsByNamedParam,		:IsWithOrByOrUsingNamedParam],
				[:IsUsingNamedParam,		:IsWithOrByOrUsingNamedParam]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next

		ok
