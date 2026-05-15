#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCONCATXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String concat extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringConcatXT from stzStringConcat

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

			# --- Concat aliases ---

			[ "Add",		"Concat" ],
			[ "AddQ",		"ConcatQ" ],

			# --- ConcatMany aliases ---

			[ "AddMany",		"ConcatMany" ],
			[ "AddManyQ",		"ConcatManyQ" ],
			[ "ConcatAll",		"ConcatMany" ],

			# --- RepeatNTimes aliases ---

			[ "Multiply",		"RepeatNTimes" ],
			[ "MultiplyQ",		"RepeatNTimesQ" ],

			# --- RepeatedNTimes aliases ---

			[ "Multiplied",		"RepeatedNTimes" ],

			# --- Prepend aliases ---

			[ "PrependWith",	"Prepend" ],
			[ "PrependWithQ",	"PrependQ" ],

			# --- Append aliases ---

			[ "AppendWith",		"Append" ],
			[ "AppendWithQ",	"AppendQ" ],

			# --- JoinWith aliases ---

			[ "GlueWith",		"JoinWith" ],
			[ "GlueWithQ",		"JoinWithQ" ],
			[ "InterspersedWith",	"JoinedWith" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
