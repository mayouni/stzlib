#=====================================================#
#  CONTEXT POOL FOR STZAPPSERCER - MEMORY MANAGEMENT  #
#=====================================================#

class stzContextPool
	aAvailable = []
	aActive = []
	nMaxContexts = 10

	def init()
		This.CreateInitialPool()

	def CreateInitialPool()
		for i = 1 to nMaxContexts
			aAvailable + new stzComputeContext()
		next

	def Acquire()
		if len(aAvailable) > 0
			oContext = aAvailable[1]
			del(aAvailable, 1)
			aActive + oContext
			return oContext
		else
			# Create new context if none available
			oContext = new stzComputeContext()
			aActive + oContext
			return oContext
		ok

	def Release(oContext)
		# Find and remove from active
		for i = 1 to len(aActive)
			if aActive[i] = oContext
				del(aActive, i)
				exit
			ok
		next
		
		# Reset context and return to available pool
		oContext.Reset()
		aAvailable + oContext

	def ActiveCount()
		return len(aActive)

	def AvailableCount()
		return len(aAvailable)


class stzComputeContext
	# Each context maintains its own Softanza workspace
	# while sharing the pre-loaded engine components

	def ExecuteHandler(fHandler, oRequest, oResponse)
		# Execute the handler with full Softanza context
		call fHandler(oRequest, oResponse)

	def Reset()
		# Clear any temporary state but keep engine loaded
