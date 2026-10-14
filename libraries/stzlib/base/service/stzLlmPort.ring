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

# Stands in for a language-model port in tests, replaying seeded answers and counting calls, with no model and no network.
#
# A port is any object with a Complete method that answers a hash list with ok, text and from. This
# one gives three things a real model cannot: determinism (a seeded prompt always gets the same
# answer), a measurable cost (the number of calls and an approximate token count, so a budget
# becomes an assertion) and offline use. A seeded answer is tried first, then a fragment rule, then
# the fallback; in strict mode, the default, anything else raises an error. It cannot reproduce the
# quality of a real model: use it for the shape of a pipeline, prompts assembled and answers parsed,
# and judge quality against the real thing separately. Its state lives in a shared table, so a copy
# of the object sees the same answers and calls.
#
#   receiver   o1 = new stzLlmSandbox()
#   example    o1.SeedAnswer("What is 2+2?", "4")
#              o1.WhenPromptContains("summarise", "A short summary.")
#              ? o1.Complete("What is 2+2?")[:text]
#              #--> 4
#              ? o1.Complete("Please summarise this")[:from]
#              #--> scripted
#              ? o1.NumberOfCalls()
#              #--> 2
#              ? o1.WasAskedAbout("SUMMARISE")
#              #--> 1
#   see        stzDlmSource, stzServiceRegistry, stzDLM
class stzLlmSandbox from stzObject

	@nId = 0

	# Builds an in-memory stand-in for a language-model port, with no seeded answer, no rule and strict mode on.
	#
	#   returns    nothing; the object is built
	#   note       the state lives in a shared global table keyed by the object's id, so a copy of
	#              the object sees the same answers and calls; no model and no network are ever used
	#   see        SeedAnswer, WhenPromptContains, Complete
	def init()
		$nStzLlmSandboxSeq = $nStzLlmSandboxSeq + 1
		@nId = $nStzLlmSandboxSeq
		$aStzLlmSandboxes + [ @nId, [], [], [], 1, "" ]

	# Returns TRUE to declare this object a test double, which a service registry refuses to ship.
	#
	#   returns    TRUE or FALSE
	#   see        StzDlmSourceQ, Complete
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Records the exact answer to give for an exact prompt, so a test that depends on model output is repeatable.
	#
	#   pcPrompt   the prompt to recognize, compared exactly with case
	#   pcText     the answer to return for it
	#   returns    nothing; use SeedAnswerQ to chain
	#   note       seeding the same prompt again replaces its answer; a seeded answer wins over a
	#              rule
	#   see        RecordFrom, WhenPromptContains, HasAnswerFor
	#@ aka  -- REPLAY: an exact answer for an exact prompt -----------------------
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

	# Calls another port once, keeps the text it answered as the seed for that prompt and returns the whole reply.
	#
	#   poClient   any object with a Complete method that answers such a list
	#   pcPrompt   the prompt to send and to seed
	#   returns    a hash list with the keys ok, text and from, as the client gave it
	#   note       give it a stand-in client in tests, never a real model
	#   warning    the text is kept even when the client reports ok as 0, so a failed call is
	#              recorded as an empty answer and later replays as ok 1 from replay
	#   see        SeedAnswer, Complete
	#@ aka  Call a real model ONCE and keep what it said. poClient is any object with Complete(prompt) -- so the recording path is testable with no key and no network, by handing in any conforming stand-in.
	def RecordFrom(poClient, pcPrompt)
		_r_ = poClient.Complete(pcPrompt)
		This.SeedAnswerQ(pcPrompt, _r_[:text])
		return _r_

	# Returns the SHA-256 hash in hex that identifies a prompt among the seeded answers.
	#
	#   pcPrompt   the prompt to hash
	#   returns    a text of 64 hex characters
	#   see        SeedAnswer, HasAnswerFor
	def PromptKey(pcPrompt)
		return StzEngineCryptoSha256("" + pcPrompt)

	# TRUE if an answer is seeded for exactly this prompt.
	#
	#   pcPrompt   the prompt to look up, compared exactly with case
	#   returns    TRUE or FALSE
	#   note       rules and the fallback are not consulted
	#   see        SeedAnswer, NumberOfSeededAnswers
	def HasAnswerFor(pcPrompt)
		return This._SeedIndex( This.PromptKey(pcPrompt) ) > 0

	# Returns how many prompts have a seeded answer.
	#
	#   returns    a number
	#   see        SeedAnswer, NumberOfRules
	def NumberOfSeededAnswers()
		return len($aStzLlmSandboxes[This._Slot()][2])

	# Adds a rule that answers every prompt containing a fragment, so one rule covers a family of prompts.
	#
	#   pcFragment   the text to look for in the prompt, without regard to case
	#   pcText       the answer to give
	#   returns      nothing; use WhenPromptContainsQ to chain
	#   note         the first rule that matches wins, in the order they were added; a seeded answer
	#                is tried before any rule
	#   see          SeedAnswer, SetFallback, Complete
	#@ aka  -- SCRIPTED: a rule for a family of prompts --------------------------
	def WhenPromptContains(pcFragment, pcText)
		This.WhenPromptContainsQ(pcFragment, pcText)

	def WhenPromptContainsQ(pcFragment, pcText)
		_i_ = This._Slot()
		$aStzLlmSandboxes[_i_][3] + [ StzLower("" + pcFragment), "" + pcText ]
		return This

	# Returns how many fragment rules were added.
	#
	#   returns    a number
	#   see        WhenPromptContains
	def NumberOfRules()
		return len($aStzLlmSandboxes[This._Slot()][3])

	# Sets a catch-all answer for prompts that no seed and no rule match.
	#
	#   pcText     the answer to give to every other prompt
	#   returns    nothing; use SetFallbackQ to chain
	#   note       with a fallback set, strict mode never raises
	#   see        Fallback, SetStrict
	#@ aka  A catch-all answer, for pipelines where the text does not matter and only the SHAPE does. Setting one turns strictness off for unmatched prompts.
	def SetFallback(pcText)
		This.SetFallbackQ(pcText)

	def SetFallbackQ(pcText)
		$aStzLlmSandboxes[This._Slot()][6] = "" + pcText
		return This

	# Returns the catch-all answer, or an empty text when none is set.
	#
	#   returns    a text
	#   see        SetFallback
	def Fallback()
		return $aStzLlmSandboxes[This._Slot()][6]

	# Answers a prompt from a seed, then a rule, then the fallback, and counts the call.
	#
	#   pcPrompt   the prompt to answer
	#   returns    a hash list with the keys ok, text and from; from is replay, scripted, fallback
	#              or miss
	#   note       no model is called, whatever the prompt
	#   warning    raises an error in strict mode, which is the default, when nothing matches: seed
	#              it, add a rule, set a fallback or turn strict off; the refused prompt is still
	#              counted; with strict off an unmatched prompt answers ok 0, an empty text and from
	#              miss
	#   see        SeedAnswer, WhenPromptContains, SetStrict, NumberOfCalls
	#@ aka  -- the PORT contract ------------------------------------------------
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

	# Chooses whether an unmatched prompt raises an error or answers a miss.
	#
	#   pbOn       TRUE to raise on an unmatched prompt, FALSE to answer ok 0
	#   returns    nothing
	#   note       it does not return the object; a fallback makes the setting irrelevant
	#   see        IsStrict, Complete
	def SetStrict(pbOn)
		This.SetStrictQ(pbOn)

	def SetStrictQ(pbOn)
		$aStzLlmSandboxes[This._Slot()][5] = pbOn
		return This

	# TRUE if an unmatched prompt raises an error.
	#
	#   returns    TRUE or FALSE
	#   see        SetStrict
	def IsStrict()
		return $aStzLlmSandboxes[This._Slot()][5]

	# Returns how many prompts were sent, including those refused in strict mode.
	#
	#   returns    a number
	#   see        ClearCalls, ApproximateTokensSent
	#@ aka  -- COST: the fee-free promise, made measurable -----------------------
	def NumberOfCalls()
		return len($aStzLlmSandboxes[This._Slot()][4])

	# Returns the approximate number of tokens sent so far, taking four bytes for a token, so a test can assert a budget.
	#
	#   returns    a number
	#   note       it is meant to bound a cost, not to bill it; the length counts bytes, so non-
	#              Latin text is overestimated
	#   see        NumberOfCalls, Prompts
	#@ aka  Approximate tokens, the conventional ~4 characters each. APPROXIMATE on purpose: it is for asserting a BUDGET ("this feature must not send more than ~2000 tokens"), not for billing.
	def ApproximateTokensSent()
		_t_ = 0
		_a_ = $aStzLlmSandboxes[This._Slot()][4]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += ceil(_a_[_i_][2] / 4)
		next
		return _t_

	# Returns every prompt sent, in order.
	#
	#   returns    a list of texts
	#   see        LastPrompt, WasAskedAbout, ClearCalls
	def Prompts()
		_out_ = []
		_a_ = $aStzLlmSandboxes[This._Slot()][4]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_out_ + _a_[_i_][1]
		next
		return _out_

	# Returns the prompt sent last, or an empty text when none was sent.
	#
	#   returns    a text
	#   see        Prompts
	def LastPrompt()
		_a_ = This.Prompts()
		if len(_a_) = 0
			return ""
		ok
		return _a_[len(_a_)]

	# TRUE if some prompt sent contained the fragment.
	#
	#   pcFragment   the text to look for, without regard to case
	#   returns      TRUE or FALSE
	#   note         it checks what the pipeline sent, where prompt-assembly bugs live
	#   see          Prompts, LastPrompt
	#@ aka  was a given thing ever asked about? -- assert on what the pipeline SENT, which is where prompt-assembly bugs actually live.
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

	# Forgets the record of prompts sent, which resets the call count and the token estimate.
	#
	#   returns    nothing; use ClearCallsQ to chain
	#   note       seeded answers and rules are kept
	#   see        NumberOfCalls, Prompts
	def ClearCalls()
		This.ClearCallsQ()

	def ClearCallsQ()
		$aStzLlmSandboxes[This._Slot()][4] = []
		return This

	# Prints one line with the seeded answers, the rules, the calls and the token estimate.
	#
	#   returns    nothing; it prints a line
	#   see        NumberOfCalls
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

# Offers a domain language model behind the language-model port, so a bounded, factual assistant needs no external model.
#
# Complete asks the model and returns the reply in the port's shape, with from set to dlm. It is a
# genuine local equivalent rather than a recording or a fake, so a service registry may ship it. It
# answers deterministically from the facts the model holds and refuses outside its domain with a
# sentence instead of inventing; that refusal still comes back as ok 1, so check the model's own Why
# to tell the two apart. The source keeps a copy of the model, so fill the model completely before
# handing it in.
#
#   receiver   oDlm = new stzDLM("restaurant") oDlm.LearnEntity("margherita", "dish") o1 = new
#              stzDlmSource(oDlm)
#   example    ? o1.IsLocalReal()
#              #--> 1
#              ? o1.Complete("what is margherita")[:text]
#              #--> Margherita is a dish.
#              ? o1.Complete("what is margherita")[:from]
#              #--> dlm
#   see        stzDLM, stzLlmSandbox
class stzDlmSource from stzObject

	@oDlm = ""

	# Builds a language-model port that answers from a domain language model.
	#
	#   poDlm      the stzDLM that answers the prompts
	#   returns    nothing; the object is built
	#   note       StzDlmSourceQ builds one the same way
	#   warning    raises an error when poDlm is not an object; the source keeps a copy of the
	#              model, so facts learned in the original afterwards are not seen: fill the model
	#              first
	#   see        Complete, DlmQ
	def init(poDlm)
		if NOT isObject(poDlm)
			StzRaise("stzDlmSource: an stzDLM instance is required.")
		ok
		@oDlm = poDlm

	# Returns TRUE to declare this object a genuine local equivalent, which a service registry may ship.
	#
	#   returns    TRUE or FALSE
	#   see        Complete
	#@ aka  a genuine local equivalent, not a fake -- see stzServiceRegistry's postures
	def IsLocalReal()
		return 1

	# Answers a prompt by asking the domain model, and returns the reply in the port's shape.
	#
	#   pcPrompt   the question to put to the model
	#   returns    a hash list with the keys ok, text and from; from is dlm
	#   note       no network and no language model are used
	#   warning    a question outside the domain still gives ok 1: the refusal sentence comes back
	#              as the text, so ok does not tell an answer from a refusal
	#   see        DlmQ
	#@ aka  the PORT contract
	def Complete(pcPrompt)
		_a_ = @oDlm.Ask("" + pcPrompt)
		if _a_ = ""
			return [ :ok = 0, :text = "", :from = :dlm ]
		ok
		return [ :ok = 1, :text = "" + _a_, :from = :dlm ]

	# Returns the domain model the source answers from.
	#
	#   returns    the stzDLM held by the source
	#   see        init, Complete
	def DlmQ()
		return @oDlm

	# Prints one line saying the source is deterministic and local.
	#
	#   returns    nothing; it prints a line
	#   see        IsLocalReal
	def Show()
		? "stzDlmSource (domain-deterministic, local)"
