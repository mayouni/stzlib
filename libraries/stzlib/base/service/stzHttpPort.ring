#================================================================#
#  STZHTTPPORT -- the generic HTTP port (scripted + replay)         #
#================================================================#

/*--- Phase 3, and the highest-leverage one: most SaaS is HTTP.

Payments, shipping quotes, geocoding, CRM, weather, an LLM endpoint -- almost every
third-party dependency is a request and a response. So rather than a bespoke double
per vendor, this is ONE double for the shape they share, and the later categories
become configuration rather than new code.

An HTTP port is **"any object with `Request(method, url, body)`"** returning
`[ :status, :body ]`. Two implementations ship:

  stzHttpSandbox        offline, deterministic, assertable -- in two modes
  stzReactorHttpClient  the real thing, over the reactor's curl-backed client

TWO SANDBOX MODES, because tests want different things:

  SCRIPTED -- rules you write. "GET /rates -> 200 with this JSON." Best when you
    want to DRIVE behaviour: make the gateway decline, make the API rate-limit you,
    make it time out. You cannot ask a real vendor to fail on demand.

  REPLAY -- a recorded response, keyed by a hash of (method, url, body). Call the
    real service ONCE, keep what it said, and replay it forever after. This
    generalises what stzLLMFunction's answer cache already does for prompts: the
    VCR idea, Softanza-native.

    oSb.RecordFrom(oLiveClient, "GET", "https://api.rates/v1", "")   # once
    oSb.Request("GET", "https://api.rates/v1", "")                    # forever

STRICT BY DEFAULT, and this is the important choice. An unscripted, unrecorded
request RAISES. A double that silently answers "" for something you forgot to set
up produces a test that passes for the wrong reason -- the worst outcome available.
SetStrict(0) turns misses into a 501 for the rare case where you want to
observe them instead.

Every request is JOURNALLED, so a test can assert on what the code TRIED to do --
often more revealing than the response it got back.

RING NOTE: this sandbox is STATEFUL (scripts, recordings, the journal), and Ring
copies an object on `=` and on list insertion -- including when a service registry
hands it back. So its state lives in a handle table keyed by an id that survives
copying, exactly as stzMailSandbox does. That is the port contract's requirement
for any stateful double, and it is what makes the registry round trip work.
*/

# state shared across copies: [ [ id, scripts, seeds, journal, strict ], ... ]
$aStzHttpSandboxes = []
$nStzHttpSandboxSeq = 0

func StzHttpSandboxQ()
	return new stzHttpSandbox()

func StzReactorHttpClientQ()
	return new stzReactorHttpClient()


  #=========================================================#
 #  HTTP SANDBOX -- scripted + replay, offline               #
#=========================================================#

class stzHttpSandbox from stzObject

	@nId = 0

	def init()
		$nStzHttpSandboxSeq = $nStzHttpSandboxSeq + 1
		@nId = $nStzHttpSandboxSeq
		# scripts, seeds, journal, strict
		$aStzHttpSandboxes + [ @nId, [], [], [], 1 ]

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	  #-- SCRIPTED mode ----------------------------------------------------

	# A rule: method + URL pattern -> status + body. First match wins, so order is
	# meaningful and a general rule goes last.
	#
	# The pattern language is three cases and no more (the same restraint stzXml's
	# paths take -- a half-regex invites people to expect the rest):
	#   "https://api/x"   exact
	#   "https://api/*"   prefix, up to the star
	#   "*/rates*"        contains, when it starts AND ends with a star
	def Script(pcMethod, pcUrlPattern, pnStatus, pcBody)
		This.ScriptQ(pcMethod, pcUrlPattern, pnStatus, pcBody)

	def ScriptQ(pcMethod, pcUrlPattern, pnStatus, pcBody)
		_i_ = This._Slot()
		$aStzHttpSandboxes[_i_][2] + [ StzUpper("" + pcMethod), "" + pcUrlPattern,
		                               pnStatus, "" + pcBody ]
		return This

	# JSON is what most of these APIs speak.
	def ScriptJsonQ(pcMethod, pcUrlPattern, pnStatus, pcJson)
		return This.ScriptQ(pcMethod, pcUrlPattern, pnStatus, pcJson)

	# make the service fail on demand -- the thing a real vendor will not do for you
	def ScriptFailureQ(pcMethod, pcUrlPattern, pnStatus)
		return This.ScriptQ(pcMethod, pcUrlPattern, pnStatus, "")

	def NumberOfScripts()
		return len($aStzHttpSandboxes[This._Slot()][2])

	  #-- REPLAY mode ------------------------------------------------------

	# Keep a response for an exact (method, url, body). The key is a hash of all
	# three, so a different body is a different recording -- which is what makes
	# this safe for POSTs.
	def SeedResponse(pcMethod, pcUrl, pcReqBody, pnStatus, pcRespBody)
		This.SeedResponseQ(pcMethod, pcUrl, pcReqBody, pnStatus, pcRespBody)

	def SeedResponseQ(pcMethod, pcUrl, pcReqBody, pnStatus, pcRespBody)
		_i_ = This._Slot()
		_k_ = This.RequestKey(pcMethod, pcUrl, pcReqBody)
		_n_ = len($aStzHttpSandboxes[_i_][3])
		for _j_ = 1 to _n_
			if $aStzHttpSandboxes[_i_][3][_j_][1] = _k_
				$aStzHttpSandboxes[_i_][3][_j_] = [ _k_, pnStatus, "" + pcRespBody ]
				return This
			ok
		next
		$aStzHttpSandboxes[_i_][3] + [ _k_, pnStatus, "" + pcRespBody ]
		return This

	# Call a LIVE client once and keep what it said. The client is any object with
	# Request(method, url, body) -- so the recording path is testable without a
	# network, by handing in any conforming stand-in.
	def RecordFrom(poClient, pcMethod, pcUrl, pcReqBody)
		_r_ = poClient.Request(pcMethod, pcUrl, pcReqBody)
		This.SeedResponseQ(pcMethod, pcUrl, pcReqBody, _r_[:status], _r_[:body])
		return _r_

	def NumberOfRecordings()
		return len($aStzHttpSandboxes[This._Slot()][3])

	def HasRecording(pcMethod, pcUrl, pcReqBody)
		return This._SeedIndex( This.RequestKey(pcMethod, pcUrl, pcReqBody) ) > 0

	# the key a recording is filed under -- exposed because seeing it makes the
	# replay model obvious (and because a fixture may want to name one).
	def RequestKey(pcMethod, pcUrl, pcReqBody)
		return StzEngineCryptoSha256(StzUpper("" + pcMethod) + "|" + pcUrl + "|" + pcReqBody)

	  #-- the PORT contract ------------------------------------------------

	# -> [ :status, :body, :from ] where :from is :replay, :scripted or :miss.
	# A RECORDING wins over a script: a recording is what the real service actually
	# said, and that is more authoritative than a rule someone wrote.
	def Request(pcMethod, pcUrl, pcReqBody)
		_i_ = This._Slot()
		_m_ = StzUpper("" + pcMethod)
		$aStzHttpSandboxes[_i_][4] + [ _m_, "" + pcUrl, "" + pcReqBody ]

		_s_ = This._SeedIndex( This.RequestKey(_m_, pcUrl, pcReqBody) )
		if _s_ > 0
			return [ :status = $aStzHttpSandboxes[_i_][3][_s_][2],
			         :body = $aStzHttpSandboxes[_i_][3][_s_][3], :from = :replay ]
		ok

		_aScripts_ = $aStzHttpSandboxes[_i_][2]
		_n_ = len(_aScripts_)
		for _j_ = 1 to _n_
			if _aScripts_[_j_][1] != _m_
				loop
			ok
			if This._Matches(_aScripts_[_j_][2], "" + pcUrl)
				return [ :status = _aScripts_[_j_][3], :body = _aScripts_[_j_][4],
				         :from = :scripted ]
			ok
		next

		if $aStzHttpSandboxes[_i_][5]
			StzRaise("stzHttpSandbox: nothing scripted or recorded for " + _m_ + " " + pcUrl +
			         ". Script it, record it, or SetStrict(FALSE) to let misses through.")
		ok
		return [ :status = 501, :body = "", :from = :miss ]

	# NOTE: not Get/Post -- `Get` is a Ring keyword (which is why stzAppServer has
	# Get_). These read better than an underscore anyway.
	def GetFrom(pcUrl)
		return This.Request("GET", pcUrl, "")

	def PostTo(pcUrl, pcBody)
		return This.Request("POST", pcUrl, pcBody)

	  #-- strictness -------------------------------------------------------

	def SetStrict(pbOn)
		This.SetStrictQ(pbOn)

	def SetStrictQ(pbOn)
		$aStzHttpSandboxes[This._Slot()][5] = pbOn
		return This

	def IsStrict()
		return $aStzHttpSandboxes[This._Slot()][5]

	  #-- the journal (what the code TRIED) --------------------------------

	def Calls()
		return $aStzHttpSandboxes[This._Slot()][4]

	def NumberOfCalls()
		return len(This.Calls())

	def LastCall()
		_a_ = This.Calls()
		if len(_a_) = 0
			return []
		ok
		_c_ = _a_[len(_a_)]
		return [ :method = _c_[1], :url = _c_[2], :body = _c_[3] ]

	# how many times a URL was asked for -- the assertion that catches an N+1 or a
	# retry storm.
	def NumberOfCallsTo(pcUrl)
		_k_ = 0
		_a_ = This.Calls()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][2] = ("" + pcUrl)
				_k_++
			ok
		next
		return _k_

	def WasCalled(pcMethod, pcUrl)
		_m_ = StzUpper("" + pcMethod)
		_a_ = This.Calls()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][1] = _m_ and _a_[_i_][2] = ("" + pcUrl)
				return 1
			ok
		next
		return 0

	def ClearCalls()
		This.ClearCallsQ()

	def ClearCallsQ()
		$aStzHttpSandboxes[This._Slot()][4] = []
		return This

	def Show()
		? "stzHttpSandbox: " + This.NumberOfScripts() + " script(s), " +
		  This.NumberOfRecordings() + " recording(s), " + This.NumberOfCalls() + " call(s)"

	  #-- internals -------------------------------------------------------

	def _Matches(pcPattern, pcUrl)
		_p_ = "" + pcPattern
		if _p_ = "*"
			return 1
		ok
		_bStar1_ = StzFindFirst("*", _p_) = 1
		_bStarN_ = len(_p_) > 0 and _p_[len(_p_)] = "*"
		if _bStar1_ and _bStarN_ and len(_p_) > 2
			return StzFindFirst( StzMid(_p_, 2, len(_p_) - 2), pcUrl ) > 0
		ok
		if _bStarN_
			return StzFindFirst( StzLeft(_p_, len(_p_) - 1), pcUrl ) = 1
		ok
		return _p_ = pcUrl

	def _SeedIndex(pcKey)
		_i_ = This._Slot()
		_n_ = len($aStzHttpSandboxes[_i_][3])
		for _j_ = 1 to _n_
			if $aStzHttpSandboxes[_i_][3][_j_][1] = pcKey
				return _j_
			ok
		next
		return 0

	def _Slot()
		_n_ = len($aStzHttpSandboxes)
		for _i_ = 1 to _n_
			if $aStzHttpSandboxes[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzHttpSandboxes + [ @nId, [], [], [], 1 ]
		return len($aStzHttpSandboxes)


  #=========================================================#
 #  REACTOR HTTP CLIENT -- the live adapter                  #
#=========================================================#
#
# The real thing, over the reactor's curl-backed client -- so the live side of this
# port is code the library already has rather than something you must supply.
#
# HONEST LIMITATION: that client returns a response BODY and no status line. So
# this adapter reports 200 when content came back and 0 when nothing did. That is
# enough to record and replay, and enough for most calls, but a status-aware
# adapter (headers, redirects, non-2xx bodies) is a richer thing you may want to
# bind instead -- which is exactly what the port is for.

class stzReactorHttpClient from stzObject

	@oReactor = ""
	@nTimeoutMs = 15000

	def init()
		@oReactor = new stzReactor()

	def SetTimeout(pnMs)
		This.SetTimeoutQ(pnMs)

	def SetTimeoutQ(pnMs)
		@nTimeoutMs = pnMs
		return This

	def Timeout()
		return @nTimeoutMs

	# the PORT contract, same three arguments as the sandbox
	def Request(pcMethod, pcUrl, pcReqBody)
		_m_ = StzUpper("" + pcMethod)
		_body_ = ""
		if _m_ = "GET"
			_body_ = @oReactor.HttpGet("" + pcUrl, @nTimeoutMs)
		else
			_body_ = @oReactor.HttpPost("" + pcUrl, "" + pcReqBody, @nTimeoutMs)
		ok
		if _body_ = ""
			return [ :status = 0, :body = "", :from = :live ]
		ok
		return [ :status = 200, :body = _body_, :from = :live ]

	def GetFrom(pcUrl)
		return This.Request("GET", pcUrl, "")

	def PostTo(pcUrl, pcBody)
		return This.Request("POST", pcUrl, pcBody)

	def ReactorQ()
		return @oReactor

	def Show()
		? "stzReactorHttpClient(timeout " + @nTimeoutMs + "ms)"
