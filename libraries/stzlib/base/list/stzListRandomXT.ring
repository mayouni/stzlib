#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTRANDOMXT            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List random extended class -- aliases       #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListRandomXT from stzListRandom

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# RandomItem aliases
				[:AnyRandomItem,		:RandomItem],
				[:AnItem,			:RandomItem],
				[:ARandomItem,			:RandomItem],

				# RandomItemExcept aliases
				[:AnItemOtherThan,		:RandomItemExcept],
				[:AnyItemOtherThan,		:RandomItemExcept],
				[:AnItemExcept,			:RandomItemExcept],
				[:AnyItemExcept,		:RandomItemExcept],

				# RandomPosition aliases
				[:AnyRandomPosition,		:RandomPosition],
				[:APosition,			:RandomPosition],
				[:ARandomPosition,		:RandomPosition],

				# Randomize aliases
				[:ShufflePositions,		:Randomize],
				[:RandomisePositions,		:Randomize],
				[:RandomizePositions,		:Randomize],

				# Passive aliases
				[:Shuffeled,			:Randomized],
				[:Randomised,			:Randomized],

				# RandomizeAntiSections aliases
				[:RandomizeOutsideSections,	:RandomizeAntiSections],
				[:RandomiseAntiSections,	:RandomizeAntiSections],
				[:RandomiseOutsideSections,	:RandomizeAntiSections]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
