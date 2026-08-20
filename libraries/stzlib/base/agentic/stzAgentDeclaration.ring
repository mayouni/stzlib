#=====================================================================#
#  STZAGENTDECLARATION -- AN AGENT IS A FILE                          #
#  the .pia format, and the court that judges it at LOAD               #
#=====================================================================#
/*
	An agent is CREATED DECLARATIVELY, DROPPED IN A FOLDER, AND RUNS IN
	THE LOOP. This file is the notation and its judge; stzAgentFolder is
	the folder; stzPIAgent, stzAgentSkill, stzAgentMemory, stzGovernance
	and stzAgentHost are the runtime, unchanged. NO NEW AGENT RUNTIME
	LIVES HERE -- this is a front-end onto classes that already work.

	A .pia file, whole:

		pia: 1
		name: kitchen-bot
		kind: pi
		coverage: watches stock levels and reorders when they run low
		reversibility: compensable
		schedule:
		  timer: 50
		memory:
		  - stock level low
		governance:
		  authority: delegated
		  risks:
		    order-stock: 2
		  grants:
		    - order-stock
		skills:
		  - name: restock
		    when: fact stock level low
		    does: learn stock level ordered
		    verify: fact stock level ordered
		    effect: order-stock

	And the same shape for a proposer:

		pia: 1
		name: summarizer
		kind: llm
		coverage: proposes a topic and a mood; commits nothing
		reversibility: reversible
		schedule:
		  event: inbox
		proposes:
		  prompt: Summarize this text: {input}
		  input: recall inbox holds
		  into: summary
		  budget: 2
		  structure:
		    - field: topic
		      type: string
		    - field: mood
		      type: oneof
		      choices: positive, negative

	THE DECLARATION IS JUDGED, AND IT IS JUDGED AT LOAD. This is prompt
	37's habit, carried over exactly: an unknown key, a missing coverage
	statement, a verb outside the vocabulary, a `ring:` clause naming a
	function that does not exist -- each is a REFUSAL AT LOAD, naming the
	rule that produced it, never a surprise at tick. A file that cannot be
	honoured never becomes an agent.

	THE VOCABULARY IS SMALL AND CLOSED, AND VERSIONED FROM DAY ONE. The
	`pia: 1` header is not decoration: a file with no version, or a version
	this build does not know, is refused rather than guessed at. Growing
	the vocabulary means growing the version.

	WHAT A CLAUSE MAY SAY (the whole of v1):

	  always                 -- only in `when:`; the precondition always holds
	  fact <s> <p> <o>       -- in `when:` / `verify:`; that triple is in memory
	  no-fact <s> <p> <o>    -- in `when:` / `verify:`; that triple is NOT
	  recall <s> <p>         -- in `when:`; memory holds at least one such fact
	  learn <s> <p> <o>      -- only in `does:`; write the triple
	  forget <s> <p> <o>     -- only in `does:`; remove it
	  propose                -- only in `does:`, only for kind: llm
	  ring:<FunctionName>    -- any slot; a Ring function taking (oMemory).
	                            REFUSED AT LOAD if no such function exists,
	                            which is what "Ring for the rest" costs and
	                            all it costs.

	THIS FILE EXTENDS stzAgentGraph's VOCABULARY RATHER THAN INVENTING A
	SECOND ONE. `kind` is the graph's actor kind, `effect` names a governed
	action exactly as AddGovernedSkill does, and the refusal for an llm
	actor holding an effect is stzAgentGraph.Grant's OWN SENTENCE, quoted
	rather than paraphrased -- one rule, two doors, same words.

	WHAT A DECLARATION CANNOT DO, said plainly: it cannot make an agent
	correct. A file that passes every gate here declares a well-formed
	agent whose skills fire on preconditions it named -- whether those are
	the RIGHT preconditions is not a question any format can answer.
*/

#---------------------------------------------------------------------#
#  THE CLOSED VOCABULARY                                               #
#---------------------------------------------------------------------#

# The format version this build knows. A file naming any other is
# refused; the number moves when the vocabulary does.
func StzPiaVersion()
	return 1

func StzPiaTopKeys()
	return [ "pia", "name", "kind", "coverage", "reversibility",
		 "schedule", "memory", "governance", "skills", "proposes", "note" ]

func StzPiaSkillKeys()
	return [ "name", "when", "does", "verify", "effect" ]

func StzPiaGovernanceKeys()
	return [ "authority", "risks", "grants" ]

func StzPiaProposesKeys()
	return [ "prompt", "input", "into", "structure", "budget", "retries", "maxtokens" ]

func StzPiaScheduleKeys()
	return [ "timer", "event" ]

func StzPiaKinds()
	return [ "pi", "llm" ]

func StzPiaReversibilityClasses()
	return [ "reversible", "compensable", "irreversible" ]

# verb -> which slots it may stand in
func StzPiaVerbs()
	return [
		[ "always",  [ "when" ] ],
		[ "fact",    [ "when", "verify" ] ],
		[ "no-fact", [ "when", "verify" ] ],
		[ "recall",  [ "when" ] ],
		[ "learn",   [ "does" ] ],
		[ "forget",  [ "does" ] ],
		[ "propose", [ "does" ] ]
	]

# The refusal a declaration answers with. Same unified shape as every
# other family verdict -- [ :rule, :subject, :where, :severity, :message ]
# -- so stzRuleReport.Ingest() takes it with no adapter, and a bad agent
# file stands in the same CI gate as a bad graph or a bad schema.
func _StzPiaFinding(pcRule, pcWhere, pcMessage)
	return [ :rule = pcRule, :subject = "pi-agent-declaration",
		 :where = pcWhere, :severity = :error, :message = pcMessage ]

func StzAgentDeclarationQ(pcText)
	return new stzAgentDeclaration(pcText, "(text)")

func StzAgentDeclarationFromFileQ(pcPath)
	if NOT fexists(pcPath)
		stzraise("stzAgentDeclaration: no file at '" + pcPath + "'.")
	ok
	return new stzAgentDeclaration(StzFileRead(pcPath), "" + pcPath)

#---------------------------------------------------------------------#
#  THE DECLARATION                                                     #
#---------------------------------------------------------------------#

class stzAgentDeclaration from stzObject

	@cText = ""
	@cSource = ""
	@aFindings = []
	@bValid = 0

	@cName = ""
	@cKind = "pi"
	@cCoverage = ""
	@cRev = ""
	@cNote = ""
	@aSchedule = []            # [ :mode = "timer"|"event", :timer, :channel ]
	@aMemory = []              # [ [ s, p, o ] ]
	@aGov = []                 # [ :authority, :risks, :grants ]
	@aSkills = []              # [ :name, :when, :does, :verify, :effect ]
	@aProposes = []

	def init(pcText, pcSource)
		@cText = "" + pcText
		@cSource = "" + pcSource
		@aSchedule = [ :mode = "", :timer = 0, :channel = "" ]
		@aGov = [ :authority = "", :risks = [], :grants = [] ]
		This._Judge()

	#-- what it says ---------------------------------------------------

	def IsValid()
		return @bValid

	def Findings()
		return @aFindings

	def Source()
		return @cSource

	def Name_()
		return @cName

	def Kind()
		return @cKind

	def CoverageStatement()
		return @cCoverage

	def ReversibilityClass()
		return @cRev

	def Schedule()
		return @aSchedule

	def NumberOfSkills()
		return len(@aSkills)

	def SkillAt(pnIndex)
		return @aSkills[pnIndex]

	def Governance()
		return @aGov

	def Proposes()
		return @aProposes

	def SeedFacts()
		return @aMemory

	# One line per refusal, in the order they were found.
	def CiteFindings()
		if len(@aFindings) = 0
			return ""
		ok
		_c_ = ""
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += char(10)
			ok
			_c_ += "[" + @aFindings[_i_][:rule] + " @ " +
				@aFindings[_i_][:where] + "] " + @aFindings[_i_][:message]
		next
		return _c_

	def Describe()
		if @bValid = 0
			return "REFUSED (" + @cSource + "):" + char(10) + This.CiteFindings()
		ok
		_c_ = "agent '" + @cName + "' -- kind " + @cKind +
			", " + @cRev + ", " + len(@aSkills) + " skill(s)" + char(10)
		_c_ += "  covers: " + @cCoverage + char(10)
		if @aSchedule[:mode] = "timer"
			_c_ += "  ticks : every " + @aSchedule[:timer] + " ms" + char(10)
		but @aSchedule[:mode] = "event"
			_c_ += "  ticks : on every event on '" + @aSchedule[:channel] + "'" + char(10)
		ok
		_n_ = len(@aSkills)
		for _i_ = 1 to _n_
			_c_ += "  - " + @aSkills[_i_][:name]
			if @aSkills[_i_][:effect] != ""
				_c_ += " (effect: " + @aSkills[_i_][:effect] + ")"
			ok
			_c_ += char(10)
		next
		return _c_

	#-- the court ------------------------------------------------------

	def _Judge()
		@aFindings = []
		_aP_ = _StzOutputParseMemo(@cText)
		if _aP_[:ok] = 0
			@aFindings + _StzPiaFinding("pia-parse", "(the whole file)",
				"this is not a readable declaration: " + _aP_[:why])
			@bValid = 0
			return
		ok
		_aDoc_ = _aP_[:value]
		if NOT isList(_aDoc_)
			@aFindings + _StzPiaFinding("pia-parse", "(the whole file)",
				"a declaration must be a block of named fields.")
			@bValid = 0
			return
		ok

		This._JudgeVersion(_aDoc_)
		This._JudgeUnknownKeys(_aDoc_)
		This._JudgeIdentity(_aDoc_)
		This._JudgeSchedule(_aDoc_)
		This._JudgeMemory(_aDoc_)
		This._JudgeGovernance(_aDoc_)
		This._JudgeSkills(_aDoc_)
		This._JudgeProposes(_aDoc_)
		This._JudgeLlmIsNotEffectful()

		if len(@aFindings) = 0
			@bValid = 1
		else
			@bValid = 0
		ok

	# THE VERSION IS A GATE, NOT A COMMENT. A file with no `pia:` line, or
	# one this build does not know, is refused rather than read hopefully.
	def _JudgeVersion(paDoc)
		if NOT HasKey(paDoc, "pia")
			@aFindings + _StzPiaFinding("pia-version", "pia",
				"a declaration must open with 'pia: " + StzPiaVersion() +
				"'. A file with no version cannot be read safely by a " +
				"later build, so it is refused rather than guessed at.")
			return
		ok
		_v_ = ring_trim("" + paDoc[:pia])
		if _v_ != ("" + StzPiaVersion())
			@aFindings + _StzPiaFinding("pia-version", "pia",
				"this build knows format version " + StzPiaVersion() +
				" and the file says '" + _v_ + "'.")
		ok

	def _JudgeUnknownKeys(paDoc)
		_acOK_ = StzPiaTopKeys()
		_n_ = len(paDoc)
		for _i_ = 1 to _n_
			_k_ = StzLower(ring_trim("" + paDoc[_i_][1]))
			if ring_find(_acOK_, _k_) = 0
				@aFindings + _StzPiaFinding("pia-unknown-key", _k_,
					"'" + _k_ + "' is not a key this format knows. The whole " +
					"of it: " + StzJoinWith(_acOK_, ", ") + ".")
			ok
		next

	def _JudgeIdentity(paDoc)
		if HasKey(paDoc, "name")
			@cName = StzLower(ring_trim("" + paDoc[:name]))
		ok
		if @cName = ""
			@aFindings + _StzPiaFinding("pia-name", "name",
				"an agent needs a name -- it is how the host supervises it, " +
				"cancels it and retires it.")
		ok

		if HasKey(paDoc, "kind")
			@cKind = StzLower(ring_trim("" + paDoc[:kind]))
		ok
		if ring_find(StzPiaKinds(), @cKind) = 0
			@aFindings + _StzPiaFinding("pia-kind", "kind",
				"kind is 'pi' or 'llm' and the file says '" + @cKind +
				"'. These are stzAgentGraph's actor kinds, not new words.")
		ok

		if HasKey(paDoc, "coverage")
			@cCoverage = ring_trim("" + paDoc[:coverage])
		ok
		if @cCoverage = ""
			@aFindings + _StzPiaFinding("pia-coverage", "coverage",
				"an agent must say WHAT IT COVERS. The engine loop refuses " +
				"to schedule an agent with no coverage statement (law 18), " +
				"so a file without one could never run and is refused here " +
				"instead of at the first tick.")
		ok

		if HasKey(paDoc, "reversibility")
			@cRev = StzLower(ring_trim("" + paDoc[:reversibility]))
		ok
		if ring_find(StzPiaReversibilityClasses(), @cRev) = 0
			@aFindings + _StzPiaFinding("pia-reversibility", "reversibility",
				"reversibility is one of " +
				StzJoinWith(StzPiaReversibilityClasses(), ", ") +
				" and the file says '" + @cRev + "'. The absence of a class " +
				"is not a class, and the engine loop refuses it.")
		ok

		if HasKey(paDoc, "note")
			@cNote = ring_trim("" + paDoc[:note])
		ok

	def _JudgeSchedule(paDoc)
		if NOT HasKey(paDoc, "schedule")
			@aFindings + _StzPiaFinding("pia-schedule", "schedule",
				"an agent that is dropped in a folder must say WHEN it runs: " +
				"'timer: <ms>' or 'event: <channel>'.")
			return
		ok
		_aS_ = paDoc[:schedule]
		if NOT isList(_aS_)
			@aFindings + _StzPiaFinding("pia-schedule", "schedule",
				"schedule is a block holding 'timer: <ms>' or 'event: <channel>'.")
			return
		ok
		_nHas_ = 0
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			_k_ = StzLower(ring_trim("" + _aS_[_i_][1]))
			if ring_find(StzPiaScheduleKeys(), _k_) = 0
				@aFindings + _StzPiaFinding("pia-unknown-key", "schedule." + _k_,
					"'" + _k_ + "' is not a schedule key; the whole of it is " +
					"timer, event.")
				loop
			ok
			_nHas_++
			if _k_ = "timer"
				_nMs_ = 0 + ring_trim("" + _aS_[_i_][2])
				if _nMs_ < 1
					@aFindings + _StzPiaFinding("pia-schedule", "schedule.timer",
						"a timer interval is a positive number of milliseconds; " +
						"the file says '" + _aS_[_i_][2] + "'.")
					loop
				ok
				@aSchedule[:mode] = "timer"
				@aSchedule[:timer] = _nMs_
			else
				_cCh_ = StzLower(ring_trim("" + _aS_[_i_][2]))
				if _cCh_ = ""
					@aFindings + _StzPiaFinding("pia-schedule", "schedule.event",
						"an event schedule needs a channel name.")
					loop
				ok
				@aSchedule[:mode] = "event"
				@aSchedule[:channel] = _cCh_
			ok
		next
		if _nHas_ > 1
			@aFindings + _StzPiaFinding("pia-schedule", "schedule",
				"an agent ticks on a TIMER or on an EVENT, never both -- " +
				"two schedules is two agents.")
		ok

	def _JudgeMemory(paDoc)
		@aMemory = []
		if NOT HasKey(paDoc, "memory")
			return
		ok
		_aM_ = paDoc[:memory]
		if NOT isList(_aM_)
			@aFindings + _StzPiaFinding("pia-memory", "memory",
				"memory is a list of '- subject predicate object' lines.")
			return
		ok
		_n_ = len(_aM_)
		for _i_ = 1 to _n_
			if isList(_aM_[_i_])
				@aFindings + _StzPiaFinding("pia-memory", "memory[" + _i_ + "]",
					"a seeded fact is one line of three words, not a block.")
				loop
			ok
			_ac_ = This._Words("" + _aM_[_i_])
			if len(_ac_) != 3
				@aFindings + _StzPiaFinding("pia-memory", "memory[" + _i_ + "]",
					"a fact is exactly three words -- subject, predicate, " +
					"object -- and this one has " + len(_ac_) + ": '" +
					_aM_[_i_] + "'.")
				loop
			ok
			@aMemory + [ StzLower(_ac_[1]), StzLower(_ac_[2]), StzLower(_ac_[3]) ]
		next

	def _JudgeGovernance(paDoc)
		if NOT HasKey(paDoc, "governance")
			return
		ok
		_aG_ = paDoc[:governance]
		if NOT isList(_aG_)
			@aFindings + _StzPiaFinding("pia-governance", "governance",
				"governance is a block holding authority, risks and grants.")
			return
		ok
		_n_ = len(_aG_)
		for _i_ = 1 to _n_
			_k_ = StzLower(ring_trim("" + _aG_[_i_][1]))
			if ring_find(StzPiaGovernanceKeys(), _k_) = 0
				@aFindings + _StzPiaFinding("pia-unknown-key", "governance." + _k_,
					"'" + _k_ + "' is not a governance key; the whole of it is " +
					StzJoinWith(StzPiaGovernanceKeys(), ", ") + ".")
				loop
			ok
			if _k_ = "authority"
				@aGov[:authority] = StzLower(ring_trim("" + _aG_[_i_][2]))
			but _k_ = "grants"
				_aL_ = _aG_[_i_][2]
				if NOT isList(_aL_)
					_aL_ = [ "" + _aL_ ]
				ok
				_aOut_ = []
				_m_ = len(_aL_)
				for _j_ = 1 to _m_
					_aOut_ + StzLower(ring_trim("" + _aL_[_j_]))
				next
				@aGov[:grants] = _aOut_
			else
				_aR_ = _aG_[_i_][2]
				if NOT isList(_aR_)
					@aFindings + _StzPiaFinding("pia-governance", "governance.risks",
						"risks is a block of '<action>: <tier 1..4>' lines.")
					loop
				ok
				_aOut_ = []
				_m_ = len(_aR_)
				for _j_ = 1 to _m_
					_cA_ = StzLower(ring_trim("" + _aR_[_j_][1]))
					_nT_ = 0 + ring_trim("" + _aR_[_j_][2])
					if _nT_ < 1 or _nT_ > 4
						@aFindings + _StzPiaFinding("pia-governance",
							"governance.risks." + _cA_,
							"risk tiers run 1 (low) to 4 (critical); the file " +
							"says '" + _aR_[_j_][2] + "'.")
						loop
					ok
					_aOut_ + [ _cA_, _nT_ ]
				next
				@aGov[:risks] = _aOut_
			ok
		next

		# An authority word the governance layer does not know would raise
		# INSIDE SetAuthority at build time -- which is a surprise at a
		# moment nobody is reading. Judged here instead.
		if @aGov[:authority] != ""
			_acA_ = [ "advisory", "delegated", "autonomous", "emergencyoverride" ]
			if ring_find(_acA_, @aGov[:authority]) = 0
				@aFindings + _StzPiaFinding("pia-governance", "governance.authority",
					"authority is one of " + StzJoinWith(_acA_, ", ") +
					" and the file says '" + @aGov[:authority] + "'.")
			ok
		ok

	def _JudgeSkills(paDoc)
		@aSkills = []
		if NOT HasKey(paDoc, "skills")
			if @cKind = "pi"
				@aFindings + _StzPiaFinding("pia-skills", "skills",
					"a pi agent with no skills has nothing to do on a tick.")
			ok
			return
		ok
		_aS_ = paDoc[:skills]
		if NOT isList(_aS_) or len(_aS_) = 0
			@aFindings + _StzPiaFinding("pia-skills", "skills",
				"skills is a list of '- name: ...' blocks.")
			return
		ok
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			This._JudgeOneSkill(_aS_[_i_], _i_)
		next

	def _JudgeOneSkill(paSk, pnAt)
		_cWhere_ = "skills[" + pnAt + "]"
		if NOT isList(paSk)
			@aFindings + _StzPiaFinding("pia-skills", _cWhere_,
				"a skill is a block of named fields.")
			return
		ok

		_acOK_ = StzPiaSkillKeys()
		_n_ = len(paSk)
		for _i_ = 1 to _n_
			_k_ = StzLower(ring_trim("" + paSk[_i_][1]))
			if ring_find(_acOK_, _k_) = 0
				@aFindings + _StzPiaFinding("pia-unknown-key", _cWhere_ + "." + _k_,
					"'" + _k_ + "' is not a skill key; the whole of it is " +
					StzJoinWith(_acOK_, ", ") + ".")
			ok
		next

		_cName_ = ""
		if HasKey(paSk, "name")
			_cName_ = StzLower(ring_trim("" + paSk[:name]))
		ok
		if _cName_ = ""
			@aFindings + _StzPiaFinding("pia-skill-name", _cWhere_,
				"a skill needs a name -- every trace line the agent writes " +
				"cites it.")
			_cName_ = "(unnamed)"
		ok
		_cWhere_ = "skills." + _cName_

		_aWhen_ = [ :verb = "always", :args = [] ]
		if HasKey(paSk, "when")
			_aWhen_ = This._Clause("" + paSk[:when], "when", _cWhere_ + ".when")
		ok

		if NOT HasKey(paSk, "does")
			@aFindings + _StzPiaFinding("pia-skill-does", _cWhere_,
				"a skill must say what it DOES; a skill with no action is a " +
				"comment.")
			return
		ok
		_aDoes_ = This._Clause("" + paSk[:does], "does", _cWhere_ + ".does")

		_aVerify_ = [ :verb = "", :args = [] ]
		if HasKey(paSk, "verify")
			_aVerify_ = This._Clause("" + paSk[:verify], "verify", _cWhere_ + ".verify")
		ok

		_cEffect_ = ""
		if HasKey(paSk, "effect")
			_cEffect_ = StzLower(ring_trim("" + paSk[:effect]))
			if _cEffect_ = ""
				@aFindings + _StzPiaFinding("pia-skill-effect", _cWhere_ + ".effect",
					"an effect names the GOVERNED ACTION the skill performs; " +
					"an empty one governs nothing.")
			ok
		ok

		@aSkills + [ :name = _cName_, :when = _aWhen_, :does = _aDoes_,
			     :verify = _aVerify_, :effect = _cEffect_ ]

	# One clause -> [ :verb, :args ]. Every refusal here names the slot as
	# well as the rule, because the same verb is legal in one slot and not
	# in another and a message that did not say which would be a riddle.
	def _Clause(pcText, pcSlot, pcWhere)
		_c_ = ring_trim("" + pcText)
		if _c_ = ""
			@aFindings + _StzPiaFinding("pia-clause", pcWhere,
				"an empty clause says nothing.")
			return [ :verb = "", :args = [] ]
		ok

		# a Ring function, named. THE GATE THE PROMPT ASKS FOR: a clause
		# naming a function that does not exist is refused AT LOAD, not
		# discovered at the first tick with the agent already running.
		if StzLower(StzLeft(_c_, 5)) = "ring:"
			_cFn_ = ring_trim(StzMid(_c_, 6, StzLen(_c_) - 5))
			if _cFn_ = ""
				@aFindings + _StzPiaFinding("pia-clause", pcWhere,
					"'ring:' must be followed by a function name.")
				return [ :verb = "", :args = [] ]
			ok
			if isfunction(_cFn_) = 0
				@aFindings + _StzPiaFinding("pia-undeclared-closure", pcWhere,
					"this clause names the Ring function '" + _cFn_ +
					"' and no such function is defined. A declaration that " +
					"points at nothing is refused at LOAD rather than at the " +
					"first tick -- load the file that defines it before the " +
					"folder, or write the clause in the declared vocabulary.")
				return [ :verb = "", :args = [] ]
			ok
			return [ :verb = "ring", :args = [ _cFn_ ] ]
		ok

		_ac_ = This._Words(_c_)
		_cVerb_ = StzLower(_ac_[1])
		_aV_ = StzPiaVerbs()
		_nAt_ = 0
		_n_ = len(_aV_)
		for _i_ = 1 to _n_
			if _aV_[_i_][1] = _cVerb_
				_nAt_ = _i_
				exit
			ok
		next
		if _nAt_ = 0
			@aFindings + _StzPiaFinding("pia-clause", pcWhere,
				"'" + _cVerb_ + "' is not a verb this format knows. The whole " +
				"of the vocabulary is always, fact, no-fact, recall, learn, " +
				"forget, propose -- or 'ring:<FunctionName>' for anything else.")
			return [ :verb = "", :args = [] ]
		ok
		if ring_find(_aV_[_nAt_][2], pcSlot) = 0
			@aFindings + _StzPiaFinding("pia-clause-slot", pcWhere,
				"'" + _cVerb_ + "' cannot stand in a '" + pcSlot +
				"' clause; it belongs in " + StzJoinWith(_aV_[_nAt_][2], " or ") +
				". A precondition that acts, or an action that only looks, is " +
				"a declaration that means the opposite of what it reads like.")
			return [ :verb = "", :args = [] ]
		ok

		_aArgs_ = []
		_m_ = len(_ac_)
		for _i_ = 2 to _m_
			_aArgs_ + StzLower(_ac_[_i_])
		next

		_nWant_ = This._Arity(_cVerb_)
		if len(_aArgs_) != _nWant_
			@aFindings + _StzPiaFinding("pia-clause-arity", pcWhere,
				"'" + _cVerb_ + "' takes " + _nWant_ + " word(s) and this " +
				"clause gives " + len(_aArgs_) + ": '" + _c_ + "'.")
			return [ :verb = "", :args = [] ]
		ok
		return [ :verb = _cVerb_, :args = _aArgs_ ]

	def _Arity(pcVerb)
		if pcVerb = "always" or pcVerb = "propose"
			return 0
		ok
		if pcVerb = "recall"
			return 2
		ok
		return 3

	def _Words(pcText)
		_ac_ = StzSplit(ring_trim("" + pcText), " ")
		_aOut_ = []
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_w_ = ring_trim(_ac_[_i_])
			if _w_ != ""
				_aOut_ + _w_
			ok
		next
		if len(_aOut_) = 0
			_aOut_ + ""
		ok
		return _aOut_

	def _JudgeProposes(paDoc)
		@aProposes = []
		if @cKind = "pi"
			if HasKey(paDoc, "proposes")
				@aFindings + _StzPiaFinding("pia-proposes", "proposes",
					"'proposes' declares what an LLM actor OFFERS and this " +
					"agent is kind 'pi'. A pi agent acts; it does not propose.")
			ok
			return
		ok
		if NOT HasKey(paDoc, "proposes")
			@aFindings + _StzPiaFinding("pia-proposes", "proposes",
				"an llm agent must declare what it proposes -- a prompt and " +
				"the OUTPUT STRUCTURE it is held to. An unconstrained proposer " +
				"is the thing the structured-output rung exists to prevent.")
			return
		ok
		_aP_ = paDoc[:proposes]
		if NOT isList(_aP_)
			@aFindings + _StzPiaFinding("pia-proposes", "proposes",
				"proposes is a block holding prompt, input, into and structure.")
			return
		ok

		_cPrompt_ = ""
		_cInput_ = ""
		_cInto_ = ""
		_aStruct_ = []
		_nBudget_ = 1
		_nRetries_ = 0
		_nMax_ = 128

		_n_ = len(_aP_)
		for _i_ = 1 to _n_
			_k_ = StzLower(ring_trim("" + _aP_[_i_][1]))
			if ring_find(StzPiaProposesKeys(), _k_) = 0
				@aFindings + _StzPiaFinding("pia-unknown-key", "proposes." + _k_,
					"'" + _k_ + "' is not a proposes key; the whole of it is " +
					StzJoinWith(StzPiaProposesKeys(), ", ") + ".")
				loop
			ok
			if _k_ = "prompt"
				_cPrompt_ = ring_trim("" + _aP_[_i_][2])
			but _k_ = "input"
				_cInput_ = ring_trim("" + _aP_[_i_][2])
			but _k_ = "into"
				_cInto_ = StzLower(ring_trim("" + _aP_[_i_][2]))
			but _k_ = "budget"
				_nBudget_ = 0 + ring_trim("" + _aP_[_i_][2])
			but _k_ = "retries"
				_nRetries_ = 0 + ring_trim("" + _aP_[_i_][2])
			but _k_ = "maxtokens"
				_nMax_ = 0 + ring_trim("" + _aP_[_i_][2])
			else
				_aStruct_ = _aP_[_i_][2]
			ok
		next

		if _cPrompt_ = ""
			@aFindings + _StzPiaFinding("pia-proposes", "proposes.prompt",
				"a proposer needs a prompt; '{input}' in it is where the " +
				"input goes.")
		ok
		if NOT isList(_aStruct_) or len(_aStruct_) = 0
			@aFindings + _StzPiaFinding("pia-proposes", "proposes.structure",
				"a proposer must declare the structure it is held to -- the " +
				"same field declarations stzOutputSchema judges.")
			_aStruct_ = []
		else
			_aStruct_ = This._NormalizeStructure(_aStruct_)
			# THE STRUCTURE IS JUDGED HERE, BY ITS OWN COURT, AT LOAD.
			# stzOutputSchema raises on a bad declaration -- which is right,
			# and which would otherwise happen inside ToAgent() long after
			# anybody was reading. Compiling it now turns that raise into a
			# refusal that names the file.
			try
				StzOutputSchemaQ(_aStruct_)
			catch
				@aFindings + _StzPiaFinding("pia-proposes", "proposes.structure",
					"the declared structure was refused by stzOutputSchema: " +
					StzLeft(cCatchError, 240))
			done
		ok
		if _cInput_ = ""
			_cInput_ = "always"
		ok
		_aIn_ = This._Clause(_cInput_, "when", "proposes.input")
		if _cInto_ = ""
			_cInto_ = @cName
		ok
		if _nBudget_ < 1
			@aFindings + _StzPiaFinding("pia-proposes", "proposes.budget",
				"a budget is mandatory and positive -- no silent spend.")
			_nBudget_ = 1
		ok

		@aProposes = [ :prompt = _cPrompt_, :input = _aIn_, :into = _cInto_,
			       :structure = _aStruct_, :budget = _nBudget_,
			       :retries = _nRetries_, :maxtokens = _nMax_ ]

	# THE ONE PLACE THE FILE'S NOTATION DIFFERS FROM THE API's, and it is
	# a translation rather than a dialect: a closed enumeration reads
	# better on one line in a file --
	#
	#     choices: positive, negative
	#
	# -- while stzOutputSchema wants the list it always wanted. Both forms
	# are accepted here and BOTH become the same list; the indented
	# `- positive` form is passed through untouched. Nothing about the
	# schema vocabulary is redefined, which is the boundary this had to
	# respect.
	def _NormalizeStructure(paStruct)
		_aOut_ = []
		_n_ = len(paStruct)
		for _i_ = 1 to _n_
			_aF_ = paStruct[_i_]
			if NOT isList(_aF_)
				_aOut_ + _aF_
				loop
			ok
			_aNew_ = []
			_m_ = len(_aF_)
			for _j_ = 1 to _m_
				_k_ = StzLower(ring_trim("" + _aF_[_j_][1]))
				_v_ = _aF_[_j_][2]
				# `_aPick_` and not `_aC_`: RING FOLDS CASE, so `_ac_` and
				# `_aC_` are ONE variable -- naming the result `_aC_` here
				# emptied the very list it was reading, and the split
				# silently produced nothing. Two locals in one method whose
				# names differ only by case are one local.
				if (_k_ = "choices" or _k_ = "oneof") and NOT isList(_v_)
					_acParts_ = StzSplit("" + _v_, ",")
					_aPick_ = []
					_nParts_ = len(_acParts_)
					for _q_ = 1 to _nParts_
						_w_ = ring_trim(_acParts_[_q_])
						if _w_ != ""
							_aPick_ + _w_
						ok
					next
					_v_ = _aPick_
				ok
				_aNew_ + [ _aF_[_j_][1], _v_ ]
			next
			_aOut_ + _aNew_
		next
		return _aOut_

	# ONE RULE, TWO DOORS, SAME WORDS. stzAgentGraph.Grant refuses to give
	# an llm actor the 'effectful' capability at the moment of expression.
	# A declaration IS a moment of expression, so the same refusal stands
	# here in the same sentence, quoted rather than paraphrased -- a rule
	# restated in different words is two rules a reader must reconcile.
	def _JudgeLlmIsNotEffectful()
		if @cKind != "llm"
			return
		ok
		_n_ = len(@aSkills)
		for _i_ = 1 to _n_
			if @aSkills[_i_][:effect] != ""
				@aFindings + _StzPiaFinding("no-llm-effectful",
					"skills." + @aSkills[_i_][:name] + ".effect",
					"REFUSED: granting 'effectful' to llm actor '" + @cName +
					"' -- an LLM proposes, only a pi-gate commits " +
					"(no-llm-effectful, enforced at CONSTRUCTION, not merely " +
					"audited).")
			ok
			if @aSkills[_i_][:does][:verb] != "propose" and
			   @aSkills[_i_][:does][:verb] != ""
				@aFindings + _StzPiaFinding("no-llm-effectful",
					"skills." + @aSkills[_i_][:name] + ".does",
					"an llm actor's skills PROPOSE and nothing else; '" +
					@aSkills[_i_][:does][:verb] + "' writes the world. " +
					"Give the effect to a pi agent and let this one propose " +
					"into its memory.")
			ok
		next

	#-- from declaration to running agent ------------------------------

	# The valid declaration, built onto the classes that already exist.
	# Nothing new runs; this only assembles.
	def ToAgent()
		if @bValid = 0
			stzraise("stzAgentDeclaration.ToAgent: this declaration was " +
				"REFUSED and will not become an agent." + char(10) +
				This.CiteFindings())
		ok
		if @cKind = "llm"
			return This._ToLlmAgent()
		ok
		return This._ToPiAgent()

	# THE ONE RING RULE THIS BUILDER MUST NOT FORGET, and it cost a
	# debugging round: NEVER HOLD MemoryQ() IN A LOCAL AND WRITE THROUGH
	# IT. Ring copies an object on ASSIGNMENT, so `oMem = oAg.MemoryQ()`
	# then `oMem.Learn(...)` writes into a copy -- the local sees the fact
	# and the agent never does. The CHAINED form
	# `oAg.MemoryQ().Learn(...)` reaches the agent's own memory, because
	# the temporary is never assigned. Measured both ways; the seeded
	# facts below are written chained for exactly that reason.
	#
	# stzGovernance is immune to this and it is worth knowing why rather
	# than copying the habit blindly: its state lives in a process table
	# keyed by an id that survives a copy, which is what its own comment
	# says it is for. stzAgentMemory holds its graph directly, so it does
	# not. Passing memory as a PARAMETER is fine either way -- Ring passes
	# objects to functions by reference, which is why a skill's clause can
	# write through the poMemory it is handed.
	def _ToPiAgent()
		_oAg_ = new stzDeclaredPIAgent(@cName)
		_oAg_.SetDeclared(@cCoverage, @cRev)

		_n_ = len(@aMemory)
		for _i_ = 1 to _n_
			_oAg_.MemoryQ().Learn(@aMemory[_i_][1], @aMemory[_i_][2], @aMemory[_i_][3])
		next

		_aR_ = @aGov[:risks]
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			_oAg_.GovernanceQ().DeclareRisk(_aR_[_i_][1], _aR_[_i_][2])
		next
		_aG_ = @aGov[:grants]
		_n_ = len(_aG_)
		for _i_ = 1 to _n_
			_oAg_.GovernanceQ().GrantPermission(@cName, _aG_[_i_])
		next
		if @aGov[:authority] != ""
			_oAg_.GovernanceQ().SetAuthority(@cName, @aGov[:authority])
		ok

		_n_ = len(@aSkills)
		for _i_ = 1 to _n_
			_oSk_ = new stzDeclaredSkill(@aSkills[_i_][:name])
			_oSk_.SetClauses(@aSkills[_i_][:when], @aSkills[_i_][:does],
				@aSkills[_i_][:verify])
			if @aSkills[_i_][:effect] != ""
				_oAg_.AddGovernedSkill(_oSk_, @aSkills[_i_][:effect])
			else
				_oAg_.AddSkill(_oSk_)
			ok
		next
		return _oAg_

	def _ToLlmAgent()
		_oAg_ = new stzDeclaredLLMAgent(@cName)
		_oAg_.SetDeclared(@cCoverage, @cRev)
		_n_ = len(@aMemory)
		for _i_ = 1 to _n_
			_oAg_.MemoryQ().Learn(@aMemory[_i_][1], @aMemory[_i_][2], @aMemory[_i_][3])
		next
		_oAg_.SetProposal(@aProposes)
		return _oAg_

#=====================================================================#
#  WHAT A DECLARATION BECOMES                                          #
#=====================================================================#
/*
	THREE SMALL SUBCLASSES, AND DELIBERATELY NO FOURTH RUNTIME. A
	declared skill is an stzAgentSkill that carries its clauses AS DATA
	and interprets them; a declared agent is an stzPIAgent (or
	stzLLMAgent) that also answers for its own coverage and reversibility.
	Everything else -- the cycle, the governance gate, the trace, the
	host, the engine loop -- is the runtime that already existed.

	WHY DATA AND NOT A CLOSURE, which is the question a reader will ask
	first: Ring's anonymous functions capture nothing, so a clause read
	out of a file cannot become a closure over the values it was read
	with. An OBJECT can hold them. So a declared skill overrides
	PreconditionHolds() and Apply() and reads its own attributes -- the
	same interface stzPIAgent already calls, with no change to stzPIAgent
	at all.
*/

class stzDeclaredSkill from stzAgentSkill

	@aWhen = []
	@aDoes = []
	@aVerify = []

	def SetClauses(paWhen, paDoes, paVerify)
		@aWhen = paWhen
		@aDoes = paDoes
		@aVerify = paVerify
		return This

	def WhenClause()
		return @aWhen

	def DoesClause()
		return @aDoes

	def VerifyClause()
		return @aVerify

	def PreconditionHolds(poMemory)
		if len(@aWhen) = 0
			return 1
		ok
		return This._Truth(@aWhen, poMemory)

	# Same [ :ran, :verified, :why ] contract as the closure-built skill,
	# so stzPIAgent.Cycle() cannot tell the two apart -- which is the
	# point of a front-end.
	def Apply(poMemory)
		if This.PreconditionHolds(poMemory) = 0
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + This.Name_() + "' skipped: precondition not met" ]
		ok
		This._Act(@aDoes, poMemory)
		_bV_ = 1
		if len(@aVerify) > 0
			if @aVerify[:verb] != ""
				_bV_ = This._Truth(@aVerify, poMemory)
			ok
		ok
		if _bV_ = 1
			return [ :ran = 1, :verified = 1,
				:why = "skill '" + This.Name_() + "' ran and VERIFIED" ]
		ok
		return [ :ran = 1, :verified = 0,
			:why = "skill '" + This.Name_() + "' ran but FAILED verification" ]

	def _Truth(paClause, poMemory)
		_v_ = paClause[:verb]
		_a_ = paClause[:args]
		if _v_ = "always"
			return 1
		ok
		if _v_ = "fact"
			return poMemory.Fact(_a_[1], _a_[2], _a_[3])
		ok
		if _v_ = "no-fact"
			return 1 - poMemory.Fact(_a_[1], _a_[2], _a_[3])
		ok
		if _v_ = "recall"
			if len(poMemory.Recall(_a_[1], _a_[2])) > 0
				return 1
			ok
			return 0
		ok
		if _v_ = "ring"
			_cF_ = _a_[1]
			if call _cF_(poMemory)
				return 1
			ok
			return 0
		ok
		return 0

	def _Act(paClause, poMemory)
		_v_ = paClause[:verb]
		_a_ = paClause[:args]
		if _v_ = "learn"
			poMemory.Learn(_a_[1], _a_[2], _a_[3])
		but _v_ = "forget"
			poMemory.Forget(_a_[1], _a_[2], _a_[3])
		but _v_ = "ring"
			_cF_ = _a_[1]
			call _cF_(poMemory)
		ok
		return This

# A pi agent that came from a file. The ONLY thing it adds is the pair of
# answers the engine loop's law-18 gate asks for -- so a declared agent
# needs no separate Declare() call on the host: the file already said it.
class stzDeclaredPIAgent from stzPIAgent

	@cCoverage = ""
	@cRevClass = ""

	def SetDeclared(pcCoverage, pcReversibility)
		@cCoverage = "" + pcCoverage
		@cRevClass = "" + pcReversibility
		return This

	def CoverageStatement()
		return @cCoverage

	def ReversibilityClass()
		return @cRevClass

	def Kind()
		return "pi_actor"

	def Capabilities()
		return [ "effectful", "compute", "sensing" ]

	def HoldsEffectful()
		return 1

# THE PROPOSER, AND WHAT IT MAY DO ON A TICK: read its input from memory,
# ask its stzLLMFunction for a STRUCTURED answer, and LEARN the result as
# facts. That is the whole of it. It writes into its own memory and
# nowhere else, it holds no effectful capability, and every field it
# learns had to satisfy the structure the file declared -- so a proposal
# that does not parse leaves no trace of itself in memory at all.
class stzDeclaredLLMAgent from stzLLMAgent

	@cCoverage = ""
	@cRevClass = ""
	@aProp = []
	@oProposer = ""       # NOT @oFn: stzLLMAgent already owns that name,
	                      # and two attributes of one name in a class and
	                      # its parent is a question nobody should have to
	                      # answer while reading a tick
	@cWhyTick = ""
	@nProposals = 0

	def SetDeclared(pcCoverage, pcReversibility)
		@cCoverage = "" + pcCoverage
		@cRevClass = "" + pcReversibility
		return This

	def CoverageStatement()
		return @cCoverage

	def ReversibilityClass()
		return @cRevClass

	def SetProposal(paProposes)
		@aProp = paProposes
		_o_ = new stzLLMFunction(This.Name_())
		_o_.SetPrompt(paProposes[:prompt])
		_o_.ReturnsStructure(paProposes[:structure])
		_o_.SetMaxTokens(paProposes[:maxtokens])
		_o_.Budget(paProposes[:budget])
		_o_.SetRetries(paProposes[:retries])
		@oProposer = _o_
		This.SetSkillFrom(_o_)
		return This

	# The offline door, and it is a METHOD rather than something a caller
	# does through FunctionQ(): Ring copies an object on assignment, so
	# `oF = oAg.FunctionQ()` then `oF.SeedAnswer(...)` seeds a copy the
	# agent will never read. Seeding from inside the class writes the
	# agent's own function, which is the only version that ticks.
	def SeedProposal(pcInput, pValue)
		if @oProposer = ""
			stzraise("stzDeclaredLLMAgent: declare the proposal first.")
		ok
		@oProposer.SeedAnswer(pcInput, pValue)
		return This

	# The live function, so a caller can seed it, fake it or read its
	# budget BEFORE the agent is handed to a host. After the handoff the
	# host's copy is the one that ticks -- the same rule stzAgentHost
	# already states for every supervised agent.
	def FunctionQ()
		return @oProposer

	def ProposalsMade()
		return @nProposals

	def WhyLastTick()
		return @cWhyTick

	# ONE TICK. Returns 1 when a proposal was made AND validated, 0
	# otherwise -- and 0 always says why rather than passing for quiet.
	def Cycle()
		if len(@aProp) = 0
			@cWhyTick = "no proposal is declared"
			return 0
		ok
		_cIn_ = This._Input()
		if _cIn_ = ""
			@cWhyTick = "nothing to propose about: the input clause found no fact"
			return 0
		ok
		_aV_ = ""
		try
			_aV_ = @oProposer.Call_(_cIn_)
		catch
			@cWhyTick = "the proposal was REFUSED: " + StzLeft(cCatchError, 200)
			return 0
		done
		if NOT isList(_aV_)
			@cWhyTick = "the proposal did not come back as a structure"
			return 0
		ok
		# chained, never held -- see the note on _ToPiAgent
		_cInto_ = @aProp[:into]
		_n_ = len(_aV_)
		for _i_ = 1 to _n_
			This.MemoryQ().Learn(_cInto_, "" + _aV_[_i_][1], "" + _aV_[_i_][2])
		next
		@nProposals++
		@cWhyTick = "proposed " + _n_ + " field(s) into '" + _cInto_ +
			"' -- a candidate, never an effect"
		return 1

	def _Input()
		_aC_ = @aProp[:input]
		if _aC_[:verb] = "recall"
			_ac_ = This.MemoryQ().Recall(_aC_[:args][1], _aC_[:args][2])
			if len(_ac_) = 0
				return ""
			ok
			return "" + _ac_[1]
		ok
		if _aC_[:verb] = "ring"
			_cF_ = _aC_[:args][1]
			return "" + call _cF_(This.MemoryQ())
		ok
		return This.Name_()
