#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZNEURALMODEL                 #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzNeuralModel -- an instantiable NEURAL      #
#                  MODEL loaded at RUNTIME from a GGUF file       #
#                  (e.g. a BERT sentence-embedding model like     #
#                  all-MiniLM-L6-v2). Unlike the classical         #
#                  @embedFile'd tables, neural models are large    #
#                  and load from disk. Exposes the model's          #
#                  architecture + hyperparameters; (next milestone) #
#                  its embedding forward pass.                       #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# StzNeuralModel(cPath) / StzNeuralModelQ(cPath) -- construct a model object and
# load the GGUF at cPath (constructor globals: both return the object).
func StzNeuralModel(pcPath)
	return new stzNeuralModel(pcPath)

func StzNeuralModelQ(pcPath)
	return new stzNeuralModel(pcPath)

class stzNeuralModel from stzNeural

	@cPath = ""

	def init(pcPath)
		if isString(pcPath) and pcPath != ""
			This.LoadFrom(pcPath)
		ok

	  #==========================================================#
	 #   LOAD / UNLOAD (runtime GGUF)                           #
	#==========================================================#
	# (Named LoadFrom, not Load -- "Load" collides with Ring's load keyword.)
	def LoadFrom(pcPath)
		if NOT isString(pcPath) return FALSE ok
		@cPath = pcPath
		return StzEngineNeuralModelLoad(pcPath) = 1

		def Open(pcPath)
			return This.LoadFrom(pcPath)

	def IsLoaded()
		return StzEngineNeuralModelLoaded() = 1

	def Unload()
		StzEngineNeuralModelFree()
		@cPath = ""
		return This

	def Path()
		return @cPath

	  #==========================================================#
	 #   ARCHITECTURE + HYPERPARAMETERS                         #
	#==========================================================#
	def Arch()
		return StzEngineNeuralModelArch()

		def Architecture()
			return This.Arch()

	def EmbeddingDim()
		return StzEngineNeuralModelNEmbd()

	def NumberOfLayers()
		return StzEngineNeuralModelNLayers()

	def NumberOfHeads()
		return StzEngineNeuralModelNHeads()

	def ContextLength()
		return StzEngineNeuralModelNCtx()

	def VocabSize()
		return StzEngineNeuralModelNVocab()

	def NumberOfTensors()
		return StzEngineNeuralModelNTensors()

	# Content() = what the model IS: its architecture + hyperparameters as
	# [key, value] data. Show() renders it (Softanza Show = visualize Content).
	def Content()
		return [
			[ "arch", This.Arch() ],
			[ "embedding_dim", This.EmbeddingDim() ],
			[ "layers", This.NumberOfLayers() ],
			[ "heads", This.NumberOfHeads() ],
			[ "context_length", This.ContextLength() ],
			[ "vocab_size", This.VocabSize() ],
			[ "tensors", This.NumberOfTensors() ]
		]

		def Info()
			return This.Content()

	def Show()
		if NOT This.IsLoaded()
			? "stzNeuralModel [ not loaded ]"
			return This
		ok
		? "stzNeuralModel [ " + This.Arch() +
		  "  dim=" + This.EmbeddingDim() +
		  "  layers=" + This.NumberOfLayers() +
		  "  vocab=" + This.VocabSize() + " ]"
		return This

	#-- ROADMAP (next milestone): the forward pass.
	#   def EmbeddingOf(cText)   -> sentence-embedding vector (list of floats)
	#   Then stzText.EmbeddingQ() / SemanticSimilarityWith() use a stzNeuralModel.
