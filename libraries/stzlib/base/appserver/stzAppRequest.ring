# The HTTP request VALUE OBJECT: method/path/headers/body plus the
# parsed query string and the protocol (for keep-alive decisions).
# Attributes carry the @ scope sigil -- bare class-head attributes
# capture same-named user globals in Ring 1.27 (verified 2026-07-14).

class stzAppRequest from stzObject
	@cMethod = ""
	@cPath = ""
	@aHeaders = []
	@cBody = ""
	@aParams = []
	@aQuery = []
	@cProtocol = "HTTP/1.1"

	def init(cMethodVal, cPathVal, aHeadersVal, cBodyVal)
		@cMethod = cMethodVal
		@cPath = cPathVal
		@aHeaders = aHeadersVal
		@cBody = cBodyVal
		This.ParseQuery()

	def Method()
		return @cMethod

	def Path()
		return @cPath

	def Headers()
		return @aHeaders

	def Header(cName)
		_nLen_ = len(@aHeaders)
		for _i_ = 1 to _nLen_
			if StzLower(@aHeaders[_i_][1]) = StzLower(cName)
				return @aHeaders[_i_][2]
			ok
		next
		return ""

	def Body()
		return @cBody

	def Protocol()
		return @cProtocol

	def SetProtocol(cProtocolVal)
		@cProtocol = cProtocolVal
		return This

	# TRUE when this request asks the connection to be closed after the
	# response (explicit Connection: close, or an HTTP/1.0 peer that did
	# not opt into keep-alive).
	def WantsClose()
		_cConn_ = StzLower(This.Header("Connection"))
		if _cConn_ = "close"
			return TRUE
		ok
		if @cProtocol = "HTTP/1.0" and _cConn_ != "keep-alive"
			return TRUE
		ok
		return FALSE

	def ParseQuery()
		_nQ_ = StzFindFirst("?", @cPath)
		if _nQ_ > 0
			_cQueryString_ = StzMidToEnd(@cPath, _nQ_ + 1)
			@cPath = StzLeft(@cPath, _nQ_ - 1)

			_aPairs_ = @split(_cQueryString_, "&")
			_nLen_ = len(_aPairs_)
			for _i_ = 1 to _nLen_
				_nEq_ = StzFindFirst("=", _aPairs_[_i_])
				if _nEq_ > 0
					@aQuery + [ StzLeft(_aPairs_[_i_], _nEq_ - 1),
					            StzMidToEnd(_aPairs_[_i_], _nEq_ + 1) ]
				ok
			next
		ok

	def Query(cKey)
		if cKey = NULL return @aQuery ok

		_nLen_ = len(@aQuery)
		for _i_ = 1 to _nLen_
			if @aQuery[_i_][1] = cKey
				return @aQuery[_i_][2]
			ok
		next
		return ""

	# Route path params (bound by the router: /user/:id -> Param("id")).
	def SetParams(paParams)
		@aParams = paParams
		return This

	def Params()
		return @aParams

	def Param(cKey)
		_nLen_ = len(@aParams)
		for _i_ = 1 to _nLen_
			if @aParams[_i_][1] = cKey
				return @aParams[_i_][2]
			ok
		next
		return ""
