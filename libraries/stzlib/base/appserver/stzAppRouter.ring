class stzAppRouter from stzObject
	aRoutes = []
	aMiddleware = []
	aStaticRoutes = []

	def AddRoute(cMethod, cPath, fHandler)
		aRoutes + [cMethod, cPath, fHandler]

	def HasRoute(cMethod, cPath)
		_nRoutes2Len_ = len(aRoutes)
		for _iLoopRoutes2_ = 1 to _nRoutes2Len_
			aRoute = aRoutes[_iLoopRoutes2_]
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return True
			ok
		next
		return False

	def GetHandler(cMethod, cPath)
		_nRoutes1Len_ = len(aRoutes)
		for _iLoopRoutes1_ = 1 to _nRoutes1Len_
			aRoute = aRoutes[_iLoopRoutes1_]
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return aRoute[3]
			ok
		next
		return NULL

	def AddMiddleware(cPath, fMiddleware)
		aMiddleware + [cPath, fMiddleware]

	def AddStaticRoute(cPath, cDirectory)
		aStaticRoutes + [cPath, cDirectory]
