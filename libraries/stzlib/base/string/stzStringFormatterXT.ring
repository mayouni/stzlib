#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTERXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string formatter -- adds all       #
#                  Softanza method aliases to stzStringFormatter#
#                  via addmethod() for full fluency.            #
#                  Use stzStringFormatter for lean canonical API#
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringFormatterXTQ(str)
	return new stzStringFormatterXT(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFormatterXT from stzStringFormatter

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

			# --- ApplyLowercase aliases ---

			[ "Lowercase",                  "ApplyLowercase" ],

			# --- Lowercased aliases ---

			[ "ToLowercase",                "Lowercased" ],

			# --- ApplyUppercase aliases ---

			[ "Uppercase",                  "ApplyUppercase" ],

			# --- Uppercased aliases ---

			[ "ToUppercase",                "Uppercased" ],

			# --- ApplyCapitalcase aliases ---

			[ "Capitalize",                 "ApplyCapitalcase" ],

			# --- ApplyTitlecase aliases ---

			[ "Titlecase",                  "ApplyTitlecase" ],

			# --- ApplyReverse aliases ---

			[ "Reverse",                    "ApplyReverse" ],

			# --- LeftAlign aliases ---

			[ "AlignLeft",                  "LeftAlign" ],

			# --- LeftAlignXT aliases ---

			[ "AlignLeftXT",                "LeftAlignXT" ],

			# --- LeftAligned aliases ---

			[ "AlignedToLeft",              "LeftAligned" ],

			# --- RightAlign aliases ---

			[ "AlignRight",                 "RightAlign" ],

			# --- RightAlignXT aliases ---

			[ "AlignRightXT",               "RightAlignXT" ],

			# --- RightAligned aliases ---

			[ "AlignedToRight",             "RightAligned" ],

			# --- CenterAlign aliases ---

			[ "AlignCenter",                "CenterAlign" ],

			# --- CenterAlignXT aliases ---

			[ "AlignCenterXT",              "CenterAlignXT" ],

			# --- CenterAligned aliases ---

			[ "AlignedToCenter",            "CenterAligned" ],
			[ "Centered",                   "CenterAligned" ],

			# --- RepeatedNTimes aliases ---

			[ "Repeated",                   "RepeatedNTimes" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
