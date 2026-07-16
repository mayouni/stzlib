# base/cluster/stzComputePipeline.ring
# -----------------------------------------------------------------------------
# R8.5 (the SCALE plane) -- stzComputePipeline: COMPUTATIONAL PIPELINES.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.)
#
# A complex enterprise workflow becomes a chain of FACET stages: each
# stage transforms the running value and is tagged with the FACET that
# handles it, so the doc's document pipeline
#   VISION (ocr) -> NLP (entities) -> KNOWLEDGE (compliance) -> SEARCH (index)
# is declared, not hand-wired. Run() threads an input through every stage
# in order (each stage's output is the next stage's input); when a worker
# POOL is attached, each stage is admitted into ITS facet's budget (the
# R8.1 load-isolation mechanism, applied per stage), so a heavy vision
# stage never starves a light nlp stage. RunBatch() fans many inputs
# through the same pipeline.
#
#   oPipe = new stzComputePipeline("doc-intake")
#   oPipe.Stage(:vision, "ocr",        func x { return StzReplace(x, "scan:", "") })
#        .Stage(:nlp,    "entities",   func x { return x + " [entities]" })
#        .Stage(:knowledge, "comply",  func x { return x + " [compliant]" })
#        .Stage(:search, "index",      func x { return x + " [indexed]" })
#   ? oPipe.Run("scan:acme invoice")   #--> "acme invoice [entities] [compliant] [indexed]"
#   ? oPipe.Facets()                   #--> [ vision, nlp, knowledge, search ]
#
# DISTRIBUTED NOTE: with UsingPool the stages dispatch through the in-
# process facet budgets (deterministic floor). Running a stage on a fleet
# WORKER PROCESS (R8.3) requires that worker to implement the facet's
# transform (app-specific) -- the pipeline routes to it via oCluster.
# Route(facet, ...); the facet tags are the routing contract.
# -----------------------------------------------------------------------------

func StzComputePipelineQ(pcName)
	return new stzComputePipeline(pcName)

class stzComputePipeline from stzObject

	@cName = ""
	@aStages = []      # [ [ facet, stageName, fWork ], ... ]
	@oPool = NULL      # optional: admit each stage into its facet's budget
	@aTrace = []       # [ [ facet, stageName, output ], ... ] from the last Run
	@xLast = NULL      # last final output
	@bFailed = FALSE   # did the last Run hit a failing stage?
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	#-- declaring the pipeline --------------------------------------------

	# Add a stage: fWork(input) -> output, handled by the FACET pcFacet.
	def Stage(pcFacet, pcStageName, fWork)
		@aStages + [ StzLower("" + pcFacet), "" + pcStageName, fWork ]
		return This

	def NumberOfStages()
		return len(@aStages)

	# The ordered facet sequence (the routing contract).
	def Facets()
		_a_ = []
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_a_ + @aStages[_i_][1]
		next
		return _a_

	def Stages()
		_a_ = []
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_a_ + @aStages[_i_][2]
		next
		return _a_

	# Attach a worker pool so each stage is admitted into its facet's
	# budget (load isolation across the pipeline; R8.1). Facets not in the
	# pool run unbudgeted. NOTE: the pipeline works on ITS pool (Ring stores
	# a copy) -- read metrics via PoolQ(), not the caller's original.
	def UsingPool(poPool)
		@oPool = poPool
		return This

	def PoolQ()
		return @oPool

	# Check every stage's facet is offered by a catalog (the deployment's
	# competences, R8.2). Returns [] when all known, else the unknown
	# facets -- so a pipeline is validated against what a cluster can run.
	def ValidateAgainst(poCatalog)
		_aUnknown_ = []
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			if NOT poCatalog.Has(@aStages[_i_][1])
				if ring_find(_aUnknown_, @aStages[_i_][1]) = 0
					_aUnknown_ + @aStages[_i_][1]
				ok
			ok
		next
		return _aUnknown_

	#-- running ------------------------------------------------------------

	# Thread pInput through every stage in order; each stage's output feeds
	# the next. Returns the final output. Records a per-stage trace. A stage
	# that RAISES is CONTAINED: the failure is traced, the facet slot is
	# released (no leak), the pipeline HALTS and returns NULL, and Why()/
	# Failed() explain -- one bad stage never crashes the whole pipeline.
	def Run(pInput)
		@aTrace = []
		@bFailed = FALSE
		@cWhy = ""
		_v_ = pInput
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_cFacet_ = @aStages[_i_][1]
			_cName_ = @aStages[_i_][2]
			_fWork_ = @aStages[_i_][3]
			_bBudgeted_ = (@oPool != NULL and @oPool.HasProfile(_cFacet_))
			if _bBudgeted_  @oPool.Acquire(_cFacet_)  ok
			_bOk_ = TRUE
			try
				_v_ = call _fWork_(_v_)
			catch
				_bOk_ = FALSE
				@cWhy = "stage '" + _cName_ + "' (" + _cFacet_ + ") failed: " + cCatchError
			done
			if _bBudgeted_  @oPool.Release(_cFacet_)  ok   # release even on failure
			if NOT _bOk_
				@aTrace + [ _cFacet_, _cName_, "ERROR" ]
				@bFailed = TRUE
				@xLast = NULL
				return NULL
			ok
			@aTrace + [ _cFacet_, _cName_, _v_ ]
		next
		@xLast = _v_
		return _v_

	def Failed()
		return @bFailed

	def Why()
		return @cWhy

	# Run many inputs through the WHOLE pipeline; returns a result list
	# (same order). The trace reflects the LAST input.
	def RunBatch(paInputs)
		_aOut_ = []
		_n_ = len(paInputs)
		for _i_ = 1 to _n_
			_aOut_ + This.Run(paInputs[_i_])
		next
		return _aOut_

	def Trace()
		return @aTrace

	def LastOutput()
		return @xLast

	def Narrate()
		_cR_ = "pipeline " + @cName + ": " + This._Join(This.Facets(), " -> ")
		return _cR_

	#-- internals ----------------------------------------------------------

	def _Join(paList, cSep)
		_cR_ = ""
		_n_ = len(paList)
		for _i_ = 1 to _n_
			_cR_ += "" + paList[_i_]
			if _i_ < _n_  _cR_ += cSep  ok
		next
		return _cR_
