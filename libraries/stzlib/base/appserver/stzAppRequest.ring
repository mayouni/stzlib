# The HTTP request VALUE OBJECT: method/path/headers/body plus the
# parsed query string and the protocol (for keep-alive decisions).
# Attributes carry the @ scope sigil -- bare class-head attributes
# capture same-named user globals in Ring 1.27 (verified 2026-07-14).

# Holds one HTTP request as a plain value: method, path, headers, body, query pairs and the path parameters a route bound.
#
# A server builds it from the parsed wire text and a handler reads it. The query string is split off
# the path at birth, so Path never carries a ?. Header names are matched without regard to case,
# while query keys and path parameters are matched with their exact case. WantsClose answers the
# keep-alive question from the protocol and the Connection header.
#
#   receiver   o1 = new stzAppRequest("GET", "/users/42?page=2", [ [ "Host", "shop.test" ] ], "")
#   example    ? o1.Path()
#              #--> /users/42
#              ? o1.Query("page")
#              #--> 2
#              ? o1.Header("host")
#              #--> shop.test
#   see        stzAppResponse, stzAppRouter, stzAppServer
class stzAppRequest from stzObject
	@cMethod = ""
	@cPath = ""
	@aHeaders = []
	@cBody = ""
	@aParams = []
	@aQuery = []
	@cProtocol = "HTTP/1.1"

	# Builds a request from its method, path, header pairs and body, and splits any query string off the path.
	#
	#   cMethodVal    the HTTP method as sent, such as GET
	#   cPathVal      the request target, possibly with a ?query part, which is removed from Path
	#   aHeadersVal   a list of [ name, value ] pairs
	#   cBodyVal      the body text
	#   returns       nothing; the object is built
	#   see           Path, Query, Header
	def init(cMethodVal, cPathVal, aHeadersVal, cBodyVal)
		@cMethod = cMethodVal
		@cPath = cPathVal
		@aHeaders = aHeadersVal
		@cBody = cBodyVal
		This.ParseQuery()

	# Returns the HTTP method exactly as it was given, without changing its case.
	#
	#   returns    a text such as GET
	#   see        Path, Protocol
	def Method()
		return @cMethod

	# Returns the path with the query string already removed.
	#
	#   returns    a text such as /users/42
	#   see        Query, Param
	def Path()
		return @cPath

	# Returns every header as a list of [ name, value ] pairs, in the order they arrived.
	#
	#   returns    a list of [ text, text ] pairs
	#   see        Header
	def Headers()
		return @aHeaders

	# Returns the value of the first header whose name matches, ignoring case.
	#
	#   cName      the header name, in any case
	#   returns    a text; an empty text when the header is absent
	#   see        Headers, WantsClose
	def Header(cName)
		_nLen_ = len(@aHeaders)
		for _i_ = 1 to _nLen_
			if StzLower(@aHeaders[_i_][1]) = StzLower(cName)
				return @aHeaders[_i_][2]
			ok
		next
		return ""

	# Returns the body text as it was given.
	#
	#   returns    a text
	#   see        Method
	def Body()
		return @cBody

	# Returns the protocol version of the request, HTTP/1.1 until SetProtocol says otherwise.
	#
	#   returns    a text such as HTTP/1.1
	#   see        SetProtocol, WantsClose
	def Protocol()
		return @cProtocol

	# Sets the protocol version that WantsClose reads.
	#
	#   cProtocolVal   the protocol text, such as HTTP/1.0
	#   returns        the request itself, so calls chain
	#   see            Protocol, WantsClose
	def SetProtocol(cProtocolVal)
		@cProtocol = cProtocolVal
		return This

	# TRUE if the peer asked for the connection to close after the response, by Connection: close or by being HTTP/1.0 without keep-alive.
	#
	#   returns    1 or 0, numbers
	#   see        Header, SetProtocol
	#@ aka  TRUE when this request asks the connection to be closed after the response (explicit Connection: close, or an HTTP/1.0 peer that did not opt into keep-alive).
	def WantsClose()
		_cConn_ = StzLower(This.Header("Connection"))
		if _cConn_ = "close"
			return 1
		ok
		if @cProtocol = "HTTP/1.0" and _cConn_ != "keep-alive"
			return 1
		ok
		return 0

	# Moves the ?key=value&key=value part of the path into the query pairs; init already did it, so a second call finds nothing to do.
	#
	#   returns    nothing
	#   note       the first occurrence wins when a key is repeated, as for Query
	#   warning    a pair without an equals sign is dropped; values are kept as sent, percent
	#              escapes are not decoded
	#   see        Query, Path
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

	# Returns the value of a query key, or every query pair when the key is empty.
	#
	#   cKey       the query key, matched with its exact case, or an empty text for all pairs
	#   returns    a text, an empty text for an absent key; a list of [ key, value ] pairs for the
	#              empty key
	#   note       a value is returned as it was sent: a%20b stays a%20b
	#   see        ParseQuery, Param
	def Query(cKey)
		if cKey = "" return @aQuery ok

		_nLen_ = len(@aQuery)
		for _i_ = 1 to _nLen_
			if @aQuery[_i_][1] = cKey
				return @aQuery[_i_][2]
			ok
		next
		return ""

	# Stores the path parameters that the router bound for this request, such as the id of /user/:id.
	#
	#   paParams   a list of [ name, value ] pairs
	#   returns    the request itself, so calls chain
	#   see        Params, Param
	#@ aka  Route path params (bound by the router: /user/:id -> Param("id")).
	def SetParams(paParams)
		@aParams = paParams
		return This

	# Returns the path parameters the router bound, as the list of [ name, value ] pairs.
	#
	#   returns    a list of [ text, text ] pairs; empty until SetParams is called
	#   see        Param, SetParams
	def Params()
		return @aParams

	# Returns the value of a path parameter by its exact name.
	#
	#   cKey       the parameter name, matched with its exact case
	#   returns    a text; an empty text for an absent name
	#   see        Params, Query
	def Param(cKey)
		_nLen_ = len(@aParams)
		for _i_ = 1 to _nLen_
			if @aParams[_i_][1] = cKey
				return @aParams[_i_][2]
			ok
		next
		return ""
