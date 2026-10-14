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

# Collects the findings of every rule domain into one list and gives one verdict, the single gate a build can fail on.
#
# Rule sets of different domains, code, agents, security, schemas, networks, all report findings in
# one shape: a hash list with rule, subject, where, severity and message, the subject being the
# domain. A report gathers them with Run for a rule set and a graph, Collect for an object that
# checks itself, Ingest for findings already in that shape and IngestLegacy for the older checkers'
# shapes. IsSound is true when no finding of severity error was collected; warnings advise. Explain
# returns the report as text lines grouped by subject and Report prints them.
#
#   receiver   o1 = new stzRuleReport("ci") o1.Ingest([ [ :rule = "entity_has_key", :subject = "er",
#              :where = "b", :severity = "error", :message = "entity B has no key" ] ])
#              o1.IngestLegacy([ [ :invariant = "unguarded", :node = "api", :severity = "warning",
#              :message = "no check" ] ], "agentic")
#   example    ? o1.NumberOfFindings()
#              #--> 2
#              ? @@( o1.Subjects() )
#              #--> [ "er", "agentic" ]
#              ? o1.IsSound()
#              #--> 0
#              ? len(o1.Warnings())
#              #--> 1
#              ? o1.Explain()[1]
#              #--> Rule report 'ci': 2 finding(s), 1 error(s), 1 warning(s) -> UNSOUND (errors present)
#   see        stzRuleGovernance, stzGraphRule, stzErDiagram
class stzRuleReport from stzObject

	@cName = ""
	@aFindings = []       # unified [ :rule, :subject, :where, :severity, :message ]

	# Builds an empty report under a name, ready to collect findings from any domain.
	#
	#   pcName     the name of the report, shown in its first line
	#   returns    nothing; the object is built
	#   note       StzRuleReportQ builds the same object
	#   see        Run, Collect
	def init(pcName)
		@cName = "" + pcName
		@aFindings = []

	# Runs a rule set over a graph and adds the findings it produces to the report.
	#
	#   poRuleSet   a rule set such as a stzErRuleSet
	#   oGraph      the graph it judges
	#   returns     the report itself, so calls chain
	#   note        each finding keeps the subject of its rule's domain, so domains coexist in one
	#               list
	#   see         Collect, Ingest
	#@ aka  -- collecting findings ---------------------------------------------
	def Run(poRuleSet, oGraph)
		_aF_ = poRuleSet.Check(oGraph)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			@aFindings + _aF_[_i_]
		next
		return This

	# Asks a graph to check itself and adds its findings to the report.
	#
	#   poGraph    any object that answers CheckRules, such as a stzErDiagram, a stzGraph or an org
	#              chart
	#   returns    the report itself, so calls chain
	#   note       an object with no CheckRules raises error R14
	#   see        Run, Ingest
	#@ aka  Collect a GRAPH's own findings -- the graph checks ITSELF (CheckRules) and the report ingests. This is the Softanza-oriented gate: each graph owns its rules and reports itself; the report just gathers them across domains. oRep.Collect(oCodeGraph).Collect(oAgentGraph).Collect(oSecurityGraph) Any object answering CheckRules() qualifies (stzGraph, stzAgentGraph, stzSecurityGraph, stzOrgChart, stzCode
	def Collect(poGraph)
		This.Ingest(poGraph.CheckRules())
		return This

	# Adds findings that are already in the unified shape to the report.
	#
	#   paFindings   a list of hash lists with rule, subject, where, severity and message
	#   returns      the report itself, so calls chain
	#   note         the findings are kept as given and nothing is checked
	#   see          IngestLegacy, Run
	#@ aka  Ingest findings already in the unified shape.
	def Ingest(paFindings)
		_n_ = len(paFindings)
		for _i_ = 1 to _n_
			@aFindings + paFindings[_i_]
		next
		return This

	# Adds findings from an older checker, turning invariant and node or line into rule and where.
	#
	#   paFindings   a list of hash lists that carry rule or invariant, and where, node or line
	#   pcSubject    the subject to give every finding
	#   returns      the report itself, so calls chain
	#   note         a missing severity becomes error and a missing message an empty text
	#   see          Ingest, Collect
	#@ aka  Ingest LEGACY findings (the hand-written checkers' shapes) under a subject, normalizing to the unified shape: :invariant->:rule, :node/:line->:where. So StzCheckAgentGraph / stzSecurityPosture / StzCheckCode output can join the one gate without changing those adapters.
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

	# Returns the name the report was built with.
	#
	#   returns    the name as text
	#   see        Explain
	#@ aka  -- reads -----------------------------------------------------------
	def Name()
		return @cName

	# Returns every finding collected so far, in the order they arrived.
	#
	#   returns    a list of hash lists with rule, subject, where, severity and message
	#   see        NumberOfFindings, FindingsOfSubject
	def Findings()
		return @aFindings

	# Returns how many findings the report holds.
	#
	#   returns    a number
	#   see        Findings, Errors
	def NumberOfFindings()
		return len(@aFindings)

	# Returns the collected findings that carry a given level, such as error or warning.
	#
	#   pcSeverity   the severity to keep, such as error or warning, in any letter case, with spaces
	#                ignored
	#   returns      a list of findings; [ ] when none match
	#   see          Errors, Warnings
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

	# Returns the findings of one subject, that is one domain.
	#
	#   pcSubject   the subject to keep, such as er or code, in any letter case
	#   returns     a list of findings; [ ] when none match
	#   see         Subjects, FindingsOfSeverity
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

	# Returns the findings of severity error.
	#
	#   returns    a list of findings
	#   see        Warnings, IsSound
	def Errors()
		return This.FindingsOfSeverity("error")

	# Returns the findings of severity warning.
	#
	#   returns    a list of findings
	#   see        Errors, FindingsOfSeverity
	def Warnings()
		return This.FindingsOfSeverity("warning")

	# Returns the subjects that produced at least one finding, in the order they first appear.
	#
	#   returns    a list of text
	#   see        FindingsOfSubject
	#@ aka  the subjects that produced at least one finding
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

	# TRUE if no finding of severity error has been collected.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 1 for an empty report
	#   note       warnings advise and do not make it false; this is the CI gate
	#   see        Errors, Explain
	#@ aka  -- the verdict + rendering -----------------------------------------
	def IsSound()
		return len(This.Errors()) = 0

	# Returns the report as lines of text: a verdict line, then each subject with its findings.
	#
	#   returns    a list of text lines
	#   note       the verdict line gives the counts and SOUND or UNSOUND (errors present); subjects
	#              come in the order they first appeared, not errors first
	#   see        Report, IsSound
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

	# Prints the lines of the explanation to the console, one per line.
	#
	#   returns    the report itself, so calls chain
	#   note       it prints with the ? statement
	#   see        Explain
	def Report()
		_a_ = This.Explain()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			? _a_[_i_]
		next
		return This
