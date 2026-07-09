/*
	Softanza HTTP Client -- engine-backed (M-DEP3 slice 2).
	Previously layered over libcurl.ring + libuv.ring; rewired
	2026-06-13 to the in-tree Zig HTTP module
	(libraries/stzlib/engine/src/http.zig) which uses
	std.http.Client + std.crypto.tls. HTTPS works without any
	external TLS library.

	The synchronous public surface (Get_, Post, Put_, Delete, Head,
	Options, PostForm, PostJson, Response..., SetHeader..., SetCookie...)
	is preserved so callers do not need to change.

	Settings that the libcurl backend exposed but std.http does not
	cover at engine slice 2 (custom UA via setopt, basic auth, proxy,
	SSL verify toggle, follow-redirects) are kept as fluent setters
	but only stored for future slices; they do not change request
	behaviour today. Most callers only need Get_/Post + headers/
	cookies.

	The libuv-based parallel GetMany() is dropped; sequential
	GetManySequential() is the supported path until M-DEP4 lands.
*/

# ── Method codes shared with engine/src/http.zig methodFromCode ─

$STZ_HTTP_METHOD_GET     = 0
$STZ_HTTP_METHOD_POST    = 1
$STZ_HTTP_METHOD_PUT     = 2
$STZ_HTTP_METHOD_DELETE  = 3
$STZ_HTTP_METHOD_HEAD    = 4
$STZ_HTTP_METHOD_OPTIONS = 5
$STZ_HTTP_METHOD_PATCH   = 6

# ── stzHttpClient ─────────────────────────────────────────────
# URLEncode is provided by stzNetworkUtils.ring (loaded earlier).

class stzHttpClient from stzNetwork

	# Request-state
	_headers_list_ = []           # accumulated "Name: Value" strings
	_cookies_list_ = []           # accumulated "k=v" strings
	_user_agent_ = "Softanza-HTTP/1.0"

	# Response state
	_last_response_ = ""
	_last_response_code_ = 0
	_last_response_headers_ = ""   # std.http does not yet expose these

	# Connection / TLS / auth settings -- all engine-backed via libcurl
	# (passed as the per-request options blob; see _ComposeOptionsBlob).
	_bFollowRedirects_ = TRUE
	_bVerifySSL_ = TRUE
	_cProxy_ = ""
	_cProxyAuth_ = ""          # "user:pass" for the proxy
	_cAuthUser_ = ""
	_cAuthPass_ = ""
	_cAuthType_ = ""           # "", basic, digest, ntlm, negotiate, any
	_cBearer_ = ""             # Bearer token (OAuth2)
	_cClientCert_ = ""         # mTLS client certificate path
	_cClientKey_ = ""          # mTLS client private key path
	_cCookieFile_ = ""         # read cookies from this file
	_cCookieJar_ = ""          # write cookies to this file
	_cAcceptEncoding_ = ""     # value passed to libcurl when enabled
	_bAcceptEncoding_ = FALSE  # off by default (no compression unless opted in)

	# Per-layer timeouts in milliseconds (0 = use the engine default:
	# connect 5s, request 30s). Wired to the custom HTTP/1.1 client +
	# connection pool (engine/src/httpcore.zig + http_pool.zig).
	_connect_timeout_ms_ = 0
	_request_timeout_ms_ = 0

	def init()
		# stzNetwork.init handles its own fields.

	# ── headers / cookies ────────────────────────────────────

	def SetUserAgent(cAgent)
		_user_agent_ = cAgent
		return This

	def SetHeader(cName, cValue)
		_headers_list_ + (cName + ": " + cValue)
		return This

	def SetHeaders(aHeaders)
		_headers_list_ = aHeaders
		return This

	def SetCookie(cName, cValue)
		_cookies_list_ + (cName + "=" + cValue)
		return This

	def SetCookies(aCookies)
		_cookies_list_ = aCookies
		return This

	# ── distributed tracing (W3C Trace Context) ──────────────
	# Inject a `traceparent` header so downstream services can correlate
	# this request into a single distributed trace (Tier 2 observability).

	def SetTraceParent(cTraceParent)
		This.SetHeader("traceparent", cTraceParent)
		return This

	# Generate a fresh sampled trace and attach it; returns the header
	# value so the caller can record / correlate it.
	def StartTrace()
		_cTP_ = StzEngineTraceNew()
		This.SetHeader("traceparent", _cTP_)
		return _cTP_

	# Compose the engine's headers blob from user agent + cookies +
	# custom headers. Each "Name: Value" pair separated by newline.
	def _ComposeHeaderBlob()
		_aLines_ = []
		if _user_agent_ != ""
			_aLines_ + ("User-Agent: " + _user_agent_)
		ok
		if len(_cookies_list_) > 0
			_cCookie_ = ""
			_nC_ = len(_cookies_list_)
			for _i_ = 1 to _nC_
				if _i_ > 1 _cCookie_ += "; " ok
				_cCookie_ += _cookies_list_[_i_]
			next
			_aLines_ + ("Cookie: " + _cCookie_)
		ok
		_nH_ = len(_headers_list_)
		for _i_ = 1 to _nH_
			_aLines_ + _headers_list_[_i_]
		next
		_cOut_ = ""
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cOut_ += char(10) ok
			_cOut_ += _aLines_[_i_]
		next
		return _cOut_

	# ── timeouts (engine-backed) ─────────────────────────────
	# These now drive the custom HTTP/1.1 client's per-socket and
	# connect deadlines via the engine, replacing the slice-2 no-ops.

	def SetTimeout(nSeconds)
		# Overall request timeout, expressed in seconds for API parity
		# with stzNetwork.SetTimeout. Stored in ms for the engine.
		_timeout_seconds_ = nSeconds
		_request_timeout_ms_ = nSeconds * 1000
		return This

	def SetConnectTimeout(nMs)
		_connect_timeout_ms_ = nMs
		return This

	def SetRequestTimeout(nMs)
		_request_timeout_ms_ = nMs
		return This

	def ConnectTimeout()
		return _connect_timeout_ms_

	def RequestTimeout()
		return _request_timeout_ms_

	# Set the process-wide engine defaults (connect / request / idle in
	# ms). 0 leaves a field unchanged. Affects every client.
	def SetDefaultTimeouts(nConnectMs, nRequestMs, nIdleMs)
		StzEngineHttpSetDefaultTimeouts(nConnectMs, nRequestMs, nIdleMs)
		return This

	# ── connection pool ──────────────────────────────────────

	# Graceful shutdown -- release pooled (idle keep-alive) connections.
	# Returns the number of idle sockets closed. In-flight synchronous
	# requests are unaffected. (The thread pool's drain is the separate
	# StzEnginePoolDrain primitive.)
	def Shutdown()
		return StzEngineHttpPoolShutdown()

	def PoolStats()
		# Engine returns "opens=N\treuses=N\tidle=N\tactive=N".
		_cRaw_ = StzEngineHttpPoolStats()
		_aR_ = [ :opens = 0, :reuses = 0, :idle = 0, :active = 0 ]
		if _cRaw_ = "" return _aR_ ok
		_aParts_ = @split(_cRaw_, char(9))
		_nP_ = len(_aParts_)
		for _i_ = 1 to _nP_
			_cKV_ = _aParts_[_i_]
			_nEq_ = StzFindFirst(_cKV_, "=")
			if _nEq_ < 1 loop ok
			_cKey_ = StzLeft(_cKV_, _nEq_ - 1)
			_cVal_ = StzMidToEnd(_cKV_, _nEq_ + 1)
			switch _cKey_
			on "opens"  _aR_[:opens]  = 0 + _cVal_
			on "reuses" _aR_[:reuses] = 0 + _cVal_
			on "idle"   _aR_[:idle]   = 0 + _cVal_
			on "active" _aR_[:active] = 0 + _cVal_
			off
		next
		return _aR_

	# ── settings (all engine-backed via libcurl) ─────────────

	def FollowRedirects(bFollow)
		_bFollowRedirects_ = bFollow
		return This

	def VerifySSL(bVerify)
		_bVerifySSL_ = bVerify
		return This

	def SetProxy(cProxy_)
		_cProxy_ = cProxy_
		return This

	# Proxy credentials, "user:pass".
	def SetProxyAuth(cUser, cPass)
		_cProxyAuth_ = cUser + ":" + cPass
		return This

	# HTTP auth (Basic by default; libcurl base64-encodes + handles the
	# challenge). Use SetAuthType for digest/ntlm/negotiate/any.
	def SetAuth(cUser, cPass)
		_cAuthUser_ = cUser
		_cAuthPass_ = cPass
		return This

	def SetAuthType(cType)
		_cAuthType_ = lower(cType)
		return This

	# Bearer / OAuth2 token auth.
	def SetBearer(cToken)
		_cBearer_ = cToken
		return This

	# mTLS: client certificate + private key (file paths, PEM).
	def SetClientCert(cCertPath, cKeyPath)
		_cClientCert_ = cCertPath
		_cClientKey_ = cKeyPath
		return This

	# Persistent cookies: read from / write to a Netscape cookie file.
	def SetCookieFile(cPath)
		_cCookieFile_ = cPath
		return This

	def SetCookieJar(cPath)
		_cCookieJar_ = cPath
		return This

	# Enable response decompression. "" lets libcurl advertise every
	# encoding it was built with (gzip/deflate when zlib is linked).
	def AcceptEncoding(cEnc)
		_cAcceptEncoding_ = cEnc
		_bAcceptEncoding_ = TRUE
		return This

	# Advertise every encoding libcurl was built with (gzip/deflate when
	# zlib is linked); libcurl auto-decompresses the response.
	def AcceptGzip()
		_cAcceptEncoding_ = ""
		_bAcceptEncoding_ = TRUE
		return This

	# Build the engine options blob ("key=value" newline lines) from the
	# settings above. Only non-default settings are emitted.
	def _ComposeOptionsBlob()
		_aLines_ = []
		if _cProxy_ != ""        _aLines_ + ("proxy=" + _cProxy_) ok
		if _cProxyAuth_ != ""    _aLines_ + ("proxyuserpwd=" + _cProxyAuth_) ok
		if _cAuthUser_ != "" or _cAuthPass_ != ""
			_aLines_ + ("userpwd=" + _cAuthUser_ + ":" + _cAuthPass_)
		ok
		if _cAuthType_ != ""     _aLines_ + ("authtype=" + _cAuthType_) ok
		if _cBearer_ != ""       _aLines_ + ("bearer=" + _cBearer_) ok
		if _cClientCert_ != ""   _aLines_ + ("sslcert=" + _cClientCert_) ok
		if _cClientKey_ != ""    _aLines_ + ("sslkey=" + _cClientKey_) ok
		if _cCookieFile_ != ""   _aLines_ + ("cookiefile=" + _cCookieFile_) ok
		if _cCookieJar_ != ""    _aLines_ + ("cookiejar=" + _cCookieJar_) ok
		if _bAcceptEncoding_ = TRUE  _aLines_ + ("acceptencoding=" + _cAcceptEncoding_) ok
		if _bVerifySSL_ = FALSE  _aLines_ + "verifyssl=0" ok
		if _bFollowRedirects_ = FALSE _aLines_ + "followredirects=0" ok
		_cOut_ = ""
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cOut_ += char(10) ok
			_cOut_ += _aLines_[_i_]
		next
		return _cOut_

	# ── verbs ────────────────────────────────────────────────

	def Get_(cUrl)
		return This._Perform($STZ_HTTP_METHOD_GET, cUrl, "", "")

	def Post(cUrl, cData)
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/octet-stream", cData)

	def Put_(cUrl, cData)
		return This._Perform($STZ_HTTP_METHOD_PUT, cUrl, "application/octet-stream", cData)

	def Delete(cUrl)
		return This._Perform($STZ_HTTP_METHOD_DELETE, cUrl, "", "")

	def Head(cUrl)
		return This._Perform($STZ_HTTP_METHOD_HEAD, cUrl, "", "")

	def Options(cUrl)
		return This._Perform($STZ_HTTP_METHOD_OPTIONS, cUrl, "", "")

	# ── unified perform ──────────────────────────────────────

	def _Perform(nMethodCode, cUrl, cContentType, cBody)
		_cHeaders_ = This._ComposeHeaderBlob()
		_cOpts_ = This._ComposeOptionsBlob()
		# Unified path: RequestEx carries timeouts (0 = engine default) AND
		# the options blob (proxy/auth/mTLS/cookies/verify/redirect/encoding).
		_last_response_ = StzEngineHttpRequestEx(nMethodCode, cUrl, _cHeaders_,
			cContentType, cBody, _connect_timeout_ms_, _request_timeout_ms_, _cOpts_)
		_last_response_code_ = StzEngineHttpLastStatus()
		_last_response_headers_ = StzEngineHttpLastHeaders()
		This._RecordRequest(cUrl, _last_response_code_)
		if _last_response_code_ <= 0
			# Transport / engine error -- LastError already captured
			# by _RecordRequest via StzEngineHttpLastError().
			return This
		ok
		ClearErrors()
		return This

	def PerformRequest()
		# Compatibility shim -- legacy code expects this method to
		# exist. Without state on which verb to send, it is a no-op.
		return This

	# ── response accessors ───────────────────────────────────

	def Response()
		return [
			:body    = _last_response_,
			:code    = _last_response_code_,
			:headers = _last_response_headers_,
			:info    = This.ConnectionInfo()
		]

	def ResponseCode()
		return _last_response_code_

	def ResponseBody()
		return _last_response_

	def ResponseHeaders()
		return _last_response_headers_

	def ResponseTime()
		# Engine slice 2 does not yet expose per-request timing.
		return 0

	# ── form helpers ─────────────────────────────────────────

	def PostForm(cUrl, aFormData)
		_cForm_ = ""
		_nL_ = len(aFormData)
		for _i_ = 1 to _nL_ step 2
			if _i_ > 1 _cForm_ += "&" ok
			_cForm_ += URLEncode(aFormData[_i_]) + "=" + URLEncode(aFormData[_i_ + 1])
		next
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/x-www-form-urlencoded", _cForm_)

	def PostJson(cUrl, cJson)
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/json", cJson)

	# ── files ────────────────────────────────────────────────

	def DownloadFile(cUrl, cLocalPath)
		This.Get_(cUrl)
		if This.HasError() return This ok
		write(cLocalPath, This.ResponseBody())
		return This

	# ── batched GET ─────────────────────────────────────────
	# GetMany uses the engine's threaded parallel-GET path (one
	# std.Thread per URL, blocking client.fetch in each). The
	# engine joins all threads before returning, so from Ring's
	# perspective the call is synchronous; the win is wall-clock,
	# not concurrency model. Up to 32 URLs per batch.

	def GetMany(aUrls)
		_cBlob_ = ""
		_nL_ = len(aUrls)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cBlob_ += char(10) ok
			_cBlob_ += aUrls[_i_]
		next
		_cJoined_ = StzEngineHttpParallelGet(_cBlob_)
		# Split on the RECORD_SEPARATOR (ASCII 0x1E).
		_aRaw_ = @split(_cJoined_, char(30))
		_aR_ = []
		_nR_ = len(_aRaw_)
		for _i_ = 1 to _nR_
			_rec_ = _aRaw_[_i_]
			if _rec_ = "" loop ok
			_nC_ = StzFindFirst(_rec_, ":")
			if _nC_ < 1 loop ok
			_cStatus_ = StzLeft(_rec_, _nC_ - 1)
			_cBody_ = StzMidToEnd(_rec_, _nC_ + 1)
			_aR_ + [
				:body    = _cBody_,
				:code    = 0 + _cStatus_,
				:headers = "",
				:info    = []
			]
		next
		return _aR_

	def GetManySequential(aUrls)
		# Kept as a backup for callers that need strictly sequential
		# semantics. The default GetMany above is parallel.
		_aR_ = []
		_nL_ = len(aUrls)
		for _i_ = 1 to _nL_
			This.Get_(aUrls[_i_])
			_aR_ + This.Response()
		next
		return _aR_
