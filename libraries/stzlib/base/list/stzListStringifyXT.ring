#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSTRINGIFYXT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List stringify extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListStringifyXT from stzListStringify

	_bAliasesLoaded = 0

	def init(paList)
		super.init(paList)

		if _bAliasesLoaded = 0

			_bAliasesLoaded = 1

			aAliases = [

				# Stringify aliases
				[:StringifyItems,		:Stringify],
				[:StringifiedItems,		:Stringified],

				# ComputableForm aliases
				[:ToListInString,		:ComputableForm],
				[:ToListInAString,		:ComputableForm],

				# Singlify aliases
				[:RemoveConsecutiveDuplicates,	:Singlify]
			]

			nLen = len(aAliases)
			for i = 1 to nLen
				addmethod(This, aAliases[i][1], aAliases[i][2])
			next
		ok
