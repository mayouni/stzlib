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
	headers_list = []           # accumulated "Name: Value" strings
	cookies_list = []           # accumulated "k=v" strings
	user_agent = "Softanza-HTTP/1.0"

	# Response state
	last_response = ""
	last_response_code = 0
	last_response_headers = ""   # std.http does not yet expose these

	# Cosmetic settings (not yet enforced by the engine)
	bFollowRedirects = TRUE
	bVerifySSL = TRUE
	cProxy = ""
	cAuthUser = ""
	cAuthPass = ""

	def init()
		# stzNetwork.init handles its own fields.

	# ── headers / cookies ────────────────────────────────────

	def SetUserAgent(cAgent)
		user_agent = cAgent
		return This

	def SetHeader(cName, cValue)
		headers_list + (cName + ": " + cValue)
		return This

	def SetHeaders(aHeaders)
		headers_list = aHeaders
		return This

	def SetCookie(cName, cValue)
		cookies_list + (cName + "=" + cValue)
		return This

	def SetCookies(aCookies)
		cookies_list = aCookies
		return This

	# Compose the engine's headers blob from user agent + cookies +
	# custom headers. Each "Name: Value" pair separated by newline.
	def _ComposeHeaderBlob()
		_aLines_ = []
		if user_agent != ""
			_aLines_ + ("User-Agent: " + user_agent)
		ok
		if len(cookies_list) > 0
			_cCookie_ = ""
			_nC_ = len(cookies_list)
			for _i_ = 1 to _nC_
				if _i_ > 1 _cCookie_ += "; " ok
				_cCookie_ += cookies_list[_i_]
			next
			_aLines_ + ("Cookie: " + _cCookie_)
		ok
		_nH_ = len(headers_list)
		for _i_ = 1 to _nH_
			_aLines_ + headers_list[_i_]
		next
		_cOut_ = ""
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			if _i_ > 1 _cOut_ += char(10) ok
			_cOut_ += _aLines_[_i_]
		next
		return _cOut_

	# ── settings (no-ops at engine slice 2 -- kept for API parity) ─

	def FollowRedirects(bFollow)
		bFollowRedirects = bFollow
		return This

	def VerifySSL(bVerify)
		bVerifySSL = bVerify
		return This

	def SetProxy(cProxy_)
		cProxy = cProxy_
		return This

	def SetAuth(cUser, cPass)
		cAuthUser = cUser
		cAuthPass = cPass
		# Basic auth header is the most commonly needed shape.
		if cUser != "" or cPass != ""
			# Trivial Base64-free fallback: engine slice 2 doesn't
			# implement encoding yet; record and warn the caller.
			? "WARNING: SetAuth recorded but not yet sent (engine slice 2)"
		ok
		return This

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
		last_response = StzEngineHttpRequest(nMethodCode, cUrl, _cHeaders_, cContentType, cBody)
		last_response_code = StzEngineHttpLastStatus()
		This._RecordRequest(cUrl, last_response_code)
		if last_response_code <= 0
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
			:body    = last_response,
			:code    = last_response_code,
			:headers = last_response_headers,
			:info    = This.ConnectionInfo()
		]

	def ResponseCode()
		return last_response_code

	def ResponseBody()
		return last_response

	def ResponseHeaders()
		return last_response_headers

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

	# ── batched GET (sequential only; libuv-backed parallel form
	#    dropped with M-DEP3 slice 2; M-DEP4 will revisit) ─────

	def GetMany(aUrls)
		return This.GetManySequential(aUrls)

	def GetManySequential(aUrls)
		_aR_ = []
		_nL_ = len(aUrls)
		for _i_ = 1 to _nL_
			This.Get_(aUrls[_i_])
			_aR_ + This.Response()
		next
		return _aR_
