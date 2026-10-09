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

# Sends HTTP and HTTPS requests through the engine and keeps the last answer, with settings for headers, cookies, auth, proxy and timeouts.
#
# Configure the client with the Set methods, each of which returns the client so calls chain, then
# send with Get_, Post, Put_, Delete, Head, Options, PostForm or PostJson and read the answer with
# ResponseCode, ResponseBody and ResponseHeaders. A status of 4xx or 5xx is an answer, not an error;
# a request that never reached a server gives ResponseCode -1 and sets LastError. GetMany fetches up
# to 32 addresses in one parallel call. The requests need a network: to try the class offline, start
# the engine's loopback fixture with StzEngineTestServerStart(0) and stop it with
# StzEngineTestServerStop(), as test/network/73_http_loopback_narrated.ring does.
#
#   receiver   o1 = new stzHttpClient()
#   example    o1.SetTimeout(5)
#              ? o1.Timeout()
#              #--> 5
#              ? o1.RequestTimeout()
#              #--> 5000
#   see        stzNetwork, stzPiSpiHttpFront
class stzHttpClient from stzNetwork

	# Request-state
	@headers_list = []           # accumulated "Name: Value" strings
	@cookies_list = []           # accumulated "k=v" strings
	@user_agent = "Softanza-HTTP/1.0"

	# Response state
	@last_response = ""
	@last_response_code = 0
	@last_response_headers = ""   # std.http does not yet expose these

	# Connection / TLS / auth settings -- all engine-backed via libcurl
	# (passed as the per-request options blob; see _ComposeOptionsBlob).
	@bFollowRedirects = 1
	@bVerifySSL = 1
	@cProxy = ""
	@cProxyAuth = ""          # "user:pass" for the proxy
	@cAuthUser = ""
	@cAuthPass = ""
	@cAuthType = ""           # "", basic, digest, ntlm, negotiate, any
	@cBearer = ""             # Bearer token (OAuth2)
	@cClientCert = ""         # mTLS client certificate path
	@cClientKey = ""          # mTLS client private key path
	@cCookieFile = ""         # read cookies from this file
	@cCookieJar = ""          # write cookies to this file
	@cAcceptEncoding = ""     # value passed to libcurl when enabled
	@bAcceptEncoding = 0  # off by default (no compression unless opted in)

	# Per-layer timeouts in milliseconds (0 = use the engine default:
	# connect 5s, request 30s). Wired to the custom HTTP/1.1 client +
	# connection pool (engine/src/httpcore.zig + http_pool.zig).
	@connect_timeout_ms = 0
	@request_timeout_ms = 0

	# Builds a client with no headers, no cookies, the user agent Softanza-HTTP/1.0 and the engine default timeouts.
	#
	#   returns    nothing; the object is built
	#   note       every field starts from its declared default
	#   see        SetHeader, Get_
	def init()
	# Sets the User-Agent header sent with every later request, replacing Softanza-HTTP/1.0.
	#
	#   cAgent     the User-Agent text
	#   returns    the client itself, so calls chain
	#   see        SetHeader, SetCookie
	#@ aka  stzNetwork.init handles its own fields.
	def SetUserAgent(cAgent)
		@user_agent = cAgent
		return This

	# Adds one request header, sent with every later request, after the headers already added.
	#
	#   cName      the header name
	#   cValue     the header value
	#   returns    the client itself, so calls chain
	#   note       adding the same name twice sends both lines; a header named Authorization reaches
	#              the server (a loopback /auth answered 200)
	#   see        SetHeaders, SetUserAgent, SetBearer
	def SetHeader(cName, cValue)
		@headers_list + (cName + ": " + cValue)
		return This

	# Replaces all the custom headers with a list of ready-made Name: Value lines.
	#
	#   aHeaders   a list of texts, each Name: Value
	#   returns    the client itself, so calls chain
	#   note       headers added earlier through SetHeader are dropped
	#   see        SetHeader
	def SetHeaders(aHeaders)
		@headers_list = aHeaders
		return This

	# Adds one name=value cookie, sent in a single Cookie header with every later request.
	#
	#   cName      the cookie name
	#   cValue     the cookie value
	#   returns    the client itself, so calls chain
	#   note       two cookies are joined as sid=abc; k=v (a loopback /checkcookie answered that
	#              text)
	#   see        SetCookies, SetCookieFile
	def SetCookie(cName, cValue)
		@cookies_list + (cName + "=" + cValue)
		return This

	# Replaces all the cookies with a list of ready-made name=value texts.
	#
	#   aCookies   a list of texts, each name=value
	#   returns    the client itself, so calls chain
	#   note       cookies added earlier through SetCookie are dropped
	#   see        SetCookie
	def SetCookies(aCookies)
		@cookies_list = aCookies
		return This

	# Sets the W3C traceparent header so a downstream service can place the request in the caller's trace.
	#
	#   cTraceParent   a traceparent value such as 00-<trace id>-<span id>-01
	#   returns        the client itself, so calls chain
	#   note           the value is not validated, it is sent as given
	#   see            StartTrace, SetHeader
	#@ aka  ── distributed tracing (W3C Trace Context) ────────────── Inject a `traceparent` header so downstream services can correlate this request into a single distributed trace (Tier 2 observability).
	def SetTraceParent(cTraceParent)
		This.SetHeader("traceparent", cTraceParent)
		return This

	# Starts a fresh sampled trace, adds it as the traceparent header and returns its value.
	#
	#   returns    a text, the new traceparent value
	#   note       each call makes a new trace id, and the header is added, not replaced, so a
	#              second call sends two traceparent lines
	#   see        SetTraceParent
	#@ aka  Generate a fresh sampled trace and attach it; returns the header value so the caller can record / correlate it.
	def StartTrace()
		_cTP_ = StzEngineTraceNew()
		This.SetHeader("traceparent", _cTP_)
		return _cTP_

	# Compose the engine's headers blob from user agent + cookies +
	# custom headers. Each "Name: Value" pair separated by newline.
	def _ComposeHeaderBlob()
		_aLines_ = []
		if @user_agent != ""
			_aLines_ + ("User-Agent: " + @user_agent)
		ok
		if len(@cookies_list) > 0
			_cCookie_ = ""
			_nC_ = len(@cookies_list)
			for _i_ = 1 to _nC_
				if _i_ > 1 _cCookie_ += "; " ok
				_cCookie_ += @cookies_list[_i_]
			next
			_aLines_ + ("Cookie: " + _cCookie_)
		ok
		_nH_ = len(@headers_list)
		for _i_ = 1 to _nH_
			_aLines_ + @headers_list[_i_]
		next
		_cOut_ = ""
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cOut_ += char(10) ok
			_cOut_ += _aLines_[_i_]
		next
		return _cOut_

	# Sets the overall request timeout in seconds, so that Timeout and RequestTimeout both report it.
	#
	#   nSeconds   the timeout in seconds, stored in milliseconds for the engine
	#   returns    the client itself, so calls chain
	#   note       SetTimeout(5) makes RequestTimeout answer 5000
	#   see        SetRequestTimeout, SetConnectTimeout
	#@ aka  ── timeouts (engine-backed) ───────────────────────────── These now drive the custom HTTP/1.1 client's per-socket and connect deadlines via the engine, replacing the slice-2 no-ops.
	def SetTimeout(nSeconds)
		# Overall request timeout, expressed in seconds for API parity
		# with stzNetwork.SetTimeout. Stored in ms for the engine.
		#
		# @timeout_seconds is the INHERITED slot stzNetwork.Timeout()
		# reads. It was being written to `_timeout_seconds_`, a local
		# that died at method exit -- so this override set the engine's
		# ms value correctly and left Timeout() reporting the default
		# 30 forever, however many times you called SetTimeout.
		# Same shape as the TCP LastError break (4e52e7a05): an
		# inherited attribute write turned into a local, silently.
		@timeout_seconds = nSeconds
		@request_timeout_ms = nSeconds * 1000
		return This

	# Sets how long the client waits to open a connection, in milliseconds.
	#
	#   nMs        the connect timeout in milliseconds, 0 keeps the engine default of 5 seconds
	#   returns    the client itself, so calls chain
	#   see        ConnectTimeout, SetRequestTimeout
	def SetConnectTimeout(nMs)
		@connect_timeout_ms = nMs
		return This

	# Sets how long one whole request may take, in milliseconds.
	#
	#   nMs        the request timeout in milliseconds, 0 keeps the engine default of 30 seconds
	#   returns    the client itself, so calls chain
	#   note       a request that outlives it ends with ResponseCode -1 (loopback test
	#              73_http_loopback_narrated)
	#   see        RequestTimeout, SetTimeout
	def SetRequestTimeout(nMs)
		@request_timeout_ms = nMs
		return This

	# Returns the connect timeout this client was given, in milliseconds.
	#
	#   returns    a number; 0 when the engine default applies
	#   see        SetConnectTimeout
	def ConnectTimeout()
		return @connect_timeout_ms

	# Returns the request timeout this client was given, in milliseconds.
	#
	#   returns    a number; 0 when the engine default applies
	#   see        SetRequestTimeout, SetTimeout
	def RequestTimeout()
		return @request_timeout_ms

	# Sets the engine-wide default connect, request and idle timeouts for every client in the process.
	#
	#   nConnectMs   the default connect timeout in milliseconds
	#   nRequestMs   the default request timeout in milliseconds
	#   nIdleMs      the idle timeout of pooled connections in milliseconds
	#   returns      the client itself, so calls chain
	#   note         a value of 0 leaves that default unchanged, and the change outlives this client
	#   see          SetConnectTimeout, SetRequestTimeout
	#@ aka  Set the process-wide engine defaults (connect / request / idle in ms). 0 leaves a field unchanged. Affects every client.
	def SetDefaultTimeouts(nConnectMs, nRequestMs, nIdleMs)
		StzEngineHttpSetDefaultTimeouts(nConnectMs, nRequestMs, nIdleMs)
		return This

	# Closes the idle keep-alive connections held in the engine pool and counts them.
	#
	#   returns    a number, how many idle sockets were closed
	#   note       requests in flight are not touched, and 0 is the normal answer when every server
	#              closed its connection after the reply
	#   see        PoolStats
	#@ aka  ── connection pool ──────────────────────────────────────
	def Shutdown()
		return StzEngineHttpPoolShutdown()

	# Returns the connection pool counters as a hash list of opens, reuses, idle and active connections.
	#
	#   returns    a hash list with the keys opens, reuses, idle and active, all numbers
	#   note       the counters are process-wide, not per client
	#   see        Shutdown
	def PoolStats()
		# Engine returns "opens=N\treuses=N\tidle=N\tactive=N".
		_cRaw_ = StzEngineHttpPoolStats()
		_aR_ = [ :opens = 0, :reuses = 0, :idle = 0, :active = 0 ]
		if _cRaw_ = "" return _aR_ ok
		_aParts_ = @split(_cRaw_, char(9))
		_nP_ = len(_aParts_)
		for _i_ = 1 to _nP_
			_cKV_ = _aParts_[_i_]
			_nEq_ = StzFindFirst("=", _cKV_)
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

	# Switches the following of 3xx redirects on or off for later requests; it is on by default.
	#
	#   bFollow    TRUE to follow redirects, FALSE to receive the 302 itself
	#   returns    the client itself, so calls chain
	#   note       with it off, a 3-hop redirect chain answers 302, with it on 200
	#   see        VerifySSL, Get_
	#@ aka  ── settings (all engine-backed via libcurl) ─────────────
	def FollowRedirects(bFollow)
		@bFollowRedirects = bFollow
		return This

	# Switches the check of the server's TLS certificate on or off for later requests; it is on by default.
	#
	#   bVerify    TRUE to check certificates, FALSE to accept any
	#   returns    the client itself, so calls chain
	#   note       not run against a TLS server: only plain loopback HTTP was called, where it
	#              changes nothing
	#   see        SetClientCert
	def VerifySSL(bVerify)
		@bVerifySSL = bVerify
		return This

	# Routes later requests through a proxy, given as host:port.
	#
	#   cProxy_    the proxy address such as 127.0.0.1:3128, an empty text removes the proxy
	#   returns    the client itself, so calls chain
	#   note       pointing at a port with nothing listening makes the request fail with
	#              ResponseCode -1
	#   see        SetProxyAuth
	def SetProxy(cProxy_)
		@cProxy = cProxy_
		return This

	# Stores the user and password the client presents to its proxy, sent as user:password.
	#
	#   cUser      the proxy user name
	#   cPass      the proxy password
	#   returns    the client itself, so calls chain
	#   note       it matters only while a proxy is set, and no authenticating proxy was available
	#              to run it against
	#   see        SetProxy
	#@ aka  Proxy credentials, "user:pass".
	def SetProxyAuth(cUser, cPass)
		@cProxyAuth = cUser + ":" + cPass
		return This

	# Sets the user and password for HTTP authentication, Basic unless SetAuthType says otherwise.
	#
	#   cUser      the user name
	#   cPass      the password
	#   returns    the client itself, so calls chain
	#   note       a loopback /auth endpoint that wants any Authorization header answered 401
	#              without it and 200 with it
	#   see        SetAuthType, SetBearer
	#@ aka  HTTP auth (Basic by default; libcurl base64-encodes + handles the challenge). Use SetAuthType for digest/ntlm/negotiate/any.
	def SetAuth(cUser, cPass)
		@cAuthUser = cUser
		@cAuthPass = cPass
		return This

	# Chooses the HTTP authentication scheme that SetAuth uses.
	#
	#   cType      basic, digest, ntlm, negotiate or any, in any case
	#   returns    the client itself, so calls chain
	#   note       the text is stored in lower case, and only basic was run because the other
	#              schemes need a server that asks for them
	#   see        SetAuth
	def SetAuthType(cType)
		@cAuthType = lower(cType)
		return This

	# Sets an OAuth2 bearer token sent as the Authorization header of later requests.
	#
	#   cToken     the bearer token
	#   returns    the client itself, so calls chain
	#   note       the token travels in clear on plain HTTP, and a loopback /auth endpoint answered
	#              200
	#   see        SetAuth, SetHeader
	#@ aka  Bearer / OAuth2 token auth.
	def SetBearer(cToken)
		@cBearer = cToken
		return This

	# Sets the client certificate and private key used for mutual TLS.
	#
	#   cCertPath   the path of the PEM certificate file
	#   cKeyPath    the path of the PEM private key file
	#   returns     the client itself, so calls chain
	#   note        not run against a TLS server: on plain HTTP with missing files the request still
	#               answered 200, so the paths are not read there
	#   see         VerifySSL
	#@ aka  mTLS: client certificate + private key (file paths, PEM).
	def SetClientCert(cCertPath, cKeyPath)
		@cClientCert = cCertPath
		@cClientKey = cKeyPath
		return This

	# Sets a Netscape cookie file from which later requests read their cookies.
	#
	#   cPath      the path of the cookie file
	#   returns    the client itself, so calls chain
	#   note       give SetCookieJar the same path to keep cookies between requests
	#   see        SetCookieJar, SetCookie
	#@ aka  Persistent cookies: read from / write to a Netscape cookie file.
	def SetCookieFile(cPath)
		@cCookieFile = cPath
		return This

	# Sets the cookie file in which cookies received from servers are saved.
	#
	#   cPath      the path of the file to write
	#   returns    the client itself, so calls chain
	#   note       with the same path as SetCookieFile, a cookie set by /setcookie came back on the
	#              next request
	#   see        SetCookieFile
	def SetCookieJar(cPath)
		@cCookieJar = cPath
		return This

	# Asks servers for compressed answers and decompresses them, for the encodings named.
	#
	#   cEnc       the encodings to advertise such as gzip, an empty text advertises every one the
	#              engine supports
	#   returns    the client itself, so calls chain
	#   note       compression is off until this or AcceptGzip is called, and the loopback server
	#              never compresses, so only the call was checked
	#   see        AcceptGzip
	#@ aka  Enable response decompression. "" lets libcurl advertise every encoding it was built with (gzip/deflate when zlib is linked).
	def AcceptEncoding(cEnc)
		@cAcceptEncoding = cEnc
		@bAcceptEncoding = 1
		return This

	# Asks servers for compressed answers in every encoding the engine supports and decompresses them.
	#
	#   returns    the client itself, so calls chain
	#   note       the loopback server never compresses, so only the call was checked
	#   see        AcceptEncoding
	#@ aka  Advertise every encoding libcurl was built with (gzip/deflate when zlib is linked); libcurl auto-decompresses the response.
	def AcceptGzip()
		@cAcceptEncoding = ""
		@bAcceptEncoding = 1
		return This

	# Build the engine options blob ("key=value" newline lines) from the
	# settings above. Only non-default settings are emitted.
	def _ComposeOptionsBlob()
		_aLines_ = []
		if @cProxy != ""        _aLines_ + ("proxy=" + @cProxy) ok
		if @cProxyAuth != ""    _aLines_ + ("proxyuserpwd=" + @cProxyAuth) ok
		if @cAuthUser != "" or @cAuthPass != ""
			_aLines_ + ("userpwd=" + @cAuthUser + ":" + @cAuthPass)
		ok
		if @cAuthType != ""     _aLines_ + ("authtype=" + @cAuthType) ok
		if @cBearer != ""       _aLines_ + ("bearer=" + @cBearer) ok
		if @cClientCert != ""   _aLines_ + ("sslcert=" + @cClientCert) ok
		if @cClientKey != ""    _aLines_ + ("sslkey=" + @cClientKey) ok
		if @cCookieFile != ""   _aLines_ + ("cookiefile=" + @cCookieFile) ok
		if @cCookieJar != ""    _aLines_ + ("cookiejar=" + @cCookieJar) ok
		if @bAcceptEncoding = 1  _aLines_ + ("acceptencoding=" + @cAcceptEncoding) ok
		if @bVerifySSL = 0  _aLines_ + "verifyssl=0" ok
		if @bFollowRedirects = 0 _aLines_ + "followredirects=0" ok
		_cOut_ = ""
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cOut_ += char(10) ok
			_cOut_ += _aLines_[_i_]
		next
		return _cOut_

	# Sends a GET request and keeps the answer in the client.
	#
	#   cUrl       the address to fetch
	#   returns    the client itself, so read the answer with ResponseCode and ResponseBody
	#   note       the name ends in an underscore because Get is taken by the language
	#   warning    a transport failure gives ResponseCode -1 and sets LastError, while a 4xx or 5xx
	#              status is not an error, only a code
	#   see        Post, ResponseBody, ResponseCode, GetMany
	#@ aka  ── verbs ────────────────────────────────────────────────
	def Get_(cUrl)
		return This._Perform($STZ_HTTP_METHOD_GET, cUrl, "", "")

	# Sends a POST request with a body, content type application/octet-stream, and keeps the answer.
	#
	#   cUrl       the address to post to
	#   cData      the request body as text
	#   returns    the client itself, so read the answer with ResponseBody
	#   note       a loopback /echo answered with the same body
	#   see        PostForm, PostJson, Put_
	def Post(cUrl, cData)
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/octet-stream", cData)

	# Sends a PUT request with a body, content type application/octet-stream, and keeps the answer.
	#
	#   cUrl       the address to put to
	#   cData      the request body as text
	#   returns    the client itself, so read the answer with ResponseBody
	#   note       the name ends in an underscore because Put is taken by the language
	#   see        Post, Delete
	def Put_(cUrl, cData)
		return This._Perform($STZ_HTTP_METHOD_PUT, cUrl, "application/octet-stream", cData)

	# Sends a DELETE request and keeps the answer.
	#
	#   cUrl       the address to delete
	#   returns    the client itself, so read the answer with ResponseCode
	#   see        Get_, Head
	def Delete(cUrl)
		return This._Perform($STZ_HTTP_METHOD_DELETE, cUrl, "", "")

	# Sends a HEAD request, which returns the status and headers but no body.
	#
	#   cUrl       the address to ask about
	#   returns    the client itself, so read the answer with ResponseHeaders
	#   note       ResponseBody stays empty
	#   see        Get_, ResponseHeaders
	def Head(cUrl)
		return This._Perform($STZ_HTTP_METHOD_HEAD, cUrl, "", "")

	# Sends an OPTIONS request and keeps the answer.
	#
	#   cUrl       the address to ask about
	#   returns    the client itself, so read the answer with ResponseHeaders
	#   see        Head, ResponseHeaders
	def Options(cUrl)
		return This._Perform($STZ_HTTP_METHOD_OPTIONS, cUrl, "", "")

	# ── unified perform ──────────────────────────────────────

	def _Perform(nMethodCode, cUrl, cContentType, cBody)
		_cHeaders_ = This._ComposeHeaderBlob()
		_cOpts_ = This._ComposeOptionsBlob()
		# Unified path: RequestEx carries timeouts (0 = engine default) AND
		# the options blob (proxy/auth/mTLS/cookies/verify/redirect/encoding).
		@last_response = StzEngineHttpRequestEx(nMethodCode, cUrl, _cHeaders_,
			cContentType, cBody, @connect_timeout_ms, @request_timeout_ms, _cOpts_)
		@last_response_code = StzEngineHttpLastStatus()
		@last_response_headers = StzEngineHttpLastHeaders()
		This._RecordRequest(cUrl, @last_response_code)
		if @last_response_code <= 0
			# Transport / engine error -- LastError already captured
			# by _RecordRequest via StzEngineHttpLastError().
			return This
		ok
		ClearErrors()
		return This

	# Does nothing and returns the client; it exists only so that older code that calls it still runs.
	#
	#   returns    the client itself
	#   note       it sends no request, because it does not know which verb to use
	#   see        Get_, Post
	def PerformRequest()
		# Compatibility shim -- legacy code expects this method to
		# exist. Without state on which verb to send, it is a no-op.
		return This

	# Returns the last answer as a hash list with its body, status code, header text and connection info.
	#
	#   returns    a hash list with the keys body, code, headers and info
	#   note       before any request the code is 0 and the body is empty, and after a failed
	#              request the code is -1
	#   see        ResponseBody, ResponseCode, ResponseHeaders
	#@ aka  ── response accessors ───────────────────────────────────
	def Response()
		return [
			:body    = @last_response,
			:code    = @last_response_code,
			:headers = @last_response_headers,
			:info    = This.ConnectionInfo()
		]

	# Returns the HTTP status of the last request.
	#
	#   returns    a number; 0 before any request, -1 when no server was reached or the request
	#              timed out
	#   note       a body over the 4 MB engine buffer gives -2
	#   see        Response, Get_
	def ResponseCode()
		return @last_response_code

	# Returns the body of the last answer.
	#
	#   returns    a text; empty for HEAD and for a failed request
	#   see        ResponseCode, Response
	def ResponseBody()
		return @last_response

	# Returns the header block of the last answer as one text, status line first.
	#
	#   returns    a text with CRLF between the lines
	#   see        ResponseBody, Response
	def ResponseHeaders()
		return @last_response_headers

	# Returns 0 whatever happened, because the engine does not report how long a request took.
	#
	#   returns    a number, always 0
	#   note       it is a placeholder, so time the call yourself
	#   see        Response
	def ResponseTime()
		# Engine slice 2 does not yet expose per-request timing.
		return 0

	# Sends a POST with the pairs as a URL-encoded form, content type application/x-www-form-urlencoded.
	#
	#   cUrl        the address to post to
	#   aFormData   a flat list of key, value, key, value texts
	#   returns     the client itself, so read the answer with ResponseBody
	#   note        a space becomes + and an ampersand becomes %26 (the loopback echo returned
	#               a=1+2&b=x%26y)
	#   see         Post, PostJson
	#@ aka  ── form helpers ─────────────────────────────────────────
	def PostForm(cUrl, aFormData)
		_cForm_ = ""
		_nL_ = len(aFormData)
		for _i_ = 1 to _nL_ step 2
			if _i_ > 1 _cForm_ += "&" ok
			_cForm_ += URLEncode(aFormData[_i_]) + "=" + URLEncode(aFormData[_i_ + 1])
		next
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/x-www-form-urlencoded", _cForm_)

	# Sends a POST whose body is the given JSON text, content type application/json.
	#
	#   cUrl       the address to post to
	#   cJson      the JSON text to send, which is not checked
	#   returns    the client itself, so read the answer with ResponseBody
	#   see        Post, PostForm
	def PostJson(cUrl, cJson)
		return This._Perform($STZ_HTTP_METHOD_POST, cUrl, "application/json", cJson)

	# Fetches an address with a GET and writes the body to a local file.
	#
	#   cUrl         the address to fetch
	#   cLocalPath   the path of the file to write
	#   returns      the client itself
	#   note         only a transport failure stops the write, an answer with status 404 is still
	#                written to the file
	#   warning      the file is overwritten if it exists
	#   see          Get_
	#@ aka  ── files ────────────────────────────────────────────────
	def DownloadFile(cUrl, cLocalPath)
		This.Get_(cUrl)
		if This.HasError() return This ok
		write(cLocalPath, This.ResponseBody())
		return This

	# Fetches several addresses in one parallel call, each with this client's headers, options and timeouts.
	#
	#   aUrls      a list of at most 32 addresses
	#   returns    a list of hash lists, each with body, code, headers and info
	#   note       the answers come in the order of the addresses, headers is always empty and info
	#              an empty list, and an empty list of addresses gives an empty list
	#   warning    a bearer token set on the client is sent to every address
	#   see        GetManySequential, Get_
	#@ aka  ── batched GET ───────────────────────────────────────── GetMany uses the engine's threaded parallel-GET path (one std.Thread per URL, blocking client.fetch in each). The engine joins all threads before returning, so from Ring's perspective the call is synchronous; the win is wall-clock, not concurrency model. Up to 32 URLs per batch.
	def GetMany(aUrls)
		_cBlob_ = ""
		_nL_ = len(aUrls)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cBlob_ += char(10) ok
			_cBlob_ += aUrls[_i_]
		next
		# THE BATCH IS STILL THIS CLIENT. Its headers, options and timeouts
		# apply to each URL exactly as they would to a single Get_() -- they
		# were dropped here, so a client holding a bearer token sent 32
		# unauthenticated requests, a configured proxy was bypassed, and every
		# per-client timeout fell back to the process default.
		_cJoined_ = StzEngineHttpParallelGet(
			_cBlob_,
			This._ComposeHeaderBlob(),
			This._ComposeOptionsBlob(),
			@connect_timeout_ms,
			@request_timeout_ms
		)
		# Split on the RECORD_SEPARATOR (ASCII 0x1E).
		_aRaw_ = @split(_cJoined_, char(30))
		_aR_ = []
		_nR_ = len(_aRaw_)
		for _i_ = 1 to _nR_
			_rec_ = _aRaw_[_i_]
			if _rec_ = "" loop ok
			_nC_ = StzFindFirst(":", _rec_)
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

	# Fetches several addresses one after the other and returns one full answer for each.
	#
	#   aUrls      a list of addresses
	#   returns    a list of hash lists as Response gives, with the real header text
	#   note       slower than GetMany and not limited to 32 addresses
	#   see        GetMany, Response
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
