		return ring_find([ "lockaccount", "revokesession" ], StzLower("" + pcVerb)) > 0
	def LockAccount(pcTarget)
		This._Auth().LockAccount("" + pcTarget, "locked by a containment plan")
		if _i_ = 0
