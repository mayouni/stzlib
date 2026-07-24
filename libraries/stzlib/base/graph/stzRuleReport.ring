#================================================================#
#  STZRULEREPORT -- one CI gate over every graph-rule domain       #
#================================================================#

/*--- One finding shape, one verdict, across domains (graph-rules plan, phase 6)

Phases 1-5 gave code, agents, and security each an stzGraphRuleSet, and unified
their findings into ONE shape: [ :rule, :subject, :where, :severity, :message ].
:subject is the rule's domain, so findings from different domains coexist in one
list. stzRuleReport is the CI gate that collects them: run each domain's rule set
over its graph, and get ONE Findings()/IsSound()/Report() instead of three
parallel APIs.

	oRep = new stzRuleReport("restolean")
	oRep.Run(StzCodeRuleSetQ(),     oCodeGraph)      # subject = code
	oRep.Run(StzAgentRuleSetQ(),    oAgentGraph)     # subject = agentic
	oRep.Run(StzSecurityRuleSetQ(), oSecurityGraph)  # subject = security
	if NOT oRep.IsSound()
		? oRep.Report()          # grouped by subject, errors first
		# CI fails here
	ok

The legacy hand-written checkers (StzCheckAgentGraph, stzSecurityPosture,
StzCheckCode) keep their own frozen shapes -- they are the adapters. IngestLegacy
normalizes their output ([:invariant/:node] or [:line]) into the unified shape,
so even a legacy source can feed the one gate.
*/

func StzRuleReportQ(pcName)
	return new stzRuleReport(pcName)

class stzRuleReport from stzObject

	@cName = ""
	@aFindings = []       # unified [ :rule, :subject, :where, :severity, :message ]

	def init(pcName)
		@cName = "" + pcName
		@aFindings = []

	  #-- collecting findings ---------------------------------------------

	# Run a rule set over a graph and collect its findings (already unified,
	# carrying :subject from each rule's domain).
	def Run(poRuleSet, oGraph)
		_aF_ = poRuleSet.Check(oGraph)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			@aFindings + _aF_[_i_]
		next
		return This

	# Ingest findings already in the unified shape.
	def Ingest(paFindings)
		_n_ = len(paFindings)
		for _i_ = 1 to _n_
			@aFindings + paFindings[_i_]
		next
		return This

	# Ingest LEGACY findings (the hand-written checkers' shapes) under a subject,
	# normalizing to the unified shape: :invariant->:rule, :node/:line->:where.
	# So StzCheckAgentGraph / stzSecurityPosture / StzCheckCode output can join
	# the one gate without changing those adapters.
	def IngestLegacy(paFindings, pcSubject)
		_cS_ = "" + pcSubject
		_n_ = len(paFindings)
		for _i_ = 1 to _n_
			_f_ = paFindings[_i_]
			_rule_ = ""
			if HasKey(_f_, :rule)        _rule_ = _f_[:rule]
			but HasKey(_f_, :invariant)  _rule_ = _f_[:invariant]  ok
			_where_ = ""
			if HasKey(_f_, :where)   _where_ = "" + _f_[:where]
			but HasKey(_f_, :node)   _where_ = "" + _f_[:node]
			but HasKey(_f_, :line)   _where_ = "" + _f_[:line]  ok
			_sev_ = :error
			if HasKey(_f_, :severity)  _sev_ = _f_[:severity]  ok
			_msg_ = ""
			if HasKey(_f_, :message)   _msg_ = _f_[:message]  ok
			@aFindings + [ :rule = _rule_, :subject = _cS_, :where = _where_,
			               :severity = "" + _sev_, :message = _msg_ ]
		next
		return This

	  #-- reads -----------------------------------------------------------

	def Name()
		return @cName

	def Findings()
		return @aFindings

	def NumberOfFindings()
		return len(@aFindings)

	def FindingsOfSeverity(pcSeverity)
		_c_ = StzLower(ring_trim("" + pcSeverity))
		_out_ = []
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if StzLower("" + @aFindings[_i_][:severity]) = _c_
				_out_ + @aFindings[_i_]
			ok
		next
		return _out_

	def FindingsOfSubject(pcSubject)
		_c_ = StzLower(ring_trim("" + pcSubject))
		_out_ = []
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if StzLower("" + @aFindings[_i_][:subject]) = _c_
				_out_ + @aFindings[_i_]
			ok
		next
		return _out_

	def Errors()
		return This.FindingsOfSeverity("error")

	def Warnings()
		return This.FindingsOfSeverity("warning")

	# the subjects that produced at least one finding
	def Subjects()
		_out_ = []
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			_s_ = "" + @aFindings[_i_][:subject]
			if ring_find(_out_, _s_) = 0
				_out_ + _s_
			ok
		next
		return _out_

	  #-- the verdict + rendering -----------------------------------------

	# the CI gate: TRUE when no ERROR-severity finding fired anywhere. Warnings
	# advise (same convention as stzGraphRuleSet / stzSecurityPosture).
	def IsSound()
		return len(This.Errors()) = 0

	def Explain()
		_out_ = []
		_nE_ = len(This.Errors())
		_nW_ = len(This.Warnings())
		_cV_ = "SOUND"
		if _nE_ > 0
			_cV_ = "UNSOUND (errors present)"
		ok
		_out_ + ("Rule report '" + @cName + "': " + len(@aFindings) + " finding(s), " +
		         _nE_ + " error(s), " + _nW_ + " warning(s) -> " + _cV_)
		# grouped by subject
		_aSubs_ = This.Subjects()
		_nS_ = len(_aSubs_)
		for _i_ = 1 to _nS_
			_aInS_ = This.FindingsOfSubject(_aSubs_[_i_])
			_out_ + ("  [" + _aSubs_[_i_] + "] " + len(_aInS_) + " finding(s)")
			_nF_ = len(_aInS_)
			for _j_ = 1 to _nF_
				_f_ = _aInS_[_j_]
				_out_ + ("    " + StzUpper("" + _f_[:severity]) + " " + _f_[:rule] +
				         " @ " + ("" + _f_[:where]) + " -- " + _f_[:message])
			next
		next
		return _out_

	def Report()
		_a_ = This.Explain()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			? _a_[_i_]
		next
		return This
