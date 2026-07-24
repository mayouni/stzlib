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
			return TRUE
		ok
	next
	return FALSE

# TRUE when class pcClass defines a method named pcName (case-insensitive).
# aMethods rows are [ class, method, line ].
func _StzClassHasMethod(paMethods, pcClass, pcName)
	_cCls_ = StzLower("" + pcClass)
	_cM_ = StzLower("" + pcName)
	_n_ = len(paMethods)
	for _i_ = 1 to _n_
		if StzLower("" + paMethods[_i_][1]) = _cCls_ and StzLower("" + paMethods[_i_][2]) = _cM_
			return TRUE
		ok
	next
	return FALSE

class stzCodeRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("code")


class stzCodeRuleSet from stzGraphRuleSet
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


# The whole-project rule set: the snippet-safe rules + no-dead-code (which needs
# the full call graph). Used by StzCheckProject. Deliberately EXCLUDES
# no-cyclic-calls -- measured at ~36s over base/graph alone (the code graph's
# CyclicCalls is O(calls^2 . methods)), which is too slow for a per-commit gate.
# That rule lives in stzCodeDeepRuleSet below, an opt-in for a deeper audit.
class stzCodeProjectRuleSet from stzCodeRuleSet
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


# The DEEP set: the project set PLUS no-cyclic-calls, which is expensive
# (measured ~36s over base/graph -- the code graph's CyclicCalls is O(calls^2 .
# methods)). Opt-in via StzCheckProjectDeep, for a periodic audit rather than a
# per-commit gate. No silent cap: the default gate documents that it omits this.
class stzCodeDeepRuleSet from stzCodeProjectRuleSet
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
