#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V1.2) - STZNEURAL (NEURAL DOMAIN)   #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzNeural -- the MODERN / NEURAL domain.     #
#                  Facade over the vendored ggml (CPU-only)     #
#                  inference runtime (engine: stz_neural.dll).   #
#                  Unlike the classical @embedFile'd models,    #
#                  neural models load at RUNTIME from disk.      #
#                  Foundation for embeddings, semantic search,   #
#                  zero-shot, transformer NER, and (later)       #
#                  stzNeuralNetwork + trainable models.          #
#   Version      : V1.2 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

# StzNeural() / StzNeuralQ() -- the neural-domain object (ToStz-style constructor,
# returns the object). StzGgmlVersion() / StzNeuralReady() -- data-returning
# shortcuts to the runtime.

func StzNeural()
	return new stzNeural()

func StzNeuralQ()
	return new stzNeural()

func StzGgmlVersion()
	return StzEngineNeuralVersion()

func StzNeuralReady()
	return StzEngineNeuralSmoke() = 1

  /////////////////
 ///   CLASS   ///
/////////////////

class stzNeural

	def init()
		# stateless facade over the engine runtime; models are loaded lazily
		# (runtime, from disk) once embedding/inference lands.

	  #==========================================================#
	 #   RUNTIME (ggml)                                         #
	#==========================================================#

	# The vendored ggml build version string.
	def GgmlVersion()
		return StzEngineNeuralVersion()

		def RuntimeVersion()
			return This.GgmlVersion()

	# TRUE if the ggml runtime is compiled in and executes (smoke: context ->
	# tensor -> compute round-trip). Cheap liveness probe.
	def IsReady()
		return StzEngineNeuralSmoke() = 1

		def IsAvailable()
			return This.IsReady()

	# Backend / runtime snapshot as [key, value] data.
	def RuntimeInfo()
		return [
			[ "backend", "ggml (CPU)" ],
			[ "version", This.GgmlVersion() ],
			[ "ready", This.IsReady() ]
		]

	# Print the runtime snapshot; returns This for chaining.
	def ShowRuntime()
		? "Softanza neural runtime (ggml, CPU)"
		? "  version : " + This.GgmlVersion()
		? "  ready   : " + This.IsReady()
		return This

	#-- ROADMAP (next milestones, wired to the engine as they land):
	#   def LoadModelQ(cPath)         -> stzNeuralModel (GGUF, runtime-loaded)
	#   stzText.EmbeddingQ()          -> sentence embedding vector
	#   stzText.SemanticSimilarityWith(cOther)
	#   class stzNeuralNetwork ...    -> build/train networks
