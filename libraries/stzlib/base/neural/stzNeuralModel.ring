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

		  #==========================================================#
		 #   FORWARD PASS -- sentence embeddings                    #
		#==========================================================#
		# EmbeddingOf(cText) -- run the BERT forward pass (embeddings + N
		# transformer layers + mean-pool + L2-normalize) and return the
		# sentence-embedding vector as a list of EmbeddingDim() floats (DATA).
		def EmbeddingOf(pcText)
			if NOT isString(pcText) return [] ok
			nDim = StzEngineNeuralEmbed(pcText)
			if nDim = 0 return [] ok
			aVec = []
			for i = 0 to nDim - 1
				aVec + StzEngineNeuralEmbedAt(i)
			next
			return aVec

			def Embedding(pcText)
				return This.EmbeddingOf(pcText)

		# WordPiece token ids for cText (with [CLS]..[SEP]) -- DATA.
		def Tokenize(pcText)
			if NOT isString(pcText) return [] ok
			nCount = StzEngineNeuralTokenize(pcText)
			aIds = []
			for i = 0 to nCount - 1
				aIds + StzEngineNeuralTokenAt(i)
			next
			return aIds

		# Cosine similarity of two texts' embeddings, in [-1, 1] (DATA). The
		# vectors are already L2-normalized, so cosine = dot product.
		def SemanticSimilarityBetween(pcA, pcB)
			aA = This.EmbeddingOf(pcA)
			aB = This.EmbeddingOf(pcB)
			nLen = len(aA)
			if nLen = 0 or len(aB) != nLen return 0 ok
			nDot = 0
			for i = 1 to nLen
				nDot += aA[i] * aB[i]
			next
			return nDot
