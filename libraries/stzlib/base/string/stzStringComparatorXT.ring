#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOMPARATORXT       #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String comparator extended class -- aliases #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringComparatorXT from stzStringComparator

	_bAliasesLoaded = FALSE

	def init(pcStr)
		super.init(pcStr)
		This._RegisterAliases()

	def _RegisterAliases()

		if _bAliasesLoaded
			return
		ok

		_bAliasesLoaded = TRUE

		_aAliases_ = [

			# --- IsEqualTo aliases ---

			[ "IsTheSameAs",	"IsEqualTo" ],
			[ "IsTheSameAsCS",	"IsEqualToCS" ],
			[ "Equals",		"IsEqualTo" ],
			[ "EqualsCS",		"IsEqualToCS" ],

			# --- IsNotEqualTo aliases ---

			[ "IsDifferentFrom",	"IsNotEqualTo" ],
			[ "IsDifferentFromCS",	"IsNotEqualToCS" ],

			# --- IsLessThan aliases ---

			[ "IsSmallerThan",	"IsLessThan" ],
			[ "IsBefore",		"IsLessThan" ],

			# --- IsGreaterThan aliases ---

			[ "IsBiggerThan",	"IsGreaterThan" ],
			[ "IsAfter",		"IsGreaterThan" ],

			# --- Compare aliases ---

			[ "CompareTo",		"Compare" ],
			[ "CompareToCS",	"CompareCS" ],

			# --- Contains aliases ---

			[ "Includes",		"Contains" ],
			[ "IncludesCS",		"ContainsCS" ],

			# --- ContainsOneOfThese aliases ---

			[ "IncludesOneOfThese",		"ContainsOneOfThese" ],
			[ "IncludesOneOfTheseCS",	"ContainsOneOfTheseCS" ],

			# --- ContainsAllOfThese aliases ---

			[ "IncludesAllOfThese",		"ContainsAllOfThese" ],
			[ "IncludesAllOfTheseCS",	"ContainsAllOfTheseCS" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
