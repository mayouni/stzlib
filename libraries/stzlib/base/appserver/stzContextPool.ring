#=====================================================#
#  CONTEXT POOL FOR STZAPPSERCER - MEMORY MANAGEMENT  #
#=====================================================#
#
# RETIRED BY THE R7 COLLAPSE RULING (5.10, 2026-07-14): the "context"
# abstraction predates the resident Zig engine; pooled parallelism now
# lives in reactive/stzReactorPool (real loop threads). The class stays
# only so old scripts don't break at load time; the reactor-driven
# stzAppServer no longer references it.

class stzContextPool from stzObject
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
		_nActiveLen_ = len(aActive)
		for i = 1 to _nActiveLen_
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


class stzComputeContext from stzObject
	# Each context maintains its own Softanza workspace
	# while sharing the pre-loaded engine components

	def ExecuteHandler(fHandler, oRequest, oResponse)
		# Execute the handler with full Softanza context
		call fHandler(oRequest, oResponse)

	def Reset()
		# Clear any temporary state but keep engine loaded
