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

func StzNeuralEngineQ()
	return new stzNeuralEngine()

# Reports which inference backend is linked and whether it is ready, as a facade with no state.
#
# It is the first thing to ask before loading a model: IsReady (also IsAvailable) says whether the
# ggml backend runs, Backend names it and Content gives all of it as data, which Show prints. It
# loads no model and downloads nothing.
#
#   receiver   o1 = new stzNeuralEngine
#   example    ? o1.Backend()
#              #--> ggml (CPU)
#              ? o1.IsReady()
#              #--> 1
#   see        stzNeural, stzNeuralModel, stzSemanticIndex
class stzNeuralEngine from stzNeural

	# Builds the facade over the inference backend; it holds no state.
	#
	#   returns    nothing; the object is built
	#   see        IsReady, Content
	def init()
		# stateless facade over the ggml inference backend.

	# TRUE if the ggml backend is compiled in and executes.
	def IsReady()
		return This.GgmlReady()

		def IsAvailable()
			return This.IsReady()

	# Returns the name of the inference backend that runs the models.
	#
	#   returns    a text, ggml (CPU) today
	#   see        IsReady, Content
	def Backend()
		return "ggml (CPU)"

	# Returns a snapshot of what the engine is: its backend, its ggml version and whether it is ready.
	#
	#   returns    a list of [ key, value ] pairs for backend, version and ready
	#   see        Show, Backend
	#@ aka  Content() = what the engine IS: its [key, value] snapshot (backend, version, readiness). Show() renders it (the Softanza Show = visualize Content rule).
	def Content()
		return [
			[ "backend", This.Backend() ],
			[ "version", This.GgmlVersion() ],
			[ "ready", This.IsReady() ]
		]

	# Prints one line that shows the engine's backend, version and readiness.
	#
	#   returns    the engine itself, so calls chain; it prints
	#   see        Content
	def Show()
		_aC_ = This.Content()
		? "stzNeuralEngine [ backend=" + _aC_[1][2] +
		  ", version=" + _aC_[2][2] + ", ready=" + _aC_[3][2] + " ]"
		return This
