# Route table for stzAppServer. Beyond exact match, patterns support
# PATH PARAMS (/user/:id) and a trailing WILDCARD (/static/*):
#   /user/:id      matches /user/42       -> params id=42
#   /files/:a/:b   matches /files/x/y     -> params a=x, b=y
#   /static/*      matches /static/a/b.js -> params *=a/b.js
# Exact routes are tried first; among patterns, the first registered
# match wins. Attributes carry the @ scope sigil (bare class-head attrs
# capture same-named user globals in Ring 1.27, verified 2026-07-14).

# Holds the route table of the application server and finds the handler for a method and a path.
#
# Routes are matched exactly first, then by pattern: a :name segment captures one path segment and a
# trailing * captures the rest of the path. Among patterns the first registered wins, and the method
# must match too. The router returns the handler and the captured parameters and never calls the
# handler. Build it without parentheses, as in new stzAppRouter: with () the call raises R19.
#
#   receiver   o1 = new stzAppRouter
#   example    o1.AddRoute("get", "/user/:id", "showUser")
#              ? o1.MatchRoute("GET", "/user/42")[2][2]
#              #--> showUser
#              ? o1.MatchRoute("GET", "/user/42")[3][2][1][2]
#              #--> 42
#              ? o1.MatchRoute("GET", "/nothing")[1][2]
#              #--> 0
#   see        stzAppServer, stzAppRequest, stzAppResponse
class stzAppRouter from stzObject
	@aRoutes = []           # [ method, path-pattern, handler ]
	@aMiddleware = []
	@aStaticRoutes = []

	# Registers a handler for a method and a path pattern; the method is stored in upper case.
	#
	#   cMethod    the HTTP method in any case
	#   cPath      the path or pattern, such as /user/:id or /static/*
	#   fHandler   the handler to return on a match, a function or any value
	#   returns    nothing
	#   see        Routes, MatchRoute, HasRoute
	def AddRoute(cMethod, cPath, fHandler)
		@aRoutes + [ StzUpper("" + cMethod), "" + cPath, fHandler ]

	# Returns every registered route as [ method, pattern, handler ], in registration order.
	#
	#   returns    a list of three-item lists
	#   see        AddRoute, MatchRoute
	def Routes()
		return @aRoutes

	# TRUE if a route with exactly that method and exactly that path text was registered; a pattern is not matched, only compared.
	#
	#   cMethod    the HTTP method in any case
	#   cPath      the path text, compared as written
	#   returns    1 or 0, numbers
	#   see        MatchRoute, GetHandler
	#@ aka  Exact-only presence check (kept for back-compat / introspection).
	def HasRoute(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return 1
			ok
		next
		return 0

	# Returns the handler registered for exactly that method and path text, an empty text when there is none; patterns are not matched.
	#
	#   cMethod    the HTTP method in any case
	#   cPath      the path text, compared as written
	#   returns    the handler, or an empty text
	#   see        MatchRoute, HasRoute
	def GetHandler(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return @aRoutes[_i_][3]
			ok
		next
		return ""

	# Returns the route for a request: the exact path first, then :name and trailing * patterns, the first registered winning.
	#
	#   cMethod    the HTTP method in any case
	#   cPath      the request path without its query
	#   returns    a list [ matched, handler, params ]: matched is 1 or 0, params the list of [
	#              name, value ] pairs, with the key * for a wildcard
	#   note       the request path is read by its non-empty segments, so a trailing slash does not
	#              matter; a wildcard also matches nothing after its prefix and then captures an
	#              empty text
	#   see        AddRoute, GetHandler
	#@ aka  THE MATCHER: try exact, then patterns. Returns a hashlist [ :matched = TRUE/FALSE, :handler = f, :params = [ [name,val], ... ] ]
	def MatchRoute(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		# exact first (fast path, no capture)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return [ :matched = 1, :handler = @aRoutes[_i_][3], :params = [] ]
			ok
		next
		# pattern match
		_aReq_ = This._Segments(cPath)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] != _cM_  loop  ok
			if StzFindFirst(":", @aRoutes[_i_][2]) = 0 and
			   StzFindFirst("*", @aRoutes[_i_][2]) = 0
				loop   # plain route, already tried exactly
			ok
			_aParams_ = This._MatchPattern(This._Segments(@aRoutes[_i_][2]), _aReq_)
			if _aParams_ != ""
				return [ :matched = 1, :handler = @aRoutes[_i_][3], :params = _aParams_ ]
			ok
		next
		return [ :matched = 0, :handler = "", :params = [] ]

	# Split a path into non-empty segments: "/a/b" -> [ "a", "b" ].
	def _Segments(cPath)
		_aRaw_ = StzSplit("" + cPath, "/")
		_aOut_ = []
		_nLen_ = len(_aRaw_)
		for _i_ = 1 to _nLen_
			if _aRaw_[_i_] != ""
				_aOut_ + _aRaw_[_i_]
			ok
		next
		return _aOut_

	# Match pattern segments against request segments. Returns the
	# captured params list, or NULL when the pattern does not match.
	def _MatchPattern(aPat, aReq)
		_aParams_ = []
		_nP_ = len(aPat)
		for _i_ = 1 to _nP_
			_cSeg_ = aPat[_i_]
			if _cSeg_ = "*"
				# wildcard: capture the rest of the request path
				_cRest_ = ""
				for _j_ = _i_ to len(aReq)
					if _j_ > _i_  _cRest_ += "/"  ok
					_cRest_ += aReq[_j_]
				next
				_aParams_ + [ "*", _cRest_ ]
				return _aParams_
			ok
			if _i_ > len(aReq)
				return ""   # pattern longer than the request
			ok
			if StzLeft(_cSeg_, 1) = ":"
				_aParams_ + [ StzMidToEnd(_cSeg_, 2), aReq[_i_] ]
			but _cSeg_ != aReq[_i_]
				return ""   # literal mismatch
			ok
		next
		if len(aReq) != _nP_
			return ""   # request longer than a non-wildcard pattern
		ok
		return _aParams_

	# Stores a function for a path prefix, in registration order; the server runs the list before it routes a request.
	#
	#   cPath         the path prefix the middleware covers, as given to stzAppServer.Use
	#   fMiddleware   the name of the function to run before the routes
	#   returns       nothing; use AddMiddlewareQ to chain
	#   note          the router only stores the pair; stzAppServer reads it back with Middleware and
	#                 decides which entries cover a request
	#   see           Middleware, AddStaticRoute
	def AddMiddleware(cPath, fMiddleware)
		@aMiddleware + [ cPath, fMiddleware ]

		def AddMiddlewareQ(cPath, fMiddleware)
			This.AddMiddleware(cPath, fMiddleware)
			return This

	# Returns the stored functions that run before routing, as [ path prefix, function ] pairs in registration order.
	#
	#   returns    a list of two-item lists, empty when none was stored
	#   see        AddMiddleware, StaticRoutes
	def Middleware()
		return @aMiddleware

	# Stores a URL path prefix and the folder that backs it, in registration order; the server reads the list back.
	#
	#   cPath        the URL path prefix, as given to stzAppServer.Static
	#   cDirectory   the folder of files
	#   returns      nothing; use AddStaticRouteQ to chain
	#   note         the router only stores the pair; stzAppServer reads it back with StaticRoutes and
	#                does the serving
	#   see          StaticRoutes, AddMiddleware
	def AddStaticRoute(cPath, cDirectory)
		@aStaticRoutes + [ cPath, cDirectory ]

		def AddStaticRouteQ(cPath, cDirectory)
			This.AddStaticRoute(cPath, cDirectory)
			return This

	# Returns the folders mounted for file serving, as [ path prefix, folder ] pairs in registration order.
	#
	#   returns    a list of two-item lists, empty when none was stored
	#   see        AddStaticRoute, Middleware
	def StaticRoutes()
		return @aStaticRoutes
