/*
	stzMetricFamily -- labels and dimensions (perf P8).

	One metric name + declared label names; each distinct label-value
	combination is a CHILD metric with its own engine stores:

		oF = StzMetricFamily("http.checkout.ms", :Timer, ["route", "method"])
		oF.Child(["/menu", "GET"]).Record(12.5)
		oF.Child(["/pay",  "POST"]).Record(48)
		? oF.Child(["/menu", "GET"]).P95()      # per-route percentiles
		? oF.ChildCount()                        #--> 2

	THE DESIGN POINT: the child REGISTRY lives in the ENGINE (the
	same copy-proof rule as every perf store). Children are created
	dynamically -- a route first hit AFTER the server copied its
	monitor -- and every Ring face resolving the same label values
	reaches the SAME engine stores. A Ring-side registry would fork
	per copy; the engine one cannot. (Each face keeps a small
	reconstruction CACHE of child wrapper objects -- derived state,
	rebuilt on miss, never the truth.)

	CARDINALITY IS BOUNDED BY DESIGN. The field's label systems
	explode when a label value is unbounded (user ids in a route...);
	a Softanza family takes max_children at birth and, when full,
	routes new label sets to a reserved OVERFLOW child (every label
	"_overflow") -- data is never silently dropped, and the exposition
	shows the overflow bucket growing, which is itself the alarm.

	Exposition: one Prometheus TYPE header, one sample line per child
	with `{label="value"}` blocks (quantiles merged for timers); one
	OTLP metric with one data point per child, labels as attributes.

	Label values are sanitized at Child(): '|' (the key separator)
	folds to '_'. An SLA judges CHILDREN, not the family -- asking the
	family for a single value refuses with that guidance.

	Engine handle: Destroy() frees the family AND every child.
*/

func StzMetricFamily(pcName, pcKind, paLabelNames)
	return new stzMetricFamily(pcName, pcKind, paLabelNames, 1024, 64)

# The extended form: per-child window capacity + the cardinality bound.
func StzMetricFamilyXT(pcName, pcKind, paLabelNames, pnWindow, pnMaxChildren)
	return new stzMetricFamily(pcName, pcKind, paLabelNames, pnWindow, pnMaxChildren)

class stzMetricFamily from stzObject

	@cName = ""
	@cKind = ""
	@cHelp = ""
	@aLabelNames = []
	@nWindow = 1024
	@nMaxChildren = 64
	pFamily = ""
	bReady = 0
	@aChildCache = []	# per-face [ key, oMetric ] -- derived, rebuilt on miss

	def init(pcName, pcKind, paLabelNames, pnWindow, pnMaxChildren)
		@cName = "" + pcName
		_cK_ = StzLower("" + pcKind)
		if _cK_ != "counter" and _cK_ != "gauge" and _cK_ != "timer"
			stzraise("stzMetricFamily: kind must be :Counter, :Gauge or :Timer (got '" + _cK_ + "').")
		ok
		@cKind = _cK_
		if NOT isList(paLabelNames) or ring_len(paLabelNames) = 0
			stzraise("stzMetricFamily: label names must be a non-empty list (a family WITHOUT labels is a plain stzMetric).")
		ok
		@aLabelNames = paLabelNames
		if isNumber(pnWindow) and pnWindow >= 1
			@nWindow = pnWindow
		ok
		if isNumber(pnMaxChildren) and pnMaxChildren >= 2
			@nMaxChildren = pnMaxChildren
		ok
		# EAGER handle materialization (the copy law): the family's
		# engine registry exists before any copy can be taken.
		_nKindCode_ = 0
		if @cKind = "gauge"
			_nKindCode_ = 1
		but @cKind = "timer"
			_nKindCode_ = 2
		ok
		pFamily = StzEnginePerfFamilyCreate(_nKindCode_, @nWindow, @nMaxChildren)
		bReady = 1
		# RESERVE the overflow child now (eager, before any copy): a
		# full family must still have somewhere to route new label
		# sets -- an overflow created on demand would find no room.
		# max_children therefore includes this slot (usable = max - 1).
		This._ChildByKey(This._JoinKey(This._OverflowVals()), This._OverflowVals())

	def Name()
		return @cName

	def Kind()
		return @cKind

	def IsFamily()
		return 1

	def LabelNames()
		return @aLabelNames

	def MaxChildren()
		return @nMaxChildren

	def SetHelp(pcText)
		@cHelp = "" + pcText
		return This

	def Help()
		return @cHelp

	# -- Children -------------------------------------------------

	# The child for these label values (declared order). Creates it on
	# first sight; a FULL family routes new label sets to the overflow
	# child instead of dropping data.
	def Child(paValues)
		if NOT isList(paValues) or ring_len(paValues) != ring_len(@aLabelNames)
			stzraise("stzMetricFamily '" + @cName + "': Child() takes " +
				ring_len(@aLabelNames) + " value(s), one per label (" +
				This._JoinNames() + ").")
		ok
		_aVals_ = []
		_nLen_ = ring_len(paValues)
		for _i_ = 1 to _nLen_
			_aVals_ + StzReplace("" + paValues[_i_], "|", "_")
		next
		_cKey_ = This._JoinKey(_aVals_)
		if StzEnginePerfFamilyCanAdd(pFamily, _cKey_) = 0
			# full + new: the overflow child (every label "_overflow")
			_aVals_ = []
			for _i_ = 1 to ring_len(@aLabelNames)
				_aVals_ + "_overflow"
			next
			_cKey_ = This._JoinKey(_aVals_)
		ok
		return This._ChildByKey(_cKey_, _aVals_)

	# How many distinct children exist (engine truth, all faces agree).
	def ChildCount()
		return StzEnginePerfFamilySize(pFamily)

	# The children's keys, creation order (values joined with '|').
	def Keys()
		_aOut_ = []
		_nN_ = StzEnginePerfFamilySize(pFamily)
		for _i_ = 1 to _nN_
			_aOut_ + StzEnginePerfFamilyKeyAt(pFamily, _i_)
		next
		return _aOut_

	def HasOverflowed()
		_aKeys_ = This.Keys()
		_cOf_ = This._JoinKey(This._OverflowVals())
		return ring_find(_aKeys_, _cOf_) > 0

	# -- The family refuses to impersonate one metric -------------

	def Value()
		This._NotOneMetric("Value")

	def Mean()
		This._NotOneMetric("Mean")

	def Percentile(nP)
		This._NotOneMetric("Percentile")

	def _NotOneMetric(pcVerb)
		stzraise("stzMetricFamily '" + @cName + "': a family has no single " + pcVerb +
			"() -- pick a Child([" + This._JoinNames() + "]) and ask it.")

	# -- Exposition -----------------------------------------------

	def PromName()
		_cN_ = StzReplace(@cName, ".", "_")
		_cN_ = StzReplace(_cN_, "-", "_")
		return _cN_

	# One TYPE header, then every child's sample lines with labels.
	def PromText()
		_cN_ = This.PromName()
		_cOut_ = ""
		_cSuffix_ = ""
		if @cKind = "counter"
			_cSuffix_ = "_total"
		ok
		if @cHelp != ""
			_cOut_ += ("# HELP " + _cN_ + _cSuffix_ + " " + @cHelp + Char(10))
		ok
		if @cKind = "counter"
			_cOut_ += ("# TYPE " + _cN_ + "_total counter" + Char(10))
		but @cKind = "gauge"
			_cOut_ += ("# TYPE " + _cN_ + " gauge" + Char(10))
		else
			_cOut_ += ("# TYPE " + _cN_ + " summary" + Char(10))
		ok
		_aKeys_ = This.Keys()
		_nLen_ = ring_len(_aKeys_)
		for _i_ = 1 to _nLen_
			_cOut_ += This._ChildByKey(_aKeys_[_i_], StzSplit(_aKeys_[_i_], "|"))._PromSampleLines()
		next
		return _cOut_

	# One OTLP metric, one data point per child (labels as attributes).
	def OtelMetricJson()
		_cPoints_ = ""
		_aKeys_ = This.Keys()
		_nLen_ = ring_len(_aKeys_)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cPoints_ += ","
			ok
			_cPoints_ += This._ChildByKey(_aKeys_[_i_], StzSplit(_aKeys_[_i_], "|"))._OtelDataPointJson()
		next
		_oProto_ = This._ChildProto()
		_cJ_ = '{"name":"' + @cName + '"'
		if @cHelp != ""
			_cJ_ += (',"description":"' + @cHelp + '"')
		ok
		_cJ_ += _oProto_._OtelBodyJson("[" + _cPoints_ + "]")
		return _cJ_

	# -- Legibility -----------------------------------------------

	def Explain()
		_aL_ = []
		_aL_ + ("Metric family " + @cName + " (:" + @cKind + ") over [" +
			This._JoinNames() + "] -- " + This.ChildCount() + " child(ren), max " +
			@nMaxChildren + ".")
		_aKeys_ = This.Keys()
		_nLen_ = ring_len(_aKeys_)
		for _i_ = 1 to _nLen_
			_oC_ = This._ChildByKey(_aKeys_[_i_], StzSplit(_aKeys_[_i_], "|"))
			_aL_ + ("  {" + _aKeys_[_i_] + "} -> " + _oC_.Value() + " (n=" + _oC_.Count() + ")")
		next
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	def Destroy()
		if bReady
			StzEnginePerfFamilyDestroy(pFamily)
			pFamily = ""
			bReady = 0
		ok
		# cached children hold ADOPTED handles -- their Destroy() is a
		# no-op on engine state; dropping the cache is enough
		@aChildCache = []
		return This

	# -- Internals ------------------------------------------------

	def _JoinKey(paVals)
		_cK_ = ""
		_nLen_ = ring_len(paVals)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cK_ += "|"
			ok
			_cK_ += ("" + paVals[_i_])
		next
		return _cK_

	def _JoinNames()
		_cN_ = ""
		_nLen_ = ring_len(@aLabelNames)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cN_ += ", "
			ok
			_cN_ += @aLabelNames[_i_]
		next
		return _cN_

	def _OverflowVals()
		_aV_ = []
		for _i_ = 1 to ring_len(@aLabelNames)
			_aV_ + "_overflow"
		next
		return _aV_

	# Resolve a child by its key: face cache first, else reconstruct a
	# wrapper around the family's engine stores (the truth).
	def _ChildByKey(pcKey, paVals)
		_nLen_ = ring_len(@aChildCache)
		for _i_ = 1 to _nLen_
			if @aChildCache[_i_][1] = pcKey
				return @aChildCache[_i_][2]
			ok
		next
		_pS_ = StzEnginePerfFamilyChildSeries(pFamily, pcKey)
		_pH_ = ""
		if @cKind = "timer"
			_pH_ = StzEnginePerfFamilyChildHist(pFamily, pcKey)
		ok
		_aPairs_ = []
		_nN_ = ring_len(@aLabelNames)
		for _i_ = 1 to _nN_
			_cV_ = ""
			if _i_ <= ring_len(paVals)
				_cV_ = paVals[_i_]
			ok
			_aPairs_ + [ @aLabelNames[_i_], _cV_ ]
		next
		_oC_ = This._ChildProto()
		_oC_._BindAdopted(_pS_, _pH_, _aPairs_)
		@aChildCache + [ pcKey, _oC_ ]
		return @aChildCache[ring_len(@aChildCache)][2]

	# Paren-less new: no init, no engine stores -- the child adopts the
	# family's. Reconstruction is two small Ring objects, no handles.
	def _ChildProto()
		_oC_ = new stzMetric
		_oC_._InitChild(@cName, @cKind)
		return _oC_
