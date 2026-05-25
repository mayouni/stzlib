#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTOPOLOGY                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Graph topology class backed by the          #
#                  Softanza Engine (stz_topology module).       #
#                  Nodes and edges with neighbor queries.       #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzTopologyQ()
	return new stzTopology()

func IsStzTopology(pObj)
	if isObject(pObj) and classname(pObj) = "stztopology"
		return 1
	else
		return 0
	ok

	func @IsStzTopology(pObj)
		return IsStzTopology(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTopology

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global topology store

	  #-------------------------------#
	 #     NODES AND EDGES           #
	#-------------------------------#

	def AddNode(cNode)
		if CheckingParams()
			if NOT isString(cNode) or cNode = ""
				StzRaise("Incorrect param! cNode must be a non-empty string.")
			ok
		ok

		nResult = StzEngineTopoAddNode(cNode)
		if nResult < 0
			StzRaise("Can't add node! Node slots full or duplicate.")
		ok

		def AddNodeQ(cNode)
			This.AddNode(cNode)
			return This

	def AddEdge(cNodeA, cNodeB)
		if CheckingParams()
			if NOT isString(cNodeA) or NOT isString(cNodeB)
				StzRaise("Incorrect params! cNodeA and cNodeB must be strings.")
			ok
		ok

		nResult = StzEngineTopoAddEdge(cNodeA, cNodeB)
		if nResult < 0
			StzRaise("Can't add edge! Nodes not found or edge slots full.")
		ok

		def AddEdgeQ(cNodeA, cNodeB)
			This.AddEdge(cNodeA, cNodeB)
			return This

	def AreNeighbors(cNodeA, cNodeB)
		nResult = StzEngineTopoAreNeighbors(cNodeA, cNodeB)
		if nResult = 1
			return 1
		else
			return 0
		ok

		def AreConnected(cNodeA, cNodeB)
			return This.AreNeighbors(cNodeA, cNodeB)

	def NeighborCount(cNode)
		return StzEngineTopoNeighborCount(cNode)

		def NumberOfNeighbors(cNode)
			return This.NeighborCount(cNode)

	def NodeCount()
		return StzEngineTopoNodeCount()

		def NumberOfNodes()
			return This.NodeCount()

	def IsConnected()
		nResult = StzEngineTopoConnected()
		if nResult = 1
			return 1
		else
			return 0
		ok

	  #-------------------------------#
	 #     REMOVAL AND CLEANUP       #
	#-------------------------------#

	def RemoveNode(cNode)
		nResult = StzEngineTopoRemoveNode(cNode)
		if nResult < 0
			StzRaise("Node '" + cNode + "' not found!")
		ok

	def Clear()
		StzEngineTopoClear()
