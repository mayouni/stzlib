#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGEXTRACTORXT        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String extractor extended class -- aliases  #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringExtractorXT from stzStringExtractor

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

			# --- ExtractSection aliases ---

			[ "PopSection",		"ExtractSection" ],

			# --- ExtractRange aliases ---

			[ "PopRange",		"ExtractRange" ],

			# --- ExtractFirst aliases ---

			[ "PopFirst",		"ExtractFirst" ],

			# --- ExtractLast aliases ---

			[ "PopLast",		"ExtractLast" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
