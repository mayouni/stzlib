#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCLASSIFIERXT        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List classifier extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListClassifierXT from stzListClassifier

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [
				[:Categorize,	:Classify],
				[:Categorized,	:Classified],
				[:Categories,	:Classes],
				[:CategorizeBy,	:ClassifyBy]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
