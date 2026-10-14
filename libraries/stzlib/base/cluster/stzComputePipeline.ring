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

# Declares a workflow as a chain of facet stages, each transforming the running value, and runs inputs through the chain.
#
# A stage is a function tagged with the facet that handles it, so a document flow such as vision,
# nlp, knowledge, search is declared and not hand-wired. Run threads an input through every stage;
# RunBatch does it for many inputs. When a worker pool is attached with SetPool, each stage is
# admitted into its own facet's budget, so a heavy facet cannot starve a light one. A stage that
# raises stops the run and is reported by Failed and Why. The stages run in-process; running a stage
# on a fleet worker needs a worker that implements the facet.
#
#   receiver   o1 = new stzComputePipeline("doc-intake") o1.Stage("vision", "ocr", func x { return
#              StzReplace(x, "scan:", "") }) o1.Stage("nlp", "entities", func x { return x + "
#              [entities]" })
#   example    ? o1.Run("scan:acme invoice")
#              #--> acme invoice [entities]
#              ? o1.Narrate()
#              #--> pipeline doc-intake: vision -> nlp
#              ? o1.Failed()
#              #--> 0
#              ? @@( o1.ValidateAgainst(new stzFacetCatalog()) )
#              #--> [ ]
#   see        stzFacetCatalog, stzClusterSupervisor, stzClusterTelemetry
class stzComputePipeline from stzObject

	@cName = ""
	@aStages = []      # [ [ facet, stageName, fWork ], ... ]
	@oPool = ""      # optional: admit each stage into its facet's budget
	@aTrace = []       # [ [ facet, stageName, output, durMs ], ... ] from the
	                   # last Run -- each stage carries its COST (perf P3)
	@xLast = ""      # last final output
	@bFailed = 0   # did the last Run hit a failing stage?
	@cWhy = ""

	# Creates an empty pipeline of facet stages, under a name.
	#
	#   pcName     the pipeline's name, shown by Narrate
	#   returns    nothing; the object is built
	#   see        Stage, Run
	def init(pcName)
		@cName = "" + pcName

	# Returns the pipeline's name.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Appends a stage: a function that transforms the running value, tagged with the facet that handles it.
	#
	#   pcFacet       the facet that handles the stage, stored in lower case
	#   pcStageName   the stage's name, shown in traces and failures
	#   fWork         a function that takes the running value and returns the new one
	#   returns       the pipeline itself, so calls chain
	#   warning       stages run in the order they were added
	#   see           Run, ValidateAgainst
	#@ aka  -- declaring the pipeline --------------------------------------------
	def Stage(pcFacet, pcStageName, fWork)
		@aStages + [ StzLower("" + pcFacet), "" + pcStageName, fWork ]
		return This

	# Returns how many stages the pipeline holds.
	#
	#   returns    a number
	#   see        Stage, Stages
	def NumberOfStages()
		return len(@aStages)

	# Returns the facet of each stage, in order; a facet repeats when two stages share it.
	#
	#   returns    a list of texts
	#   see        Stages, ValidateAgainst
	#@ aka  The ordered facet sequence (the routing contract).
	def Facets()
		_a_ = []
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_a_ + @aStages[_i_][1]
		next
		return _a_

	# Returns the name of each stage, in order.
	#
	#   returns    a list of texts
	#   see        Facets, Trace
	def Stages()
		_a_ = []
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_a_ + @aStages[_i_][2]
		next
		return _a_

	# Attaches a worker pool, so that each stage is admitted into the budget of its facet before it runs.
	#
	#   poPool     an object that answers HasProfile(facet), Acquire(facet) and Release(facet), such
	#              as a stzWorkerPool
	#   returns    the pipeline itself, so calls chain
	#   warning    the pipeline keeps a copy of the pool object; a stage whose facet the pool has no
	#              profile for runs without admission
	#   see        PoolQ, Run
	#@ aka  Attach a worker pool so each stage is admitted into its facet's budget (load isolation across the pipeline; R8.1). Facets not in the pool run unbudgeted. NOTE: the pipeline works on ITS pool (Ring stores a copy) -- read metrics via PoolQ(), not the caller's original.
	def SetPool(poPool)
		@oPool = poPool
		return This

	# Returns the attached pool; an empty text when none was attached.
	#
	#   returns    the pool object
	#   see        SetPool
	def PoolQ()
		return @oPool

	# Returns the facets of the pipeline that a catalog does not know, each once, in order.
	#
	#   poCatalog   a stzFacetCatalog, or any object that answers Has(facet)
	#   returns     a list of texts; empty when every facet is known
	#   see         Facets, Run
	#@ aka  Check every stage's facet is offered by a catalog (the deployment's competences, R8.2). Returns [] when all known, else the unknown facets -- so a pipeline is validated against what a cluster can run.
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

	# Threads an input through every stage in order, each stage's output being the next stage's input, and returns the final value.
	#
	#   pInput     the value that enters the first stage
	#   returns    the final value; an empty text if a stage failed
	#   note       each stage is timed on the monotonic clock
	#   warning    a stage that raises stops the run: the output is empty, Failed answers TRUE and
	#              Why names the stage and the cause; a run replaces the trace of the one before
	#   see        RunBatch, Failed, Trace
	#@ aka  -- running ------------------------------------------------------------
	def Run(pInput)
		@aTrace = []
		@bFailed = 0
		@cWhy = ""
		_v_ = pInput
		_n_ = len(@aStages)
		for _i_ = 1 to _n_
			_cFacet_ = @aStages[_i_][1]
			_cName_ = @aStages[_i_][2]
			_fWork_ = @aStages[_i_][3]
			_bBudgeted_ = (@oPool != "" and @oPool.HasProfile(_cFacet_))
			if _bBudgeted_  @oPool.Acquire(_cFacet_)  ok
			# perf P3: each stage is timed on the monotonic clock -- the
			# bracket covers the work AND its budget admission overhead.
			_nT0_ = StzEngineWatchTimestampNs()
			_bOk_ = 1
			try
				_v_ = call _fWork_(_v_)
			catch
				_bOk_ = 0
				@cWhy = "stage '" + _cName_ + "' (" + _cFacet_ + ") failed: " + cCatchError
			done
			_nMs_ = (StzEngineWatchTimestampNs() - _nT0_) / 1000000
			if _bBudgeted_  @oPool.Release(_cFacet_)  ok   # release even on failure
			if NOT _bOk_
				@aTrace + [ _cFacet_, _cName_, "ERROR", _nMs_ ]
				@bFailed = 1
				@xLast = ""
				return ""
			ok
			@aTrace + [ _cFacet_, _cName_, _v_, _nMs_ ]
		next
		@xLast = _v_
		return _v_

	# TRUE if the last Run stopped because a stage raised.
	#
	#   returns    TRUE or FALSE
	#   see        Why, Run
	def Failed()
		return @bFailed

	# Returns the reason the last Run failed, naming the stage, its facet and the error; empty after a clean run.
	#
	#   returns    a text
	#   see        Failed
	def Why()
		return @cWhy

	# Runs a list of inputs one after the other through the whole pipeline and returns the outputs in the same order.
	#
	#   paInputs   the inputs to run, one value per item
	#   returns    a list of final values
	#   warning    the trace and the last output reflect the last input only
	#   see        Run
	#@ aka  Run many inputs through the WHOLE pipeline; returns a result list (same order). The trace reflects the LAST input.
	def RunBatch(paInputs)
		_aOut_ = []
		_n_ = len(paInputs)
		for _i_ = 1 to _n_
			_aOut_ + This.Run(paInputs[_i_])
		next
		return _aOut_

	# Returns what the last Run did, one [ facet, stage, value, ms ] list per stage; a failed stage shows ERROR in place of the value.
	#
	#   returns    a list of lists
	#   see        StageDurations, TotalMs
	def Trace()
		return @aTrace

	# Returns the cost of each stage of the last Run as [ stage, ms ] pairs.
	#
	#   returns    a list of lists
	#   see        TotalMs, Trace
	#@ aka  Per-stage costs from the last Run: [ [ stageName, durMs ], ... ]. The slowest stage is the pipeline's bottleneck candidate.
	def StageDurations()
		_a_ = []
		_n_ = len(@aTrace)
		for _i_ = 1 to _n_
			_a_ + [ @aTrace[_i_][2], @aTrace[_i_][4] ]
		next
		return _a_

	# Returns the total of the stage durations of the last Run, in milliseconds.
	#
	#   returns    a number
	#   see        StageDurations
	#@ aka  Total cost of the last Run (sum of its stage durations, ms).
	def TotalMs()
		_nSum_ = 0
		_n_ = len(@aTrace)
		for _i_ = 1 to _n_
			_nSum_ += @aTrace[_i_][4]
		next
		return _nSum_

	# Returns the final value of the last Run; empty after a failed run.
	#
	#   returns    the last value
	#   see        Run
	def LastOutput()
		return @xLast

	# Returns one line that gives the pipeline's name and its facets joined by arrows.
	#
	#   returns    a text
	#   see        Facets
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
