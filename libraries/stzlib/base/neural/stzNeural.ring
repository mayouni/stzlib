#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V1.2) - STZNEURAL (BASE)            #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzNeural -- the COMMON BASE for every class  #
#                  in the neural domain (base/neural/). "Neural"  #
#                  is not itself a thing you instantiate: the     #
#                  inference runtime is stzNeuralEngine, a loaded  #
#                  model is stzNeuralModel, and future neural      #
#                  classes (stzNeuralNetwork ...) also derive from  #
#                  stzNeural. This base carries what they all       #
#                  share: access to the vendored ggml runtime.     #
#   Version      : V1.2 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

# Data-returning runtime shortcuts (no object needed).
func StzGgmlVersion()
	return StzEngineNeuralVersion()

func StzNeuralReady()
	return StzEngineNeuralSmoke() = 1

  /////////////////
 ///   CLASS   ///
/////////////////

# Base class -- not meant to be instantiated directly; derive from it.
class stzNeural

	# The vendored ggml build version (common to the whole domain).
	def GgmlVersion()
		return StzEngineNeuralVersion()

	# TRUE if the ggml runtime is compiled in and executes (context -> tensor ->
	# compute round-trip). Every neural class depends on this being ready.
	def RuntimeReady()
		return StzEngineNeuralSmoke() = 1

		def IsRuntimeReady()
			return This.RuntimeReady()
