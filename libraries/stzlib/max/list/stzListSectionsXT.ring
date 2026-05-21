#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSECTIONSXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sections extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSectionsXT from stzListSections

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# Section aliases
				[:Slice,			:Section],
				[:SliceCS,			:SectionCS],

				# Sections aliases
				[:Slices,			:Sections],
				[:ManySections,			:Sections],

				# Range aliases
				[:ManyRanges,			:Ranges],

				# AntiSection aliases
				[:SectionsOtherThan,		:AntiSections],
				[:RangesOtherThan,		:AntiRanges]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
