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
