# Exact-match method+path routing table for stzAppServer.
# Attributes carry the @ scope sigil -- bare class-head attributes
# capture same-named user globals in Ring 1.27 (verified 2026-07-14).

class stzAppRouter from stzObject
	@aRoutes = []
	@aMiddleware = []
	@aStaticRoutes = []

	def AddRoute(cMethod, cPath, fHandler)
		@aRoutes + [cMethod, cPath, fHandler]

	def Routes()
		return @aRoutes

	def HasRoute(cMethod, cPath)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = cMethod and @aRoutes[_i_][2] = cPath
				return True
			ok
		next
		return False

	def GetHandler(cMethod, cPath)
		_nLen_ = len(@aRoutes)
		for _i_ = 1 to _nLen_
			if @aRoutes[_i_][1] = cMethod and @aRoutes[_i_][2] = cPath
				return @aRoutes[_i_][3]
			ok
		next
		return NULL

	def AddMiddleware(cPath, fMiddleware)
		@aMiddleware + [cPath, fMiddleware]

	def AddStaticRoute(cPath, cDirectory)
		@aStaticRoutes + [cPath, cDirectory]
