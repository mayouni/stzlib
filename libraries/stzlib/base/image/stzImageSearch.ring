#=====================================================================#
#  STZIMAGESEARCH -- pictures and words in ONE space (IM5 of         #
#  SOFTANZA_IMAGE_INTELLIGENCE.md)                                   #
#=====================================================================#
/*
	SigLIP2 (Google, base patch16-224, Apache-2.0) has two towers: one
	turns a picture into 768 numbers, the other turns a text into 768
	numbers, and both land in the same space. The cosine between a
	picture's vector and a text's vector says how well the words describe
	the picture. That one fact gives three faculties, none of which needs
	a list of classes fixed in advance:

	  oImg.ClassifyAs([ "a dog", "a cat", "a car" ])   the caller's own labels
	  oImg.SimilarityTo("people crossing a street")    one picture, one text
	  oIndex.Search("a red bus")                       many pictures, one text

	Both towers run on ggml (stz_neural, engine/src/vision.zig), converted
	from ONNX by engine/tools/onnx_to_gguf.py; the text tower's Gemma
	tokenizer (256,000 tokens, 580,604 merges) travels inside its GGUF and
	runs in engine/src/bpe.zig. Every model call goes through the vision
	door (stzVision.ring) and is recorded in the security ledger.

	A SCORE HERE IS A COSINE, NOT A PROBABILITY. SigLIP2 turns a cosine
	into a probability with a learned scale and bias that the tower files
	do not carry, so the plane reports the cosine and ranks by it. Between
	pictures and texts it is small in absolute terms (about 0.05 to 0.20);
	what carries meaning is the ORDER, and the gap between the first and
	the second answer.
*/

$cStzVisionImageEmbedder = "siglip2_vision.gguf"
$cStzVisionTextEmbedder = "siglip2_text.gguf"

# The prompt a bare label is put into before it is embedded: SigLIP's own template, as HF's
# zero-shot pipeline writes it. Fixed before any measurement, never tuned on a golden set.
$cStzVisionLabelPrompt = "This is a photo of {}."

# the text embeddings already computed in this process: the same words never cross the model twice
$acStzVisionTextSeen = []
$aStzVisionTextVectors = []

# The 768 numbers SigLIP2 gives a text, L2-normalized (so a dot product with a picture's IS the cosine).
func StzVisionTextEmbedding(pcText)
	_c_ = "" + pcText
	_n_ = len($acStzVisionTextSeen)
	for _i_ = 1 to _n_
		if $acStzVisionTextSeen[_i_] = _c_
			return $aStzVisionTextVectors[_i_]
		ok
	next
	_cP_ = _StzVisionModelOrRaise($cStzVisionTextEmbedder, "TextEmbedding")
	_a_ = StzEngineNeuralVisionEmbedText(_cP_, _c_, 4)
	if len(_a_) = 0
		_StzVisionFailed("TextEmbedding", $cStzVisionTextEmbedder)
	ok
	_StzVisionDoor("embed-text", $cStzVisionTextEmbedder, "" + len(_a_) + " numbers for " + StzLen(_c_) + " characters")
	$acStzVisionTextSeen + _c_
	$aStzVisionTextVectors + _a_
	return _a_

# The token ids the text tower reads for a text: Gemma's BPE, then <eos> (1), then <pad> (0) up to 64.
func StzVisionTokens(pcText)
	_cP_ = _StzVisionModelOrRaise($cStzVisionTextEmbedder, "Tokens")
	return StzEngineNeuralVisionTokens(_cP_, "" + pcText)

# The cosine of two embeddings (both L2-normalized, so it is their dot product).
func StzVisionCosine(paA, paB)
	_n_ = len(paA)
	if _n_ != len(paB)
		stzraise("StzVisionCosine: the two embeddings differ in length (" + _n_ + " and " + len(paB) + ").")
	ok
	_d_ = 0
	for _i_ = 1 to _n_
		_d_ += paA[_i_] * paB[_i_]
	next
	return _d_

# A label put into the prompt: "a dog" -> "This is a photo of a dog."
func StzVisionLabelPrompt(pcLabel)
	return StzReplace($cStzVisionLabelPrompt, "{}", "" + pcLabel)

# A picture's embedding from a stzImage or a file path (a path is opened and released here).
func _StzVisionEmbeddingOf(pImage)
	if isObject(pImage)
		return pImage.Embedding()
	ok
	_o_ = StzImageQ("" + pImage)
	_a_ = _o_.Embedding()
	_o_.Release()
	return _a_

# [ [ :label, :score ], ... ] best first: each label scored against one picture embedding.
func _StzVisionRankLabels(paVector, paLabels, pcPrompt)
	_aOut_ = []
	_n_ = len(paLabels)
	for _i_ = 1 to _n_
		_cT_ = StzReplace(pcPrompt, "{}", "" + paLabels[_i_])
		_aOut_ + [ :label = paLabels[_i_], :score = StzVisionCosine(paVector, StzVisionTextEmbedding(_cT_)) ]
	next
	return _StzVisionByScore(_aOut_)

# a list of [ ..., :score = n ] rows, highest score first
func _StzVisionByScore(paRows)
	_aK_ = []
	_n_ = len(paRows)
	for _i_ = 1 to _n_
		_aK_ + [ paRows[_i_][:score], _i_ ]
	next
	_aK_ = sort(_aK_, 1)
	_aOut_ = []
	for _i_ = _n_ to 1 step -1
		_aOut_ + paRows[_aK_[_i_][2]]
	next
	return _aOut_

#---------------------------------------------------------------------#
#  STZIMAGEINDEX -- many pictures, searched by words or by a picture   #
#---------------------------------------------------------------------#
# The storing and the ranking are stzSemanticIndex's (base/neural): the
# vectors resident in the engine, an exact top-k, the cosine read back from
# the unit-vector distance. This class only turns pictures and words into
# SigLIP2 vectors and hands them over -- one search path in the library.

func StzImageIndexQ()
	return new stzImageIndex

class stzImageIndex from stzObject

	@oIndex = new stzSemanticIndex([])

	# Adds a picture under a name: a stzImage, or the path of an image file (the name may be "": the path).
	#
	#   note       the picture is embedded once, here; searching never runs the image tower again
	def AddImage(pImage, pcName)
		_c_ = "" + pcName
		if _c_ = "" and isString(pImage)
			_c_ = pImage
		ok
		if _c_ = ""
			stzraise("stzImageIndex.AddImage: give a name to a picture that is not a file.")
		ok
		@oIndex.AddEmbedded(_c_, _StzVisionEmbeddingOf(pImage))

		def AddImageQ(pImage, pcName)
			This.AddImage(pImage, pcName)
			return This

	# Adds every image file of a list of paths, each under its own path.
	def AddImages(pacPaths)
		_n_ = len(pacPaths)
		for _i_ = 1 to _n_
			This.AddImage(pacPaths[_i_], pacPaths[_i_])
		next

		def AddImagesQ(pacPaths)
			This.AddImages(pacPaths)
			return This

	# Returns the number of pictures the index holds.
	#
	#   returns    a number, 0 for an empty index
	#   see        Names, AddImage
	def NumberOfImages()
		return @oIndex.Count()

	# Returns the names the pictures were added under, as the underlying semantic index lists them.
	#
	#   returns    a list of strings, one per picture (a file's path when it was added without a name)
	#   see        NumberOfImages, AddImage
	def Names()
		return @oIndex.Texts()

	# Returns the pictures ranked by how well a text describes them, best first.
	#
	#   pcText     the words to look for, used as written
	#   returns    a list of [ :name = n, :score = s ] rows, all pictures, [] for an empty index
	#   note       the text is used as written -- a sentence, a phrase, a word, in any language the
	#              tokenizer covers; a score is a cosine (see the header), the ORDER is the answer
	#   see        SearchXT, SearchLike
	def Search(pcText)
		return This._Ranked(StzVisionTextEmbedding(pcText), 0)

	def SearchXT(pcText, pnHowMany)
		return This._Ranked(StzVisionTextEmbedding(pcText), pnHowMany)

	# Returns the pictures ranked by how much they resemble another picture, best first.
	#
	#   pImage     a stzImage or the path of an image file
	#   returns    a list of [ :name = n, :score = s ] rows, all pictures, [] for an empty index
	#   see        SearchLikeXT, Search
	def SearchLike(pImage)
		return This._Ranked(_StzVisionEmbeddingOf(pImage), 0)

	def SearchLikeXT(pImage, pnHowMany)
		return This._Ranked(_StzVisionEmbeddingOf(pImage), pnHowMany)

	def _Ranked(paVector, pnHowMany)
		_n_ = @oIndex.Count()
		if _n_ = 0
			return []
		ok
		if pnHowMany > 0 and pnHowMany < _n_
			_n_ = pnHowMany
		ok
		_aHits_ = @oIndex.SearchByVectorXT(paVector, _n_)
		_aOut_ = []
		_m_ = len(_aHits_)
		for _i_ = 1 to _m_
			_aOut_ + [ :name = _aHits_[_i_][1], :score = _aHits_[_i_][2] ]
		next
		return _aOut_
