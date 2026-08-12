#---------------------------------------------------------------------------#
#  STZVECTORINDEX -- approximate nearest neighbours over a corpus of        #
#  vectors. The thing semantic search is built on.                          #
#---------------------------------------------------------------------------#
#
# The last integration gap the numeric retro named. The library already had
# EXACT k-NN (stzKnn, engine-backed) and that is the right answer for a few
# thousand vectors: it is O(n) per query. A corpus of a million embeddings costs
# a million distance computations to answer ONE question, which is why nobody
# runs semantic search that way.
#
# -- WHY APPROXIMATE, AND WHAT IS GIVEN UP --
#
# There is no exact nearest-neighbour structure that stays fast in high
# dimensions. kd-trees and ball trees decay to a full scan somewhere around 20
# dimensions and embeddings have hundreds; this is the curse of dimensionality,
# a theorem rather than a missing optimisation.
#
# So every practical vector index is APPROXIMATE -- it returns the true nearest
# neighbours most of the time and near ones otherwise. The honest way to ship
# that is to make the tradeoff visible instead of hiding it:
#
#     Search(query, k)                a sensible default budget
#     SearchWithBudget(query, k, n)   the dial, stated outright
#     SearchExact(query, k)           the full scan, for ground truth
#     RecallAgainstExact(...)         MEASURE what you are losing
#
# That last method is the point. An approximate index whose recall you have
# never measured is not a fast index, it is an unknown one -- so measuring is
# part of the surface, not an afterthought in a benchmark script.
#
# -- THE STRUCTURE --
#
# A forest of random projection trees (Annoy's algorithm). Each tree picks TWO
# POINTS AT RANDOM, splits its set by the hyperplane bisecting them, and
# recurses. Splitting on the bisector of two of the corpus's own points rather
# than on a random direction is what makes it work: the cut ADAPTS TO THE DATA.
#
# A single tree loses whatever falls on the far side of a split, so the trees
# are grown in a forest -- a neighbour missed in one is usually found in
# another. More trees, better recall, bigger index.
#
# Search walks all the trees at once, preferring the branches the query sits
# most confidently inside, until the candidate budget is spent -- then RERANKS
# THE CANDIDATES BY TRUE DISTANCE. So every distance reported is exact and the
# only possible error is an OMISSION, never a wrong number or a wrong order.
#
# -- EUCLIDEAN OR COSINE --
#
# Text embeddings are compared by direction, not length, so pass :Cosine and
# the corpus is unit-normalized at build time (and so is every query). For
# unit vectors the two orderings agree, because |a-b|^2 = 2 - 2*cos(a,b) falls
# as the cosine rises -- the same trick FAISS uses.

func StzVectorIndexQ(paVectors)
	return new stzVectorIndex(paVectors)

func StzVectorIndex(paVectors)
	return new stzVectorIndex(paVectors)

class stzVectorIndex from stzObject

	@pIndex = ""
	@nCount = 0
	@nDim = 0
	@nTrees = 10
	@cMetric = :Euclidean
	@nSeed = 42
	@aVectors = []

	# -- the G3 silent seam (SOFTANZA_GPU_PLAN.md) --
	# For a big enough :Euclidean corpus, SearchExact() runs its full scan on
	# the GPU: the corpus is uploaded ONCE (resident buffer), each query then
	# moves only d floats in and reads k pairs back -- d flops per byte, the
	# compute-dense shape G0 approved. Below the calibrated threshold, or in
	# :Cosine mode (the CPU index normalizes internally), or on any GPU
	# refusal, the CPU path answers exactly as before. Distances come back
	# f32 instead of f64 -- same squared-Euclidean contract, parity banded
	# by the seam guard.
	@nGpuCorpus_ = 0
	@nGpuQuery_ = 0
	@nGpuDist_ = 0
	@bGpuTried_ = 0

	# paVectors is a list of equal-length lists of numbers -- one row per vector.
	def init(paVectors)
		if NOT isList(paVectors) or len(paVectors) = 0
			StzRaise("stzVectorIndex: give me a non-empty list of vectors.")
		ok
		if NOT isList(paVectors[1])
			StzRaise("stzVectorIndex: each vector must itself be a list of numbers.")
		ok

		@aVectors = paVectors
		@nCount = len(paVectors)
		@nDim = len(paVectors[1])
		if @nDim = 0
			StzRaise("stzVectorIndex: the vectors have no dimensions.")
		ok
		_nL_ = @nCount
		for _i_ = 2 to _nL_
			if NOT isList(paVectors[_i_]) or len(paVectors[_i_]) != @nDim
				StzRaise("stzVectorIndex: vector " + _i_ + " has " +
					len(paVectors[_i_]) + " dimensions, not " + @nDim +
					" -- every vector must have the same width.")
			ok
		next

	# ---- configuration (before the first search) -------------------------

	# More trees means better recall at the same budget, and a bigger index.
	def SetTrees(n)
		if n < 1
			StzRaise("SetTrees: at least one tree.")
		ok
		@nTrees = n
		This._Drop()
		return This

	# :Euclidean compares positions, :Cosine compares directions. Text
	# embeddings almost always want :Cosine.
	def SetMetric(pcMetric)
		if pcMetric != :Euclidean and pcMetric != :Cosine
			StzRaise("SetMetric: :Euclidean or :Cosine.")
		ok
		@cMetric = pcMetric
		This._Drop()
		return This

	# The forest is random; the seed makes it reproducible, so a recall figure
	# is a property of the code and not of the run that produced it.
	def SetSeed(n)
		@nSeed = n
		This._Drop()
		return This

	def Trees()
		return @nTrees

	def Metric()
		return @cMetric

	def Count()
		return @nCount

	def Dimensions()
		return @nDim

	# ---- searching -------------------------------------------------------

	# The k nearest neighbours, as [ [index, distance], ... ], nearest first.
	# Indexes are 1-based into the vectors this index was built from.
	#
	# The distance is SQUARED Euclidean over the stored vectors -- squared
	# because the square root changes nothing about the ordering and costs a
	# call per candidate. In :Cosine mode the vectors are unit-length, so the
	# distance is 2 - 2*cos and CosineSimilarityTo() reads it back as a cosine.
	def Search(paQuery, nK)
		return This._Query(paQuery, nK, 0, 0)

		def Nearest(paQuery, nK)
			return This.Search(paQuery, nK)

	# The same, with the candidate budget stated. Bigger budget, better recall,
	# more work. 0 asks for the default.
	def SearchWithBudget(paQuery, nK, nBudget)
		return This._Query(paQuery, nK, nBudget, 0)

	# The exact answer by full scan -- O(n) and the ground truth. Use it on a
	# small corpus, or to measure what the approximate path is missing.
	def SearchExact(paQuery, nK)
		return This._Query(paQuery, nK, 0, 1)

		def NearestExact(paQuery, nK)
			return This.SearchExact(paQuery, nK)

	# RECALL@K over a set of queries: the fraction of the true k nearest
	# neighbours that the approximate search actually returned. 1.0 means it
	# missed nothing.
	#
	# THIS IS THE METHOD THAT MAKES THE INDEX HONEST. Measure it on your own
	# vectors before trusting a budget -- recall depends on the data, not just
	# on the settings, and no default can promise a number.
	def RecallAgainstExact(paQueries, nK, nBudget)
		if NOT isList(paQueries) or len(paQueries) = 0
			StzRaise("RecallAgainstExact: give me a non-empty list of queries.")
		ok
		This._Ensure()
		_aFlat_ = []
		_nQ_ = len(paQueries)
		for _i_ = 1 to _nQ_
			if NOT isList(paQueries[_i_]) or len(paQueries[_i_]) != @nDim
				StzRaise("RecallAgainstExact: query " + _i_ + " is not " + @nDim +
					" number(s) wide.")
			ok
			for _d_ = 1 to @nDim
				_aFlat_ + paQueries[_i_][_d_]
			next
		next
		_nR_ = StzEngineAnnRecall(@pIndex, _aFlat_, _nQ_, nK, nBudget)
		if _nR_ < 0
			StzRaise("RecallAgainstExact: the engine refused the measurement.")
		ok
		return _nR_

	# Cosine similarity of a stored vector to a query, recovered from the
	# stored distance. Only meaningful in :Cosine mode, where both are unit
	# vectors and d^2 = 2 - 2*cos.
	def CosineFromDistance(nDist)
		if @cMetric != :Cosine
			StzRaise("CosineFromDistance: only meaningful for a :Cosine index.")
		ok
		return 1 - nDist / 2

	# ---- internals -------------------------------------------------------

	def _Query(paQuery, nK, nBudget, bExact)
		if NOT isList(paQuery) or len(paQuery) != @nDim
			StzRaise("stzVectorIndex: the query must be a list of " + @nDim +
				" numbers.")
		ok
		if nK < 1
			StzRaise("stzVectorIndex: ask for at least one neighbour.")
		ok
		This._Ensure()

		# the silent seam: an exact scan on a resident GPU corpus. Any
		# refusal (evicted buffer, lost device) falls through to the CPU
		# path below -- same answer, later.
		if bExact and @nGpuCorpus_ > 0
			_aG_ = This._QueryGpu(paQuery, nK)
			if isList(_aG_)
				return _aG_
			ok
		ok

		if bExact
			_aFlat_ = StzEngineAnnSearchExact(@pIndex, paQuery, nK)
		else
			_aFlat_ = StzEngineAnnSearch(@pIndex, paQuery, nK, nBudget)
		ok
		if NOT isList(_aFlat_)
			StzRaise("stzVectorIndex: the search failed on this query.")
		ok

		_aOut_ = []
		_nP_ = len(_aFlat_) / 2
		for _i_ = 1 to _nP_
			# the engine indexes from 0; Ring lists start at 1
			_aOut_ + [ _aFlat_[(_i_ - 1) * 2 + 1] + 1,
			           _aFlat_[(_i_ - 1) * 2 + 2] ]
		next
		return _aOut_

	def _Ensure()
		if @pIndex != ""
			return
		ok
		_aFlat_ = []
		_nR_ = @nCount
		for _i_ = 1 to _nR_
			_aRow_ = @aVectors[_i_]
			for _j_ = 1 to @nDim
				_aFlat_ + _aRow_[_j_]
			next
		next
		_bCos_ = 0
		if @cMetric = :Cosine
			_bCos_ = 1
		ok
		@pIndex = StzEngineAnnBuild(_aFlat_, @nCount, @nDim, @nTrees, _bCos_, @nSeed)
		if @pIndex = ""
			StzRaise("stzVectorIndex: the index could not be built.")
		ok
		This._EnsureGpu(_aFlat_)

	# Decide ONCE per build whether this corpus earns a resident GPU copy.
	# The decision is the calibration store's (threshold on nCount*nDim,
	# seeded conservatively from G0's floors if nobody calibrated); the
	# residency investment is build-time, so the gate is build-time too --
	# once the corpus is resident, every exact query uses it.
	def _EnsureGpu(paFlat)
		if @bGpuTried_
			return
		ok
		@bGpuTried_ = 1
		if @cMetric != :Euclidean
			# the CPU index normalizes :Cosine rows internally; the raw
			# vectors here would compute the WRONG distances. CPU keeps.
			return
		ok
		# the threshold is consulted BEFORE the device: Init() costs ~300 ms
		# of adapter/device creation, and a small corpus must never pay it.
		# Order of authority: an already-set value > the persisted
		# calibration (the default file loads without a device) > the
		# conservative G0 seed. A real Calibrate() pass replaces the seed.
		_nThresh_ = StzEngineGpuCalibGet("pairdist")
		if _nThresh_ = 0
			StzGpuLoadCalibrationDefault()
			_nThresh_ = StzEngineGpuCalibGet("pairdist")
		ok
		if _nThresh_ = 0
			_nThresh_ = 4000000
			StzEngineGpuCalibSet("pairdist", _nThresh_)
		ok
		if @nCount * @nDim < _nThresh_
			return
		ok
		if StzEngineGpuIsAvailable() = 0
			StzEngineGpuInit($cStzGpuRuntime)
		ok
		if StzEngineGpuIsAvailable() = 1
			# per-adapter truth may refine the default-file threshold
			StzGpuLoadCalibrationForAdapter()
		ok
		# the canonical gate has the final say (device present + threshold)
		if StzEngineGpuShouldDispatch("pairdist", @nCount * @nDim) = 0
			return
		ok
		@nGpuCorpus_ = StzEngineGpuBufferNew(@nCount * @nDim * 4)
		if @nGpuCorpus_ = 0
			return
		ok
		if StzEngineGpuBufferUploadList(@nGpuCorpus_, paFlat) != 0
			This._DropGpu()
			return
		ok
		@nGpuQuery_ = StzEngineGpuBufferNew(@nDim * 4)
		@nGpuDist_ = StzEngineGpuBufferNew(@nCount * 4)
		if @nGpuQuery_ = 0 or @nGpuDist_ = 0
			This._DropGpu()
		ok

	# One exact query on the resident corpus: query up (d floats), pairdist
	# (1 x nCount), top-k selected ENGINE-side (a Ring-side scan of the
	# distance vector would eat the win). NULL on any refusal -> CPU path.
	def _QueryGpu(paQuery, nK)
		if StzEngineGpuBufferUploadList(@nGpuQuery_, paQuery) != 0
			This._DropGpu()
			return ""
		ok
		if StzEngineGpuOpPairDist(@nGpuQuery_, @nGpuCorpus_, @nGpuDist_, 1, @nCount, @nDim) != 0
			This._DropGpu()
			return ""
		ok
		_aFlat_ = StzEngineGpuOpTopK(@nGpuDist_, @nCount, nK)
		if _aFlat_[1] != 0
			This._DropGpu()
			return ""
		ok
		_aOut_ = []
		_nP_ = (len(_aFlat_) - 1) / 2
		for _i_ = 1 to _nP_
			# engine indices are 0-based; Ring lists start at 1
			_aOut_ + [ _aFlat_[(_i_ - 1) * 2 + 2] + 1,
			           _aFlat_[(_i_ - 1) * 2 + 3] ]
		next
		return _aOut_

	def _DropGpu()
		# frees the device buffers; leaves @bGpuTried_ alone -- after a
		# runtime refusal the index stays CPU (no thrash); a config change
		# via _Drop() re-opens the question.
		if @nGpuCorpus_ > 0
			StzEngineGpuBufferFree(@nGpuCorpus_)
			@nGpuCorpus_ = 0
		ok
		if @nGpuQuery_ > 0
			StzEngineGpuBufferFree(@nGpuQuery_)
			@nGpuQuery_ = 0
		ok
		if @nGpuDist_ > 0
			StzEngineGpuBufferFree(@nGpuDist_)
			@nGpuDist_ = 0
		ok

	def _Drop()
		if @pIndex != ""
			StzEngineAnnFree(@pIndex)
			@pIndex = ""
		ok
		This._DropGpu()
		@bGpuTried_ = 0
