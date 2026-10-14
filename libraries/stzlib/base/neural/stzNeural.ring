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

# Data-returning shortcuts (no object needed).
func StzGgmlVersion()
	return StzEngineNeuralVersion()

func StzGgmlReady()
	return StzEngineNeuralSmoke() = 1

  /////////////////
 ///   CLASS   ///
/////////////////

# Is the common base of the neural classes, which carries what they share: access to the vendored ggml backend.
#
# It is not meant to be built for its own sake; stzNeuralEngine and stzNeuralModel derive from it.
# It answers two questions every neural class depends on: which ggml build is linked, and whether
# the backend computes. The data-returning shortcuts StzGgmlVersion() and StzGgmlReady() do the same
# without an object.
#
#   receiver   o1 = new stzNeural
#   example    ? o1.GgmlReady()
#              #--> 1
#   see        stzNeuralEngine, stzNeuralModel, StzGgmlVersion
class stzNeural from stzObject

	# Returns the build version of the vendored ggml library, the same for every neural class.
	#
	#   returns    a text such as 0.0.0-stz
	#   see        GgmlReady, stzNeuralEngine
	#@ aka  The vendored ggml build version (common to the whole domain).
	def GgmlVersion()
		return StzEngineNeuralVersion()

	# TRUE if the ggml backend is compiled in and runs a small tensor computation end to end.
	#
	#   returns    1 or 0, numbers
	#   see        GgmlVersion, stzNeuralEngine
	#@ aka  TRUE if the ggml backend is compiled in and executes (context -> tensor -> compute round-trip). Every neural class depends on this being ready.
	def GgmlReady()
		return StzEngineNeuralSmoke() = 1
