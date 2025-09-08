class stzAppRouter
	aRoutes = []
	aMiddleware = []
	aStaticRoutes = []

	def AddRoute(cMethod, cPath, fHandler)
		aRoutes + [cMethod, cPath, fHandler]

	def HasRoute(cMethod, cPath)
		for aRoute in aRoutes
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return True
			ok
		next
		return False

	def GetHandler(cMethod, cPath)
		for aRoute in aRoutes
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return aRoute[3]
			ok
		next
		return NULL

	def AddMiddleware(cPath, fMiddleware)
		aMiddleware + [cPath, fMiddleware]

	def AddStaticRoute(cPath, cDirectory)
		aStaticRoutes + [cPath, cDirectory]
