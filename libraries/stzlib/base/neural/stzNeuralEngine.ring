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
		# stateless facade over the ggml runtime.

	# TRUE if the runtime is compiled in and executes.
	def IsReady()
		return This.RuntimeReady()

		def IsAvailable()
			return This.IsReady()

	def Backend()
		return "ggml (CPU)"

	# Backend / runtime snapshot as [key, value] data.
	def RuntimeInfo()
		return [
			[ "backend", This.Backend() ],
			[ "version", This.GgmlVersion() ],
			[ "ready", This.IsReady() ]
		]

	# Print the runtime snapshot; returns This for chaining.
	def ShowRuntime()
		? "Softanza neural engine (" + This.Backend() + ")"
		? "  version : " + This.GgmlVersion()
		? "  ready   : " + This.IsReady()
		return This
