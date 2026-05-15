#--------------------------------------------------------------#
#     SOFTANZA LIBRARY (V0.9) - STZSTRINGVISUALIZERXT          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string visualizer -- adds all      #
#                  Softanza method aliases to                   #
#                  stzStringVisualizer via addmethod() for full #
#                  fluency. Use stzStringVisualizer for lean    #
#                  canonical API.                               #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringVisualizerXTQ(str)
	return new stzStringVisualizerXT(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringVisualizerXT from stzStringVisualizer

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

			# --- Stringify aliases ---

			[ "Stringified",                "Stringify" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
