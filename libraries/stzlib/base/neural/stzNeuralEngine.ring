#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZNEURALENGINE                #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzNeuralEngine -- wraps the INFERENCE       #
#                  RUNTIME itself (the vendored ggml, CPU-only). #
#                  The compute backend that runs models: version, #
#                  readiness, backend info, and (later) thread     #
#                  config + running a model's forward pass.         #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

func StzNeuralEngine()
	return new stzNeuralEngine()

func StzNeuralEngineQ()
	return new stzNeuralEngine()

class stzNeuralEngine from stzNeural

	def init()
		# stateless facade over the ggml inference backend.

	# TRUE if the ggml backend is compiled in and executes.
	def IsReady()
		return This.GgmlReady()

		def IsAvailable()
			return This.IsReady()

	def Backend()
		return "ggml (CPU)"

	# Content() = what the engine IS: its [key, value] snapshot (backend, version,
	# readiness). Show() renders it (the Softanza Show = visualize Content rule).
	def Content()
		return [
			[ "backend", This.Backend() ],
			[ "version", This.GgmlVersion() ],
			[ "ready", This.IsReady() ]
		]

	def Show()
		_aC_ = This.Content()
		? "stzNeuralEngine [ backend=" + _aC_[1][2] +
		  ", version=" + _aC_[2][2] + ", ready=" + _aC_[3][2] + " ]"
		return This
