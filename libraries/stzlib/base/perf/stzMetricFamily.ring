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

# Holds one metric name over declared labels, with one child metric for every combination of label values and a bound on how many.
#
# A family such as http.checkout.ms with labels route and method gives each combination its own
# child with its own percentiles: Child(["/menu", "GET"]).Record(12.5). The registry of children
# lives in the engine, so a child created after the server copied its monitor is reached by every
# copy. Cardinality is bounded by design: when the family is full, new label sets are routed to a
# reserved overflow child whose labels are all _overflow, so data is never dropped and a growing
# overflow bucket shows in the exposition. The overflow child takes one of the slots from birth, so
# HasOverflowed answers 1 for a new family. A family has no single value, mean or percentile: ask a
# child. PromText and OtelMetricJson write one metric with every child.
#
#   receiver   o1 = StzMetricFamily("http.checkout.ms", :Timer, [ "route", "method" ]) o1.Child([
#              "/menu", "GET" ]).Record(10) o1.Child([ "/menu", "GET" ]).Record(30) o1.Child([
#              "/pay", "POST" ]).Record(48)
#   example    ? o1.ChildCount()
#              #--> 3
#              ? o1.Child([ "/menu", "GET" ]).Count()
#              #--> 2
#              ? o1.Child([ "/pay", "POST" ]).Value()
#              #--> 48
#              ? o1.Keys()[2]
#              #--> /menu|GET
#              ? o1.PromName()
#              #--> http_checkout_ms
#              ? o1.Kind()
#              #--> timer
#              ? left(o1.PromText(), 6)
#              #--> # TYPE
#   see        stzMetric, stzSla, stzPerfMonitor
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

	# Builds a family of one metric name over declared labels, with an engine registry for its children and a reserved overflow child.
	#
	#   pcName          the metric name, such as http.checkout.ms
	#   pcKind          Counter, Gauge or Timer, in any letter case
	#   paLabelNames    the label names, a non-empty list of text
	#   pnWindow        how many samples each child keeps, 1 or more, otherwise 1024
	#   pnMaxChildren   the most children, overflow included, 2 or more, otherwise 64
	#   returns         nothing; the engine registry and the overflow child exist when the object is
	#                   made
	#   note            StzMetricFamily builds it with window 1024 and at most 64 children,
	#                   StzMetricFamilyXT sets both; the reserved overflow child uses one of the
	#                   slots, so a family of at most 3 holds 2 label sets of its own
	#   warning         a kind other than counter, gauge or timer raises error stzMetricFamily: kind
	#                   must be :Counter, :Gauge or :Timer; an empty list of label names raises
	#                   error ... a family WITHOUT labels is a plain stzMetric
	#   see             Child, StzMetricFamily
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

	# Returns the metric name.
	#
	#   returns    the name as text, as given
	#   see        PromName, Kind
	def Name()
		return @cName

	# Returns the kind of every child.
	#
	#   returns    counter, gauge or timer, in lower case
	#   see        Name
	def Kind()
		return @cKind

	# TRUE if the object is a family rather than one metric.
	#
	#   returns    always 1
	#   note       a stzMetric answers 0
	#   see        Kind
	def IsFamily()
		return 1

	# Returns the declared label names.
	#
	#   returns    a list of text, in declared order
	#   see        Child, MaxChildren
	def LabelNames()
		return @aLabelNames

	# Returns the bound on the number of children.
	#
	#   returns    a number, overflow child included
	#   see        ChildCount, HasOverflowed
	def MaxChildren()
		return @nMaxChildren

	# Sets the help text written in the exposition.
	#
	#   pcText     the description
	#   returns    the family itself, so calls chain
	#   see        Help, PromText
	def SetHelp(pcText)
		@cHelp = "" + pcText
		return This

	# Returns the help text.
	#
	#   returns    the text; an empty text until SetHelp is called
	#   see        SetHelp
	def Help()
		return @cHelp

	# Returns the child metric for one combination of label values, creating it on first sight.
	#
	#   paValues   the label values, a list with one value for each label in declared order
	#   returns    a stzMetric that records for those values; a full family returns the overflow
	#              child instead of dropping data
	#   note       every call with the same values reaches the same engine stores, even from a copy
	#              of the family; once the family is full, new label sets all land in the child
	#              whose labels are all _overflow
	#   warning    a list of another length raises error stzMetricFamily ...: Child() takes N
	#              value(s), one per label
	#   see        LabelNames, ChildCount, HasOverflowed
	#@ aka  -- Children -------------------------------------------------
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

	# Returns how many children the family holds.
	#
	#   returns    a number; a new family already holds 1, the reserved overflow child
	#   note       the count is the engine's, so every copy of the family agrees
	#   see        Keys, MaxChildren
	#@ aka  How many distinct children exist (engine truth, all faces agree).
	def ChildCount()
		return StzEnginePerfFamilySize(pFamily)

	# Returns the keys of the children, in the order they were created.
	#
	#   returns    a list of text, each the label values joined with a bar; the first is always the
	#              overflow key
	#   note       for labels route and method the key of GET on /menu is the two values joined by a
	#              bar
	#   see        ChildCount, Child
	#@ aka  The children's keys, creation order (values joined with '|').
	def Keys()
		_aOut_ = []
		_nN_ = StzEnginePerfFamilySize(pFamily)
		for _i_ = 1 to _nN_
			_aOut_ + StzEnginePerfFamilyKeyAt(pFamily, _i_)
		next
		return _aOut_

	# TRUE if the overflow child exists.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 1 from the moment the family is built
	#   note       the intended meaning, that some label set was routed to overflow, is not what it
	#              tests
	#   warning    the overflow child is created when the family is built, so this answers 1 for a
	#              new family that has never overflowed, whatever its children: on a family of 3
	#              holding two children of its own it answered 1 before any label set was refused;
	#              whether overflow data exists has to be read from the overflow child's own count
	#   see        Keys, MaxChildren
	def HasOverflowed()
		_aKeys_ = This.Keys()
		_cOf_ = This._JoinKey(This._OverflowVals())
		return ring_find(_aKeys_, _cOf_) > 0

	# Refuses with an error telling you to pick a child, since a family has no single value.
	#
	#   returns    nothing; it always raises error stzMetricFamily ...: a family has no single
	#              Value() -- pick a Child([...]) and ask it
	#   note       by design: a family never impersonates one metric
	#   see        Child, Mean
	#@ aka  -- The family refuses to impersonate one metric -------------
	def Value()
		This._NotOneMetric("Value")

	# Refuses with an error telling you to pick a child, since a family has no single mean.
	#
	#   returns    nothing; it always raises error ... a family has no single Mean()
	#   note       by design
	#   see        Child, Value
	def Mean()
		This._NotOneMetric("Mean")

	# Refuses with an error telling you to pick a child, since a family has no single percentile.
	#
	#   nP         the percentile that was asked for, ignored
	#   returns    nothing; it always raises error ... a family has no single Percentile()
	#   note       by design; ask a child, whose Percentile reads its own samples
	#   see        Child, Value
	def Percentile(nP)
		This._NotOneMetric("Percentile")

	def _NotOneMetric(pcVerb)
		stzraise("stzMetricFamily '" + @cName + "': a family has no single " + pcVerb +
			"() -- pick a Child([" + This._JoinNames() + "]) and ask it.")

	# Returns the metric name in a form Prometheus accepts.
	#
	#   returns    the name as text with dots and dashes replaced by underscores, such as
	#              http_checkout_ms
	#   see        PromText, Name
	#@ aka  -- Exposition -----------------------------------------------
	def PromName()
		_cN_ = StzReplace(@cName, ".", "_")
		_cN_ = StzReplace(_cN_, "-", "_")
		return _cN_

	# Returns the family in the Prometheus text format: one header, then every child's sample lines with its labels.
	#
	#   returns    a multi-line text; a counter is named with _total, a gauge as it is, and a timer
	#              is a summary with quantile 0.5, 0.95 and 0.99 lines, a sum and a count for each
	#              child
	#   note       the overflow child is listed like any other, so a growing overflow bucket shows
	#              in the exposition; a help line is written only when SetHelp was called
	#   see        OtelMetricJson, SetHelp
	#@ aka  One TYPE header, then every child's sample lines with labels.
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

	# Returns the family as one OpenTelemetry metric with one data point for each child, the labels as attributes.
	#
	#   returns    a JSON text
	#   note       a counter is a sum, a gauge a gauge and a timer a summary
	#   see        PromText, Explain
	#@ aka  One OTLP metric, one data point per child (labels as attributes).
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

	# Returns the family as lines of text: a header with the counts, then each child with its value and its sample count.
	#
	#   returns    a list of text lines
	#   note       the header reads Metric family name (:kind) over [labels] -- N child(ren), max M
	#   see        Show, Keys
	#@ aka  -- Legibility -----------------------------------------------
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

	# Prints the explanation to the console, one line per line.
	#
	#   returns    nothing
	#   note       it prints with the ? statement
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Frees the engine registry and every child.
	#
	#   returns    the family itself, so calls chain
	#   note       after it ChildCount answers 0 and the family must not be used again
	#   see        ChildCount, init
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
