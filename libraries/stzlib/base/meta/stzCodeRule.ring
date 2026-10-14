#===========================================================#
#  STZCODERULE / STZCODERULESET -- code rules ARE graph rules #
#===========================================================#

/*--- A code rule is a graph rule over a code graph (graph-rules plan, phase 3)

The plan's thesis, made literal for the first instance: `stzCodeRule` IS-A
`stzGraphRule`, and `stzCodeRuleSet` IS-A `stzGraphRuleSet`. The old
`stzCodeRules.ring` was a 106-line TEXT SCANNER -- it read source line by line
and prefix-matched "def len(". These rules instead query a `stzCodeGraph`: real
method definitions, real call edges. Three of the four house rules move here;
the fourth (q-returns-object) stays a text pass in StzCheckCode because the code
graph does not model return statements (an honest limit, not a rule on a graph).

Each rule is a CHECKER over the code graph (not a node-property clause -- the
code graph keeps methods/functions/calls in LISTS, not as graph nodes), and its
finding puts the LINE in :where, so StzCheckCode maps it straight to :line and
keeps its frozen [ :rule, :line, :severity, :message ] shape.

WHERE IT LOADS: after graph/stzGraphRule.ring (its parent) even though it lives
in meta/ -- StzCheckCode only ever constructs it at RUNTIME, so the meta funcs
that load earlier still resolve it.
*/

func StzCodeRuleQ(pcName)
	return new stzCodeRule(pcName)

func StzCodeRuleSetQ()
	return new stzCodeRuleSet()

# The whole-project set: the snippet-safe rules PLUS the two that need the full
# CALL graph (no-dead-code, no-cyclic-calls). Meaningless on a snippet -- every
# method looks dead when nothing in the fragment calls it -- so they live here,
# for StzCheckProject only.
func StzCodeProjectRuleSetQ()
	return new stzCodeProjectRuleSet()

func StzCodeDeepRuleSetQ()
	return new stzCodeDeepRuleSet()

# TRUE when a method name (minus its trailing Q) begins with an unambiguous
# MUTATOR verb -- Set/Add/From/... The code graph has no method BODIES, so it
# cannot tell a mutator (needs a plain twin) from an object-accessor (ReactorQ,
# GraphQ -- a NOUN, legitimately Q-only). This verb list is how q-has-plain-twin
# stays precise: it flags SetLevelQ / AddSourceQ but never a noun accessor.
func _StzIsMutatorVerb(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	_aVerbs_ = [ "set", "add", "remove", "clear", "delete", "insert", "append",
	             "replace", "rename", "move", "register", "rotate", "grant",
	             "attach", "bind", "connect", "enable", "disable", "reset",
	             "update", "expose", "mount", "unmount", "load", "save", "target",
	             "optimize", "spawn", "emit", "send", "from", "use", "push", "pop" ]
	_n_ = len(_aVerbs_)
	for _i_ = 1 to _n_
		if StzLeft(_c_, len(_aVerbs_[_i_])) = _aVerbs_[_i_]
			return 1
		ok
	next
	return 0

# TRUE when class pcClass defines a method named pcName (case-insensitive).
# aMethods rows are [ class, method, line ].
func _StzClassHasMethod(paMethods, pcClass, pcName)
	_cCls_ = StzLower("" + pcClass)
	_cM_ = StzLower("" + pcName)
	_n_ = len(paMethods)
	for _i_ = 1 to _n_
		if StzLower("" + paMethods[_i_][1]) = _cCls_ and StzLower("" + paMethods[_i_][2]) = _cM_
			return 1
		ok
	next
	return 0

# Holds one code rule, a graph rule over a code graph, whose finding carries the line of the offending code.
#
# A code rule is a stzGraphRule in the code domain. Its checker queries a stzCodeGraph, which models
# real method definitions and real call edges, instead of scanning text, so a comment that says def
# len is not a method and a method definition named substr is not a call. The house rules are
# declared in stzCodeRuleSet, and StzCheckCode runs them over source.
#
#   receiver   o1 = new stzCodeRule("no-len-method")
#   example    ? o1.Name()
#              #--> no-len-method
#              ? o1.Domain()
#              #--> code
#   see        stzCodeRuleSet, stzGraphRule, stzCodeGraph
class stzCodeRule from stzGraphRule
	# Builds a code rule of that name in the code domain; it is a graph rule whose checker queries a code graph.
	#
	#   pcName     the rule's name
	#   returns    nothing; the object is built
	#   see        stzCodeRuleSet, stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("code")


# Holds the house rules of the library that a code graph can check, as one graph rule set in the code domain.
#
# Five rules are loaded: no-len-method, no-aggressive-verbs, engine-first, q-has-plain-twin and no-
# case-collision. The sixth house rule, q-returns-object, needs a model of return statements that
# the code graph does not have, so StzCheckCode runs it as a text pass and merges the findings. The
# project set adds no-dead-code, and the deep set adds the slow no-cyclic-calls.
#
#   receiver   o1 = new stzCodeRuleSet()
#   example    ? o1.Name()
#              #--> softanza-house-rules
#              ? o1.NumberOfRules()
#              #--> 5
#              ? o1.RuleNames()[1]
#              #--> no-len-method
#   see        stzCodeProjectRuleSet, stzCodeDeepRuleSet, stzCodeRule
class stzCodeRuleSet from stzGraphRuleSet
	# Builds the house rule set, named softanza-house-rules, loaded with the five rules that a code graph can check.
	#
	#   returns    nothing; the object is built
	#   note       the rules are no-len-method, no-aggressive-verbs, engine-first, q-has-plain-twin
	#              and no-case-collision
	#   see        stzCodeProjectRuleSet, stzCodeRule
	def init()
		super.init("softanza-house-rules")
		This.SetDomainQ("code")
		This._LoadCodeRules()

	# The graph-portable house rules. q-returns-object is NOT here -- it needs a
	# return-statement model the code graph does not have, so StzCheckCode runs
	# it as a text pass and merges. See stzCodeRules.ring.
	def _LoadCodeRules()
		# no-len-method (error) -- a real method DEFINITION named len, on any
		# class. Structural: a comment or string saying "def len" is not a
		# method, so it is never flagged (a false-positive the text scan risks).
		_oLen_ = new stzCodeRule("no-len-method")
		_oLen_.SetSeverityQ("error")
		_oLen_.SetMessageQ("never define Len() on a class -- it shadows Ring's builtin")
		# EVERY METHOD DEFINITION, and the boundary is that a FUNCTION is
		# not one. `func len(...)` outside a class shadows nothing, and
		# this rule has never claimed it does -- but nothing said so, so
		# a reader could not tell the exclusion from an oversight.
		_oLen_.SetOrderQ(10)
		_oLen_.SetReadsQ([ "code.methods" ])
		_oLen_.GovernsQ(func oCG {
			_r_ = []
			_a_ = oCG.MethodsWithLines()
			for _i_ = 1 to len(_a_)
				_r_ + ("method:" + StzLower("" + _a_[_i_][1]) + "." +
					StzLower("" + _a_[_i_][2]))
			next
			return _r_
		})
		_oLen_.ExcludesQ(func oCG {
			_r_ = []
			_a_ = oCG.FunctionsWithLines()
			for _i_ = 1 to len(_a_)
				_r_ + ("function:" + StzLower("" + _a_[_i_][1]))
			next
			return _r_
		})
		_oLen_.UseCheckerQ(func oCG {
			_aOut_ = []
			_aM_ = oCG.MethodsWithLines()
			_n_ = len(_aM_)
			for _i_ = 1 to _n_
				if StzLower("" + _aM_[_i_][2]) = "len"
					_aOut_ + [ :where = _aM_[_i_][3],
						:message = "never define Len() on class '" + _aM_[_i_][1] +
						"' -- it shadows Ring's builtin and breaks every caller; use Count()/Size()/NumberOf...()" ]
				ok
			next
			return _aOut_
		})
		This.AddRule(_oLen_)

		# no-aggressive-verbs (warning) -- a method OR function whose name starts
		# with Kill/Destroy. Over real definitions, not text.
		_oVerb_ = new stzCodeRule("no-aggressive-verbs")
		_oVerb_.SetSeverityQ("warning")
		_oVerb_.SetMessageQ("aggressive verb in a name -- prefer Remove/Delete/Dispose/Clear/Close")
		# BOTH methods and functions -- this rule is about TONE, which a
		# free function carries as much as a method does. Declaring the
		# union is what distinguishes it from no-len-method above, whose
		# scope is deliberately narrower for a structural reason.
		_oVerb_.SetOrderQ(20)
		_oVerb_.SetReadsQ([ "code.methods", "code.functions" ])
		_oVerb_.DeclareUniversalQ("every name a reader will see is in " +
			"scope, because tone is a property of the vocabulary and not " +
			"of where a name is declared -- there is no definition this " +
			"rule could legitimately decline to look at")
		_oVerb_.GovernsQ(func oCG {
			_r_ = []
			_a_ = oCG.MethodsWithLines()
			for _i_ = 1 to len(_a_)
				_r_ + ("method:" + StzLower("" + _a_[_i_][1]) + "." +
					StzLower("" + _a_[_i_][2]))
			next
			_b_ = oCG.FunctionsWithLines()
			for _i_ = 1 to len(_b_)
				_r_ + ("function:" + StzLower("" + _b_[_i_][1]))
			next
			return _r_
		})
		_oVerb_.UseCheckerQ(func oCG {
			_aOut_ = []
			_aM_ = oCG.MethodsWithLines()
			_n_ = len(_aM_)
			for _i_ = 1 to _n_
				_nm_ = StzLower("" + _aM_[_i_][2])
				if StzLeft(_nm_, 4) = "kill" or StzLeft(_nm_, 7) = "destroy"
					_aOut_ + [ :where = _aM_[_i_][3],
						:message = "aggressive verb in method '" + _aM_[_i_][2] +
						"' -- prefer Remove/Delete/Dispose/Clear/Close (Softanza tone)" ]
				ok
			next
			_aF_ = oCG.FunctionsWithLines()
			_m_ = len(_aF_)
			for _i_ = 1 to _m_
				_nm_ = StzLower("" + _aF_[_i_][1])
				if StzLeft(_nm_, 4) = "kill" or StzLeft(_nm_, 7) = "destroy"
					_aOut_ + [ :where = _aF_[_i_][2],
						:message = "aggressive verb in function '" + _aF_[_i_][1] +
						"' -- prefer Remove/Delete/Dispose/Clear/Close (Softanza tone)" ]
				ok
			next
			return _aOut_
		})
		This.AddRule(_oVerb_)

		# engine-first (warning) -- a CALL to a byte-oriented Ring builtin
		# (substr/lower/upper). Reads RAW call edges, so `def substr(` (a
		# definition, not a call) is NOT flagged -- the false-positive the text
		# scan of "substr(" has. Needs a Ring code graph (RawCallEntries).
		_oEng_ = new stzCodeRule("engine-first")
		_oEng_.SetSeverityQ("warning")
		_oEng_.SetMessageQ("Ring's substr()/lower()/upper() are byte-oriented (break UTF-8)")
		# CALL SITES, never definitions -- the exclusion the comment above
		# already names as the text scan's false positive. It was a real
		# design decision recorded in prose and nowhere a machine could
		# read it.
		_oEng_.SetOrderQ(30)
		_oEng_.SetReadsQ([ "code.calls" ])
		_oEng_.GovernsQ(func oCG {
			_r_ = []
			_a_ = oCG.RawCallEntries()
			for _i_ = 1 to len(_a_)
				_r_ + ("call:" + StzLower("" + _a_[_i_][3]) + "@" +
					"" + _a_[_i_][4])
			next
			return _r_
		})
		_oEng_.ExcludesQ(func oCG {
			_r_ = []
			_a_ = oCG.FunctionsWithLines()
			for _i_ = 1 to len(_a_)
				_n_ = StzLower("" + _a_[_i_][1])
				if _n_ != "substr" and _n_ != "lower" and _n_ != "upper"
					loop
				ok
				_r_ + ("function:" + _n_)
			next
			return _r_
		})
		_oEng_.UseCheckerQ(func oCG {
			_aOut_ = []
			_aC_ = oCG.RawCallEntries()
			_n_ = len(_aC_)
			for _i_ = 1 to _n_
				_callee_ = StzLower("" + _aC_[_i_][3])
				if _callee_ = "substr" or _callee_ = "lower" or _callee_ = "upper"
					_aOut_ + [ :where = _aC_[_i_][4],
						:message = "Ring's " + _aC_[_i_][3] + "() is byte-oriented (breaks UTF-8) -- " +
						"new code uses StzFind/StzReplace/StzSplit/StzLower/StzUpper (the engine forms)" ]
				ok
			next
			return _aOut_
		})
		This.AddRule(_oEng_)

		# q-has-plain-twin (warning) -- a ...Q() MUTATOR must have a plain twin
		# (Q chains, plain acts). A graph-only rule: it compares a class's whole
		# method set, which a line scan cannot. Warning, not error: the graph has
		# no bodies, so mutator-ness is inferred from the verb prefix -- precise
		# (Set/Add/From...), but a candidate, not proof. This is the rule that
		# would have flagged the 62 Q-only mutators of the naming campaign.
		_oTwin_ = new stzCodeRule("q-has-plain-twin")
		_oTwin_.SetSeverityQ("warning")
		_oTwin_.SetMessageQ("a Q mutator must have a plain twin")
		# ONLY THE Q MUTATORS, and the comment above explains why the set
		# is a candidate rather than a proof: the graph has no bodies, so
		# mutator-ness is inferred from the verb. That uncertainty belongs
		# in the SCOPE, where a reader can see how much of the class the
		# rule actually inspected -- not in the severity, which only says
		# how loudly it complains about what it happened to look at.
		_oTwin_.SetOrderQ(40)
		_oTwin_.SetReadsQ([ "code.methods" ])
		_oTwin_.GovernsQ(func oCG {
			_r_ = []
			_a_ = oCG.MethodsWithLines()
			for _i_ = 1 to len(_a_)
				_m_ = "" + _a_[_i_][2]
				if StzLen(_m_) < 2  loop  ok
				if StzLower(StzRight(_m_, 1)) != "q"  loop  ok
				_r_ + ("method:" + StzLower("" + _a_[_i_][1]) + "." +
					StzLower(_m_))
			next
			return _r_
		})
		_oTwin_.ExcludesQ(func oCG {
			_r_ = []
			_a_ = oCG.MethodsWithLines()
			for _i_ = 1 to len(_a_)
				_m_ = "" + _a_[_i_][2]
				if StzLen(_m_) >= 2 and StzLower(StzRight(_m_, 1)) = "q"
					loop
				ok
				_r_ + ("method:" + StzLower("" + _a_[_i_][1]) + "." +
					StzLower(_m_))
			next
			return _r_
		})
		_oTwin_.UseCheckerQ(func oCG {
			_aOut_ = []
			_aM_ = oCG.MethodsWithLines()
			_n_ = len(_aM_)
			for _i_ = 1 to _n_
				_cls_ = _aM_[_i_][1]
				_m_ = _aM_[_i_][2]
				if StzLen(_m_) > 1 and StzLower(StzRight(_m_, 1)) = "q"
					_plain_ = StzLeft(_m_, StzLen(_m_) - 1)
					if _StzIsMutatorVerb(_plain_) and NOT _StzClassHasMethod(_aM_, _cls_, _plain_)
						_aOut_ + [ :where = _aM_[_i_][3],
							:message = "'" + _m_ + "' is a Q mutator with no plain twin '" + _plain_ +
							"' in class '" + _cls_ + "' -- both are required (Q chains, plain acts)" ]
					ok
				ok
			next
			return _aOut_
		})
		This.AddRule(_oTwin_)

		# no-case-collision (error) -- two methods in one class whose names differ
		# ONLY in case. Ring is case-insensitive, so this is a C22 "Function
		# redefinition" that takes the whole file down at load. A graph sees BOTH
		# method nodes and compares them; a line scanner, one line at a time,
		# never can. Keyed accumulation (O(n)) so it scales to a whole project.
		_oCase_ = new stzCodeRule("no-case-collision")
		_oCase_.SetSeverityQ("error")
		_oCase_.SetMessageQ("two names differ only in case -- Ring C22 (case-insensitive)")
		_oCase_.UseCheckerQ(func oCG {
			_aOut_ = []
			_aM_ = oCG.MethodsWithLines()
			_aSeen_ = []      # [ lowerKey, exactSpelling ]
			_n_ = len(_aM_)
			for _i_ = 1 to _n_
				_key_ = StzLower("" + _aM_[_i_][1]) + "|" + StzLower("" + _aM_[_i_][2])
				_idx_ = 0
				_ns_ = len(_aSeen_)
				for _k_ = 1 to _ns_
					if _aSeen_[_k_][1] = _key_
						_idx_ = _k_
						exit
					ok
				next
				if _idx_ = 0
					_aSeen_ + [ _key_, "" + _aM_[_i_][2] ]
				but _aSeen_[_idx_][2] != ("" + _aM_[_i_][2])
					_aOut_ + [ :where = _aM_[_i_][3],
						:message = "method '" + _aM_[_i_][2] + "' collides with '" + _aSeen_[_idx_][2] +
						"' in class '" + _aM_[_i_][1] + "' -- Ring is case-insensitive (C22 redefinition)" ]
				ok
			next
			return _aOut_
		})
		This.AddRule(_oCase_)


# Holds the house rules plus no-dead-code, the set that StzCheckProject runs over a whole directory.
#
# no-dead-code names a defined method or function that no recorded call reaches. It is name-based
# and cannot see a call through a variable, so it reports candidates and not proof; a graph without
# call edges yields nothing. The slow no-cyclic-calls rule is not here, so the set is cheap enough
# for a per-commit gate.
#
#   receiver   o1 = new stzCodeProjectRuleSet()
#   example    ? o1.NumberOfRules()
#              #--> 6
#              ? o1.RuleNames()[6]
#              #--> no-dead-code
#   see        stzCodeRuleSet, stzCodeDeepRuleSet
class stzCodeProjectRuleSet from stzCodeRuleSet
	# Builds the whole-project rule set: the five house rules plus no-dead-code, which needs the call graph of the whole project.
	#
	#   returns    nothing; the object is built
	#   note       it leaves out no-cyclic-calls on purpose, measured at about 36 seconds over
	#              base/graph
	#   see        stzCodeDeepRuleSet, stzCodeRuleSet
	def init()
		super.init()
		This._LoadProjectRules()

	def _LoadProjectRules()
		# no-dead-code (warning) -- a defined method/function no recorded call
		# reaches. Name-based and honest about dynamic dispatch (a call through a
		# variable can't be seen), so it names CANDIDATES, not proof. Needs call
		# edges; a graph without them yields nothing rather than raising.
		_oDead_ = new stzCodeRule("no-dead-code")
		_oDead_.SetSeverityQ("warning")
		_oDead_.SetMessageQ("a defined name that no recorded call reaches")
		_oDead_.UseCheckerQ(func oCG {
			_aOut_ = []
			if NOT oCG.HasCallEdges()
				return _aOut_
			ok
			# the Ring backend returns records [ :class, :method, :file, :line ]
			_aDead_ = oCG.DeadCode()
			_n_ = len(_aDead_)
			for _i_ = 1 to _n_
				_d_ = _aDead_[_i_]
				_aOut_ + [ :where = _d_[:line],
					:message = "'" + _d_[:class] + "." + _d_[:method] +
					"' is defined but no recorded call reaches it -- dead-code candidate" ]
			next
			return _aOut_
		})
		This.AddRule(_oDead_)


# Holds the project rules plus no-cyclic-calls, the opt-in set for a deeper and slower audit.
#
# no-cyclic-calls needs call edges and finds a pair of methods in one class that call each other.
# Its cost grows with the square of the calls times the methods, so it is opt-in through
# StzCheckProjectDeep, and the default gate documents that it omits it.
#
#   receiver   o1 = new stzCodeDeepRuleSet()
#   example    ? o1.NumberOfRules()
#              #--> 7
#              ? o1.RuleNames()[7]
#              #--> no-cyclic-calls
#   see        stzCodeProjectRuleSet, stzCodeRuleSet
class stzCodeDeepRuleSet from stzCodeProjectRuleSet
	# Builds the deep audit rule set: the project rules plus no-cyclic-calls, which reports two methods of a class that call each other.
	#
	#   returns    nothing; the object is built
	#   note       the extra rule is slow, measured at about 36 seconds over base/graph, so it suits
	#              a periodic audit and not a per-commit gate
	#   see        stzCodeProjectRuleSet
	def init()
		super.init()
		This._LoadDeepRules()

	def _LoadDeepRules()
		# no-cyclic-calls (warning) -- two methods in a class that call each other
		# (mutual recursion). Needs call edges. Slow; opt-in.
		_oCyc_ = new stzCodeRule("no-cyclic-calls")
		_oCyc_.SetSeverityQ("warning")
		_oCyc_.SetMessageQ("a call cycle")
		_oCyc_.UseCheckerQ(func oCG {
			_aOut_ = []
			if NOT oCG.HasCallEdges()
				return _aOut_
			ok
			# the Ring backend returns records [ :class, :cycle = [ a, b ] ]
			_aCyc_ = oCG.CyclicCalls()
			_n_ = len(_aCyc_)
			for _i_ = 1 to _n_
				_c_ = _aCyc_[_i_]
				_aOut_ + [ :where = _c_[:class],
					:message = "methods '" + _c_[:cycle][1] + "' and '" + _c_[:cycle][2] +
					"' in class '" + _c_[:class] + "' call each other -- a cycle" ]
			next
			return _aOut_
		})
		This.AddRule(_oCyc_)
