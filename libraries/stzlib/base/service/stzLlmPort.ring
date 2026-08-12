#================================================================#
#  STZLLMPORT -- the generative port (replay / scripted / local)     #
#================================================================#

/*--- Phase 5: mostly PROMOTION, and one honest limit.

An LLM port is **"any object with `Complete(prompt)`"** returning
`[ :ok, :text, :from ]`. Softanza already had most of the pieces; this file names
the contract and puts them behind it.

WHAT WAS ALREADY THERE:
  * `stzLLMFunction` caches a validated answer per input hash and can be seeded
    (`SeedAnswer`) -- a record-replay primitive, already described in its own
    comments as "memoized: deterministic, free";
  * `stzDLM` answers from a domain knowledge graph -- deterministic, local, and
    genuinely reasoning over facts you gave it;
  * the neural tier runs a local GGUF model through vendored ggml -- a real, small
    model on your own machine.

THE HONEST LIMIT, stated first because it governs everything else: **frontier-model
QUALITY cannot be virtualized.** The other ports in this plane substitute
faithfully -- a sandbox mail sink really is mail-shaped, sqlite really is a
database. Nothing local is GPT-class. So what a generative sandbox buys you is not
fidelity but three other things, each real:

  DETERMINISM -- replay a recorded answer, so a test that depends on model output
    stops being flaky and starts being a test.
  COST -- zero, and *measurable*: this sandbox counts calls and approximate tokens,
    so "this feature must not cost more than two calls" becomes an assertion
    instead of a hope.
  OFFLINE -- no key, no network, no rate limit in CI.

Use it for the SHAPE of your pipeline: prompts assembled correctly, answers parsed
correctly, retries bounded, cost bounded. Judge model QUALITY against the real
thing, deliberately, as its own activity -- and note the plan's caveat that
recorded answers DRIFT, so a replay suite needs re-recording and contract tests.

    oLlm = new stzLlmSandbox()
    oLlm.WhenPromptContainsQ("summarise", "A short summary.")
    oLlm.SeedAnswerQ("What is 2+2?", "4")
    oLlm.Complete("What is 2+2?")            # -> replayed, free, deterministic
    oLlm.NumberOfCalls()                     # -> assert your cost

The LIVE side is a frontier-API client (Anthropic, OpenAI, a hosted endpoint)
behind the same one method, and it is infra-gated: it needs a key and a network.
The contract is here; the registry refuses to let a sandbox ship in its place.
*/

# shared across copies -- see the Ring note in stzServiceRegistry:
# [ [ id, seeds, rules, journal, strict, fallback ], ... ]
$aStzLlmSandboxes = []
$nStzLlmSandboxSeq = 0

func StzLlmSandboxQ()
	return new stzLlmSandbox()

func StzDlmSourceQ(poDlm)
	return new stzDlmSource(poDlm)


  #=========================================================#
 #  LLM SANDBOX -- replay + scripted, with cost accounting    #
#=========================================================#

class stzLlmSandbox from stzObject

	@nId = 0

	def init()
		$nStzLlmSandboxSeq = $nStzLlmSandboxSeq + 1
		@nId = $nStzLlmSandboxSeq
		$aStzLlmSandboxes + [ @nId, [], [], [], 1, "" ]

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	  #-- REPLAY: an exact answer for an exact prompt -----------------------

	# Keyed by a hash of the prompt, exactly as stzLLMFunction keys its cache. The
	# same prompt always gets the same answer, which is what makes a test a test.
	def SeedAnswer(pcPrompt, pcText)
		This.SeedAnswerQ(pcPrompt, pcText)

	def SeedAnswerQ(pcPrompt, pcText)
		_i_ = This._Slot()
		_k_ = This.PromptKey(pcPrompt)
		_n_ = len($aStzLlmSandboxes[_i_][2])
		for _j_ = 1 to _n_
			if $aStzLlmSandboxes[_i_][2][_j_][1] = _k_
				$aStzLlmSandboxes[_i_][2][_j_] = [ _k_, "" + pcText ]
				return This
			ok
		next
		$aStzLlmSandboxes[_i_][2] + [ _k_, "" + pcText ]
		return This

	# Call a real model ONCE and keep what it said. poClient is any object with
	# Complete(prompt) -- so the recording path is testable with no key and no
	# network, by handing in any conforming stand-in.
	def RecordFrom(poClient, pcPrompt)
		_r_ = poClient.Complete(pcPrompt)
		This.SeedAnswerQ(pcPrompt, _r_[:text])
		return _r_

	def PromptKey(pcPrompt)
		return StzEngineCryptoSha256("" + pcPrompt)

	def HasAnswerFor(pcPrompt)
		return This._SeedIndex( This.PromptKey(pcPrompt) ) > 0

	def NumberOfSeededAnswers()
		return len($aStzLlmSandboxes[This._Slot()][2])

	  #-- SCRIPTED: a rule for a family of prompts --------------------------

	# Match on a fragment of the prompt, so one rule covers a whole family
	# ("anything asking for a summary"). First matching rule wins.
	def WhenPromptContains(pcFragment, pcText)
		This.WhenPromptContainsQ(pcFragment, pcText)

	def WhenPromptContainsQ(pcFragment, pcText)
		_i_ = This._Slot()
		$aStzLlmSandboxes[_i_][3] + [ StzLower("" + pcFragment), "" + pcText ]
		return This

	def NumberOfRules()
		return len($aStzLlmSandboxes[This._Slot()][3])

	# A catch-all answer, for pipelines where the text does not matter and only the
	# SHAPE does. Setting one turns strictness off for unmatched prompts.
	def SetFallback(pcText)
		This.SetFallbackQ(pcText)

	def SetFallbackQ(pcText)
		$aStzLlmSandboxes[This._Slot()][6] = "" + pcText
		return This

	def Fallback()
		return $aStzLlmSandboxes[This._Slot()][6]

	  #-- the PORT contract ------------------------------------------------

	# -> [ :ok, :text, :from ] where :from is :replay, :scripted or :fallback.
	# A SEEDED answer wins over a rule: a recording is what a model actually said,
	# and that beats a rule someone wrote.
	def Complete(pcPrompt)
		_i_ = This._Slot()
		$aStzLlmSandboxes[_i_][4] + [ "" + pcPrompt, len("" + pcPrompt) ]

		_s_ = This._SeedIndex( This.PromptKey(pcPrompt) )
		if _s_ > 0
			return [ :ok = 1, :text = $aStzLlmSandboxes[_i_][2][_s_][2], :from = :replay ]
		ok

		_low_ = StzLower("" + pcPrompt)
		_aRules_ = $aStzLlmSandboxes[_i_][3]
		_n_ = len(_aRules_)
		for _j_ = 1 to _n_
			if StzFindFirst(_aRules_[_j_][1], _low_) > 0
				return [ :ok = 1, :text = _aRules_[_j_][2], :from = :scripted ]
			ok
		next

		if $aStzLlmSandboxes[_i_][6] != ""
			return [ :ok = 1, :text = $aStzLlmSandboxes[_i_][6], :from = :fallback ]
		ok
		if $aStzLlmSandboxes[_i_][5]
			StzRaise("stzLlmSandbox: no seeded answer, rule or fallback for this prompt. " +
			         "Seed it, add a rule, SetFallback, or SetStrict(FALSE).")
		ok
		return [ :ok = 0, :text = "", :from = :miss ]

	def SetStrict(pbOn)
		This.SetStrictQ(pbOn)

	def SetStrictQ(pbOn)
		$aStzLlmSandboxes[This._Slot()][5] = pbOn
		return This

	def IsStrict()
		return $aStzLlmSandboxes[This._Slot()][5]

	  #-- COST: the fee-free promise, made measurable -----------------------

	def NumberOfCalls()
		return len($aStzLlmSandboxes[This._Slot()][4])

	# Approximate tokens, the conventional ~4 characters each. APPROXIMATE on
	# purpose: it is for asserting a BUDGET ("this feature must not send more than
	# ~2000 tokens"), not for billing.
	def ApproximateTokensSent()
		_t_ = 0
		_a_ = $aStzLlmSandboxes[This._Slot()][4]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += ceil(_a_[_i_][2] / 4)
		next
		return _t_

	def Prompts()
		_out_ = []
		_a_ = $aStzLlmSandboxes[This._Slot()][4]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_out_ + _a_[_i_][1]
		next
		return _out_

	def LastPrompt()
		_a_ = This.Prompts()
		if len(_a_) = 0
			return ""
		ok
		return _a_[len(_a_)]

	# was a given thing ever asked about? -- assert on what the pipeline SENT, which
	# is where prompt-assembly bugs actually live.
	def WasAskedAbout(pcFragment)
		_f_ = StzLower("" + pcFragment)
		_a_ = This.Prompts()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzFindFirst(_f_, StzLower(_a_[_i_])) > 0
				return 1
			ok
		next
		return 0

	def ClearCalls()
		This.ClearCallsQ()

	def ClearCallsQ()
		$aStzLlmSandboxes[This._Slot()][4] = []
		return This

	def Show()
		? "stzLlmSandbox: " + This.NumberOfSeededAnswers() + " seeded, " +
		  This.NumberOfRules() + " rule(s), " + This.NumberOfCalls() + " call(s), ~" +
		  This.ApproximateTokensSent() + " tokens"

	  #-- internals -------------------------------------------------------

	def _SeedIndex(pcKey)
		_i_ = This._Slot()
		_n_ = len($aStzLlmSandboxes[_i_][2])
		for _j_ = 1 to _n_
			if $aStzLlmSandboxes[_i_][2][_j_][1] = pcKey
				return _j_
			ok
		next
		return 0

	def _Slot()
		_n_ = len($aStzLlmSandboxes)
		for _i_ = 1 to _n_
			if $aStzLlmSandboxes[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzLlmSandboxes + [ @nId, [], [], [], 1, "" ]
		return len($aStzLlmSandboxes)


  #=========================================================#
 #  DLM SOURCE -- local-real: it genuinely reasons            #
#=========================================================#
#
# Promotes stzDLM behind the port. This one is NOT a fake and NOT a recording: it
# answers from a domain knowledge graph you built, so it is deterministic AND
# derived -- ask it something outside its domain and it says so rather than
# inventing, which is the opposite failure mode from a language model.
#
# It is therefore LOCAL-REAL in the registry's sense (see stzDataPort for how that
# posture came about): shipping it is a legitimate choice for a bounded, factual
# assistant, not a fake awaiting replacement.

class stzDlmSource from stzObject

	@oDlm = ""

	def init(poDlm)
		if NOT isObject(poDlm)
			StzRaise("stzDlmSource: an stzDLM instance is required.")
		ok
		@oDlm = poDlm

	# a genuine local equivalent, not a fake -- see stzServiceRegistry's postures
	def IsLocalReal()
		return 1

	# the PORT contract
	def Complete(pcPrompt)
		_a_ = @oDlm.Ask("" + pcPrompt)
		if _a_ = ""
			return [ :ok = 0, :text = "", :from = :dlm ]
		ok
		return [ :ok = 1, :text = "" + _a_, :from = :dlm ]

	def DlmQ()
		return @oDlm

	def Show()
		? "stzDlmSource (domain-deterministic, local)"
