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

# Stands in for an HTTP service offline, answering from rules you script or answers you recorded, and journals every request.
#
# It follows the HTTP port contract: any object with Request(method, url, body) that returns a list
# with status, body and from. Scripted mode drives behaviour, with a rule per method and address
# pattern, first match winning. Replay mode keeps what a real service said, filed under a hash of
# method, address and body, and a recording wins over a rule. By default an unscripted, unrecorded
# request raises an error, because a double that silently answers makes a test pass for the wrong
# reason; SetStrict(0) answers 501 instead. Every request is journalled, so a test can check what
# the code tried to do. The state lives in a table shared by copies, so a copy of the sandbox sees
# the same rules.
#
#   receiver   o1 = new stzHttpSandbox()
#   example    o1.Script("GET", "https://api.test/rates", 200, '{"eur":0.92}')
#              ? o1.GetFrom("https://api.test/rates")[:body]
#              #--> {"eur":0.92}
#              ? o1.NumberOfCallsTo("https://api.test/rates")
#              #--> 1
#   see        stzReactorHttpClient, stzServiceRegistry
class stzHttpSandbox from stzObject

	@nId = 0

	# Builds an offline HTTP double with no rules, no recordings, an empty journal and strict mode on.
	#
	#   returns    nothing; the object is built
	#   see        Script, SeedResponse, SetStrict
	def init()
		$nStzHttpSandboxSeq = $nStzHttpSandboxSeq + 1
		@nId = $nStzHttpSandboxSeq
		# scripts, seeds, journal, strict
		$aStzHttpSandboxes + [ @nId, [], [], [], 1 ]

	# TRUE if the object is a fake, which is how a service registry tells it from a live client.
	#
	#   returns    TRUE
	#   see        stzReactorHttpClient
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Adds a rule: requests with that method and a matching address get that status and body.
	#
	#   pcMethod       the HTTP method, kept in upper case
	#   pcUrlPattern   an exact address, a prefix ending in *, or a part between a * at each end
	#   pnStatus       the status number to answer with
	#   pcBody         the response body
	#   returns        nothing; use ScriptQ to chain
	#   note           ScriptQ is the same call and returns the sandbox
	#   warning        rules are tried in the order added and the first match wins, so put a general
	#                  rule last; a pattern with a * only at its start, such as */rates, is taken as
	#                  an exact address and never matches; the method matches without regard to case
	#                  but the address with it; a status given as text stays text
	#   see            NumberOfScripts, Request, SetStrict
	#@ aka  -- SCRIPTED mode ----------------------------------------------------
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

	# Adds a rule that makes matching requests answer with a failure status and an empty body.
	#
	#   pcMethod       the HTTP method
	#   pcUrlPattern   the address pattern, as for Script
	#   pnStatus       the failure status, such as 503
	#   returns        the sandbox itself, so calls chain
	#   warning        the way to test a service that fails, which a real vendor will not do on
	#                  demand
	#   see            Script, Request
	#@ aka  make the service fail on demand -- the thing a real vendor will not do for you
	def ScriptFailureQ(pcMethod, pcUrlPattern, pnStatus)
		return This.ScriptQ(pcMethod, pcUrlPattern, pnStatus, "")

	# Returns how many rules the sandbox holds.
	#
	#   returns    a number
	#   see        Script
	def NumberOfScripts()
		return len($aStzHttpSandboxes[This._Slot()][2])

	# Keeps a recorded answer for an exact method, address and request body, replacing an earlier one for the same three.
	#
	#   pcMethod     the HTTP method
	#   pcUrl        the exact address
	#   pcReqBody    the exact request body
	#   pnStatus     the status to replay
	#   pcRespBody   the body to replay
	#   returns      nothing; use SeedResponseQ to chain
	#   note         SeedResponseQ is the same call and returns the sandbox
	#   warning      a recording is found only for the same body, and it wins over any rule
	#   see          RecordFrom, HasRecording, Request
	#@ aka  -- REPLAY mode ------------------------------------------------------
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

	# Sends a request to another client once and keeps the answer, so that the sandbox replays it from then on.
	#
	#   poClient    any object with a Request(method, url, body) method, such as a second sandbox or
	#               stzReactorHttpClient
	#   pcMethod    the HTTP method
	#   pcUrl       the address
	#   pcReqBody   the request body
	#   returns     the answer of the client, a list with status, body and from
	#   note        the sandbox's own journal does not note the request, only the client's
	#   warning     an error raised by the client, such as a strict miss, passes through and nothing
	#               is recorded
	#   see         SeedResponse, HasRecording
	#@ aka  Call a LIVE client once and keep what it said. The client is any object with Request(method, url, body) -- so the recording path is testable without a network, by handing in any conforming stand-in.
	def RecordFrom(poClient, pcMethod, pcUrl, pcReqBody)
		_r_ = poClient.Request(pcMethod, pcUrl, pcReqBody)
		This.SeedResponseQ(pcMethod, pcUrl, pcReqBody, _r_[:status], _r_[:body])
		return _r_

	# Returns how many recorded answers the sandbox holds.
	#
	#   returns    a number
	#   see        SeedResponse, HasRecording
	def NumberOfRecordings()
		return len($aStzHttpSandboxes[This._Slot()][3])

	# TRUE if an answer is kept for exactly that method, address and body.
	#
	#   pcMethod    the HTTP method, matched without regard to case
	#   pcUrl       the exact address
	#   pcReqBody   the exact request body
	#   returns     TRUE or FALSE
	#   see         SeedResponse, RequestKey
	def HasRecording(pcMethod, pcUrl, pcReqBody)
		return This._SeedIndex( This.RequestKey(pcMethod, pcUrl, pcReqBody) ) > 0

	# Returns the key a recording is filed under: a SHA-256 hash of the method in upper case, the address and the body.
	#
	#   pcMethod    the HTTP method
	#   pcUrl       the address
	#   pcReqBody   the request body
	#   returns     a text of 64 hexadecimal characters
	#   warning     the same method in another letter case gives the same key
	#   see         SeedResponse, HasRecording
	#@ aka  the key a recording is filed under -- exposed because seeing it makes the replay model obvious (and because a fixture may want to name one).
	def RequestKey(pcMethod, pcUrl, pcReqBody)
		return StzEngineCryptoSha256(StzUpper("" + pcMethod) + "|" + pcUrl + "|" + pcReqBody)

	# Answers a request from a recording first, then from the first matching rule, and notes the request in the journal.
	#
	#   pcMethod    the HTTP method, matched without regard to case
	#   pcUrl       the address
	#   pcReqBody   the request body
	#   returns     a hash list with status, body and from, from being replay, scripted or miss
	#   note        with strict mode off a miss answers status 501 with from miss
	#   warning     in strict mode, which is the default, a request with no recording and no rule
	#               raises an error naming the method and address; it is still journalled
	#   see         GetFrom, PostTo, Script, SeedResponse, SetStrict
	#@ aka  -- the PORT contract ------------------------------------------------
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

	# Sends a GET request with no body through Request.
	#
	#   pcUrl      the address
	#   returns    a hash list with status, body and from
	#   see        Request, PostTo
	#@ aka  NOTE: not Get/Post -- `Get` is a Ring keyword (which is why stzAppServer has Get_). These read better than an underscore anyway.
	def GetFrom(pcUrl)
		return This.Request("GET", pcUrl, "")

	# Sends a POST request with a body through Request.
	#
	#   pcUrl      the address
	#   pcBody     the request body
	#   returns    a hash list with status, body and from
	#   see        Request, GetFrom
	def PostTo(pcUrl, pcBody)
		return This.Request("POST", pcUrl, pcBody)

	# Chooses whether a request that matches nothing raises an error (1) or answers a 501 miss (0).
	#
	#   pbOn       1 for strict, 0 to let misses through
	#   returns    nothing; use SetStrictQ to chain
	#   warning    SetStrictQ is the same call and returns the sandbox
	#   see        IsStrict, Request
	#@ aka  -- strictness -------------------------------------------------------
	def SetStrict(pbOn)
		This.SetStrictQ(pbOn)

	def SetStrictQ(pbOn)
		$aStzHttpSandboxes[This._Slot()][5] = pbOn
		return This

	# TRUE if a request that matches nothing raises an error.
	#
	#   returns    TRUE or FALSE
	#   see        SetStrict
	def IsStrict()
		return $aStzHttpSandboxes[This._Slot()][5]

	# Returns the journal of every request made, oldest first, those that raised an error included.
	#
	#   returns    a list of rows [ method, url, body ], the method in upper case
	#   see        LastCall, NumberOfCalls, ClearCalls
	#@ aka  -- the journal (what the code TRIED) --------------------------------
	def Calls()
		return $aStzHttpSandboxes[This._Slot()][4]

	# Returns how many requests the journal holds.
	#
	#   returns    a number
	#   see        Calls
	def NumberOfCalls()
		return len(This.Calls())

	# Returns the most recent request of the journal.
	#
	#   returns    a hash list with method, url and body; an empty list when the journal is empty
	#   see        Calls
	def LastCall()
		_a_ = This.Calls()
		if len(_a_) = 0
			return []
		ok
		_c_ = _a_[len(_a_)]
		return [ :method = _c_[1], :url = _c_[2], :body = _c_[3] ]

	# Returns how many journalled requests asked for exactly that address, whatever the method.
	#
	#   pcUrl      the exact address
	#   returns    a number
	#   warning    the way to catch a request repeated too often
	#   see        WasCalled, Calls
	#@ aka  how many times a URL was asked for -- the assertion that catches an N+1 or a retry storm.
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

	# TRUE if the journal holds a request with that method and exact address.
	#
	#   pcMethod   the HTTP method, matched without regard to case
	#   pcUrl      the exact address
	#   returns    TRUE or FALSE
	#   see        NumberOfCallsTo, Calls
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

	# Empties the journal; rules and recordings stay.
	#
	#   returns    nothing; use ClearCallsQ to chain
	#   warning    ClearCallsQ is the same call and returns the sandbox
	#   see        Calls
	def ClearCalls()
		This.ClearCallsQ()

	def ClearCallsQ()
		$aStzHttpSandboxes[This._Slot()][4] = []
		return This

	# Prints one line giving the number of rules, recordings and journalled requests.
	#
	#   returns    nothing; it prints
	#   see        NumberOfScripts, NumberOfRecordings, NumberOfCalls
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

# Sends real HTTP requests through the reactor's curl client and reports only a body, with status 200 or 0.
#
# It is the live side of the HTTP port, with the same Request(method, url, body) shape as
# stzHttpSandbox. The reactor's client returns a body and no status line, so the adapter answers
# status 200 when content came back and 0 when nothing did; headers, redirects and non-2xx bodies
# are not seen. It was run only against a listener started on 127.0.0.1 in the same process, which
# never answers, and against a closed port: both gave status 0. The 200 path was read from the code
# and not run.
#
#   receiver   o1 = new stzReactorHttpClient()
#   example    o1.SetTimeout(500)
#              ? o1.Timeout()
#              #--> 500
#              ? o1.GetFrom("http://127.0.0.1:1/x")[:status]
#              #--> 0
#   see        stzHttpSandbox, stzReactor
class stzReactorHttpClient from stzObject

	@oReactor = ""
	@nTimeoutMs = 15000

	# Builds the live HTTP client, which sends its requests through a new reactor.
	#
	#   returns    nothing; the object is built
	#   see        Request, ReactorQ
	def init()
		@oReactor = new stzReactor()

	# Sets the longest wait for an answer, in milliseconds; the default is 15000.
	#
	#   pnMs       the wait in milliseconds
	#   returns    nothing; use SetTimeoutQ to chain
	#   warning    SetTimeoutQ is the same call and returns the client
	#   see        Timeout, Request
	def SetTimeout(pnMs)
		This.SetTimeoutQ(pnMs)

	def SetTimeoutQ(pnMs)
		@nTimeoutMs = pnMs
		return This

	# Returns the longest wait for an answer, in milliseconds.
	#
	#   returns    a number; 15000 by default
	#   see        SetTimeout
	def Timeout()
		return @nTimeoutMs

	# Sends a GET, or a POST for any other method, through the reactor and waits for the body.
	#
	#   pcMethod    the HTTP method, GET or anything else meaning POST
	#   pcUrl       the address
	#   pcReqBody   the body sent by a POST and ignored by a GET
	#   returns     a hash list with status, body and from; status 200 with the body, or status 0
	#               with an empty body when nothing came back, from being live
	#   note        a closed port and a listener that never answers both gave status 0
	#   warning     only the body is returned, never the real status, so (by the source comment) an
	#               error page would read as 200, while a refused connection or a timeout reads as
	#               0; by its code any method other than GET is sent as a POST; the 200 answer was
	#               not run, because one process cannot answer a request while it waits for it
	#   see         GetFrom, PostTo, SetTimeout
	#@ aka  the PORT contract, same three arguments as the sandbox
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

	# Sends a GET request with no body through Request.
	#
	#   pcUrl      the address
	#   returns    a hash list with status, body and from
	#   see        Request, PostTo
	def GetFrom(pcUrl)
		return This.Request("GET", pcUrl, "")

	# Sends a POST request with a body through Request.
	#
	#   pcUrl      the address
	#   pcBody     the request body
	#   returns    a hash list with status, body and from
	#   see        Request, GetFrom
	def PostTo(pcUrl, pcBody)
		return This.Request("POST", pcUrl, pcBody)

	# Returns the reactor that carries the requests.
	#
	#   returns    a stzReactor object
	#   see        Request
	def ReactorQ()
		return @oReactor

	# Prints one line giving the client's timeout.
	#
	#   returns    nothing; it prints
	#   see        Timeout
	def Show()
		? "stzReactorHttpClient(timeout " + @nTimeoutMs + "ms)"
