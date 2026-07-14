# Route table for stzAppServer. Beyond exact match, patterns support
# PATH PARAMS (/user/:id) and a trailing WILDCARD (/static/*):
#   /user/:id      matches /user/42       -> params id=42
#   /files/:a/:b   matches /files/x/y     -> params a=x, b=y
#   /static/*      matches /static/a/b.js -> params *=a/b.js
# Exact routes are tried first; among patterns, the first registered
# match wins. Attributes carry the @ scope sigil (bare class-head attrs
# capture same-named user globals in Ring 1.27, verified 2026-07-14).

class stzAppRouter from stzObject
	@aRoutes = []           # [ method, path-pattern, handler ]
	@aMiddleware = []
	@aStaticRoutes = []

	def AddRoute(cMethod, cPath, fHandler)
		@aRoutes + [ StzUpper("" + cMethod), "" + cPath, fHandler ]

	def Routes()
		return @aRoutes

	# Exact-only presence check (kept for back-compat / introspection).
	def HasRoute(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return True
			ok
		next
		return False

	def GetHandler(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return @aRoutes[_i_][3]
			ok
		next
		return NULL

	# THE MATCHER: try exact, then patterns. Returns a hashlist
	#   [ :matched = TRUE/FALSE, :handler = f, :params = [ [name,val], ... ] ]
	def MatchRoute(cMethod, cPath)
		_cM_ = StzUpper("" + cMethod)
		# exact first (fast path, no capture)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = _cM_ and @aRoutes[_i_][2] = cPath
				return [ :matched = TRUE, :handler = @aRoutes[_i_][3], :params = [] ]
			ok
		next
		# pattern match
		_aReq_ = This._Segments(cPath)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] != _cM_  loop  ok
			if StzFindFirst(@aRoutes[_i_][2], ":") = 0 and
			   StzFindFirst(@aRoutes[_i_][2], "*") = 0
				loop   # plain route, already tried exactly
			ok
			_aParams_ = This._MatchPattern(This._Segments(@aRoutes[_i_][2]), _aReq_)
			if _aParams_ != NULL
				return [ :matched = TRUE, :handler = @aRoutes[_i_][3], :params = _aParams_ ]
			ok
		next
		return [ :matched = FALSE, :handler = NULL, :params = [] ]

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
				return NULL   # pattern longer than the request
			ok
			if StzLeft(_cSeg_, 1) = ":"
				_aParams_ + [ StzMidToEnd(_cSeg_, 2), aReq[_i_] ]
			but _cSeg_ != aReq[_i_]
				return NULL   # literal mismatch
			ok
		next
		if len(aReq) != _nP_
			return NULL   # request longer than a non-wildcard pattern
		ok
		return _aParams_

	def AddMiddleware(cPath, fMiddleware)
		@aMiddleware + [ cPath, fMiddleware ]

	def AddStaticRoute(cPath, cDirectory)
		@aStaticRoutes + [ cPath, cDirectory ]
